#!/usr/bin/env python3

from __future__ import annotations

import json
import re
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
GENERATED_DIR = TOOL_ROOT / "cases" / "generated"
SAFE_ID = re.compile(r"[^A-Za-z0-9_.-]+")

SIZES = {
    "small": {"canvas": (64, 64), "rect": (24, 24, 39, 35), "half": (5, 4)},
    "medium": {"canvas": (96, 96), "rect": (34, 34, 61, 53), "half": (8, 6)},
    "large": {"canvas": (128, 128), "rect": (44, 44, 83, 75), "half": (12, 9)},
}


def safe_case_id(raw: str) -> str:
    safe = SAFE_ID.sub("_", raw).strip("._")
    return safe or "generated_case"


def ask(label: str, default: str, choices: list[str] | None = None) -> str:
    hint = f" [{'/'.join(choices)}]" if choices else ""
    raw = input(f"{label}{hint} ({default}): ").strip()
    value = raw or default
    if choices and value not in choices:
        print(f"Using default: {default}")
        return default
    return value


def build_case() -> dict:
    print("Create World Edit Visual case")
    print("Press Enter to accept defaults. Advanced tuning can be edited in the JSON after creation.")
    print()

    case_id = safe_case_id(ask("Case id", "generated_building_layout"))
    shape = ask("Shape", "rectangle", ["rectangle", "point"])
    size = ask("Size", "medium", ["small", "medium", "large"])
    direction = ask("Direction", "east", ["north", "east", "south", "west"])
    seed_raw = ask("Seed", "1001")
    try:
        seed = int(seed_raw)
    except ValueError:
        seed = 1001

    spec = SIZES[size]
    width, height = spec["canvas"]
    half_width, half_depth = spec["half"]
    if shape == "point":
        anchors = [{"x": width // 2, "y": height // 2}]
    else:
        x1, y1, x2, y2 = spec["rect"]
        anchors = [{"x": x1, "y": y1}, {"x": x2, "y": y2}]

    return {
        "id": case_id,
        "generator": "building_layout",
        "seed": seed,
        "canvas": {
            "preset": f"blank_{width}",
            "width": width,
            "height": height,
        },
        "shape": {
            "id": shape,
            "anchors": anchors,
        },
        "config": {
            "program": "living",
            "faction_preset": "colony",
            "direction": direction,
            "auto_size": True,
            "half_width": half_width,
            "half_depth": half_depth,
            "respect_blockers": False,
            "replace_blocked_turfs": True,
            "confirm_large_replacement": False,
        },
        "expect": {
            "status": "supported",
        },
        "render": {
            "semantic_png": True,
            "after_dmm": False,
            "debug_overlays": True,
        },
        "profile": {
            "enabled": True,
            "include_stage_timings": True,
            "include_loop_counters": True,
        },
    }


def main() -> int:
    case_data = build_case()
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    out_path = GENERATED_DIR / f"{case_data['id']}.json"
    out_path.write_text(json.dumps(case_data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print()
    print(f"Wrote {out_path}")
    print("Use menu option 2 to render this case.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
