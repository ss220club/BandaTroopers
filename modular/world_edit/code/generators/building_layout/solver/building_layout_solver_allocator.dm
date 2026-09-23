/datum/world_edit_generator/building_layout/proc/allocate_building_layout_rooms_bounded(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, allocation_variant = 0)
	if(!istype(context) || !istype(candidate))
		return FALSE
	if(!istype(candidate.region_candidate))
		candidate.errors += "room.alloc_invalid_region_candidate"
		return FALSE
	var/frontier_variant = allocation_variant >= 4 ? 0 : allocation_variant
	var/complete_choice_index = allocation_variant >= 4 ? allocation_variant - 2 : 1
	var/list/shortlist = get_building_layout_complete_partial_shortlist(context, candidate, frontier_variant)
	context.state.add_stage_report("layout_allocation_order", "ok", null, list(
		"candidate_id" = candidate.id,
		"family_policy_id" = candidate.family_policy_id,
		"allocation_variant" = allocation_variant,
		"frontier_variant" = frontier_variant,
		"complete_choice_index" = complete_choice_index,
		"contracts" = islist(shortlist?["contract_report"]) ? shortlist["contract_report"].Copy() : list(),
	))
	for(var/error_text as anything in shortlist?["errors"])
		candidate.errors += "[error_text]"
	if(length(candidate.errors))
		return FALSE
	var/list/feasible_partials = shortlist["feasible_partials"]
	var/list/evaluation_reports = shortlist["evaluation_reports"]
	if(!islist(feasible_partials) || length(feasible_partials) < complete_choice_index)
		candidate.errors += "room.complete_partial_alternate_missing:[complete_choice_index]"
		context.state.add_stage_report("layout_complete_partial_evaluation", "failed", "requested ranked complete partial is unavailable", list("candidate_id" = candidate.id, "complete_choice_index" = complete_choice_index, "feasible_count" = length(feasible_partials), "evaluated" = evaluation_reports))
		return FALSE
	var/datum/world_edit_building_layout_allocation_partial/winner = feasible_partials[complete_choice_index]
	if(!istype(winner))
		candidate.errors += "room.complete_partial_invalid:[complete_choice_index]"
		return FALSE
	if(!building_layout_partial_route_network_possible(context, candidate, winner, candidate.route_terminal_hints_by_connection))
		candidate.errors += "room.route_terminal_hint_commit_failed"
		return FALSE
	for(var/connection_id as anything in candidate.route_terminal_hints_by_connection)
		var/list/terminal_hint = candidate.route_terminal_hints_by_connection[connection_id]
		for(var/turf/wall_turf as anything in terminal_hint?["wall_run"])
			if(istype(wall_turf))
				candidate.route_terminal_wall_hint_lookup[wall_turf] = TRUE
	for(var/room_id as anything in winner.placement_order)
		var/list/rect = winner.placements[room_id]
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(room_id)
		if(!islist(rect) || !istype(room_contract))
			candidate.errors += "room.alloc_materialize_missing:[room_id]"
			continue
		var/datum/world_edit_building_layout_room_plan/room_plan = add_building_layout_room_rect(context, candidate, room_contract.id, room_contract.id, room_contract.role, room_contract.zone_id, rect["x1"], rect["y1"], rect["x2"], rect["y2"])
		if(!istype(room_plan))
			candidate.errors += "room.alloc_emit_failed:[room_contract.id]"
			continue
		var/datum/world_edit_building_layout_topology_node/topology_node = candidate.topology_graph?.get_node(room_contract.id)
		room_plan.spatial_kind = room_contract.spatial_kind
		room_plan.counts_toward_target = room_contract.counts_toward_target
		room_plan.topology_parent = topology_node?.parent_id || ""
		room_plan.graph_depth = topology_node?.depth || 0
	if(!materialize_building_layout_nested_room_ownership(context, candidate, winner))
		candidate.errors += "room.nested_partition_materialize_failed"
		return FALSE
	candidate.score += winner.score
	context.state.add_stage_report("layout_bounded_allocation", "ok", null, list("candidate_id" = candidate.id, "rooms" = length(candidate.room_plans), "partial_expansions" = shortlist["partial_expansions"] || 0, "score" = winner.score, "complete_choice_index" = complete_choice_index, "complete_evaluated" = shortlist["evaluated_complete_count"] || 0, "complete_evaluations" = evaluation_reports, "placements" = format_building_layout_partial(winner)))
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/get_building_layout_complete_partial_shortlist(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, frontier_variant = 0)
	if(!istype(context) || !istype(candidate?.region_candidate))
		return list("errors" = list("room.alloc_invalid_region_candidate"))
	// BYOND associative lists do not give a stable identity namespace when a datum
	// is used directly as the key here: sibling topology-family regions can reuse
	// the first computed shortlist.  Cache by authored region identity so every
	// family/orientation keeps its own ordering, zones, and hard constraints while
	// the 4-6 materialized alternatives still share their bounded beam.
	var/region_cache_key = "[candidate.region_candidate.family_policy_id || candidate.family_policy_id]:[candidate.region_candidate.id]:[candidate.region_candidate.orientation_variant]"
	var/list/region_cache = context.allocation_shortlists_by_region[region_cache_key]
	if(!islist(region_cache))
		region_cache = list()
		context.allocation_shortlists_by_region[region_cache_key] = region_cache
	var/list/cached = region_cache["[frontier_variant]"]
	if(islist(cached))
		return cached
	var/list/contracts = sort_building_layout_room_contracts_by_topology(candidate, context.program_contract.functional_room_contracts, frontier_variant)
	var/list/ordered_contract_ids = list()
	for(var/datum/world_edit_building_layout_room_contract/ordered_contract as anything in contracts)
		var/route_terminal_count = 0
		for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph?.get_edges_for(ordered_contract?.id))
			if(istype(edge) && edge.required && edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE && edge.route_policy == WORLD_EDIT_BUILDING_ROUTE_POLICY_NETWORK)
				route_terminal_count++
		ordered_contract_ids += "[ordered_contract?.id]:route_terminals=[route_terminal_count]"
	var/list/result = list(
		"contract_report" = ordered_contract_ids,
		"family_policy_id" = candidate.family_policy_id,
		"frontier_variant" = frontier_variant,
		"errors" = list(),
		"feasible_partials" = list(),
		"feasible_scores" = list(),
		"evaluation_reports" = list(),
		"partial_expansions" = 0,
		"evaluated_complete_count" = 0,
	)
	var/list/beam = list(new /datum/world_edit_building_layout_allocation_partial)
	var/partial_expansions = 0
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in contracts)
		if(!istype(room_contract))
			continue
		var/datum/world_edit_building_layout_influence_zone/zone = get_building_layout_contract_seed_zone(candidate.region_candidate, room_contract.id)
		if(!istype(zone))
			var/list/seed_errors = result["errors"]
			if(room_contract.required)
				seed_errors += "room.seed_region_missing:[room_contract.id]"
			region_cache["[frontier_variant]"] = result
			return result
		var/list/next_beam = list()
		context.state.config["layout_partial_terminal_reject_counts"] = list()
		var/enumerated_option_count = 0
		var/edge_fit_option_count = 0
		var/terminal_fit_option_count = 0
		var/partition_spacing_reject_count = 0
		var/list/partition_spacing_reject_rects = list()
		var/required_edge_reject_count = 0
		var/nested_parent_floor_reject_count = 0
		for(var/datum/world_edit_building_layout_allocation_partial/partial as anything in beam)
			if(!istype(partial) || partial_expansions >= WORLD_EDIT_BUILDING_ALLOCATION_MAX_EXPANSIONS)
				continue
			partial_expansions++
			var/list/options = enumerate_building_layout_room_rects(context, candidate, partial, zone, room_contract, frontier_variant)
			enumerated_option_count += length(options)
			for(var/list/option as anything in options)
				var/list/rect = option?["rect"]
				if(!islist(rect))
					continue
				var/datum/world_edit_building_layout_allocation_partial/child = partial.fork_with(room_contract.id, rect, option["score"])
				if(!building_layout_partial_closed_partition_spacing_valid(context, candidate, child))
					partition_spacing_reject_count++
					if(length(partition_spacing_reject_rects) < WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE)
						partition_spacing_reject_rects += "[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
					continue
				if(!building_layout_partial_all_required_edges_fit(context, candidate.topology_graph, child))
					required_edge_reject_count++
					continue
				// Keep the parent's authored floor/composition rectangle intact while
				// nested children enter the beam. Deferring this hard invariant until
				// complete-partial scoring lets centrally placed children crowd out the
				// edge-packed alternative even when the latter is the only valid layout.
				if(!building_layout_partial_nested_parent_floor_possible(context, candidate, child))
					nested_parent_floor_reject_count++
					continue
				edge_fit_option_count++
				var/list/estimated_route_terminals = list()
				if(!building_layout_partial_route_terminal_slots_possible(context, candidate, child, room_contract.id, estimated_route_terminals))
					continue
				terminal_fit_option_count++
				child.estimated_route_terminals = estimated_route_terminals
				child.terminal_topology_signature = build_building_layout_partial_terminal_topology_signature(context, child)
				insert_building_layout_partial(context, next_beam, child, WORLD_EDIT_BUILDING_ALLOCATION_BEAM_WIDTH)
		if(!length(next_beam))
			var/list/beam_terminal_signatures = list()
			var/list/beam_placements = list()
			for(var/datum/world_edit_building_layout_allocation_partial/blocked_partial as anything in beam)
				if(istype(blocked_partial))
					beam_terminal_signatures += blocked_partial.terminal_topology_signature
					beam_placements += format_building_layout_partial(blocked_partial)
			context.state.add_stage_report("layout_room_enumeration_reject", "failed", "bounded room options exhausted before beam insertion", list(
				"candidate_id" = candidate.id,
				"room_id" = room_contract.id,
				"beam_count" = length(beam),
				"enumerated_option_count" = enumerated_option_count,
				"edge_fit_option_count" = edge_fit_option_count,
				"terminal_fit_option_count" = terminal_fit_option_count,
				"partition_spacing_reject_count" = partition_spacing_reject_count,
				"partition_spacing_reject_rects" = partition_spacing_reject_rects,
				"required_edge_reject_count" = required_edge_reject_count,
				"nested_parent_floor_reject_count" = nested_parent_floor_reject_count,
				"terminal_reject_counts" = islist(context.state.config["layout_partial_terminal_reject_counts"]) ? context.state.config["layout_partial_terminal_reject_counts"].Copy() : list(),
				"beam_terminal_signatures" = beam_terminal_signatures,
				"beam_placements" = beam_placements,
				"zone" = "[zone.x1],[zone.y1]-[zone.x2],[zone.y2]",
				"contract" = "[room_contract.min_width]x[room_contract.min_height]:[room_contract.min_area]-[room_contract.max_area]",
			))
			var/list/failure_errors = result["errors"]
			if(room_contract.required)
				failure_errors += "room.alloc_failed:[room_contract.id]"
			if(length(beam))
				failure_errors += "room.alloc_partial:[format_building_layout_partial(beam[1])]"
			result["partial_expansions"] = partial_expansions
			region_cache["[frontier_variant]"] = result
			return result
		beam = next_beam
	if(!length(beam))
		var/list/beam_errors = result["errors"]
		beam_errors += "room.alloc_beam_empty"
		result["partial_expansions"] = partial_expansions
		region_cache["[frontier_variant]"] = result
		return result
	var/list/feasible_partials = list()
	var/list/feasible_scores = list()
	var/list/evaluation_reports = list()
	var/evaluated_complete_count = 0
	for(var/datum/world_edit_building_layout_allocation_partial/complete_partial as anything in beam)
		if(!istype(complete_partial) || evaluated_complete_count >= WORLD_EDIT_BUILDING_ALLOCATION_BEAM_WIDTH)
			continue
		evaluated_complete_count++
		var/list/evaluation = evaluate_building_layout_complete_partial(context, candidate, complete_partial)
		evaluation_reports += list(evaluation)
		if(evaluation?["feasible"])
			var/complete_score = round(text2num("[evaluation["total_score"]]") || -999999999)
			var/insert_at = length(feasible_partials) + 1
			for(var/rank_index in 1 to length(feasible_scores))
				if(complete_score > feasible_scores[rank_index])
					insert_at = rank_index
					break
			feasible_partials.Insert(insert_at, null)
			feasible_partials[insert_at] = complete_partial
			feasible_scores.Insert(insert_at, complete_score)
	if(!length(feasible_partials))
		var/list/route_errors = result["errors"]
		route_errors += "room.route_partial_unreachable"
		context.state.add_stage_report("layout_complete_partial_evaluation", "failed", "no complete partial passed dry constraints", list("candidate_id" = candidate.id, "feasible_count" = 0, "evaluated" = evaluation_reports))
	result["feasible_partials"] = feasible_partials
	result["feasible_scores"] = feasible_scores
	result["evaluation_reports"] = evaluation_reports
	result["partial_expansions"] = partial_expansions
	result["evaluated_complete_count"] = evaluated_complete_count
	region_cache["[frontier_variant]"] = result
	return result

/datum/world_edit_generator/building_layout/proc/materialize_building_layout_nested_room_ownership(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context) || !istype(candidate?.topology_graph) || !istype(partial))
		return FALSE
	var/list/nested_partition_plan = partial.nested_partition_plan
	if(!islist(nested_partition_plan) || !nested_partition_plan["valid"])
		nested_partition_plan = build_building_layout_partial_nested_partition_plan(context, candidate.topology_graph, partial)
	if(!nested_partition_plan?["valid"])
		return FALSE
	var/list/nested_runs_by_edge = nested_partition_plan["runs_by_edge"]
	var/list/carve_by_parent = list()
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph.edges)
		if(!istype(edge) || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		var/datum/world_edit_building_layout_topology_node/from_node = candidate.topology_graph.get_node(edge.from_id)
		var/datum/world_edit_building_layout_topology_node/to_node = candidate.topology_graph.get_node(edge.to_id)
		var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
		var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
		var/datum/world_edit_building_layout_room_plan/child_plan = candidate.get_room_plan(child_id)
		var/datum/world_edit_building_layout_room_plan/parent_plan = candidate.get_room_plan(parent_id)
		if(!istype(child_plan) || !istype(parent_plan))
			continue
		var/list/carve_lookup = carve_by_parent[parent_id]
		if(!islist(carve_lookup))
			carve_lookup = list()
			carve_by_parent[parent_id] = carve_lookup
		for(var/turf/child_turf as anything in child_plan.turfs)
			carve_lookup[child_turf] = TRUE
		var/list/selected_partition_option = nested_runs_by_edge?[get_building_layout_nested_partition_edge_key(edge)]
		for(var/turf/partition_turf as anything in selected_partition_option?["wall_turfs"])
			if(parent_plan.turf_lookup[partition_turf])
				carve_lookup[partition_turf] = TRUE
	for(var/parent_id as anything in carve_by_parent)
		var/datum/world_edit_building_layout_room_plan/parent_plan = candidate.get_room_plan(parent_id)
		var/list/carve_lookup = carve_by_parent[parent_id]
		if(!istype(parent_plan) || !islist(carve_lookup))
			continue
		for(var/turf/sibling_partition_turf as anything in build_building_layout_partial_nested_sibling_partition_cells(context, candidate.topology_graph, partial, parent_id))
			if(parent_plan.turf_lookup[sibling_partition_turf])
				carve_lookup[sibling_partition_turf] = TRUE
		for(var/turf/carve_turf as anything in carve_lookup)
			if(!parent_plan.turf_lookup[carve_turf])
				continue
			parent_plan.turfs -= carve_turf
			parent_plan.turf_lookup -= carve_turf
	return TRUE

/datum/world_edit_generator/building_layout/proc/format_building_layout_partial(datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(partial))
		return "invalid"
	var/list/parts = list()
	for(var/room_id as anything in partial.placement_order)
		var/list/rect = partial.placements[room_id]
		parts += "[room_id]=[rect?["x1"]],[rect?["y1"]]-[rect?["x2"]],[rect?["y2"]]"
	return jointext(parts, "|")

/datum/world_edit_generator/building_layout/proc/evaluate_building_layout_complete_partial(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial)
	var/list/result = list(
		"placements" = format_building_layout_partial(partial),
		"feasible" = FALSE,
		"route_feasible" = FALSE,
		"family_valid" = FALSE,
		"exterior_partition_valid" = FALSE,
		"partition_spacing_valid" = FALSE,
		"residual" = 0,
		"route_cost" = 0,
		"partition_cost" = 0,
		"partition_edge_report" = list(),
		"terminal_reject_counts" = list(),
		"total_score" = -999999999,
	)
	if(!istype(context) || !istype(candidate) || !istype(partial))
		return result
	context.state.config["layout_partial_terminal_reject_counts"] = list()
	var/route_feasible = building_layout_partial_route_network_possible(context, candidate, partial)
	result["terminal_reject_counts"] = context.state.config["layout_partial_terminal_reject_counts"].Copy()
	var/family_constraints_valid = building_layout_partial_family_constraints_fit(context, candidate, partial)
	var/nested_parent_floor_valid = building_layout_partial_nested_parent_floor_possible(context, candidate, partial)
	var/list/nested_partition_plan = build_building_layout_partial_nested_partition_plan(context, candidate.topology_graph, partial)
	partial.nested_partition_plan = nested_partition_plan
	var/nested_partition_plan_valid = nested_partition_plan?["valid"] ? TRUE : FALSE
	var/family_valid = family_constraints_valid && nested_parent_floor_valid && nested_partition_plan_valid
	var/partition_spacing_valid = building_layout_partial_closed_partition_spacing_valid(context, candidate, partial)
	var/list/assigned_lookup = list()
	var/route_cost = 0
	var/exterior_partition_valid = TRUE
	var/field_x = round((context.local_width() + 1) / 2)
	var/field_y = round((context.local_height() + 1) / 2)
	for(var/room_id as anything in partial.placement_order)
		var/list/rect = partial.placements[room_id]
		if(!islist(rect))
			continue
		for(var/local_x in rect["x1"] to rect["x2"])
			for(var/local_y in rect["y1"] to rect["y2"])
				var/turf/assigned_turf = context.local_turf(local_x, local_y)
				if(istype(assigned_turf))
					assigned_lookup[assigned_turf] = TRUE
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_id)
		if(istype(room_contract) && room_contract.counts_toward_target && (room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE)) && building_layout_room_rect_leaves_single_wall_strip_against_boundary(context, rect))
			exterior_partition_valid = FALSE
		if(istype(room_contract) && room_contract.must_touch_route)
			route_cost += abs(round((rect["x1"] + rect["x2"]) / 2) - field_x) + abs(round((rect["y1"] + rect["y2"]) / 2) - field_y)
	var/residual = max(length(context.state.geometry.interior) - length(assigned_lookup), 0)
	var/partition_cost = estimate_building_layout_partial_partition_cost(candidate.topology_graph, partial)
	var/list/partition_edge_report = list()
	for(var/datum/world_edit_building_layout_topology_edge/partition_edge as anything in candidate.topology_graph?.edges)
		if(!istype(partition_edge) || !partition_edge.required || (partition_edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED)))
			continue
		var/required_overlap = max(partition_edge.min_shared_wall, 1)
		var/actual_overlap = building_layout_rect_partition_overlap(partial.placements[partition_edge.from_id], partial.placements[partition_edge.to_id])
		partition_edge_report += "[partition_edge.from_id]>[partition_edge.to_id]:[partition_edge.edge_kind]:[actual_overlap]/[required_overlap]"
	var/total_score = partial.score - route_cost * 30 - residual * 12 - partition_cost * 200
	result["route_feasible"] = route_feasible
	result["family_constraints_valid"] = family_constraints_valid
	result["nested_parent_floor_valid"] = nested_parent_floor_valid
	result["nested_partition_plan_valid"] = nested_partition_plan_valid
	result["nested_partition_expansions"] = nested_partition_plan?["expansions"] || 0
	result["family_valid"] = family_valid
	result["exterior_partition_valid"] = exterior_partition_valid
	result["partition_spacing_valid"] = partition_spacing_valid
	result["residual"] = residual
	result["route_cost"] = route_cost
	result["partition_cost"] = partition_cost
	result["partition_edge_report"] = partition_edge_report
	result["total_score"] = total_score
	result["feasible"] = route_feasible && family_valid && exterior_partition_valid && partition_spacing_valid && partition_cost <= 0
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_partial_closed_partition_spacing_valid(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context?.program_contract) || !istype(candidate?.topology_graph) || !istype(partial))
		return FALSE
	for(var/first_index in 1 to length(partial.placement_order))
		var/first_id = partial.placement_order[first_index]
		var/list/first_rect = partial.placements[first_id]
		var/datum/world_edit_building_layout_room_contract/first_contract = context.program_contract.get_room_contract(first_id)
		if(!islist(first_rect) || !istype(first_contract) || !(first_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE)))
			continue
		if(first_index >= length(partial.placement_order))
			continue
		for(var/second_index in first_index + 1 to length(partial.placement_order))
			var/second_id = partial.placement_order[second_index]
			var/list/second_rect = partial.placements[second_id]
			var/datum/world_edit_building_layout_room_contract/second_contract = context.program_contract.get_room_contract(second_id)
			if(!islist(second_rect) || !istype(second_contract) || !(second_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE)))
				continue
			if(building_layout_nodes_are_typed_nested_siblings(candidate.topology_graph, first_id, second_id))
				continue
			var/datum/world_edit_building_layout_topology_node/first_node = candidate.topology_graph.get_node(first_id)
			var/datum/world_edit_building_layout_topology_node/second_node = candidate.topology_graph.get_node(second_id)
			// A nested room does not own a perimeter raster. Its only wall is the
			// canonical edge-specific containment segment, so rectangle distance to a
			// room outside the parent cannot imply a parallel-wall canyon. The emitted
			// segment validator remains the authority for actual wall spacing.
			if(building_layout_topology_node_has_nested_parent(candidate.topology_graph, first_node) || building_layout_topology_node_has_nested_parent(candidate.topology_graph, second_node))
				continue
			var/x_overlap = max(min(first_rect["x2"], second_rect["x2"]) - max(first_rect["x1"], second_rect["x1"]) + 1, 0)
			var/y_overlap = max(min(first_rect["y2"], second_rect["y2"]) - max(first_rect["y1"], second_rect["y1"]) + 1, 0)
			var/x_gap = max(max(first_rect["x1"], second_rect["x1"]) - min(first_rect["x2"], second_rect["x2"]) - 1, 0)
			var/y_gap = max(max(first_rect["y1"], second_rect["y1"]) - min(first_rect["y2"], second_rect["y2"]) - 1, 0)
			if((x_overlap > 0 && y_gap == 2) || (y_overlap > 0 && x_gap == 2))
				return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_nodes_are_typed_nested_siblings(datum/world_edit_building_layout_topology_graph/graph, first_id, second_id)
	if(!istype(graph))
		return FALSE
	var/datum/world_edit_building_layout_topology_node/first_node = graph.get_node(first_id)
	var/datum/world_edit_building_layout_topology_node/second_node = graph.get_node(second_id)
	if(!istype(first_node) || !istype(second_node) || !length(first_node.parent_id) || first_node.parent_id != second_node.parent_id)
		return FALSE
	var/datum/world_edit_building_layout_topology_edge/first_parent_edge = get_building_layout_partial_edge(graph, first_id, first_node.parent_id)
	var/datum/world_edit_building_layout_topology_edge/second_parent_edge = get_building_layout_partial_edge(graph, second_id, second_node.parent_id)
	return first_parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED && second_parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED

/datum/world_edit_generator/building_layout/proc/estimate_building_layout_partial_partition_cost(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial)
	var/cost = 0
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph?.edges)
		if(!istype(edge) || !edge.required || (edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED)))
			continue
		var/list/from_rect = partial?.placements[edge.from_id]
		var/list/to_rect = partial?.placements[edge.to_id]
		if(!islist(from_rect) || !islist(to_rect))
			cost += max(edge.min_shared_wall, 1)
			continue
		cost += max(max(edge.min_shared_wall, 1) - building_layout_rect_partition_overlap(from_rect, to_rect), 0)
	return cost

/datum/world_edit_generator/building_layout/proc/building_layout_partial_family_constraints_fit(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial)
	switch(candidate?.family_policy_id)
		if("open_bay_perimeter")
			var/open_bay_count = 0
			var/list/placed_lookup = list()
			for(var/placed_id as anything in partial.placement_order)
				var/list/placed_rect = partial.placements[placed_id]
				for(var/local_x in placed_rect["x1"] to placed_rect["x2"])
					for(var/local_y in placed_rect["y1"] to placed_rect["y2"])
						var/turf/placed_turf = context.local_turf(local_x, local_y)
						if(istype(placed_turf))
							placed_lookup[placed_turf] = TRUE
			var/placed_area = length(placed_lookup)
			for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in context.program_contract?.functional_room_contracts)
				if(room_contract?.spatial_kind != WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
					continue
				var/list/bay_rect = partial.placements[room_contract.id]
				if(!islist(bay_rect))
					return FALSE
				var/bay_floor_area = 0
				for(var/local_x in bay_rect["x1"] to bay_rect["x2"])
					for(var/local_y in bay_rect["y1"] to bay_rect["y2"])
						if(!building_layout_partial_room_cell_carved_by_nested_child(candidate.topology_graph, partial, room_contract.id, local_x, local_y))
							bay_floor_area++
				var/bay_ratio = round(bay_floor_area * 100 / max(length(context.state.geometry.interior), 1))
				var/potential_ratio = round((bay_floor_area + max(length(context.state.geometry.interior) - placed_area, 0)) * 100 / max(length(context.state.geometry.interior), 1))
				if(bay_ratio > 60 || potential_ratio < 35)
					return FALSE
				open_bay_count++
			return open_bay_count == 1
		if("split_wing")
			var/midpoint = candidate.orientation_variant % 2 ? (context.local_height() + 1) / 2 : (context.local_width() + 1) / 2
			var/wing_a = FALSE
			var/wing_b = FALSE
			for(var/room_id as anything in partial.placement_order)
				if(room_id == candidate.topology_graph?.root_node_id)
					continue
				var/datum/world_edit_building_layout_topology_node/room_node = candidate.topology_graph?.get_node(room_id)
				var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(candidate.topology_graph, room_id, room_node?.parent_id)
				if(parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
					continue
				var/list/rect = partial.placements[room_id]
				var/coord = candidate.orientation_variant % 2 ? (rect["y1"] + rect["y2"]) / 2 : (rect["x1"] + rect["x2"]) / 2
				if(coord < midpoint)
					wing_a = TRUE
				else
					wing_b = TRUE
			return wing_a && wing_b
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_nested_parent_floor_possible(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context) || !istype(candidate?.topology_graph) || !istype(partial))
		return FALSE
	for(var/datum/world_edit_building_layout_room_contract/parent_contract as anything in context.program_contract?.functional_room_contracts)
		if(!istype(parent_contract) || parent_contract.nested_parent_floor_min_area <= 0)
			continue
		var/list/parent_rect = partial.placements[parent_contract.id]
		if(!islist(parent_rect))
			return FALSE
		var/list/free_lookup = list()
		for(var/local_x in parent_rect["x1"] to parent_rect["x2"])
			for(var/local_y in parent_rect["y1"] to parent_rect["y2"])
				var/blocked = FALSE
				for(var/datum/world_edit_building_layout_topology_node/child_node as anything in candidate.topology_graph.nodes)
					if(!istype(child_node) || child_node.parent_id != parent_contract.id)
						continue
					var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(candidate.topology_graph, child_node.id, parent_contract.id)
					if(parent_edge?.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
						continue
					var/list/child_rect = partial.placements[child_node.id]
					if(islist(child_rect) && local_x >= child_rect["x1"] && local_x <= child_rect["x2"] && local_y >= child_rect["y1"] && local_y <= child_rect["y2"])
						blocked = TRUE
						break
				if(!blocked)
					var/turf/free_turf = context.local_turf(local_x, local_y)
					if(istype(free_turf))
						free_lookup[free_turf] = TRUE
		// Beam guidance remains edge-local: it preserves enough parent floor while
		// sibling geometry is still changing. Mutual NESTED compatibility is a
		// complete-partial hard gate below and the committed plan at materialization.
		for(var/datum/world_edit_building_layout_topology_edge/nested_edge as anything in candidate.topology_graph.edges)
			if(!istype(nested_edge) || nested_edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED || !(parent_contract.id in list(nested_edge.from_id, nested_edge.to_id)))
				continue
			if(!islist(partial.placements[nested_edge.from_id]) || !islist(partial.placements[nested_edge.to_id]))
				continue
			var/list/nested_partition_turfs = build_building_layout_partial_nested_partition_run_cells_independent(context, candidate.topology_graph, partial, nested_edge)
			if(length(nested_partition_turfs) < get_building_layout_nested_required_partition_run(context, nested_edge))
				return FALSE
			for(var/turf/partition_turf as anything in nested_partition_turfs)
				free_lookup -= partition_turf
		for(var/turf/sibling_partition_turf as anything in build_building_layout_partial_nested_sibling_partition_cells(context, candidate.topology_graph, partial, parent_contract.id))
			free_lookup -= sibling_partition_turf
		var/largest_component = 0
		var/list/visited = list()
		for(var/turf/seed_turf as anything in free_lookup)
			if(visited[seed_turf])
				continue
			var/component_size = 0
			var/list/open = list(seed_turf)
			visited[seed_turf] = TRUE
			var/open_index = 1
			while(open_index <= length(open))
				var/turf/current = open[open_index++]
				component_size++
				for(var/check_dir in GLOB.cardinals)
					var/turf/nearby = get_step(current, check_dir)
					if(!free_lookup[nearby] || visited[nearby])
						continue
					visited[nearby] = TRUE
					open += nearby
			largest_component = max(largest_component, component_size)
		if(largest_component < parent_contract.nested_parent_floor_min_area)
			report_building_layout_nested_parent_floor_reject(context, candidate, partial, parent_contract.id, "component_area", length(free_lookup), largest_component, FALSE)
			return FALSE
		var/required_short = max(parent_contract.min_composition_short_side, parent_contract.nested_parent_floor_min_width, 1)
		var/required_long = max(parent_contract.min_composition_long_side, parent_contract.nested_parent_floor_min_height, required_short)
		var/rect_fit = building_layout_free_lookup_has_rect(context, free_lookup, parent_rect, required_short, required_long) || building_layout_free_lookup_has_rect(context, free_lookup, parent_rect, required_long, required_short)
		if(!rect_fit)
			report_building_layout_nested_parent_floor_reject(context, candidate, partial, parent_contract.id, "composition_rect", length(free_lookup), largest_component, FALSE)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/report_building_layout_nested_parent_floor_reject(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, parent_id, reject_kind, free_area, largest_component, rect_fit)
	if(!istype(context?.state))
		return
	var/debug_count = round(text2num("[context.state.config["layout_nested_parent_floor_debug_count"]]") || 0)
	if(debug_count >= 16)
		return
	context.state.config["layout_nested_parent_floor_debug_count"] = debug_count + 1
	var/datum/world_edit_building_layout_room_contract/parent_contract = context.program_contract?.get_room_contract(parent_id)
	context.state.add_stage_report("layout_nested_parent_floor_reject", "failed", "nested parent floor invariant rejected allocation partial", list(
		"candidate_id" = candidate?.id,
		"parent_id" = "[parent_id]",
		"reject_kind" = "[reject_kind]",
		"free_area" = free_area,
		"largest_component" = largest_component,
		"required_area" = parent_contract?.nested_parent_floor_min_area || 0,
		"required_width" = parent_contract?.nested_parent_floor_min_width || 0,
		"required_height" = parent_contract?.nested_parent_floor_min_height || 0,
		"rect_fit" = rect_fit ? TRUE : FALSE,
		"placements" = format_building_layout_partial(partial),
	))

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_nested_partition_run_cells_independent(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_topology_edge/edge)
	var/list/result = list()
	if(!istype(context) || !istype(graph) || !istype(partial) || !istype(edge) || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
		return result
	var/datum/world_edit_building_layout_topology_node/from_node = graph.get_node(edge.from_id)
	var/datum/world_edit_building_layout_topology_node/to_node = graph.get_node(edge.to_id)
	var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
	var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
	var/list/child_rect = partial.placements[child_id]
	if(!islist(child_rect) || !islist(partial.placements[parent_id]))
		return result
	var/list/runs = list()
	var/list/current_run = list()
	for(var/local_y in child_rect["y1"] to child_rect["y2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, child_rect["x1"] - 1, local_y, child_rect["x1"] - 2, local_y))
			current_run += context.local_turf(child_rect["x1"] - 1, local_y)
		else if(length(current_run))
			runs += list(current_run)
			current_run = list()
	if(length(current_run))
		runs += list(current_run)
	current_run = list()
	for(var/local_y in child_rect["y1"] to child_rect["y2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, child_rect["x2"] + 1, local_y, child_rect["x2"] + 2, local_y))
			current_run += context.local_turf(child_rect["x2"] + 1, local_y)
		else if(length(current_run))
			runs += list(current_run)
			current_run = list()
	if(length(current_run))
		runs += list(current_run)
	current_run = list()
	for(var/local_x in child_rect["x1"] to child_rect["x2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y1"] - 1, local_x, child_rect["y1"] - 2))
			current_run += context.local_turf(local_x, child_rect["y1"] - 1)
		else if(length(current_run))
			runs += list(current_run)
			current_run = list()
	if(length(current_run))
		runs += list(current_run)
	current_run = list()
	for(var/local_x in child_rect["x1"] to child_rect["x2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y2"] + 1, local_x, child_rect["y2"] + 2))
			current_run += context.local_turf(local_x, child_rect["y2"] + 1)
		else if(length(current_run))
			runs += list(current_run)
			current_run = list()
	if(length(current_run))
		runs += list(current_run)
	var/required_run = get_building_layout_nested_required_partition_run(context, edge)
	var/list/primary_run = null
	for(var/list/run as anything in runs)
		if(length(run) < required_run)
			continue
		if(!islist(primary_run) || length(run) > length(primary_run))
			primary_run = run
	if(!islist(primary_run))
		return result
	for(var/turf/run_turf as anything in primary_run)
		if(istype(run_turf))
			result |= run_turf
	var/datum/world_edit_building_layout_room_contract/child_contract = context.program_contract?.get_room_contract(child_id)
	var/required_wall_frontage = max(child_contract?.min_wall_frontage || 0, 0)
	var/opening_clearance_width = max(edge.min_opening_width, 1)
	if(edge.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR))
		var/list/cone_profile = get_building_internal_door_cone_profile(context.state)
		var/lateral_radius = length(cone_profile) ? max(round(text2num("[cone_profile[1]]") || 0), 0) : 0
		opening_clearance_width += lateral_radius * 2
	var/primary_wall_frontage = max(length(primary_run) - opening_clearance_width, 0)
	if(required_wall_frontage > primary_wall_frontage)
		var/list/secondary_run = null
		for(var/list/run as anything in runs)
			if(run == primary_run || length(run) < required_wall_frontage)
				continue
			if(!islist(secondary_run) || length(run) > length(secondary_run))
				secondary_run = run
		if(!islist(secondary_run))
			return list()
		for(var/turf/run_turf as anything in secondary_run)
			if(istype(run_turf))
				result |= run_turf
	return result

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_nested_partition_plan(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial)
	var/list/result = list("valid" = FALSE, "runs_by_edge" = list())
	if(!istype(context) || !istype(graph) || !istype(partial))
		return result
	var/list/nested_edges = list()
	var/list/options_by_edge = list()
	var/list/sibling_wall_lookup = list()
	var/list/seen_parents = list()
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.edges)
		if(!istype(edge) || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED || !islist(partial.placements[edge.from_id]) || !islist(partial.placements[edge.to_id]))
			continue
		var/edge_key = get_building_layout_nested_partition_edge_key(edge)
		var/list/options = build_building_layout_partial_nested_partition_options(context, graph, partial, edge)
		if(!length(options))
			return result
		nested_edges += edge
		options_by_edge[edge_key] = options
		var/datum/world_edit_building_layout_topology_node/from_node = graph.get_node(edge.from_id)
		var/datum/world_edit_building_layout_topology_node/to_node = graph.get_node(edge.to_id)
		var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
		var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
		if(!seen_parents[parent_id])
			seen_parents[parent_id] = TRUE
			for(var/turf/sibling_wall as anything in build_building_layout_partial_nested_sibling_partition_cells(context, graph, partial, parent_id))
				if(istype(sibling_wall))
					sibling_wall_lookup[sibling_wall] = TRUE
	var/list/floor_reservation_options = build_building_layout_partial_parent_floor_reservation_options(context, graph, partial, sibling_wall_lookup, 12)
	if(!length(floor_reservation_options))
		return result
	var/total_expansions = 0
	for(var/list/floor_reservation as anything in floor_reservation_options)
		var/list/selected_by_edge = list()
		var/list/search_state = list("expansions" = 0, "max_expansions" = 512)
		if(!assign_building_layout_partial_nested_partition_options(context, graph, partial, nested_edges, options_by_edge, 1, sibling_wall_lookup, list(), floor_reservation, selected_by_edge, search_state))
			total_expansions += search_state["expansions"] || 0
			continue
		total_expansions += search_state["expansions"] || 0
		result["valid"] = TRUE
		result["runs_by_edge"] = selected_by_edge
		break
	result["expansions"] = total_expansions
	return result

/datum/world_edit_generator/building_layout/proc/get_building_layout_nested_partition_edge_key(datum/world_edit_building_layout_topology_edge/edge)
	return istype(edge) ? "[edge.from_id]|[edge.to_id]" : ""

/datum/world_edit_generator/building_layout/proc/assign_building_layout_partial_nested_partition_options(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, list/nested_edges, list/options_by_edge, edge_index, list/sibling_wall_lookup, list/selected_wall_lookup, list/parent_lookup, list/selected_by_edge, list/search_state)
	if(edge_index > length(nested_edges))
		var/list/committed_wall_lookup = sibling_wall_lookup.Copy()
		for(var/turf/selected_wall as anything in selected_wall_lookup)
			committed_wall_lookup[selected_wall] = TRUE
		return building_layout_partial_nested_partition_selection_preserves_parent_floor(context, graph, partial, selected_by_edge, committed_wall_lookup)
	var/datum/world_edit_building_layout_topology_edge/edge = nested_edges[edge_index]
	var/edge_key = get_building_layout_nested_partition_edge_key(edge)
	var/list/options = options_by_edge[edge_key]
	for(var/list/option as anything in options)
		if((search_state["expansions"] || 0) >= (search_state["max_expansions"] || 4096))
			return FALSE
		search_state["expansions"] = (search_state["expansions"] || 0) + 1
		var/list/option_walls = option?["wall_turfs"]
		var/list/option_primary_walls = option?["primary_wall_turfs"]
		var/list/option_frontage_walls = option?["frontage_wall_turfs"]
		var/list/option_parent_turfs = option?["parent_turfs"]
		if(!islist(option_walls) || !length(option_walls) || !islist(option_primary_walls) || !length(option_primary_walls) || !islist(option_frontage_walls) || !islist(option_parent_turfs))
			continue
		var/conflicts = FALSE
		// A typed NESTED threshold must face real parent floor. It cannot consume a
		// sibling wall, another committed wall, or a protected parent/composition
		// cell. Secondary authored frontage is different: it may deliberately reuse
		// the canonical wall between two nested siblings.
		for(var/turf/primary_wall_turf as anything in option_primary_walls)
			if(sibling_wall_lookup[primary_wall_turf] || selected_wall_lookup[primary_wall_turf] || parent_lookup[primary_wall_turf])
				conflicts = TRUE
				break
		if(conflicts)
			continue
		for(var/turf/parent_turf as anything in option_parent_turfs)
			if(sibling_wall_lookup[parent_turf] || selected_wall_lookup[parent_turf])
				conflicts = TRUE
				break
		if(conflicts)
			continue
		for(var/turf/frontage_wall_turf as anything in option_frontage_walls)
			if(parent_lookup[frontage_wall_turf] && !sibling_wall_lookup[frontage_wall_turf])
				conflicts = TRUE
				break
		if(conflicts)
			continue
		var/list/next_wall_lookup = selected_wall_lookup.Copy()
		var/list/next_parent_lookup = parent_lookup.Copy()
		for(var/turf/wall_turf as anything in option_walls)
			next_wall_lookup[wall_turf] = TRUE
		for(var/turf/parent_turf as anything in option_parent_turfs)
			next_parent_lookup[parent_turf] = TRUE
		selected_by_edge[edge_key] = option
		if(assign_building_layout_partial_nested_partition_options(context, graph, partial, nested_edges, options_by_edge, edge_index + 1, sibling_wall_lookup, next_wall_lookup, next_parent_lookup, selected_by_edge, search_state))
			return TRUE
		selected_by_edge -= edge_key
	return FALSE

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_parent_floor_reservation_options(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, list/sibling_wall_lookup, option_limit = 12)
	var/list/combined_options = list(list())
	if(!istype(context) || !istype(graph) || !istype(partial) || option_limit <= 0)
		return list()
	for(var/datum/world_edit_building_layout_room_contract/parent_contract as anything in context.program_contract?.functional_room_contracts)
		if(!istype(parent_contract) || parent_contract.nested_parent_floor_min_area <= 0 || !islist(partial.placements[parent_contract.id]))
			continue
		var/list/parent_options = build_building_layout_partial_single_parent_floor_reservations(context, graph, partial, sibling_wall_lookup, parent_contract, option_limit)
		if(!length(parent_options))
			return list()
		var/list/next_combined_options = list()
		for(var/list/existing_option as anything in combined_options)
			for(var/list/parent_option as anything in parent_options)
				var/list/combined = existing_option.Copy()
				for(var/turf/reserved_turf as anything in parent_option)
					combined[reserved_turf] = TRUE
				next_combined_options += list(combined)
				if(length(next_combined_options) >= option_limit)
					break
			if(length(next_combined_options) >= option_limit)
				break
		combined_options = next_combined_options
	return combined_options

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_single_parent_floor_reservations(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, list/sibling_wall_lookup, datum/world_edit_building_layout_room_contract/parent_contract, option_limit)
	var/list/result = list()
	var/list/parent_rect = partial?.placements[parent_contract?.id]
	if(!istype(context) || !istype(graph) || !islist(parent_rect) || option_limit <= 0)
		return result
	var/list/free_lookup = list()
	for(var/local_x in parent_rect["x1"] to parent_rect["x2"])
		for(var/local_y in parent_rect["y1"] to parent_rect["y2"])
			var/turf/free_turf = context.local_turf(local_x, local_y)
			if(istype(free_turf) && !sibling_wall_lookup?[free_turf])
				free_lookup[free_turf] = TRUE
	for(var/datum/world_edit_building_layout_topology_node/child_node as anything in graph.nodes)
		if(!istype(child_node) || child_node.parent_id != parent_contract.id)
			continue
		var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(graph, child_node.id, parent_contract.id)
		var/list/child_rect = partial.placements[child_node.id]
		if(parent_edge?.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED || !islist(child_rect))
			continue
		for(var/local_x in child_rect["x1"] to child_rect["x2"])
			for(var/local_y in child_rect["y1"] to child_rect["y2"])
				free_lookup -= context.local_turf(local_x, local_y)
	var/required_short = max(parent_contract.min_composition_short_side, parent_contract.nested_parent_floor_min_width, 1)
	var/required_long = max(parent_contract.min_composition_long_side, parent_contract.nested_parent_floor_min_height, required_short)
	var/list/dimensions = list(list(required_short, required_long))
	if(required_short != required_long)
		dimensions += list(list(required_long, required_short))
	for(var/list/dimension as anything in dimensions)
		var/rect_width = dimension[1]
		var/rect_height = dimension[2]
		for(var/local_x1 in parent_rect["x1"] to parent_rect["x2"] - rect_width + 1)
			for(var/local_y1 in parent_rect["y1"] to parent_rect["y2"] - rect_height + 1)
				var/list/reservation = list()
				var/fits = TRUE
				for(var/local_x in local_x1 to local_x1 + rect_width - 1)
					for(var/local_y in local_y1 to local_y1 + rect_height - 1)
						var/turf/check_turf = context.local_turf(local_x, local_y)
						if(!free_lookup[check_turf])
							fits = FALSE
							break
						reservation[check_turf] = TRUE
					if(!fits)
						break
				if(fits)
					result += list(reservation)
	if(length(result) <= option_limit)
		return result
	var/list/distributed_result = list()
	for(var/sample_index in 1 to option_limit)
		var/source_index = option_limit == 1 ? round((length(result) + 1) / 2) : round(1 + (sample_index - 1) * (length(result) - 1) / (option_limit - 1))
		distributed_result += list(result[clamp(source_index, 1, length(result))])
	return distributed_result

/datum/world_edit_generator/building_layout/proc/building_layout_partial_nested_partition_selection_preserves_parent_floor(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, list/selected_by_edge, list/wall_lookup)
	if(!istype(context) || !istype(graph) || !istype(partial) || !islist(selected_by_edge) || !islist(wall_lookup))
		return FALSE
	for(var/datum/world_edit_building_layout_room_contract/parent_contract as anything in context.program_contract?.functional_room_contracts)
		if(!istype(parent_contract) || parent_contract.nested_parent_floor_min_area <= 0)
			continue
		var/list/parent_rect = partial.placements[parent_contract.id]
		if(!islist(parent_rect))
			continue
		var/list/free_lookup = list()
		for(var/local_x in parent_rect["x1"] to parent_rect["x2"])
			for(var/local_y in parent_rect["y1"] to parent_rect["y2"])
				var/turf/free_turf = context.local_turf(local_x, local_y)
				if(istype(free_turf))
					free_lookup[free_turf] = TRUE
		for(var/datum/world_edit_building_layout_topology_node/child_node as anything in graph.nodes)
			if(!istype(child_node) || child_node.parent_id != parent_contract.id)
				continue
			var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(graph, child_node.id, parent_contract.id)
			var/list/child_rect = partial.placements[child_node.id]
			if(parent_edge?.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED || !islist(child_rect))
				continue
			for(var/local_x in child_rect["x1"] to child_rect["x2"])
				for(var/local_y in child_rect["y1"] to child_rect["y2"])
					free_lookup -= context.local_turf(local_x, local_y)
		for(var/turf/wall_turf as anything in wall_lookup)
			free_lookup -= wall_turf
		var/largest_component = 0
		var/list/visited = list()
		for(var/turf/seed_turf as anything in free_lookup)
			if(visited[seed_turf])
				continue
			var/component_size = 0
			var/list/open = list(seed_turf)
			visited[seed_turf] = TRUE
			var/open_index = 1
			while(open_index <= length(open))
				var/turf/current = open[open_index++]
				component_size++
				for(var/check_dir in GLOB.cardinals)
					var/turf/nearby = get_step(current, check_dir)
					if(!free_lookup[nearby] || visited[nearby])
						continue
					visited[nearby] = TRUE
					open += nearby
			largest_component = max(largest_component, component_size)
		if(largest_component < parent_contract.nested_parent_floor_min_area)
			return FALSE
		var/required_short = max(parent_contract.min_composition_short_side, parent_contract.nested_parent_floor_min_width, 1)
		var/required_long = max(parent_contract.min_composition_long_side, parent_contract.nested_parent_floor_min_height, required_short)
		if(!building_layout_free_lookup_has_rect(context, free_lookup, parent_rect, required_short, required_long) && !building_layout_free_lookup_has_rect(context, free_lookup, parent_rect, required_long, required_short))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_nested_partition_options(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_topology_edge/edge)
	var/list/result = list()
	if(!istype(context) || !istype(graph) || !istype(partial) || !istype(edge) || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
		return result
	var/datum/world_edit_building_layout_topology_node/from_node = graph.get_node(edge.from_id)
	var/datum/world_edit_building_layout_topology_node/to_node = graph.get_node(edge.to_id)
	var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
	var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
	var/list/child_rect = partial.placements[child_id]
	if(!islist(child_rect) || !islist(partial.placements[parent_id]))
		return result
	var/list/runs = list()
	var/list/frontage_runs = list()
	var/list/current_walls = list()
	var/list/current_parent_turfs = list()
	var/list/current_frontage_walls = list()
	for(var/local_y in child_rect["y1"] to child_rect["y2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, child_rect["x1"] - 1, local_y, child_rect["x1"] - 2, local_y))
			current_walls += context.local_turf(child_rect["x1"] - 1, local_y)
			current_parent_turfs += context.local_turf(child_rect["x1"] - 2, local_y)
		else if(length(current_walls))
			runs += list(list("side_id" = "left", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
			current_walls = list()
			current_parent_turfs = list()
		if(building_layout_partial_nested_frontage_cell_available(graph, partial, child_id, parent_id, child_rect["x1"] - 1, local_y, child_rect["x1"] - 2, local_y))
			current_frontage_walls += context.local_turf(child_rect["x1"] - 1, local_y)
		else if(length(current_frontage_walls))
			frontage_runs += list(list("side_id" = "left", "wall_turfs" = current_frontage_walls))
			current_frontage_walls = list()
	if(length(current_walls))
		runs += list(list("side_id" = "left", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
	if(length(current_frontage_walls))
		frontage_runs += list(list("side_id" = "left", "wall_turfs" = current_frontage_walls))
	current_walls = list()
	current_parent_turfs = list()
	current_frontage_walls = list()
	for(var/local_y in child_rect["y1"] to child_rect["y2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, child_rect["x2"] + 1, local_y, child_rect["x2"] + 2, local_y))
			current_walls += context.local_turf(child_rect["x2"] + 1, local_y)
			current_parent_turfs += context.local_turf(child_rect["x2"] + 2, local_y)
		else if(length(current_walls))
			runs += list(list("side_id" = "right", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
			current_walls = list()
			current_parent_turfs = list()
		if(building_layout_partial_nested_frontage_cell_available(graph, partial, child_id, parent_id, child_rect["x2"] + 1, local_y, child_rect["x2"] + 2, local_y))
			current_frontage_walls += context.local_turf(child_rect["x2"] + 1, local_y)
		else if(length(current_frontage_walls))
			frontage_runs += list(list("side_id" = "right", "wall_turfs" = current_frontage_walls))
			current_frontage_walls = list()
	if(length(current_walls))
		runs += list(list("side_id" = "right", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
	if(length(current_frontage_walls))
		frontage_runs += list(list("side_id" = "right", "wall_turfs" = current_frontage_walls))
	current_walls = list()
	current_parent_turfs = list()
	current_frontage_walls = list()
	for(var/local_x in child_rect["x1"] to child_rect["x2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y1"] - 1, local_x, child_rect["y1"] - 2))
			current_walls += context.local_turf(local_x, child_rect["y1"] - 1)
			current_parent_turfs += context.local_turf(local_x, child_rect["y1"] - 2)
		else if(length(current_walls))
			runs += list(list("side_id" = "bottom", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
			current_walls = list()
			current_parent_turfs = list()
		if(building_layout_partial_nested_frontage_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y1"] - 1, local_x, child_rect["y1"] - 2))
			current_frontage_walls += context.local_turf(local_x, child_rect["y1"] - 1)
		else if(length(current_frontage_walls))
			frontage_runs += list(list("side_id" = "bottom", "wall_turfs" = current_frontage_walls))
			current_frontage_walls = list()
	if(length(current_walls))
		runs += list(list("side_id" = "bottom", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
	if(length(current_frontage_walls))
		frontage_runs += list(list("side_id" = "bottom", "wall_turfs" = current_frontage_walls))
	current_walls = list()
	current_parent_turfs = list()
	current_frontage_walls = list()
	for(var/local_x in child_rect["x1"] to child_rect["x2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y2"] + 1, local_x, child_rect["y2"] + 2))
			current_walls += context.local_turf(local_x, child_rect["y2"] + 1)
			current_parent_turfs += context.local_turf(local_x, child_rect["y2"] + 2)
		else if(length(current_walls))
			runs += list(list("side_id" = "top", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
			current_walls = list()
			current_parent_turfs = list()
		if(building_layout_partial_nested_frontage_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y2"] + 1, local_x, child_rect["y2"] + 2))
			current_frontage_walls += context.local_turf(local_x, child_rect["y2"] + 1)
		else if(length(current_frontage_walls))
			frontage_runs += list(list("side_id" = "top", "wall_turfs" = current_frontage_walls))
			current_frontage_walls = list()
	if(length(current_walls))
		runs += list(list("side_id" = "top", "wall_turfs" = current_walls, "parent_turfs" = current_parent_turfs))
	if(length(current_frontage_walls))
		frontage_runs += list(list("side_id" = "top", "wall_turfs" = current_frontage_walls))
	var/required_run = get_building_layout_nested_required_partition_run(context, edge)
	// NESTED owns an edge-specific threshold, not a universal reservation ring.
	// Enumerate the bounded set of exact primary/secondary straight runs. The
	// parent-level backtracker selects one mutually compatible option per typed
	// edge, so a sibling wall can never masquerade as parent-owned floor.
	var/datum/world_edit_building_layout_room_contract/child_contract = context.program_contract?.get_room_contract(child_id)
	var/required_wall_frontage = max(child_contract?.min_wall_frontage || 0, 0)
	var/opening_clearance_width = max(edge.min_opening_width, 1)
	if(edge.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR))
		var/list/cone_profile = get_building_internal_door_cone_profile(context.state)
		var/lateral_radius = length(cone_profile) ? max(round(text2num("[cone_profile[1]]") || 0), 0) : 0
		opening_clearance_width += lateral_radius * 2
	var/max_run_length = 0
	for(var/list/run as anything in runs)
		max_run_length = max(max_run_length, length(run?["wall_turfs"]))
	// Prefer the shortest complete contract. Longer primary windows remain bounded
	// alternatives when they can carry both the opening and authored frontage.
	for(var/primary_length in required_run to max_run_length)
		for(var/list/primary_run as anything in runs)
			var/list/available_primary_walls = primary_run?["wall_turfs"]
			var/list/available_primary_parent_turfs = primary_run?["parent_turfs"]
			if(length(available_primary_walls) < primary_length)
				continue
			for(var/primary_start in 1 to length(available_primary_walls) - primary_length + 1)
				var/list/primary_walls = available_primary_walls.Copy(primary_start, primary_start + primary_length)
				var/list/primary_parent_turfs = available_primary_parent_turfs.Copy(primary_start, primary_start + primary_length)
				var/primary_wall_frontage = max(primary_length - opening_clearance_width, 0)
				if(required_wall_frontage <= primary_wall_frontage)
					result += list(list("wall_turfs" = primary_walls, "primary_wall_turfs" = primary_walls.Copy(), "frontage_wall_turfs" = list(), "parent_turfs" = primary_parent_turfs))
					continue
				for(var/list/secondary_run as anything in frontage_runs)
					var/list/available_secondary_walls = secondary_run?["wall_turfs"]
					if(secondary_run?["side_id"] == primary_run?["side_id"] || length(available_secondary_walls) < required_wall_frontage)
						continue
					for(var/secondary_start in 1 to length(available_secondary_walls) - required_wall_frontage + 1)
						var/list/combined_walls = primary_walls.Copy()
						var/list/combined_parent_turfs = primary_parent_turfs.Copy()
						var/list/frontage_walls = list()
						for(var/secondary_index in secondary_start to secondary_start + required_wall_frontage - 1)
							combined_walls |= available_secondary_walls[secondary_index]
							frontage_walls |= available_secondary_walls[secondary_index]
						// The secondary segment is authored composition frontage, not a
						// second NESTED threshold. It must remain a canonical wall but may
						// face a sibling/residual owner; only the primary run reserves an
						// actual parent-owned side for the typed child -> parent edge.
						result += list(list("wall_turfs" = combined_walls, "primary_wall_turfs" = primary_walls.Copy(), "frontage_wall_turfs" = frontage_walls, "parent_turfs" = combined_parent_turfs))
					if(length(available_secondary_walls) > required_wall_frontage)
						var/list/full_frontage_walls = primary_walls.Copy()
						for(var/turf/secondary_wall as anything in available_secondary_walls)
							full_frontage_walls |= secondary_wall
						result += list(list("wall_turfs" = full_frontage_walls, "primary_wall_turfs" = primary_walls.Copy(), "frontage_wall_turfs" = available_secondary_walls.Copy(), "parent_turfs" = primary_parent_turfs.Copy()))
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_partial_nested_frontage_cell_available(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, child_id, parent_id, wall_x, wall_y, opposite_x, opposite_y)
	var/list/parent_rect = partial?.placements[parent_id]
	if(!islist(parent_rect) || wall_x < parent_rect["x1"] || wall_x > parent_rect["x2"] || wall_y < parent_rect["y1"] || wall_y > parent_rect["y2"] || opposite_x < parent_rect["x1"] || opposite_x > parent_rect["x2"] || opposite_y < parent_rect["y1"] || opposite_y > parent_rect["y2"])
		return FALSE
	// The wall itself must remain outside every child footprint. The cell across
	// it may belong either to the parent or to a typed NESTED sibling: in both
	// cases this is one canonical straight partition usable as authored frontage.
	for(var/datum/world_edit_building_layout_topology_node/node as anything in graph?.nodes)
		if(!istype(node) || node.parent_id != parent_id || node.id == child_id || !building_layout_nodes_are_typed_nested_siblings(graph, child_id, node.id))
			continue
		var/list/sibling_rect = partial?.placements[node.id]
		if(islist(sibling_rect) && wall_x >= sibling_rect["x1"] && wall_x <= sibling_rect["x2"] && wall_y >= sibling_rect["y1"] && wall_y <= sibling_rect["y2"])
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_nested_sibling_partition_cells(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, parent_id)
	var/list/result = list()
	if(!istype(context) || !istype(graph) || !istype(partial) || !length("[parent_id]"))
		return result
	var/list/children = list()
	for(var/datum/world_edit_building_layout_topology_node/node as anything in graph.nodes)
		var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(graph, node?.id, parent_id)
		if(istype(node) && node.parent_id == parent_id && parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED && islist(partial.placements[node.id]))
			children += node.id
	for(var/first_index in 1 to length(children))
		var/list/first_rect = partial.placements[children[first_index]]
		if(first_index >= length(children))
			continue
		for(var/second_index in first_index + 1 to length(children))
			var/list/second_rect = partial.placements[children[second_index]]
			var/x_overlap_start = max(first_rect["x1"], second_rect["x1"])
			var/x_overlap_end = min(first_rect["x2"], second_rect["x2"])
			if(x_overlap_start <= x_overlap_end && (first_rect["y2"] + 2 == second_rect["y1"] || second_rect["y2"] + 2 == first_rect["y1"]))
				var/wall_y = min(first_rect["y2"], second_rect["y2"]) + 1
				for(var/local_x in x_overlap_start to x_overlap_end)
					result |= context.local_turf(local_x, wall_y)
			var/y_overlap_start = max(first_rect["y1"], second_rect["y1"])
			var/y_overlap_end = min(first_rect["y2"], second_rect["y2"])
			if(y_overlap_start <= y_overlap_end && (first_rect["x2"] + 2 == second_rect["x1"] || second_rect["x2"] + 2 == first_rect["x1"]))
				var/wall_x = min(first_rect["x2"], second_rect["x2"]) + 1
				for(var/local_y in y_overlap_start to y_overlap_end)
					result |= context.local_turf(wall_x, local_y)
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_free_lookup_has_rect(datum/world_edit_building_layout_context/context, list/free_lookup, list/bounds, rect_width, rect_height)
	if(!istype(context) || !islist(free_lookup) || !islist(bounds) || rect_width <= 0 || rect_height <= 0)
		return FALSE
	for(var/local_x1 in bounds["x1"] to bounds["x2"] - rect_width + 1)
		for(var/local_y1 in bounds["y1"] to bounds["y2"] - rect_height + 1)
			var/fits = TRUE
			for(var/local_x in local_x1 to local_x1 + rect_width - 1)
				for(var/local_y in local_y1 to local_y1 + rect_height - 1)
					if(!free_lookup[context.local_turf(local_x, local_y)])
						fits = FALSE
						break
				if(!fits)
					break
			if(fits)
				return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/get_building_layout_contract_seed_zone(datum/world_edit_building_layout_region_candidate/region, room_id)
	if(!istype(region))
		return null
	for(var/datum/world_edit_building_layout_influence_zone/zone as anything in region.influence_zones)
		if(istype(zone) && "[room_id]" in zone.preferred_room_contracts)
			return zone
	return null

/datum/world_edit_generator/building_layout/proc/enumerate_building_layout_room_rects(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_influence_zone/zone, datum/world_edit_building_layout_room_contract/room_contract, allocation_variant = 0)
	var/list/result = list()
	if(!istype(context) || !istype(candidate) || !istype(partial) || !istype(zone) || !istype(room_contract))
		return result
	// The authored preferred area applies to the primary instance.  Repeated
	// instances are already composition-sized by the compiler; targeting that
	// hard-safe minimum keeps the bounded beam from spending the whole footprint
	// on the first copies and then failing the final required sibling.
	var/target_area = room_contract.preferred_area
	var/datum/world_edit_building_layout_topology_node/room_node = candidate.topology_graph?.get_node(room_contract.id)
	var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(candidate.topology_graph, room_contract.id, room_node?.parent_id)
	var/is_nested_child = parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED
	if(is_nested_child)
		target_area = room_contract.min_area
	switch(allocation_variant)
		if(1)
			target_area = room_contract.min_area
		if(2)
			// Compact-frontier order is meaningful only with the authored hard-safe
			// footprints; inflating the early rooms would consume the frontage it is
			// specifically intended to preserve for a complete partial.
			target_area = room_contract.min_area
		if(3)
			// The residual frontier grows only the topology root toward useful
			// coverage. Growing every required sibling to its independent maximum
			// cannot form a complete packing and therefore never reaches the bounded
			// complete-partial evaluation that owns the residual decision.
			target_area = room_contract.min_area
			if(room_contract.id == candidate.topology_graph?.root_node_id)
				target_area = min(room_contract.max_area, max(room_contract.preferred_area, round(length(context.state.geometry.interior) * 0.30)))
	if(candidate.family_policy_id == "open_bay_perimeter" && room_contract.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
		// Allocate only the authored module-sized core. The explicit bay owner may
		// absorb connected residual after all perimeter rooms and route terminals
		// have become hard owners.
		target_area = room_contract.preferred_area
	var/list/size_variants = build_building_layout_room_size_variants(room_contract, target_area, allocation_variant)
	var/nested_compact_area = 0
	if(is_nested_child && length(size_variants))
		var/list/compact_variant = size_variants[1]
		nested_compact_area = round(text2num("[compact_variant?["w"]]") || 0) * round(text2num("[compact_variant?["h"]]") || 0)
	var/shape_valid_count = 0
	var/footprint_valid_count = 0
	var/conflict_reject_count = 0
	var/list/conflict_reject_rects = list()
	var/edge_reject_count = 0
	var/direct_edge_reject_count = 0
	var/existing_edge_reject_count = 0
	var/list/edge_reject_rects = list()
	var/pending_edge_reject_count = 0
	var/list/pending_edge_reject_rects = list()
	var/terminal_feasibility_reject_count = 0
	var/list/terminal_feasibility_reject_rects = list()
	var/family_reject_count = 0
	var/list/family_reject_rects = list()
	for(var/list/size_variant as anything in size_variants)
		var/room_w = round(text2num("[size_variant?["w"]]") || 0)
		var/room_h = round(text2num("[size_variant?["h"]]") || 0)
		if(is_nested_child && nested_compact_area > 0 && room_w * room_h != nested_compact_area)
			continue
		if(room_w <= 0 || room_h <= 0 || room_w > max(context.local_width() - 2, 1) || room_h > max(context.local_height() - 2, 1))
			continue
		var/zone_x_span = zone.x2 - room_w + 1
		var/zone_y_span = zone.y2 - room_h + 1
		var/list/x_positions = build_building_layout_axis_anchors(zone.x1, zone_x_span, allocation_variant % 2)
		var/list/y_positions = build_building_layout_axis_anchors(zone.y1, zone_y_span, allocation_variant >= 2)
		add_building_layout_partial_edge_anchors(candidate.topology_graph, partial, room_contract.id, room_w, room_h, x_positions, y_positions)
		add_building_layout_partial_packing_anchors(partial, room_w, room_h, x_positions, y_positions)
		add_building_layout_partial_nested_sibling_anchors(candidate.topology_graph, partial, room_contract.id, room_w, room_h, x_positions, y_positions)
		var/global_x_span = context.local_width() - room_w
		var/global_y_span = context.local_height() - room_h
		for(var/local_x1 as anything in x_positions)
			if(local_x1 < 2 || local_x1 > global_x_span)
				continue
			for(var/local_y1 as anything in y_positions)
				if(local_y1 < 2 || local_y1 > global_y_span)
					continue
				var/list/rect = build_building_layout_rect(local_x1, local_y1, local_x1 + room_w - 1, local_y1 + room_h - 1)
				if(!building_layout_room_rect_valid_for_contract(context, rect, room_contract))
					continue
				shape_valid_count++
				if(!building_layout_room_rect_inside_footprint(context, rect))
					continue
				footprint_valid_count++
				if(building_layout_partial_rect_conflicts(candidate.topology_graph, partial, room_contract.id, rect))
					conflict_reject_count++
					if(length(conflict_reject_rects) < WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE)
						conflict_reject_rects += "[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
					continue
				if(!building_layout_partial_required_edges_fit(context, candidate.topology_graph, partial, room_contract.id, rect))
					edge_reject_count++
					direct_edge_reject_count++
					if(length(edge_reject_rects) < 32)
						edge_reject_rects += "direct:[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
					continue
				// A new nested child can consume the parent-side approach of an already
				// placed sibling. Apply the full typed-edge check before spatial-bucket
				// pruning, otherwise a locally valid but globally destructive rectangle
				// evicts the lower-scored grid cell that completes the authored packing.
				var/datum/world_edit_building_layout_allocation_partial/edge_probe = partial.fork_with(room_contract.id, rect)
				if(!building_layout_partial_all_required_edges_fit(context, candidate.topology_graph, edge_probe))
					edge_reject_count++
					existing_edge_reject_count++
					if(length(edge_reject_rects) < 32)
						edge_reject_rects += "existing:[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
					continue
				// Apply pending typed-edge feasibility before per-bucket option pruning.
				// Otherwise a centered root which cannot leave room for its child can
				// evict the slightly off-centre, complete-packing geometry in the same
				// coarse spatial bucket.
				if(!building_layout_partial_pending_required_edges_possible(context, candidate, edge_probe))
					pending_edge_reject_count++
					if(length(pending_edge_reject_rects) < WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE)
						pending_edge_reject_rects += "[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
					continue
				// Typed terminals may move to another valid wall as later rooms are
				// inserted. Evaluate the whole placed terminal set before spatial-bucket
				// ranking instead of freezing the previous hint or letting an impossible
				// higher-scored rectangle evict a feasible alternative.
				if(length(partial.estimated_route_terminals))
					var/list/route_probe_hints = list()
					if(!building_layout_partial_route_terminal_slots_possible(context, candidate, edge_probe, room_contract.id, route_probe_hints))
						terminal_feasibility_reject_count++
						if(length(terminal_feasibility_reject_rects) < WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE)
							terminal_feasibility_reject_rects += "[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
						continue
				if(!building_layout_partial_rect_fits_family(context, candidate, partial, room_contract, rect))
					family_reject_count++
					if(length(family_reject_rects) < WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE)
						family_reject_rects += "[rect["x1"]],[rect["y1"]]-[rect["x2"]],[rect["y2"]]"
					continue
				var/score = score_building_layout_partial_rect(context, candidate, partial, room_contract, zone, rect, target_area, allocation_variant)
				insert_building_layout_rect_option(result, list(
					"rect" = rect,
					"score" = score,
					"spatial_bucket" = get_building_layout_rect_spatial_bucket(zone, rect),
				), WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE)
	if(!length(result))
		context.state.add_stage_report("layout_room_rect_enumeration", "failed", "no edge-valid rectangle option", list(
			"candidate_id" = candidate.id,
			"room_id" = room_contract.id,
			"partial" = format_building_layout_partial(partial),
			"size_variants" = size_variants,
			"shape_valid_count" = shape_valid_count,
			"footprint_valid_count" = footprint_valid_count,
			"conflict_reject_count" = conflict_reject_count,
			"conflict_reject_rects" = conflict_reject_rects,
			"edge_reject_count" = edge_reject_count,
			"direct_edge_reject_count" = direct_edge_reject_count,
			"existing_edge_reject_count" = existing_edge_reject_count,
			"edge_reject_rects" = edge_reject_rects,
			"pending_edge_reject_count" = pending_edge_reject_count,
			"pending_edge_reject_rects" = pending_edge_reject_rects,
			"terminal_feasibility_reject_count" = terminal_feasibility_reject_count,
			"terminal_feasibility_reject_rects" = terminal_feasibility_reject_rects,
			"family_reject_count" = family_reject_count,
			"family_reject_rects" = family_reject_rects,
		))
	if(!length(result) && !length(partial.placement_order))
		candidate.errors += "room.enum_diag:[room_contract.id]:zone=[zone.x1],[zone.y1]-[zone.x2],[zone.y2],contract=[room_contract.min_width]x[room_contract.min_height]-[room_contract.max_width]x[room_contract.max_height]:[room_contract.min_area]-[room_contract.max_area]:aspect=[room_contract.max_aspect],sizes=[json_encode(size_variants)],shape=[shape_valid_count],footprint=[footprint_valid_count],conflict=[conflict_reject_count],edge=[edge_reject_count]"
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_partial_rect_fits_family(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_room_contract/room_contract, list/rect)
	if(!istype(context) || !istype(candidate) || !istype(partial) || !istype(room_contract) || !islist(rect))
		return FALSE
	switch(candidate.family_policy_id)
		if("hub_spoke")
			var/hub_root_id = "[candidate.topology_graph?.root_node_id || ""]"
			if(room_contract.id == hub_root_id)
				var/root_center_x = (rect["x1"] + rect["x2"]) / 2
				var/root_center_y = (rect["y1"] + rect["y2"]) / 2
				var/field_center_x = (context.local_width() + 1) / 2
				var/field_center_y = (context.local_height() + 1) / 2
				return abs(root_center_x - field_center_x) <= max(round(context.local_width() * 0.2), 2) && abs(root_center_y - field_center_y) <= max(round(context.local_height() * 0.2), 2)
			var/list/hub_root_rect = partial.placements[hub_root_id]
			var/datum/world_edit_building_layout_topology_edge/root_edge = get_building_layout_partial_edge(candidate.topology_graph, room_contract.id, hub_root_id)
			if(islist(hub_root_rect) && istype(root_edge) && !(root_edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED)))
				var/list/used_hub_sides = list()
				var/remaining_hub_children = 0
				for(var/datum/world_edit_building_layout_topology_edge/hub_edge as anything in candidate.topology_graph.get_edges_for(hub_root_id))
					if(!istype(hub_edge) || !hub_edge.required || hub_edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED))
						continue
					var/hub_child_id = hub_edge.from_id == hub_root_id ? hub_edge.to_id : hub_edge.from_id
					var/list/hub_child_rect = hub_child_id == room_contract.id ? rect : partial.placements[hub_child_id]
					if(!islist(hub_child_rect))
						remaining_hub_children++
						continue
					if(hub_child_rect["x2"] + 2 == hub_root_rect["x1"])
						used_hub_sides["west"] = TRUE
					else if(hub_child_rect["x1"] == hub_root_rect["x2"] + 2)
						used_hub_sides["east"] = TRUE
					else if(hub_child_rect["y2"] + 2 == hub_root_rect["y1"])
						used_hub_sides["south"] = TRUE
					else if(hub_child_rect["y1"] == hub_root_rect["y2"] + 2)
						used_hub_sides["north"] = TRUE
				if(!remaining_hub_children && length(used_hub_sides) < 2)
					return FALSE
		if("split_wing")
			var/split_axis = candidate.orientation_variant % 2 ? "y" : "x"
			var/split_coord = split_axis == "x" ? (context.local_width() + 1) / 2 : (context.local_height() + 1) / 2
			var/room_coord = split_axis == "x" ? (rect["x1"] + rect["x2"]) / 2 : (rect["y1"] + rect["y2"]) / 2
			if(room_contract.id == candidate.topology_graph?.root_node_id)
				return abs(room_coord - split_coord) <= 2
			var/datum/world_edit_building_layout_topology_node/room_node = candidate.topology_graph?.get_node(room_contract.id)
			var/list/parent_rect = partial.placements[room_node?.parent_id]
			var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(candidate.topology_graph, room_contract.id, room_node?.parent_id)
			if(parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED && islist(parent_rect))
				// NESTED belongs to its containing room, not to either split wing.
				// A central transition may straddle the abstract split line, so comparing
				// child/parent centers incorrectly forbids a valid edge-packed child.
				// Strict containment and the typed NESTED partition are checked above.
				return TRUE
			var/datum/world_edit_building_layout_influence_zone/wing_zone = get_building_layout_contract_seed_zone(candidate.region_candidate, room_contract.id)
			if(wing_zone?.id == "wing_a" && room_coord >= split_coord)
				return FALSE
			if(wing_zone?.id == "wing_b" && room_coord < split_coord)
				return FALSE
			// A complete split-wing allocation must put at least one non-nested
			// functional room on each side. Enforce that when the last such room is
			// placed so the bounded beam cannot retain geometrically impossible
			// one-wing completions and defer the contradiction to scoring.
			var/wing_a = room_coord < split_coord
			var/wing_b = !wing_a
			for(var/existing_id as anything in partial.placement_order)
				if(existing_id == candidate.topology_graph.root_node_id)
					continue
				var/datum/world_edit_building_layout_topology_node/existing_node = candidate.topology_graph.get_node(existing_id)
				var/datum/world_edit_building_layout_topology_edge/existing_parent_edge = get_building_layout_partial_edge(candidate.topology_graph, existing_id, existing_node?.parent_id)
				if(existing_parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
					continue
				var/list/existing_rect = partial.placements[existing_id]
				var/existing_coord = split_axis == "x" ? (existing_rect["x1"] + existing_rect["x2"]) / 2 : (existing_rect["y1"] + existing_rect["y2"]) / 2
				if(existing_coord < split_coord)
					wing_a = TRUE
				else
					wing_b = TRUE
			var/remaining_external_rooms = 0
			for(var/datum/world_edit_building_layout_room_contract/pending_contract as anything in context.program_contract?.functional_room_contracts)
				if(!istype(pending_contract) || pending_contract.id == candidate.topology_graph.root_node_id || pending_contract.id == room_contract.id || partial.placements[pending_contract.id])
					continue
				var/datum/world_edit_building_layout_topology_node/pending_node = candidate.topology_graph.get_node(pending_contract.id)
				var/datum/world_edit_building_layout_topology_edge/pending_parent_edge = get_building_layout_partial_edge(candidate.topology_graph, pending_contract.id, pending_node?.parent_id)
				if(pending_parent_edge?.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
					remaining_external_rooms++
			if(!remaining_external_rooms && (!wing_a || !wing_b))
				return FALSE
		if("secure_core")
			if(room_contract.privacy_class == "secure")
				for(var/local_x in rect["x1"] to rect["x2"])
					for(var/local_y in rect["y1"] to rect["y2"])
						var/turf/room_turf = context.local_turf(local_x, local_y)
						for(var/check_dir in GLOB.cardinals)
							if(context.state.geometry.boundary_lookup[get_step(room_turf, check_dir)])
								return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_rect_spatial_bucket(datum/world_edit_building_layout_influence_zone/zone, list/rect)
	if(!istype(zone) || !islist(rect))
		return "invalid"
	var/zone_width = max(zone.x2 - zone.x1 + 1, 1)
	var/center_x = round((rect["x1"] + rect["x2"]) / 2)
	var/center_y = round((rect["y1"] + rect["y2"]) / 2)
	var/x_bucket = clamp(round((center_x - zone.x1) * 4 / zone_width), 0, 3)
	var/y_bucket = center_y <= round((zone.y1 + zone.y2) / 2) ? 0 : 1
	return "[x_bucket]:[y_bucket]"

/datum/world_edit_generator/building_layout/proc/add_building_layout_partial_edge_anchors(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, room_id, room_w, room_h, list/x_positions, list/y_positions)
	if(!istype(graph) || !istype(partial) || !islist(x_positions) || !islist(y_positions))
		return
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(room_id))
		if(!istype(edge) || !edge.required || edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
			continue
		var/other_id = edge.from_id == room_id ? edge.to_id : edge.from_id
		var/list/other_rect = partial.placements[other_id]
		if(!islist(other_rect))
			continue
		var/required_overlap = max(edge.min_shared_wall, 1)
		if(edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
			var/datum/world_edit_building_layout_topology_node/room_node = graph.get_node(room_id)
			if(room_node?.parent_id == other_id)
				// NESTED is strict containment with a declared one-cell parent margin.
				// Anchor the child to the first legal inner positions, not flush to the
				// parent bounds where the hard containment validator must reject it.
				x_positions |= other_rect["x1"] + 1
				x_positions |= other_rect["x2"] - room_w
				y_positions |= other_rect["y1"] + 1
				y_positions |= other_rect["y2"] - room_h
			continue
		// Exact partition-distance anchors make geometry-aware edges reachable
		// without widening the bounded scan or relying on a later repair pass.
		x_positions |= other_rect["x2"] + 2
		x_positions |= other_rect["x1"] - room_w - 1
		x_positions |= other_rect["x1"]
		x_positions |= other_rect["x2"] - room_w + 1
		x_positions |= other_rect["x1"] - room_w + required_overlap
		x_positions |= other_rect["x2"] - required_overlap + 1
		y_positions |= other_rect["y2"] + 2
		y_positions |= other_rect["y1"] - room_h - 1
		y_positions |= other_rect["y1"]
		y_positions |= other_rect["y2"] - room_h + 1
		y_positions |= other_rect["y1"] - room_h + required_overlap
		y_positions |= other_rect["y2"] - required_overlap + 1

/datum/world_edit_generator/building_layout/proc/add_building_layout_partial_packing_anchors(datum/world_edit_building_layout_allocation_partial/partial, room_w, room_h, list/x_positions, list/y_positions)
	if(!istype(partial) || !islist(x_positions) || !islist(y_positions))
		return
	// Siblings which share the same family region still need bounded positions
	// beside each other.  Anchoring to their partition edge prevents a valid
	// final room from disappearing between the five coarse region anchors.
	for(var/existing_id as anything in partial.placement_order)
		var/list/existing_rect = partial.placements[existing_id]
		if(!islist(existing_rect))
			continue
		x_positions |= existing_rect["x2"] + 2
		x_positions |= existing_rect["x1"] - room_w - 1
		x_positions |= existing_rect["x2"] + 3
		x_positions |= existing_rect["x1"] - room_w - 2
		x_positions |= existing_rect["x1"]
		x_positions |= existing_rect["x2"] - room_w + 1
		y_positions |= existing_rect["y2"] + 2
		y_positions |= existing_rect["y1"] - room_h - 1
		y_positions |= existing_rect["y2"] + 3
		y_positions |= existing_rect["y1"] - room_h - 2
		y_positions |= existing_rect["y2"] + 4
		y_positions |= existing_rect["y1"] - room_h - 3
		y_positions |= existing_rect["y1"]
		y_positions |= existing_rect["y2"] - room_h + 1

/datum/world_edit_generator/building_layout/proc/add_building_layout_partial_nested_sibling_anchors(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, room_id, room_w, room_h, list/x_positions, list/y_positions)
	if(!istype(graph) || !istype(partial) || !islist(x_positions) || !islist(y_positions))
		return
	var/datum/world_edit_building_layout_topology_node/room_node = graph.get_node(room_id)
	var/parent_id = "[room_node?.parent_id || ""]"
	var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(graph, room_id, parent_id)
	if(!length(parent_id) || parent_edge?.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
		return
	for(var/existing_id as anything in partial.placement_order)
		var/datum/world_edit_building_layout_topology_node/existing_node = graph.get_node(existing_id)
		var/list/existing_rect = partial.placements[existing_id]
		if(!istype(existing_node) || existing_node.parent_id != parent_id || !islist(existing_rect) || !building_layout_nodes_are_typed_nested_siblings(graph, room_id, existing_id))
			continue
		// One canonical partition gap is sufficient between nested siblings. Exact
		// child door/module feasibility chooses a different side when that shared
		// partition cannot carry the controlled opening.
		x_positions |= existing_rect["x2"] + 2
		x_positions |= existing_rect["x1"] - room_w - 1
		// Shared nested column aisle: wall + three parent cells + wall.
		x_positions |= existing_rect["x2"] + 6
		x_positions |= existing_rect["x1"] - room_w - 5
		x_positions |= existing_rect["x1"]
		x_positions |= existing_rect["x2"] - room_w + 1
		y_positions |= existing_rect["y2"] + 2
		y_positions |= existing_rect["y1"] - room_h - 1
		// Shared nested row aisle: wall + three parent cells + wall.
		y_positions |= existing_rect["y2"] + 6
		y_positions |= existing_rect["y1"] - room_h - 5
		y_positions |= existing_rect["y1"]
		y_positions |= existing_rect["y2"] - room_h + 1

/datum/world_edit_generator/building_layout/proc/build_building_layout_axis_anchors(axis_min, axis_max, reverse_order = FALSE)
	var/list/result = list()
	result |= reverse_order ? axis_max : axis_min
	result |= reverse_order ? axis_min : axis_max
	result |= round((axis_min + axis_max) / 2)
	result |= round((axis_min * 3 + axis_max) / 4)
	result |= round((axis_min + axis_max * 3) / 4)
	return result

/datum/world_edit_generator/building_layout/proc/get_building_layout_partial_edge(datum/world_edit_building_layout_topology_graph/graph, node_a, node_b)
	if(!istype(graph))
		return null
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(node_a))
		if(istype(edge) && (edge.from_id == node_b || edge.to_id == node_b))
			return edge
	return null

/datum/world_edit_generator/building_layout/proc/building_layout_partial_rect_conflicts(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, room_id, list/rect)
	if(!istype(graph) || !istype(partial) || !islist(rect))
		return TRUE
	for(var/existing_id as anything in partial.placement_order)
		var/list/existing = partial.placements[existing_id]
		if(!islist(existing))
			continue
		var/nested_siblings = building_layout_nodes_are_typed_nested_siblings(graph, room_id, existing_id)
		var/datum/world_edit_building_layout_topology_edge/edge = get_building_layout_partial_edge(graph, room_id, existing_id)
		if(istype(edge) && edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		if(building_layout_rects_intersect(existing, rect))
			return TRUE
		if(nested_siblings)
			var/x_overlap = min(existing["x2"], rect["x2"]) - max(existing["x1"], rect["x1"]) + 1
			var/y_overlap = min(existing["y2"], rect["y2"]) - max(existing["y1"], rect["y1"]) + 1
			if((x_overlap > 0 && (existing["y2"] + 1 == rect["y1"] || rect["y2"] + 1 == existing["y1"])) || (y_overlap > 0 && (existing["x2"] + 1 == rect["x1"] || rect["x2"] + 1 == existing["x1"])))
				return TRUE
		if(istype(edge) && (edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_SHARED, WORLD_EDIT_BUILDING_EDGE_OPEN_MERGE, WORLD_EDIT_BUILDING_EDGE_SECURE)))
			var/list/partition_reserve = build_building_layout_rect(existing["x1"] - 1, existing["y1"] - 1, existing["x2"] + 1, existing["y2"] + 1)
			if(building_layout_rects_intersect(partition_reserve, rect))
				return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_required_edges_fit(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, room_id, list/rect)
	if(!istype(context) || !istype(graph) || !istype(partial) || !islist(rect))
		return FALSE
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(room_id))
		if(!istype(edge) || !edge.required || edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
			continue
		var/other_id = edge.from_id == room_id ? edge.to_id : edge.from_id
		var/list/other_rect = partial.placements[other_id]
		if(!islist(other_rect))
			continue
		switch(edge.edge_kind)
			if(WORLD_EDIT_BUILDING_EDGE_NESTED)
				var/datum/world_edit_building_layout_topology_node/room_node = graph.get_node(room_id)
				var/list/child_rect = room_node?.parent_id == other_id ? rect : other_rect
				var/list/parent_rect = child_rect == rect ? other_rect : rect
				if(!building_layout_nested_rect_has_inner_margin(child_rect, parent_rect))
					return FALSE
				if(building_layout_partial_nested_partition_run(graph, partial, edge, room_id, rect) < get_building_layout_nested_required_partition_run(context, edge))
					return FALSE
			if(WORLD_EDIT_BUILDING_EDGE_SHARED, WORLD_EDIT_BUILDING_EDGE_OPEN_MERGE, WORLD_EDIT_BUILDING_EDGE_SECURE)
				if(building_layout_rect_partition_overlap(rect, other_rect) < max(edge.min_shared_wall, 1))
					return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_all_required_edges_fit(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context) || !istype(graph) || !istype(partial))
		return FALSE
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.edges)
		if(!istype(edge) || !edge.required || edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
			continue
		if(!islist(partial.placements[edge.from_id]) || !islist(partial.placements[edge.to_id]))
			continue
		if(edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
			var/datum/world_edit_building_layout_topology_node/from_node = graph.get_node(edge.from_id)
			var/datum/world_edit_building_layout_topology_node/to_node = graph.get_node(edge.to_id)
			var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
			var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
			if(!building_layout_nested_rect_has_inner_margin(partial.placements[child_id], partial.placements[parent_id]))
				return FALSE
			// Require the exact edge-local threshold/frontage set while the beam is
			// expanding. Mutual compatibility across sibling edges is proved once by
			// the bounded complete-partial partition planner.
			if(length(build_building_layout_partial_nested_partition_run_cells_independent(context, graph, partial, edge)) < get_building_layout_nested_required_partition_run(context, edge))
				return FALSE
			continue
		if(building_layout_partial_effective_partition_overlap(graph, partial, edge) < max(edge.min_shared_wall, 1))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_pending_required_edges_possible(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context) || !istype(candidate?.topology_graph) || !istype(partial))
		return FALSE
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph.edges)
		if(!istype(edge) || !edge.required || (edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED)))
			continue
		var/list/from_rect = partial.placements[edge.from_id]
		var/list/to_rect = partial.placements[edge.to_id]
		if(islist(from_rect) == islist(to_rect))
			continue
		var/placed_id = islist(from_rect) ? edge.from_id : edge.to_id
		var/pending_id = placed_id == edge.from_id ? edge.to_id : edge.from_id
		var/list/placed_rect = partial.placements[placed_id]
		var/datum/world_edit_building_layout_room_contract/pending_contract = context.program_contract?.get_room_contract(pending_id)
		var/datum/world_edit_building_layout_influence_zone/pending_zone = get_building_layout_contract_seed_zone(candidate.region_candidate, pending_id)
		if(!islist(placed_rect) || !istype(pending_contract) || !istype(pending_zone))
			return FALSE
		var/required_overlap = max(edge.min_shared_wall, 1)
		var/edge_possible = FALSE
		var/list/reject_counts = list()
		var/list/size_variants = build_building_layout_room_size_variants(pending_contract, pending_contract.min_area, 1)
		for(var/list/size_variant as anything in size_variants)
			var/room_w = round(text2num("[size_variant?["w"]]") || 0)
			var/room_h = round(text2num("[size_variant?["h"]]") || 0)
			if(room_w <= 0 || room_h <= 0)
				continue
			for(var/local_y in (placed_rect["y1"] - room_h + required_overlap) to (placed_rect["y2"] - required_overlap + 1))
				var/list/west_rect = build_building_layout_rect(placed_rect["x1"] - room_w - 1, local_y, placed_rect["x1"] - 2, local_y + room_h - 1)
				if(building_layout_pending_required_edge_rect_possible(context, candidate, partial, pending_contract, pending_zone, west_rect, reject_counts))
					edge_possible = TRUE
					break
				var/list/east_rect = build_building_layout_rect(placed_rect["x2"] + 2, local_y, placed_rect["x2"] + room_w + 1, local_y + room_h - 1)
				if(building_layout_pending_required_edge_rect_possible(context, candidate, partial, pending_contract, pending_zone, east_rect, reject_counts))
					edge_possible = TRUE
					break
			if(edge_possible)
				break
			for(var/local_x in (placed_rect["x1"] - room_w + required_overlap) to (placed_rect["x2"] - required_overlap + 1))
				var/list/south_rect = build_building_layout_rect(local_x, placed_rect["y1"] - room_h - 1, local_x + room_w - 1, placed_rect["y1"] - 2)
				if(building_layout_pending_required_edge_rect_possible(context, candidate, partial, pending_contract, pending_zone, south_rect, reject_counts))
					edge_possible = TRUE
					break
				var/list/north_rect = build_building_layout_rect(local_x, placed_rect["y2"] + 2, local_x + room_w - 1, placed_rect["y2"] + room_h + 1)
				if(building_layout_pending_required_edge_rect_possible(context, candidate, partial, pending_contract, pending_zone, north_rect, reject_counts))
					edge_possible = TRUE
					break
			if(edge_possible)
				break
		if(!edge_possible)
			var/list/reported = context.state.config["layout_pending_edge_reported"]
			if(!islist(reported))
				reported = list()
				context.state.config["layout_pending_edge_reported"] = reported
			var/report_key = "[candidate.id]:[placed_id]>[pending_id]"
			if(!reported[report_key])
				reported[report_key] = TRUE
				context.state.add_stage_report("layout_pending_edge_feasibility", "failed", "no exact partition position for pending typed neighbour", list(
					"candidate_id" = candidate.id,
					"placed_room_id" = placed_id,
					"pending_room_id" = pending_id,
					"placed_rect" = "[placed_rect["x1"]],[placed_rect["y1"]]-[placed_rect["x2"]],[placed_rect["y2"]]",
					"pending_zone" = "[pending_zone.x1],[pending_zone.y1]-[pending_zone.x2],[pending_zone.y2]",
					"required_overlap" = required_overlap,
					"reject_counts" = reject_counts.Copy(),
				))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_pending_required_edge_rect_possible(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_room_contract/room_contract, datum/world_edit_building_layout_influence_zone/zone, list/rect, list/reject_counts = null)
	if(!building_layout_room_rect_valid_for_contract(context, rect, room_contract))
		if(islist(reject_counts))
			reject_counts["contract"] = (reject_counts["contract"] || 0) + 1
		return FALSE
	if(!building_layout_room_rect_inside_footprint(context, rect))
		if(islist(reject_counts))
			reject_counts["footprint"] = (reject_counts["footprint"] || 0) + 1
		return FALSE
	if(building_layout_partial_rect_conflicts(candidate.topology_graph, partial, room_contract.id, rect))
		if(islist(reject_counts))
			reject_counts["conflict"] = (reject_counts["conflict"] || 0) + 1
		return FALSE
	if(!building_layout_partial_required_edges_fit(context, candidate.topology_graph, partial, room_contract.id, rect))
		if(islist(reject_counts))
			reject_counts["required_edge"] = (reject_counts["required_edge"] || 0) + 1
		return FALSE
	if(!building_layout_partial_rect_fits_family(context, candidate, partial, room_contract, rect))
		if(islist(reject_counts))
			reject_counts["family"] = (reject_counts["family"] || 0) + 1
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_nested_rect_has_inner_margin(list/child_rect, list/parent_rect)
	if(!islist(child_rect) || !islist(parent_rect))
		return FALSE
	return child_rect["x1"] > parent_rect["x1"] && child_rect["y1"] > parent_rect["y1"] && child_rect["x2"] < parent_rect["x2"] && child_rect["y2"] < parent_rect["y2"]

/datum/world_edit_generator/building_layout/proc/get_building_layout_nested_required_partition_run(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_topology_edge/edge)
	if(!istype(context?.program_contract) || !istype(edge))
		return 1
	var/required_run = max(edge.min_shared_wall, 1)
	if(edge.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR))
		// The controlled threshold needs two shoulders. Module frontage is checked
		// independently by exact composition placement and need not share this axis.
		required_run = max(required_run, edge.min_opening_width + 2)
	return required_run

/datum/world_edit_generator/building_layout/proc/building_layout_partial_nested_partition_run(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_topology_edge/edge, override_id = "", list/override_rect = null)
	if(!istype(graph) || !istype(partial) || !istype(edge))
		return 0
	var/datum/world_edit_building_layout_topology_node/from_node = graph.get_node(edge.from_id)
	var/datum/world_edit_building_layout_topology_node/to_node = graph.get_node(edge.to_id)
	var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
	var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
	var/list/child_rect = child_id == override_id && islist(override_rect) ? override_rect : partial.placements[child_id]
	var/list/parent_rect = parent_id == override_id && islist(override_rect) ? override_rect : partial.placements[parent_id]
	if(!islist(child_rect) || !islist(parent_rect))
		return 0
	var/best_run = 0
	var/current_run = 0
	for(var/local_y in child_rect["y1"] to child_rect["y2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, child_rect["x1"] - 1, local_y, child_rect["x1"] - 2, local_y, override_id, override_rect))
			current_run++
			best_run = max(best_run, current_run)
		else
			current_run = 0
	current_run = 0
	for(var/local_y in child_rect["y1"] to child_rect["y2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, child_rect["x2"] + 1, local_y, child_rect["x2"] + 2, local_y, override_id, override_rect))
			current_run++
			best_run = max(best_run, current_run)
		else
			current_run = 0
	current_run = 0
	for(var/local_x in child_rect["x1"] to child_rect["x2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y1"] - 1, local_x, child_rect["y1"] - 2, override_id, override_rect))
			current_run++
			best_run = max(best_run, current_run)
		else
			current_run = 0
	current_run = 0
	for(var/local_x in child_rect["x1"] to child_rect["x2"])
		if(building_layout_partial_nested_partition_cell_available(graph, partial, child_id, parent_id, local_x, child_rect["y2"] + 1, local_x, child_rect["y2"] + 2, override_id, override_rect))
			current_run++
			best_run = max(best_run, current_run)
		else
			current_run = 0
	return best_run

/datum/world_edit_generator/building_layout/proc/building_layout_partial_nested_partition_cell_available(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, child_id, parent_id, wall_x, wall_y, parent_x, parent_y, override_id = "", list/override_rect = null)
	var/list/parent_rect = parent_id == override_id && islist(override_rect) ? override_rect : partial?.placements[parent_id]
	if(!islist(parent_rect) || wall_x < parent_rect["x1"] || wall_x > parent_rect["x2"] || wall_y < parent_rect["y1"] || wall_y > parent_rect["y2"] || parent_x < parent_rect["x1"] || parent_x > parent_rect["x2"] || parent_y < parent_rect["y1"] || parent_y > parent_rect["y2"])
		return FALSE
	for(var/datum/world_edit_building_layout_topology_node/node as anything in graph?.nodes)
		if(!istype(node) || node.parent_id != parent_id || node.id == child_id || !building_layout_nodes_are_typed_nested_siblings(graph, child_id, node.id))
			continue
		var/list/sibling_rect = node.id == override_id && islist(override_rect) ? override_rect : partial?.placements[node.id]
		if(!islist(sibling_rect))
			continue
		if(wall_x >= sibling_rect["x1"] && wall_x <= sibling_rect["x2"] && wall_y >= sibling_rect["y1"] && wall_y <= sibling_rect["y2"])
			return FALSE
		// The parent-side cell belongs to the containing room.  Reject a real
		// sibling footprint, but do not recreate a universal +/-1 reservation ring;
		// exact door cones and parent-floor continuity validate the shared aisle.
		if(parent_x >= sibling_rect["x1"] && parent_x <= sibling_rect["x2"] && parent_y >= sibling_rect["y1"] && parent_y <= sibling_rect["y2"])
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_effective_partition_overlap(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_topology_edge/edge)
	var/list/from_rect = partial?.placements[edge?.from_id]
	var/list/to_rect = partial?.placements[edge?.to_id]
	if(!istype(graph) || !islist(from_rect) || !islist(to_rect))
		return 0
	var/overlap = 0
	if(from_rect["x2"] + 2 == to_rect["x1"] || to_rect["x2"] + 2 == from_rect["x1"])
		var/from_x = from_rect["x2"] < to_rect["x1"] ? from_rect["x2"] : from_rect["x1"]
		var/to_x = from_rect["x2"] < to_rect["x1"] ? to_rect["x1"] : to_rect["x2"]
		for(var/local_y in max(from_rect["y1"], to_rect["y1"]) to min(from_rect["y2"], to_rect["y2"]))
			if(!building_layout_partial_room_cell_carved_by_nested_child(graph, partial, edge.from_id, from_x, local_y) && !building_layout_partial_room_cell_carved_by_nested_child(graph, partial, edge.to_id, to_x, local_y))
				overlap++
	else if(from_rect["y2"] + 2 == to_rect["y1"] || to_rect["y2"] + 2 == from_rect["y1"])
		var/from_y = from_rect["y2"] < to_rect["y1"] ? from_rect["y2"] : from_rect["y1"]
		var/to_y = from_rect["y2"] < to_rect["y1"] ? to_rect["y1"] : to_rect["y2"]
		for(var/local_x in max(from_rect["x1"], to_rect["x1"]) to min(from_rect["x2"], to_rect["x2"]))
			if(!building_layout_partial_room_cell_carved_by_nested_child(graph, partial, edge.from_id, local_x, from_y) && !building_layout_partial_room_cell_carved_by_nested_child(graph, partial, edge.to_id, local_x, to_y))
				overlap++
	return overlap

/datum/world_edit_generator/building_layout/proc/building_layout_partial_room_cell_carved_by_nested_child(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_allocation_partial/partial, room_id, local_x, local_y)
	for(var/datum/world_edit_building_layout_topology_node/node as anything in graph?.nodes)
		if(!istype(node) || node.parent_id != room_id)
			continue
		var/datum/world_edit_building_layout_topology_edge/parent_edge = get_building_layout_partial_edge(graph, node.id, room_id)
		if(parent_edge?.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		var/list/child_rect = partial?.placements[node.id]
		// The child footprint is carved from the parent. Its controlled boundary is
		// one canonical straight segment chosen separately; reserving child +/- 1
		// here recreates the forbidden universal nested ring and destroys unrelated
		// parent frontage during dry allocation.
		if(islist(child_rect) && local_x >= child_rect["x1"] && local_x <= child_rect["x2"] && local_y >= child_rect["y1"] && local_y <= child_rect["y2"])
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_rect_partition_overlap(list/a, list/b)
	if(!islist(a) || !islist(b))
		return 0
	if(a["x2"] + 2 == b["x1"] || b["x2"] + 2 == a["x1"])
		return max(min(a["y2"], b["y2"]) - max(a["y1"], b["y1"]) + 1, 0)
	if(a["y2"] + 2 == b["y1"] || b["y2"] + 2 == a["y1"])
		return max(min(a["x2"], b["x2"]) - max(a["x1"], b["x1"]) + 1, 0)
	return 0

/datum/world_edit_generator/building_layout/proc/building_layout_partial_route_network_possible(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, list/terminal_hints_out = null)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !istype(partial))
		return FALSE
	var/list/owner_by_turf = list()
	for(var/room_id as anything in partial.placement_order)
		var/list/rect = partial.placements[room_id]
		if(!islist(rect))
			continue
		for(var/local_x in rect["x1"] to rect["x2"])
			for(var/local_y in rect["y1"] to rect["y2"])
				var/turf/room_turf = context.local_turf(local_x, local_y)
				if(istype(room_turf))
					owner_by_turf[room_turf] = "[room_id]"
	var/list/free_lookup = list()
	for(var/turf/interior_turf as anything in state.geometry.footprint)
		if(!istype(interior_turf) || state.geometry.boundary_lookup[interior_turf] || owner_by_turf[interior_turf])
			continue
		var/is_partition_gap = FALSE
		for(var/check_dir in list(NORTH, EAST))
			var/owner_a = "[owner_by_turf[get_step(interior_turf, check_dir)] || ""]"
			var/owner_b = "[owner_by_turf[get_step(interior_turf, turn(check_dir, 180))] || ""]"
			if(length(owner_a) && length(owner_b) && owner_a != owner_b)
				is_partition_gap = TRUE
				break
		if(!is_partition_gap)
			free_lookup[interior_turf] = TRUE
	var/entry_dir = state.geometry.requested_direction || state.placement_dir || NORTH
	if(!(entry_dir in GLOB.cardinals))
		entry_dir = NORTH
	var/turf/center_turf = context.local_turf(round((context.local_width() + 1) / 2), round((context.local_height() + 1) / 2))
	var/turf/entry_seed = null
	var/best_entry_distance = 999999
	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(!istype(boundary_turf) || !boundary_turf_has_outside_dir(boundary_turf, state.geometry.footprint_lookup, entry_dir) || is_corner_boundary_turf(boundary_turf, state.geometry.footprint_lookup))
			continue
		var/turf/inside_turf = get_step(boundary_turf, turn(entry_dir, 180))
		if(!free_lookup[inside_turf])
			continue
		var/entry_distance = istype(center_turf) ? abs(inside_turf.x - center_turf.x) + abs(inside_turf.y - center_turf.y) : 0
		if(!istype(entry_seed) || entry_distance < best_entry_distance)
			entry_seed = inside_turf
			best_entry_distance = entry_distance
	if(!istype(entry_seed))
		return FALSE
	var/list/reachable = list()
	reachable[entry_seed] = TRUE
	var/list/open = list(entry_seed)
	var/open_index = 1
	while(open_index <= length(open))
		var/turf/current = open[open_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby = get_step(current, check_dir)
			if(!free_lookup[nearby] || reachable[nearby])
				continue
			reachable[nearby] = TRUE
			open += nearby
	var/list/route_connections = list()
	for(var/datum/world_edit_building_layout_room_connection/connection as anything in candidate.room_connections)
		if(!istype(connection) || !connection.required || connection.edge_kind != WORLD_EDIT_BUILDING_EDGE_ROUTE || connection.route_policy != WORLD_EDIT_BUILDING_ROUTE_POLICY_NETWORK)
			continue
		var/room_id = get_building_layout_connection_functional_node_id(context, connection)
		// A circulation-to-circulation edge is a typed segment transition, not a
		// room frontage.  Ownership validation handles it after the route graph is
		// built; only edges with a functional endpoint consume wall terminals.
		if(!length(room_id))
			continue
		if(!islist(partial.placements[room_id]))
			return FALSE
		route_connections += connection
	var/list/selected_hints = list()
	var/list/reserved_entry_wall_lookup = list()
	reserved_entry_wall_lookup[entry_seed] = TRUE
	if(!assign_building_layout_partial_route_terminals(context, candidate, partial, route_connections, 1, free_lookup, reachable, reserved_entry_wall_lookup, list(), selected_hints, entry_seed))
		return FALSE
	if(islist(terminal_hints_out))
		terminal_hints_out.Cut()
		for(var/connection_id as anything in selected_hints)
			terminal_hints_out[connection_id] = selected_hints[connection_id]
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_route_terminal_slots_possible(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, focus_room_id, list/terminal_hints_out)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !istype(partial) || !length("[focus_room_id]") || !islist(terminal_hints_out))
		return FALSE
	var/list/owner_by_turf = list()
	for(var/room_id as anything in partial.placement_order)
		var/list/rect = partial.placements[room_id]
		if(!islist(rect))
			continue
		for(var/local_x in rect["x1"] to rect["x2"])
			for(var/local_y in rect["y1"] to rect["y2"])
				var/turf/room_turf = context.local_turf(local_x, local_y)
				if(istype(room_turf))
					owner_by_turf[room_turf] = "[room_id]"
	var/list/free_lookup = list()
	for(var/turf/interior_turf as anything in state.geometry.footprint)
		if(!istype(interior_turf) || state.geometry.boundary_lookup[interior_turf] || owner_by_turf[interior_turf])
			continue
		var/is_partition_gap = FALSE
		for(var/check_dir in list(NORTH, EAST))
			var/owner_a = "[owner_by_turf[get_step(interior_turf, check_dir)] || ""]"
			var/owner_b = "[owner_by_turf[get_step(interior_turf, turn(check_dir, 180))] || ""]"
			if(length(owner_a) && length(owner_b) && owner_a != owner_b)
				is_partition_gap = TRUE
				break
		if(!is_partition_gap)
			free_lookup[interior_turf] = TRUE
	var/entry_dir = state.geometry.requested_direction || state.placement_dir || NORTH
	if(!(entry_dir in GLOB.cardinals))
		entry_dir = NORTH
	var/turf/center_turf = context.local_turf(round((context.local_width() + 1) / 2), round((context.local_height() + 1) / 2))
	var/turf/entry_seed = null
	var/best_entry_distance = 999999
	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(!istype(boundary_turf) || !boundary_turf_has_outside_dir(boundary_turf, state.geometry.footprint_lookup, entry_dir) || is_corner_boundary_turf(boundary_turf, state.geometry.footprint_lookup))
			continue
		var/turf/inside_turf = get_step(boundary_turf, turn(entry_dir, 180))
		if(!free_lookup[inside_turf])
			continue
		var/entry_distance = istype(center_turf) ? abs(inside_turf.x - center_turf.x) + abs(inside_turf.y - center_turf.y) : 0
		if(!istype(entry_seed) || entry_distance < best_entry_distance)
			entry_seed = inside_turf
			best_entry_distance = entry_distance
	if(!istype(entry_seed))
		return FALSE
	var/list/reachable = list()
	reachable[entry_seed] = TRUE
	var/list/open = list(entry_seed)
	var/open_index = 1
	while(open_index <= length(open))
		var/turf/current = open[open_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby = get_step(current, check_dir)
			if(!free_lookup[nearby] || reachable[nearby])
				continue
			reachable[nearby] = TRUE
			open += nearby
	terminal_hints_out.Cut()
	var/list/placed_route_connections = list()
	for(var/datum/world_edit_building_layout_room_connection/connection as anything in candidate.room_connections)
		if(!istype(connection) || !connection.required || connection.edge_kind != WORLD_EDIT_BUILDING_EDGE_ROUTE || connection.route_policy != WORLD_EDIT_BUILDING_ROUTE_POLICY_NETWORK)
			continue
		var/room_id = get_building_layout_connection_functional_node_id(context, connection)
		if(!length(room_id))
			continue
		if(!islist(partial.placements[room_id]))
			continue
		placed_route_connections += connection
	// A room can own more than one typed route terminal (for example kitchen's
	// entry -> dining -> serving chain).  Independent slot probes let those
	// terminals claim the same wall/opening and keep an impossible partial in the
	// beam.  Reuse the complete-partial backtracker for every currently placed
	// terminal so wall runs, route runs and entry reachability hold together.
	var/list/reserved_entry_wall_lookup = list()
	reserved_entry_wall_lookup[entry_seed] = TRUE
	return assign_building_layout_partial_route_terminals(context, candidate, partial, placed_route_connections, 1, free_lookup, reachable, reserved_entry_wall_lookup, list(), terminal_hints_out, entry_seed)

/datum/world_edit_generator/building_layout/proc/find_building_layout_partial_route_terminal_slot(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_room_connection/connection, list/free_lookup, list/reachable)
	var/room_id = get_building_layout_connection_functional_node_id(context, connection)
	var/list/terminal_rect = partial?.placements[room_id]
	var/datum/world_edit_building_layout_room_contract/room_contract = context?.program_contract?.get_room_contract(room_id)
	if(!length(room_id) || !islist(terminal_rect) || !istype(room_contract) || !islist(free_lookup) || !islist(reachable))
		return null
	var/opening_width = max(connection.min_opening_width, room_contract.min_route_opening_width, 1)
	if(connection.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
		opening_width = max(opening_width, 2)
	opening_width = min(opening_width, max(connection.max_opening_width, opening_width))
	var/frontage_width = max(connection.min_shared_wall, opening_width)
	for(var/check_dir in GLOB.cardinals)
		var/world_check_dir = context.local_dir_to_world_dir(check_dir)
		var/axis_start = (check_dir in list(NORTH, SOUTH)) ? terminal_rect["x1"] : terminal_rect["y1"]
		var/axis_end = (check_dir in list(NORTH, SOUTH)) ? terminal_rect["x2"] : terminal_rect["y2"]
		for(var/run_start in axis_start to axis_end - frontage_width + 1)
			var/controlled_opening = !(connection.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
			if(controlled_opening && frontage_width < 3)
				continue
			var/list/wall_run = list()
			var/list/route_run = list()
			var/run_valid = TRUE
			var/opening_start_offset = max(round((frontage_width - opening_width) / 2), 0)
			for(var/run_offset in 0 to frontage_width - 1)
				var/local_x = (check_dir in list(NORTH, SOUTH)) ? run_start + run_offset : (check_dir == EAST ? terminal_rect["x2"] : terminal_rect["x1"])
				var/local_y = (check_dir in list(EAST, WEST)) ? run_start + run_offset : (check_dir == NORTH ? terminal_rect["y1"] : terminal_rect["y2"])
				var/turf/room_turf = context.local_turf(local_x, local_y)
				var/turf/wall_turf = get_step(room_turf, world_check_dir)
				var/turf/route_turf = get_step(wall_turf, world_check_dir)
				var/opening_offset = run_offset >= opening_start_offset && run_offset < opening_start_offset + opening_width
				if(building_layout_partial_room_cell_carved_by_nested_child(candidate.topology_graph, partial, room_id, local_x, local_y) || !free_lookup[wall_turf] || (opening_offset && !reachable[route_turf]))
					run_valid = FALSE
					break
				wall_run += wall_turf
				if(opening_offset)
					route_run += route_turf
			if(run_valid)
				return list(
					"room_id" = room_id,
					"circulation_id" = get_building_layout_connection_circulation_node_id(context, connection),
					"room_side_dir" = world_check_dir,
					"wall_run" = wall_run,
					"route_run" = route_run,
				)
	return null

/datum/world_edit_generator/building_layout/proc/assign_building_layout_partial_route_terminals(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, list/route_connections, connection_index, list/free_lookup, list/reachable, list/reserved_wall_lookup, list/reserved_route_lookup, list/selected_hints, turf/entry_seed)
	if(connection_index > length(route_connections))
		return building_layout_partial_terminal_routes_connected(entry_seed, free_lookup, selected_hints)
	var/datum/world_edit_building_layout_room_connection/connection = route_connections[connection_index]
	var/room_id = get_building_layout_connection_functional_node_id(context, connection)
	var/list/terminal_rect = partial.placements[room_id]
	var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_id)
	if(!istype(connection) || !islist(terminal_rect) || !istype(room_contract))
		return FALSE
	var/opening_width = max(connection.min_opening_width, room_contract.min_route_opening_width, 1)
	if(connection.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
		opening_width = max(opening_width, 2)
	opening_width = min(opening_width, max(connection.max_opening_width, opening_width))
	var/frontage_width = max(connection.min_shared_wall, opening_width)
	for(var/check_dir in GLOB.cardinals)
		var/world_check_dir = context.local_dir_to_world_dir(check_dir)
		var/axis_start = (check_dir in list(NORTH, SOUTH)) ? terminal_rect["x1"] : terminal_rect["y1"]
		var/axis_end = (check_dir in list(NORTH, SOUTH)) ? terminal_rect["x2"] : terminal_rect["y2"]
		for(var/run_start in axis_start to axis_end - frontage_width + 1)
			var/controlled_opening = !(connection.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
			if(controlled_opening && frontage_width < 3)
				continue
			var/list/wall_run = list()
			var/list/route_run = list()
			var/run_valid = TRUE
			var/opening_start_offset = max(round((frontage_width - opening_width) / 2), 0)
			for(var/run_offset in 0 to frontage_width - 1)
				var/local_x = (check_dir in list(NORTH, SOUTH)) ? run_start + run_offset : (check_dir == EAST ? terminal_rect["x2"] : terminal_rect["x1"])
				var/local_y = (check_dir in list(EAST, WEST)) ? run_start + run_offset : (check_dir == NORTH ? terminal_rect["y1"] : terminal_rect["y2"])
				var/turf/room_turf = context.local_turf(local_x, local_y)
				var/turf/wall_turf = get_step(room_turf, world_check_dir)
				var/turf/route_turf = get_step(wall_turf, world_check_dir)
				var/opening_offset = run_offset >= opening_start_offset && run_offset < opening_start_offset + opening_width
				var/reject_reason = ""
				if(building_layout_partial_room_cell_carved_by_nested_child(candidate.topology_graph, partial, room_id, local_x, local_y))
					reject_reason = "room_frontage_unavailable"
				else if(!free_lookup[wall_turf])
					reject_reason = "wall_unavailable"
				else if(reserved_wall_lookup[wall_turf] || reserved_route_lookup[wall_turf])
					reject_reason = "wall_reserved"
				else if(opening_offset && !reachable[route_turf])
					reject_reason = "route_unreachable"
				else if(opening_offset && (reserved_route_lookup[route_turf] || reserved_wall_lookup[route_turf]))
					reject_reason = "route_reserved"
				if(length(reject_reason))
					var/list/reject_counts = context.state.config["layout_partial_terminal_reject_counts"]
					if(!islist(reject_counts))
						reject_counts = list()
						context.state.config["layout_partial_terminal_reject_counts"] = reject_counts
					var/reject_key = "[world_check_dir]:[reject_reason]"
					reject_counts[reject_key] = (reject_counts[reject_key] || 0) + 1
					run_valid = FALSE
					break
				wall_run += wall_turf
				if(opening_offset)
					route_run += route_turf
			if(!run_valid)
				continue
			for(var/turf/wall_turf as anything in wall_run)
				reserved_wall_lookup[wall_turf] = TRUE
			for(var/turf/route_turf as anything in route_run)
				reserved_route_lookup[route_turf] = TRUE
			selected_hints[connection.id] = list(
				"room_id" = room_id,
				"circulation_id" = get_building_layout_connection_circulation_node_id(context, connection),
				"room_side_dir" = world_check_dir,
				"wall_run" = wall_run.Copy(),
				"route_run" = route_run.Copy(),
			)
			if(assign_building_layout_partial_route_terminals(context, candidate, partial, route_connections, connection_index + 1, free_lookup, reachable, reserved_wall_lookup, reserved_route_lookup, selected_hints, entry_seed))
				return TRUE
			selected_hints -= connection.id
			for(var/turf/wall_turf as anything in wall_run)
				reserved_wall_lookup -= wall_turf
			for(var/turf/route_turf as anything in route_run)
				reserved_route_lookup -= route_turf
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_partial_terminal_routes_connected(turf/entry_seed, list/free_lookup, list/selected_hints)
	if(!istype(entry_seed) || !islist(free_lookup) || !free_lookup[entry_seed] || !islist(selected_hints))
		return FALSE
	var/list/blocked_wall_lookup = list()
	for(var/connection_id as anything in selected_hints)
		var/list/terminal_hint = selected_hints[connection_id]
		for(var/turf/wall_turf as anything in terminal_hint?["wall_run"])
			if(istype(wall_turf))
				blocked_wall_lookup[wall_turf] = TRUE
	var/list/reachable_without_terminal_walls = list()
	reachable_without_terminal_walls[entry_seed] = TRUE
	var/list/open = list(entry_seed)
	var/open_index = 1
	while(open_index <= length(open))
		var/turf/current = open[open_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby = get_step(current, check_dir)
			if(!free_lookup[nearby] || blocked_wall_lookup[nearby] || reachable_without_terminal_walls[nearby])
				continue
			reachable_without_terminal_walls[nearby] = TRUE
			open += nearby
	for(var/connection_id as anything in selected_hints)
		var/list/terminal_hint = selected_hints[connection_id]
		var/list/route_run = terminal_hint?["route_run"]
		var/turf/route_target = islist(route_run) && length(route_run) ? route_run[max(round((length(route_run) + 1) / 2), 1)] : null
		if(!istype(route_target) || !reachable_without_terminal_walls[route_target])
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_terminal_topology_signature(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context) || !istype(partial) || !islist(partial.estimated_route_terminals))
		return ""
	var/list/parts = list()
	for(var/connection_id as anything in partial.estimated_route_terminals)
		var/list/terminal_hint = partial.estimated_route_terminals[connection_id]
		var/room_id = "[terminal_hint?["room_id"] || ""]"
		var/list/rect = partial.placements[room_id]
		var/list/wall_run = terminal_hint?["wall_run"]
		var/turf/wall_turf = islist(wall_run) && length(wall_run) ? wall_run[1] : null
		var/list/wall_local = context.local_coordinates(wall_turf)
		if(!length(room_id) || !islist(rect) || !islist(wall_local))
			continue
		var/side = "unknown"
		if(wall_local["x"] == rect["x1"] - 1)
			side = "west"
		else if(wall_local["x"] == rect["x2"] + 1)
			side = "east"
		else if(wall_local["y"] == rect["y1"] - 1)
			side = "south"
		else if(wall_local["y"] == rect["y2"] + 1)
			side = "north"
		var/center_x = (rect["x1"] + rect["x2"]) / 2
		var/center_y = (rect["y1"] + rect["y2"]) / 2
		var/delta_x = center_x - (context.local_width() + 1) / 2
		var/delta_y = center_y - (context.local_height() + 1) / 2
		var/field_side = abs(delta_x) > abs(delta_y) ? (delta_x < 0 ? "west" : "east") : (delta_y < 0 ? "south" : "north")
		if(abs(delta_x) < 0.5 && abs(delta_y) < 0.5)
			field_side = "center"
		parts += "[connection_id]:door=[side]:field=[field_side]"
	return jointext(parts, "|")

/datum/world_edit_generator/building_layout/proc/score_building_layout_partial_rect(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_allocation_partial/partial, datum/world_edit_building_layout_room_contract/room_contract, datum/world_edit_building_layout_influence_zone/zone, list/rect, target_area, allocation_variant)
	var/score = 100000 + zone.priority
	// Authored footprint/clearance/approach area is the allocation target. Keep
	// bounded alternatives, but do not let incidental partition overlap turn a
	// compact required room into an oversized rectangle that starves siblings.
	score -= abs(building_layout_rect_area(rect) - target_area) * 180
	var/center_x = round((rect["x1"] + rect["x2"]) / 2)
	var/center_y = round((rect["y1"] + rect["y2"]) / 2)
	var/field_x = round((context.local_width() + 1) / 2)
	var/field_y = round((context.local_height() + 1) / 2)
	var/datum/world_edit_building_layout_topology_node/node = candidate.topology_graph?.get_node(room_contract.id)
	if(node?.id == candidate.topology_graph?.root_node_id)
		score += building_layout_rect_area(rect) * 80
		score -= (abs(center_x - field_x) + abs(center_y - field_y)) * 300
	// Only authored non-route edges may reward partition overlap. A generic
	// overlap bonus silently invents adjacency between unrelated rooms and pulls
	// repeated public rooms into the center of a wing, starving their sibling.
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph?.get_edges_for(room_contract.id))
		if(!istype(edge) || edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
			continue
		var/other_id = edge.from_id == room_contract.id ? edge.to_id : edge.from_id
		var/list/other_rect = partial.placements[other_id]
		if(islist(other_rect))
			if(edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
				var/list/contact_sides = list(
					"west" = rect["x1"] == other_rect["x1"] + 1,
					"east" = rect["x2"] == other_rect["x2"] - 1,
					"south" = rect["y1"] == other_rect["y1"] + 1,
					"north" = rect["y2"] == other_rect["y2"] - 1,
				)
				var/list/used_sides = list()
				for(var/existing_id as anything in partial.placement_order)
					var/datum/world_edit_building_layout_topology_node/existing_node = candidate.topology_graph?.get_node(existing_id)
					var/list/existing_rect = partial.placements[existing_id]
					if(!istype(existing_node) || existing_node.parent_id != other_id || !islist(existing_rect) || !building_layout_nodes_are_typed_nested_siblings(candidate.topology_graph, room_contract.id, existing_id))
						continue
					// Siblings are not connected by a functional topology edge, but their
					// compiler-authored packing does share canonical straight partitions.
					score += building_layout_rect_partition_overlap(rect, existing_rect) * 1500
					score += building_layout_rect_parent_aisle_overlap(rect, existing_rect) * 1800
					used_sides["west"] = used_sides["west"] || existing_rect["x1"] == other_rect["x1"] + 1
					used_sides["east"] = used_sides["east"] || existing_rect["x2"] == other_rect["x2"] - 1
					used_sides["south"] = used_sides["south"] || existing_rect["y1"] == other_rect["y1"] + 1
					used_sides["north"] = used_sides["north"] || existing_rect["y2"] == other_rect["y2"] - 1
				// Reuse already occupied parent sides. This keeps nested packing compact
				// while preserving at least one straight authored wall frontage for the
				// parent's own required composition.
				for(var/contact_side as anything in contact_sides)
					if(contact_sides[contact_side])
						score += used_sides[contact_side] ? 5000 : 500
				continue
			var/shared_length = building_layout_rect_partition_overlap(rect, other_rect)
			var/required_length = max(edge.min_shared_wall, 1)
			score += min(shared_length, required_length) * 1200
			// Once the hard overlap is satisfied, consuming more of the same root
			// frontage can make later spokes impossible.  Prefer the authored
			// overlap and leave the remaining partition axes available.
			score -= max(shared_length - required_length, 0) * 1200
	switch(candidate.family_policy_id)
		if("hub_spoke")
			score -= (node?.depth || 0) ? abs((abs(center_x - field_x) + abs(center_y - field_y)) - 5) * 20 : 0
		if("open_bay_perimeter")
			if(room_contract.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY || room_contract.privacy_class == "public")
				score -= (abs(center_x - field_x) + abs(center_y - field_y)) * 40
		if("secure_core")
			if(room_contract.privacy_class == "secure")
				score -= (abs(center_x - field_x) + abs(center_y - field_y)) * 80
	if(allocation_variant % 2)
		score += center_x
	if(allocation_variant >= 2)
		score += center_y
	score += ((center_x * 17 + center_y * 31 + allocation_variant * 13) % 23)
	return score

/datum/world_edit_generator/building_layout/proc/building_layout_rect_parent_aisle_overlap(list/a, list/b)
	if(!islist(a) || !islist(b))
		return 0
	if(a["x2"] + 6 == b["x1"] || b["x2"] + 6 == a["x1"])
		return max(min(a["y2"], b["y2"]) - max(a["y1"], b["y1"]) + 1, 0)
	if(a["y2"] + 6 == b["y1"] || b["y2"] + 6 == a["y1"])
		return max(min(a["x2"], b["x2"]) - max(a["x1"], b["x1"]) + 1, 0)
	return 0

/datum/world_edit_generator/building_layout/proc/insert_building_layout_rect_option(list/options, list/option, limit)
	if(!islist(options) || !islist(option))
		return
	var/spatial_bucket = "[option["spatial_bucket"] || ""]"
	if(length(spatial_bucket))
		for(var/existing_index in 1 to length(options))
			var/list/existing_option = options[existing_index]
			if("[existing_option?["spatial_bucket"] || ""]" != spatial_bucket)
				continue
			if(round(text2num("[option["score"]]") || 0) <= round(text2num("[existing_option?["score"]]") || 0))
				return
			options.Cut(existing_index, existing_index + 1)
			break
	options.len++
	options[options.len] = option
	for(var/index = length(options), index > 1, index--)
		var/list/current = options[index]
		var/list/previous = options[index - 1]
		if(round(text2num("[current?["score"]]") || 0) <= round(text2num("[previous?["score"]]") || 0))
			break
		options[index - 1] = current
		options[index] = previous
	if(length(options) > limit)
		options.Cut(limit + 1)

/datum/world_edit_generator/building_layout/proc/build_building_layout_partial_beam_signature(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_allocation_partial/partial)
	if(!istype(context) || !istype(partial))
		return ""
	var/signature = "[partial.terminal_topology_signature]"
	if(!length(partial.placement_order))
		return signature
	var/latest_room_id = partial.placement_order[length(partial.placement_order)]
	var/list/latest_rect = partial.placements[latest_room_id]
	if(!islist(latest_rect))
		return signature
	var/local_mid_x = (context.local_width() + 1) / 2
	var/local_mid_y = (context.local_height() + 1) / 2
	var/x_sector = latest_rect["x2"] < local_mid_x ? "left" : (latest_rect["x1"] > local_mid_x ? "right" : "center")
	var/y_sector = latest_rect["y2"] < local_mid_y ? "front" : (latest_rect["y1"] > local_mid_y ? "back" : "center")
	return "[signature]|room=[latest_room_id]|x=[x_sector]|y=[y_sector]"

/datum/world_edit_generator/building_layout/proc/insert_building_layout_partial(datum/world_edit_building_layout_context/context, list/partials, datum/world_edit_building_layout_allocation_partial/partial, limit)
	if(!istype(context) || !islist(partials) || !istype(partial))
		return
	// Route-terminal sides are typed feasibility state, not a cosmetic score.
	// Retain two alternatives per typed-terminal and geometric sector branch so
	// a locally attractive same-side placement cannot evict the opposite wing
	// that later required rooms need in order to complete the authored graph.
	var/beam_signature = build_building_layout_partial_beam_signature(context, partial)
	if(length(beam_signature))
		var/list/matching_indices = list()
		for(var/existing_index in 1 to length(partials))
			var/datum/world_edit_building_layout_allocation_partial/existing = partials[existing_index]
			if(istype(existing) && build_building_layout_partial_beam_signature(context, existing) == beam_signature)
				matching_indices += existing_index
		if(length(matching_indices) >= 2)
			var/worst_index = matching_indices[length(matching_indices)]
			var/datum/world_edit_building_layout_allocation_partial/worst_match = partials[worst_index]
			if(istype(worst_match) && partial.score <= worst_match.score)
				return
			partials.Cut(worst_index, worst_index + 1)
	partials.len++
	partials[partials.len] = partial
	for(var/index = length(partials), index > 1, index--)
		var/datum/world_edit_building_layout_allocation_partial/current = partials[index]
		var/datum/world_edit_building_layout_allocation_partial/previous = partials[index - 1]
		if(istype(previous) && current.score <= previous.score)
			break
		partials[index - 1] = current
		partials[index] = previous
	if(length(partials) > limit)
		partials.Cut(limit + 1)
