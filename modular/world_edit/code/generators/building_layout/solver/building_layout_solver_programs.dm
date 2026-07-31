#define WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES 24
#define WORLD_EDIT_BUILDING_MAX_ROOM_CANDIDATES 128
#define WORLD_EDIT_BUILDING_MAX_ROUTE_EXPANSIONS 4096
#define WORLD_EDIT_BUILDING_MAX_MODULE_ANCHORS 64
#define WORLD_EDIT_BUILDING_MAX_MODULE_CANDIDATES 32

/datum/world_edit_generator/building_layout/proc/build_building_layout_program_contract(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.archetype) || !istype(state.semantic_plan))
		return null
	var/datum/world_edit_building_layout_program_contract/program = new
	program.id = state.archetype.id
	program.allowed_layout_patterns = state.archetype.layout_families.Copy()
	program.max_layout_candidates = WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES
	var/list/selected_zone_specs = select_building_layout_room_zone_specs(state)
	if(!islist(selected_zone_specs) || !length(selected_zone_specs))
		state.add_error("Program contract '[program.id]' has no active room zones.")
		return null
	var/target_room_count = round(text2num("[state.config["target_room_count"]]") || 0)
	if(target_room_count <= 0)
		for(var/datum/world_edit_building_zone_spec/default_zone as anything in selected_zone_specs)
			if(istype(default_zone) && default_zone.counts_toward_target)
				target_room_count++
	var/required_zone_count = 0
	for(var/datum/world_edit_building_zone_spec/required_zone as anything in selected_zone_specs)
		if(istype(required_zone) && required_zone.required && required_zone.counts_toward_target)
			required_zone_count++
	if(target_room_count < required_zone_count)
		state.add_error("program.target_room_count_unreachable: requested [target_room_count], required [required_zone_count].")
		return null
	program.target_room_count = target_room_count
	program.target_functional_room_count = target_room_count
	var/list/room_zone_demands = build_building_layout_room_zone_demands(state, selected_zone_specs, target_room_count)
	state.add_stage_report("layout_program_demands", "ok", null, list(
		"target_room_count" = target_room_count,
		"zone_ids" = build_building_layout_zone_demand_report(room_zone_demands),
		"repeat_budget_rejections" = islist(state.config["layout_repeat_budget_rejections"]) ? state.config["layout_repeat_budget_rejections"].Copy() : list(),
	))
	var/functional_demand_count = 0
	for(var/datum/world_edit_building_zone_spec/demand_zone as anything in room_zone_demands)
		if(istype(demand_zone) && demand_zone.counts_toward_target)
			functional_demand_count++
	if(functional_demand_count != target_room_count)
		state.add_error("program.target_room_count_unreachable: requested [target_room_count], allocated [functional_demand_count] functional spaces.")
		return null
	var/list/zone_instance_counts = list()
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in room_zone_demands)
		if(!istype(zone_spec))
			continue
		var/instance_index = round(text2num("[zone_instance_counts[zone_spec.id]]") || 0) + 1
		zone_instance_counts[zone_spec.id] = instance_index
		var/datum/world_edit_building_layout_room_contract/room_contract = compile_building_layout_room_contract(state, zone_spec, instance_index, target_room_count)
		if(istype(room_contract))
			program.add_room_contract(room_contract)
	if(length(program.functional_room_contracts) != target_room_count)
		state.add_error("program.target_room_count_unreachable: compiled [length(program.functional_room_contracts)] of [target_room_count] functional room contracts.")
		return null
	for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in program.circulation_contracts)
		if(!istype(circulation_contract))
			continue
		if(circulation_contract.circulation_kind == WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE)
			var/datum/world_edit_building_layout_room_contract/owner_contract = program.get_room_contract(circulation_contract.circulation_owner_room_id)
			if(!istype(owner_contract) || !owner_contract.counts_toward_target)
				state.add_error("program.room_owned_aisle_owner_unresolved:[circulation_contract.id]:[circulation_contract.circulation_owner_room_id]")
				return null
		else if(circulation_contract.circulation_kind != WORLD_EDIT_BUILDING_CIRCULATION_ENCLOSED_ROUTE)
			state.add_error("program.circulation_kind_invalid:[circulation_contract.id]:[circulation_contract.circulation_kind]")
			return null
		program.min_circulation_area += circulation_contract.min_area
	for(var/category as anything in state.semantic_plan.object_budgets)
		if(!is_building_infrastructure_category(category))
			program.global_scene_slot_limits["[category]"] = state.semantic_plan.object_budgets[category]
	// Table recipes can author secondary members (chairs) which are not their
	// own semantic cluster and are therefore absent from the normalized plan.
	// Preserve those explicit archetype budgets for hard module accounting.
	for(var/category as anything in state.archetype.object_budgets)
		if(!is_building_infrastructure_category(category))
			program.global_scene_slot_limits["[category]"] = max(program.global_scene_slot_limits["[category]"] || 0, state.archetype.object_budgets[category] || 0)
	if(!compile_building_layout_scene_contracts(state, program))
		return null
	if(!apply_building_layout_composition_footprints(state, program))
		return null
	// Connection frontage is derived from authored composition footprints, so
	// typed edges must be compiled after the scene/module contract is known.
	compile_building_layout_connection_contracts(state, program)
	program.topology_graph = compile_building_layout_topology_graph(state, program)
	if(!istype(program.topology_graph) || !length(program.topology_graph.nodes) || length(program.topology_graph.compile_errors))
		state.add_error("Program contract '[program.id]' has no functional topology graph.")
		return null
	apply_building_layout_connection_approach_footprints(state, program)
	if(!apply_building_layout_nested_containment_footprints(program))
		return null
	if(!validate_building_layout_required_composition_preflight(state, program))
		return null
	return program

/datum/world_edit_generator/building_layout/proc/apply_building_layout_connection_approach_footprints(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	if(!istype(state) || !istype(program))
		return FALSE
	for(var/datum/world_edit_building_layout_room_contract/room as anything in program.functional_room_contracts)
		if(!istype(room))
			continue
		var/opening_count = 0
		var/has_controlled_opening = FALSE
		var/has_nested_controlled_opening = FALSE
		for(var/datum/world_edit_building_layout_connection_contract/connection as anything in program.connection_contracts)
			if(!istype(connection) || !connection.required || connection.opening_policy == WORLD_EDIT_BUILDING_OPENING_NONE)
				continue
			if(connection.from_node_id == room.id || connection.to_node_id == room.id)
				opening_count++
				if(connection.opening_policy in list(WORLD_EDIT_BUILDING_OPENING_DOOR, WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR))
					has_controlled_opening = TRUE
					if(connection.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED)
						has_nested_controlled_opening = TRUE
		if(has_controlled_opening && room.min_wall_frontage > 0 && room.min_composition_long_side <= 3)
			// A three-cell room has no independent shouldered threshold and wall
			// frontage. Add one longitudinal cell for the end-biased opening.
			room.min_height = max(room.min_height, 4)
			room.min_composition_long_side = max(room.min_composition_long_side, 4)
			room.min_area = max(room.min_area, room.min_width * room.min_height)
		if(has_nested_controlled_opening && room.min_wall_frontage > 1)
			// A controlled threshold and an authored wall module are independent
			// obligations. A NESTED child owns only its edge-specific canonical
			// partitions, so a multi-cell frontage needs a real perpendicular lane.
			room.min_width = max(room.min_width, 4)
			room.min_height = max(room.min_height, 4)
			room.min_composition_short_side = max(room.min_composition_short_side, 4)
			room.min_composition_long_side = max(room.min_composition_long_side, 4)
			room.min_area = max(room.min_area, room.min_width * room.min_height)
		if(opening_count > 1)
			// Composition footprint already owns one approach lane. Every additional
			// typed opening needs an independent inside tile plus one bypass tile; a
			// 3x3 room with two doors is therefore not accepted as a nominally valid
			// shell that can never host its curated compact recipe.
			room.min_area += (opening_count - 1) * 2
		room.preferred_area = max(room.preferred_area, room.min_area)
		var/public_multiplier = (room.role in list("hub", "public", "public_med", "staging") || room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY) ? 1.40 : 1.25
		room.max_area = max(room.max_area, round(room.preferred_area * public_multiplier), room.min_area)
	return TRUE

/datum/world_edit_generator/building_layout/proc/select_building_layout_room_zone_specs(datum/world_edit_building_layout_state/state)
	var/list/required_zones = list()
	var/list/optional_zones = list()
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in state.semantic_plan?.zone_specs)
		if(!istype(zone_spec))
			continue
		if(zone_spec.required)
			required_zones += zone_spec
		else
			optional_zones += zone_spec
	return required_zones + optional_zones

/datum/world_edit_generator/building_layout/proc/build_building_layout_room_zone_demands(datum/world_edit_building_layout_state/state, list/zone_specs, target_room_count)
	state.config["layout_repeat_budget_rejections"] = list()
	var/list/demands = list()
	var/list/functional_demands = list()
	var/list/optional = list()
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in zone_specs)
		if(!istype(zone_spec))
			continue
		if(!zone_spec.counts_toward_target)
			if(zone_spec.required)
				demands += zone_spec
			continue
		if(zone_spec.required)
			functional_demands += zone_spec
		else
			optional += zone_spec
	for(var/datum/world_edit_building_zone_spec/optional_zone as anything in optional)
		if(length(functional_demands) >= target_room_count)
			break
		functional_demands += optional_zone
	var/guard = 0
	while(length(functional_demands) < target_room_count && guard < 24)
		guard++
		var/datum/world_edit_building_zone_spec/repeat_zone = select_building_layout_repeat_zone(state, zone_specs, functional_demands)
		if(!istype(repeat_zone))
			break
		functional_demands += repeat_zone
	return functional_demands + demands

/datum/world_edit_generator/building_layout/proc/build_building_layout_zone_demand_report(list/demands)
	var/list/result = list()
	var/list/instance_counts = list()
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in demands)
		if(!istype(zone_spec))
			continue
		instance_counts[zone_spec.id] = round(text2num("[instance_counts[zone_spec.id]]") || 0) + 1
		result += "[zone_spec.id]#[instance_counts[zone_spec.id]]"
	return result

/datum/world_edit_generator/building_layout/proc/select_building_layout_repeat_zone(datum/world_edit_building_layout_state/state, list/zone_specs, list/current_demands)
	var/datum/world_edit_building_zone_spec/best = null
	var/best_score = -999999999
	var/list/instance_counts = list()
	for(var/datum/world_edit_building_zone_spec/current as anything in current_demands)
		if(istype(current))
			instance_counts[current.id] = round(text2num("[instance_counts[current.id]]") || 0) + 1
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in zone_specs)
		if(!istype(zone_spec) || !zone_spec.counts_toward_target)
			continue
		// The primary signature zone is unique program identity. Exact target-room
		// expansion must add support/private/service instances, not clone the
		// program centerpiece into a second fake primary room.
		if(zone_spec.id == state.archetype?.primary_zone)
			continue
		if(!building_layout_repeat_zone_fits_required_composition_budget(state, zone_specs, current_demands, zone_spec))
			var/list/rejections = state.config["layout_repeat_budget_rejections"]
			if(islist(rejections))
				rejections += "[length(current_demands) + 1]:[zone_spec.id]"
			continue
		var/score = zone_spec.required ? 100 : 50
		score += zone_spec.min_area * 4
		switch(zone_spec.role)
			if("private", "storage", "service", "support", "secure")
				score += 180
			if("hub", "public", "public_med", "staging")
				score += 100
		for(var/datum/world_edit_building_region_spec/region_spec as anything in state.semantic_plan?.region_specs)
			if(istype(region_spec) && region_spec.zone_id == zone_spec.id)
				score += 35
		score -= round(text2num("[instance_counts[zone_spec.id]]") || 0) * 90
		if(!istype(best) || score > best_score)
			best = zone_spec
			best_score = score
	return best

/datum/world_edit_generator/building_layout/proc/building_layout_repeat_zone_fits_required_composition_budget(datum/world_edit_building_layout_state/state, list/all_zone_specs, list/current_demands, datum/world_edit_building_zone_spec/repeat_zone)
	if(!istype(state) || !islist(all_zone_specs) || !islist(current_demands) || !istype(repeat_zone))
		return FALSE
	var/list/projected_demands = current_demands.Copy()
	projected_demands += repeat_zone
	var/list/zone_instance_counts = list()
	var/list/zone_specs_by_id = list()
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in all_zone_specs)
		if(istype(zone_spec) && !zone_spec.counts_toward_target && zone_spec.required)
			zone_specs_by_id[zone_spec.id] = zone_spec
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in projected_demands)
		if(!istype(zone_spec) || !zone_spec.counts_toward_target)
			continue
		zone_instance_counts[zone_spec.id] = round(text2num("[zone_instance_counts[zone_spec.id]]") || 0) + 1
		zone_specs_by_id[zone_spec.id] = zone_spec
	var/list/category_demand = list()
	var/list/repeated_identity_by_zone = list()
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan?.cluster_specs)
		if(!istype(cluster_spec) || cluster_spec.compact_substitute_only || is_building_infrastructure_category(cluster_spec.category))
			continue
		var/datum/world_edit_building_zone_spec/owner_zone = select_building_layout_demand_owner_zone(cluster_spec, zone_specs_by_id)
		if(!istype(owner_zone))
			continue
		if(cluster_spec.required || cluster_spec.signature_required)
			if(!accumulate_building_layout_required_group_category_demand(state, owner_zone, cluster_spec, category_demand))
				return FALSE
		var/zone_instance_count = round(text2num("[zone_instance_counts[owner_zone.id]]") || 0)
		if(zone_instance_count <= 1 || !cluster_spec.signature_required)
			continue
		if(!islist(repeated_identity_by_zone[owner_zone.id]))
			repeated_identity_by_zone[owner_zone.id] = list()
		repeated_identity_by_zone[owner_zone.id] += cluster_spec
	for(var/zone_id as anything in zone_instance_counts)
		var/extra_instances = max(round(text2num("[zone_instance_counts[zone_id]]") || 0) - 1, 0)
		if(extra_instances <= 0)
			continue
		var/datum/world_edit_building_zone_spec/zone_spec = zone_specs_by_id[zone_id]
		var/list/identity_specs = repeated_identity_by_zone[zone_id]
		var/datum/world_edit_building_cluster_spec/best_optional = null
		for(var/datum/world_edit_building_cluster_spec/optional_spec as anything in state.semantic_plan?.cluster_specs)
			if(!istype(optional_spec) || optional_spec.required || optional_spec.compact_substitute_only || is_building_infrastructure_category(optional_spec.category))
				continue
			if(get_building_layout_cluster_zone_anchor_score(optional_spec, zone_id) <= 0 && optional_spec.optional_zone_id != zone_id)
				continue
			if(!istype(best_optional) || optional_spec.priority > best_optional.priority)
				best_optional = optional_spec
		for(var/instance_index in 1 to extra_instances)
			var/instance_has_identity = FALSE
			for(var/datum/world_edit_building_cluster_spec/identity_spec as anything in identity_specs)
				var/datum/world_edit_building_cluster_spec/repeated_spec = build_building_layout_repeated_group_spec(state, identity_spec)
				if(!istype(repeated_spec) || !building_layout_required_group_fits_projected_category_demand(state, zone_spec, repeated_spec, category_demand))
					continue
				accumulate_building_layout_required_group_category_demand(state, zone_spec, repeated_spec, category_demand)
				instance_has_identity = TRUE
			if(instance_has_identity)
				continue
			var/datum/world_edit_building_cluster_spec/optional_identity = build_building_layout_repeated_group_spec(state, best_optional)
			if(!istype(optional_identity) || !building_layout_required_group_fits_projected_category_demand(state, zone_spec, optional_identity, category_demand))
				return FALSE
			accumulate_building_layout_required_group_category_demand(state, zone_spec, optional_identity, category_demand)
	for(var/category as anything in category_demand)
		var/limit = round(text2num("[state.semantic_plan?.object_budgets[category]]") || 0)
		if(limit > 0 && round(text2num("[category_demand[category]]") || 0) > limit)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/select_building_layout_demand_owner_zone(datum/world_edit_building_cluster_spec/cluster_spec, list/zone_specs_by_id)
	var/datum/world_edit_building_zone_spec/best = null
	var/best_score = -999999999
	for(var/zone_id as anything in zone_specs_by_id)
		var/datum/world_edit_building_zone_spec/zone_spec = zone_specs_by_id[zone_id]
		if(!istype(zone_spec))
			continue
		var/anchor_score = get_building_layout_cluster_zone_anchor_score(cluster_spec, zone_spec.id)
		if(anchor_score <= 0 && cluster_spec.optional_zone_id != zone_spec.id)
			continue
		var/score = anchor_score * 1000 + zone_spec.min_area * 10
		if(cluster_spec.optional_zone_id == zone_spec.id)
			score += 100000000
		if(zone_spec.role in list("hub", "public", "public_med", "staging", "work"))
			score += 500
		if(!istype(best) || score > best_score)
			best = zone_spec
			best_score = score
	return best

/datum/world_edit_generator/building_layout/proc/build_building_layout_repeated_group_spec(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/source_spec)
	if(!istype(state) || !istype(source_spec))
		return null
	var/datum/world_edit_building_cluster_spec/effective_spec = source_spec
	if(length(source_spec.compact_substitute_id))
		var/datum/world_edit_building_cluster_spec/compact_spec = state.semantic_plan?.get_cluster_spec_by_id(source_spec.compact_substitute_id)
		if(istype(compact_spec) && compact_spec.compact_substitute_only)
			effective_spec = compact_spec
	var/datum/world_edit_building_cluster_spec/repeated_spec = effective_spec.clone()
	repeated_spec.required = TRUE
	repeated_spec.min_count = repeated_spec.slot == "bed" ? 2 : 1
	repeated_spec.max_count = max(repeated_spec.min_count, min(repeated_spec.max_count, 2))
	return repeated_spec

/datum/world_edit_generator/building_layout/proc/building_layout_required_group_fits_projected_category_demand(datum/world_edit_building_layout_state/state, datum/world_edit_building_zone_spec/zone_spec, datum/world_edit_building_cluster_spec/group, list/category_demand)
	if(!istype(state) || !istype(zone_spec) || !istype(group) || !islist(category_demand))
		return FALSE
	var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
	if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
		return FALSE
	var/list/member_counts = module_footprint["member_counts"]
	for(var/category as anything in member_counts)
		var/limit = round(text2num("[state.semantic_plan?.object_budgets[category]]") || 0)
		var/projected = round(text2num("[category_demand[category]]") || 0) + round(text2num("[member_counts[category]]") || 0)
		if(limit > 0 && projected > limit)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/accumulate_building_layout_required_group_category_demand(datum/world_edit_building_layout_state/state, datum/world_edit_building_zone_spec/zone_spec, datum/world_edit_building_cluster_spec/group, list/category_demand)
	if(!istype(state) || !istype(zone_spec) || !istype(group) || !islist(category_demand))
		return FALSE
	var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
	if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
		return FALSE
	var/list/member_counts = module_footprint["member_counts"]
	for(var/category as anything in member_counts)
		category_demand["[category]"] = (category_demand["[category]"] || 0) + round(text2num("[member_counts[category]]") || 0)
	return TRUE

/datum/world_edit_generator/building_layout/proc/compile_building_layout_room_contract(datum/world_edit_building_layout_state/state, datum/world_edit_building_zone_spec/zone_spec, instance_index, target_room_count)
	if(!istype(state) || !istype(zone_spec))
		return null
	var/min_area = max(zone_spec.min_area, (zone_spec.role in list("hub", "public", "public_med")) ? 9 : ((zone_spec.role in list("entry", "route", "choke")) ? 2 : 4))
	var/preferred_area = min_area
	var/public_multiplier = (zone_spec.role in list("hub", "public", "public_med", "staging") || zone_spec.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY) ? 1.40 : 1.25
	var/max_area = max(preferred_area, round(preferred_area * public_multiplier))
	var/min_width = max(2, min(round(sqrt(min_area)), 8))
	var/min_height = max(2, round(min_area / max(min_width, 1)))
	var/requires_controlled_route_access = zone_spec.privacy_class != "public"
	if(requires_controlled_route_access)
		min_width = max(min_width, 3)
		min_height = max(min_height, 3)
	min_area = max(min_area, min_width * min_height)
	preferred_area = max(preferred_area, min_area)
	max_area = max(max_area, min_area)
	if(requires_controlled_route_access)
		min_area = max(min_area, 9)
	if(zone_spec.role in list("hub", "public", "public_med"))
		min_width = max(min_width, 3)
		min_height = max(min_height, 3)
	var/max_width = max(min_width, min(12, round(state.geometry.bounds["width"]) - 2))
	var/max_height = max(min_height, min(12, round(state.geometry.bounds["height"]) - 2))
	var/room_id = instance_index > 1 ? "[zone_spec.id]_[instance_index]" : zone_spec.id
	var/datum/world_edit_building_layout_room_contract/room = new(room_id, zone_spec.role, zone_spec.id, zone_spec.required || zone_spec.counts_toward_target || instance_index > 1, min_area, preferred_area, max_area, min_width, min_height, max_width, max_height)
	room.instance_index = instance_index
	room.spatial_kind = zone_spec.spatial_kind
	// OPEN_BAY is an authored, singular topology owner. Demand expansion may add
	// another composition-bearing copy of the same zone, but that copy is a
	// compact functional cell; promoting it to a second bay would invent a second
	// aisle owner and make open_bay_perimeter semantically ambiguous.
	if(instance_index > 1 && room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
		room.spatial_kind = WORLD_EDIT_BUILDING_SPACE_FUNCTIONAL_ROOM
	room.counts_toward_target = zone_spec.counts_toward_target
	room.min_capacity_units = zone_spec.min_capacity_units
	room.capacity_kind = zone_spec.capacity_kind
	room.circulation_kind = zone_spec.circulation_kind
	room.circulation_owner_room_id = zone_spec.circulation_owner_room_id
	room.circulation_min_width = max(zone_spec.circulation_min_width, 1)
	room.privacy_class = length("[zone_spec.privacy_class]") ? zone_spec.privacy_class : "semi_private"
	room.must_touch_route = zone_spec.must_touch_route
	room.max_aspect = (zone_spec.role in list("route", "staging")) ? 3.5 : 2.4
	room.target_aspect = (zone_spec.role in list("storage", "service")) ? 1.6 : 1.25
	room.anchor_tags = zone_spec.anchor_tags.Copy()
	room.window_policy = zone_spec.window_allowed ? "desired" : "forbidden"
	room.exterior_window_policy = room.window_policy
	configure_building_layout_partition_policy(room)
	room.required_scene_kinds = list()
	room.allowed_scene_kinds = list()
	return room

/datum/world_edit_generator/building_layout/proc/get_building_layout_room_composition_footprint_contract(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_room_contract/room, datum/world_edit_building_layout_composition_contract/composition)
	var/list/result = list(
		"valid" = TRUE,
		"area" = 0,
		"min_short_side" = 0,
		"min_long_side" = 0,
		"wall_frontage" = 0,
		"requires_bypass" = FALSE,
		"module_ids" = list(),
		"missing_groups" = list(),
	)
	if(!istype(state) || !istype(room) || !istype(composition))
		result["valid"] = FALSE
		return result
	var/required_area = 0
	var/occupied_area = 0
	var/max_clearance_area = 0
	var/max_short_side = 0
	var/max_long_side = 0
	var/max_wall_frontage = 0
	var/requires_bypass = FALSE
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(room.zone_id)
	for(var/datum/world_edit_building_cluster_spec/group as anything in composition.required_groups)
		if(!istype(group) || is_building_infrastructure_category(group.category))
			continue
		var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
		if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
			result["valid"] = FALSE
			result["missing_groups"] += group.id
			continue
		var/module_area = round(text2num("[module_footprint["area"]]") || 0)
		var/module_occupied_area = round(text2num("[module_footprint["occupied_area"]]") || 0)
		occupied_area += module_occupied_area
		max_clearance_area = max(max_clearance_area, max(module_area - module_occupied_area, 0))
		max_short_side = max(max_short_side, round(text2num("[module_footprint["short_side"]]") || 0))
		max_long_side = max(max_long_side, round(text2num("[module_footprint["long_side"]]") || 0))
		max_wall_frontage = max(max_wall_frontage, round(text2num("[module_footprint["wall_frontage"]]") || 0))
		requires_bypass = requires_bypass || GLOB.world_edit_helpers.parse_bool(module_footprint["requires_bypass"])
		result["module_ids"] += module_footprint["module_id"]
	required_area = occupied_area + max_clearance_area
	if(required_area > 0)
		// One door-to-focus approach and one negative-space tile are room-level
		// obligations; authored module clearance masks account for the per-module
		// interaction/front/service lanes. Exact coexistence with the selected
		// opening is checked against the authored recipe before materialization.
		required_area += max(2, max_short_side) + 1
		max_short_side = max(max_short_side, 3)
		max_long_side = max(max_long_side, 3)
		if(requires_bypass)
			// Keep the authored transverse module span and add door-cone depth on
			// its long axis. Widening the short axis still left a 3-deep room where
			// every exact table orientation intersected the controlled threshold.
			max_long_side += 2
	if(max_wall_frontage > 0)
		// Wall frontage and the controlled threshold are separate authored
		// obligations. They may use perpendicular canonical segments; summing them
		// into one wall run overstates the room envelope and contradicts the exact
		// composition/opening feasibility gate below the allocator.
		max_short_side = max(max_short_side, 3)
		// The wall module may use a perpendicular segment, but its axis still needs
		// two cells of longitudinal approach/negative space somewhere in the room.
		// This is a room dimension, not a claim that module and door share one wall.
		max_long_side = max(max_long_side, max_wall_frontage + 2, max(room.max_route_opening_width, 1) + 2)
		required_area = max(required_area, max_short_side * max_long_side)
	result["area"] = required_area
	result["min_short_side"] = max_short_side
	result["min_long_side"] = max_long_side
	result["wall_frontage"] = max_wall_frontage
	result["requires_bypass"] = requires_bypass ? TRUE : FALSE
	return result
/datum/world_edit_generator/building_layout/proc/apply_building_layout_composition_footprints(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	if(!istype(state) || !istype(program))
		return FALSE
	for(var/datum/world_edit_building_layout_room_contract/room as anything in program.room_contracts)
		var/datum/world_edit_building_layout_composition_contract/composition = program.get_composition_contract(room?.id)
		if(!istype(room) || !istype(composition))
			continue
		var/list/footprint = get_building_layout_room_composition_footprint_contract(state, room, composition)
		if(!GLOB.world_edit_helpers.parse_bool(footprint["valid"]))
			state.add_error("program.required_composition_module_missing:[room.id]:[jointext(footprint["missing_groups"], ",")]")
			return FALSE
		var/required_area = round(text2num("[footprint["area"]]") || 0)
		if(required_area <= 0)
			continue
		var/min_short_side = max(2, round(text2num("[footprint["min_short_side"]]") || 0))
		var/min_long_side = max(2, round(text2num("[footprint["min_long_side"]]") || 0))
		var/wall_frontage = max(round(text2num("[footprint["wall_frontage"]]") || 0), 0)
		if(room.privacy_class != "public")
			min_short_side = max(min_short_side, 3)
			min_long_side = max(min_long_side, 3)
		room.min_width = max(room.min_width, min_short_side)
		room.min_height = max(room.min_height, min_long_side)
		room.min_composition_short_side = max(room.min_composition_short_side, min_short_side)
		room.min_composition_long_side = max(room.min_composition_long_side, min_long_side)
		room.min_wall_frontage = max(room.min_wall_frontage, wall_frontage)
		room.min_area = max(room.min_area, required_area, room.min_width * room.min_height, min_short_side * max(min_short_side, min_long_side))
		room.preferred_area = max(room.preferred_area, room.min_area)
		var/public_multiplier = (room.role in list("hub", "public", "public_med", "staging") || room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY) ? 1.40 : 1.25
		room.max_area = max(room.max_area, round(room.preferred_area * public_multiplier), room.min_area)
		if(room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
			// OPEN_BAY is an explicit topology capability.  Its family policy owns
			// the 35-60% target, so retain enough contract headroom for that policy
			// without forcing non-open-bay families to consume it.
			room.max_area = max(room.max_area, round(length(state.geometry.interior) * 0.60))
		room.max_width = max(room.max_width, room.min_width)
		room.max_height = max(room.max_height, room.min_height)
	return TRUE

/datum/world_edit_generator/building_layout/proc/apply_building_layout_nested_containment_footprints(datum/world_edit_building_layout_program_contract/program)
	if(!istype(program?.topology_graph))
		return FALSE
	var/list/children_by_parent = list()
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in program.topology_graph.edges)
		if(!istype(edge) || !edge.required || edge.edge_kind != WORLD_EDIT_BUILDING_EDGE_NESTED)
			continue
		var/datum/world_edit_building_layout_topology_node/from_node = program.topology_graph.get_node(edge.from_id)
		var/datum/world_edit_building_layout_topology_node/to_node = program.topology_graph.get_node(edge.to_id)
		var/child_id = to_node?.parent_id == edge.from_id ? edge.to_id : (from_node?.parent_id == edge.to_id ? edge.from_id : edge.to_id)
		var/parent_id = child_id == edge.to_id ? edge.from_id : edge.to_id
		var/datum/world_edit_building_layout_room_contract/parent_room = program.get_room_contract(parent_id)
		var/datum/world_edit_building_layout_room_contract/child_room = program.get_room_contract(child_id)
		if(!istype(parent_room) || !istype(child_room) || !parent_room.counts_toward_target || !child_room.counts_toward_target)
			continue
		if(!islist(children_by_parent[parent_id]))
			children_by_parent[parent_id] = list()
		var/list/child_ids = children_by_parent[parent_id]
		child_ids |= child_id
	for(var/parent_id as anything in children_by_parent)
		var/datum/world_edit_building_layout_room_contract/parent_room = program.get_room_contract(parent_id)
		var/list/child_ids = children_by_parent[parent_id]
		if(!istype(parent_room) || !islist(child_ids) || !length(child_ids))
			continue
		parent_room.nested_parent_floor_min_area = parent_room.min_area
		parent_room.nested_parent_floor_min_width = parent_room.min_width
		parent_room.nested_parent_floor_min_height = parent_room.min_height
		var/child_area = 0
		var/nested_partition_area = 0
		var/list/child_short_sides = list()
		var/list/child_long_sides = list()
		for(var/child_id as anything in child_ids)
			var/datum/world_edit_building_layout_room_contract/child_room = program.get_room_contract(child_id)
			if(!istype(child_room))
				continue
			child_area += child_room.min_area
			child_short_sides += max(min(child_room.min_width, child_room.min_height), child_room.min_composition_short_side)
			child_long_sides += max(max(child_room.min_width, child_room.min_height), child_room.min_composition_long_side)
			var/nested_run = 3
			for(var/datum/world_edit_building_layout_topology_edge/edge as anything in program.topology_graph.get_edges_for(child_id))
				if(istype(edge) && edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_NESTED && (edge.from_id == parent_id || edge.to_id == parent_id))
					nested_run = max(nested_run, edge.min_shared_wall)
					break
			// Reserve the canonical controlled wall segment itself. The parent-side
			// approach remains part of the authored parent floor/interaction budget;
			// charging it again here would recreate the removed universal ring.
			nested_partition_area += nested_run
		var/columns = max(ceil(sqrt(length(child_ids))), 1)
		var/rows = max(ceil(length(child_ids) / columns), 1)
		var/list/column_widths = list()
		var/list/row_heights = list()
		for(var/child_index in 1 to length(child_short_sides))
			var/column_index = ((child_index - 1) % columns) + 1
			var/row_index = floor((child_index - 1) / columns) + 1
			// Controlled openings face the shared parent aisle: authored frontage
			// therefore runs along a row, while the short side consumes row depth.
			column_widths["[column_index]"] = max(column_widths["[column_index]"] || 0, child_long_sides[child_index])
			row_heights["[row_index]"] = max(row_heights["[row_index]"] || 0, child_short_sides[child_index])
		var/packed_width = max(columns - 1, 0)
		// Column siblings share one canonical partition. Between authored rows a
		// single common seam carries both child thresholds and the parent's own
		// route/composition approach: wall + three parent-owned aisle cells + wall.
		// This is one shared aisle, not a reservation ring around every child.
		var/packed_height = max((rows - 1) * 5, 0)
		for(var/packed_column_index in 1 to columns)
			packed_width += column_widths["[packed_column_index]"] || 0
		for(var/packed_row_index in 1 to rows)
			packed_height += row_heights["[packed_row_index]"] || 0
		var/required_envelope_area = parent_room.nested_parent_floor_min_area + child_area + nested_partition_area
		// Child packing describes the footprint inside the parent. Typed NESTED
		// containment requires the authored margin on both outer sides. The parent
		// also keeps one continuous authored-composition band; an area-only surplus
		// can be fragmented around the child grid and is not a usable module footprint.
		var/parent_floor_short = max(parent_room.min_composition_short_side, min(parent_room.nested_parent_floor_min_width, parent_room.nested_parent_floor_min_height), 1)
		var/parent_floor_long = max(parent_room.min_composition_long_side, max(parent_room.nested_parent_floor_min_width, parent_room.nested_parent_floor_min_height), parent_floor_short)
		var/required_width = max(parent_room.min_width, packed_width + 2, parent_floor_long)
		// A multi-row pack already contains the authored shared parent aisle in
		// packed_height (wall + parent floor band + wall). Add a separate band only
		// for a single row; charging both produced an impossible double reservation.
		var/external_parent_band = rows > 1 ? 0 : parent_floor_short
		var/required_height = max(parent_room.min_height, packed_height + 2 + external_parent_band)
		while(required_width * required_height < required_envelope_area)
			if(required_width <= required_height)
				required_width++
			else
				required_height++
		parent_room.min_width = required_width
		parent_room.min_height = required_height
		parent_room.nested_child_reserved_area = child_area
		parent_room.nested_partition_reserved_area = nested_partition_area
		parent_room.min_area = max(required_envelope_area, packed_width * packed_height, parent_room.min_width * parent_room.min_height)
		parent_room.preferred_area = max(parent_room.preferred_area, parent_room.min_area)
		parent_room.max_area = max(parent_room.max_area, parent_room.min_area)
		parent_room.max_width = max(parent_room.max_width, parent_room.min_width)
		parent_room.max_height = max(parent_room.max_height, parent_room.min_height)
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_required_group_module_footprint(datum/world_edit_building_layout_state/state, datum/world_edit_building_zone_spec/zone_spec, datum/world_edit_building_cluster_spec/group)
	var/list/result = list(
		"valid" = FALSE,
		"area" = 0,
		"short_side" = 0,
		"long_side" = 0,
		"wall_frontage" = 0,
		"requires_bypass" = FALSE,
		"module_id" = "",
		"required_instances" = 0,
		"occupied_area" = 0,
		"member_counts" = list(),
		"provider_slots" = list(),
	)
	if(!istype(state) || !istype(zone_spec) || !istype(group))
		return result
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	var/best_area = 999999
	for(var/datum/world_edit_building_placement_module/module as anything in catalog.get_for_cluster(group))
		if(!istype(module) || !module.curated || !length(module.curated_recipe_id) || !length(module.member_specs))
			continue
		if(length(module.allowed_programs) && !(state.archetype.id in module.allowed_programs))
			continue
		if(length(module.allowed_zone_ids) && !(zone_spec.id in module.allowed_zone_ids))
			continue
		if(length(module.allowed_room_roles) && !(zone_spec.role in module.allowed_room_roles))
			continue
		var/module_credit = get_building_layout_curated_module_group_credit(module, group)
		if(module_credit <= 0 || module_credit > max(group.max_count, max(group.min_count, 1)))
			continue
		var/list/module_measure = measure_building_layout_curated_module(module)
		if(!GLOB.world_edit_helpers.parse_bool(module_measure["valid"]))
			continue
		var/required_instances = max(1, round((max(group.min_count, 1) + module_credit - 1) / module_credit))
		var/module_area = round(text2num("[module_measure["area"]]") || 0) * required_instances
		if(module_area >= best_area)
			continue
		best_area = module_area
		var/measured_short_side = max(round(text2num("[module_measure["short_side"]]") || 0), 1)
		var/measured_long_side = max(round(text2num("[module_measure["long_side"]]") || 0), measured_short_side)
		result["valid"] = TRUE
		result["area"] = module_area
		result["short_side"] = max(measured_short_side, round((module_area + measured_long_side - 1) / measured_long_side))
		result["long_side"] = measured_long_side
		result["wall_frontage"] = module_measure["wall_frontage"]
		result["requires_bypass"] = !round(text2num("[module_measure["wall_frontage"]]") || 0) && length(module.member_specs) > 1
		result["module_id"] = module.id
		result["required_instances"] = required_instances
		result["occupied_area"] = length(module.member_specs) * required_instances
		var/list/member_counts = list()
		var/list/provider_slots = list()
		for(var/list/member as anything in module.member_specs)
			if(!islist(member))
				continue
			var/category = building_layout_global_scene_slot_key(member["category"])
			member_counts[category] = (member_counts[category] || 0) + required_instances
			provider_slots["[member["slot"]]"] = "[member["category"]]"
		result["member_counts"] = member_counts
		result["provider_slots"] = provider_slots
	return result

/datum/world_edit_generator/building_layout/proc/validate_building_layout_required_composition_preflight(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	if(!istype(state) || !istype(program))
		return FALSE
	var/list/required_category_demand = list()
	var/list/required_category_sources = list()
	var/check_required_providers = !state.config["error"]
	for(var/datum/world_edit_building_layout_composition_contract/composition as anything in program.composition_contracts)
		if(!istype(composition))
			continue
		var/datum/world_edit_building_layout_room_contract/room = program.get_room_contract(composition.room_id)
		var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(room?.zone_id)
		if(!istype(room) || !istype(zone_spec))
			state.add_error("program.required_composition_room_unresolved:[composition.id]:[composition.room_id]")
			return FALSE
		for(var/datum/world_edit_building_cluster_spec/group as anything in composition.required_groups)
			if(!istype(group))
				continue
			var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
			if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
				state.add_error("program.required_composition_module_missing:[room.id]:[group.id]")
				return FALSE
			var/list/member_counts = module_footprint["member_counts"]
			for(var/category as anything in member_counts)
				var/member_count = round(text2num("[member_counts[category]]") || 0)
				required_category_demand["[category]"] = (required_category_demand["[category]"] || 0) + member_count
				if(!islist(required_category_sources["[category]"]))
					required_category_sources["[category]"] = list()
				required_category_sources["[category]"] += "[room.id]:[group.id]=[member_count]"
			var/list/provider_slots = module_footprint["provider_slots"]
			for(var/slot as anything in provider_slots)
				if(!check_required_providers)
					continue
				var/category = "[provider_slots[slot]]"
				var/datum/world_edit_building_fixture_provider/provider = resolve_fixture_provider(state.config, slot)
				if(istype(provider) && building_fixture_provider_satisfies_slot(provider, slot, category))
					continue
				state.add_error("program.required_composition_provider_unreachable:[room.id]:[group.id]:[slot]")
				return FALSE
	for(var/category as anything in required_category_demand)
		var/demand = round(text2num("[required_category_demand[category]]") || 0)
		var/limit = round(text2num("[program.global_scene_slot_limits[category]]") || 0)
		if(limit > 0 && demand > limit)
			state.add_error("program.required_composition_budget_unreachable:[category]:[demand]/[limit]:[jointext(required_category_sources[category], ",")]")
			return FALSE
	state.config["required_composition_category_demand"] = required_category_demand
	state.config["required_composition_category_sources"] = required_category_sources
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_curated_module_group_credit(datum/world_edit_building_placement_module/module, datum/world_edit_building_cluster_spec/group)
	if(!istype(module) || !istype(group))
		return 0
	var/credit = 0
	var/chair_count = 0
	var/has_primary_slot = FALSE
	for(var/list/member as anything in module.member_specs)
		if(!islist(member))
			continue
		credit += get_building_fixture_count_credit(group, member["slot"], member["category"])
		if("[member["slot"]]" == "[group.slot]" || "[member["category"]]" == "[group.category]")
			has_primary_slot = TRUE
		if("[member["slot"]]" == "chair" || "[member["category"]]" == "chair")
			chair_count++
	if(!has_primary_slot || (group.pattern == "table_cluster" && chair_count < max(group.chair_count, 0)))
		return 0
	return credit

/datum/world_edit_generator/building_layout/proc/measure_building_layout_curated_module(datum/world_edit_building_placement_module/module)
	var/list/result = list("valid" = FALSE, "area" = 0, "short_side" = 0, "long_side" = 0, "wall_frontage" = 0)
	if(!istype(module) || !module.curated || !length(module.member_specs))
		return result
	var/min_x = 999999
	var/min_y = 999999
	var/max_x = -999999
	var/max_y = -999999
	var/member_min_x = 999999
	var/member_max_x = -999999
	for(var/list/member as anything in module.member_specs)
		if(!islist(member))
			continue
		var/member_x = round(text2num("[member["dx"]]") || 0)
		var/member_y = round(text2num("[member["dy"]]") || 0)
		min_x = min(min_x, member_x)
		min_y = min(min_y, member_y)
		max_x = max(max_x, member_x)
		max_y = max(max_y, member_y)
		member_min_x = min(member_min_x, member_x)
		member_max_x = max(member_max_x, member_x)
	for(var/offset_key as anything in get_building_module_clearance_offsets(module))
		var/list/parts = splittext("[offset_key]", ",")
		if(length(parts) < 2)
			continue
		var/offset_x = round(text2num(parts[1]) || 0)
		var/offset_y = round(text2num(parts[2]) || 0)
		min_x = min(min_x, offset_x)
		min_y = min(min_y, offset_y)
		max_x = max(max_x, offset_x)
		max_y = max(max_y, offset_y)
	if(min_x > max_x || min_y > max_y)
		return result
	var/width = max_x - min_x + 1
	var/height = max_y - min_y + 1
	// Curated wall members are authored on local X. Interaction clearance extends
	// inward on Y and must not inflate the straight partition frontage contract.
	var/wall_frontage = module.wall_required && member_min_x <= member_max_x ? member_max_x - member_min_x + 1 : 0
	var/area = width * height
	if(module.wall_required && !length(module.front_access_offsets))
		area += max(wall_frontage, 1)
	result["valid"] = TRUE
	result["area"] = area
	result["short_side"] = min(width, height)
	result["long_side"] = max(width, height)
	result["wall_frontage"] = wall_frontage
	return result

/datum/world_edit_generator/building_layout/proc/configure_building_layout_partition_policy(datum/world_edit_building_layout_room_contract/room)
	if(!istype(room))
		return
	switch(room.privacy_class)
		if("public")
			if(room.role == "entry")
				room.partition_policy = WORLD_EDIT_BUILDING_PARTITION_OPEN
				room.route_opening_kind = WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH
				room.min_route_opening_width = 2
				room.max_route_opening_width = 3
			else
				room.partition_policy = WORLD_EDIT_BUILDING_PARTITION_SOFT
				room.route_opening_kind = WORLD_EDIT_BUILDING_OPENING_ARCH
				room.min_route_opening_width = 2
				room.max_route_opening_width = 2
			room.allow_public_route_merge = TRUE
		if("private")
			room.partition_policy = WORLD_EDIT_BUILDING_PARTITION_CLOSED
			room.route_opening_kind = WORLD_EDIT_BUILDING_OPENING_DOOR
			room.window_policy = "forbidden"
			room.exterior_window_policy = "forbidden"
		if("secure")
			room.partition_policy = WORLD_EDIT_BUILDING_PARTITION_SECURE
			room.route_opening_kind = WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR
			room.window_policy = "forbidden"
			room.exterior_window_policy = "forbidden"
		else
			room.partition_policy = WORLD_EDIT_BUILDING_PARTITION_CLOSED
			room.route_opening_kind = WORLD_EDIT_BUILDING_OPENING_DOOR

/datum/world_edit_generator/building_layout/proc/compile_building_layout_connection_contracts(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	if(!istype(state) || !istype(program))
		return
	for(var/datum/world_edit_building_adjacency_rule/rule as anything in state.semantic_plan?.adjacency_rules)
		if(!istype(rule))
			continue
		var/list/from_room_ids = get_building_layout_room_ids_for_zone(program, rule.zone_a)
		var/list/to_room_ids = get_building_layout_room_ids_for_zone(program, rule.zone_b)
		if(!length(from_room_ids) || !length(to_room_ids))
			if(rule.required)
				state.add_error("topology.required_endpoint_missing:[rule.zone_a]:[rule.zone_b]")
			continue
		for(var/from_index in 1 to length(from_room_ids))
			var/from_room_id = from_room_ids[from_index]
			var/to_room_id = to_room_ids[((from_index - 1) % length(to_room_ids)) + 1]
			program.add_connection_contract(build_building_layout_connection_contract(state, program, from_room_id, to_room_id, rule.required))
		for(var/to_index in 1 to length(to_room_ids))
			var/to_room_id = to_room_ids[to_index]
			var/from_room_id = from_room_ids[((to_index - 1) % length(from_room_ids)) + 1]
			if(!building_layout_program_has_connection(program, from_room_id, to_room_id))
				program.add_connection_contract(build_building_layout_connection_contract(state, program, from_room_id, to_room_id, rule.required))
	// Nested specs are typed topology, not graph-only metadata. Promote the
	// selected child connection into the same contract consumed by allocation,
	// opening assignment, containment sizing, validation, and reporting.
	for(var/datum/world_edit_building_nested_room_spec/nested_spec as anything in state.semantic_plan?.nested_room_specs)
		if(!istype(nested_spec))
			continue
		var/list/outer_ids = get_building_layout_functional_room_ids_for_zone(program, nested_spec.outer_zone_id)
		var/list/inner_ids = get_building_layout_functional_room_ids_for_zone(program, nested_spec.inner_zone_id)
		for(var/inner_index in 1 to length(inner_ids))
			if(!length(outer_ids))
				break
			var/outer_id = outer_ids[((inner_index - 1) % length(outer_ids)) + 1]
			var/inner_id = inner_ids[inner_index]
			var/datum/world_edit_building_layout_connection_contract/connection = get_building_layout_program_connection(program, outer_id, inner_id)
			if(!istype(connection))
				connection = build_building_layout_connection_contract(state, program, outer_id, inner_id, TRUE)
				program.add_connection_contract(connection)
			connection.required = TRUE
			connection.edge_kind = WORLD_EDIT_BUILDING_EDGE_NESTED
			connection.opening_policy = WORLD_EDIT_BUILDING_OPENING_DOOR
			connection.route_policy = WORLD_EDIT_BUILDING_ROUTE_POLICY_DIRECT
			connection.min_shared_wall = max(connection.min_shared_wall, connection.min_opening_width + 2, 3)

/datum/world_edit_generator/building_layout/proc/build_building_layout_connection_contract(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program, from_node_id, to_node_id, required = TRUE)
	var/edge_kind = get_building_layout_topology_edge_kind(state, program, from_node_id, to_node_id)
	var/opening_policy = get_building_layout_topology_opening_policy(program, from_node_id, to_node_id, edge_kind)
	var/route_policy = edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE ? WORLD_EDIT_BUILDING_ROUTE_POLICY_NETWORK : WORLD_EDIT_BUILDING_ROUTE_POLICY_DIRECT
	var/datum/world_edit_building_layout_room_contract/from_contract = program?.get_room_contract(from_node_id)
	var/datum/world_edit_building_layout_room_contract/to_contract = program?.get_room_contract(to_node_id)
	var/datum/world_edit_building_layout_room_contract/functional_contract = from_contract?.counts_toward_target ? from_contract : to_contract
	var/min_opening_width = max(functional_contract?.min_route_opening_width || 1, 1)
	var/max_opening_width = max(functional_contract?.max_route_opening_width || min_opening_width, min_opening_width)
	var/min_shared_wall = 3
	if(edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE && (opening_policy in list(WORLD_EDIT_BUILDING_OPENING_ARCH, WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH, WORLD_EDIT_BUILDING_OPENING_NONE)))
		min_shared_wall = min_opening_width
	else
		// A controlled edge owns its threshold segment. Authored module frontage is
		// a separate room obligation and may use another canonical wall axis.
		min_shared_wall = max(min_shared_wall, min_opening_width + 2)
	return new /datum/world_edit_building_layout_connection_contract(from_node_id, to_node_id, required, edge_kind, opening_policy, route_policy, min_shared_wall, min_opening_width, max_opening_width)

/datum/world_edit_generator/building_layout/proc/get_building_layout_room_ids_for_zone(datum/world_edit_building_layout_program_contract/program, zone_id)
	var/list/result = list()
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in program?.room_contracts)
		if(istype(room_contract) && room_contract.zone_id == zone_id)
			result += room_contract.id
	return result

/datum/world_edit_generator/building_layout/proc/get_building_layout_functional_room_ids_for_zone(datum/world_edit_building_layout_program_contract/program, zone_id)
	var/list/result = list()
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in program?.functional_room_contracts)
		if(istype(room_contract) && room_contract.zone_id == zone_id)
			result += room_contract.id
	return result

/datum/world_edit_generator/building_layout/proc/get_building_layout_topology_edge_kind(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program, from_room_id, to_room_id)
	var/datum/world_edit_building_layout_room_contract/from_room = program?.get_room_contract(from_room_id)
	var/datum/world_edit_building_layout_room_contract/to_room = program?.get_room_contract(to_room_id)
	if(!istype(from_room) || !istype(to_room))
		return WORLD_EDIT_BUILDING_EDGE_SHARED
	var/from_is_circulation = from_room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_CIRCULATION || from_room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_CHOKE
	var/to_is_circulation = to_room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_CIRCULATION || to_room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_CHOKE
	if(from_is_circulation || to_is_circulation)
		return WORLD_EDIT_BUILDING_EDGE_ROUTE
	for(var/datum/world_edit_building_nested_room_spec/nested_spec as anything in state?.semantic_plan?.nested_room_specs)
		if(!istype(nested_spec))
			continue
		if((nested_spec.outer_zone_id == from_room.zone_id && nested_spec.inner_zone_id == to_room.zone_id) || (nested_spec.outer_zone_id == to_room.zone_id && nested_spec.inner_zone_id == from_room.zone_id))
			return WORLD_EDIT_BUILDING_EDGE_NESTED
	if(from_room.privacy_class == "secure" || to_room.privacy_class == "secure" || from_room.partition_policy == WORLD_EDIT_BUILDING_PARTITION_SECURE || to_room.partition_policy == WORLD_EDIT_BUILDING_PARTITION_SECURE)
		return WORLD_EDIT_BUILDING_EDGE_SECURE
	var/from_public = from_room.privacy_class == "public" || from_room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY
	var/to_public = to_room.privacy_class == "public" || to_room.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY
	if(from_public && to_public)
		return WORLD_EDIT_BUILDING_EDGE_OPEN_MERGE
	return WORLD_EDIT_BUILDING_EDGE_SHARED

/datum/world_edit_generator/building_layout/proc/get_building_layout_topology_opening_policy(datum/world_edit_building_layout_program_contract/program, from_node_id, to_node_id, edge_kind)
	var/datum/world_edit_building_layout_room_contract/from_contract = program?.get_room_contract(from_node_id)
	var/datum/world_edit_building_layout_room_contract/to_contract = program?.get_room_contract(to_node_id)
	if(edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE && istype(from_contract) && istype(to_contract) && !from_contract.counts_toward_target && !to_contract.counts_toward_target)
		return WORLD_EDIT_BUILDING_OPENING_NONE
	switch("[edge_kind]")
		if(WORLD_EDIT_BUILDING_EDGE_SECURE)
			return WORLD_EDIT_BUILDING_OPENING_SECURE_DOOR
		if(WORLD_EDIT_BUILDING_EDGE_OPEN_MERGE)
			return WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH
		if(WORLD_EDIT_BUILDING_EDGE_NESTED)
			return WORLD_EDIT_BUILDING_OPENING_DOOR
	var/datum/world_edit_building_layout_room_contract/functional_contract = from_contract?.counts_toward_target ? from_contract : to_contract
	if(edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE && istype(functional_contract) && length(functional_contract.route_opening_kind))
		return functional_contract.route_opening_kind
	return WORLD_EDIT_BUILDING_OPENING_DOOR

/datum/world_edit_generator/building_layout/proc/building_layout_program_has_connection(datum/world_edit_building_layout_program_contract/program, from_room_id, to_room_id)
	var/datum/world_edit_building_layout_connection_contract/connection = get_building_layout_program_connection(program, from_room_id, to_room_id)
	return istype(connection)

/datum/world_edit_generator/building_layout/proc/get_building_layout_program_connection(datum/world_edit_building_layout_program_contract/program, from_room_id, to_room_id)
	for(var/datum/world_edit_building_layout_connection_contract/connection as anything in program?.connection_contracts)
		if((connection.from_node_id == from_room_id && connection.to_node_id == to_room_id) || (connection.from_node_id == to_room_id && connection.to_node_id == from_room_id))
			return connection
	return null

/datum/world_edit_generator/building_layout/proc/compile_building_layout_topology_graph(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	if(!istype(state) || !istype(program))
		return null
	var/datum/world_edit_building_layout_topology_graph/graph = new
	for(var/datum/world_edit_building_layout_room_contract/room_contract as anything in program.room_contracts)
		if(istype(room_contract))
			graph.add_node(new /datum/world_edit_building_layout_topology_node(room_contract))
	for(var/datum/world_edit_building_layout_connection_contract/connection as anything in program.connection_contracts)
		if(!istype(connection) || !graph.get_node(connection.from_node_id) || !graph.get_node(connection.to_node_id))
			continue
		var/datum/world_edit_building_layout_topology_edge/edge = new(connection.from_node_id, connection.to_node_id, connection.edge_kind, connection.required, connection.opening_policy, connection.route_policy)
		edge.privacy_transition = connection.privacy_transition
		edge.min_shared_wall = connection.min_shared_wall
		edge.min_opening_width = connection.min_opening_width
		edge.max_opening_width = connection.max_opening_width
		graph.add_edge(edge)
	graph.root_node_id = select_building_layout_topology_root(state, program, graph)
	var/list/reachable = build_building_layout_topology_reachable_lookup(graph, graph.root_node_id)
	for(var/datum/world_edit_building_layout_topology_node/node as anything in graph.nodes)
		if(istype(node) && node.required && !reachable[node.id])
			var/error_code = "topology.required_disconnected:[node.id]"
			graph.compile_errors += error_code
			state.add_error(error_code)
	graph.required_connected = !length(graph.compile_errors)
	assign_building_layout_topology_depths(graph)
	return graph

/datum/world_edit_generator/building_layout/proc/select_building_layout_topology_root(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program, datum/world_edit_building_layout_topology_graph/graph)
	var/list/preferred_zones = list(state.archetype?.primary_zone, state.archetype?.hub_zone)
	for(var/preferred_zone as anything in preferred_zones)
		var/list/preferred_ids = get_building_layout_functional_room_ids_for_zone(program, preferred_zone)
		if(length(preferred_ids))
			return preferred_ids[1]
	for(var/datum/world_edit_building_adjacency_rule/rule as anything in state.semantic_plan?.adjacency_rules)
		if(!istype(rule) || !rule.required)
			continue
		var/datum/world_edit_building_zone_spec/zone_a = state.semantic_plan.get_zone_spec(rule.zone_a)
		var/datum/world_edit_building_zone_spec/zone_b = state.semantic_plan.get_zone_spec(rule.zone_b)
		if(istype(zone_a) && !zone_a.counts_toward_target)
			var/list/candidates_b = get_building_layout_functional_room_ids_for_zone(program, rule.zone_b)
			if(length(candidates_b))
				return candidates_b[1]
		if(istype(zone_b) && !zone_b.counts_toward_target)
			var/list/candidates_a = get_building_layout_functional_room_ids_for_zone(program, rule.zone_a)
			if(length(candidates_a))
				return candidates_a[1]
	var/datum/world_edit_building_layout_topology_node/first_node = length(graph.nodes) ? graph.nodes[1] : null
	return first_node?.id || ""

/datum/world_edit_generator/building_layout/proc/build_building_layout_topology_reachable_lookup(datum/world_edit_building_layout_topology_graph/graph, root_id)
	var/list/reachable = list()
	if(!istype(graph) || !length("[root_id]"))
		return reachable
	var/list/open = list("[root_id]")
	reachable["[root_id]"] = TRUE
	while(length(open))
		var/current_id = open[1]
		open.Cut(1, 2)
		for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(current_id))
			var/next_id = edge.from_id == current_id ? edge.to_id : edge.from_id
			if(reachable[next_id])
				continue
			reachable[next_id] = TRUE
			open += next_id
	return reachable

/datum/world_edit_generator/building_layout/proc/assign_building_layout_topology_depths(datum/world_edit_building_layout_topology_graph/graph)
	if(!istype(graph) || !length(graph.root_node_id))
		return
	var/list/open = list(graph.root_node_id)
	var/list/seen = list(graph.root_node_id = TRUE)
	while(length(open))
		var/current_id = open[1]
		open.Cut(1, 2)
		var/datum/world_edit_building_layout_topology_node/current = graph.get_node(current_id)
		for(var/datum/world_edit_building_layout_topology_edge/edge as anything in graph.get_edges_for(current_id))
			var/next_id = edge.from_id == current_id ? edge.to_id : edge.from_id
			if(seen[next_id])
				continue
			var/datum/world_edit_building_layout_topology_node/next = graph.get_node(next_id)
			if(!istype(next))
				continue
			next.parent_id = current_id
			next.depth = (current?.depth || 0) + 1
			seen[next_id] = TRUE
			open += next_id

/datum/world_edit_generator/building_layout/proc/get_building_layout_first_room_id_for_zone(datum/world_edit_building_layout_program_contract/program, zone_id)
	for(var/datum/world_edit_building_layout_room_contract/room as anything in program?.room_contracts)
		if(istype(room) && room.zone_id == "[zone_id]")
			return room.id
	return ""

/datum/world_edit_generator/building_layout/proc/compile_building_layout_scene_contracts(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	if(!istype(state) || !istype(program))
		return FALSE
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan?.cluster_specs)
		if(!istype(cluster_spec) || cluster_spec.compact_substitute_only || is_building_infrastructure_category(cluster_spec.category))
			continue
		cluster_spec.instance_policy = cluster_spec.signature_required ? WORLD_EDIT_BUILDING_CLUSTER_PRIMARY_ONLY : (cluster_spec.required ? WORLD_EDIT_BUILDING_CLUSTER_GLOBAL_ONCE : WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL)
	var/list/required_slot_usage = build_building_layout_primary_required_slot_usage(state, program)
	for(var/datum/world_edit_building_layout_room_contract/room as anything in program.room_contracts)
		if(!istype(room))
			continue
		if(room.role == "route")
			room.allowed_scene_kinds = list()
			room.required_scene_kinds = list()
			continue
		var/list/exact_module_specs = list()
		var/list/compatible_module_specs = list()
		for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan?.cluster_specs)
			if(!istype(cluster_spec) || cluster_spec.compact_substitute_only || is_building_infrastructure_category(cluster_spec.category))
				continue
			if(!building_layout_cluster_owned_by_room(program, cluster_spec, room))
				continue
			if(building_layout_cluster_exactly_matches_room(cluster_spec, room))
				exact_module_specs += cluster_spec
			else if(building_layout_cluster_matches_room(cluster_spec, room))
				compatible_module_specs += cluster_spec
		var/list/module_specs = length(exact_module_specs) ? exact_module_specs : compatible_module_specs
		var/scene_kind = resolve_building_layout_scene_kind(room, module_specs)
		var/datum/world_edit_building_layout_scene_contract/scene = new("[room.id]_identity", scene_kind)
		scene.allowed_programs = list(program.id)
		scene.allowed_room_ids = list(room.id)
		scene.allowed_room_roles = list(room.role)
		scene.required = room.required
		scene.min_room_area = room.min_area
		scene.primary_anchor_policy = (room.privacy_class in list("private", "secure")) ? "far_wall" : "center"
		scene.negative_space_policy = "door_to_focus"
		for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in module_specs)
			var/datum/world_edit_building_cluster_spec/instance_spec = build_building_layout_scene_instance_module_spec(state, cluster_spec, room)
			if(!istype(instance_spec))
				continue
			if(room.instance_index > 1 && instance_spec.required && cluster_spec.instance_policy == WORLD_EDIT_BUILDING_CLUSTER_PRIMARY_ONLY && !building_layout_required_group_fits_category_budget(state, program, room, instance_spec, required_slot_usage))
				continue
			scene.module_specs += instance_spec
			if(instance_spec.required)
				scene.required_modules += instance_spec.id
				if(room.instance_index > 1)
					accumulate_building_layout_required_group_slot_usage(state, room, instance_spec, required_slot_usage)
			else
				scene.optional_modules += instance_spec.id
		if(room.required && room.counts_toward_target && !length(scene.required_modules))
			var/datum/world_edit_building_cluster_spec/distributed_identity = select_building_layout_distributed_instance_identity(state, program, room, scene.module_specs, required_slot_usage)
			if(istype(distributed_identity))
				for(var/datum/world_edit_building_cluster_spec/optional_identity as anything in scene.module_specs.Copy())
					if(!istype(optional_identity) || optional_identity.required || !building_layout_composition_groups_match(optional_identity, distributed_identity))
						continue
					scene.module_specs -= optional_identity
					scene.optional_modules -= optional_identity.id
				distributed_identity.required = TRUE
				distributed_identity.failure_severity = "required"
				distributed_identity.min_count = 1
				distributed_identity.max_count = max(1, min(distributed_identity.max_count, 1))
				if(!(distributed_identity in scene.module_specs))
					scene.module_specs += distributed_identity
				scene.optional_modules -= distributed_identity.id
				scene.required_modules += distributed_identity.id
				accumulate_building_layout_required_group_slot_usage(state, room, distributed_identity, required_slot_usage)
		if(room.required && room.counts_toward_target && !length(scene.required_modules))
			state.add_error("program.required_composition_identity_unreachable:[room.id]")
			return FALSE
		room.allowed_scene_kinds = list(scene_kind)
		if(room.required)
			room.required_scene_kinds = list(scene_kind)
		program.add_scene_contract(scene)
		var/datum/world_edit_building_layout_composition_contract/composition = new("[room.id]_composition", room.id, scene.id)
		composition.instance_policy = room.instance_index > 1 ? WORLD_EDIT_BUILDING_CLUSTER_PER_INSTANCE : WORLD_EDIT_BUILDING_CLUSTER_GLOBAL_ONCE
		composition.min_negative_space_tiles = max(scene.min_negative_space_tiles, 1)
		for(var/datum/world_edit_building_cluster_spec/composition_group as anything in scene.module_specs)
			if(!istype(composition_group))
				continue
			if(composition_group.required)
				composition.required_groups += composition_group
			else
				composition.optional_groups += composition_group
		program.add_composition_contract(composition)
	return TRUE

/datum/world_edit_generator/building_layout/proc/select_building_layout_distributed_instance_identity(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program, datum/world_edit_building_layout_room_contract/room, list/module_specs, list/required_slot_usage)
	if(!istype(state) || !istype(program) || !istype(room) || !islist(module_specs) || !islist(required_slot_usage))
		return null
	var/datum/world_edit_building_cluster_spec/best = null
	var/list/evaluated = list()
	var/list/candidates = module_specs.Copy()
	var/list/seen_source_ids = list()
	for(var/datum/world_edit_building_cluster_spec/existing_spec as anything in candidates)
		if(istype(existing_spec))
			seen_source_ids[existing_spec.count_cluster_id || existing_spec.id] = TRUE
	for(var/datum/world_edit_building_cluster_spec/module_spec as anything in module_specs)
		if(!istype(module_spec) || !length(module_spec.compact_substitute_id))
			continue
		var/datum/world_edit_building_cluster_spec/compact_spec = get_building_compact_substitute_spec(state, module_spec)
		if(!istype(compact_spec))
			continue
		compact_spec.count_cluster_id = module_spec.id
		compact_spec.instance_policy = WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL
		candidates += compact_spec
	// A promoted optional room may have no elected GLOBAL_ONCE owner, while a
	// DISTRIBUTE_TOTAL authored group is explicitly compatible with its zone.
	// Bring that group into this room as a named per-room identity; the curated
	// catalog and category budget remain hard gates below.
	for(var/datum/world_edit_building_cluster_spec/source_spec as anything in state.semantic_plan?.cluster_specs)
		if(!istype(source_spec) || source_spec.required || source_spec.signature_required || source_spec.compact_substitute_only || is_building_infrastructure_category(source_spec.category) || seen_source_ids[source_spec.id] || !building_layout_cluster_matches_room(source_spec, room))
			continue
		var/datum/world_edit_building_cluster_spec/distributed_spec = source_spec.clone()
		distributed_spec.id = "[room.id]_[source_spec.id]"
		distributed_spec.count_cluster_id = source_spec.id
		distributed_spec.instance_policy = WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL
		candidates += distributed_spec
		seen_source_ids[source_spec.id] = TRUE
	for(var/datum/world_edit_building_cluster_spec/module_spec as anything in candidates)
		if(!istype(module_spec) || module_spec.instance_policy != WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL)
			continue
		var/datum/world_edit_building_cluster_spec/required_probe = module_spec.clone()
		required_probe.required = TRUE
		required_probe.min_count = 1
		required_probe.max_count = max(1, min(required_probe.max_count, 1))
		var/budget_fits = building_layout_required_group_fits_category_budget(state, program, room, required_probe, required_slot_usage)
		var/list/budget_parts = list()
		var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(room.zone_id)
		var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, required_probe)
		var/list/member_counts = module_footprint?["member_counts"]
		for(var/category as anything in member_counts)
			budget_parts += "[category]=[required_slot_usage[category] || 0]+[member_counts[category] || 0]/[program.global_scene_slot_limits[category] || 0]"
		evaluated += "[required_probe.id]:source=[required_probe.count_cluster_id || required_probe.id]:module_valid=[GLOB.world_edit_helpers.parse_bool(module_footprint?["valid"]) ? "yes" : "no"]:module=[module_footprint?["module_id"] || "none"]:budget=[budget_fits ? "ok" : "rejected"]:[jointext(budget_parts, ",")]:priority=[required_probe.priority]"
		if(!budget_fits)
			continue
		if(!istype(best) || required_probe.priority > best.priority)
			best = required_probe
	if(!istype(best))
		state.add_stage_report("layout_distributed_identity", "failed", "required room has no curated distributed identity within the authored budget", list(
			"room_id" = room.id,
			"zone_id" = room.zone_id,
			"candidate_count" = length(candidates),
			"evaluated" = evaluated,
		))
	return best

/datum/world_edit_generator/building_layout/proc/build_building_layout_primary_required_slot_usage(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program)
	var/list/usage = list()
	if(!istype(state) || !istype(program))
		return usage
	for(var/datum/world_edit_building_layout_room_contract/room as anything in program.room_contracts)
		if(!istype(room) || room.instance_index > 1 || room.role == "route")
			continue
		for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan?.cluster_specs)
			if(!istype(cluster_spec) || cluster_spec.compact_substitute_only || is_building_infrastructure_category(cluster_spec.category) || !building_layout_cluster_owned_by_room(program, cluster_spec, room))
				continue
			var/datum/world_edit_building_cluster_spec/instance_spec = build_building_layout_scene_instance_module_spec(state, cluster_spec, room)
			if(istype(instance_spec) && instance_spec.required)
				accumulate_building_layout_required_group_slot_usage(state, room, instance_spec, usage)
	return usage

/datum/world_edit_generator/building_layout/proc/building_layout_required_group_fits_category_budget(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_program_contract/program, datum/world_edit_building_layout_room_contract/room, datum/world_edit_building_cluster_spec/group, list/required_slot_usage)
	if(!istype(state) || !istype(program) || !istype(room) || !istype(group) || !islist(required_slot_usage))
		return FALSE
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(room.zone_id)
	var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
	if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
		return FALSE
	var/list/member_counts = module_footprint["member_counts"]
	for(var/category as anything in member_counts)
		var/limit = round(text2num("[program.global_scene_slot_limits[category]]") || 0)
		var/projected = round(text2num("[required_slot_usage[category]]") || 0) + round(text2num("[member_counts[category]]") || 0)
		if(limit > 0 && projected > limit)
			return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/accumulate_building_layout_required_group_slot_usage(datum/world_edit_building_layout_state/state, datum/world_edit_building_layout_room_contract/room, datum/world_edit_building_cluster_spec/group, list/required_slot_usage)
	if(!istype(state) || !istype(room) || !istype(group) || !islist(required_slot_usage))
		return FALSE
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(room.zone_id)
	var/list/module_footprint = get_building_layout_required_group_module_footprint(state, zone_spec, group)
	if(!GLOB.world_edit_helpers.parse_bool(module_footprint["valid"]))
		return FALSE
	var/list/member_counts = module_footprint["member_counts"]
	for(var/category as anything in member_counts)
		required_slot_usage["[category]"] = (required_slot_usage["[category]"] || 0) + round(text2num("[member_counts[category]]") || 0)
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_layout_scene_instance_module_spec(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_layout_room_contract/room)
	if(!istype(state) || !istype(cluster_spec) || !istype(room))
		return null
	var/datum/world_edit_building_cluster_spec/source_spec = cluster_spec
	var/use_compact_spec = FALSE
	if(room.instance_index > 1 && length(cluster_spec.compact_substitute_id))
		var/datum/world_edit_building_cluster_spec/compact_spec = state.semantic_plan?.get_cluster_spec_by_id(cluster_spec.compact_substitute_id)
		if(istype(compact_spec) && compact_spec.compact_substitute_only)
			source_spec = compact_spec
			use_compact_spec = TRUE
	if(room.instance_index <= 1 && !use_compact_spec)
		cluster_spec.instance_policy = cluster_spec.signature_required ? WORLD_EDIT_BUILDING_CLUSTER_PRIMARY_ONLY : (cluster_spec.required ? WORLD_EDIT_BUILDING_CLUSTER_GLOBAL_ONCE : WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL)
		return cluster_spec
	var/datum/world_edit_building_cluster_spec/instance_spec = source_spec.clone()
	instance_spec.id = "[room.id]_[source_spec.id]"
	// An explicit compact substitute keeps its own authored recipe/capacity but
	// resolves curated module recipes through the parent group catalog.
	instance_spec.count_cluster_id = use_compact_spec ? cluster_spec.id : source_spec.id
	instance_spec.compact_substitute_only = FALSE
	instance_spec.instance_policy = room.instance_index > 1 && source_spec.instance_policy == WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL ? WORLD_EDIT_BUILDING_CLUSTER_DISTRIBUTE_TOTAL : (room.instance_index > 1 ? WORLD_EDIT_BUILDING_CLUSTER_PER_INSTANCE : source_spec.instance_policy)
	instance_spec.required = cluster_spec.required || (room.required && cluster_spec.optional_zone_id == room.zone_id)
	instance_spec.failure_severity = instance_spec.required ? "required" : "optional"
	if(room.instance_index <= 1)
		instance_spec.signature_required = cluster_spec.signature_required
		instance_spec.signature_id = cluster_spec.signature_id
		instance_spec.semantic_credit = cluster_spec.semantic_credit
		return instance_spec
	instance_spec.signature_required = FALSE
	instance_spec.signature_id = "[room.zone_id]_instance_composition"
	instance_spec.semantic_credit = "[room.zone_id]_instance_identity"
	if(instance_spec.required)
		var/min_members = instance_spec.slot == "bed" ? 2 : 1
		instance_spec.min_count = min_members
		instance_spec.max_count = max(min_members, min(instance_spec.max_count, 2))
	return instance_spec

/datum/world_edit_generator/building_layout/proc/building_layout_cluster_owned_by_room(datum/world_edit_building_layout_program_contract/program, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_layout_room_contract/room)
	if(!istype(program) || !istype(cluster_spec) || !istype(room))
		return FALSE
	if(room.instance_index > 1)
		if(cluster_spec.instance_policy == WORLD_EDIT_BUILDING_CLUSTER_GLOBAL_ONCE)
			return FALSE
		return building_layout_cluster_exactly_matches_room(cluster_spec, room)
	var/owner_room_id = ""
	var/best_score = -999999999
	for(var/datum/world_edit_building_layout_room_contract/candidate_room as anything in program.room_contracts)
		// A GLOBAL_ONCE/PRIMARY_ONLY owner is always a primary instance. Secondary
		// rooms compile their own explicit PER_INSTANCE clone below; allowing one
		// of them into this election can steal the only authored group from the
		// primary room merely because its minimum footprint is larger.
		if(!istype(candidate_room) || candidate_room.instance_index > 1 || !building_layout_cluster_matches_room(cluster_spec, candidate_room))
			continue
		var/anchor_score = get_building_layout_cluster_zone_anchor_score(cluster_spec, candidate_room.zone_id)
		var/score = anchor_score * 1000 + candidate_room.preferred_area * 100 + candidate_room.min_area * 10
		if(length(cluster_spec.optional_zone_id) && cluster_spec.optional_zone_id == candidate_room.zone_id)
			score += 100000000
		score += get_building_layout_cluster_zone_anchor_score(cluster_spec, candidate_room.zone_id)
		if(candidate_room.role in list("hub", "public", "public_med", "staging", "work"))
			score += 500
		if(!length(owner_room_id) || score > best_score)
			owner_room_id = candidate_room.id
			best_score = score
	return owner_room_id == room.id

/datum/world_edit_generator/building_layout/proc/building_layout_cluster_exactly_matches_room(datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_layout_room_contract/room)
	if(!istype(cluster_spec) || !istype(room))
		return FALSE
	if(length(cluster_spec.optional_zone_id) && cluster_spec.optional_zone_id == room.zone_id)
		return TRUE
	return building_layout_cluster_has_zone_anchor(cluster_spec, room.zone_id)

/datum/world_edit_generator/building_layout/proc/building_layout_cluster_has_zone_anchor(datum/world_edit_building_cluster_spec/cluster_spec, zone_id)
	return get_building_layout_cluster_zone_anchor_score(cluster_spec, zone_id) > 0

/datum/world_edit_generator/building_layout/proc/get_building_layout_cluster_zone_anchor_score(datum/world_edit_building_cluster_spec/cluster_spec, zone_id)
	if(!istype(cluster_spec) || !length("[zone_id]"))
		return 0
	var/zone_prefix = "[zone_id]_"
	var/anchor_index = 0
	for(var/anchor_id as anything in cluster_spec.anchors)
		anchor_index++
		var/anchor_key = "[anchor_id]"
		if(anchor_key == "[zone_id]")
			return max(60000 - anchor_index * 1000, 1)
		if(findtext(anchor_key, zone_prefix) == 1)
			return max(50000 - anchor_index * 1000, 1)
	return 0

/datum/world_edit_generator/building_layout/proc/building_layout_cluster_matches_room(datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_layout_room_contract/room)
	if(!istype(cluster_spec) || !istype(room) || is_building_infrastructure_category(cluster_spec.category))
		return FALSE
	if(length(cluster_spec.optional_zone_id) && cluster_spec.optional_zone_id == room.zone_id)
		return TRUE
	if(building_layout_cluster_has_zone_anchor(cluster_spec, room.zone_id))
		return TRUE
	for(var/anchor_id as anything in cluster_spec.anchors)
		if("[anchor_id]" == room.role || "[anchor_id]" in room.anchor_tags)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/resolve_building_layout_scene_kind(datum/world_edit_building_layout_room_contract/room, list/module_specs)
	if(!istype(room))
		return "room_identity"
	if(findtext(room.zone_id, "sleep") || ("sleeping" in room.anchor_tags))
		return "bedroom"
	var/has_social_module = FALSE
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in module_specs)
		if(!istype(cluster_spec))
			continue
		if(cluster_spec.slot == "bed" || (cluster_spec.category in list("bed", "sleeping_bed")))
			return "bedroom"
		if((cluster_spec.slot in list("toilet", "sink")) || cluster_spec.category == "sanitation")
			return "sanitation"
		if(cluster_spec.pattern == "table_cluster" && cluster_spec.chair_count > 0)
			has_social_module = TRUE
	if(room.role == "storage" || findtext(room.zone_id, "storage"))
		return "storage"
	if(has_social_module)
		return "living_common"
	return room.zone_id


/datum/world_edit_generator/building_layout/proc/get_building_layout_pattern(pattern_id)
	switch("[pattern_id]")
		if("hub_spoke")
			return new /datum/world_edit_building_layout_pattern/topology_family/hub_spoke()
		if("split_wing")
			return new /datum/world_edit_building_layout_pattern/topology_family/split_wing()
		if("open_bay_perimeter")
			return new /datum/world_edit_building_layout_pattern/topology_family/open_bay_perimeter()
		if("secure_core")
			return new /datum/world_edit_building_layout_pattern/topology_family/secure_core()
		if("nested_service")
			return new /datum/world_edit_building_layout_pattern/topology_family/nested_service()
		if("compound_cells")
			return new /datum/world_edit_building_layout_pattern/topology_family/compound_cells()
		if("axial_fallback")
			return new /datum/world_edit_building_layout_pattern/topology_family/axial_fallback()
	return null

/datum/world_edit_building_layout_pattern/topology_family
	min_width = 9
	min_height = 9
	max_width = 64
	max_height = 64
	var/list/orientation_variants = list("primary", "rotated")

/datum/world_edit_building_layout_pattern/topology_family/build_region_candidates(datum/world_edit_building_layout_context/context)
	var/list/candidates = list()
	if(!can_solve(context))
		return candidates
	var/variant_index = 0
	for(var/orientation as anything in orientation_variants)
		variant_index++
		var/datum/world_edit_building_layout_region_candidate/candidate = context.generator.build_building_layout_topology_region_candidate(context, id, "[id]_[orientation]", variant_index - 1)
		if(istype(candidate))
			candidates += candidate
	return candidates

/datum/world_edit_building_layout_pattern/topology_family/hub_spoke
	id = "hub_spoke"

/datum/world_edit_building_layout_pattern/topology_family/split_wing
	id = "split_wing"

/datum/world_edit_building_layout_pattern/topology_family/open_bay_perimeter
	id = "open_bay_perimeter"

/datum/world_edit_building_layout_pattern/topology_family/secure_core
	id = "secure_core"

/datum/world_edit_building_layout_pattern/topology_family/nested_service
	id = "nested_service"

/datum/world_edit_building_layout_pattern/topology_family/compound_cells
	id = "compound_cells"

/datum/world_edit_building_layout_pattern/topology_family/axial_fallback
	id = "axial_fallback"

/datum/world_edit_generator/building_layout/proc/build_building_layout_topology_region_candidate(datum/world_edit_building_layout_context/context, family_id, candidate_id, orientation_variant = 0)
	if(!istype(context) || !istype(context.program_contract))
		return null
	if(!istype(context.program_contract.topology_graph) || !length(context.program_contract.functional_room_contracts))
		context.state?.add_stage_report("layout_family_policy_reject", "failed", "topology graph or functional rooms unavailable", list("family" = family_id, "orientation" = orientation_variant))
		return null
	var/datum/world_edit_building_layout_region_candidate/region = new(family_id, candidate_id, 600 - orientation_variant * 5)
	region.topology_graph = context.program_contract.topology_graph
	region.topology_family = "[family_id]"
	region.family_policy_id = "[family_id]"
	region.orientation_variant = orientation_variant
	var/datum/world_edit_building_layout_family_policy/policy = get_building_layout_family_policy(family_id)
	if(!istype(policy) || !policy.can_solve(context))
		context.state?.add_stage_report("layout_family_policy_reject", "failed", "policy unavailable or dimension-gated", list("family" = family_id, "orientation" = orientation_variant, "width" = context.local_width(), "height" = context.local_height()))
		return null
	region.family_constraints = call(policy, "build_constraints")(context, orientation_variant)
	var/list/debug_groups = build_building_layout_family_groups(context)
	var/seed_result = call(policy, "build_seed_regions")(context, region, orientation_variant)
	if(!seed_result || !length(region.influence_zones))
		var/datum/world_edit_building_layout_room_contract/first_functional = length(context.program_contract.functional_room_contracts) ? context.program_contract.functional_room_contracts[1] : null
		context.state?.add_stage_report("layout_family_policy_reject", "failed", "policy produced no seed regions", list("family" = family_id, "orientation" = orientation_variant, "policy_type" = "[policy.type]", "policy_id" = policy.id, "seed_result" = seed_result, "zone_count" = length(region.influence_zones), "functional_count" = length(context.program_contract.functional_room_contracts), "first_functional_type" = "[first_functional?.type]", "first_functional_value" = "[first_functional]", "first_functional_id" = "[first_functional?.id]", "first_functional_role" = "[first_functional?.role]", "root_count" = length(debug_groups?["root"]), "public_count" = length(debug_groups?["public"]), "other_count" = length(debug_groups?["other"])))
		return null
	for(var/datum/world_edit_building_layout_topology_edge/edge as anything in region.topology_graph.edges)
		if(!istype(edge))
			continue
		var/datum/world_edit_building_layout_room_contract/from_contract = context.program_contract.get_room_contract(edge.from_id)
		var/privacy = from_contract?.privacy_class || "public"
		if(edge.from_id == edge.to_id)
			continue
		var/datum/world_edit_building_layout_room_connection/connection = region.add_connection("topology_[edge.from_id]_[edge.to_id]", edge.from_id, edge.to_id, privacy, edge.required, edge.edge_kind, edge.opening_policy, edge.route_policy)
		connection.min_shared_wall = edge.min_shared_wall
		connection.min_opening_width = edge.min_opening_width
		connection.max_opening_width = edge.max_opening_width
		if(family_id == "open_bay_perimeter" && edge.edge_kind == WORLD_EDIT_BUILDING_EDGE_ROUTE)
			var/datum/world_edit_building_layout_room_contract/to_contract = context.program_contract.get_room_contract(edge.to_id)
			var/datum/world_edit_building_layout_room_contract/functional_contract = from_contract?.counts_toward_target ? from_contract : to_contract
			if(functional_contract?.spatial_kind == WORLD_EDIT_BUILDING_SPACE_OPEN_BAY)
				// The named bay meets circulation through a physical opening, not a
				// controlled door cone. Keep this override on the family-specific typed
				// edge so OPEN_BAY rooms used by other families retain their contract.
				connection.opening_policy = WORLD_EDIT_BUILDING_OPENING_WIDE_ARCH
				connection.min_opening_width = max(connection.min_opening_width, 2)
				connection.max_opening_width = max(connection.max_opening_width, connection.min_opening_width)
	return region
