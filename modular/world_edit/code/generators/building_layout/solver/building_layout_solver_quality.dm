/datum/world_edit_generator/building_layout/proc/get_layout_scene_room_solve_order(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/list/signature_rooms = list()
	var/list/required_rooms = list()
	var/list/optional_rooms = list()
	if(!istype(context) || !istype(candidate))
		return required_rooms
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan?.contract_id)
		if(building_layout_room_has_required_scene_module(context, room_plan))
			signature_rooms += room_plan
		else if(istype(room_contract) && room_contract.required)
			required_rooms += room_plan
		else
			optional_rooms += room_plan
	return signature_rooms + required_rooms + optional_rooms

/datum/world_edit_generator/building_layout/proc/building_layout_room_has_required_scene_module(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_plan/room_plan)
	if(!istype(context?.program_contract) || !istype(room_plan))
		return FALSE
	for(var/datum/world_edit_building_layout_scene_contract/scene_contract as anything in context.program_contract.scene_contracts)
		if(!istype(scene_contract) || !(room_plan.contract_id in scene_contract.allowed_room_ids))
			continue
		if(length(scene_contract.required_modules))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_scene_budget_allows(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(context?.scene_budget) || !istype(scene_plan))
		return TRUE
	var/list/required_slot_counts = build_building_layout_scene_required_slot_counts(scene_plan)
	for(var/global_slot as anything in required_slot_counts)
		var/amount = round(text2num("[required_slot_counts[global_slot]]") || 0)
		if(amount <= 0)
			continue
		if(!context.scene_budget.can_use(global_slot, amount))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/register_building_layout_scene_budget_use(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(context?.scene_budget) || !istype(scene_plan))
		return
	var/list/required_slot_counts = build_building_layout_scene_required_slot_counts(scene_plan)
	for(var/global_slot as anything in required_slot_counts)
		context.scene_budget.use(global_slot, required_slot_counts[global_slot])

/datum/world_edit_generator/building_layout/proc/build_building_layout_scene_required_slot_counts(datum/world_edit_building_layout_scene_plan/scene_plan)
	var/list/counts = list()
	if(!istype(scene_plan))
		return counts
	for(var/list/member as anything in scene_plan.members)
		if(!islist(member) || !GLOB.world_edit_helpers.parse_bool(member["major"]))
			continue
		var/global_slot = building_layout_global_scene_slot_key(member["category"])
		counts[global_slot] = (counts[global_slot] || 0) + 1
	return counts


/datum/world_edit_generator/building_layout/proc/validate_building_layout_scene_composition(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_contract/scene_contract, datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(scene_contract) || !istype(scene_plan))
		return FALSE
	var/turf/focus_turf = scene_plan.primary_anchors["focus"]
	if(!istype(focus_turf))
		return FALSE
	if(scene_contract.min_negative_space_tiles > 0 && length(scene_plan.negative_space_turfs) < scene_contract.min_negative_space_tiles)
		candidate?.errors += "scene.composition_negative_short:[room_plan?.id]:[length(scene_plan.negative_space_turfs)]/[scene_contract.min_negative_space_tiles]"
		return FALSE
	for(var/list/member as anything in scene_plan.members)
		if(!islist(member))
			continue
		var/turf/member_turf = member["turf"]
		if(istype(member_turf) && scene_plan.no_furniture_lookup[member_turf] && member_turf != focus_turf)
			candidate?.errors += "scene.composition_member_in_negative:[room_plan?.id]:[member["slot"]]:[member_turf.x],[member_turf.y]"
			return FALSE
	var/room_area = max(room_plan?.area() || 0, 1)
	var/occupancy_ratio = round(length(scene_plan.occupied_turfs) * 100 / room_area)
	if(occupancy_ratio > scene_contract.max_occupancy_ratio)
		candidate?.errors += "scene.composition_overfill:[room_plan?.id]:[occupancy_ratio]/[scene_contract.max_occupancy_ratio]"
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/mark_building_layout_scene_negative_space(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(state) || !istype(scene_plan))
		return
	for(var/turf/negative_turf as anything in scene_plan.negative_space_turfs)
		if(!istype(negative_turf))
			continue
		state.fixtures.scene_negative_space_lookup[negative_turf] = TRUE
		state.fixtures.scene_no_furniture_lookup[negative_turf] = TRUE

/datum/world_edit_generator/building_layout/proc/validate_building_layout_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return FALSE
	validate_building_layout_room_quality(context, candidate)
	validate_building_layout_opening_quality(context, candidate)
	validate_building_layout_scene_quality(context, candidate)
	validate_building_layout_window_quality(context, candidate)
	validate_building_layout_architectural_quality(context, candidate)
	return !building_layout_quality_has_hard_failures(context)

/datum/world_edit_generator/building_layout/proc/validate_building_layout_room_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state))
		return
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan.contract_id)
		var/room_min_dim = min(room_plan.width(), room_plan.height())
		var/room_max_dim = max(room_plan.width(), room_plan.height())
		var/aspect = room_max_dim / max(room_min_dim, 1)
		if(istype(room_contract) && aspect > max(room_contract.max_aspect, 1))
			state.validation.layout_room_bad_aspect_count++
		if(room_plan.area() >= 12 && (room_min_dim <= 2 || room_max_dim > room_min_dim * 4))
			state.validation.layout_room_thin_strip_count++
		if(istype(room_contract) && room_contract.required && room_contract.must_touch_route && !building_layout_room_has_valid_route_connection(candidate, room_plan.id))
			state.validation.layout_isolated_room_count++
		var/scene_member_count = istype(room_plan.scene_plan) ? length(room_plan.scene_plan.members) : 0
		if(room_plan.area() >= 16 && scene_member_count <= 1 && !(room_plan.role in list("storage", "route")) && !(room_plan.contract_id in list("sanitation", "utility")))
			state.validation.layout_empty_large_room_count++
		if(istype(room_contract) && length(room_contract.required_scene_kinds) && !building_layout_room_can_fit_required_scene(context, build_building_layout_rect(room_plan.x1, room_plan.y1, room_plan.x2, room_plan.y2), room_contract))
			state.validation.layout_room_scene_capacity_failed_count++

/datum/world_edit_generator/building_layout/proc/building_layout_room_has_valid_route_connection(datum/world_edit_building_layout_candidate/candidate, room_id)
	if(!istype(candidate))
		return FALSE
	var/list/open = list("route")
	var/list/seen = list("route" = TRUE)
	for(var/turf/route_turf as anything in candidate.route_owner_by_turf)
		var/route_owner = "[candidate.route_owner_by_turf[route_turf] || ""]"
		if(!length(route_owner) || seen[route_owner])
			continue
		seen[route_owner] = TRUE
		open += route_owner
	while(length(open))
		var/current_id = open[1]
		open.Cut(1, 2)
		if(current_id == "[room_id]")
			return TRUE
		for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
			if(!istype(door_plan) || door_plan.kind == "main_exit")
				continue
			var/next_id = ""
			if(door_plan.from_room == current_id)
				next_id = door_plan.to_room
			else if(door_plan.to_room == current_id)
				next_id = door_plan.from_room
			if(!length(next_id) || seen[next_id])
				continue
			seen[next_id] = TRUE
			open += next_id
	return FALSE

/datum/world_edit_generator/building_layout/proc/validate_building_layout_opening_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state))
		return
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || door_plan.kind == "main_exit")
			continue
		if(!building_layout_door_plan_has_valid_shared_wall(context, candidate, door_plan))
			state.validation.layout_door_not_on_shared_wall_count++
		var/segment_length = building_layout_door_plan_segment_length(context, candidate, door_plan)
		if(segment_length <= 0)
			state.validation.layout_door_no_shared_wall_count++
		var/datum/world_edit_building_layout_room_connection/connection_contract = null
		for(var/datum/world_edit_building_layout_room_connection/pending_connection as anything in candidate.room_connections)
			if(istype(pending_connection) && pending_connection.id == door_plan.id)
				connection_contract = pending_connection
				break
		var/min_opening_width = istype(connection_contract) ? max(connection_contract.min_opening_width, 1) : 1
		if(segment_length > 0 && segment_length < min_opening_width)
			state.validation.layout_door_short_segment_count++
			state.add_stage_report("layout_door_short_segment", "failed", "opening wall run is shorter than the typed edge opening width", list(
				"opening_id" = door_plan.id,
				"segment_length" = segment_length,
				"min_opening_width" = min_opening_width,
				"from_node_id" = door_plan.from_room,
				"to_node_id" = door_plan.to_room,
			))
		var/emits_door_object = building_layout_opening_plan_emits_door_object(context, door_plan)
		if(emits_door_object && building_layout_door_plan_at_segment_end(context, candidate, door_plan) && !building_layout_opening_has_wall_shoulders(candidate, door_plan.opening_turf, door_plan.dir))
			state.validation.layout_door_corner_count++
			state.add_stage_report("layout_door_corner", "failed", "controlled opening lacks an intact wall shoulder", list("opening_id" = door_plan.id, "x" = door_plan.opening_turf.x, "y" = door_plan.opening_turf.y, "z" = door_plan.opening_turf.z, "dir" = door_plan.dir))
		if(emits_door_object && building_layout_opening_near_other_door_excluding(candidate, door_plan, 1))
			state.validation.layout_door_near_other_door_count++
		if(!building_layout_door_clearance_ok(candidate, door_plan))
			state.validation.layout_door_invalid_clearance_count++

/datum/world_edit_generator/building_layout/proc/building_layout_door_plan_segment_length(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/door_plan)
	var/list/endpoint_lookups = get_building_layout_opening_endpoint_lookups(context, candidate, door_plan?.from_room, door_plan?.to_room, door_plan?.id)
	var/list/from_lookup = endpoint_lookups["from_lookup"]
	var/list/to_lookup = endpoint_lookups["to_lookup"]
	return building_layout_shared_wall_run_length_for_regions(context, candidate, from_lookup, to_lookup, door_plan?.opening_turf, door_plan?.dir)

/datum/world_edit_generator/building_layout/proc/building_layout_door_plan_at_segment_end(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/door_plan)
	var/list/endpoint_lookups = get_building_layout_opening_endpoint_lookups(context, candidate, door_plan?.from_room, door_plan?.to_room, door_plan?.id)
	var/list/from_lookup = endpoint_lookups["from_lookup"]
	var/list/to_lookup = endpoint_lookups["to_lookup"]
	return building_layout_opening_at_segment_end_for_regions(context, candidate, from_lookup, to_lookup, door_plan?.opening_turf, door_plan?.dir)

/datum/world_edit_generator/building_layout/proc/building_layout_opening_near_other_door_excluding(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/source_door, radius = 2)
	if(source_door?.public_opening)
		return FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate?.opening_plans)
		if(!istype(door_plan?.opening_turf) || door_plan == source_door || door_plan.public_opening)
			continue
		for(var/turf/source_turf as anything in get_building_layout_opening_plan_turfs(source_door))
			for(var/turf/other_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
				if(building_layout_openings_are_opposite_route_pair(candidate, source_turf, source_door.dir, other_turf, door_plan.dir))
					continue
				if(get_dist(source_turf, other_turf) <= radius)
					return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_door_clearance_ok(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/door_plan)
	if(!istype(candidate) || !istype(door_plan?.opening_turf))
		return FALSE
	for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
		if(!building_layout_opening_side_clear(candidate, get_step(opening_turf, door_plan.dir)) || !building_layout_opening_side_clear(candidate, get_step(opening_turf, turn(door_plan.dir, 180))))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/validate_building_layout_scene_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state))
		return
	var/list/global_slots = list()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan?.contract_id)
		var/datum/world_edit_building_layout_scene_plan/scene_plan = room_plan?.scene_plan
		if(istype(room_contract) && room_contract.required && length(room_contract.required_scene_kinds) && !istype(scene_plan))
			state.validation.layout_scene_required_missing_count++
		if(!istype(scene_plan))
			continue
		var/turf/focus_turf = scene_plan.primary_anchors["focus"]
		if(!istype(focus_turf))
			state.validation.layout_primary_anchor_missing_count++
		if(!length(scene_plan.negative_space_turfs))
			state.validation.layout_negative_space_missing_count++
		for(var/list/member as anything in scene_plan.members)
			if(!islist(member))
				continue
			var/turf/member_turf = member["turf"]
			if(istype(member_turf) && scene_plan.no_furniture_lookup[member_turf] && member_turf != focus_turf)
				state.validation.layout_scene_blocks_negative_space_count++
		var/room_area = max(room_plan.area(), 1)
		var/occupancy_ratio = round(length(scene_plan.occupied_turfs) * 100 / room_area)
		var/datum/world_edit_building_layout_scene_contract/scene_contract = context.program_contract?.get_scene_contract(scene_plan.scene_contract_id)
		if(istype(scene_contract) && occupancy_ratio > scene_contract.max_occupancy_ratio)
			state.validation.layout_scene_overfill_count++
		for(var/scene_slot as anything in scene_plan.scene_slot_counts)
			var/global_slot = building_layout_global_scene_slot_key(scene_slot)
			global_slots[global_slot] = (global_slots[global_slot] || 0) + round(text2num("[scene_plan.scene_slot_counts[scene_slot]]") || 0)
	var/public_focal_count = round(text2num("[global_slots["public_focal"]]") || 0)
	if(public_focal_count > 1)
		state.validation.layout_duplicate_focal_scene_count += public_focal_count - 1
	for(var/scene_slot as anything in context.program_contract?.global_scene_slot_limits)
		var/limit = round(text2num("[context.program_contract.global_scene_slot_limits[scene_slot]]") || 0)
		var/current = round(text2num("[global_slots[scene_slot]]") || 0)
		if(limit > 0 && current > limit)
			state.validation.layout_scene_budget_overflow_count += current - limit
	for(var/scene_slot as anything in context.program_contract?.global_scene_slot_minimums)
		var/minimum = round(text2num("[context.program_contract.global_scene_slot_minimums[scene_slot]]") || 0)
		var/current = round(text2num("[global_slots[scene_slot]]") || 0)
		if(current < minimum)
			state.validation.layout_scene_budget_missing_required_count += minimum - current

/datum/world_edit_generator/building_layout/proc/validate_building_layout_window_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state))
		return
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(!building_layout_window_plan_obeys_policy(context, candidate, window_plan))
			state.validation.layout_window_policy_violation_count++
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan?.contract_id)
		if(istype(room_contract) && (room_contract.window_policy == "required" || room_contract.exterior_window_policy == "required") && !building_layout_room_has_window(candidate, room_plan.id))
			state.validation.layout_window_policy_violation_count++

/datum/world_edit_generator/building_layout/proc/building_layout_room_has_window(datum/world_edit_building_layout_candidate/candidate, room_id)
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate?.window_plans)
		if(istype(window_plan) && window_plan.from_room == room_id)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/validate_building_layout_architectural_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return
	validate_building_layout_public_openings(context, candidate)
	validate_building_layout_opposing_route_doors(state, candidate)
	validate_building_layout_template_reject_quality(state)
	validate_building_layout_candidate_diversity(state)

/datum/world_edit_generator/building_layout/proc/validate_building_layout_public_openings(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state))
		return
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate?.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan?.contract_id)
		if(!istype(room_contract) || !(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_OPEN, WORLD_EDIT_BUILDING_PARTITION_SOFT)))
			continue
		var/public_opening_tiles = count_building_layout_room_public_opening_tiles(context, candidate, room_plan.id)
		if(public_opening_tiles <= 0)
			state.validation.layout_public_room_hard_closed_count++
			state.validation.layout_public_opening_missing_count++

/datum/world_edit_generator/building_layout/proc/count_building_layout_room_public_opening_tiles(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, room_id)
	var/count = 0
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate?.opening_plans)
		if(!istype(opening_plan) || !building_layout_opening_plan_is_public(context, opening_plan))
			continue
		if(opening_plan.from_room == room_id || opening_plan.to_room == room_id)
			count += length(get_building_layout_opening_plan_turfs(opening_plan))
	return count

/datum/world_edit_generator/building_layout/proc/validate_building_layout_opposing_route_doors(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(state) || !istype(candidate))
		return
	var/list/physical_doors = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || !building_layout_opening_plan_emits_door_object(state.layout_context, door_plan) || door_plan.kind == "main_exit")
			continue
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(istype(opening_turf))
				physical_doors += list(list("turf" = opening_turf, "dir" = door_plan.dir))
	for(var/i in 1 to length(physical_doors))
		if(i >= length(physical_doors))
			continue
		var/list/a = physical_doors[i]
		for(var/j in i + 1 to length(physical_doors))
			var/list/b = physical_doors[j]
			if(building_layout_openings_are_opposite_route_pair(candidate, a["turf"], a["dir"], b["turf"], b["dir"]))
				state.validation.layout_opposing_route_door_pair_count++

/datum/world_edit_generator/building_layout/proc/validate_building_layout_template_reject_quality(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !islist(state.validation.template_reject_reason_counts))
		return
	state.validation.layout_template_geometry_reject_count = round(text2num("[state.validation.template_reject_reason_counts["template_geometry_conflict"]]") || 0)
	state.validation.layout_missing_wall_context_reject_count = round(text2num("[state.validation.template_reject_reason_counts["missing_wall_context"]]") || 0)

/datum/world_edit_generator/building_layout/proc/validate_building_layout_candidate_diversity(datum/world_edit_building_layout_state/state)
	if(!istype(state) || GLOB.world_edit_helpers.parse_bool(state.config["layout_trial_emission"]) || isnull(state.config["layout_hard_valid_candidate_count"]))
		return
	var/is_compact = is_building_compact_or_micro_state(state)
	var/min_hard_valid_candidates = is_compact ? 1 : 2
	var/min_distinct_families = is_compact ? 1 : 2
	var/hard_valid_count = round(text2num("[state.config["layout_hard_valid_candidate_count"]]") || 0)
	var/distinct_family_count = round(text2num("[state.config["layout_distinct_hard_valid_family_count"]]") || 0)
	state.add_stage_report("layout_candidate_diversity", "ok", null, list(
		"is_compact" = is_compact,
		"size_profile" = state.config["size_profile"],
		"half_width" = state.config["half_width"],
		"half_depth" = state.config["half_depth"],
		"geometry_width" = state.geometry?.bounds?["width"],
		"geometry_height" = state.geometry?.bounds?["height"],
		"hard_valid_count" = hard_valid_count,
		"min_hard_valid_candidates" = min_hard_valid_candidates,
		"distinct_family_count" = distinct_family_count,
		"min_distinct_families" = min_distinct_families,
	))
	if(hard_valid_count < min_hard_valid_candidates || distinct_family_count < min_distinct_families)
		state.validation.layout_hard_valid_candidate_shortage_count++

/datum/world_edit_generator/building_layout/proc/building_layout_quality_has_hard_failures(datum/world_edit_building_layout_context/context)
	var/datum/world_edit_building_layout_validation_state/validation = context?.state?.validation
	if(!istype(validation))
		return TRUE
	if(validation.layout_empty_large_room_count > 0)
		return TRUE
	if(validation.layout_isolated_room_count > 0)
		return TRUE
	if(validation.layout_door_corner_count > 0)
		return TRUE
	if(validation.layout_door_not_on_shared_wall_count > 0)
		return TRUE
	if(validation.layout_door_no_shared_wall_count > 0)
		return TRUE
	if(validation.layout_door_short_segment_count > 0)
		return TRUE
	if(validation.layout_door_near_other_door_count > 0)
		return TRUE
	if(validation.layout_door_invalid_clearance_count > 0)
		return TRUE
	if(validation.layout_room_bad_aspect_count > 0)
		return TRUE
	if(validation.layout_room_thin_strip_count > 0)
		return TRUE
	if(validation.layout_room_scene_capacity_failed_count > 0)
		return TRUE
	if(validation.layout_scene_required_missing_count > 0)
		return TRUE
	if(validation.layout_primary_anchor_missing_count > 0)
		return TRUE
	if(validation.layout_negative_space_missing_count > 0)
		return TRUE
	if(validation.layout_scene_blocks_negative_space_count > 0)
		return TRUE
	if(validation.layout_scene_budget_overflow_count > 0)
		return TRUE
	if(validation.layout_scene_budget_missing_required_count > 0)
		return TRUE
	if(validation.layout_duplicate_focal_scene_count > 0)
		return TRUE
	if(validation.layout_window_policy_violation_count > 0)
		return TRUE
	if(validation.layout_public_room_hard_closed_count > 0)
		return TRUE
	if(validation.layout_public_opening_missing_count > 0)
		return TRUE
	if(validation.layout_corridor_wall_canyon_count > 0)
		return TRUE
	if(validation.layout_hard_valid_candidate_shortage_count > 0)
		return TRUE
	if(validation.layout_underfurnished_room_count > 0)
		return TRUE
	if(validation.large_sparse_room_count > 0)
		return TRUE
	if(validation.layout_scene_underfill_count > 0)
		return TRUE
	if(validation.layout_room_composition_missing_count > 0)
		return TRUE
	if(validation.layout_room_capacity_shortfall_count > 0)
		return TRUE
	if(validation.layout_required_adjacency_missing_count > 0)
		return TRUE
	if(validation.layout_required_adjacency_geometry_missing_count > 0)
		return TRUE
	if(validation.layout_unassigned_interior_excess_count > 0)
		return TRUE
	if(validation.layout_ownerless_open_bay_count > 0)
		return TRUE
	if(validation.layout_route_component_error_count > 0)
		return TRUE
	if(validation.layout_wall_stub_count > 0)
		return TRUE
	if(validation.layout_wall_notch_count > 0)
		return TRUE
	if(validation.layout_wall_stair_step_count > 0)
		return TRUE
	if(validation.layout_wall_misaligned_join_count > 0)
		return TRUE
	if(validation.layout_atomic_module_fragmentation_count > 0)
		return TRUE
	if(validation.layout_required_module_fallback_count > 0)
		return TRUE
	if(validation.layout_required_template_reject_count > 0)
		return TRUE
	if(validation.layout_wall_cleanup_unmapped_count > 0)
		return TRUE
	if(validation.layout_wall_cleanup_spur_count > 0)
		return TRUE
	if(validation.layout_functional_room_count_gap > 0)
		return TRUE
	if(validation.layout_candidate_metric_mismatch_count > 0)
		return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/validate_building_layout_review_contract(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/datum/world_edit_building_layout_context/context = state.layout_context
	var/datum/world_edit_building_layout_candidate/candidate = context?.selected_candidate
	var/datum/world_edit_building_layout_program_contract/program = context?.program_contract
	if(!istype(candidate) || !istype(program))
		return
	state.validation.layout_functional_room_count = 0
	state.validation.layout_circulation_region_count = 0
	state.validation.layout_room_composition_missing_count = 0
	state.validation.layout_room_capacity_shortfall_count = 0
	state.validation.layout_required_adjacency_missing_count = 0
	state.validation.layout_required_adjacency_geometry_missing_count = 0
	state.validation.layout_unassigned_interior_turf_count = 0
	state.validation.layout_unassigned_interior_ratio_percent = 0
	state.validation.layout_unassigned_interior_excess_count = 0
	state.validation.layout_ownerless_open_bay_count = 0
	state.validation.layout_route_component_count = 0
	state.validation.layout_route_component_error_count = 0
	state.validation.layout_wall_stub_count = 0
	state.validation.layout_wall_notch_count = 0
	state.validation.layout_wall_stair_step_count = 0
	state.validation.layout_wall_misaligned_join_count = 0
	state.validation.layout_atomic_module_fragmentation_count = 0
	state.validation.layout_scene_underfill_count = 0
	state.validation.layout_underfurnished_room_count = 0
	state.validation.layout_candidate_metric_mismatch_count = 0
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		var/datum/world_edit_building_layout_room_contract/room_contract = program.get_room_contract(room_plan.contract_id)
		if(istype(room_contract) && !room_contract.counts_toward_target)
			state.validation.layout_circulation_region_count++
			continue
		state.validation.layout_functional_room_count++
		var/datum/world_edit_building_layout_scene_plan/scene_plan = room_plan.scene_plan
		var/list/occupied_lookup = list()
		var/member_count = 0
		var/bed_capacity = 0
		if(istype(scene_plan))
			for(var/list/member as anything in scene_plan.members)
				if(!islist(member))
					continue
				var/turf/member_turf = member["turf"]
				if(istype(member_turf))
					occupied_lookup[member_turf] = TRUE
				member_count++
				if("[member["slot"]]" == "bed")
					bed_capacity++
		if(!istype(scene_plan) || member_count <= 0)
			state.validation.layout_room_composition_missing_count++
			state.add_stage_report("layout_room_composition_missing", "failed", "functional room has no authored scene", list(
				"room_id" = room_plan.id,
				"contract_id" = room_plan.contract_id,
				"role" = room_plan.role,
				"area" = room_plan.area(),
				"width" = room_plan.width(),
				"height" = room_plan.height(),
			))
		else
			var/datum/world_edit_building_layout_composition_contract/composition = program.get_composition_contract(room_plan.contract_id)
			var/missing_required_group_count = 0
			for(var/datum/world_edit_building_cluster_spec/required_group as anything in composition?.required_groups)
				if(!building_layout_scene_contains_required_group(scene_plan, required_group))
					missing_required_group_count++
			if(missing_required_group_count > 0)
				state.validation.layout_scene_underfill_count += missing_required_group_count
				state.validation.layout_underfurnished_room_count += missing_required_group_count
				state.add_stage_report("layout_room_composition_underfill", "failed", "authored required composition group is missing", list(
					"room_id" = room_plan.id,
					"contract_id" = room_plan.contract_id,
					"missing_group_count" = missing_required_group_count,
					"member_count" = member_count,
				))
		if(room_plan.role == "private" && room_plan.scene_kind == "bedroom" && istype(room_contract) && room_contract.instance_index > 1 && bed_capacity < 2)
			state.validation.layout_room_capacity_shortfall_count++
	var/list/circulation_zone_lookup = list()
	for(var/turf/circulation_turf as anything in candidate.route_owner_by_turf)
		var/circulation_id = "[candidate.route_owner_by_turf[circulation_turf] || ""]"
		if(length(circulation_id) && circulation_id != "route")
			circulation_zone_lookup[circulation_id] = TRUE
	state.validation.layout_circulation_region_count = length(circulation_zone_lookup)
	state.validation.layout_target_functional_room_count = program.target_room_count
	state.validation.layout_functional_room_count_gap = abs(program.target_room_count - state.validation.layout_functional_room_count)
	var/reported_candidate_count = round(text2num("[state.config["layout_candidate_count"]]") || 0)
	var/reported_hard_valid_count = round(text2num("[state.config["layout_hard_valid_candidate_count"]]") || 0)
	if(reported_candidate_count <= 0 || reported_hard_valid_count > reported_candidate_count || "[state.config["layout_candidate_id"]]" != candidate.id)
		state.validation.layout_candidate_metric_mismatch_count++
	for(var/datum/world_edit_building_layout_connection_contract/connection_contract as anything in program.connection_contracts)
		if(!istype(connection_contract) || !connection_contract.required)
			continue
		var/datum/world_edit_building_layout_room_contract/from_contract = program.get_room_contract(connection_contract.from_node_id)
		var/datum/world_edit_building_layout_room_contract/to_contract = program.get_room_contract(connection_contract.to_node_id)
		var/circulation_edge = istype(from_contract) && istype(to_contract) && !from_contract.counts_toward_target && !to_contract.counts_toward_target
		if(!(circulation_edge ? building_layout_candidate_has_circulation_edge(candidate, program, connection_contract) : building_layout_candidate_has_required_topology_edge(candidate, connection_contract.from_node_id, connection_contract.to_node_id)))
			state.validation.layout_required_adjacency_missing_count++
			state.add_stage_report("layout_required_adjacency", "failed", "candidate topology edge is missing", list("from" = connection_contract.from_node_id, "to" = connection_contract.to_node_id, "edge_kind" = connection_contract.edge_kind, "opening_policy" = connection_contract.opening_policy, "route_policy" = connection_contract.route_policy))
		if(!building_layout_candidate_has_required_topology_geometry(context, candidate, program, connection_contract))
			state.validation.layout_required_adjacency_geometry_missing_count++
			state.add_stage_report("layout_required_adjacency_geometry", "failed", "required edge has no matching physical opening", list("from" = connection_contract.from_node_id, "to" = connection_contract.to_node_id, "edge_kind" = connection_contract.edge_kind, "opening_policy" = connection_contract.opening_policy, "route_policy" = connection_contract.route_policy))
	var/list/assigned_interior_lookup = list()
	for(var/datum/world_edit_building_layout_room_plan/assigned_room as anything in candidate.room_plans)
		for(var/turf/assigned_turf as anything in assigned_room?.turfs)
			assigned_interior_lookup[assigned_turf] = TRUE
	for(var/turf/route_turf as anything in candidate.route_turfs)
		assigned_interior_lookup[route_turf] = TRUE
	for(var/turf/owner_aisle_turf as anything in candidate.owner_aisle_turfs)
		assigned_interior_lookup[owner_aisle_turf] = TRUE
	for(var/turf/wall_turf as anything in candidate.wall_turfs)
		assigned_interior_lookup[wall_turf] = TRUE
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(opening_plan))
			assigned_interior_lookup[opening_turf] = TRUE
	for(var/turf/structural_buffer_turf as anything in candidate.reserved_partition_wall_lookup)
		assigned_interior_lookup[structural_buffer_turf] = TRUE
	var/list/unassigned_lookup = list()
	for(var/turf/interior_turf as anything in state.geometry.interior)
		if(!istype(interior_turf) || assigned_interior_lookup[interior_turf])
			continue
		unassigned_lookup[interior_turf] = TRUE
	state.validation.layout_unassigned_interior_turf_count = length(unassigned_lookup)
	state.validation.layout_unassigned_interior_ratio_percent = round(length(unassigned_lookup) * 100 / max(length(state.geometry.interior), 1))
	var/unassigned_limit_percent = state.config["footprint_family"] == WORLD_EDIT_BUILDING_FOOTPRINT_FAMILY_RECT ? 3 : 5
	var/allowed_unassigned_count = round(length(state.geometry.interior) * unassigned_limit_percent / 100)
	state.validation.layout_unassigned_interior_excess_count = max(length(unassigned_lookup) - allowed_unassigned_count, 0)
	state.validation.layout_ownerless_open_bay_count = count_building_layout_lookup_components(unassigned_lookup)
	state.validation.layout_route_component_count = count_building_layout_lookup_components(candidate.route_lookup)
	state.validation.layout_route_component_error_count = state.validation.layout_route_component_count == 1 ? 0 : abs(state.validation.layout_route_component_count - 1)
	var/list/wall_defects = count_building_layout_wall_geometry_defects(candidate)
	state.validation.layout_wall_stub_count = wall_defects["stub_count"] || 0
	state.validation.layout_wall_notch_count = wall_defects["notch_count"] || 0
	state.validation.layout_wall_stair_step_count = wall_defects["stair_step_count"] || 0
	state.validation.layout_wall_misaligned_join_count = wall_defects["misaligned_join_count"] || 0
	if(state.validation.layout_wall_stub_count || state.validation.layout_wall_notch_count || state.validation.layout_wall_stair_step_count || state.validation.layout_wall_misaligned_join_count)
		state.add_stage_report("layout_wall_geometry_defects", "failed", "candidate wall graph contains prohibited geometry", wall_defects)
	var/list/wall_cleanup_report = candidate.wall_cleanup_report
	var/removed_unmapped = round(text2num("[wall_cleanup_report?["removed_unmapped_wall_tile_count"]]") || 0)
	var/removed_spurs = round(text2num("[wall_cleanup_report?["removed_single_sided_wall_tile_count"]]") || 0)
	var/removed_components = round(text2num("[wall_cleanup_report?["removed_wall_tile_count"]]") || 0)
	state.validation.layout_wall_cleanup_removed_count = removed_unmapped + removed_spurs + removed_components
	state.validation.layout_wall_cleanup_unmapped_count = removed_unmapped + removed_components
	state.validation.layout_wall_cleanup_spur_count = removed_spurs
	state.validation.layout_wall_cleanup_ratio_percent = round(state.validation.layout_wall_cleanup_removed_count * 100 / max(length(candidate.wall_turfs) + state.validation.layout_wall_cleanup_removed_count, 1))
	var/list/canyon_report = count_building_layout_route_band_canyon_slices(candidate, state.geometry.wall_lookup)
	state.validation.layout_route_wall_canyon_length = canyon_report["slice_count"] || 0
	state.validation.layout_corridor_wall_canyon_count = canyon_report["failure_count"] || 0
	var/wall_ratio = round(length(state.geometry.wall_lookup) * 100 / max(length(state.geometry.floor_turfs), 1))
	state.validation.layout_excessive_wall_to_floor_ratio_count = wall_ratio > 95 ? 1 : 0

/datum/world_edit_generator/building_layout/proc/building_layout_scene_contains_required_group(datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_cluster_spec/required_group)
	if(!istype(scene_plan) || !istype(required_group))
		return FALSE
	return building_layout_composition_group_satisfied(scene_plan, required_group, 0)

/datum/world_edit_generator/building_layout/proc/validate_building_layout_structured_scene_contracts(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/relevant_room_count = 0
	var/covered_room_count = 0
	var/dense_scene_object_count = 0
	var/blocked_scene_object_count = 0
	var/unscened_major_count = 0
	var/non_scene_object_count = 0
	for(var/datum/world_edit_building_room/room as anything in state.geometry.solved_rooms)
		if(!istype(room) || room.area < 6 || (room.role in list("route", "entry", "choke")))
			continue
		relevant_room_count++
		if((state.fixtures.scene_primary_counts_by_room[room.id] || 0) > 0 || length("[state.fixtures.scene_kind_by_room[room.id] || ""]"))
			covered_room_count++
		else if(state.fixtures.structured_scene_emitted)
			state.validation.semantic_room_primary_scene_missing_count++
	for(var/list/placement as anything in state.fixtures.object_placements)
		if(!islist(placement) || "[placement["kind"]]" != "interior" || GLOB.world_edit_helpers.parse_bool(placement["infrastructure"]))
			continue
		var/turf/target_turf = placement["turf"]
		var/dense = istype(target_turf) && building_object_path_is_dense(placement["obj_path"])
		var/has_scene = GLOB.world_edit_helpers.parse_bool(placement["layout_scene"]) || length("[placement["scene_id"] || ""]")
		if(dense && has_scene)
			dense_scene_object_count++
			if(state.geometry.reserved_lookup[target_turf] || state.has_anchor("door_cone", target_turf))
				blocked_scene_object_count++
		if(state.fixtures.structured_scene_emitted && !has_scene)
			non_scene_object_count++
			if(GLOB.world_edit_helpers.parse_bool(placement["major"]))
				unscened_major_count++
	state.fixtures.legacy_fixture_after_scene_count = non_scene_object_count
	state.validation.legacy_fixture_after_scene_count = max(state.validation.legacy_fixture_after_scene_count, non_scene_object_count)
	state.validation.semantic_major_object_without_scene_count = max(state.validation.semantic_major_object_without_scene_count, unscened_major_count)
	state.validation.semantic_scene_route_block_count = max(state.validation.semantic_scene_route_block_count, state.validation.scene_blocks_route_count + state.validation.route_blocked_by_furniture_count + blocked_scene_object_count)
	state.validation.semantic_scene_door_clearance_block_count = max(state.validation.semantic_scene_door_clearance_block_count, state.validation.door_clearance_blocked_count)
	state.validation.semantic_room_primary_scene_missing_count = max(state.validation.semantic_room_primary_scene_missing_count, state.validation.room_primary_scene_missing_count)
	state.validation.semantic_scene_required_missing_count = max(state.validation.semantic_scene_required_missing_count, state.validation.scene_required_missing_count, state.validation.semantic_room_primary_scene_missing_count)
	state.validation.semantic_pairing_error_count = max(state.validation.semantic_pairing_error_count, state.validation.unpaired_chair_count + state.validation.loose_table_count + state.validation.loose_chair_count + state.validation.table_chair_mosaic_count + state.validation.furniture_group_fragmented_count)
	var/coverage_percent = relevant_room_count > 0 ? round(covered_room_count * 100 / relevant_room_count) : 100
	var/clearance_percent = dense_scene_object_count > 0 ? round((dense_scene_object_count - blocked_scene_object_count) * 100 / dense_scene_object_count) : 100
	state.validation.semantic_functional_coverage_percent = clamp(coverage_percent, 0, 100)
	state.validation.semantic_route_clearance_percent = clamp(clearance_percent, 0, 100)
	state.validation.semantic_distribution_noise_score = min(100, state.validation.semantic_pairing_error_count * 10 + state.validation.semantic_major_object_without_scene_count * 15 + state.validation.legacy_fixture_after_scene_count * 20 + state.validation.common_scene_fragmentation_count * 8 + state.validation.room_scene_duplicate_count * 8 + state.validation.layout_underfurnished_room_count * 12 + state.validation.large_sparse_room_count * 12 + state.validation.large_empty_unassigned_floor_count * 12)

/datum/world_edit_generator/building_layout/proc/building_layout_candidate_has_required_topology_edge(datum/world_edit_building_layout_candidate/candidate, from_room, to_room)
	if(!istype(candidate))
		return FALSE
	for(var/datum/world_edit_building_layout_room_connection/connection as anything in candidate.room_connections)
		if(!istype(connection))
			continue
		if((connection.from_node_id == from_room && connection.to_node_id == to_room) || (connection.from_node_id == to_room && connection.to_node_id == from_room))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_candidate_has_required_topology_geometry(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_program_contract/program, datum/world_edit_building_layout_connection_contract/connection_contract)
	if(!istype(context) || !istype(candidate) || !istype(program) || !istype(connection_contract))
		return FALSE
	var/from_endpoint = connection_contract.from_node_id
	var/to_endpoint = connection_contract.to_node_id
	var/datum/world_edit_building_layout_room_contract/from_contract = program.get_room_contract(from_endpoint)
	var/datum/world_edit_building_layout_room_contract/to_contract = program.get_room_contract(to_endpoint)
	if(istype(from_contract) && istype(to_contract) && !from_contract.counts_toward_target && !to_contract.counts_toward_target)
		return building_layout_candidate_has_circulation_edge(candidate, program, connection_contract)
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		if(!istype(opening_plan))
			continue
		var/endpoint_match = (opening_plan.from_room == from_endpoint && opening_plan.to_room == to_endpoint) || (opening_plan.from_room == to_endpoint && opening_plan.to_room == from_endpoint)
		if(!endpoint_match)
			continue
		if((istype(from_contract) && !from_contract.counts_toward_target) || (istype(to_contract) && !to_contract.counts_toward_target))
			if(building_layout_door_plan_has_valid_shared_wall(context, candidate, opening_plan))
				return TRUE
			continue
		var/datum/world_edit_building_layout_room_plan/from_plan = candidate.get_room_plan(opening_plan.from_room)
		var/datum/world_edit_building_layout_room_plan/to_plan = candidate.get_room_plan(opening_plan.to_room)
		if(!istype(from_plan) || !istype(to_plan))
			continue
		var/forward_match = from_plan.contract_id == connection_contract.from_node_id && to_plan.contract_id == connection_contract.to_node_id
		var/reverse_match = from_plan.contract_id == connection_contract.to_node_id && to_plan.contract_id == connection_contract.from_node_id
		if(!forward_match && !reverse_match)
			continue
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(opening_plan))
			if(building_layout_opening_bridges_room_plans(opening_turf, from_plan, to_plan))
				return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_candidate_has_circulation_edge(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_program_contract/program, datum/world_edit_building_layout_connection_contract/connection_contract)
	if(!istype(candidate) || !istype(program) || !istype(connection_contract) || !building_layout_route_turfs_are_connected(candidate))
		return FALSE
	var/datum/world_edit_building_layout_room_contract/from_contract = program.get_room_contract(connection_contract.from_node_id)
	var/datum/world_edit_building_layout_room_contract/to_contract = program.get_room_contract(connection_contract.to_node_id)
	if(!istype(from_contract) || !istype(to_contract))
		return FALSE
	for(var/turf/from_turf as anything in candidate.route_owner_by_turf)
		if(candidate.route_owner_by_turf[from_turf] != from_contract.id)
			continue
		for(var/check_dir in GLOB.cardinals)
			var/turf/to_turf = get_step(from_turf, check_dir)
			if(candidate.route_owner_by_turf[to_turf] == to_contract.id)
				return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_opening_bridges_room_plans(turf/opening_turf, datum/world_edit_building_layout_room_plan/from_plan, datum/world_edit_building_layout_room_plan/to_plan)
	if(!istype(opening_turf) || !istype(from_plan) || !istype(to_plan))
		return FALSE
	for(var/check_dir in GLOB.cardinals)
		var/turf/near_turf = get_step(opening_turf, check_dir)
		var/turf/far_turf = get_step(opening_turf, turn(check_dir, 180))
		if((from_plan.turf_lookup[near_turf] && to_plan.turf_lookup[far_turf]) || (to_plan.turf_lookup[near_turf] && from_plan.turf_lookup[far_turf]))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/count_building_layout_lookup_components(list/turf_lookup)
	if(!islist(turf_lookup) || !length(turf_lookup))
		return 0
	var/list/visited = list()
	var/component_count = 0
	for(var/turf/seed as anything in turf_lookup)
		if(!istype(seed) || visited[seed])
			continue
		component_count++
		var/list/open = list(seed)
		visited[seed] = TRUE
		while(length(open))
			var/turf/current = open[1]
			open.Cut(1, 2)
			for(var/check_dir in GLOB.cardinals)
				var/turf/nearby = get_step(current, check_dir)
				if(!istype(nearby) || !turf_lookup[nearby] || visited[nearby])
					continue
				visited[nearby] = TRUE
				open += nearby
	return component_count

/datum/world_edit_generator/building_layout/proc/count_building_layout_wall_geometry_defects(datum/world_edit_building_layout_candidate/candidate)
	var/list/report = list("stub_count" = 0, "notch_count" = 0, "stair_step_count" = 0, "misaligned_join_count" = 0, "stub_turfs" = list(), "notch_turfs" = list(), "stair_step_turfs" = list(), "misaligned_join_turfs" = list())
	if(!istype(candidate) || !length(candidate.partition_segments))
		return report
	var/list/segment_by_turf = list()
	for(var/datum/world_edit_building_partition_segment/segment as anything in candidate.partition_segments)
		if(!istype(segment) || !length(segment.turfs))
			report["stub_count"]++
			continue
		var/valid_orientation = segment.orientation in list("vertical", "horizontal")
		var/turf/first_turf = segment.turfs[1]
		var/min_axis = segment.orientation == "vertical" ? first_turf.y : first_turf.x
		var/max_axis = min_axis
		var/straight = valid_orientation
		for(var/turf/wall_turf as anything in segment.turfs)
			if(!istype(wall_turf))
				straight = FALSE
				continue
			if((segment.orientation == "vertical" && wall_turf.x != first_turf.x) || (segment.orientation == "horizontal" && wall_turf.y != first_turf.y))
				straight = FALSE
			var/axis_value = segment.orientation == "vertical" ? wall_turf.y : wall_turf.x
			min_axis = min(min_axis, axis_value)
			max_axis = max(max_axis, axis_value)
			if(segment_by_turf[wall_turf] && segment_by_turf[wall_turf] != segment)
				report["misaligned_join_count"]++
				report["misaligned_join_turfs"] += "[wall_turf.x],[wall_turf.y],[wall_turf.z]"
			else
				segment_by_turf[wall_turf] = segment
		if(length(segment.turfs) < 2)
			report["stub_count"]++
			report["stub_turfs"] += "[first_turf.x],[first_turf.y],[first_turf.z]"
		if(!straight || max_axis - min_axis + 1 != length(segment.turfs))
			report["stair_step_count"]++
			report["stair_step_turfs"] += "[first_turf.x],[first_turf.y],[first_turf.z]"
	return report

/datum/world_edit_generator/building_layout/proc/count_building_layout_route_band_canyon_slices(datum/world_edit_building_layout_candidate/candidate, list/wall_lookup)
	var/list/report = list("slice_count" = 0, "failure_count" = 0, "share_percent" = 0)
	if(!istype(candidate) || !islist(wall_lookup) || !length(candidate.route_turfs))
		return report
	var/list/opening_lookup = list()
	var/list/access_approach_lookup = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(opening_plan))
			if(istype(opening_turf))
				opening_lookup[opening_turf] = TRUE
	for(var/room_id as anything in candidate.access_reservations_by_room)
		var/list/reservation = candidate.access_reservations_by_room[room_id]
		for(var/turf/approach_turf as anything in reservation?["route_run"])
			if(istype(approach_turf))
				access_approach_lookup[approach_turf] = TRUE
		var/list/connector_run = reservation?["connector_run"]
		if(islist(connector_run) && length(connector_run))
			for(var/connector_index in max(length(connector_run) - 1, 1) to length(connector_run))
				var/turf/connector_approach = connector_run[connector_index]
				if(istype(connector_approach))
					access_approach_lookup[connector_approach] = TRUE
	var/list/canyon_lookup = list()
	var/list/orientation_lookup = list()
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf) || opening_lookup[route_turf] || access_approach_lookup[route_turf])
			continue
		var/vertical = candidate.route_lookup[get_step(route_turf, NORTH)] || candidate.route_lookup[get_step(route_turf, SOUTH)]
		var/horizontal = candidate.route_lookup[get_step(route_turf, EAST)] || candidate.route_lookup[get_step(route_turf, WEST)]
		if(!vertical && !horizontal)
			continue
		var/side_a = vertical ? WEST : NORTH
		var/side_b = vertical ? EAST : SOUTH
		var/turf/wall_a = find_building_layout_first_non_route_turf(candidate, route_turf, side_a)
		var/turf/wall_b = find_building_layout_first_non_route_turf(candidate, route_turf, side_b)
		if(!istype(wall_a) || !istype(wall_b) || !wall_lookup[wall_a] || !wall_lookup[wall_b] || opening_lookup[wall_a] || opening_lookup[wall_b])
			continue
		canyon_lookup[route_turf] = TRUE
		orientation_lookup[route_turf] = vertical ? "V" : "H"
	var/slice_count = length(canyon_lookup)
	var/share_percent = round(slice_count * 100 / max(length(candidate.route_turfs), 1))
	report["slice_count"] = slice_count
	report["share_percent"] = share_percent
	var/list/visited_lookup = list()
	var/failure_count = 0
	for(var/turf/canyon_turf as anything in canyon_lookup)
		if(!istype(canyon_turf) || visited_lookup[canyon_turf])
			continue
		var/orientation = orientation_lookup[canyon_turf]
		var/list/open = list(canyon_turf)
		var/component_length = 0
		while(length(open))
			var/turf/current = open[1]
			open.Cut(1, 2)
			if(visited_lookup[current] || orientation_lookup[current] != orientation)
				continue
			visited_lookup[current] = TRUE
			component_length++
			var/list/axis_dirs = orientation == "V" ? list(NORTH, SOUTH) : list(EAST, WEST)
			for(var/axis_dir in axis_dirs)
				var/turf/nearby = get_step(current, axis_dir)
				if(canyon_lookup[nearby] && !visited_lookup[nearby] && orientation_lookup[nearby] == orientation)
					open += nearby
		if(component_length > 3)
			failure_count += component_length - 3
	report["failure_count"] = failure_count
	return report

/datum/world_edit_generator/building_layout/proc/find_building_layout_first_non_route_turf(datum/world_edit_building_layout_candidate/candidate, turf/start_turf, step_dir)
	if(!istype(candidate) || !istype(start_turf))
		return null
	var/turf/current = get_step(start_turf, step_dir)
	var/guard = 0
	while(istype(current) && candidate.route_lookup[current] && guard < 8)
		current = get_step(current, step_dir)
		guard++
	return current
