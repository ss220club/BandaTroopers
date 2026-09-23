#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from crop_bounds import DEFAULT_CROP_PADDING


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
REPO_ROOT = SCRIPT_DIR.parents[2]
DEFAULT_OUT_DIR = TOOL_ROOT / "out"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(line_buffering=True)


class RenderAll:
    def __init__(
        self,
        out_dir: Path,
        case_ids: list[str],
        render_semantic: bool,
        render_sprites: bool,
        render_ascii: bool,
        build_index: bool,
        index_path: Path,
        allow_schematic_fallback: bool,
        full_canvas: bool,
        crop_padding: int,
    ) -> None:
        self.out_dir = out_dir
        self.case_ids = case_ids
        self.render_semantic = render_semantic
        self.render_sprites = render_sprites
        self.render_ascii = render_ascii
        self.build_index = build_index
        self.index_path = index_path
        self.allow_schematic_fallback = allow_schematic_fallback
        self.full_canvas = full_canvas
        self.crop_padding = crop_padding
        self.failures: list[str] = []
        self.rendered = 0
        self.skipped = 0

    def run(self) -> int:
        for case_dir in self.case_dirs():
            if not (case_dir / "semantic.json").exists():
                self.skipped += 1
                print(f"[skip] {case_dir.name}: semantic.json not found")
                continue
            self.render_case(case_dir)

        if self.build_index:
            self.run_step(
                "index",
                [
                    sys.executable,
                    str(SCRIPT_DIR / "build_index.py"),
                    "--out-dir",
                    str(self.out_dir),
                    "--index",
                    str(self.index_path),
                ],
            )

        print(
            f"render_all: rendered={self.rendered} skipped={self.skipped} "
            f"failures={len(self.failures)}"
        )
        if self.failures:
            print("Failures:")
            for failure in self.failures:
                print(f"- {failure}")
            return 1
        return 0

    def case_dirs(self) -> list[Path]:
        if self.case_ids:
            return [self.out_dir / case_id for case_id in self.case_ids]
        if not self.out_dir.exists():
            return []
        return [case_dir for case_dir in sorted(self.out_dir.iterdir()) if case_dir.is_dir()]

    def render_case(self, case_dir: Path) -> None:
        print(f"[case] {case_dir.name}")
        report = case_dir / "report.json"
        semantic = case_dir / "semantic.json"
        for workflow_error in (case_dir / "workflow.error.txt", case_dir / "workflow.error.json"):
            if workflow_error.exists():
                workflow_error.unlink()

        if self.render_semantic:
            cmd = [
                sys.executable,
                str(SCRIPT_DIR / "render_semantic.py"),
                "--semantic-json",
                str(semantic),
                "--out",
                str(case_dir / "semantic.png"),
                *self.crop_args(),
            ]
            if report.exists():
                cmd.extend(["--report-json", str(report)])
            self.run_step(case_dir.name, cmd)

        if self.render_sprites:
            self.run_sprite_step(case_dir, semantic)

        if self.render_ascii:
            cmd = [
                sys.executable,
                str(SCRIPT_DIR / "render_ascii_map.py"),
                "--semantic-json",
                str(semantic),
                *self.crop_args(),
            ]
            if report.exists():
                cmd.extend(["--report-json", str(report)])
            self.run_ascii_step(case_dir, cmd)

        self.rendered += 1

    def run_sprite_step(self, case_dir: Path, semantic: Path) -> None:
        output = case_dir / "semantic_sprites.png"
        temp_output = case_dir / "semantic_sprites.tmp.png"
        error_txt = case_dir / "semantic_sprites.error.txt"
        error_json = case_dir / "semantic_sprites.error.json"

        if temp_output.exists():
            temp_output.unlink()

        cmd = [
            sys.executable,
            str(SCRIPT_DIR / "render_sprites.py"),
            "--semantic-json",
            str(semantic),
            "--output",
            str(temp_output),
            *self.crop_args(),
        ]
        if self.allow_schematic_fallback:
            cmd.append("--allow-schematic-fallback")

        try:
            completed = subprocess.run(
                cmd,
                cwd=REPO_ROOT,
                check=True,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
                errors="replace",
            )
        except subprocess.CalledProcessError as exc:
            if temp_output.exists():
                temp_output.unlink()
            deleted_sprite_mtime = None
            if output.exists():
                deleted_sprite_mtime = output.stat().st_mtime
                output.unlink()
            error_payload = self.sprite_error_payload(
                case_dir=case_dir,
                semantic=semantic,
                output=output,
                cmd=cmd,
                exit_code=exc.returncode,
                stdout=exc.stdout or "",
                stderr=exc.stderr or "",
                deleted_sprite_mtime=deleted_sprite_mtime,
            )
            error_json.write_text(json.dumps(error_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            error_txt.write_text(self.sprite_error_text(error_payload), encoding="utf-8")
            self.failures.append(
                f"{case_dir.name}: sprite render failed; stale semantic_sprites.png "
                f"{'deleted' if deleted_sprite_mtime is not None else 'was absent'}; see {error_txt}"
            )
            print(f"[sprites:error] {case_dir.name}: see {error_txt}")
            return

        if not temp_output.exists():
            deleted_sprite_mtime = None
            if output.exists():
                deleted_sprite_mtime = output.stat().st_mtime
                output.unlink()
            error_payload = self.sprite_error_payload(
                case_dir=case_dir,
                semantic=semantic,
                output=output,
                cmd=cmd,
                exit_code=1,
                stdout=completed.stdout or "",
                stderr=(completed.stderr or "") + "\nrender_sprites.py exited 0 but did not create temp output",
                deleted_sprite_mtime=deleted_sprite_mtime,
            )
            error_json.write_text(json.dumps(error_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            error_txt.write_text(self.sprite_error_text(error_payload), encoding="utf-8")
            self.failures.append(f"{case_dir.name}: sprite render produced no temp output; see {error_txt}")
            print(f"[sprites:error] {case_dir.name}: no temp output")
            return

        temp_output.replace(output)
        for error_file in (error_txt, error_json):
            if error_file.exists():
                error_file.unlink()
        if completed.stdout:
            print(completed.stdout.rstrip())
        if completed.stderr:
            print(completed.stderr.rstrip(), file=sys.stderr)
        print(f"[sprites:ok] {case_dir.name}: {output}")

    def crop_args(self) -> list[str]:
        args = ["--crop-padding", str(self.crop_padding)]
        if self.full_canvas:
            args.append("--full-canvas")
        return args

    def sprite_error_payload(
        self,
        case_dir: Path,
        semantic: Path,
        output: Path,
        cmd: list[str],
        exit_code: int,
        stdout: str,
        stderr: str,
        deleted_sprite_mtime: float | None,
    ) -> dict:
        semantic_mtime = semantic.stat().st_mtime if semantic.exists() else None
        return {
            "case_id": case_dir.name,
            "status": "error",
            "kind": "semantic_sprites_render_failed",
            "message": "semantic_sprites.png could not be rendered from the current semantic.json.",
            "recommended_fix": (
                "Read stderr for the exact icon/state/case. If the semantic export is stale, run the "
                "World Edit Visual Render action again; otherwise fix the missing DMI appearance."
            ),
            "created_at": datetime.now(timezone.utc).isoformat(),
            "semantic_json": str(semantic),
            "semantic_mtime": semantic_mtime,
            "sprite_png": str(output),
            "deleted_stale_sprite": deleted_sprite_mtime is not None,
            "deleted_stale_sprite_mtime": deleted_sprite_mtime,
            "command": cmd,
            "exit_code": exit_code,
            "stdout": self.trim_output(stdout),
            "stderr": self.trim_output(stderr),
        }

    def sprite_error_text(self, payload: dict) -> str:
        lines = [
            "semantic_sprites.png render failed",
            f"case: {payload['case_id']}",
            f"semantic_json: {payload['semantic_json']}",
            f"semantic_mtime: {payload['semantic_mtime']}",
            f"deleted_stale_sprite: {payload['deleted_stale_sprite']}",
            f"exit_code: {payload['exit_code']}",
            "",
            str(payload["message"]),
            str(payload["recommended_fix"]),
            "",
        ]
        if payload.get("stderr"):
            lines.extend(["stderr:", str(payload["stderr"]), ""])
        if payload.get("stdout"):
            lines.extend(["stdout:", str(payload["stdout"]), ""])
        return "\n".join(lines)

    @staticmethod
    def trim_output(text: str, limit: int = 4000) -> str:
        if len(text) <= limit:
            return text
        return text[:limit] + f"\n... truncated {len(text) - limit} characters"

    def run_step(self, label: str, cmd: list[str]) -> None:
        try:
            subprocess.run(cmd, cwd=REPO_ROOT, check=True)
        except subprocess.CalledProcessError as exc:
            self.failures.append(f"{label}: {' '.join(cmd)} exited {exc.returncode}")

    def run_ascii_step(self, case_dir: Path, cmd: list[str]) -> None:
        try:
            completed = subprocess.run(
                cmd,
                cwd=REPO_ROOT,
                check=True,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
                errors="replace",
            )
        except subprocess.CalledProcessError as exc:
            if exc.stdout:
                print(exc.stdout)
            if exc.stderr:
                print(exc.stderr, file=sys.stderr)
            self.failures.append(f"{case_dir.name}: ASCII render exited {exc.returncode}")
            return
        ascii_path = case_dir / "ascii_dump.txt"
        ascii_path.write_text(completed.stdout, encoding="utf-8")
        if completed.stderr:
            print(completed.stderr, file=sys.stderr)


def main() -> int:
    parser = argparse.ArgumentParser(description="Render all completed World Edit Visual cases.")
    parser.add_argument("--out-dir", default=DEFAULT_OUT_DIR, type=Path)
    parser.add_argument("--case", action="append", default=[], help="Only render this case id; may repeat")
    parser.add_argument("--no-semantic", action="store_true", help="Do not render semantic.png")
    parser.add_argument("--no-sprites", action="store_true", help="Do not render semantic_sprites.png")
    parser.add_argument("--no-ascii", action="store_true", help="Do not render ascii_dump.txt")
    parser.add_argument("--no-index", action="store_true", help="Do not rebuild index.md")
    parser.add_argument("--index", default=TOOL_ROOT / "index.md", type=Path, help="Path for generated index.md")
    parser.add_argument(
        "--allow-schematic-fallback",
        action="store_true",
        help="Developer/debug only: pass placeholder fallback flag through to render_sprites.py",
    )
    parser.add_argument("--full-canvas", action="store_true", help="Render complete semantic canvases instead of cropped views")
    parser.add_argument("--crop-padding", default=DEFAULT_CROP_PADDING, type=int, help="Tiles to keep around useful content")
    args = parser.parse_args()

    runner = RenderAll(
        out_dir=args.out_dir,
        case_ids=args.case,
        render_semantic=not args.no_semantic,
        render_sprites=not args.no_sprites,
        render_ascii=not args.no_ascii,
        build_index=not args.no_index,
        index_path=args.index,
        allow_schematic_fallback=args.allow_schematic_fallback,
        full_canvas=args.full_canvas,
        crop_padding=args.crop_padding,
    )
    return runner.run()


if __name__ == "__main__":
    raise SystemExit(main())
