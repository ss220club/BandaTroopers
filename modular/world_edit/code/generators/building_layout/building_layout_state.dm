/datum/world_edit_building_layout_state
	var/datum/world_edit_building_request/request
	var/datum/world_edit_building_archetype/archetype
	var/datum/world_edit_building_semantic_plan/semantic_plan
	var/list/config = list()

	var/datum/world_edit_building_layout_geometry_state/geometry
	var/datum/world_edit_building_layout_fixture_state/fixtures
	var/datum/world_edit_building_layout_validation_state/validation
	var/layout_context

	var/root_seed = 0
	var/stage_seed_footprint = 0
	var/stage_seed_rooms = 0
	var/stage_seed_corridor = 0
	var/stage_seed_patterns = 0
	var/stage_seed_details = 0
	var/placement_dir = NORTH

/datum/world_edit_building_layout_state/New()
	..()
	geometry = new()
	fixtures = new()
	validation = new()

/datum/world_edit_building_layout_state/proc/add_error(message)
	if(length(validation.errors) >= WORLD_EDIT_BUILDING_MAX_VALIDATION_ERRORS)
		return
	validation.errors += "[message]"

/datum/world_edit_building_layout_state/proc/add_warning(message)
	validation.warnings += "[message]"

/datum/world_edit_building_layout_state/proc/add_capped_report(list/report_list, list/report, max_count)
	if(!islist(report_list) || !islist(report))
		return null
	var/cap = max(round(text2num("[max_count]") || 0), 1)
	if(length(report_list) >= cap)
		return null
	report_list += list(report)
	return report

/datum/world_edit_building_layout_state/proc/set_support_status(status, reason = null)
	validation.current_request_support_status = length("[status]") ? "[status]" : WORLD_EDIT_BUILDING_SUPPORT_FAILED
	if(!isnull(reason))
		validation.user_facing_failure_reason = "[reason]"
	validation.support_status_report = list(
		"status" = validation.current_request_support_status,
		"reason" = validation.user_facing_failure_reason,
		"program_id" = archetype?.id,
		"shape_id" = config["placement_shape_id"],
		"style_id" = config["faction_preset"],
		"size" = "[config["half_width"]]x[config["half_depth"]]",
		"respect_blockers" = config["respect_blockers"] ? TRUE : FALSE,
		"replace_blocked_turfs" = config["replace_blocked_turfs"] ? TRUE : FALSE,
	)

/datum/world_edit_building_layout_state/proc/add_stage_report(stage_id, status, reason = null, list/extra = null)
	var/list/report = list(
		"stage_id" = "[stage_id]",
		"status" = "[status]",
	)
	if(!isnull(reason))
		report["reason"] = "[reason]"
	if(islist(extra))
		for(var/key as anything in extra)
			report[key] = extra[key]
	add_capped_report(validation.stage_reports, report, WORLD_EDIT_BUILDING_MAX_STAGE_REPORTS)
	return report

/datum/world_edit_building_layout_state/proc/add_pattern_report(list/report)
	return add_capped_report(validation.pattern_reports, report, WORLD_EDIT_BUILDING_MAX_PATTERN_REPORTS)

/datum/world_edit_building_layout_state/proc/add_semantic_slot_report(list/report)
	return add_capped_report(validation.semantic_slot_reports, report, WORLD_EDIT_BUILDING_MAX_SEMANTIC_SLOT_REPORTS)

/datum/world_edit_building_layout_state/proc/add_semantic_requirement_report(list/report)
	return add_capped_report(validation.semantic_requirement_reports, report, WORLD_EDIT_BUILDING_MAX_SEMANTIC_SLOT_REPORTS)

/datum/world_edit_building_layout_state/proc/add_template_reject_reason(reason_id, list/report = null)
	if(!length("[reason_id]"))
		return
	validation.template_reject_reason_counts["[reason_id]"] = (validation.template_reject_reason_counts["[reason_id]"] || 0) + 1
	if(islist(report))
		report["reason"] = "[reason_id]"
		add_capped_report(validation.template_reject_reports, report, WORLD_EDIT_BUILDING_MAX_SEMANTIC_SLOT_REPORTS)

/datum/world_edit_building_layout_state/proc/add_template_cluster_report(list/report)
	return add_capped_report(validation.template_cluster_reports, report, WORLD_EDIT_BUILDING_MAX_SEMANTIC_SLOT_REPORTS)

/datum/world_edit_building_layout_state/proc/add_degraded_region_report(list/report)
	return add_capped_report(validation.degraded_region_reports, report, WORLD_EDIT_BUILDING_MAX_DEGRADED_REGION_REPORTS)

/datum/world_edit_building_layout_state/proc/clear_validation_cache()
	if(islist(validation.validation_reachable_floor_lookup))
		validation.validation_reachable_floor_lookup.Cut()
	validation.validation_reachable_floor_lookup = null

/datum/world_edit_building_layout_state/proc/has_errors()
	return length(validation.errors) > 0

/datum/world_edit_building_layout_state/proc/append_unique_turf(list/target, turf/target_turf)
	if(!islist(target) || !istype(target_turf))
		return FALSE
	if(target_turf in target)
		return FALSE
	target += target_turf
	return TRUE

/datum/world_edit_building_layout_state/proc/add_zone(turf/target_turf, zone_id)
	if(!istype(target_turf) || !length("[zone_id]"))
		return
	var/old_zone_id = geometry.zone_by_turf[target_turf]
	if(length("[old_zone_id]") && old_zone_id != "[zone_id]")
		var/list/old_turfs = geometry.zone_turfs["[old_zone_id]"]
		if(islist(old_turfs))
			old_turfs -= target_turf
	geometry.zone_by_turf[target_turf] = "[zone_id]"
	var/list/turfs = geometry.zone_turfs["[zone_id]"]
	if(!islist(turfs))
		turfs = list()
		geometry.zone_turfs["[zone_id]"] = turfs
	append_unique_turf(turfs, target_turf)

/datum/world_edit_building_layout_state/proc/clear_zones()
	geometry.zone_by_turf.Cut()
	geometry.zone_turfs.Cut()
	geometry.zone_focus_turfs.Cut()

/datum/world_edit_building_layout_state/proc/get_zone(turf/target_turf)
	return "[geometry.zone_by_turf[target_turf] || ""]"

/datum/world_edit_building_layout_state/proc/get_zone_turfs(zone_id)
	var/list/turfs = geometry.zone_turfs["[zone_id]"]
	var/list/result = islist(turfs) ? turfs.Copy() : list()
	// A room-owned aisle is a typed semantic layer over functional-room floor,
	// not a request to steal those cells from the room's single physical owner.
	// Expose the committed overlay and its connector through zone queries so
	// validators/reporting see the authored circulation ID after materialization.
	for(var/datum/world_edit_building_layout_route_overlay/overlay as anything in geometry.layout_route_overlays)
		if(!istype(overlay) || overlay.id != "[zone_id]")
			continue
		for(var/turf/overlay_turf as anything in overlay.turfs)
			append_unique_turf(result, overlay_turf)
		for(var/turf/approach_turf as anything in overlay.approach_turfs)
			append_unique_turf(result, approach_turf)
	return result

/datum/world_edit_building_layout_state/proc/set_zone_focus(zone_id, turf/target_turf)
	if(!istype(target_turf) || !length("[zone_id]"))
		return
	geometry.zone_focus_turfs["[zone_id]"] = target_turf

/datum/world_edit_building_layout_state/proc/get_zone_focus(zone_id)
	return geometry.zone_focus_turfs["[zone_id]"]

/datum/world_edit_building_layout_state/proc/add_anchor(anchor_id, turf/target_turf)
	if(!istype(target_turf) || !length("[anchor_id]"))
		return
	var/anchor_key = "[anchor_id]"
	var/list/turfs = fixtures.anchor_turfs[anchor_key]
	if(!islist(turfs))
		turfs = list()
		fixtures.anchor_turfs[anchor_key] = turfs
	var/list/lookup = fixtures.anchor_lookup[anchor_key]
	if(!islist(lookup))
		lookup = list()
		fixtures.anchor_lookup[anchor_key] = lookup
	if(lookup[target_turf])
		return
	turfs += target_turf
	lookup[target_turf] = TRUE

/datum/world_edit_building_layout_state/proc/get_anchor_turfs(anchor_id)
	var/list/turfs = fixtures.anchor_turfs["[anchor_id]"]
	return islist(turfs) ? turfs : list()

/datum/world_edit_building_layout_state/proc/has_anchor(anchor_id, turf/target_turf)
	if(!istype(target_turf))
		return FALSE
	var/list/lookup = fixtures.anchor_lookup["[anchor_id]"]
	return islist(lookup) && lookup[target_turf]

/datum/world_edit_building_layout_state/proc/clear_anchors()
	fixtures.anchor_turfs.Cut()
	fixtures.anchor_lookup.Cut()

/datum/world_edit_building_layout_state/proc/add_reserved(turf/target_turf)
	if(istype(target_turf))
		geometry.reserved_lookup[target_turf] = TRUE

/datum/world_edit_building_layout_state/proc/add_primary_route(turf/target_turf)
	if(!istype(target_turf))
		return
	append_unique_turf(geometry.primary_route_turfs, target_turf)
	add_reserved(target_turf)

/datum/world_edit_building_layout_state/proc/add_corridor_turf(turf/target_turf)
	if(!istype(target_turf) || !geometry.footprint_lookup[target_turf])
		return FALSE
	if(!geometry.corridor_lookup[target_turf])
		geometry.corridor_turfs += target_turf
		geometry.corridor_lookup[target_turf] = TRUE
	add_primary_route(target_turf)
	return TRUE

/datum/world_edit_building_layout_state/proc/add_separator_lane(turf/target_turf)
	if(!istype(target_turf) || !geometry.footprint_lookup[target_turf])
		return FALSE
	if(geometry.boundary_lookup[target_turf] || geometry.corridor_lookup[target_turf] || geometry.door_dirs[target_turf])
		return FALSE
	if(geometry.separator_lane_lookup[target_turf])
		return TRUE
	geometry.separator_lane_lookup[target_turf] = TRUE
	append_unique_turf(geometry.separator_lane_turfs, target_turf)
	return TRUE

/datum/world_edit_building_layout_state/proc/add_solved_room(datum/world_edit_building_room/room)
	if(!istype(room) || !length(room.turfs))
		return FALSE
	if(!(room in geometry.solved_rooms))
		geometry.solved_rooms += room
	for(var/turf/room_turf as anything in room.turfs)
		if(!istype(room_turf) || !geometry.footprint_lookup[room_turf])
			continue
		geometry.room_by_turf[room_turf] = room
		add_zone(room_turf, room.zone_id)
	if(istype(room.focus_turf))
		set_zone_focus(room.zone_id, room.focus_turf)
	return TRUE

/datum/world_edit_building_layout_state/proc/get_room_for_turf(turf/target_turf)
	if(!istype(target_turf))
		return null
	return geometry.room_by_turf[target_turf]

/datum/world_edit_building_layout_state/proc/clear_room_layout()
	geometry.solved_rooms.Cut()
	geometry.room_by_turf.Cut()
	geometry.corridor_turfs.Cut()
	geometry.corridor_lookup.Cut()
	geometry.solved_regions.Cut()
	geometry.internal_wall_turfs.Cut()
	geometry.layout_room_plans.Cut()
	geometry.layout_route_opening_plans.Cut()
	geometry.layout_route_overlays.Cut()
	geometry.primary_route_turfs.Cut()
	geometry.separator_lane_turfs.Cut()
	geometry.separator_lane_lookup.Cut()
	geometry.reserved_lookup.Cut()
	geometry.wall_lookup.Cut()
	geometry.floor_turfs.Cut()
	geometry.floor_lookup.Cut()
	geometry.adjacent_wall_dirs_by_turf.Cut()
	clear_zones()

/datum/world_edit_building_layout_state/proc/add_internal_wall(turf/target_turf)
	if(!istype(target_turf) || !geometry.footprint_lookup[target_turf])
		return FALSE
	if(geometry.reserved_lookup[target_turf] || geometry.door_dirs[target_turf])
		return FALSE
	geometry.wall_lookup[target_turf] = TRUE
	geometry.adjacent_wall_dirs_by_turf.Cut()
	append_unique_turf(geometry.internal_wall_turfs, target_turf)
	return TRUE

/datum/world_edit_building_layout_state/proc/can_place_fixture(turf/target_turf, allow_reserved = FALSE)
	if(!istype(target_turf))
		return FALSE
	if(!geometry.floor_lookup[target_turf])
		return FALSE
	if(geometry.wall_lookup[target_turf] || geometry.door_dirs[target_turf])
		return FALSE
	if(fixtures.fixture_lookup[target_turf])
		return FALSE
	if(fixtures.semantic_slot_clearance_by_turf[target_turf])
		return FALSE
	if(!allow_reserved && geometry.reserved_lookup[target_turf])
		return FALSE
	if(has_anchor("door_cone", target_turf))
		return FALSE
	return TRUE

/datum/world_edit_building_layout_state/proc/register_fixture(turf/target_turf, category, major = FALSE, wall_mounted = FALSE)
	if(!istype(target_turf))
		return
	fixtures.fixture_lookup[target_turf] = TRUE
	fixtures.fixture_categories[target_turf] = "[category]"
	fixtures.category_counts["[category]"] = (fixtures.category_counts["[category]"] || 0) + 1
	fixtures.fixture_count++
	if(major)
		fixtures.major_fixture_count++
		append_unique_turf(fixtures.major_fixture_turfs, target_turf)
	if(wall_mounted)
		append_unique_turf(fixtures.wall_fixture_turfs, target_turf)

/datum/world_edit_building_layout_state/proc/rebuild_fixture_indexes()
	fixtures.fixture_lookup.Cut()
	fixtures.fixture_categories.Cut()
	fixtures.category_counts.Cut()
	fixtures.cluster_counts.Cut()
	fixtures.signature_counts.Cut()
	fixtures.placed_requirement_counts.Cut()
	fixtures.semantic_requirement_counts.Cut()
	fixtures.module_counts.Cut()
	fixtures.module_expected_member_counts.Cut()
	fixtures.module_instance_rooms.Cut()
	fixtures.module_instance_repeat_groups.Cut()
	fixtures.module_counts_by_room.Cut()
	fixtures.module_repeat_group_counts_by_room.Cut()
	fixtures.major_fixture_turfs.Cut()
	fixtures.wall_fixture_turfs.Cut()
	fixtures.fixture_count = 0
	fixtures.major_fixture_count = 0
	fixtures.template_chunk_count = 0
	fixtures.template_chunk_cell_count = 0
	fixtures.infrastructure_count = 0
	fixtures.module_instance_count = 0
	var/list/template_chunk_instance_lookup = list()
	var/list/module_instance_lookup = list()
	for(var/list/object_placement as anything in fixtures.object_placements)
		if(!islist(object_placement) || "[object_placement["kind"]]" != "interior")
			continue
		var/turf/target_turf = object_placement["turf"]
		if(!istype(target_turf))
			continue
		var/category = "[object_placement["category"] || ""]"
		if(!length(category))
			category = "object"
		register_fixture(target_turf, category, GLOB.world_edit_helpers.parse_bool(object_placement["major"]), GLOB.world_edit_helpers.parse_bool(object_placement["wall_mounted"]))
		var/cluster_credit = round(text2num("[object_placement["cluster_count_credit"]]") || 0)
		if(cluster_credit > 0 && length("[object_placement["cluster_id"]]"))
			register_cluster(object_placement["cluster_id"], cluster_credit)
		var/signature_credit = round(text2num("[object_placement["signature_count_credit"]]") || 0)
		if(signature_credit > 0 && length("[object_placement["signature_id"]]"))
			register_signature(object_placement["signature_id"], signature_credit)
		var/requirement_credit = round(text2num("[object_placement["requirement_count_credit"]]") || 0)
		if(requirement_credit > 0 && length("[object_placement["requirement_id"]]"))
			register_placed_requirement(object_placement["requirement_id"], requirement_credit)
		if(length("[object_placement["template_chunk_id"]]"))
			fixtures.template_chunk_cell_count++
			var/template_chunk_instance_id = "[object_placement["template_chunk_instance_id"]]"
			if(!length(template_chunk_instance_id))
				template_chunk_instance_id = "[object_placement["template_chunk_id"]]@[target_turf.x],[target_turf.y],[target_turf.z]"
			if(!template_chunk_instance_lookup[template_chunk_instance_id])
				template_chunk_instance_lookup[template_chunk_instance_id] = TRUE
				fixtures.template_chunk_count++
		var/module_instance_id = "[object_placement["module_instance_id"] || ""]"
		if(length(module_instance_id) && !module_instance_lookup[module_instance_id])
			module_instance_lookup[module_instance_id] = TRUE
			fixtures.module_instance_count++
			var/module_id = "[object_placement["module_id"] || ""]"
			var/module_room_id = "[object_placement["module_room_id"] || ""]"
			if(!length(module_room_id))
				var/datum/world_edit_building_room/module_room = get_room_for_turf(target_turf)
				if(istype(module_room))
					module_room_id = module_room.id
			var/module_repeat_group = "[object_placement["module_repeat_group"] || ""]"
			if(length(module_id))
				fixtures.module_counts[module_id] = (fixtures.module_counts[module_id] || 0) + 1
			if(length(module_room_id))
				fixtures.module_instance_rooms[module_instance_id] = module_room_id
				if(length(module_id))
					var/room_module_key = "[module_room_id]|[module_id]"
					fixtures.module_counts_by_room[room_module_key] = (fixtures.module_counts_by_room[room_module_key] || 0) + 1
				if(length(module_repeat_group))
					var/room_repeat_key = "[module_room_id]|[module_repeat_group]"
					fixtures.module_repeat_group_counts_by_room[room_repeat_key] = (fixtures.module_repeat_group_counts_by_room[room_repeat_key] || 0) + 1
			if(length(module_repeat_group))
				fixtures.module_instance_repeat_groups[module_instance_id] = module_repeat_group
			fixtures.module_expected_member_counts[module_instance_id] = max(round(text2num("[object_placement["module_expected_member_count"]]") || 0), 1)
		if(GLOB.world_edit_helpers.parse_bool(object_placement["infrastructure"]))
			fixtures.infrastructure_count++

/datum/world_edit_building_layout_state/proc/register_module_instance(module_id, module_instance_id, expected_member_count, room_id = null, repeat_group = null)
	if(!length("[module_id]") || !length("[module_instance_id]"))
		return
	if(!fixtures.module_expected_member_counts["[module_instance_id]"])
		fixtures.module_instance_count++
	fixtures.module_counts["[module_id]"] = (fixtures.module_counts["[module_id]"] || 0) + 1
	fixtures.module_expected_member_counts["[module_instance_id]"] = max(round(text2num("[expected_member_count]") || 0), 1)
	if(length("[room_id]"))
		fixtures.module_instance_rooms["[module_instance_id]"] = "[room_id]"
		var/room_module_key = "[room_id]|[module_id]"
		fixtures.module_counts_by_room[room_module_key] = (fixtures.module_counts_by_room[room_module_key] || 0) + 1
	if(length("[repeat_group]"))
		fixtures.module_instance_repeat_groups["[module_instance_id]"] = "[repeat_group]"
		if(length("[room_id]"))
			var/room_repeat_key = "[room_id]|[repeat_group]"
			fixtures.module_repeat_group_counts_by_room[room_repeat_key] = (fixtures.module_repeat_group_counts_by_room[room_repeat_key] || 0) + 1

/datum/world_edit_building_layout_state/proc/get_building_module_count(module_id)
	if(!length("[module_id]"))
		return 0
	return round(text2num("[fixtures.module_counts["[module_id]"]]") || 0)

/datum/world_edit_building_layout_state/proc/get_room_module_count(room_id, module_id)
	if(!length("[room_id]") || !length("[module_id]"))
		return 0
	return round(text2num("[fixtures.module_counts_by_room["[room_id]|[module_id]"]]") || 0)

/datum/world_edit_building_layout_state/proc/get_room_repeat_group_count(room_id, repeat_group)
	if(!length("[room_id]") || !length("[repeat_group]"))
		return 0
	return round(text2num("[fixtures.module_repeat_group_counts_by_room["[room_id]|[repeat_group]"]]") || 0)

/datum/world_edit_building_layout_state/proc/remove_module_instance(module_instance_id)
	if(!length("[module_instance_id]"))
		return FALSE
	var/removed = FALSE
	for(var/index = length(fixtures.object_placements), index >= 1, index--)
		var/list/object_placement = fixtures.object_placements[index]
		if(!islist(object_placement) || "[object_placement["module_instance_id"]]" != "[module_instance_id]")
			continue
		fixtures.object_placements.Cut(index, index + 1)
		removed = TRUE
	if(removed)
		rebuild_fixture_indexes()
	return removed
/datum/world_edit_building_layout_state/proc/remove_fixture_at(turf/target_turf)
	if(!istype(target_turf))
		return FALSE
	var/removed = FALSE
	for(var/index = length(fixtures.object_placements), index >= 1, index--)
		var/list/object_placement = fixtures.object_placements[index]
		if(!islist(object_placement) || object_placement["turf"] != target_turf || "[object_placement["kind"]]" != "interior")
			continue
		fixtures.object_placements.Cut(index, index + 1)
		removed = TRUE
	if(removed)
		rebuild_fixture_indexes()
	return removed

/datum/world_edit_building_layout_state/proc/reset_validation_metrics()
	validation.privacy_violation_count = 0
	validation.reachability_failure_count = 0
	validation.repetition_conflict_count = 0
	validation.door_buffer_conflict_count = 0
	validation.window_conflict_count = 0
	validation.facade_conflict_count = 0
	validation.invalid_window_count = 0
	validation.service_wall_window_violation_count = 0
	validation.secure_wall_window_violation_count = 0
	validation.fixture_conflict_count = 0
	validation.route_conflict_count = 0
	validation.signature_failure_count = 0
	validation.divider_capacity_warning_count = 0
	validation.provider_path_not_in_build_count = 0
	validation.unknown_provider_count = 0
	validation.unique_provider_path_count = 0
	validation.unique_functional_provider_path_count = 0
	validation.unique_decorative_provider_path_count = 0
	validation.required_module_missing_count = 0
	validation.optional_module_missing_count = 0
	validation.required_module_not_placeable_count = 0
	validation.required_room_without_required_module_count = 0
	validation.loose_table_count = 0
	validation.loose_chair_count = 0
	validation.unpaired_chair_count = 0
	validation.table_chair_mosaic_count = 0
	validation.furniture_group_fragmented_count = 0
	validation.bed_without_access_count = 0
	validation.bed_outside_sleeping_count = 0
	validation.toilet_outside_sanitation_count = 0
	validation.medical_bed_outside_medical_count = 0
	validation.hydro_tray_outside_hydroponics_count = 0
	validation.weapon_rack_outside_armory_security_count = 0
	validation.module_max_per_room_violation_count = 0
	validation.module_max_per_building_violation_count = 0
	validation.repeat_group_violation_count = 0
	validation.room_overfilled_count = 0
	validation.route_blocked_by_furniture_count = 0
	validation.door_clearance_blocked_count = 0
	validation.scene_required_missing_count = 0
	validation.room_primary_scene_missing_count = 0
	validation.room_identity_missing_count = 0
	validation.room_scene_duplicate_count = 0
	validation.scene_slot_overflow_count = 0
	validation.common_scene_fragmentation_count = 0
	validation.excessive_small_social_groups_count = 0
	validation.private_room_without_bed_scene_count = 0
	validation.sanitation_without_sanitation_scene_count = 0
	validation.storage_without_storage_scene_count = 0
	validation.scene_blocks_route_count = 0
	validation.large_empty_unassigned_floor_count = 0
	validation.oversized_role_room_count = 0
	validation.unclaimed_interior_wall_count = 0
	validation.wall_outside_footprint_count = 0
	validation.wall_orphan_island_count = 0
	validation.wall_unmapped_interior_count = 0
	validation.wall_single_sided_internal_count = 0
	validation.thin_room_strip_count = 0
	validation.large_sparse_room_count = 0
	validation.corridor_ribbon_count = 0
	validation.layout_underfurnished_room_count = 0
	validation.layout_room_composition_missing_count = 0
	validation.layout_room_capacity_shortfall_count = 0
	validation.layout_required_adjacency_missing_count = 0
	validation.layout_required_adjacency_geometry_missing_count = 0
	validation.layout_unassigned_interior_turf_count = 0
	validation.layout_unassigned_interior_ratio_percent = 0
	validation.layout_unassigned_interior_excess_count = 0
	validation.layout_ownerless_open_bay_count = 0
	validation.layout_route_component_count = 0
	validation.layout_route_component_error_count = 0
	validation.layout_wall_stub_count = 0
	validation.layout_wall_notch_count = 0
	validation.layout_wall_stair_step_count = 0
	validation.layout_wall_misaligned_join_count = 0
	validation.layout_atomic_module_fragmentation_count = 0
	validation.layout_required_module_fallback_count = 0
	validation.layout_required_template_reject_count = 0
	validation.layout_optional_template_attempt_count = 0
	validation.layout_optional_template_reject_count = 0
	validation.layout_template_reject_ratio_percent = 0
	validation.layout_wall_cleanup_removed_count = 0
	validation.layout_wall_cleanup_unmapped_count = 0
	validation.layout_wall_cleanup_spur_count = 0
	validation.layout_wall_cleanup_ratio_percent = 0
	validation.layout_functional_room_count = 0
	validation.layout_target_functional_room_count = 0
	validation.layout_functional_room_count_gap = 0
	validation.layout_circulation_region_count = 0
	validation.layout_candidate_metric_mismatch_count = 0
	validation.layout_distinct_hard_valid_family_count = 0
	validation.layout_required_connection_missing_count = 0
	validation.layout_door_not_shared_wall_count = 0
	validation.layout_room_without_door_count = 0
	validation.layout_forbidden_room_window_count = 0
	validation.layout_empty_large_room_count = 0
	validation.layout_isolated_room_count = 0
	validation.layout_door_corner_count = 0
	validation.layout_door_not_on_shared_wall_count = 0
	validation.layout_door_no_shared_wall_count = 0
	validation.layout_door_short_segment_count = 0
	validation.layout_door_near_other_door_count = 0
	validation.layout_door_invalid_clearance_count = 0
	validation.layout_room_allocation_failed_count = 0
	validation.layout_room_bad_aspect_count = 0
	validation.layout_room_thin_strip_count = 0
	validation.layout_room_scene_capacity_failed_count = 0
	validation.layout_scene_required_missing_count = 0
	validation.layout_primary_anchor_missing_count = 0
	validation.layout_negative_space_missing_count = 0
	validation.layout_scene_blocks_negative_space_count = 0
	validation.layout_secondary_anchor_conflict_count = 0
	validation.layout_scene_overfill_count = 0
	validation.layout_scene_underfill_count = 0
	validation.layout_scene_budget_overflow_count = 0
	validation.layout_scene_budget_missing_required_count = 0
	validation.layout_duplicate_focal_scene_count = 0
	validation.layout_window_policy_violation_count = 0
	validation.layout_public_room_hard_closed_count = 0
	validation.layout_public_opening_missing_count = 0
	validation.layout_opposing_route_door_pair_count = 0
	validation.layout_corridor_wall_canyon_count = 0
	validation.layout_route_wall_canyon_length = 0
	validation.layout_excessive_wall_to_floor_ratio_count = 0
	validation.layout_template_geometry_reject_count = 0
	validation.layout_missing_wall_context_reject_count = 0
	validation.layout_hard_valid_candidate_shortage_count = 0
	validation.semantic_scene_route_block_count = 0
	validation.semantic_scene_door_clearance_block_count = 0
	validation.semantic_scene_required_missing_count = 0
	validation.semantic_room_primary_scene_missing_count = 0
	validation.semantic_major_object_without_scene_count = 0
	validation.semantic_pairing_error_count = 0
	validation.legacy_fixture_after_scene_count = 0
	validation.semantic_distribution_noise_score = 0
	validation.semantic_functional_coverage_percent = 100
	validation.semantic_route_clearance_percent = 100
	validation.mandatory_room_missing_count = 0
	validation.mandatory_room_no_bounds_count = 0
	validation.mandatory_room_no_access_count = 0
	validation.mandatory_pattern_missing_count = 0
	validation.mandatory_pattern_uncredited_count = 0
	validation.mandatory_pattern_failure_count = 0
	validation.mandatory_anchor_missing_count = 0
	validation.mandatory_fixture_access_unreachable_count = 0
	validation.reserved_walk_blocked_count = 0
	validation.door_cone_blocked_count = 0
	validation.door_corner_count = 0
	validation.double_wall_error_count = 0
	validation.double_wall_repair_count = 0
	validation.diagonal_only_contact_count = 0
	validation.diagonal_wall_repair_count = 0
	validation.raw_category_credit_count = 0
	validation.scatter_signature_credit_count = 0
	validation.semantic_credit_without_emitted_slots_count = 0
	validation.style_required_slot_missing_count = 0
	validation.wall_machinery_invalid_dir_count = 0
	validation.wall_machinery_no_wall_count = 0
	validation.infrastructure_required_missing_count = 0
	validation.infrastructure_route_block_count = 0
	validation.blocked_route_conflict_count = 0
	validation.blocked_room_conflict_count = 0
	validation.blocked_wall_conflict_count = 0
	validation.blocked_fixture_conflict_count = 0
	clear_validation_cache()

/datum/world_edit_building_layout_state/proc/register_layout_macro(macro_id, category, turf/anchor_turf, dir_value = SOUTH, list/covered_turfs = null, list/source_ids = null)
	if(!length("[macro_id]") || !istype(anchor_turf))
		return
	var/list/macro = list(
		"id" = "[macro_id]",
		"category" = length("[category]") ? "[category]" : "generic",
		"turf" = anchor_turf,
		"dir" = dir_value,
		"covered_turfs" = islist(covered_turfs) ? covered_turfs.Copy() : list(anchor_turf),
		"source_ids" = islist(source_ids) ? source_ids.Copy() : list(),
	)
	fixtures.layout_macros += list(macro)
	fixtures.layout_macro_counts["[macro_id]"] = (fixtures.layout_macro_counts["[macro_id]"] || 0) + 1

/datum/world_edit_building_layout_state/proc/register_cluster(cluster_id, placed_count)
	if(!length("[cluster_id]") || placed_count <= 0)
		return
	fixtures.cluster_counts["[cluster_id]"] = (fixtures.cluster_counts["[cluster_id]"] || 0) + placed_count

/datum/world_edit_building_layout_state/proc/register_signature(signature_id, placed_count)
	if(!length("[signature_id]") || placed_count <= 0)
		return
	fixtures.signature_counts["[signature_id]"] = (fixtures.signature_counts["[signature_id]"] || 0) + placed_count

/datum/world_edit_building_layout_state/proc/register_requirement(requirement_id, placed_count)
	if(!length("[requirement_id]") || placed_count <= 0)
		return
	fixtures.semantic_requirement_counts["[requirement_id]"] = (fixtures.semantic_requirement_counts["[requirement_id]"] || 0) + placed_count

/datum/world_edit_building_layout_state/proc/register_placed_requirement(requirement_id, placed_count)
	if(!length("[requirement_id]") || placed_count <= 0)
		return
	fixtures.placed_requirement_counts["[requirement_id]"] = (fixtures.placed_requirement_counts["[requirement_id]"] || 0) + placed_count

/datum/world_edit_building_layout_state/proc/clear_semantic_slot_reservations()
	fixtures.semantic_slot_reservation_by_turf.Cut()
	fixtures.semantic_slot_reserved_turfs.Cut()
	fixtures.semantic_slot_clearance_by_turf.Cut()
	validation.semantic_slot_reservation_conflict_count = 0

/datum/world_edit_building_layout_state/proc/reserve_semantic_slot(requirement_id, turf/target_turf)
	if(!length("[requirement_id]") || !istype(target_turf))
		return FALSE
	var/clearance_owner = "[fixtures.semantic_slot_clearance_by_turf[target_turf] || ""]"
	if(length(clearance_owner) && clearance_owner != "[requirement_id]")
		validation.semantic_slot_reservation_conflict_count++
		return FALSE
	var/owner = "[fixtures.semantic_slot_reservation_by_turf[target_turf] || ""]"
	if(length(owner) && owner != "[requirement_id]")
		validation.semantic_slot_reservation_conflict_count++
		return FALSE
	fixtures.semantic_slot_reservation_by_turf[target_turf] = "[requirement_id]"
	var/list/turfs = fixtures.semantic_slot_reserved_turfs["[requirement_id]"]
	if(!islist(turfs))
		turfs = list()
		fixtures.semantic_slot_reserved_turfs["[requirement_id]"] = turfs
	append_unique_turf(turfs, target_turf)
	return TRUE

/datum/world_edit_building_layout_state/proc/get_semantic_slot_owner(turf/target_turf)
	if(!istype(target_turf))
		return ""
	return "[fixtures.semantic_slot_reservation_by_turf[target_turf] || ""]"

/datum/world_edit_building_layout_state/proc/reserve_semantic_slot_clearance(requirement_id, turf/target_turf)
	if(!length("[requirement_id]") || !istype(target_turf))
		return FALSE
	var/slot_owner = "[fixtures.semantic_slot_reservation_by_turf[target_turf] || ""]"
	if(length(slot_owner) && slot_owner != "[requirement_id]")
		validation.semantic_slot_reservation_conflict_count++
		return FALSE
	var/clearance_owner = "[fixtures.semantic_slot_clearance_by_turf[target_turf] || ""]"
	if(length(clearance_owner) && clearance_owner != "[requirement_id]")
		validation.semantic_slot_reservation_conflict_count++
		return FALSE
	fixtures.semantic_slot_clearance_by_turf[target_turf] = "[requirement_id]"
	return TRUE

/datum/world_edit_building_layout_state/proc/get_semantic_slot_clearance_owner(turf/target_turf)
	if(!istype(target_turf))
		return ""
	return "[fixtures.semantic_slot_clearance_by_turf[target_turf] || ""]"

/datum/world_edit_building_layout_state/proc/get_category_budget(category)
	var/budget = fixtures.category_budgets["[category]"]
	if(isnum(budget) && budget > 0)
		return budget
	budget = semantic_plan?.object_budgets["[category]"]
	if(isnum(budget) && budget > 0)
		return budget
	budget = archetype?.object_budgets["[category]"]
	if(isnum(budget) && budget > 0)
		return budget
	return WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS
