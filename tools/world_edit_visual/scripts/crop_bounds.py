from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterable


DEFAULT_CROP_PADDING = 3


@dataclass(frozen=True)
class TileBounds:
    min_x: int
    min_y: int
    max_x: int
    max_y: int

    @property
    def width(self) -> int:
        return self.max_x - self.min_x + 1

    @property
    def height(self) -> int:
        return self.max_y - self.min_y + 1

    def contains(self, local_x: int, local_y: int) -> bool:
        return self.min_x <= local_x <= self.max_x and self.min_y <= local_y <= self.max_y

    def clamp_rect(self, min_x: int, min_y: int, max_x: int, max_y: int) -> "TileBounds | None":
        clipped_min_x = max(self.min_x, min_x)
        clipped_min_y = max(self.min_y, min_y)
        clipped_max_x = min(self.max_x, max_x)
        clipped_max_y = min(self.max_y, max_y)
        if clipped_min_x > clipped_max_x or clipped_min_y > clipped_max_y:
            return None
        return TileBounds(clipped_min_x, clipped_min_y, clipped_max_x, clipped_max_y)


def full_bounds(semantic: dict[str, Any]) -> TileBounds:
    return TileBounds(
        1,
        1,
        max(1, as_int(semantic.get("width"), 1)),
        max(1, as_int(semantic.get("height"), 1)),
    )


def compute_crop_bounds(
    semantic: dict[str, Any],
    padding: int = DEFAULT_CROP_PADDING,
    full_canvas: bool = False,
) -> TileBounds:
    bounds = full_bounds(semantic)
    if full_canvas:
        return bounds

    points = useful_points(semantic, bounds)
    if not points:
        points = fallback_points(semantic, bounds)
    if not points:
        return bounds

    pad = max(0, int(padding))
    min_x = max(bounds.min_x, min(x for x, _ in points) - pad)
    min_y = max(bounds.min_y, min(y for _, y in points) - pad)
    max_x = min(bounds.max_x, max(x for x, _ in points) + pad)
    max_y = min(bounds.max_y, max(y for _, y in points) + pad)
    return TileBounds(min_x, min_y, max_x, max_y)


def useful_points(semantic: dict[str, Any], bounds: TileBounds) -> list[tuple[int, int]]:
    points: list[tuple[int, int]] = []
    for tile in semantic.get("tiles", []):
        if not isinstance(tile, dict) or not tile_is_useful(tile):
            continue
        point = tile_point(tile, bounds)
        if point is not None:
            points.append(point)

    for room in semantic.get("rooms", []):
        for point in room_points(room, semantic, bounds):
            points.append(point)

    for marker in semantic.get("markers", []):
        point = mapping_point(marker, semantic, bounds)
        if point is not None:
            points.append(point)

    for error in semantic.get("errors", []):
        point = mapping_point(error, semantic, bounds)
        if point is not None:
            points.append(point)

    return points


def fallback_points(semantic: dict[str, Any], bounds: TileBounds) -> list[tuple[int, int]]:
    points: list[tuple[int, int]] = []
    for tile in semantic.get("tiles", []):
        if not isinstance(tile, dict):
            continue
        flags = tile.get("flags") or {}
        if not any(flags.get(key) for key in ("floor", "wall", "door", "error")) and not tile.get("objects"):
            continue
        point = tile_point(tile, bounds)
        if point is not None:
            points.append(point)
    return points


def tile_is_useful(tile: dict[str, Any]) -> bool:
    flags = tile.get("flags") or {}
    if any(flags.get(key) for key in ("changed", "error", "wall", "door", "reserved_walk", "blocked")):
        return True
    return bool(tile.get("objects"))


def room_points(room: Any, semantic: dict[str, Any], bounds: TileBounds) -> Iterable[tuple[int, int]]:
    if not isinstance(room, dict):
        return []
    raw_bounds = room.get("bounds")
    parsed = parse_rect(raw_bounds, semantic, bounds)
    if parsed is None:
        return []
    min_x, min_y, max_x, max_y = parsed
    clipped = bounds.clamp_rect(min_x, min_y, max_x, max_y)
    if clipped is None:
        return []
    return [
        (clipped.min_x, clipped.min_y),
        (clipped.min_x, clipped.max_y),
        (clipped.max_x, clipped.min_y),
        (clipped.max_x, clipped.max_y),
    ]


def parse_rect(raw_bounds: Any, semantic: dict[str, Any], bounds: TileBounds) -> tuple[int, int, int, int] | None:
    if isinstance(raw_bounds, dict):
        values = (
            raw_bounds.get("x1") or raw_bounds.get("min_x"),
            raw_bounds.get("y1") or raw_bounds.get("min_y"),
            raw_bounds.get("x2") or raw_bounds.get("max_x"),
            raw_bounds.get("y2") or raw_bounds.get("max_y"),
        )
    elif isinstance(raw_bounds, (list, tuple)) and len(raw_bounds) == 4:
        values = tuple(raw_bounds)
    else:
        return None

    min_x = localize_coord(values[0], "x", semantic, bounds)
    min_y = localize_coord(values[1], "y", semantic, bounds)
    max_x = localize_coord(values[2], "x", semantic, bounds)
    max_y = localize_coord(values[3], "y", semantic, bounds)
    if None in (min_x, min_y, max_x, max_y):
        return None
    left, right = sorted((min_x, max_x))
    bottom, top = sorted((min_y, max_y))
    return left, bottom, right, top


def tile_point(tile: dict[str, Any], bounds: TileBounds) -> tuple[int, int] | None:
    local_x = as_int(tile.get("local_x"), 0)
    local_y = as_int(tile.get("local_y"), 0)
    if bounds.contains(local_x, local_y):
        return local_x, local_y
    return None


def mapping_point(mapping: Any, semantic: dict[str, Any], bounds: TileBounds) -> tuple[int, int] | None:
    if not isinstance(mapping, dict):
        return None
    raw_x = mapping.get("local_x")
    raw_y = mapping.get("local_y")
    if raw_x is None:
        raw_x = mapping.get("x") or mapping.get("world_x")
    if raw_y is None:
        raw_y = mapping.get("y") or mapping.get("world_y")
    local_x = localize_coord(raw_x, "x", semantic, bounds)
    local_y = localize_coord(raw_y, "y", semantic, bounds)
    if local_x is None or local_y is None or not bounds.contains(local_x, local_y):
        return None
    return local_x, local_y


def localize_coord(value: Any, axis: str, semantic: dict[str, Any], bounds: TileBounds) -> int | None:
    raw = as_int(value, 0)
    if raw <= 0:
        return None
    if axis == "x":
        max_local = bounds.max_x
        origin_value = as_int((semantic.get("origin") or {}).get("x"), 1)
    else:
        max_local = bounds.max_y
        origin_value = as_int((semantic.get("origin") or {}).get("y"), 1)

    if origin_value > 1 and raw >= origin_value:
        local = raw - origin_value + 1
        if 1 <= local <= max_local:
            return local
    if 1 <= raw <= max_local:
        return raw
    return raw


def as_int(value: Any, default: int = 0) -> int:
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return default
