/datum/world_edit_generator/building_layout/proc/extract_building_anchors(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		var/zone_id = state.get_zone(floor_turf)
		if(length(zone_id))
			state.add_anchor(zone_id, floor_turf)
			var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
			if(istype(zone_spec))
				for(var/anchor_tag as anything in zone_spec.anchor_tags)
					state.add_anchor("[anchor_tag]", floor_turf)
		if(state.geometry.reserved_lookup[floor_turf])
			state.add_anchor("primary_lane", floor_turf)
		if(length(get_adjacent_wall_dirs_for_state(state, floor_turf)))
			state.add_anchor("wall_anchor", floor_turf)
		if(is_corner_floor_anchor(state, floor_turf))
			state.add_anchor("corner_anchor", floor_turf)

	add_door_cone_anchors(state)
	add_window_band_anchors(state)
	if(istype(state.geometry.center_turf))
		state.add_anchor("focus_center", state.geometry.center_turf)
		for(var/check_dir in GLOB.cardinals)
			var/turf/focus_turf = get_step(state.geometry.center_turf, check_dir)
			if(state.geometry.floor_lookup[focus_turf] && !state.geometry.reserved_lookup[focus_turf])
				state.add_anchor("focus_ring", focus_turf)
	if(istype(state.geometry.semantic_hub_turf))
		state.add_anchor("semantic_hub", state.geometry.semantic_hub_turf)
	for(var/zone_id as anything in state.geometry.zone_focus_turfs)
		var/turf/zone_focus = state.geometry.zone_focus_turfs[zone_id]
		if(istype(zone_focus))
			state.add_anchor("[zone_id]_focus", zone_focus)
	add_building_signature_anchors(state)

/datum/world_edit_generator/building_layout/proc/refresh_building_semantic_anchors(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	state.clear_anchors()
	extract_building_anchors(state)
	apply_building_facade_rules(state)

/datum/world_edit_generator/building_layout/proc/get_adjacent_wall_dirs_for_state(datum/world_edit_building_layout_state/state, turf/target_turf)
	var/list/wall_dirs = list()
	if(!istype(state) || !istype(target_turf))
		return wall_dirs
	var/list/cached_wall_dirs = state.geometry.adjacent_wall_dirs_by_turf[target_turf]
	if(islist(cached_wall_dirs))
		return cached_wall_dirs
	for(var/check_dir in GLOB.cardinals)
		if(state.geometry.wall_lookup[get_step(target_turf, check_dir)])
			wall_dirs += check_dir
	state.geometry.adjacent_wall_dirs_by_turf[target_turf] = wall_dirs
	return wall_dirs

/datum/world_edit_generator/building_layout/proc/is_corner_floor_anchor(datum/world_edit_building_layout_state/state, turf/target_turf)
	var/list/wall_dirs = get_adjacent_wall_dirs_for_state(state, target_turf)
	if(length(wall_dirs) < 2)
		return FALSE
	for(var/dir_a in wall_dirs)
		for(var/dir_b in wall_dirs)
			if(dir_a == dir_b)
				continue
			if(turn(dir_a, 90) == dir_b || turn(dir_a, -90) == dir_b)
				return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/add_door_cone_anchors(datum/world_edit_building_layout_state/state)
	for(var/turf/door_turf as anything in state.geometry.door_turfs)
		var/list/door_cone_lateral_steps_by_depth = state.geometry.boundary_lookup[door_turf] ? get_building_door_cone_profile(state) : get_building_internal_door_cone_profile(state)
		if(!length(door_cone_lateral_steps_by_depth))
			continue
		var/outward_dir = state.geometry.door_dirs[door_turf] || get_outward_dir(door_turf, state.geometry.footprint_lookup, (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2, (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2, state.placement_dir)
		var/inward_dir = turn(outward_dir, 180)
		for(var/depth_index in 0 to length(door_cone_lateral_steps_by_depth) - 1)
			var/lateral_steps = round(text2num("[door_cone_lateral_steps_by_depth[depth_index + 1]]") || 0)
			var/turf/base_turf = door_turf
			if(depth_index > 0)
				for(var/depth_step in 1 to depth_index)
					base_turf = get_step(base_turf, inward_dir)
					if(!istype(base_turf))
						break
			if(!state.geometry.floor_lookup[base_turf])
				continue
			state.add_anchor("door_cone", base_turf)
			state.add_anchor("primary_lane", base_turf)
			state.add_reserved(base_turf)
			for(var/side_dir as anything in list(turn(inward_dir, 90), turn(inward_dir, -90)))
				var/turf/side_turf = base_turf
				for(var/side_step in 1 to lateral_steps)
					side_turf = get_step(side_turf, side_dir)
					if(!state.geometry.floor_lookup[side_turf])
						break
					state.add_anchor("door_cone", side_turf)
					if(depth_index <= 1)
						state.add_anchor("primary_lane", side_turf)
					state.add_reserved(side_turf)
		var/turf/exterior_buffer_turf = get_step(door_turf, outward_dir)
		if(state.geometry.floor_lookup[exterior_buffer_turf])
			state.add_anchor("door_cone", exterior_buffer_turf)
			state.add_anchor("primary_lane", exterior_buffer_turf)
			state.add_reserved(exterior_buffer_turf)

/datum/world_edit_generator/building_layout/proc/get_building_door_cone_profile(datum/world_edit_building_layout_state/state)
	if(is_building_compact_or_micro_state(state))
		return list(1, 1, 0)
	var/degrade_level = "[state?.config["size_degrade_level"] || WORLD_EDIT_BUILDING_DEGRADE_NONE]"
	if(degrade_level == WORLD_EDIT_BUILDING_DEGRADE_MICRO)
		return list(1, 1, 0)
	if(degrade_level == WORLD_EDIT_BUILDING_DEGRADE_COMPACT)
		return list(1, 1, 0)
	return list(1, 2, 2, 1, 0)

/datum/world_edit_generator/building_layout/proc/get_building_internal_door_cone_profile(datum/world_edit_building_layout_state/state)
	// Internal partitions need a real interaction lane but not the deep
	// approach envelope used by the building's exterior entry.
	return list(1, 1, 0)

/datum/world_edit_generator/building_layout/proc/add_window_band_anchors(datum/world_edit_building_layout_state/state)
	for(var/turf/window_turf as anything in state.geometry.window_turfs)
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby = get_step(window_turf, check_dir)
			if(state.geometry.floor_lookup[nearby])
				state.add_anchor("window_band", nearby)
