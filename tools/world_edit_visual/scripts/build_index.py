#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import argparse
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
OUT_DIR = TOOL_ROOT / "out"
INDEX = TOOL_ROOT / "index.md"


class WorkbenchIndexBuilder:
    """Build a local Markdown review sheet from runtime reports.

    The index is generated output, not source. Links are written relative to the
    index file because the sheet lives in `tools/world_edit_visual` while the
    canonical DreamDaemon artifacts live under repo-root `tools/world_edit_visual`.
    """

    def __init__(self, out_dir: Path = OUT_DIR, index_path: Path = INDEX) -> None:
        self.out_dir = out_dir
        self.index_path = index_path

    def build(self) -> None:
        rows = [
            "| Case | Status | Errors | Semantic | Sprites | ASCII | Report |",
            "| --- | --- | ---: | --- | --- | --- | --- |",
        ]
        for case_dir in self.case_dirs():
            report_path = case_dir / "report.json"
            report = self.load_report(report_path)
            workflow_error = self.load_report(case_dir / "workflow.error.json")
            if not report and not workflow_error:
                continue
            errors = len(report.get("errors") or [])
            if workflow_error:
                errors = max(errors, 1)
            status = "workflow_error" if workflow_error else report.get("status", "unknown")
            semantic_cell = "-" if workflow_error else self.link_if_exists(case_dir / "semantic.png", "semantic.png")
            sprite_cell = "-" if workflow_error else self.sprite_cell(case_dir)
            ascii_cell = "-" if workflow_error else self.link_if_exists(case_dir / "ascii_dump.txt", "ascii_dump.txt")
            report_cell = self.workflow_error_cell(case_dir) if workflow_error else self.report_cell(case_dir, report_path)
            rows.append(
                f"| {case_dir.name} | {status} | {errors} | "
                f"{semantic_cell} | "
                f"{sprite_cell} | "
                f"{ascii_cell} | "
                f"{report_cell} |"
            )
        self.index_path.parent.mkdir(parents=True, exist_ok=True)
        self.index_path.write_text("# World Edit Visual Workbench\n\n" + "\n".join(rows) + "\n", encoding="utf-8")

    def case_dirs(self) -> list[Path]:
        if not self.out_dir.exists():
            return []
        return [case_dir for case_dir in sorted(self.out_dir.iterdir()) if case_dir.is_dir()]

    @staticmethod
    def load_report(report_path: Path) -> dict:
        if not report_path.exists():
            return {}
        return json.loads(report_path.read_text(encoding="utf-8-sig"))

    def link_to(self, target: Path) -> str:
        """Return a Markdown-friendly path from index.md to a runtime artifact."""

        return Path(os.path.relpath(target, self.index_path.parent)).as_posix()

    def link_if_exists(self, target: Path, label: str) -> str:
        if not target.exists():
            return "-"
        return f"[{label}]({self.link_to(target)})"

    def sprite_cell(self, case_dir: Path) -> str:
        sprite_png = case_dir / "semantic_sprites.png"
        if sprite_png.exists():
            return self.link_if_exists(sprite_png, "semantic_sprites.png")
        links = []
        error_txt = case_dir / "semantic_sprites.error.txt"
        error_json = case_dir / "semantic_sprites.error.json"
        if error_txt.exists():
            links.append(self.link_if_exists(error_txt, "sprite error"))
        if error_json.exists():
            links.append(self.link_if_exists(error_json, "json"))
        return " / ".join(links) if links else "-"

    def report_cell(self, case_dir: Path, report_path: Path) -> str:
        links = []
        if report_path.exists():
            links.append(self.link_if_exists(report_path, "report.json"))
        links.extend(self.workflow_error_links(case_dir))
        return " / ".join(links) if links else "-"

    def workflow_error_cell(self, case_dir: Path) -> str:
        links = self.workflow_error_links(case_dir)
        return " / ".join(links) if links else "-"

    def workflow_error_links(self, case_dir: Path) -> list[str]:
        links = []
        workflow_txt = case_dir / "workflow.error.txt"
        workflow_json = case_dir / "workflow.error.json"
        if workflow_txt.exists():
            links.append(self.link_if_exists(workflow_txt, "workflow error"))
        if workflow_json.exists():
            links.append(self.link_if_exists(workflow_json, "json"))
        return links


def main() -> int:
    parser = argparse.ArgumentParser(description="Build World Edit Visual index.md from runtime reports.")
    parser.add_argument("--out-dir", default=OUT_DIR, type=Path)
    parser.add_argument("--index", default=INDEX, type=Path)
    args = parser.parse_args()

    WorkbenchIndexBuilder(args.out_dir, args.index).build()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
