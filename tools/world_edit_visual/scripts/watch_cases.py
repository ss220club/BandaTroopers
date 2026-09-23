#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
REPO_ROOT = SCRIPT_DIR.parents[2]
OUT_DIR = TOOL_ROOT / "out"


class SemanticRenderWatcher:
    """Watch runtime output folders and render completed semantic exports."""

    def __init__(
        self,
        out_dir: Path = OUT_DIR,
        poll_seconds: float = 0.5,
        index_path: Path = TOOL_ROOT / "index.md",
        allow_schematic_fallback: bool = False,
    ) -> None:
        self.out_dir = out_dir
        self.poll_seconds = poll_seconds
        self.index_path = index_path
        self.allow_schematic_fallback = allow_schematic_fallback
        self.seen: dict[Path, float] = {}
        self.failure_count = 0

    def watch(self, once: bool = False) -> int:
        while True:
            self.render_ready_cases()
            if once:
                return 1 if self.failure_count else 0
            time.sleep(self.poll_seconds)

    def render_ready_cases(self) -> None:
        for case_dir in self.case_dirs():
            semantic = case_dir / "semantic.json"
            if not semantic.exists():
                continue
            stamp = semantic.stat().st_mtime
            if self.seen.get(semantic) == stamp:
                continue
            self.render_case(case_dir)
            self.seen[semantic] = stamp

    def case_dirs(self) -> list[Path]:
        if not self.out_dir.exists():
            return []
        return [case_dir for case_dir in sorted(self.out_dir.iterdir()) if case_dir.is_dir()]

    def render_case(self, case_dir: Path) -> None:
        start = time.perf_counter()
        cmd = [
            sys.executable,
            str(SCRIPT_DIR / "render_all.py"),
            "--out-dir",
            str(self.out_dir),
            "--index",
            str(self.index_path),
            "--case",
            case_dir.name,
        ]
        if self.allow_schematic_fallback:
            cmd.append("--allow-schematic-fallback")

        status: dict[str, object] = {"case_id": case_dir.name}
        try:
            subprocess.run(cmd, cwd=REPO_ROOT, check=True)
            status["status"] = "ok"
        except subprocess.CalledProcessError as exc:
            self.failure_count += 1
            status["status"] = "error"
            status["exit_code"] = exc.returncode
            status["message"] = "render_all.py failed; see console output for exact renderer errors"
        finally:
            status["semantic_render_ms"] = int((time.perf_counter() - start) * 1000)
            (case_dir / "external_profile.json").write_text(
                json.dumps(status, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )


def main() -> int:
    parser = argparse.ArgumentParser(description="Watch World Edit Visual out/ and render changed cases.")
    parser.add_argument("--out-dir", default=OUT_DIR, type=Path)
    parser.add_argument("--poll-seconds", default=0.5, type=float)
    parser.add_argument("--index", default=TOOL_ROOT / "index.md", type=Path)
    parser.add_argument("--once", action="store_true", help="Render currently ready cases once and exit")
    parser.add_argument(
        "--allow-schematic-fallback",
        action="store_true",
        help="Developer/debug only: pass placeholder fallback flag through to sprite rendering",
    )
    args = parser.parse_args()

    watcher = SemanticRenderWatcher(
        out_dir=args.out_dir,
        poll_seconds=args.poll_seconds,
        index_path=args.index,
        allow_schematic_fallback=args.allow_schematic_fallback,
    )
    return watcher.watch(once=args.once)


if __name__ == "__main__":
    raise SystemExit(main())
