#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
REPO_ROOT = SCRIPT_DIR.parents[2]
CASES_DIR = TOOL_ROOT / "cases"
OUT_DIR = TOOL_ROOT / "out"
MATRIX_CASES_DIR = OUT_DIR / "building_layout_seed_matrix_cases"
DEFAULT_SUMMARY = OUT_DIR / "building_layout_seed_matrix_summary.json"
LOCK_PATH = OUT_DIR / "building_layout_seed_matrix.lock"
DEFAULT_SEEDS = (101, 211, 307, 401, 503, 601, 701, 809, 907, 1009)
BASE_CASES = {
    "living": "building_living_target_rooms_6.json",
    "workshop": "building_workshop_target_rooms_6.json",
    "storage": "building_storage_target_rooms_5.json",
    "office": "building_office_rectangle_target_rooms_6.json",
    "hydroponics": "building_hydroponics_target_rooms_7.json",
    "dormitory": "building_dormitory_target_rooms_7.json",
}

# These gates are the shared Definition of Done for every standard-profile
# sample. Program-specific expectations from the committed base case remain in
# force and are extended, never replaced, by this contract.
MATRIX_EXPECTATIONS = {
    "status": "supported",
    "preflight": "supported",
    "feasibility_dry_solve": "solved",
    "same_seed_layout_hash": True,
    "layout_min_candidate_count": 2,
    "generation": "valid_plan",
    "generation_stage": "candidate_validation",
    "apply": "applied",
    "undo": "restored",
    "direction_honored": True,
    "hard_error_count": 0,
    "post_apply_error_count": 0,
    "post_emit_validation_error_count": 0,
    "room_count_satisfied": True,
    "layout_functional_room_count_gap": 0,
    "layout_required_adjacency_missing_count": 0,
    "layout_room_composition_missing_count": 0,
    "layout_room_capacity_shortfall_count": 0,
    "layout_underfurnished_room_count": 0,
    "large_sparse_room_count": 0,
    "layout_scene_underfill_count": 0,
    "layout_required_module_fallback_count": 0,
    "layout_required_template_reject_count": 0,
    "layout_template_reject_ratio_percent_max": 35,
    "layout_wall_cleanup_unmapped_count": 0,
    "layout_wall_cleanup_spur_count": 0,
    "layout_corridor_wall_canyon_count": 0,
    "layout_candidate_metric_mismatch_count": 0,
    "layout_distinct_hard_valid_family_count_min": 2,
    "semantic_functional_coverage_percent_min": 90,
    "semantic_route_clearance_percent_min": 100,
}

SUMMARY_METRICS = (
    "room_count",
    "target_room_count",
    "layout_functional_room_count_gap",
    "layout_required_adjacency_missing_count",
    "layout_room_composition_missing_count",
    "layout_room_capacity_shortfall_count",
    "layout_underfurnished_room_count",
    "large_sparse_room_count",
    "layout_scene_underfill_count",
    "layout_wall_cleanup_unmapped_count",
    "layout_wall_cleanup_spur_count",
    "layout_corridor_wall_canyon_count",
    "layout_candidate_metric_mismatch_count",
    "layout_hard_valid_candidate_count",
    "layout_distinct_hard_valid_family_count",
    "layout_selected_topology_family",
    "layout_best_hard_valid_candidate_score",
    "layout_family_winner_count",
    "layout_family_winner_scores",
    "layout_seed_quality_margin",
    "layout_seed_quality_floor",
    "layout_seed_eligible_family_count",
    "layout_seed_selection_index",
    "layout_selected_candidate_score_gap",
    "semantic_functional_coverage_percent",
    "semantic_route_clearance_percent",
)


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8-sig") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"Expected a JSON object in {path}")
    return value


@contextmanager
def exclusive_matrix_lock():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    lock_handle = LOCK_PATH.open("a+b")
    if LOCK_PATH.stat().st_size == 0:
        lock_handle.write(b"0")
        lock_handle.flush()
    lock_handle.seek(0)
    try:
        if os.name == "nt":
            import msvcrt

            msvcrt.locking(lock_handle.fileno(), msvcrt.LK_NBLCK, 1)
        else:
            import fcntl

            fcntl.flock(lock_handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError as error:
        lock_handle.close()
        raise RuntimeError("Another Building Layout seed-matrix run is already active.") from error
    try:
        yield
    finally:
        lock_handle.seek(0)
        if os.name == "nt":
            import msvcrt

            msvcrt.locking(lock_handle.fileno(), msvcrt.LK_UNLCK, 1)
        else:
            import fcntl

            fcntl.flock(lock_handle.fileno(), fcntl.LOCK_UN)
        lock_handle.close()


def prepare_matrix_cases(programs: list[str], seeds: list[int]) -> list[dict]:
    MATRIX_CASES_DIR.mkdir(parents=True, exist_ok=True)
    for stale_case in MATRIX_CASES_DIR.glob("*.json"):
        stale_case.unlink()

    samples: list[dict] = []
    for program in programs:
        base_path = CASES_DIR / BASE_CASES[program]
        base_case = load_json(base_path)
        configured_program = str((base_case.get("config") or {}).get("program") or "")
        if configured_program != program:
            raise ValueError(
                f"Base case {base_path.name} declares program {configured_program!r}, expected {program!r}"
            )
        target_room_count = (base_case.get("config") or {}).get("target_room_count")
        if target_room_count is None:
            raise ValueError(f"Base case {base_path.name} has no target_room_count")

        for seed in seeds:
            case_data = json.loads(json.dumps(base_case))
            case_id = f"building_layout_matrix_{program}_seed_{seed}"
            case_data["id"] = case_id
            case_data["seed"] = seed
            expectations = dict(case_data.get("expect") or {})
            expectations.update(MATRIX_EXPECTATIONS)
            expectations["target_room_count"] = target_room_count
            case_data["expect"] = expectations
            case_path = MATRIX_CASES_DIR / f"{case_id}.json"
            case_path.write_text(
                json.dumps(case_data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            samples.append(
                {
                    "case_id": case_id,
                    "case_path": case_path,
                    "program": program,
                    "seed": seed,
                    "target_room_count": target_room_count,
                }
            )
    return samples


def run_shards(samples: list[dict], shard_size: int, timeout_seconds: int) -> list[dict]:
    shard_results: list[dict] = []
    total_shards = (len(samples) + shard_size - 1) // shard_size
    for offset in range(0, len(samples), shard_size):
        shard = samples[offset : offset + shard_size]
        shard_number = offset // shard_size + 1
        print(f"\nSeed matrix shard {shard_number}/{total_shards}: {len(shard)} cases", flush=True)
        command = [
            sys.executable,
            str(SCRIPT_DIR / "render_workflow.py"),
            "--timeout-seconds",
            str(timeout_seconds),
            "--no-ascii",
        ]
        for sample in shard:
            command.extend(["--case-path", str(sample["case_path"])])
        completed = subprocess.run(command, cwd=REPO_ROOT)
        shard_results.append(
            {
                "shard": shard_number,
                "case_ids": [sample["case_id"] for sample in shard],
                "exit_code": completed.returncode,
            }
        )
    return shard_results


def sample_result(sample: dict) -> dict:
    report_path = OUT_DIR / sample["case_id"] / "report.json"
    workflow_error_path = OUT_DIR / sample["case_id"] / "workflow.error.json"
    result = {
        "case_id": sample["case_id"],
        "program": sample["program"],
        "seed": sample["seed"],
        "target_room_count": sample["target_room_count"],
        "passed": False,
        "status": "missing",
        "hard_error_count": None,
        "expectation_diff": [],
        "layout_hash": None,
        "replay_layout_hash": None,
        "same_seed_layout_hash": False,
        "metrics": {},
    }
    if workflow_error_path.exists():
        result["workflow_error"] = load_json(workflow_error_path)
    if not report_path.exists():
        result["failure_reason"] = "report_missing"
        return result

    report = load_json(report_path)
    determinism = report.get("determinism_replay") or {}
    metrics = report.get("metrics") or {}
    report_matches_sample = (
        str(report.get("program") or "") == sample["program"]
        and int(report.get("seed") or 0) == sample["seed"]
    )
    replay_match = determinism.get("same_seed_layout_hash")
    result.update(
        {
            "passed": report_matches_sample and (report.get("passed") is True or report.get("passed") == 1),
            "status": report.get("status"),
            "hard_error_count": report.get("hard_error_count"),
            "expectation_diff": report.get("expectation_diff") or [],
            "layout_hash": determinism.get("layout_hash") or metrics.get("layout_hash"),
            "replay_layout_hash": determinism.get("replay_layout_hash"),
            "same_seed_layout_hash": replay_match is True or replay_match == 1,
            "metrics": {key: metrics.get(key) for key in SUMMARY_METRICS},
        }
    )
    if not result["passed"]:
        if not report_matches_sample:
            result["failure_reason"] = "report_identity_mismatch"
        else:
            result["failure_reason"] = "expectation_mismatch" if result["expectation_diff"] else "hard_error"
    return result


def existing_sample_passes(sample: dict) -> bool:
    result = sample_result(sample)
    return bool(result["passed"] and result["same_seed_layout_hash"])


def write_summary(
    summary_path: Path,
    programs: list[str],
    seeds: list[int],
    samples: list[dict],
    shard_results: list[dict],
    prepared_only: bool,
) -> dict:
    results = [] if prepared_only else [sample_result(sample) for sample in samples]
    passed = sum(1 for result in results if result["passed"])
    summary = {
        "schema": "world_edit_building_layout_seed_matrix/v1",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "programs": programs,
        "seeds": seeds,
        "sample_count": len(samples),
        "prepared_only": prepared_only,
        "passed_count": passed,
        "failed_count": 0 if prepared_only else len(results) - passed,
        "shards": shard_results,
        "results": results,
    }
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run the canonical Building Layout 10-seed acceptance matrix."
    )
    parser.add_argument(
        "--program",
        action="append",
        choices=tuple(BASE_CASES),
        help="Limit to a key program; may repeat.",
    )
    parser.add_argument(
        "--seed",
        action="append",
        type=int,
        help="Override the canonical seed set; may repeat.",
    )
    parser.add_argument("--shard-size", type=int, default=3)
    parser.add_argument("--timeout-seconds", type=int, default=300)
    parser.add_argument(
        "--resume-passed",
        action="store_true",
        help="Skip samples whose existing report already passes, including same-seed replay.",
    )
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--summary", type=Path, default=DEFAULT_SUMMARY)
    args = parser.parse_args()
    if args.shard_size < 1:
        parser.error("--shard-size must be at least 1")
    if args.timeout_seconds < 1:
        parser.error("--timeout-seconds must be at least 1")
    if args.seed and any(seed < 1 for seed in args.seed):
        parser.error("--seed values must be positive integers")
    return args


def main() -> int:
    args = parse_args()
    try:
        with exclusive_matrix_lock():
            programs = list(dict.fromkeys(args.program or BASE_CASES.keys()))
            seeds = list(dict.fromkeys(args.seed or DEFAULT_SEEDS))
            samples = prepare_matrix_cases(programs, seeds)
            print(f"Prepared {len(samples)} cases in {MATRIX_CASES_DIR}", flush=True)

            pending_samples = samples
            if args.resume_passed and not args.prepare_only:
                pending_samples = [sample for sample in samples if not existing_sample_passes(sample)]
                print(
                    f"Resume: keeping {len(samples) - len(pending_samples)} passed reports; "
                    f"running {len(pending_samples)} samples",
                    flush=True,
                )

            shard_results = []
            if not args.prepare_only:
                shard_results = run_shards(pending_samples, args.shard_size, args.timeout_seconds)
            summary = write_summary(
                args.summary,
                programs,
                seeds,
                samples,
                shard_results,
                prepared_only=args.prepare_only,
            )
            print(f"Summary: {args.summary}", flush=True)
            if args.prepare_only:
                return 0
            print(
                f"Seed matrix: passed={summary['passed_count']}, failed={summary['failed_count']}",
                flush=True,
            )
            return 0 if summary["failed_count"] == 0 and all(shard["exit_code"] == 0 for shard in shard_results) else 1
    except RuntimeError as error:
        print(str(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
