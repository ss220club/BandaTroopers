/datum/world_edit_generator/building_layout/proc/building_layout_solver_enabled(datum/world_edit_building_layout_state/state)
	return istype(state) && GLOB.world_edit_helpers.parse_bool(state.config["layout_enabled"])

/datum/world_edit_generator/building_layout/proc/solve_building_layout(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.archetype) || !istype(state.semantic_plan))
		return FALSE
	state.config["layout_enabled"] = TRUE
	var/datum/world_edit_building_layout_program_contract/program_contract = build_building_layout_program_contract(state)
	if(!istype(program_contract))
		state.add_error("Building layout has no solver contract for [state.archetype.id].")
		return FALSE
	var/datum/world_edit_building_layout_context/context = new(src, state, program_contract)
	state.layout_context = context
	var/list/candidates = generate_building_layout_candidates(context)
	var/datum/world_edit_building_layout_candidate/best = select_hard_valid_building_layout_candidate(context, candidates)
	if(!istype(best))
		state.add_error("Building layout could not select a valid layout candidate.")
		state.add_stage_report("layout_scene", "failed", format_building_messages(state.validation.errors), list("candidate_count" = state.config["layout_candidate_count"] || 0, "topology_candidate_count" = length(candidates)))
		return FALSE
	context.selected_candidate = best
	if(!run_building_layout_candidate_emission_pipeline(context, best))
		state.add_stage_report("layout_scene", "failed", "selected candidate failed final emission validation", list(
			"pattern_id" = best.pattern_id,
			"candidate_id" = best.id,
			"errors" = state.validation.errors.Copy(),
			"hard_counters" = build_building_state_hard_counter_report(state),
		))
		return FALSE
	state.add_stage_report("layout_scene", state.has_errors() ? "failed" : "ok", state.has_errors() ? format_building_messages(state.validation.errors) : null, list(
		"program_id" = program_contract.id,
		"pattern_id" = best.pattern_id,
		"candidate_count" = state.config["layout_candidate_count"] || 0,
		"topology_candidate_count" = length(candidates),
		"scene_count" = length(best.room_plans),
		"room_count" = length(state.geometry.solved_rooms),
	))
	return !state.has_errors()

/datum/world_edit_generator/building_layout/proc/generate_building_layout_candidates(datum/world_edit_building_layout_context/context)
	var/list/candidates = list()
	if(!istype(context) || !istype(context.program_contract))
		return candidates
	var/list/family_order = list()
	var/list/work_by_family = list()
	for(var/pattern_id as anything in context.program_contract.allowed_layout_patterns)
		var/datum/world_edit_building_layout_pattern/pattern = get_building_layout_pattern(pattern_id)
		if(!istype(pattern) || !pattern.can_solve(context))
			continue
		var/list/family_work = list()
		for(var/datum/world_edit_building_layout_region_candidate/region_candidate as anything in pattern.build_region_candidates(context))
			if(!istype(region_candidate))
				continue
			// Evaluate four authored contract orders, then materialize the second and
			// third ranked complete partials from the cached primary-order beam.
			for(var/allocation_variant in 0 to 5)
				family_work += list(list("region" = region_candidate, "allocation_variant" = allocation_variant))
		if(length(family_work))
			family_order += pattern_id
			work_by_family[pattern_id] = family_work
	context.state.add_stage_report("layout_candidate_schedule", length(family_order) ? "ok" : "failed", length(family_order) ? null : "no eligible family/orientation work", list(
		"family_count" = length(family_order),
		"families" = family_order.Copy(),
		"candidate_cap" = context.program_contract.max_layout_candidates,
		"room_contracts" = build_building_layout_program_room_contract_report(context.state, context.program_contract),
		"connection_contracts" = build_building_layout_program_connection_contract_report(context.program_contract),
	))
	var/round_robin_progress = TRUE
	while(round_robin_progress && length(candidates) < context.program_contract.max_layout_candidates)
		round_robin_progress = FALSE
		for(var/family_id as anything in family_order)
			var/list/family_work = work_by_family[family_id]
			if(!islist(family_work) || !length(family_work) || length(candidates) >= context.program_contract.max_layout_candidates)
				continue
			round_robin_progress = TRUE
			var/list/work = family_work[1]
			family_work.Cut(1, 2)
			var/datum/world_edit_building_layout_region_candidate/region_candidate = work["region"]
			var/allocation_variant = work["allocation_variant"]
			var/datum/world_edit_building_layout_candidate/candidate = allocate_building_layout_rooms(context, region_candidate, allocation_variant)
			if(!istype(candidate))
				context.state.add_stage_report("layout_candidate_room_allocation_reject", "failed", "region allocation returned no candidate", list("candidate_id" = region_candidate.id, "pattern_id" = region_candidate.pattern_id))
				continue
			candidate.id = "[region_candidate.id]_order_[allocation_variant]"
			if(length(candidate.errors))
				context.state.add_stage_report("layout_candidate_room_allocation_reject", "failed", format_building_messages(candidate.errors), list("candidate_id" = candidate.id, "pattern_id" = candidate.pattern_id, "errors" = candidate.errors.Copy()))
				continue
			if(!ensure_building_layout_candidate_wall_model(context, candidate))
				context.state.add_stage_report("layout_candidate_wall_model_reject", "failed", format_building_messages(candidate.errors), list("candidate_id" = candidate.id, "pattern_id" = candidate.pattern_id, "errors" = candidate.errors.Copy(), "rooms" = build_building_layout_candidate_room_report(candidate), "routes" = build_building_layout_candidate_route_report(candidate)))
				continue
			if(!solve_building_layout_openings(context, candidate))
				context.state.add_stage_report("layout_candidate_opening_reject", "failed", format_building_messages(candidate.errors), list("candidate_id" = candidate.id, "pattern_id" = candidate.pattern_id, "errors" = candidate.errors.Copy(), "rooms" = build_building_layout_candidate_room_report(candidate), "routes" = build_building_layout_candidate_route_report(candidate)))
				continue
			candidate.wall_model_ready = FALSE
			if(!ensure_building_layout_candidate_wall_model(context, candidate))
				context.state.add_stage_report("layout_candidate_wall_model_reject", "failed", format_building_messages(candidate.errors), list("candidate_id" = candidate.id, "pattern_id" = candidate.pattern_id, "errors" = candidate.errors.Copy(), "rooms" = build_building_layout_candidate_room_report(candidate), "routes" = build_building_layout_candidate_route_report(candidate)))
				continue
			if(!validate_building_layout_topology(context, candidate))
				context.state.add_stage_report("layout_candidate_topology_reject", "failed", format_building_messages(candidate.errors), list("candidate_id" = candidate.id, "pattern_id" = candidate.pattern_id, "errors" = candidate.errors.Copy(), "rooms" = build_building_layout_candidate_room_report(candidate), "routes" = build_building_layout_candidate_route_report(candidate)))
				continue
			var/datum/world_edit_building_layout_family_policy/policy = get_building_layout_family_policy(candidate.family_policy_id)
			if(!istype(policy) || !policy.hard_validate(context, candidate))
				candidate.errors += "family.hard_constraint_failed:[candidate.family_policy_id]"
				context.state.add_stage_report("layout_candidate_family_reject", "failed", format_building_messages(candidate.errors), list(
					"candidate_id" = candidate.id,
					"family_id" = candidate.family_policy_id,
					"errors" = candidate.errors.Copy(),
					"family_constraints" = candidate.family_constraints.Copy(),
				))
				continue
			candidate.score += score_building_layout_solver_candidate(context, candidate)
			candidate.topology_signature = build_building_layout_topology_signature(candidate)
			candidates += candidate
	return candidates

/datum/world_edit_generator/building_layout/proc/build_building_layout_program_room_contract_report(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	var/list/result = list()
	for(var/datum/world_edit_building_layout_room_contract/room as anything in program?.room_contracts)
		if(!istype(room))
			continue
		var/list/required_groups = list()
		var/datum/world_edit_building_layout_composition_contract/composition = program.get_composition_contract(room.id)
		var/datum/world_edit_building_zone_spec/zone_spec = state?.semantic_plan?.get_zone_spec(room.zone_id)
		for(var/datum/world_edit_building_cluster_spec/group as anything in composition?.required_groups)
			var/list/footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
			required_groups += list(list(
				"group_id" = group.id,
				"module_id" = footprint["module_id"],
				"area" = footprint["area"],
				"occupied_area" = footprint["occupied_area"],
				"required_instances" = footprint["required_instances"],
			))
		result += list(list(
			"id" = room.id,
			"zone_id" = room.zone_id,
			"role" = room.role,
			"spatial_kind" = room.spatial_kind,
			"circulation_kind" = room.circulation_kind,
			"circulation_owner_room_id" = room.circulation_owner_room_id,
			"circulation_min_width" = room.circulation_min_width,
			"instance_index" = room.instance_index,
			"counts_toward_target" = room.counts_toward_target,
			"min_area" = room.min_area,
			"preferred_area" = room.preferred_area,
			"min_width" = room.min_width,
			"min_height" = room.min_height,
			"min_composition_short_side" = room.min_composition_short_side,
			"min_composition_long_side" = room.min_composition_long_side,
			"nested_parent_floor_min_area" = room.nested_parent_floor_min_area,
			"nested_parent_floor_min_width" = room.nested_parent_floor_min_width,
			"nested_parent_floor_min_height" = room.nested_parent_floor_min_height,
			"nested_child_reserved_area" = room.nested_child_reserved_area,
			"nested_partition_reserved_area" = room.nested_partition_reserved_area,
			"required_groups" = required_groups,
		))
	return result

/datum/world_edit_generator/building_layout/proc/build_building_layout_program_connection_contract_report(datum/world_edit_building_layout_program_contract/program)
	var/list/result = list()
	for(var/datum/world_edit_building_layout_connection_contract/connection as anything in program?.connection_contracts)
		if(!istype(connection))
			continue
		result += list(list(
			"from_node_id" = connection.from_node_id,
			"to_node_id" = connection.to_node_id,
			"edge_kind" = connection.edge_kind,
			"opening_policy" = connection.opening_policy,
			"route_policy" = connection.route_policy,
			"required" = connection.required,
			"min_shared_wall" = connection.min_shared_wall,
			"min_opening_width" = connection.min_opening_width,
			"max_opening_width" = connection.max_opening_width,
		))
	return result

/datum/world_edit_generator/building_layout/proc/select_best_building_layout_candidate(datum/world_edit_building_layout_context/context, list/candidates)
	var/datum/world_edit_building_layout_candidate/best = null
	var/best_score = -999999999
	for(var/datum/world_edit_building_layout_candidate/candidate as anything in candidates)
		if(!istype(candidate) || length(candidate.errors))
			continue
		if(!istype(best) || candidate.score > best_score)
			best = candidate
			best_score = candidate.score
	if(istype(best) && istype(context?.state))
		context.state.config["layout_pattern_id"] = best.pattern_id
		context.state.config["layout_candidate_id"] = best.id
		context.state.config["layout_candidate_score"] = best.score
	return best

/datum/world_edit_generator/building_layout/proc/select_hard_valid_building_layout_candidate(datum/world_edit_building_layout_context/context, list/candidates)
	if(!istype(context) || !istype(context.state) || !islist(candidates))
		return null
	var/list/remaining = candidates.Copy()
	var/hard_valid_count = 0
	var/list/hard_valid_family_lookup = list()
	var/list/hard_valid_signature_lookup = list()
	var/list/hard_valid_candidates = list()
	var/scene_solved_candidate_count = 0
	var/min_hard_valid_candidates = is_building_compact_or_micro_state(context.state) ? 1 : 2
	var/min_distinct_families = is_building_compact_or_micro_state(context.state) ? 1 : 2
	var/list/best_rejected_hard_counters = null
	var/list/best_rejected_validation_verdict = null
	while(length(remaining))
		var/non_axial_remaining = FALSE
		for(var/datum/world_edit_building_layout_candidate/pending_candidate as anything in remaining)
			if(istype(pending_candidate) && pending_candidate.topology_family != "axial_fallback")
				non_axial_remaining = TRUE
				break
		if(!non_axial_remaining && length(hard_valid_candidates))
			break
		var/datum/world_edit_building_layout_candidate/candidate = null
		var/best_score = -999999999
		var/best_index = 0
		for(var/index in 1 to length(remaining))
			var/datum/world_edit_building_layout_candidate/indexed_candidate = remaining[index]
			if(!istype(indexed_candidate) || length(indexed_candidate.errors))
				continue
			if(non_axial_remaining && indexed_candidate.topology_family == "axial_fallback")
				continue
			if(!istype(candidate) || indexed_candidate.score > best_score)
				candidate = indexed_candidate
				best_score = indexed_candidate.score
				best_index = index
		if(!istype(candidate))
			break
		remaining.Cut(best_index, best_index + 1)
		var/composition_solved = solve_building_layout_compositions(context, candidate)
		if(!composition_solved)
			context.state.add_stage_report("layout_candidate_scene_reject", "failed", format_building_messages(candidate.errors), list(
				"candidate_id" = candidate.id,
				"pattern_id" = candidate.pattern_id,
				"errors" = candidate.errors.Copy(),
			))
			continue
		// Required authored compositions own their floor and clearance before
		// desired exterior windows are selected. A required window remains a hard
		// contract, while a desired window may be omitted when no scene-safe wall
		// position survives.
		if(!solve_building_layout_windows(context, candidate))
			context.state.add_stage_report("layout_candidate_scene_reject", "failed", format_building_messages(candidate.errors), list(
				"candidate_id" = candidate.id,
				"pattern_id" = candidate.pattern_id,
				"errors" = candidate.errors.Copy(),
			))
			continue
		candidate.score += score_building_layout_scene_quality(context, candidate)
		scene_solved_candidate_count++
		// Trial state snapshots the source config. Keep the public candidate
		// metric synchronized before cloning so metric-consistency validation
		// observes the exact progressive shortlist size.
		context.state.config["layout_candidate_count"] = scene_solved_candidate_count
		var/datum/world_edit_building_layout_state/trial_state = build_building_layout_candidate_trial_state(context, candidate)
		if(!istype(trial_state))
			context.state.add_stage_report("layout_candidate_post_emit_reject", "failed", "trial state unavailable", list(
				"candidate_id" = candidate.id,
				"pattern_id" = candidate.pattern_id,
				"score" = candidate.score,
			))
			continue
		var/datum/world_edit_building_layout_context/trial_context = trial_state.layout_context
		var/trial_succeeded = run_building_layout_candidate_emission_pipeline(trial_context, candidate)
		if(trial_succeeded)
			hard_valid_count++
			hard_valid_family_lookup[candidate.topology_family || candidate.pattern_id] = TRUE
			hard_valid_signature_lookup[candidate.topology_signature || build_building_layout_topology_signature(candidate)] = TRUE
			candidate.quality_vector = build_building_layout_quality_vector(trial_state, candidate)
			hard_valid_candidates += candidate
			context.state.add_stage_report("layout_candidate_hard_valid", "ok", null, list(
				"candidate_id" = candidate.id,
				"pattern_id" = candidate.pattern_id,
				"topology_signature" = candidate.topology_signature,
				"quality_vector" = candidate.quality_vector.Copy(),
			))
			if(hard_valid_count >= min_hard_valid_candidates && length(hard_valid_family_lookup) >= min_distinct_families)
				break
			continue
		var/list/hard_counters = build_building_state_hard_counter_report(trial_state)
		if(!islist(best_rejected_hard_counters))
			best_rejected_hard_counters = hard_counters.Copy()
			var/datum/world_edit_validation_verdict/rejected_verdict = build_building_generation_validation_verdict(trial_state)
			best_rejected_validation_verdict = rejected_verdict.as_payload()
		context.state.add_stage_report("layout_candidate_post_emit_reject", "failed", format_building_messages(trial_state.validation.errors), list(
			"candidate_id" = candidate.id,
			"pattern_id" = candidate.pattern_id,
			"score" = candidate.score,
			"errors" = trial_state.validation.errors.Copy(),
			"hard_counters" = hard_counters,
			"room_count" = length(trial_state.geometry.solved_rooms),
			"corridor_turf_count" = length(trial_state.geometry.corridor_turfs),
			"rooms" = build_building_layout_candidate_room_report(candidate),
			"routes" = build_building_layout_candidate_route_report(candidate),
			"openings" = build_building_layout_candidate_opening_report(candidate),
			"walls" = build_building_layout_candidate_wall_report(candidate),
			"partitions" = candidate.partition_edges.Copy(),
			"stage_reports" = trial_state.validation.stage_reports.Copy(),
		))
	context.state.config["layout_hard_valid_candidate_count"] = hard_valid_count
	context.state.config["layout_candidate_count"] = scene_solved_candidate_count
	context.state.config["layout_distinct_hard_valid_family_count"] = length(hard_valid_family_lookup)
	context.state.config["structural_topology_signature_count"] = length(hard_valid_signature_lookup)
	context.state.validation.layout_distinct_hard_valid_family_count = length(hard_valid_family_lookup)
	var/datum/world_edit_building_layout_candidate/selected_candidate = select_seeded_building_layout_family_winner(context, hard_valid_candidates)
	if(istype(selected_candidate))
		stamp_building_layout_selected_candidate(context.state, selected_candidate)
	else
		context.state.config["layout_failed_trial_hard_counters"] = islist(best_rejected_hard_counters) ? best_rejected_hard_counters : list()
		context.state.config["layout_failed_trial_validation_verdict"] = islist(best_rejected_validation_verdict) ? best_rejected_validation_verdict : list()
	return selected_candidate

/datum/world_edit_generator/building_layout/proc/build_building_layout_topology_signature(datum/world_edit_building_layout_candidate/candidate)
	if(!istype(candidate))
		return ""
	var/list/parts = list()
	var/list/node_parts = list()
	var/list/edge_parts = list()
	var/list/route_degree_parts = list()
	var/list/route_overlay_parts = list()
	var/min_x = 999999
	var/min_y = 999999
	var/max_x = -999999
	var/max_y = -999999
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		min_x = min(min_x, room_plan.x1)
		min_y = min(min_y, room_plan.y1)
		max_x = max(max_x, room_plan.x2)
		max_y = max(max_y, room_plan.y2)
	var/center_x = min_x <= max_x ? (min_x + max_x) / 2 : 0
	var/center_y = min_y <= max_y ? (min_y + max_y) / 2 : 0
	var/open_bay_count = 0
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		var/room_center_x = (room_plan.x1 + room_plan.x2) / 2
		var/room_center_y = (room_plan.y1 + room_plan.y2) / 2
		var/delta_x = room_center_x - center_x
		var/delta_y = room_center_y - center_y
		var/side = abs(delta_x) > abs(delta_y) ? (delta_x < 0 ? "W" : "E") : (delta_y < 0 ? "S" : "N")
		if(abs(delta_x) < 0.5 && abs(delta_y) < 0.5)
			side = "C"
		var/datum/world_edit_building_layout_topology_node/node = candidate.topology_graph?.get_node(room_plan.contract_id)
		var/node_degree = length(candidate.topology_graph?.get_edges_for(room_plan.contract_id))
		node_parts += "node|[room_plan.contract_id]|kind=[node?.node_kind || WORLD_EDIT_BUILDING_TOPOLOGY_FUNCTIONAL]|parent=[room_plan.topology_parent]|degree=[node_degree]|depth=[node?.depth || 0]|group=[node?.placement_group]|space=[room_plan.spatial_kind]|side=[side]"
		if(room_plan.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
			open_bay_count++
	for(var/datum/world_edit_building_layout_topology_node/node as anything in candidate.topology_graph?.nodes)
		if(!istype(node) || candidate.room_plans_by_id[node.id])
			continue
		var/node_degree = length(candidate.topology_graph.get_edges_for(node.id))
		node_parts += "node|[node.id]|kind=[node.node_kind]|parent=[node.parent_id]|degree=[node_degree]|depth=[node.depth]|group=[node.placement_group]|space=circulation|side=C"
	var/nested_edge_count = 0
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph?.edges)
		if(istype(edge))
			var/list/endpoints = sortList(list(edge.from_id, edge.to_id))
			edge_parts += "edge|[edge.edge_kind]|[endpoints[1]]|[endpoints[2]]|opening=[edge.opening_policy]|route=[edge.route_policy]|width=[edge.min_opening_width]-[edge.max_opening_width]"
			if(edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
				nested_edge_count++
	var/list/owner_counts = list()
	var/route_min_x = 999999
	var/route_min_y = 999999
	var/route_max_x = -999999
	var/route_max_y = -999999
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf))
			continue
		route_min_x = min(route_min_x, route_turf.x)
		route_min_y = min(route_min_y, route_turf.y)
		route_max_x = max(route_max_x, route_turf.x)
		route_max_y = max(route_max_y, route_turf.y)
		var/degree = 0
		for(var/check_dir in GLOB.cardinals)
			if(candidate.route_lookup[get_step(route_turf, check_dir)])
				degree++
		route_degree_parts += "route_degree|[degree]"
		var/owner_id = "[candidate.route_owner_by_turf[route_turf] || "route"]"
		owner_counts[owner_id] = (owner_counts[owner_id] || 0) + 1
	for(var/node_part in sortList(node_parts))
		parts += node_part
	for(var/edge_part in sortList(edge_parts))
		parts += edge_part
	for(var/route_degree_part in sortList(route_degree_parts))
		parts += route_degree_part
	var/list/owner_parts = list()
	for(var/owner_id as anything in owner_counts)
		owner_parts += "route_owner|[owner_id]|count=[owner_counts[owner_id]]"
	for(var/owner_part in sortList(owner_parts))
		parts += owner_part
	for(var/datum/world_edit_building_layout_route_overlay/overlay as anything in candidate.route_overlays)
		if(istype(overlay))
			route_overlay_parts += "route_overlay|[overlay.id]|owner=[overlay.owner_room_id]|kind=[overlay.kind]|width=[overlay.min_width]|cells=[length(overlay.turfs)]|approach=[length(overlay.approach_turfs)]"
	for(var/overlay_part in sortList(route_overlay_parts))
		parts += overlay_part
	var/route_width = length(candidate.route_turfs) ? route_max_x - route_min_x + 1 : 0
	var/route_height = length(candidate.route_turfs) ? route_max_y - route_min_y + 1 : 0
	parts += "route_shape|cells=[length(candidate.route_turfs)]|short=[min(route_width, route_height)]|long=[max(route_width, route_height)]"
	parts += "open_bays|[open_bay_count]"
	parts += "nested_edges|[nested_edge_count]"
	return "[build_building_hash_from_strings(parts)]"

/datum/world_edit_generator/building_layout/proc/build_building_layout_quality_vector(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(state) || !istype(candidate))
		return list(1, 999999, 999999, 999999, 999999, 999999, -999999)
	var/mapping_defects = state.validation.layout_required_adjacency_geometry_missing_count + state.validation.layout_candidate_metric_mismatch_count + state.validation.layout_required_connection_missing_count
	var/composition_deficits = state.validation.layout_room_composition_missing_count + state.validation.layout_room_capacity_shortfall_count + state.validation.layout_atomic_module_fragmentation_count + state.validation.layout_required_template_reject_count
	var/residual_cleanup = state.validation.layout_unassigned_interior_excess_count + state.validation.layout_wall_cleanup_unmapped_count + state.validation.layout_wall_cleanup_spur_count + state.validation.layout_wall_stub_count + state.validation.layout_wall_notch_count + state.validation.layout_wall_stair_step_count + state.validation.layout_wall_misaligned_join_count
	var/topology_defects = state.validation.layout_required_adjacency_missing_count + state.validation.layout_ownerless_open_bay_count + state.validation.layout_route_component_error_count
	var/route_cost = length(candidate.route_turfs) + state.validation.layout_corridor_wall_canyon_count * 100
	return list(0, mapping_defects, composition_deficits, residual_cleanup, topology_defects, route_cost, candidate.score)

/datum/world_edit_generator/building_layout/proc/building_layout_quality_vector_better(list/candidate_vector, list/reference_vector)
	if(!islist(candidate_vector))
		return FALSE
	if(!islist(reference_vector))
		return TRUE
	for(var/index in 1 to 6)
		var/candidate_value = text2num("[candidate_vector[index]]") || 0
		var/reference_value = text2num("[reference_vector[index]]") || 0
		if(candidate_value < reference_value)
			return TRUE
		if(candidate_value > reference_value)
			return FALSE
	return (text2num("[candidate_vector[7]]") || 0) > (text2num("[reference_vector[7]]") || 0)

/datum/world_edit_generator/building_layout/proc/building_layout_quality_vector_prefix_equal(list/a, list/b)
	if(!islist(a) || !islist(b))
		return FALSE
	for(var/index in 1 to 6)
		if((text2num("[a[index]]") || 0) != (text2num("[b[index]]") || 0))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/select_seeded_building_layout_family_winner(datum/world_edit_building_layout_context/context, list/hard_valid_candidates)
	if(!istype(context) || !istype(context.state) || !islist(hard_valid_candidates) || !length(hard_valid_candidates))
		return null
	var/list/family_winner_by_id = list()
	var/list/family_ids = list()
	for(var/datum/world_edit_building_layout_candidate/candidate as anything in hard_valid_candidates)
		if(!istype(candidate) || length(candidate.errors))
			continue
		var/family_id = "[candidate.topology_signature || build_building_layout_topology_signature(candidate)]"
		var/datum/world_edit_building_layout_candidate/existing_winner = family_winner_by_id[family_id]
		if(!istype(existing_winner))
			family_ids += family_id
			family_winner_by_id[family_id] = candidate
		else if(building_layout_quality_vector_better(candidate.quality_vector, existing_winner.quality_vector))
			family_winner_by_id[family_id] = candidate
	if(!length(family_ids))
		return null

	var/best_score = -999999999
	var/datum/world_edit_building_layout_candidate/lexicographic_best = null
	var/list/family_winner_scores = list()
	for(var/family_id as anything in family_ids)
		var/datum/world_edit_building_layout_candidate/family_winner = family_winner_by_id[family_id]
		if(!istype(family_winner))
			continue
		family_winner_scores[family_id] = family_winner.score
		if(!istype(lexicographic_best) || building_layout_quality_vector_better(family_winner.quality_vector, lexicographic_best.quality_vector))
			lexicographic_best = family_winner
			best_score = family_winner.score
	var/quality_margin = max(1, round(abs(best_score) * 0.005))
	var/quality_floor = best_score - quality_margin
	var/list/eligible_by_key = list()
	var/list/eligible_keys = list()
	for(var/family_id as anything in family_ids)
		var/datum/world_edit_building_layout_candidate/family_winner = family_winner_by_id[family_id]
		if(!istype(family_winner) || !building_layout_quality_vector_prefix_equal(family_winner.quality_vector, lexicographic_best.quality_vector) || family_winner.score < quality_floor)
			continue
		var/selection_key = "[family_id]|[family_winner.id]"
		eligible_keys += selection_key
		eligible_by_key[selection_key] = family_winner
	if(!length(eligible_keys))
		return null
	eligible_keys = sortList(eligible_keys)
	var/root_seed = round(text2num("[context.state.root_seed || context.state.config["effective_seed"] || context.state.config["building_seed"] || 1]") || 1)
	var/datum/world_edit_building_prng/selection_rng = new(build_stage_seed(root_seed, "layout_family_selection"))
	var/selection_index = selection_rng.next_between(1, length(eligible_keys))
	var/selected_key = eligible_keys[selection_index]
	var/datum/world_edit_building_layout_candidate/selected_candidate = eligible_by_key[selected_key]
	if(!istype(selected_candidate))
		return null
	context.state.config["layout_best_hard_valid_candidate_score"] = best_score
	context.state.config["layout_family_winner_count"] = length(family_ids)
	context.state.config["layout_family_winner_scores"] = family_winner_scores.Copy()
	context.state.config["layout_seed_quality_margin"] = quality_margin
	context.state.config["layout_seed_quality_floor"] = quality_floor
	context.state.config["layout_seed_eligible_family_count"] = length(eligible_keys)
	context.state.config["layout_seed_selection_index"] = selection_index
	context.state.config["layout_seed_selection_key"] = selected_key
	context.state.config["layout_selected_candidate_score_gap"] = best_score - selected_candidate.score
	context.state.add_stage_report("layout_lexicographic_selection", "ok", null, list(
		"root_seed" = root_seed,
		"best_score" = best_score,
		"quality_margin" = quality_margin,
		"quality_floor" = quality_floor,
		"family_winner_count" = length(family_ids),
		"family_winner_scores" = family_winner_scores.Copy(),
		"eligible_family_count" = length(eligible_keys),
		"eligible_keys" = eligible_keys.Copy(),
		"selected_index" = selection_index,
		"selected_key" = selected_key,
		"selected_score" = selected_candidate.score,
		"selected_score_gap" = best_score - selected_candidate.score,
		"selected_quality_vector" = selected_candidate.quality_vector.Copy(),
		"selected_topology_signature" = selected_candidate.topology_signature,
	))
	return selected_candidate

/datum/world_edit_generator/building_layout/proc/stamp_building_layout_selected_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(state) || !istype(candidate))
		return
	state.config["layout_pattern_id"] = candidate.pattern_id
	state.config["layout_candidate_id"] = candidate.id
	state.config["layout_candidate_score"] = candidate.score
	state.validation.layout_candidate_score = candidate.score

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_trial_state(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/source_state = context?.state
	if(!istype(source_state) || !istype(context?.program_contract) || !istype(candidate))
		return null
	var/datum/world_edit_building_layout_state/trial_state = new()
	trial_state.request = source_state.request
	trial_state.archetype = source_state.archetype
	trial_state.semantic_plan = source_state.semantic_plan
	trial_state.config = source_state.config.Copy()
	trial_state.root_seed = source_state.root_seed
	trial_state.stage_seed_footprint = source_state.stage_seed_footprint
	trial_state.stage_seed_rooms = source_state.stage_seed_rooms
	trial_state.stage_seed_corridor = source_state.stage_seed_corridor
	trial_state.stage_seed_patterns = source_state.stage_seed_patterns
	trial_state.stage_seed_details = source_state.stage_seed_details
	trial_state.placement_dir = source_state.placement_dir
	trial_state.geometry.footprint = source_state.geometry.footprint.Copy()
	trial_state.geometry.boundary = source_state.geometry.boundary.Copy()
	trial_state.geometry.interior = source_state.geometry.interior.Copy()
	trial_state.geometry.footprint_lookup = source_state.geometry.footprint_lookup.Copy()
	trial_state.geometry.boundary_lookup = source_state.geometry.boundary_lookup.Copy()
	trial_state.geometry.bounds = source_state.geometry.bounds.Copy()
	trial_state.geometry.max_front_depth = source_state.geometry.max_front_depth
	trial_state.geometry.max_lateral_abs = source_state.geometry.max_lateral_abs
	trial_state.geometry.requested_direction = source_state.geometry.requested_direction
	trial_state.geometry.actual_entry_direction = source_state.geometry.actual_entry_direction
	trial_state.geometry.footprint_hash = source_state.geometry.footprint_hash
	trial_state.validation.blocked_turf_conflict_count = source_state.validation.blocked_turf_conflict_count
	trial_state.validation.replace_blocked_turf_count = source_state.validation.replace_blocked_turf_count
	trial_state.validation.current_request_support_status = source_state.validation.current_request_support_status
	trial_state.validation.user_facing_failure_reason = source_state.validation.user_facing_failure_reason
	if(islist(source_state.validation.support_status_report))
		trial_state.validation.support_status_report = source_state.validation.support_status_report.Copy()
	stamp_building_layout_selected_candidate(trial_state, candidate)
	trial_state.config["layout_candidate_count"] = source_state.config["layout_candidate_count"] || 0
	trial_state.config["layout_enabled"] = TRUE
	trial_state.config["layout_trial_emission"] = TRUE
	var/datum/world_edit_building_layout_context/trial_context = new(src, trial_state, context.program_contract)
	trial_context.selected_candidate = candidate
	trial_state.layout_context = trial_context
	return trial_state

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_room_report(datum/world_edit_building_layout_candidate/candidate)
	var/list/report = list()
	if(!istype(candidate))
		return report
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		report += list(list(
			"id" = room_plan.id,
			"contract_id" = room_plan.contract_id,
			"role" = room_plan.role,
			"spatial_kind" = room_plan.spatial_kind,
			"topology_parent" = room_plan.topology_parent,
			"topology_depth" = room_plan.graph_depth,
			"area" = room_plan.area(),
			"width" = room_plan.width(),
			"height" = room_plan.height(),
			"bounds" = list("x1" = room_plan.x1, "y1" = room_plan.y1, "x2" = room_plan.x2, "y2" = room_plan.y2),
		))
	return report

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_route_report(datum/world_edit_building_layout_candidate/candidate)
	var/list/report = list()
	if(!istype(candidate))
		return report
	var/index = 0
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf))
			continue
		index++
		if(index > 48)
			break
		report += list(list(
			"x" = route_turf.x,
			"y" = route_turf.y,
			"z" = route_turf.z,
		))
	return report

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_route_overlay_report(datum/world_edit_building_layout_candidate/candidate)
	var/list/report = list()
	if(!istype(candidate))
		return report
	for(var/datum/world_edit_building_layout_route_overlay/overlay as anything in candidate.route_overlays)
		if(!istype(overlay))
			continue
		var/list/coords = list()
		var/list/approach_coords = list()
		for(var/turf/overlay_turf as anything in overlay.turfs)
			if(istype(overlay_turf))
				coords += "[overlay_turf.x],[overlay_turf.y],[overlay_turf.z]"
		for(var/turf/approach_turf as anything in overlay.approach_turfs)
			if(istype(approach_turf))
				approach_coords += "[approach_turf.x],[approach_turf.y],[approach_turf.z]"
		report += list(list(
			"id" = overlay.id,
			"owner_room_id" = overlay.owner_room_id,
			"kind" = overlay.kind,
			"min_width" = overlay.min_width,
			"required" = overlay.required ? TRUE : FALSE,
			"turfs" = coords,
			"approach_turfs" = approach_coords,
		))
	return report

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_wall_report(datum/world_edit_building_layout_candidate/candidate)
	var/list/report = list()
	if(!istype(candidate))
		return report
	var/index = 0
	for(var/turf/wall_turf as anything in candidate.solved_internal_wall_turfs)
		if(!istype(wall_turf))
			continue
		index++
		if(index > 192)
			break
		report += "[wall_turf.x],[wall_turf.y],[wall_turf.z]"
	return report

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_opening_report(datum/world_edit_building_layout_candidate/candidate)
	var/list/report = list()
	if(!istype(candidate))
		return report
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		if(!istype(opening_plan))
			continue
		var/list/coords = list()
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(opening_plan))
			if(istype(opening_turf))
				coords += "[opening_turf.x],[opening_turf.y],[opening_turf.z]"
		report += list(list(
			"id" = opening_plan.id,
			"kind" = opening_plan.kind,
			"from" = opening_plan.from_room,
			"to" = opening_plan.to_room,
			"dir" = opening_plan.dir,
			"coords" = coords,
		))
	return report

/datum/world_edit_generator/building_layout/proc/validate_building_layout_topology(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate) || !istype(context.state))
		return FALSE
	var/list/room_turf_owner = list()
	var/list/candidate_floor_lookup = list()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan) || !length(room_plan.turfs))
			candidate.errors += "room.empty:[room_plan?.id]"
			continue
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(room_plan.contract_id)
		if(istype(room_contract))
			var/room_width = room_plan.width()
			var/room_height = room_plan.height()
			var/min_floor_area = room_contract.nested_parent_floor_min_area || room_contract.min_area
			var/min_floor_width = room_contract.nested_parent_floor_min_width || room_contract.min_width
			var/min_floor_height = room_contract.nested_parent_floor_min_height || room_contract.min_height
			var/fits_min_dimensions = (room_width >= min_floor_width && room_height >= min_floor_height) || (room_width >= min_floor_height && room_height >= min_floor_width)
			var/fits_max_dimensions = (room_width <= room_contract.max_width && room_height <= room_contract.max_height) || (room_width <= room_contract.max_height && room_height <= room_contract.max_width)
			if(room_plan.area() < min_floor_area || !fits_min_dimensions)
				candidate.errors += "room.too_small:[room_plan.id]"
			if(room_plan.area() > room_contract.max_area || !fits_max_dimensions)
				candidate.errors += "room.too_large:[room_plan.id]"
		var/room_min_dim = min(room_plan.width(), room_plan.height())
		var/room_max_dim = max(room_plan.width(), room_plan.height())
		if(room_plan.area() >= 12 && (room_min_dim <= 2 || room_max_dim > room_min_dim * 4))
			candidate.errors += "room.thin_strip:[room_plan.id]"
		for(var/turf/room_turf as anything in room_plan.turfs)
			if(!istype(room_turf) || !context.state.geometry.footprint_lookup[room_turf] || context.state.geometry.boundary_lookup[room_turf])
				candidate.errors += "room.out_of_bounds:[room_plan.id]"
				continue
			if(room_turf_owner[room_turf])
				candidate.errors += "room.overlap:[room_plan.id]"
				continue
			room_turf_owner[room_turf] = room_plan.id
			candidate_floor_lookup[room_turf] = TRUE
	for(var/datum/world_edit_building_layout_room_contract/required_contract as anything in context.program_contract.room_contracts)
		if(!istype(required_contract) || !required_contract.required || !required_contract.counts_toward_target)
			continue
		var/datum/world_edit_building_layout_room_plan/required_room_plan = candidate.get_room_plan(required_contract.id)
		if(!istype(required_room_plan))
			candidate.errors += "room.required_missing:[required_contract.id]"
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf) || !context.state.geometry.footprint_lookup[route_turf] || context.state.geometry.boundary_lookup[route_turf])
			candidate.errors += "route.out_of_bounds"
			continue
		candidate_floor_lookup[route_turf] = TRUE
	// Owner-bound aisles are explicit typed floor ownership, not residual. Keep
	// the pre-emission coverage gate identical to materialize_building_layout_candidate()
	// and to the canonical residual equation.
	for(var/turf/owner_aisle_turf as anything in candidate.owner_aisle_turfs)
		if(!istype(owner_aisle_turf) || !context.state.geometry.footprint_lookup[owner_aisle_turf] || context.state.geometry.boundary_lookup[owner_aisle_turf])
			candidate.errors += "owner_aisle.out_of_bounds"
			continue
		candidate_floor_lookup[owner_aisle_turf] = TRUE
	var/list/seen_overlay_turfs = list()
	for(var/datum/world_edit_building_layout_route_overlay/overlay as anything in candidate.route_overlays)
		var/datum/world_edit_building_layout_room_contract/overlay_contract = context.program_contract.get_room_contract(overlay?.id)
		var/datum/world_edit_building_layout_room_plan/overlay_owner = candidate.get_room_plan(overlay?.owner_room_id)
		if(!istype(overlay) || !istype(overlay_contract) || !istype(overlay_owner) || overlay.kind != WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE)
			candidate.errors += "route_overlay.invalid_contract:[overlay?.id]"
			continue
		if(length(overlay.turfs) < overlay_contract.min_area || !building_layout_route_overlay_meets_width(overlay) || !building_layout_route_overlay_is_connected(overlay) || !building_layout_route_overlay_touches_terminal(candidate, overlay))
			candidate.errors += "route_overlay.invalid_geometry:[overlay.id]"
		for(var/turf/overlay_turf as anything in overlay.turfs)
			if(!overlay_owner.turf_lookup[overlay_turf] || seen_overlay_turfs[overlay_turf])
				candidate.errors += "route_overlay.invalid_owner:[overlay.id]"
				continue
			seen_overlay_turfs[overlay_turf] = TRUE
		for(var/turf/approach_turf as anything in overlay.approach_turfs)
			if(!overlay_owner.turf_lookup[approach_turf] || seen_overlay_turfs[approach_turf])
				candidate.errors += "route_overlay.invalid_approach:[overlay.id]"
				continue
			seen_overlay_turfs[approach_turf] = TRUE
	var/list/connected_rooms = list()
	var/has_main_exit = FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || !istype(door_plan.opening_turf))
			candidate.errors += "door.missing"
			continue
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(!istype(opening_turf) || !context.state.geometry.footprint_lookup[opening_turf])
				candidate.errors += "door.out_of_bounds:[door_plan.id]"
				continue
		if(!building_layout_door_plan_has_valid_shared_wall(context, candidate, door_plan))
			candidate.errors += "door.not_shared_wall:[door_plan.id]"
			continue
		if(door_plan.kind == "main_exit")
			has_main_exit = TRUE
		else
			if(length(door_plan.from_room) && door_plan.from_room != "route")
				connected_rooms[door_plan.from_room] = TRUE
			if(length(door_plan.to_room) && door_plan.to_room != "route")
				connected_rooms[door_plan.to_room] = TRUE
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(istype(opening_turf))
				candidate_floor_lookup[opening_turf] = TRUE
	if(!has_main_exit)
		candidate.errors += "door.main_exit_missing"
	if(!building_layout_route_turfs_are_connected(candidate))
		candidate.errors += "route.disconnected"
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(!building_layout_window_plan_obeys_policy(context, candidate, window_plan))
			candidate.errors += "window.policy_or_boundary:[window_plan?.id]"
	var/interior_count = length(context.state.geometry.interior)
	if(interior_count >= 180)
		var/min_floor_count = round(interior_count * (interior_count >= 360 ? 0.49 : 0.50))
		if(length(candidate_floor_lookup) < min_floor_count)
			candidate.errors += "coverage.too_sparse:[length(candidate_floor_lookup)]/[interior_count]"
	for(var/datum/world_edit_building_layout_room_contract/connection_contract as anything in context.program_contract.room_contracts)
		if(!istype(connection_contract) || !connection_contract.required || !connection_contract.counts_toward_target || !connection_contract.must_touch_route)
			continue
		if(!connected_rooms[connection_contract.id])
			candidate.errors += "route.room_unconnected:[connection_contract.id]"
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/score_building_layout_solver_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/score = 0
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(room_plan.contract_id)
		if(!istype(room_contract))
			continue
		score += room_contract.required ? 200 : 60
		score -= abs(room_plan.area() - room_contract.preferred_area)
	var/expected_route_turfs = max(12, length(candidate.room_plans) * 3)
	if(length(candidate.route_turfs) > expected_route_turfs)
		score -= (length(candidate.route_turfs) - expected_route_turfs) * 8
	var/expected_door_count = 1
	for(var/datum/world_edit_building_layout_room_plan/door_room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/door_room_contract = context.program_contract.get_room_contract(door_room_plan.contract_id)
		if(istype(door_room_contract) && door_room_contract.must_touch_route)
			expected_door_count++
	if(length(candidate.opening_plans) > expected_door_count)
		score -= (length(candidate.opening_plans) - expected_door_count) * 40
	score += score_building_layout_partition_quality(context, candidate)
	score -= count_building_layout_opposing_physical_route_door_pairs(context, candidate) * 450
	score -= count_building_layout_route_wall_canyon_tiles(context, candidate) * 35
	return score

/datum/world_edit_generator/building_layout/proc/score_building_layout_partition_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return 0
	var/score = 0
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan?.contract_id)
		if(!istype(room_contract))
			continue
		if(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_OPEN, WORLD_EDIT_BUILDING_PARTITION_SOFT))
			var/opening_score = count_building_layout_room_public_opening_tiles(context, candidate, room_plan.id)
			if(opening_score <= 0)
				score -= 1200
			else
				score += opening_score * 220
		if(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE))
			if(!building_layout_room_has_single_controlled_door(context, candidate, room_plan))
				score -= 600
	return score

/datum/world_edit_generator/building_layout/proc/building_layout_room_has_single_controlled_door(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan)
	if(!istype(candidate) || !istype(room_plan))
		return FALSE
	var/door_count = 0
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || !building_layout_opening_plan_emits_door_object(context, door_plan) || door_plan.kind == "main_exit")
			continue
		if(door_plan.from_room == room_plan.id || door_plan.to_room == room_plan.id)
			door_count += max(length(get_building_layout_opening_plan_turfs(door_plan)), 1)
	return door_count == 1

/datum/world_edit_generator/building_layout/proc/count_building_layout_opposing_physical_route_door_pairs(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(candidate))
		return 0
	var/list/physical_doors = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || !building_layout_opening_plan_emits_door_object(context, door_plan) || door_plan.kind == "main_exit")
			continue
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(istype(opening_turf))
				physical_doors += list(list("turf" = opening_turf, "dir" = door_plan.dir))
	var/pair_count = 0
	for(var/i in 1 to length(physical_doors))
		if(i >= length(physical_doors))
			continue
		var/list/a = physical_doors[i]
		for(var/j in i + 1 to length(physical_doors))
			var/list/b = physical_doors[j]
			if(building_layout_openings_are_opposite_route_pair(candidate, a["turf"], a["dir"], b["turf"], b["dir"]))
				pair_count++
	return pair_count

/datum/world_edit_generator/building_layout/proc/count_building_layout_route_wall_canyon_tiles(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return 0
	var/list/wall_lookup = length(candidate.solved_wall_lookup) ? candidate.solved_wall_lookup : candidate.wall_lookup
	var/canyon_count = 0
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf))
			continue
		var/turf/east_turf = get_step(route_turf, EAST)
		var/turf/west_turf = get_step(route_turf, WEST)
		var/turf/north_turf = get_step(route_turf, NORTH)
		var/turf/south_turf = get_step(route_turf, SOUTH)
		var/ns_canyon = wall_lookup[east_turf] && !building_layout_candidate_turf_is_opening(candidate, east_turf) && wall_lookup[west_turf] && !building_layout_candidate_turf_is_opening(candidate, west_turf)
		var/ew_canyon = wall_lookup[north_turf] && !building_layout_candidate_turf_is_opening(candidate, north_turf) && wall_lookup[south_turf] && !building_layout_candidate_turf_is_opening(candidate, south_turf)
		if(ns_canyon || ew_canyon)
			canyon_count++
	return canyon_count

/datum/world_edit_generator/building_layout/proc/building_layout_candidate_turf_is_opening(datum/world_edit_building_layout_candidate/candidate, turf/check_turf)
	if(!istype(candidate) || !istype(check_turf))
		return FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		if(istype(opening_plan) && (check_turf in get_building_layout_opening_plan_turfs(opening_plan)))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/score_building_layout_scene_quality(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return 0
	var/score = 0
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		var/member_count = istype(room_plan.scene_plan) ? length(room_plan.scene_plan.members) : 0
		var/min_member_count = get_building_layout_min_scene_members_for_room(room_plan.contract_id, room_plan.role, room_plan.area())
		if(min_member_count > 0 && member_count < min_member_count)
			score -= (min_member_count - member_count) * 300
		score += min(member_count, 6) * 18
	return score

/datum/world_edit_generator/building_layout/proc/solve_building_layout_room_allocation(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return FALSE
	if(length(candidate.room_plans))
		return TRUE
	if(!length(candidate.room_allocation_requests))
		candidate.errors += "room_allocation.none"
		return FALSE
	for(var/datum/world_edit_building_layout_room_allocation_request/allocation_request as anything in candidate.room_allocation_requests)
		if(!istype(allocation_request))
			continue
		if(!allocate_building_layout_room_from_request(context, candidate, allocation_request))
			candidate.errors += "room_allocation.failed:[allocation_request.id]"
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/allocate_building_layout_room_from_request(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_allocation_request/allocation_request)
	if(!istype(context) || !istype(candidate) || !istype(allocation_request))
		return FALSE
	var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(allocation_request.contract_id)
	if(!istype(room_contract))
		candidate.errors += "room_allocation.unknown_contract:[allocation_request.contract_id]"
		return FALSE
	var/min_x = min(allocation_request.x1, allocation_request.x2)
	var/max_x = max(allocation_request.x1, allocation_request.x2)
	var/min_y = min(allocation_request.y1, allocation_request.y2)
	var/max_y = max(allocation_request.y1, allocation_request.y2)
	var/slot_width = max(max_x - min_x + 1, 0)
	var/slot_height = max(max_y - min_y + 1, 0)
	var/list/dimensions = select_building_layout_room_dimensions_for_slot(context, allocation_request, room_contract, slot_width, slot_height)
	if(!islist(dimensions))
		candidate.errors += "room_allocation.no_fit:[allocation_request.id]"
		return FALSE
	var/room_width = round(text2num("[dimensions["width"]]") || 0)
	var/room_height = round(text2num("[dimensions["height"]]") || 0)
	if(room_width <= 0 || room_height <= 0)
		candidate.errors += "room_allocation.invalid_dimensions:[allocation_request.id]"
		return FALSE
	var/local_x1 = align_building_layout_room_axis(min_x, max_x, room_width, allocation_request.align_x)
	var/local_y1 = align_building_layout_room_axis(min_y, max_y, room_height, allocation_request.align_y)
	var/local_x2 = local_x1 + room_width - 1
	var/local_y2 = local_y1 + room_height - 1
	var/datum/world_edit_building_layout_room_plan/room_plan = add_building_layout_room_rect(context, candidate, allocation_request.id, allocation_request.contract_id, allocation_request.role, allocation_request.zone_id, local_x1, local_y1, local_x2, local_y2)
	return istype(room_plan)

/datum/world_edit_generator/building_layout/proc/select_building_layout_room_dimensions_for_slot(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_allocation_request/allocation_request, datum/world_edit_building_layout_room_contract/room_contract, slot_width, slot_height)
	if(!istype(context) || !istype(allocation_request) || !istype(room_contract) || slot_width <= 0 || slot_height <= 0)
		return null
	var/list/best_dimensions = null
	var/best_score = -999999999
	var/slot_area = slot_width * slot_height
	var/should_fill_slot = room_contract.required || length(room_contract.required_scene_kinds)
	var/target_area = should_fill_slot ? min(room_contract.max_area, slot_area) : min(room_contract.max_area, max(room_contract.preferred_area, round(slot_area * 0.80)))
	for(var/room_width in 1 to slot_width)
		for(var/room_height in 1 to slot_height)
			var/room_area = room_width * room_height
			if(!building_layout_room_dimensions_fit_contract(room_contract, room_width, room_height, room_area))
				continue
			if(!building_layout_room_dimensions_have_required_scene_fit(context, allocation_request, room_contract, room_width, room_height, room_area))
				continue
			var/score = 0
			score -= abs(room_area - target_area) * 4
			score -= abs(room_area - room_contract.preferred_area)
			score += min(room_width, room_height) * 3
			if(room_width == slot_width)
				score += 4
			if(room_height == slot_height)
				score += 4
			if(!islist(best_dimensions) || score > best_score)
				best_score = score
				best_dimensions = list("width" = room_width, "height" = room_height)
	return best_dimensions

/datum/world_edit_generator/building_layout/proc/building_layout_room_dimensions_fit_contract(datum/world_edit_building_layout_room_contract/room_contract, room_width, room_height, room_area)
	if(!istype(room_contract))
		return FALSE
	var/fits_min_dimensions = (room_width >= room_contract.min_width && room_height >= room_contract.min_height) || (room_width >= room_contract.min_height && room_height >= room_contract.min_width)
	var/fits_max_dimensions = (room_width <= room_contract.max_width && room_height <= room_contract.max_height) || (room_width <= room_contract.max_height && room_height <= room_contract.max_width)
	return room_area >= room_contract.min_area && room_area <= room_contract.max_area && fits_min_dimensions && fits_max_dimensions

/datum/world_edit_generator/building_layout/proc/building_layout_room_dimensions_have_required_scene_fit(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_allocation_request/allocation_request, datum/world_edit_building_layout_room_contract/room_contract, room_width, room_height, room_area)
	if(!istype(context) || !istype(allocation_request) || !istype(room_contract))
		return FALSE
	if(!length(room_contract.required_scene_kinds))
		return TRUE
	for(var/required_scene_kind as anything in room_contract.required_scene_kinds)
		var/has_fit = FALSE
		for(var/datum/world_edit_building_layout_scene_contract/scene_contract as anything in context.program_contract.scene_contracts)
			if(!building_layout_scene_contract_can_fit_room_allocation(context, allocation_request, room_contract, scene_contract, "[required_scene_kind]", room_width, room_height, room_area))
				continue
			has_fit = TRUE
			break
		if(!has_fit)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_scene_contract_can_fit_room_allocation(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_allocation_request/allocation_request, datum/world_edit_building_layout_room_contract/room_contract, datum/world_edit_building_layout_scene_contract/scene_contract, required_scene_kind, room_width, room_height, room_area)
	if(!istype(context) || !istype(allocation_request) || !istype(room_contract) || !istype(scene_contract))
		return FALSE
	if(length(scene_contract.allowed_programs) && !(context.program_contract?.id in scene_contract.allowed_programs))
		return FALSE
	if(scene_contract.scene_kind != "[required_scene_kind]")
		return FALSE
	if(length(scene_contract.allowed_room_roles) && !(room_contract.role in scene_contract.allowed_room_roles))
		return FALSE
	if(length(scene_contract.allowed_room_ids) && !(allocation_request.id in scene_contract.allowed_room_ids) && !(allocation_request.contract_id in scene_contract.allowed_room_ids))
		return FALSE
	return room_area >= scene_contract.min_room_area && room_width >= scene_contract.min_room_width && room_height >= scene_contract.min_room_height

/datum/world_edit_generator/building_layout/proc/align_building_layout_room_axis(slot_min, slot_max, room_size, alignment)
	var/span = max(slot_max - slot_min + 1, 1)
	var/clamped_size = clamp(room_size, 1, span)
	switch("[alignment]")
		if("min", "front", "left", "top")
			return slot_min
		if("max", "back", "right", "bottom")
			return slot_max - clamped_size + 1
	return slot_min + round((span - clamped_size) / 2)

/datum/world_edit_generator/building_layout/proc/add_building_layout_room_allocation_slot(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, room_id, contract_id, role, zone_id, relation_zone, x1, y1, x2, y2, align_x = "center", align_y = "center")
	if(!istype(context) || !istype(candidate))
		return null
	var/datum/world_edit_building_layout_room_allocation_request/allocation_request = new(room_id, contract_id, role, zone_id, relation_zone, x1, y1, x2, y2, align_x, align_y)
	candidate.add_room_allocation_request(allocation_request)
	return allocation_request

/datum/world_edit_generator/building_layout/proc/add_building_layout_room_rect(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, room_id, contract_id, role, zone_id, x1, y1, x2, y2)
	if(!istype(context) || !istype(candidate))
		return null
	var/datum/world_edit_building_layout_room_plan/room_plan = new(room_id, contract_id, role, zone_id)
	var/min_x = min(x1, x2)
	var/max_x = max(x1, x2)
	var/min_y = min(y1, y2)
	var/max_y = max(y1, y2)
	for(var/local_x in min_x to max_x)
		for(var/local_y in min_y to max_y)
			var/turf/room_turf = context.local_turf(local_x, local_y)
			if(istype(room_turf))
				room_plan.add_turf(room_turf)
	candidate.add_room_plan(room_plan)
	return room_plan

/datum/world_edit_generator/building_layout/proc/add_building_layout_door(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, door_id, kind, local_x, local_y, local_dir, from_room = "", to_room = "")
	if(!istype(context) || !istype(candidate))
		return
	var/turf/door_turf = context.local_turf(local_x, local_y)
	if(!istype(door_turf))
		return
	var/world_dir = context.local_dir_to_world_dir(local_dir)
	candidate.add_door_plan(new /datum/world_edit_building_layout_route_opening_plan(door_id, kind, door_turf, world_dir, from_room, to_room))

/datum/world_edit_generator/building_layout/proc/add_building_layout_window(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, window_id, local_x, local_y, local_dir, room_id = "")
	if(!istype(context) || !istype(candidate))
		return
	var/turf/window_turf = context.local_turf(local_x, local_y)
	if(!istype(window_turf))
		return
	var/world_dir = context.local_dir_to_world_dir(local_dir)
	candidate.add_window_plan(new /datum/world_edit_building_layout_route_opening_plan(window_id, "window", window_turf, world_dir, room_id, "outside"))

/datum/world_edit_generator/building_layout/proc/solve_building_layout_openings(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return FALSE
	build_building_layout_candidate_lookups(context, candidate)
	candidate.opening_plans.Cut()
	candidate.window_plans.Cut()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		room_plan.door_candidates.Cut()
		room_plan.window_candidates.Cut()
	if(!solve_building_layout_main_exit(context, candidate))
		candidate.errors += "door.main_exit_missing"
		return FALSE
	if(!length(candidate.room_connections))
		candidate.errors += "door.no_declared_connections"
		return FALSE
	var/list/opening_connections = list()
	for(var/datum/world_edit_building_layout_room_connection/connection as anything in candidate.room_connections)
		if(!istype(connection))
			continue
		if(connection.opening_policy == WORLD_EDIT_BUILDING_OPENING_NONE)
			continue
		var/list/from_lookup = get_building_layout_region_lookup(candidate, connection.from_node_id)
		var/list/to_lookup = get_building_layout_region_lookup(candidate, connection.to_node_id)
		if(!length(from_lookup) || !length(to_lookup))
			if(connection.required)
				candidate.errors += "door.connection_region_missing:[connection.id]"
			continue
		opening_connections += connection
	if(length(candidate.errors))
		return FALSE
	var/list/opening_search_state = list("expansions" = 0)
	if(!assign_building_layout_openings_bounded(context, candidate, opening_connections, 1, opening_search_state))
		report_building_layout_opening_search_failure(context, candidate, opening_connections, opening_search_state)
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/building_layout_candidate_route_lookup(datum/world_edit_building_layout_candidate/candidate)
	var/list/route_lookup = list()
	if(!istype(candidate))
		return route_lookup
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(istype(route_turf))
			route_lookup[route_turf] = TRUE
	return route_lookup

/datum/world_edit_generator/building_layout/proc/building_layout_candidate_room_floor_lookup(datum/world_edit_building_layout_candidate/candidate)
	var/list/room_lookup = list()
	if(!istype(candidate))
		return room_lookup
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		for(var/turf/room_turf as anything in room_plan.turfs)
			if(istype(room_turf))
				room_lookup[room_turf] = room_plan.id
	return room_lookup

/datum/world_edit_generator/building_layout/proc/building_layout_opening_turf_is_room_or_route(datum/world_edit_building_layout_candidate/candidate, turf/opening_turf)
	if(!istype(candidate) || !istype(opening_turf))
		return FALSE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(istype(room_plan) && room_plan.has_turf(opening_turf))
			return TRUE
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(route_turf == opening_turf)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/solve_building_layout_main_exit(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return FALSE
	var/entry_dir = state.geometry.requested_direction || state.placement_dir || NORTH
	if(!(entry_dir in GLOB.cardinals))
		entry_dir = NORTH
	var/center_x = (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2
	var/center_y = (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2
	var/turf/best_turf = null
	var/best_score = -999999999
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf))
			continue
		var/turf/boundary_turf = get_step(route_turf, entry_dir)
		if(!istype(boundary_turf) || !state.geometry.boundary_lookup[boundary_turf] || !state.geometry.footprint_lookup[boundary_turf])
			continue
		if(!boundary_turf_has_outside_dir(boundary_turf, state.geometry.footprint_lookup, entry_dir))
			continue
		if(is_corner_boundary_turf(boundary_turf, state.geometry.footprint_lookup))
			continue
		var/score = 100000 - (get_lateral_distance_for_dir(boundary_turf, center_x, center_y, entry_dir) * 25)
		score += get_projection_for_dir(boundary_turf, center_x, center_y, entry_dir) * 10
		if(!istype(best_turf) || score > best_score)
			best_turf = boundary_turf
			best_score = score
	if(!istype(best_turf))
		return FALSE
	candidate.add_door_plan(new /datum/world_edit_building_layout_route_opening_plan("front_entry", "main_exit", best_turf, entry_dir, "", "route"))
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_door_plan_has_valid_shared_wall(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/door_plan)
	if(!istype(context) || !istype(candidate) || !istype(door_plan) || !istype(door_plan.opening_turf))
		return FALSE
	if(door_plan.kind == "main_exit")
		return building_layout_main_exit_has_valid_boundary(context, candidate, door_plan)
	var/datum/world_edit_building_layout_room_plan/room_plan = candidate.get_room_plan(door_plan.from_room)
	if(!istype(room_plan))
		room_plan = candidate.get_room_plan(door_plan.to_room)
	var/list/endpoint_lookups = get_building_layout_opening_endpoint_lookups(context, candidate, door_plan.from_room, door_plan.to_room, door_plan.id)
	var/list/from_lookup = endpoint_lookups["from_lookup"]
	var/list/to_lookup = endpoint_lookups["to_lookup"]
	if(!length(from_lookup) || !length(to_lookup))
		if(istype(room_plan))
			from_lookup = room_plan.turf_lookup
			to_lookup = get_building_layout_region_lookup(candidate, "route")
		else
			return FALSE
	for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
		if(!building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_plan.dir))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_main_exit_has_valid_boundary(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/door_plan)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !istype(door_plan) || !istype(door_plan.opening_turf))
		return FALSE
	if(!state.geometry.boundary_lookup[door_plan.opening_turf])
		return FALSE
	if(!boundary_turf_has_outside_dir(door_plan.opening_turf, state.geometry.footprint_lookup, door_plan.dir))
		return FALSE
	var/turf/inside_turf = get_step(door_plan.opening_turf, turn(door_plan.dir, 180))
	var/list/route_lookup = building_layout_candidate_route_lookup(candidate)
	return route_lookup[inside_turf] ? TRUE : FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_route_turfs_are_connected(datum/world_edit_building_layout_candidate/candidate)
	if(!istype(candidate) || !length(candidate.route_turfs))
		return FALSE
	var/list/route_lookup = building_layout_candidate_route_lookup(candidate)
	var/list/open = list(candidate.route_turfs[1])
	var/list/seen = list()
	while(length(open))
		var/turf/current = open[1]
		open.Cut(1, 2)
		if(!istype(current) || seen[current])
			continue
		seen[current] = TRUE
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(current, check_dir)
			if(route_lookup[nearby_turf] && !seen[nearby_turf])
				open += nearby_turf
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(istype(route_turf) && !seen[route_turf])
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/solve_building_layout_windows(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return FALSE
	building_layout_seed_state_room_zones_for_policy(context, candidate)
	candidate.window_plans.Cut()
	for(var/datum/world_edit_building_layout_room_plan/reset_room as anything in candidate.room_plans)
		if(istype(reset_room))
			reset_room.window_candidates.Cut()
	var/raw_window_density = null
	if(istype(context.state))
		raw_window_density = context.state.config["window_density"]
	var/window_density = clamp(round(text2num("[raw_window_density]") || 0), 0, 100)
	var/list/window_lookup = list()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(room_plan.contract_id)
		var/policy = istype(room_contract) ? "[room_contract.exterior_window_policy]" : "optional"
		if(policy == "forbidden")
			continue
		if(!(policy in list("required", "desired")))
			continue
		if(window_density <= 0 && policy != "required")
			continue
		if(!(room_plan.role in list("entry_common", "dining", "sleeping")) && !(policy in list("required", "desired")))
			continue
		var/list/window_candidate = select_building_layout_room_window_candidate(context, candidate, room_plan, window_lookup)
		if(!islist(window_candidate))
			if(policy == "required")
				candidate.errors += "window.required_missing:[room_plan.id]"
			continue
		var/turf/window_turf = window_candidate["window_turf"]
		var/window_dir = window_candidate["dir"]
		candidate.add_window_plan(new /datum/world_edit_building_layout_route_opening_plan("[room_plan.id]_window", "window", window_turf, window_dir, room_plan.id, "outside"))
		window_lookup[window_turf] = TRUE
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/select_building_layout_room_window_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, list/window_lookup)
	var/list/door_lookup = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(istype(opening_turf))
				door_lookup[opening_turf] = TRUE
	var/list/best = null
	var/best_score = -999999999
	var/center_x = round((room_plan.x1 + room_plan.x2) / 2)
	var/center_y = round((room_plan.y1 + room_plan.y2) / 2)
	for(var/turf/room_turf as anything in room_plan.turfs)
		if(!istype(room_turf))
			continue
		for(var/check_dir in GLOB.cardinals)
			var/turf/window_turf = get_step(room_turf, check_dir)
			if(!istype(window_turf) || !context.state.geometry.boundary_lookup[window_turf] || !context.state.geometry.footprint_lookup[window_turf])
				continue
			if(door_lookup[window_turf] || (islist(window_lookup) && window_lookup[window_turf]))
				continue
			if(is_corner_boundary_turf(window_turf, context.state.geometry.footprint_lookup))
				continue
			if(!boundary_turf_has_outside_dir(window_turf, context.state.geometry.footprint_lookup, check_dir))
				continue
			if(!can_place_building_window_for_boundary_turf(context.state, window_turf))
				continue
			var/turf/interior_turf = get_step(window_turf, turn(check_dir, 180))
			if(room_plan.scene_plan?.occupied_turfs[interior_turf] || room_plan.scene_plan?.clearance_turfs[interior_turf])
				continue
			var/score = 10000 - ((abs(window_turf.x - center_x) + abs(window_turf.y - center_y)) * 35)
			if(room_plan.role in list("entry_common", "dining"))
				score += 300
			if(room_plan.role == "sleeping")
				score += 80
			if(!islist(best) || score > best_score)
				best = list("window_turf" = window_turf, "dir" = check_dir, "score" = score)
				best_score = score
	if(islist(best))
		room_plan.window_candidates += list(best)
	return best

/datum/world_edit_generator/building_layout/proc/building_layout_seed_state_room_zones_for_policy(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		for(var/turf/room_turf as anything in room_plan.turfs)
			if(istype(room_turf))
				state.add_zone(room_turf, room_plan.zone_id)

/datum/world_edit_generator/building_layout/proc/building_layout_window_plan_obeys_policy(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_opening_plan/window_plan)
	if(!istype(context) || !istype(candidate) || !istype(window_plan) || !istype(window_plan.opening_turf))
		return FALSE
	var/datum/world_edit_building_layout_state/state = context.state
	if(!istype(state) || !state.geometry.boundary_lookup[window_plan.opening_turf] || !state.geometry.footprint_lookup[window_plan.opening_turf])
		return FALSE
	if(!boundary_turf_has_outside_dir(window_plan.opening_turf, state.geometry.footprint_lookup, window_plan.dir))
		return FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(opening_turf == window_plan.opening_turf)
				return FALSE
	var/datum/world_edit_building_layout_room_plan/room_plan = candidate.get_room_plan(window_plan.from_room)
	if(!istype(room_plan))
		return FALSE
	var/turf/interior_turf = get_step(window_plan.opening_turf, turn(window_plan.dir, 180))
	if(!room_plan.has_turf(interior_turf))
		return FALSE
	var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(room_plan.contract_id)
	if(istype(room_contract) && room_contract.exterior_window_policy == "forbidden")
		return FALSE
	return TRUE


/datum/world_edit_generator/building_layout/proc/add_building_layout_cluster_module(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_cluster_spec/cluster_spec, list/occupied_lookup, remaining_budget)
	if(!istype(cluster_spec) || remaining_budget <= 0)
		return 0
	var/list/curated_modules = get_building_layout_curated_scene_modules(context, room_plan, cluster_spec)
	if(length(curated_modules))
		return add_building_layout_curated_scene_modules(context, candidate, room_plan, scene_plan, cluster_spec, curated_modules, occupied_lookup, remaining_budget)
	if(cluster_spec.required)
		context.state?.add_stage_report("layout_curated_module", "failed", "required_curated_module_missing", list(
			"candidate_id" = candidate.id,
			"room_id" = room_plan.id,
			"cluster_id" = cluster_spec.id,
			"compact_substitute_id" = cluster_spec.compact_substitute_id,
		))
	return 0

/datum/world_edit_generator/building_layout/proc/get_building_layout_curated_scene_modules(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/cluster_spec)
	var/list/result = list()
	if(!istype(context?.state) || !istype(room_plan) || !istype(cluster_spec))
		return result
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	var/required_module_id = ""
	if(cluster_spec.required)
		var/datum/world_edit_building_zone_spec/zone_spec = context.state.semantic_plan?.get_zone_spec(room_plan.zone_id)
		var/list/required_footprint = get_building_layout_required_group_module_footprint(context.state, zone_spec, cluster_spec)
		required_module_id = "[required_footprint?["module_id"] || ""]"
	for(var/datum/world_edit_building_placement_module/module as anything in catalog.get_for_cluster(cluster_spec))
		if(!istype(module) || !module.curated)
			continue
		if(length(required_module_id) && module.id != required_module_id)
			continue
		if(length(module.allowed_programs) && !(context.program_contract?.id in module.allowed_programs))
			continue
		if(length(module.allowed_zone_ids) && !(room_plan.zone_id in module.allowed_zone_ids))
			continue
		if(length(module.allowed_room_roles) && !(room_plan.role in module.allowed_room_roles))
			continue
		result += module
	return result

/datum/world_edit_generator/building_layout/proc/add_building_layout_curated_scene_modules(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_cluster_spec/cluster_spec, list/modules, list/occupied_lookup, remaining_budget)
	if(!islist(modules) || !length(modules) || !islist(occupied_lookup))
		return 0
	context.state.config["layout_curated_candidate_reject_counts"] = list()
	var/target_count = min(max(cluster_spec.min_count, 1), remaining_budget, max(1, round(room_plan.area() / 2)))
	var/placed = 0
	var/placed_credit = 0
	var/module_index = 0
	while(placed_credit < target_count && placed < remaining_budget && module_index < WORLD_EDIT_BUILDING_MAX_MODULE_ANCHORS)
		var/list/module_candidate = select_building_layout_curated_scene_module_candidate(context, candidate, room_plan, cluster_spec, modules, occupied_lookup, remaining_budget - placed, target_count - placed_credit)
		if(!islist(module_candidate))
			if(cluster_spec.required)
				var/list/module_ids = list()
				var/list/wall_coords = list()
				var/list/opening_coords = list()
				var/list/window_coords = list()
				var/clear_turf_count = 0
				var/wall_turf_count = 0
				var/list/debug_blocked_lookup = build_building_layout_scene_blocked_lookup(context, candidate, occupied_lookup)
				for(var/turf/debug_turf as anything in room_plan.turfs)
					if(building_layout_scene_turf_clear(context, candidate, room_plan, debug_turf, debug_blocked_lookup, occupied_lookup))
						clear_turf_count++
						if(length(get_building_layout_scene_adjacent_wall_dirs(context, candidate, debug_turf)))
							wall_turf_count++
							wall_coords += "[debug_turf.x],[debug_turf.y],[debug_turf.z]"
				for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
					if(istype(opening_plan) && (opening_plan.from_room == room_plan.id || opening_plan.to_room == room_plan.id))
						for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(opening_plan))
							if(istype(opening_turf))
								opening_coords += "[opening_turf.x],[opening_turf.y],[opening_turf.z]:dir=[opening_plan.dir]"
				for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
					if(istype(window_plan?.opening_turf) && window_plan.from_room == room_plan.id)
						window_coords += "[window_plan.opening_turf.x],[window_plan.opening_turf.y],[window_plan.opening_turf.z]:dir=[window_plan.dir]"
				for(var/datum/world_edit_building_placement_module/failed_module as anything in modules)
					if(istype(failed_module))
						module_ids += failed_module.id
				context.state?.add_stage_report("layout_curated_module", "failed", "no_atomic_candidate", list(
					"candidate_id" = candidate.id,
					"room_id" = room_plan.id,
					"cluster_id" = cluster_spec.id,
					"room_area" = room_plan.area(),
					"placed" = placed,
					"target" = target_count,
					"remaining_budget" = remaining_budget - placed,
					"occupied_count" = length(occupied_lookup),
					"clear_turf_count" = clear_turf_count,
					"wall_turf_count" = wall_turf_count,
					"wall_coords" = wall_coords,
					"opening_coords" = opening_coords,
					"window_coords" = window_coords,
					"module_ids" = module_ids,
					"reject_counts" = islist(context.state?.config["layout_curated_candidate_reject_counts"]) ? context.state.config["layout_curated_candidate_reject_counts"].Copy() : list(),
				))
			break
		var/datum/world_edit_building_placement_module/module = module_candidate["module"]
		var/list/members = module_candidate["members"]
		var/module_credit = round(text2num("[module_candidate["credit_count"]]") || 0)
		if(!istype(module) || !length(members) || module_credit <= 0)
			break
		module_index++
		var/module_instance_id = "[scene_plan.id]_[cluster_spec.id]_[module_index]"
		var/turf/module_origin = module_candidate["origin"]
		var/module_dir = module_candidate["module_dir"]
		for(var/list/member as anything in members)
			var/turf/member_turf = member["turf"]
			var/member_is_major = cluster_spec.required ? TRUE : FALSE
			scene_plan.add_member(member["slot"], member["category"], member_turf, member["dir"], member["category"], member["wall_mounted"], member_is_major, cluster_spec)
			var/list/scene_member = scene_plan.members[length(scene_plan.members)]
			scene_member["wall_dir"] = member["wall_dir"]
			scene_member["front_dir"] = member["front_dir"]
			scene_member["interaction_dir"] = member["interaction_dir"]
			scene_member["placement_module_id"] = module.id
			scene_member["placement_module_recipe_id"] = module.curated_recipe_id
			scene_member["placement_module_wall_required"] = module.wall_required ? TRUE : FALSE
			scene_member["placement_module_instance_id"] = module_instance_id
			scene_member["placement_module_member_count"] = length(members)
			scene_member["placement_module_repeat_group"] = module.repeat_group
			scene_member["placement_module_origin"] = module_origin
			scene_member["placement_module_dir"] = module_dir
			occupied_lookup[member_turf] = TRUE
			placed++
		for(var/turf/clearance_turf as anything in module_candidate["clearance_turfs"])
			if(!istype(clearance_turf) || occupied_lookup[clearance_turf])
				continue
			scene_plan.clearance_turfs += clearance_turf
			scene_plan.no_furniture_lookup[clearance_turf] = TRUE
			occupied_lookup[clearance_turf] = TRUE
		for(var/turf/path_turf as anything in module_candidate["protected_path"])
			if(!istype(path_turf) || occupied_lookup[path_turf])
				continue
			scene_plan.negative_space_turfs += path_turf
			scene_plan.no_furniture_lookup[path_turf] = TRUE
			occupied_lookup[path_turf] = TRUE
		placed_credit += module_credit
	return placed

/datum/world_edit_generator/building_layout/proc/select_building_layout_curated_scene_module_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/cluster_spec, list/modules, list/occupied_lookup, remaining_budget, remaining_credit)
	var/list/best_candidate = null
	var/best_score = -999999999
	for(var/datum/world_edit_building_placement_module/module as anything in modules)
		if(!istype(module) || !length(module.member_specs) || length(module.member_specs) > remaining_budget)
			continue
		var/module_credit = get_building_layout_curated_module_group_credit(module, cluster_spec)
		// A curated recipe must fit the authored group capacity. This is what keeps
		// an explicit compact substitute from resolving back to the parent's large
		// recipe merely because both identities share a count/catalog key.
		if(module_credit <= 0 || module_credit > max(cluster_spec.max_count, max(cluster_spec.min_count, 1)))
			continue
		var/evaluated = 0
		var/room_turf_count = length(room_plan.turfs)
		var/anchor_sample_count = min(room_turf_count, WORLD_EDIT_BUILDING_MAX_MODULE_ANCHORS)
		var/list/prefilter_blocked_lookup = build_building_layout_scene_blocked_lookup(context, candidate, occupied_lookup)
		for(var/anchor_step in 1 to anchor_sample_count)
			var/anchor_index = 1 + round(((anchor_step - 1) * max(room_turf_count - 1, 0)) / max(anchor_sample_count - 1, 1))
			var/turf/origin = room_plan.turfs[anchor_index]
			for(var/dir_to_use as anything in GLOB.cardinals)
				if(!building_layout_curated_module_geometry_prefilter(context, candidate, room_plan, cluster_spec, module, origin, dir_to_use, occupied_lookup, prefilter_blocked_lookup))
					continue
				if(evaluated >= WORLD_EDIT_BUILDING_MAX_MODULE_CANDIDATES)
					break
				evaluated++
				var/list/module_candidate = build_building_layout_curated_scene_module_candidate(context, candidate, room_plan, cluster_spec, module, origin, dir_to_use, occupied_lookup, prefilter_blocked_lookup)
				if(!islist(module_candidate))
					continue
				module_candidate["credit_count"] = module_credit
				var/score = round(text2num("[module_candidate["score"]]") || 0)
				if(!islist(best_candidate) || score > best_score)
					best_candidate = module_candidate
					best_score = score
			if(evaluated >= WORLD_EDIT_BUILDING_MAX_MODULE_CANDIDATES)
				break
	return best_candidate

/datum/world_edit_generator/building_layout/proc/building_layout_curated_module_geometry_prefilter(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_placement_module/module, turf/origin, dir_to_use, list/occupied_lookup, list/blocked_lookup = null)
	if(!istype(context) || !istype(candidate) || !istype(room_plan) || !istype(cluster_spec) || !istype(module) || !istype(origin))
		return FALSE
	if(!islist(blocked_lookup))
		blocked_lookup = build_building_layout_scene_blocked_lookup(context, candidate, occupied_lookup)
	var/list/member_lookup = list()
	var/list/common_wall_dirs = null
	for(var/list/member as anything in module.member_specs)
		if(!islist(member))
			record_building_layout_curated_candidate_reject(context, "prefilter_member_invalid")
			return FALSE
		var/turf/member_turf = get_template_offset_turf(origin, dir_to_use, member["dx"], member["dy"])
		if(!building_layout_scene_turf_clear(context, candidate, room_plan, member_turf, blocked_lookup, member_lookup))
			record_building_layout_curated_candidate_reject(context, "prefilter_member_not_clear")
			return FALSE
		var/primary_wall_only = module.curated_recipe_id in list("nook_pair")
		var/needs_wall = (module.wall_required || cluster_spec.wall_required) && (!primary_wall_only || GLOB.world_edit_helpers.parse_bool(member["major"]))
		if(needs_wall)
			var/list/member_wall_dirs = get_building_layout_scene_adjacent_wall_dirs(context, candidate, member_turf)
			if(!length(member_wall_dirs))
				record_building_layout_curated_candidate_reject(context, "prefilter_wall_missing")
				return FALSE
			if(!islist(common_wall_dirs))
				common_wall_dirs = member_wall_dirs.Copy()
			else
				for(var/existing_dir as anything in common_wall_dirs.Copy())
					if(!(existing_dir in member_wall_dirs))
						common_wall_dirs -= existing_dir
			if(!length(common_wall_dirs))
				record_building_layout_curated_candidate_reject(context, "prefilter_wall_axis_mismatch")
				return FALSE
		member_lookup[member_turf] = TRUE
	if(length(common_wall_dirs) && !(turn(dir_to_use, 180) in common_wall_dirs))
		record_building_layout_curated_candidate_reject(context, "prefilter_frontage_dir_mismatch")
		return FALSE
	for(var/offset_key as anything in get_building_module_clearance_offsets(module))
		var/list/parts = splittext("[offset_key]", ",")
		if(length(parts) < 2)
			continue
		var/turf/clearance_turf = get_template_offset_turf(origin, dir_to_use, text2num(parts[1]), text2num(parts[2]))
		if(member_lookup[clearance_turf])
			continue
		if(!building_layout_scene_turf_clear(context, candidate, room_plan, clearance_turf, blocked_lookup, member_lookup))
			record_building_layout_curated_candidate_reject(context, "prefilter_module_clearance")
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_curated_scene_module_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_placement_module/module, turf/origin, dir_to_use, list/occupied_lookup, list/blocked_lookup = null)
	if(!istype(context) || !istype(candidate) || !istype(room_plan) || !istype(cluster_spec) || !istype(module) || !istype(origin))
		return null
	if(!islist(blocked_lookup))
		blocked_lookup = build_building_layout_scene_blocked_lookup(context, candidate, occupied_lookup)
	var/list/member_lookup = list()
	var/list/member_plans = list()
	var/list/clearance_turfs = list()
	var/turf/focus_turf = null
	var/module_wall_dir = null
	var/list/common_wall_dirs = null
	for(var/list/wall_member as anything in module.member_specs)
		if(!islist(wall_member))
			return null
		var/primary_wall_only = module.curated_recipe_id in list("nook_pair")
		var/needs_wall = (module.wall_required || cluster_spec.wall_required) && (!primary_wall_only || GLOB.world_edit_helpers.parse_bool(wall_member["major"]))
		if(!needs_wall)
			continue
		var/turf/wall_member_turf = get_template_offset_turf(origin, dir_to_use, wall_member["dx"], wall_member["dy"])
		var/list/member_wall_dirs = get_building_layout_scene_adjacent_wall_dirs(context, candidate, wall_member_turf)
		if(!length(member_wall_dirs))
			record_building_layout_curated_candidate_reject(context, "wall_missing")
			return null
		if(!islist(common_wall_dirs))
			common_wall_dirs = member_wall_dirs.Copy()
		else
			for(var/existing_dir as anything in common_wall_dirs.Copy())
				if(!(existing_dir in member_wall_dirs))
					common_wall_dirs -= existing_dir
		if(!length(common_wall_dirs))
			record_building_layout_curated_candidate_reject(context, "wall_axis_mismatch")
			return null
	if(length(common_wall_dirs))
		var/expected_wall_dir = turn(dir_to_use, 180)
		if(!(expected_wall_dir in common_wall_dirs))
			record_building_layout_curated_candidate_reject(context, "frontage_dir_mismatch")
			return null
		module_wall_dir = expected_wall_dir
	for(var/list/member as anything in module.member_specs)
		if(!islist(member))
			return null
		var/turf/member_turf = get_template_offset_turf(origin, dir_to_use, member["dx"], member["dy"])
		if(!building_layout_scene_turf_clear(context, candidate, room_plan, member_turf, blocked_lookup, member_lookup))
			record_building_layout_curated_candidate_reject(context, "member_not_clear")
			return null
		var/slot = "[member["slot"]]"
		var/category = "[member["category"]]"
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(slot, category)
		var/primary_wall_only = module.curated_recipe_id in list("nook_pair")
		var/needs_wall = (module.wall_required || cluster_spec.wall_required) && (!primary_wall_only || GLOB.world_edit_helpers.parse_bool(member["major"]))
		var/wall_dir = null
		var/member_dir = dir_to_use
		if(needs_wall)
			wall_dir = module_wall_dir
			member_dir = resolve_building_place_rule_dir(wall_dir, place_rule.dir_mode)
			if(!member_dir)
				record_building_layout_curated_candidate_reject(context, "dir_missing")
				return null
		if(!building_layout_scene_place_rule_clearance_ok(context, candidate, room_plan, member_turf, member_dir, wall_dir, place_rule, blocked_lookup, member_lookup))
			record_building_layout_curated_candidate_reject(context, "member_clearance")
			return null
		member_lookup[member_turf] = TRUE
		if(!istype(focus_turf) && GLOB.world_edit_helpers.parse_bool(member["major"]))
			focus_turf = member_turf
		member_plans += list(list(
			"slot" = slot,
			"category" = category,
			"turf" = member_turf,
			"dir" = member_dir,
			"wall_dir" = wall_dir,
			"front_dir" = wall_dir ? turn(wall_dir, 180) : dir_to_use,
			"interaction_dir" = wall_dir ? turn(wall_dir, 180) : dir_to_use,
			"wall_mounted" = needs_wall ? TRUE : FALSE,
			"major" = member["major"] ? TRUE : FALSE,
		))
	for(var/offset_key as anything in get_building_module_clearance_offsets(module))
		var/list/parts = splittext("[offset_key]", ",")
		if(length(parts) < 2)
			continue
		var/turf/clearance_turf = get_template_offset_turf(origin, dir_to_use, text2num(parts[1]), text2num(parts[2]))
		if(member_lookup[clearance_turf])
			continue
		if(!building_layout_scene_turf_clear(context, candidate, room_plan, clearance_turf, blocked_lookup, member_lookup))
			var/clearance_sample_count = round(text2num("[context.state.config["layout_curated_clearance_reject_sample_count"]]") || 0)
			if(clearance_sample_count < 12)
				context.state.config["layout_curated_clearance_reject_sample_count"] = clearance_sample_count + 1
				context.state.add_stage_report("layout_curated_clearance_reject", "failed", "curated module clearance turf is unavailable", list(
					"candidate_id" = candidate.id,
					"room_id" = room_plan.id,
					"module_id" = module.id,
					"origin_x" = origin.x,
					"origin_y" = origin.y,
					"module_dir" = dir_to_use,
					"clearance_x" = clearance_turf?.x,
					"clearance_y" = clearance_turf?.y,
					"inside_room" = room_plan.has_turf(clearance_turf) ? 1 : 0,
					"blocked" = blocked_lookup[clearance_turf] ? 1 : 0,
					"member_conflict" = member_lookup[clearance_turf] ? 1 : 0,
				))
			record_building_layout_curated_candidate_reject(context, "module_clearance")
			return null
		clearance_turfs += clearance_turf
	if(!istype(focus_turf) && length(member_plans))
		focus_turf = member_plans[1]["turf"]
	var/list/protected_path = list()
	var/list/path_blocked_lookup = islist(occupied_lookup) ? occupied_lookup.Copy() : list()
	for(var/turf/member_turf as anything in member_lookup)
		path_blocked_lookup[member_turf] = TRUE
	var/focus_path_available = FALSE
	for(var/turf/door_turf as anything in get_building_layout_room_door_turfs(candidate, room_plan.id))
		var/turf/start_turf = get_building_layout_room_door_inside_turf(candidate, room_plan, door_turf)
		var/list/door_path = build_building_layout_room_internal_path(room_plan, start_turf, focus_turf, path_blocked_lookup)
		if(!islist(door_path) || (!length(door_path) && start_turf != focus_turf))
			continue
		// The bounded room BFS already excludes blocked intermediate cells. Its
		// start is deliberately reserved as interaction-lane negative space, so
		// rechecking the returned path against the same lookup would reject every
		// otherwise valid module at the doorway itself.
		for(var/turf/path_turf as anything in door_path)
			if(istype(path_turf) && path_turf != focus_turf)
				protected_path[path_turf] = TRUE
		focus_path_available = TRUE
		break
	if(!focus_path_available)
		record_building_layout_curated_candidate_reject(context, "focus_path_blocked")
		return null
	var/score = module.priority + length(member_plans) * 30 + score_building_layout_scene_turf(context, candidate, room_plan, origin, room_plan.scene_kind || room_plan.role)
	return list("module" = module, "members" = member_plans, "origin" = origin, "module_dir" = dir_to_use, "clearance_turfs" = clearance_turfs, "protected_path" = protected_path, "score" = score)

/datum/world_edit_generator/building_layout/proc/record_building_layout_curated_candidate_reject(datum/world_edit_building_layout_context/context, reason)
	if(!istype(context?.state))
		return
	var/list/reject_counts = context.state.config["layout_curated_candidate_reject_counts"]
	if(!islist(reject_counts))
		reject_counts = list()
		context.state.config["layout_curated_candidate_reject_counts"] = reject_counts
	reject_counts["[reason]"] = (reject_counts["[reason]"] || 0) + 1


/datum/world_edit_generator/building_layout/proc/building_layout_global_scene_slot_key(scene_slot)
	switch("[scene_slot]")
		if("dining_focal", "lounge_focal")
			return "public_focal"
	return "[scene_slot]"


/datum/world_edit_generator/building_layout/proc/building_layout_scene_members_clear_candidate_paths(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(candidate) || !istype(scene_plan))
		return FALSE
	var/list/route_lookup = list()
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(istype(route_turf))
			route_lookup[route_turf] = TRUE
	var/list/door_clearance_lookup = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(!istype(opening_turf))
				continue
			door_clearance_lookup[opening_turf] = TRUE
			door_clearance_lookup[get_step(opening_turf, door_plan.dir)] = TRUE
			door_clearance_lookup[get_step(opening_turf, turn(door_plan.dir, 180))] = TRUE
	for(var/list/member as anything in scene_plan.members)
		var/turf/member_turf = member["turf"]
		if(!istype(member_turf) || route_lookup[member_turf] || door_clearance_lookup[member_turf])
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_scene_slots_within_contract(datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_layout_scene_contract/scene_contract)
	if(!istype(scene_plan) || !istype(scene_contract))
		return FALSE
	for(var/scene_slot as anything in scene_plan.scene_slot_counts)
		var/count = round(text2num("[scene_plan.scene_slot_counts[scene_slot]]") || 0)
		var/limit = round(text2num("[scene_contract.scene_slot_limits[scene_slot]]") || 0)
		if(limit > 0 && count > limit)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_scene_members_inside_room(datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(room_plan) || !istype(scene_plan))
		return FALSE
	var/list/seen = list()
	for(var/list/member as anything in scene_plan.members)
		var/turf/member_turf = member["turf"]
		if(!room_plan.has_turf(member_turf) || seen[member_turf])
			return FALSE
		seen[member_turf] = TRUE
	return TRUE

/datum/world_edit_generator/building_layout/proc/add_building_layout_scene_blocked_turf(list/blocked_lookup, turf/target_turf)
	if(islist(blocked_lookup) && istype(target_turf))
		blocked_lookup[target_turf] = TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_floor_lookup(datum/world_edit_building_layout_candidate/candidate)
	var/list/floor_lookup = list()
	if(!istype(candidate))
		return floor_lookup
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		for(var/turf/room_turf as anything in room_plan.turfs)
			if(istype(room_turf))
				floor_lookup[room_turf] = TRUE
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(istype(route_turf))
			floor_lookup[route_turf] = TRUE
	for(var/turf/owner_aisle_turf as anything in candidate.owner_aisle_turfs)
		if(istype(owner_aisle_turf))
			floor_lookup[owner_aisle_turf] = TRUE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(istype(opening_turf))
				floor_lookup[opening_turf] = TRUE
	return floor_lookup

/datum/world_edit_generator/building_layout/proc/build_building_layout_window_lookup(datum/world_edit_building_layout_candidate/candidate)
	var/list/window_lookup = list()
	if(!istype(candidate))
		return window_lookup
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(istype(window_plan) && istype(window_plan.opening_turf))
			window_lookup[window_plan.opening_turf] = TRUE
	return window_lookup

/datum/world_edit_generator/building_layout/proc/ensure_building_layout_candidate_wall_model(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context?.state) || !istype(candidate))
		return FALSE
	if(candidate.wall_model_ready)
		return TRUE
	var/list/floor_lookup = build_building_layout_candidate_floor_lookup(candidate)
	var/list/wall_lookup = list()
	var/list/internal_wall_turfs = list()
	for(var/turf/footprint_turf as anything in context.state.geometry.footprint)
		if(!istype(footprint_turf) || floor_lookup[footprint_turf])
			continue
		if(context.state.geometry.boundary_lookup[footprint_turf])
			wall_lookup[footprint_turf] = TRUE
			continue
		if(candidate.reserved_partition_wall_lookup[footprint_turf])
			wall_lookup[footprint_turf] = TRUE
			internal_wall_turfs += footprint_turf
	candidate.solved_wall_lookup = wall_lookup
	candidate.solved_internal_wall_turfs = internal_wall_turfs
	candidate.wall_turfs.Cut()
	for(var/turf/wall_turf as anything in wall_lookup)
		if(istype(wall_turf))
			candidate.wall_turfs += wall_turf
	candidate.wall_cleanup_report = list(
		"removed_unmapped_wall_tile_count" = 0,
		"removed_single_sided_wall_tile_count" = 0,
		"removed_wall_tile_count" = 0,
		"removed_wall_component_count" = 0,
	)
	candidate.wall_model_ready = TRUE
	if(!length(candidate.solved_wall_lookup))
		candidate.errors += "wall_model.empty"
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_scene_blocked_lookup(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/occupied_lookup = null)
	var/list/blocked_lookup = list()
	if(!istype(context) || !istype(candidate))
		return blocked_lookup
	for(var/turf/route_turf as anything in candidate.route_turfs)
		add_building_layout_scene_blocked_turf(blocked_lookup, route_turf)
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(!istype(opening_turf))
				continue
			add_building_layout_scene_blocked_turf(blocked_lookup, opening_turf)
			add_building_layout_scene_blocked_turf(blocked_lookup, get_step(opening_turf, door_plan.dir))
			add_building_layout_scene_blocked_turf(blocked_lookup, get_step(opening_turf, turn(door_plan.dir, 180)))
			if(!door_plan.emits_door_object && door_plan.kind != "main_exit")
				continue
			var/inward_dir = turn(door_plan.dir, 180)
			var/list/door_cone_profile = (door_plan.kind == "main_exit" || context.state.geometry.boundary_lookup[opening_turf]) ? get_building_door_cone_profile(context.state) : get_building_internal_door_cone_profile(context.state)
			if(!length(door_cone_profile))
				continue
			for(var/depth_index in 0 to length(door_cone_profile) - 1)
				var/turf/base_turf = opening_turf
				if(depth_index > 0)
					for(var/depth_step in 1 to depth_index)
						base_turf = get_step(base_turf, inward_dir)
				if(!istype(base_turf))
					break
				add_building_layout_scene_blocked_turf(blocked_lookup, base_turf)
				var/lateral_steps = round(text2num("[door_cone_profile[depth_index + 1]]") || 0)
				for(var/side_dir as anything in list(turn(inward_dir, 90), turn(inward_dir, -90)))
					var/turf/side_turf = base_turf
					for(var/side_step in 1 to lateral_steps)
						side_turf = get_step(side_turf, side_dir)
						add_building_layout_scene_blocked_turf(blocked_lookup, side_turf)
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(!istype(window_plan) || !istype(window_plan.opening_turf))
			continue
		add_building_layout_scene_blocked_turf(blocked_lookup, window_plan.opening_turf)
		add_building_layout_scene_blocked_turf(blocked_lookup, get_step(window_plan.opening_turf, turn(window_plan.dir, 180)))
	if(islist(occupied_lookup))
		for(var/turf/occupied_turf as anything in occupied_lookup)
			add_building_layout_scene_blocked_turf(blocked_lookup, occupied_turf)
	return blocked_lookup

/datum/world_edit_generator/building_layout/proc/building_layout_scene_turf_clear(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, turf/target_turf, list/blocked_lookup, list/occupied_lookup = null)
	if(!istype(context) || !istype(candidate) || !istype(room_plan) || !istype(target_turf))
		return FALSE
	if(!room_plan.has_turf(target_turf))
		return FALSE
	if(blocked_lookup[target_turf])
		return FALSE
	if(islist(occupied_lookup) && occupied_lookup[target_turf])
		return FALSE
	var/datum/world_edit_building_layout_state/state = context.state
	if(istype(state))
		if(state.fixtures.fixture_lookup[target_turf] || state.fixtures.semantic_slot_clearance_by_turf[target_turf])
			return FALSE
	return TRUE


/datum/world_edit_generator/building_layout/proc/building_layout_scene_clearance_turf_open(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, turf/check_turf, list/blocked_lookup, list/occupied_lookup = null)
	return building_layout_scene_turf_clear(context, candidate, room_plan, check_turf, blocked_lookup, occupied_lookup)

/datum/world_edit_generator/building_layout/proc/building_layout_scene_place_rule_clearance_ok(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, turf/target_turf, dir_to_use, wall_dir, datum/world_edit_building_place_rule/place_rule, list/blocked_lookup, list/occupied_lookup = null)
	if(!istype(place_rule))
		place_rule = resolve_building_place_rule(null, null)
	var/front_steps = max(round(text2num("[place_rule.clear_front]") || 0), 0)
	var/side_steps = max(round(text2num("[place_rule.clear_sides]") || 0), 0)
	if(front_steps <= 0 && side_steps <= 0)
		return TRUE
	var/front_dir = get_building_place_rule_front_dir(dir_to_use, wall_dir, place_rule)
	if(!front_dir)
		return FALSE
	if(front_steps > 0)
		var/turf/front_turf = target_turf
		for(var/step_index in 1 to front_steps)
			front_turf = get_step(front_turf, front_dir)
			if(!building_layout_scene_clearance_turf_open(context, candidate, room_plan, front_turf, blocked_lookup, occupied_lookup))
				return FALSE
	if(side_steps > 0)
		for(var/side_dir as anything in list(turn(front_dir, 90), turn(front_dir, -90)))
			var/turf/side_turf = target_turf
			for(var/step_index in 1 to side_steps)
				side_turf = get_step(side_turf, side_dir)
				if(!building_layout_scene_clearance_turf_open(context, candidate, room_plan, side_turf, blocked_lookup, occupied_lookup))
					return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_scene_adjacent_wall_dirs(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/target_turf)
	var/list/wall_dirs = list()
	if(!istype(context) || !istype(candidate) || !istype(target_turf))
		return wall_dirs
	if(!ensure_building_layout_candidate_wall_model(context, candidate))
		return wall_dirs
	var/list/window_lookup = build_building_layout_window_lookup(candidate)
	for(var/check_dir as anything in GLOB.cardinals)
		var/turf/wall_turf = get_step(target_turf, check_dir)
		if(!istype(wall_turf) || !candidate.solved_wall_lookup[wall_turf])
			continue
		if(window_lookup[wall_turf])
			continue
		wall_dirs += check_dir
	return wall_dirs

/datum/world_edit_generator/building_layout/proc/score_building_layout_scene_turf(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, turf/target_turf, scene_kind, wall_dir = null)
	if(!istype(context) || !istype(candidate) || !istype(room_plan) || !istype(target_turf))
		return -999999999
	var/center_x = round((room_plan.x1 + room_plan.x2) / 2)
	var/center_y = round((room_plan.y1 + room_plan.y2) / 2)
	var/center_dist = abs(target_turf.x - center_x) + abs(target_turf.y - center_y)
	var/list/wall_dirs = get_building_layout_scene_adjacent_wall_dirs(context, candidate, target_turf)
	var/adjacent_wall_count = length(wall_dirs)
	var/score = 1000 - (center_dist * 12)
	if(!isnull(wall_dir))
		score += 160
	switch("[scene_kind]")
		if("dining")
			score += 260 - (center_dist * 18)
			score -= adjacent_wall_count * 80
		if("living_common")
			score += adjacent_wall_count * 75
		if("bedroom")
			score += adjacent_wall_count * 140
		if("sanitation")
			score += adjacent_wall_count * 120
		if("storage")
			score += adjacent_wall_count * 150
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(!istype(opening_turf))
				continue
			var/door_dist = get_dist(target_turf, opening_turf)
			if(door_dist <= 1)
				score -= 900
			else if(door_dist == 2)
				score -= 180
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(!istype(window_plan) || !istype(window_plan.opening_turf))
			continue
		if(get_dist(target_turf, window_plan.opening_turf) <= 1)
			score -= 180
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(istype(route_turf) && get_dist(target_turf, route_turf) == 1)
			score -= 80
	return score



/datum/world_edit_generator/building_layout/proc/run_building_layout_candidate_emission_pipeline(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return FALSE
	context.selected_candidate = candidate
	state.layout_context = context
	stamp_building_layout_selected_candidate(state, candidate)
	if(!emit_building_layout_candidate_to_state(context, candidate))
		state.add_error("Building layout could not emit the selected candidate.")
		return FALSE
	sync_building_layout_physical_door_state(state, candidate)
	refresh_building_semantic_anchors(state)
	reserve_building_immediate_door_cones(state)
	if(!place_building_layout_scene_plans(context, candidate))
		state.add_error("Building layout could not place solved room scenes.")
		return FALSE
	place_building_infrastructure(state)
	state.rebuild_fixture_indexes()
	mark_building_structured_scene_emission(state, "building_layout")
	add_building_layout_scene_placement_report(state)
	validate_building_layout_state(state)
	if(state.has_errors())
		add_building_layout_validation_debug_report(state)
	state.fixtures.pattern_credit_hash = build_building_assoc_hash(state.fixtures.semantic_requirement_counts)
	build_building_layout_hashes(state)
	state.config["layout_scene_count"] = length(candidate.room_plans)
	return !state.has_errors()

/datum/world_edit_generator/building_layout/proc/sync_building_layout_physical_door_state(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(state) || !istype(candidate))
		return
	state.geometry.door_turfs.Cut()
	state.geometry.door_dirs.Cut()
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan))
			continue
		var/list/opening_turfs = get_building_layout_opening_plan_turfs(door_plan)
		if(door_plan.kind == "main_exit" && length(opening_turfs))
			var/turf/main_exit_turf = opening_turfs[1]
			if(istype(main_exit_turf))
				state.geometry.front_door_turf = main_exit_turf
				state.geometry.actual_entry_direction = door_plan.dir
		if(!building_layout_opening_plan_emits_door_object(state.layout_context, door_plan))
			continue
		for(var/turf/opening_turf as anything in opening_turfs)
			if(!istype(opening_turf))
				continue
			state.append_unique_turf(state.geometry.door_turfs, opening_turf)
			state.geometry.door_dirs[opening_turf] = door_plan.dir

/datum/world_edit_generator/building_layout/proc/emit_building_layout_candidate_to_state(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context.state
	if(!istype(state) || !istype(candidate))
		return FALSE
	if(!ensure_building_layout_candidate_wall_model(context, candidate))
		state.add_error("Building layout could not derive a valid wall model for the selected candidate.")
		return FALSE
	state.clear_room_layout()
	state.geometry.door_turfs.Cut()
	state.geometry.door_dirs.Cut()
	state.geometry.window_turfs.Cut()
	state.validation.door_reports.Cut()
	state.validation.room_reports.Cut()
	state.validation.zone_reports.Cut()
	state.validation.corridor_report = list()
	state.fixtures.scene_plans.Cut()
	state.fixtures.scene_counts_by_room.Cut()
	state.fixtures.scene_primary_counts_by_room.Cut()
	state.fixtures.scene_kind_by_room.Cut()
	state.fixtures.scene_slot_counts_by_room.Cut()
	state.fixtures.scene_reserved_lookup.Cut()
	state.fixtures.scene_negative_space_lookup.Cut()
	state.fixtures.scene_no_furniture_lookup.Cut()
	state.geometry.layout_room_plans = candidate.room_plans.Copy()
	state.geometry.layout_route_opening_plans = candidate.opening_plans.Copy()
	state.geometry.layout_route_overlays = candidate.route_overlays.Copy()
	var/list/floor_lookup = list()
	var/list/floor_turfs = list()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_room/room = new("layout_[room_plan.id]", room_plan.zone_id, room_plan.role)
		for(var/turf/room_turf as anything in room_plan.turfs)
			room.add_turf(room_turf)
			if(!floor_lookup[room_turf])
				floor_lookup[room_turf] = TRUE
				floor_turfs += room_turf
			state.add_zone(room_turf, room_plan.zone_id)
			if(room_plan.role == "route")
				state.add_corridor_turf(room_turf)
		room.focus_turf = select_building_layout_room_focus(room_plan)
		state.add_solved_room(room)
		var/datum/world_edit_building_solved_region/region = new("layout_region_[room_plan.id]", room_plan.zone_id, (room_plan.role in list("entry", "private", "service", "storage", "secure")) ? 100 : 50)
		for(var/turf/region_turf as anything in room_plan.turfs)
			region.turfs += region_turf
			extend_solved_region_bounds(region, region_turf)
		region.focus_turf = room.focus_turf
		state.geometry.solved_regions += region
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf))
			continue
		if(!floor_lookup[route_turf])
			floor_lookup[route_turf] = TRUE
			floor_turfs += route_turf
		state.add_corridor_turf(route_turf)
		if(!length(state.get_zone(route_turf)))
			state.add_zone(route_turf, candidate.route_zone_by_turf[route_turf] || "entry_buffer")
	for(var/turf/owner_aisle_turf as anything in candidate.owner_aisle_turfs)
		if(!istype(owner_aisle_turf))
			continue
		if(!floor_lookup[owner_aisle_turf])
			floor_lookup[owner_aisle_turf] = TRUE
			floor_turfs += owner_aisle_turf
		if(!length(state.get_zone(owner_aisle_turf)))
			state.add_zone(owner_aisle_turf, candidate.owner_aisle_zone_by_turf[owner_aisle_turf] || "entry_buffer")
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		var/list/opening_turfs = get_building_layout_opening_plan_turfs(door_plan)
		if(!length(opening_turfs))
			continue
		var/door_zone = "entry_buffer"
		var/datum/world_edit_building_layout_room_plan/door_room = candidate.get_room_plan(door_plan.from_room)
		if(!istype(door_room))
			door_room = candidate.get_room_plan(door_plan.to_room)
		if(istype(door_room))
			door_zone = door_room.zone_id
		for(var/turf/opening_turf as anything in opening_turfs)
			if(!istype(opening_turf))
				continue
			if(!floor_lookup[opening_turf])
				floor_lookup[opening_turf] = TRUE
				floor_turfs += opening_turf
			state.add_primary_route(opening_turf)
			var/public_opening = building_layout_opening_plan_is_public(context, door_plan)
			var/emits_door_object = building_layout_opening_plan_emits_door_object(context, door_plan)
			state.add_zone(opening_turf, public_opening ? "entry_buffer" : door_zone)
			if(emits_door_object)
				state.append_unique_turf(state.geometry.door_turfs, opening_turf)
				state.geometry.door_dirs[opening_turf] = door_plan.dir
			if(door_plan.kind == "main_exit")
				state.geometry.front_door_turf = opening_turf
				state.geometry.actual_entry_direction = door_plan.dir
			state.validation.door_reports += list(list(
				"turf" = opening_turf,
				"dir" = door_plan.dir,
				"kind" = door_plan.kind,
				"zone_id" = door_zone,
				"from_room" = door_plan.from_room,
				"to_room" = door_plan.to_room,
				"opening_width" = door_plan.opening_width,
				"public_opening" = public_opening ? TRUE : FALSE,
				"emits_door_object" = emits_door_object ? TRUE : FALSE,
			))
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(istype(window_plan.opening_turf))
			state.append_unique_turf(state.geometry.window_turfs, window_plan.opening_turf)
	state.geometry.floor_turfs = floor_turfs
	state.geometry.floor_lookup = floor_lookup
	state.geometry.wall_lookup = candidate.solved_wall_lookup.Copy()
	state.geometry.adjacent_wall_dirs_by_turf.Cut()
	state.geometry.internal_wall_turfs = candidate.solved_internal_wall_turfs.Copy()
	var/list/wall_cleanup_report = candidate.wall_cleanup_report
	var/removed_unmapped_count = round(text2num("[wall_cleanup_report?["removed_unmapped_wall_tile_count"]]") || 0)
	var/removed_spur_count = round(text2num("[wall_cleanup_report?["removed_single_sided_wall_tile_count"]]") || 0)
	var/removed_wall_tile_count = round(text2num("[wall_cleanup_report?["removed_wall_tile_count"]]") || 0)
	var/removed_wall_component_count = round(text2num("[wall_cleanup_report?["removed_wall_component_count"]]") || 0)
	if(removed_unmapped_count > 0)
		state.add_stage_report("layout_wall_mapping_cleanup", "ok", null, list(
			"removed_unmapped_wall_tile_count" = removed_unmapped_count,
		))
	if(removed_spur_count > 0)
		state.add_stage_report("layout_wall_spur_cleanup", "ok", null, list(
			"removed_single_sided_wall_tile_count" = removed_spur_count,
		))
	if(removed_wall_tile_count > 0)
		state.add_stage_report("layout_wall_cleanup", "ok", null, list(
			"removed_wall_tile_count" = removed_wall_tile_count,
			"removed_wall_component_count" = removed_wall_component_count,
		))
	state.geometry.center_turf = select_center_floor_turf(state.geometry.floor_turfs, (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2, (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2)
	state.geometry.semantic_hub_turf = length(candidate.route_turfs) ? candidate.route_turfs[max(1, round(length(candidate.route_turfs) / 2))] : state.geometry.center_turf
	state.validation.direction_honored_count = state.geometry.actual_entry_direction == state.geometry.requested_direction ? 1 : 0
	state.validation.direction_fallback_count = state.validation.direction_honored_count ? 0 : 1
	state.fixtures.usable_fixture_area = max(length(state.geometry.floor_turfs) - length(state.geometry.primary_route_turfs), 1)
	state.config["room_count"] = length(state.geometry.solved_rooms)
	state.config["corridor_turf_count"] = length(state.geometry.corridor_turfs)
	build_building_layout_room_reports(state)
	build_building_layout_hashes(state)
	return TRUE

/datum/world_edit_generator/building_layout/proc/mark_building_structured_scene_emission(datum/world_edit_building_layout_state/state, owner)
	if(!istype(state))
		return
	state.fixtures.structured_scene_emitted = TRUE
	state.fixtures.structured_scene_owner = length("[owner]") ? "[owner]" : "building_layout"
	state.fixtures.structured_scene_count = length(state.fixtures.scene_plans)
	state.fixtures.structured_primary_scene_count = length(state.fixtures.scene_primary_counts_by_room)

/datum/world_edit_generator/building_layout/proc/select_building_layout_room_focus(datum/world_edit_building_layout_room_plan/room_plan)
	if(!istype(room_plan) || !length(room_plan.turfs))
		return null
	var/turf/first_turf = room_plan.turfs[1]
	var/turf/center_turf = locate(round((room_plan.x1 + room_plan.x2) / 2), round((room_plan.y1 + room_plan.y2) / 2), first_turf?.z)
	if(room_plan.has_turf(center_turf))
		return center_turf
	return room_plan.turfs[1]

/datum/world_edit_generator/building_layout/proc/place_building_layout_scene_plans(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context.state
	if(!istype(state) || !istype(candidate))
		return FALSE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan.scene_plan))
			continue
		if(!place_building_layout_scene_plan(state, room_plan, room_plan.scene_plan))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/place_building_layout_scene_plan(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_plan/scene_plan)
	var/module_id = "layout_scene_[scene_plan.scene_contract_id]"
	var/module_instance_id = "layout_scene_[room_plan.id]_[scene_plan.scene_contract_id]"
	var/list/occupied = list()
	for(var/list/member as anything in scene_plan.members)
		var/turf/member_turf = member["turf"]
		var/block_reason = occupied[member_turf] ? "scene_member_overlap" : get_building_layout_scene_member_block_reason(state, member_turf, TRUE)
		if(length(block_reason))
			state.add_stage_report("layout_scene", "failed", block_reason, list(
				"room_id" = room_plan.id,
				"scene_id" = scene_plan.scene_contract_id,
				"slot" = member["slot"],
				"category" = member["category"],
				"turf" = member_turf,
				"coords" = istype(member_turf) ? "[member_turf.x],[member_turf.y],[member_turf.z]" : "",
			))
			state.remove_module_instance(module_instance_id)
			return FALSE
		occupied[member_turf] = TRUE
	mark_building_layout_scene_negative_space(state, scene_plan)
	var/placed_members = 0
	for(var/list/member as anything in scene_plan.members)
		var/turf/member_turf = member["turf"]
		var/slot = "[member["slot"]]"
		var/category = "[member["category"]]"
		var/datum/world_edit_building_cluster_spec/cluster_spec = member["cluster_spec"]
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(slot, category)
		if(istype(cluster_spec) && !cluster_spec.wall_required && cluster_spec.pattern != "wall_object" && place_rule.needs_wall)
			place_rule = new /datum/world_edit_building_place_rule(place_rule.slot, place_rule.category, place_rule.clear_front, place_rule.clear_sides, FALSE, place_rule.dir_mode, place_rule.forbidden_anchor_tags, place_rule.priority_bonus)
		var/datum/world_edit_building_layout_context/layout_context = state.layout_context
		var/datum/world_edit_building_layout_candidate/selected_candidate = layout_context?.selected_candidate
		var/list/place_context = build_building_fixture_place_context(state, member_turf, place_rule, member["dir"], member["wall_mounted"], cluster_spec, null)
		if(!islist(place_context))
			state.add_stage_report("layout_scene", "failed", "place_context_failed", list(
				"room_id" = room_plan.id,
				"scene_id" = scene_plan.scene_contract_id,
				"slot" = slot,
				"category" = category,
				"turf" = member_turf,
				"coords" = istype(member_turf) ? "[member_turf.x],[member_turf.y],[member_turf.z]" : "",
				"needs_wall" = place_rule.needs_wall ? TRUE : FALSE,
				"wall_mounted" = member["wall_mounted"] ? TRUE : FALSE,
				"dir" = member["dir"],
				"cluster_id" = cluster_spec?.id || "",
				"placement_module_id" = member["placement_module_id"] || "",
				"selected_candidate_id" = selected_candidate?.id || "",
				"state_wall_dirs" = get_adjacent_wall_dirs_for_state(state, member_turf),
				"candidate_wall_dirs" = get_building_layout_scene_adjacent_wall_dirs(layout_context, selected_candidate, member_turf),
				"fixture_occupied" = state.fixtures.fixture_lookup[member_turf] ? TRUE : FALSE,
				"semantic_clearance" = state.fixtures.semantic_slot_clearance_by_turf[member_turf] ? TRUE : FALSE,
			))
			state.remove_module_instance(module_instance_id)
			return FALSE
		var/wall_mounted = place_context["wall_mounted"] ? TRUE : FALSE
		var/wall_dir = place_context["wall_dir"]
		if(!place_fixture_at(state, member_turf, slot, place_context["dir"] || member["dir"], category, member["major"], wall_mounted, place_rule, wall_dir, cluster_spec, null, null, "layout_scene", TRUE, module_id, module_instance_id, length(scene_plan.members), scene_plan.scene_kind, "layout_[room_plan.id]", slot in list("table", "chair"), TRUE))
			var/datum/world_edit_building_fixture_provider/provider = resolve_fixture_provider(state.config, slot)
			state.add_stage_report("layout_scene", "failed", "fixture_emit_failed", list(
				"room_id" = room_plan.id,
				"scene_id" = scene_plan.scene_contract_id,
				"slot" = slot,
				"category" = category,
				"turf" = member_turf,
				"can_place" = state.can_place_fixture(member_turf, TRUE),
				"reservation_owner" = state.get_semantic_slot_owner(member_turf),
				"zone" = state.get_zone(member_turf),
				"zone_contract_ok" = building_fixture_matches_semantic_zone_contract(state, member_turf, slot, category, cluster_spec),
				"place_rule_ok" = building_place_rule_allows_turf(state, member_turf, place_rule, place_context["dir"] || member["dir"], wall_dir),
				"provider_id" = provider?.id,
				"provider_functional" = provider?.functional,
			))
			state.remove_module_instance(module_instance_id)
			return FALSE
		annotate_building_layout_scene_placement(state, member_turf, scene_plan, member)
		placed_members++
	if(placed_members != length(scene_plan.members))
		state.remove_module_instance(module_instance_id)
		return FALSE
	state.register_module_instance(module_id, module_instance_id, length(scene_plan.members), "layout_[room_plan.id]", scene_plan.scene_kind)
	register_building_layout_scene_plan(state, room_plan, scene_plan)
	return TRUE

/datum/world_edit_generator/building_layout/proc/add_building_layout_scene_placement_report(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/list/placements = list()
	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(!islist(object_placement) || !GLOB.world_edit_helpers.parse_bool(object_placement["layout_scene"]))
			continue
		var/turf/target_turf = object_placement["turf"]
		placements += list(list(
			"slot" = object_placement["slot"],
			"category" = object_placement["category"],
			"scene_id" = object_placement["scene_id"],
			"scene_kind" = object_placement["scene_kind"],
			"scene_slot" = object_placement["scene_slot"],
			"kind" = object_placement["kind"],
			"module_id" = object_placement["module_id"],
			"module_instance_id" = object_placement["module_instance_id"],
			"placement_module_id" = object_placement["placement_module_id"],
			"placement_module_instance_id" = object_placement["placement_module_instance_id"],
			"room_id" = object_placement["module_room_id"],
			"stored_zone" = object_placement["zone_id"],
			"actual_zone" = state.get_zone(target_turf),
			"turf" = target_turf,
			"coords" = istype(target_turf) ? "[target_turf.x],[target_turf.y],[target_turf.z]" : "",
		))
	state.add_stage_report("layout_scene_summary", "ok", null, list(
		"placement_count" = length(placements),
		"placements" = placements,
	))

/datum/world_edit_generator/building_layout/proc/add_building_layout_validation_debug_report(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/list/reachable = get_building_validation_reachable_floor_lookup(state)
	var/list/unreachable_major = list()
	var/list/module_actual_counts = list()
	var/list/module_expected_counts = list()
	var/list/toilet_placements = list()
	var/list/wall_overlap_placements = list()
	var/list/orphan_internal_walls = list()
	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(!islist(object_placement))
			continue
		var/turf/target_turf = object_placement["turf"]
		if(istype(target_turf) && state.geometry.wall_lookup[target_turf])
			wall_overlap_placements += list(list(
				"slot" = object_placement["slot"],
				"category" = object_placement["category"],
				"layout_scene" = GLOB.world_edit_helpers.parse_bool(object_placement["layout_scene"]) ? TRUE : FALSE,
				"module_instance_id" = object_placement["module_instance_id"],
				"stored_zone" = object_placement["zone_id"],
				"actual_zone" = state.get_zone(target_turf),
				"coords" = "[target_turf.x],[target_turf.y],[target_turf.z]",
			))
		if("[object_placement["slot"]]" == "toilet")
			toilet_placements += list(list(
				"slot" = object_placement["slot"],
				"category" = object_placement["category"],
				"layout_scene" = GLOB.world_edit_helpers.parse_bool(object_placement["layout_scene"]) ? TRUE : FALSE,
				"module_instance_id" = object_placement["module_instance_id"],
				"stored_zone" = object_placement["zone_id"],
				"actual_zone" = state.get_zone(target_turf),
				"coords" = istype(target_turf) ? "[target_turf.x],[target_turf.y],[target_turf.z]" : "",
			))
		if(GLOB.world_edit_helpers.parse_bool(object_placement["major"]) && !reachable[target_turf])
			var/has_adjacent_reachable = FALSE
			for(var/check_dir in GLOB.cardinals)
				if(reachable[get_step(target_turf, check_dir)])
					has_adjacent_reachable = TRUE
					break
			if(!has_adjacent_reachable)
				unreachable_major += list(list(
					"slot" = object_placement["slot"],
					"category" = object_placement["category"],
					"scene_id" = object_placement["scene_id"],
					"room_id" = object_placement["module_room_id"],
					"zone" = state.get_zone(target_turf),
					"coords" = istype(target_turf) ? "[target_turf.x],[target_turf.y],[target_turf.z]" : "",
				))
		if(!GLOB.world_edit_helpers.parse_bool(object_placement["layout_scene"]))
			continue
		var/module_instance_id = "[object_placement["module_instance_id"] || ""]"
		if(length(module_instance_id))
			module_actual_counts[module_instance_id] = (module_actual_counts[module_instance_id] || 0) + 1
			module_expected_counts[module_instance_id] = max(round(text2num("[object_placement["module_expected_member_count"]]") || 0), round(text2num("[module_expected_counts[module_instance_id]]") || 0), 1)
	for(var/turf/internal_wall_turf as anything in state.geometry.internal_wall_turfs)
		if(!istype(internal_wall_turf))
			continue
		var/adjacent_floor = FALSE
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(internal_wall_turf, check_dir)
			if(state.geometry.floor_lookup[nearby_turf] || state.geometry.door_dirs[nearby_turf])
				adjacent_floor = TRUE
				break
		if(!adjacent_floor)
			orphan_internal_walls += list("[internal_wall_turf.x],[internal_wall_turf.y],[internal_wall_turf.z]")
			if(length(orphan_internal_walls) >= 16)
				break
	var/list/module_reports = list()
	for(var/module_instance_id as anything in module_expected_counts)
		var/actual_count = round(text2num("[module_actual_counts[module_instance_id]]") || 0)
		var/expected_count = round(text2num("[module_expected_counts[module_instance_id]]") || 0)
		if(actual_count != expected_count)
			module_reports += list(list(
				"module_instance_id" = module_instance_id,
				"actual" = actual_count,
				"expected" = expected_count,
			))
	state.add_stage_report("layout_validation_debug", "ok", null, list(
		"unreachable_major" = unreachable_major,
		"fragmented_modules" = module_reports,
		"toilet_placements" = toilet_placements,
		"wall_overlap_placements" = wall_overlap_placements,
		"orphan_internal_walls" = orphan_internal_walls,
	))

/datum/world_edit_generator/building_layout/proc/get_building_layout_scene_member_block_reason(datum/world_edit_building_layout_state/state, turf/member_turf, allow_reserved = FALSE)
	if(!istype(member_turf))
		return "invalid_turf"
	if(!state.geometry.floor_lookup[member_turf])
		return "not_floor"
	if(state.geometry.wall_lookup[member_turf])
		return "wall"
	if(state.geometry.door_dirs[member_turf])
		return "door"
	if(state.fixtures.fixture_lookup[member_turf])
		return "fixture"
	if(state.fixtures.semantic_slot_clearance_by_turf[member_turf])
		return "semantic_clearance"
	if(state.fixtures.scene_no_furniture_lookup[member_turf])
		return "scene_no_furniture"
	if(!allow_reserved && state.geometry.reserved_lookup[member_turf])
		return "reserved_route"
	if(state.has_anchor("door_cone", member_turf))
		return "door_cone"
	return ""

/datum/world_edit_generator/building_layout/proc/annotate_building_layout_scene_placement(datum/world_edit_building_layout_state/state, turf/member_turf, datum/world_edit_building_layout_scene_plan/scene_plan, list/member)
	for(var/index = length(state.fixtures.object_placements), index >= 1, index--)
		var/list/placement = state.fixtures.object_placements[index]
		if(!islist(placement) || placement["turf"] != member_turf || "[placement["module_instance_id"]]" != "layout_scene_[scene_plan.room_id]_[scene_plan.scene_contract_id]")
			continue
		placement["layout_scene"] = TRUE
		placement["scene_id"] = scene_plan.scene_contract_id
		placement["scene_kind"] = scene_plan.scene_kind
		placement["scene_slot"] = member["scene_slot"]
		placement["scene_primary"] = scene_plan.primary ? TRUE : FALSE
		placement["placement_module_id"] = member["placement_module_id"]
		placement["placement_module_instance_id"] = member["placement_module_instance_id"]
		placement["placement_module_repeat_group"] = member["placement_module_repeat_group"]
		return

/datum/world_edit_generator/building_layout/proc/register_building_layout_scene_plan(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_plan/scene_plan)
	var/room_key = "layout_[room_plan.id]"
	state.fixtures.scene_plans += list(list(
		"id" = scene_plan.id,
		"room_id" = room_key,
		"room_contract_id" = room_plan.contract_id,
		"room_role" = room_plan.role,
		"scene_id" = scene_plan.scene_contract_id,
		"scene_kind" = scene_plan.scene_kind,
		"primary" = scene_plan.primary ? TRUE : FALSE,
		"member_count" = length(scene_plan.members),
		"scene_slot_counts" = scene_plan.scene_slot_counts.Copy(),
	))
	state.fixtures.scene_counts_by_room[room_key] = (state.fixtures.scene_counts_by_room[room_key] || 0) + 1
	if(scene_plan.primary)
		state.fixtures.scene_primary_counts_by_room[room_key] = (state.fixtures.scene_primary_counts_by_room[room_key] || 0) + 1
	state.fixtures.scene_kind_by_room[room_key] = scene_plan.scene_kind
	state.fixtures.scene_slot_counts_by_room[room_key] = scene_plan.scene_slot_counts.Copy()

/datum/world_edit_generator/building_layout/proc/build_building_layout_room_reports(datum/world_edit_building_layout_state/state)
	state.validation.room_reports.Cut()
	var/datum/world_edit_building_layout_context/context = state.layout_context
	var/datum/world_edit_building_layout_candidate/candidate = context?.selected_candidate
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate?.room_plans)
		if(!istype(room_plan))
			continue
		var/room_key = "layout_[room_plan.id]"
		var/list/module_ids = list()
		var/list/module_lookup = list()
		var/list/functional_units = list()
		var/list/module_bounds = list()
		var/occupied_count = 0
		for(var/list/placement as anything in state.fixtures.object_placements)
			if(!islist(placement) || "[placement["module_room_id"]]" != room_key || !GLOB.world_edit_helpers.parse_bool(placement["layout_scene"]))
				continue
			occupied_count++
			var/module_id = "[placement["placement_module_id"] || placement["module_id"] || ""]"
			if(length(module_id) && !module_lookup[module_id])
				module_lookup[module_id] = TRUE
				module_ids += module_id
			var/unit_id = "[placement["requested_slot"] || placement["slot"] || placement["category"] || "object"]"
			functional_units[unit_id] = (functional_units[unit_id] || 0) + 1
			var/turf/module_turf = placement["turf"]
			if(istype(module_turf))
				module_bounds += list(list("x1" = module_turf.x, "y1" = module_turf.y, "x2" = module_turf.x, "y2" = module_turf.y))
		var/access_count = 0
		for(var/list/door_report as anything in state.validation.door_reports)
			if(islist(door_report) && ("[door_report["from_room"]]" in list(room_plan.id, room_key) || "[door_report["to_room"]]" in list(room_plan.id, room_key)))
				access_count++
		var/list/topology_edges = list()
		for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph?.get_edges_for(room_plan.contract_id))
			if(istype(edge))
				topology_edges += list(list("from" = edge.from_id, "to" = edge.to_id, "kind" = edge.edge_kind, "opening_policy" = edge.opening_policy, "route_policy" = edge.route_policy, "required" = edge.required ? TRUE : FALSE))
		var/negative_space_count = length(room_plan.scene_plan?.negative_space_turfs)
		state.validation.room_reports += list(list(
			"id" = room_plan.id,
			"normalized_id" = room_key,
			"contract_id" = room_plan.contract_id,
			"zone_id" = room_plan.zone_id,
			"role" = room_plan.role,
			"spatial_kind" = room_plan.spatial_kind,
			"topology_parent" = room_plan.topology_parent,
			"topology_depth" = room_plan.graph_depth,
			"topology_edges" = topology_edges,
			"area" = room_plan.area(),
			"useful_area" = length(room_plan.turfs),
			"bounds" = list("x1" = room_plan.x1, "y1" = room_plan.y1, "x2" = room_plan.x2, "y2" = room_plan.y2),
			"focus" = select_building_layout_room_focus(room_plan),
			"composition_id" = state.fixtures.scene_kind_by_room[room_key],
			"module_ids" = module_ids,
			"module_count" = length(module_ids),
			"module_bounds" = module_bounds,
			"functional_units" = functional_units,
			"occupied_turf_count" = occupied_count,
			"occupied_ratio_percent" = round(occupied_count * 100 / max(room_plan.area(), 1)),
			"density_percent" = round(occupied_count * 100 / max(room_plan.area(), 1)),
			"ownership_turf_count" = length(room_plan.turfs),
			"aisle_turf_count" = negative_space_count,
			"negative_space_count" = negative_space_count,
			"clearance_turf_count" = length(room_plan.scene_plan?.clearance_turfs),
			"access_count" = access_count,
			"primary_scene_count" = state.fixtures.scene_primary_counts_by_room[room_key] || 0,
			"layout_scene" = TRUE,
		))
	state.validation.zone_reports.Cut()
	for(var/zone_id as anything in state.geometry.zone_turfs)
		var/list/zone_turfs = state.geometry.zone_turfs[zone_id]
		state.validation.zone_reports += list(list(
			"id" = "[zone_id]",
			"area" = islist(zone_turfs) ? length(zone_turfs) : 0,
			"focus" = state.geometry.zone_focus_turfs[zone_id],
		))
	state.validation.corridor_report = list(
		"reserved_walk_count" = length(state.geometry.primary_route_turfs),
		"corridor_turf_count" = length(state.geometry.corridor_turfs),
		"owner_aisle_turf_count" = length(context?.selected_candidate?.owner_aisle_turfs),
		"owner_aisle_assignment_count" = length(context?.selected_candidate?.owner_aisle_owner_by_turf),
		"route_overlays" = build_building_layout_candidate_route_overlay_report(context?.selected_candidate),
		"door_transition_count" = length(state.validation.door_reports),
		"front_door_turf" = state.geometry.front_door_turf,
		"layout_scene" = TRUE,
	)

/datum/world_edit_generator/building_layout/proc/build_building_layout_route_overlay_geometry_hash(datum/world_edit_building_layout_candidate/candidate)
	var/list/values = list()
	for(var/datum/world_edit_building_layout_route_overlay/overlay as anything in candidate?.route_overlays)
		if(!istype(overlay))
			continue
		for(var/turf/overlay_turf as anything in overlay.turfs)
			if(istype(overlay_turf))
				values += "[overlay.id]|[overlay.owner_room_id]|[overlay.kind]|[overlay_turf.x],[overlay_turf.y],[overlay_turf.z]"
		for(var/turf/approach_turf as anything in overlay.approach_turfs)
			if(istype(approach_turf))
				values += "[overlay.id]|[overlay.owner_room_id]|approach|[approach_turf.x],[approach_turf.y],[approach_turf.z]"
	return build_building_hash_from_strings(sortList(values))

/datum/world_edit_generator/building_layout/proc/build_building_layout_hashes(datum/world_edit_building_layout_state/state)
	var/datum/world_edit_building_layout_context/context = state?.layout_context
	state.geometry.room_graph_hash = build_building_room_ownership_hash(state)
	state.geometry.route_hash = build_building_turf_list_hash(state.geometry.primary_route_turfs)
	state.geometry.wall_hash = build_building_turf_lookup_hash(state.geometry.wall_lookup)
	var/object_placement_hash = build_building_object_placement_hash(state.fixtures.object_placements)
	state.geometry.structural_topology_signature = context?.selected_candidate?.topology_signature || build_building_layout_topology_signature(context?.selected_candidate)
	state.geometry.geometry_layout_hash = build_building_hash_from_strings(list(
		"solver=1",
		"footprint=[state.geometry.footprint_hash]",
		"rooms=[state.geometry.room_graph_hash]",
		"route=[state.geometry.route_hash]",
		"route_overlays=[build_building_layout_route_overlay_geometry_hash(context?.selected_candidate)]",
		"floor=[build_building_turf_lookup_hash(state.geometry.floor_lookup)]",
		"walls=[state.geometry.wall_hash]",
		"doors=[build_building_door_hash(state)]",
		"objects=[object_placement_hash]",
	))
	state.geometry.layout_hash = state.geometry.geometry_layout_hash
	state.validation.determinism_check_hash = state.geometry.layout_hash

/datum/world_edit_generator/building_layout/proc/validate_building_layout_scenes(datum/world_edit_building_layout_state/state)
	if(!building_layout_solver_enabled(state))
		return
	var/datum/world_edit_building_layout_context/context = state.layout_context
	var/datum/world_edit_building_layout_program_contract/program = context?.program_contract
	if(!istype(program))
		program = build_building_layout_program_contract(state.archetype?.id)
	validate_building_layout_openings(state, context, context?.selected_candidate)
	var/list/scene_by_room = state.fixtures.scene_kind_by_room
	var/list/primary_counts = state.fixtures.scene_primary_counts_by_room
	var/list/slot_counts_by_room = state.fixtures.scene_slot_counts_by_room
	var/list/scene_member_counts_by_room = list()
	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(!islist(object_placement) || !GLOB.world_edit_helpers.parse_bool(object_placement["layout_scene"]))
			continue
		var/member_room_id = "[object_placement["module_room_id"] || ""]"
		if(length(member_room_id))
			scene_member_counts_by_room[member_room_id] = (scene_member_counts_by_room[member_room_id] || 0) + 1
	var/common_focal_count = 0
	var/common_small_social_count = 0
	var/public_focal_count = 0
	for(var/datum/world_edit_building_room/room as anything in state.geometry.solved_rooms)
		if(!istype(room))
			continue
		var/room_contract_id = building_layout_room_contract_id_from_room(room)
		var/datum/world_edit_building_layout_room_contract/room_contract = program?.get_room_contract(room_contract_id)
		var/scene_kind = "[scene_by_room[room.id] || ""]"
		var/primary_count = round(text2num("[primary_counts[room.id]]") || 0)
		var/list/slot_counts = slot_counts_by_room[room.id]
		if(primary_count > 1)
			state.validation.room_scene_duplicate_count += primary_count - 1
		if(istype(room_contract) && primary_count > room_contract.max_scene_count)
			state.validation.scene_slot_overflow_count += primary_count - room_contract.max_scene_count
		if(istype(room_contract) && room_contract.required && length(room_contract.required_scene_kinds) && !length(scene_kind))
			state.validation.scene_required_missing_count++
			state.validation.room_primary_scene_missing_count++
		if(room.area >= 12 && !(room.role in list("route", "entry")) && !length(scene_kind))
			state.validation.room_identity_missing_count++
			state.validation.large_empty_unassigned_floor_count++
		if(room_contract_id == "sleeping" && scene_kind != "bedroom")
			state.validation.private_room_without_bed_scene_count++
		if(room_contract_id == "sanitation" && scene_kind != "sanitation")
			state.validation.sanitation_without_sanitation_scene_count++
		if(room_contract_id == "storage" && scene_kind != "storage")
			state.validation.storage_without_storage_scene_count++
		if(istype(room_contract) && room.area > room_contract.max_area)
			state.validation.oversized_role_room_count++
		var/room_width = isnull(room.x1) || isnull(room.x2) ? 0 : max(room.x2 - room.x1 + 1, 0)
		var/room_height = isnull(room.y1) || isnull(room.y2) ? 0 : max(room.y2 - room.y1 + 1, 0)
		var/room_min_dim = min(room_width, room_height)
		var/room_max_dim = max(room_width, room_height)
		if(room.area >= 12 && (room_min_dim <= 2 || room_max_dim > room_min_dim * 4))
			state.validation.thin_room_strip_count++
		var/scene_member_count = round(text2num("[scene_member_counts_by_room[room.id]]") || 0)
		var/min_scene_member_count = get_building_layout_min_scene_members_for_room(room_contract_id, room.role, room.area)
		if(min_scene_member_count > 0 && scene_member_count < min_scene_member_count)
			state.validation.layout_underfurnished_room_count += min_scene_member_count - scene_member_count
		if(room.area >= 64 && scene_member_count <= 2 && !(room_contract_id in list("sanitation", "storage", "utility")))
			state.validation.large_sparse_room_count++
		if(room_contract_id in list("entry_common", "dining"))
			var/dining_focal = islist(slot_counts) ? round(text2num("[slot_counts["dining_focal"]]") || 0) : 0
			var/lounge_focal = islist(slot_counts) ? round(text2num("[slot_counts["lounge_focal"]]") || 0) : 0
			common_focal_count += dining_focal > 0 ? 1 : 0
			common_small_social_count += lounge_focal > 0 ? 1 : 0
			public_focal_count += dining_focal + lounge_focal
			if(dining_focal > 1)
				state.validation.scene_slot_overflow_count += dining_focal - 1
	for(var/list/placement as anything in state.fixtures.object_placements)
		if(!islist(placement) || !GLOB.world_edit_helpers.parse_bool(placement["layout_scene"]))
			continue
		var/turf/target_turf = placement["turf"]
		if(istype(target_turf) && building_object_path_is_dense(placement["obj_path"]) && (state.geometry.reserved_lookup[target_turf] || state.has_anchor("door_cone", target_turf)))
			state.validation.scene_blocks_route_count++
		validate_building_layout_scene_placement_role(state, placement)
	if(common_focal_count > 1)
		state.validation.common_scene_fragmentation_count += common_focal_count - 1
	if(public_focal_count > 1)
		state.validation.common_scene_fragmentation_count += public_focal_count - 1
	if(common_small_social_count > 1)
		state.validation.excessive_small_social_groups_count += common_small_social_count - 1
	var/interior_count = length(state.geometry.interior)
	if(interior_count >= 180)
		var/orphan_internal_wall_count = 0
		for(var/turf/internal_wall_turf as anything in state.geometry.internal_wall_turfs)
			if(!istype(internal_wall_turf))
				continue
			var/adjacent_floor = FALSE
			for(var/check_dir in GLOB.cardinals)
				var/turf/nearby_turf = get_step(internal_wall_turf, check_dir)
				if(state.geometry.floor_lookup[nearby_turf] || state.geometry.door_dirs[nearby_turf])
					adjacent_floor = TRUE
					break
			if(!adjacent_floor)
				orphan_internal_wall_count++
		var/orphan_internal_wall_allowance = max(10, length(state.geometry.solved_rooms) * 3)
		if(orphan_internal_wall_count > orphan_internal_wall_allowance)
			state.validation.unclaimed_interior_wall_count += orphan_internal_wall_count - orphan_internal_wall_allowance
	var/allowed_route_count = max(28, length(state.geometry.solved_rooms) * 5 + 4)
	var/layout_room_count = 0
	if(istype(context?.selected_candidate))
		layout_room_count = length(context.selected_candidate.room_plans)
	if(layout_room_count > 0)
		allowed_route_count = max(allowed_route_count, layout_room_count * 5 + 4)
		var/layout_route_budget = length(context.selected_candidate.route_turfs)
		for(var/datum/world_edit_building_layout_room_plan/route_room_plan as anything in context.selected_candidate.room_plans)
			if(istype(route_room_plan) && route_room_plan.role == "route")
				layout_route_budget += length(route_room_plan.turfs)
		for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in context.selected_candidate.opening_plans)
			if(istype(opening_plan))
				layout_route_budget += length(get_building_layout_opening_plan_turfs(opening_plan))
		if(layout_route_budget > 0)
			allowed_route_count = max(allowed_route_count, layout_route_budget)
	if(length(state.geometry.primary_route_turfs) > allowed_route_count)
		state.validation.corridor_ribbon_count += length(state.geometry.primary_route_turfs) - allowed_route_count
	validate_building_layout_quality(context, context?.selected_candidate)

/datum/world_edit_generator/building_layout/proc/get_building_layout_min_scene_members_for_room(room_contract_id, room_role, room_area)
	var/resolved_role = "[room_role]"
	if(resolved_role in list("route", "entry") || round(text2num("[room_area]") || 0) <= 0)
		return 0
	var/area = round(text2num("[room_area]") || 0)
	var/occupied_ratio = 8
	switch(resolved_role)
		if("hub", "work", "staging")
			occupied_ratio = 10
		if("storage", "service", "secure", "support")
			occupied_ratio = 14
	return max(1, round((area * occupied_ratio + 99) / 100))

/datum/world_edit_generator/building_layout/proc/validate_building_layout_scene_placement_role(datum/world_edit_building_layout_state/state, list/placement)
	if(!istype(state) || !islist(placement))
		return
	var/slot = "[placement["requested_slot"] || placement["slot"] || ""]"
	var/scene_kind = "[placement["scene_kind"] || ""]"
	var/scene_slot = "[placement["scene_slot"] || ""]"
	if(slot in list("table", "chair") && GLOB.world_edit_helpers.parse_bool(placement["module_requires_table_pairing"]) && !length("[placement["module_instance_id"] || ""]"))
		if(slot == "table")
			state.validation.loose_table_count++
		else
			state.validation.loose_chair_count++
	if(slot == "bed" && scene_kind != "bedroom")
		state.validation.bed_outside_sleeping_count++
	if(slot in list("toilet", "sink") && scene_kind != "sanitation")
		state.validation.toilet_outside_sanitation_count++
		if(scene_slot in list("storage_run", "storage_corner") && scene_kind != "storage")
			state.validation.storage_without_storage_scene_count++

/datum/world_edit_generator/building_layout/proc/validate_building_layout_openings(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(state) || !istype(context) || !istype(candidate))
		return
	var/list/room_door_counts = list()
	var/main_exit_ok = FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan))
			continue
		var/valid = building_layout_door_plan_has_valid_shared_wall(context, candidate, door_plan)
		if(!valid)
			state.validation.layout_door_not_shared_wall_count++
			state.add_error("Building layout door '[door_plan.id]' is not a valid shared-wall opening.")
			continue
		if(door_plan.kind == "main_exit")
			main_exit_ok = TRUE
			continue
		if(length(door_plan.from_room) && door_plan.from_room != "route")
			room_door_counts[door_plan.from_room] = (room_door_counts[door_plan.from_room] || 0) + 1
		if(length(door_plan.to_room) && door_plan.to_room != "route")
			room_door_counts[door_plan.to_room] = (room_door_counts[door_plan.to_room] || 0) + 1
	if(!main_exit_ok)
		state.validation.layout_required_connection_missing_count++
		state.add_error("Building layout has no valid main exit opening.")
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(room_plan.contract_id)
		if(!istype(room_contract) || !room_contract.must_touch_route)
			continue
		if(room_door_counts[room_plan.id])
			continue
		state.validation.layout_room_without_door_count++
		if(room_contract.required)
			state.validation.layout_required_connection_missing_count++
		state.add_error("Building layout room '[room_plan.id]' has no valid route opening.")
	for(var/datum/world_edit_building_layout_route_opening_plan/window_plan as anything in candidate.window_plans)
		if(!istype(window_plan))
			continue
		var/datum/world_edit_building_layout_room_plan/window_room = candidate.get_room_plan(window_plan.from_room)
		var/datum/world_edit_building_layout_room_contract/window_contract = context.program_contract.get_room_contract(window_room?.contract_id)
		if(istype(window_contract) && window_contract.exterior_window_policy == "forbidden")
			state.validation.layout_forbidden_room_window_count++
			state.add_error("Building layout room '[window_room.id]' has a forbidden exterior window.")
			continue
		if(!building_layout_window_plan_obeys_policy(context, candidate, window_plan))
			state.validation.invalid_window_count++
			state.add_error("Building layout window '[window_plan.id]' violates exterior/window policy.")

/datum/world_edit_generator/building_layout/proc/building_layout_room_contract_id_from_room(datum/world_edit_building_room/room)
	if(!istype(room))
		return ""
	if(findtext(room.id, "entry_common"))
		return "entry_common"
	if(findtext(room.id, "sleeping"))
		return "sleeping"
	if(findtext(room.id, "sanitation"))
		return "sanitation"
	if(findtext(room.id, "storage") && !findtext(room.id, "utility"))
		return "storage"
	if(findtext(room.id, "dining"))
		return "dining"
	if(findtext(room.id, "utility"))
		return "utility"
	return ""
