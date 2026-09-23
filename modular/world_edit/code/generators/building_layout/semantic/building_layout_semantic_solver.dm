/datum/world_edit_generator/building_layout/proc/run_building_semantic_interiors(datum/world_edit_building_layout_state/state)
	if(!istype(state) || state.has_errors())
		return FALSE
	if(building_layout_solver_enabled(state))
		state.add_stage_report("semantic_interiors", "skipped", "building_layout owns scene emission", list(
			"layout_enabled" = TRUE,
		))
		return TRUE
	var/list/global_scene_counts = list()
	var/room_count = 0
	var/scene_count = 0
	var/required_missing = 0
	for(var/datum/world_edit_building_room/room as anything in state.geometry.solved_rooms)
		if(!istype(room))
			continue
		room_count++
		var/datum/world_edit_building_semantic_room_field/field = build_building_semantic_room_field(state, room)
		if(!istype(field) || !length(field.free_turfs))
			continue
		add_building_semantic_room_field_anchors(state, field)
		var/list/rules = build_building_semantic_scene_rules_for_room(state, field, global_scene_counts)
		var/placed_primary = FALSE
		for(var/phase in list(WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_SECONDARY, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_DETAIL))
			var/phase_has_required = FALSE
			var/phase_required_satisfied = FALSE
			var/phase_emitted = FALSE
			for(var/datum/world_edit_building_semantic_scene_rule/rule as anything in rules)
				if(!istype(rule) || rule.phase != phase)
					continue
				if(length(rule.global_limit_id) && rule.global_limit > 0 && (global_scene_counts[rule.global_limit_id] || 0) >= rule.global_limit)
					continue
				if(rule.required)
					phase_has_required = TRUE
				var/datum/world_edit_building_semantic_scene_candidate/candidate = select_building_semantic_scene_candidate(state, field, rule)
				if(!istype(candidate))
					continue
				if(!emit_building_semantic_scene_candidate(state, candidate))
					continue
				scene_count++
				phase_emitted = TRUE
				if(rule.required)
					phase_required_satisfied = TRUE
				if(rule.primary)
					placed_primary = TRUE
				if(length(rule.global_limit_id))
					global_scene_counts[rule.global_limit_id] = (global_scene_counts[rule.global_limit_id] || 0) + 1
				break
			if(phase_has_required && !phase_required_satisfied)
				required_missing++
			if(!phase_emitted && phase == WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY)
				break
		if(!placed_primary && building_semantic_room_requires_primary_scene(state, room))
			state.validation.semantic_room_primary_scene_missing_count++
	if(scene_count > 0)
		mark_building_structured_scene_emission(state, "semantic")
		credit_building_semantic_scene_requirements(state)
	if(required_missing > 0)
		state.validation.semantic_scene_required_missing_count += required_missing
	state.add_stage_report("semantic_interiors", required_missing > 0 ? "failed" : "ok", required_missing > 0 ? "required scene missing" : null, list(
		"rooms_analyzed" = room_count,
		"scene_count" = scene_count,
		"required_missing" = required_missing,
		"public_focal_count" = global_scene_counts["public_focal"] || 0,
	))
	return required_missing <= 0 && state.validation.semantic_room_primary_scene_missing_count <= 0

/datum/world_edit_generator/building_layout/proc/build_building_semantic_room_field(datum/world_edit_building_layout_state/state, datum/world_edit_building_room/room)
	if(!istype(state) || !istype(room))
		return null
	var/datum/world_edit_building_semantic_room_field/field = new()
	field.room = room
	field.focus_turf = room.focus_turf
	for(var/turf/room_turf as anything in room.turfs)
		if(!istype(room_turf) || !state.geometry.floor_lookup[room_turf] || state.geometry.wall_lookup[room_turf] || state.geometry.door_dirs[room_turf])
			continue
		field.floor_turfs += room_turf
		field.area++
		var/wall_count = 0
		var/route_edge = FALSE
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby = get_step(room_turf, check_dir)
			if(state.geometry.wall_lookup[nearby])
				wall_count++
			if(state.geometry.reserved_lookup[nearby] || state.geometry.door_dirs[nearby])
				route_edge = TRUE
		if(state.has_anchor("door_cone", room_turf))
			field.door_buffer_turfs += room_turf
		if(route_edge || state.geometry.reserved_lookup[room_turf])
			field.route_edge_turfs += room_turf
		if(wall_count >= 1)
			field.wall_band_turfs += room_turf
			field.service_wall_turfs += room_turf
		if(wall_count >= 2)
			field.corner_turfs += room_turf
		if(wall_count <= 0 && !route_edge)
			field.center_turfs += room_turf
		if(state.can_place_fixture(room_turf))
			field.free_turfs += room_turf
	if(!istype(field.focus_turf) || !(field.focus_turf in field.floor_turfs))
		field.focus_turf = length(field.center_turfs) ? field.center_turfs[1] : (length(field.free_turfs) ? field.free_turfs[1] : null)
	return field

/datum/world_edit_generator/building_layout/proc/add_building_semantic_room_field_anchors(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field)
	if(!istype(state) || !istype(field) || !istype(field.room))
		return
	var/room_prefix = "semantic_room_[field.room.id]_"
	if(istype(field.focus_turf))
		state.add_anchor("[room_prefix]focus", field.focus_turf)
	for(var/turf/wall_turf as anything in field.wall_band_turfs)
		state.add_anchor("[room_prefix]wall", wall_turf)
	for(var/turf/free_turf as anything in field.free_turfs)
		state.add_anchor("[room_prefix]free", free_turf)

/datum/world_edit_generator/building_layout/proc/select_building_semantic_scene_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field, datum/world_edit_building_semantic_scene_rule/rule)
	if(!istype(state) || !istype(field) || !istype(rule))
		return null
	var/list/anchors = build_building_semantic_scene_anchor_candidates(field, rule)
	var/datum/world_edit_building_semantic_scene_candidate/best_candidate = null
	var/best_score = -999999999
	var/attempts = 0
	for(var/turf/anchor_turf as anything in anchors)
		if(!istype(anchor_turf))
			continue
		attempts++
		if(attempts > WORLD_EDIT_BUILDING_SEMANTIC_MAX_ROOM_CANDIDATES)
			break
		var/datum/world_edit_building_semantic_scene_candidate/candidate = build_building_semantic_scene_candidate_at_anchor(state, field, rule, anchor_turf)
		if(!istype(candidate))
			continue
		if(!istype(best_candidate) || candidate.score > best_score)
			best_candidate = candidate
			best_score = candidate.score
	return best_candidate

/datum/world_edit_generator/building_layout/proc/build_building_semantic_scene_anchor_candidates(datum/world_edit_building_semantic_room_field/field, datum/world_edit_building_semantic_scene_rule/rule)
	var/list/anchors = list()
	if(!istype(field))
		return anchors
	var/list/source = length(field.center_turfs) ? field.center_turfs : field.free_turfs
	if(rule?.scene_kind in list(WORLD_EDIT_BUILDING_SEMANTIC_SCENE_BEDROOM, WORLD_EDIT_BUILDING_SEMANTIC_SCENE_SANITATION, WORLD_EDIT_BUILDING_SEMANTIC_SCENE_STORAGE))
		source = length(field.wall_band_turfs) ? field.wall_band_turfs : source
	for(var/turf/source_turf as anything in source)
		if(!(source_turf in anchors))
			anchors += source_turf
	for(var/turf/free_turf as anything in field.free_turfs)
		if(!(free_turf in anchors))
			anchors += free_turf
	return anchors

/datum/world_edit_generator/building_layout/proc/build_building_semantic_scene_candidate_at_anchor(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field, datum/world_edit_building_semantic_scene_rule/rule, turf/anchor_turf)
	var/datum/world_edit_building_semantic_scene_candidate/candidate = new(field, rule)
	var/list/occupied = list()
	for(var/datum/world_edit_building_semantic_scene_member_spec/spec as anything in rule.member_specs)
		var/turf/member_turf = find_building_semantic_member_turf(state, field, spec, anchor_turf, occupied)
		if(!istype(member_turf))
			return null
		occupied[member_turf] = TRUE
		candidate.members += list(list(
			"spec" = spec,
			"turf" = member_turf,
			"anchor" = anchor_turf,
		))
	candidate.score = score_building_semantic_scene_candidate(state, candidate)
	return candidate

/datum/world_edit_generator/building_layout/proc/find_building_semantic_member_turf(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field, datum/world_edit_building_semantic_scene_member_spec/spec, turf/anchor_turf, list/occupied)
	if(!istype(state) || !istype(field) || !istype(spec))
		return null
	var/list/candidates = list()
	switch(spec.placement_mode)
		if(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ANCHOR)
			candidates += anchor_turf
		if(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ADJACENT)
			for(var/check_dir in GLOB.cardinals)
				candidates += get_step(anchor_turf, check_dir)
		if(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_RELATIVE)
			candidates += build_building_semantic_relative_member_turfs(anchor_turf, spec)
		if(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR)
			candidates += field.wall_band_turfs
		if(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN)
			candidates += field.wall_band_turfs
		if(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_CENTER_RING)
			candidates += field.center_turfs
			for(var/check_dir in GLOB.cardinals)
				candidates += get_step(anchor_turf, check_dir)
		else
			candidates += field.free_turfs
	if(spec.placement_mode != WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR && spec.placement_mode != WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN)
		for(var/turf/free_turf as anything in field.free_turfs)
			if(!(free_turf in candidates))
				candidates += free_turf
	var/turf/best_turf = null
	var/best_score = -999999999
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(spec.slot, spec.category)
	for(var/turf/candidate_turf as anything in candidates)
		if(!istype(candidate_turf) || occupied[candidate_turf])
			continue
		if(!(candidate_turf in field.floor_turfs))
			continue
		if(!state.can_place_fixture(candidate_turf))
			continue
		var/fallback_dir = get_cardinal_dir_toward(candidate_turf, anchor_turf || field.focus_turf || state.geometry.semantic_hub_turf || state.geometry.center_turf, state.placement_dir || SOUTH)
		if(spec.placement_mode == WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ADJACENT)
			fallback_dir = get_cardinal_dir_toward(candidate_turf, anchor_turf, fallback_dir)
		if(!islist(build_building_fixture_place_context(state, candidate_turf, place_rule, fallback_dir, spec.wall_required)))
			continue
		if(!building_semantic_member_clearance_ok(state, field, candidate_turf, spec, occupied))
			continue
		var/score = score_building_semantic_member_turf(state, field, candidate_turf, anchor_turf, spec)
		if(score > best_score)
			best_score = score
			best_turf = candidate_turf
	return best_turf

/datum/world_edit_generator/building_layout/proc/score_building_semantic_member_turf(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field, turf/candidate_turf, turf/anchor_turf, datum/world_edit_building_semantic_scene_member_spec/spec)
	var/score = 1000
	if(istype(anchor_turf))
		score -= get_dist(candidate_turf, anchor_turf) * 25
	if(istype(field.focus_turf))
		score -= get_dist(candidate_turf, field.focus_turf) * 5
	if(candidate_turf in field.wall_band_turfs)
		if(spec.placement_mode in list(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN))
			score += 140
		else
			score += 20
	if(candidate_turf in field.center_turfs)
		if(spec.placement_mode in list(WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ANCHOR, WORLD_EDIT_BUILDING_SEMANTIC_PLACE_CENTER_RING))
			score += 120
		else
			score += 15
	if(spec.placement_mode == WORLD_EDIT_BUILDING_SEMANTIC_PLACE_RELATIVE)
		score += 90
	if(candidate_turf in field.route_edge_turfs)
		score -= 260
	if(candidate_turf in field.door_buffer_turfs)
		score -= 1000
	var/list/wall_dirs = get_adjacent_wall_dirs_for_state(state, candidate_turf)
	if(spec.wall_required && !length(wall_dirs))
		score -= 10000
	return score

/datum/world_edit_generator/building_layout/proc/build_building_semantic_relative_member_turfs(turf/anchor_turf, datum/world_edit_building_semantic_scene_member_spec/spec)
	var/list/candidates = list()
	if(!istype(anchor_turf) || !istype(spec))
		return candidates
	if(!length(spec.allowed_relative_dirs))
		candidates += locate(anchor_turf.x + spec.dx, anchor_turf.y + spec.dy, anchor_turf.z)
		return candidates
	for(var/relative_dir as anything in spec.allowed_relative_dirs)
		var/list/offset = rotate_building_semantic_relative_offset(spec.dx, spec.dy, relative_dir)
		var/turf/relative_turf = locate(anchor_turf.x + offset["dx"], anchor_turf.y + offset["dy"], anchor_turf.z)
		if(istype(relative_turf) && !(relative_turf in candidates))
			candidates += relative_turf
	return candidates

/datum/world_edit_generator/building_layout/proc/rotate_building_semantic_relative_offset(dx, dy, relative_dir)
	var/resolved_dx = round(text2num("[dx]") || 0)
	var/resolved_dy = round(text2num("[dy]") || 0)
	switch(relative_dir)
		if(SOUTH)
			return list("dx" = -resolved_dx, "dy" = -resolved_dy)
		if(EAST)
			return list("dx" = resolved_dy, "dy" = -resolved_dx)
		if(WEST)
			return list("dx" = -resolved_dy, "dy" = resolved_dx)
	return list("dx" = resolved_dx, "dy" = resolved_dy)

/datum/world_edit_generator/building_layout/proc/building_semantic_member_clearance_ok(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field, turf/member_turf, datum/world_edit_building_semantic_scene_member_spec/spec, list/occupied)
	if(!istype(state) || !istype(field) || !istype(member_turf) || !istype(spec))
		return FALSE
	for(var/forbidden_tag as anything in spec.forbidden_anchor_tags)
		if(state.has_anchor(forbidden_tag, member_turf))
			return FALSE
	if(!length(spec.clearance_offsets))
		return TRUE
	for(var/list/offset as anything in spec.clearance_offsets)
		if(!islist(offset))
			continue
		var/check_dx = round(text2num("[offset["dx"]]") || 0)
		var/check_dy = round(text2num("[offset["dy"]]") || 0)
		var/turf/check_turf = locate(member_turf.x + check_dx, member_turf.y + check_dy, member_turf.z)
		if(!istype(check_turf) || !(check_turf in field.floor_turfs))
			return FALSE
		if(occupied[check_turf] || state.geometry.wall_lookup[check_turf])
			return FALSE
		if(state.geometry.reserved_lookup[check_turf] || state.geometry.door_dirs[check_turf] || state.has_anchor("door_cone", check_turf))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/score_building_semantic_scene_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_scene_candidate/candidate)
	var/score = candidate.rule.priority + length(candidate.members) * 100
	for(var/list/member as anything in candidate.members)
		var/turf/member_turf = member["turf"]
		if(!istype(member_turf))
			continue
		if(member_turf in candidate.field.route_edge_turfs)
			score -= 60
		if(member_turf in candidate.field.wall_band_turfs)
			score += 20
	return score
