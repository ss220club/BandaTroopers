/datum/world_edit_generator/building_layout/proc/validate_building_semantic_scene_contracts(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/relevant_room_count = 0
	var/covered_room_count = 0
	var/dense_scene_object_count = 0
	var/blocked_scene_object_count = 0
	var/unscened_major_count = 0
	var/legacy_after_scene_count = 0
	for(var/datum/world_edit_building_room/room as anything in state.geometry.solved_rooms)
		if(!istype(room) || !building_semantic_room_requires_primary_scene(state, room))
			continue
		relevant_room_count++
		if((state.fixtures.scene_primary_counts_by_room[room.id] || 0) > 0 || length("[state.fixtures.scene_kind_by_room[room.id] || ""]"))
			covered_room_count++
		else if(state.fixtures.structured_scene_emitted)
			state.validation.semantic_room_primary_scene_missing_count++
	for(var/list/placement as anything in state.fixtures.object_placements)
		if(!islist(placement) || "[placement["kind"]]" != "interior")
			continue
		if(GLOB.world_edit_helpers.parse_bool(placement["infrastructure"]))
			continue
		var/turf/target_turf = placement["turf"]
		var/dense = istype(target_turf) && building_object_path_is_dense(placement["obj_path"])
		var/has_scene = GLOB.world_edit_helpers.parse_bool(placement["semantic_scene"]) || GLOB.world_edit_helpers.parse_bool(placement["layout_scene"]) || length("[placement["scene_id"] || ""]")
		if(dense && has_scene)
			dense_scene_object_count++
			if(state.geometry.reserved_lookup[target_turf] || state.has_anchor("door_cone", target_turf))
				blocked_scene_object_count++
		if(state.fixtures.structured_scene_emitted && !has_scene)
			legacy_after_scene_count++
			if(GLOB.world_edit_helpers.parse_bool(placement["major"]))
				unscened_major_count++
		else if(GLOB.world_edit_helpers.parse_bool(placement["major"]) && !has_scene && (state.fixtures.semantic_interiors_emitted || building_layout_solver_enabled(state)))
			unscened_major_count++
	state.fixtures.legacy_fixture_after_scene_count = legacy_after_scene_count
	state.validation.legacy_fixture_after_scene_count = max(state.validation.legacy_fixture_after_scene_count, legacy_after_scene_count)
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

/datum/world_edit_generator/building_layout/proc/building_semantic_room_requires_primary_scene(datum/world_edit_building_layout_state/state, datum/world_edit_building_room/room)
	if(!istype(room))
		return FALSE
	var/room_class = resolve_building_semantic_room_class(state, room)
	if(room_class in list(WORLD_EDIT_BUILDING_SEMANTIC_ROOM_ROUTE, WORLD_EDIT_BUILDING_SEMANTIC_ROOM_NONE))
		return FALSE
	if(room.area < 6)
		return FALSE
	if(room_class in list(
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_COMMON,
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SLEEPING,
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SANITATION,
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_STORAGE,
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_UTILITY,
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_WORK,
		WORLD_EDIT_BUILDING_SEMANTIC_ROOM_HYDRO,
	))
		return TRUE
	return FALSE
