/datum/world_edit_generator/building_layout/proc/solve_building_layout_compositions(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	if(!istype(context) || !istype(candidate))
		return FALSE
	context.scene_budget = new
	context.scene_budget.limits = islist(context.program_contract?.global_scene_slot_limits) ? context.program_contract.global_scene_slot_limits.Copy() : list()
	context.scene_budget.minimums = islist(context.program_contract?.global_scene_slot_minimums) ? context.program_contract.global_scene_slot_minimums.Copy() : list()
	var/list/remaining_required_slots = build_building_layout_remaining_required_slot_demand(context, candidate)
	for(var/datum/world_edit_building_layout_room_plan/reset_room as anything in candidate.room_plans)
		if(!istype(reset_room))
			continue
		reset_room.scene_plan = null
		reset_room.scene_kind = ""
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in get_layout_scene_room_solve_order(context, candidate))
		if(!istype(room_plan) || room_plan.role == "route")
			continue
		var/datum/world_edit_building_layout_composition_contract/composition = context.program_contract?.get_composition_contract(room_plan.contract_id)
		var/datum/world_edit_building_layout_room_contract/room_contract = context.program_contract?.get_room_contract(room_plan.contract_id)
		if(!istype(composition))
			if(istype(room_contract) && room_contract.required)
				candidate.errors += "composition.contract_missing:[room_plan.id]"
			continue
		var/datum/world_edit_building_layout_scene_plan/scene_plan = build_building_layout_atomic_composition(context, candidate, room_plan, composition, remaining_required_slots)
		if(!istype(scene_plan))
			candidate.errors += "composition.required_group_unplaceable:[room_plan.id]"
			continue
		if(!building_layout_scene_budget_allows(context, scene_plan))
			candidate.errors += "composition.module_budget_exceeded:[room_plan.id]"
			continue
		room_plan.scene_plan = scene_plan
		room_plan.scene_kind = scene_plan.scene_kind
		register_building_layout_scene_budget_use(context, scene_plan)
	var/list/missing_minimums = context.scene_budget?.missing_minimums()
	for(var/scene_slot as anything in missing_minimums)
		candidate.errors += "composition.global_minimum_missing:[scene_slot]=[missing_minimums[scene_slot]]"
	return !length(candidate.errors)

/datum/world_edit_generator/building_layout/proc/build_building_layout_atomic_composition(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_composition_contract/composition, list/remaining_required_slots)
	var/datum/world_edit_building_layout_scene_contract/scene_contract = context.program_contract?.get_scene_contract(composition?.scene_contract_id)
	if(!istype(scene_contract) || !istype(room_plan) || !istype(candidate))
		return null
	var/datum/world_edit_building_layout_scene_plan/scene_plan = new
	scene_plan.id = "[room_plan.id]_[scene_contract.id]"
	scene_plan.room_id = room_plan.id
	scene_plan.room_contract_id = room_plan.contract_id
	scene_plan.scene_contract_id = scene_contract.id
	scene_plan.scene_kind = scene_contract.scene_kind
	scene_plan.primary = scene_contract.primary
	scene_plan.score = 100 + room_plan.area()
	var/list/occupied_lookup = list()
	reserve_building_layout_composition_negative_space(candidate, room_plan, scene_plan, occupied_lookup, composition.min_negative_space_tiles)
	var/module_budget = max(1, min(WORLD_EDIT_BUILDING_MAX_MODULE_CANDIDATES, round(room_plan.area() / 2)))
	for(var/datum/world_edit_building_cluster_spec/required_group as anything in sort_building_layout_composition_groups(composition.required_groups))
		if(!istype(required_group))
			continue
		var/remaining_budget = module_budget - length(scene_plan.members)
		if(remaining_budget <= 0)
			candidate.errors += "composition.room_module_budget_exhausted:[room_plan.id]:[required_group.id]"
			return null
		if(!building_layout_required_group_budget_available(context, required_group))
			var/slot_key = building_layout_global_scene_slot_key(required_group.category)
			candidate.errors += "composition.global_module_budget_exhausted:[room_plan.id]:[required_group.id]:[slot_key]=[context.scene_budget?.used[slot_key] || 0]/[context.scene_budget?.limits[slot_key] || 0]"
			return null
		var/member_start = length(scene_plan.members)
		var/placed = add_building_layout_cluster_module(context, candidate, room_plan, scene_plan, required_group, occupied_lookup, remaining_budget)
		var/group_satisfied = building_layout_composition_group_satisfied(scene_plan, required_group, member_start)
		var/wall_axis_valid = building_layout_wall_group_has_contiguous_axis(scene_plan, required_group, member_start)
		if(placed <= 0 || !group_satisfied || !wall_axis_valid)
			candidate.errors += "composition.group_atomic_reject:[room_plan.id]:[required_group.id]:placed=[placed]:members=[length(scene_plan.members) - member_start]:area=[room_plan.area()]"
			context.state?.add_stage_report("layout_composition_group", "failed", "required group was not placed atomically", list(
				"candidate_id" = candidate.id,
				"room_id" = room_plan.id,
				"group_id" = required_group.id,
				"placed" = placed,
				"group_satisfied" = group_satisfied,
				"wall_axis_valid" = wall_axis_valid,
				"recipe_validation" = get_building_layout_composition_recipe_validation(scene_plan, required_group, member_start),
				"member_start" = member_start,
				"member_count" = length(scene_plan.members),
			))
			return null
		consume_building_layout_required_slot_demand(context, room_plan, required_group, remaining_required_slots)
	for(var/datum/world_edit_building_cluster_spec/optional_group as anything in composition.optional_groups)
		if(!istype(optional_group))
			continue
		var/remaining_budget = module_budget - length(scene_plan.members)
		if(remaining_budget <= 0)
			break
		if(!building_layout_optional_group_preserves_required_budget(context, room_plan, optional_group, remaining_required_slots))
			continue
		var/member_start = length(scene_plan.members)
		var/list/occupied_before = occupied_lookup.Copy()
		var/list/slot_counts_before = scene_plan.scene_slot_counts.Copy()
		var/placed = add_building_layout_cluster_module(context, candidate, room_plan, scene_plan, optional_group, occupied_lookup, remaining_budget)
		if(placed <= 0 || !building_layout_wall_group_has_contiguous_axis(scene_plan, optional_group, member_start))
			rollback_building_layout_composition_group(scene_plan, occupied_lookup, occupied_before, slot_counts_before, member_start)
	if(!length(scene_plan.members))
		report_building_layout_composition_reject(context, candidate, room_plan, "no_members", scene_plan)
		return null
	if(!building_layout_scene_members_inside_room(room_plan, scene_plan))
		report_building_layout_composition_reject(context, candidate, room_plan, "member_outside_or_duplicate", scene_plan)
		return null
	if(!building_layout_scene_members_clear_candidate_paths(candidate, scene_plan))
		report_building_layout_composition_reject(context, candidate, room_plan, "member_blocks_route_or_opening", scene_plan)
		return null
	if(!finalize_building_layout_composition_hierarchy(scene_plan))
		report_building_layout_composition_reject(context, candidate, room_plan, "focus_missing", scene_plan)
		return null
	if(!building_layout_scene_slots_within_contract(scene_plan, scene_contract))
		report_building_layout_composition_reject(context, candidate, room_plan, "scene_slot_limit", scene_plan)
		return null
	if(!validate_building_layout_scene_composition(context, candidate, room_plan, scene_contract, scene_plan))
		report_building_layout_composition_reject(context, candidate, room_plan, "composition_validation", scene_plan)
		return null
	return scene_plan

/datum/world_edit_generator/building_layout/proc/build_building_layout_remaining_required_slot_demand(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate)
	var/list/result = list()
	if(!istype(context?.state) || !istype(candidate))
		return result
	for(var/datum/world_edit_building_layout_room_plan/room_plan as anything in candidate.room_plans)
		var/datum/world_edit_building_layout_composition_contract/composition = context.program_contract?.get_composition_contract(room_plan?.contract_id)
		for(var/datum/world_edit_building_cluster_spec/required_group as anything in composition?.required_groups)
			accumulate_building_layout_group_member_demand(context, room_plan, required_group, result, 1)
	return result

/datum/world_edit_generator/building_layout/proc/consume_building_layout_required_slot_demand(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/group, list/remaining_required_slots)
	accumulate_building_layout_group_member_demand(context, room_plan, group, remaining_required_slots, -1)

/datum/world_edit_generator/building_layout/proc/accumulate_building_layout_group_member_demand(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/group, list/target, multiplier = 1)
	if(!istype(context?.state) || !istype(room_plan) || !istype(group) || !islist(target))
		return FALSE
	var/datum/world_edit_building_zone_spec/zone_spec = context.state.semantic_plan?.get_zone_spec(room_plan.zone_id)
	var/list/module_footprint = get_building_layout_required_group_module_footprint(context.state, zone_spec, group)
	if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
		return FALSE
	var/list/member_counts = module_footprint["member_counts"]
	for(var/category as anything in member_counts)
		target["[category]"] = max((target["[category]"] || 0) + round(text2num("[member_counts[category]]") || 0) * multiplier, 0)
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_optional_group_preserves_required_budget(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_cluster_spec/group, list/remaining_required_slots)
	if(!istype(context?.state) || !istype(room_plan) || !istype(group) || !islist(remaining_required_slots))
		return FALSE
	var/list/optional_demand = list()
	if(!accumulate_building_layout_group_member_demand(context, room_plan, group, optional_demand, 1))
		return FALSE
	for(var/category as anything in optional_demand)
		// Required recipes own their authored category capacity until every required
		// room using that category has been composed. An optional curated module may
		// place a larger recipe than its minimum footprint, so a numeric minimum-only
		// projection is not a safe reservation while required demand remains.
		if(round(text2num("[remaining_required_slots[category]]") || 0) > 0)
			return FALSE
		var/limit = round(text2num("[context.scene_budget?.limits[category]]") || 0)
		var/projected = round(text2num("[context.scene_budget?.used[category]]") || 0) + round(text2num("[remaining_required_slots[category]]") || 0) + round(text2num("[optional_demand[category]]") || 0)
		if(limit > 0 && projected > limit)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/sort_building_layout_composition_groups(list/groups)
	var/list/result = list()
	for(var/datum/world_edit_building_cluster_spec/group as anything in groups)
		if(!istype(group))
			continue
		var/group_weight = max(group.min_count, 1) * 10 + max(group.chair_count, 0) * 12 + (group.wall_required ? 5 : 0)
		var/inserted = FALSE
		for(var/index in 1 to length(result))
			var/datum/world_edit_building_cluster_spec/existing = result[index]
			var/existing_weight = max(existing.min_count, 1) * 10 + max(existing.chair_count, 0) * 12 + (existing.wall_required ? 5 : 0)
			if(group_weight <= existing_weight)
				continue
			result.Insert(index, group)
			inserted = TRUE
			break
		if(!inserted)
			result += group
	return result

/datum/world_edit_generator/building_layout/proc/finalize_building_layout_composition_hierarchy(datum/world_edit_building_layout_scene_plan/scene_plan)
	if(!istype(scene_plan) || !length(scene_plan.members))
		return FALSE
	var/turf/focus_turf = null
	for(var/list/member as anything in scene_plan.members)
		if(!islist(member) || !GLOB.world_edit_helpers.parse_bool(member["major"]))
			continue
		focus_turf = member["turf"]
		break
	if(!istype(focus_turf))
		var/list/first_member = scene_plan.members[1]
		focus_turf = first_member?["turf"]
	if(!istype(focus_turf))
		return FALSE
	scene_plan.primary_anchors["focus"] = focus_turf
	scene_plan.secondary_anchors.Cut()
	scene_plan.detail_anchors.Cut()
	for(var/list/member as anything in scene_plan.members)
		var/turf/member_turf = member?["turf"]
		if(!istype(member_turf) || member_turf == focus_turf)
			continue
		if(GLOB.world_edit_helpers.parse_bool(member["major"]))
			scene_plan.secondary_anchors += member_turf
		else
			scene_plan.detail_anchors += member_turf
	return TRUE

/datum/world_edit_generator/building_layout/proc/report_building_layout_composition_reject(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, reason, datum/world_edit_building_layout_scene_plan/scene_plan)
	context?.state?.add_stage_report("layout_composition", "failed", "[reason]", list(
		"candidate_id" = candidate?.id,
		"room_id" = room_plan?.id,
		"room_area" = room_plan?.area() || 0,
		"member_count" = length(scene_plan?.members),
		"negative_space_count" = length(scene_plan?.negative_space_turfs),
		"occupied_count" = length(scene_plan?.occupied_turfs),
	))

/datum/world_edit_generator/building_layout/proc/reserve_building_layout_composition_negative_space(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, datum/world_edit_building_layout_scene_plan/scene_plan, list/occupied_lookup, minimum_tiles = 1)
	if(!istype(candidate) || !istype(room_plan) || !istype(scene_plan) || !islist(occupied_lookup))
		return
	// A room-owned aisle is an authored circulation layer inside the functional
	// room. Reserve it before modules so furnishing cannot consume the aisle and
	// later pretend the circulation contract was satisfied by object clearance.
	for(var/datum/world_edit_building_layout_route_overlay/overlay as anything in candidate.route_overlays)
		if(!istype(overlay) || overlay.owner_room_id != room_plan.id)
			continue
		for(var/turf/overlay_turf as anything in overlay.turfs)
			if(room_plan.turf_lookup[overlay_turf])
				add_building_layout_negative_space_turf(scene_plan, occupied_lookup, overlay_turf)
		for(var/turf/approach_turf as anything in overlay.approach_turfs)
			if(room_plan.turf_lookup[approach_turf])
				add_building_layout_negative_space_turf(scene_plan, occupied_lookup, approach_turf)
	var/center_x = round((room_plan.x1 + room_plan.x2) / 2)
	var/center_y = round((room_plan.y1 + room_plan.y2) / 2)
	for(var/turf/door_turf as anything in get_building_layout_room_door_turfs(candidate, room_plan.id))
		var/turf/inside_turf = get_building_layout_room_door_inside_turf(candidate, room_plan, door_turf)
		if(!istype(inside_turf) || !room_plan.turf_lookup[inside_turf])
			continue
		add_building_layout_negative_space_turf(scene_plan, occupied_lookup, inside_turf)
		var/turf/lane_turf = inside_turf
		for(var/lane_index in 2 to max(minimum_tiles, 1))
			var/lane_dir = abs(center_x - lane_turf.x) >= abs(center_y - lane_turf.y) ? (center_x >= lane_turf.x ? EAST : WEST) : (center_y >= lane_turf.y ? NORTH : SOUTH)
			lane_turf = get_step(lane_turf, lane_dir)
			if(!room_plan.turf_lookup[lane_turf])
				break
			add_building_layout_negative_space_turf(scene_plan, occupied_lookup, lane_turf)
	if(!length(scene_plan.negative_space_turfs) && length(room_plan.turfs))
		var/turf/fallback_clearance = room_plan.turfs[1]
		add_building_layout_negative_space_turf(scene_plan, occupied_lookup, fallback_clearance)

/datum/world_edit_generator/building_layout/proc/add_building_layout_negative_space_turf(datum/world_edit_building_layout_scene_plan/scene_plan, list/occupied_lookup, turf/clearance_turf)
	if(!istype(scene_plan) || !islist(occupied_lookup) || !istype(clearance_turf) || occupied_lookup[clearance_turf])
		return
	scene_plan.negative_space_turfs += clearance_turf
	scene_plan.no_furniture_lookup[clearance_turf] = TRUE
	occupied_lookup[clearance_turf] = TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_room_door_turfs(datum/world_edit_building_layout_candidate/candidate, room_id)
	var/list/door_turfs = list()
	if(!istype(candidate))
		return door_turfs
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan?.opening_turf) || door_plan.kind == "main_exit")
			continue
		if(door_plan.from_room == room_id || door_plan.to_room == room_id)
			door_turfs += get_building_layout_opening_plan_turfs(door_plan)
	return door_turfs

/datum/world_edit_generator/building_layout/proc/get_building_layout_room_door_inside_turf(datum/world_edit_building_layout_candidate/candidate, datum/world_edit_building_layout_room_plan/room_plan, turf/door_turf)
	if(!istype(candidate) || !istype(room_plan) || !istype(door_turf))
		return null
	for(var/datum/world_edit_building_layout_route_opening_plan/door_plan as anything in candidate.opening_plans)
		if(!istype(door_plan) || !(door_turf in get_building_layout_opening_plan_turfs(door_plan)))
			continue
		var/turf/front_turf = get_step(door_turf, door_plan.dir)
		if(room_plan.has_turf(front_turf))
			return front_turf
		var/turf/back_turf = get_step(door_turf, turn(door_plan.dir, 180))
		if(room_plan.has_turf(back_turf))
			return back_turf
	return null

/datum/world_edit_generator/building_layout/proc/build_building_layout_room_internal_path(datum/world_edit_building_layout_room_plan/room_plan, turf/start_turf, turf/focus_turf, list/occupied_lookup = null)
	var/list/path_x_first = build_building_layout_room_internal_path_order(room_plan, start_turf, focus_turf, TRUE)
	var/list/path_y_first = build_building_layout_room_internal_path_order(room_plan, start_turf, focus_turf, FALSE)
	if(!islist(occupied_lookup))
		return length(path_x_first) <= length(path_y_first) ? path_x_first : path_y_first
	if(istype(room_plan) && istype(start_turf) && istype(focus_turf))
		var/list/open = list(start_turf)
		var/list/seen = list()
		seen[start_turf] = TRUE
		var/list/previous = list()
		var/turf/found = null
		var/expansions = 0
		while(length(open) && expansions < min(max(room_plan.area() * 4, 1), WORLD_EDIT_BUILDING_MAX_ROUTE_EXPANSIONS))
			var/turf/current = open[1]
			open.Cut(1, 2)
			if(current == focus_turf)
				found = current
				break
			for(var/check_dir in GLOB.cardinals)
				var/turf/nearby = get_step(current, check_dir)
				if(!istype(nearby) || seen[nearby] || !room_plan.has_turf(nearby) || (occupied_lookup[nearby] && nearby != focus_turf))
					continue
				seen[nearby] = TRUE
				previous[nearby] = current
				open += nearby
			expansions++
		if(istype(found))
			var/list/bfs_path = list()
			var/turf/path_turf = found
			while(istype(path_turf))
				bfs_path.Insert(1, path_turf)
				if(path_turf == start_turf)
					break
				path_turf = previous[path_turf]
			return bfs_path
	var/x_blocks = count_building_layout_path_occupied(path_x_first, occupied_lookup, focus_turf)
	var/y_blocks = count_building_layout_path_occupied(path_y_first, occupied_lookup, focus_turf)
	return x_blocks <= y_blocks ? path_x_first : path_y_first

/datum/world_edit_generator/building_layout/proc/build_building_layout_room_internal_path_order(datum/world_edit_building_layout_room_plan/room_plan, turf/start_turf, turf/focus_turf, x_first = TRUE)
	var/list/path = list()
	if(!istype(room_plan) || !istype(start_turf) || !istype(focus_turf) || !room_plan.has_turf(start_turf) || !room_plan.has_turf(focus_turf))
		return path
	var/current_x = start_turf.x
	var/current_y = start_turf.y
	var/z_level = start_turf.z
	if(x_first)
		while(current_x != focus_turf.x)
			current_x += current_x < focus_turf.x ? 1 : -1
			var/turf/check_turf = locate(current_x, current_y, z_level)
			if(room_plan.has_turf(check_turf))
				path += check_turf
		while(current_y != focus_turf.y)
			current_y += current_y < focus_turf.y ? 1 : -1
			var/turf/check_turf = locate(current_x, current_y, z_level)
			if(room_plan.has_turf(check_turf))
				path += check_turf
	else
		while(current_y != focus_turf.y)
			current_y += current_y < focus_turf.y ? 1 : -1
			var/turf/check_turf = locate(current_x, current_y, z_level)
			if(room_plan.has_turf(check_turf))
				path += check_turf
		while(current_x != focus_turf.x)
			current_x += current_x < focus_turf.x ? 1 : -1
			var/turf/check_turf = locate(current_x, current_y, z_level)
			if(room_plan.has_turf(check_turf))
				path += check_turf
	return path

/datum/world_edit_generator/building_layout/proc/count_building_layout_path_occupied(list/path, list/occupied_lookup, turf/focus_turf)
	var/count = 0
	for(var/turf/path_turf as anything in path)
		if(istype(path_turf) && path_turf != focus_turf && occupied_lookup[path_turf])
			count++
	return count

/datum/world_edit_generator/building_layout/proc/building_layout_required_group_budget_available(datum/world_edit_building_layout_context/context, datum/world_edit_building_cluster_spec/group)
	if(!istype(context?.scene_budget) || !istype(group))
		return TRUE
	if(!context.scene_budget.can_use(building_layout_global_scene_slot_key(group.category), max(group.min_count, 1)))
		return FALSE
	if(group.pattern == "table_cluster" && group.chair_count > 0 && !context.scene_budget.can_use("chair", group.chair_count))
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/building_layout_composition_group_satisfied(datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_cluster_spec/group, member_start)
	if(!istype(scene_plan) || !istype(group))
		return FALSE
	var/list/module_instances = list()
	for(var/index in member_start + 1 to length(scene_plan.members))
		var/list/member = scene_plan.members[index]
		if(!islist(member))
			continue
		var/datum/world_edit_building_cluster_spec/member_group = member["cluster_spec"]
		if(!building_layout_composition_groups_match(member_group, group))
			continue
		var/module_instance_id = "[member["placement_module_instance_id"]]"
		if(!length(module_instance_id))
			return FALSE
		if(!islist(module_instances[module_instance_id]))
			module_instances[module_instance_id] = list()
		var/list/instance_members = module_instances[module_instance_id]
		instance_members += list(member)
	var/credit = 0
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	for(var/module_instance_id as anything in module_instances)
		var/list/instance_members = module_instances[module_instance_id]
		var/list/first_member = instance_members?[1]
		var/datum/world_edit_building_placement_module/module = catalog.get_module(first_member?["placement_module_id"])
		if(!building_layout_curated_module_belongs_to_group(catalog, module, group) || !building_layout_curated_module_instance_complete(module, instance_members))
			return FALSE
		credit += get_building_layout_curated_module_group_credit(module, group)
	return length(module_instances) > 0 && credit >= max(group.min_count, 1)

/datum/world_edit_generator/building_layout/proc/building_layout_composition_groups_match(datum/world_edit_building_cluster_spec/member_group, datum/world_edit_building_cluster_spec/required_group)
	if(!istype(member_group) || !istype(required_group))
		return FALSE
	return member_group == required_group || member_group.id == required_group.id || (length(member_group.count_cluster_id) && member_group.count_cluster_id == required_group.id) || (length(required_group.count_cluster_id) && required_group.count_cluster_id == member_group.id)

/datum/world_edit_generator/building_layout/proc/building_layout_curated_module_belongs_to_group(datum/world_edit_building_placement_module_catalog/catalog, datum/world_edit_building_placement_module/module, datum/world_edit_building_cluster_spec/group)
	if(!istype(catalog) || !istype(module) || !istype(group) || !module.curated || !length(module.curated_recipe_id))
		return FALSE
	for(var/datum/world_edit_building_placement_module/group_module as anything in catalog.get_for_cluster(group))
		if(istype(group_module) && group_module.curated && group_module.id == module.id)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_layout_curated_module_instance_complete(datum/world_edit_building_placement_module/module, list/instance_members)
	return !length(get_building_layout_curated_module_instance_error(module, instance_members))

/datum/world_edit_generator/building_layout/proc/get_building_layout_curated_module_instance_error(datum/world_edit_building_placement_module/module, list/instance_members)
	if(!istype(module))
		return "module_missing"
	if(!module.curated || !length(module.curated_recipe_id))
		return "recipe_not_curated"
	if(!islist(instance_members) || length(instance_members) != length(module.member_specs))
		return "member_count:[length(instance_members)]/[length(module.member_specs)]"
	var/list/first_member = instance_members[1]
	var/turf/origin = first_member?["placement_module_origin"]
	var/module_dir = first_member?["placement_module_dir"]
	if(!istype(origin) || !(module_dir in GLOB.cardinals))
		return "origin_or_dir"
	var/list/matched_member_indexes = list()
	for(var/list/expected_member as anything in module.member_specs)
		if(!islist(expected_member))
			return "expected_member_invalid"
		var/turf/expected_turf = get_template_offset_turf(origin, module_dir, expected_member["dx"], expected_member["dy"])
		var/matched_index = 0
		for(var/member_index in 1 to length(instance_members))
			if(matched_member_indexes[member_index])
				continue
			var/list/actual_member = instance_members[member_index]
			if(!islist(actual_member) || actual_member["turf"] != expected_turf || "[actual_member["slot"]]" != "[expected_member["slot"]]" || "[actual_member["category"]]" != "[expected_member["category"]]")
				continue
			if("[actual_member["placement_module_recipe_id"]]" != module.curated_recipe_id || round(text2num("[actual_member["placement_module_member_count"]]") || 0) != length(module.member_specs))
				return "recipe_or_declared_count"
			if(!(actual_member["front_dir"] in GLOB.cardinals) || !(actual_member["interaction_dir"] in GLOB.cardinals))
				return "front_or_interaction_dir"
			matched_index = member_index
			break
		if(!matched_index)
			return "member_geometry:[expected_member["slot"]]:[expected_member["category"]]:[expected_member["dx"]],[expected_member["dy"]]"
		matched_member_indexes[matched_index] = TRUE
	return length(matched_member_indexes) == length(module.member_specs) ? "" : "member_match_count"

/datum/world_edit_generator/building_layout/proc/get_building_layout_composition_recipe_validation(datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_cluster_spec/group, member_start)
	var/list/result = list()
	if(!istype(scene_plan) || !istype(group))
		return list("invalid_group")
	var/list/module_instances = list()
	for(var/index in member_start + 1 to length(scene_plan.members))
		var/list/member = scene_plan.members[index]
		if(!islist(member) || !building_layout_composition_groups_match(member["cluster_spec"], group))
			continue
		var/module_instance_id = "[member["placement_module_instance_id"]]"
		if(!islist(module_instances[module_instance_id]))
			module_instances[module_instance_id] = list()
		var/list/instance_members = module_instances[module_instance_id]
		instance_members += list(member)
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	for(var/module_instance_id as anything in module_instances)
		var/list/instance_members = module_instances[module_instance_id]
		var/list/first_member = instance_members?[1]
		var/datum/world_edit_building_placement_module/module = catalog.get_module(first_member?["placement_module_id"])
		var/error = get_building_layout_curated_module_instance_error(module, instance_members)
		result += "[module_instance_id]:[module?.id || "missing"]:[length(error) ? error : "ok"]:credit=[get_building_layout_curated_module_group_credit(module, group)]"
	if(!length(result))
		result += "no_module_instances"
	return result

/datum/world_edit_generator/building_layout/proc/building_layout_wall_group_has_contiguous_axis(datum/world_edit_building_layout_scene_plan/scene_plan, datum/world_edit_building_cluster_spec/group, member_start)
	if(!istype(scene_plan) || !istype(group) || !group.wall_required)
		return TRUE
	var/list/wall_members = list()
	for(var/index in member_start + 1 to length(scene_plan.members))
		var/list/member = scene_plan.members[index]
		if(islist(member) && GLOB.world_edit_helpers.parse_bool(member["wall_mounted"]))
			wall_members += list(member)
	if(length(wall_members) <= 1)
		return TRUE
	var/list/first_member = wall_members[1]
	var/turf/first_turf = first_member["turf"]
	var/first_dir = first_member["wall_dir"]
	var/first_front_dir = first_member["front_dir"]
	if(!(first_dir in GLOB.cardinals) || !(first_front_dir in GLOB.cardinals))
		return FALSE
	var/min_axis = (first_dir in list(NORTH, SOUTH)) ? first_turf.x : first_turf.y
	var/max_axis = min_axis
	for(var/list/member as anything in wall_members)
		var/turf/member_turf = member["turf"]
		if(!istype(member_turf) || member["wall_dir"] != first_dir || member["front_dir"] != first_front_dir)
			return FALSE
		if(first_dir in list(NORTH, SOUTH))
			if(member_turf.y != first_turf.y)
				return FALSE
			min_axis = min(min_axis, member_turf.x)
			max_axis = max(max_axis, member_turf.x)
		else
			if(member_turf.x != first_turf.x)
				return FALSE
			min_axis = min(min_axis, member_turf.y)
			max_axis = max(max_axis, member_turf.y)
	return max_axis - min_axis + 1 <= length(wall_members)

/datum/world_edit_generator/building_layout/proc/rollback_building_layout_composition_group(datum/world_edit_building_layout_scene_plan/scene_plan, list/occupied_lookup, list/occupied_before, list/slot_counts_before, member_start)
	if(!istype(scene_plan) || !islist(occupied_lookup) || !islist(occupied_before) || !islist(slot_counts_before))
		return
	scene_plan.members.Cut(member_start + 1)
	scene_plan.occupied_turfs.Cut()
	for(var/list/member as anything in scene_plan.members)
		var/turf/member_turf = member?["turf"]
		if(istype(member_turf))
			scene_plan.occupied_turfs += member_turf
	occupied_lookup.Cut()
	for(var/turf/occupied_turf as anything in occupied_before)
		occupied_lookup[occupied_turf] = occupied_before[occupied_turf]
	scene_plan.scene_slot_counts = slot_counts_before.Copy()
