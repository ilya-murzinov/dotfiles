#!/usr/bin/env python3
"""Convert Apple Notes RTF exports to Markdown files for Obsidian.

Usage:
    python apple-notes-to-md.py /path/to/notes/folder
    python apple-notes-to-md.py  # uses current directory
"""

import argparse
import sys
from pathlib import Path

from striprtf.striprtf import rtf_to_text


def convert_notes(source_dir: Path) -> None:
    folders = [p for p in source_dir.iterdir() if p.is_dir()]

    if not folders:
        print("No folders found.")
        return

    converted = 0
    skipped = 0

    for folder in sorted(folders):
        rtf_file = folder / "TXT.rtf"
        if not rtf_file.exists():
            skipped += 1
            continue

        output_file = source_dir / f"{folder.name}.md"
        rtf_content = rtf_file.read_bytes().decode("utf-8", errors="ignore")
        text = rtf_to_text(rtf_content).strip()

        output_file.write_text(text, encoding="utf-8")
        print(f"  {folder.name}.md")
        converted += 1

    print(f"\nDone: {converted} converted, {skipped} skipped (no TEXT.rtf).")


def main():
    parser = argparse.ArgumentParser(
        description="Convert Apple Notes RTF exports to Markdown for Obsidian."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory containing note folders (default: current directory)",
    )
    args = parser.parse_args()

    source_dir = Path(args.directory).resolve()
    if not source_dir.is_dir():
        print(f"Error: '{source_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    convert_notes(source_dir)


if __name__ == "__main__":
    main()
