/datum/world_edit_building_placement_module
	var/id = ""
	var/label = ""
	var/phase = "major"
	var/list/allowed_programs = list()
	var/list/allowed_zone_ids = list()
	var/list/allowed_room_roles = list()
	var/list/source_cluster_ids = list()
	var/list/source_signature_ids = list()
	var/list/source_macro_ids = list()
	var/list/required_provider_slots = list()
	var/list/occupied_offsets = list()
	var/list/front_access_offsets = list()
	var/list/interaction_offsets = list()
	var/list/aisle_offsets = list()
	var/list/forbidden_offsets = list()
	var/list/member_specs = list()
	var/repeat_group = ""
	var/max_per_room = 1
	var/max_per_building = 999
	var/max_repeat_group_per_room = 1
	var/priority = 50
	var/wall_required = FALSE
	var/pattern = "single_floor"
	var/requires_table_pairing = FALSE
	var/seating_group_ok = FALSE
	var/curated = FALSE
	var/curated_recipe_id = ""

/datum/world_edit_building_placement_module_catalog
	var/list/modules_by_id = list()
	var/list/modules_by_cluster_id = list()
	var/list/modules_by_signature_id = list()
	var/list/modules_by_macro_id = list()
	var/curated_module_count = 0
	var/generated_module_count = 0

/datum/world_edit_building_placement_module_catalog/proc/register_module(datum/world_edit_building_placement_module/module)
	if(!istype(module) || !length(module.id))
		return
	if(!modules_by_id[module.id])
		if(module.curated)
			curated_module_count++
		else
			generated_module_count++
	modules_by_id[module.id] = module
	for(var/cluster_id as anything in module.source_cluster_ids)
		if(!islist(modules_by_cluster_id["[cluster_id]"]))
			modules_by_cluster_id["[cluster_id]"] = list()
		modules_by_cluster_id["[cluster_id]"] += module
	for(var/signature_id as anything in module.source_signature_ids)
		if(!islist(modules_by_signature_id["[signature_id]"]))
			modules_by_signature_id["[signature_id]"] = list()
		modules_by_signature_id["[signature_id]"] += module
	for(var/macro_id as anything in module.source_macro_ids)
		if(!islist(modules_by_macro_id["[macro_id]"]))
			modules_by_macro_id["[macro_id]"] = list()
		modules_by_macro_id["[macro_id]"] += module

/datum/world_edit_building_placement_module_catalog/proc/has_module(module_id)
	return istype(modules_by_id["[module_id]"], /datum/world_edit_building_placement_module)

/datum/world_edit_building_placement_module_catalog/proc/get_module(module_id)
	return modules_by_id["[module_id]"]

/datum/world_edit_building_placement_module_catalog/proc/get_for_cluster(datum/world_edit_building_cluster_spec/cluster_spec)
	var/list/result = list()
	var/list/generated_result = list()
	var/list/seen = list()
	if(!istype(cluster_spec))
		return result
	for(var/source_list as anything in list(modules_by_cluster_id["[cluster_spec.id]"], modules_by_cluster_id["[cluster_spec.count_cluster_id]"], modules_by_signature_id["[cluster_spec.signature_id]"], modules_by_macro_id["[cluster_spec.macro_id]"]))
		if(!islist(source_list))
			continue
		for(var/datum/world_edit_building_placement_module/module as anything in source_list)
			if(!istype(module) || seen[module.id])
				continue
			seen[module.id] = TRUE
			if(module.curated)
				result += module
			else
				generated_result += module
	for(var/datum/world_edit_building_placement_module/generated_module as anything in generated_result)
		result += generated_module
	return result

/datum/world_edit_generator/building_layout/proc/get_building_placement_module_catalog()
	if(istype(GLOB.world_edit_building_placement_module_catalog, /datum/world_edit_building_placement_module_catalog))
		return GLOB.world_edit_building_placement_module_catalog
	var/datum/world_edit_building_placement_module_catalog/catalog = new
	var/list/archetypes = get_building_archetype_catalog()
	register_curated_building_placement_modules(catalog, archetypes)
	for(var/program_id as anything in archetypes)
		var/datum/world_edit_building_archetype/archetype = archetypes[program_id]
		if(!istype(archetype))
			continue
		for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in archetype.cluster_specs)
			if(!istype(cluster_spec) || !is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
				continue
			register_building_modules_for_cluster(catalog, archetype, cluster_spec)
	GLOB.world_edit_building_placement_module_catalog = catalog
	return catalog

/datum/world_edit_generator/building_layout/proc/register_curated_building_placement_modules(datum/world_edit_building_placement_module_catalog/catalog, list/archetypes)
	var/list/families = list(
		list("living", "sleep_nook_signature", list("wall_pair", "nook_pair", "long_pair")),
		list("living", "dining_pair", list("table_pair", "table_corner", "desk_suite")),
		list("living", "center_social_cluster", list("table_cross", "table_corner", "compact_table")),
		list("living", "ring_social_cluster", list("table_cross", "table_arc", "table_pair", "compact_table")),
		list("living", "personal_storage", list("wall_single", "wall_pair", "service_line")),
		list("living", "sanitation_combined", list("wall_single", "service_single", "compact_single")),
		list("living", "side_table", list("table_pair", "compact_table")),
		list("living", "center_chair_group", list("seating_row", "seating_corner")),
		list("workshop", "workbench_machine_wall", list("wall_quad", "wall_line", "wide_line", "service_line")),
		list("workshop", "workbench_machine_wall_compact", list("wall_single", "wall_pair", "compact_single")),
		list("workshop", "parts_rack_aisles", list("aisle_line", "wall_line", "wide_line")),
		list("workshop", "parts_rack_aisles_compact", list("wall_pair", "compact_single")),
		list("workshop", "central_assembly_table", list("table_pair", "table_corner", "desk_suite")),
		list("workshop", "operator_console", list("wall_single", "service_single")),
		list("workshop", "tool_storage", list("wall_pair", "wall_single")),
		list("workshop", "parts_crate_stack", list("staging_pair", "staging_corner", "compact_single")),
		list("storage", "rack_aisles", list("aisle_six", "aisle_line", "wide_line", "wall_line", "compact_single")),
		list("storage", "loading_crates", list("staging_pair", "staging_corner", "staging_line", "compact_single")),
		list("storage", "inspection_table", list("desk_suite", "table_pair")),
		list("storage", "crate_stack", list("staging_pair", "staging_line", "compact_single")),
		list("medbay", "treatment_bay_signature", list("wall_line", "wide_line", "service_line", "wall_single", "compact_single")),
		list("medbay", "med_storage_wall", list("wall_single")),
		list("medbay", "triage_table", list("desk_suite", "table_pair", "compact_table")),
		list("medbay", "waiting_chairs", list("seating_row", "seating_corner")),
		list("medbay", "med_side_storage", list("wall_single", "service_single")),
		list("medbay", "surgery_bed", list("centerpiece_single", "compact_single")),
		list("medbay", "cryo_sleeper", list("wall_single", "service_single")),
		list("medbay", "chem_storage", list("wall_single", "service_single")),
		list("medbay", "morgue_storage", list("wall_pair", "service_line")),
		list("hydroponics", "hydro_tray_rows", list("grow_grid_6", "row_line", "wide_line", "grid_line", "compact_single")),
		list("hydroponics", "service_counter", list("wall_pair", "service_line", "compact_single")),
		list("hydroponics", "seed_cabinets", list("wall_pair", "service_line", "compact_single")),
		list("hydroponics", "seed_cabinets_compact", list("wall_single", "service_single")),
		list("hydroponics", "fertilizer_crates", list("staging_pair", "staging_corner", "compact_single")),
		list("hydroponics", "tool_rack", list("wall_single", "service_single")),
		list("hydroponics", "grower_chair", list("seating_single", "seating_corner")),
		list("kitchen", "serving_counter", list("counter_line", "wide_line", "service_line")),
		list("kitchen", "prep_tables", list("table_pair", "desk_suite", "compact_table")),
		list("kitchen", "cooking_run", list("wall_quad", "wall_line", "service_line", "wide_line", "wall_single", "service_single", "compact_single")),
		list("kitchen", "cold_storage_wall", list("wall_pair", "wall_line", "compact_single")),
		list("kitchen", "dining_tables", list("table_pair", "table_corner", "compact_table")),
		list("kitchen", "pantry_rack", list("wall_single", "service_single")),
		list("kitchen", "supply_crates", list("staging_pair", "staging_corner", "compact_single")),
		list("dormitory", "bed_wall_runs", list("wall_quad", "wall_line", "wide_line", "long_pair", "wall_single")),
		list("dormitory", "locker_wall", list("wall_line", "wall_pair", "service_line")),
		list("dormitory", "locker_wall_compact", list("wall_pair", "wall_single", "service_single", "compact_single")),
		list("dormitory", "ready_table", list("table_pair", "table_corner", "desk_suite")),
		list("dormitory", "personal_rack", list("wall_single", "service_single")),
		list("dormitory", "footlocker_crates", list("staging_pair", "staging_corner", "compact_single")),
		list("office", "primary_desk_suite", list("desk_suite", "table_pair", "table_corner")),
		list("office", "filing_cabinets", list("wall_line", "wall_pair", "service_line", "compact_single")),
		list("office", "office_console", list("wall_single", "service_single")),
		list("office", "visitor_chairs", list("seating_row", "seating_corner")),
		list("office", "side_storage", list("wall_single", "service_single")),
		list("office", "records_terminal", list("wall_single", "service_single")),
		list("security", "security_control_counter", list("counter_quad", "counter_line", "wide_line", "service_line")),
		list("security", "locker_run", list("wall_pair", "wall_line", "service_line")),
		list("security", "holding_bed", list("wall_single", "compact_single")),
		list("security", "evidence_rack", list("wall_single", "service_single")),
		list("security", "armory_rack", list("wall_pair", "wall_single")),
		list("security", "evidence_storage", list("wall_pair", "wall_single")),
		list("security", "visitor_chair", list("seating_row", "seating_corner")),
		list("checkpoint", "checkpoint_control", list("counter_line", "wide_line", "service_line")),
		list("checkpoint", "operator_console", list("wall_single", "service_single")),
		list("checkpoint", "security_storage", list("wall_single", "service_single")),
		list("checkpoint", "visitor_chair", list("seating_single", "seating_corner")),
		list("checkpoint", "barricade_line", list("staging_pair", "staging_line")),
		list("chapel", "altar_focus", list("table_pair", "compact_table")),
		list("chapel", "seating_left_rows", list("seating_row")),
		list("chapel", "seating_right_rows", list("seating_row")),
		list("ritual_chamber", "ritual_centerpiece", list("centerpiece_single")),
		list("ritual_chamber", "axis_barriers", list("staging_line", "staging_pair")),
		list("ritual_chamber", "reliquary_wall", list("wall_pair", "service_line")),
		list("compound_colony", "central_table", list("table_cross")),
		list("compound_colony", "living_beds", list("wall_pair", "long_pair")),
		list("compound_colony", "workbench_run", list("wall_pair", "service_line")),
		list("compound_colony", "storage_racks", list("wall_pair", "service_line")),
		list("engineering", "engineering_service_wall", list("wall_quad", "aisle_line", "compact_single")),
		list("engineering", "power_console_wall", list("wall_single")),
		list("engineering", "parts_racks", list("aisle_line", "compact_single")),
		list("engineering", "generator_unit", list("wall_single")),
		list("engineering", "cable_crates", list("staging_pair", "staging_line", "compact_single")),
		list("laboratory", "lab_bench_signature", list("wall_quad", "wall_pair", "service_line")),
		list("laboratory", "sample_storage_wall", list("wall_pair", "service_line")),
		list("laboratory", "analysis_table", list("table_pair", "compact_table")),
		list("laboratory", "research_console", list("wall_single", "service_single"))
	)
	for(var/list/family as anything in families)
		if(!islist(family) || length(family) < 3)
			continue
		var/program_id = "[family[1]]"
		var/cluster_id = "[family[2]]"
		var/list/recipe_ids = family[3]
		var/datum/world_edit_building_archetype/archetype = islist(archetypes) ? archetypes[program_id] : null
		if(!istype(archetype) || !islist(recipe_ids))
			continue
		var/datum/world_edit_building_cluster_spec/cluster_spec = find_building_cluster_spec_by_id(archetype, cluster_id)
		if(!istype(cluster_spec) || !is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
			continue
		for(var/recipe_id as anything in recipe_ids)
			var/datum/world_edit_building_placement_module/module = build_curated_building_module_from_cluster(archetype, cluster_spec, "[recipe_id]")
			catalog.register_module(module)

/datum/world_edit_generator/building_layout/proc/find_building_cluster_spec_by_id(datum/world_edit_building_archetype/archetype, cluster_id)
	if(!istype(archetype) || !length("[cluster_id]"))
		return null
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in archetype.cluster_specs)
		if(istype(cluster_spec) && cluster_spec.id == "[cluster_id]")
			return cluster_spec
	return null

/datum/world_edit_generator/building_layout/proc/build_curated_building_module_from_cluster(datum/world_edit_building_archetype/archetype, datum/world_edit_building_cluster_spec/cluster_spec, recipe_id)
	var/datum/world_edit_building_placement_module/module = new
	var/clean_recipe_id = sanitize_filename("[recipe_id]")
	module.id = "curated__[archetype.id]__[cluster_spec.id]__[clean_recipe_id]"
	module.label = "[archetype.id] [cluster_spec.id] [clean_recipe_id]"
	module.phase = cluster_spec.phase
	module.allowed_programs = list(archetype.id)
	module.allowed_zone_ids = build_building_module_allowed_zones(archetype, cluster_spec)
	module.allowed_room_roles = build_building_module_allowed_roles(archetype, module.allowed_zone_ids)
	module.source_cluster_ids = list(cluster_spec.id)
	if(length(cluster_spec.signature_id))
		module.source_signature_ids = list(cluster_spec.signature_id)
	if(length(cluster_spec.macro_id))
		module.source_macro_ids = list(cluster_spec.macro_id)
	module.required_provider_slots = list(cluster_spec.slot)
	module.repeat_group = length(cluster_spec.signature_id) ? cluster_spec.signature_id : (length(cluster_spec.macro_id) ? cluster_spec.macro_id : cluster_spec.id)
	module.max_per_room = max(cluster_spec.max_count, 1)
	module.max_per_building = max(cluster_spec.max_count, 1)
	module.max_repeat_group_per_room = max(cluster_spec.max_count, 1)
	module.priority = cluster_spec.priority + 25
	var/wall_recipe = (clean_recipe_id in list("wall_single", "wall_pair", "wall_line", "wall_quad", "service_line", "long_pair", "nook_pair", "counter_line", "counter_quad")) ? TRUE : FALSE
	module.wall_required = (cluster_spec.slot == "toilet" && cluster_spec.category == "sanitation") ? FALSE : (cluster_spec.wall_required || wall_recipe)
	module.pattern = "curated_[clean_recipe_id]"
	module.curated = TRUE
	module.curated_recipe_id = clean_recipe_id
	build_curated_building_module_member_specs(module, cluster_spec, clean_recipe_id)
	module.requires_table_pairing = (module_has_building_module_slot(module, "chair") && module_has_building_module_slot(module, "table"))
	module.seating_group_ok = (cluster_spec.slot == "chair" || cluster_spec.category == "chair" || findtext("[cluster_spec.id]|[cluster_spec.signature_id]|[cluster_spec.macro_id]|[clean_recipe_id]", "seating")) ? TRUE : FALSE
	return module

/datum/world_edit_generator/building_layout/proc/module_has_building_module_slot(datum/world_edit_building_placement_module/module, slot)
	if(!istype(module))
		return FALSE
	for(var/list/member as anything in module.member_specs)
		if(islist(member) && "[member["slot"]]" == "[slot]")
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/build_curated_building_module_member_specs(datum/world_edit_building_placement_module/module, datum/world_edit_building_cluster_spec/cluster_spec, recipe_id)
	if(cluster_spec.pattern == "table_cluster" || cluster_spec.chair_count > 0)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		var/list/chair_offsets = list(list(0, 1), list(0, -1), list(1, 0), list(-1, 0))
		var/chairs = clamp(cluster_spec.chair_count, 1, 4)
		if(recipe_id in list("compact_table", "desk_suite"))
			chairs = min(chairs, 1)
		else if(recipe_id in list("table_pair", "table_corner", "table_arc"))
			chairs = min(chairs, 2)
		for(var/index in 1 to chairs)
			var/list/offset = chair_offsets[index]
			add_building_module_member(module, "chair", "chair", offset[1], offset[2], FALSE)
	else if(recipe_id in list("seating_row", "seating_corner") || cluster_spec.slot == "chair")
		var/member_count = min(max(cluster_spec.max_count, 1), recipe_id == "seating_row" ? 3 : 2)
		for(var/index in 1 to member_count)
			var/dx = recipe_id == "seating_corner" && index == 2 ? 0 : index - 1
			var/dy = recipe_id == "seating_corner" && index == 2 ? 1 : 0
			add_building_module_member(module, cluster_spec.slot, cluster_spec.category, dx, dy, index == 1)
	else
		var/member_count = 1
		if(recipe_id in list("grow_grid_6", "aisle_six"))
			member_count = min(max(cluster_spec.max_count, 1), 6)
		else if(recipe_id in list("wall_quad", "counter_quad"))
			member_count = min(max(cluster_spec.max_count, 1), 4)
		else if(recipe_id in list("wall_pair", "service_line", "staging_pair", "staging_corner", "long_pair", "nook_pair"))
			member_count = min(max(cluster_spec.max_count, 1), 2)
		else if(recipe_id in list("wall_line", "wide_line", "aisle_line", "row_line", "grid_line", "counter_line", "staging_line"))
			member_count = min(max(cluster_spec.max_count, 1), 3)
		for(var/index in 1 to member_count)
			var/dx = index - 1
			var/dy = 0
			if(recipe_id in list("grow_grid_6", "aisle_six"))
				dx = (index - 1) % 3
				dy = floor((index - 1) / 3)
			else if(recipe_id in list("staging_corner", "nook_pair") && index == 2)
				dx = 0
				dy = 1
			else if(recipe_id == "wide_line" && index > 1)
				dx = (index - 1) * 2
			else if(recipe_id == "grid_line" && index == 3)
				dx = 0
				dy = 1
			add_building_module_member(module, cluster_spec.slot, cluster_spec.category, dx, dy, index == 1)
	if(recipe_id == "grow_grid_6")
		for(var/dx in 0 to 2)
			add_building_module_clearance(module, dx, 2)
	else if(recipe_id in list("compact_single", "service_single", "seating_single", "centerpiece_single"))
		add_building_module_clearance(module, 0, 1)
	else if(recipe_id in list("aisle_six", "aisle_line", "row_line", "grid_line", "staging_pair", "staging_corner", "staging_line", "wide_line"))
		for(var/list/member as anything in module.member_specs)
			add_building_module_clearance(module, member["dx"], round(text2num("[member["dy"]]") || 0) + 1, "aisle")
	else if(cluster_spec.pattern == "table_cluster" || cluster_spec.chair_count > 0)
		// Curated table recipes author interaction geometry explicitly. A blanket
		// four-neighbour halo around every chair reserves irrelevant side cells and
		// makes the nominal compact recipe impossible beside a valid door cone. The
		// rotatable one-sided lane is the authored approach; door-to-focus path
		// validation chooses the accessible side for the concrete room.
		add_building_module_clearance(module, 1, 0, "interaction")
	else
		for(var/list/member as anything in module.member_specs)
			var/dx = round(text2num("[member["dx"]]") || 0)
			var/dy = round(text2num("[member["dy"]]") || 0)
			if(module.wall_required)
				// Curated wall recipes have an authored frontage: members run on
				// the local X axis and the interaction lane is one tile forward.
				// Reserving all four neighbours also reserves the wall behind the
				// module and makes every multi-member wall recipe impossible.
				add_building_module_clearance(module, dx, dy + 1, "front")
			else
				for(var/list/nearby in list(list(dx + 1, dy), list(dx - 1, dy), list(dx, dy + 1), list(dx, dy - 1)))
					add_building_module_clearance(module, nearby[1], nearby[2])

/datum/world_edit_generator/building_layout/proc/register_building_modules_for_cluster(datum/world_edit_building_placement_module_catalog/catalog, datum/world_edit_building_archetype/archetype, datum/world_edit_building_cluster_spec/cluster_spec)
	var/list/variants = list("base")
	if(cluster_spec.max_count > 1 || cluster_spec.chair_count > 0 || cluster_spec.pattern in list("run", "counter_line", "staging_group"))
		variants += "run"
	if(cluster_spec.max_count > 1 && cluster_spec.pattern != "table_cluster")
		variants += "wide"
	if(cluster_spec.max_count > 1 && cluster_spec.slot == "bed")
		variants += "long"
		variants += "diag_left"
		variants += "diag_right"
	if(cluster_spec.pattern == "table_cluster" && cluster_spec.chair_count > 1)
		variants += "compact"
	if(cluster_spec.phase != "major" || !cluster_spec.required)
		variants += "detail"
	for(var/variant as anything in variants)
		var/datum/world_edit_building_placement_module/module = build_building_module_from_cluster(archetype, cluster_spec, variant)
		catalog.register_module(module)

/datum/world_edit_generator/building_layout/proc/build_building_module_from_cluster(datum/world_edit_building_archetype/archetype, datum/world_edit_building_cluster_spec/cluster_spec, variant)
	var/datum/world_edit_building_placement_module/module = new
	module.id = "[archetype.id]__[cluster_spec.id]__[variant]"
	module.label = "[archetype.id] [cluster_spec.id] [variant]"
	module.phase = cluster_spec.phase
	module.allowed_programs = list(archetype.id)
	module.allowed_zone_ids = build_building_module_allowed_zones(archetype, cluster_spec)
	module.allowed_room_roles = build_building_module_allowed_roles(archetype, module.allowed_zone_ids)
	module.source_cluster_ids = list(cluster_spec.id)
	if(length(cluster_spec.signature_id))
		module.source_signature_ids = list(cluster_spec.signature_id)
	if(length(cluster_spec.macro_id))
		module.source_macro_ids = list(cluster_spec.macro_id)
	module.required_provider_slots = list(cluster_spec.slot)
	module.repeat_group = length(cluster_spec.signature_id) ? cluster_spec.signature_id : (length(cluster_spec.macro_id) ? cluster_spec.macro_id : cluster_spec.id)
	module.max_per_room = max(cluster_spec.max_count, 1)
	module.max_per_building = max(cluster_spec.max_count, 1)
	module.max_repeat_group_per_room = max(cluster_spec.max_count, 1)
	module.priority = cluster_spec.priority
	module.wall_required = (cluster_spec.slot == "toilet" && cluster_spec.category == "sanitation") ? FALSE : cluster_spec.wall_required
	module.pattern = cluster_spec.pattern
	module.requires_table_pairing = (cluster_spec.pattern == "table_cluster" && cluster_spec.chair_count > 0)
	module.seating_group_ok = (cluster_spec.slot == "chair" || cluster_spec.category == "chair" || findtext("[cluster_spec.id]|[cluster_spec.signature_id]|[cluster_spec.macro_id]", "seating")) ? TRUE : FALSE
	build_building_module_member_specs(module, cluster_spec, variant)
	return module

/datum/world_edit_generator/building_layout/proc/build_building_module_allowed_zones(datum/world_edit_building_archetype/archetype, datum/world_edit_building_cluster_spec/cluster_spec)
	var/list/zones = list()
	var/list/seen = list()
	for(var/anchor_id as anything in cluster_spec.anchors)
		var/datum/world_edit_building_zone_spec/zone_spec = archetype.zone_specs_by_id["[anchor_id]"]
		if(istype(zone_spec) && !seen[zone_spec.id])
			zones += zone_spec.id
			seen[zone_spec.id] = TRUE
			continue
		for(var/zone_id as anything in archetype.zone_specs_by_id)
			if(findtext("[anchor_id]", "[zone_id]_") == 1 && !seen[zone_id])
				zones += zone_id
				seen[zone_id] = TRUE
			var/datum/world_edit_building_zone_spec/tagged_zone_spec = archetype.zone_specs_by_id[zone_id]
			if(!istype(tagged_zone_spec) || seen[tagged_zone_spec.id])
				continue
			if("[anchor_id]" in tagged_zone_spec.anchor_tags)
				zones += tagged_zone_spec.id
				seen[tagged_zone_spec.id] = TRUE
	if(!length(zones))
		switch("[cluster_spec.slot]")
			if("bed")
				for(var/zone_id in list("sleep_privacy", "sleep_bay", "living_wing", "holding_nook"))
					if(archetype.zone_specs_by_id[zone_id] && !seen[zone_id])
						zones += zone_id
						seen[zone_id] = TRUE
			if("toilet", "sink")
				if(archetype.zone_specs_by_id["sanitation"])
					zones += "sanitation"
			if("medical_bed", "medical_storage", "sleeper", "medical_scanner", "wall_monitor")
				for(var/zone_id in list("treatment", "med_storage", "clinic_nook", "surgery_core", "cryo_bay", "treatment_wall", "treatment_bay"))
					if(archetype.zone_specs_by_id[zone_id] && !seen[zone_id])
						zones += zone_id
						seen[zone_id] = TRUE
			if("hydro_tray", "seed_storage")
				for(var/zone_id in list("grow_rows", "seed_storage", "greenhouse_band"))
					if(archetype.zone_specs_by_id[zone_id] && !seen[zone_id])
						zones += zone_id
						seen[zone_id] = TRUE
			if("weapon_rack", "security_console", "security_camera", "brig_cell")
				for(var/zone_id in list("armory_nook", "secure_storage", "secure_side", "locker_storage", "public_lobby"))
					if(archetype.zone_specs_by_id[zone_id] && !seen[zone_id])
						zones += zone_id
						seen[zone_id] = TRUE
	return zones

/datum/world_edit_generator/building_layout/proc/build_building_module_allowed_roles(datum/world_edit_building_archetype/archetype, list/zone_ids)
	var/list/roles = list()
	var/list/seen = list()
	for(var/zone_id as anything in zone_ids)
		var/datum/world_edit_building_zone_spec/zone_spec = archetype.zone_specs_by_id["[zone_id]"]
		if(!istype(zone_spec) || !length(zone_spec.role) || seen[zone_spec.role])
			continue
		roles += zone_spec.role
		seen[zone_spec.role] = TRUE
	return roles

/datum/world_edit_generator/building_layout/proc/add_building_module_member(datum/world_edit_building_placement_module/module, slot, category, dx, dy, major = TRUE)
	module.member_specs += list(list("slot" = "[slot]", "category" = "[category]", "dx" = round(dx), "dy" = round(dy), "major" = major ? TRUE : FALSE))
	module.occupied_offsets += list("[round(dx)],[round(dy)]")
	if(!("[slot]" in module.required_provider_slots))
		module.required_provider_slots += "[slot]"

/datum/world_edit_generator/building_layout/proc/add_building_module_clearance(datum/world_edit_building_placement_module/module, dx, dy, clearance_kind = "")
	var/key = "[round(dx)],[round(dy)]"
	var/list/target_offsets = module.interaction_offsets
	switch("[clearance_kind]")
		if("front")
			target_offsets = module.front_access_offsets
		if("aisle")
			target_offsets = module.aisle_offsets
		if("forbidden")
			target_offsets = module.forbidden_offsets
		else
			if(module.wall_required)
				target_offsets = module.front_access_offsets
	if(!(key in target_offsets))
		target_offsets += key

/datum/world_edit_generator/building_layout/proc/get_building_module_clearance_offsets(datum/world_edit_building_placement_module/module)
	var/list/result = list()
	if(!istype(module))
		return result
	for(var/offset_key as anything in module.front_access_offsets + module.interaction_offsets + module.aisle_offsets + module.forbidden_offsets)
		if(!(offset_key in result))
			result += offset_key
	return result

/datum/world_edit_generator/building_layout/proc/build_building_module_member_specs(datum/world_edit_building_placement_module/module, datum/world_edit_building_cluster_spec/cluster_spec, variant)
	if(cluster_spec.pattern == "table_cluster")
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		var/chairs = clamp(cluster_spec.chair_count, 0, 4)
		if(variant == "compact")
			chairs = min(chairs, 1)
		var/list/chair_offsets = list(list(0, 1), list(0, -1), list(1, 0), list(-1, 0))
		for(var/index in 1 to chairs)
			var/list/offset = chair_offsets[index]
			add_building_module_member(module, "chair", "chair", offset[1], offset[2], FALSE)
	else if(cluster_spec.pattern == "paired_object")
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 1, 0, FALSE)
	else if(cluster_spec.pattern in list("run", "counter_line", "staging_group") && variant == "run")
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 1, 0, FALSE)
	else if(variant == "run" && cluster_spec.max_count > 1)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 1, 0, FALSE)
	else if(variant == "wide" && cluster_spec.max_count > 1)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 2, 0, FALSE)
	else if(variant == "long" && cluster_spec.max_count > 1)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 3, 0, FALSE)
	else if(variant == "diag_left" && cluster_spec.max_count > 1)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 1, 1, FALSE)
	else if(variant == "diag_right" && cluster_spec.max_count > 1)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 1, -1, FALSE)
	else
		add_building_module_member(module, cluster_spec.slot, cluster_spec.category, 0, 0, TRUE)
	for(var/list/member as anything in module.member_specs)
		var/dx = round(text2num("[member["dx"]]") || 0)
		var/dy = round(text2num("[member["dy"]]") || 0)
		for(var/list/nearby in list(list(dx + 1, dy), list(dx - 1, dy), list(dx, dy + 1), list(dx, dy - 1)))
			add_building_module_clearance(module, nearby[1], nearby[2])

/datum/world_edit_generator/building_layout/proc/is_building_semantic_furniture_slot(slot, category = null)
	var/slot_key = "[slot]"
	var/category_key = "[category]"
	if(slot_key in list("light", "apc", "air_alarm", "fire_alarm", "light_switch"))
		return FALSE
	if(slot_key in list("table", "chair", "bed", "toilet", "sink", "medical_bed", "medical_storage", "sleeper", "medical_scanner", "wall_monitor", "hydro_tray", "seed_storage", "weapon_rack", "security_console", "security_camera", "brig_cell", "cabinet", "rack", "crate", "console", "filing", "fridge", "microwave", "processor", "water_tank", "engineering_machine", "power_console", "lab_machine", "sample_storage", "barrier"))
		return TRUE
	return category_key in list("table", "chair", "bed", "sanitation", "medical_bed", "medical_storage", "hydro_tray", "weapon_rack", "rack", "cabinet", "crate", "console", "barrier")

/datum/world_edit_generator/building_layout/proc/place_building_modules_for_cluster(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, major)
	if(!istype(state) || !istype(cluster_spec))
		return 0
	if(cluster_spec.slot == "chair" && !cluster_spec.required)
		state.add_warning("Optional chair-only cluster '[cluster_spec.id]' skipped to avoid loose chair placement.")
		return 0
	var/datum/world_edit_building_placement_module_catalog/catalog = get_building_placement_module_catalog()
	var/list/modules = catalog.get_for_cluster(cluster_spec)
	if(!length(modules))
		if(cluster_spec.required)
			state.validation.required_module_missing_count++
			state.add_error("Required cluster '[cluster_spec.id]' has no placement module mapping.")
		else
			state.validation.optional_module_missing_count++
			state.add_warning("Optional cluster '[cluster_spec.id]' has no placement module mapping and was skipped.")
		return 0
	var/target_count = get_scaled_cluster_target_count(state, cluster_spec)
	var/effective_minimum = get_effective_cluster_min_count(state, cluster_spec)
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/already_placed = get_building_placed_requirement_count(state, requirement_id, cluster_spec.id, cluster_spec.signature_id)
	var/placed_credit = 0
	var/required_remaining = effective_minimum - already_placed
	if(required_remaining > 0 && is_building_semantic_furniture_slot(cluster_spec.slot, cluster_spec.category))
		placed_credit += place_building_reserved_slot_module(state, cluster_spec, modules, major, required_remaining)
	var/attempts = 0
	while(already_placed + placed_credit < max(target_count, effective_minimum) && attempts < WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS && state.fixtures.fixture_count < WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS)
		attempts++
		var/list/best_candidate = find_best_building_module_candidate(state, cluster_spec, modules)
		if(!islist(best_candidate))
			break
		var/placed_now = commit_building_module_candidate(state, cluster_spec, best_candidate, major && placed_credit <= 0)
		if(placed_now <= 0)
			break
		placed_credit += placed_now
	if(cluster_spec.required && effective_minimum > 0 && already_placed + placed_credit < effective_minimum)
		state.validation.required_module_not_placeable_count++
		state.add_warning("Required cluster '[cluster_spec.id]' module placement produced [already_placed + placed_credit], needs [effective_minimum].")
	return placed_credit

/datum/world_edit_generator/building_layout/proc/place_building_reserved_slot_module(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/modules, major, needed_count)
	if(!istype(state) || !istype(cluster_spec) || !islist(modules) || needed_count <= 0)
		return 0
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/reserved_turfs = state.fixtures.semantic_slot_reserved_turfs["[requirement_id]"]
	if(!islist(reserved_turfs) || length(reserved_turfs) < needed_count)
		return 0
	var/datum/world_edit_building_cluster_spec/compact_spec = get_building_compact_substitute_spec(state, cluster_spec)
	var/list/compact_turfs = istype(compact_spec) ? state.fixtures.semantic_slot_turf_sets[compact_spec.id] : null
	var/prefer_compact_module = islist(compact_turfs) && length(compact_turfs)
	var/datum/world_edit_building_placement_module/selected_module = null
	var/datum/world_edit_building_room/selected_room = null
	var/list/member_plans = list()
	for(var/turf/reserved_turf as anything in reserved_turfs)
		if(length(member_plans) >= needed_count)
			break
		if(!istype(reserved_turf))
			continue
		var/datum/world_edit_building_room/room = state.get_room_for_turf(reserved_turf)
		if(!istype(room))
			continue
		var/datum/world_edit_building_cluster_spec/placement_spec = (istype(compact_spec) && islist(compact_turfs) && (reserved_turf in compact_turfs)) ? compact_spec : cluster_spec
		if(!istype(selected_module))
			for(var/datum/world_edit_building_placement_module/module as anything in modules)
				if(!istype(module) || !(placement_spec.slot in module.required_provider_slots) || !building_module_allowed_in_room(state, module, room))
					continue
				if(prefer_compact_module && istype(compact_spec) && !(compact_spec.id in module.source_cluster_ids))
					continue
				if(module.max_per_building > 0 && state.get_building_module_count(module.id) >= module.max_per_building)
					continue
				selected_module = module
				selected_room = room
				break
			if(!istype(selected_module) && prefer_compact_module)
				for(var/datum/world_edit_building_placement_module/module as anything in modules)
					if(!istype(module) || !(placement_spec.slot in module.required_provider_slots) || !building_module_allowed_in_room(state, module, room))
						continue
					if(module.max_per_building > 0 && state.get_building_module_count(module.id) >= module.max_per_building)
						continue
					selected_module = module
					selected_room = room
					break
		if(!istype(selected_module))
			return 0
		if(!building_module_allowed_in_room(state, selected_module, room))
			continue
		var/semantic_owner = state.get_semantic_slot_owner(reserved_turf)
		if(length(semantic_owner) && semantic_owner != requirement_id)
			continue
		if(!state.can_place_fixture(reserved_turf, TRUE))
			continue
		if(!building_fixture_matches_semantic_zone_contract(state, reserved_turf, placement_spec.slot, placement_spec.category, placement_spec))
			continue
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(placement_spec.slot, placement_spec.category)
		var/needs_wall = selected_module.wall_required || get_cluster_effective_needs_wall(state, placement_spec, place_rule)
		var/fallback_dir = get_cardinal_dir_toward(reserved_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, state.placement_dir || SOUTH)
		var/list/place_context = selected_module.wall_required || selected_module.pattern == "wall_object" ? build_building_module_front_clear_place_context(state, reserved_turf, place_rule, fallback_dir, needs_wall, placement_spec, placement_spec.anchors, null) : build_building_fixture_place_context(state, reserved_turf, place_rule, fallback_dir, needs_wall, placement_spec, placement_spec.anchors)
		if(!islist(place_context))
			continue
		member_plans += list(list(
			"slot" = placement_spec.slot,
			"category" = placement_spec.category,
			"turf" = reserved_turf,
			"room_id" = room.id,
			"cluster_spec" = placement_spec,
			"place_rule" = place_rule,
			"dir" = place_context["dir"] || fallback_dir,
			"wall_dir" = place_context["wall_dir"],
			"wall_mounted" = place_context["wall_mounted"],
			"dir_source" = place_context["dir_source"],
			"allow_reserved" = TRUE,
			"major" = length(member_plans) ? FALSE : TRUE,
		))
	if(!istype(selected_module) || length(member_plans) < needed_count)
		return 0
	var/list/candidate = list("module" = selected_module, "room" = selected_room, "members" = member_plans)
	return commit_building_module_candidate(state, cluster_spec, candidate, major)

/datum/world_edit_generator/building_layout/proc/find_best_building_module_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/modules)
	var/list/best_candidates = list()
	var/best_score = -999999999
	for(var/datum/world_edit_building_placement_module/module as anything in modules)
		if(!istype(module))
			continue
		if(module.max_per_building > 0 && state.get_building_module_count(module.id) >= module.max_per_building)
			continue
		for(var/datum/world_edit_building_room/room as anything in state.geometry.solved_rooms)
			if(!building_module_allowed_in_room(state, module, room))
				continue
			if(module.max_per_room > 0 && state.get_room_module_count(room.id, module.id) >= module.max_per_room)
				continue
			if(length(module.repeat_group) && module.max_repeat_group_per_room > 0 && state.get_room_repeat_group_count(room.id, module.repeat_group) >= module.max_repeat_group_per_room)
				continue
			for(var/turf/origin as anything in room.turfs)
				for(var/dir_to_use as anything in GLOB.cardinals)
					var/list/candidate = build_building_module_candidate(state, cluster_spec, module, room, origin, dir_to_use)
					if(!islist(candidate))
						continue
					var/score = round(text2num("[candidate["score"]]") || 0)
					if(score > best_score)
						best_score = score
						best_candidates.Cut()
						best_candidates += list(candidate)
					else if(score == best_score)
						best_candidates += list(candidate)
	if(!length(best_candidates))
		return null
	return state.request.fixture_rng.pick_from(best_candidates)

/datum/world_edit_generator/building_layout/proc/building_module_allowed_in_room(datum/world_edit_building_layout_state/state, datum/world_edit_building_placement_module/module, datum/world_edit_building_room/room)
	if(!istype(state) || !istype(module) || !istype(room))
		return FALSE
	if(length(module.allowed_programs) && !(state.archetype?.id in module.allowed_programs))
		return FALSE
	var/zone_id = "[room.zone_id]"
	var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan?.get_zone_spec(zone_id)
	var/role = "[zone_spec?.role || ""]"
	if(length(module.allowed_zone_ids) && !(zone_id in module.allowed_zone_ids))
		return FALSE
	if(length(module.allowed_room_roles) && length(role) && !(role in module.allowed_room_roles))
		return FALSE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_building_module_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_placement_module/module, datum/world_edit_building_room/room, turf/origin, dir_to_use)
	if(!istype(state) || !istype(module) || !istype(room) || !istype(origin))
		return null
	if(module.max_per_building > 0 && state.get_building_module_count(module.id) >= module.max_per_building)
		return null
	if(module.max_per_room > 0 && state.get_room_module_count(room.id, module.id) >= module.max_per_room)
		return null
	if(length(module.repeat_group) && module.max_repeat_group_per_room > 0 && state.get_room_repeat_group_count(room.id, module.repeat_group) >= module.max_repeat_group_per_room)
		return null
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/member_plans = list()
	var/list/occupied_lookup = list()
	var/list/occupied_turfs = list()
	for(var/list/member as anything in module.member_specs)
		var/turf/member_turf = get_template_offset_turf(origin, dir_to_use, member["dx"], member["dy"])
		if(!istype(member_turf) || occupied_lookup[member_turf])
			return null
		if(!(member_turf in room.turfs))
			return null
		var/semantic_owner = state.get_semantic_slot_owner(member_turf)
		if(length(semantic_owner) && semantic_owner != requirement_id)
			return null
		var/allow_owned_reserved = length(semantic_owner) && semantic_owner == requirement_id
		if(!state.can_place_fixture(member_turf, allow_owned_reserved))
			return null
		var/slot = "[member["slot"]]"
		var/category = "[member["category"]]"
		if(!building_fixture_matches_semantic_zone_contract(state, member_turf, slot, category, cluster_spec))
			return null
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(slot, category)
		var/needs_wall = member["wall_required"] || module.wall_required || get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
		var/fallback_dir = get_cardinal_dir_toward(member_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, dir_to_use)
		var/list/place_context = module.wall_required || module.pattern == "wall_object" ? build_building_module_front_clear_place_context(state, member_turf, place_rule, fallback_dir, needs_wall, cluster_spec, cluster_spec.anchors, occupied_lookup) : build_building_fixture_place_context(state, member_turf, place_rule, fallback_dir, needs_wall, cluster_spec, cluster_spec.anchors)
		if(!islist(place_context))
			return null
		occupied_lookup[member_turf] = TRUE
		occupied_turfs += member_turf
		member_plans += list(list(
			"slot" = slot,
			"category" = category,
			"turf" = member_turf,
			"room_id" = room.id,
			"place_rule" = place_rule,
			"dir" = place_context["dir"] || fallback_dir,
			"wall_dir" = place_context["wall_dir"],
			"wall_mounted" = place_context["wall_mounted"],
			"dir_source" = place_context["dir_source"],
			"allow_reserved" = allow_owned_reserved ? TRUE : FALSE,
			"major" = member["major"] ? TRUE : FALSE,
		))
	if(module.wall_required || module.pattern == "wall_object")
		for(var/list/member_plan as anything in member_plans)
			var/turf/member_turf = member_plan["turf"]
			var/front_dir = get_building_place_rule_front_dir(member_plan["dir"], member_plan["wall_dir"], member_plan["place_rule"])
			var/turf/clearance_turf = front_dir ? get_step(member_turf, front_dir) : null
			if(!istype(clearance_turf) || occupied_lookup[clearance_turf])
				continue
			if(building_module_front_clearance_cell_blocked(state, clearance_turf, occupied_lookup, requirement_id))
				return null
	for(var/offset_key as anything in get_building_module_clearance_offsets(module))
		var/list/parts = splittext("[offset_key]", ",")
		if(length(parts) < 2)
			continue
		var/turf/clearance_turf = get_template_offset_turf(origin, dir_to_use, text2num(parts[1]), text2num(parts[2]))
		if(!istype(clearance_turf) || occupied_lookup[clearance_turf])
			continue
		if(state.geometry.wall_lookup[clearance_turf] || state.geometry.door_dirs[clearance_turf] || state.fixtures.fixture_lookup[clearance_turf] || state.geometry.reserved_lookup[clearance_turf] || state.has_anchor("door_cone", clearance_turf))
			return null
	var/score = module.priority + (length(module.member_specs) * 20) + score_fixture_turf(state, origin, cluster_spec.anchors, module.wall_required, cluster_spec)
	if(state.has_anchor("focus_center", origin))
		score += 100
	return list("module" = module, "room" = room, "origin" = origin, "dir" = dir_to_use, "members" = member_plans, "occupied_turfs" = occupied_turfs, "score" = score)

/datum/world_edit_generator/building_layout/proc/building_module_front_clearance_cell_blocked(datum/world_edit_building_layout_state/state, turf/clearance_turf, list/occupied_lookup = null, allowed_clearance_owner = null)
	if(!istype(state) || !istype(clearance_turf))
		return FALSE
	if(islist(occupied_lookup) && occupied_lookup[clearance_turf])
		return FALSE
	var/clearance_owner = state.get_semantic_slot_clearance_owner(clearance_turf)
	if(length(clearance_owner) && clearance_owner != "[allowed_clearance_owner || ""]")
		return TRUE
	return state.geometry.wall_lookup[clearance_turf] || state.geometry.door_dirs[clearance_turf] || state.fixtures.fixture_lookup[clearance_turf] || state.geometry.reserved_lookup[clearance_turf] || state.has_anchor("door_cone", clearance_turf)

/datum/world_edit_generator/building_layout/proc/build_building_module_front_clear_place_context(datum/world_edit_building_layout_state/state, turf/target_turf, datum/world_edit_building_place_rule/place_rule, fallback_dir = null, force_wall = FALSE, datum/world_edit_building_cluster_spec/cluster_spec = null, list/anchor_ids = null, list/occupied_lookup = null)
	if(!istype(state) || !istype(target_turf))
		return null
	if(!istype(place_rule))
		place_rule = resolve_building_place_rule(null, null)
	var/list/best_context = null
	var/best_score = -999999999
	var/requirement_id = istype(cluster_spec) ? get_building_cluster_requirement_id(cluster_spec) : ""
	for(var/wall_dir as anything in get_adjacent_wall_dirs_for_state(state, target_turf))
		var/list/context = score_building_fixture_wall_context(state, target_turf, place_rule, wall_dir, cluster_spec, anchor_ids)
		if(!islist(context))
			continue
		var/front_dir = get_building_place_rule_front_dir(context["dir"], context["wall_dir"], place_rule)
		var/turf/clearance_turf = front_dir ? get_step(target_turf, front_dir) : null
		if(building_module_front_clearance_cell_blocked(state, clearance_turf, occupied_lookup, requirement_id))
			continue
		var/context_score = round(text2num("[context["score"]]") || 0)
		if(!islist(best_context) || context_score > best_score)
			best_context = context
			best_score = context_score
	if(islist(best_context))
		return best_context
	if(force_wall || place_rule.needs_wall)
		return null
	return build_building_fixture_place_context(state, target_turf, place_rule, fallback_dir, force_wall, cluster_spec, anchor_ids)

/datum/world_edit_generator/building_layout/proc/commit_building_module_candidate(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, list/candidate, major)
	var/datum/world_edit_building_placement_module/module = candidate["module"]
	var/datum/world_edit_building_room/room = candidate["room"]
	var/list/members = candidate["members"]
	if(!istype(module) || !length(members) || !istype(room))
		return 0
	var/module_instance_id = "[module.id]#[state.fixtures.module_instance_count + 1]"
	var/placed_credit = 0
	var/placed_members = 0
	for(var/list/member as anything in members)
		var/turf/member_turf = member["turf"]
		var/member_room_id = "[member["room_id"] || room.id]"
		var/datum/world_edit_building_cluster_spec/member_cluster_spec = member["cluster_spec"]
		if(!istype(member_cluster_spec))
			member_cluster_spec = cluster_spec
		if(!place_fixture_at(state, member_turf, member["slot"], member["dir"], member["category"], major && member["major"] && placed_members <= 0, member["wall_mounted"], member["place_rule"], member["wall_dir"], member_cluster_spec, null, null, member["dir_source"], member["allow_reserved"], module.id, module_instance_id, length(members), module.repeat_group, member_room_id, module.requires_table_pairing, module.seating_group_ok))
			state.remove_module_instance(module_instance_id)
			return 0
		placed_members++
		placed_credit += get_building_fixture_count_credit(member_cluster_spec, member["slot"], member["category"])
	if(placed_members != length(members))
		state.remove_module_instance(module_instance_id)
		return 0
	state.register_module_instance(module.id, module_instance_id, length(members), room.id, module.repeat_group)
	return placed_credit
