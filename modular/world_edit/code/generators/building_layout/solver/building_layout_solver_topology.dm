#define WORLD_EDIT_BUILDING_ALLOCATION_BEAM_WIDTH 6
#define WORLD_EDIT_BUILDING_ALLOCATION_RECTS_PER_NODE 8
#define WORLD_EDIT_BUILDING_ALLOCATION_MAX_EXPANSIONS 96

/datum/world_edit_building_layout_family_policy
	var/id = ""
	var/min_width = 9
	var/min_height = 9

/datum/world_edit_building_layout_family_policy/proc/can_solve(datum/world_edit_building_layout_context/context)
	return istype(context) && context.local_width() >= min_width && context.local_height() >= min_height

/datum/world_edit_building_layout_family_policy/proc/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = list(
		"family" = id,
		"orientation" = orientation_variant,
		"requires_root_first" = TRUE,
		"requires_edge_geometry" = TRUE,
	)
	switch(id)
		if("hub_spoke")
			result["root_position"] = "center"
			result["spoke_count"] = 5
		if("split_wing")
			result["wing_count"] = 2
			result["central_transition"] = TRUE
		if("open_bay_perimeter")
			result["open_bay_min_percent"] = 35
			result["open_bay_max_percent"] = 60
			result["perimeter_services"] = TRUE
		if("secure_core")
			result["secure_core"] = TRUE
			result["controlled_transition"] = TRUE
		if("nested_service")
			result["requires_nested_parent_child"] = TRUE
			result["child_after_parent"] = TRUE
		if("compound_cells")
			result["compound_pods"] = 4
			result["courtyard"] = TRUE
		if("axial_fallback")
			result["axial_fallback_only"] = TRUE
	return result

/datum/world_edit_building_layout_family_policy/proc/build_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	switch(id)
		if("hub_spoke") return build_hub_spoke_seed_regions(context, region, orientation_variant)
		if("split_wing") return build_split_wing_seed_regions(context, region, orientation_variant)
		if("open_bay_perimeter") return build_open_bay_perimeter_seed_regions(context, region, orientation_variant)
		if("secure_core") return build_secure_core_seed_regions(context, region, orientation_variant)
		if("nested_service") return build_nested_service_seed_regions(context, region, orientation_variant)
		if("compound_cells") return build_compound_cells_seed_regions(context, region, orientation_variant)
		if("axial_fallback") return build_axial_fallback_seed_regions(context, region, orientation_variant)
	return FALSE

/datum/world_edit_building_layout_family_policy/proc/score_partial(datum/world_edit_building_layout_context/context, list/placements)
	return islist(placements) ? length(placements) * 100 : 0

/datum/world_edit_building_layout_family_policy/proc/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate) || candidate.family_policy_id != id || !length(candidate.room_plans))
		return FALSE
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/reject_candidate(datum/world_edit_building_layout_candidate/candidate, reason)
	if(istype(candidate) && length("[reason]"))
		candidate.errors += "family.[id].[reason]"
	return FALSE

/datum/world_edit_generator/building_layout/proc/get_building_layout_candidate_root_plan(datum/world_edit_building_layout_candidate/candidate)
	if(!istype(candidate))
		return null
	return candidate.get_room_plan(candidate.topology_graph?.root_node_id)

/datum/world_edit_generator/building_layout/proc/get_building_layout_root_functional_children(datum/world_edit_building_layout_candidate/candidate)
	var/list/result = list()
	var/root_id = "[candidate?.topology_graph?.root_node_id || ""]"
	if(!length(root_id))
		return result
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph.get_edges_for(root_id))
		// A typed NESTED child consumes its parent's interior; it is not an
		// external hub spoke and must not consume the authored 3-4 spoke budget.
		if(!istype(edge) || !edge.required || edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED))
			continue
		var/child_id = edge.from_id == root_id ? edge.to_id : edge.from_id
		var/datum/world_edit_building_layout_room_plan/child_plan = candidate.get_room_plan(child_id)
		if(istype(child_plan))
			result += child_plan
	return result

/datum/world_edit_generator/building_layout/proc/get_building_layout_room_side(datum/world_edit_building_layout_room_plan/root_plan, datum/world_edit_building_layout_room_plan/other_plan)
	if(!istype(root_plan) || !istype(other_plan))
		return ""
	var/root_cx = (root_plan.x1 + root_plan.x2) / 2
	var/root_cy = (root_plan.y1 + root_plan.y2) / 2
	return get_building_layout_room_side_from_point(root_cx, root_cy, other_plan)

/datum/world_edit_generator/building_layout/proc/get_building_layout_room_side_from_point(root_cx, root_cy, datum/world_edit_building_layout_room_plan/other_plan)
	if(!istype(other_plan))
		return ""
	var/other_cx = (other_plan.x1 + other_plan.x2) / 2
	var/other_cy = (other_plan.y1 + other_plan.y2) / 2
	var/dx = other_cx - root_cx
	var/dy = other_cy - root_cy
	if(abs(dx) >= abs(dy))
		return dx < 0 ? "west" : "east"
	return dy < 0 ? "south" : "north"

/datum/world_edit_generator/building_layout/proc/building_layout_room_plans_share_partition(datum/world_edit_building_layout_room_plan/a, datum/world_edit_building_layout_room_plan/b, min_length = 1)
	if(!istype(a) || !istype(b))
		return FALSE
	var/shared = 0
	for(var/turf/a_turf as anything in a.turfs)
		for(var/check_dir in GLOB.cardinals)
			var/turf/wall_turf = get_step(a_turf, check_dir)
			var/turf/b_turf = get_step(wall_turf, check_dir)
			if(b.turf_lookup[b_turf])
				shared++
	return shared >= max(min_length, 1)

/datum/world_edit_generator/building_layout/proc/count_building_layout_openings_between(datum/world_edit_building_layout_candidate/candidate, from_id, to_id)
	var/count = 0
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate?.opening_plans)
		if(!istype(opening_plan) || opening_plan.kind == "main_exit")
			continue
		if((opening_plan.from_room == from_id && opening_plan.to_room == to_id) || (opening_plan.from_room == to_id && opening_plan.to_room == from_id))
			count++
	return count

/datum/world_edit_generator/building_layout/proc/building_layout_room_touches_route(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan)
	if(!istype(candidate) || !istype(room_plan))
		return FALSE
	for(var/turf/room_turf as anything in room_plan.turfs)
		for(var/check_dir in GLOB.cardinals)
			var/turf/near_turf = get_step(room_turf, check_dir)
			if(candidate.route_lookup[near_turf] || candidate.route_lookup[get_step(near_turf, check_dir)])
				return TRUE
	return FALSE

/datum/world_edit_building_layout_family_policy/proc/add_seed_zone(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, zone_id, role, x1, y1, x2, y2, list/room_ids, priority, orientation_variant)
	if(!istype(context) || !istype(region) || !islist(room_ids) || !length(room_ids))
		return
	var/w = context.local_width()
	var/h = context.local_height()
	if(orientation_variant % 2)
		var/old_x1 = x1
		var/old_x2 = x2
		x1 = y1
		x2 = y2
		y1 = old_x1
		y2 = old_x2
	x1 = clamp(round(x1), 2, max(w - 1, 2))
	x2 = clamp(round(x2), 2, max(w - 1, 2))
	y1 = clamp(round(y1), 2, max(h - 1, 2))
	y2 = clamp(round(y2), 2, max(h - 1, 2))
	region.add_influence_zone(zone_id, role, min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2), room_ids, priority)

/datum/world_edit_generator/building_layout/proc/build_building_layout_family_groups(datum/world_edit_building_layout_context/context)
	var/list/root_rooms = list()
	var/list/public_rooms = list()
	var/list/secure_rooms = list()
	var/list/nested_rooms = list()
	var/list/other_rooms = list()
	var/list/groups = list()
	var/root_id = "[context.program_contract.topology_graph.root_node_id || ""]"
	for(var/room_index in 1 to length(context.program_contract.functional_room_contracts))
		var/datum/world_edit_building_layout_room_contract/room = context.program_contract.functional_room_contracts[room_index]
		if(isnull(room))
			continue
		var/datum/world_edit_building_layout_topology_node/topology_node = context.program_contract.topology_graph.get_node(room.id)
		if(room.id == root_id)
			root_rooms += room.id
		else if(room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_NESTED_ROOM || context.generator.building_layout_topology_node_has_nested_parent(context.program_contract.topology_graph, topology_node))
			nested_rooms += room.id
		else if(room.privacy_class == "secure" || room.partition_policy == WORLD_EDIT_BUILDING_PARTITION_SECURE)
			secure_rooms += room.id
		else if(room.privacy_class == "public" || room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY || (room.role in list("hub", "public", "public_med", "staging")))
			public_rooms += room.id
		else
			other_rooms += room.id
	if(!length(root_rooms) && length(context.program_contract.functional_room_contracts))
		var/datum/world_edit_building_layout_room_contract/first_room = context.program_contract.functional_room_contracts[1]
		root_rooms += first_room.id
		other_rooms -= first_room.id
	groups["root"] = root_rooms.Copy()
	groups["public"] = public_rooms.Copy()
	groups["secure"] = secure_rooms.Copy()
	groups["nested"] = nested_rooms.Copy()
	groups["other"] = other_rooms.Copy()
	return groups

/datum/world_edit_generator/building_layout/proc/building_layout_topology_node_has_nested_parent(datum/world_edit_building_layout_topology_graph/graph, datum/world_edit_building_layout_topology_node/node)
	if(!istype(graph) || !istype(node) || !length(node.parent_id))
		return FALSE
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(node.id))
		if(!istype(edge) || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		var/other_id = edge.from_id == node.id ? edge.to_id : edge.from_id
		if(other_id == node.parent_id)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/split_building_layout_ids_round_robin(list/source, bucket_count)
	var/list/result = list()
	for(var/index in 1 to max(bucket_count, 1))
		result.len++
		result[result.len] = list()
	var/source_index = 0
	for(var/id as anything in source)
		source_index++
		var/bucket_index = ((source_index - 1) % length(result)) + 1
		var/list/bucket = result[bucket_index]
		bucket += id
		result[bucket_index] = bucket
	return result

/datum/world_edit_generator/building_layout/proc/split_building_layout_atomic_topology_groups(datum/world_edit_building_layout_topology_graph/graph, list/source, bucket_count)
	var/list/result = list()
	for(var/index in 1 to max(bucket_count, 1))
		result.len++
		result[result.len] = list()
	if(!istype(graph) || !islist(source) || !length(source))
		return result
	var/list/source_lookup = list()
	for(var/room_id as anything in source)
		source_lookup["[room_id]"] = TRUE
	var/list/visited = list()
	var/list/components = list()
	for(var/source_id as anything in source)
		var/source_key = "[source_id]"
		if(visited[source_key])
			continue
		var/list/component = list()
		var/list/queue = list(source_key)
		visited[source_key] = TRUE
		var/queue_index = 1
		while(queue_index <= length(queue))
			var/current_id = "[queue[queue_index]]"
			queue_index++
			component += current_id
			for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(current_id))
				if(!istype(edge) || !edge.required || !(edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_NESTED, WORLD_EDIT_BUILDING_EDGE_SECURE)))
					continue
				var/other_id = edge.from_id == current_id ? edge.to_id : edge.from_id
				if(!source_lookup[other_id] || visited[other_id])
					continue
				visited[other_id] = TRUE
				queue += other_id
		components += list(component)
	for(var/list/component as anything in components)
		var/best_bucket_index = 1
		var/best_bucket_size = length(result[1])
		for(var/bucket_index in 2 to length(result))
			var/list/bucket = result[bucket_index]
			if(length(bucket) >= best_bucket_size)
				continue
			best_bucket_index = bucket_index
			best_bucket_size = length(bucket)
		var/list/best_bucket = result[best_bucket_index]
		best_bucket += component
		result[best_bucket_index] = best_bucket
	return result

/datum/world_edit_generator/building_layout/proc/sort_building_layout_ids_by_min_area(datum/world_edit_building_layout_context/context, list/source)
	var/list/result = list()
	if(!istype(context) || !islist(source))
		return result
	for(var/room_id as anything in source)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_id)
		var/inserted = FALSE
		for(var/index in 1 to length(result))
			var/datum/world_edit_building_layout_room_contract/existing_contract = context.program_contract?.get_room_contract(result[index])
			if((room_contract?.min_area || 0) <= (existing_contract?.min_area || 0))
				continue
			result.Insert(index, room_id)
			inserted = TRUE
			break
		if(!inserted)
			result += room_id
	return result

/datum/world_edit_building_layout_family_policy/hub_spoke
	id = "hub_spoke"

/datum/world_edit_building_layout_family_policy/hub_spoke/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["root_position"] = "center"
	result["min_root_children"] = 2
	result["max_root_children"] = 4
	result["max_branch_depth"] = 2
	return result

/datum/world_edit_building_layout_family_policy/hub_spoke/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/datum/world_edit_building_layout_room_plan/root_plan = context.generator.get_building_layout_candidate_root_plan(candidate)
	var/datum/world_edit_building_layout_room_contract/root_contract = context.program_contract?.get_room_contract(root_plan?.contract_id)
	if(!istype(root_plan) || !istype(root_contract) || !(root_contract.spatial_kind in list(WORLD_EDIT_BUILDING_SPACE_FUNCTIONAL_ROOM, WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)))
		return reject_candidate(candidate, "root_missing")
	var/root_cx = (root_plan.x1 + root_plan.x2) / 2
	var/root_cy = (root_plan.y1 + root_plan.y2) / 2
	var/list/children = context.generator.get_building_layout_root_functional_children(candidate)
	var/hub_zone_id = "[context.state.archetype?.hub_zone || ""]"
	var/datum/world_edit_building_layout_room_contract/hub_contract = context.program_contract?.get_room_contract(hub_zone_id)
	// Some authored hub/spoke programs use a typed circulation node as their hub
	// while the topology traversal root remains a functional room. Validate the
	// actual circulation degree/centroid rather than erasing ROUTE edges and then
	// reporting a synthetic zero-spoke family.
	if(istype(hub_contract) && !hub_contract.counts_toward_target)
		var/list/hub_turfs = list()
		var/datum/world_edit_building_layout_route_overlay/hub_overlay = candidate.route_overlays_by_id[hub_contract.id]
		if(istype(hub_overlay))
			hub_turfs = hub_overlay.turfs.Copy()
			for(var/turf/approach_turf as anything in hub_overlay.approach_turfs)
				if(istype(approach_turf))
					hub_turfs |= approach_turf
		else
			for(var/turf/route_turf as anything in candidate.route_zone_by_turf)
				if(candidate.route_zone_by_turf[route_turf] == hub_contract.zone_id)
					hub_turfs += route_turf
		if(!length(hub_turfs))
			return reject_candidate(candidate, "hub_circulation_missing")
		var/datum/world_edit_building_layout_room_plan/hub_owner_plan = candidate.get_room_plan(hub_contract.circulation_owner_room_id)
		if(hub_contract.circulation_kind == WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE && istype(hub_owner_plan))
			// The aisle is a circulation layer within its functional owner; its strip
			// may hug a terminal, while the containing room is the actual spatial hub.
			root_cx = (hub_owner_plan.x1 + hub_owner_plan.x2) / 2
			root_cy = (hub_owner_plan.y1 + hub_owner_plan.y2) / 2
		else
			root_cx = 0
			root_cy = 0
			for(var/turf/hub_turf as anything in hub_turfs)
				root_cx += hub_turf.x
				root_cy += hub_turf.y
			root_cx /= length(hub_turfs)
			root_cy /= length(hub_turfs)
		children = list()
		for(var/datum/world_edit_building_layout_topology_edge/hub_edge as anything in candidate.topology_graph?.get_edges_for(hub_contract.id))
			if(!istype(hub_edge) || !hub_edge.required || hub_edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_ROUTE)
				continue
			var/child_id = hub_edge.from_id == hub_contract.id ? hub_edge.to_id : hub_edge.from_id
			var/datum/world_edit_building_layout_room_contract/child_contract = context.program_contract.get_room_contract(child_id)
			var/datum/world_edit_building_layout_room_plan/child_plan = candidate.get_room_plan(child_id)
			if(istype(child_contract) && child_contract.counts_toward_target && istype(child_plan))
				children += child_plan
	var/bounds_cx = (context.state.geometry.bounds["min_x"] + context.state.geometry.bounds["max_x"]) / 2
	var/bounds_cy = (context.state.geometry.bounds["min_y"] + context.state.geometry.bounds["max_y"]) / 2
	if(abs(root_cx - bounds_cx) > max(round(context.local_width() * 0.2), 2) || abs(root_cy - bounds_cy) > max(round(context.local_height() * 0.2), 2))
		return reject_candidate(candidate, "root_off_center")
	if(length(children) < 2 || length(children) > 4)
		return reject_candidate(candidate, "root_child_count:[length(children)]")
	var/list/used_sides = list()
	for(var/datum/world_edit_building_layout_room_plan/child_plan as anything in children)
		used_sides[context.generator.get_building_layout_room_side_from_point(root_cx, root_cy, child_plan)] = TRUE
	if(length(used_sides) < 2)
		return reject_candidate(candidate, "root_single_side")
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(room_plan.graph_depth > 2)
			return reject_candidate(candidate, "branch_depth:[room_plan.contract_id]:[room_plan.graph_depth]")
	if(length(candidate.route_turfs) * 100 > length(context.state.geometry.interior) * 30)
		return reject_candidate(candidate, "route_ratio")
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/build_hub_spoke_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/list/groups = context.generator.build_building_layout_family_groups(context)
	var/w = context.local_width()
	var/h = context.local_height()
	var/cx = round((w + 1) / 2)
	var/cy = round((h + 1) / 2)
	var/root_id = "[context.program_contract?.topology_graph?.root_node_id || ""]"
	// Keep a seven-cell long side on the hub and move it one cell away from
	// the entry. That gives one real front partition and two non-overlapping
	// partitions on each long side without inventing a rear spoke.
	add_seed_zone(context, region, "hub_root", "root", cx - 3, cy - 2, cx + 2, cy + 4, groups["root"], 200, orientation_variant)
	var/list/spoke_ids = list()
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in context.program_contract?.topology_graph?.get_edges_for(root_id))
		if(!istype(edge) || !edge.required || edge.edge_kind in list(WORLD_EDIT_BUILDING_EDGE_ROUTE, WORLD_EDIT_BUILDING_EDGE_NESTED))
			continue
		spoke_ids |= edge.from_id == root_id ? edge.to_id : edge.from_id
	spoke_ids = context.generator.sort_building_layout_ids_by_min_area(context, spoke_ids)
	var/list/spokes = context.generator.split_building_layout_ids_round_robin(spoke_ids, 5)
	var/list/nested_ids = groups["nested"].Copy()
	var/list/branch_ids = groups["public"] + groups["secure"] + groups["other"]
	for(var/spoke_id as anything in spoke_ids)
		branch_ids -= spoke_id
	// The widest service footprint gets the four-cell outer side. The front
	// spoke remains three cells wide and leaves the entry terminal unobstructed.
	add_seed_zone(context, region, "spoke_front", "spoke", 2, 2, cx - 1, cy - 4, spokes[2], 120, orientation_variant)
	add_seed_zone(context, region, "spoke_right_front", "spoke", cx + 4, 2, w - 1, cy, spokes[1], 120, orientation_variant)
	add_seed_zone(context, region, "spoke_right_back", "spoke", cx + 4, cy + 2, w - 1, h - 1, spokes[3], 120, orientation_variant)
	add_seed_zone(context, region, "spoke_left_front", "spoke", 2, 2, cx - 5, cy, spokes[4], 120, orientation_variant)
	add_seed_zone(context, region, "spoke_left_back", "spoke", 2, cy + 2, cx - 5, h - 1, spokes[5], 120, orientation_variant)
	// Typed NESTED rooms are packed inside the root by their containment anchors;
	// they are not external spokes. Route/public branches remain independently
	// placeable around the hub and do not consume its structural spoke count.
	add_seed_zone(context, region, "hub_nested", "nested", cx - 3, cy - 2, cx + 2, cy + 4, nested_ids, 180, orientation_variant)
	add_seed_zone(context, region, "hub_route_branch", "branch", 2, 2, w - 1, h - 1, branch_ids, 100, orientation_variant)
	region.add_route_hint("hub_cross", "cross", cx, 2, cx, h - 1, list())
	return TRUE

/datum/world_edit_building_layout_family_policy/split_wing
	id = "split_wing"

/datum/world_edit_building_layout_family_policy/split_wing/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["wing_count"] = 2
	result["central_transition"] = TRUE
	return result

/datum/world_edit_building_layout_family_policy/split_wing/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/datum/world_edit_building_layout_room_plan/root_plan = context.generator.get_building_layout_candidate_root_plan(candidate)
	if(!istype(root_plan))
		return reject_candidate(candidate, "transition_missing")
	var/split_axis = candidate.orientation_variant % 2 ? "y" : "x"
	var/split_coord = split_axis == "x" ? (context.local_width() + 1) / 2 : (context.local_height() + 1) / 2
	var/turf/root_center = locate(round((root_plan.x1 + root_plan.x2) / 2), round((root_plan.y1 + root_plan.y2) / 2), root_plan.turfs?[1]?.z)
	var/list/root_local = context.local_coordinates(root_center)
	var/root_coord = text2num("[root_local?[split_axis]]") || 0
	if(abs(root_coord - split_coord) > 2)
		return reject_candidate(candidate, "transition_not_central")
	var/wing_a_count = 0
	var/wing_b_count = 0
	var/list/wing_a_ids = list()
	var/list/wing_b_ids = list()
	for(var/datum/world_edit_building_layout_influence_zone/wing_zone as anything in candidate.region_candidate?.influence_zones)
		if(!istype(wing_zone))
			continue
		if(wing_zone.id == "wing_a")
			for(var/wing_a_id as anything in wing_zone.preferred_room_contracts)
				wing_a_ids["[wing_a_id]"] = TRUE
		else if(wing_zone.id == "wing_b")
			for(var/wing_b_id as anything in wing_zone.preferred_room_contracts)
				wing_b_ids["[wing_b_id]"] = TRUE
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(room_plan == root_plan)
			continue
		var/datum/world_edit_building_layout_topology_node/topology_node = candidate.topology_graph?.get_node(room_plan.contract_id)
		var/datum/world_edit_building_layout_topology_edge/parent_edge = context.generator.get_building_layout_partial_edge(candidate.topology_graph, room_plan.contract_id, topology_node?.parent_id)
		if(parent_edge?.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		var/turf/room_center = locate(round((room_plan.x1 + room_plan.x2) / 2), round((room_plan.y1 + room_plan.y2) / 2), room_plan.turfs?[1]?.z)
		var/list/room_local = context.local_coordinates(room_center)
		var/room_coord = text2num("[room_local?[split_axis]]") || 0
		var/wing = room_coord < split_coord ? "a" : "b"
		if(wing == "a")
			wing_a_count++
		else
			wing_b_count++
		if(wing_a_ids[room_plan.contract_id] && wing != "a")
			return reject_candidate(candidate, "topology_cluster_split:wing_a|[room_plan.contract_id]")
		if(wing_b_ids[room_plan.contract_id] && wing != "b")
			return reject_candidate(candidate, "topology_cluster_split:wing_b|[room_plan.contract_id]")
		if(!wing_a_ids[room_plan.contract_id] && !wing_b_ids[room_plan.contract_id])
			return reject_candidate(candidate, "topology_cluster_unassigned:[room_plan.contract_id]")
	if(!wing_a_count || !wing_b_count)
		return reject_candidate(candidate, "empty_wing")
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/build_split_wing_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/list/groups = context.generator.build_building_layout_family_groups(context)
	var/root_id = "[context.program_contract?.topology_graph?.root_node_id || ""]"
	var/list/all_ids = groups["root"] + groups["public"] + groups["secure"] + groups["nested"] + groups["other"]
	all_ids -= root_id
	var/list/wings = context.generator.split_building_layout_atomic_topology_groups(context.program_contract.topology_graph, all_ids, 2)
	var/w = context.local_width()
	var/h = context.local_height()
	var/cx = round((w + 1) / 2)
	if(length(root_id))
		add_seed_zone(context, region, "wing_transition_room", "transition", cx - 3, 2, cx + 3, h - 1, list(root_id), 240, orientation_variant)
	add_seed_zone(context, region, "wing_a", "wing", 2, 2, cx - 1, h - 1, wings[1], 140, orientation_variant)
	add_seed_zone(context, region, "wing_b", "wing", cx + 1, 2, w - 1, h - 1, wings[2], 140, orientation_variant)
	region.add_route_hint("wing_transition", "line", cx, 2, cx, h - 1, list())
	return TRUE

/datum/world_edit_building_layout_family_policy/open_bay_perimeter
	id = "open_bay_perimeter"

/datum/world_edit_building_layout_family_policy/open_bay_perimeter/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["open_bay_min_percent"] = 35
	result["open_bay_max_percent"] = 60
	result["perimeter_services"] = TRUE
	return result

/datum/world_edit_building_layout_family_policy/open_bay_perimeter/can_solve(datum/world_edit_building_layout_context/context)
	if(!..())
		return FALSE
	var/open_bay_count = 0
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in context.program_contract?.functional_room_contracts)
		if(room_contract?.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
			open_bay_count++
	return open_bay_count == 1

/datum/world_edit_building_layout_family_policy/open_bay_perimeter/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/datum/world_edit_building_layout_room_plan/bay_plan = null
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		if(room_plan.spatial_kind != WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
			continue
		if(istype(bay_plan))
			return reject_candidate(candidate, "multiple_open_bay_owners")
		bay_plan = room_plan
	if(!istype(bay_plan))
		return reject_candidate(candidate, "open_bay_owner_missing")
	var/bay_owned_area = length(bay_plan.turfs)
	for(var/turf/aisle_turf as anything in candidate.owner_aisle_turfs)
		if(candidate.owner_aisle_owner_by_turf[aisle_turf] == bay_plan.id)
			bay_owned_area++
	var/list/bay_opening_lookup = list()
	for(var/datum/world_edit_building_layout_route_opening_plan/opening_plan as anything in candidate.opening_plans)
		if(!istype(opening_plan) || !(bay_plan.id in list(opening_plan.from_room, opening_plan.to_room)))
			continue
		for(var/turf/opening_turf as anything in context.generator.get_building_layout_opening_plan_turfs(opening_plan))
			if(istype(opening_turf))
				bay_opening_lookup[opening_turf] = TRUE
	bay_owned_area += length(bay_opening_lookup)
	var/useful_interior_area = context.generator.get_building_layout_useful_interior_area(context, candidate)
	var/bay_ratio = round(bay_owned_area * 100 / max(useful_interior_area, 1))
	if(bay_ratio < 35 || bay_ratio > 60)
		return reject_candidate(candidate, "open_bay_ratio:[bay_ratio]:owned=[bay_owned_area]:useful=[useful_interior_area]:openings=[length(bay_opening_lookup)]")
	if(!context.generator.building_layout_room_touches_route(candidate, bay_plan))
		return reject_candidate(candidate, "owner_aisle_missing")
	for(var/datum/world_edit_building_layout_room_plan/service_plan as anything in candidate.room_plans)
		if(service_plan == bay_plan)
			continue
		if(open_bay_room_has_perimeter_contact(context, candidate, bay_plan, service_plan))
			continue
		// A typed private child may sit directly behind its perimeter service
		// parent.  Requiring that SECURE child to touch the public route itself
		// would contradict the edge contract, so validate the pair as one
		// perimeter cluster while the generic edge validator enforces their wall.
		var/cluster_has_perimeter_contact = FALSE
		for(var/datum/world_edit_building_layout_room_connection/connection as anything in candidate.room_connections)
			if(!istype(connection) || !connection.required || connection.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
				continue
			var/other_room_id = ""
			if(connection.from_node_id == service_plan.id)
				other_room_id = connection.to_node_id
			else if(connection.to_node_id == service_plan.id)
				other_room_id = connection.from_node_id
			if(!length(other_room_id))
				continue
			var/datum/world_edit_building_layout_room_plan/other_plan = candidate.get_room_plan(other_room_id)
			if(istype(other_plan) && open_bay_room_has_perimeter_contact(context, candidate, bay_plan, other_plan))
				cluster_has_perimeter_contact = TRUE
				break
		if(!cluster_has_perimeter_contact)
			return reject_candidate(candidate, "service_not_perimeter:[service_plan.contract_id]")
	return TRUE

/datum/world_edit_building_layout_family_policy/open_bay_perimeter/proc/open_bay_room_has_perimeter_contact(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/bay_plan, datum/world_edit_building_layout_room_plan/room_plan)
	if(!istype(context) || !istype(candidate) || !istype(bay_plan) || !istype(room_plan))
		return FALSE
	for(var/turf/room_turf as anything in room_plan.turfs)
		for(var/check_dir in GLOB.cardinals)
			if(context.state.geometry.boundary_lookup[get_step(room_turf, check_dir)])
				return TRUE
	return context.generator.building_layout_room_touches_route(candidate, room_plan) || context.generator.building_layout_room_plans_share_partition(bay_plan, room_plan, 1)

/datum/world_edit_building_layout_family_policy/proc/build_open_bay_perimeter_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/w = context.local_width()
	var/h = context.local_height()
	var/open_bay_width = max(round((w - 2) * 0.67), 3)
	var/open_bay_height = max(round((h - 2) * 0.67), 3)
	var/margin_x = max(round((w + 1 - open_bay_width) / 2), 3)
	var/margin_y = max(round((h + 1 - open_bay_height) / 2), 3)
	var/list/bay_ids = list()
	var/list/perimeter_ids = list()
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in context.program_contract?.functional_room_contracts)
		if(room_contract?.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
			bay_ids += room_contract.id
		else
			perimeter_ids += room_contract.id
	var/list/root_adjacent_ids = list()
	var/root_id = length(bay_ids) ? "[bay_ids[1]]" : ""
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in context.program_contract.topology_graph.get_edges_for(root_id))
		if(!istype(edge) || !edge.required || edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
			continue
		var/other_id = edge.from_id == root_id ? edge.to_id : edge.from_id
		if(other_id in perimeter_ids)
			root_adjacent_ids |= other_id
	for(var/root_adjacent_id as anything in root_adjacent_ids)
		perimeter_ids -= root_adjacent_id
	var/list/perimeter = context.generator.split_building_layout_atomic_topology_groups(context.program_contract.topology_graph, perimeter_ids, 4)
	add_seed_zone(context, region, "named_open_bay", "open_bay", margin_x, margin_y, w - margin_x + 1, h - margin_y + 1, bay_ids, 220, orientation_variant)
	add_seed_zone(context, region, "open_bay_root_edge", "root_edge", 2, 2, w - 1, h - 1, root_adjacent_ids, 200, orientation_variant)
	add_seed_zone(context, region, "perimeter_front", "perimeter", 2, 2, w - 1, margin_y, perimeter[1], 130, orientation_variant)
	add_seed_zone(context, region, "perimeter_right", "perimeter", w - margin_x + 1, 2, w - 1, h - 1, perimeter[2], 130, orientation_variant)
	add_seed_zone(context, region, "perimeter_back", "perimeter", 2, h - margin_y + 1, w - 1, h - 1, perimeter[3], 130, orientation_variant)
	add_seed_zone(context, region, "perimeter_left", "perimeter", 2, 2, margin_x, h - 1, perimeter[4], 130, orientation_variant)
	return TRUE

/datum/world_edit_building_layout_family_policy/secure_core
	id = "secure_core"

/datum/world_edit_building_layout_family_policy/secure_core/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["secure_core"] = TRUE
	result["controlled_transition"] = TRUE
	return result

/datum/world_edit_building_layout_family_policy/secure_core/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/choke_count = 0
	var/secure_room_count = 0
	var/controlled_edge_count = 0
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in context.program_contract?.room_contracts)
		if(room_contract?.spatial_kind == WORLD_EDIT_BUILDING_SPACE_CHOKE)
			choke_count++
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan.contract_id)
		if(!istype(room_contract) || room_contract.privacy_class != "secure")
			continue
		secure_room_count++
		for(var/turf/room_turf as anything in room_plan.turfs)
			for(var/check_dir in GLOB.cardinals)
				if(context.state.geometry.boundary_lookup[get_step(room_turf, check_dir)])
					return reject_candidate(candidate, "secure_core_touches_entry_shell:[room_plan.contract_id]")
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph?.edges)
		if(edge?.required && edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_SECURE && edge.opening_policy == WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR)
			controlled_edge_count++
	if(!secure_room_count || choke_count != 1 || controlled_edge_count != 1)
		return reject_candidate(candidate, "controlled_threshold:[secure_room_count]:[choke_count]:[controlled_edge_count]")
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/build_secure_core_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/list/groups = context.generator.build_building_layout_family_groups(context)
	var/w = context.local_width()
	var/h = context.local_height()
	var/cx = round((w + 1) / 2)
	var/cy = round((h + 1) / 2)
	var/list/core_ids = groups["secure"]
	if(!length(core_ids))
		core_ids = groups["root"].Copy()
	var/list/ring_ids = groups["root"] + groups["public"] + groups["nested"] + groups["other"]
	for(var/core_id as anything in core_ids)
		ring_ids -= core_id
	var/list/ring = context.generator.split_building_layout_ids_round_robin(ring_ids, 4)
	add_seed_zone(context, region, "secure_core", "secure", cx - 3, cy - 3, cx + 3, cy + 3, core_ids, 230, orientation_variant)
	add_seed_zone(context, region, "secure_ring_front", "ring", 2, 2, w - 1, cy - 3, ring[1], 120, orientation_variant)
	add_seed_zone(context, region, "secure_ring_right", "ring", cx + 3, 2, w - 1, h - 1, ring[2], 120, orientation_variant)
	add_seed_zone(context, region, "secure_ring_back", "ring", 2, cy + 3, w - 1, h - 1, ring[3], 120, orientation_variant)
	add_seed_zone(context, region, "secure_ring_left", "ring", 2, 2, cx - 3, h - 1, ring[4], 120, orientation_variant)
	return TRUE

/datum/world_edit_building_layout_family_policy/nested_service
	id = "nested_service"

/datum/world_edit_building_layout_family_policy/nested_service/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["requires_nested_parent_child"] = TRUE
	result["child_after_parent"] = TRUE
	return result

/datum/world_edit_building_layout_family_policy/nested_service/can_solve(datum/world_edit_building_layout_context/context)
	if(!..())
		return FALSE
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in context.program_contract?.topology_graph?.edges)
		if(istype(edge) && edge.required && edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
			return TRUE
	return FALSE

/datum/world_edit_building_layout_family_policy/nested_service/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/nested_count = 0
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in candidate.topology_graph?.edges)
		if(!istype(edge) || !edge.required || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		var/datum/world_edit_building_layout_topology_node/from_node = candidate.topology_graph.get_node(edge.from_id)
		var/datum/world_edit_building_layout_topology_node/to_node = candidate.topology_graph.get_node(edge.to_id)
		var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
		var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
		var/datum/world_edit_building_layout_room_plan/child_plan = candidate.get_room_plan(child_id)
		var/datum/world_edit_building_layout_room_plan/parent_plan = candidate.get_room_plan(parent_id)
		if(!istype(child_plan) || !istype(parent_plan) || child_plan.x1 <= parent_plan.x1 || child_plan.y1 <= parent_plan.y1 || child_plan.x2 >= parent_plan.x2 || child_plan.y2 >= parent_plan.y2)
			return reject_candidate(candidate, "containment:[parent_id]:[child_id]")
		if(context.generator.count_building_layout_openings_between(candidate, parent_id, child_id) != 1)
			return reject_candidate(candidate, "controlled_opening:[parent_id]:[child_id]")
		nested_count++
	if(!nested_count)
		return reject_candidate(candidate, "nested_edge_missing")
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/build_nested_service_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/list/groups = context.generator.build_building_layout_family_groups(context)
	var/w = context.local_width()
	var/h = context.local_height()
	var/list/parent_ids = groups["root"] + groups["public"]
	var/list/service_ids = groups["nested"] + groups["secure"]
	var/list/other_ids = groups["other"]
	add_seed_zone(context, region, "nested_parent", "parent", 2, 2, round(w * 0.7), h - 1, parent_ids, 210, orientation_variant)
	add_seed_zone(context, region, "nested_child", "child", round(w * 0.55), round(h * 0.35), w - 1, h - 1, service_ids, 190, orientation_variant)
	add_seed_zone(context, region, "nested_support", "support", round(w * 0.55), 2, w - 1, round(h * 0.45), other_ids, 120, orientation_variant)
	return TRUE

/datum/world_edit_building_layout_family_policy/compound_cells
	id = "compound_cells"

/datum/world_edit_building_layout_family_policy/compound_cells/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["compound_pods"] = 4
	result["courtyard"] = TRUE
	return result

/datum/world_edit_building_layout_family_policy/compound_cells/can_solve(datum/world_edit_building_layout_context/context)
	return ..() && !context.generator.is_building_compact_or_micro_state(context.state)

/datum/world_edit_building_layout_family_policy/compound_cells/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/cx = (context.state.geometry.bounds["min_x"] + context.state.geometry.bounds["max_x"]) / 2
	var/cy = (context.state.geometry.bounds["min_y"] + context.state.geometry.bounds["max_y"]) / 2
	var/list/occupied_pods = list()
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/room_cx = (room_plan.x1 + room_plan.x2) / 2
		var/room_cy = (room_plan.y1 + room_plan.y2) / 2
		var/pod_id = "[room_cx < cx ? "west" : "east"]_[room_cy < cy ? "south" : "north"]"
		occupied_pods[pod_id] = TRUE
	if(length(occupied_pods) < 3)
		return reject_candidate(candidate, "pod_count:[length(occupied_pods)]")
	var/has_courtyard = FALSE
	for(var/datum/world_edit_building_layout_route_hint/route_hint as anything in candidate.region_candidate?.route_hints)
		if(route_hint?.id == "compound_courtyard")
			has_courtyard = TRUE
			break
	if(!has_courtyard || !length(candidate.route_turfs))
		return reject_candidate(candidate, "courtyard_missing")
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/build_compound_cells_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/list/groups = context.generator.build_building_layout_family_groups(context)
	var/list/all_ids = groups["root"] + groups["public"] + groups["secure"] + groups["nested"] + groups["other"]
	var/list/pods = context.generator.split_building_layout_ids_round_robin(all_ids, 4)
	var/w = context.local_width()
	var/h = context.local_height()
	var/cx = round((w + 1) / 2)
	var/cy = round((h + 1) / 2)
	add_seed_zone(context, region, "pod_nw", "pod", 2, 2, cx - 1, cy - 1, pods[1], 150, orientation_variant)
	add_seed_zone(context, region, "pod_ne", "pod", cx + 1, 2, w - 1, cy - 1, pods[2], 150, orientation_variant)
	add_seed_zone(context, region, "pod_se", "pod", cx + 1, cy + 1, w - 1, h - 1, pods[3], 150, orientation_variant)
	add_seed_zone(context, region, "pod_sw", "pod", 2, cy + 1, cx - 1, h - 1, pods[4], 150, orientation_variant)
	region.add_route_hint("compound_courtyard", "cross", cx, cy, cx, cy, list())
	return TRUE

/datum/world_edit_building_layout_family_policy/axial_fallback
	id = "axial_fallback"

/datum/world_edit_building_layout_family_policy/axial_fallback/can_solve(datum/world_edit_building_layout_context/context)
	if(!..())
		return FALSE
	var/w = context.local_width()
	var/h = context.local_height()
	var/aspect = max(w, h) / max(min(w, h), 1)
	return context.generator.is_building_compact_or_micro_state(context.state) || min(w, h) <= 11 || aspect >= 1.7

/datum/world_edit_building_layout_family_policy/axial_fallback/build_constraints(datum/world_edit_building_layout_context/context, orientation_variant = 0)
	var/list/result = ..()
	result["axial_fallback_only"] = TRUE
	result["route_policy"] = WORLD_EDIT_BUILDING_ROUTE_POLICY_AXIAL
	return result

/datum/world_edit_building_layout_family_policy/axial_fallback/hard_validate(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!..())
		return FALSE
	var/has_axial_policy = FALSE
	for(var/datum/world_edit_building_layout_route_hint/route_hint as anything in candidate.region_candidate?.route_hints)
		if(route_hint?.id == "axial_route" && route_hint.kind == "line")
			has_axial_policy = TRUE
			break
	if(!has_axial_policy)
		return reject_candidate(candidate, "trunk_policy_missing")
	var/list/x_counts = list()
	var/list/y_counts = list()
	var/max_axis_count = 0
	for(var/turf/route_turf as anything in candidate.route_turfs)
		var/x_key = "[route_turf.x]"
		var/y_key = "[route_turf.y]"
		x_counts[x_key] = (x_counts[x_key] || 0) + 1
		y_counts[y_key] = (y_counts[y_key] || 0) + 1
		max_axis_count = max(max_axis_count, x_counts[x_key], y_counts[y_key])
	if(max_axis_count < max(round(length(candidate.route_turfs) * 0.5), 2))
		return reject_candidate(candidate, "trunk_missing")
	return TRUE

/datum/world_edit_building_layout_family_policy/proc/build_axial_fallback_seed_regions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_region_candidate/region, orientation_variant = 0)
	var/list/groups = context.generator.build_building_layout_family_groups(context)
	var/list/all_ids = groups["root"] + groups["public"] + groups["secure"] + groups["nested"] + groups["other"]
	var/list/bands = context.generator.split_building_layout_ids_round_robin(all_ids, 2)
	var/w = context.local_width()
	var/h = context.local_height()
	var/cx = round((w + 1) / 2)
	add_seed_zone(context, region, "axial_a", "axial", 2, 2, cx - 1, h - 1, bands[1], 100, orientation_variant)
	add_seed_zone(context, region, "axial_b", "axial", cx + 1, 2, w - 1, h - 1, bands[2], 100, orientation_variant)
	region.add_route_hint("axial_route", "line", cx, 2, cx, h - 1, list())
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_family_policy(family_id)
	switch("[family_id]")
		if("hub_spoke") return new /datum/world_edit_building_layout_family_policy/hub_spoke()
		if("split_wing") return new /datum/world_edit_building_layout_family_policy/split_wing()
		if("open_bay_perimeter") return new /datum/world_edit_building_layout_family_policy/open_bay_perimeter()
		if("secure_core") return new /datum/world_edit_building_layout_family_policy/secure_core()
		if("nested_service") return new /datum/world_edit_building_layout_family_policy/nested_service()
		if("compound_cells") return new /datum/world_edit_building_layout_family_policy/compound_cells()
		if("axial_fallback") return new /datum/world_edit_building_layout_family_policy/axial_fallback()
	return null
