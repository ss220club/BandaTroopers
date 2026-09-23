/datum/world_edit_generator/building_layout/proc/add_building_layout_connection(datum/world_edit_building_layout_candidate/candidate, connection_id, from_node_id, to_node_id, privacy = "public", required = TRUE, edge_kind = WORLD_EDIT_BUILDING_EDGE_SHARED, opening_policy = WORLD_EDIT_BUILDING_OPENING_DOOR, route_policy = WORLD_EDIT_BUILDING_ROUTE_POLICY_DIRECT)
	if(!istype(candidate))
		return null
	var/datum/world_edit_building_layout_room_connection/connection = new(connection_id, from_node_id, to_node_id, privacy, required, edge_kind, opening_policy, route_policy)
	candidate.add_room_connection(connection)
	return connection

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_lookups(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(candidate))
		return
	refresh_building_layout_candidate_lookups(candidate)
	if(istype(context) && candidate.wall_model_ready)
		candidate.wall_lookup = candidate.solved_wall_lookup

/datum/world_edit_generator/building_layout/proc/get_building_layout_region_lookup(datum/world_edit_building_layout_candidate/candidate, region_id)
	var/list/lookup = list()
	if(!istype(candidate))
		return lookup
	if("[region_id]" == "route")
		return islist(candidate.route_lookup) && length(candidate.route_lookup) ? candidate.route_lookup : building_layout_candidate_route_lookup(candidate)
	var/datum/world_edit_building_layout_room_plan/room_plan = candidate.get_room_plan(region_id)
	if(istype(room_plan))
		return room_plan.turf_lookup
	var/datum/world_edit_building_layout_topology_node/node = candidate.topology_graph?.get_node(region_id)
	var/zone_id = "[node?.room_contract?.zone_id || region_id]"
	for(var/turf/route_turf as anything in candidate.route_zone_by_turf)
		if(candidate.route_zone_by_turf[route_turf] == zone_id)
			lookup[route_turf] = TRUE
	return lookup

/datum/world_edit_generator/building_layout/proc/get_building_layout_opening_endpoint_lookups(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, from_node_id, to_node_id, terminal_id = "")
	var/list/from_lookup = get_building_layout_region_lookup(candidate, from_node_id)
	var/list/to_lookup = get_building_layout_region_lookup(candidate, to_node_id)
	if(!istype(context?.program_contract) || !istype(candidate))
		return list("from_lookup" = from_lookup, "to_lookup" = to_lookup)
	var/datum/world_edit_building_layout_room_contract/from_contract = context.program_contract.get_room_contract(from_node_id)
	var/datum/world_edit_building_layout_room_contract/to_contract = context.program_contract.get_room_contract(to_node_id)
	var/functional_room_id = ""
	if(istype(from_contract) && from_contract.counts_toward_target)
		functional_room_id = from_contract.id
	else if(istype(to_contract) && to_contract.counts_toward_target)
		functional_room_id = to_contract.id
	var/list/terminal_reservation = candidate.get_route_access_reservation(functional_room_id, terminal_id)
	var/list/terminal_route_run = terminal_reservation?["route_run"]
	// Segment ownership remains single-valued. Preserve the edge-specific typed
	// transition for every consumer of the opening contract, including quality
	// validation after route ownership has been finalized.
	if(islist(terminal_route_run) && istype(from_contract) && !from_contract.counts_toward_target)
		from_lookup = from_lookup.Copy()
		for(var/turf/terminal_turf as anything in terminal_route_run)
			if(candidate.route_lookup[terminal_turf])
				from_lookup[terminal_turf] = TRUE
	if(islist(terminal_route_run) && istype(to_contract) && !to_contract.counts_toward_target)
		to_lookup = to_lookup.Copy()
		for(var/turf/terminal_turf as anything in terminal_route_run)
			if(candidate.route_lookup[terminal_turf])
				to_lookup[terminal_turf] = TRUE
	return list("from_lookup" = from_lookup, "to_lookup" = to_lookup)

/datum/world_edit_generator/building_layout/proc/collect_building_layout_opening_candidates(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_connection/connection, datum/world_edit_building_layout_room_contract/room_contract = null)
	var/list/opening_candidates = list()
	if(!istype(context) || !istype(candidate) || !istype(connection))
		return opening_candidates
	if(!istype(room_contract))
		room_contract = get_building_layout_connection_room_contract(context, connection)
	var/list/endpoint_lookups = get_building_layout_opening_endpoint_lookups(context, candidate, connection.from_node_id, connection.to_node_id, connection.id)
	var/list/from_lookup = endpoint_lookups["from_lookup"]
	var/list/to_lookup = endpoint_lookups["to_lookup"]
	if(!length(from_lookup) || !length(to_lookup))
		return opening_candidates
	var/opening_kind = get_building_layout_connection_opening_kind(context, connection, room_contract, candidate)
	var/datum/world_edit_building_layout_opening_candidate/reserved_candidate = build_reserved_building_layout_opening_candidate(context, candidate, connection, room_contract, from_lookup, to_lookup, opening_kind)
	if(istype(reserved_candidate))
		opening_candidates += reserved_candidate
	var/index = 0
	for(var/turf/from_turf as anything in from_lookup)
		if(!istype(from_turf))
			continue
		for(var/room_to_wall_dir as anything in GLOB.cardinals)
			var/turf/opening_turf = get_step(from_turf, room_to_wall_dir)
			var/turf/to_turf = get_step(opening_turf, room_to_wall_dir)
			if(!to_lookup[to_turf])
				continue
			var/door_dir = turn(room_to_wall_dir, 180)
			if(!building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir))
				continue
			var/datum/world_edit_building_layout_opening_candidate/opening_candidate = new
			index++
			opening_candidate.id = "[connection.id]_[index]"
			opening_candidate.opening_turf = opening_turf
			opening_candidate.dir = door_dir
			opening_candidate.from_room_id = connection.from_node_id
			opening_candidate.to_room_id = connection.to_node_id
			opening_candidate.privacy = connection.privacy
			opening_candidate.segment_len = building_layout_shared_wall_run_length_for_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir)
			var/opening_width = get_building_layout_connection_opening_width(room_contract, opening_kind, opening_candidate.segment_len, connection)
			opening_candidate.opening_turfs = build_building_layout_opening_turf_run(context, candidate, from_lookup, to_lookup, opening_turf, door_dir, opening_width)
			opening_candidate.segment_center_distance = building_layout_shared_wall_segment_center_distance(context, candidate, from_lookup, to_lookup, opening_turf, door_dir)
			opening_candidate.corner = building_layout_opening_at_segment_end_for_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir)
			var/avoid_near_opening = !istype(room_contract) || (room_contract.avoid_facing_route_doors && !room_contract.allow_public_route_merge)
			opening_candidate.near_other_door = avoid_near_opening && building_layout_opening_near_existing_door(candidate, opening_turf, 1, door_dir)
			opening_candidate.front_clear = building_layout_opening_side_clear(candidate, get_step(opening_turf, door_dir))
			opening_candidate.back_clear = building_layout_opening_side_clear(candidate, get_step(opening_turf, turn(door_dir, 180)))
			validate_building_layout_opening_candidate(context, candidate, connection, room_contract, opening_candidate)
			score_building_layout_opening_candidate(context, candidate, room_contract, opening_candidate)
			opening_candidates += opening_candidate
	return opening_candidates

/datum/world_edit_generator/building_layout/proc/build_reserved_building_layout_opening_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_connection/connection, datum/world_edit_building_layout_room_contract/room_contract, list/from_lookup, list/to_lookup, opening_kind)
	if(!istype(context) || !istype(candidate) || !istype(connection) || !islist(from_lookup) || !islist(to_lookup))
		return null
	var/room_id = get_building_layout_connection_functional_node_id(context, connection)
	var/list/reservation = candidate.get_route_access_reservation(room_id, connection.id)
	var/list/wall_run = reservation?["wall_run"]
	var/list/route_run = reservation?["route_run"]
	if(!islist(wall_run) || !length(wall_run) || !islist(route_run) || !length(route_run))
		return null
	var/list/reserved_route_lookup = list()
	for(var/turf/reserved_route_turf as anything in route_run)
		if(istype(reserved_route_turf))
			reserved_route_lookup[reserved_route_turf] = TRUE
	var/turf/opening_turf = null
	var/door_dir = 0
	for(var/turf/reserved_wall_turf as anything in wall_run)
		if(!istype(reserved_wall_turf))
			continue
		for(var/check_dir in GLOB.cardinals)
			var/turf/from_turf = get_step(reserved_wall_turf, check_dir)
			var/turf/to_turf = get_step(reserved_wall_turf, turn(check_dir, 180))
			if(from_lookup[from_turf] && to_lookup[to_turf] && (reserved_route_lookup[from_turf] || reserved_route_lookup[to_turf]))
				opening_turf = reserved_wall_turf
				door_dir = check_dir
				break
		if(istype(opening_turf))
			break
	if(!(door_dir in GLOB.cardinals) || !building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir))
		return null
	var/datum/world_edit_building_layout_opening_candidate/opening_candidate = new
	opening_candidate.id = "[connection.id]_reserved"
	opening_candidate.opening_turf = opening_turf
	opening_candidate.dir = door_dir
	opening_candidate.from_room_id = connection.from_node_id
	opening_candidate.to_room_id = connection.to_node_id
	opening_candidate.privacy = connection.privacy
	opening_candidate.segment_len = max(building_layout_shared_wall_run_length_for_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir), length(wall_run))
	var/opening_width = get_building_layout_connection_opening_width(room_contract, opening_kind, opening_candidate.segment_len, connection)
	opening_candidate.opening_turfs = build_building_layout_opening_turf_run(context, candidate, from_lookup, to_lookup, opening_turf, door_dir, opening_width)
	opening_candidate.segment_center_distance = building_layout_shared_wall_segment_center_distance(context, candidate, from_lookup, to_lookup, opening_turf, door_dir)
	var/axis_dir = turn(door_dir, 90)
	// The route terminal reserves the whole canonical wall run even though only
	// the selected access cell belongs to the route floor.  Corner validity must
	// therefore use that authored reservation, not the one-cell route lookup.
	opening_candidate.corner = !(get_step(opening_turf, axis_dir) in wall_run) || !(get_step(opening_turf, turn(axis_dir, 180)) in wall_run)
	var/avoid_near_opening = !istype(room_contract) || (room_contract.avoid_facing_route_doors && !room_contract.allow_public_route_merge)
	opening_candidate.near_other_door = avoid_near_opening && building_layout_opening_near_existing_door(candidate, opening_turf, 1, door_dir)
	opening_candidate.front_clear = building_layout_opening_side_clear(candidate, get_step(opening_turf, door_dir))
	opening_candidate.back_clear = building_layout_opening_side_clear(candidate, get_step(opening_turf, turn(door_dir, 180)))
	validate_building_layout_opening_candidate(context, candidate, connection, room_contract, opening_candidate)
	score_building_layout_opening_candidate(context, candidate, room_contract, opening_candidate)
	if(!length(opening_candidate.reject_reasons))
		opening_candidate.score += 5000
	return opening_candidate

/datum/world_edit_generator/building_layout/proc/select_best_building_layout_opening_candidate(list/opening_candidates)
	var/datum/world_edit_building_layout_opening_candidate/best = null
	var/best_score = -999999999
	if(!islist(opening_candidates))
		return null
	for(var/datum/world_edit_building_layout_opening_candidate/opening_candidate as anything in opening_candidates)
		if(!istype(opening_candidate) || length(opening_candidate.reject_reasons))
			continue
		if(!istype(best) || opening_candidate.score > best_score)
			best = opening_candidate
			best_score = opening_candidate.score
	return best

/datum/world_edit_generator/building_layout/proc/assign_building_layout_openings_bounded(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/connections, connection_index, list/search_state)
	if(!istype(context) || !istype(candidate) || !islist(connections) || !islist(search_state))
		return FALSE
	if(connection_index > length(connections))
		var/list/failed_rooms = list()
		if(building_layout_all_required_compositions_fit(context, candidate, failed_rooms))
			return TRUE
		var/list/leaf_failure_rooms = search_state["leaf_failure_rooms"]
		if(!islist(leaf_failure_rooms))
			leaf_failure_rooms = list()
			search_state["leaf_failure_rooms"] = leaf_failure_rooms
		for(var/failed_room_id as anything in failed_rooms)
			leaf_failure_rooms["[failed_room_id]"] = (leaf_failure_rooms["[failed_room_id]"] || 0) + 1
		if(!islist(search_state["leaf_failure_sample"]))
			var/list/opening_sample = list()
			for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
				if(istype(opening_plan))
					opening_sample += list(list("id" = opening_plan.id, "x" = opening_plan.opening_turf?.x, "y" = opening_plan.opening_turf?.y, "dir" = opening_plan.dir))
			search_state["leaf_failure_sample"] = list("rooms" = failed_rooms.Copy(), "openings" = opening_sample)
		return FALSE
	if((search_state["expansions"] || 0) >= 256)
		return FALSE
	var/list/ordered_connections = connections.Copy()
	var/selected_index = 0
	var/selected_candidate_count = 999999
	var/list/ordered_candidates = list()
	for(var/pending_index in connection_index to length(ordered_connections))
		var/datum/world_edit_building_layout_room_connection/pending_connection = ordered_connections[pending_index]
		if(!istype(pending_connection))
			continue
		var/datum/world_edit_building_layout_room_contract/pending_room_contract = get_building_layout_connection_room_contract(context, pending_connection)
		var/list/pending_candidates = sort_valid_building_layout_opening_candidates(collect_building_layout_opening_candidates(context, candidate, pending_connection, pending_room_contract), 8)
		var/pending_candidate_count = length(pending_candidates) + (pending_connection.required ? 0 : 1)
		if(!selected_index || pending_candidate_count < selected_candidate_count)
			selected_index = pending_index
			selected_candidate_count = pending_candidate_count
			ordered_candidates = pending_candidates
	if(!selected_index)
		return assign_building_layout_openings_bounded(context, candidate, ordered_connections, connection_index + 1, search_state)
	var/datum/world_edit_building_layout_room_connection/connection = ordered_connections[selected_index]
	ordered_connections[selected_index] = ordered_connections[connection_index]
	ordered_connections[connection_index] = connection
	var/datum/world_edit_building_layout_room_contract/room_contract = get_building_layout_connection_room_contract(context, connection)
	var/opening_kind = get_building_layout_connection_opening_kind(context, connection, room_contract, candidate)
	search_state["max_connection_index"] = max(search_state["max_connection_index"] || 0, connection_index)
	if(!length(ordered_candidates) && connection.required)
		var/list/dead_connections = search_state["dead_connections"]
		if(!islist(dead_connections))
			dead_connections = list()
			search_state["dead_connections"] = dead_connections
		dead_connections[connection.id] = (dead_connections[connection.id] || 0) + 1
	for(var/datum/world_edit_building_layout_opening_candidate/opening_candidate as anything in ordered_candidates)
		if((search_state["expansions"] || 0) >= 256)
			break
		search_state["expansions"] = (search_state["expansions"] || 0) + 1
		var/datum/world_edit_building_layout_route_opening_plan/opening_plan = new(connection.id, opening_kind, opening_candidate.opening_turf, opening_candidate.dir, connection.from_node_id, connection.to_node_id)
		configure_building_layout_opening_plan(opening_plan, opening_candidate.opening_turfs, opening_kind)
		opening_plan.public_opening = building_layout_opening_plan_is_public(context, opening_plan)
		opening_plan.emits_door_object = building_layout_opening_plan_emits_door_object(context, opening_plan)
		candidate.add_door_plan(opening_plan)
		if(assign_building_layout_openings_bounded(context, candidate, ordered_connections, connection_index + 1, search_state))
			return TRUE
		candidate.opening_plans.Cut(length(candidate.opening_plans), length(candidate.opening_plans) + 1)
	if(!connection.required)
		return assign_building_layout_openings_bounded(context, candidate, ordered_connections, connection_index + 1, search_state)
	return FALSE

/datum/world_edit_generator/building_layout/proc/sort_valid_building_layout_opening_candidates(list/opening_candidates, limit = 8)
	var/list/result = list()
	for(var/datum/world_edit_building_layout_opening_candidate/opening_candidate as anything in opening_candidates)
		if(!istype(opening_candidate) || length(opening_candidate.reject_reasons))
			continue
		var/insert_at = length(result) + 1
		for(var/index in 1 to length(result))
			var/datum/world_edit_building_layout_opening_candidate/existing = result[index]
			if(opening_candidate.score > existing.score)
				insert_at = index
				break
		result.Insert(insert_at, null)
		result[insert_at] = opening_candidate
		if(length(result) > limit)
			result.Cut(limit + 1)
	return result

/datum/world_edit_generator/building_layout/proc/report_building_layout_opening_search_failure(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/connections, list/search_state)
	if(!istype(context?.state) || !istype(candidate) || !islist(connections))
		return
	for(var/datum/world_edit_building_layout_room_connection/connection as anything in connections)
		if(!istype(connection) || !connection.required)
			continue
		var/datum/world_edit_building_layout_room_contract/room_contract = get_building_layout_connection_room_contract(context, connection)
		var/opening_kind = get_building_layout_connection_opening_kind(context, connection, room_contract, candidate)
		var/list/opening_candidates = collect_building_layout_opening_candidates(context, candidate, connection, room_contract)
		var/list/reject_counts = list()
		var/list/reject_details = list()
		for(var/datum/world_edit_building_layout_opening_candidate/opening_candidate as anything in opening_candidates)
			for(var/reject_reason as anything in opening_candidate.reject_reasons)
				reject_counts[reject_reason] = (reject_counts[reject_reason] || 0) + 1
			reject_details += list(list("id" = opening_candidate.id, "x" = opening_candidate.opening_turf?.x, "y" = opening_candidate.opening_turf?.y, "dir" = opening_candidate.dir, "segment_len" = opening_candidate.segment_len, "opening_width" = length(opening_candidate.opening_turfs), "rejects" = opening_candidate.reject_reasons.Copy()))
		if(!length(opening_candidates))
			candidate.errors += "door.no_shared_wall:[connection.id]"
		else if(!length(sort_valid_building_layout_opening_candidates(opening_candidates, 1)))
			candidate.errors += "door.no_valid_candidate:[connection.id]:[json_encode(reject_counts)]"
		else
			candidate.errors += "door.no_valid_combination:[connection.id]"
		var/connection_room_id = get_building_layout_connection_functional_node_id(context, connection)
		var/list/reservation = candidate.get_route_access_reservation(connection_room_id, connection.id)
		var/list/reservation_report = list()
		for(var/reservation_key as anything in list("wall_run", "route_run"))
			var/list/coord_report = list()
			for(var/turf/reserved_turf as anything in reservation?[reservation_key])
				if(istype(reserved_turf))
					coord_report += "[reserved_turf.x],[reserved_turf.y],[reserved_turf.z]:route=[candidate.route_lookup[reserved_turf] ? 1 : 0]"
			reservation_report[reservation_key] = coord_report
		context.state.add_stage_report("layout_opening_candidate_reject", "failed", "required connection has no globally valid opening assignment", list("candidate_id" = candidate.id, "connection_id" = connection.id, "opening_kind" = opening_kind, "search_expansions" = search_state?["expansions"] || 0, "search_max_connection_index" = search_state?["max_connection_index"] || 0, "search_dead_connections" = islist(search_state?["dead_connections"]) ? search_state["dead_connections"].Copy() : list(), "search_leaf_failure_rooms" = islist(search_state?["leaf_failure_rooms"]) ? search_state["leaf_failure_rooms"].Copy() : list(), "search_leaf_failure_sample" = islist(search_state?["leaf_failure_sample"]) ? search_state["leaf_failure_sample"].Copy() : list(), "candidates" = reject_details, "reservation" = reservation_report))

/datum/world_edit_generator/building_layout/proc/get_building_layout_connection_room_contract(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_connection/connection)
	if(!istype(context?.program_contract) || !istype(connection))
		return null
	var/room_id = get_building_layout_connection_functional_node_id(context, connection)
	return context.program_contract.get_room_contract(room_id)

/datum/world_edit_generator/building_layout/proc/get_building_layout_connection_functional_node_id(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_connection/connection)
	if(!istype(context?.program_contract) || !istype(connection))
		return ""
	for(var/node_id as anything in list(connection.from_node_id, connection.to_node_id))
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(node_id)
		if(istype(room_contract) && room_contract.counts_toward_target)
			return node_id
	return ""

/datum/world_edit_generator/building_layout/proc/get_building_layout_connection_opening_kind(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_connection/connection, datum/world_edit_building_layout_room_contract/room_contract = null, datum/world_edit_building_layout_candidate/candidate = null)
	if(istype(connection) && length(connection.opening_policy))
		return connection.opening_policy
	if(connection?.privacy in list("secure", "controlled"))
		return WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR
	var/opening_kind = istype(room_contract) && length(room_contract.route_opening_kind) ? room_contract.route_opening_kind : WORLD_EDIT_BUILDING_OPENING_DOOR
	if(opening_kind == WORLD_EDIT_BUILDING_OPENING_DOOR && istype(room_contract))
		switch(room_contract.partition_policy)
			if(WORLD_EDIT_BUILDING_PARTITION_OPEN)
				return WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH
			if(WORLD_EDIT_BUILDING_PARTITION_SOFT)
				return WORLD_EDIT_BUILDING_OPENING_ARCH
	return opening_kind

/datum/world_edit_generator/building_layout/proc/get_building_layout_connection_opening_width(datum/world_edit_building_layout_room_contract/room_contract, opening_kind, segment_len, datum/world_edit_building_layout_room_connection/connection = null)
	var/max_segment_width = max(round(text2num("[segment_len]") || 0), 0)
	if(max_segment_width <= 0 || opening_kind == WORLD_EDIT_BUILDING_OPENING_NONE)
		return 0
	var/min_width = max(connection?.min_opening_width || 1, 1)
	var/max_width = max(connection?.max_opening_width || min_width, min_width)
	if(opening_kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
		min_width = max(min_width, 2)
	else
		max_width = min(max_width, 1)
	return min(max_width, max(min_width, min(max_segment_width, max_width)))

/datum/world_edit_generator/building_layout/proc/get_building_layout_opening_plan_room_contract(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_route_opening_plan/opening_plan)
	if(!istype(context?.program_contract) || !istype(opening_plan))
		return null
	for(var/node_id as anything in list(opening_plan.from_room, opening_plan.to_room))
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(node_id)
		if(istype(room_contract) && room_contract.counts_toward_target)
			return room_contract
	return null

/datum/world_edit_generator/building_layout/proc/building_layout_opening_plan_is_public(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_route_opening_plan/opening_plan)
	if(!istype(opening_plan) || opening_plan.kind == "main_exit")
		return FALSE
	if(opening_plan.kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
		return TRUE
	var/datum/world_edit_building_layout_room_contract/room_contract = get_building_layout_opening_plan_room_contract(context, opening_plan)
	if(istype(room_contract))
		if(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE))
			return FALSE
		if(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_OPEN, WORLD_EDIT_BUILDING_PARTITION_SOFT))
			return TRUE
	if(opening_plan.kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
		return TRUE
	if(opening_plan.public_opening)
		return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_opening_plan_emits_door_object(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_route_opening_plan/opening_plan)
	if(!istype(opening_plan))
		return FALSE
	if(opening_plan.kind == "main_exit")
		return TRUE
	if(opening_plan.kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
		return FALSE
	var/datum/world_edit_building_layout_room_contract/room_contract = get_building_layout_opening_plan_room_contract(context, opening_plan)
	if(istype(room_contract))
		if(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE))
			return TRUE
		if(room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_OPEN, WORLD_EDIT_BUILDING_PARTITION_SOFT))
			return FALSE
	if(building_layout_opening_plan_is_public(context, opening_plan))
		return FALSE
	return opening_plan.kind in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR)

/datum/world_edit_generator/building_layout/proc/build_building_layout_opening_turf_run(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/from_lookup, list/to_lookup, turf/opening_turf, door_dir, opening_width)
	var/list/opening_turfs = list()
	var/width = max(round(text2num("[opening_width]") || 0), 0)
	if(width <= 0 || !building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir))
		return opening_turfs
	var/list/segment = list(opening_turf)
	var/turf/check_turf = get_step(opening_turf, turn(door_dir, 90))
	while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, check_turf, door_dir))
		segment.Insert(1, check_turf)
		check_turf = get_step(check_turf, turn(door_dir, 90))
	check_turf = get_step(opening_turf, turn(door_dir, -90))
	while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, check_turf, door_dir))
		segment += check_turf
		check_turf = get_step(check_turf, turn(door_dir, -90))
	if(length(segment) < width)
		return opening_turfs
	var/center_index = max(segment.Find(opening_turf), 1)
	var/start_index = clamp(center_index - round((width - 1) / 2), 1, length(segment) - width + 1)
	for(var/index in start_index to start_index + width - 1)
		opening_turfs += segment[index]
	return opening_turfs

/datum/world_edit_generator/building_layout/proc/configure_building_layout_opening_plan(datum/world_edit_building_layout_route_opening_plan/opening_plan, list/opening_turfs, opening_kind)
	if(!istype(opening_plan))
		return
	if(islist(opening_turfs) && length(opening_turfs))
		opening_plan.opening_turfs = opening_turfs.Copy()
	else if(istype(opening_plan.opening_turf))
		opening_plan.opening_turfs = list(opening_plan.opening_turf)
	opening_plan.opening_width = max(length(opening_plan.opening_turfs), 1)
	opening_plan.kind = length("[opening_kind]") ? "[opening_kind]" : opening_plan.kind
	opening_plan.public_opening = opening_plan.kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH)
	opening_plan.emits_door_object = opening_plan.kind in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR, "main_exit")

/datum/world_edit_generator/building_layout/proc/get_building_layout_opening_plan_turfs(datum/world_edit_building_layout_route_opening_plan/opening_plan)
	var/list/opening_turfs = list()
	if(!istype(opening_plan))
		return opening_turfs
	if(islist(opening_plan.opening_turfs) && length(opening_plan.opening_turfs))
		return opening_plan.opening_turfs.Copy()
	if(istype(opening_plan.opening_turf))
		opening_turfs += opening_plan.opening_turf
	return opening_turfs

/datum/world_edit_generator/building_layout/proc/validate_building_layout_opening_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_connection/connection, datum/world_edit_building_layout_room_contract/room_contract, datum/world_edit_building_layout_opening_candidate/opening_candidate)
	if(!istype(opening_candidate?.opening_turf))
		opening_candidate.reject_reasons += "missing_turf"
		return
	var/opening_kind = get_building_layout_connection_opening_kind(context, connection, room_contract, candidate)
	var/controlled_opening = !(opening_kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH))
	var/min_segment_length = max(connection?.min_shared_wall || 1, controlled_opening ? 1 : 2)
	if(opening_candidate.segment_len < min_segment_length)
		opening_candidate.reject_reasons += "short_segment"
	var/opening_width = length(opening_candidate.opening_turfs)
	if(opening_candidate.segment_len > 0 && (!opening_width || opening_width < max(connection?.min_opening_width || 1, 1) || opening_width > max(connection?.max_opening_width || 1, 1)))
		opening_candidate.reject_reasons += "opening_width"
	var/required_module_frontage = get_building_layout_connection_required_module_frontage(context, connection)
	var/functional_room_id = get_building_layout_connection_functional_node_id(context, connection)
	var/datum/world_edit_building_layout_composition_contract/required_composition = context.program_contract?.get_composition_contract(functional_room_id)
	// Exact curated-module feasibility below may use any canonical wall of the
	// room. Restricting it to the opening's own partition incorrectly rejects a
	// valid perpendicular authored frontage.
	if(required_module_frontage > 0 && (!istype(required_composition) || !length(required_composition.required_groups)) && get_building_layout_opening_remaining_frontage(context, candidate, connection, opening_candidate) < required_module_frontage)
		opening_candidate.reject_reasons += "module_frontage"
	if(!building_layout_opening_preserves_required_composition(context, candidate, connection, opening_candidate))
		opening_candidate.reject_reasons += "required_composition"
	if(opening_candidate.corner && controlled_opening && !connection?.allow_corner && !building_layout_opening_has_wall_shoulders(candidate, opening_candidate.opening_turf, opening_candidate.dir))
		opening_candidate.reject_reasons += "corner"
	if(opening_candidate.near_other_door)
		opening_candidate.reject_reasons += "near_other_door"
	if(!opening_candidate.front_clear)
		opening_candidate.reject_reasons += "front_blocked"
	if(!opening_candidate.back_clear)
		opening_candidate.reject_reasons += "back_blocked"

/datum/world_edit_generator/building_layout/proc/building_layout_opening_has_wall_shoulders(datum/world_edit_building_layout_candidate/candidate, turf/opening_turf, opening_dir)
	if(!istype(candidate) || !istype(opening_turf) || !(opening_dir in GLOB.cardinals))
		return FALSE
	var/turf/left_wall = get_step(opening_turf, turn(opening_dir, 90))
	var/turf/right_wall = get_step(opening_turf, turn(opening_dir, -90))
	return candidate.solved_wall_lookup[left_wall] && candidate.solved_wall_lookup[right_wall]

/datum/world_edit_generator/building_layout/proc/score_building_layout_opening_candidate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_contract/room_contract, datum/world_edit_building_layout_opening_candidate/opening_candidate)
	if(!istype(opening_candidate))
		return 0
	var/score = 0
	score += opening_candidate.segment_len * 20
	if(istype(room_contract) && (room_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_OPEN, WORLD_EDIT_BUILDING_PARTITION_SOFT)))
		score += length(opening_candidate.opening_turfs) * 220
	score -= opening_candidate.segment_center_distance * 15
	if(opening_candidate.front_clear && opening_candidate.back_clear)
		score += 300
	if(opening_candidate.privacy == "private")
		score -= opening_exposes_private_room(context, candidate, opening_candidate) ? 400 : 0
	if(opening_candidate.corner)
		score -= 10000
	if(opening_candidate.near_other_door)
		score -= 1000
	opening_candidate.score = score
	return score

/datum/world_edit_generator/building_layout/proc/building_layout_opening_wall_matches_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/from_lookup, list/to_lookup, turf/opening_turf, door_dir)
	if(!istype(context?.state) || !istype(candidate) || !islist(from_lookup) || !islist(to_lookup) || !istype(opening_turf) || !(door_dir in GLOB.cardinals))
		return FALSE
	if(!context.state.geometry.footprint_lookup[opening_turf] || context.state.geometry.boundary_lookup[opening_turf])
		return FALSE
	if(building_layout_opening_turf_is_room_or_route(candidate, opening_turf))
		return FALSE
	var/turf/from_turf = get_step(opening_turf, door_dir)
	var/turf/to_turf = get_step(opening_turf, turn(door_dir, 180))
	return from_lookup[from_turf] && to_lookup[to_turf]

/datum/world_edit_generator/building_layout/proc/building_layout_shared_wall_run_length_for_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/from_lookup, list/to_lookup, turf/opening_turf, door_dir)
	if(!building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir))
		return 0
	var/run_length = 1
	for(var/axis_dir in list(turn(door_dir, 90), turn(door_dir, -90)))
		var/turf/check_turf = get_step(opening_turf, axis_dir)
		while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, check_turf, door_dir))
			run_length++
			check_turf = get_step(check_turf, axis_dir)
	return run_length

/datum/world_edit_generator/building_layout/proc/building_layout_shared_wall_segment_center_distance(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/from_lookup, list/to_lookup, turf/opening_turf, door_dir)
	if(!building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir))
		return 999
	var/left_count = 0
	var/turf/check_turf = get_step(opening_turf, turn(door_dir, 90))
	while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, check_turf, door_dir))
		left_count++
		check_turf = get_step(check_turf, turn(door_dir, 90))
	var/right_count = 0
	check_turf = get_step(opening_turf, turn(door_dir, -90))
	while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, check_turf, door_dir))
		right_count++
		check_turf = get_step(check_turf, turn(door_dir, -90))
	return abs(left_count - right_count)

/datum/world_edit_generator/building_layout/proc/get_building_layout_connection_required_module_frontage(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_connection/connection)
	if(!istype(context?.program_contract) || !istype(connection))
		return 0
	if(connection.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
		var/datum/world_edit_building_layout_topology_node/from_node = context.program_contract.topology_graph?.get_node(connection.from_node_id)
		var/datum/world_edit_building_layout_topology_node/to_node = context.program_contract.topology_graph?.get_node(connection.to_node_id)
		var/child_id = to_node?.parent_id == connection.from_node_id ? connection.to_node_id : (from_node?.parent_id == connection.to_node_id ? connection.from_node_id : connection.to_node_id)
		var/datum/world_edit_building_layout_room_contract/child_contract = context.program_contract.get_room_contract(child_id)
		return max(child_contract?.min_wall_frontage || 0, 0)
	var/datum/world_edit_building_layout_room_contract/from_contract = context.program_contract.get_room_contract(connection.from_node_id)
	var/datum/world_edit_building_layout_room_contract/to_contract = context.program_contract.get_room_contract(connection.to_node_id)
	return max(from_contract?.min_wall_frontage || 0, to_contract?.min_wall_frontage || 0)

/datum/world_edit_generator/building_layout/proc/get_building_layout_opening_remaining_frontage(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_connection/connection, datum/world_edit_building_layout_opening_candidate/opening_candidate)
	if(!istype(context) || !istype(candidate) || !istype(connection) || !istype(opening_candidate?.opening_turf))
		return 0
	var/list/from_lookup = get_building_layout_region_lookup(candidate, connection.from_node_id)
	var/list/to_lookup = get_building_layout_region_lookup(candidate, connection.to_node_id)
	var/axis_dir = turn(opening_candidate.dir, 90)
	var/turf/segment_start = opening_candidate.opening_turf
	while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, get_step(segment_start, turn(axis_dir, 180)), opening_candidate.dir))
		segment_start = get_step(segment_start, turn(axis_dir, 180))
	var/list/opening_lookup = list()
	for(var/turf/opening_turf as anything in opening_candidate.opening_turfs)
		if(istype(opening_turf))
			opening_lookup[opening_turf] = TRUE
	var/opening_kind = get_building_layout_connection_opening_kind(context, connection, get_building_layout_connection_room_contract(context, connection), candidate)
	if(opening_kind in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR))
		var/list/cone_profile = get_building_internal_door_cone_profile(context.state)
		var/lateral_radius = length(cone_profile) ? max(round(text2num("[cone_profile[1]]") || 0), 0) : 0
		for(var/turf/opening_turf as anything in opening_candidate.opening_turfs)
			if(!istype(opening_turf))
				continue
			for(var/side_dir as anything in list(axis_dir, turn(axis_dir, 180)))
				var/turf/shoulder_turf = opening_turf
				for(var/shoulder_step in 1 to lateral_radius)
					shoulder_turf = get_step(shoulder_turf, side_dir)
					if(istype(shoulder_turf))
						opening_lookup[shoulder_turf] = TRUE
	var/best_run = 0
	var/current_run = 0
	var/turf/check_turf = segment_start
	while(building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, check_turf, opening_candidate.dir))
		if(opening_lookup[check_turf])
			current_run = 0
		else
			current_run++
			best_run = max(best_run, current_run)
		check_turf = get_step(check_turf, axis_dir)
	return best_run

/datum/world_edit_generator/building_layout/proc/building_layout_opening_preserves_required_composition(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_connection/connection, datum/world_edit_building_layout_opening_candidate/opening_candidate)
	if(!istype(context?.state) || !istype(candidate) || !istype(connection) || !istype(opening_candidate?.opening_turf))
		return FALSE
	var/datum/world_edit_building_layout_route_opening_plan/provisional_plan = new(connection.id, get_building_layout_connection_opening_kind(context, connection, get_building_layout_connection_room_contract(context, connection), candidate), opening_candidate.opening_turf, opening_candidate.dir, connection.from_node_id, connection.to_node_id)
	configure_building_layout_opening_plan(provisional_plan, opening_candidate.opening_turfs, provisional_plan.kind)
	provisional_plan.public_opening = building_layout_opening_plan_is_public(context, provisional_plan)
	provisional_plan.emits_door_object = building_layout_opening_plan_emits_door_object(context, provisional_plan)
	candidate.opening_plans += provisional_plan
	var/preserved = TRUE
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	// SHARED, SECURE and NESTED edges may connect two functional rooms.  A
	// provisional opening is valid only when it preserves the authored recipe on
	// every functional endpoint; choosing a single endpoint defers the other
	// room's contradiction to the combinatorial leaf search.
	var/list/endpoint_ids = list(connection.from_node_id, connection.to_node_id)
	for(var/endpoint_id as anything in endpoint_ids)
		var/datum/world_edit_building_layout_room_plan/room_plan = candidate.get_room_plan(endpoint_id)
		var/datum/world_edit_building_layout_composition_contract/composition = context.program_contract?.get_composition_contract(room_plan?.contract_id)
		if(!istype(room_plan) || !istype(composition) || !length(composition.required_groups))
			continue
		var/datum/world_edit_building_zone_spec/zone_spec = context.state.semantic_plan?.get_zone_spec(room_plan.zone_id)
		for(var/datum/world_edit_building_cluster_spec/group as anything in composition.required_groups)
			if(!istype(group))
				continue
			var/list/reject_counts_before = islist(context.state.config["layout_curated_candidate_reject_counts"]) ? context.state.config["layout_curated_candidate_reject_counts"].Copy() : list()
			var/list/module_footprint = get_building_layout_required_group_module_footprint(context.state, zone_spec, group)
			var/datum/world_edit_building_placement_module/module = catalog.get_module(module_footprint?["module_id"])
			if(!istype(module))
				preserved = FALSE
				break
			var/list/blocked_lookup = build_building_layout_scene_blocked_lookup(context, candidate)
			var/module_fits = FALSE
			var/anchor_count = min(length(room_plan.turfs), WORLD_EDIT_BUILDING_MAX_MODULE_ANCHORS)
			for(var/anchor_step in 1 to anchor_count)
				var/anchor_index = 1 + round(((anchor_step - 1) * max(length(room_plan.turfs) - 1, 0)) / max(anchor_count - 1, 1))
				var/turf/origin = room_plan.turfs[anchor_index]
				for(var/dir_to_use as anything in GLOB.cardinals)
					if(islist(build_building_layout_curated_scene_module_candidate(context, candidate, room_plan, group, module, origin, dir_to_use, list(), blocked_lookup)))
						module_fits = TRUE
						break
				if(module_fits)
					break
			if(!module_fits)
				var/list/reject_delta = list()
				var/list/reject_counts_after = context.state.config["layout_curated_candidate_reject_counts"]
				for(var/reject_reason as anything in reject_counts_after)
					var/reject_count = (reject_counts_after[reject_reason] || 0) - (reject_counts_before[reject_reason] || 0)
					if(reject_count > 0)
						reject_delta[reject_reason] = reject_count
				var/list/blocked_coords = list()
				for(var/turf/room_turf as anything in room_plan.turfs)
					if(!blocked_lookup[room_turf])
						continue
					var/list/block_sources = list()
					if(candidate.route_lookup[room_turf])
						block_sources += "route"
					for(var/datum/world_edit_building_layout_route_opening_plan/blocking_plan as anything in candidate.opening_plans)
						if(room_turf in get_building_layout_opening_plan_turfs(blocking_plan))
							block_sources += "opening:[blocking_plan.id]"
						else if(room_turf == get_step(blocking_plan.opening_turf, blocking_plan.dir) || room_turf == get_step(blocking_plan.opening_turf, turn(blocking_plan.dir, 180)))
							block_sources += "threshold:[blocking_plan.id]"
					blocked_coords += "[room_turf.x],[room_turf.y]:[jointext(block_sources, ",")]"
				context.state.add_stage_report("layout_opening_composition_reject", "failed", "required curated module does not fit with provisional opening", list(
					"candidate_id" = candidate.id,
					"connection_id" = connection.id,
					"room_id" = room_plan.id,
					"group_id" = group.id,
					"module_id" = module.id,
					"opening_x" = opening_candidate.opening_turf.x,
					"opening_y" = opening_candidate.opening_turf.y,
					"opening_dir" = opening_candidate.dir,
					"opening_width" = length(opening_candidate.opening_turfs),
					"room_width" = room_plan.x2 - room_plan.x1 + 1,
					"room_height" = room_plan.y2 - room_plan.y1 + 1,
					"blocked_coords" = blocked_coords,
					"reject_counts" = reject_delta,
				))
				preserved = FALSE
				break
		if(!preserved)
			break
	candidate.opening_plans.Cut(length(candidate.opening_plans), length(candidate.opening_plans) + 1)
	return preserved

/datum/world_edit_generator/building_layout/proc/building_layout_all_required_compositions_fit(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/failed_rooms_out = null)
	if(!istype(context?.state) || !istype(candidate))
		return FALSE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!building_layout_room_required_composition_fits(context, candidate, room_plan))
			if(islist(failed_rooms_out))
				failed_rooms_out |= room_plan.id
			else
				return FALSE
	return !islist(failed_rooms_out) || !length(failed_rooms_out)

/datum/world_edit_generator/building_layout/proc/building_layout_room_required_composition_fits(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan)
	if(!istype(context?.state) || !istype(candidate) || !istype(room_plan))
		return FALSE
	var/datum/world_edit_building_layout_composition_contract/composition = context.program_contract?.get_composition_contract(room_plan.contract_id)
	if(!istype(composition) || !length(composition.required_groups))
		return TRUE
	var/datum/world_edit_building_zone_spec/zone_spec = context.state.semantic_plan?.get_zone_spec(room_plan.zone_id)
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	for(var/datum/world_edit_building_cluster_spec/group as anything in composition.required_groups)
		if(!istype(group))
			continue
		var/list/reject_counts_before = islist(context.state.config["layout_curated_candidate_reject_counts"]) ? context.state.config["layout_curated_candidate_reject_counts"].Copy() : list()
		var/list/module_footprint = get_building_layout_required_group_module_footprint(context.state, zone_spec, group)
		var/datum/world_edit_building_placement_module/module = catalog.get_module(module_footprint?["module_id"])
		if(!istype(module))
			return FALSE
		var/list/blocked_lookup = build_building_layout_scene_blocked_lookup(context, candidate)
		var/module_fits = FALSE
		var/anchor_count = min(length(room_plan.turfs), WORLD_EDIT_BUILDING_MAX_MODULE_ANCHORS)
		for(var/anchor_step in 1 to anchor_count)
			var/anchor_index = 1 + round(((anchor_step - 1) * max(length(room_plan.turfs) - 1, 0)) / max(anchor_count - 1, 1))
			var/turf/origin = room_plan.turfs[anchor_index]
			for(var/dir_to_use as anything in GLOB.cardinals)
				if(islist(build_building_layout_curated_scene_module_candidate(context, candidate, room_plan, group, module, origin, dir_to_use, list(), blocked_lookup)))
					module_fits = TRUE
					break
			if(module_fits)
				break
		if(!module_fits)
			var/list/reported = context.state.config["layout_composition_fit_reject_reported"]
			if(!islist(reported))
				reported = list()
				context.state.config["layout_composition_fit_reject_reported"] = reported
			var/report_key = "[candidate.id]|[room_plan.id]"
			if(!reported[report_key])
				reported[report_key] = TRUE
				var/list/reject_delta = list()
				var/list/reject_counts_after = context.state.config["layout_curated_candidate_reject_counts"]
				for(var/reject_reason as anything in reject_counts_after)
					var/reject_count = (reject_counts_after[reject_reason] || 0) - (reject_counts_before[reject_reason] || 0)
					if(reject_count > 0)
						reject_delta[reject_reason] = reject_count
				var/list/blocked_coords = list()
				var/list/wall_frontage_coords = list()
				for(var/turf/room_turf as anything in room_plan.turfs)
					if(blocked_lookup[room_turf])
						blocked_coords += "[room_turf.x],[room_turf.y]"
					var/list/wall_dirs = get_building_layout_scene_adjacent_wall_dirs(context, candidate, room_turf)
					if(length(wall_dirs))
						wall_frontage_coords += "[room_turf.x],[room_turf.y]:[jointext(wall_dirs, ",")]"
				context.state.add_stage_report("layout_composition_fit_reject", "failed", "required curated module does not fit after opening assignment", list(
					"candidate_id" = candidate.id,
					"room_id" = room_plan.id,
					"group_id" = group.id,
					"module_id" = module?.id,
					"room_width" = room_plan.x2 - room_plan.x1 + 1,
					"room_height" = room_plan.y2 - room_plan.y1 + 1,
					"room_area" = room_plan.area(),
					"blocked_coords" = blocked_coords,
					"wall_frontage_coords" = wall_frontage_coords,
					"reject_counts" = reject_delta,
				))
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_opening_at_segment_end_for_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/from_lookup, list/to_lookup, turf/opening_turf, door_dir)
	if(!building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, opening_turf, door_dir))
		return TRUE
	for(var/axis_dir in list(turn(door_dir, 90), turn(door_dir, -90)))
		if(!building_layout_opening_wall_matches_regions(context, candidate, from_lookup, to_lookup, get_step(opening_turf, axis_dir), door_dir))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_opening_near_existing_door(datum/world_edit_building_layout_candidate/candidate, turf/opening_turf, radius = 2, door_dir = null)
	if(!istype(candidate) || !istype(opening_turf))
		return FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || door_plan.public_opening)
			continue
		for(var/turf/existing_turf as anything in get_building_layout_opening_plan_turfs(door_plan))
			if(istype(existing_turf) && get_dist(opening_turf, existing_turf) <= radius)
				if(building_layout_openings_are_opposite_route_pair(candidate, opening_turf, door_dir, existing_turf, door_plan.dir))
					continue
				return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_openings_are_opposite_route_pair(datum/world_edit_building_layout_candidate/candidate, turf/a, a_dir, turf/b, b_dir)
	if(!istype(candidate) || !istype(a) || !istype(b) || !(a_dir in GLOB.cardinals) || !(b_dir in GLOB.cardinals))
		return FALSE
	if(get_dist(a, b) != 2 || turn(a_dir, 180) != b_dir)
		return FALSE
	var/mid_x = round((a.x + b.x) / 2)
	var/mid_y = round((a.y + b.y) / 2)
	var/turf/mid_turf = locate(mid_x, mid_y, a.z)
	return candidate.route_lookup[mid_turf] ? TRUE : FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_opening_side_clear(datum/world_edit_building_layout_candidate/candidate, turf/check_turf)
	if(!istype(candidate) || !istype(check_turf))
		return FALSE
	if(candidate.route_lookup[check_turf])
		return TRUE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(istype(room_plan) && room_plan.has_turf(check_turf))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/opening_exposes_private_room(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_opening_candidate/opening_candidate)
	if(!istype(candidate) || !istype(opening_candidate?.opening_turf))
		return FALSE
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(istype(door_plan?.opening_turf) && door_plan.kind == "main_exit" && get_dist(opening_candidate.opening_turf, door_plan.opening_turf) <= 4)
			return TRUE
	return FALSE
