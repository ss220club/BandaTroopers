/datum/world_edit_generator/building_layout/proc/world_edit_building_front_depth(turf/target_turf, list/bounds, direction)
	if(!istype(target_turf) || !islist(bounds))
		return 0
	switch(direction)
		if(NORTH)
			return text2num("[bounds["max_y"]]") - target_turf.y
		if(SOUTH)
			return target_turf.y - text2num("[bounds["min_y"]]")
		if(EAST)
			return text2num("[bounds["max_x"]]") - target_turf.x
		if(WEST)
			return target_turf.x - text2num("[bounds["min_x"]]")
	return 0

/datum/world_edit_generator/building_layout/proc/world_edit_building_lateral_offset(turf/target_turf, list/bounds, direction)
	if(!istype(target_turf) || !islist(bounds))
		return 0
	var/center_x = (text2num("[bounds["min_x"]]") + text2num("[bounds["max_x"]]")) / 2
	var/center_y = (text2num("[bounds["min_y"]]") + text2num("[bounds["max_y"]]")) / 2
	if(direction in list(NORTH, SOUTH))
		return target_turf.x - center_x
	return target_turf.y - center_y

/datum/world_edit_generator/building_layout/proc/build_building_layout_state(datum/world_edit_building_request/request, datum/world_edit_shape_contract/shape_contract, list/placement_context, list/validated)
	var/datum/world_edit_building_layout_state/state = new
	state.request = request
	state.config = request.config
	state.archetype = request.archetype
	state.root_seed = round(text2num("[state.config["root_seed"] || request.effective_seed]") || 0)
	state.stage_seed_footprint = build_stage_seed(state.root_seed, "footprint")
	state.stage_seed_rooms = round(text2num("[state.config["stage_seed_geometry"]]") || build_stage_seed(state.root_seed, "geometry"))
	state.stage_seed_corridor = build_stage_seed(state.stage_seed_rooms, "corridor")
	state.stage_seed_patterns = round(text2num("[state.config["stage_seed_fixtures"]]") || build_stage_seed(state.root_seed, "fixtures"))
	state.stage_seed_details = round(text2num("[state.config["stage_seed_microvariation"]]") || build_stage_seed(state.root_seed, "microvariation"))
	state.set_support_status(state.config["current_request_support_status"] || WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED, state.config["user_facing_failure_reason"] || "")
	if(islist(state.config["support_status_report"]))
		state.validation.support_status_report = state.config["support_status_report"].Copy()
	state.add_stage_report("state_init", "ok", null, list("root_seed" = state.root_seed))
	state.geometry.footprint = validated["footprint"]
	state.geometry.boundary = validated["boundary"]
	state.geometry.interior = validated["interior"]
	state.geometry.footprint_lookup = validated["footprint_lookup"]
	state.geometry.bounds = validated["bounds"]
	state.validation.blocked_turf_conflict_count = round(text2num("[validated["blocked_turf_conflict_count"]]") || 0)
	state.validation.replace_blocked_turf_count = round(text2num("[validated["replace_blocked_turf_count"]]") || 0)
	state.geometry.boundary_lookup = GLOB.world_edit_placement_shapes.world_edit_build_turf_lookup(state.geometry.boundary)
	state.placement_dir = text2num("[placement_context["direction"]]")
	if(!(state.placement_dir in GLOB.cardinals))
		state.placement_dir = manager?.get_effective_placement_dir() || NORTH
	state.geometry.requested_direction = state.placement_dir
	state.geometry.actual_entry_direction = state.placement_dir

	if(length(state.geometry.footprint) > WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS)
		state.add_error("Building footprint exceeds cap ([WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS]).")
		state.add_stage_report("footprint", "failed", "footprint cap exceeded")
		return state

	state.request.config["validated_footprint_count"] = length(state.geometry.footprint)
	state.request.config["validated_interior_count"] = length(state.geometry.interior)
	state.request.config["validated_boundary_count"] = length(state.geometry.boundary)
	state.geometry.footprint_hash = build_building_turf_list_hash(state.geometry.footprint)
	state.add_stage_report("footprint", "ok", null, list(
		"footprint_count" = length(state.geometry.footprint),
		"footprint_hash" = state.geometry.footprint_hash,
	))
	var/list/support_report = state.config["support_status_report"]
	if(!length("[state.config["size_degrade_level"]]"))
		state.config["size_degrade_level"] = islist(support_report) ? (support_report["degrade_level"] || WORLD_EDIT_BUILDING_DEGRADE_NONE) : WORLD_EDIT_BUILDING_DEGRADE_NONE
	if(isnull(state.config["program_shedding"]))
		state.config["program_shedding"] = islist(support_report) ? (support_report["program_shedding"] ? TRUE : FALSE) : FALSE
	state.semantic_plan = state.archetype.build_semantic_plan(state.request)
	if(!istype(state.semantic_plan))
		state.add_error("Unable to build semantic plan for [state.archetype.id].")
		state.add_stage_report("semantic_plan", "failed", "semantic plan unavailable")
		return state
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in state.semantic_plan.zone_specs)
		if(!istype(zone_spec) || !zone_spec.required)
			continue
		state.validation.mandatory_zone_count++
		if(zone_spec.divider_mode == "room")
			state.validation.mandatory_room_count++
	state.add_stage_report("semantic_plan", "ok", null, list(
		"program_id" = state.archetype.id,
		"mandatory_room_count" = state.validation.mandatory_room_count,
		"mandatory_zone_count" = state.validation.mandatory_zone_count,
	))
	return state

/datum/world_edit_generator/building_layout/proc/get_room_first_region_specs_for_zone(datum/world_edit_building_layout_state/state, zone_id)
	var/list/result = list()
	if(!istype(state) || !istype(state.semantic_plan) || !length("[zone_id]"))
		return result
	for(var/datum/world_edit_building_region_spec/region_spec as anything in state.semantic_plan.region_specs)
		if(istype(region_spec) && region_spec.zone_id == "[zone_id]")
			result += region_spec
	return result

/datum/world_edit_generator/building_layout/proc/get_building_front_percent(datum/world_edit_building_layout_state/state, turf/target_turf)
	if(!istype(state) || !istype(target_turf))
		return 0
	return round((world_edit_building_front_depth(target_turf, state.geometry.bounds, state.placement_dir) * 100) / max(state.geometry.max_front_depth, 1))

/datum/world_edit_generator/building_layout/proc/get_building_lateral_percent(datum/world_edit_building_layout_state/state, turf/target_turf)
	if(!istype(state) || !istype(target_turf))
		return 0
	return round((world_edit_building_lateral_offset(target_turf, state.geometry.bounds, state.placement_dir) * 100) / max(state.geometry.max_lateral_abs, 1))

/datum/world_edit_generator/building_layout/proc/region_spec_contains_turf(datum/world_edit_building_layout_state/state, datum/world_edit_building_region_spec/region_spec, turf/target_turf)
	if(!istype(state) || !istype(region_spec) || !istype(target_turf))
		return FALSE
	var/front_percent = get_building_front_percent(state, target_turf)
	var/lateral_percent = get_building_lateral_percent(state, target_turf)
	return front_percent >= region_spec.front_min && front_percent <= region_spec.front_max && lateral_percent >= region_spec.lateral_min && lateral_percent <= region_spec.lateral_max

/datum/world_edit_generator/building_layout/proc/extend_solved_region_bounds(datum/world_edit_building_solved_region/region, turf/target_turf)
	if(!istype(region) || !istype(target_turf))
		return
	if(isnull(region.x1) || target_turf.x < region.x1)
		region.x1 = target_turf.x
	if(isnull(region.x2) || target_turf.x > region.x2)
		region.x2 = target_turf.x
	if(isnull(region.y1) || target_turf.y < region.y1)
		region.y1 = target_turf.y
	if(isnull(region.y2) || target_turf.y > region.y2)
		region.y2 = target_turf.y

/datum/world_edit_generator/building_layout/proc/repair_building_zone_coverage(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.semantic_plan))
		return
	for(var/pass in 1 to 3)
		var/repaired_this_pass = FALSE
		for(var/datum/world_edit_building_zone_spec/zone_spec as anything in state.semantic_plan.zone_specs)
			if(!zone_spec.required)
				continue
			var/list/zone_turfs = state.get_zone_turfs(zone_spec.id)
			var/attempts = 0
			while(length(zone_turfs) < zone_spec.min_area && attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS)
				attempts++
				var/turf/repair_turf = select_zone_repair_turf(state, zone_spec)
				if(!istype(repair_turf))
					break
				state.add_zone(repair_turf, zone_spec.id)
				repaired_this_pass = TRUE
				zone_turfs = state.get_zone_turfs(zone_spec.id)
		if(!repaired_this_pass)
			break

/datum/world_edit_generator/building_layout/proc/select_zone_repair_turf(datum/world_edit_building_layout_state/state, datum/world_edit_building_zone_spec/zone_spec)
	var/turf/best_turf = null
	var/best_score = -999999999
	for(var/turf/candidate as anything in state.geometry.interior)
		if(!can_reassign_turf_to_zone(state, candidate, zone_spec))
			continue
		var/score = score_turf_for_zone_repair(state, candidate, zone_spec)
		if(!istype(best_turf) || score > best_score)
			best_turf = candidate
			best_score = score
	return best_turf

/datum/world_edit_generator/building_layout/proc/can_reassign_turf_to_zone(datum/world_edit_building_layout_state/state, turf/candidate, datum/world_edit_building_zone_spec/target_zone_spec)
	if(!istype(state) || !istype(candidate) || !istype(target_zone_spec))
		return FALSE
	if(state.geometry.boundary_lookup[candidate] || state.geometry.wall_lookup[candidate])
		return FALSE
	var/current_zone_id = state.get_zone(candidate)
	if(current_zone_id == target_zone_spec.id)
		return FALSE
	var/datum/world_edit_building_zone_spec/current_zone_spec = state.semantic_plan.get_zone_spec(current_zone_id)
	if(istype(current_zone_spec) && current_zone_spec.required && length(state.get_zone_turfs(current_zone_spec.id)) <= current_zone_spec.min_area)
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/score_turf_for_zone_repair(datum/world_edit_building_layout_state/state, turf/candidate, datum/world_edit_building_zone_spec/zone_spec)
	var/score = 0
	for(var/datum/world_edit_building_region_spec/region_spec as anything in state.semantic_plan.region_specs)
		if(region_spec.zone_id != zone_spec.id)
			continue
		if(region_spec_contains_turf(state, region_spec, candidate))
			score += 200 + region_spec.priority

	var/same_zone_neighbors = 0
	var/boundary_neighbors = 0
	var/route_neighbors = 0
	for(var/check_dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(candidate, check_dir)
		if(state.get_zone(nearby_turf) == zone_spec.id)
			same_zone_neighbors++
		if(state.geometry.boundary_lookup[nearby_turf])
			boundary_neighbors++
		if(state.geometry.reserved_lookup[nearby_turf])
			route_neighbors++
	score += same_zone_neighbors * 90
	score += route_neighbors * 20

	var/front_percent = get_building_front_percent(state, candidate)
	var/lateral_abs = abs(get_building_lateral_percent(state, candidate))
	switch(zone_spec.role)
		if("entry", "public", "public_med")
			score += 100 - front_percent
			score -= lateral_abs / 2
		if("hub", "staging")
			score += 100 - lateral_abs
			score -= abs(front_percent - 55) / 2
		if("storage", "service", "secure", "private", "nested")
			score += front_percent
			score += boundary_neighbors * 35
		if("route", "choke")
			score += 100 - lateral_abs
			score += route_neighbors * 35
		else
			score += 50 - lateral_abs / 2

	var/current_zone_id = state.get_zone(candidate)
	if(current_zone_id == state.semantic_plan.primary_zone_id)
		score += 25
	return score
