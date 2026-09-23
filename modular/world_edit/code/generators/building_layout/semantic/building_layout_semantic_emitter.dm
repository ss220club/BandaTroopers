/datum/world_edit_generator/building_layout/proc/mark_building_structured_scene_emission(datum/world_edit_building_layout_state/state, owner)
	if(!istype(state))
		return
	var/resolved_owner = length("[owner]") ? "[owner]" : "unknown"
	state.fixtures.structured_scene_emitted = TRUE
	state.fixtures.structured_scene_owner = resolved_owner
	state.fixtures.structured_scene_count = length(state.fixtures.scene_plans)
	state.fixtures.structured_primary_scene_count = length(state.fixtures.scene_primary_counts_by_room)
	if(resolved_owner == "semantic")
		state.fixtures.semantic_interiors_emitted = TRUE
		state.fixtures.semantic_interiors_scene_count = state.fixtures.structured_scene_count
		state.fixtures.semantic_interiors_primary_scene_count = state.fixtures.structured_primary_scene_count

/datum/world_edit_generator/building_layout/proc/emit_building_semantic_scene_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_scene_candidate/candidate)
	if(!istype(state) || !istype(candidate) || !istype(candidate.rule) || !istype(candidate.room))
		return FALSE
	var/datum/world_edit_building_semantic_scene_rule/rule = candidate.rule
	var/datum/world_edit_building_room/room = candidate.room
	var/module_id = "semantic_scene_[rule.id]"
	var/module_instance_id = "semantic_scene_[room.id]_[rule.id]"
	var/expected_count = length(candidate.members)
	var/placed_count = 0
	for(var/list/member as anything in candidate.members)
		var/datum/world_edit_building_semantic_scene_member_spec/spec = member["spec"]
		var/turf/member_turf = member["turf"]
		var/turf/anchor_turf = member["anchor"]
		if(!istype(spec) || !istype(member_turf))
			state.remove_module_instance(module_instance_id)
			return FALSE
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(spec.slot, spec.category)
		var/fallback_dir = get_cardinal_dir_toward(member_turf, anchor_turf || candidate.field.focus_turf || state.geometry.semantic_hub_turf || state.geometry.center_turf, state.placement_dir || SOUTH)
		if(spec.placement_mode == "adjacent_to_anchor")
			fallback_dir = get_cardinal_dir_toward(member_turf, anchor_turf, fallback_dir)
		var/list/place_context = build_building_fixture_place_context(state, member_turf, place_rule, fallback_dir, spec.wall_required)
		if(!islist(place_context))
			state.add_stage_report("semantic_scene", "failed", "place_context_failed", list(
				"room_id" = room.id,
				"scene_id" = rule.id,
				"slot" = spec.slot,
				"category" = spec.category,
			))
			state.remove_module_instance(module_instance_id)
			return FALSE
		if(!place_fixture_at(state, member_turf, spec.slot, place_context["dir"] || fallback_dir, spec.category, spec.major, place_context["wall_dir"] ? TRUE : FALSE, place_rule, place_context["wall_dir"], null, null, null, "semantic_scene", FALSE, module_id, module_instance_id, expected_count, rule.scene_kind, room.id, spec.requires_table_pairing, spec.seating_group_ok))
			state.add_stage_report("semantic_scene", "failed", "fixture_emit_failed", list(
				"room_id" = room.id,
				"scene_id" = rule.id,
				"slot" = spec.slot,
				"category" = spec.category,
			))
			state.remove_module_instance(module_instance_id)
			return FALSE
		annotate_building_semantic_scene_placement(state, member_turf, module_instance_id, rule, spec)
		placed_count++
	if(placed_count != expected_count)
		state.remove_module_instance(module_instance_id)
		return FALSE
	state.register_module_instance(module_id, module_instance_id, expected_count, room.id, rule.scene_kind)
	register_building_semantic_scene_plan(state, candidate)
	return TRUE

/datum/world_edit_generator/building_layout/proc/annotate_building_semantic_scene_placement(datum/world_edit_building_layout_state/state, turf/member_turf, module_instance_id, datum/world_edit_building_semantic_scene_rule/rule, datum/world_edit_building_semantic_scene_member_spec/spec)
	for(var/index = length(state.fixtures.object_placements), index >= 1, index--)
		var/list/placement = state.fixtures.object_placements[index]
		if(!islist(placement) || placement["turf"] != member_turf || "[placement["module_instance_id"]]" != "[module_instance_id]")
			continue
		placement["semantic_scene"] = TRUE
		placement["scene_id"] = rule.id
		placement["scene_kind"] = rule.scene_kind
		placement["scene_slot"] = spec.scene_slot
		placement["scene_phase"] = rule.phase
		placement["scene_primary"] = rule.primary ? TRUE : FALSE
		return

/datum/world_edit_generator/building_layout/proc/register_building_semantic_scene_plan(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_scene_candidate/candidate)
	if(!istype(state) || !istype(candidate) || !istype(candidate.rule) || !istype(candidate.room))
		return
	var/list/slot_counts = list()
	for(var/list/member as anything in candidate.members)
		var/datum/world_edit_building_semantic_scene_member_spec/spec = member["spec"]
		if(istype(spec))
			slot_counts[spec.scene_slot] = (slot_counts[spec.scene_slot] || 0) + 1
	state.fixtures.scene_plans += list(list(
		"id" = candidate.rule.id,
		"room_id" = candidate.room.id,
		"room_role" = candidate.room.role,
		"room_zone_id" = candidate.room.zone_id,
		"scene_id" = candidate.rule.id,
		"scene_kind" = candidate.rule.scene_kind,
		"primary" = candidate.rule.primary ? TRUE : FALSE,
		"member_count" = length(candidate.members),
		"scene_slot_counts" = slot_counts.Copy(),
		"semantic_scene" = TRUE,
	))
	state.fixtures.scene_counts_by_room[candidate.room.id] = (state.fixtures.scene_counts_by_room[candidate.room.id] || 0) + 1
	if(candidate.rule.primary)
		state.fixtures.scene_primary_counts_by_room[candidate.room.id] = (state.fixtures.scene_primary_counts_by_room[candidate.room.id] || 0) + 1
	state.fixtures.scene_kind_by_room[candidate.room.id] = candidate.rule.scene_kind
	state.fixtures.scene_slot_counts_by_room[candidate.room.id] = slot_counts.Copy()

/datum/world_edit_generator/building_layout/proc/credit_building_semantic_scene_requirements(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.semantic_plan))
		return
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan.get_cluster_specs("major"))
		if(!istype(cluster_spec) || !cluster_spec.required)
			continue
		var/credit_count = get_building_semantic_scene_credit_count_for_cluster(state, cluster_spec)
		if(credit_count <= 0)
			continue
		var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
		var/minimum = get_effective_cluster_min_count(state, cluster_spec)
		var/final_credit = max(credit_count, minimum, 1)
		state.fixtures.placed_requirement_counts[requirement_id] = max(round(text2num("[state.fixtures.placed_requirement_counts[requirement_id]]") || 0), final_credit)
		state.fixtures.semantic_requirement_counts[requirement_id] = max(round(text2num("[state.fixtures.semantic_requirement_counts[requirement_id]]") || 0), final_credit)
		if(length(cluster_spec.id) && cluster_spec.id != requirement_id)
			state.fixtures.placed_requirement_counts[cluster_spec.id] = max(round(text2num("[state.fixtures.placed_requirement_counts[cluster_spec.id]]") || 0), final_credit)
			state.fixtures.semantic_requirement_counts[cluster_spec.id] = max(round(text2num("[state.fixtures.semantic_requirement_counts[cluster_spec.id]]") || 0), final_credit)
		if(length(cluster_spec.signature_id))
			state.fixtures.semantic_requirement_counts[cluster_spec.signature_id] = max(round(text2num("[state.fixtures.semantic_requirement_counts[cluster_spec.signature_id]]") || 0), final_credit)

/datum/world_edit_generator/building_layout/proc/get_building_semantic_scene_credit_count_for_cluster(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	var/count = 0
	var/cluster_slot = lowertext("[cluster_spec.slot]")
	var/cluster_category = lowertext("[cluster_spec.category]")
	for(var/list/placement as anything in state.fixtures.object_placements)
		if(!islist(placement) || !GLOB.world_edit_helpers.parse_bool(placement["semantic_scene"]))
			continue
		var/slot = lowertext("[placement["requested_slot"] || placement["slot"]]")
		var/category = lowertext("[placement["category"] || ""]")
		var/scene_kind = lowertext("[placement["scene_kind"] || ""]")
		if(cluster_slot == slot || cluster_category == category)
			count++
			continue
		if(cluster_slot in list("table", "chair") && scene_kind in list(WORLD_EDIT_BUILDING_SEMANTIC_SCENE_DINING, WORLD_EDIT_BUILDING_SEMANTIC_SCENE_LIVING, WORLD_EDIT_BUILDING_SEMANTIC_SCENE_WORK))
			count++
			continue
		if(cluster_slot in list("rack", "cabinet", "crate", "filing") && scene_kind == WORLD_EDIT_BUILDING_SEMANTIC_SCENE_STORAGE)
			count++
			continue
		if(cluster_slot in list("toilet", "sink") && scene_kind == WORLD_EDIT_BUILDING_SEMANTIC_SCENE_SANITATION)
			count++
			continue
		if(cluster_slot in list("bed", "sleeper") && scene_kind == WORLD_EDIT_BUILDING_SEMANTIC_SCENE_BEDROOM)
			count++
	return count
