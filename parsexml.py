#!/usr/bin/env python3
"""Parse XML workflow definitions and create a unified JSON structure."""

import json
import os
import xml.etree.ElementTree as ET
from pathlib import Path


def parse_workflow_xml(filepath: str) -> dict | None:
    """Parse a single workflow XML file and extract workflow data."""
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"Error parsing {filepath}: {e}")
        return None

    ns = {"wf": "http://pdbml.wwpdb.org/schema-wf"}

    workflow = {
        "id": "",
        "name": "",
        "filename": os.path.basename(filepath),
        "description": "",
        "artifacts": [],
        "tasks": [],
    }

    # Parse metadata
    version_elem = root.find(".//wf:metadata/wf:version", ns)
    if version_elem is not None:
        workflow["id"] = version_elem.get("id", "")
        workflow["name"] = version_elem.get("name", "")

    # Parse description
    subtext_elem = root.find(".//wf:metadata/wf:description/wf:subtext", ns)
    if subtext_elem is not None and subtext_elem.text:
        workflow["description"] = subtext_elem.text.strip()

    # Parse data objects (artifacts)
    data_objects = root.findall(".//wf:workflow/wf:dataObjects/wf:dataObject", ns)
    for obj in data_objects:
        artifact = {
            "id": obj.get("dataID", ""),
            "filetype": "",
            "location": "",
            "version": "",
        }

        location_elem = obj.find("wf:location", ns)
        if location_elem is not None:
            content = location_elem.get("content", "")
            fmt = location_elem.get("format", "")
            artifact["filetype"] = f"{content}.{fmt}" if content and fmt else content or fmt
            artifact["location"] = location_elem.get("where", "")
            artifact["version"] = location_elem.get("version", "")

        workflow["artifacts"].append(artifact)

    # Parse tasks
    tasks = root.findall(".//wf:flow/wf:tasks/wf:task", ns)
    for task_elem in tasks:
        task = {
            "id": task_elem.get("taskID", ""),
            "name": task_elem.get("name", ""),
            "action": "",
            "next": task_elem.get("nextTask", ""),
            "timeout": "",
            "inputs": [],
            "outputs": [],
        }

        # Parse process details
        process_elem = task_elem.find("wf:process", ns)
        if process_elem is not None:
            task["timeout"] = process_elem.get("failTime", "")

            detail_elem = process_elem.find("wf:detail", ns)
            if detail_elem is not None:
                task["action"] = detail_elem.get("action", "")

            # Parse data objects locations for inputs/outputs
            locations = process_elem.findall("wf:dataObjectsLocation/wf:location", ns)
            for loc in locations:
                data_id = loc.get("dataID", "")
                loc_type = loc.get("type", "")

                if "input" in loc_type.lower():
                    task["inputs"].append(data_id)
                elif "output" in loc_type.lower():
                    task["outputs"].append(data_id)

        workflow["tasks"].append(task)

    return workflow


def main():
    wf_defs_dir = Path(__file__).parent / "wfe" / "wf-defs"

    if not wf_defs_dir.exists():
        print(f"Directory not found: {wf_defs_dir}")
        return

    workflows = []

    for xml_file in sorted(wf_defs_dir.glob("*.xml")):
        # Skip symlinks
        if xml_file.is_symlink():
            print(f"Skipping symlink: {xml_file.name}")
            continue

        print(f"Parsing: {xml_file.name}")
        workflow = parse_workflow_xml(str(xml_file))
        if workflow:
            workflows.append(workflow)

    # Write to JSON file
    output_file = Path(__file__).parent / "workflows.json"
    with open(output_file, "w") as f:
        json.dump(workflows, f, indent=2)

    print(f"\nGenerated {output_file} with {len(workflows)} workflows")


if __name__ == "__main__":
    main()