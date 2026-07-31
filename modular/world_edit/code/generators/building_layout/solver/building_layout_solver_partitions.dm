/datum/world_edit_generator/building_layout/proc/build_building_layout_ownership_partition_graph(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return FALSE
	candidate.ownership_by_turf = list()
	candidate.partition_segments = list()
	candidate.partition_edges = list()
	candidate.reserved_partition_wall_lookup = list()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		for(var/turf/room_turf as anything in room_plan.turfs)
			candidate.ownership_by_turf[room_turf] = room_plan.id
	for(var/turf/route_turf as anything in candidate.route_turfs)
		candidate.ownership_by_turf[route_turf] = candidate.route_owner_by_turf[route_turf] || "route"
	for(var/turf/owner_aisle_turf as anything in candidate.owner_aisle_turfs)
		candidate.ownership_by_turf[owner_aisle_turf] = candidate.owner_aisle_owner_by_turf[owner_aisle_turf] || "route"
	var/list/vertical_records = list()
	var/list/horizontal_records = list()
	for(var/turf/interior_turf as anything in state.geometry.interior)
		if(!istype(interior_turf) || candidate.ownership_by_turf[interior_turf])
			continue
		var/list/vertical_record = build_building_layout_partition_cell_record(context, candidate, interior_turf, EAST, "vertical")
		if(islist(vertical_record))
			vertical_records[interior_turf] = vertical_record
		var/list/horizontal_record = build_building_layout_partition_cell_record(context, candidate, interior_turf, NORTH, "horizontal")
		if(islist(horizontal_record))
			horizontal_records[interior_turf] = horizontal_record
	resolve_building_layout_partition_record_intersections(vertical_records, horizontal_records)
	materialize_building_layout_straight_partition_segments(context, candidate, vertical_records, "vertical")
	materialize_building_layout_straight_partition_segments(context, candidate, horizontal_records, "horizontal")
	var/list/segment_report = list()
	for(var/datum/world_edit_building_partition_segment/segment as anything in candidate.partition_segments)
		if(!istype(segment))
			continue
		var/turf/first_turf = length(segment.turfs) ? segment.turfs[1] : null
		var/turf/last_turf = length(segment.turfs) ? segment.turfs[length(segment.turfs)] : null
		segment_report += "[segment.id]:[segment.owner_a]>[segment.owner_b]:[segment.kind]:[segment.orientation]:[length(segment.turfs)]:[first_turf?.x],[first_turf?.y]-[last_turf?.x],[last_turf?.y]"
	state.add_stage_report("layout_partition_segments", length(candidate.partition_segments) ? "ok" : "failed", length(candidate.partition_segments) ? null : "no canonical partition segments", list(
		"candidate_id" = candidate.id,
		"segment_count" = length(candidate.partition_segments),
		"wall_turf_count" = length(candidate.reserved_partition_wall_lookup),
		"segments" = segment_report,
	))
	return length(candidate.partition_segments) > 0

/datum/world_edit_generator/building_layout/proc/build_building_layout_partition_cell_record(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/wall_turf, side_dir, orientation)
	if(!istype(context?.state) || !istype(candidate) || !istype(wall_turf))
		return null
	var/list/terminal_record = build_building_layout_terminal_partition_cell_record(candidate, wall_turf, side_dir, orientation)
	if(islist(terminal_record))
		return terminal_record
	var/owner_a = "[candidate.ownership_by_turf[get_step(wall_turf, side_dir)] || ""]"
	var/owner_b = "[candidate.ownership_by_turf[get_step(wall_turf, turn(side_dir, 180))] || ""]"
	if(owner_a == owner_b)
		return null
	if(!length(owner_a) || !length(owner_b))
		var/owned_side = length(owner_a) ? owner_a : owner_b
		var/datum/world_edit_building_layout_room_contract/owned_contract = context.program_contract?.get_room_contract(owned_side)
		if(!istype(owned_contract) || !owned_contract.counts_toward_target || !(owned_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE)))
			return null
		if(!length(owner_a))
			owner_a = "structural_residual"
		else
			owner_b = "structural_residual"
	var/list/sorted_owners = sortList(list(owner_a, owner_b))
	var/datum/world_edit_building_layout_topology_edge/edge = get_building_layout_partition_edge_contract(candidate, sorted_owners[1], sorted_owners[2])
	var/nested_siblings = building_layout_partition_owners_are_nested_siblings(candidate, sorted_owners[1], sorted_owners[2])
	if(edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
		return null
	var/edge_kind = WORLD_EDIT_BUILDING_EDGE_NESTED
	var/opening_policy = WORLD_EDIT_BUILDING_OPENING_NONE
	if(istype(edge))
		edge_kind = edge.edge_kind
		opening_policy = edge.opening_policy
	else if(!nested_siblings)
		var/datum/world_edit_building_layout_room_contract/owner_a_contract = context.program_contract?.get_room_contract(sorted_owners[1])
		var/datum/world_edit_building_layout_room_contract/owner_b_contract = context.program_contract?.get_room_contract(sorted_owners[2])
		var/owner_a_closed = istype(owner_a_contract) && owner_a_contract.counts_toward_target && (owner_a_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE))
		var/owner_b_closed = istype(owner_b_contract) && owner_b_contract.counts_toward_target && (owner_b_contract.partition_policy in list(WORLD_EDIT_BUILDING_PARTITION_CLOSED, WORLD_EDIT_BUILDING_PARTITION_SECURE))
		if(!owner_a_closed && !owner_b_closed)
			return null
		edge_kind = (owner_a_contract?.partition_policy == WORLD_EDIT_BUILDING_PARTITION_SECURE || owner_b_contract?.partition_policy == WORLD_EDIT_BUILDING_PARTITION_SECURE) ? WORLD_EDIT_BUILDING_EDGE_SECURE : WORLD_EDIT_BUILDING_EDGE_SHARED
	return list(
		"owner_a" = sorted_owners[1],
		"owner_b" = sorted_owners[2],
		"orientation" = orientation,
		"kind" = edge_kind,
		"opening_policy" = opening_policy,
		"key" = "[sorted_owners[1]]|[sorted_owners[2]]|[edge_kind]|[opening_policy]",
	)

/datum/world_edit_generator/building_layout/proc/get_building_layout_useful_interior_area(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context?.state) || !istype(candidate))
		return 0
	var/useful_area = 0
	var/list/opening_lookup = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		for(var/turf/opening_turf as anything in get_building_layout_opening_plan_turfs(opening_plan))
			if(istype(opening_turf))
				opening_lookup[opening_turf] = TRUE
	for(var/turf/interior_turf as anything in context.state.geometry.interior)
		if(istype(interior_turf) && (!candidate.reserved_partition_wall_lookup[interior_turf] || opening_lookup[interior_turf]))
			useful_area++
	return useful_area

/datum/world_edit_generator/building_layout/proc/building_layout_partition_owners_are_nested_siblings(datum/world_edit_building_layout_candidate/candidate, owner_a, owner_b)
	return istype(candidate) && building_layout_nodes_are_typed_nested_siblings(candidate.topology_graph, owner_a, owner_b)

/datum/world_edit_generator/building_layout/proc/build_building_layout_terminal_partition_cell_record(datum/world_edit_building_layout_candidate/candidate, turf/wall_turf, side_dir, orientation)
	if(!istype(candidate) || !istype(wall_turf) || !(side_dir in GLOB.cardinals))
		return null
	for(var/connection_id as anything in candidate.route_terminal_hints_by_connection)
		var/list/terminal_hint = candidate.route_terminal_hints_by_connection[connection_id]
		var/list/wall_run = terminal_hint?["wall_run"]
		if(!islist(wall_run) || !(wall_turf in wall_run))
			continue
		var/room_side_dir = round(text2num("[terminal_hint["room_side_dir"]]") || 0)
		if(room_side_dir && !(room_side_dir in list(side_dir, turn(side_dir, 180))))
			continue
		var/room_id = "[terminal_hint["room_id"]]"
		var/circulation_id = "[terminal_hint["circulation_id"]]"
		var/datum/world_edit_building_layout_room_plan/room_plan = candidate.get_room_plan(room_id)
		if(!istype(room_plan) || !length(circulation_id))
			continue
		var/room_on_a = room_plan.turf_lookup[get_step(wall_turf, side_dir)]
		var/room_on_b = room_plan.turf_lookup[get_step(wall_turf, turn(side_dir, 180))]
		if(!room_on_a && !room_on_b)
			continue
		var/list/sorted_owners = sortList(list(room_id, circulation_id))
		var/datum/world_edit_building_layout_topology_edge/edge = get_building_layout_partition_edge_contract(candidate, sorted_owners[1], sorted_owners[2])
		var/edge_kind = istype(edge) ? edge.edge_kind : WORLD_EDIT_BUILDING_EDGE_ROUTE
		var/opening_policy = istype(edge) ? edge.opening_policy : WORLD_EDIT_BUILDING_OPENING_DOOR
		return list(
			"owner_a" = sorted_owners[1],
			"owner_b" = sorted_owners[2],
			"orientation" = orientation,
			"kind" = edge_kind,
			"opening_policy" = opening_policy,
			"key" = "[sorted_owners[1]]|[sorted_owners[2]]|[edge_kind]|[opening_policy]",
		)
	return null

/datum/world_edit_generator/building_layout/proc/resolve_building_layout_partition_record_intersections(list/vertical_records, list/horizontal_records)
	if(!islist(vertical_records) || !islist(horizontal_records))
		return
	for(var/turf/wall_turf as anything in vertical_records)
		if(!islist(horizontal_records[wall_turf]))
			continue
		var/vertical_run_length = get_building_layout_partition_record_run_length(vertical_records, wall_turf, NORTH, SOUTH)
		var/horizontal_run_length = get_building_layout_partition_record_run_length(horizontal_records, wall_turf, EAST, WEST)
		if(horizontal_run_length > vertical_run_length)
			vertical_records -= wall_turf
		else
			horizontal_records -= wall_turf

/datum/world_edit_generator/building_layout/proc/get_building_layout_partition_record_run_length(list/records_by_turf, turf/origin, forward_dir, backward_dir)
	var/list/origin_record = records_by_turf?[origin]
	if(!islist(origin_record))
		return 0
	var/record_key = "[origin_record["key"]]"
	var/run_length = 1
	for(var/check_dir in list(forward_dir, backward_dir))
		var/turf/check_turf = get_step(origin, check_dir)
		while(istype(check_turf))
			var/list/check_record = records_by_turf[check_turf]
			if(!islist(check_record) || check_record["key"] != record_key)
				break
			run_length++
			check_turf = get_step(check_turf, check_dir)
	return run_length

/datum/world_edit_generator/building_layout/proc/materialize_building_layout_straight_partition_segments(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, list/records_by_turf, orientation)
	if(!istype(context?.state) || !istype(candidate) || !islist(records_by_turf))
		return
	var/min_x = round(text2num("[context.state.geometry.bounds["min_x"]]") || 0)
	var/max_x = round(text2num("[context.state.geometry.bounds["max_x"]]") || 0)
	var/min_y = round(text2num("[context.state.geometry.bounds["min_y"]]") || 0)
	var/max_y = round(text2num("[context.state.geometry.bounds["max_y"]]") || 0)
	var/z_level = round(text2num("[context.state.geometry.bounds["z"]]") || 1)
	var/segment_index = length(candidate.partition_segments)
	if(orientation == "vertical")
		for(var/x in min_x to max_x)
			var/list/current_run = list()
			var/list/current_record = null
			var/current_key = ""
			for(var/y in min_y to max_y)
				var/turf/wall_turf = locate(x, y, z_level)
				var/list/record = records_by_turf[wall_turf]
				if(!islist(record) || record["key"] != current_key)
					if(materialize_building_layout_partition_record_run(candidate, current_run, current_record, orientation, segment_index + 1))
						segment_index++
					current_run = list()
					current_record = null
					current_key = ""
				if(!islist(record))
					continue
				if(!length(current_run))
					current_key = record["key"]
					current_record = record
				current_run += wall_turf
			if(materialize_building_layout_partition_record_run(candidate, current_run, current_record, orientation, segment_index + 1))
				segment_index++
	else
		for(var/y in min_y to max_y)
			var/list/current_run = list()
			var/list/current_record = null
			var/current_key = ""
			for(var/x in min_x to max_x)
				var/turf/wall_turf = locate(x, y, z_level)
				var/list/record = records_by_turf[wall_turf]
				if(!islist(record) || record["key"] != current_key)
					if(materialize_building_layout_partition_record_run(candidate, current_run, current_record, orientation, segment_index + 1))
						segment_index++
					current_run = list()
					current_record = null
					current_key = ""
				if(!islist(record))
					continue
				if(!length(current_run))
					current_key = record["key"]
					current_record = record
				current_run += wall_turf
			if(materialize_building_layout_partition_record_run(candidate, current_run, current_record, orientation, segment_index + 1))
				segment_index++

/datum/world_edit_generator/building_layout/proc/materialize_building_layout_partition_record_run(datum/world_edit_building_layout_candidate/candidate, list/run_turfs, list/record, orientation, segment_index)
	if(!istype(candidate) || !islist(run_turfs) || length(run_turfs) < 2 || !islist(record))
		return FALSE
	var/datum/world_edit_building_partition_segment/segment = new("partition_[segment_index]", record["owner_a"], record["owner_b"], orientation, record["kind"], record["opening_policy"])
	candidate.partition_segments += segment
	for(var/turf/wall_turf as anything in run_turfs)
		add_building_layout_partition_segment_turf(candidate, segment, wall_turf)
	return TRUE

/datum/world_edit_generator/building_layout/proc/add_building_layout_partition_segment_turf(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_partition_segment/segment, turf/wall_turf)
	if(!istype(candidate) || !istype(segment) || !istype(wall_turf))
		return
	segment.add_turf(wall_turf)
	candidate.reserved_partition_wall_lookup[wall_turf] = TRUE
	candidate.partition_edges += list(list(
		"segment_id" = segment.id,
		"wall_turf" = wall_turf,
		"wall_x" = wall_turf.x,
		"wall_y" = wall_turf.y,
		"wall_z" = wall_turf.z,
		"owner_a" = segment.owner_a,
		"owner_b" = segment.owner_b,
		"orientation" = segment.orientation,
		"kind" = segment.kind,
		"opening_policy" = segment.opening_policy,
	))

/datum/world_edit_generator/building_layout/proc/get_building_layout_partition_edge_contract(datum/world_edit_building_layout_candidate/candidate, owner_a, owner_b)
	if(!istype(candidate?.topology_graph))
		return null
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph.get_edges_for(owner_a))
		if(!istype(edge))
			continue
		var/other_id = edge.from_id == owner_a ? edge.to_id : edge.from_id
		if(other_id == owner_b)
			return edge
	return null

/datum/world_edit_generator/building_layout/proc/get_building_layout_partition_edge_kind(datum/world_edit_building_layout_candidate/candidate, owner_a, owner_b)
	var/datum/world_edit_building_layout_topology_edge/edge = get_building_layout_partition_edge_contract(candidate, owner_a, owner_b)
	return istype(edge) ? edge.edge_kind : WORLD_EDIT_BUILDING_EDGE_SHARED
