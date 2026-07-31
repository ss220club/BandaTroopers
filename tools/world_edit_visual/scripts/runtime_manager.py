#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
REPO_ROOT = SCRIPT_DIR.parents[2]
DEFAULT_DMB = REPO_ROOT / "colonialmarines.dmb"
DEFAULT_DREAMDAEMON_ARGS = ["-trusted", "-verbose"]
DEFAULT_RUNTIME_LOG = TOOL_ROOT / "runtime.log"
START_DETECTION_TIMEOUT_SECONDS = 15.0
START_DETECTION_POLL_SECONDS = 0.5

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(line_buffering=True)


CREATE_FLAGS = 0
if sys.platform == "win32":
    CREATE_FLAGS = subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.DETACHED_PROCESS
    if hasattr(subprocess, "CREATE_NO_WINDOW"):
        CREATE_FLAGS |= subprocess.CREATE_NO_WINDOW


def run_powershell_json(command: str) -> object:
    completed = subprocess.run(
        ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", command],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding="utf-8",
        errors="replace",
    )
    if completed.returncode != 0:
        return []
    text = completed.stdout.strip()
    if not text:
        return []
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return []


def runtime_processes() -> list[dict]:
    if sys.platform != "win32":
        return []
    data = run_powershell_json(
        """
$items = Get-CimInstance Win32_Process -Filter "name = 'dreamdaemon.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
  $gp = Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue
  [PSCustomObject]@{
    Id = $_.ProcessId
    Path = if ($_.ExecutablePath) { $_.ExecutablePath } elseif ($gp.Path) { $gp.Path } else { $null }
    CommandLine = $_.CommandLine
    StartTime = if ($gp.StartTime) { $gp.StartTime.ToUniversalTime().ToString('o') } else { $null }
  }
}
$items | ConvertTo-Json -Compress
"""
    )
    if isinstance(data, dict):
        return [data]
    if isinstance(data, list):
        return [item for item in data if isinstance(item, dict)]
    return []


def normalize_process_text(value: object) -> str:
    return str(value or "").replace("\\", "/").lower()


def process_matches_dmb(process: dict, dmb_path: Path) -> bool:
    command_line = normalize_process_text(process.get("CommandLine"))
    if not command_line:
        return False
    target = normalize_process_text(dmb_path.resolve())
    return target in command_line


def select_runtime_processes(processes: list[dict], dmb_path: Path) -> list[dict]:
    return [process for process in processes if process_matches_dmb(process, dmb_path)]


def ambiguous_runtime_message(dmb_path: Path) -> str:
    return (
        "DreamDaemon is running, but none of the processes clearly matches the exact DMB path "
        f"{dmb_path}. Close that DreamDaemon manually once, or start it through the World Edit "
        "Visual Render action so automation can manage it safely."
    )


def parse_datetime(value: object) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except ValueError:
        return None


def find_dreamdaemon(processes: list[dict]) -> Path | None:
    for process in processes:
        raw_path = process.get("Path")
        if raw_path and Path(str(raw_path)).exists():
            return Path(str(raw_path))
    candidates = []
    if os.environ.get("BYOND_DREAMDAEMON"):
        candidates.append(Path(os.environ["BYOND_DREAMDAEMON"]))
    if os.environ.get("ProgramFiles(x86)"):
        candidates.append(Path(os.environ["ProgramFiles(x86)"]) / "BYOND" / "bin" / "dreamdaemon.exe")
    if os.environ.get("ProgramFiles"):
        candidates.append(Path(os.environ["ProgramFiles"]) / "BYOND" / "bin" / "dreamdaemon.exe")
    for candidate in candidates:
        if candidate and candidate.exists():
            return candidate
    return None


def is_stale(process: dict, dmb_path: Path) -> bool:
    started = parse_datetime(process.get("StartTime"))
    if not started or not dmb_path.exists():
        return False
    dmb_mtime = datetime.fromtimestamp(dmb_path.stat().st_mtime, tz=started.tzinfo)
    return started < dmb_mtime


def stop_runtime(dry_run: bool = False, processes: list[dict] | None = None) -> int:
    if processes is None:
        processes = runtime_processes()
    if not processes:
        print("DreamDaemon is not running.")
        return 0
    pids = [str(process.get("Id")) for process in processes if process.get("Id")]
    print("Stopping DreamDaemon: " + ", ".join(pids))
    if dry_run:
        return 0
    for pid in pids:
        subprocess.run(["taskkill", "/PID", pid, "/T", "/F"], cwd=REPO_ROOT)
    deadline = time.monotonic() + 15
    target_pids = set(pids)
    while time.monotonic() < deadline:
        current_pids = {str(process.get("Id")) for process in runtime_processes() if process.get("Id")}
        if not (current_pids & target_pids):
            return 0
        time.sleep(0.5)
    print("DreamDaemon did not stop within timeout.", file=sys.stderr)
    return 1


def start_runtime(
    dmb_path: Path,
    dry_run: bool = False,
    preferred_exe: Path | None = None,
    extra_args: list[str] | None = None,
    runtime_log: Path = DEFAULT_RUNTIME_LOG,
) -> int:
    if not dmb_path.exists():
        print(f"Cannot start DreamDaemon: DMB not found: {dmb_path}", file=sys.stderr)
        return 1
    exe = preferred_exe or find_dreamdaemon(runtime_processes())
    if not exe:
        print("Cannot find dreamdaemon.exe. Set BYOND_DREAMDAEMON or install BYOND.", file=sys.stderr)
        return 1
    launch_args = [str(exe), str(dmb_path), *(extra_args or DEFAULT_DREAMDAEMON_ARGS)]
    print("Starting DreamDaemon: " + " ".join(launch_args))
    print(f"DreamDaemon log: {runtime_log}")
    if dry_run:
        return 0
    before_pids = {str(process.get("Id")) for process in runtime_processes() if process.get("Id")}
    runtime_log.parent.mkdir(parents=True, exist_ok=True)
    log_handle = runtime_log.open("a", encoding="utf-8", errors="replace")
    log_handle.write("\n=== DreamDaemon start " + datetime.now().isoformat() + " ===\n")
    log_handle.write("command: " + " ".join(launch_args) + "\n")
    log_handle.flush()
    launched = subprocess.Popen(
        launch_args,
        cwd=REPO_ROOT,
        stdout=log_handle,
        stderr=log_handle,
        creationflags=CREATE_FLAGS,
    )
    log_handle.close()
    deadline = time.monotonic() + START_DETECTION_TIMEOUT_SECONDS
    while time.monotonic() < deadline:
        after_processes = runtime_processes()
        for process in after_processes:
            process_id = str(process.get("Id") or "")
            if process_id == str(launched.pid) or (process_id not in before_pids and process_matches_dmb(process, dmb_path)):
                return 0
        if launched.poll() is not None:
            print(f"DreamDaemon exited during startup with code {launched.returncode}.", file=sys.stderr)
            return 1
        time.sleep(START_DETECTION_POLL_SECONDS)

    print(
        f"DreamDaemon did not appear after {START_DETECTION_TIMEOUT_SECONDS:g} seconds; stopping launched PID {launched.pid}.",
        file=sys.stderr,
    )
    subprocess.run(["taskkill", "/PID", str(launched.pid), "/T", "/F"], cwd=REPO_ROOT)
    return 1


def dreamdaemon_args(runtime_params: list[str] | None = None) -> list[str]:
    args = list(DEFAULT_DREAMDAEMON_ARGS)
    for param in runtime_params or []:
        if param:
            args.extend(["-params", param])
    return args


def ensure_runtime(
    dmb_path: Path,
    restart: bool = False,
    dry_run: bool = False,
    runtime_params: list[str] | None = None,
) -> int:
    processes = runtime_processes()
    managed_processes = select_runtime_processes(processes, dmb_path)
    if processes and not managed_processes:
        print(ambiguous_runtime_message(dmb_path), file=sys.stderr)
        return 1
    stale = [process for process in managed_processes if is_stale(process, dmb_path)]
    if restart or stale:
        exe = find_dreamdaemon(processes)
        if stale:
            print("DreamDaemon is older than the current DMB; restarting it.")
        elif restart:
            print("Restarting DreamDaemon.")
        result = stop_runtime(dry_run=dry_run, processes=managed_processes)
        if result != 0:
            return result
        return start_runtime(dmb_path, dry_run=dry_run, preferred_exe=exe, extra_args=dreamdaemon_args(runtime_params))
    if managed_processes:
        print("DreamDaemon is already running and fresh enough.")
        return 0
    return start_runtime(dmb_path, dry_run=dry_run, extra_args=dreamdaemon_args(runtime_params))


def print_status(dmb_path: Path) -> int:
    processes = runtime_processes()
    if not processes:
        print("DreamDaemon: stopped")
        return 0
    for process in processes:
        stale = is_stale(process, dmb_path)
        print(
            f"DreamDaemon: pid={process.get('Id')} start={process.get('StartTime')} "
            f"path={process.get('Path')} stale={stale} command={process.get('CommandLine')}"
        )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Manage DreamDaemon for World Edit Visual.")
    parser.add_argument("--dmb", default=DEFAULT_DMB, type=Path)
    parser.add_argument("--status", action="store_true")
    parser.add_argument("--ensure", action="store_true")
    parser.add_argument("--restart", action="store_true")
    parser.add_argument("--stop", action="store_true")
    parser.add_argument("--start", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--param", action="append", default=[], help="DreamDaemon -params assignment; may repeat")
    args = parser.parse_args()

    if sys.platform != "win32":
        print("DreamDaemon automation is currently Windows-only.", file=sys.stderr)
        return 1

    dmb_path = args.dmb.resolve()
    if args.status:
        return print_status(dmb_path)
    if args.stop:
        processes = runtime_processes()
        managed_processes = select_runtime_processes(processes, dmb_path)
        if processes and not managed_processes:
            print(ambiguous_runtime_message(dmb_path), file=sys.stderr)
            return 1
        return stop_runtime(dry_run=args.dry_run, processes=managed_processes)
    if args.start:
        return start_runtime(dmb_path, dry_run=args.dry_run, extra_args=dreamdaemon_args(args.param))
    if args.ensure or args.restart:
        return ensure_runtime(dmb_path, restart=args.restart, dry_run=args.dry_run, runtime_params=args.param)
    return print_status(dmb_path)


if __name__ == "__main__":
    raise SystemExit(main())
