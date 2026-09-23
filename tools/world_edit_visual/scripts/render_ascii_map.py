#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path

from crop_bounds import DEFAULT_CROP_PADDING, TileBounds, compute_crop_bounds

# ── Symbol tables ──────────────────────────────────────────────────────
# Geometry layer
WALL     = "#"
DOOR     = "+"
WINDOW   = "O"
FLOOR    = "."
EMPTY    = " "

# Object layer
OBJ_FLOOR_BG  = "."   # background for floor tiles without objects
OBJ_WALL_BG   = ":"   # faint wall outline on object layer (colon for cp1251 compat)
OBJ_EMPTY_BG  = " "   # background for empty (non-floor, non-wall) tiles

# Object symbols – first letter of the object path basename, uppercased.
# Special overrides can be added here.
OBJECT_SYMBOL_MAP = {
    "table":            "T",
    "stool":            "S",
    "chair":            "C",
    "bed":              "B",
    "locker":           "L",
    "rack":             "R",
    "crate":            "X",
    "machine":          "M",
    "computer":         "P",  # PC / terminal
    "vendor":           "V",
    "light":            "I",  # Illumination
    "lamp":             "I",
    "fire_alarm":       "A",
    "extinguisher":     "E",
    "sign":             "N",  # sigN
    "poster":           "N",
    "button":           "U",  # bUtton
    "switch":           "U",
    "intercom":         "Y",
    "camera":           "K",  # Kamera
    "landmark":         "@",
}


def load_json(path: str | None) -> dict:
    if not path:
        return {}
    if not Path(path).exists():
        return {}
    with open(path, "r", encoding="utf-8-sig") as handle:
        return json.load(handle)


def _object_symbol(obj: dict) -> str:
    """Return a single-character symbol for an object dict."""
    path = obj.get("path", "")
    # Extract the last component of the path, e.g. /obj/structure/table -> table
    basename = path.rsplit("/", 1)[-1] if "/" in path else path
    basename_lower = basename.lower()

    # Check explicit map first
    for key, sym in OBJECT_SYMBOL_MAP.items():
        if key in basename_lower:
            return sym

    # Fallback: first letter uppercased
    if basename:
        return basename[0].upper()
    return "?"


class ASCIIRenderer:
    def __init__(self, semantic: dict, report: dict, crop: TileBounds | None = None):
        self.semantic = semantic
        self.report = report
        self.crop = crop or compute_crop_bounds(semantic)
        self.width = self.crop.width
        self.height = self.crop.height

        # Layer 1 – Geometry: walls, doors, windows, zone floors
        self.geo_map = [[" " for _ in range(self.width)] for _ in range(self.height)]
        # Layer 2 – Objects: only objects, with faint background
        self.obj_map = [[" " for _ in range(self.width)] for _ in range(self.height)]

    # ── Public API ────────────────────────────────────────────────────

    def render(self):
        self._build_maps()
        self._print_crop_header()
        self._print_dual_map()
        self._print_legend()
        self._print_report()

    # ── Build ─────────────────────────────────────────────────────────

    def _build_maps(self):
        for tile in self.semantic.get("tiles", []):
            local_x = int(tile.get("local_x", 1))
            local_y = int(tile.get("local_y", 1))
            if not self.crop.contains(local_x, local_y):
                continue

            x = local_x - self.crop.min_x
            y = self.crop.max_y - local_y

            if not (0 <= x < self.width and 0 <= y < self.height):
                continue

            flags = tile.get("flags", {})
            objects = tile.get("objects", [])

            # ── Geometry layer ──────────────────────────────────────
            if flags.get("wall"):
                self.geo_map[y][x] = WALL
            elif flags.get("door"):
                self.geo_map[y][x] = DOOR
            elif flags.get("window"):
                self.geo_map[y][x] = WINDOW
            elif flags.get("floor"):
                # Zone floor – could be a digit/letter in the future;
                # for now use a dot to distinguish from empty space.
                self.geo_map[y][x] = FLOOR
            else:
                self.geo_map[y][x] = EMPTY

            # ── Object layer ────────────────────────────────────────
            if objects:
                # Pick the "most interesting" object for the symbol.
                # Priority: non-landmark, then first.
                primary = objects[0]
                for obj in objects:
                    if "landmark" not in obj.get("path", "").lower():
                        primary = obj
                        break
                sym = _object_symbol(primary)
                # Wall-mounted objects get lowercase to hint at placement
                if primary.get("wall_mounted"):
                    sym = sym.lower()
                self.obj_map[y][x] = sym
            else:
                # Background: show faint wall outline or floor dot
                if flags.get("wall"):
                    self.obj_map[y][x] = OBJ_WALL_BG
                elif flags.get("floor"):
                    self.obj_map[y][x] = OBJ_FLOOR_BG
                else:
                    self.obj_map[y][x] = OBJ_EMPTY_BG

    # ── Dual output ───────────────────────────────────────────────────

    def _print_crop_header(self):
        full_width = int(self.semantic.get("width", self.width) or self.width)
        full_height = int(self.semantic.get("height", self.height) or self.height)
        full_canvas = (
            self.crop.min_x == 1
            and self.crop.min_y == 1
            and self.crop.max_x == full_width
            and self.crop.max_y == full_height
        )
        mode = "full canvas" if full_canvas else "cropped"
        print(
            f"VIEW: {mode} local=({self.crop.min_x},{self.crop.min_y}).."
            f"({self.crop.max_x},{self.crop.max_y}) size={self.width}x{self.height}"
        )
        print("")

    def _print_dual_map(self):
        """Print two ASCII grids side by side: Geometry | Objects."""
        sep = "   |   "  # vertical bar separator between the two layers

        # Header
        geo_label = "GEOMETRY (walls/doors/floors)"
        obj_label = "OBJECTS (furniture/decor)"
        header = (
            "+" + "-" * self.width + "+"
            + sep
            + "+" + "-" * self.width + "+"
        )
        # Centre the labels above each grid
        geo_pad = (self.width - len(geo_label)) // 2
        obj_pad = (self.width - len(obj_label)) // 2
        label_line = (
            " " * (geo_pad + 1) + geo_label + " " * (self.width - geo_pad - len(geo_label))
            + sep
            + " " * (obj_pad + 1) + obj_label + " " * (self.width - obj_pad - len(obj_label))
        )
        print(label_line)
        print(header)

        for y in range(self.height):
            geo_row = "".join(self.geo_map[y])
            obj_row = "".join(self.obj_map[y])
            print("|" + geo_row + "|" + sep + "|" + obj_row + "|")

        print(header)

    # ── Legend & Report ───────────────────────────────────────────────

    def _print_legend(self):
        print("\n=== ROOMS LEGEND ===")
        rooms = self.semantic.get("rooms", [])
        if not rooms:
            print("No rooms defined.")
            return

        for i, room in enumerate(rooms):
            role = room.get("role") or room.get("id") or "room"
            status = room.get("status", "ok")
            bounds = room.get("bounds", "N/A")
            print(f"{i+1}. {role} (Status: {status}) | Bounds: {bounds}")

    def _print_report(self):
        print("\n=== REPORT ===")
        status = self.report.get("status", "unknown")
        print(f"Status: {status}")

        metrics = self.report.get("metrics", {})
        if metrics:
            print("Metrics:")
            for k, v in metrics.items():
                print(f"  {k}: {v}")

        errors = self.report.get("errors") or self.semantic.get("errors") or []
        if errors:
            print("Errors:")
            for err in errors:
                if isinstance(err, dict):
                    print(f"  - {err.get('code', 'UNKNOWN')}: {err.get('message', '')} {err.get('context', '')}")
                else:
                    print(f"  - {err}")
        else:
            print("Errors: None")


# ── Entry point ───────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--semantic-json", required=True)
    parser.add_argument("--report-json")
    parser.add_argument("--full-canvas", action="store_true", help="Render the complete semantic canvas")
    parser.add_argument("--crop-padding", default=DEFAULT_CROP_PADDING, type=int, help="Tiles to keep around useful content")
    args = parser.parse_args()

    semantic = load_json(args.semantic_json)
    report = load_json(args.report_json) if args.report_json else {}

    renderer = ASCIIRenderer(
        semantic,
        report,
        crop=compute_crop_bounds(semantic, padding=args.crop_padding, full_canvas=args.full_canvas),
    )
    renderer.render()


if __name__ == "__main__":
    main()
