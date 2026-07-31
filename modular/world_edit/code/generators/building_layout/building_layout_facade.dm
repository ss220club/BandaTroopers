/datum/world_edit_generator/building_layout/proc/build_building_windows(datum/world_edit_building_layout_state/state)
	var/window_density = clamp(round(text2num("[state.config["window_density"]]")), 0, 100)
	if(window_density <= 0)
		return
	var/list/window_policy = islist(state.semantic_plan?.window_policy) ? state.semantic_plan.window_policy : list()
	var/policy_bias = round(text2num("[window_policy["density_bias"]]") || state.archetype.window_bias)
	window_density = round((window_density + policy_bias) / 2)
	var/list/door_lookup = GLOB.world_edit_placement_shapes.world_edit_build_turf_lookup(state.geometry.door_turfs)
	var/list/candidates = list()
	var/list/candidate_lookup = list()
	var/list/weighted_candidates = list()
	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(door_lookup[boundary_turf])
			continue
		if(is_corner_boundary_turf(boundary_turf, state.geometry.footprint_lookup))
			continue
		if(!can_place_building_window_for_boundary_turf(state, boundary_turf))
			continue
		append_unique_turf(candidates, candidate_lookup, boundary_turf)
		var/weight = clamp(round(get_building_window_role_weight(state, boundary_turf) / 50), 1, 4)
		for(var/repeat_index in 1 to weight)
			weighted_candidates += boundary_turf

	if(!length(candidates) || window_density <= 0)
		return

	var/target_count = min(WORLD_EDIT_BUILDING_MAX_WINDOWS, max(1, round(length(candidates) * window_density / 250)))
	var/list/source_candidates = length(weighted_candidates) ? weighted_candidates : candidates
	var/stride = max(round(length(source_candidates) / max(target_count, 1)), 1)
	var/index = state.request.facade_rng.next_between(1, min(stride, length(source_candidates)))
	var/list/window_lookup = list()
	for(var/turf/existing_window as anything in state.geometry.window_turfs)
		window_lookup[existing_window] = TRUE
	while(length(state.geometry.window_turfs) < target_count && index <= length(source_candidates))
		var/turf/window_turf = source_candidates[index]
		if(!window_lookup[window_turf])
			state.append_unique_turf(state.geometry.window_turfs, window_turf)
			window_lookup[window_turf] = TRUE
		index += stride

/datum/world_edit_generator/building_layout/proc/get_building_window_interior_turf(datum/world_edit_building_layout_state/state, turf/boundary_turf)
	if(!istype(state) || !istype(boundary_turf) || !state.geometry.boundary_lookup[boundary_turf])
		return null
	for(var/check_dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(boundary_turf, check_dir)
		if(state.geometry.footprint_lookup[nearby_turf] && !state.geometry.boundary_lookup[nearby_turf] && !state.geometry.wall_lookup[nearby_turf])
			return nearby_turf
	return null

/datum/world_edit_generator/building_layout/proc/can_place_building_window_for_boundary_turf(datum/world_edit_building_layout_state/state, turf/boundary_turf)
	var/turf/interior_turf = get_building_window_interior_turf(state, boundary_turf)
	if(!istype(interior_turf))
		return FALSE
	var/zone_id = state.get_zone(interior_turf)
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
	if(!istype(zone_spec))
		return FALSE
	var/datum/world_edit_building_facade_rule/facade_rule = get_building_facade_rule_for_zone(state, zone_id)
	if(istype(facade_rule) && !facade_rule.window_allowed)
		return FALSE
	if(zone_spec.privacy_sensitive || !zone_spec.window_allowed)
		var/list/window_policy = islist(state.semantic_plan?.window_policy) ? state.semantic_plan.window_policy : list()
		if(!GLOB.world_edit_helpers.parse_bool(window_policy["privacy_windows"]))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_window_role_weight(datum/world_edit_building_layout_state/state, turf/boundary_turf)
	var/turf/interior_turf = get_building_window_interior_turf(state, boundary_turf)
	var/zone_id = state.get_zone(interior_turf)
	if(!length(zone_id))
		return 50
	var/datum/world_edit_building_facade_rule/facade_rule = get_building_facade_rule_for_zone(state, zone_id)
	if(istype(facade_rule))
		return facade_rule.window_weight
	var/list/window_policy = islist(state.semantic_plan?.window_policy) ? state.semantic_plan.window_policy : list()
	var/privacy_class = get_building_zone_privacy_class(state, zone_id)
	switch(privacy_class)
		if("public")
			return round(text2num("[window_policy["public_weight"]]") || 120)
		if("semi_private")
			return round(text2num("[window_policy["semi_private_weight"]]") || 60)
		if("secure")
			return round(text2num("[window_policy["secure_weight"]]") || 25)
		if("service")
			return round(text2num("[window_policy["service_weight"]]") || 25)
		if("private")
			return round(text2num("[window_policy["private_weight"]]") || 0)
	return 50

/datum/world_edit_generator/building_layout/proc/get_building_zone_privacy_class(datum/world_edit_building_layout_state/state, zone_id)
	if(!istype(state) || !length("[zone_id]"))
		return "public"
	var/list/privacy_classes = islist(state.semantic_plan?.privacy_classes) ? state.semantic_plan.privacy_classes : list()
	var/privacy_class = privacy_classes["[zone_id]"]
	if(length("[privacy_class]"))
		return "[privacy_class]"
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
	if(istype(zone_spec) && length(zone_spec.privacy_class))
		return zone_spec.privacy_class
	return "public"

/datum/world_edit_generator/building_layout/proc/facade_rule_matches_zone(datum/world_edit_building_facade_rule/facade_rule, datum/world_edit_building_zone_spec/zone_spec, zone_id, privacy_class)
	if(!istype(facade_rule) || !istype(zone_spec))
		return FALSE
	if(length(facade_rule.zone_id) && facade_rule.zone_id != "[zone_id]")
		return FALSE
	if(length(facade_rule.role) && facade_rule.role != zone_spec.role)
		return FALSE
	if(length(facade_rule.privacy_class) && facade_rule.privacy_class != "[privacy_class]")
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/score_facade_rule_specificity(datum/world_edit_building_facade_rule/facade_rule)
	if(!istype(facade_rule))
		return -1
	var/score = 0
	if(length(facade_rule.zone_id))
		score += 100
	if(length(facade_rule.role))
		score += 35
	if(length(facade_rule.privacy_class))
		score += 20
	return score

/datum/world_edit_generator/building_layout/proc/get_building_facade_rule_for_zone(datum/world_edit_building_layout_state/state, zone_id)
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
	if(!istype(zone_spec))
		return null
	var/privacy_class = get_building_zone_privacy_class(state, zone_id)
	var/datum/world_edit_building_facade_rule/best_rule = null
	var/best_score = -1
	var/list/facade_rules = islist(state.semantic_plan?.facade_rules) ? state.semantic_plan.facade_rules : list()
	for(var/datum/world_edit_building_facade_rule/facade_rule as anything in facade_rules)
		if(!facade_rule_matches_zone(facade_rule, zone_spec, zone_id, privacy_class))
			continue
		var/score = score_facade_rule_specificity(facade_rule)
		if(!istype(best_rule) || score > best_score)
			best_rule = facade_rule
			best_score = score
	return best_rule

/datum/world_edit_generator/building_layout/proc/get_building_facade_role_for_boundary_turf(datum/world_edit_building_layout_state/state, turf/boundary_turf)
	var/turf/interior_turf = get_building_window_interior_turf(state, boundary_turf)
	if(!istype(interior_turf))
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(boundary_turf, check_dir)
			if(state.geometry.footprint_lookup[nearby_turf] && !state.geometry.wall_lookup[nearby_turf])
				interior_turf = nearby_turf
				break
	var/zone_id = state.get_zone(interior_turf)
	var/datum/world_edit_building_facade_rule/facade_rule = get_building_facade_rule_for_zone(state, zone_id)
	if(istype(facade_rule))
		return facade_rule.facade_role
	return "neutral_face"

/datum/world_edit_generator/building_layout/proc/get_building_facade_macro_for_boundary_turf(datum/world_edit_building_layout_state/state, turf/boundary_turf)
	var/turf/interior_turf = get_building_window_interior_turf(state, boundary_turf)
	if(!istype(interior_turf))
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(boundary_turf, check_dir)
			if(state.geometry.footprint_lookup[nearby_turf] && !state.geometry.wall_lookup[nearby_turf])
				interior_turf = nearby_turf
				break
	var/datum/world_edit_building_facade_rule/facade_rule = get_building_facade_rule_for_zone(state, state.get_zone(interior_turf))
	if(istype(facade_rule) && length(facade_rule.macro_id))
		return facade_rule.macro_id
	return "facade_panel"

/datum/world_edit_generator/building_layout/proc/apply_building_facade_rules(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(state.geometry.wall_lookup[boundary_turf])
			state.add_anchor("facade_segment", boundary_turf)
			state.add_anchor("facade_[get_building_facade_role_for_boundary_turf(state, boundary_turf)]", boundary_turf)
