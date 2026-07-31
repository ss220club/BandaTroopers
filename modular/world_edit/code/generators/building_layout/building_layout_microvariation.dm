/datum/world_edit_generator/building_layout/proc/apply_building_microvariation(datum/world_edit_building_layout_state/state)
	if(!istype(state) || state.has_errors())
		return
	if(state.config["microvariation_applied"])
		return
	var/detail_budget = get_building_microvariation_budget(state)
	if(detail_budget <= 0)
		return

	add_building_floor_rhythm_anchors(state, detail_budget)
	add_building_facade_panel_anchors(state, detail_budget)
	add_building_service_patch_anchors(state, detail_budget)
	add_building_wear_patch_anchors(state, detail_budget)
	add_building_symmetric_ritual_hint_anchors(state)
	place_building_microvariation_details(state, detail_budget)
	state.config["microvariation_applied"] = TRUE

/datum/world_edit_generator/building_layout/proc/has_building_microvariation_anchors(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !islist(state.fixtures.anchor_turfs))
		return FALSE
	var/prefix = "microvariation_"
	for(var/anchor_id as anything in state.fixtures.anchor_turfs)
		if(copytext("[anchor_id]", 1, length(prefix) + 1) == prefix)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/get_building_microvariation_budget(datum/world_edit_building_layout_state/state)
	var/detail_budget = clamp(round(text2num("[state.config["detail_budget"]]") || 0), 0, 100)
	if(detail_budget <= 0)
		return 0
	var/detail_bias = clamp(round(text2num("[state.archetype?.detail_bias]") || detail_budget), 0, 100)
	return round((detail_budget + detail_bias) / 2)

/datum/world_edit_generator/building_layout/proc/get_building_microvariation_floor_path(datum/world_edit_building_layout_state/state)
	switch(state?.archetype?.id)
		if("storage", "security", "checkpoint", "workshop", "kitchen")
			return "/obj/effect/decal/warning_stripes"
		if("ritual_chamber", "chapel")
			return "/obj/effect/decal/hefa_cult_decals"
		if("hydroponics")
			return "/obj/effect/decal/cleanable/dirt/greenglow"
	return "/obj/effect/decal/strata_decals/grime/grime1"

/datum/world_edit_generator/building_layout/proc/get_building_microvariation_wear_path(datum/world_edit_building_layout_state/state)
	if("[state?.archetype?.suggested_shell_preset]" == "covenant" || state?.archetype?.id == "ritual_chamber")
		return "/obj/effect/decal/hefa_cult_decals/d32"
	return "/obj/effect/decal/strata_decals/grime/grime2"

/datum/world_edit_generator/building_layout/proc/can_place_building_microvariation_detail(datum/world_edit_building_layout_state/state, turf/target_turf, wall_allowed = FALSE)
	if(!istype(state) || !istype(target_turf))
		return FALSE
	if(state.geometry.door_dirs[target_turf] || state.fixtures.fixture_lookup[target_turf])
		return FALSE
	if(wall_allowed && state.geometry.wall_lookup[target_turf])
		return TRUE
	return can_anchor_building_microvariation_floor(state, target_turf)

/datum/world_edit_generator/building_layout/proc/get_building_microvariation_detail_dir(datum/world_edit_building_layout_state/state, turf/target_turf, anchor_id)
	if(!istype(state) || !istype(target_turf))
		return SOUTH
	if(findtext("[anchor_id]", "facade"))
		return get_outward_dir(target_turf, state.geometry.footprint_lookup, (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2, (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2, state.placement_dir)
	if(findtext("[anchor_id]", "ritual"))
		return get_cardinal_dir_toward(target_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, state.placement_dir)
	if(state.request?.microvariation_rng?.chance(50))
		return state.placement_dir
	return turn(state.placement_dir, 90)

/datum/world_edit_generator/building_layout/proc/place_building_microvariation_anchor_details(datum/world_edit_building_layout_state/state, anchor_id, path_value, max_count, list/used_lookup, wall_allowed = FALSE)
	if(!istype(state) || !islist(used_lookup) || max_count <= 0)
		return 0
	var/obj_path = resolve_building_type_path(path_value, /obj)
	if(!obj_path)
		return 0
	var/placed = 0
	for(var/turf/target_turf as anything in state.get_anchor_turfs(anchor_id))
		if(placed >= max_count)
			break
		if(!istype(target_turf) || used_lookup[target_turf])
			continue
		if(!can_place_building_microvariation_detail(state, target_turf, wall_allowed))
			continue
		if(state.request?.microvariation_rng && !state.request.microvariation_rng.chance(75))
			continue
		var/detail_dir = get_building_microvariation_detail_dir(state, target_turf, anchor_id)
		state.fixtures.object_placements += list(build_object_placement("microvariation", target_turf, obj_path, detail_dir))
		state.validation.microvariation_count++
		used_lookup[target_turf] = TRUE
		placed++
	return placed

/datum/world_edit_generator/building_layout/proc/place_building_microvariation_details(datum/world_edit_building_layout_state/state, detail_budget)
	if(!istype(state) || detail_budget <= 0)
		return
	var/list/used_lookup = list()
	var/floor_budget = min(14, max(1, round(detail_budget / 10)))
	var/facade_budget = min(10, max(1, round(detail_budget / 14)))
	var/service_budget = min(8, max(1, round(detail_budget / 16)))
	var/wear_budget = min(10, max(1, round(detail_budget / 14)))
	var/ritual_budget = min(7, max(1, round(detail_budget / 18)))
	place_building_microvariation_anchor_details(state, "microvariation_ritual_focus_hint", "/obj/effect/decal/hefa_cult_decals/d96", ritual_budget, used_lookup)
	place_building_microvariation_anchor_details(state, "microvariation_ritual_symmetric_pair", "/obj/effect/decal/hefa_cult_decals/d32", ritual_budget, used_lookup)
	place_building_microvariation_anchor_details(state, "microvariation_ritual_axis", "/obj/effect/decal/cleanable/crayon", ritual_budget, used_lookup)
	place_building_microvariation_anchor_details(state, "microvariation_facade_panel", "/obj/effect/decal/warning_stripes", facade_budget, used_lookup, TRUE)
	place_building_microvariation_anchor_details(state, "microvariation_service_patch", "/obj/effect/decal/cleanable/dirt", service_budget, used_lookup)
	place_building_microvariation_anchor_details(state, "microvariation_wear_patch", get_building_microvariation_wear_path(state), wear_budget, used_lookup)
	place_building_microvariation_anchor_details(state, "microvariation_floor_rhythm", get_building_microvariation_floor_path(state), floor_budget, used_lookup)

/datum/world_edit_generator/building_layout/proc/can_anchor_building_microvariation_floor(datum/world_edit_building_layout_state/state, turf/target_turf)
	if(!istype(state) || !istype(target_turf))
		return FALSE
	if(!state.geometry.floor_lookup[target_turf])
		return FALSE
	if(state.geometry.wall_lookup[target_turf] || state.geometry.door_dirs[target_turf])
		return FALSE
	if(state.geometry.reserved_lookup[target_turf] || state.fixtures.fixture_lookup[target_turf])
		return FALSE
	if(state.has_anchor("door_cone", target_turf))
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/add_building_floor_rhythm_anchors(datum/world_edit_building_layout_state/state, detail_budget)
	var/stride = detail_budget >= 70 ? 2 : 3
	var/phase = state.request?.microvariation_rng?.next_between(0, stride - 1) || 0
	var/target_count = min(48, max(4, round(length(state.geometry.floor_turfs) * detail_budget / 220)))
	var/placed = 0
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		if(placed >= target_count)
			break
		if(!can_anchor_building_microvariation_floor(state, floor_turf))
			continue
		var/front_depth = world_edit_building_front_depth(floor_turf, state.geometry.bounds, state.placement_dir)
		var/lateral = round(world_edit_building_lateral_offset(floor_turf, state.geometry.bounds, state.placement_dir) + state.geometry.max_lateral_abs)
		if(((front_depth + lateral + phase) % stride) != 0)
			continue
		state.add_anchor("microvariation_floor_rhythm", floor_turf)
		state.add_anchor((front_depth % 2) ? "microvariation_floor_rhythm_a" : "microvariation_floor_rhythm_b", floor_turf)
		placed++

/datum/world_edit_generator/building_layout/proc/add_building_facade_panel_anchors(datum/world_edit_building_layout_state/state, detail_budget)
	var/list/door_lookup = GLOB.world_edit_placement_shapes.world_edit_build_turf_lookup(state.geometry.door_turfs)
	var/list/window_lookup = GLOB.world_edit_placement_shapes.world_edit_build_turf_lookup(state.geometry.window_turfs)
	var/panel_stride = detail_budget >= 75 ? 2 : 3
	var/phase = state.request?.microvariation_rng?.next_between(0, panel_stride - 1) || 0
	var/center_x = (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2
	var/center_y = (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2
	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(!istype(boundary_turf) || !state.geometry.wall_lookup[boundary_turf])
			continue
		if(door_lookup[boundary_turf] || window_lookup[boundary_turf])
			continue
		if(is_corner_boundary_turf(boundary_turf, state.geometry.footprint_lookup))
			continue
		var/outward_dir = get_outward_dir(boundary_turf, state.geometry.footprint_lookup, center_x, center_y, state.placement_dir)
		var/side_coord = (outward_dir in list(NORTH, SOUTH)) ? boundary_turf.x : boundary_turf.y
		if(((side_coord + phase) % panel_stride) != 0)
			continue
		state.add_anchor("microvariation_facade_panel", boundary_turf)
		state.add_anchor("microvariation_facade_panel_[get_building_dir_anchor_suffix(outward_dir)]", boundary_turf)
		if(building_microvariation_turf_touches_lookup(boundary_turf, window_lookup))
			state.add_anchor("microvariation_facade_window_panel", boundary_turf)

/datum/world_edit_generator/building_layout/proc/add_building_service_patch_anchors(datum/world_edit_building_layout_state/state, detail_budget)
	var/target_count = min(24, max(2, round(length(state.geometry.floor_turfs) * detail_budget / 320)))
	var/placed = 0
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		if(placed >= target_count)
			break
		if(!can_anchor_building_microvariation_floor(state, floor_turf))
			continue
		if(!is_building_microvariation_service_candidate(state, floor_turf))
			continue
		state.add_anchor("microvariation_service_patch", floor_turf)
		if(length(get_adjacent_wall_dirs_for_state(state, floor_turf)))
			state.add_anchor("microvariation_service_wall_patch", floor_turf)
		placed++

/datum/world_edit_generator/building_layout/proc/add_building_wear_patch_anchors(datum/world_edit_building_layout_state/state, detail_budget)
	var/target_count = min(32, max(2, round(length(state.geometry.floor_turfs) * detail_budget / 280)))
	var/placed = 0
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		if(placed >= target_count)
			break
		if(!can_anchor_building_microvariation_floor(state, floor_turf))
			continue
		if(!is_building_microvariation_wear_candidate(state, floor_turf))
			continue
		state.add_anchor("microvariation_wear_patch", floor_turf)
		var/wear_anchor = length(get_adjacent_wall_dirs_for_state(state, floor_turf)) >= 2 ? "microvariation_wear_heavy" : "microvariation_wear_light"
		state.add_anchor(wear_anchor, floor_turf)
		placed++

/datum/world_edit_generator/building_layout/proc/add_building_symmetric_ritual_hint_anchors(datum/world_edit_building_layout_state/state)
	var/ritual_zone_id = get_building_ritual_zone_id(state)
	if(!length(ritual_zone_id))
		return
	var/turf/focus_turf = state.get_zone_focus(ritual_zone_id) || state.geometry.semantic_hub_turf || state.geometry.center_turf
	if(!can_anchor_building_microvariation_floor(state, focus_turf))
		return
	state.add_anchor("microvariation_ritual_focus_hint", focus_turf)
	state.add_anchor("microvariation_symmetric_ritual_hint", focus_turf)

	var/side_positive = get_side_axis_positive_dir(state.placement_dir)
	var/side_negative = get_side_axis_negative_dir(state.placement_dir)
	var/max_pairs = 3
	for(var/offset in 1 to max_pairs)
		var/turf/left_turf = get_building_microvariation_offset_turf(focus_turf, side_negative, offset)
		var/turf/right_turf = get_building_microvariation_offset_turf(focus_turf, side_positive, offset)
		if(!can_anchor_building_microvariation_floor(state, left_turf) || !can_anchor_building_microvariation_floor(state, right_turf))
			continue
		state.add_anchor("microvariation_ritual_symmetric_pair", left_turf)
		state.add_anchor("microvariation_ritual_symmetric_pair", right_turf)
		state.add_anchor("microvariation_ritual_left_hint", left_turf)
		state.add_anchor("microvariation_ritual_right_hint", right_turf)

	var/forward_dir = state.placement_dir
	var/back_dir = turn(state.placement_dir, 180)
	for(var/axis_step in 1 to 3)
		var/turf/forward_turf = get_building_microvariation_offset_turf(focus_turf, forward_dir, axis_step)
		if(can_anchor_building_microvariation_floor(state, forward_turf))
			state.add_anchor("microvariation_ritual_axis", forward_turf)
		var/turf/back_turf = get_building_microvariation_offset_turf(focus_turf, back_dir, axis_step)
		if(can_anchor_building_microvariation_floor(state, back_turf))
			state.add_anchor("microvariation_ritual_axis", back_turf)

/datum/world_edit_generator/building_layout/proc/get_building_dir_anchor_suffix(direction)
	switch(direction)
		if(NORTH)
			return "north"
		if(SOUTH)
			return "south"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
	return "unknown"

/datum/world_edit_generator/building_layout/proc/building_microvariation_turf_touches_lookup(turf/target_turf, list/turf_lookup)
	if(!istype(target_turf) || !islist(turf_lookup))
		return FALSE
	for(var/check_dir in GLOB.cardinals)
		if(turf_lookup[get_step(target_turf, check_dir)])
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/is_building_microvariation_service_candidate(datum/world_edit_building_layout_state/state, turf/target_turf)
	if(state.has_anchor("service_strip", target_turf))
		return TRUE
	var/zone_id = state.get_zone(target_turf)
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
	if(!istype(zone_spec))
		return FALSE
	if(zone_spec.role in list("service", "storage", "support", "secure"))
		return TRUE
	if(findtext(lowertext("[zone_spec.id] [zone_spec.label] [zone_spec.role]"), "service"))
		return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/is_building_microvariation_wear_candidate(datum/world_edit_building_layout_state/state, turf/target_turf)
	for(var/check_dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(target_turf, check_dir)
		if(state.fixtures.fixture_lookup[nearby_turf] || state.fixtures.wall_fixture_turfs.Find(nearby_turf))
			return TRUE
	if(length(get_adjacent_wall_dirs_for_state(state, target_turf)) >= 2)
		return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/get_building_ritual_zone_id(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.semantic_plan))
		return ""
	var/list/needles = list("chapel", "ritual", "covenant", "altar", "reliquary", "shrine")
	if(building_microvariation_text_matches_any("[state.archetype?.id] [state.archetype?.label]", needles))
		return state.semantic_plan.hub_zone_id || state.semantic_plan.primary_zone_id
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in state.semantic_plan.zone_specs)
		if(!istype(zone_spec))
			continue
		if(building_microvariation_text_matches_any("[zone_spec.id] [zone_spec.label] [zone_spec.role]", needles))
			return zone_spec.id
		for(var/anchor_tag as anything in zone_spec.anchor_tags)
			if(building_microvariation_text_matches_any("[anchor_tag]", needles))
				return zone_spec.id
	return ""

/datum/world_edit_generator/building_layout/proc/building_microvariation_text_matches_any(value, list/needles)
	var/text_value = lowertext("[value]")
	for(var/needle as anything in needles)
		if(findtext(text_value, lowertext("[needle]")))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/get_building_microvariation_offset_turf(turf/start_turf, direction, distance)
	var/turf/current_turf = start_turf
	var/steps = max(round(distance), 0)
	if(!steps)
		return current_turf
	for(var/step_index in 1 to steps)
		current_turf = get_step(current_turf, direction)
	return current_turf
