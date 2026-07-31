#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
import shutil
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
RUNTIME_ROOT = SCRIPT_DIR.parent
SAFE_ID = re.compile(r"[^A-Za-z0-9_.-]+")


class CasePreparer:
    """Prepare runtime state before DreamDaemon starts.

    DM-side code only checks that directories exist; it does not shell out to
    mkdir during early startup. Keeping directory creation here makes repeated
    local runs predictable and avoids hanging the headless runtime on platform
    quoting issues.
    """

    def __init__(self, runtime_root: Path = RUNTIME_ROOT) -> None:
        self.runtime_root = runtime_root
        self.inbox_dir = runtime_root / "inbox"
        self.out_dir = runtime_root / "out"

    def prepare(
        self,
        case_paths: list[Path],
        workflow_run_id: str | None = None,
        source_sha: str | None = None,
    ) -> None:
        self.ensure_runtime_dirs()
        self.clear_inbox()
        for case_path in case_paths:
            case_id = self.case_id(case_path)
            (self.out_dir / case_id).mkdir(parents=True, exist_ok=True)
            self.write_inbox_case(case_path, workflow_run_id, source_sha)

    def ensure_runtime_dirs(self) -> None:
        self.inbox_dir.mkdir(parents=True, exist_ok=True)
        self.out_dir.mkdir(parents=True, exist_ok=True)

    def clear_inbox(self) -> None:
        for case_path in self.inbox_dir.glob("*.json"):
            if case_path.is_file():
                case_path.unlink()

    def write_inbox_case(
        self,
        case_path: Path,
        workflow_run_id: str | None,
        source_sha: str | None,
    ) -> None:
        target = self.inbox_dir / case_path.name
        if not workflow_run_id and not source_sha:
            shutil.copy2(case_path, target)
            return
        try:
            with case_path.open("r", encoding="utf-8-sig") as handle:
                data = json.load(handle)
        except (OSError, json.JSONDecodeError):
            shutil.copy2(case_path, target)
            return
        if not isinstance(data, dict):
            shutil.copy2(case_path, target)
            return
        if workflow_run_id:
            data["workflow_run_id"] = workflow_run_id
        if source_sha:
            data["source_sha"] = source_sha
        target.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    def case_id(self, case_path: Path) -> str:
        """Return the output folder name the DM runtime will expect.

        Invalid JSON still gets a fallback directory based on the filename so
        the workbench can write a structured `invalid_json_case` report instead
        of failing because the output directory is missing.
        """

        try:
            with case_path.open("r", encoding="utf-8-sig") as handle:
                data = json.load(handle)
        except (OSError, json.JSONDecodeError):
            data = {}
        raw_id = str(data.get("id") or case_path.stem)
        safe_id = SAFE_ID.sub("_", raw_id).strip("._")
        return safe_id or case_path.stem


def expand_cases(raw_paths: list[str]) -> list[Path]:
    paths: list[Path] = []
    for raw_path in raw_paths:
        path = Path(raw_path)
        if path.is_dir():
            paths.extend(sorted(path.rglob("*.json")))
        else:
            paths.append(path)
    return paths


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workflow-run-id")
    parser.add_argument("--source-sha")
    parser.add_argument("cases", nargs="+")
    args = parser.parse_args()

    CasePreparer().prepare(
        expand_cases(args.cases),
        workflow_run_id=args.workflow_run_id,
        source_sha=args.source_sha,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
