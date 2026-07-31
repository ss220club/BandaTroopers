/datum/world_edit_generator/building_layout/proc/building_zone_matches_signature_token(datum/world_edit_building_layout_state/state, zone_id, token)
	var/token_text = lowertext("[token]")
	if(!length(token_text))
		return FALSE
	var/zone_text = lowertext("[zone_id]")
	if(findtext(zone_text, token_text))
		return TRUE
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
	if(!istype(zone_spec))
		return FALSE
	if(findtext(lowertext("[zone_spec.role]"), token_text))
		return TRUE
	for(var/anchor_tag as anything in zone_spec.anchor_tags)
		if(findtext(lowertext("[anchor_tag]"), token_text))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_zone_matches_any_signature_token(datum/world_edit_building_layout_state/state, zone_id, list/tokens)
	if(!islist(tokens))
		return FALSE
	for(var/token as anything in tokens)
		if(building_zone_matches_signature_token(state, zone_id, token))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/building_turf_touches_reserved_lane(datum/world_edit_building_layout_state/state, turf/target_turf)
	if(!istype(state) || !istype(target_turf))
		return FALSE
	if(state.geometry.reserved_lookup[target_turf])
		return TRUE
	for(var/check_dir in GLOB.cardinals)
		if(state.geometry.reserved_lookup[get_step(target_turf, check_dir)])
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/add_building_signature_anchors(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		if(!istype(floor_turf))
			continue
		var/zone_id = state.get_zone(floor_turf)
		var/has_wall = length(get_adjacent_wall_dirs_for_state(state, floor_turf)) > 0
		var/touches_lane = building_turf_touches_reserved_lane(state, floor_turf)
		if(state.geometry.reserved_lookup[floor_turf])
			state.add_anchor("main_aisle", floor_turf)
			state.add_anchor("aisle", floor_turf)
		else if(touches_lane)
			state.add_anchor("aisle_edge", floor_turf)

		if(!length(zone_id))
			continue
		if(building_zone_matches_any_signature_token(state, zone_id, list("public", "entry", "triage", "dining")))
			state.add_anchor("public_side", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("secure", "counter_back", "locker", "armory", "holding")))
			state.add_anchor("secure_side", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("counter", "barrier", "serving")))
			state.add_anchor("counter_line_turf", floor_turf)
			if(touches_lane)
				state.add_anchor("counter_front", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("ritual", "chapel", "altar", "shrine", "nave", "axis")))
			state.add_anchor("ritual_axis", floor_turf)
			if(touches_lane || has_wall)
				state.add_anchor("barrier_line", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("storage", "rack", "loading", "staging")))
			state.add_anchor("rack_aisle", floor_turf)
			if(touches_lane)
				state.add_anchor("loading_axis", floor_turf)
			if(has_wall)
				state.add_anchor("storage_wall", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("service", "work", "machine", "cooking", "prep")))
			if(has_wall)
				state.add_anchor("service_wall", floor_turf)
				state.add_anchor("machine_wall", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("engineering", "power", "machine_bay", "parts")))
			state.add_anchor("engineering_bay", floor_turf)
			if(has_wall)
				state.add_anchor("engineering_wall", floor_turf)
				state.add_anchor("machine_wall", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("lab", "analysis", "specimen", "containment", "clean")))
			state.add_anchor("lab_bench", floor_turf)
			if(has_wall)
				state.add_anchor("lab_wall", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("treatment", "triage", "med", "surgery")))
			state.add_anchor("treatment_bay", floor_turf)
			if(has_wall)
				state.add_anchor("treatment_wall", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("grow", "hydro", "greenhouse")))
			state.add_anchor("hydro_row", floor_turf)
			if(state.has_anchor("window_band", floor_turf))
				state.add_anchor("greenhouse_band", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("sleep", "bunk", "private")))
			state.add_anchor("bunk_row", floor_turf)
			if(has_wall)
				state.add_anchor("bed_wall", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("desk", "office", "visitor")))
			state.add_anchor("desk_anchor", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("filing", "records")))
			if(has_wall)
				state.add_anchor("filing_wall_anchor", floor_turf)
		if(building_zone_matches_any_signature_token(state, zone_id, list("cold", "freezer", "pantry")))
			if(has_wall)
				state.add_anchor("cold_storage_wall", floor_turf)

/datum/world_edit_generator/building_layout/proc/place_building_signature_cluster(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count)
	if(!istype(state) || !istype(cluster_spec))
		return 0
	switch(cluster_spec.pattern)
		if("signature_workshop_wall")
			return place_signature_slot_run(state, cluster_spec, max(target_count, 5), list("table", "processor", "console", "rack"), list("table", "work_machine", "console", "rack"), TRUE)
		if("signature_rack_aisles")
			return place_signature_dense_pattern(state, cluster_spec, max(target_count, 7), list("rack", "rack", "crate"), list("rack", "rack", "crate"), TRUE)
		if("signature_hydro_rows")
			var/placed_hydro = place_signature_dense_pattern(state, cluster_spec, max(target_count, 8), list("hydro_tray"), list("hydro_tray"), FALSE)
			place_signature_support_fixture(state, list("work_counter", "seed_storage", "service_wall", "storage_wall"), "water_tank", "water_or_chem", TRUE, cluster_spec)
			place_signature_support_fixture(state, list("seed_storage", "storage_wall"), "seed_storage", "seed_storage", TRUE, cluster_spec)
			return placed_hydro
		if("signature_cook_line")
			return place_signature_slot_run(state, cluster_spec, max(target_count, 5), list("table", "microwave", "processor", "sink", "fridge"), list("table", "kitchen_machine", "kitchen_machine", "kitchen_machine", "cold_storage"), TRUE)
		if("signature_bed_rows")
			return place_signature_dense_pattern(state, cluster_spec, max(target_count, 5), list("bed", "bed", "cabinet"), list("bed", "bed", "cabinet"), TRUE)
		if("signature_treatment_bay")
			return place_signature_treatment_bay(state, cluster_spec, target_count)
		if("signature_office_suite")
			return place_signature_office_suite(state, cluster_spec, target_count)
		if("signature_security_counter")
			return place_signature_security_counter(state, cluster_spec, target_count)
		if("signature_living_nook")
			return place_signature_living_nook(state, cluster_spec, target_count)
		if("signature_engineering_bay")
			return place_signature_slot_run(state, cluster_spec, max(target_count, 5), list("engineering_machine", "power_console", "table", "rack"), list("engineering_machine", "console", "table", "rack"), TRUE)
		if("signature_lab_bench")
			return place_signature_slot_run(state, cluster_spec, max(target_count, 5), list("table", "lab_machine", "sample_storage", "medical_scanner"), list("table", "lab_machine", "sample_storage", "lab_machine"), TRUE)
	return 0

/datum/world_edit_generator/building_layout/proc/place_signature_dense_pattern(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count, list/slots, list/categories, force_wall = FALSE)
	if(!islist(slots) || !length(slots) || !islist(categories) || !length(categories))
		return 0
	return place_signature_slot_run(state, cluster_spec, target_count, slots, categories, force_wall)

/datum/world_edit_generator/building_layout/proc/place_signature_support_fixture(datum/world_edit_building_layout_state/state, list/anchors, slot, category, force_wall = FALSE, datum/world_edit_building_cluster_spec/parent_spec = null)
	var/datum/world_edit_building_cluster_spec/support_spec = new("support_[slot]_[category]", "major", "wall_object", slot, category, anchors, 1, 1, force_wall, 0, 70, TRUE)
	if(force_wall)
		return place_wall_fixture(state, support_spec)
	return place_fixture_object(state, support_spec)

/datum/world_edit_generator/building_layout/proc/place_signature_slot_run(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count, list/slots, list/categories, force_wall = FALSE)
	if(!islist(slots) || !length(slots) || !islist(categories) || !length(categories))
		return 0
	var/placed = 0
	var/attempts = 0
	while(placed < target_count && attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		attempts++
		var/turf/start_turf = select_fixture_turf(state, cluster_spec.anchors, force_wall || cluster_spec.wall_required, cluster_spec)
		if(!istype(start_turf))
			break
		var/start_slot = slots[1]
		var/start_category = categories[min(1, length(categories))]
		var/datum/world_edit_building_place_rule/start_rule = resolve_building_place_rule(start_slot, start_category)
		var/fallback_dir = get_cardinal_dir_toward(start_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
		var/list/place_context = build_building_fixture_place_context(state, start_turf, start_rule, fallback_dir, force_wall || cluster_spec.wall_required, cluster_spec, cluster_spec.anchors)
		if(!islist(place_context))
			break
		var/wall_dir = place_context["wall_dir"]
		var/dir_to_use = place_context["dir"] || fallback_dir
		if(!place_fixture_at(state, start_turf, start_slot, dir_to_use, start_category, cluster_spec.phase == "major" && placed <= 0, force_wall || cluster_spec.wall_required, start_rule, wall_dir, cluster_spec, null, null, place_context["dir_source"]))
			break
		placed++
		var/list/run_dirs = get_fixture_run_dirs(state, wall_dir)
		for(var/run_dir as anything in run_dirs)
			if(placed >= target_count)
				break
			placed = extend_signature_slot_run(state, start_turf, run_dir, cluster_spec, slots, categories, dir_to_use, wall_dir, placed, target_count, force_wall)
	return placed

/datum/world_edit_generator/building_layout/proc/extend_signature_slot_run(datum/world_edit_building_layout_state/state, turf/start_turf, run_dir, datum/world_edit_building_cluster_spec/cluster_spec, list/slots, list/categories, dir_to_use, wall_dir, placed, target_count, force_wall = FALSE)
	var/turf/current_turf = start_turf
	var/steps = 0
	while(placed < target_count && steps < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		steps++
		current_turf = get_step(current_turf, run_dir)
		if(!state.can_place_fixture(current_turf))
			break
		if(!fixture_turf_matches_anchor(state, current_turf, cluster_spec.anchors))
			break
		if((force_wall || cluster_spec.wall_required) && isnull(wall_dir))
			break
		if(!isnull(wall_dir) && !state.geometry.wall_lookup[get_step(current_turf, wall_dir)])
			break
		var/list_index = (placed % length(slots)) + 1
		var/slot = slots[list_index]
		var/category = categories[min(list_index, length(categories))]
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(slot, category)
		if(!building_place_rule_allows_turf(state, current_turf, place_rule, dir_to_use, wall_dir))
			break
		if(!place_fixture_at(state, current_turf, slot, dir_to_use, category, FALSE, force_wall || cluster_spec.wall_required, place_rule, wall_dir, cluster_spec, null, null, "signature_run"))
			break
		placed++
	return placed

/datum/world_edit_generator/building_layout/proc/place_signature_adjacent_fixture(datum/world_edit_building_layout_state/state, turf/source_turf, slot, category, preferred_dir = null, needs_wall = FALSE, datum/world_edit_building_cluster_spec/cluster_spec = null)
	if(!istype(state) || !istype(source_turf))
		return FALSE
	var/list/check_dirs = list()
	if(preferred_dir)
		check_dirs += preferred_dir
	for(var/check_dir in GLOB.cardinals)
		if(!(check_dir in check_dirs))
			check_dirs += check_dir
	for(var/check_dir as anything in check_dirs)
		var/turf/target_turf = get_step(source_turf, check_dir)
		if(!state.can_place_fixture(target_turf))
			continue
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(slot, category)
		var/fallback_dir = get_cardinal_dir_toward(target_turf, source_turf, SOUTH)
		var/list/place_context = build_building_fixture_place_context(state, target_turf, place_rule, fallback_dir, needs_wall || place_rule.needs_wall, cluster_spec, cluster_spec?.anchors)
		if(!islist(place_context))
			continue
		if(place_fixture_at(state, target_turf, slot, place_context["dir"] || fallback_dir, category, FALSE, needs_wall || place_rule.needs_wall, place_rule, place_context["wall_dir"], cluster_spec, null, null, place_context["dir_source"]))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/place_signature_treatment_bay(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count)
	var/placed = 0
	var/bed_target = max(1, round(target_count / 2))
	var/datum/world_edit_building_cluster_spec/bed_spec = new("[cluster_spec.id]_bed", cluster_spec.phase, "run", "sleeper", "medical_bed", cluster_spec.anchors, bed_target, bed_target, cluster_spec.wall_required, 0, cluster_spec.priority, TRUE)
	inherit_building_cluster_count_context(bed_spec, cluster_spec)
	placed += place_fixture_run(state, bed_spec, bed_target)
	for(var/turf/bed_turf as anything in state.fixtures.major_fixture_turfs.Copy())
		if(placed >= target_count + 2)
			break
		if(state.fixtures.fixture_categories[bed_turf] != "medical_bed")
			continue
		if(place_signature_adjacent_fixture(state, bed_turf, "medical_storage", "medical_storage", null, TRUE, cluster_spec))
			placed++
		if(place_signature_adjacent_fixture(state, bed_turf, "wall_monitor", "console", null, TRUE, cluster_spec))
			placed++
		if(place_signature_adjacent_fixture(state, bed_turf, "medical_scanner", "medical_bed", null, FALSE, cluster_spec))
			placed++
	return placed

/datum/world_edit_generator/building_layout/proc/place_signature_office_suite(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count)
	var/placed = place_table_cluster(state, cluster_spec)
	if(placed <= 0)
		return 0
	var/datum/world_edit_building_cluster_spec/console_spec = new("[cluster_spec.id]_console", cluster_spec.phase, "wall_object", "console", "console", list("desk_core", "desk_anchor", "wall_anchor", "service_wall"), 1, 1, TRUE, 0, cluster_spec.priority, TRUE)
	inherit_building_cluster_count_context(console_spec, cluster_spec)
	placed += place_wall_fixture(state, console_spec)
	var/datum/world_edit_building_cluster_spec/filing_spec = new("[cluster_spec.id]_filing", cluster_spec.phase, "wall_object", "filing", "cabinet", list("filing_wall", "filing_wall_anchor", "storage_wall", "wall_anchor"), 1, 1, TRUE, 0, cluster_spec.priority, TRUE)
	inherit_building_cluster_count_context(filing_spec, cluster_spec)
	placed += place_wall_fixture(state, filing_spec)
	return min(placed, max(target_count, cluster_spec.min_count))

/datum/world_edit_generator/building_layout/proc/place_signature_security_counter(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count)
	var/counter_count = max(2, min(target_count, 4))
	var/datum/world_edit_building_cluster_spec/counter_spec = new("[cluster_spec.id]_counter", cluster_spec.phase, "counter_line", "table", "table", cluster_spec.anchors, counter_count, counter_count, FALSE, 0, cluster_spec.priority, TRUE)
	inherit_building_cluster_count_context(counter_spec, cluster_spec)
	var/placed = place_fixture_run(state, counter_spec, counter_count)
	var/list/secure_turfs = state.get_anchor_turfs("secure_side")
	for(var/turf/secure_turf as anything in secure_turfs)
		if(placed >= target_count + 2)
			break
		if(!state.can_place_fixture(secure_turf))
			continue
		var/datum/world_edit_building_place_rule/console_rule = resolve_building_place_rule("security_console", "console")
		var/fallback_dir = get_cardinal_dir_toward(secure_turf, state.geometry.front_door_turf || state.geometry.center_turf, SOUTH)
		var/list/place_context = build_building_fixture_place_context(state, secure_turf, console_rule, fallback_dir, TRUE, cluster_spec, cluster_spec.anchors)
		if(!islist(place_context))
			continue
		if(place_fixture_at(state, secure_turf, "security_console", place_context["dir"] || fallback_dir, "console", TRUE, TRUE, console_rule, place_context["wall_dir"], cluster_spec, null, null, place_context["dir_source"]))
			placed++
			place_signature_adjacent_fixture(state, secure_turf, "chair", "chair", turn(place_context["dir"] || fallback_dir, 180), FALSE)
			break
	for(var/turf/secure_turf as anything in secure_turfs)
		if(placed >= target_count + 3)
			break
		if(place_signature_adjacent_fixture(state, secure_turf, "cabinet", "cabinet", null, TRUE, cluster_spec))
			placed++
		if(place_signature_adjacent_fixture(state, secure_turf, "security_camera", "security_camera", null, TRUE, cluster_spec))
			placed++
		if(place_signature_adjacent_fixture(state, secure_turf, "weapon_rack", "weapon_rack", null, TRUE, cluster_spec))
			placed++
	var/list/holding_turfs = state.get_anchor_turfs("holding_nook")
	for(var/turf/holding_turf as anything in holding_turfs)
		if(place_signature_adjacent_fixture(state, holding_turf, "brig_cell", "security_machine", null, TRUE, cluster_spec))
			placed++
			break
	return placed

/datum/world_edit_generator/building_layout/proc/place_signature_living_nook(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, target_count)
	var/placed = place_signature_slot_run(state, cluster_spec, max(1, target_count), list("bed", "cabinet"), list("bed", "cabinet"), TRUE)
	if(placed > 0 && target_count > placed)
		var/datum/world_edit_building_cluster_spec/table_spec = new("[cluster_spec.id]_table", cluster_spec.phase, "table_cluster", "table", "table", list("common", "social_focus", "focus_center"), 1, 1, FALSE, 1, cluster_spec.priority, TRUE)
		inherit_building_cluster_count_context(table_spec, cluster_spec)
		placed += place_table_cluster(state, table_spec)
	return placed
