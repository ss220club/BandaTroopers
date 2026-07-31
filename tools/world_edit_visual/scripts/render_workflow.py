#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

from crop_bounds import DEFAULT_CROP_PADDING
from prepare_cases import CasePreparer, expand_cases


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
REPO_ROOT = SCRIPT_DIR.parents[2]
DEFAULT_CASES_DIR = TOOL_ROOT / "cases"
DEFAULT_OUT_DIR = TOOL_ROOT / "out"
DEFAULT_RUNTIME_LOG = TOOL_ROOT / "runtime.log"
DEFAULT_WORKFLOW_LOG = TOOL_ROOT / "workflow.log"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(line_buffering=True)


class RenderWorkflow:
    def __init__(
        self,
        case_paths: list[Path],
        timeout_seconds: int,
        poll_seconds: float,
        render_ascii: bool,
        dry_run_runtime: bool,
        isolated: bool,
        full_canvas: bool,
        crop_padding: int,
        verbose: bool,
    ) -> None:
        self.case_paths = case_paths
        self.timeout_seconds = timeout_seconds
        self.poll_seconds = poll_seconds
        self.render_ascii = render_ascii
        self.dry_run_runtime = dry_run_runtime
        self.isolated = isolated
        self.full_canvas = full_canvas
        self.crop_padding = crop_padding
        self.verbose = verbose
        self.log_handle = None
        self.preparer = CasePreparer()
        self.workflow_run_id = ""
        self.source_sha = self.resolve_source_sha()

    def run(self) -> int:
        self.start_log()
        try:
            self.info("World Edit Visual render")
            self.info(f"Details: {self.display_path(DEFAULT_WORKFLOW_LOG)}")
            if not self.source_sha:
                self.info("Cannot resolve the repository HEAD for SHA-bound artifacts.")
                return 1
            self.debug(f"Source SHA: {self.source_sha}")
            if not self.case_paths:
                self.info("No cases found.")
                return 1

            case_paths = self.deduplicated_case_paths()
            self.info(f"Cases: {len(case_paths)}")
            if self.isolated:
                return self.run_isolated(case_paths)
            return self.run_batch(case_paths)
        finally:
            self.close_log()

    def run_batch(self, case_paths: list[Path]) -> int:
        case_ids = [self.preparer.case_id(case_path) for case_path in case_paths]
        self.workflow_run_id = self.create_workflow_run_id()
        self.info("Mode: batch")
        self.debug("Runtime: one DreamDaemon run for this selection.")
        self.debug(f"Workflow run id: {self.workflow_run_id}")

        for case_id in case_ids:
            self.clear_case_artifacts(case_id)
        self.preparer.prepare(case_paths, workflow_run_id=self.workflow_run_id, source_sha=self.source_sha)

        failures: list[str] = []
        rendered = 0
        runtime_result, runtime_log = self.ensure_runtime()
        if runtime_result != 0:
            for case_id in case_ids:
                self.write_workflow_error(
                    case_id,
                    kind="runtime_start_failed",
                    message="DreamDaemon could not be restarted for this render run.",
                    details={
                        "mode": "batch",
                        "runtime_output": runtime_log,
                        "runtime_log": str(DEFAULT_RUNTIME_LOG),
                    },
                )
            self.build_index()
            self.stop_runtime()
            return self.finish_summary(rendered, case_ids)

        processed, missing = self.wait_for_semantic(case_ids)
        self.info(f"Semantic export: {len(processed)}/{len(case_ids)} ready")
        for case_id in missing:
            self.info(f"Missing semantic export: {case_id}")
            self.write_workflow_error(
                case_id,
                kind="semantic_output_missing",
                message="DreamDaemon did not write a matching semantic.json before the timeout.",
                details={
                    "mode": "batch",
                    "timeout_seconds": self.timeout_seconds,
                    "workflow_run_id": self.workflow_run_id,
                    "last_progress": self.load_last_progress(case_id),
                    "runtime_log": str(DEFAULT_RUNTIME_LOG),
                },
            )
            failures.append(case_id)

        if processed:
            for case_id in processed:
                self.remove_workflow_error(case_id)
            render_result = self.render_cases(processed)
            render_failures = self.render_failures(processed)
            if render_result != 0 and not render_failures:
                render_failures = processed
            failures.extend(case_id for case_id in render_failures if case_id not in failures)
            rendered = len([case_id for case_id in processed if case_id not in render_failures])

        self.build_index()
        self.stop_runtime()
        return self.finish_summary(rendered, failures)

    def run_isolated(self, case_paths: list[Path]) -> int:
        self.info("Mode: isolated")
        self.debug("Runtime: restart DreamDaemon for each case.")
        failures: list[str] = []
        rendered = 0
        for index, case_path in enumerate(case_paths, start=1):
            case_id = self.preparer.case_id(case_path)
            result = self.run_one_case(case_path, index, len(case_paths))
            if result == 0:
                rendered += 1
            else:
                failures.append(case_id)
        self.build_index()
        self.stop_runtime()
        return self.finish_summary(rendered, failures)

    def finish_summary(self, rendered: int, failures: list[str]) -> int:
        self.info(f"Done: rendered={rendered}, failures={len(failures)}")
        if failures:
            self.info("Failures:")
            for case_id in failures:
                self.info(f"- {case_id}")
            self.info(f"Read details: {self.display_path(DEFAULT_WORKFLOW_LOG)}")
            return 1
        self.info(f"Index: {self.display_path(TOOL_ROOT / 'index.md')}")
        return 0

    def run_one_case(self, case_path: Path, index: int, total: int) -> int:
        case_id = self.preparer.case_id(case_path)
        self.workflow_run_id = self.create_workflow_run_id()
        self.info("")
        self.info(f"[{index}/{total}] Case: {case_id}")
        self.debug(f"Workflow run id: {self.workflow_run_id}")

        self.clear_case_artifacts(case_id)
        self.preparer.prepare([case_path], workflow_run_id=self.workflow_run_id, source_sha=self.source_sha)

        runtime_result, runtime_log = self.ensure_runtime()
        if runtime_result != 0:
            self.write_workflow_error(
                case_id,
                kind="runtime_start_failed",
                message="DreamDaemon could not be restarted for this render run.",
                details={"runtime_output": runtime_log, "runtime_log": str(DEFAULT_RUNTIME_LOG)},
            )
            return runtime_result

        processed, missing = self.wait_for_semantic([case_id])
        if missing:
            self.info(f"Missing semantic export: {case_id}")
            self.write_workflow_error(
                case_id,
                kind="semantic_output_missing",
                message="DreamDaemon did not write a matching semantic.json before the timeout.",
                details={
                    "timeout_seconds": self.timeout_seconds,
                    "workflow_run_id": self.workflow_run_id,
                    "last_progress": self.load_last_progress(case_id),
                    "runtime_log": str(DEFAULT_RUNTIME_LOG),
                },
            )
            self.stop_runtime()
            return 1

        if processed:
            self.remove_workflow_error(case_id)
            return self.render_cases([case_id])
        return 1

    def render_failures(self, case_ids: list[str]) -> list[str]:
        failures: list[str] = []
        for case_id in case_ids:
            case_dir = DEFAULT_OUT_DIR / case_id
            if (case_dir / "workflow.error.txt").exists() or (case_dir / "workflow.error.json").exists():
                failures.append(case_id)
                continue
            report_failure = self.report_failure_reason(case_id)
            if report_failure:
                self.info(f"Acceptance failed for {case_id}: {report_failure}")
                failures.append(case_id)
                continue
            if (case_dir / "semantic_sprites.error.txt").exists() or (case_dir / "semantic_sprites.error.json").exists():
                failures.append(case_id)
        return failures

    def report_failure_reason(self, case_id: str) -> str:
        report_path = DEFAULT_OUT_DIR / case_id / "report.json"
        if not report_path.exists():
            return "report_missing"
        try:
            report = json.loads(report_path.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError) as error:
            return f"report_invalid_json:{error}"
        if not isinstance(report, dict):
            return "report_invalid_shape"
        if report.get("passed") is True or report.get("passed") == 1:
            return ""
        diff = report.get("expectation_diff")
        if isinstance(diff, list) and diff:
            return f"expectation_mismatch:{len(diff)}"
        hard_error_count = report.get("hard_error_count")
        if hard_error_count:
            return f"hard_errors:{hard_error_count}"
        return "report_not_passed"

    def deduplicated_case_paths(self) -> list[Path]:
        by_case_id: dict[str, Path] = {}
        duplicates: list[tuple[str, Path, Path]] = []
        for case_path in self.case_paths:
            case_id = self.preparer.case_id(case_path)
            previous = by_case_id.get(case_id)
            if previous is not None:
                duplicates.append((case_id, previous, case_path))
            by_case_id[case_id] = case_path
        for case_id, previous, current in duplicates:
            self.info(f"Note: duplicate case id {case_id!r}; using {current.name}.")
            self.debug(f"Duplicate details: using {current} and skipping earlier {previous}.")
        return list(by_case_id.values())

    def ensure_runtime(self) -> tuple[int, str]:
        cmd = [
            sys.executable,
            str(SCRIPT_DIR / "runtime_manager.py"),
            "--restart",
            "--param",
            "world_edit_acceptance=1",
            "--param",
            f"world_edit_acceptance_inbox={self.param_path(TOOL_ROOT / 'inbox')}",
            "--param",
            f"world_edit_acceptance_out={self.param_path(DEFAULT_OUT_DIR)}",
        ]
        if self.dry_run_runtime:
            cmd.append("--dry-run")
        self.info("Starting DreamDaemon...")
        completed = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            errors="replace",
        )
        self.log_completed_process("runtime_manager", cmd, completed)
        return completed.returncode, (completed.stdout or "") + (completed.stderr or "")

    @staticmethod
    def param_path(path: Path) -> str:
        try:
            text = str(path.relative_to(REPO_ROOT))
        except ValueError:
            text = str(path)
        return quote(text.replace("\\", "/"), safe="/._-")

    def stop_runtime(self) -> None:
        if self.dry_run_runtime:
            return
        self.info("Stopping DreamDaemon...")
        completed = subprocess.run(
            [
                sys.executable,
                str(SCRIPT_DIR / "runtime_manager.py"),
                "--stop",
            ],
            cwd=REPO_ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            errors="replace",
        )
        self.log_completed_process("runtime_manager --stop", [sys.executable, str(SCRIPT_DIR / "runtime_manager.py"), "--stop"], completed)

    @staticmethod
    def create_workflow_run_id() -> str:
        return f"{int(time.time() * 1000)}-{uuid.uuid4().hex}"

    @staticmethod
    def resolve_source_sha() -> str:
        completed = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=REPO_ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            errors="replace",
        )
        if completed.returncode != 0:
            return ""
        return completed.stdout.strip()

    def wait_for_semantic(self, case_ids: list[str]) -> tuple[list[str], list[str]]:
        deadline = time.monotonic() + self.timeout_seconds
        pending = set(case_ids)
        processed: set[str] = set()
        self.info("Waiting for semantic export...")
        while pending and time.monotonic() < deadline:
            for case_id in list(pending):
                semantic = DEFAULT_OUT_DIR / case_id / "semantic.json"
                if not semantic.exists():
                    continue
                if self.semantic_matches_workflow(semantic):
                    pending.remove(case_id)
                    processed.add(case_id)
                    self.debug(f"[ready] {case_id}")
            if pending:
                time.sleep(self.poll_seconds)
        return [case_id for case_id in case_ids if case_id in processed], [case_id for case_id in case_ids if case_id in pending]

    def semantic_matches_workflow(self, semantic_path: Path) -> bool:
        try:
            data = json.loads(semantic_path.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError):
            return False
        return (
            str(data.get("workflow_run_id") or "") == self.workflow_run_id
            and str(data.get("source_sha") or "") == self.source_sha
        )

    def load_last_progress(self, case_id: str) -> dict:
        progress_path = DEFAULT_OUT_DIR / case_id / "progress.json"
        if not progress_path.exists():
            return {}
        try:
            progress = json.loads(progress_path.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError):
            return {}
        if isinstance(progress, dict):
            return progress
        return {}

    def render_cases(self, case_ids: list[str]) -> int:
        self.info("Rendering review files...")
        cmd = [
            sys.executable,
            str(SCRIPT_DIR / "render_all.py"),
        ]
        if not self.render_ascii:
            cmd.append("--no-ascii")
        cmd.extend(["--crop-padding", str(self.crop_padding)])
        if self.full_canvas:
            cmd.append("--full-canvas")
        for case_id in case_ids:
            cmd.extend(["--case", case_id])
        completed = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            errors="replace",
        )
        self.log_completed_process("render_all", cmd, completed)
        if completed.returncode != 0:
            self.info("Review rendering failed; see log and case error files.")
        return completed.returncode

    def write_workflow_error(self, case_id: str, kind: str, message: str, details: dict | None = None) -> None:
        case_dir = DEFAULT_OUT_DIR / case_id
        case_dir.mkdir(parents=True, exist_ok=True)
        payload = {
            "case_id": case_id,
            "workflow_run_id": self.workflow_run_id,
            "source_sha": self.source_sha,
            "status": "error",
            "kind": kind,
            "message": message,
            "recommended_fix": "Run the World Edit Visual Render action again; it will prepare cases and restart DreamDaemon.",
            "created_at": datetime.now(timezone.utc).isoformat(),
            "details": details or {},
        }
        error_json = case_dir / "workflow.error.json"
        error_txt = case_dir / "workflow.error.txt"
        error_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        error_txt.write_text(self.workflow_error_text(payload), encoding="utf-8")

    def clear_case_artifacts(self, case_id: str) -> None:
        case_dir = DEFAULT_OUT_DIR / case_id
        case_dir.mkdir(parents=True, exist_ok=True)
        stale_names = (
            "progress.json",
            "report.json",
            "semantic.json",
            "semantic.png",
            "semantic_sprites.png",
            "semantic_sprites.tmp.png",
            "semantic_sprites.error.txt",
            "semantic_sprites.error.json",
            "ascii_dump.txt",
            "workflow.error.txt",
            "workflow.error.json",
        )
        for name in stale_names:
            path = case_dir / name
            if path.exists():
                path.unlink()

    def start_log(self) -> None:
        DEFAULT_WORKFLOW_LOG.parent.mkdir(parents=True, exist_ok=True)
        self.log_handle = DEFAULT_WORKFLOW_LOG.open("w", encoding="utf-8", buffering=1)
        self.log_line("World Edit Visual workflow log")
        self.log_line(f"created_at: {datetime.now(timezone.utc).isoformat()}")
        self.log_line(f"repo: {REPO_ROOT}")
        self.log_line("")

    def close_log(self) -> None:
        if self.log_handle:
            self.log_handle.close()
            self.log_handle = None

    def info(self, message: str = "") -> None:
        print(message)
        self.log_line(message)

    def debug(self, message: str = "", stderr: bool = False) -> None:
        self.log_line(message)
        if self.verbose:
            print(message, file=sys.stderr if stderr else sys.stdout)

    def log_line(self, message: str = "") -> None:
        if self.log_handle:
            print(message, file=self.log_handle)

    def log_completed_process(self, label: str, cmd: list[str], completed: subprocess.CompletedProcess) -> None:
        self.log_line("")
        self.log_line(f"--- {label} ---")
        self.log_line("$ " + " ".join(cmd))
        self.log_line(f"exit_code: {completed.returncode}")
        stdout = completed.stdout or ""
        stderr = completed.stderr or ""
        if stdout:
            self.log_line("stdout:")
            self.log_line(stdout.rstrip())
            if self.verbose:
                print(stdout.rstrip().encode("cp1251", errors="replace").decode("cp1251"))
        if stderr:
            self.log_line("stderr:")
            self.log_line(stderr.rstrip())
            if self.verbose:
                print(stderr.rstrip().encode("cp1251", errors="replace").decode("cp1251"), file=sys.stderr)

    @staticmethod
    def display_path(path: Path) -> str:
        try:
            return str(path.relative_to(REPO_ROOT))
        except ValueError:
            return str(path)

    @staticmethod
    def workflow_error_text(payload: dict) -> str:
        lines = [
            "World Edit Visual workflow failed",
            f"case: {payload['case_id']}",
            f"workflow_run_id: {payload.get('workflow_run_id', '')}",
            f"kind: {payload['kind']}",
            "",
            str(payload["message"]),
            str(payload["recommended_fix"]),
            "",
        ]
        details = payload.get("details") or {}
        if details:
            lines.extend(["details:", json.dumps(details, ensure_ascii=False, indent=2), ""])
        return "\n".join(lines)

    def remove_workflow_error(self, case_id: str) -> None:
        case_dir = DEFAULT_OUT_DIR / case_id
        for error_file in (case_dir / "workflow.error.txt", case_dir / "workflow.error.json"):
            if error_file.exists():
                error_file.unlink()

    def build_index(self) -> None:
        cmd = [
            sys.executable,
            str(SCRIPT_DIR / "build_index.py"),
        ]
        completed = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            errors="replace",
        )
        self.log_completed_process("build_index", cmd, completed)


def resolve_case_paths(args: argparse.Namespace) -> list[Path]:
    if args.case_path:
        return expand_cases(args.case_path)
    if args.case:
        paths: list[Path] = []
        for case_id in args.case:
            matches = sorted(DEFAULT_CASES_DIR.rglob(f"{case_id}.json"))
            if matches:
                paths.append(matches[0])
            else:
                print(f"Case JSON not found for id/name: {case_id}", file=sys.stderr)
        return paths
    return expand_cases([str(DEFAULT_CASES_DIR)])


def main() -> int:
    parser = argparse.ArgumentParser(description="Prepare, run, wait, and render World Edit Visual cases.")
    parser.add_argument("--case-path", action="append", help="Case JSON path; may repeat")
    parser.add_argument("--case", action="append", help="Case id/name from tools/world_edit_visual/cases; may repeat")
    parser.add_argument("--timeout-seconds", default=60, type=int)
    parser.add_argument("--poll-seconds", default=1.0, type=float)
    parser.add_argument("--no-ascii", action="store_true")
    parser.add_argument("--dry-run-runtime", action="store_true", help="Do not actually start/stop DreamDaemon")
    parser.add_argument(
        "--isolated",
        action="store_true",
        help="Diagnostic mode: restart DreamDaemon per case instead of one batch run",
    )
    parser.add_argument("--full-canvas", action="store_true", help="Render complete semantic canvases instead of cropped views")
    parser.add_argument("--crop-padding", default=DEFAULT_CROP_PADDING, type=int, help="Tiles to keep around useful content")
    parser.add_argument("--verbose", action="store_true", help="Print detailed child-process output to the console")
    args = parser.parse_args()

    workflow = RenderWorkflow(
        case_paths=resolve_case_paths(args),
        timeout_seconds=args.timeout_seconds,
        poll_seconds=args.poll_seconds,
        render_ascii=not args.no_ascii,
        dry_run_runtime=args.dry_run_runtime,
        isolated=args.isolated,
        full_canvas=args.full_canvas,
        crop_padding=args.crop_padding,
        verbose=args.verbose,
    )
    return workflow.run()


if __name__ == "__main__":
    raise SystemExit(main())
