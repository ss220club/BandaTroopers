/// Keep the native full-cell shadow pipeline for ordinary masks.
/atom/movable/lighting_mask/proc/is_full_shadow_blocker(turf/target)
	return !!target.directional_opacity

/atom/movable/lighting_mask/proc/can_skip_small_shadows()
	return TRUE

/atom/movable/lighting_mask/proc/append_border_shadows(list/overlays_to_add)
	return

/atom/movable/lighting_mask/proc/shadow_geometry_candidates(list/visible_turfs, turf/origin, view_range)
	return visible_turfs

/turf
	/// Geometry subscriptions only. These never confer visibility or get_lumcount.
	var/tmp/list/atom/movable/lighting_mask/flashlight_60/directional_shadow_watchers

/atom/movable/lighting_mask/flashlight_60
	var/list/turf/shadow_geometry_turfs
	var/list/turf/shadow_watch_turfs

/// BYOND opacity hides the whole cell, even for our custom ON_BORDER objects.
/// Only scenes containing a visible thin blocker need the broader local geometry.
/atom/movable/lighting_mask/flashlight_60/shadow_geometry_candidates(list/visible_turfs, turf/origin, view_range)
	var/has_border = FALSE
	for(var/turf/target as anything in visible_turfs)
		if(target.directional_opacity && !is_full_shadow_blocker(target))
			has_border = TRUE
			break
	if(!has_border)
		clear_shadow_watchers()
		shadow_geometry_turfs = visible_turfs
		return visible_turfs
	// Controller caps production beams at radius10 (at most441 geometry cells).
	var/turf/lower = locate(max(1, origin.x - view_range), max(1, origin.y - view_range), origin.z)
	var/turf/upper = locate(min(world.maxx, origin.x + view_range), min(world.maxy, origin.y + view_range), origin.z)
	var/list/candidates = block(lower, upper)
	for(var/turf/previous as anything in shadow_watch_turfs)
		if(!(previous in candidates))
			LAZYREMOVE(previous.directional_shadow_watchers, src)
	for(var/turf/target as anything in candidates)
		if(!(target in shadow_watch_turfs))
			LAZYOR(target.directional_shadow_watchers, src)
	shadow_watch_turfs = candidates
	shadow_geometry_turfs = candidates
	return candidates

/atom/movable/lighting_mask/flashlight_60/proc/clear_shadow_watchers()
	for(var/turf/target as anything in shadow_watch_turfs)
		LAZYREMOVE(target.directional_shadow_watchers, src)
	shadow_watch_turfs = null
	shadow_geometry_turfs = null

/atom/movable/lighting_mask/flashlight_60/Destroy(force)
	clear_shadow_watchers()
	return ..()

/// Turf replacement must queue watchers before its old subscriptions disappear.
/turf/proc/release_directional_shadow_watchers()
	for(var/atom/movable/lighting_mask/flashlight_60/mask as anything in directional_shadow_watchers)
		LAZYREMOVE(mask.shadow_watch_turfs, src)
		LAZYREMOVE(mask.shadow_geometry_turfs, src)
		mask.queue_mask_update()
	directional_shadow_watchers = null

/// Four opaque borders are not a solid cell: a source may be inside them.
/atom/movable/lighting_mask/flashlight_60/is_full_shadow_blocker(turf/target)
	if(target.opacity)
		return TRUE
	for(var/atom/movable/blocker as anything in target.opacity_sources)
		if(!(blocker.flags_atom & ON_BORDER))
			return TRUE
	return FALSE

/atom/movable/lighting_mask/flashlight_60/can_skip_small_shadows()
	return FALSE

/// Reuse native extrusion, matrices and compositor; only border extraction differs.
/// Geometry-only candidates never enter the gameplay contribution lists.
/atom/movable/lighting_mask/flashlight_60/append_border_shadows(list/overlays_to_add)
	var/list/lines = list()
	var/list/seen = list()
	for(var/turf/target as anything in shadow_geometry_turfs)
		if(!target.directional_opacity || is_full_shadow_blocker(target))
			continue
		var/left = target.x - 0.5
		var/right = target.x + 0.5
		var/bottom = target.y - 0.5
		var/top = target.y + 0.5
		if(target.directional_opacity & NORTH)
			add_border_shadow_line(lines, seen, left, top, right, top)
		if(target.directional_opacity & SOUTH)
			add_border_shadow_line(lines, seen, left, bottom, right, bottom)
		if(target.directional_opacity & EAST)
			add_border_shadow_line(lines, seen, right, bottom, right, top)
		if(target.directional_opacity & WEST)
			add_border_shadow_line(lines, seen, left, bottom, left, top)
	if(!length(lines))
		return
	for(var/list/triangle as anything in calculate_triangle_vertices(lines))
		var/matrix/triangle_matrix = triangle_to_matrix(triangle)
		triangle_matrix /= transform
		var/mutable_appearance/shadow = new()
		shadow.icon = LIGHTING_ICON_BIG
		shadow.icon_state = "triangle"
		shadow.color = "#000"
		shadow.transform = triangle_matrix
		shadow.render_target = SHADOW_RENDER_TARGET
		shadow.blend_mode = BLEND_OVERLAY
		LAZYADD(shadows, shadow)
		overlays_to_add += shadow

/// A border casts from either side. Collinear sources have no finite shadow wedge.
/atom/movable/lighting_mask/flashlight_60/proc/add_border_shadow_line(list/lines, list/seen, x1, y1, x2, y2)
	if((x1 == x2 && x1 == calculated_position_x) || (y1 == y2 && y1 == calculated_position_y))
		return
	var/key = "[x1],[y1],[x2],[y2]"
	if(seen[key])
		return
	seen[key] = TRUE
	lines += list(list(list(x1, y1), list(x2, y2)))

/// Partial opacity changes previously skipped the native full-cell invalidation.
/turf/proc/reconsider_directional_lights()
	for(var/atom/movable/lighting_mask/flashlight_60/mask in hybrid_lights_affecting)
		mask.queue_mask_update()
	for(var/atom/movable/lighting_mask/flashlight_60/mask as anything in directional_shadow_watchers)
		mask.queue_mask_update()

/// Direction signals precede dir assignment, so calculate using their new value.
/datum/element/light_blocking/proc/on_directional_blocker_turn(atom/movable/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir || !(source.flags_atom & ON_BORDER) || !isturf(source.loc))
		return
	for(var/turf/target as anything in source.locs)
		target.recalculate_directional_opacity(source, new_dir)
