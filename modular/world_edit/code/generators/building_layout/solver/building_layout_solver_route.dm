/datum/world_edit_generator/building_layout/proc/solve_building_layout_terminal_route_network(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !length(candidate.room_plans))
		return FALSE
	var/turf/entry_seed = find_building_layout_route_entry_seed(context, candidate)
	if(!istype(entry_seed))
		candidate.errors += "route.entry_terminal_missing"
		return FALSE
	candidate.add_route_turf(entry_seed)
	candidate.route_owner_by_turf[entry_seed] = "route"
	var/list/terminal_connections = build_building_layout_route_terminal_set(candidate)
	var/list/remaining_terminals = terminal_connections.Copy()
	while(length(remaining_terminals))
		var/best_index = 0
		var/establishing_main_segment = candidate.family_constraints?["route_policy"] == WORLD_EDIT_BUILDING_ROUTE_POLICY_AXIAL && !length(candidate.access_reservations_by_room)
		var/best_cost = establishing_main_segment ? -1 : 999999999
		var/list/terminal = null
		var/datum/world_edit_building_layout_room_plan/room_plan = null
		var/datum/world_edit_building_layout_room_connection/selected_connection = null
		for(var/terminal_index in 1 to length(remaining_terminals))
			var/datum/world_edit_building_layout_room_connection/indexed_connection = remaining_terminals[terminal_index]
			var/room_id = get_building_layout_connection_functional_node_id(context, indexed_connection)
			var/datum/world_edit_building_layout_room_plan/indexed_room_plan = candidate.get_room_plan(room_id)
			var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_id)
			if(!istype(indexed_room_plan) || !istype(room_contract))
				continue
			var/list/indexed_terminal = find_building_layout_terminal_route(context, candidate, indexed_room_plan, room_contract, indexed_connection)
			if(!islist(indexed_terminal))
				continue
			var/indexed_cost = round(text2num("[indexed_terminal["cost"]]") || 0)
			if(!islist(terminal) || (establishing_main_segment ? indexed_cost > best_cost : indexed_cost < best_cost))
				best_index = terminal_index
				best_cost = indexed_cost
				terminal = indexed_terminal
				room_plan = indexed_room_plan
				selected_connection = indexed_connection
		if(!best_index || !islist(terminal) || !istype(room_plan))
			for(var/datum/world_edit_building_layout_room_connection/unreachable_connection as anything in remaining_terminals)
				var/room_id = get_building_layout_connection_functional_node_id(context, unreachable_connection)
				var/datum/world_edit_building_layout_room_plan/unreachable_room = candidate.get_room_plan(room_id)
				candidate.errors += "route.terminal_unreachable:[unreachable_connection?.id || room_id]"
				context.state.add_stage_report("layout_route_terminal", "failed", "bounded A* could not connect terminal", list(
					"candidate_id" = candidate.id,
					"connection_id" = unreachable_connection?.id,
					"room_id" = room_id,
					"entry_x" = entry_seed.x,
					"entry_y" = entry_seed.y,
					"room_x1" = unreachable_room?.x1,
					"room_y1" = unreachable_room?.y1,
					"room_x2" = unreachable_room?.x2,
					"room_y2" = unreachable_room?.y2,
					"route_count" = length(candidate.route_turfs),
					"frontage_options" = count_building_layout_terminal_frontage_options(context, candidate, unreachable_room, context.program_contract?.get_room_contract(room_id)),
				))
			break
		var/room_id = get_building_layout_connection_functional_node_id(context, selected_connection)
		var/circulation_id = get_building_layout_connection_circulation_node_id(context, selected_connection)
		remaining_terminals.Cut(best_index, best_index + 1)
		var/list/path = terminal["path"]
		var/list/route_run = terminal["route_run"]
		var/list/wall_run = terminal["wall_run"]
		for(var/turf/path_turf as anything in path)
			candidate.add_route_turf(path_turf)
			candidate.route_owner_by_turf[path_turf] = "route"
		for(var/turf/route_turf as anything in route_run)
			candidate.add_route_turf(route_turf)
			candidate.route_owner_by_turf[route_turf] = "route"
		if(!candidate.reserve_route_access(room_id, wall_run, route_run, path, selected_connection.id, circulation_id))
			candidate.errors += "route.terminal_reservation_failed:[selected_connection.id]"
		context.state.add_stage_report("layout_route_terminal", "ok", null, list("candidate_id" = candidate.id, "connection_id" = selected_connection.id, "circulation_id" = circulation_id, "room_id" = room_id, "wall_run" = length(wall_run), "route_run" = length(route_run), "path" = length(path), "cost" = best_cost))
	normalize_building_layout_route_network(candidate, entry_seed)
	normalize_building_layout_route_width_bounded(context, candidate)
	if(!assign_building_layout_route_segment_ownership(context, candidate, entry_seed))
		candidate.errors += "route.segment_ownership_failed"
	if(!length(candidate.errors) && !assign_building_layout_room_owned_route_overlays(context, candidate))
		candidate.errors += "route.room_owned_overlay_failed"
	return !length(candidate.errors) && building_layout_route_turfs_are_connected(candidate)

/datum/world_edit_generator/building_layout/proc/assign_building_layout_route_segment_ownership(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/entry_seed)
	if(!istype(context) || !istype(candidate) || !istype(entry_seed) || !length(candidate.route_turfs))
		return FALSE
	candidate.route_zone_by_turf.Cut()
	// Ownership is recomputed from typed entry/terminal seeds below.  Path finding
	// initially marks cells with the technical owner "route"; retaining those
	// marks makes the multi-source BFS skip semantic reassignment after width or
	// capacity normalization.
	candidate.route_owner_by_turf.Cut()
	var/datum/world_edit_building_layout_room_contract/entry_contract = null
	var/datum/world_edit_building_layout_room_contract/default_contract = null
	var/list/required_contracts = list()
	var/list/enclosed_required_contracts = list()
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in context.program_contract?.circulation_contracts)
		if(!istype(circulation_contract) || !circulation_contract.required)
			continue
		required_contracts += circulation_contract
		if(building_layout_circulation_uses_enclosed_route(circulation_contract))
			enclosed_required_contracts += circulation_contract
		if(circulation_contract.role == "entry" && !istype(entry_contract))
			entry_contract = circulation_contract
		else if(!istype(default_contract))
			default_contract = circulation_contract
	if(!istype(default_contract))
		default_contract = entry_contract
	if(!istype(default_contract))
		return FALSE
	var/required_route_area = 0
	for(var/datum/world_edit_building_layout_room_contract/required_contract as anything in enclosed_required_contracts)
		required_route_area += max(required_contract.min_area, 1)
	if(!ensure_building_layout_route_contract_capacity(context, candidate, required_route_area))
		candidate.errors += "route.total_capacity_underfill:[length(candidate.route_turfs)]/[required_route_area]"
		return FALSE
	var/list/source_turfs = list()
	var/list/source_zones = list()
	var/list/source_owners = list()
	var/list/source_lookup = list()
	var/list/seeded_owners = list()
	if(istype(entry_contract))
		source_turfs += entry_seed
		source_zones += entry_contract.zone_id
		source_owners += entry_contract.id
		source_lookup[entry_seed] = TRUE
		seeded_owners[entry_contract.id] = TRUE
	// Every authored route terminal is an ownership seed.  Collapsing terminals
	// to one source per circulation id disconnects the semantic segment from
	// all but one of its room frontages (most visibly entry_buffer at the outer
	// entry versus the same entry_buffer at a public room).
	for(var/reservation_id as anything in candidate.access_reservations_by_room)
		var/list/reservation = candidate.access_reservations_by_room[reservation_id]
		var/room_id = "[reservation?["room_id"]]"
		var/circulation_id = "[reservation?["circulation_id"]]"
		var/datum/world_edit_building_layout_room_contract/route_contract = context.program_contract?.get_room_contract(circulation_id)
		if(!istype(route_contract))
			route_contract = get_building_layout_terminal_circulation_contract(context.program_contract, room_id)
		if(!istype(route_contract))
			route_contract = default_contract
		var/list/route_run = reservation?["route_run"]
		if(!islist(route_run))
			continue
		for(var/turf/source_turf as anything in route_run)
			if(!istype(source_turf) || !candidate.route_lookup[source_turf] || source_lookup[source_turf])
				continue
			source_turfs += source_turf
			source_zones += route_contract.zone_id
			source_owners += route_contract.id
			source_lookup[source_turf] = TRUE
			seeded_owners[route_contract.id] = TRUE
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in required_contracts)
		if(seeded_owners[circulation_contract.id])
			continue
		var/turf/farthest_turf = null
		var/farthest_distance = -1
		for(var/turf/route_turf as anything in candidate.route_turfs)
			if(source_lookup[route_turf])
				continue
			var/distance = get_dist(entry_seed, route_turf)
			if(distance > farthest_distance)
				farthest_turf = route_turf
				farthest_distance = distance
		if(istype(farthest_turf))
			source_turfs += farthest_turf
			source_zones += circulation_contract.zone_id
			source_owners += circulation_contract.id
			source_lookup[farthest_turf] = TRUE
			seeded_owners[circulation_contract.id] = TRUE
	// Reserve each authored circulation segment's minimum before the ordinary
	// multi-source BFS fills the remainder.  A pure Voronoi fill can leave the
	// entry owner with a single cell when the next route seed is nearby even
	// though the connected route has ample capacity.
	var/list/claimed_owner_by_turf = list()
	var/list/claimed_zone_by_turf = list()
	var/list/owned_count_by_id = list()
	var/list/protected_owner_seed_lookup = list()
	var/list/protected_owner_ids = list()
	for(var/source_index in 1 to length(source_turfs))
		var/turf/seeded_turf = source_turfs[source_index]
		if(!istype(seeded_turf) || claimed_owner_by_turf[seeded_turf])
			continue
		var/source_zone = "[source_zones[source_index]]"
		var/source_owner = "[source_owners[source_index]]"
		claimed_owner_by_turf[seeded_turf] = source_owner
		claimed_zone_by_turf[seeded_turf] = source_zone
		owned_count_by_id[source_owner] = (owned_count_by_id[source_owner] || 0) + 1
		if(!protected_owner_ids[source_owner])
			protected_owner_ids[source_owner] = TRUE
			protected_owner_seed_lookup[seeded_turf] = TRUE
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in enclosed_required_contracts)
		var/required_area = max(circulation_contract.min_area, 1)
		var/list/quota_open = list()
		for(var/turf/claimed_turf as anything in claimed_owner_by_turf)
			if(claimed_owner_by_turf[claimed_turf] == circulation_contract.id)
				quota_open += claimed_turf
		var/quota_index = 1
		var/expanded_count = 0
		while(round(text2num("[owned_count_by_id[circulation_contract.id]]") || 0) < required_area)
			if(quota_index <= length(quota_open))
				var/turf/quota_current_turf = quota_open[quota_index++]
				for(var/quota_dir in GLOB.cardinals)
					if(round(text2num("[owned_count_by_id[circulation_contract.id]]") || 0) >= required_area)
						break
					var/turf/quota_near_turf = get_step(quota_current_turf, quota_dir)
					if(!candidate.route_lookup[quota_near_turf] || claimed_owner_by_turf[quota_near_turf])
						continue
					claimed_owner_by_turf[quota_near_turf] = circulation_contract.id
					claimed_zone_by_turf[quota_near_turf] = circulation_contract.zone_id
					owned_count_by_id[circulation_contract.id] = (owned_count_by_id[circulation_contract.id] || 0) + 1
					quota_open += quota_near_turf
				continue
			var/turf/expanded_turf = find_building_layout_route_owner_capacity_turf(context, candidate, circulation_contract.id, claimed_owner_by_turf)
			if(!istype(expanded_turf))
				break
			candidate.add_route_turf(expanded_turf)
			claimed_owner_by_turf[expanded_turf] = circulation_contract.id
			claimed_zone_by_turf[expanded_turf] = circulation_contract.zone_id
			owned_count_by_id[circulation_contract.id] = (owned_count_by_id[circulation_contract.id] || 0) + 1
			quota_open += expanded_turf
			expanded_count++
		context.state.add_stage_report("layout_route_segment_capacity", round(text2num("[owned_count_by_id[circulation_contract.id]]") || 0) >= required_area ? "ok" : "failed", null, list(
			"candidate_id" = candidate.id,
			"circulation_id" = circulation_contract.id,
			"required_area" = required_area,
			"owned_area" = round(text2num("[owned_count_by_id[circulation_contract.id]]") || 0),
			"expanded_area" = expanded_count,
		))
	var/list/open_turfs = list()
	var/list/open_zones = list()
	var/list/open_owners = list()
	var/list/queued_lookup = list()
	for(var/turf/claimed_turf as anything in claimed_owner_by_turf)
		open_turfs += claimed_turf
		open_zones += "[claimed_zone_by_turf[claimed_turf]]"
		open_owners += "[claimed_owner_by_turf[claimed_turf]]"
		queued_lookup[claimed_turf] = TRUE
		candidate.route_zone_by_turf[claimed_turf] = claimed_zone_by_turf[claimed_turf]
		candidate.route_owner_by_turf[claimed_turf] = claimed_owner_by_turf[claimed_turf]
	var/open_index = 1
	while(open_index <= length(open_turfs))
		var/turf/current_turf = open_turfs[open_index]
		var/current_zone = "[open_zones[open_index]]"
		var/current_owner = "[open_owners[open_index]]"
		open_index++
		if(!istype(current_turf) || !candidate.route_lookup[current_turf])
			continue
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_turf, check_dir)
			if(!candidate.route_lookup[near_turf] || queued_lookup[near_turf])
				continue
			queued_lookup[near_turf] = TRUE
			candidate.route_zone_by_turf[near_turf] = current_zone
			candidate.route_owner_by_turf[near_turf] = current_owner
			open_turfs += near_turf
			open_zones += current_zone
			open_owners += current_owner
	var/list/ownership_distribution = list()
	var/list/unassigned_route_turfs = list()
	for(var/turf/route_turf as anything in candidate.route_turfs)
		var/route_owner = "[candidate.route_owner_by_turf[route_turf] || ""]"
		if(!length(route_owner))
			unassigned_route_turfs += "[route_turf.x],[route_turf.y],[route_turf.z]"
			continue
		ownership_distribution[route_owner] = (ownership_distribution[route_owner] || 0) + 1
	var/ownership_transfer_count = 0
	for(var/datum/world_edit_building_layout_room_contract/deficit_contract as anything in enclosed_required_contracts)
		var/deficit_min_area = max(deficit_contract.min_area, 1)
		while(round(text2num("[ownership_distribution[deficit_contract.id]]") || 0) < deficit_min_area)
			var/turf/best_transfer_turf = null
			var/best_transfer_score = -999999999
			for(var/turf/transfer_turf as anything in candidate.route_turfs)
				var/donor_id = "[candidate.route_owner_by_turf[transfer_turf] || ""]"
				if(!length(donor_id) || donor_id == deficit_contract.id || protected_owner_seed_lookup[transfer_turf])
					continue
				var/datum/world_edit_building_layout_room_contract/donor_contract = context.program_contract?.get_room_contract(donor_id)
				var/donor_min_area = istype(donor_contract) && donor_contract.required && building_layout_circulation_uses_enclosed_route(donor_contract) ? max(donor_contract.min_area, 1) : 0
				if(round(text2num("[ownership_distribution[donor_id]]") || 0) <= donor_min_area)
					continue
				var/recipient_neighbors = 0
				var/donor_neighbors = 0
				for(var/check_dir in GLOB.cardinals)
					var/near_owner = "[candidate.route_owner_by_turf[get_step(transfer_turf, check_dir)] || ""]"
					if(near_owner == deficit_contract.id)
						recipient_neighbors++
					else if(near_owner == donor_id)
						donor_neighbors++
				if(!recipient_neighbors || !building_layout_route_owner_connected_without(candidate, donor_id, transfer_turf))
					continue
				var/transfer_score = recipient_neighbors * 1000 - donor_neighbors * 100 - transfer_turf.x * 2 - transfer_turf.y
				if(!istype(best_transfer_turf) || transfer_score > best_transfer_score)
					best_transfer_turf = transfer_turf
					best_transfer_score = transfer_score
			if(!istype(best_transfer_turf))
				break
			var/previous_owner = "[candidate.route_owner_by_turf[best_transfer_turf]]"
			candidate.route_owner_by_turf[best_transfer_turf] = deficit_contract.id
			candidate.route_zone_by_turf[best_transfer_turf] = deficit_contract.zone_id
			ownership_distribution[previous_owner] = max((ownership_distribution[previous_owner] || 0) - 1, 0)
			ownership_distribution[deficit_contract.id] = (ownership_distribution[deficit_contract.id] || 0) + 1
			ownership_transfer_count++
	context.state.add_stage_report("layout_route_segment_ownership", length(unassigned_route_turfs) ? "failed" : "ok", null, list(
		"candidate_id" = candidate.id,
		"route_area" = length(candidate.route_turfs),
		"owner_area" = ownership_distribution,
		"boundary_transfer_count" = ownership_transfer_count,
		"unassigned_route_turfs" = unassigned_route_turfs,
	))
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in enclosed_required_contracts)
		var/owned_count = 0
		for(var/turf/route_turf as anything in candidate.route_owner_by_turf)
			if(candidate.route_owner_by_turf[route_turf] == circulation_contract.id)
				owned_count++
		if(owned_count < max(circulation_contract.min_area, 1))
			candidate.errors += "route.circulation_underfill:[circulation_contract.id]:[owned_count]/[circulation_contract.min_area]"
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/building_layout_circulation_uses_enclosed_route(datum/world_edit_building_layout_room_contract/circulation_contract)
	return istype(circulation_contract) && circulation_contract.circulation_kind != WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE

/datum/world_edit_generator/building_layout/proc/assign_building_layout_room_owned_route_overlays(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context?.program_contract) || !istype(candidate))
		return FALSE
	candidate.route_overlays = list()
	candidate.route_overlays_by_id = list()
	candidate.route_overlay_lookup = list()
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in context.program_contract.circulation_contracts)
		if(!istype(circulation_contract) || circulation_contract.circulation_kind != WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE)
			continue
		var/datum/world_edit_building_layout_room_plan/owner_plan = candidate.get_room_plan(circulation_contract.circulation_owner_room_id)
		var/datum/world_edit_building_layout_route_overlay/overlay = build_building_layout_room_owned_route_overlay(context, candidate, circulation_contract, owner_plan)
		var/overlay_valid = istype(overlay) && length(overlay.turfs) >= circulation_contract.min_area && building_layout_route_overlay_meets_width(overlay)
		context.state.add_stage_report("layout_room_owned_route_overlay", overlay_valid ? "ok" : "failed", overlay_valid ? null : "required room-owned aisle could not be materialized", list(
			"candidate_id" = candidate.id,
			"circulation_id" = circulation_contract.id,
			"owner_room_id" = circulation_contract.circulation_owner_room_id,
			"required_area" = circulation_contract.min_area,
			"actual_area" = length(overlay?.turfs),
			"min_width" = circulation_contract.circulation_min_width,
		))
		if(!overlay_valid || !candidate.add_route_overlay(overlay))
			candidate.errors += "route.room_owned_overlay_underfill:[circulation_contract.id]:[length(overlay?.turfs)]/[circulation_contract.min_area]"
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/build_building_layout_room_owned_route_overlay(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_contract/circulation_contract, datum/world_edit_building_layout_room_plan/owner_plan)
	if(!istype(context) || !istype(candidate) || !istype(circulation_contract) || !istype(owner_plan))
		return null
	var/required_width = max(circulation_contract.circulation_min_width, 1)
	var/required_depth = max(ceil(circulation_contract.min_area / required_width), 1)
	var/list/best_turfs = null
	var/best_score = -999999999
	var/matching_reservation_count = 0
	var/inside_seed_count = 0
	var/strip_attempt_count = 0
	var/list/debug_owner_turfs = list()
	var/list/debug_wall_turfs = list()
	var/list/terminal_inside_turfs = list()
	for(var/turf/owner_turf as anything in owner_plan.turfs)
		if(istype(owner_turf) && length(debug_owner_turfs) < 64)
			debug_owner_turfs += "[owner_turf.x],[owner_turf.y],[owner_turf.z]"
	for(var/reservation_id as anything in candidate.access_reservations_by_room)
		var/list/reservation = candidate.access_reservations_by_room[reservation_id]
		var/reservation_circulation_id = "[reservation?["circulation_id"]]"
		var/reservation_room_id = "[reservation?["room_id"]]"
		if(reservation_circulation_id != circulation_contract.id || reservation_room_id != owner_plan.id)
			continue
		matching_reservation_count++
		var/list/wall_run = reservation?["wall_run"]
		for(var/turf/wall_turf as anything in wall_run)
			if(!istype(wall_turf))
				continue
			if(length(debug_wall_turfs) < 32)
				debug_wall_turfs += "[wall_turf.x],[wall_turf.y],[wall_turf.z]"
			for(var/inward_dir in GLOB.cardinals)
				var/turf/inside_turf = get_step(wall_turf, inward_dir)
				if(!owner_plan.turf_lookup[inside_turf])
					continue
				inside_seed_count++
				terminal_inside_turfs |= inside_turf
				var/lateral_dir = turn(inward_dir, 90)
				for(var/lateral_shift = 0, lateral_shift >= -(required_width - 1), lateral_shift--)
					strip_attempt_count++
					var/turf/lateral_start = building_layout_step_turf(inside_turf, lateral_dir, lateral_shift)
					var/list/strip_turfs = list()
					var/strip_valid = TRUE
					for(var/depth_index in 0 to required_depth - 1)
						var/turf/depth_turf = building_layout_step_turf(lateral_start, inward_dir, depth_index)
						for(var/width_index in 0 to required_width - 1)
							var/turf/overlay_turf = building_layout_step_turf(depth_turf, lateral_dir, width_index)
							if(!owner_plan.turf_lookup[overlay_turf] || candidate.route_overlay_lookup[overlay_turf])
								strip_valid = FALSE
								break
							strip_turfs += overlay_turf
						if(!strip_valid)
							break
					if(!strip_valid || length(strip_turfs) < circulation_contract.min_area)
						continue
					var/center_x = (owner_plan.x1 + owner_plan.x2) / 2
					var/center_y = (owner_plan.y1 + owner_plan.y2) / 2
					var/strip_score = -abs(inside_turf.x - center_x) * 10 - abs(inside_turf.y - center_y) * 10 - wall_turf.x * 2 - wall_turf.y
					if(!islist(best_turfs) || strip_score > best_score)
						best_turfs = strip_turfs
						best_score = strip_score
	// Nested rooms may leave a controlled one-cell approach immediately behind
	// the door while preserving a wider aisle deeper in the parent room. Search
	// the same connected parent floor for the nearest exact-width strip; the
	// approach is reserved separately and never credited toward aisle area.
	if(!islist(best_turfs) && length(terminal_inside_turfs))
		for(var/turf/origin_turf as anything in owner_plan.turfs)
			if(!istype(origin_turf))
				continue
			for(var/orientation_index in 1 to 2)
				var/strip_width_x = orientation_index == 1 ? required_width : required_depth
				var/strip_width_y = orientation_index == 1 ? required_depth : required_width
				var/list/strip_turfs = list()
				var/strip_valid = TRUE
				for(var/x_offset in 0 to strip_width_x - 1)
					for(var/y_offset in 0 to strip_width_y - 1)
						var/turf/overlay_turf = locate(origin_turf.x + x_offset, origin_turf.y + y_offset, origin_turf.z)
						if(!owner_plan.turf_lookup[overlay_turf] || candidate.route_overlay_lookup[overlay_turf])
							strip_valid = FALSE
							break
						strip_turfs += overlay_turf
					if(!strip_valid)
						break
				if(!strip_valid || length(strip_turfs) < circulation_contract.min_area)
					continue
				var/terminal_distance = 999999999
				for(var/turf/terminal_inside_turf as anything in terminal_inside_turfs)
					for(var/turf/strip_turf as anything in strip_turfs)
						terminal_distance = min(terminal_distance, get_dist(terminal_inside_turf, strip_turf))
				var/strip_score = -terminal_distance * 1000 - origin_turf.x * 2 - origin_turf.y - orientation_index
				if(!islist(best_turfs) || strip_score > best_score)
					best_turfs = strip_turfs
					best_score = strip_score
	if(!islist(best_turfs))
		context.state.add_stage_report("layout_room_owned_route_overlay_geometry", "failed", "no terminal-adjacent width strip", list(
			"candidate_id" = candidate.id,
			"circulation_id" = circulation_contract.id,
			"owner_room_id" = owner_plan.id,
			"owner_turf_count" = length(owner_plan.turfs),
			"owner_turfs" = debug_owner_turfs,
			"matching_reservation_count" = matching_reservation_count,
			"wall_turfs" = debug_wall_turfs,
			"inside_seed_count" = inside_seed_count,
			"strip_attempt_count" = strip_attempt_count,
			"required_width" = required_width,
			"required_depth" = required_depth,
		))
		return null
	var/datum/world_edit_building_layout_route_overlay/overlay = new(circulation_contract.id, owner_plan.id, circulation_contract.circulation_kind, required_width, circulation_contract.required)
	for(var/turf/overlay_turf as anything in best_turfs)
		overlay.add_turf(overlay_turf)
	var/list/approach_turfs = build_building_layout_room_overlay_approach(owner_plan, terminal_inside_turfs, overlay.turf_lookup)
	if(!islist(approach_turfs))
		return null
	for(var/turf/approach_turf as anything in approach_turfs)
		overlay.add_approach_turf(approach_turf)
	return overlay

/datum/world_edit_generator/building_layout/proc/build_building_layout_room_overlay_approach(datum/world_edit_building_layout_room_plan/owner_plan, list/start_turfs, list/target_lookup)
	if(!istype(owner_plan) || !islist(start_turfs) || !length(start_turfs) || !islist(target_lookup) || !length(target_lookup))
		return null
	var/list/open = list()
	var/list/seen = list()
	var/list/parent_by_turf = list()
	for(var/turf/start_turf as anything in start_turfs)
		if(!owner_plan.turf_lookup[start_turf] || seen[start_turf])
			continue
		open += start_turf
		seen[start_turf] = TRUE
		parent_by_turf[start_turf] = start_turf
	var/open_index = 1
	var/turf/reached_turf = null
	while(open_index <= length(open))
		var/turf/current_turf = open[open_index++]
		if(target_lookup[current_turf])
			reached_turf = current_turf
			break
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_turf, check_dir)
			if(!owner_plan.turf_lookup[near_turf] || seen[near_turf])
				continue
			seen[near_turf] = TRUE
			parent_by_turf[near_turf] = current_turf
			open += near_turf
	if(!istype(reached_turf))
		return null
	var/list/reversed_path = list()
	var/turf/path_turf = reached_turf
	while(istype(path_turf))
		if(!target_lookup[path_turf])
			reversed_path += path_turf
		var/turf/parent_turf = parent_by_turf[path_turf]
		if(!istype(parent_turf) || parent_turf == path_turf)
			break
		path_turf = parent_turf
	var/list/result = list()
	for(var/path_index = length(reversed_path), path_index >= 1, path_index--)
		result += reversed_path[path_index]
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_step_turf(turf/start_turf, travel_dir, step_count)
	if(!istype(start_turf) || !(travel_dir in GLOB.cardinals))
		return null
	var/steps = round(text2num("[step_count]") || 0)
	if(!steps)
		return start_turf
	var/effective_dir = steps < 0 ? turn(travel_dir, 180) : travel_dir
	var/turf/result = start_turf
	for(var/step_index in 1 to abs(steps))
		result = get_step(result, effective_dir)
		if(!istype(result))
			return null
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_route_overlay_meets_width(datum/world_edit_building_layout_route_overlay/overlay)
	if(!istype(overlay) || !length(overlay.turfs))
		return FALSE
	var/min_x = 999999
	var/min_y = 999999
	var/max_x = -999999
	var/max_y = -999999
	for(var/turf/overlay_turf as anything in overlay.turfs)
		if(!istype(overlay_turf))
			return FALSE
		min_x = min(min_x, overlay_turf.x)
		min_y = min(min_y, overlay_turf.y)
		max_x = max(max_x, overlay_turf.x)
		max_y = max(max_y, overlay_turf.y)
	return min(max_x - min_x + 1, max_y - min_y + 1) >= overlay.min_width

/datum/world_edit_generator/building_layout/proc/building_layout_route_overlay_touches_terminal(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_route_overlay/overlay)
	if(!istype(candidate) || !istype(overlay))
		return FALSE
	for(var/reservation_id as anything in candidate.access_reservations_by_room)
		var/list/reservation = candidate.access_reservations_by_room[reservation_id]
		var/reservation_circulation_id = "[reservation?["circulation_id"]]"
		var/reservation_room_id = "[reservation?["room_id"]]"
		if(reservation_circulation_id != overlay.id || reservation_room_id != overlay.owner_room_id)
			continue
		for(var/turf/wall_turf as anything in reservation?["wall_run"])
			for(var/check_dir in GLOB.cardinals)
				var/turf/near_turf = get_step(wall_turf, check_dir)
				if(overlay.turf_lookup[near_turf] || overlay.approach_lookup[near_turf])
					return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_route_overlay_is_connected(datum/world_edit_building_layout_route_overlay/overlay)
	if(!istype(overlay) || !length(overlay.turfs))
		return FALSE
	var/list/combined_lookup = overlay.turf_lookup.Copy()
	for(var/turf/approach_turf as anything in overlay.approach_turfs)
		combined_lookup[approach_turf] = TRUE
	var/turf/start_turf = combined_lookup[1]
	if(!istype(start_turf))
		return FALSE
	var/list/open = list(start_turf)
	var/list/seen = list()
	seen[start_turf] = TRUE
	var/open_index = 1
	while(open_index <= length(open))
		var/turf/current_turf = open[open_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_turf, check_dir)
			if(!combined_lookup[near_turf] || seen[near_turf])
				continue
			seen[near_turf] = TRUE
			open += near_turf
	return length(seen) == length(combined_lookup)

/datum/world_edit_generator/building_layout/proc/building_layout_route_owner_connected_without(datum/world_edit_building_layout_candidate/candidate, owner_id, turf/excluded_turf)
	if(!istype(candidate) || !length("[owner_id]"))
		return FALSE
	var/turf/start_turf = null
	var/expected_count = 0
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(route_turf == excluded_turf || candidate.route_owner_by_turf[route_turf] != owner_id)
			continue
		expected_count++
		if(!istype(start_turf))
			start_turf = route_turf
	if(!expected_count)
		return TRUE
	var/list/open = list(start_turf)
	var/list/seen = list()
	seen[start_turf] = TRUE
	var/open_index = 1
	while(open_index <= length(open))
		var/turf/current_turf = open[open_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_turf, check_dir)
			if(near_turf == excluded_turf || seen[near_turf] || candidate.route_owner_by_turf[near_turf] != owner_id)
				continue
			seen[near_turf] = TRUE
			open += near_turf
	return length(seen) == expected_count

/datum/world_edit_generator/building_layout/proc/ensure_building_layout_route_contract_capacity(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, required_area)
	if(!istype(context?.state) || !istype(candidate))
		return FALSE
	var/target_area = max(round(text2num("[required_area]") || 0), 0)
	var/source_area = length(candidate.route_turfs)
	var/expanded_area = 0
	while(length(candidate.route_turfs) < target_area)
		var/turf/best_turf = null
		var/best_score = -999999999
		for(var/turf/interior_turf as anything in context.state.geometry.interior)
			if(!istype(interior_turf) || candidate.route_lookup[interior_turf] || candidate.route_terminal_wall_hint_lookup[interior_turf] || candidate.access_reserved_lookup[interior_turf] || !building_layout_route_turf_is_free(context, candidate, interior_turf, null))
				continue
			var/route_neighbors = 0
			for(var/check_dir in GLOB.cardinals)
				if(candidate.route_lookup[get_step(interior_turf, check_dir)])
					route_neighbors++
			if(!route_neighbors)
				continue
			// Grow the existing connected network with the smallest bounded bulge.
			// Prefer cells that close a two-sided width gap; stable coordinates keep
			// same-seed geometry hashes deterministic.
			var/score = route_neighbors * 1000 - interior_turf.x * 2 - interior_turf.y
			if(!istype(best_turf) || score > best_score)
				best_turf = interior_turf
				best_score = score
		if(!istype(best_turf))
			break
		candidate.add_route_turf(best_turf)
		expanded_area++
	context.state.add_stage_report("layout_route_contract_capacity", length(candidate.route_turfs) >= target_area ? "ok" : "failed", null, list(
		"candidate_id" = candidate.id,
		"required_area" = target_area,
		"source_area" = source_area,
		"expanded_area" = expanded_area,
		"final_area" = length(candidate.route_turfs),
	))
	return length(candidate.route_turfs) >= target_area

/datum/world_edit_generator/building_layout/proc/find_building_layout_route_owner_capacity_turf(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, owner_id, list/claimed_owner_by_turf)
	if(!istype(context?.state) || !istype(candidate) || !length("[owner_id]") || !islist(claimed_owner_by_turf))
		return null
	var/turf/best_turf = null
	var/best_score = -999999999
	for(var/turf/interior_turf as anything in context.state.geometry.interior)
		if(!istype(interior_turf) || candidate.route_lookup[interior_turf] || candidate.route_terminal_wall_hint_lookup[interior_turf] || candidate.access_reserved_lookup[interior_turf] || !building_layout_route_turf_is_free(context, candidate, interior_turf, null))
			continue
		var/owner_neighbors = 0
		var/route_neighbors = 0
		var/foreign_owner_neighbors = 0
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(interior_turf, check_dir)
			if(candidate.route_lookup[near_turf])
				route_neighbors++
			if(claimed_owner_by_turf[near_turf] == owner_id)
				owner_neighbors++
			else if(length("[claimed_owner_by_turf[near_turf]]"))
				foreign_owner_neighbors++
		if(!owner_neighbors)
			continue
		var/score = owner_neighbors * 1000 + route_neighbors * 200 - foreign_owner_neighbors * 500 - interior_turf.x - interior_turf.y
		if(!istype(best_turf) || score > best_score)
			best_turf = interior_turf
			best_score = score
	return best_turf

/datum/world_edit_generator/building_layout/proc/assign_building_layout_owner_aisles(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !length(candidate.route_turfs))
		return FALSE
	candidate.owner_aisle_turfs = list()
	candidate.owner_aisle_lookup = list()
	candidate.owner_aisle_zone_by_turf = list()
	candidate.owner_aisle_owner_by_turf = list()
	var/list/blocked_lookup = list()
	var/list/interior_lookup = list()
	for(var/turf/interior_turf as anything in state.geometry.interior)
		if(istype(interior_turf))
			interior_lookup[interior_turf] = TRUE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		for(var/turf/room_turf as anything in room_plan?.turfs)
			blocked_lookup[room_turf] = TRUE
	for(var/turf/route_turf as anything in candidate.route_turfs)
		blocked_lookup[route_turf] = TRUE
	for(var/turf/access_turf as anything in candidate.access_reserved_lookup)
		blocked_lookup[access_turf] = TRUE
	for(var/turf/terminal_wall_turf as anything in candidate.route_terminal_wall_hint_lookup)
		blocked_lookup[terminal_wall_turf] = TRUE
	for(var/turf/partition_wall_turf as anything in candidate.reserved_partition_wall_lookup)
		blocked_lookup[partition_wall_turf] = TRUE
	var/list/open_turfs = list()
	var/list/open_owners = list()
	var/list/open_zones = list()
	var/list/queued_lookup = list()
	var/open_bay_owner_id = ""
	var/open_bay_zone_id = ""
	var/open_bay_owned_area = 0
	var/open_bay_min_area = 0
	var/open_bay_max_area = 0
	var/open_bay_expected_opening_area = 0
	var/list/open_bay_access_lookup = list()
	if(candidate.family_policy_id == "open_bay_perimeter")
		for(var/datum/world_edit_building_layout_room_plan/bay_plan as anything in candidate.room_plans)
			if(!istype(bay_plan) || bay_plan.spatial_kind != WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
				continue
			if(length(open_bay_owner_id))
				open_bay_owner_id = ""
				break
			open_bay_owner_id = bay_plan.id
			open_bay_zone_id = bay_plan.zone_id
			open_bay_owned_area = length(bay_plan.turfs)
			var/useful_interior_area = get_building_layout_useful_interior_area(context, candidate)
			for(var/datum/world_edit_building_layout_room_connection/bay_connection as anything in candidate.room_connections)
				if(!istype(bay_connection) || !bay_connection.required || bay_connection.opening_policy == WORLD_EDIT_BUILDING_OPENING_NONE || !(bay_plan.id in list(bay_connection.from_node_id, bay_connection.to_node_id)))
					continue
				open_bay_expected_opening_area += max(bay_connection.min_opening_width, 1)
			// Ownership changes alter which residual cells become structural walls on
			// the second canonical partition pass.  Use the raw interior as a safe
			// upper bound for the minimum so the final useful-area ratio cannot fall
			// below the authored 35% hard constraint after that pass.
			var/allocation_useful_area_upper_bound = length(state.geometry.interior)
			open_bay_min_area = max(ceil((allocation_useful_area_upper_bound + open_bay_expected_opening_area) * 0.35) - open_bay_expected_opening_area, length(bay_plan.turfs))
			open_bay_max_area = max(floor((useful_interior_area + open_bay_expected_opening_area) * 0.60) - open_bay_expected_opening_area, open_bay_min_area)
			for(var/turf/bay_turf as anything in bay_plan.turfs)
				for(var/check_dir in GLOB.cardinals)
					var/turf/near_turf = get_step(bay_turf, check_dir)
					if(!istype(near_turf) || queued_lookup[near_turf] || blocked_lookup[near_turf] || !interior_lookup[near_turf] || open_bay_owned_area >= open_bay_max_area)
						continue
					queued_lookup[near_turf] = TRUE
					candidate.add_owner_aisle_turf(near_turf, open_bay_owner_id, open_bay_zone_id)
					open_bay_owned_area++
					open_turfs += near_turf
					open_owners += open_bay_owner_id
					open_zones += open_bay_zone_id
			// The canonical route terminal can occupy every directly-adjacent cell
			// outside the authored bay footprint.  Seed the owner aisle from that
			// exact typed terminal as well, without relabelling circulation cells.
			// This keeps the bay semantic owner connected through its OPEN_BAY
			// access while preserving circulation IDs on the route layer.
			var/list/bay_access = candidate.get_route_access_reservation(bay_plan.id)
			var/list/bay_route_run = bay_access?["route_run"]
			var/list/bay_connector_run = bay_access?["connector_run"]
			var/list/bay_access_run = islist(bay_route_run) ? bay_route_run.Copy() : list()
			if(islist(bay_connector_run))
				bay_access_run |= bay_connector_run
			if(length(bay_access_run))
				for(var/turf/bay_route_turf as anything in bay_access_run)
					open_bay_access_lookup[bay_route_turf] = TRUE
					for(var/check_dir in GLOB.cardinals)
						var/turf/near_turf = get_step(bay_route_turf, check_dir)
						if(!istype(near_turf) || queued_lookup[near_turf] || blocked_lookup[near_turf] || !interior_lookup[near_turf] || open_bay_owned_area >= open_bay_max_area)
							continue
						queued_lookup[near_turf] = TRUE
						candidate.add_owner_aisle_turf(near_turf, open_bay_owner_id, open_bay_zone_id)
						open_bay_owned_area++
						open_turfs += near_turf
						open_owners += open_bay_owner_id
						open_zones += open_bay_zone_id
	// OPEN_BAY owns its bounded surplus before circulation claims the remaining
	// residual.  Interleaving both source sets lets the much larger route seed
	// set win after one bay layer and makes the hard family ratio order-dependent.
	var/open_bay_index = 1
	while(length(open_bay_owner_id) && open_bay_index <= length(open_turfs) && open_bay_owned_area < open_bay_max_area)
		var/turf/current_bay_turf = open_turfs[open_bay_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_bay_turf, check_dir)
			if(!istype(near_turf) || queued_lookup[near_turf] || blocked_lookup[near_turf] || !interior_lookup[near_turf])
				continue
			queued_lookup[near_turf] = TRUE
			candidate.add_owner_aisle_turf(near_turf, open_bay_owner_id, open_bay_zone_id)
			open_bay_owned_area++
			open_turfs += near_turf
			open_owners += open_bay_owner_id
			open_zones += open_bay_zone_id
			if(open_bay_owned_area >= open_bay_max_area)
				break
	// Structural partitions may split surplus into several regions around the
	// service perimeter.  Attach the nearest remaining region through the same
	// authored terminal until the family minimum is met; circulation receives
	// every cell after that hard minimum, so OPEN_BAY cannot blanket-fill it.
	while(length(open_bay_owner_id) && open_bay_owned_area < open_bay_min_area)
		var/turf/next_bay_seed = null
		var/next_bay_distance = 999999999
		for(var/turf/interior_turf as anything in state.geometry.interior)
			if(!istype(interior_turf) || queued_lookup[interior_turf] || blocked_lookup[interior_turf])
				continue
			var/seed_distance = 999999999
			for(var/turf/bay_access_turf as anything in open_bay_access_lookup)
				seed_distance = min(seed_distance, get_dist(interior_turf, bay_access_turf))
			if(!istype(next_bay_seed) || seed_distance < next_bay_distance || (seed_distance == next_bay_distance && (interior_turf.x < next_bay_seed.x || (interior_turf.x == next_bay_seed.x && interior_turf.y < next_bay_seed.y))))
				next_bay_seed = interior_turf
				next_bay_distance = seed_distance
		if(!istype(next_bay_seed))
			break
		queued_lookup[next_bay_seed] = TRUE
		candidate.add_owner_aisle_turf(next_bay_seed, open_bay_owner_id, open_bay_zone_id)
		open_bay_owned_area++
		open_turfs += next_bay_seed
		open_owners += open_bay_owner_id
		open_zones += open_bay_zone_id
		while(open_bay_index <= length(open_turfs) && open_bay_owned_area < open_bay_min_area)
			var/turf/current_surplus_turf = open_turfs[open_bay_index++]
			for(var/check_dir in GLOB.cardinals)
				var/turf/near_turf = get_step(current_surplus_turf, check_dir)
				if(!istype(near_turf) || queued_lookup[near_turf] || blocked_lookup[near_turf] || !interior_lookup[near_turf])
					continue
				queued_lookup[near_turf] = TRUE
				candidate.add_owner_aisle_turf(near_turf, open_bay_owner_id, open_bay_zone_id)
				open_bay_owned_area++
				open_turfs += near_turf
				open_owners += open_bay_owner_id
				open_zones += open_bay_zone_id
				if(open_bay_owned_area >= open_bay_min_area)
					break
	for(var/turf/route_turf as anything in candidate.route_turfs)
		if(!istype(route_turf))
			continue
		open_turfs += route_turf
		open_owners += "[candidate.route_owner_by_turf[route_turf] || "route"]"
		open_zones += "[candidate.route_zone_by_turf[route_turf] || "entry_buffer"]"
		queued_lookup[route_turf] = TRUE
	var/open_index = 1
	while(open_index <= length(open_turfs))
		var/turf/current_turf = open_turfs[open_index]
		var/current_owner = "[open_owners[open_index]]"
		var/current_zone = "[open_zones[open_index]]"
		open_index++
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_turf, check_dir)
			if(!istype(near_turf) || queued_lookup[near_turf] || blocked_lookup[near_turf] || !interior_lookup[near_turf])
				continue
			if(length(open_bay_owner_id) && current_owner == open_bay_owner_id && open_bay_owned_area >= open_bay_max_area)
				continue
			queued_lookup[near_turf] = TRUE
			candidate.add_owner_aisle_turf(near_turf, current_owner, current_zone)
			if(length(open_bay_owner_id) && current_owner == open_bay_owner_id)
				open_bay_owned_area++
			open_turfs += near_turf
			open_owners += current_owner
			open_zones += current_zone
	var/list/unassigned_lookup = list()
	for(var/turf/interior_turf as anything in state.geometry.interior)
		if(istype(interior_turf) && !blocked_lookup[interior_turf] && !candidate.owner_aisle_lookup[interior_turf])
			unassigned_lookup[interior_turf] = TRUE
	var/detached_component_count = 0
	while(length(unassigned_lookup))
		var/turf/component_seed = unassigned_lookup[1]
		var/assign_component_to_open_bay = FALSE
		if(length(open_bay_owner_id) && open_bay_owned_area < open_bay_min_area && length(open_bay_access_lookup))
			var/nearest_bay_distance = 999999999
			for(var/turf/unassigned_turf as anything in unassigned_lookup)
				for(var/turf/bay_access_turf as anything in open_bay_access_lookup)
					var/bay_distance = get_dist(unassigned_turf, bay_access_turf)
					if(!istype(component_seed) || bay_distance < nearest_bay_distance || (bay_distance == nearest_bay_distance && (unassigned_turf.x < component_seed.x || (unassigned_turf.x == component_seed.x && unassigned_turf.y < component_seed.y))))
						component_seed = unassigned_turf
						nearest_bay_distance = bay_distance
			assign_component_to_open_bay = istype(component_seed)
		if(!istype(component_seed))
			break
		var/turf/nearest_route_turf = null
		var/nearest_distance = 999999999
		for(var/turf/route_turf as anything in candidate.route_turfs)
			if(!istype(route_turf))
				continue
			var/route_distance = get_dist(component_seed, route_turf)
			if(!istype(nearest_route_turf) || route_distance < nearest_distance)
				nearest_route_turf = route_turf
				nearest_distance = route_distance
		if(!istype(nearest_route_turf))
			break
		detached_component_count++
		var/component_owner = "[candidate.route_owner_by_turf[nearest_route_turf] || "route"]"
		var/component_zone = "[candidate.route_zone_by_turf[nearest_route_turf] || "entry_buffer"]"
		var/list/component_open = list(component_seed)
		unassigned_lookup -= component_seed
		var/component_index = 1
		while(component_index <= length(component_open))
			var/turf/component_turf = component_open[component_index++]
			if(assign_component_to_open_bay && open_bay_owned_area < open_bay_min_area)
				candidate.add_owner_aisle_turf(component_turf, open_bay_owner_id, open_bay_zone_id)
				open_bay_owned_area++
			else
				candidate.add_owner_aisle_turf(component_turf, component_owner, component_zone)
			for(var/check_dir in GLOB.cardinals)
				var/turf/near_turf = get_step(component_turf, check_dir)
				if(!unassigned_lookup[near_turf])
					continue
				unassigned_lookup -= near_turf
				component_open += near_turf
	state.add_stage_report("layout_owner_aisles", "ok", null, list(
		"candidate_id" = candidate.id,
		"assigned_area" = length(candidate.owner_aisle_turfs),
		"open_bay_owned_area" = open_bay_owned_area,
		"open_bay_min_area" = open_bay_min_area,
		"open_bay_expected_opening_area" = open_bay_expected_opening_area,
		"useful_interior_area" = get_building_layout_useful_interior_area(context, candidate),
		"remaining_area" = length(unassigned_lookup),
		"remaining_component_count" = count_building_layout_lookup_components(unassigned_lookup),
		"detached_component_count" = detached_component_count,
	))
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_terminal_circulation_contract(datum/world_edit_building_layout_program_contract/program, room_id)
	if(!istype(program) || !istype(program.topology_graph))
		return null
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in program.topology_graph.get_edges_for(room_id))
		if(!istype(edge) || !edge.required || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_ROUTE)
			continue
		var/other_id = edge.from_id == room_id ? edge.to_id : edge.from_id
		var/datum/world_edit_building_layout_room_contract/other_contract = program.get_room_contract(other_id)
		if(istype(other_contract) && !other_contract.counts_toward_target)
			return other_contract
	return null

/datum/world_edit_generator/building_layout/proc/get_building_layout_connection_circulation_node_id(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_connection/connection)
	if(!istype(context?.program_contract) || !istype(connection))
		return ""
	for(var/node_id as anything in list(connection.from_node_id, connection.to_node_id))
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract.get_room_contract(node_id)
		if(istype(room_contract) && !room_contract.counts_toward_target)
			return node_id
	return ""

/datum/world_edit_generator/building_layout/proc/count_building_layout_terminal_frontage_options(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_room_contract/room_contract)
	if(!istype(context) || !istype(candidate) || !istype(room_plan) || !istype(room_contract))
		return 0
	var/list/width_attempts = list(1)
	if(room_contract.min_route_opening_width > 1 || room_plan.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY || (room_contract.route_opening_kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH)))
		width_attempts += 2
	var/options = 0
	for(var/route_width as anything in width_attempts)
		var/list/axis_offsets = route_width == 2 ? list(0, 1) : list(0)
		for(var/turf/room_turf as anything in room_plan.turfs)
			for(var/check_dir in GLOB.cardinals)
				var/valid = TRUE
				for(var/axis_offset as anything in axis_offsets)
					var/turf/run_room_turf = axis_offset ? get_step(room_turf, turn(check_dir, 90)) : room_turf
					var/turf/wall_turf = get_step(run_room_turf, check_dir)
					var/turf/route_turf = get_step(wall_turf, check_dir)
					if(!room_plan.turf_lookup[run_room_turf] || !building_layout_route_turf_is_free(context, candidate, wall_turf, room_plan) || !building_layout_route_turf_is_free(context, candidate, route_turf, room_plan) || candidate.route_lookup[wall_turf] || candidate.access_reserved_lookup[wall_turf])
						valid = FALSE
						break
				if(valid)
					options++
	return options

/datum/world_edit_generator/building_layout/proc/find_building_layout_route_entry_seed(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate))
		return null
	var/entry_dir = state.geometry.requested_direction || state.placement_dir || NORTH
	if(!(entry_dir in GLOB.cardinals))
		entry_dir = NORTH
	var/turf/center_turf = context.local_turf(round((context.local_width() + 1) / 2), round((context.local_height() + 1) / 2))
	var/turf/best = null
	var/best_distance = 999999
	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(!istype(boundary_turf) || !boundary_turf_has_outside_dir(boundary_turf, state.geometry.footprint_lookup, entry_dir) || is_corner_boundary_turf(boundary_turf, state.geometry.footprint_lookup))
			continue
		var/turf/inside_turf = get_step(boundary_turf, turn(entry_dir, 180))
		if(candidate.route_terminal_wall_hint_lookup[inside_turf] || !building_layout_route_turf_is_free(context, candidate, inside_turf, null))
			continue
		// get_dist() is Chebyshev distance. Every cell on a square boundary can
		// therefore tie against the center and make iteration order select a
		// corner-side entry. Manhattan distance preserves the authored entry
		// face while selecting its actual center terminal.
		var/distance = istype(center_turf) ? abs(inside_turf.x - center_turf.x) + abs(inside_turf.y - center_turf.y) : 0
		if(!istype(best) || distance < best_distance)
			best = inside_turf
			best_distance = distance
	return best

/datum/world_edit_generator/building_layout/proc/build_building_layout_route_terminal_set(datum/world_edit_building_layout_candidate/candidate)
	var/list/result = list()
	if(!istype(candidate))
		return result
	for(var/datum/world_edit_building_layout_room_connection/connection as anything in candidate.room_connections)
		if(!istype(connection) || !connection.required || connection.edge_kind != WORLD_EDIT_BUILDING_EDGE_ROUTE || connection.route_policy != WORLD_EDIT_BUILDING_ROUTE_POLICY_NETWORK)
			continue
		var/datum/world_edit_building_layout_room_plan/from_room_plan = candidate.get_room_plan(connection.from_node_id)
		var/datum/world_edit_building_layout_room_plan/to_room_plan = candidate.get_room_plan(connection.to_node_id)
		if(istype(from_room_plan) || istype(to_room_plan))
			result += connection
	return result

/datum/world_edit_generator/building_layout/proc/find_building_layout_terminal_route(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_room_contract/room_contract, datum/world_edit_building_layout_room_connection/connection)
	if(!istype(context) || !istype(candidate) || !istype(room_plan) || !istype(room_contract))
		return null
	var/list/terminal_hint = candidate.route_terminal_hints_by_connection?[connection?.id]
	if(islist(terminal_hint))
		var/list/hint_wall_run = terminal_hint["wall_run"]
		var/list/hint_route_run = terminal_hint["route_run"]
		var/hint_valid = islist(hint_wall_run) && islist(hint_route_run) && length(hint_wall_run) && length(hint_route_run)
		for(var/turf/hint_wall_turf as anything in hint_wall_run)
			if(!building_layout_route_turf_is_free(context, candidate, hint_wall_turf, room_plan) || candidate.route_lookup[hint_wall_turf] || candidate.access_reserved_lookup[hint_wall_turf])
				hint_valid = FALSE
				break
		for(var/turf/hint_route_turf as anything in hint_route_run)
			if(!building_layout_route_turf_is_free(context, candidate, hint_route_turf, room_plan))
				hint_valid = FALSE
				break
		if(!hint_valid)
			context.state.add_stage_report("layout_route_terminal_hint", "failed", "committed terminal hint is no longer free", list(
				"candidate_id" = candidate.id,
				"connection_id" = connection?.id,
				"room_id" = room_plan.id,
				"wall_run" = length(hint_wall_run),
				"route_run" = length(hint_route_run),
			))
			return null
		var/turf/hint_target_turf = hint_route_run[max(round((length(hint_route_run) + 1) / 2), 1)]
		var/list/hint_path_result = find_building_layout_bounded_route_path(context, candidate, hint_target_turf, room_plan, hint_wall_run)
		var/list/hint_path = hint_path_result?["path"]
		if(!islist(hint_path))
			context.state.add_stage_report("layout_route_terminal_hint", "failed", "committed terminal hint is unreachable from current route", list(
				"candidate_id" = candidate.id,
				"connection_id" = connection?.id,
				"room_id" = room_plan.id,
				"target_x" = hint_target_turf?.x,
				"target_y" = hint_target_turf?.y,
				"entry_route_count" = length(candidate.route_turfs),
				"free_neighbor_count" = count_building_layout_free_route_neighbors(context, candidate, hint_target_turf, room_plan),
			))
			return null
		return list("wall_run" = hint_wall_run.Copy(), "route_run" = hint_route_run.Copy(), "path" = hint_path, "cost" = round(text2num("[hint_path_result["cost"]]") || length(hint_path) * 10), "width" = length(hint_route_run))
	var/list/width_attempts = list(1)
	if(room_contract.min_route_opening_width > 1)
		width_attempts += 2
	var/transition_width = 1
	if(room_plan.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY || (room_contract.route_opening_kind in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH)))
		transition_width = 2
	if(transition_width > 1 && !width_attempts.Find(2))
		width_attempts += 2
	for(var/route_width as anything in width_attempts)
		var/list/axis_offsets = route_width == 2 ? list(0, 1) : list(0)
		var/list/best = null
		var/best_cost = 999999999
		var/evaluated = 0
		for(var/turf/room_turf as anything in room_plan.turfs)
			if(evaluated >= 48)
				break
			for(var/check_dir in GLOB.cardinals)
				if(evaluated >= 48)
					break
				var/list/wall_run = list()
				var/list/route_run = list()
				var/valid = TRUE
				for(var/axis_offset as anything in axis_offsets)
					var/axis_dir = axis_offset ? turn(check_dir, 90) : 0
					var/turf/run_room_turf = axis_offset ? get_step(room_turf, axis_dir) : room_turf
					if(route_width == 1 && transition_width == 1 && (!room_plan.turf_lookup[get_step(run_room_turf, turn(check_dir, 90))] || !room_plan.turf_lookup[get_step(run_room_turf, turn(check_dir, -90))]))
						valid = FALSE
						break
					var/turf/wall_turf = get_step(run_room_turf, check_dir)
					var/turf/route_turf = get_step(wall_turf, check_dir)
					if(!room_plan.turf_lookup[run_room_turf] || !building_layout_route_turf_is_free(context, candidate, wall_turf, room_plan) || !building_layout_route_turf_is_free(context, candidate, route_turf, room_plan) || candidate.route_lookup[wall_turf] || candidate.access_reserved_lookup[wall_turf])
						valid = FALSE
						break
					wall_run += wall_turf
					route_run += route_turf
				if(!valid)
					continue
				evaluated++
				var/turf/target_turf = route_run[max(round((length(route_run) + 1) / 2), 1)]
				var/list/path_result = find_building_layout_bounded_route_path(context, candidate, target_turf, room_plan, wall_run)
				var/list/path = path_result?["path"]
				if(!islist(path))
					continue
				var/path_cost = round(text2num("[path_result["cost"]]") || length(path) * 10)
				if(!islist(best) || path_cost < best_cost)
					best = list("wall_run" = wall_run, "route_run" = route_run, "path" = path, "cost" = path_cost, "width" = route_width)
					best_cost = path_cost
		if(islist(best) && route_width >= transition_width)
			return best
	return null

/datum/world_edit_generator/building_layout/proc/building_layout_route_turf_is_free(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/check_turf, datum/world_edit_building_layout_room_plan/ignored_room)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !istype(check_turf) || !state.geometry.footprint_lookup[check_turf] || state.geometry.boundary_lookup[check_turf])
		return FALSE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(istype(room_plan) && room_plan != ignored_room && room_plan.turf_lookup[check_turf])
			return FALSE
	if(istype(ignored_room) && ignored_room.turf_lookup[check_turf])
		return FALSE
	if(building_layout_turf_is_functional_partition_gap(candidate, check_turf))
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_turf_is_functional_partition_gap(datum/world_edit_building_layout_candidate/candidate, turf/check_turf)
	if(!istype(candidate) || !istype(check_turf))
		return FALSE
	for(var/check_dir in list(NORTH, EAST))
		var/owner_a = ""
		var/owner_b = ""
		var/turf/side_a = get_step(check_turf, check_dir)
		var/turf/side_b = get_step(check_turf, turn(check_dir, 180))
		for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
			if(!istype(room_plan))
				continue
			if(room_plan.turf_lookup[side_a])
				owner_a = room_plan.id
			if(room_plan.turf_lookup[side_b])
				owner_b = room_plan.id
		if(length(owner_a) && length(owner_b) && owner_a != owner_b)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/find_building_layout_bounded_route_path(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/target_turf, datum/world_edit_building_layout_room_plan/terminal_room, list/protected_wall_run)
	var/datum/world_edit_building_layout_state/state = context?.state
	if(!istype(state) || !istype(candidate) || !istype(target_turf) || !length(candidate.route_turfs))
		return null
	if(candidate.route_lookup[target_turf])
		return list("path" = list(), "cost" = 0)
	var/list/open = list(target_turf)
	var/list/closed = list()
	var/list/previous = list()
	var/list/cost_lookup = list()
	var/list/estimate_lookup = list()
	var/list/protected_wall_lookup = list()
	for(var/turf/protected_wall_turf as anything in protected_wall_run)
		if(istype(protected_wall_turf))
			protected_wall_lookup[protected_wall_turf] = TRUE
	cost_lookup[target_turf] = 0
	estimate_lookup[target_turf] = get_building_layout_nearest_route_distance(candidate, target_turf) * 10
	var/turf/found = null
	var/expansions = 0
	var/max_expansions = min(length(state.geometry.footprint) * 4, 4096)
	while(length(open) && expansions < max_expansions)
		var/best_index = 1
		var/best_estimate = 999999999
		for(var/open_index in 1 to length(open))
			var/turf/open_turf = open[open_index]
			var/open_estimate = round(text2num("[estimate_lookup[open_turf]]") || 0)
			if(open_estimate < best_estimate)
				best_estimate = open_estimate
				best_index = open_index
		var/turf/current = open[best_index]
		open.Cut(best_index, best_index + 1)
		if(closed[current])
			continue
		closed[current] = TRUE
		if(candidate.route_lookup[current])
			found = current
			break
		var/turf/previous_turf = previous[current]
		var/previous_dir = istype(previous_turf) ? get_dir(previous_turf, current) : 0
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby = get_step(current, check_dir)
			if(!building_layout_route_turf_is_free(context, candidate, nearby, terminal_room) || closed[nearby] || protected_wall_lookup[nearby] || (candidate.route_terminal_wall_hint_lookup[nearby] && !protected_wall_lookup[nearby]) || (candidate.access_reserved_lookup[nearby] && !candidate.route_lookup[nearby]))
				continue
			var/step_cost = candidate.route_lookup[nearby] ? 0 : get_building_layout_route_turf_cost(context, candidate, nearby)
			if(previous_dir && previous_dir != check_dir)
				step_cost += 12
			if(count_building_layout_free_route_neighbors(context, candidate, nearby, terminal_room) <= 1)
				step_cost += 20
			if(!candidate.route_lookup[nearby] && building_layout_turf_has_parallel_route_neighbor(candidate, nearby, check_dir))
				step_cost += 25
			var/next_cost = round(text2num("[cost_lookup[current]]") || 0) + step_cost
			var/existing_cost = cost_lookup[nearby]
			if(!isnull(existing_cost) && next_cost >= existing_cost)
				continue
			cost_lookup[nearby] = next_cost
			previous[nearby] = current
			estimate_lookup[nearby] = next_cost + get_building_layout_nearest_route_distance(candidate, nearby) * 10
			open |= nearby
		expansions++
	if(!istype(found))
		return null
	var/list/path = list()
	var/turf/path_turf = found
	while(istype(path_turf) && path_turf != target_turf)
		path_turf = previous[path_turf]
		if(istype(path_turf))
			path += path_turf
	return list("path" = path, "cost" = round(text2num("[cost_lookup[found]]") || length(path) * 10), "expansions" = expansions)

/datum/world_edit_generator/building_layout/proc/get_building_layout_route_turf_cost(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/route_turf)
	var/cost = 10
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(!istype(room_plan))
			continue
		for(var/check_dir in GLOB.cardinals)
			if(!room_plan.turf_lookup[get_step(get_step(route_turf, check_dir), check_dir)])
				continue
			var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan.contract_id)
			if(istype(room_contract) && (room_contract.privacy_class == "public" || room_contract.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY))
				return 8
			if(istype(room_contract) && room_contract.role in list("service", "storage", "support"))
				cost = max(cost, 12)
	return cost

/datum/world_edit_generator/building_layout/proc/get_building_layout_nearest_route_distance(datum/world_edit_building_layout_candidate/candidate, turf/check_turf)
	var/best = 999
	for(var/turf/route_turf as anything in candidate?.route_turfs)
		if(istype(route_turf))
			best = min(best, get_dist(check_turf, route_turf))
	return best

/datum/world_edit_generator/building_layout/proc/count_building_layout_free_route_neighbors(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, turf/check_turf, datum/world_edit_building_layout_room_plan/terminal_room)
	var/count = 0
	for(var/check_dir in GLOB.cardinals)
		if(building_layout_route_turf_is_free(context, candidate, get_step(check_turf, check_dir), terminal_room))
			count++
	return count

/datum/world_edit_generator/building_layout/proc/building_layout_turf_has_parallel_route_neighbor(datum/world_edit_building_layout_candidate/candidate, turf/check_turf, travel_dir)
	if(!istype(candidate) || !istype(check_turf))
		return FALSE
	var/side_a = turn(travel_dir, 90)
	var/side_b = turn(travel_dir, -90)
	return candidate.route_lookup[get_step(check_turf, side_a)] || candidate.route_lookup[get_step(check_turf, side_b)]

/datum/world_edit_generator/building_layout/proc/normalize_building_layout_route_network(datum/world_edit_building_layout_candidate/candidate, turf/entry_seed)
	if(!istype(candidate) || !istype(entry_seed))
		return
	var/list/protected = list()
	protected[entry_seed] = TRUE
	for(var/reservation_id as anything in candidate.access_reservations_by_room)
		var/list/reservation = candidate.access_reservations_by_room[reservation_id]
		for(var/turf/route_turf as anything in reservation?["route_run"])
			if(istype(route_turf))
				protected[route_turf] = TRUE
	var/changed = TRUE
	while(changed)
		changed = FALSE
		for(var/index = length(candidate.route_turfs), index >= 1, index--)
			var/turf/route_turf = candidate.route_turfs[index]
			if(!istype(route_turf) || protected[route_turf])
				continue
			var/neighbors = 0
			for(var/check_dir in GLOB.cardinals)
				if(candidate.route_lookup[get_step(route_turf, check_dir)])
					neighbors++
			if(neighbors > 1)
				continue
			candidate.route_turfs.Cut(index, index + 1)
			candidate.route_lookup -= route_turf
			candidate.route_owner_by_turf -= route_turf
			changed = TRUE
	for(var/index = length(candidate.route_turfs), index >= 1, index--)
		var/turf/route_turf = candidate.route_turfs[index]
		if(!istype(route_turf) || protected[route_turf])
			continue
		var/neighbors = 0
		for(var/check_dir in GLOB.cardinals)
			if(candidate.route_lookup[get_step(route_turf, check_dir)])
				neighbors++
		if(neighbors < 2 || !building_layout_route_protected_connected_without(candidate, protected, route_turf))
			continue
		candidate.route_turfs.Cut(index, index + 1)
		candidate.route_lookup -= route_turf
		candidate.route_owner_by_turf -= route_turf

/datum/world_edit_generator/building_layout/proc/normalize_building_layout_route_width_bounded(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context?.state) || !istype(candidate) || !length(candidate.route_turfs))
		return
	var/target_width = 1
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in context.program_contract?.circulation_contracts)
		if(istype(circulation_contract) && circulation_contract.required)
			target_width = max(target_width, min(circulation_contract.min_width, 2))
	if(target_width <= 1)
		return
	var/list/source_route = candidate.route_turfs.Copy()
	var/expanded_count = 0
	for(var/turf/route_turf as anything in source_route)
		if(!istype(route_turf))
			continue
		var/list/neighbor_dirs = list()
		for(var/check_dir in GLOB.cardinals)
			if(candidate.route_lookup[get_step(route_turf, check_dir)])
				neighbor_dirs += check_dir
		var/travel_dir = 0
		if(length(neighbor_dirs) == 1)
			travel_dir = neighbor_dirs[1]
		else if(length(neighbor_dirs) == 2 && neighbor_dirs[2] == turn(neighbor_dirs[1], 180))
			travel_dir = neighbor_dirs[1]
		if(!travel_dir || building_layout_turf_has_parallel_route_neighbor(candidate, route_turf, travel_dir))
			continue
		var/list/side_candidates = list(get_step(route_turf, turn(travel_dir, 90)), get_step(route_turf, turn(travel_dir, -90)))
		var/turf/best_side = null
		var/best_side_score = -999999999
		for(var/turf/side_turf as anything in side_candidates)
			if(!istype(side_turf) || candidate.route_terminal_wall_hint_lookup[side_turf] || candidate.access_reserved_lookup[side_turf] || !building_layout_route_turf_is_free(context, candidate, side_turf, null))
				continue
			var/side_score = 0
			for(var/side_dir in GLOB.cardinals)
				if(candidate.route_lookup[get_step(side_turf, side_dir)])
					side_score += 100
			// Stable coordinate tie-break keeps replay hashes deterministic.
			side_score -= side_turf.x * 2 + side_turf.y
			if(!istype(best_side) || side_score > best_side_score)
				best_side = side_turf
				best_side_score = side_score
		if(!istype(best_side))
			continue
		candidate.add_route_turf(best_side)
		candidate.route_owner_by_turf[best_side] = "route"
		expanded_count++
	context.state.add_stage_report("layout_route_width_normalization", "ok", null, list(
		"candidate_id" = candidate.id,
		"target_width" = target_width,
		"source_area" = length(source_route),
		"expanded_area" = expanded_count,
		"normalized_area" = length(candidate.route_turfs),
	))

/datum/world_edit_generator/building_layout/proc/building_layout_route_protected_connected_without(datum/world_edit_building_layout_candidate/candidate, list/protected, turf/excluded_turf)
	var/turf/start_turf = null
	for(var/turf/protected_turf as anything in protected)
		if(protected_turf != excluded_turf && candidate.route_lookup[protected_turf])
			start_turf = protected_turf
			break
	if(!istype(start_turf))
		return FALSE
	var/list/seen = list()
	seen[start_turf] = TRUE
	var/list/open = list(start_turf)
	var/open_index = 1
	while(open_index <= length(open))
		var/turf/current_turf = open[open_index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(current_turf, check_dir)
			if(near_turf == excluded_turf || !candidate.route_lookup[near_turf] || seen[near_turf])
				continue
			seen[near_turf] = TRUE
			open += near_turf
	for(var/turf/protected_turf as anything in protected)
		if(protected_turf != excluded_turf && candidate.route_lookup[protected_turf] && !seen[protected_turf])
			return FALSE
	return TRUE
