#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw

from crop_bounds import DEFAULT_CROP_PADDING, TileBounds, compute_crop_bounds


TILE_SIZE = 32
SCRIPT_DIR = Path(__file__).resolve().parent
TOOL_ROOT = SCRIPT_DIR.parent
REPO_ROOT = SCRIPT_DIR.parents[2]
DEFAULT_CACHE_DIR = TOOL_ROOT / ".cache" / "sprites"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(line_buffering=True)

DMITOOL_DIR = REPO_ROOT / "tools" / "dmitool"
if str(DMITOOL_DIR) not in sys.path:
    sys.path.insert(0, str(DMITOOL_DIR))

try:
    import dmitool  # type: ignore
except Exception as exc:  # pragma: no cover - exercised only on broken setup
    dmitool = None
    DMITOOL_IMPORT_ERROR = exc
else:
    DMITOOL_IMPORT_ERROR = None


DIR_TO_DMITOOL = {
    1: "N",
    2: "S",
    4: "E",
    8: "W",
    5: "NE",
    6: "SE",
    9: "NW",
    10: "SW",
}

DIR_TEXT_TO_DMITOOL = {
    "north": "N",
    "n": "N",
    "south": "S",
    "s": "S",
    "east": "E",
    "e": "E",
    "west": "W",
    "w": "W",
    "northeast": "NE",
    "ne": "NE",
    "southeast": "SE",
    "se": "SE",
    "northwest": "NW",
    "nw": "NW",
    "southwest": "SW",
    "sw": "SW",
}

SCHEMATIC_COLORS = {
    "empty": (18, 18, 18, 255),
    "floor": (170, 170, 170, 255),
    "wall": (70, 70, 70, 255),
    "door": (220, 180, 40, 255),
    "object": (255, 0, 255, 210),
}


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8-sig") as handle:
        return json.load(handle)


def as_int(value: Any, default: int = 0) -> int:
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return default


def as_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def as_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value != 0
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def direction_for_dmitool(appearance: dict[str, Any]) -> str | None:
    dir_value = appearance.get("dir_value")
    if dir_value is not None:
        try:
            return DIR_TO_DMITOOL.get(int(float(dir_value)))
        except (TypeError, ValueError):
            pass
    raw_dir = appearance.get("dir")
    if raw_dir is not None:
        try:
            numeric_dir = DIR_TO_DMITOOL.get(int(float(raw_dir)))
            if numeric_dir:
                return numeric_dir
        except (TypeError, ValueError):
            pass
    dir_text = str(raw_dir or "").strip().lower()
    return DIR_TEXT_TO_DMITOOL.get(dir_text)


def appearance_is_visible(appearance: dict[str, Any]) -> bool:
    if as_int(appearance.get("invisibility"), 0) > 0:
        return False
    return as_int(appearance.get("alpha"), 255) > 0


def semantic_object_is_visible(obj: dict[str, Any]) -> bool:
    if as_int(obj.get("invisibility"), 0) > 0:
        return False
    appearance = obj.get("appearance")
    if isinstance(appearance, dict):
        return appearance_is_visible(appearance)
    return True


def normalize_icon_state(value: Any) -> str:
    if value is None:
        return ""
    return str(value)


def alpha_adjust(image: Image.Image, alpha: int) -> Image.Image:
    alpha = max(0, min(255, alpha))
    if alpha >= 255:
        return image
    adjusted = image.copy()
    channel = adjusted.getchannel("A").point(lambda pixel: int(pixel * alpha / 255))
    adjusted.putalpha(channel)
    return adjusted


def apply_color(image: Image.Image, color: Any) -> Image.Image:
    if color is None:
        return image
    text = str(color).strip()
    if not text or text.lower() == "null":
        return image
    if text.startswith("#"):
        text = text[1:]
    if len(text) != 6:
        return image
    try:
        red = int(text[0:2], 16)
        green = int(text[2:4], 16)
        blue = int(text[4:6], 16)
    except ValueError:
        return image
    tinted = image.copy()
    r, g, b, a = tinted.split()
    r = r.point(lambda pixel: int(pixel * red / 255))
    g = g.point(lambda pixel: int(pixel * green / 255))
    b = b.point(lambda pixel: int(pixel * blue / 255))
    return Image.merge("RGBA", (r, g, b, a))


def alpha_composite_at(base: Image.Image, overlay: Image.Image, x: int, y: int) -> None:
    x0 = max(0, x)
    y0 = max(0, y)
    x1 = min(base.width, x + overlay.width)
    y1 = min(base.height, y + overlay.height)
    if x0 >= x1 or y0 >= y1:
        return
    crop = overlay.crop((x0 - x, y0 - y, x1 - x, y1 - y))
    base.alpha_composite(crop, (x0, y0))


class SpriteRenderer:
    def __init__(
        self,
        semantic: dict[str, Any],
        semantic_path: Path,
        output_path: Path,
        cache_dir: Path,
        allow_schematic_fallback: bool = False,
        crop: TileBounds | None = None,
    ) -> None:
        self.semantic = semantic
        self.semantic_path = semantic_path
        self.output_path = output_path
        self.cache_dir = cache_dir
        self.allow_schematic_fallback = allow_schematic_fallback
        self.case_id = str(semantic.get("case_id") or output_path.parent.name or "unknown")
        self.crop = crop or compute_crop_bounds(semantic)
        self.width = self.crop.width
        self.height = self.crop.height
        self.image = Image.new(
            "RGBA",
            (self.width * TILE_SIZE, self.height * TILE_SIZE),
            (0, 0, 0, 255),
        )
        self.draw = ImageDraw.Draw(self.image)
        self.frame_cache: dict[tuple[str, str, str | None], Image.Image | None] = {}
        self.problems: list[str] = []
        self.problem_keys: set[str] = set()

    def render(self) -> bool:
        self.cache_dir.mkdir(parents=True, exist_ok=True)

        if not self.allow_schematic_fallback:
            preflight_error = self.appearance_preflight_error()
            if preflight_error:
                print(preflight_error, file=sys.stderr)
                return False

        for entry in sorted(self.collect_appearance_entries(), key=self.entry_sort_key):
            self.render_appearance(
                entry["appearance"],
                entry["tile_px"],
                entry["tile_py"],
                entry["context"],
                entry["layer_kind"],
            )

        if self.problems and not self.allow_schematic_fallback:
            print(
                "Error: sprite rendering could not extract one or more required DMI appearances "
                "from the current semantic.json.",
                file=sys.stderr,
            )
            for problem in self.problems[:40]:
                print(f"- {problem}", file=sys.stderr)
            if len(self.problems) > 40:
                print(f"- ... {len(self.problems) - 40} more problems", file=sys.stderr)
            return False

        self.output_path.parent.mkdir(parents=True, exist_ok=True)
        self.image.save(self.output_path)
        if self.problems and self.allow_schematic_fallback:
            print(f"Rendered sprites with schematic fallback to {self.output_path}")
        else:
            print(f"Rendered real sprites to {self.output_path}")
        return True

    def appearance_preflight_error(self) -> str | None:
        features = self.semantic.get("features")
        appearance_feature = isinstance(features, dict) and as_bool(features.get("appearance"))
        appearance_schema = self.semantic.get("appearance_schema")
        tiles = [tile for tile in self.semantic.get("tiles", []) if isinstance(tile, dict)]
        tile_appearances = sum(1 for tile in tiles if isinstance(tile.get("appearance"), dict))
        objects = [
            obj
            for tile in tiles
            for obj in (tile.get("objects") or [])
            if isinstance(obj, dict) and semantic_object_is_visible(obj)
        ]
        object_appearances = sum(1 for obj in objects if isinstance(obj.get("appearance"), dict))

        if appearance_feature and as_int(appearance_schema, 0) >= 1 and tile_appearances == len(tiles) and object_appearances == len(objects):
            return None

        semantic_mtime = "unknown"
        try:
            semantic_mtime = str(self.semantic_path.stat().st_mtime_ns)
        except OSError:
            pass

        return "\n".join(
            [
                "Error: semantic JSON cannot render real DMI sprites.",
                f"- case: {self.case_id}",
                f"- semantic_json: {self.semantic_path}",
                f"- semantic_mtime_ns: {semantic_mtime}",
                f"- appearance_schema: {appearance_schema!r}",
                f"- features.appearance: {appearance_feature}",
                f"- tiles_with_appearance: {tile_appearances}/{len(tiles)}",
                f"- objects_with_appearance: {object_appearances}/{len(objects)}",
                "- reason: stale or incompatible workbench export; regenerate semantic.json with the updated runtime.",
                "- fix: run the World Edit Visual Render action again; it prepares cases and restarts DreamDaemon when needed.",
            ]
        )

    def collect_appearance_entries(self) -> list[dict[str, Any]]:
        entries: list[dict[str, Any]] = []
        order = 0
        for tile in self.semantic.get("tiles", []):
            if not isinstance(tile, dict):
                continue
            tile_info = self.tile_screen_info(tile)
            if tile_info is None:
                continue
            x, y_byond, px, py = tile_info
            context = self.tile_context(tile)

            appearance = tile.get("appearance")
            if isinstance(appearance, dict):
                if appearance_is_visible(appearance):
                    entries.append(
                        {
                            "appearance": appearance,
                            "tile_px": px,
                            "tile_py": py,
                            "context": context,
                            "layer_kind": "turf",
                            "group": 0,
                            "local_x": x,
                            "local_y": y_byond,
                            "order": order,
                        }
                    )
                    order += 1
            else:
                self.problem(
                    f"missing-turf-appearance:{context}",
                    f"{context}: missing turf appearance metadata; regenerate with updated workbench",
                )
                if self.allow_schematic_fallback:
                    self.draw_schematic_tile(tile, px, py)

            objects = tile.get("objects") or []
            for index, obj in enumerate(objects):
                if not isinstance(obj, dict) or not semantic_object_is_visible(obj):
                    continue
                obj_context = self.object_context(tile, obj)
                obj_appearance = obj.get("appearance")
                if isinstance(obj_appearance, dict):
                    entries.append(
                        {
                            "appearance": obj_appearance,
                            "tile_px": px,
                            "tile_py": py,
                            "context": obj_context,
                            "layer_kind": "object",
                            "group": 1,
                            "local_x": x,
                            "local_y": y_byond,
                            "order": order + index,
                        }
                    )
                else:
                    self.problem(
                        f"missing-object-appearance:{obj_context}",
                        f"{obj_context}: missing object appearance metadata; regenerate with updated workbench",
                    )
                    if self.allow_schematic_fallback:
                        self.draw_schematic_object(obj, px, py)
            order += len(objects)
        return entries

    def tile_screen_info(self, tile: dict[str, Any]) -> tuple[int, int, int, int] | None:
        local_x = as_int(tile.get("local_x"), 1)
        local_y = as_int(tile.get("local_y"), 1)
        if not self.crop.contains(local_x, local_y):
            return None

        x = local_x - self.crop.min_x
        y = self.crop.max_y - local_y
        if not (0 <= x < self.width and 0 <= y < self.height):
            return None

        px = x * TILE_SIZE
        py = y * TILE_SIZE
        return local_x, local_y, px, py

    @staticmethod
    def entry_sort_key(entry: dict[str, Any]) -> tuple[float, float, int, int, int, int]:
        appearance = entry["appearance"]
        return (
            as_float(appearance.get("plane"), 0.0),
            as_float(appearance.get("layer"), 0.0),
            as_int(entry.get("group"), 0),
            as_int(entry.get("local_y"), 0),
            as_int(entry.get("local_x"), 0),
            as_int(entry.get("order"), 0),
        )

    def render_appearance(
        self,
        appearance: dict[str, Any],
        tile_px: int,
        tile_py: int,
        context: str,
        layer_kind: str,
    ) -> None:
        if not appearance_is_visible(appearance):
            return
        overlays = appearance.get("overlays")
        if self.should_render_base_appearance(appearance, overlays):
            self.render_single_appearance(appearance, tile_px, tile_py, context, layer_kind)
        if not isinstance(overlays, list):
            return
        for index, overlay in enumerate(overlays):
            if isinstance(overlay, dict) and appearance_is_visible(overlay):
                self.render_single_appearance(
                    overlay,
                    tile_px,
                    tile_py,
                    f"{context} overlay[{index}]",
                    "overlay",
                )

    @staticmethod
    def should_render_base_appearance(appearance: dict[str, Any], overlays: Any) -> bool:
        if appearance.get("skip_base"):
            return False
        if "base_icon_exists" in appearance and not as_bool(appearance.get("base_icon_exists")) and isinstance(overlays, list) and overlays:
            return False
        return True

    def render_single_appearance(
        self,
        appearance: dict[str, Any],
        tile_px: int,
        tile_py: int,
        context: str,
        layer_kind: str,
    ) -> None:
        if not appearance_is_visible(appearance):
            return
        frame = self.extract_frame(appearance, context)
        if frame is None:
            if self.allow_schematic_fallback:
                if layer_kind == "turf":
                    self.draw.rectangle(
                        [tile_px, tile_py, tile_px + TILE_SIZE - 1, tile_py + TILE_SIZE - 1],
                        fill=SCHEMATIC_COLORS["floor"],
                    )
                else:
                    self.draw.rectangle(
                        [tile_px + 8, tile_py + 8, tile_px + 23, tile_py + 23],
                        fill=SCHEMATIC_COLORS["object"],
                    )
            return

        alpha = as_int(appearance.get("alpha"), 255)
        frame = apply_color(alpha_adjust(frame, alpha), appearance.get("color"))

        pixel_x = as_int(appearance.get("pixel_x"), 0)
        pixel_y = as_int(appearance.get("pixel_y"), 0)
        draw_x = tile_px + pixel_x
        draw_y = tile_py - pixel_y - max(0, frame.height - TILE_SIZE)
        alpha_composite_at(self.image, frame, draw_x, draw_y)

    def extract_frame(self, appearance: dict[str, Any], context: str) -> Image.Image | None:
        icon_path = self.resolve_icon_path(appearance.get("icon"), context)
        if icon_path is None:
            return None
        icon_state = normalize_icon_state(appearance.get("icon_state"))
        direction = direction_for_dmitool(appearance)
        key = (str(icon_path), icon_state, direction)
        if key in self.frame_cache:
            cached = self.frame_cache[key]
            return cached.copy() if cached is not None else None

        image_path = self.extract_to_cache(icon_path, icon_state, direction, context)
        if image_path is None and direction is not None:
            image_path = self.extract_to_cache(icon_path, icon_state, None, context, retry=True)
        if image_path is None:
            self.frame_cache[key] = None
            return None

        try:
            image = Image.open(image_path).convert("RGBA")
        except OSError as exc:
            self.problem(
                f"load-failed:{icon_path}:{icon_state}:{direction}",
                f"{context}: extracted PNG could not be read: {image_path} ({exc})",
            )
            self.frame_cache[key] = None
            return None

        self.frame_cache[key] = image.copy()
        return image

    def extract_to_cache(
        self,
        icon_path: Path,
        icon_state: str,
        direction: str | None,
        context: str,
        retry: bool = False,
    ) -> Path | None:
        cache_key = self.cache_key(icon_path, icon_state, direction)
        out_path = self.cache_dir / f"{cache_key}.png"
        if out_path.exists():
            return out_path
        if dmitool is None:
            self.problem(
                "dmitool-import",
                f"{context}: failed to import tools/dmitool/dmitool.py ({DMITOOL_IMPORT_ERROR})",
            )
            return None

        try:
            process = self.start_dmitool_extract(icon_path, out_path, icon_state, direction)
            stdout, stderr = process.communicate()
            return_code = process.returncode
        except FileNotFoundError as exc:
            self.problem(
                "dmitool-java-missing",
                f"{context}: Java/dmitool launch failed ({exc}); ensure Java and tools/dmitool/dmitool.jar are available",
            )
            return None
        except OSError as exc:
            self.problem(
                f"dmitool-launch:{icon_path}:{icon_state}:{direction}",
                f"{context}: dmitool launch failed for icon={icon_path} state={icon_state!r} dir={direction}: {exc}",
            )
            return None

        if return_code != 0 or not out_path.exists():
            if out_path.exists():
                out_path.unlink()
            if retry:
                dmitool_output = self.format_dmitool_output(stdout, stderr)
                details = f" ({dmitool_output})" if dmitool_output else ""
                self.problem(
                    f"dmitool-failed:{icon_path}:{icon_state}:none",
                    f"{context}: DMI extraction failed icon={icon_path} state={icon_state!r} without direction{details}",
                )
            return None
        return out_path

    @staticmethod
    def start_dmitool_extract(icon_path: Path, out_path: Path, icon_state: str, direction: str | None) -> subprocess.Popen:
        if hasattr(dmitool, "_dmitool_call"):
            args = ["extract", str(icon_path), icon_state, str(out_path)]
            if direction is not None:
                args.extend(("direction", str(direction)))
            return dmitool._dmitool_call(  # type: ignore[attr-defined]
                *args,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        return dmitool.extract_state(str(icon_path), str(out_path), icon_state, direction=direction)

    @staticmethod
    def format_dmitool_output(stdout: bytes | str | None, stderr: bytes | str | None, limit: int = 500) -> str:
        chunks: list[str] = []
        for value in (stdout, stderr):
            if value is None:
                continue
            if isinstance(value, bytes):
                text = value.decode("utf-8", errors="replace")
            else:
                text = value
            text = text.strip()
            if text:
                chunks.append(text)
        combined = "\n".join(chunks)
        if len(combined) > limit:
            return combined[:limit] + f"\n... truncated {len(combined) - limit} characters"
        return combined

    def cache_key(self, icon_path: Path, icon_state: str, direction: str | None) -> str:
        stat = icon_path.stat()
        raw = "\0".join(
            [
                str(icon_path.relative_to(REPO_ROOT)),
                icon_state,
                direction or "",
                str(stat.st_mtime_ns),
                str(stat.st_size),
            ]
        )
        return hashlib.sha1(raw.encode("utf-8")).hexdigest()

    def resolve_icon_path(self, raw_icon: Any, context: str) -> Path | None:
        if raw_icon is None:
            self.problem(
                f"missing-icon:{context}",
                f"{context}: appearance has no icon path",
            )
            return None
        text = str(raw_icon).strip().strip("\"'")
        if not text or text.lower() == "null":
            self.problem(
                f"missing-icon:{context}",
                f"{context}: appearance has no icon path",
            )
            return None
        text = text.replace("\\", "/")
        if text.startswith("./"):
            text = text[2:]
        candidate = (REPO_ROOT / text).resolve()
        try:
            candidate.relative_to(REPO_ROOT)
        except ValueError:
            self.problem(
                f"icon-outside-repo:{context}:{text}",
                f"{context}: icon path escapes repo root: {text}",
            )
            return None
        if not candidate.exists():
            self.problem(
                f"icon-missing:{context}:{text}",
                f"{context}: icon file does not exist: {text}",
            )
            return None
        return candidate

    def draw_schematic_tile(self, tile: dict[str, Any], px: int, py: int) -> None:
        flags = tile.get("flags") or {}
        color = SCHEMATIC_COLORS["empty"]
        if flags.get("wall"):
            color = SCHEMATIC_COLORS["wall"]
        elif flags.get("door"):
            color = SCHEMATIC_COLORS["door"]
        elif flags.get("floor"):
            color = SCHEMATIC_COLORS["floor"]
        self.draw.rectangle([px, py, px + TILE_SIZE - 1, py + TILE_SIZE - 1], fill=color)

    def draw_schematic_object(self, obj: dict[str, Any], px: int, py: int) -> None:
        self.draw.rectangle([px + 8, py + 8, px + 23, py + 23], fill=SCHEMATIC_COLORS["object"])
        basename = str(obj.get("path") or "?").rsplit("/", 1)[-1]
        self.draw.text((px + 10, py + 10), (basename[:1] or "?").upper(), fill=(255, 255, 255, 255))

    def tile_context(self, tile: dict[str, Any]) -> str:
        return (
            f"case={self.case_id} tile=({tile.get('local_x')},{tile.get('local_y')}) "
            f"world=({tile.get('x')},{tile.get('y')}) turf={tile.get('turf')}"
        )

    def object_context(self, tile: dict[str, Any], obj: dict[str, Any]) -> str:
        return (
            f"case={self.case_id} tile=({tile.get('local_x')},{tile.get('local_y')}) "
            f"world=({tile.get('x')},{tile.get('y')}) object={obj.get('path')}"
        )

    def problem(self, key: str, message: str) -> None:
        if key in self.problem_keys:
            return
        self.problem_keys.add(key)
        self.problems.append(message)


def main() -> int:
    parser = argparse.ArgumentParser(description="Render semantic JSON using real DMI appearances.")
    parser.add_argument("--semantic-json", required=True, type=Path, help="Path to semantic.json")
    parser.add_argument("--output", required=True, type=Path, help="Path to save semantic_sprites.png")
    parser.add_argument(
        "--cache-dir",
        default=DEFAULT_CACHE_DIR,
        type=Path,
        help="Directory for extracted DMI sprite cache",
    )
    parser.add_argument(
        "--allow-schematic-fallback",
        action="store_true",
        help="Developer/debug only: allow placeholder rendering when appearance metadata is missing",
    )
    parser.add_argument("--full-canvas", action="store_true", help="Render the complete semantic canvas")
    parser.add_argument("--crop-padding", default=DEFAULT_CROP_PADDING, type=int, help="Tiles to keep around useful content")
    args = parser.parse_args()

    try:
        semantic = load_json(args.semantic_json)
    except (OSError, json.JSONDecodeError) as exc:
        print(f"Error: could not load {args.semantic_json}: {exc}", file=sys.stderr)
        return 1

    renderer = SpriteRenderer(
        semantic=semantic,
        semantic_path=args.semantic_json,
        output_path=args.output,
        cache_dir=args.cache_dir,
        allow_schematic_fallback=args.allow_schematic_fallback,
        crop=compute_crop_bounds(semantic, padding=args.crop_padding, full_canvas=args.full_canvas),
    )
    return 0 if renderer.render() else 1


if __name__ == "__main__":
    raise SystemExit(main())
