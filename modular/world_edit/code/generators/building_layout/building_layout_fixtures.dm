/datum/world_edit_generator/building_layout/proc/get_building_cluster_requirement_id(datum/world_edit_building_cluster_spec/cluster_spec)
	if(!istype(cluster_spec))
		return ""
	if(length(cluster_spec.count_signature_id))
		return "[cluster_spec.count_signature_id]"
	if(length(cluster_spec.signature_id))
		return "[cluster_spec.signature_id]"
	if(length(cluster_spec.count_cluster_id))
		return "[cluster_spec.count_cluster_id]"
	return "[cluster_spec.id]"

/datum/world_edit_generator/building_layout/proc/semantic_slot_reserved_for_other(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, turf/target_turf)
	if(!istype(state) || !istype(target_turf))
		return FALSE
	var/owner = state.get_semantic_slot_owner(target_turf)
	if(!length(owner))
		return FALSE
	if(!istype(cluster_spec))
		return TRUE
	return owner != get_building_cluster_requirement_id(cluster_spec)

/datum/world_edit_generator/building_layout/proc/building_cluster_can_use_procedural_pattern(datum/world_edit_building_cluster_spec/cluster_spec)
	if(!istype(cluster_spec) || !length(cluster_spec.pattern))
		return FALSE
	if(cluster_spec.required && cluster_spec.pattern == "object")
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/place_building_compact_substitute_for_cluster(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/parent_spec, needed_count, major)
	if(!istype(state) || !istype(parent_spec) || needed_count <= 0)
		return 0
	var/datum/world_edit_building_cluster_spec/substitute_spec = get_building_compact_substitute_spec(state, parent_spec)
	if(!istype(substitute_spec))
		return 0
	substitute_spec.force_placement = TRUE
	substitute_spec.min_count = min(max(round(text2num("[needed_count]") || 1), 1), max(substitute_spec.max_count, 1))
	substitute_spec.max_count = substitute_spec.min_count
	var/before_count = get_building_placed_requirement_count(state, get_building_cluster_requirement_id(parent_spec), parent_spec.id, parent_spec.signature_id)
	if(place_building_cluster_spec(state, substitute_spec, major))
		var/after_count = get_building_placed_requirement_count(state, get_building_cluster_requirement_id(parent_spec), parent_spec.id, parent_spec.signature_id)
		return max(after_count - before_count, 0)
	return 0

/datum/world_edit_generator/building_layout/proc/place_building_cluster_spec(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, major)
	if(!istype(state) || !istype(cluster_spec) || state.fixtures.fixture_count >= WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		return FALSE
	if(cluster_spec.compact_substitute_only)
		return FALSE
	var/list/cluster_report = list(
		"cluster_id" = cluster_spec.id,
		"pattern" = cluster_spec.pattern,
		"slot" = cluster_spec.slot,
		"category" = cluster_spec.category,
		"phase" = cluster_spec.phase,
		"required" = cluster_spec.required ? TRUE : FALSE,
		"major" = major ? TRUE : FALSE,
	)
	if(!length(cluster_spec.macro_id))
		cluster_spec.macro_id = get_building_macro_id_for_cluster(cluster_spec, state)
	var/requested_macro_id = "[cluster_spec.macro_id]"
	cluster_report["macro_id"] = requested_macro_id
	if(is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
		var/module_placed = place_building_modules_for_cluster(state, cluster_spec, major)
		cluster_report["status"] = module_placed > 0 ? "module_satisfied" : "module_failed"
		cluster_report["placed"] = module_placed
		state.add_template_cluster_report(cluster_report)
		return module_placed > 0
	var/has_template_path = building_cluster_has_template_chunk(cluster_spec, state)
	if(length(cluster_spec.macro_id) && cluster_spec.macro_id != requested_macro_id)
		cluster_report["resolved_macro_id"] = cluster_spec.macro_id
	cluster_report["has_template_path"] = has_template_path ? TRUE : FALSE
	if(!has_template_path)
		// Capture why template path is missing — the reason is already recorded via add_template_reject_reason()
		// inside building_cluster_has_template_chunk(). Summarize the dominant reject reason for this cluster.
		var/list/template_reject_reason_counts = state.validation.template_reject_reason_counts
		var/best_reason = ""
		var/best_count = 0
		for(var/reason_id in template_reject_reason_counts)
			if(template_reject_reason_counts[reason_id] > best_count)
				best_reason = reason_id
				best_count = template_reject_reason_counts[reason_id]
		cluster_report["has_template_path_detail"] = length(best_reason) ? best_reason : "unknown"
	var/placed = 0
	var/template_placed = 0
	var/effective_minimum = get_effective_cluster_min_count(state, cluster_spec)
	var/declared_minimum = max(round(text2num("[cluster_spec.min_count]") || 0), 0)
	var/desired_count = max(effective_minimum, declared_minimum)
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	cluster_report["requirement_id"] = requirement_id
	cluster_report["effective_minimum"] = effective_minimum
	var/already_placed = round(text2num("[state.fixtures.placed_requirement_counts["[requirement_id]"]]") || 0)
	if(length(cluster_spec.id))
		already_placed = max(already_placed, round(text2num("[state.fixtures.placed_requirement_counts["[cluster_spec.id]"]]") || 0))
	if(length(cluster_spec.signature_id))
		already_placed = max(already_placed, round(text2num("[state.fixtures.placed_requirement_counts["[cluster_spec.signature_id]"]]") || 0))
	if(!cluster_spec.force_placement && effective_minimum > 0 && already_placed >= effective_minimum && (!length(cluster_spec.compact_substitute_id) || already_placed >= desired_count))
		cluster_report["status"] = "already_satisfied"
		cluster_report["already_placed"] = already_placed
		state.add_template_cluster_report(cluster_report)
		return TRUE
	var/target_count = get_scaled_cluster_target_count(state, cluster_spec)
	cluster_report["already_placed"] = already_placed
	cluster_report["target_count"] = target_count
	if(has_template_path)
		var/template_goal = max(effective_minimum - already_placed, 0)
		if(template_goal <= 0)
			template_goal = 1
		var/template_attempts = 0
		while(placed < template_goal && template_attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
			template_attempts++
			var/template_placed_now = place_building_template_chunk_for_cluster(state, cluster_spec, major && placed <= 0 && already_placed <= 0)
			if(template_placed_now <= 0)
				break
			template_placed += template_placed_now
			placed += template_placed_now
		cluster_report["template_placed"] = template_placed
		cluster_report["template_attempts"] = template_attempts
		if(template_placed > 0)
			state.add_warning("Template-first placement partially succeeded for cluster '[cluster_spec.id]'.")
		if(!cluster_spec.force_placement && ((effective_minimum <= 0 && placed > 0) || (already_placed + placed >= effective_minimum)) && (!length(cluster_spec.compact_substitute_id) || (already_placed + placed) >= desired_count))
			cluster_report["status"] = "template_satisfied"
			cluster_report["total_placed"] = already_placed + placed
			state.add_template_cluster_report(cluster_report)
			return TRUE
		if(cluster_spec.required && !building_cluster_can_use_procedural_pattern(cluster_spec))
			if(effective_minimum > 0 || target_count > 0)
				state.validation.forbidden_fallback_count++
				state.add_template_reject_reason("required_cluster_shortfall", list(
					"scope" = "cluster",
					"cluster_id" = cluster_spec.id,
					"requirement_id" = requirement_id,
					"template_placed" = template_placed,
					"effective_minimum" = effective_minimum,
					"target_count" = target_count,
					"macro_id" = cluster_spec.macro_id,
				))
				state.add_warning("Template-first placement failed or was incomplete for required cluster '[cluster_spec.id]'.")
			cluster_report["status"] = "required_cluster_shortfall"
			state.add_template_cluster_report(cluster_report)
			return FALSE
		if(!building_cluster_can_use_procedural_pattern(cluster_spec))
			cluster_report["status"] = placed > 0 ? "template_partial_no_procedural_pattern" : "template_failed_no_procedural_pattern"
			state.add_template_cluster_report(cluster_report)
			return placed > 0
	else if(!building_cluster_can_use_procedural_pattern(cluster_spec))
		if(cluster_spec.required)
			state.validation.forbidden_fallback_count++
			state.add_template_reject_reason("required_cluster_shortfall", list(
				"scope" = "cluster",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"template_placed" = template_placed,
				"effective_minimum" = effective_minimum,
				"target_count" = target_count,
				"macro_id" = cluster_spec.macro_id,
				"detail" = "missing_template_macro_or_chunk",
			))
			state.add_warning("Required cluster '[cluster_spec.id]' lacks a template and cannot use a generic procedural object.")
		cluster_report["status"] = "missing_template_path_no_procedural_pattern"
		state.add_template_cluster_report(cluster_report)
		return FALSE
	switch(cluster_spec.pattern)
		if("signature_workshop_wall", "signature_rack_aisles", "signature_hydro_rows", "signature_cook_line", "signature_bed_rows", "signature_treatment_bay", "signature_office_suite", "signature_security_counter", "signature_living_nook", "signature_engineering_bay", "signature_lab_bench")
			placed = place_building_signature_cluster(state, cluster_spec, target_count)
		if("run", "counter_line", "staging_group")
			placed = place_fixture_run(state, cluster_spec, target_count)
		else
			var/attempts = 0
			while(placed < target_count && attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
				attempts++
				var/unit_placed = 0
				switch(cluster_spec.pattern)
					if("table_cluster")
						unit_placed = place_table_cluster(state, cluster_spec)
					if("wall_object")
						unit_placed = place_wall_fixture(state, cluster_spec)
					if("paired_object")
						unit_placed = place_paired_fixture_objects(state, cluster_spec)
					if("object")
						unit_placed = place_fixture_object(state, cluster_spec)
				if(unit_placed <= 0)
					break
				placed += unit_placed
	if(!has_template_path)
		placed += template_placed
	var/current_placed = get_building_placed_requirement_count(state, requirement_id, cluster_spec.id, cluster_spec.signature_id)
	if(cluster_spec.required && desired_count > 0 && current_placed < desired_count && length(cluster_spec.compact_substitute_id))
		var/compact_placed = place_building_compact_substitute_for_cluster(state, cluster_spec, desired_count - current_placed, major)
		if(compact_placed > 0)
			placed += compact_placed
			current_placed += compact_placed
			cluster_report["compact_substitute_id"] = cluster_spec.compact_substitute_id
			cluster_report["compact_placed"] = compact_placed
			if(current_placed >= desired_count)
				cluster_report["status"] = "compact_satisfied"
				cluster_report["placed"] = placed
				cluster_report["total_placed"] = current_placed
				state.add_template_cluster_report(cluster_report)
				return TRUE
	cluster_report["placed"] = placed
	cluster_report["status"] = placed > 0 ? "placed" : "failed"
	state.add_template_cluster_report(cluster_report)
	return placed > 0

/datum/world_edit_generator/building_layout/proc/building_cluster_has_template_chunk(datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_layout_state/state = null)
	if(!istype(cluster_spec))
		return FALSE
	var/macro_id = length(cluster_spec.macro_id) ? cluster_spec.macro_id : get_building_macro_id_for_cluster(cluster_spec, state)
	if(!length(macro_id))
		if(istype(state))
			state.add_template_reject_reason("template_macro_not_resolved", list(
				"scope" = "has_template_chunk",
				"cluster_id" = cluster_spec.id,
				"pattern" = cluster_spec.pattern,
				"slot" = cluster_spec.slot,
				"category" = cluster_spec.category,
			))
		return FALSE
	var/resolved_macro_id = resolve_existing_building_template_chunk_id(macro_id)
	var/datum/world_edit_building_template_chunk/chunk = length(resolved_macro_id) ? get_building_template_chunk(resolved_macro_id) : null
	if(!istype(chunk))
		if(istype(state))
			state.add_template_reject_reason("template_chunk_not_found", list(
				"scope" = "has_template_chunk",
				"cluster_id" = cluster_spec.id,
				"macro_id" = macro_id,
				"resolved_macro_id" = resolved_macro_id,
				"pattern" = cluster_spec.pattern,
				"slot" = cluster_spec.slot,
				"category" = cluster_spec.category,
			))
		return FALSE
	if(!length(chunk.cells))
		if(istype(state))
			state.add_template_reject_reason("template_chunk_no_cells", list(
				"scope" = "has_template_chunk",
				"cluster_id" = cluster_spec.id,
				"macro_id" = macro_id,
				"resolved_macro_id" = resolved_macro_id,
				"pattern" = cluster_spec.pattern,
				"slot" = cluster_spec.slot,
				"category" = cluster_spec.category,
			))
		return FALSE
	cluster_spec.macro_id = resolved_macro_id
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_macro_id_for_cluster(datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_layout_state/state = null)
	if(!istype(cluster_spec))
		return ""
	if(length(cluster_spec.macro_id))
		return cluster_spec.macro_id

	var/is_micro = FALSE
	if(istype(state) && is_building_compact_or_micro_state(state))
		is_micro = TRUE

	if(cluster_spec.category == "light")
		return is_micro ? "micro_light_chunk" : "infrastructure_light_chunk"
	if(cluster_spec.category == "apc")
		return is_micro ? "micro_power_chunk" : "infrastructure_power_chunk"
	if(cluster_spec.category == "air_alarm")
		return is_micro ? "micro_air_alarm_chunk" : "infrastructure_air_alarm_chunk"
	if(cluster_spec.category == "fire_alarm")
		return is_micro ? "micro_fire_alarm_chunk" : "infrastructure_fire_alarm_chunk"
	if(cluster_spec.category == "light_switch")
		return is_micro ? "micro_switch_chunk" : "infrastructure_switch_chunk"
	switch(cluster_spec.pattern)
		if("signature_workshop_wall")
			return "workshop_wall_chunk"
		if("signature_rack_aisles")
			return "rack_run_chunk"
		if("signature_bed_rows", "signature_living_nook")
			return "bed_niche_chunk"
		if("signature_security_counter", "counter_line")
			return "checkpoint_counter_chunk"
		if("signature_hydro_rows")
			return "hydro_rows_chunk"
		if("signature_cook_line")
			return "cook_line_chunk"
		if("signature_treatment_bay")
			return is_micro ? "micro_med_chunk" : "treatment_bay_chunk"
		if("signature_office_suite")
			return is_micro ? "micro_office_chunk" : "office_suite_chunk"
		if("signature_engineering_bay")
			return "engineering_service_chunk"
		if("signature_lab_bench")
			return is_micro ? "micro_table_chunk" : "lab_bench_chunk"
		if("run")
			if(cluster_spec.category in list("rack", "cabinet", "bed"))
				var/room_area = length(get_fixture_candidate_turfs_for_anchors(state, cluster_spec.anchors))
				var/use_island = ("focus_center" in cluster_spec.anchors) || (!cluster_spec.wall_required && room_area >= 20)
				if(use_island && !is_micro)
					return "island_[cluster_spec.category]_chunk"
				return is_micro ? "micro_[cluster_spec.category]_chunk" : "[cluster_spec.category]_run_chunk"
		if("wall_object")
			switch(cluster_spec.category)
				if("seed_storage")
					return ""
				if("cabinet", "medical_storage", "sample_storage", "cold_storage")
					return "wall_cabinet_chunk"
				if("rack", "weapon_rack")
					return "wall_rack_chunk"
				if("console")
					return "wall_console_chunk"
				if("sanitation")
					return "wall_toilet_chunk"
				if("kitchen_machine")
					return "wall_sink_chunk"
				if("medical_bed")
					return "clinic_bed_chunk"
			return "wall_fixture_chunk"
		if("table_cluster")
			var/room_area = length(get_fixture_candidate_turfs_for_anchors(state, cluster_spec.anchors))
			if(room_area >= 40 && !is_micro)
				return "large_island_table_chunk"
			return is_micro ? "micro_table_chunk" : "island_table_chunk"
		if("object", "paired_object")
			if(cluster_spec.category == "table")
				return is_micro ? "micro_table_chunk" : "island_table_chunk"
			if(cluster_spec.category == "bed")
				return is_micro ? "micro_bed_chunk" : "island_bed_chunk"
			if(cluster_spec.category == "chair")
				return is_micro ? "micro_table_chunk" : "island_chair_group_chunk"
	return ""

/datum/world_edit_generator/building_layout/proc/inherit_building_cluster_count_context(datum/world_edit_building_cluster_spec/child_spec, datum/world_edit_building_cluster_spec/parent_spec)
	if(!istype(child_spec) || !istype(parent_spec))
		return child_spec
	child_spec.count_cluster_id = length(parent_spec.count_cluster_id) ? parent_spec.count_cluster_id : parent_spec.id
	child_spec.count_signature_id = length(parent_spec.count_signature_id) ? parent_spec.count_signature_id : parent_spec.signature_id
	child_spec.semantic_credit = length(parent_spec.semantic_credit) ? parent_spec.semantic_credit : get_building_cluster_requirement_id(parent_spec)
	child_spec.failure_severity = parent_spec.failure_severity
	child_spec.acceptance_counter = length(parent_spec.acceptance_counter) ? parent_spec.acceptance_counter : "[child_spec.semantic_credit]_count"
	if(!length(child_spec.macro_id) && length(parent_spec.macro_id))
		child_spec.macro_id = parent_spec.macro_id
	return child_spec

/datum/world_edit_generator/building_layout/proc/get_building_fixture_count_credit(datum/world_edit_building_cluster_spec/cluster_spec, slot, category)
	if(!istype(cluster_spec))
		return 0
	if("[slot]" == "chair" && "[category]" == "chair" && cluster_spec.category != "chair")
		return 0
	return 1

/datum/world_edit_generator/building_layout/proc/prepare_building_fixture_scale(datum/world_edit_building_layout_state/state)
	state.fixtures.usable_fixture_area = 0
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		if(state.can_place_fixture(floor_turf))
			state.fixtures.usable_fixture_area++
	state.fixtures.category_budgets.Cut()
	var/usable_area = max(state.fixtures.usable_fixture_area, length(state.geometry.floor_turfs) - length(state.geometry.primary_route_turfs))
	var/list/object_budgets = islist(state.semantic_plan?.object_budgets) ? state.semantic_plan.object_budgets : state.archetype.object_budgets
	for(var/category as anything in object_budgets)
		var/base_budget = round(text2num("[object_budgets[category]]") || 0)
		if(base_budget <= 0)
			continue
		var/area_bonus = max(0, round((usable_area - 24) / 14))
		if(state.archetype?.id == "living")
			switch("[category]")
				if("table")
					area_bonus += max(0, round((usable_area - 18) / 10))
				if("chair")
					area_bonus += max(0, round((usable_area - 16) / 8))
				if("cabinet")
					area_bonus += max(0, round((usable_area - 28) / 18))
		state.fixtures.category_budgets["[category]"] = min(WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS, max(base_budget, base_budget + area_bonus))

/datum/world_edit_generator/building_layout/proc/get_cluster_effective_needs_wall(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_place_rule/place_rule)
	if(istype(cluster_spec) && cluster_spec.slot == "toilet" && cluster_spec.category == "sanitation")
		return FALSE
	if(istype(cluster_spec) && !cluster_spec.wall_required && cluster_spec.pattern != "wall_object" && is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
		return FALSE
	var/needs_wall = cluster_spec.wall_required || place_rule.needs_wall
	if(!needs_wall)
		return FALSE
	var/macro_id = length(cluster_spec.macro_id) ? cluster_spec.macro_id : get_building_macro_id_for_cluster(cluster_spec, state)
	if(findtext(macro_id, "island") || cluster_spec.pattern == "table_cluster")
		return FALSE
	// Allow micro chunks to bypass strict wall requirement to avoid forbidden_fallback errors in tiny rooms
	if(findtext(macro_id, "micro") && is_building_compact_or_micro_state(state))
		return FALSE
	// If the template chunk has no wall-required cells, placement should not demand an adjacent wall
	if(length(macro_id))
		var/resolved_macro_id = resolve_existing_building_template_chunk_id(macro_id)
		var/datum/world_edit_building_template_chunk/chunk = length(resolved_macro_id) ? get_building_template_chunk(resolved_macro_id) : null
		if(istype(chunk) && length(chunk.cells))
			var/all_cells_wall_optional = TRUE
			for(var/datum/world_edit_building_template_cell/cell as anything in chunk.cells)
				if(cell.wall_required)
					all_cells_wall_optional = FALSE
					break
			if(all_cells_wall_optional)
				return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_cluster_anchor_area(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	var/area = 0
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/effective_needs_wall = get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
	for(var/turf/floor_turf as anything in get_fixture_candidate_turfs_for_anchors(state, cluster_spec.anchors))
		if(!building_fixture_candidate_has_entry_access(state, floor_turf, cluster_spec))
			continue
		if(!state.can_place_fixture(floor_turf))
			continue
		if(effective_needs_wall && !length(get_adjacent_wall_dirs_for_state(state, floor_turf)))
			continue
		if(!fixture_turf_matches_anchor(state, floor_turf, cluster_spec.anchors))
			continue
		var/fallback_dir = get_cardinal_dir_toward(floor_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
		if(!fixture_turf_satisfies_place_rule(state, floor_turf, place_rule, fallback_dir, effective_needs_wall))
			continue
		area++
	return area

/datum/world_edit_generator/building_layout/proc/get_fixture_candidate_turfs_for_anchors(datum/world_edit_building_layout_state/state, list/anchor_ids)
	if(!istype(state))
		return list()
	if(!islist(anchor_ids) || !length(anchor_ids))
		return state.geometry.floor_turfs
	var/list/candidates = list()
	var/list/candidate_lookup = list()
	for(var/anchor_id as anything in anchor_ids)
		var/anchor_key = "[anchor_id]"
		for(var/turf/zone_turf as anything in state.get_zone_turfs(anchor_key))
			if(istype(zone_turf) && !candidate_lookup[zone_turf])
				candidates += zone_turf
				candidate_lookup[zone_turf] = TRUE
		for(var/turf/anchor_turf as anything in state.get_anchor_turfs(anchor_key))
			if(istype(anchor_turf) && !candidate_lookup[anchor_turf])
				candidates += anchor_turf
				candidate_lookup[anchor_turf] = TRUE
	return candidates

/datum/world_edit_generator/building_layout/proc/is_building_infrastructure_category(category)
	return "[category]" in list("light", "apc", "air_alarm", "fire_alarm", "light_switch")

/datum/world_edit_generator/building_layout/proc/building_fixture_candidate_has_entry_access(datum/world_edit_building_layout_state/state, turf/target_turf, datum/world_edit_building_cluster_spec/cluster_spec)
	if(!istype(state) || !istype(target_turf) || !istype(cluster_spec) || !is_building_infrastructure_category(cluster_spec.category))
		return TRUE
	var/list/reachable = get_building_validation_reachable_floor_lookup(state)
	if(reachable[target_turf])
		return TRUE
	for(var/check_dir in GLOB.cardinals)
		if(reachable[get_step(target_turf, check_dir)])
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/is_building_compact_or_micro_state(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return FALSE
	var/degrade_level = "[state.config["size_degrade_level"] || WORLD_EDIT_BUILDING_DEGRADE_NONE]"
	var/size_profile = "[state.config["size_profile"] || WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD]"
	var/geometry_width = round(text2num("[state.geometry?.bounds?["width"]]") || 0)
	var/geometry_height = round(text2num("[state.geometry?.bounds?["height"]]") || 0)
	var/compact_geometry = geometry_width > 0 && geometry_height > 0 && geometry_width <= 13 && geometry_height <= 13
	return size_profile == WORLD_EDIT_BUILDING_SIZE_PROFILE_COMPACT || compact_geometry || GLOB.world_edit_helpers.parse_bool(state.config["program_shedding"]) || GLOB.world_edit_helpers.parse_bool(state.config["micro_layout"]) || (degrade_level in list(WORLD_EDIT_BUILDING_DEGRADE_COMPACT, WORLD_EDIT_BUILDING_DEGRADE_MICRO))

/datum/world_edit_generator/building_layout/proc/can_building_cluster_use_broad_fallback_anchors(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(!istype(cluster_spec) || !cluster_spec.required)
		return TRUE
	if(is_building_infrastructure_category(cluster_spec.category))
		return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/add_building_fallback_anchor_id(list/anchor_ids, list/anchor_lookup, anchor_id)
	if(!islist(anchor_ids) || !islist(anchor_lookup) || !length("[anchor_id]"))
		return
	var/anchor_key = "[anchor_id]"
	if(anchor_lookup[anchor_key])
		return
	anchor_ids += anchor_key
	anchor_lookup[anchor_key] = TRUE

/datum/world_edit_generator/building_layout/proc/build_required_cluster_fallback_anchor_ids(datum/world_edit_building_layout_state/state, list/original_anchor_ids, datum/world_edit_building_cluster_spec/cluster_spec)
	var/list/fallback_anchor_ids = list()
	var/list/fallback_lookup = list()
	if(islist(original_anchor_ids))
		for(var/anchor_id as anything in original_anchor_ids)
			add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
	if(!istype(state) || !istype(cluster_spec))
		return fallback_anchor_ids

	if(!can_building_cluster_use_broad_fallback_anchors(state, cluster_spec))
		return fallback_anchor_ids

	add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, state.semantic_plan?.primary_zone_id)
	add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, state.semantic_plan?.hub_zone_id)
	add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, "focus_center")
	add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, "aisle_edge")

	var/category = "[cluster_spec.category]"
	var/slot = "[cluster_spec.slot]"
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(slot, category)
	var/needs_wall = get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
	if(needs_wall)
		for(var/anchor_id as anything in list("wall_anchor", "service_wall", "storage_wall", "machine_wall", "corner_anchor"))
			add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)

	switch(category)
		if("rack")
			for(var/anchor_id as anything in list("rack_aisle", "storage_wall", "loading_axis", "service_wall", "wall_anchor"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("cabinet", "medical_storage", "seed_storage", "sample_storage", "cold_storage")
			for(var/anchor_id as anything in list("storage_wall", "service_wall", "cold_storage_wall", "filing_wall_anchor", "wall_anchor"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("table")
			for(var/anchor_id as anything in list("counter_line_turf", "counter_front", "serving_edge", "desk_anchor", "lab_bench", "focus_center"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("console", "security_console", "apc", "air_alarm", "fire_alarm", "light_switch")
			for(var/anchor_id as anything in list("secure_side", "desk_anchor", "engineering_wall", "lab_wall", "service_wall", "wall_anchor", "entry_buffer"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("barrier")
			for(var/anchor_id as anything in list("barrier_line", "ritual_axis", "counter_line_turf", "public_side"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("hydro_tray")
			for(var/anchor_id as anything in list("hydro_row", "greenhouse_band", state.semantic_plan?.primary_zone_id))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("medical_bed")
			for(var/anchor_id as anything in list("treatment_bay", "treatment_wall", state.semantic_plan?.primary_zone_id))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("kitchen_machine", "water_or_chem")
			for(var/anchor_id as anything in list("service_wall", "machine_wall", "cold_storage_wall", "wall_anchor"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("engineering_machine", "weapon_rack")
			for(var/anchor_id as anything in list("engineering_bay", "engineering_wall", "machine_wall", "service_wall", "wall_anchor"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)
		if("lab_machine")
			for(var/anchor_id as anything in list("lab_bench", "lab_wall", "machine_wall", "service_wall", "wall_anchor"))
				add_building_fallback_anchor_id(fallback_anchor_ids, fallback_lookup, anchor_id)

	return fallback_anchor_ids

/datum/world_edit_generator/building_layout/proc/get_cluster_preflight_anchor_ids(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/default_anchor_ids)
	if(istype(state) && istype(cluster_spec))
		var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
		var/list/planned_anchor_ids = state.fixtures.semantic_slot_anchor_sets[cluster_spec.id]
		if(!islist(planned_anchor_ids) || !length(planned_anchor_ids))
			planned_anchor_ids = state.fixtures.semantic_slot_anchor_sets[requirement_id]
		if(islist(planned_anchor_ids) && length(planned_anchor_ids))
			return planned_anchor_ids
	return islist(default_anchor_ids) ? default_anchor_ids : list()

/datum/world_edit_generator/building_layout/proc/building_compact_substitute_preserves_semantics(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/parent_spec, datum/world_edit_building_cluster_spec/substitute_spec)
	if(!istype(parent_spec) || !istype(substitute_spec))
		return FALSE
	if(!parent_spec.required)
		return TRUE
	var/parent_capability = get_building_fixture_required_capability(parent_spec.slot, parent_spec.category)
	var/substitute_capability = get_building_fixture_required_capability(substitute_spec.slot, substitute_spec.category)
	if(length(parent_capability) && length(substitute_capability) && parent_capability != substitute_capability)
		return FALSE
	var/datum/world_edit_building_place_rule/parent_rule = resolve_building_place_rule(parent_spec.slot, parent_spec.category)
	var/datum/world_edit_building_place_rule/substitute_rule = resolve_building_place_rule(substitute_spec.slot, substitute_spec.category)
	if(get_cluster_effective_needs_wall(state, parent_spec, parent_rule) && !get_cluster_effective_needs_wall(state, substitute_spec, substitute_rule))
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/get_building_compact_substitute_spec(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/parent_spec)
	if(!istype(state) || !istype(state.semantic_plan) || !istype(parent_spec) || !length(parent_spec.compact_substitute_id))
		return null
	var/datum/world_edit_building_cluster_spec/source_spec = state.semantic_plan.get_cluster_spec_by_id(parent_spec.compact_substitute_id)
	if(!istype(source_spec) || !source_spec.compact_substitute_only)
		return null
	if(!building_compact_substitute_preserves_semantics(state, parent_spec, source_spec))
		return null
	var/datum/world_edit_building_cluster_spec/substitute_spec = source_spec.clone()
	var/source_macro_id = substitute_spec.macro_id
	if(parent_spec.required && is_building_semantic_furniture_slot(parent_spec.slot, parent_spec.category))
		substitute_spec.anchors = islist(parent_spec.anchors) ? parent_spec.anchors.Copy() : list()
	substitute_spec.required = parent_spec.required
	substitute_spec.signature_required = parent_spec.signature_required
	substitute_spec.failure_severity = parent_spec.failure_severity
	substitute_spec.compact_substitute_only = FALSE
	inherit_building_cluster_count_context(substitute_spec, parent_spec)
	substitute_spec.macro_id = source_macro_id
	return substitute_spec

/datum/world_edit_generator/building_layout/proc/compute_zone_wall_slot_capacity(datum/world_edit_building_layout_state/state, zone_id, list/anchor_ids = null)
	if(!istype(state) || !length("[zone_id]"))
		return 0
	var/list/candidates = islist(anchor_ids) && length(anchor_ids) ? get_fixture_candidate_turfs_for_anchors(state, anchor_ids) : state.get_zone_turfs(zone_id)
	var/capacity = 0
	for(var/turf/candidate_turf as anything in candidates)
		if(!istype(candidate_turf))
			continue
		if(state.get_zone(candidate_turf) != "[zone_id]")
			continue
		if(!state.can_place_fixture(candidate_turf))
			continue
		if(!length(get_adjacent_wall_dirs_for_state(state, candidate_turf)))
			continue
		capacity++
	return capacity

/datum/world_edit_generator/building_layout/proc/get_building_cluster_wall_slot_requirement(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(!istype(state) || !istype(cluster_spec))
		return 0
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	if(!get_cluster_effective_needs_wall(state, cluster_spec, place_rule))
		return 0
	var/required_count = max(round(text2num("[cluster_spec.min_count]") || 0), 0)
	var/datum/world_edit_building_cluster_spec/substitute_spec = get_building_compact_substitute_spec(state, cluster_spec)
	if(istype(substitute_spec))
		var/datum/world_edit_building_place_rule/substitute_rule = resolve_building_place_rule(substitute_spec.slot, substitute_spec.category)
		if(get_cluster_effective_needs_wall(state, substitute_spec, substitute_rule))
			required_count = min(required_count, max(round(text2num("[substitute_spec.min_count]") || 0), 0))
	return required_count

/datum/world_edit_generator/building_layout/proc/count_building_cluster_fixture_capacity_for_anchors(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/anchor_ids)
	if(!istype(state) || !istype(cluster_spec))
		return 0
	var/capacity = 0
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/effective_needs_wall = get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
	for(var/turf/floor_turf as anything in get_fixture_candidate_turfs_for_anchors(state, anchor_ids))
		if(!building_fixture_candidate_has_entry_access(state, floor_turf, cluster_spec))
			continue
		var/owner = state.get_semantic_slot_owner(floor_turf)
		if(length(owner) && owner != requirement_id)
			continue
		if(!state.can_place_fixture(floor_turf))
			continue
		if(effective_needs_wall && !length(get_adjacent_wall_dirs_for_state(state, floor_turf)))
			continue
		if(!fixture_turf_matches_anchor(state, floor_turf, anchor_ids))
			continue
		if(!building_fixture_matches_semantic_zone_contract(state, floor_turf, cluster_spec.slot, cluster_spec.category, cluster_spec))
			continue
		var/fallback_dir = get_cardinal_dir_toward(floor_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
		var/list/place_context = (effective_needs_wall && is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category)) ? build_building_module_front_clear_place_context(state, floor_turf, place_rule, fallback_dir, effective_needs_wall, cluster_spec, anchor_ids) : build_building_fixture_place_context(state, floor_turf, place_rule, fallback_dir, effective_needs_wall, cluster_spec, anchor_ids)
		if(!islist(place_context))
			continue
		capacity++
	return capacity

/datum/world_edit_generator/building_layout/proc/count_building_cluster_template_capacity_for_anchors(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/anchor_ids)
	if(!istype(state) || !istype(cluster_spec))
		return 0
	var/macro_id = length(cluster_spec.macro_id) ? cluster_spec.macro_id : get_building_macro_id_for_cluster(cluster_spec, state)
	if(!length(macro_id))
		return 0
	var/resolved_macro_id = resolve_existing_building_template_chunk_id(macro_id)
	if(length(resolved_macro_id))
		cluster_spec.macro_id = resolved_macro_id
	var/datum/world_edit_building_template_chunk/chunk = length(resolved_macro_id) ? get_building_template_chunk(resolved_macro_id) : null
	if(!istype(chunk) || !length(chunk.cells))
		return 0
	var/list/candidate_data = build_template_chunk_candidate_turfs(state, cluster_spec, chunk, anchor_ids)
	var/list/candidates = candidate_data["turfs"]
	return (islist(candidates) ? length(candidates) : 0) * get_building_template_chunk_credit_count(cluster_spec, chunk)

/datum/world_edit_generator/building_layout/proc/get_building_template_chunk_credit_count(datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_template_chunk/chunk)
	if(!istype(cluster_spec) || !istype(chunk))
		return 0
	var/credit_count = 0
	for(var/datum/world_edit_building_template_cell/cell as anything in chunk.cells)
		if(!istype(cell))
			continue
		credit_count += get_building_fixture_count_credit(cluster_spec, cell.slot, cell.category)
	return credit_count

/datum/world_edit_generator/building_layout/proc/count_building_cluster_slot_capacity_for_anchors(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/anchor_ids)
	if(!istype(state) || !istype(cluster_spec))
		return 0
	var/fixture_capacity = count_building_cluster_fixture_capacity_for_anchors(state, cluster_spec, anchor_ids)
	if(is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
		return fixture_capacity
	var/template_capacity = count_building_cluster_template_capacity_for_anchors(state, cluster_spec, anchor_ids)
	return max(fixture_capacity, template_capacity)

/datum/world_edit_generator/building_layout/proc/build_building_cluster_planned_slot_turfs(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/anchor_ids, target_count)
	var/list/planned_turfs = list()
	if(!istype(state) || !istype(cluster_spec) || target_count <= 0)
		return planned_turfs
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/macro_id = length(cluster_spec.macro_id) ? cluster_spec.macro_id : get_building_macro_id_for_cluster(cluster_spec, state)
	var/planned_credit_count = 0
	if(length(macro_id) && !is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
		var/resolved_macro_id = resolve_existing_building_template_chunk_id(macro_id)
		if(length(resolved_macro_id))
			cluster_spec.macro_id = resolved_macro_id
		var/datum/world_edit_building_template_chunk/chunk = length(resolved_macro_id) ? get_building_template_chunk(resolved_macro_id) : null
		if(istype(chunk) && length(chunk.cells))
			var/chunk_credit_count = get_building_template_chunk_credit_count(cluster_spec, chunk)
			var/list/candidate_data = build_template_chunk_candidate_turfs(state, cluster_spec, chunk, anchor_ids)
			var/list/template_candidates = candidate_data["turfs"]
			var/list/template_scores = candidate_data["scores"]
			var/template_attempts = 0
			while(planned_credit_count < target_count && chunk_credit_count > 0 && length(template_candidates) && template_attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS)
				template_attempts++
				var/turf/anchor_turf = select_best_template_candidate(template_candidates, template_scores)
				if(!istype(anchor_turf))
					break
				template_candidates -= anchor_turf
				var/datum/world_edit_building_place_rule/template_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
				var/fallback_dir = get_cardinal_dir_toward(anchor_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
				var/list/place_context = build_building_fixture_place_context(state, anchor_turf, template_rule, fallback_dir, get_cluster_effective_needs_wall(state, cluster_spec, template_rule), cluster_spec, anchor_ids)
				if(!islist(place_context))
					continue
				var/dir_to_use = place_context["dir"] || fallback_dir
				var/wall_dir = place_context["wall_dir"]
				if(!can_place_building_template_chunk_at(state, cluster_spec, chunk, anchor_turf, dir_to_use, wall_dir))
					continue
				var/list/cell_turfs = list()
				var/conflict = FALSE
				for(var/datum/world_edit_building_template_cell/cell as anything in chunk.cells)
					if(!istype(cell))
						continue
					var/turf/cell_turf = get_template_offset_turf(anchor_turf, dir_to_use, cell.dx, cell.dy)
					var/owner = state.get_semantic_slot_owner(cell_turf)
					if(length(owner) && owner != requirement_id)
						conflict = TRUE
						break
					cell_turfs += cell_turf
				if(conflict)
					continue
				for(var/turf/cell_turf as anything in cell_turfs)
					if(state.reserve_semantic_slot(requirement_id, cell_turf))
						planned_turfs += cell_turf
				planned_credit_count += chunk_credit_count
			if(length(planned_turfs))
				return planned_turfs
	var/list/candidates = get_fixture_candidate_turfs_for_anchors(state, anchor_ids)
	var/list/planned_lookup = list()
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/effective_needs_wall = get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
	while(planned_credit_count < target_count && length(candidates))
		var/turf/best_turf = null
		var/list/best_place_context = null
		var/best_score = -999999999
		for(var/turf/candidate_turf as anything in candidates)
			if(!istype(candidate_turf) || planned_lookup[candidate_turf])
				continue
			if(!building_fixture_candidate_has_entry_access(state, candidate_turf, cluster_spec))
				continue
			var/owner = state.get_semantic_slot_owner(candidate_turf)
			if(length(owner) && owner != requirement_id)
				continue
			if(!state.can_place_fixture(candidate_turf))
				continue
			if(effective_needs_wall && !length(get_adjacent_wall_dirs_for_state(state, candidate_turf)))
				continue
			if(!fixture_turf_matches_anchor(state, candidate_turf, anchor_ids))
				continue
			if(!building_fixture_matches_semantic_zone_contract(state, candidate_turf, cluster_spec.slot, cluster_spec.category, cluster_spec))
				continue
			var/fallback_dir = get_cardinal_dir_toward(candidate_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
			var/list/place_context = (effective_needs_wall && is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category)) ? build_building_module_front_clear_place_context(state, candidate_turf, place_rule, fallback_dir, effective_needs_wall, cluster_spec, anchor_ids) : build_building_fixture_place_context(state, candidate_turf, place_rule, fallback_dir, effective_needs_wall, cluster_spec, anchor_ids)
			if(!islist(place_context))
				continue
			var/score = score_fixture_turf(state, candidate_turf, anchor_ids, effective_needs_wall, cluster_spec, place_rule)
			if(!istype(best_turf) || score > best_score)
				best_turf = candidate_turf
				best_place_context = place_context
				best_score = score
		if(!istype(best_turf))
			break
		if(!state.can_place_fixture(best_turf))
			candidates -= best_turf
			continue
		if(!state.reserve_semantic_slot(requirement_id, best_turf))
			candidates -= best_turf
			continue
		planned_turfs += best_turf
		planned_lookup[best_turf] = TRUE
		if(effective_needs_wall && is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category) && islist(best_place_context))
			var/front_dir = get_building_place_rule_front_dir(best_place_context["dir"], best_place_context["wall_dir"], place_rule)
			var/turf/front_turf = front_dir ? get_step(best_turf, front_dir) : null
			if(istype(front_turf))
				state.reserve_semantic_slot_clearance(requirement_id, front_turf)
		planned_credit_count += max(get_building_fixture_count_credit(cluster_spec, cluster_spec.slot, cluster_spec.category), 1)
		candidates -= best_turf
	return planned_turfs

/datum/world_edit_generator/building_layout/proc/cluster_turf_is_preflight_planned(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, turf/target_turf)
	if(!istype(state) || !istype(cluster_spec) || !istype(target_turf))
		return FALSE
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/planned_turfs = state.fixtures.semantic_slot_turf_sets[cluster_spec.id]
	if(!islist(planned_turfs))
		planned_turfs = state.fixtures.semantic_slot_turf_sets[requirement_id]
	if(!islist(planned_turfs))
		return FALSE
	return target_turf in planned_turfs

/datum/world_edit_generator/building_layout/proc/preflight_building_cluster_slots(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, source = "program")
	if(!istype(state) || !istype(cluster_spec) || !cluster_spec.required)
		return
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/declared_anchor_ids = islist(cluster_spec.anchors) ? cluster_spec.anchors.Copy() : list()
	var/declared_capacity = count_building_cluster_slot_capacity_for_anchors(state, cluster_spec, declared_anchor_ids)
	var/declared_minimum = max(round(text2num("[cluster_spec.min_count]") || 0), 1)
	var/required_count = declared_minimum
	if(is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category) && declared_capacity > 0 && declared_capacity < required_count && !can_building_cluster_use_broad_fallback_anchors(state, cluster_spec))
		required_count = declared_capacity
	var/list/selected_anchor_ids = declared_anchor_ids
	var/selected_mode = "declared"
	var/fallback_capacity = 0
	var/compact_capacity = 0
	var/compact_planned_slot_count = 0
	var/list/compact_anchor_ids = list()
	var/list/compact_planned_turfs = list()
	var/datum/world_edit_building_cluster_spec/compact_spec = null
	if(declared_capacity < required_count)
		var/list/fallback_anchor_ids = build_required_cluster_fallback_anchor_ids(state, declared_anchor_ids, cluster_spec)
		fallback_capacity = count_building_cluster_slot_capacity_for_anchors(state, cluster_spec, fallback_anchor_ids)
		if(fallback_capacity >= required_count || fallback_capacity > declared_capacity)
			selected_anchor_ids = fallback_anchor_ids
			selected_mode = "fallback"
		compact_spec = get_building_compact_substitute_spec(state, cluster_spec)
		if(istype(compact_spec))
			compact_anchor_ids = islist(compact_spec.anchors) ? compact_spec.anchors.Copy() : list()
			compact_capacity = count_building_cluster_slot_capacity_for_anchors(state, compact_spec, compact_anchor_ids)
	var/base_capacity = max(declared_capacity, fallback_capacity)
	var/best_capacity = min(required_count, base_capacity + compact_capacity)
	var/shortage = max(required_count - best_capacity, 0)
	if(declared_capacity < required_count && !can_building_cluster_use_broad_fallback_anchors(state, cluster_spec) && shortage > 0)
		state.validation.fallback_anchor_required_cluster_count++
		state.validation.forbidden_fallback_count++
		state.add_warning("Required cluster '[cluster_spec.id]' cannot use fallback anchors: declared capacity [declared_capacity], compact capacity [compact_capacity], required [required_count].")
	if(shortage > 0)
		state.validation.semantic_slot_shortage_count += shortage
	state.validation.semantic_slot_capacity_count += min(best_capacity, required_count)
	state.fixtures.semantic_requirement_minimums[requirement_id] = max(round(text2num("[state.fixtures.semantic_requirement_minimums[requirement_id]]") || 0), required_count)
	if(length(selected_anchor_ids))
		state.fixtures.semantic_slot_anchor_sets[requirement_id] = selected_anchor_ids.Copy()
	var/list/planned_turfs = build_building_cluster_planned_slot_turfs(state, cluster_spec, selected_anchor_ids, min(base_capacity, required_count))
	if(length(planned_turfs))
		state.fixtures.semantic_slot_turf_sets[requirement_id] = planned_turfs.Copy()
	if(istype(compact_spec) && compact_capacity > 0 && length(planned_turfs) < required_count)
		var/compact_target = min(compact_capacity, required_count - length(planned_turfs))
		compact_planned_turfs = build_building_cluster_planned_slot_turfs(state, compact_spec, compact_anchor_ids, compact_target)
		compact_planned_slot_count = length(compact_planned_turfs)
		if(length(compact_anchor_ids))
			state.fixtures.semantic_slot_anchor_sets[compact_spec.id] = compact_anchor_ids.Copy()
		if(length(compact_planned_turfs))
			state.fixtures.semantic_slot_turf_sets[compact_spec.id] = compact_planned_turfs.Copy()
			if(!islist(state.fixtures.semantic_slot_turf_sets[requirement_id]))
				state.fixtures.semantic_slot_turf_sets[requirement_id] = list()
			var/list/combined_planned_turfs = state.fixtures.semantic_slot_turf_sets[requirement_id]
			for(var/turf/compact_turf as anything in compact_planned_turfs)
				if(istype(compact_turf) && !(compact_turf in combined_planned_turfs))
					combined_planned_turfs += compact_turf
		if(compact_planned_slot_count > 0)
			selected_mode = selected_mode == "fallback" ? "fallback_compact" : "compact"
	if(selected_mode != "declared")
		state.validation.semantic_slot_fallback_count++
	state.fixtures.semantic_slot_selected_modes[requirement_id] = selected_mode
	var/list/report = list(
		"id" = requirement_id,
		"cluster_id" = cluster_spec.id,
		"source" = "[source]",
		"phase" = cluster_spec.phase,
		"pattern" = cluster_spec.pattern,
		"slot" = cluster_spec.slot,
		"category" = cluster_spec.category,
		"semantic_credit" = length(cluster_spec.semantic_credit) ? cluster_spec.semantic_credit : requirement_id,
		"failure_severity" = cluster_spec.failure_severity,
		"acceptance_counter" = length(cluster_spec.acceptance_counter) ? cluster_spec.acceptance_counter : "[requirement_id]_count",
		"required" = required_count,
		"declared_capacity" = declared_capacity,
		"fallback_capacity" = fallback_capacity,
		"compact_capacity" = compact_capacity,
		"best_capacity" = best_capacity,
		"shortage" = shortage,
		"planned_slot_count" = length(planned_turfs) + compact_planned_slot_count,
		"compact_planned_slot_count" = compact_planned_slot_count,
		"selected_mode" = selected_mode,
		"declared_anchors" = declared_anchor_ids,
		"selected_anchors" = islist(selected_anchor_ids) ? selected_anchor_ids.Copy() : list(),
	)
	if(length(cluster_spec.signature_id))
		report["signature_id"] = cluster_spec.signature_id
	if(istype(compact_spec))
		report["compact_substitute_id"] = compact_spec.id
	state.add_semantic_slot_report(report)
	state.add_semantic_requirement_report(report.Copy())

/datum/world_edit_generator/building_layout/proc/run_building_semantic_slot_preflight(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.semantic_plan))
		return
	state.validation.semantic_slot_reports.Cut()
	state.fixtures.semantic_slot_anchor_sets.Cut()
	state.fixtures.semantic_slot_selected_modes.Cut()
	state.fixtures.semantic_slot_turf_sets.Cut()
	state.fixtures.semantic_requirement_minimums.Cut()
	state.validation.semantic_requirement_reports.Cut()
	state.validation.template_reject_reason_counts.Cut()
	state.validation.template_reject_reports.Cut()
	state.validation.template_cluster_reports.Cut()
	state.clear_semantic_slot_reservations()
	state.validation.semantic_slot_capacity_count = 0
	state.validation.semantic_slot_shortage_count = 0
	state.validation.semantic_slot_fallback_count = 0
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan.get_cluster_specs("major"))
		if(!istype(cluster_spec) || !cluster_spec.required)
			continue
		preflight_building_cluster_slots(state, cluster_spec, "program")
	if(length(state.geometry.floor_turfs) >= 12)
		var/list/anchors = build_infrastructure_anchor_list(state)
		for(var/list/spec_data as anything in get_building_infrastructure_specs(state))
			if(!islist(spec_data))
				continue
			var/category = "[spec_data["category"]]"
			var/minimum = max(round(text2num("[spec_data["minimum"]]") || 0), 0)
			if(minimum <= 0)
				continue
			var/maximum = max(round(text2num("[spec_data["maximum"]]") || minimum), minimum)
			var/datum/world_edit_building_cluster_spec/cluster_spec = new(
				"[spec_data["id"]]",
				"major",
				spec_data["pattern"],
				spec_data["slot"],
				category,
				anchors,
				minimum,
				max(minimum, maximum),
				TRUE,
				0,
				round(text2num("[spec_data["priority"]]") || 70),
				TRUE,
				null,
				spec_data["macro"]
			)
			preflight_building_cluster_slots(state, cluster_spec, "infrastructure")

/datum/world_edit_generator/building_layout/proc/get_effective_cluster_min_count(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(!istype(cluster_spec))
		return 1
	var/minimum = max(round(text2num("[cluster_spec.min_count]") || 0), 0)
	if(minimum <= 0)
		return 0
	if(!istype(state))
		return minimum
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/preflight_minimum = max(round(text2num("[state.fixtures.semantic_requirement_minimums[requirement_id]]") || 0), 0)
	if(preflight_minimum > 0)
		return preflight_minimum
	var/anchor_area = get_cluster_anchor_area(state, cluster_spec)
	if(anchor_area <= 0)
		return minimum
	return max(1, min(minimum, anchor_area))

/datum/world_edit_generator/building_layout/proc/get_effective_signature_min_count(datum/world_edit_building_layout_state/state, signature_id, declared_minimum = 0)
	var/minimum = max(round(text2num("[declared_minimum]") || 0), 0)
	if(minimum <= 1 || !istype(state) || !istype(state.semantic_plan))
		return minimum
	for(var/phase_id as anything in list("major", "secondary", "detail"))
		for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan.get_cluster_specs(phase_id))
			if(!istype(cluster_spec) || cluster_spec.signature_id != "[signature_id]")
				continue
			minimum = min(minimum, get_effective_cluster_min_count(state, cluster_spec))
	return max(1, minimum)

/datum/world_edit_generator/building_layout/proc/get_cluster_area_divisor(datum/world_edit_building_cluster_spec/cluster_spec)
	switch(cluster_spec.pattern)
		if("signature_hydro_rows", "signature_rack_aisles", "signature_bed_rows")
			return 6
		if("signature_workshop_wall", "signature_cook_line", "signature_security_counter")
			return 7
		if("signature_treatment_bay", "signature_office_suite", "signature_living_nook")
			return 14
		if("run")
			return 8
		if("counter_line")
			return 6
		if("staging_group")
			return 10
		if("table_cluster")
			return 28
		if("wall_object", "paired_object")
			return 18
	return 22

/datum/world_edit_generator/building_layout/proc/get_scaled_cluster_target_count(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(cluster_spec.force_placement)
		return max(cluster_spec.min_count, 0)
	var/base_count = max(cluster_spec.min_count, cluster_spec.max_count)
	var/room_area = length(get_fixture_candidate_turfs_for_anchors(state, cluster_spec.anchors))
	if(room_area <= 0)
		return base_count
	var/divisor = max(get_cluster_area_divisor(cluster_spec), 1)
	
	// SS220 EDIT: area_bonus scales with the semantic zone area, not just valid anchor tiles or the whole building, to properly fill rooms based on area.
	var/area_bonus = max(0, round((room_area - (base_count * divisor)) / divisor))
	
	if(cluster_spec.phase != "major")
		area_bonus = round(area_bonus * clamp(round(text2num("[state.config["detail_budget"]]") || 0), 0, 100) / 100)
	var/area_cap = max(cluster_spec.min_count, min(WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS, round(room_area / max(cluster_spec.pattern == "table_cluster" ? 5 : 2, 1))))
	return min(area_cap, max(base_count, base_count + area_bonus))

/datum/world_edit_generator/building_layout/proc/place_table_cluster(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(istype(cluster_spec) && !length(cluster_spec.macro_id))
		cluster_spec.macro_id = get_building_macro_id_for_cluster(cluster_spec, state)
	var/datum/world_edit_building_place_rule/table_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/turf/table_turf = select_fixture_turf(state, cluster_spec.anchors, cluster_spec.wall_required, cluster_spec)
	if(!istype(table_turf))
		return 0
	var/fallback_dir = get_cardinal_dir_toward(table_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
	var/list/table_context = build_building_fixture_place_context(state, table_turf, table_rule, fallback_dir, cluster_spec.wall_required, cluster_spec, cluster_spec.anchors)
	if(!islist(table_context))
		return 0
	var/dir_to_use = table_context["dir"] || fallback_dir
	var/wall_dir = table_context["wall_dir"]
	if(!place_fixture_at(state, table_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, cluster_spec.phase == "major", cluster_spec.wall_required, table_rule, wall_dir, cluster_spec, null, null, table_context["dir_source"]))
		return 0
	var/placed_primary = 1
	var/placed_chairs = 0
	var/datum/world_edit_building_place_rule/chair_rule = resolve_building_place_rule("chair", "chair")
	for(var/check_dir in GLOB.cardinals)
		if(placed_chairs >= cluster_spec.chair_count)
			break
		var/turf/chair_turf = get_step(table_turf, check_dir)
		if(!state.can_place_fixture(chair_turf))
			continue
		var/chair_dir = get_cardinal_dir_toward(chair_turf, table_turf, SOUTH)
		if(!building_place_rule_allows_turf(state, chair_turf, chair_rule, chair_dir, null))
			continue
		if(place_fixture_at(state, chair_turf, "chair", chair_dir, "chair", FALSE, FALSE, chair_rule, null, cluster_spec, null, null, "table_pair"))
			placed_chairs++
	return placed_primary

/datum/world_edit_generator/building_layout/proc/place_fixture_run(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count)
	if(istype(cluster_spec) && !length(cluster_spec.macro_id))
		cluster_spec.macro_id = get_building_macro_id_for_cluster(cluster_spec, state)
	var/placed = 0
	var/attempts = 0
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	while(placed < target_count && attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		attempts++
		var/turf/start_turf = select_fixture_turf(state, cluster_spec.anchors, cluster_spec.wall_required, cluster_spec)
		if(!istype(start_turf))
			break
		var/fallback_dir = get_cardinal_dir_toward(start_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
		var/list/place_context = build_building_fixture_place_context(state, start_turf, place_rule, fallback_dir, cluster_spec.wall_required, cluster_spec, cluster_spec.anchors)
		if(!islist(place_context))
			break
		var/wall_dir = place_context["wall_dir"]
		var/dir_to_use = place_context["dir"] || fallback_dir
		if(!place_fixture_at(state, start_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, cluster_spec.phase == "major" && placed <= 0, cluster_spec.wall_required, place_rule, wall_dir, cluster_spec, null, null, place_context["dir_source"]))
			break
		placed++
		var/list/run_dirs = get_fixture_run_dirs(state, wall_dir)
		for(var/run_dir as anything in run_dirs)
			if(placed >= target_count)
				break
			placed = extend_fixture_run(state, start_turf, run_dir, cluster_spec, dir_to_use, wall_dir, place_rule, placed, target_count)
	return placed

/datum/world_edit_generator/building_layout/proc/add_building_fixture_semantic_zone_id(datum/world_edit_building_layout_state/state, list/zone_ids, list/zone_lookup, zone_id)
	if(!istype(state) || !islist(zone_ids) || !islist(zone_lookup) || !length("[zone_id]"))
		return
	var/zone_key = "[zone_id]"
	if(zone_lookup[zone_key])
		return
	if(!istype(state.semantic_plan))
		return
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan.get_zone_spec(zone_key)
	if(!istype(zone_spec))
		return
	zone_ids += zone_key
	zone_lookup[zone_key] = TRUE

/datum/world_edit_generator/building_layout/proc/get_building_fixture_semantic_zone_ids(datum/world_edit_building_layout_state/state, slot, category, datum/world_edit_building_cluster_spec/cluster_spec = null)
	var/list/zone_ids = list()
	var/list/zone_lookup = list()
	if(!istype(state) || !istype(state.semantic_plan))
		return zone_ids
	if(istype(cluster_spec) && islist(cluster_spec.anchors))
		for(var/anchor_id as anything in cluster_spec.anchors)
			add_building_fixture_semantic_zone_id(state, zone_ids, zone_lookup, anchor_id)
			// Module eligibility already treats authored zone anchor tags as an
			// explicit compatibility relation. Required fixture validation must use
			// the same relation or a curated module can solve successfully and then
			// become impossible only during emission.
			for(var/datum/world_edit_building_zone_spec/zone_spec as anything in state.semantic_plan.zone_specs)
				if(istype(zone_spec) && "[anchor_id]" in zone_spec.anchor_tags)
					add_building_fixture_semantic_zone_id(state, zone_ids, zone_lookup, zone_spec.id)
	var/slot_text = lowertext("[slot]")
	var/category_text = lowertext("[category]")
	if(slot_text in list("bed", "sleeper") || category_text in list("bed", "medical_bed") || (istype(cluster_spec) && findtext(lowertext(cluster_spec.id), "sleep")))
		add_building_fixture_semantic_zone_id(state, zone_ids, zone_lookup, "sleep_privacy")
	if(slot_text in list("toilet", "sink") || category_text == "sanitation" || (istype(cluster_spec) && findtext(lowertext(cluster_spec.id), "sanitation")))
		add_building_fixture_semantic_zone_id(state, zone_ids, zone_lookup, "sanitation")
	if(slot_text in list("table", "chair") || category_text in list("table", "chair"))
		add_building_fixture_semantic_zone_id(state, zone_ids, zone_lookup, "common")
	if(category_text in list("rack", "cabinet", "medical_storage", "seed_storage", "sample_storage", "cold_storage"))
		add_building_fixture_semantic_zone_id(state, zone_ids, zone_lookup, "storage_service")
	return zone_ids

/datum/world_edit_generator/building_layout/proc/building_fixture_matches_semantic_zone_contract(datum/world_edit_building_layout_state/state, turf/target_turf, slot, category, datum/world_edit_building_cluster_spec/cluster_spec = null)
	if(!istype(state) || !istype(target_turf))
		return FALSE
	if(!istype(cluster_spec) || !cluster_spec.required)
		return TRUE
	if(is_building_infrastructure_category(category))
		return TRUE
	if(is_building_compact_or_micro_state(state))
		return TRUE
	var/list/zone_ids = get_building_fixture_semantic_zone_ids(state, slot, category, cluster_spec)
	if(!length(zone_ids))
		return TRUE
	var/zone_id = state.get_zone(target_turf)
	return zone_id in zone_ids

/datum/world_edit_generator/building_layout/proc/get_building_fixture_anchor_id_for_turf(datum/world_edit_building_layout_state/state, turf/target_turf, list/anchor_ids)
	if(!istype(state) || !istype(target_turf) || !islist(anchor_ids))
		return ""
	var/zone_id = state.get_zone(target_turf)
	for(var/anchor_id as anything in anchor_ids)
		if(state.has_anchor(anchor_id, target_turf) || zone_id == "[anchor_id]")
			return "[anchor_id]"
	return zone_id

/datum/world_edit_generator/building_layout/proc/fixture_turf_matches_anchor(datum/world_edit_building_layout_state/state, turf/target_turf, list/anchor_ids)
	if(!istype(state) || !istype(target_turf))
		return FALSE
	if(!islist(anchor_ids) || !length(anchor_ids))
		return TRUE
	var/zone_id = state.get_zone(target_turf)
	var/has_semantic_zone_anchor = FALSE
	for(var/anchor_id as anything in anchor_ids)
		if(state.has_anchor("[anchor_id]", target_turf))
			return TRUE
		var/datum/world_edit_building_zone_spec/anchor_zone_spec = state.semantic_plan?.get_zone_spec("[anchor_id]")
		if(istype(anchor_zone_spec))
			has_semantic_zone_anchor = TRUE
			if(zone_id == "[anchor_id]")
				return TRUE
	if(has_semantic_zone_anchor)
		return FALSE
	for(var/anchor_id as anything in anchor_ids)
		if(zone_id == "[anchor_id]" || state.has_anchor("[anchor_id]", target_turf))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/place_paired_fixture_objects(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/turf/primary_turf = select_fixture_turf(state, cluster_spec.anchors, cluster_spec.wall_required, cluster_spec)
	if(!istype(primary_turf))
		return 0
	var/fallback_dir = get_cardinal_dir_toward(primary_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
	var/list/place_context = build_building_fixture_place_context(state, primary_turf, place_rule, fallback_dir, cluster_spec.wall_required, cluster_spec, cluster_spec.anchors)
	if(!islist(place_context))
		return 0
	var/wall_dir = place_context["wall_dir"]
	var/dir_to_use = place_context["dir"] || fallback_dir
	if(!place_fixture_at(state, primary_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, cluster_spec.phase == "major", cluster_spec.wall_required, place_rule, wall_dir, cluster_spec, null, null, place_context["dir_source"]))
		return 0
	var/placed = 1
	var/target_count = clamp(cluster_spec.max_count, 2, 2)
	while(placed < target_count)
		var/turf/best_pair_turf = null
		var/best_pair_score = -999999999
		for(var/check_dir in GLOB.cardinals)
			var/turf/pair_turf = get_step(primary_turf, check_dir)
			if(!state.can_place_fixture(pair_turf))
				continue
			if(!fixture_turf_matches_anchor(state, pair_turf, cluster_spec.anchors))
				continue
			if(cluster_spec.wall_required && (isnull(wall_dir) || !state.geometry.wall_lookup[get_step(pair_turf, wall_dir)]))
				continue
			if(!building_place_rule_allows_turf(state, pair_turf, place_rule, dir_to_use, wall_dir))
				continue
			var/pair_score = score_fixture_turf(state, pair_turf, cluster_spec.anchors, get_cluster_effective_needs_wall(state, cluster_spec, place_rule), cluster_spec, place_rule)
			if(check_dir == turn(dir_to_use, 90) || check_dir == turn(dir_to_use, -90))
				pair_score += 40
			if(!istype(best_pair_turf) || pair_score > best_pair_score)
				best_pair_turf = pair_turf
				best_pair_score = pair_score
		if(!istype(best_pair_turf))
			break
		if(!place_fixture_at(state, best_pair_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, FALSE, cluster_spec.wall_required, place_rule, wall_dir, cluster_spec, null, null, "paired_run"))
			break
		placed++
	return placed

/datum/world_edit_generator/building_layout/proc/get_fixture_run_dirs(datum/world_edit_building_layout_state/state, wall_dir)
	var/list/run_dirs = list()
	if(wall_dir)
		run_dirs += turn(wall_dir, 90)
		run_dirs += turn(wall_dir, -90)
	else if(state.placement_dir in list(NORTH, SOUTH))
		run_dirs += EAST
		run_dirs += WEST
	else
		run_dirs += NORTH
		run_dirs += SOUTH
	return run_dirs

/datum/world_edit_generator/building_layout/proc/extend_fixture_run(datum/world_edit_building_layout_state/state, turf/start_turf, run_dir, datum/world_edit_building_cluster_spec/cluster_spec, dir_to_use, wall_dir, datum/world_edit_building_place_rule/place_rule, placed, target_count)
	var/turf/current_turf = start_turf
	var/steps = 0
	while(placed < target_count && steps < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		steps++
		current_turf = get_step(current_turf, run_dir)
		if(!state.can_place_fixture(current_turf))
			break
		if(!fixture_turf_matches_anchor(state, current_turf, cluster_spec.anchors))
			break
		if(cluster_spec.wall_required && isnull(wall_dir))
			break
		if(!isnull(wall_dir) && !state.geometry.wall_lookup[get_step(current_turf, wall_dir)])
			break
		if(!building_place_rule_allows_turf(state, current_turf, place_rule, dir_to_use, wall_dir))
			break
		if(!place_fixture_at(state, current_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, FALSE, cluster_spec.wall_required, place_rule, wall_dir, cluster_spec, null, null, "run_extend"))
			break
		placed++
	return placed

/datum/world_edit_generator/building_layout/proc/place_wall_fixture(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(istype(cluster_spec) && !length(cluster_spec.macro_id))
		cluster_spec.macro_id = get_building_macro_id_for_cluster(cluster_spec, state)
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/turf/target_turf = select_fixture_turf(state, cluster_spec.anchors, TRUE, cluster_spec)
	if(!istype(target_turf))
		return 0
	var/fallback_dir = get_cardinal_dir_toward(target_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
	var/list/place_context = build_building_fixture_place_context(state, target_turf, place_rule, fallback_dir, TRUE, cluster_spec, cluster_spec.anchors)
	if(!islist(place_context))
		return 0
	var/wall_dir = place_context["wall_dir"]
	var/dir_to_use = place_context["dir"] || fallback_dir
	if(!place_fixture_at(state, target_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, cluster_spec.phase == "major", TRUE, place_rule, wall_dir, cluster_spec, null, null, place_context["dir_source"]))
		return 0
	return 1

/datum/world_edit_generator/building_layout/proc/place_fixture_object(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec)
	if(istype(cluster_spec) && !length(cluster_spec.macro_id))
		cluster_spec.macro_id = get_building_macro_id_for_cluster(cluster_spec, state)
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
	var/turf/target_turf = select_fixture_turf(state, cluster_spec.anchors, cluster_spec.wall_required, cluster_spec)
	if(!istype(target_turf))
		return 0
	var/fallback_dir = get_cardinal_dir_toward(target_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
	var/list/place_context = build_building_fixture_place_context(state, target_turf, place_rule, fallback_dir, cluster_spec.wall_required, cluster_spec, cluster_spec.anchors)
	if(!islist(place_context))
		return 0
	var/wall_dir = place_context["wall_dir"]
	var/dir_to_use = place_context["dir"] || fallback_dir
	if(!place_fixture_at(state, target_turf, cluster_spec.slot, dir_to_use, cluster_spec.category, cluster_spec.phase == "major", cluster_spec.wall_required, place_rule, wall_dir, cluster_spec, null, null, place_context["dir_source"]))
		return 0
	return 1

/datum/world_edit_generator/building_layout/proc/select_fixture_turf(datum/world_edit_building_layout_state/state, list/anchor_ids, needs_wall = FALSE, datum/world_edit_building_cluster_spec/cluster_spec = null)
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec?.slot, cluster_spec?.category)
	var/effective_needs_wall = needs_wall || (istype(cluster_spec) ? get_cluster_effective_needs_wall(state, cluster_spec, place_rule) : place_rule.needs_wall)
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/anchor_sets = list()
	anchor_sets += list(get_cluster_preflight_anchor_ids(state, cluster_spec, anchor_ids))
	for(var/list/effective_anchor_ids as anything in anchor_sets)
		var/list/best_turfs = list()
		var/best_score = -999999999
		for(var/turf/floor_turf as anything in get_fixture_candidate_turfs_for_anchors(state, effective_anchor_ids))
			if(!building_fixture_candidate_has_entry_access(state, floor_turf, cluster_spec))
				continue
			var/owner = state.get_semantic_slot_owner(floor_turf)
			if(length(owner) && owner != requirement_id)
				continue
			if(!state.can_place_fixture(floor_turf))
				continue
			if(effective_needs_wall && !length(get_adjacent_wall_dirs_for_state(state, floor_turf)))
				continue
			if(!fixture_turf_matches_anchor(state, floor_turf, effective_anchor_ids))
				continue
			if(!building_fixture_matches_semantic_zone_contract(state, floor_turf, cluster_spec.slot, cluster_spec.category, cluster_spec))
				continue
			var/fallback_dir = get_cardinal_dir_toward(floor_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
			if(!fixture_turf_satisfies_place_rule(state, floor_turf, place_rule, fallback_dir, effective_needs_wall))
				continue
			var/score = score_fixture_turf(state, floor_turf, effective_anchor_ids, effective_needs_wall, cluster_spec, place_rule)
			if(score > best_score)
				best_score = score
				best_turfs.Cut()
				best_turfs += floor_turf
			else if(score == best_score)
				best_turfs += floor_turf
		if(length(best_turfs))
			return state.request.fixture_rng.pick_from(best_turfs)
	return null

/datum/world_edit_generator/building_layout/proc/score_fixture_turf(datum/world_edit_building_layout_state/state, turf/target_turf, list/anchor_ids, needs_wall = FALSE, datum/world_edit_building_cluster_spec/cluster_spec = null, datum/world_edit_building_place_rule/place_rule = null)
	var/score = 0
	if(!istype(place_rule))
		place_rule = resolve_building_place_rule(cluster_spec?.slot, cluster_spec?.category)
	var/zone_id = state.get_zone(target_turf)
	for(var/anchor_id as anything in anchor_ids)
		if(state.has_anchor(anchor_id, target_turf) || zone_id == "[anchor_id]")
			score += 120
	var/wall_count = length(get_adjacent_wall_dirs_for_state(state, target_turf))
	if(needs_wall)
		score += wall_count * 35
	else
		score -= wall_count * 500
		var/focus_bonus = 0
		var/turf/focus_turf = null
		if(state.has_anchor("focus_center", target_turf))
			focus_bonus += 1800
		var/datum/world_edit_building_room/room = state.get_room_for_turf(target_turf)
		if(istype(room) && istype(room.focus_turf))
			focus_turf = room.focus_turf
		else if(length(zone_id))
			focus_turf = state.geometry.zone_focus_turfs[zone_id]
		if(!istype(focus_turf))
			focus_turf = state.geometry.zone_focus_turfs[state.semantic_plan?.hub_zone_id] || state.geometry.center_turf || state.geometry.semantic_hub_turf
		if(istype(focus_turf))
			var/dist_to_focus = abs(target_turf.x - focus_turf.x) + abs(target_turf.y - focus_turf.y)
			focus_bonus += max(0, 12 - dist_to_focus) * 220
			score += focus_bonus
	if(state.has_anchor("door_cone", target_turf))
		score -= 1000
	if(state.geometry.reserved_lookup[target_turf])
		score -= 500
	if(cluster_spec)
		score += cluster_spec.priority
		if(zone_id in cluster_spec.anchors)
			score += 80
		if(cluster_turf_is_preflight_planned(state, cluster_spec, target_turf))
			score += 5000
		if(state.get_semantic_slot_owner(target_turf) == get_building_cluster_requirement_id(cluster_spec))
			score += 3000
		score -= get_building_repeat_penalty_score(state, cluster_spec.category)
	score += place_rule.priority_bonus
	var/clearance = 0
	for(var/check_dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(target_turf, check_dir)
		if(state.geometry.floor_lookup[nearby_turf] && !state.fixtures.fixture_lookup[nearby_turf] && !state.geometry.wall_lookup[nearby_turf])
			clearance++
	score += clearance * 8
	if(istype(state.geometry.semantic_hub_turf))
		score -= abs(target_turf.x - state.geometry.semantic_hub_turf.x) + abs(target_turf.y - state.geometry.semantic_hub_turf.y)
	return score

/datum/world_edit_generator/building_layout/proc/get_building_repeat_penalty_score(datum/world_edit_building_layout_state/state, category)
	if(!istype(state) || !length("[category]"))
		return 0
	var/list/repeat_penalties = state.semantic_plan?.repeat_penalties
	var/list/repeat_rule = islist(repeat_penalties) && islist(repeat_penalties["[category]"]) ? repeat_penalties["[category]"] : list()
	var/list/style_budget = islist(state.semantic_plan?.style_budget) ? state.semantic_plan.style_budget : list()
	var/soft_percent = round(text2num("[style_budget["max_repeat_index"]]") || 55)
	if(!isnull(repeat_rule["soft_percent"]))
		soft_percent = round(text2num("[repeat_rule["soft_percent"]]") || soft_percent)
	var/penalty = round(text2num("[repeat_rule["penalty"]]") || 8)
	var/category_count = round(text2num("[state.fixtures.category_counts["[category]"]]") || 0)
	if(category_count <= 0 || state.fixtures.fixture_count <= 0)
		return 0
	var/projected_percent = round((category_count + 1) * 100 / max(state.fixtures.fixture_count + 1, 1))
	if(projected_percent <= soft_percent)
		return 0
	return (projected_percent - soft_percent) * max(penalty, 1)

/datum/world_edit_generator/building_layout/proc/place_fixture_at(datum/world_edit_building_layout_state/state, turf/target_turf, slot, dir_to_use, category, major = FALSE, wall_mounted = FALSE, datum/world_edit_building_place_rule/place_rule = null, wall_dir = null, datum/world_edit_building_cluster_spec/cluster_spec = null, template_chunk_id = null, template_chunk_instance_id = null, dir_source = null, allow_reserved = FALSE, module_id = null, module_instance_id = null, module_expected_member_count = 0, module_repeat_group = null, module_room_id = null, module_requires_table_pairing = FALSE, module_seating_group_ok = FALSE)
	var/layout_scene_owner = findtext("[module_id]", "layout_scene_") == 1
	if(!state.can_place_fixture(target_turf, allow_reserved))
		return FALSE
	var/reservation_owner = state.get_semantic_slot_owner(target_turf)
	if(length(reservation_owner))
		if(!layout_scene_owner && (!istype(cluster_spec) || reservation_owner != get_building_cluster_requirement_id(cluster_spec)))
			return FALSE
	if(state.fixtures.fixture_count >= WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		return FALSE
	if(!istype(place_rule))
		place_rule = resolve_building_place_rule(slot, category)
	if(!building_fixture_matches_semantic_zone_contract(state, target_turf, slot, category, cluster_spec))
		return FALSE
	if(wall_mounted && isnull(wall_dir))
		var/list/wall_dirs = get_adjacent_wall_dirs_for_state(state, target_turf)
		for(var/check_wall_dir as anything in wall_dirs)
			if(resolve_building_place_rule_dir(check_wall_dir, place_rule.dir_mode) == dir_to_use)
				wall_dir = check_wall_dir
				break
	if(wall_mounted && isnull(wall_dir))
		return FALSE
	if(!building_place_rule_allows_turf(state, target_turf, place_rule, dir_to_use, wall_dir))
		return FALSE
	var/is_required_cluster = istype(cluster_spec) && cluster_spec.required
	var/budget = state.get_category_budget(category)
	if(!layout_scene_owner && !is_required_cluster && !major && isnum(budget) && budget > 0 && (state.fixtures.category_counts["[category]"] || 0) >= budget)
		return FALSE
	var/list/repeat_penalties = state.semantic_plan?.repeat_penalties
	var/list/repeat_rule = islist(repeat_penalties) && islist(repeat_penalties["[category]"]) ? repeat_penalties["[category]"] : list()
	var/hard_percent = round(text2num("[repeat_rule["hard_percent"]]") || 0)
	if(!layout_scene_owner && !is_required_cluster && !major && hard_percent > 0 && state.fixtures.fixture_count >= 4)
		var/projected_percent = round(((state.fixtures.category_counts["[category]"] || 0) + 1) * 100 / max(state.fixtures.fixture_count + 1, 1))
		if(projected_percent > hard_percent)
			return FALSE
	var/datum/world_edit_building_fixture_provider/provider = resolve_fixture_provider(state.config, slot)
	if(!istype(provider) || !provider.obj_path)
		state.add_warning("Unable to resolve fixture object '[slot]' for program [state.archetype.id].")
		return FALSE
	if(!building_fixture_provider_satisfies_slot(provider, slot, category))
		var/provider_reason = provider.reason_if_not_functional || "provider is not functionally equivalent"
		if(major || cluster_spec?.required)
			state.add_error("Fixture provider for required slot '[slot]' is not functional: [provider_reason].")
			state.validation.style_required_slot_missing_count++
		else
			state.add_warning("Skipping non-functional fixture provider for slot '[slot]': [provider_reason].")
		return FALSE
	var/obj_path = provider.obj_path
	var/list/object_placement = build_object_placement("interior", target_turf, obj_path, dir_to_use)
	object_placement["slot"] = "[slot]"
	object_placement["requested_slot"] = "[slot]"
	object_placement["required_capability"] = get_building_fixture_required_capability(slot, category)
	object_placement["provided_slots"] = provider.provides_slots.Copy()
	object_placement["provided_capabilities"] = provider.provides_capabilities.Copy()
	object_placement["fixture_provider_id"] = provider.id
	object_placement["functional"] = provider.functional ? TRUE : FALSE
	object_placement["category"] = "[category]"
	object_placement["major"] = major ? TRUE : FALSE
	object_placement["zone_id"] = state.get_zone(target_turf)
	object_placement["anchor_id"] = istype(cluster_spec) ? get_building_fixture_anchor_id_for_turf(state, target_turf, cluster_spec.anchors) : object_placement["zone_id"]
	object_placement["dir_label"] = GLOB.world_edit_helpers.dir_to_label(dir_to_use)
	object_placement["dir_source"] = length("[dir_source]") ? "[dir_source]" : (wall_mounted ? "wall_context" : "fallback_face")
	object_placement["dir_mode"] = place_rule.dir_mode
	object_placement["front_dir"] = get_building_place_rule_front_dir(dir_to_use, wall_dir, place_rule)
	object_placement["front_dir_label"] = GLOB.world_edit_helpers.dir_to_label(object_placement["front_dir"])
	if(length("[template_chunk_id]"))
		object_placement["template_chunk_id"] = "[template_chunk_id]"
		object_placement["template_chunk_instance_id"] = length("[template_chunk_instance_id]") ? "[template_chunk_instance_id]" : "[template_chunk_id]@[target_turf.x],[target_turf.y],[target_turf.z]"
	if(length("[module_id]"))
		object_placement["module_id"] = "[module_id]"
	if(length("[module_instance_id]"))
		object_placement["module_instance_id"] = "[module_instance_id]"
		object_placement["module_expected_member_count"] = max(round(text2num("[module_expected_member_count]") || 0), 1)
		if(length("[module_repeat_group]"))
			object_placement["module_repeat_group"] = "[module_repeat_group]"
		if(length("[module_room_id]"))
			object_placement["module_room_id"] = "[module_room_id]"
		object_placement["module_requires_table_pairing"] = module_requires_table_pairing ? TRUE : FALSE
		object_placement["module_seating_group_ok"] = module_seating_group_ok ? TRUE : FALSE
	if("[category]" in list("light", "apc", "air_alarm", "fire_alarm", "light_switch"))
		object_placement["infrastructure"] = TRUE
	if(istype(cluster_spec))
		var/count_cluster_id = length(cluster_spec.count_cluster_id) ? cluster_spec.count_cluster_id : cluster_spec.id
		var/count_signature_id = length(cluster_spec.count_signature_id) ? cluster_spec.count_signature_id : cluster_spec.signature_id
		var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
		var/count_credit = get_building_fixture_count_credit(cluster_spec, slot, category)
		object_placement["cluster_id"] = count_cluster_id
		object_placement["requirement_id"] = requirement_id
		object_placement["semantic_requirement_id"] = requirement_id
		object_placement["requirement_count_credit"] = count_credit
		if(count_cluster_id != cluster_spec.id)
			object_placement["cluster_source_id"] = cluster_spec.id
		object_placement["cluster_pattern"] = cluster_spec.pattern
		object_placement["cluster_count_credit"] = count_credit
		if(length(count_signature_id))
			object_placement["signature_id"] = count_signature_id
			object_placement["signature_count_credit"] = count_credit
		if(length(cluster_spec.macro_id))
			object_placement["layout_macro"] = cluster_spec.macro_id
	if(wall_mounted)
		object_placement["wall_mounted"] = TRUE
		object_placement["wall_dir"] = wall_dir
		object_placement["wall_dir_label"] = GLOB.world_edit_helpers.dir_to_label(wall_dir)
		object_placement["dir_mode"] = place_rule.dir_mode
	state.fixtures.object_placements += list(object_placement)
	state.register_fixture(target_turf, category, major, wall_mounted)
	if(istype(cluster_spec))
		var/requirement_id_to_count = get_building_cluster_requirement_id(cluster_spec)
		var/requirement_credit = get_building_fixture_count_credit(cluster_spec, slot, category)
		if(requirement_credit > 0)
			state.register_placed_requirement(requirement_id_to_count, requirement_credit)
	if(object_placement["infrastructure"])
		state.fixtures.infrastructure_count++
	return TRUE
