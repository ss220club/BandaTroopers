/datum/world_edit_generator/building_layout
	requires_preview_before_apply = TRUE
	var/current_plan_request_key = null
	var/feasibility_cached_request_key = null
	var/datum/world_edit_building_layout_state/feasibility_cached_state = null
	var/list/feasibility_cached_support_report = null

/datum/world_edit_generator/building_layout/get_supported_placement_modes()
	return list("single", "repeat")

/datum/world_edit_generator/building_layout/get_supported_placement_shapes()
	return list(
		WORLD_EDIT_SHAPE_POINT,
		WORLD_EDIT_SHAPE_RECTANGLE,
		WORLD_EDIT_SHAPE_FILLED_RECTANGLE,
	)

/datum/world_edit_generator/building_layout/supports_placement_direction()
	return TRUE

/datum/world_edit_generator/building_layout/get_default_placement_direction()
	return NORTH

/datum/world_edit_generator/building_layout/proc/get_building_faction_options()
	return list("colony", "uscm", "unsc", "neutral", "covenant")

/datum/world_edit_generator/building_layout/proc/get_building_archetype_ids()
	var/list/result = list()
	var/list/catalog = get_building_archetype_catalog()
	for(var/archetype_id in catalog)
		result += "[archetype_id]"
	return result

/datum/world_edit_generator/building_layout/proc/get_building_size_profile_options()
	return list(
		list("label" = "Compact", "value" = WORLD_EDIT_BUILDING_SIZE_PROFILE_COMPACT),
		list("label" = "Standard", "value" = WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD),
		list("label" = "Spacious", "value" = WORLD_EDIT_BUILDING_SIZE_PROFILE_SPACIOUS),
	)

/datum/world_edit_generator/building_layout/proc/resolve_building_size_profile(value)
	var/profile_id = lowertext("[value || WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD]")
	switch(profile_id)
		if("compact", "small")
			return WORLD_EDIT_BUILDING_SIZE_PROFILE_COMPACT
		if("standard", "")
			return WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD
		if("spacious", "large")
			return WORLD_EDIT_BUILDING_SIZE_PROFILE_SPACIOUS
	return WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD

/datum/world_edit_generator/building_layout/proc/apply_building_size_profile(list/config, profile_id)
	if(!islist(config))
		return
	config["size_profile"] = resolve_building_size_profile(profile_id)
	switch(config["size_profile"])
		if(WORLD_EDIT_BUILDING_SIZE_PROFILE_COMPACT)
			config["half_width"] = 6
			config["half_depth"] = 6
		if(WORLD_EDIT_BUILDING_SIZE_PROFILE_SPACIOUS)
			config["half_width"] = 8
			config["half_depth"] = 8
		else
			config["half_width"] = 7
			config["half_depth"] = 7
	config["requested_half_width"] = config["half_width"]
	config["requested_half_depth"] = config["half_depth"]
	config["auto_size"] = FALSE
	config["size_policy"] = WORLD_EDIT_BUILDING_SIZE_POLICY_EXPLICIT

/datum/world_edit_generator/building_layout/proc/get_building_faction_catalog()
	if(length(GLOB.world_edit_building_faction_catalog))
		return GLOB.world_edit_building_faction_catalog

	GLOB.world_edit_building_faction_catalog = list(
		"colony" = list(
			"label" = "Colony",
			"wall_path" = "/turf/closed/wall/kutjevo/colony",
			"floor_path" = "/turf/open/floor/interior/wood",
			"door_path" = "/obj/structure/machinery/door/airlock/almayer/generic",
			"window_path" = "/obj/structure/window/framed/colony/reinforced",
			"interior_paths" = list(
				"table" = "/obj/structure/surface/table/woodentable",
				"chair" = "/obj/structure/bed/chair/wood/normal",
				"cabinet" = "/obj/structure/closet/cabinet",
				"bed" = "/obj/structure/bed",
				"rack" = "/obj/structure/surface/rack",
				"crate" = "/obj/structure/closet/crate/supply",
				"console" = "/obj/structure/prop/server_equipment/laptop/on",
				"barrier" = "/obj/structure/barricade/metal",
				"medical_bed" = "/obj/structure/bed/roller/hospital_empty",
				"medical_storage" = "/obj/structure/closet/crate/medical",
				"sleeper" = "/obj/structure/machinery/medical_pod/sleeper",
				"medical_scanner" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"wall_monitor" = "/obj/structure/machinery/body_scanconsole",
				"hydro_tray" = "/obj/structure/machinery/portable_atmospherics/hydroponics",
				"seed_storage" = "/obj/structure/filingcabinet/seeds",
				"water_tank" = "/obj/structure/reagent_dispensers/watertank",
				"fridge" = "/obj/structure/machinery/smartfridge",
				"microwave" = "/obj/structure/machinery/microwave",
				"processor" = "/obj/structure/machinery/processor",
				"sink" = "/obj/structure/sink/kitchen",
				"toilet" = "/obj/structure/toilet",
				"filing" = "/obj/structure/filingcabinet",
				"security_console" = "/obj/structure/machinery/computer/cameras",
				"security_camera" = "/obj/structure/machinery/camera",
				"brig_cell" = "/obj/structure/machinery/brig_cell",
				"weapon_rack" = "/obj/structure/gun_rack/m41/empty",
				"engineering_machine" = "/obj/structure/machinery/processor",
				"power_console" = "/obj/structure/prop/server_equipment/laptop/on",
				"lab_machine" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"sample_storage" = "/obj/structure/closet/crate/medical",
				"light" = "/obj/structure/machinery/light/small",
				"apc" = "/obj/structure/machinery/power/apc",
				"air_alarm" = "/obj/structure/machinery/alarm",
				"fire_alarm" = "/obj/structure/machinery/firealarm",
				"light_switch" = "/obj/structure/machinery/light_switch",
			),
		),
		"uscm" = list(
			"label" = "USCM",
			"wall_path" = "/turf/closed/wall/almayer",
			"floor_path" = "/turf/open/floor/plating",
			"door_path" = "/obj/structure/machinery/door/airlock/almayer/marine",
			"window_path" = "/obj/structure/window/framed/almayer",
			"interior_paths" = list(
				"table" = "/obj/structure/surface/table/reinforced",
				"chair" = "/obj/structure/bed/chair/office/dark",
				"cabinet" = "/obj/structure/closet/secure_closet/security_empty",
				"bed" = "/obj/structure/bed",
				"rack" = "/obj/structure/surface/rack",
				"crate" = "/obj/structure/closet/crate/supply",
				"console" = "/obj/structure/prop/server_equipment/laptop/on",
				"barrier" = "/obj/structure/barricade/metal",
				"medical_bed" = "/obj/structure/bed/roller/hospital_empty",
				"medical_storage" = "/obj/structure/closet/medical_wall",
				"sleeper" = "/obj/structure/machinery/medical_pod/sleeper",
				"medical_scanner" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"wall_monitor" = "/obj/structure/machinery/body_scanconsole",
				"hydro_tray" = "/obj/structure/machinery/portable_atmospherics/hydroponics",
				"seed_storage" = "/obj/structure/filingcabinet/seeds",
				"water_tank" = "/obj/structure/reagent_dispensers/watertank",
				"fridge" = "/obj/structure/machinery/smartfridge",
				"microwave" = "/obj/structure/machinery/microwave",
				"processor" = "/obj/structure/machinery/processor",
				"sink" = "/obj/structure/sink/kitchen",
				"toilet" = "/obj/structure/toilet",
				"filing" = "/obj/structure/filingcabinet",
				"security_console" = "/obj/structure/machinery/computer/cameras/almayer_brig",
				"security_camera" = "/obj/structure/machinery/camera/autoname/almayer/brig",
				"brig_cell" = "/obj/structure/machinery/brig_cell",
				"weapon_rack" = "/obj/structure/gun_rack/m41/empty",
				"engineering_machine" = "/obj/structure/machinery/processor",
				"power_console" = "/obj/structure/prop/server_equipment/laptop/on",
				"lab_machine" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"sample_storage" = "/obj/structure/closet/medical_wall",
				"light" = "/obj/structure/machinery/light/small/blue",
				"apc" = "/obj/structure/machinery/power/apc/almayer",
				"air_alarm" = "/obj/structure/machinery/alarm/almayer",
				"fire_alarm" = "/obj/structure/machinery/firealarm",
				"light_switch" = "/obj/structure/machinery/light_switch",
			),
		),
		"unsc" = list(
			"label" = "UNSC",
			"wall_path" = "/turf/closed/wall/unsc",
			"floor_path" = "/turf/open/floor/plating",
			"door_path" = "/obj/structure/machinery/door/airlock/unsc",
			"window_path" = "/obj/structure/window/framed/unsc",
			"interior_paths" = list(
				"table" = "/obj/structure/surface/table/reinforced",
				"chair" = "/obj/structure/bed/chair/vehicle",
				"cabinet" = "/obj/structure/closet/secure_closet/security_empty",
				"bed" = "/obj/structure/bed",
				"rack" = "/obj/structure/gun_rack/m41/empty",
				"crate" = "/obj/structure/closet/crate/supply",
				"console" = "/obj/structure/prop/server_equipment/laptop/on",
				"barrier" = "/obj/structure/barricade/metal",
				"medical_bed" = "/obj/structure/bed/roller/hospital_empty",
				"medical_storage" = "/obj/structure/closet/crate/medical",
				"sleeper" = "/obj/structure/machinery/medical_pod/sleeper",
				"medical_scanner" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"wall_monitor" = "/obj/structure/machinery/body_scanconsole",
				"hydro_tray" = "/obj/structure/machinery/portable_atmospherics/hydroponics",
				"seed_storage" = "/obj/structure/filingcabinet/seeds",
				"water_tank" = "/obj/structure/reagent_dispensers/watertank",
				"fridge" = "/obj/structure/machinery/smartfridge",
				"microwave" = "/obj/structure/machinery/microwave",
				"processor" = "/obj/structure/machinery/processor",
				"sink" = "/obj/structure/sink/kitchen",
				"toilet" = "/obj/structure/toilet",
				"filing" = "/obj/structure/filingcabinet",
				"security_console" = "/obj/structure/machinery/computer/cameras",
				"security_camera" = "/obj/structure/machinery/camera",
				"brig_cell" = "/obj/structure/machinery/brig_cell",
				"weapon_rack" = "/obj/structure/gun_rack/halo/armory/ma5c/empty",
				"engineering_machine" = "/obj/structure/machinery/processor",
				"power_console" = "/obj/structure/prop/server_equipment/laptop/on",
				"lab_machine" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"sample_storage" = "/obj/structure/closet/crate/medical",
				"light" = "/obj/structure/machinery/light/small/blue",
				"apc" = "/obj/structure/machinery/power/apc",
				"air_alarm" = "/obj/structure/machinery/alarm",
				"fire_alarm" = "/obj/structure/machinery/firealarm",
				"light_switch" = "/obj/structure/machinery/light_switch",
			),
		),
		"neutral" = list(
			"label" = "Neutral",
			"wall_path" = "/turf/closed/wall/wood",
			"floor_path" = "/turf/open/floor/wood",
			"door_path" = "/obj/structure/machinery/door/airlock/hybrisa/generic",
			"window_path" = "/obj/structure/window/framed/hybrisa/colony",
			"interior_paths" = list(
				"table" = "/obj/structure/surface/table/woodentable",
				"chair" = "/obj/structure/bed/chair/wood/normal",
				"cabinet" = "/obj/structure/closet/cabinet/hybrisa/metal",
				"bed" = "/obj/structure/bed",
				"rack" = "/obj/structure/surface/rack",
				"crate" = "/obj/structure/closet/crate/supply",
				"console" = "/obj/structure/prop/server_equipment/laptop/on",
				"barrier" = "/obj/structure/barricade/metal",
				"medical_bed" = "/obj/structure/bed/roller/hospital_empty",
				"medical_storage" = "/obj/structure/closet/crate/medical",
				"sleeper" = "/obj/structure/machinery/medical_pod/sleeper",
				"medical_scanner" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"wall_monitor" = "/obj/structure/machinery/body_scanconsole",
				"hydro_tray" = "/obj/structure/machinery/portable_atmospherics/hydroponics",
				"seed_storage" = "/obj/structure/filingcabinet/seeds",
				"water_tank" = "/obj/structure/reagent_dispensers/watertank",
				"fridge" = "/obj/structure/machinery/smartfridge",
				"microwave" = "/obj/structure/machinery/microwave",
				"processor" = "/obj/structure/machinery/processor",
				"sink" = "/obj/structure/sink/kitchen",
				"toilet" = "/obj/structure/toilet",
				"filing" = "/obj/structure/filingcabinet",
				"security_console" = "/obj/structure/machinery/computer/cameras",
				"security_camera" = "/obj/structure/machinery/camera",
				"brig_cell" = "/obj/structure/machinery/brig_cell",
				"weapon_rack" = "/obj/structure/gun_rack/m41/empty",
				"engineering_machine" = "/obj/structure/machinery/processor",
				"power_console" = "/obj/structure/prop/server_equipment/laptop/on",
				"lab_machine" = "/obj/structure/machinery/medical_pod/bodyscanner",
				"sample_storage" = "/obj/structure/closet/crate/medical",
				"light" = "/obj/structure/machinery/light/small",
				"apc" = "/obj/structure/machinery/power/apc",
				"air_alarm" = "/obj/structure/machinery/alarm",
				"fire_alarm" = "/obj/structure/machinery/firealarm",
				"light_switch" = "/obj/structure/machinery/light_switch",
			),
		),
		"covenant" = list(
			"label" = "Covenant",
			"wall_path" = "/turf/closed/wall/covenant/lights/hull",
			"floor_path" = "/turf/open/floor/covenant/smooth_plating",
			"door_path" = "/obj/structure/machinery/door/airlock/voi",
			"window_path" = "/obj/structure/covenant_barricade",
			"interior_paths" = list(
				"table" = "/obj/structure/machinery/recharger/covenant",
				"chair" = "/obj/structure/covenant_barricade",
				"cabinet" = "/obj/structure/covenant_barricade",
				"bed" = "/obj/structure/covenant_barricade",
				"rack" = "/obj/structure/covenant_barricade",
				"crate" = "/obj/structure/covenant_barricade",
				"console" = "/obj/structure/machinery/recharger/covenant",
				"barrier" = "/obj/structure/covenant_barricade",
				"medical_bed" = "/obj/structure/covenant_barricade",
				"medical_storage" = "/obj/structure/covenant_barricade",
				"sleeper" = "/obj/structure/covenant_barricade",
				"medical_scanner" = "/obj/structure/covenant_barricade",
				"wall_monitor" = "/obj/structure/machinery/recharger/covenant",
				"hydro_tray" = "/obj/structure/covenant_barricade",
				"seed_storage" = "/obj/structure/covenant_barricade",
				"water_tank" = "/obj/structure/covenant_barricade",
				"fridge" = "/obj/structure/covenant_barricade",
				"microwave" = "/obj/structure/machinery/recharger/covenant",
				"processor" = "/obj/structure/machinery/recharger/covenant",
				"sink" = "/obj/structure/covenant_barricade",
				"toilet" = "/obj/structure/covenant_barricade",
				"filing" = "/obj/structure/covenant_barricade",
				"security_console" = "/obj/structure/machinery/recharger/covenant",
				"security_camera" = "/obj/structure/machinery/recharger/covenant",
				"brig_cell" = "/obj/structure/covenant_barricade",
				"weapon_rack" = "/obj/structure/covenant_barricade",
				"engineering_machine" = "/obj/structure/machinery/recharger/covenant",
				"power_console" = "/obj/structure/machinery/recharger/covenant",
				"lab_machine" = "/obj/structure/machinery/recharger/covenant",
				"sample_storage" = "/obj/structure/covenant_barricade/wide",
				"light" = "/obj/structure/machinery/recharger/covenant",
				"apc" = "/obj/structure/machinery/recharger/covenant",
				"air_alarm" = "/obj/structure/machinery/recharger/covenant",
				"fire_alarm" = "/obj/structure/machinery/recharger/covenant",
				"light_switch" = "/obj/structure/machinery/recharger/covenant",
			),
		),
	)
	return GLOB.world_edit_building_faction_catalog

/datum/world_edit_generator/building_layout/proc/has_building_param(list/params, param_id)
	return islist(params) && !isnull(params["[param_id]"])

/datum/world_edit_generator/building_layout/proc/resolve_building_option(value, list/options, fallback)
	var/value_text = "[value]"
	if(value_text in options)
		return value_text
	return fallback

/datum/world_edit_generator/building_layout/proc/num_param(list/params, param_id, default_value, min_value, max_value)
	var/value = text2num("[islist(params) ? params[param_id] : null]")
	if(!isnum(value))
		value = default_value
	return clamp(round(value), min_value, max_value)

/datum/world_edit_generator/building_layout/proc/ui_num_param(value, default_value, min_value, max_value)
	var/num_value = text2num("[value]")
	if(!isnum(num_value))
		num_value = default_value
	return clamp(round(num_value), min_value, max_value)

/datum/world_edit_generator/building_layout/proc/resolve_building_type_path(path_value, expected_root)
	if(ispath(path_value, expected_root))
		return path_value
	var/resolved_path = text2path("[path_value]")
	if(!ispath(resolved_path, expected_root))
		return null
	return resolved_path

/datum/world_edit_generator/building_layout/proc/merge_building_preset_overrides(list/base_preset, datum/world_edit_building_archetype/archetype)
	var/list/preset = islist(base_preset) ? base_preset.Copy() : list()
	var/list/base_interiors = islist(base_preset?["interior_paths"]) ? base_preset["interior_paths"].Copy() : list()
	preset["interior_paths"] = base_interiors
	if(!istype(archetype) || !islist(archetype.shell_overrides))
		return preset
	for(var/key in archetype.shell_overrides)
		if("[key]" == "interior_paths")
			var/list/interior_overrides = archetype.shell_overrides[key]
			if(islist(interior_overrides))
				for(var/interior_key in interior_overrides)
					base_interiors["[interior_key]"] = interior_overrides[interior_key]
			continue
		preset[key] = archetype.shell_overrides[key]
	return preset

/datum/world_edit_generator/building_layout/proc/add_building_required_slot(list/slots, list/slot_lookup, slot)
	if(!islist(slots) || !islist(slot_lookup) || !length("[slot]"))
		return
	var/slot_key = "[slot]"
	if(slot_lookup[slot_key])
		return
	slots += slot_key
	slot_lookup[slot_key] = TRUE

/datum/world_edit_generator/building_layout/proc/collect_building_required_slots(datum/world_edit_building_archetype/archetype)
	var/list/slots = list()
	var/list/slot_lookup = list()
	if(!istype(archetype))
		return slots
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in archetype.cluster_specs)
		if(!istype(cluster_spec))
			continue
		if(!cluster_spec.required)
			continue
		add_building_required_slot(slots, slot_lookup, cluster_spec.slot)
		var/macro_id = length(cluster_spec.macro_id) ? cluster_spec.macro_id : get_building_macro_id_for_cluster(cluster_spec)
		var/resolved_macro_id = resolve_existing_building_template_chunk_id(macro_id)
		var/datum/world_edit_building_template_chunk/chunk = length(resolved_macro_id) ? get_building_template_chunk(resolved_macro_id) : null
		if(!istype(chunk))
			continue
		for(var/datum/world_edit_building_template_cell/cell as anything in chunk.cells)
			if(istype(cell))
				add_building_required_slot(slots, slot_lookup, cell.slot)
	for(var/infra_slot as anything in list("light", "apc", "air_alarm", "light_switch", "fire_alarm"))
		add_building_required_slot(slots, slot_lookup, infra_slot)
	return slots

/datum/world_edit_generator/building_layout/proc/validate_building_preset_capabilities_uncached(list/config, datum/world_edit_building_archetype/archetype)
	if(!islist(config) || !istype(archetype))
		return null
	var/list/missing_slots = list()
	for(var/slot as anything in collect_building_required_slots(archetype))
		var/datum/world_edit_building_fixture_provider/provider = resolve_fixture_provider(config, slot)
		if(!istype(provider))
			missing_slots += "[slot]: no provider"
			continue
		if(!building_fixture_provider_satisfies_slot(provider, slot))
			missing_slots += "[slot]: [provider.reason_if_not_functional || "provider is not functionally equivalent"]"
	if(length(missing_slots))
		return "Shell preset '[config["faction_preset"]]' is locked for program '[archetype.id]': missing functional providers for [english_list(missing_slots)]."
	return null

/datum/world_edit_generator/building_layout/proc/validate_building_preset_capabilities(list/config, datum/world_edit_building_archetype/archetype)
	if(!islist(config) || !istype(archetype))
		return null
	var/cache_key = "[archetype.id]|[config["faction_preset"]]"
	if(cache_key in GLOB.world_edit_building_preset_capability_cache)
		var/cached_error = GLOB.world_edit_building_preset_capability_cache[cache_key]
		return length("[cached_error]") ? "[cached_error]" : null
	var/error = validate_building_preset_capabilities_uncached(config, archetype)
	GLOB.world_edit_building_preset_capability_cache[cache_key] = error || ""
	return error

/datum/world_edit_generator/building_layout/proc/get_building_point_usable_area_for_half_size(half_width, half_depth)
	var/outer_width = max(round(text2num("[half_width]") || 0) * 2 + 1, 0)
	var/outer_height = max(round(text2num("[half_depth]") || 0) * 2 + 1, 0)
	return max(outer_width - 2, 0) * max(outer_height - 2, 0)

/datum/world_edit_generator/building_layout/proc/get_building_program_target_usable_area(datum/world_edit_building_archetype/archetype)
	var/required_compact_area = get_building_program_required_compact_area(archetype)
	if(required_compact_area <= 0)
		return 0
	return max(required_compact_area * 3, required_compact_area + 64, 121)

/datum/world_edit_generator/building_layout/proc/apply_building_minimum_point_size(list/config, datum/world_edit_building_archetype/archetype)
	if(!islist(config) || !istype(archetype))
		return
	var/required_compact_area = get_building_program_required_compact_area(archetype)
	if(required_compact_area <= 0)
		return
	var/target_usable_area = get_building_program_target_usable_area(archetype)
	var/current_half_width = round(text2num("[config["half_width"]]") || 4)
	var/current_half_depth = round(text2num("[config["half_depth"]]") || 4)
	if(get_building_point_usable_area_for_half_size(current_half_width, current_half_depth) >= target_usable_area)
		return

	var/best_half_width = current_half_width
	var/best_half_depth = current_half_depth
	var/best_score = 999999
	for(var/test_half_width in current_half_width to WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
		for(var/test_half_depth in current_half_depth to WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
			if(get_building_point_usable_area_for_half_size(test_half_width, test_half_depth) < target_usable_area)
				continue
			var/score = ((test_half_width - current_half_width) + (test_half_depth - current_half_depth)) * 100 + abs(test_half_width - test_half_depth)
			if(score >= best_score)
				continue
			best_score = score
			best_half_width = test_half_width
			best_half_depth = test_half_depth
	if(best_score >= 999999)
		return
	config["requested_half_width"] = current_half_width
	config["requested_half_depth"] = current_half_depth
	config["half_width"] = best_half_width
	config["half_depth"] = best_half_depth
	config["size_auto_adjusted"] = TRUE
	config["required_compact_area"] = required_compact_area
	config["target_usable_area"] = target_usable_area

/datum/world_edit_generator/building_layout/proc/normalize_building_params(list/params)
	var/list/config = list()
	var/default_archetype_id = resolve_layout_variant_archetype_alias(params)
	config["archetype_id"] = resolve_building_archetype_option(islist(params) ? params["archetype_id"] : null, default_archetype_id)
	var/datum/world_edit_building_archetype/archetype = get_building_archetype(config["archetype_id"])
	if(!istype(archetype))
		config["error"] = "Unable to resolve building program '[config["archetype_id"]]'."
		return config
	var/auto_size = isnull(islist(params) ? params["auto_size"] : null) ? TRUE : GLOB.world_edit_helpers.parse_bool(params["auto_size"])
	config["half_width"] = num_param(params, "half_width", 4, 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	config["half_depth"] = num_param(params, "half_depth", 4, 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	config["requested_half_width"] = config["half_width"]
	config["requested_half_depth"] = config["half_depth"]
	config["auto_size"] = auto_size ? TRUE : FALSE
	config["size_policy"] = config["auto_size"] ? WORLD_EDIT_BUILDING_SIZE_POLICY_AUTO : WORLD_EDIT_BUILDING_SIZE_POLICY_EXPLICIT
	config["size_profile"] = resolve_building_size_profile(islist(params) ? params["size_profile"] : null)
	if(has_building_param(params, "size_profile") && !has_building_param(params, "half_width") && !has_building_param(params, "half_depth") && isnull(islist(params) ? params["auto_size"] : null))
		apply_building_size_profile(config, config["size_profile"])
	if(config["auto_size"])
		apply_building_minimum_point_size(config, archetype)
	config["final_half_width"] = config["half_width"]
	config["final_half_depth"] = config["half_depth"]
	config["target_room_count"] = num_param(params, "target_room_count", 0, 0, 24)
	config["window_density"] = num_param(params, "window_density", archetype.window_bias, 0, 100)
	config["detail_budget"] = num_param(params, "detail_budget", has_building_param(params, "interior_density") ? num_param(params, "interior_density", archetype.detail_bias, 0, 100) : archetype.detail_bias, 0, 100)
	config["building_seed"] = num_param(params, "building_seed", WORLD_EDIT_BUILDING_AUTO_SEED, 0, 999999999)
	config["back_exit"] = GLOB.world_edit_helpers.parse_bool(islist(params) ? params["back_exit"] : null) ? TRUE : FALSE
	config["respect_blockers"] = isnull(islist(params) ? params["respect_blockers"] : null) ? TRUE : GLOB.world_edit_helpers.parse_bool(params["respect_blockers"])
	config["replace_blocked_turfs"] = isnull(islist(params) ? params["replace_blocked_turfs"] : null) ? FALSE : GLOB.world_edit_helpers.parse_bool(params["replace_blocked_turfs"])
	config["confirm_large_replacement"] = GLOB.world_edit_helpers.parse_bool(islist(params) ? params["confirm_large_replacement"] : null) ? TRUE : FALSE
	config["debug_reports"] = GLOB.world_edit_helpers.parse_bool(islist(params) ? params["debug_reports"] : null) ? TRUE : FALSE
	config["skip_feasibility_dry_solve"] = GLOB.world_edit_helpers.parse_bool(islist(params) ? params["skip_feasibility_dry_solve"] : null) ? TRUE : FALSE
	var/default_shell_preset = length("[archetype.suggested_shell_preset]") ? archetype.suggested_shell_preset : "colony"
	config["faction_preset"] = resolve_building_option(islist(params) ? params["faction_preset"] : null, get_building_faction_options(), default_shell_preset)
	var/list/catalog = get_building_faction_catalog()
	var/list/base_preset = catalog[config["faction_preset"]] || catalog[default_shell_preset] || catalog["colony"]
	var/list/preset = merge_building_preset_overrides(base_preset, archetype)
	config["preset"] = preset
	config["wall_type"] = resolve_building_type_path(preset["wall_path"], /turf)
	config["floor_type"] = resolve_building_type_path(preset["floor_path"], /turf)
	config["door_type"] = resolve_building_type_path(preset["door_path"], /obj)
	config["window_type"] = resolve_building_type_path(preset["window_path"], /obj)
	config["interior_paths"] = islist(preset["interior_paths"]) ? preset["interior_paths"].Copy() : list()
	config["fixture_providers_by_slot"] = build_fixture_provider_registry(config)
	if(!config["wall_type"] || !config["floor_type"] || !config["door_type"] || !config["window_type"])
		config["error"] = "Unable to resolve one or more shell type paths for preset '[config["faction_preset"]]' and building program '[config["archetype_id"]]'."
	if(!config["error"])
		config["error"] = validate_building_preset_capabilities(config, archetype)
		if(config["error"])
			config["error_code"] = WORLD_EDIT_BUILDING_ERROR_STYLE_MISSING_CAPABILITY
	return config

/datum/world_edit_generator/building_layout/get_ui_fields(list/current_params)
	var/list/config = normalize_building_params(current_params)
	return list(
		list(
			"id" = "archetype_id",
			"label" = "Building program",
			"kind" = "select",
			"group" = "Program",
			"value" = config["archetype_id"],
			"options" = get_building_archetype_options(),
		),
		list(
			"id" = "faction_preset",
			"label" = "Shell preset",
			"kind" = "select",
			"group" = "Shell",
			"value" = config["faction_preset"],
			"options" = list(
				list("label" = "Colony", "value" = "colony"),
				list("label" = "USCM", "value" = "uscm"),
				list("label" = "UNSC", "value" = "unsc"),
				list("label" = "Neutral", "value" = "neutral"),
				list("label" = "Covenant", "value" = "covenant"),
			),
		),
		list(
			"id" = "building_seed",
			"label" = "Seed",
			"kind" = "number",
			"group" = "Program",
			"value" = config["building_seed"],
			"min" = 0,
			"max" = 999999999,
			"step" = 1,
		),
		list(
			"id" = "size_profile",
			"label" = "Size profile",
			"kind" = "select",
			"group" = "Size",
			"value" = config["size_profile"],
			"options" = get_building_size_profile_options(),
		),
	)

/datum/world_edit_generator/building_layout/get_ui_payload(list/current_params)
	var/list/config = normalize_building_params(current_params)
	return list(
		"building_layout" = list(
			"schema_version" = 1,
			"current_program_id" = "[config["archetype_id"] || ""]",
			"current_style_id" = "[config["faction_preset"] || ""]",
			"current_error" = "[config["error"] || ""]",
			"current_error_code" = "[config["error_code"] || ""]",
			"capability_matrix" = build_building_capability_matrix_payload(),
		),
	)

/datum/world_edit_generator/building_layout/set_ui_param(mob/user, list/current_params, param_id, value)
	if(!islist(current_params))
		current_params = list()
	var/list/new_params = current_params.Copy()
	switch("[param_id]")
		if("archetype_id")
			new_params[param_id] = resolve_building_archetype_option(value, "living")
		if("faction_preset")
			new_params[param_id] = resolve_building_option(value, get_building_faction_options(), "colony")
		if("size_profile")
			new_params[param_id] = resolve_building_size_profile(value)
			new_params -= "auto_size"
			new_params -= "half_width"
			new_params -= "half_depth"
		if("auto_size")
			new_params[param_id] = GLOB.world_edit_helpers.parse_bool(value) ? TRUE : FALSE
		if("half_width")
			new_params[param_id] = ui_num_param(value, 4, 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
			new_params["auto_size"] = FALSE
		if("half_depth")
			new_params[param_id] = ui_num_param(value, 4, 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
			new_params["auto_size"] = FALSE
		if("target_room_count")
			new_params[param_id] = ui_num_param(value, 0, 0, 24)
		if("window_density")
			new_params[param_id] = ui_num_param(value, 40, 0, 100)
		if("detail_budget")
			new_params[param_id] = ui_num_param(value, 60, 0, 100)
		if("building_seed")
			new_params[param_id] = ui_num_param(value, WORLD_EDIT_BUILDING_AUTO_SEED, 0, 999999999)
		if("back_exit", "respect_blockers", "replace_blocked_turfs", "confirm_large_replacement")
			new_params[param_id] = GLOB.world_edit_helpers.parse_bool(value) ? TRUE : FALSE
		else
			new_params[param_id] = value
	return new_params

/datum/world_edit_generator/building_layout/get_params_short(list/params)
	var/list/config = normalize_building_params(params)
	return "program=[config["archetype_id"]] shell=[config["faction_preset"]] seed=[config["building_seed"]] effective_seed=[config["effective_seed"]] size=[config["half_width"]]x[config["half_depth"]] auto_size=[config["auto_size"]] target_rooms=[config["target_room_count"]] windows=[config["window_density"]] details=[config["detail_budget"]] back=[config["back_exit"]] strict_blockers=[config["respect_blockers"]] replace_blocked=[config["replace_blocked_turfs"]] large_replace=[config["confirm_large_replacement"]] shape=[manager?.get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT] dir=[GLOB.world_edit_helpers.dir_to_label(manager?.get_effective_placement_dir() || NORTH)]"

/datum/world_edit_generator/building_layout/proc/build_building_support_validation_verdict(list/support_result)
	var/support_status = "[support_result?["status"] || WORLD_EDIT_BUILDING_SUPPORT_FAILED]"
	var/verdict_status = WORLD_EDIT_BUILDING_PREFLIGHT_SUPPORTED
	if(support_status != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		verdict_status = support_status == WORLD_EDIT_BUILDING_SUPPORT_FAILED ? WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST : WORLD_EDIT_BUILDING_PREFLIGHT_UNSUPPORTED
	var/datum/world_edit_validation_verdict/verdict = new(verdict_status, WORLD_EDIT_BUILDING_STAGE_FEASIBILITY)
	if(islist(support_result))
		for(var/metric_id as anything in list(
			"estimated_usable_area",
			"required_usable_area",
			"required_compact_area",
			"blocked_turf_conflict_count",
			"replace_blocked_turf_count",
			"default_max_replaced_blockers",
			"hard_max_replaced_blockers",
			"feasibility_dry_solve_attempt_count",
			"feasibility_dry_solve_valid_candidate_count",
			"feasibility_dry_solve_error_count",
		))
			verdict.set_metric(metric_id, support_result[metric_id])
		verdict.set_metric("program_id", "[support_result["program_id"] || ""]")
		verdict.set_metric("style_id", "[support_result["style_id"] || ""]")
		verdict.set_metric("shape_id", "[support_result["requested_shape_id"] || ""]")
		verdict.set_metric("feasibility_dry_solve_status", "[support_result["feasibility_dry_solve_status"] || ""]")
		verdict.set_metric("feasibility_dry_solve_stage", "[support_result["feasibility_dry_solve_stage"] || ""]")
		verdict.set_metric("can_preview", support_result["can_preview"] ? TRUE : FALSE)
		verdict.set_metric("can_apply", support_result["can_apply"] ? TRUE : FALSE)
	if(verdict_status != WORLD_EDIT_BUILDING_PREFLIGHT_SUPPORTED)
		var/error_code = "[support_result?["lock_code"] || support_result?["reason_code"] || support_status || WORLD_EDIT_BUILDING_ERROR_HARD_VALIDATION_FAILED]"
		var/error_message = "[support_result?["reason"] || "Building request is unsupported."]"
		verdict.add_hard_error(error_code, error_message, list(
			"program_id" = "[support_result?["program_id"] || ""]",
			"style_id" = "[support_result?["style_id"] || ""]",
			"shape_id" = "[support_result?["requested_shape_id"] || ""]",
		))
	else if(islist(support_result) && length("[support_result["reason"]]") && !support_result["can_apply"])
		verdict.add_warning("request.confirmation_required", "[support_result["reason"]]", list(
			"program_id" = "[support_result["program_id"] || ""]",
			"style_id" = "[support_result["style_id"] || ""]",
		))
	return verdict

/datum/world_edit_generator/building_layout/proc/finalize_building_support_result(list/support_result)
	if(!islist(support_result))
		return support_result
	var/datum/world_edit_validation_verdict/verdict = build_building_support_validation_verdict(support_result)
	support_result["verdict"] = verdict.as_payload()
	support_result["preflight_status"] = verdict.status
	support_result["hard_error_count"] = length(verdict.hard_errors)
	support_result["warning_count"] = length(verdict.warnings)
	return support_result

/datum/world_edit_generator/building_layout/proc/build_building_context_support_result(shape_id, list/config, list/placement_context = null)
	var/list/result = list(
		"status" = WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED,
		"reason" = "",
		"visible" = TRUE,
		"locked" = FALSE,
		"shape_locked" = FALSE,
		"request_locked" = FALSE,
		"lock_code" = "",
		"can_preview" = TRUE,
		"can_apply" = TRUE,
		"requested_shape_id" = "[shape_id]",
		"program_id" = "",
		"style_id" = "",
		"size_policy" = "",
		"degrade_level" = WORLD_EDIT_BUILDING_DEGRADE_NONE,
		"program_shedding" = FALSE,
		"estimated_usable_area" = 0,
		"required_usable_area" = 0,
		"required_compact_area" = 0,
		"requested_direction" = islist(placement_context) ? placement_context["direction"] : null,
		"respect_blockers" = FALSE,
		"replace_blocked_turfs" = FALSE,
		"will_replace_blocked_turfs" = FALSE,
		"blocked_turf_conflict_count" = 0,
		"replace_blocked_turf_count" = 0,
		"default_max_replaced_blockers" = WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS,
		"hard_max_replaced_blockers" = WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS,
		"feasibility_dry_solve_status" = "not_run",
		"feasibility_dry_solve_stage" = WORLD_EDIT_BUILDING_STAGE_FEASIBILITY,
		"feasibility_dry_solve_attempt_count" = 0,
		"feasibility_dry_solve_valid_candidate_count" = 0,
		"feasibility_dry_solve_error_count" = 0,
		"feasibility_dry_solve_reason" = "",
	)
	if(!islist(config))
		result["status"] = WORLD_EDIT_BUILDING_SUPPORT_FAILED
		result["reason"] = "Building request config is unavailable."
		result["request_locked"] = TRUE
		result["can_preview"] = FALSE
		result["can_apply"] = FALSE
		return finalize_building_support_result(result)
	result["program_id"] = "[config["archetype_id"] || ""]"
	result["style_id"] = "[config["faction_preset"] || ""]"
	result["respect_blockers"] = config["respect_blockers"] ? TRUE : FALSE
	result["replace_blocked_turfs"] = config["replace_blocked_turfs"] ? TRUE : FALSE
	result["will_replace_blocked_turfs"] = result["replace_blocked_turfs"]
	if(islist(placement_context))
		var/list/context_turfs = get_building_support_blocker_turfs(shape_id, config, placement_context)
		if(islist(context_turfs) && length(context_turfs))
			var/context_blocked_count = 0
			var/first_context_blocker_error = null
			for(var/turf/context_turf as anything in context_turfs)
				var/context_blocker_error = get_footprint_blocker_error(context_turf)
				if(!length("[context_blocker_error]"))
					continue
				context_blocked_count++
				if(isnull(first_context_blocker_error))
					first_context_blocker_error = context_blocker_error
			result["blocked_turf_conflict_count"] = context_blocked_count
			result["replace_blocked_turf_count"] = result["replace_blocked_turfs"] ? context_blocked_count : 0
			if(context_blocked_count > 0 && (result["respect_blockers"] || !result["replace_blocked_turfs"]))
				result["status"] = WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
				result["reason"] = "Cannot build: [first_context_blocker_error]"
				result["request_locked"] = TRUE
				result["can_preview"] = FALSE
				result["can_apply"] = FALSE
				return finalize_building_support_result(result)
			if(result["replace_blocked_turfs"] && context_blocked_count > WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS && !config["confirm_large_replacement"])
				result["reason"] = "Building would replace [context_blocked_count] blocked turfs. Enable large replacement confirmation."
				result["can_apply"] = FALSE
			if(result["replace_blocked_turfs"] && context_blocked_count > WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS)
				result["status"] = WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
				result["reason"] = "Building would replace [context_blocked_count] blocked turfs, above the hard cap of [WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS]."
				result["request_locked"] = TRUE
				result["can_preview"] = FALSE
				result["can_apply"] = FALSE
				return finalize_building_support_result(result)
	var/datum/world_edit_building_archetype/archetype = get_building_archetype_catalog()[result["program_id"]]
	if(!istype(archetype))
		result["status"] = WORLD_EDIT_BUILDING_SUPPORT_DISABLED
		result["reason"] = "Building program '[result["program_id"]]' is not available in the archetype catalog."
		result["request_locked"] = TRUE
		result["can_preview"] = FALSE
		result["can_apply"] = FALSE
		return finalize_building_support_result(result)
	if(config["error"])
		result["status"] = WORLD_EDIT_BUILDING_SUPPORT_FAILED
		result["reason"] = "[config["error"]]"
		result["lock_code"] = "[config["error_code"] || WORLD_EDIT_BUILDING_ERROR_HARD_VALIDATION_FAILED]"
		result["request_locked"] = TRUE
		result["locked"] = TRUE
		result["can_preview"] = FALSE
		result["can_apply"] = FALSE
		return finalize_building_support_result(result)

	var/shape_text = "[shape_id]"
	if(!(shape_text in list(
		WORLD_EDIT_SHAPE_POINT,
		WORLD_EDIT_SHAPE_RECTANGLE,
		WORLD_EDIT_SHAPE_FILLED_RECTANGLE
	)))
		result["status"] = WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
		result["reason"] = "Placement shape '[shape_text]' is not supported by building layout."
		result["shape_locked"] = TRUE
		result["request_locked"] = TRUE
		result["locked"] = TRUE
		result["lock_code"] = "shape.unsupported_for_building_layout"
		result["can_preview"] = FALSE
		result["can_apply"] = FALSE
		return finalize_building_support_result(result)

	var/required_compact_area = get_building_program_required_compact_area(archetype)
	var/estimated_usable_area = get_building_request_estimated_usable_area(config, shape_text == WORLD_EDIT_SHAPE_POINT ? null : placement_context)
	var/required_usable_area = shape_text == WORLD_EDIT_SHAPE_POINT ? max(required_compact_area, get_building_program_target_usable_area(archetype)) : required_compact_area
	result["required_compact_area"] = required_compact_area
	result["required_usable_area"] = required_usable_area
	result["estimated_usable_area"] = estimated_usable_area
	result["degrade_level"] = WORLD_EDIT_BUILDING_DEGRADE_NONE
	result["program_shedding"] = FALSE
	result["size_policy"] = config["size_policy"] || WORLD_EDIT_BUILDING_SIZE_POLICY_ADAPTIVE
	if(estimated_usable_area <= 0)
		result["status"] = WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
		result["reason"] = "Cannot build [archetype.id]: selected area has no usable tiles."
		result["request_locked"] = TRUE
		result["can_preview"] = FALSE
		result["can_apply"] = FALSE
		return finalize_building_support_result(result)
	if(estimated_usable_area < required_compact_area)
		result["status"] = WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
		result["reason"] = "Cannot build [archetype.id]: selected area has [estimated_usable_area]/[required_compact_area] minimum usable tiles."
		result["lock_code"] = WORLD_EDIT_BUILDING_ERROR_PROGRAM_INSUFFICIENT_FOOTPRINT
		result["request_locked"] = TRUE
		result["locked"] = TRUE
		result["can_preview"] = FALSE
		result["can_apply"] = FALSE
		return finalize_building_support_result(result)

	if(!config["skip_feasibility_dry_solve"])
		var/list/dry_solve = build_building_feasibility_dry_solve_result(shape_text, config, placement_context)
		if(islist(dry_solve))
			result["feasibility_dry_solve_status"] = dry_solve["status"]
			result["feasibility_dry_solve_stage"] = dry_solve["stage"]
			result["feasibility_dry_solve_attempt_count"] = dry_solve["candidate_attempt_count"]
			result["feasibility_dry_solve_valid_candidate_count"] = dry_solve["valid_candidate_count"]
			result["feasibility_dry_solve_error_count"] = dry_solve["error_candidate_count"]
			result["feasibility_dry_solve_reason"] = dry_solve["reason"]
			if(islist(dry_solve["selected_candidate_report"]))
				result["feasibility_dry_solve_selected_candidate"] = dry_solve["selected_candidate_report"]
			if(islist(dry_solve["failed_candidate_report"]))
				result["feasibility_dry_solve_failed_candidate"] = dry_solve["failed_candidate_report"]
			if("[dry_solve["status"]]" == "no_solution" || "[dry_solve["status"]]" == "failed")
				result["status"] = WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
				result["reason"] = length("[dry_solve["reason"]]") ? "[dry_solve["reason"]]" : "Cannot build [archetype.id]: no valid topology/route candidate found."
				result["lock_code"] = WORLD_EDIT_BUILDING_ERROR_PROGRAM_INSUFFICIENT_FOOTPRINT
				result["request_locked"] = TRUE
				result["locked"] = TRUE
				result["can_preview"] = FALSE
				result["can_apply"] = FALSE
				return finalize_building_support_result(result)
	else
		result["feasibility_dry_solve_status"] = "skipped_internal"
		result["feasibility_dry_solve_reason"] = "Internal support recursion guard."

	return finalize_building_support_result(result)

/datum/world_edit_generator/building_layout/get_placement_shape_support_report(shape_id, list/params, list/placement_context)
	var/list/config = normalize_building_params(params)
	feasibility_cached_request_key = null
	feasibility_cached_state = null
	feasibility_cached_support_report = null
	var/list/report = build_building_context_support_result(shape_id, config, placement_context)
	var/shape_locked = report["shape_locked"] || "[report["lock_code"]]" == "shape.unsupported_for_building_layout"
	report["shape_locked"] = shape_locked ? TRUE : FALSE
	report["request_locked"] = "[report["status"]]" != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED
	report["locked"] = report["shape_locked"] ? TRUE : FALSE
	if(istype(feasibility_cached_state) && "[report["status"]]" == WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		feasibility_cached_support_report = report.Copy()
	else
		feasibility_cached_request_key = null
		feasibility_cached_state = null
	return report

/datum/world_edit_generator/building_layout/proc/build_building_feasibility_cache_key(shape_id, list/config, list/placement_context)
	if(!islist(config) || !islist(placement_context))
		return null
	var/list/key_parts = list(
		"archetype_id=[config["archetype_id"]]",
		"faction_preset=[config["faction_preset"]]",
		"shape=[shape_id || placement_context["shape"] || WORLD_EDIT_SHAPE_POINT]",
		"direction=[placement_context["direction"] || config["direction"] || NORTH]",
		"auto_size=[config["auto_size"] ? TRUE : FALSE]",
		"half_width=[config["half_width"]]",
		"half_depth=[config["half_depth"]]",
		"size_profile=[config["size_profile"]]",
		"target_room_count=[config["target_room_count"]]",
		"window_density=[config["window_density"]]",
		"detail_budget=[config["detail_budget"]]",
		"building_seed=[config["building_seed"]]",
		"back_exit=[config["back_exit"] ? TRUE : FALSE]",
		"respect_blockers=[config["respect_blockers"] ? TRUE : FALSE]",
		"replace_blocked_turfs=[config["replace_blocked_turfs"] ? TRUE : FALSE]",
		"forced_footprint_family=[config["forced_footprint_family"]]",
	)
	var/list/anchor_keys = list()
	for(var/turf/anchor_turf as anything in placement_context["anchor_turfs"])
		if(istype(anchor_turf))
			anchor_keys += "[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]"
	if(length(anchor_keys))
		key_parts += "anchors=[sortList(anchor_keys).Join(";")]"
	return sortList(key_parts).Join("|")

/datum/world_edit_generator/building_layout/proc/get_building_program_required_compact_area(datum/world_edit_building_archetype/archetype)
	if(!istype(archetype))
		return 0
	var/required_area = 0
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in archetype.zone_specs)
		if(!istype(zone_spec) || !zone_spec.required)
			continue
		required_area += max(round(text2num("[zone_spec.min_area]") || 0), 0)
	return required_area

/datum/world_edit_generator/building_layout/proc/get_building_size_degrade_level(estimated_usable_area, required_usable_area)
	estimated_usable_area = max(round(text2num("[estimated_usable_area]") || 0), 0)
	required_usable_area = max(round(text2num("[required_usable_area]") || 0), 0)
	if(required_usable_area <= 0 || estimated_usable_area >= required_usable_area)
		return WORLD_EDIT_BUILDING_DEGRADE_NONE
	if(estimated_usable_area >= max(round(required_usable_area * 0.45), 4))
		return WORLD_EDIT_BUILDING_DEGRADE_COMPACT
	return WORLD_EDIT_BUILDING_DEGRADE_MICRO

/datum/world_edit_generator/building_layout/proc/apply_building_support_result_to_config(list/config, list/support_result)
	if(!islist(config) || !islist(support_result))
		return
	config["current_request_support_status"] = support_result["status"]
	config["user_facing_failure_reason"] = support_result["reason"]
	config["support_status_report"] = support_result.Copy()
	config["support_verdict"] = support_result["verdict"]
	config["size_degrade_level"] = support_result["degrade_level"] || WORLD_EDIT_BUILDING_DEGRADE_NONE
	config["program_shedding"] = support_result["program_shedding"] ? TRUE : FALSE
	config["estimated_usable_area"] = support_result["estimated_usable_area"]
	config["required_usable_area"] = support_result["required_usable_area"]
	config["required_compact_area"] = support_result["required_compact_area"]
	if(length("[support_result["size_policy"]]"))
		config["size_policy"] = support_result["size_policy"]

/datum/world_edit_generator/building_layout/proc/get_building_support_blocker_turfs(shape_id, list/config, list/placement_context)
	if(!islist(placement_context))
		return null
	var/datum/world_edit_shape_contract/shape_contract = placement_context["shape_contract"]
	var/list/raw_turfs = null
	if(istype(shape_contract))
		raw_turfs = shape_contract.copy_anchor_turfs()
	if(!islist(raw_turfs) || !length(raw_turfs))
		raw_turfs = placement_context["anchor_turfs"]
	if(!islist(raw_turfs) || !length(raw_turfs))
		return null
	if("[shape_id]" != WORLD_EDIT_SHAPE_POINT)
		var/list/explicit_footprint = build_explicit_shape_footprint(shape_contract, raw_turfs, placement_context)
		if(length(explicit_footprint))
			return explicit_footprint
	return raw_turfs

/datum/world_edit_generator/building_layout/proc/get_building_request_estimated_usable_area(list/config, list/placement_context = null)
	var/shape_id = islist(placement_context) ? placement_context["shape"] : null
	var/list/footprint = get_building_support_blocker_turfs(shape_id || WORLD_EDIT_SHAPE_POINT, config, placement_context)
	if(islist(footprint) && length(footprint))
		var/list/boundary = GLOB.world_edit_placement_shapes.world_edit_collect_boundary_turfs(footprint)
		return max(length(footprint) - length(boundary), 0)
	var/half_width = max(round(text2num("[config?["half_width"]]") || 0), 0)
	var/half_depth = max(round(text2num("[config?["half_depth"]]") || 0), 0)
	var/outer_width = max(half_width * 2 + 1, 0)
	var/outer_height = max(half_depth * 2 + 1, 0)
	return max(outer_width - 2, 0) * max(outer_height - 2, 0)

/datum/world_edit_generator/building_layout/proc/get_building_shape_error(shape_id, list/config, list/placement_context = null)
	var/list/support_result = build_building_context_support_result(shape_id, config, placement_context)
	if("[support_result["status"]]" != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		return "[support_result["reason"]]"
	return null

/datum/world_edit_generator/building_layout/validate_params(mob/user, list/params)
	var/list/config = normalize_building_params(params)
	if(config["error"])
		return "[config["error"]]"
	var/shape_id = manager?.get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT
	var/shape_error = get_building_shape_error(shape_id, config)
	if(length("[shape_error]"))
		return shape_error
	return null

/datum/world_edit_generator/building_layout/get_shape_support_error(shape_id, list/anchor_turfs, list/params, list/placement_context)
	var/list/config = normalize_building_params(params)
	if(config["error"])
		return "[config["error"]]"
	return get_building_shape_error(shape_id, config, placement_context)

/datum/world_edit_generator/building_layout/proc/turf_coord_key(turf/target_turf)
	if(!istype(target_turf))
		return ""
	return "[target_turf.x],[target_turf.y],[target_turf.z]"

/datum/world_edit_generator/building_layout/proc/fill_turf_bounds(list/raw_turfs)
	var/list/result = list()
	var/list/result_lookup = list()
	if(!islist(raw_turfs) || !length(raw_turfs))
		return result

	var/min_x = null
	var/max_x = null
	var/min_y = null
	var/max_y = null
	var/z_level = null
	for(var/turf/source_turf as anything in raw_turfs)
		if(!istype(source_turf))
			continue
		if(isnull(z_level))
			z_level = source_turf.z
		if(source_turf.z != z_level)
			continue
		if(isnull(min_x) || source_turf.x < min_x)
			min_x = source_turf.x
		if(isnull(max_x) || source_turf.x > max_x)
			max_x = source_turf.x
		if(isnull(min_y) || source_turf.y < min_y)
			min_y = source_turf.y
		if(isnull(max_y) || source_turf.y > max_y)
			max_y = source_turf.y

	if(isnull(min_x) || isnull(min_y) || isnull(z_level))
		return result

	for(var/y in min_y to max_y)
		for(var/x in min_x to max_x)
			var/turf/target_turf = locate(x, y, z_level)
			GLOB.world_edit_placement_shapes.world_edit_add_turf_unique(result, result_lookup, target_turf, z_level)
	return result

/datum/world_edit_generator/building_layout/proc/fill_turf_bounds_capped(list/raw_turfs, max_turf_count = WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS)
	var/list/filled = fill_turf_bounds(raw_turfs)
	if(length(filled) > max(round(text2num("[max_turf_count]") || WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS), 1))
		return GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(raw_turfs)
	return filled

/datum/world_edit_generator/building_layout/proc/inflate_turf_footprint(list/raw_turfs, radius = 1)
	var/list/result = list()
	var/list/result_lookup = list()
	if(!islist(raw_turfs) || !length(raw_turfs))
		return result
	radius = max(round(radius), 0)
	var/z_level = null
	for(var/turf/source_turf as anything in raw_turfs)
		if(!istype(source_turf))
			continue
		if(isnull(z_level))
			z_level = source_turf.z
		if(source_turf.z != z_level)
			continue
		for(var/dx in -radius to radius)
			for(var/dy in -radius to radius)
				var/turf/target_turf = locate(source_turf.x + dx, source_turf.y + dy, source_turf.z)
				GLOB.world_edit_placement_shapes.world_edit_add_turf_unique(result, result_lookup, target_turf, z_level)
	return result

/datum/world_edit_generator/building_layout/proc/add_scatter_connection_turf(list/result, list/result_lookup, turf/source_turf, z_level)
	if(!istype(source_turf) || isnull(z_level) || source_turf.z != z_level)
		return
	for(var/dx in -2 to 2)
		for(var/dy in -2 to 2)
			var/turf/target_turf = locate(source_turf.x + dx, source_turf.y + dy, source_turf.z)
			GLOB.world_edit_placement_shapes.world_edit_add_turf_unique(result, result_lookup, target_turf, z_level)

/datum/world_edit_generator/building_layout/proc/add_scatter_connection_line(list/result, list/result_lookup, turf/start_turf, turf/end_turf, z_level)
	if(!istype(start_turf) || !istype(end_turf) || isnull(z_level) || start_turf.z != z_level || end_turf.z != z_level)
		return
	var/current_x = start_turf.x
	var/current_y = start_turf.y
	var/safety = WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS
	while(current_x != end_turf.x && safety-- > 0)
		current_x += current_x < end_turf.x ? 1 : -1
		add_scatter_connection_turf(result, result_lookup, locate(current_x, current_y, z_level), z_level)
	while(current_y != end_turf.y && safety-- > 0)
		current_y += current_y < end_turf.y ? 1 : -1
		add_scatter_connection_turf(result, result_lookup, locate(current_x, current_y, z_level), z_level)

/datum/world_edit_generator/building_layout/proc/build_scatter_compound_footprint(list/raw_turfs)
	var/list/source_turfs = GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(raw_turfs)
	var/list/result = list()
	var/list/result_lookup = list()
	if(!length(source_turfs))
		return result
	var/z_level = null
	var/turf/previous_turf = null
	for(var/turf/source_turf as anything in source_turfs)
		if(!istype(source_turf))
			continue
		if(isnull(z_level))
			z_level = source_turf.z
		if(source_turf.z != z_level)
			continue
		add_scatter_connection_turf(result, result_lookup, source_turf, z_level)
		if(istype(previous_turf))
			add_scatter_connection_line(result, result_lookup, previous_turf, source_turf, z_level)
		previous_turf = source_turf
	return GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(result)

/datum/world_edit_generator/building_layout/proc/should_adapt_shape_to_building_envelope(shape_id)
	switch("[shape_id]")
		if(
			WORLD_EDIT_SHAPE_CIRCLE,
			WORLD_EDIT_SHAPE_RING,
			WORLD_EDIT_SHAPE_ELLIPSE,
			WORLD_EDIT_SHAPE_DIAMOND,
			WORLD_EDIT_SHAPE_TRIANGLE,
			WORLD_EDIT_SHAPE_SECTOR,
			WORLD_EDIT_SHAPE_CUSTOM_MASK,
			WORLD_EDIT_SHAPE_BRUSH_PATH
		)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/build_explicit_shape_footprint(datum/world_edit_shape_contract/shape_contract, list/raw_turfs, list/placement_context)
	var/shape_id = "[shape_contract?.shape_id || (islist(placement_context) ? placement_context["shape"] : null) || WORLD_EDIT_SHAPE_POINT]"
	var/list/footprint = GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(raw_turfs)
	if(!length(footprint))
		return footprint

	switch(shape_id)
		if(WORLD_EDIT_SHAPE_RECTANGLE)
			if(shape_contract?.is_closed && !shape_contract?.is_filled)
				footprint = fill_turf_bounds_capped(footprint)
		if(WORLD_EDIT_SHAPE_POLYGON)
			if(shape_contract?.is_closed && !shape_contract?.is_filled)
				var/list/metadata = istype(shape_contract) ? shape_contract.copy_metadata() : placement_context["shape_metadata"]
				if(!islist(metadata))
					metadata = list()
				var/list/points = metadata["normalized_points"]
				var/turf/origin_turf = placement_context["shape_origin_turf"] || placement_context["start_turf"] || get_shape_placement_seed_turf(shape_contract, placement_context)
				if(istype(origin_turf) && islist(points) && length(points) >= 3)
					footprint = GLOB.world_edit_placement_shapes.world_edit_collect_polygon_turfs(origin_turf, points, TRUE)
		if(WORLD_EDIT_SHAPE_LINE, WORLD_EDIT_SHAPE_POLYLINE)
			footprint = fill_turf_bounds_capped(inflate_turf_footprint(footprint, 4))
		if(WORLD_EDIT_SHAPE_SCATTER_CLUSTER)
			footprint = fill_turf_bounds_capped(build_scatter_compound_footprint(footprint))

	if(should_adapt_shape_to_building_envelope(shape_id))
		footprint = fill_turf_bounds_capped(footprint)

	return GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(footprint)

/datum/world_edit_generator/building_layout/proc/select_building_context_center_turf(list/raw_turfs)
	if(!islist(raw_turfs) || !length(raw_turfs))
		return null
	var/min_x = null
	var/max_x = null
	var/min_y = null
	var/max_y = null
	var/z_level = null
	for(var/turf/source_turf as anything in raw_turfs)
		if(!istype(source_turf))
			continue
		if(isnull(z_level))
			z_level = source_turf.z
		if(source_turf.z != z_level)
			continue
		if(isnull(min_x) || source_turf.x < min_x)
			min_x = source_turf.x
		if(isnull(max_x) || source_turf.x > max_x)
			max_x = source_turf.x
		if(isnull(min_y) || source_turf.y < min_y)
			min_y = source_turf.y
		if(isnull(max_y) || source_turf.y > max_y)
			max_y = source_turf.y
	if(isnull(min_x) || isnull(min_y) || isnull(z_level))
		return null
	var/center_x = round((min_x + max_x) / 2)
	var/center_y = round((min_y + max_y) / 2)
	return locate(center_x, center_y, z_level)

/datum/world_edit_generator/building_layout/proc/resolve_shape_footprint(datum/world_edit_shape_contract/shape_contract, list/config, list/params, list/placement_context)
	var/list/result = list("footprint" = list())
	var/shape_id = "[shape_contract?.shape_id || (islist(placement_context) ? placement_context["shape"] : null) || WORLD_EDIT_SHAPE_POINT]"
	var/list/support_result = build_building_context_support_result(shape_id, config, placement_context)
	apply_building_support_result_to_config(config, support_result)
	if("[support_result["status"]]" != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		result["support_status"] = support_result["status"]
		result["user_facing_failure_reason"] = support_result["reason"]
		result["support_status_report"] = support_result
		result["error"] = "[support_result["reason"]]"
		return result

	var/list/raw_turfs = null
	if(istype(shape_contract))
		raw_turfs = shape_contract.copy_anchor_turfs()
	if((!islist(raw_turfs) || !length(raw_turfs)) && islist(placement_context))
		raw_turfs = placement_context["anchor_turfs"]
	var/turf/seed_turf = get_shape_placement_seed_turf(shape_contract, placement_context)
	if(!istype(seed_turf) && islist(placement_context))
		seed_turf = placement_context["seed_turf"]
	if(!istype(seed_turf) && islist(placement_context))
		seed_turf = placement_context["shape_origin_turf"]
	if(!istype(seed_turf) && islist(placement_context))
		seed_turf = placement_context["start_turf"]
	if(!istype(seed_turf))
		seed_turf = select_building_context_center_turf(raw_turfs)
	if(!istype(seed_turf))
		result["error"] = "Unable to resolve building center turf."
		return result
	if(shape_id != WORLD_EDIT_SHAPE_POINT)
		var/list/explicit_footprint = build_explicit_shape_footprint(shape_contract, raw_turfs, placement_context)
		if(!length(explicit_footprint))
			result["error"] = "Unable to resolve explicit building shape footprint."
			return result
		config["placement_shape_used_as_seed_only"] = FALSE
		config["explicit_placement_shape_footprint"] = TRUE
		config["footprint_source"] = "explicit_shape"
		config["placement_shape_id"] = shape_id
		config["footprint_family"] = uppertext("[shape_id]")
		config["footprint_mask_score"] = 0
		config["footprint_mask_candidate_count"] = 1
		result["footprint"] = explicit_footprint
		result["footprint_family"] = uppertext("[shape_id]")
		return result
	config["placement_shape_used_as_seed_only"] = TRUE
	config["footprint_source"] = "point_size"
	config["placement_shape_id"] = shape_id
	return build_point_building_footprint(seed_turf, config, placement_context)

/datum/world_edit_generator/building_layout/proc/validate_footprint(list/footprint, list/config)
	var/list/result = list()
	footprint = GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(footprint)
	result["footprint"] = footprint
	if(!length(footprint))
		result["error"] = "Building footprint is empty."
		return result
	if(length(footprint) > WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS)
		result["error"] = "Building footprint exceeds cap ([WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS])."
		return result

	var/z_level = null
	var/min_x = null
	var/max_x = null
	var/min_y = null
	var/max_y = null
	for(var/turf/target_turf as anything in footprint)
		if(!istype(target_turf))
			result["error"] = "Building footprint contains an invalid turf."
			return result
		if(isnull(z_level))
			z_level = target_turf.z
		if(target_turf.z != z_level)
			result["error"] = "Building footprint must stay on one z-level."
			return result
		if(isnull(min_x) || target_turf.x < min_x)
			min_x = target_turf.x
		if(isnull(max_x) || target_turf.x > max_x)
			max_x = target_turf.x
		if(isnull(min_y) || target_turf.y < min_y)
			min_y = target_turf.y
		if(isnull(max_y) || target_turf.y > max_y)
			max_y = target_turf.y

	var/width = max_x - min_x + 1
	var/height = max_y - min_y + 1
	if(width < 3 || height < 3)
		result["error"] = "Building footprint requires at least a 3x3 area."
		return result

	var/list/footprint_lookup = GLOB.world_edit_placement_shapes.world_edit_build_turf_lookup(footprint)
	var/list/visited_lookup = list()
	var/list/queue = list(footprint[1])
	visited_lookup[footprint[1]] = TRUE
	var/index = 1
	while(index <= length(queue))
		var/turf/current_turf = queue[index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(current_turf, check_dir)
			if(!footprint_lookup[nearby_turf] || visited_lookup[nearby_turf])
				continue
			visited_lookup[nearby_turf] = TRUE
			queue += nearby_turf
	if(length(queue) != length(footprint))
		result["error"] = "Building footprint must be connected."
		return result

	var/blocked_turf_conflict_count = 0
	var/first_blocker_error = null
	for(var/turf/check_turf as anything in footprint)
		var/blocker_error = get_footprint_blocker_error(check_turf)
		if(!length("[blocker_error]"))
			continue
		blocked_turf_conflict_count++
		if(isnull(first_blocker_error))
			first_blocker_error = blocker_error
		if(config["respect_blockers"] || !config["replace_blocked_turfs"])
			result["blocked_turf_conflict_count"] = blocked_turf_conflict_count
			result["replace_blocked_turf_count"] = 0
			config["blocked_turf_conflict_count"] = blocked_turf_conflict_count
			config["replace_blocked_turf_count"] = 0
			config["first_blocked_turf_error"] = blocker_error
			result["error"] = "Cannot build: [blocker_error]"
			return result
	result["blocked_turf_conflict_count"] = blocked_turf_conflict_count
	result["replace_blocked_turf_count"] = config["replace_blocked_turfs"] ? blocked_turf_conflict_count : 0
	config["blocked_turf_conflict_count"] = blocked_turf_conflict_count
	config["replace_blocked_turf_count"] = config["replace_blocked_turfs"] ? blocked_turf_conflict_count : 0
	if(blocked_turf_conflict_count > 0)
		config["first_blocked_turf_error"] = first_blocker_error
	if(config["replace_blocked_turfs"] && blocked_turf_conflict_count > WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS)
		result["error"] = "Cannot build: footprint would replace [blocked_turf_conflict_count] blocked turfs, above the hard cap of [WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS]."
		return result
	if(config["replace_blocked_turfs"] && blocked_turf_conflict_count > WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS && !config["confirm_large_replacement"])
		config["large_replacement_requires_confirmation"] = TRUE
		config["large_replacement_reason"] = "Building would replace [blocked_turf_conflict_count] blocked turfs. Enable large replacement confirmation before apply."

	var/list/boundary = GLOB.world_edit_placement_shapes.world_edit_collect_boundary_turfs(footprint)
	if(length(boundary) < 3)
		result["error"] = "Unable to resolve building exterior boundary."
		return result

	var/list/boundary_lookup = GLOB.world_edit_placement_shapes.world_edit_build_turf_lookup(boundary)
	var/list/interior = list()
	for(var/turf/interior_turf as anything in footprint)
		if(boundary_lookup[interior_turf])
			continue
		interior += interior_turf

	result["bounds"] = list("min_x" = min_x, "max_x" = max_x, "min_y" = min_y, "max_y" = max_y, "width" = width, "height" = height, "z" = z_level)
	result["boundary"] = boundary
	result["interior"] = interior
	result["footprint_lookup"] = footprint_lookup
	return result

/datum/world_edit_generator/building_layout/proc/get_footprint_blocker_error(turf/target_turf)
	if(!istype(target_turf))
		return "Footprint contains an invalid turf."
	if(target_turf.density)
		return "Footprint intersects dense turf [GLOB.world_edit_helpers.turf_to_text(target_turf)]."
	for(var/atom/movable/blocker as anything in target_turf)
		if(ismob(blocker))
			continue
		if(blocker.density)
			return "Footprint intersects dense object at [GLOB.world_edit_helpers.turf_to_text(target_turf)]."
	return null

/datum/world_edit_generator/building_layout/proc/get_dir_component_x(direction)
	switch(direction)
		if(EAST)
			return 1
		if(WEST)
			return -1
	return 0

/datum/world_edit_generator/building_layout/proc/get_dir_component_y(direction)
	switch(direction)
		if(NORTH)
			return 1
		if(SOUTH)
			return -1
	return 0

/datum/world_edit_generator/building_layout/proc/get_projection_for_dir(turf/target_turf, center_x, center_y, direction)
	if(!istype(target_turf))
		return -999999
	return ((target_turf.x - center_x) * get_dir_component_x(direction)) + ((target_turf.y - center_y) * get_dir_component_y(direction))

/datum/world_edit_generator/building_layout/proc/get_lateral_distance_for_dir(turf/target_turf, center_x, center_y, direction)
	if(direction in list(NORTH, SOUTH))
		return abs(target_turf.x - center_x)
	return abs(target_turf.y - center_y)

/datum/world_edit_generator/building_layout/proc/get_side_axis_positive_dir(direction)
	if(direction in list(NORTH, SOUTH))
		return EAST
	return NORTH

/datum/world_edit_generator/building_layout/proc/get_side_axis_negative_dir(direction)
	if(direction in list(NORTH, SOUTH))
		return WEST
	return SOUTH

/datum/world_edit_generator/building_layout/proc/boundary_turf_has_outside_dir(turf/target_turf, list/footprint_lookup, direction)
	if(!istype(target_turf) || !islist(footprint_lookup))
		return FALSE
	var/turf/nearby_turf = get_step(target_turf, direction)
	return !footprint_lookup[nearby_turf]

/datum/world_edit_generator/building_layout/proc/get_side_run_length(turf/target_turf, list/side_lookup, direction)
	if(!istype(target_turf) || !islist(side_lookup) || !side_lookup[target_turf])
		return 0
	var/run_length = 1
	var/positive_dir = get_side_axis_positive_dir(direction)
	var/negative_dir = get_side_axis_negative_dir(direction)
	var/turf/check_turf = get_step(target_turf, positive_dir)
	while(side_lookup[check_turf])
		run_length++
		check_turf = get_step(check_turf, positive_dir)
	check_turf = get_step(target_turf, negative_dir)
	while(side_lookup[check_turf])
		run_length++
		check_turf = get_step(check_turf, negative_dir)
	return run_length

/datum/world_edit_generator/building_layout/proc/select_boundary_turf_for_dir(list/boundary, center_x, center_y, direction, list/excluded_lookup = null, list/footprint_lookup = null)
	var/list/side_lookup = list()
	if(islist(footprint_lookup))
		for(var/turf/boundary_turf as anything in boundary)
			if(!istype(boundary_turf) || (islist(excluded_lookup) && excluded_lookup[boundary_turf]))
				continue
			if(boundary_turf_has_outside_dir(boundary_turf, footprint_lookup, direction))
				side_lookup[boundary_turf] = TRUE

	var/turf/best_turf = null
	var/best_score = -999999999
	for(var/turf/boundary_turf as anything in boundary)
		if(!istype(boundary_turf) || (islist(excluded_lookup) && excluded_lookup[boundary_turf]))
			continue
		var/projection = get_projection_for_dir(boundary_turf, center_x, center_y, direction)
		var/lateral = get_lateral_distance_for_dir(boundary_turf, center_x, center_y, direction)
		var/exact_side = side_lookup[boundary_turf]
		var/run_length = exact_side ? get_side_run_length(boundary_turf, side_lookup, direction) : 0
		var/score = (projection * 100) - (lateral * 10)
		if(exact_side)
			score += 100000
		if(run_length >= 3)
			score += 30000 + (min(run_length, 8) * 1000)
		else if(run_length)
			score += run_length * 500
		if(islist(footprint_lookup) && is_corner_boundary_turf(boundary_turf, footprint_lookup))
			score -= 20000
		if(!istype(best_turf) || score > best_score)
			best_turf = boundary_turf
			best_score = score
	return best_turf

/datum/world_edit_generator/building_layout/proc/get_outward_dir(turf/target_turf, list/footprint_lookup, center_x, center_y, preferred_dir = NORTH)
	if(!istype(target_turf))
		return preferred_dir
	var/list/outside_dirs = list()
	for(var/check_dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(target_turf, check_dir)
		if(footprint_lookup[nearby_turf])
			continue
		outside_dirs += check_dir
	if(!length(outside_dirs))
		return preferred_dir
	if(preferred_dir in outside_dirs)
		return preferred_dir

	var/best_dir = outside_dirs[1]
	var/best_score = -999999
	for(var/outside_dir in outside_dirs)
		var/score = (get_dir_component_x(outside_dir) * (target_turf.x - center_x)) + (get_dir_component_y(outside_dir) * (target_turf.y - center_y))
		if(score > best_score)
			best_score = score
			best_dir = outside_dir
	return best_dir

/datum/world_edit_generator/building_layout/proc/is_corner_boundary_turf(turf/target_turf, list/footprint_lookup)
	if(!istype(target_turf) || !islist(footprint_lookup))
		return FALSE
	var/outside_count = 0
	for(var/check_dir in GLOB.cardinals)
		var/turf/nearby_turf = get_step(target_turf, check_dir)
		if(!footprint_lookup[nearby_turf])
			outside_count++
	return outside_count >= 2

/datum/world_edit_generator/building_layout/proc/append_unique_turf(list/target_list, list/target_lookup, turf/target_turf)
	if(!istype(target_turf) || target_lookup[target_turf])
		return FALSE
	target_list += target_turf
	target_lookup[target_turf] = TRUE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_turf_placement(kind, turf/target_turf, turf_path)
	return list(
		"kind" = kind,
		"turf" = target_turf,
		"x" = target_turf.x,
		"y" = target_turf.y,
		"z" = target_turf.z,
		"turf_path" = turf_path,
	)

/datum/world_edit_generator/building_layout/proc/build_object_placement(kind, turf/target_turf, obj_path, dir_to_use)
	return list(
		"kind" = kind,
		"turf" = target_turf,
		"x" = target_turf.x,
		"y" = target_turf.y,
		"z" = target_turf.z,
		"obj_path" = obj_path,
		"dir" = dir_to_use,
	)

/datum/world_edit_generator/building_layout/proc/get_cardinal_dir_toward(turf/source_turf, turf/target_turf, fallback_dir = SOUTH)
	if(!istype(source_turf) || !istype(target_turf))
		return fallback_dir
	var/dx = target_turf.x - source_turf.x
	var/dy = target_turf.y - source_turf.y
	if(abs(dx) >= abs(dy) && dx)
		return dx > 0 ? EAST : WEST
	if(dy)
		return dy > 0 ? NORTH : SOUTH
	return fallback_dir

/datum/world_edit_generator/building_layout/proc/select_center_floor_turf(list/floor_turfs, center_x, center_y)
	var/turf/best_turf = null
	var/best_distance = 999999
	for(var/turf/floor_turf as anything in floor_turfs)
		if(!istype(floor_turf))
			continue
		var/distance = abs(floor_turf.x - center_x) + abs(floor_turf.y - center_y)
		if(!istype(best_turf) || distance < best_distance)
			best_turf = floor_turf
			best_distance = distance
	return best_turf

/datum/world_edit_generator/building_layout/proc/build_reserved_path(turf/start_turf, turf/end_turf, list/floor_lookup)
	var/list/reserved = list()
	if(!istype(start_turf) || !istype(end_turf) || !islist(floor_lookup))
		return reserved

	var/list/queue = list(start_turf)
	var/list/visited = list()
	var/list/previous = list()
	visited[start_turf] = TRUE
	var/index = 1
	while(index <= length(queue))
		var/turf/current_turf = queue[index++]
		if(current_turf == end_turf)
			break
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(current_turf, check_dir)
			if(!floor_lookup[nearby_turf] || visited[nearby_turf])
				continue
			visited[nearby_turf] = TRUE
			previous[nearby_turf] = current_turf
			queue += nearby_turf

	if(!visited[end_turf])
		return list(start_turf, end_turf)

	var/turf/path_turf = end_turf
	while(istype(path_turf))
		reserved.Insert(1, path_turf)
		if(path_turf == start_turf)
			break
		path_turf = previous[path_turf]
	return reserved

/datum/world_edit_generator/building_layout/proc/build_reserved_paths(list/door_turfs, turf/center_turf, list/floor_lookup)
	var/list/reserved = list()
	var/list/reserved_lookup = list()
	if(!islist(door_turfs) || !istype(center_turf) || !islist(floor_lookup))
		return reserved
	for(var/turf/door_turf as anything in door_turfs)
		if(!istype(door_turf))
			continue
		var/list/door_path = build_reserved_path(door_turf, center_turf, floor_lookup)
		for(var/turf/path_turf as anything in door_path)
			append_unique_turf(reserved, reserved_lookup, path_turf)
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(door_turf, check_dir)
			if(floor_lookup[nearby_turf])
				append_unique_turf(reserved, reserved_lookup, nearby_turf)
	return reserved

/datum/world_edit_generator/building_layout/proc/resolve_interior_obj_path(list/config, slot)
	var/list/path_report = build_building_fixture_path_report(config, slot)
	return path_report["path"]

/datum/world_edit_generator/building_layout/proc/build_building_candidate_request(datum/world_edit_building_request/base_request, footprint_family, attempt_index)
	var/datum/world_edit_building_request/request = new
	request.config = base_request.config.Copy()
	request.config["forced_footprint_family"] = uppertext("[footprint_family]")
	request.config["layout_candidate_index"] = attempt_index
	request.config["layout_candidate_family"] = uppertext("[footprint_family]")
	request.archetype = base_request.archetype
	request.effective_seed = base_request.effective_seed
	var/candidate_seed = build_stage_seed(base_request.effective_seed, "candidate_[attempt_index]_[footprint_family]")
	var/program_seed = build_stage_seed(candidate_seed, "program")
	var/geometry_seed = build_stage_seed(candidate_seed, "geometry")
	var/fixture_seed = build_stage_seed(candidate_seed, "fixtures")
	var/facade_seed = build_stage_seed(candidate_seed, "facade")
	var/microvariation_seed = build_stage_seed(candidate_seed, "microvariation")
	request.program_rng = new /datum/world_edit_building_prng(program_seed)
	request.geometry_rng = new /datum/world_edit_building_prng(geometry_seed)
	request.fixture_rng = new /datum/world_edit_building_prng(fixture_seed)
	request.facade_rng = new /datum/world_edit_building_prng(facade_seed)
	request.microvariation_rng = new /datum/world_edit_building_prng(microvariation_seed)
	request.config["candidate_seed"] = candidate_seed
	request.config["stage_seed_program"] = program_seed
	request.config["stage_seed_geometry"] = geometry_seed
	request.config["stage_seed_fixtures"] = fixture_seed
	request.config["stage_seed_facade"] = facade_seed
	request.config["stage_seed_microvariation"] = microvariation_seed
	return request

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_state(datum/world_edit_building_request/request, datum/world_edit_shape_contract/shape_contract, list/params, list/placement_context)
	var/list/footprint_result = resolve_shape_footprint(shape_contract, request.config, params, placement_context)
	if(footprint_result["error"])
		request.config["layout_candidate_error"] = "[footprint_result["error"]]"
		return null
	var/list/validated = validate_footprint(footprint_result["footprint"], request.config)
	if(validated["error"])
		request.config["layout_candidate_error"] = "[validated["error"]]"
		return null

	var/datum/world_edit_building_layout_state/state = build_building_layout_state(request, shape_contract, placement_context, validated)
	if(!istype(state) || state.has_errors())
		return state
	solve_building_layout(state)
	return state

/datum/world_edit_generator/building_layout/proc/calculate_building_style_metrics(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/list/expected_categories = list()
	var/list/object_budgets = islist(state.semantic_plan?.object_budgets) ? state.semantic_plan.object_budgets : state.archetype?.object_budgets
	if(islist(object_budgets))
		for(var/category as anything in object_budgets)
			if((round(text2num("[object_budgets[category]]") || 0)) > 0)
				expected_categories["[category]"] = TRUE
	if(islist(state.semantic_plan?.category_minimums))
		for(var/category as anything in state.semantic_plan.category_minimums)
			if((round(text2num("[state.semantic_plan.category_minimums[category]]") || 0)) > 0)
				expected_categories["[category]"] = TRUE

	var/covered_categories = 0
	for(var/category as anything in expected_categories)
		if((state.fixtures.category_counts["[category]"] || 0) > 0)
			covered_categories++
	state.validation.category_coverage_score = length(expected_categories) ? round(covered_categories * 100 / length(expected_categories)) : 100

	var/highest_category_count = 0
	for(var/category as anything in state.fixtures.category_counts)
		highest_category_count = max(highest_category_count, round(text2num("[state.fixtures.category_counts[category]]") || 0))
	state.validation.repeat_index = state.fixtures.fixture_count > 0 ? round(highest_category_count * 100 / state.fixtures.fixture_count) : 0

	state.validation.repetition_conflict_count = 0
	var/list/repeat_penalties = islist(state.semantic_plan?.repeat_penalties) ? state.semantic_plan.repeat_penalties : list()
	for(var/category as anything in repeat_penalties)
		var/list/repeat_rule = islist(repeat_penalties[category]) ? repeat_penalties[category] : list()
		var/soft_percent = round(text2num("[repeat_rule["soft_percent"]]") || 55)
		var/category_count = round(text2num("[state.fixtures.category_counts["[category]"]]") || 0)
		if(state.fixtures.fixture_count > 0 && category_count > 0 && round(category_count * 100 / state.fixtures.fixture_count) > soft_percent)
			state.validation.repetition_conflict_count++

	var/list/style_budget = islist(state.semantic_plan?.style_budget) ? state.semantic_plan.style_budget : list()
	var/max_repeat_index = round(text2num("[style_budget["max_repeat_index"]]") || 55)
	var/repeat_penalty = max(0, state.validation.repeat_index - max_repeat_index)
	state.validation.style_score = clamp(state.validation.category_coverage_score - repeat_penalty, 0, 100)
	calculate_building_quality_metrics(state)

/datum/world_edit_generator/building_layout/proc/calculate_building_quality_metrics(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	var/list/style_budget = islist(state.semantic_plan?.style_budget) ? state.semantic_plan.style_budget : list()
	var/list/reachable = get_building_validation_reachable_floor_lookup(state)
	var/reachable_floor = 0
	for(var/turf/floor_turf as anything in state.geometry.floor_turfs)
		if(reachable[floor_turf])
			reachable_floor++
	state.validation.connectivity_score = length(state.geometry.floor_turfs) ? round(reachable_floor * 100 / length(state.geometry.floor_turfs)) : 0

	var/usable_area = max(state.fixtures.usable_fixture_area, length(state.geometry.floor_turfs) - length(state.geometry.primary_route_turfs), 1)
	var/fixture_density = round(state.fixtures.fixture_count * 100 / usable_area)
	var/ideal_density = round(text2num("[style_budget["ideal_fixture_density"]]") || 38)
	var/max_density_delta = max(ideal_density, 1)
	state.validation.fixture_density_score = clamp(100 - round(abs(fixture_density - ideal_density) * 100 / max_density_delta), 0, 100)

	state.validation.visibility_privacy_score = clamp(100 - (state.validation.privacy_violation_count * 18) - (state.validation.window_conflict_count * 10) - (state.validation.facade_conflict_count * 8), 0, 100)
	state.validation.space_distribution_score = clamp(100 - state.validation.empty_floor_ratio + min(length(state.geometry.solved_regions), 8) * 4, 0, 100)

/datum/world_edit_generator/building_layout/proc/build_building_object_placement_hash(list/object_placements)
	var/list/values = list()
	if(islist(object_placements))
		for(var/list/object_placement as anything in object_placements)
			if(!islist(object_placement))
				continue
			var/turf/target_turf = object_placement["turf"]
			if(!istype(target_turf))
				continue
			values += "[object_placement["kind"]]@[target_turf.x],[target_turf.y],[target_turf.z]|[object_placement["obj_path"]]|dir=[object_placement["dir"]]|cluster=[object_placement["cluster_id"]]|signature=[object_placement["signature_id"]]|requirement=[object_placement["requirement_id"]]|pattern=[object_placement["cluster_pattern"]]"
	return build_building_hash_from_strings(values)

/datum/world_edit_generator/building_layout/proc/build_building_door_hash(datum/world_edit_building_layout_state/state)
	var/list/values = list()
	if(istype(state))
		for(var/turf/door_turf as anything in state.geometry.door_turfs)
			if(istype(door_turf))
				values += "[door_turf.x],[door_turf.y],[door_turf.z]|dir=[state.geometry.door_dirs[door_turf] || 0]"
	return build_building_hash_from_strings(values)

/datum/world_edit_generator/building_layout/proc/build_building_room_ownership_hash(datum/world_edit_building_layout_state/state)
	var/list/values = list()
	if(istype(state))
		for(var/turf/room_turf as anything in state.geometry.room_by_turf)
			var/datum/world_edit_building_room/room = state.geometry.room_by_turf[room_turf]
			if(istype(room_turf) && istype(room))
				values += "[room_turf.x],[room_turf.y],[room_turf.z]|room=[room.id]|zone=[room.zone_id]|role=[room.role]"
	return build_building_hash_from_strings(values)

/datum/world_edit_generator/building_layout/proc/get_building_hard_counter_names()
	return list(
		"provider_path_not_in_build_count",
		"unknown_provider_count",
		"required_module_missing_count",
		"required_module_not_placeable_count",
		"required_room_without_required_module_count",
		"loose_table_count",
		"loose_chair_count",
		"unpaired_chair_count",
		"table_chair_mosaic_count",
		"furniture_group_fragmented_count",
		"bed_without_access_count",
		"bed_outside_sleeping_count",
		"toilet_outside_sanitation_count",
		"medical_bed_outside_medical_count",
		"hydro_tray_outside_hydroponics_count",
		"weapon_rack_outside_armory_security_count",
		"module_max_per_room_violation_count",
		"module_max_per_building_violation_count",
		"repeat_group_violation_count",
		"room_overfilled_count",
		"route_blocked_by_furniture_count",
		"door_clearance_blocked_count",
		"scene_required_missing_count",
		"room_primary_scene_missing_count",
		"room_identity_missing_count",
		"room_scene_duplicate_count",
		"scene_slot_overflow_count",
		"common_scene_fragmentation_count",
		"excessive_small_social_groups_count",
		"private_room_without_bed_scene_count",
		"sanitation_without_sanitation_scene_count",
		"storage_without_storage_scene_count",
		"scene_blocks_route_count",
		"large_empty_unassigned_floor_count",
		"oversized_role_room_count",
		"unclaimed_interior_wall_count",
		"wall_outside_footprint_count",
		"wall_orphan_island_count",
		"wall_unmapped_interior_count",
		"wall_single_sided_internal_count",
		"thin_room_strip_count",
		"large_sparse_room_count",
		"corridor_ribbon_count",
		"layout_underfurnished_room_count",
		"layout_room_composition_missing_count",
		"layout_room_capacity_shortfall_count",
		"layout_required_adjacency_missing_count",
		"layout_required_adjacency_geometry_missing_count",
		"layout_unassigned_interior_excess_count",
		"layout_ownerless_open_bay_count",
		"layout_route_component_error_count",
		"layout_wall_stub_count",
		"layout_wall_notch_count",
		"layout_wall_stair_step_count",
		"layout_wall_misaligned_join_count",
		"layout_atomic_module_fragmentation_count",
		"layout_required_module_fallback_count",
		"layout_required_template_reject_count",
		"layout_wall_cleanup_unmapped_count",
		"layout_wall_cleanup_spur_count",
		"layout_functional_room_count_gap",
		"layout_candidate_metric_mismatch_count",
		"layout_required_connection_missing_count",
		"layout_door_not_shared_wall_count",
		"layout_room_without_door_count",
		"layout_forbidden_room_window_count",
		"layout_empty_large_room_count",
		"layout_isolated_room_count",
		"layout_door_corner_count",
		"layout_door_not_on_shared_wall_count",
		"layout_door_no_shared_wall_count",
		"layout_door_short_segment_count",
		"layout_door_near_other_door_count",
		"layout_door_invalid_clearance_count",
		"layout_room_allocation_failed_count",
		"layout_room_bad_aspect_count",
		"layout_room_thin_strip_count",
		"layout_room_scene_capacity_failed_count",
		"layout_scene_required_missing_count",
		"layout_primary_anchor_missing_count",
		"layout_negative_space_missing_count",
		"layout_scene_blocks_negative_space_count",
		"layout_secondary_anchor_conflict_count",
		"layout_scene_overfill_count",
		"layout_scene_underfill_count",
		"layout_scene_budget_overflow_count",
		"layout_scene_budget_missing_required_count",
		"layout_duplicate_focal_scene_count",
		"layout_window_policy_violation_count",
		"layout_public_room_hard_closed_count",
		"layout_public_opening_missing_count",
		"layout_corridor_wall_canyon_count",
		"layout_hard_valid_candidate_shortage_count",
		"semantic_scene_route_block_count",
		"semantic_scene_door_clearance_block_count",
		"semantic_scene_required_missing_count",
		"semantic_room_primary_scene_missing_count",
		"semantic_major_object_without_scene_count",
		"semantic_pairing_error_count",
		"legacy_fixture_after_scene_count",
		"mandatory_room_missing_count",
		"mandatory_room_no_bounds_count",
		"mandatory_room_no_access_count",
		"mandatory_pattern_missing_count",
		"mandatory_pattern_uncredited_count",
		"mandatory_pattern_failure_count",
		"mandatory_room_patch_fallback_count",
		"fallback_anchor_required_cluster_count",
		"style_required_slot_missing_count",
		"semantic_credit_without_emitted_slots_count",
		"raw_category_credit_count",
		"scatter_signature_credit_count",
		"reserved_walk_blocked_count",
		"door_cone_blocked_count",
		"door_corner_count",
		"mandatory_fixture_access_unreachable_count",
		"double_wall_error_count",
		"diagonal_only_contact_count",
		"unsupported_shape_silent_fallback_count",
		"cutout_violation_count",
		"invalid_window_count",
		"service_wall_window_violation_count",
		"secure_wall_window_violation_count",
		"blocked_turf_conflict_count",
		"blocked_route_conflict_count",
		"blocked_room_conflict_count",
		"blocked_wall_conflict_count",
		"blocked_fixture_conflict_count",
		"replace_blocked_turf_count",
		"counter_wrong_facing_count",
		"entry_face_mismatch_count",
		"emit_missing_path_count",
		"emit_failed_object_count",
		"emit_state_mismatch_count",
		"post_emit_validation_error_count",
	)

/datum/world_edit_generator/building_layout/proc/get_building_state_hard_counter(datum/world_edit_building_layout_state/state, counter_name)
	if(!istype(state))
		return 0
	switch("[counter_name]")
		if("provider_path_not_in_build_count") return state.validation.provider_path_not_in_build_count
		if("unknown_provider_count") return state.validation.unknown_provider_count
		if("required_module_missing_count") return state.validation.required_module_missing_count
		if("required_module_not_placeable_count") return state.validation.required_module_not_placeable_count
		if("required_room_without_required_module_count") return state.validation.required_room_without_required_module_count
		if("loose_table_count") return state.validation.loose_table_count
		if("loose_chair_count") return state.validation.loose_chair_count
		if("unpaired_chair_count") return state.validation.unpaired_chair_count
		if("table_chair_mosaic_count") return state.validation.table_chair_mosaic_count
		if("furniture_group_fragmented_count") return state.validation.furniture_group_fragmented_count
		if("bed_without_access_count") return state.validation.bed_without_access_count
		if("bed_outside_sleeping_count") return state.validation.bed_outside_sleeping_count
		if("toilet_outside_sanitation_count") return state.validation.toilet_outside_sanitation_count
		if("medical_bed_outside_medical_count") return state.validation.medical_bed_outside_medical_count
		if("hydro_tray_outside_hydroponics_count") return state.validation.hydro_tray_outside_hydroponics_count
		if("weapon_rack_outside_armory_security_count") return state.validation.weapon_rack_outside_armory_security_count
		if("module_max_per_room_violation_count") return state.validation.module_max_per_room_violation_count
		if("module_max_per_building_violation_count") return state.validation.module_max_per_building_violation_count
		if("repeat_group_violation_count") return state.validation.repeat_group_violation_count
		if("room_overfilled_count") return state.validation.room_overfilled_count
		if("route_blocked_by_furniture_count") return state.validation.route_blocked_by_furniture_count
		if("door_clearance_blocked_count") return state.validation.door_clearance_blocked_count
		if("scene_required_missing_count") return state.validation.scene_required_missing_count
		if("room_primary_scene_missing_count") return state.validation.room_primary_scene_missing_count
		if("room_identity_missing_count") return state.validation.room_identity_missing_count
		if("room_scene_duplicate_count") return state.validation.room_scene_duplicate_count
		if("scene_slot_overflow_count") return state.validation.scene_slot_overflow_count
		if("common_scene_fragmentation_count") return state.validation.common_scene_fragmentation_count
		if("excessive_small_social_groups_count") return state.validation.excessive_small_social_groups_count
		if("private_room_without_bed_scene_count") return state.validation.private_room_without_bed_scene_count
		if("sanitation_without_sanitation_scene_count") return state.validation.sanitation_without_sanitation_scene_count
		if("storage_without_storage_scene_count") return state.validation.storage_without_storage_scene_count
		if("scene_blocks_route_count") return state.validation.scene_blocks_route_count
		if("large_empty_unassigned_floor_count") return state.validation.large_empty_unassigned_floor_count
		if("oversized_role_room_count") return state.validation.oversized_role_room_count
		if("unclaimed_interior_wall_count") return state.validation.unclaimed_interior_wall_count
		if("wall_outside_footprint_count") return state.validation.wall_outside_footprint_count
		if("wall_orphan_island_count") return state.validation.wall_orphan_island_count
		if("wall_unmapped_interior_count") return state.validation.wall_unmapped_interior_count
		if("wall_single_sided_internal_count") return state.validation.wall_single_sided_internal_count
		if("thin_room_strip_count") return state.validation.thin_room_strip_count
		if("large_sparse_room_count") return state.validation.large_sparse_room_count
		if("corridor_ribbon_count") return state.validation.corridor_ribbon_count
		if("layout_underfurnished_room_count") return state.validation.layout_underfurnished_room_count
		if("layout_room_composition_missing_count") return state.validation.layout_room_composition_missing_count
		if("layout_room_capacity_shortfall_count") return state.validation.layout_room_capacity_shortfall_count
		if("layout_required_adjacency_missing_count") return state.validation.layout_required_adjacency_missing_count
		if("layout_required_adjacency_geometry_missing_count") return state.validation.layout_required_adjacency_geometry_missing_count
		if("layout_unassigned_interior_excess_count") return state.validation.layout_unassigned_interior_excess_count
		if("layout_ownerless_open_bay_count") return state.validation.layout_ownerless_open_bay_count
		if("layout_route_component_error_count") return state.validation.layout_route_component_error_count
		if("layout_wall_stub_count") return state.validation.layout_wall_stub_count
		if("layout_wall_notch_count") return state.validation.layout_wall_notch_count
		if("layout_wall_stair_step_count") return state.validation.layout_wall_stair_step_count
		if("layout_wall_misaligned_join_count") return state.validation.layout_wall_misaligned_join_count
		if("layout_atomic_module_fragmentation_count") return state.validation.layout_atomic_module_fragmentation_count
		if("layout_required_module_fallback_count") return state.validation.layout_required_module_fallback_count
		if("layout_required_template_reject_count") return state.validation.layout_required_template_reject_count
		if("layout_wall_cleanup_unmapped_count") return state.validation.layout_wall_cleanup_unmapped_count
		if("layout_wall_cleanup_spur_count") return state.validation.layout_wall_cleanup_spur_count
		if("layout_functional_room_count_gap") return state.validation.layout_functional_room_count_gap
		if("layout_candidate_metric_mismatch_count") return state.validation.layout_candidate_metric_mismatch_count
		if("layout_required_connection_missing_count") return state.validation.layout_required_connection_missing_count
		if("layout_door_not_shared_wall_count") return state.validation.layout_door_not_shared_wall_count
		if("layout_room_without_door_count") return state.validation.layout_room_without_door_count
		if("layout_forbidden_room_window_count") return state.validation.layout_forbidden_room_window_count
		if("layout_empty_large_room_count") return state.validation.layout_empty_large_room_count
		if("layout_isolated_room_count") return state.validation.layout_isolated_room_count
		if("layout_door_corner_count") return state.validation.layout_door_corner_count
		if("layout_door_not_on_shared_wall_count") return state.validation.layout_door_not_on_shared_wall_count
		if("layout_door_no_shared_wall_count") return state.validation.layout_door_no_shared_wall_count
		if("layout_door_short_segment_count") return state.validation.layout_door_short_segment_count
		if("layout_door_near_other_door_count") return state.validation.layout_door_near_other_door_count
		if("layout_door_invalid_clearance_count") return state.validation.layout_door_invalid_clearance_count
		if("layout_room_allocation_failed_count") return state.validation.layout_room_allocation_failed_count
		if("layout_room_bad_aspect_count") return state.validation.layout_room_bad_aspect_count
		if("layout_room_thin_strip_count") return state.validation.layout_room_thin_strip_count
		if("layout_room_scene_capacity_failed_count") return state.validation.layout_room_scene_capacity_failed_count
		if("layout_scene_required_missing_count") return state.validation.layout_scene_required_missing_count
		if("layout_primary_anchor_missing_count") return state.validation.layout_primary_anchor_missing_count
		if("layout_negative_space_missing_count") return state.validation.layout_negative_space_missing_count
		if("layout_scene_blocks_negative_space_count") return state.validation.layout_scene_blocks_negative_space_count
		if("layout_secondary_anchor_conflict_count") return state.validation.layout_secondary_anchor_conflict_count
		if("layout_scene_overfill_count") return state.validation.layout_scene_overfill_count
		if("layout_scene_underfill_count") return state.validation.layout_scene_underfill_count
		if("layout_scene_budget_overflow_count") return state.validation.layout_scene_budget_overflow_count
		if("layout_scene_budget_missing_required_count") return state.validation.layout_scene_budget_missing_required_count
		if("layout_duplicate_focal_scene_count") return state.validation.layout_duplicate_focal_scene_count
		if("layout_window_policy_violation_count") return state.validation.layout_window_policy_violation_count
		if("layout_public_room_hard_closed_count") return state.validation.layout_public_room_hard_closed_count
		if("layout_public_opening_missing_count") return state.validation.layout_public_opening_missing_count
		if("layout_opposing_route_door_pair_count") return state.validation.layout_opposing_route_door_pair_count
		if("layout_corridor_wall_canyon_count") return state.validation.layout_corridor_wall_canyon_count
		if("layout_route_wall_canyon_length") return state.validation.layout_route_wall_canyon_length
		if("layout_excessive_wall_to_floor_ratio_count") return state.validation.layout_excessive_wall_to_floor_ratio_count
		if("layout_template_geometry_reject_count") return state.validation.layout_template_geometry_reject_count
		if("layout_missing_wall_context_reject_count") return state.validation.layout_missing_wall_context_reject_count
		if("layout_hard_valid_candidate_shortage_count") return state.validation.layout_hard_valid_candidate_shortage_count
		if("semantic_scene_route_block_count") return state.validation.semantic_scene_route_block_count
		if("semantic_scene_door_clearance_block_count") return state.validation.semantic_scene_door_clearance_block_count
		if("semantic_scene_required_missing_count") return state.validation.semantic_scene_required_missing_count
		if("semantic_room_primary_scene_missing_count") return state.validation.semantic_room_primary_scene_missing_count
		if("semantic_major_object_without_scene_count") return state.validation.semantic_major_object_without_scene_count
		if("semantic_pairing_error_count") return state.validation.semantic_pairing_error_count
		if("legacy_fixture_after_scene_count") return state.validation.legacy_fixture_after_scene_count
		if("mandatory_room_missing_count") return state.validation.mandatory_room_missing_count
		if("mandatory_room_no_bounds_count") return state.validation.mandatory_room_no_bounds_count
		if("mandatory_room_no_access_count") return state.validation.mandatory_room_no_access_count
		if("mandatory_pattern_missing_count") return state.validation.mandatory_pattern_missing_count
		if("mandatory_pattern_uncredited_count") return state.validation.mandatory_pattern_uncredited_count
		if("mandatory_pattern_failure_count") return state.validation.mandatory_pattern_failure_count
		if("mandatory_room_patch_fallback_count") return state.validation.mandatory_room_patch_fallback_count
		if("fallback_anchor_required_cluster_count") return state.validation.fallback_anchor_required_cluster_count
		if("style_required_slot_missing_count") return state.validation.style_required_slot_missing_count
		if("semantic_credit_without_emitted_slots_count") return state.validation.semantic_credit_without_emitted_slots_count
		if("raw_category_credit_count") return state.validation.raw_category_credit_count
		if("scatter_signature_credit_count") return state.validation.scatter_signature_credit_count
		if("reserved_walk_blocked_count") return state.validation.reserved_walk_blocked_count
		if("door_cone_blocked_count") return state.validation.door_cone_blocked_count
		if("door_corner_count") return state.validation.door_corner_count
		if("mandatory_fixture_access_unreachable_count") return state.validation.mandatory_fixture_access_unreachable_count
		if("double_wall_error_count") return state.validation.double_wall_error_count
		if("diagonal_only_contact_count") return state.validation.diagonal_only_contact_count
		if("unsupported_shape_silent_fallback_count") return state.validation.unsupported_shape_silent_fallback_count
		if("cutout_violation_count") return state.validation.cutout_violation_count
		if("invalid_window_count") return state.validation.invalid_window_count
		if("service_wall_window_violation_count") return state.validation.service_wall_window_violation_count
		if("secure_wall_window_violation_count") return state.validation.secure_wall_window_violation_count
		if("blocked_turf_conflict_count") return state.validation.blocked_turf_conflict_count
		if("blocked_route_conflict_count") return state.validation.blocked_route_conflict_count
		if("blocked_room_conflict_count") return state.validation.blocked_room_conflict_count
		if("blocked_wall_conflict_count") return state.validation.blocked_wall_conflict_count
		if("blocked_fixture_conflict_count") return state.validation.blocked_fixture_conflict_count
		if("replace_blocked_turf_count") return state.validation.replace_blocked_turf_count
		if("route_access_repair_count") return state.validation.route_access_repair_count
		if("counter_wrong_facing_count") return state.validation.counter_wrong_facing_count
		if("entry_face_mismatch_count") return state.validation.entry_face_mismatch_count
		if("emit_missing_path_count") return state.validation.emit_missing_path_count
		if("emit_failed_object_count") return state.validation.emit_failed_object_count
		if("emit_state_mismatch_count") return state.validation.emit_state_mismatch_count
		if("post_emit_validation_error_count") return state.validation.post_emit_validation_error_count
	return 0

/datum/world_edit_generator/building_layout/proc/building_state_has_hard_counter_failures(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return TRUE
	for(var/counter_name as anything in get_building_hard_counter_names())
		if(get_building_state_hard_counter(state, counter_name) > 0)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/build_building_state_hard_counter_report(datum/world_edit_building_layout_state/state)
	var/list/report = list()
	for(var/counter_name as anything in get_building_hard_counter_names())
		report["[counter_name]"] = get_building_state_hard_counter(state, counter_name)
	return report

/datum/world_edit_generator/building_layout/proc/build_building_generation_validation_verdict(datum/world_edit_building_layout_state/state)
	var/list/hard_counters = build_building_state_hard_counter_report(state)
	var/hard_counter_failure_count = 0
	for(var/counter_name as anything in hard_counters)
		var/counter_value = round(text2num("[hard_counters[counter_name]]") || 0)
		if(counter_value > 0)
			hard_counter_failure_count++
	var/error_count = istype(state) ? length(state.validation.errors) : 1
	var/verdict_status = (!error_count && !hard_counter_failure_count) ? WORLD_EDIT_BUILDING_GENERATION_VALID_PLAN : WORLD_EDIT_BUILDING_GENERATION_VALIDATION_FAILED
	if(!istype(state))
		verdict_status = WORLD_EDIT_BUILDING_GENERATION_INTERNAL_ERROR
	var/datum/world_edit_validation_verdict/verdict = new(verdict_status, WORLD_EDIT_BUILDING_STAGE_CANDIDATE_VALIDATION)
	verdict.set_metric("error_count", error_count)
	verdict.set_metric("hard_counter_failure_count", hard_counter_failure_count)
	for(var/counter_name as anything in hard_counters)
		verdict.set_metric(counter_name, hard_counters[counter_name])
	if(!istype(state))
		verdict.add_hard_error("generation.state_unavailable", "Building layout state is unavailable.")
		return verdict
	verdict.set_metric("program_id", "[state.archetype?.id || ""]")
	verdict.set_metric("style_id", "[state.config["faction_preset"] || ""]")
	verdict.set_metric("shape_id", "[state.config["placement_shape_id"] || ""]")
	verdict.set_metric("layout_candidate_score", state.config["layout_candidate_score"] || state.validation.layout_candidate_score)
	verdict.set_metric("layout_candidate_index", state.config["layout_candidate_index"] || 1)
	verdict.set_metric("layout_enabled", state.config["layout_enabled"] ? TRUE : FALSE)
	verdict.set_metric("layout_pattern_id", "[state.config["layout_pattern_id"] || ""]")
	verdict.set_metric("layout_candidate_id", "[state.config["layout_candidate_id"] || ""]")
	verdict.set_metric("layout_candidate_count", state.config["layout_candidate_count"] || 0)
	verdict.set_metric("layout_hard_valid_candidate_count", state.config["layout_hard_valid_candidate_count"] || 0)
	verdict.set_metric("layout_scene_count", state.config["layout_scene_count"] || 0)
	verdict.set_metric("layout_functional_room_count", state.validation.layout_functional_room_count)
	verdict.set_metric("layout_target_functional_room_count", state.validation.layout_target_functional_room_count)
	verdict.set_metric("layout_functional_room_count_gap", state.validation.layout_functional_room_count_gap)
	verdict.set_metric("layout_circulation_region_count", state.validation.layout_circulation_region_count)
	verdict.set_metric("layout_wall_cleanup_removed_count", state.validation.layout_wall_cleanup_removed_count)
	verdict.set_metric("layout_wall_cleanup_ratio_percent", state.validation.layout_wall_cleanup_ratio_percent)
	verdict.set_metric("layout_optional_template_attempt_count", state.validation.layout_optional_template_attempt_count)
	verdict.set_metric("layout_optional_template_reject_count", state.validation.layout_optional_template_reject_count)
	verdict.set_metric("layout_template_reject_ratio_percent", state.validation.layout_template_reject_ratio_percent)
	verdict.set_metric("layout_distinct_hard_valid_family_count", state.validation.layout_distinct_hard_valid_family_count)
	verdict.set_metric("structural_topology_signature_count", state.config["structural_topology_signature_count"] || state.validation.layout_distinct_hard_valid_family_count)
	verdict.set_metric("semantic_distribution_noise_score", state.validation.semantic_distribution_noise_score)
	verdict.set_metric("semantic_functional_coverage_percent", state.validation.semantic_functional_coverage_percent)
	verdict.set_metric("semantic_route_clearance_percent", state.validation.semantic_route_clearance_percent)
	verdict.set_metric("structured_scene_owner", "[state.fixtures.structured_scene_owner || ""]")
	verdict.set_metric("structured_scene_count", state.fixtures.structured_scene_count)
	verdict.set_metric("structured_primary_scene_count", state.fixtures.structured_primary_scene_count)
	verdict.set_metric("semantic_interiors_scene_count", state.fixtures.semantic_interiors_scene_count)
	verdict.set_metric("semantic_interiors_primary_scene_count", state.fixtures.semantic_interiors_primary_scene_count)
	verdict.set_metric("footprint_family", "[state.config["footprint_family"] || ""]")
	verdict.set_metric("room_count", length(state.geometry.solved_rooms))
	verdict.set_metric("target_room_count", state.config["target_room_count"] || state.validation.requested_room_count)
	verdict.set_metric("room_count_satisfied", !round(text2num("[state.config["target_room_count"]]") || 0) || length(state.geometry.solved_rooms) >= round(text2num("[state.config["target_room_count"]]") || 0))
	verdict.set_metric("support_status", "[state.validation.current_request_support_status || ""]")
	verdict.set_metric("unique_provider_path_count", state.validation.unique_provider_path_count)
	verdict.set_metric("unique_functional_provider_path_count", state.validation.unique_functional_provider_path_count)
	verdict.set_metric("unique_decorative_provider_path_count", state.validation.unique_decorative_provider_path_count)
	for(var/error_message as anything in state.validation.errors)
		verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_HARD_VALIDATION_FAILED, "[error_message]")
	for(var/counter_name as anything in hard_counters)
		var/counter_value = round(text2num("[hard_counters[counter_name]]") || 0)
		if(counter_value > 0)
			verdict.add_hard_error("[counter_name]", "Hard validation counter [counter_name] is nonzero.", list("count" = counter_value))
	return verdict

/datum/world_edit_generator/building_layout/proc/build_building_apply_validation_verdict(status, message = null, list/failures = null, list/metrics = null)
	var/resolved_status = length("[status]") ? "[status]" : WORLD_EDIT_BUILDING_APPLY_FAILED
	var/datum/world_edit_validation_verdict/verdict = new(resolved_status, WORLD_EDIT_BUILDING_STAGE_APPLY)
	if(islist(metrics))
		for(var/metric_id as anything in metrics)
			verdict.set_metric(metric_id, metrics[metric_id])
	if(length("[message]"))
		verdict.set_metric("message", "[message]")
	if(islist(failures))
		verdict.set_metric("failure_count", length(failures))
		for(var/failure as anything in failures)
			verdict.add_hard_error("[failure]", "[failure]")
	if(resolved_status != WORLD_EDIT_BUILDING_APPLY_APPLIED && !verdict.has_hard_errors())
		var/error_code = resolved_status == WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT ? WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT : WORLD_EDIT_BUILDING_APPLY_FAILED
		verdict.add_hard_error(error_code, length("[message]") ? "[message]" : "Building apply failed.")
	return verdict

/datum/world_edit_generator/building_layout/proc/stamp_building_apply_validation_verdict(datum/world_edit_apply_result/result, status, message = null, list/failures = null, list/metrics = null)
	if(!istype(result))
		return null
	if(!islist(result.meta))
		result.meta = list()
	var/datum/world_edit_validation_verdict/verdict = build_building_apply_validation_verdict(status, message, failures, metrics)
	result.meta["apply_validation_verdict"] = verdict.as_payload()
	result.meta["apply_status"] = verdict.status
	result.meta["apply_hard_error_count"] = length(verdict.hard_errors)
	return verdict

/datum/world_edit_generator/building_layout/proc/score_building_layout_candidate(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return -999999999
	var/score = 0
	var/error_count = length(state.validation.errors)
	if(!error_count)
		score += 50000
	else
		score -= error_count * 20000
	score += state.validation.signature_score * 120
	score += state.validation.style_score * 45
	score += state.validation.connectivity_score * 35
	score += state.validation.fixture_density_score * 20
	score += state.validation.visibility_privacy_score * 25
	score += state.validation.space_distribution_score * 15
	if(state.validation.signature_max_score > 0 && state.validation.signature_score >= state.semantic_plan?.min_signature_score)
		score += 2500
	score += min(length(state.geometry.internal_wall_turfs), 32) * 90
	score += length(state.geometry.solved_regions) * 120
	score += min(state.validation.region_claim_count, 80) * 45
	score += min(state.validation.rectangular_region_candidate_count, 80) * 22
	score += state.validation.nested_room_count * 800
	score += state.fixtures.template_chunk_count * 650
	score += state.fixtures.infrastructure_count * 220
	score += min(state.validation.semantic_slot_capacity_count, 80) * 35
	score += min(state.validation.microvariation_count, 24) * 20
	score += round(text2num("[state.config["footprint_mask_score"]]") || 0)
	score += length(state.geometry.primary_route_turfs) * 15
	score -= state.validation.empty_floor_ratio * 35
	if(state.validation.repeat_index > 75)
		score -= (state.validation.repeat_index - 75) * 80
	score -= state.validation.privacy_violation_count * 1800
	score -= state.validation.reachability_failure_count * 1400
	score -= state.validation.repetition_conflict_count * 500
	score -= state.validation.degraded_region_fallback_count * 2500
	score -= state.validation.semantic_slot_shortage_count * 18000
	score -= state.validation.semantic_slot_fallback_count * 3500
	score -= state.validation.semantic_slot_reservation_conflict_count * 12000
	score -= (state.validation.fixture_conflict_count + state.validation.route_conflict_count + state.validation.window_conflict_count + state.validation.facade_conflict_count) * 900
	if(state.validation.empty_floor_ratio <= 60)
		score += 800
	var/list/major_specs = state.semantic_plan?.get_cluster_specs("major")
	if(islist(major_specs) && state.fixtures.major_fixture_count >= length(major_specs))
		score += 1000
	return score

/datum/world_edit_generator/building_layout/proc/build_building_layout_candidate_report(datum/world_edit_building_layout_state/state, footprint_family, attempt_index, score_override = null, error_message = null, detailed = FALSE)
	var/list/report = list(
		"attempt" = attempt_index,
		"family" = uppertext("[footprint_family]"),
		"score" = isnull(score_override) && istype(state) ? state.validation.layout_candidate_score : score_override,
		"detailed" = detailed ? TRUE : FALSE,
	)
	if(istype(state))
		var/datum/world_edit_building_layout_context/layout_context = state.layout_context
		report["current_request_support_status"] = state.validation.current_request_support_status
		report["user_facing_failure_reason"] = state.validation.user_facing_failure_reason
		report["support_status_report"] = detailed ? state.validation.support_status_report.Copy() : list(
			"status" = state.validation.current_request_support_status,
			"reason" = state.validation.user_facing_failure_reason,
			"program_id" = state.archetype?.id,
			"shape_id" = state.config["placement_shape_id"],
			"style_id" = state.config["faction_preset"],
		)
		if(detailed)
			report["stage_reports"] = state.validation.stage_reports.Copy()
			report["errors"] = state.validation.errors.Copy()
		else
			report["stage_report_count"] = length(state.validation.stage_reports)
			report["errors"] = length(state.validation.errors) ? list(state.validation.errors[1]) : list()
		report["error_count"] = length(state.validation.errors)
		report["signature_score"] = state.validation.signature_score
		report["style_score"] = state.validation.style_score
		report["category_coverage_score"] = state.validation.category_coverage_score
		report["repeat_index"] = state.validation.repeat_index
		report["privacy_violation_count"] = state.validation.privacy_violation_count
		report["reachability_failure_count"] = state.validation.reachability_failure_count
		report["repetition_conflict_count"] = state.validation.repetition_conflict_count
		report["fixture_density_score"] = state.validation.fixture_density_score
		report["connectivity_score"] = state.validation.connectivity_score
		report["visibility_privacy_score"] = state.validation.visibility_privacy_score
		report["space_distribution_score"] = state.validation.space_distribution_score
		report["empty_floor_ratio"] = state.validation.empty_floor_ratio
		report["partition_segment_count"] = length(layout_context?.selected_candidate?.partition_segments)
		report["internal_wall_count"] = length(state.geometry.internal_wall_turfs)
		report["room_count"] = length(state.geometry.solved_rooms)
		report["corridor_turf_count"] = length(state.geometry.corridor_turfs)
		report["semantic_region_claim_count"] = state.validation.region_claim_count
		if(detailed)
			report["semantic_region_claim_reports"] = state.validation.region_claim_reports.Copy()
		else
			report["semantic_region_claim_report_count"] = length(state.validation.region_claim_reports)
		report["rectangular_region_candidate_count"] = state.validation.rectangular_region_candidate_count
		report["nested_room_count"] = state.validation.nested_room_count
		report["template_chunk_count"] = state.fixtures.template_chunk_count
		report["template_chunk_cell_count"] = state.fixtures.template_chunk_cell_count
		report["infrastructure_count"] = state.fixtures.infrastructure_count
		report["semantic_slot_capacity_count"] = state.validation.semantic_slot_capacity_count
		report["semantic_slot_shortage_count"] = state.validation.semantic_slot_shortage_count
		report["semantic_slot_fallback_count"] = state.validation.semantic_slot_fallback_count
		report["template_reject_reason_counts"] = state.validation.template_reject_reason_counts.Copy()
		if(detailed)
			report["semantic_slot_reports"] = state.validation.semantic_slot_reports.Copy()
			report["placed_requirement_counts"] = state.fixtures.placed_requirement_counts.Copy()
			report["semantic_requirement_counts"] = state.fixtures.semantic_requirement_counts.Copy()
			report["semantic_requirement_minimums"] = state.fixtures.semantic_requirement_minimums.Copy()
			report["pattern_reports"] = state.validation.pattern_reports.Copy()
			report["template_reject_reports"] = state.validation.template_reject_reports.Copy()
			report["template_cluster_reports"] = state.validation.template_cluster_reports.Copy()
		else
			report["semantic_slot_report_count"] = length(state.validation.semantic_slot_reports)
			report["semantic_requirement_count"] = length(state.fixtures.semantic_requirement_counts)
			report["pattern_report_count"] = length(state.validation.pattern_reports)
			report["template_reject_report_count"] = length(state.validation.template_reject_reports)
			report["template_cluster_report_count"] = length(state.validation.template_cluster_reports)
		report["semantic_slot_reservation_count"] = length(state.fixtures.semantic_slot_reservation_by_turf)
		report["semantic_slot_reservation_conflict_count"] = state.validation.semantic_slot_reservation_conflict_count
		report["mandatory_room_count"] = state.validation.mandatory_room_count
		report["mandatory_zone_count"] = state.validation.mandatory_zone_count
		report["forbidden_fallback_count"] = state.validation.forbidden_fallback_count
		var/list/failed_trial_hard_counters = state.config["layout_failed_trial_hard_counters"]
		var/list/hard_counters = islist(failed_trial_hard_counters) && length(failed_trial_hard_counters) ? failed_trial_hard_counters.Copy() : build_building_state_hard_counter_report(state)
		report["hard_counters"] = hard_counters
		for(var/counter_name as anything in hard_counters)
			report[counter_name] = hard_counters[counter_name]
		report["layout_public_room_hard_closed_count"] = state.validation.layout_public_room_hard_closed_count
		report["layout_public_opening_missing_count"] = state.validation.layout_public_opening_missing_count
		report["layout_opposing_route_door_pair_count"] = state.validation.layout_opposing_route_door_pair_count
		report["layout_corridor_wall_canyon_count"] = state.validation.layout_corridor_wall_canyon_count
		report["layout_route_wall_canyon_length"] = state.validation.layout_route_wall_canyon_length
		report["layout_excessive_wall_to_floor_ratio_count"] = state.validation.layout_excessive_wall_to_floor_ratio_count
		report["layout_template_geometry_reject_count"] = state.validation.layout_template_geometry_reject_count
		report["layout_missing_wall_context_reject_count"] = state.validation.layout_missing_wall_context_reject_count
		report["layout_hard_valid_candidate_shortage_count"] = state.validation.layout_hard_valid_candidate_shortage_count
		for(var/counter_name as anything in hard_counters)
			report[counter_name] = hard_counters[counter_name]
		report["semantic_distribution_noise_score"] = state.validation.semantic_distribution_noise_score
		report["semantic_functional_coverage_percent"] = state.validation.semantic_functional_coverage_percent
		report["semantic_route_clearance_percent"] = state.validation.semantic_route_clearance_percent
		report["structured_scene_owner"] = state.fixtures.structured_scene_owner
		report["structured_scene_count"] = state.fixtures.structured_scene_count
		report["structured_primary_scene_count"] = state.fixtures.structured_primary_scene_count
		report["semantic_interiors_scene_count"] = state.fixtures.semantic_interiors_scene_count
		report["semantic_interiors_primary_scene_count"] = state.fixtures.semantic_interiors_primary_scene_count
		var/list/failed_trial_validation_verdict = state.config["layout_failed_trial_validation_verdict"]
		if(islist(failed_trial_validation_verdict) && length(failed_trial_validation_verdict))
			report["generation_validation_verdict"] = failed_trial_validation_verdict.Copy()
		else
			var/datum/world_edit_validation_verdict/validation_verdict = build_building_generation_validation_verdict(state)
			report["generation_validation_verdict"] = validation_verdict.as_payload()
		report["validation_verdict"] = report["generation_validation_verdict"]
		report["requested_direction"] = state.geometry.requested_direction
		report["actual_entry_direction"] = state.geometry.actual_entry_direction
		report["direction_honored"] = state.geometry.actual_entry_direction == state.geometry.requested_direction
		report["direction_fallback_reason"] = state.geometry.direction_fallback_reason
		report["footprint_hash"] = state.geometry.footprint_hash
		report["room_graph_hash"] = state.geometry.room_graph_hash
		report["route_hash"] = state.geometry.route_hash
		report["wall_hash"] = state.geometry.wall_hash
		report["structural_topology_signature"] = state.geometry.structural_topology_signature
		report["geometry_layout_hash"] = state.geometry.geometry_layout_hash
		report["pattern_credit_hash"] = state.fixtures.pattern_credit_hash
		report["layout_hash"] = state.geometry.layout_hash
		report["degraded_region_fallback_count"] = state.validation.degraded_region_fallback_count
		if(detailed)
			report["degraded_region_reports"] = state.validation.degraded_region_reports.Copy()
		else
			report["degraded_region_report_count"] = length(state.validation.degraded_region_reports)
		report["microvariation_count"] = state.validation.microvariation_count
		report["footprint_mask_score"] = state.config["footprint_mask_score"]
		report["footprint_mask_candidate_count"] = state.config["footprint_mask_candidate_count"]
		report["major_fixture_count"] = state.fixtures.major_fixture_count
		report["footprint_count"] = length(state.geometry.footprint)
		report["half_width"] = state.config["half_width"]
		report["half_depth"] = state.config["half_depth"]
		report["size_candidate_index"] = state.config["size_candidate_index"]
	else
		report["errors"] = list("[error_message]")
		report["error_count"] = 1
	return report

/datum/world_edit_generator/building_layout/proc/select_best_building_layout_candidate_report(list/candidate_reports)
	if(!islist(candidate_reports) || !length(candidate_reports))
		return null
	var/list/best_report = null
	var/best_score = -999999999
	for(var/list/report as anything in candidate_reports)
		if(!islist(report))
			continue
		var/score = round(text2num("[report["score"]]") || -999999999)
		if(!islist(best_report) || score > best_score)
			best_report = report
			best_score = score
	if(!islist(best_report))
		return null
	return best_report.Copy()

/datum/world_edit_generator/building_layout/proc/add_building_point_size_candidate(list/candidates, list/seen, index, half_width, half_depth)
	if(!islist(candidates) || !islist(seen))
		return index
	half_width = clamp(round(text2num("[half_width]") || 4), 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	half_depth = clamp(round(text2num("[half_depth]") || 4), 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	var/key = "[half_width]x[half_depth]"
	if(seen[key])
		return index
	seen[key] = TRUE
	index++
	candidates += list(list(
		"index" = index,
		"half_width" = half_width,
		"half_depth" = half_depth,
	))
	return index

/datum/world_edit_generator/building_layout/proc/get_building_point_size_candidate_specs(list/config)
	var/list/candidates = list()
	if(!islist(config))
		return candidates
	var/start_half_width = clamp(round(text2num("[config["half_width"]]") || 4), 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	var/start_half_depth = clamp(round(text2num("[config["half_depth"]]") || 4), 1, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	if(!GLOB.world_edit_helpers.parse_bool(config["auto_size"]))
		candidates += list(list(
			"index" = 1,
			"half_width" = start_half_width,
			"half_depth" = start_half_depth,
			"explicit_size" = TRUE,
		))
		return candidates
	var/index = 0
	var/list/seen = list()
	index = add_building_point_size_candidate(candidates, seen, index, start_half_width, start_half_depth)
	for(var/delta in 1 to 3)
		if(length(candidates) >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
			break
		index = add_building_point_size_candidate(candidates, seen, index, start_half_width + delta, start_half_depth)
		if(length(candidates) >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
			break
		index = add_building_point_size_candidate(candidates, seen, index, start_half_width, start_half_depth + delta)
		if(length(candidates) >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
			break
		index = add_building_point_size_candidate(candidates, seen, index, start_half_width + delta, start_half_depth + delta)
	if(length(candidates) < WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
		index = add_building_point_size_candidate(candidates, seen, index, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT, WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT)
	if(!length(candidates))
		candidates += list(list(
			"index" = 1,
			"half_width" = start_half_width,
			"half_depth" = start_half_depth,
		))
	return candidates

/datum/world_edit_generator/building_layout/proc/build_building_feasibility_dry_solve_result(shape_id, list/config, list/placement_context)
	var/list/result = list(
		"status" = "not_run",
		"stage" = WORLD_EDIT_BUILDING_STAGE_FEASIBILITY,
		"reason" = "",
		"candidate_attempt_count" = 0,
		"valid_candidate_count" = 0,
		"error_candidate_count" = 0,
	)
	if(!islist(config))
		result["status"] = "failed"
		result["reason"] = "Building request config is unavailable."
		return result
	if(!islist(placement_context))
		result["status"] = "not_run_no_context"
		result["reason"] = "No placement context was available for feasibility dry solve."
		return result

	var/list/dry_params = config.Copy()
	dry_params["skip_feasibility_dry_solve"] = TRUE
	dry_params["debug_reports"] = FALSE
	var/cache_key = build_building_feasibility_cache_key(shape_id, config, placement_context)
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract_from_placement_context(shape_id, placement_context["anchor_turfs"], placement_context)
	var/datum/world_edit_building_request/request = build_building_request(dry_params, shape_contract, placement_context)
	if(!istype(request) || request.config["error"])
		var/request_error = istype(request) && islist(request.config) ? request.config["error"] : null
		result["status"] = "failed"
		result["reason"] = "[request_error || "Unable to build feasibility request."]"
		return result

	var/resolved_shape_id = "[shape_contract?.shape_id || shape_id || WORLD_EDIT_SHAPE_POINT]"
	var/list/ordered_candidate_families = (resolved_shape_id == WORLD_EDIT_SHAPE_POINT) ? get_ordered_building_footprint_candidate_families(request.config) : list(uppertext("[resolved_shape_id]"))
	var/list/candidate_families = length(ordered_candidate_families) ? list(ordered_candidate_families[1]) : list("RECT")
	var/list/size_candidates = resolved_shape_id == WORLD_EDIT_SHAPE_POINT ? get_building_point_size_candidate_specs(request.config) : list(list("index" = 1, "half_width" = request.config["half_width"], "half_depth" = request.config["half_depth"]))
	var/cache_solved_state = length(size_candidates) == 1 && length(candidate_families) == 1
	var/attempt_index = 0
	var/first_candidate_error = null
	var/datum/world_edit_building_layout_state/best_failed_state = null
	var/best_failed_score = -999999999
	var/best_failed_family = null
	var/best_failed_attempt = 0
	for(var/list/size_candidate as anything in size_candidates)
		for(var/footprint_family as anything in candidate_families)
			if(attempt_index >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
				break
			attempt_index++
			var/datum/world_edit_building_request/candidate_request = build_building_candidate_request(request, footprint_family, attempt_index)
			candidate_request.config["half_width"] = size_candidate["half_width"]
			candidate_request.config["half_depth"] = size_candidate["half_depth"]
			candidate_request.config["final_half_width"] = size_candidate["half_width"]
			candidate_request.config["final_half_depth"] = size_candidate["half_depth"]
			candidate_request.config["size_candidate_index"] = size_candidate["index"]
			candidate_request.config["skip_feasibility_dry_solve"] = TRUE
			if(GLOB.world_edit_helpers.parse_bool(request.config["auto_size"]) && (size_candidate["half_width"] != request.config["half_width"] || size_candidate["half_depth"] != request.config["half_depth"]))
				candidate_request.config["size_auto_adjusted"] = TRUE
			var/datum/world_edit_building_layout_state/candidate_state = build_building_layout_candidate_state(candidate_request, shape_contract, dry_params, placement_context)
			result["candidate_attempt_count"] = attempt_index
			if(!istype(candidate_state))
				result["error_candidate_count"] = result["error_candidate_count"] + 1
				if(isnull(first_candidate_error))
					first_candidate_error = candidate_request.config["layout_candidate_error"] || "Candidate layout failed before semantic state."
				continue
			if(candidate_state.has_errors())
				result["error_candidate_count"] = result["error_candidate_count"] + 1
				var/candidate_score = candidate_state.validation.layout_candidate_score
				if(!istype(best_failed_state) || candidate_score > best_failed_score)
					best_failed_state = candidate_state
					best_failed_score = candidate_score
					best_failed_family = footprint_family
					best_failed_attempt = attempt_index
				if(isnull(first_candidate_error))
					if(candidate_state.validation.current_request_support_status != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED && length(candidate_state.validation.user_facing_failure_reason))
						first_candidate_error = candidate_state.validation.user_facing_failure_reason
					else
						first_candidate_error = length(candidate_state.validation.errors) ? candidate_state.validation.errors[1] : "Building candidate failed validation."
				continue
			result["valid_candidate_count"] = result["valid_candidate_count"] + 1
			result["status"] = "solved"
			result["reason"] = ""
			result["selected_candidate_report"] = build_building_layout_candidate_report(candidate_state, footprint_family, attempt_index, candidate_state.validation.layout_candidate_score, null, FALSE)
			if(cache_solved_state && length("[cache_key]"))
				feasibility_cached_request_key = cache_key
				feasibility_cached_state = candidate_state
			return result
		if(attempt_index >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
			break

	result["status"] = "no_solution"
	result["reason"] = first_candidate_error || "No valid topology/route candidate found during feasibility dry solve."
	if(istype(best_failed_state))
		result["failed_candidate_report"] = build_building_layout_candidate_report(best_failed_state, best_failed_family, best_failed_attempt, best_failed_score, result["reason"], TRUE)
	return result

/datum/world_edit_generator/building_layout/build_plan_from_shape_contract(mob/user, datum/world_edit_shape_contract/shape_contract, list/params, list/placement_context)
	var/datum/world_edit_plan/plan = new
	var/datum/world_edit_building_request/request = build_building_request(params, shape_contract, placement_context)
	var/shape_id = "[shape_contract?.shape_id || (islist(placement_context) ? placement_context["shape"] : null) || WORLD_EDIT_SHAPE_POINT]"
	var/plan_cache_key = build_building_feasibility_cache_key(shape_id, request.config, placement_context)
	var/reuse_feasibility_state = istype(feasibility_cached_state) && length("[plan_cache_key]") && plan_cache_key == feasibility_cached_request_key
	// The plan path performs the canonical candidate solve immediately below.
	// Running the feasibility dry solve here would solve the same request twice;
	// the public support-report path still performs its independent dry solve.
	var/list/plan_support_config = request.config.Copy()
	plan_support_config["skip_feasibility_dry_solve"] = TRUE
	var/list/support_result = build_building_context_support_result(shape_id, plan_support_config, placement_context)
	if(reuse_feasibility_state && islist(feasibility_cached_support_report) && "[support_result["status"]]" == WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		support_result = feasibility_cached_support_report.Copy()
	apply_building_support_result_to_config(request.config, support_result)
	// Locked/unsupported plans return before the normal building emitter. Keep
	// the public size contract observable on that path as well, especially for
	// explicit impossible footprints.
	plan.metadata["half_width"] = request.config["half_width"]
	plan.metadata["half_depth"] = request.config["half_depth"]
	plan.metadata["requested_half_width"] = request.config["requested_half_width"]
	plan.metadata["requested_half_depth"] = request.config["requested_half_depth"]
	plan.metadata["final_half_width"] = request.config["final_half_width"] || request.config["half_width"]
	plan.metadata["final_half_depth"] = request.config["final_half_depth"] || request.config["half_depth"]
	plan.metadata["size_profile"] = request.config["size_profile"]
	plan.metadata["size_auto_adjusted"] = request.config["size_auto_adjusted"]
	plan.metadata["program_shedding"] = request.config["program_shedding"]
	plan.metadata["current_request_support_status"] = support_result["status"]
	plan.metadata["user_facing_failure_reason"] = support_result["reason"]
	plan.metadata["support_status_report"] = support_result
	if(request.config["error"])
		plan.metadata["error"] = "[request.config["error"]]"
		plan.metadata["current_request_support_status"] = WORLD_EDIT_BUILDING_SUPPORT_FAILED
		plan.metadata["user_facing_failure_reason"] = "[request.config["error"]]"
		finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
		return plan
	if(shape_contract?.error)
		plan.metadata["error"] = "[shape_contract.error]"
		plan.metadata["current_request_support_status"] = WORLD_EDIT_BUILDING_SUPPORT_FAILED
		plan.metadata["user_facing_failure_reason"] = "[shape_contract.error]"
		finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
		return plan
	if("[support_result["status"]]" != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		plan.metadata["error"] = "[support_result["reason"]]"
		finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
		return plan

	var/list/ordered_candidate_families = (shape_id == WORLD_EDIT_SHAPE_POINT) ? get_ordered_building_footprint_candidate_families(request.config) : list(uppertext("[shape_id]"))
	var/list/candidate_families = length(ordered_candidate_families) ? list(ordered_candidate_families[1]) : list("RECT")
	var/list/size_candidates = shape_id == WORLD_EDIT_SHAPE_POINT ? get_building_point_size_candidate_specs(request.config) : list(list("index" = 1, "half_width" = request.config["half_width"], "half_depth" = request.config["half_depth"]))
	var/list/candidate_reports = list()
	var/datum/world_edit_building_layout_state/best_state = null
	var/best_score = -999999999
	var/datum/world_edit_building_layout_state/best_failed_state = null
	var/best_failed_score = -999999999
	var/best_failed_family = null
	var/best_failed_attempt = 0
	var/attempt_index = 0
	var/first_candidate_error = null
	if(reuse_feasibility_state && "[support_result["status"]]" == WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED)
		best_state = feasibility_cached_state
		best_score = best_state.validation.layout_candidate_score
		attempt_index = max(round(text2num("[best_state.config["layout_candidate_index"]]") || 0), 1)
		best_state.config["debug_reports"] = request.config["debug_reports"] ? TRUE : FALSE
		apply_building_support_result_to_config(best_state.config, support_result)
		best_state.set_support_status(support_result["status"], support_result["reason"])
		best_state.validation.support_status_report = support_result.Copy()
		candidate_reports += list(build_building_layout_candidate_report(best_state, best_state.config["footprint_family"], attempt_index))
	feasibility_cached_request_key = null
	feasibility_cached_state = null
	feasibility_cached_support_report = null
	if(!istype(best_state))
		for(var/list/size_candidate as anything in size_candidates)
			for(var/footprint_family as anything in candidate_families)
				if(attempt_index >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
					break
				attempt_index++
				var/datum/world_edit_building_request/candidate_request = build_building_candidate_request(request, footprint_family, attempt_index)
				candidate_request.config["half_width"] = size_candidate["half_width"]
				candidate_request.config["half_depth"] = size_candidate["half_depth"]
				candidate_request.config["final_half_width"] = size_candidate["half_width"]
				candidate_request.config["final_half_depth"] = size_candidate["half_depth"]
				candidate_request.config["size_candidate_index"] = size_candidate["index"]
				if(GLOB.world_edit_helpers.parse_bool(request.config["auto_size"]) && (size_candidate["half_width"] != request.config["half_width"] || size_candidate["half_depth"] != request.config["half_depth"]))
					candidate_request.config["size_auto_adjusted"] = TRUE
				var/datum/world_edit_building_layout_state/candidate_state = build_building_layout_candidate_state(candidate_request, shape_contract, params, placement_context)
				if(!istype(candidate_state))
					var/error_message = candidate_request.config["layout_candidate_error"] || "Candidate layout failed before semantic state."
					if(isnull(first_candidate_error))
						first_candidate_error = error_message
					candidate_reports += list(build_building_layout_candidate_report(null, footprint_family, attempt_index, -999999999 + attempt_index, error_message))
					continue
				candidate_reports += list(build_building_layout_candidate_report(candidate_state, footprint_family, attempt_index))
				if(candidate_state.has_errors())
					if(!istype(best_failed_state) || candidate_state.validation.layout_candidate_score > best_failed_score)
						best_failed_state = candidate_state
						best_failed_score = candidate_state.validation.layout_candidate_score
						best_failed_family = footprint_family
						best_failed_attempt = attempt_index
					if(isnull(first_candidate_error))
						if(candidate_state.validation.current_request_support_status != WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED && length(candidate_state.validation.user_facing_failure_reason))
							first_candidate_error = candidate_state.validation.user_facing_failure_reason
						else
							first_candidate_error = length(candidate_state.validation.errors) ? candidate_state.validation.errors[1] : "Building candidate failed validation."
					continue
				if(!istype(best_state) || candidate_state.validation.layout_candidate_score > best_score)
					best_state = candidate_state
					best_score = candidate_state.validation.layout_candidate_score
					best_state.config["layout_candidate_index"] = attempt_index
			if(attempt_index >= WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES)
				break

	if(!istype(best_state))
		var/final_candidate_error = first_candidate_error || "Unable to build any building layout candidate."
		plan.metadata["error"] = "[final_candidate_error]"
		plan.metadata["current_request_support_status"] = WORLD_EDIT_BUILDING_SUPPORT_FAILED
		plan.metadata["user_facing_failure_reason"] = "[final_candidate_error]"
		plan.metadata["layout_candidate_reports"] = candidate_reports
		plan.metadata["footprint_candidate_count"] = length(candidate_reports)
		var/list/failed_candidate_report = null
		if(istype(best_failed_state))
			failed_candidate_report = build_building_layout_candidate_report(best_failed_state, best_failed_family, best_failed_attempt, best_failed_score, final_candidate_error, TRUE)
		else
			failed_candidate_report = select_best_building_layout_candidate_report(candidate_reports)
		if(islist(failed_candidate_report))
			plan.metadata["selected_candidate_report"] = failed_candidate_report.Copy()
			plan.metadata["failed_candidate_diagnostics"] = failed_candidate_report.Copy()
		finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
		return plan

	if(should_emit_detailed_building_reports(best_state.config))
		best_state.config["layout_candidate_reports"] = candidate_reports
		best_state.config["selected_candidate_report"] = build_building_layout_candidate_report(best_state, best_state.config["footprint_family"], best_state.config["layout_candidate_index"] || 1, best_score, null, TRUE)
	else
		best_state.config["layout_candidate_reports"] = list()
		best_state.config["selected_candidate_report"] = build_building_layout_candidate_report(best_state, best_state.config["footprint_family"], best_state.config["layout_candidate_index"] || 1, best_score, null, FALSE)
	best_state.config["footprint_candidate_count"] = length(candidate_reports)
	best_state.config["layout_candidate_score"] = best_score
	var/datum/world_edit_plan/final_plan = emit_building_layout_plan(best_state, shape_contract, placement_context)
	stamp_building_target_state_metadata(final_plan)
	return final_plan

/datum/world_edit_generator/building_layout/build_placement_plan(mob/user, list/params, list/placement_context)
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract_from_placement_context(placement_context["shape"], placement_context["anchor_turfs"], placement_context)
	return build_plan_from_shape_contract(user, shape_contract, params, placement_context)

/datum/world_edit_generator/building_layout/proc/should_emit_detailed_building_reports(list/config)
	return GLOB.world_edit_helpers.parse_bool(config?["debug_reports"])

/datum/world_edit_generator/building_layout/build_plan(list/params)
	var/turf/anchor_turf = manager?.placement_anchor_turf
	if(!istype(anchor_turf))
		anchor_turf = get_turf(manager?.holder?.mob)
	var/datum/world_edit_plan/error_plan
	if(!istype(anchor_turf))
		error_plan = new
		error_plan.metadata["error"] = "Unable to resolve building anchor turf."
		return error_plan

	var/shape_id = manager?.get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT
	var/placement_dir = manager?.get_effective_placement_dir() || NORTH
	var/list/shape_result = GLOB.world_edit_placement_shapes.world_edit_build_shape_turfs(shape_id, anchor_turf, null, params, placement_dir)
	if(shape_result["error"])
		var/original_shape_error = "[shape_result["error"]]"
		error_plan = new
		error_plan.metadata["error"] = original_shape_error
		return error_plan
	return build_placement_plan(manager?.holder?.mob, params, list(
		"mode" = manager?.get_effective_placement_mode() || "single",
		"shape" = shape_id,
		"shape_metadata" = shape_result["metadata"] || list(),
		"anchor_turfs" = shape_result["turfs"] || list(anchor_turf),
		"start_turf" = anchor_turf,
		"end_turf" = anchor_turf,
		"shape_origin_turf" = anchor_turf,
		"seed_turf" = anchor_turf,
		"requested_end_turf" = anchor_turf,
		"resolved_end_turf" = anchor_turf,
		"direction" = placement_dir,
	))

/datum/world_edit_generator/building_layout/proc/build_building_preview_spec_from_placement(list/placement)
	if(!islist(placement))
		return null
	var/kind = "[placement["kind"]]"
	var/turf/target_turf = placement["turf"]
	if(!istype(target_turf))
		return null
	if(kind in list("floor", "wall"))
		var/turf_path = placement["turf_path"]
		if(!ispath(turf_path, /turf))
			return null
		var/turf/preview_turf = turf_path
		var/list/turf_spec = GLOB.world_edit_helpers.build_world_edit_preview_object_spec(
			target_turf,
			initial(preview_turf.icon),
			initial(preview_turf.icon_state),
			SOUTH,
			initial(preview_turf.layer),
			initial(preview_turf.plane),
			0,
			0,
			kind == "floor" ? 210 : 235
		)
		if(islist(turf_spec))
			turf_spec["kind"] = kind
		return turf_spec
	if(kind in list("door", "window", "interior", "microvariation"))
		var/obj_path = placement["obj_path"]
		if(!ispath(obj_path, /obj))
			return null
		var/list/object_spec = GLOB.world_edit_helpers.build_world_edit_atom_preview_spec(obj_path, target_turf, placement["dir"])
		if(islist(object_spec))
			object_spec["kind"] = kind
		return object_spec
	return null

/datum/world_edit_generator/building_layout/build_plan_preview_object_specs(datum/world_edit_plan/plan, list/runtime_params = null, list/placement_context = null, hover_only = FALSE)
	var/list/specs = list()
	if(!istype(plan))
		return specs
	var/spec_limit = hover_only ? WORLD_EDIT_BUILDING_MAX_HOVER_PREVIEW_OBJECT_SPECS : WORLD_EDIT_BUILDING_MAX_PREVIEW_OBJECT_SPECS
	for(var/list/placement as anything in plan.placements)
		if(length(specs) >= spec_limit)
			break
		var/list/spec = build_building_preview_spec_from_placement(placement)
		if(islist(spec))
			specs += list(spec)
	return specs

/datum/world_edit_generator/building_layout/should_render_preview_via_placement_layers(datum/world_edit_plan/plan)
	return istype(plan) ? TRUE : FALSE

/datum/world_edit_generator/building_layout/should_skip_plan_build_for_hover_only_placement(datum/world_edit_shape_contract/shape_contract, list/runtime_params = null, list/placement_context = null)
	return TRUE

/datum/world_edit_generator/building_layout/should_build_hover_object_preview_plan(datum/world_edit_shape_contract/shape_contract, list/runtime_params = null, list/placement_context = null)
	return FALSE

/datum/world_edit_generator/building_layout/get_hover_object_preview_anchor_limit()
	return 2

/datum/world_edit_generator/building_layout/clear_built_plan()
	. = ..()
	current_plan_request_key = null

/datum/world_edit_generator/building_layout/proc/build_building_runtime_request_key(list/params)
	var/list/config = normalize_building_params(params)
	var/list/key_parts = list(
		"archetype_id=[config["archetype_id"]]",
		"faction_preset=[config["faction_preset"]]",
		"half_width=[config["half_width"]]",
		"half_depth=[config["half_depth"]]",
		"auto_size=[config["auto_size"] ? TRUE : FALSE]",
		"window_density=[config["window_density"]]",
		"detail_budget=[config["detail_budget"]]",
		"building_seed=[config["building_seed"]]",
		"back_exit=[config["back_exit"] ? TRUE : FALSE]",
		"respect_blockers=[config["respect_blockers"] ? TRUE : FALSE]",
		"replace_blocked_turfs=[config["replace_blocked_turfs"] ? TRUE : FALSE]",
		"confirm_large_replacement=[config["confirm_large_replacement"] ? TRUE : FALSE]",
		"shape=[manager?.get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT]",
		"dir=[manager?.get_effective_placement_dir() || NORTH]",
	)
	for(var/shape_param as anything in list(
		"shape_rect_width",
		"shape_rect_height",
		"shape_radius",
		"shape_thickness",
		"shape_radius_x",
		"shape_radius_y",
		"shape_points_text",
		"shape_polygon_filled",
		"shape_line_length",
		"shape_line_spacing",
		"shape_triangle_size",
		"shape_sector_angle",
		"shape_brush_radius",
		"shape_scatter_radius",
		"shape_scatter_count",
		"shape_scatter_seed"
	))
		if(islist(params) && !isnull(params[shape_param]))
			key_parts += "[shape_param]=[params[shape_param]]"
	var/turf/anchor_turf = manager?.placement_anchor_turf
	if(istype(anchor_turf))
		key_parts += "anchor=[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]"
	return sortList(key_parts.Copy()).Join("|")

/datum/world_edit_generator/building_layout/preview(mob/user, list/params)
	var/datum/world_edit_preview_result/result = new
	clear_built_plan()
	current_plan_request_key = null

	var/datum/world_edit_plan/plan = build_plan(params)
	if(!istype(plan))
		result.message = "Unable to build building plan."
		return result
	if(plan.metadata["error"])
		result.message = "[plan.metadata["error"]]"
		return result
	if(!length(plan.placements))
		result.message = "Building plan is empty."
		return result

	current_plan = plan
	current_plan_request_key = build_building_runtime_request_key(params)
	plan.metadata["request_key"] = current_plan_request_key
	result.success = TRUE
	if(!manager?.should_use_placement_layer_preview(plan))
		result.preview_images = GLOB.world_edit_helpers.build_turf_preview_images(plan.affected_turfs)
		result.preview_images += GLOB.world_edit_helpers.build_preview_images_from_specs(build_plan_preview_object_specs(plan, params))
	result.meta = plan.metadata.Copy()
	result.message = "Building preview ready: program=[plan.metadata["archetype_id"]], shape=[plan.metadata["placement_shape_id"]], source=[plan.metadata["footprint_source"]], family=[plan.metadata["footprint_family"]], candidates=[plan.metadata["layout_candidate_count"]], score=[plan.metadata["layout_candidate_score"]], signature=[plan.metadata["signature_score"]]/100, rooms=[plan.metadata["room_count"]], corridor=[plan.metadata["corridor_turf_count"]], slots=[plan.metadata["semantic_slot_capacity_count"]] shortage=[plan.metadata["semantic_slot_shortage_count"]] fallback=[plan.metadata["semantic_slot_fallback_count"]], reservations=[plan.metadata["semantic_slot_reservation_count"]] conflicts=[plan.metadata["semantic_slot_reservation_conflict_count"]], chunks=[plan.metadata["template_chunk_count"]], infra=[plan.metadata["infrastructure_count"]], detail=[plan.metadata["microvariation_count"]], footprint=[plan.metadata["footprint_count"]], walls=[plan.metadata["wall_count"]], doors=[plan.metadata["door_count"]], windows=[plan.metadata["window_count"]], interior=[plan.metadata["interior_object_count"]], empty=[plan.metadata["empty_floor_ratio"]]%."
	if(plan.metadata["will_replace_blocked_turfs"] && round(text2num("[plan.metadata["replace_blocked_turf_count"]]") || 0) > 0)
		result.message += " Will replace blocked turfs: [plan.metadata["replace_blocked_turf_count"]]."
	return result

/datum/world_edit_generator/building_layout/apply(mob/user, list/params)
	var/current_key = build_building_runtime_request_key(params)
	if(length("[current_plan_request_key]") && current_key != current_plan_request_key)
		var/datum/world_edit_apply_result/result = new
		result.message = "Building parameters changed after preview. Run preview again before apply."
		return result
	return apply_plan(user, params, current_plan)

/datum/world_edit_generator/building_layout/proc/runtime_target_turf(list/placement)
	var/x_value = text2num("[placement["x"]]")
	var/y_value = text2num("[placement["y"]]")
	var/z_value = text2num("[placement["z"]]")
	return locate(x_value, y_value, z_value)

/datum/world_edit_generator/building_layout/proc/placement_coord_key(list/placement)
	if(!islist(placement))
		return null
	return "[placement["x"]],[placement["y"]],[placement["z"]]"

/datum/world_edit_generator/building_layout/proc/has_runtime_object_blocker(turf/target_turf, obj_path = null, kind = null)
	if(!istype(target_turf))
		return TRUE
	if(target_turf.density && !GLOB.world_edit_blueprints.world_edit_can_place_blueprint_wall_detail(target_turf, obj_path))
		return TRUE
	if(kind == "microvariation")
		return FALSE
	for(var/atom/movable/blocker as anything in target_turf)
		if(ismob(blocker))
			continue
		if(blocker.density)
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/get_runtime_footprint_blocker_error(datum/world_edit_plan/plan)
	if(!istype(plan))
		return "Building plan is unavailable."
	var/list/checked_lookup = list()
	for(var/list/placement as anything in plan.placements)
		var/kind = "[placement["kind"]]"
		if(!(kind in list("floor", "wall", "door", "window", "interior", "microvariation")))
			continue
		var/key = placement_coord_key(placement)
		if(checked_lookup[key])
			continue
		checked_lookup[key] = TRUE
		var/turf/check_turf = runtime_target_turf(placement)
		var/blocker_error = get_footprint_blocker_error(check_turf)
		if(length("[blocker_error]"))
			return blocker_error
	return null

/datum/world_edit_generator/building_layout/proc/add_building_runtime_failure_reason(list/runtime_failure_reasons, reason)
	if(!islist(runtime_failure_reasons) || !length("[reason]"))
		return
	if(length(runtime_failure_reasons) < 32)
		runtime_failure_reasons += "[reason]"
	else if(length(runtime_failure_reasons) == 32)
		runtime_failure_reasons += "..."

/datum/world_edit_generator/building_layout/proc/get_building_plan_target_turfs(datum/world_edit_plan/plan)
	var/list/targets = list()
	var/list/target_lookup = list()
	if(!istype(plan))
		return targets
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement))
			continue
		var/kind = "[placement["kind"]]"
		if(!(kind in list("floor", "wall", "door", "window", "interior", "microvariation")))
			continue
		// A cached turf reference becomes stale after ChangeTurf().  The target
		// state contract must always hash the live turf at the placement coords.
		var/turf/target_turf = runtime_target_turf(placement)
		if(!istype(target_turf))
			continue
		var/key = "[target_turf.x],[target_turf.y],[target_turf.z]"
		if(target_lookup[key])
			continue
		target_lookup[key] = TRUE
		targets += target_turf
	return targets

/datum/world_edit_generator/building_layout/proc/build_building_target_state_hash(datum/world_edit_plan/plan)
	var/list/values = list()
	for(var/turf/target_turf as anything in get_building_plan_target_turfs(plan))
		if(!istype(target_turf))
			continue
		values += "[target_turf.x],[target_turf.y],[target_turf.z]|turf=[target_turf.type]|density=[target_turf.density]"
		for(var/atom/movable/existing_atom as anything in target_turf)
			if(ismob(existing_atom) || QDELETED(existing_atom))
				continue
			values += "[target_turf.x],[target_turf.y],[target_turf.z]|atom=[existing_atom.type]|dir=[existing_atom.dir]|density=[existing_atom.density]"
	return build_building_hash_from_strings(values)

/datum/world_edit_generator/building_layout/proc/stamp_building_target_state_metadata(datum/world_edit_plan/plan)
	if(!istype(plan))
		return null
	if(!islist(plan.metadata))
		plan.metadata = list()
	plan.metadata["target_state_hash"] = build_building_target_state_hash(plan)
	plan.metadata["target_state_turf_count"] = length(get_building_plan_target_turfs(plan))
	plan.metadata["target_state_revision_time"] = world.time
	return plan

/datum/world_edit_generator/building_layout/proc/validate_building_apply_world_state(datum/world_edit_plan/plan)
	var/list/report = list(
		"status" = "ok",
		"error_count" = 0,
		"errors" = list(),
	)
	if(!istype(plan))
		report["status"] = "failed"
		report["error_count"] = 1
		report["errors"] += "plan_missing"
		return report
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement))
			continue
		var/kind = "[placement["kind"]]"
		var/turf/target_turf = runtime_target_turf(placement)
		var/coord_key = placement_coord_key(placement)
		if(kind in list("floor", "wall"))
			var/turf_path = placement["turf_path"]
			if(!istype(target_turf) || !ispath(turf_path, /turf) || target_turf.type != turf_path)
				add_building_runtime_failure_reason(report["errors"], "post_apply_turf_mismatch:[coord_key]")
			continue
		if(kind in list("door", "window", "interior", "microvariation"))
			var/obj_path = placement["obj_path"]
			var/dir_to_check = text2num("[placement["dir"]]")
			var/found_object = FALSE
			if(istype(target_turf) && ispath(obj_path, /obj))
				for(var/obj/existing_object as anything in target_turf)
					if(!istype(existing_object) || QDELETED(existing_object) || existing_object.type != obj_path)
						continue
					if((dir_to_check in GLOB.cardinals) && existing_object.dir != dir_to_check)
						continue
					found_object = TRUE
					break
			if(!found_object)
				add_building_runtime_failure_reason(report["errors"], "post_apply_object_missing:[coord_key]:[obj_path]")
	var/list/errors = report["errors"]
	report["error_count"] = length(errors)
	if(length(errors))
		report["status"] = "failed"
	return report

/datum/world_edit_generator/building_layout/proc/fail_building_apply_transaction(datum/world_edit_apply_result/result, datum/world_edit_changeset/changeset, message, list/failures = null, verdict_status = null)
	if(!istype(result))
		result = new
	if(!islist(result.meta))
		result.meta = list()
	result.success = FALSE
	result.changeset = null
	result.message = "[message]"
	result.suppress_history = TRUE
	result.meta["transaction_committed"] = FALSE
	result.meta["suppress_history"] = TRUE
	if(islist(failures))
		result.meta["runtime_failure_reasons"] = failures.Copy()
	if(istype(changeset) && !changeset.is_empty())
		var/list/rollback_report = GLOB.world_edit_changesets.revert_changeset(changeset)
		result.meta["rollback_report"] = rollback_report
	var/list/metrics = list(
		"transaction_committed" = FALSE,
		"suppress_history" = TRUE,
		"changed_turf_count" = result.meta["changed_turf_count"] || 0,
		"created_object_count" = result.meta["created_object_count"] || 0,
		"post_apply_validation_error_count" = result.meta["post_apply_validation_error_count"] || 0,
	)
	if(!isnull(result.meta["target_state_hash"]))
		metrics["target_state_hash"] = result.meta["target_state_hash"]
	if(!isnull(result.meta["current_target_state_hash"]))
		metrics["current_target_state_hash"] = result.meta["current_target_state_hash"]
	if(islist(result.meta["rollback_report"]))
		var/list/rollback_report = result.meta["rollback_report"]
		metrics["rollback_outcome"] = rollback_report["outcome"]
		metrics["rollback_reverted_count"] = rollback_report["reverted_count"] || 0
		metrics["rollback_skipped_count"] = rollback_report["skipped_count"] || 0
	var/resolved_status = length("[verdict_status]") ? verdict_status : (istype(changeset) && !changeset.is_empty() ? WORLD_EDIT_BUILDING_APPLY_ROLLED_BACK : WORLD_EDIT_BUILDING_APPLY_FAILED)
	stamp_building_apply_validation_verdict(result, resolved_status, message, failures, metrics)
	current_plan = null
	current_plan_request_key = null
	return result

/datum/world_edit_generator/building_layout/apply_plan(mob/user, list/params, datum/world_edit_plan/plan)
	var/datum/world_edit_apply_result/result = new
	if(!istype(plan))
		result.message = "Run building preview first."
		stamp_building_apply_validation_verdict(result, WORLD_EDIT_BUILDING_APPLY_FAILED, result.message)
		return result
	if(plan.metadata["error"])
		result.message = "[plan.metadata["error"]]"
		stamp_building_apply_validation_verdict(result, WORLD_EDIT_BUILDING_APPLY_FAILED, result.message)
		return result

	result.center_turf = plan.metadata["center_turf"]
	result.meta = islist(plan.metadata) ? plan.metadata.Copy() : list()

	var/list/config = normalize_building_params(params)
	if(config["respect_blockers"])
		var/runtime_blocker_error = get_runtime_footprint_blocker_error(plan)
		if(length("[runtime_blocker_error]"))
			return fail_building_apply_transaction(result, null, "[runtime_blocker_error]", list("runtime_blocker:[runtime_blocker_error]"), WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT)
	var/replaced_blocker_count = round(text2num("[plan.metadata["replace_blocked_turf_count"]]") || 0)
	if(config["replace_blocked_turfs"] && replaced_blocker_count > WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS)
		result.message = "Building apply blocked: would replace [replaced_blocker_count] blocked turfs, above the hard cap of [WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS]."
		stamp_building_apply_validation_verdict(result, WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT, result.message, list("replace_blocked_turf_hard_cap"))
		return result
	if(config["replace_blocked_turfs"] && replaced_blocker_count > WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS && !config["confirm_large_replacement"])
		result.message = "Building apply requires confirmation: would replace [replaced_blocker_count] blocked turfs. Enable large replacement confirmation."
		stamp_building_apply_validation_verdict(result, WORLD_EDIT_BUILDING_APPLY_FAILED, result.message, list("replacement_confirmation_required"))
		return result

	var/expected_target_hash = round(text2num("[plan.metadata["target_state_hash"]]") || 0)
	var/current_target_hash = round(text2num("[build_building_target_state_hash(plan)]") || 0)
	result.meta["current_target_state_hash"] = current_target_hash
	if(expected_target_hash <= 0)
		return fail_building_apply_transaction(result, null, "Building apply blocked: preview plan is missing target state hash. Run preview again.")
	if(current_target_hash != expected_target_hash)
		result.meta["target_state_mismatch"] = TRUE
		return fail_building_apply_transaction(result, null, "Building apply blocked: target world changed after preview. Run preview again.", list("apply_target_state_mismatch"), WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT)

	var/list/preflight_failures = list()
	var/replace_blocked_turfs = config["replace_blocked_turfs"]
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement))
			continue
		var/kind = "[placement["kind"]]"
		var/turf/target_turf = runtime_target_turf(placement)
		var/coord_key = placement_coord_key(placement)
		if(kind in list("floor", "wall"))
			var/turf_path = placement["turf_path"]
			if(!istype(target_turf) || !ispath(turf_path, /turf))
				add_building_runtime_failure_reason(preflight_failures, "invalid_turf_or_path:[coord_key]")
				continue
			if(!replace_blocked_turfs && get_footprint_blocker_error(target_turf))
				add_building_runtime_failure_reason(preflight_failures, "turf_blocked:[coord_key]")
			continue
		if(kind in list("door", "window", "interior", "microvariation"))
			var/obj_path = placement["obj_path"]
			if(!istype(target_turf) || !ispath(obj_path, /obj))
				add_building_runtime_failure_reason(preflight_failures, "invalid_turf_or_path:[coord_key]")
	if(length(preflight_failures))
		return fail_building_apply_transaction(result, null, "Building apply blocked before mutation: [preflight_failures[1]].", preflight_failures, WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT)

	var/datum/world_edit_changeset/changeset = new /datum/world_edit_changeset(definition?.id || "building_layout", WORLD_EDIT_UNDO_FULL, list(
		"center_turf" = plan.metadata["center_turf"],
		"archetype_id" = plan.metadata["archetype_id"],
		"faction_preset" = plan.metadata["faction_preset"],
		"effective_seed" = plan.metadata["effective_seed"],
		"placement_mode" = plan.metadata["placement_mode"],
		"placement_dir" = plan.metadata["placement_dir"],
	))

	var/changed_turf_count = 0
	var/created_object_count = 0
	var/list/runtime_failures = list()
	for(var/list/placement as anything in plan.placements)
		var/kind = "[placement["kind"]]"
		if(!(kind in list("floor", "wall")))
			continue
		var/turf/target_turf = runtime_target_turf(placement)
		var/coord_key = placement_coord_key(placement)
		var/turf_path = placement["turf_path"]
		if(!istype(target_turf) || !ispath(turf_path, /turf))
			add_building_runtime_failure_reason(runtime_failures, "invalid_turf_or_path:[coord_key]")
			break
		if(!replace_blocked_turfs && get_footprint_blocker_error(target_turf))
			add_building_runtime_failure_reason(runtime_failures, "turf_blocked:[coord_key]")
			break
		if(target_turf.type == turf_path)
			continue
		var/old_type = target_turf.type
		var/old_baseturfs = islist(target_turf.baseturfs) ? target_turf.baseturfs.Copy() : target_turf.baseturfs
		var/turf/new_turf = target_turf.ChangeTurf(turf_path)
		if(!istype(new_turf) || new_turf.type != turf_path)
			add_building_runtime_failure_reason(runtime_failures, "change_turf_failed:[coord_key]")
			break
		changed_turf_count++
		changeset.add_changed_turf(new_turf, old_type, turf_path, old_baseturfs, list("kind" = kind))
	if(length(runtime_failures))
		result.meta["changed_turf_count"] = changed_turf_count
		result.meta["created_object_count"] = created_object_count
		return fail_building_apply_transaction(result, changeset, "Building apply rolled back: [runtime_failures[1]].", runtime_failures)

	for(var/list/placement as anything in plan.placements)
		var/kind = "[placement["kind"]]"
		if(!(kind in list("door", "window", "interior", "microvariation")))
			continue
		var/turf/target_turf = runtime_target_turf(placement)
		var/coord_key = placement_coord_key(placement)
		var/obj_path = placement["obj_path"]
		if(!istype(target_turf) || !ispath(obj_path, /obj))
			add_building_runtime_failure_reason(runtime_failures, "invalid_turf_or_path:[coord_key]")
			break
		if(!replace_blocked_turfs && has_runtime_object_blocker(target_turf, obj_path, kind))
			add_building_runtime_failure_reason(runtime_failures, "object_blocked:[coord_key]:[obj_path]")
			break
		var/obj/created_object = new obj_path(target_turf)
		if(!created_object)
			add_building_runtime_failure_reason(runtime_failures, "object_create_failed:[coord_key]:[obj_path]")
			break
		var/dir_to_use = text2num("[placement["dir"]]")
		if(dir_to_use in GLOB.cardinals)
			created_object.setDir(dir_to_use)
			if(GLOB.world_edit_helpers.parse_bool(placement["wall_mounted"]))
				var/wall_dir = text2num("[placement["wall_dir"]]")
				if(!wall_dir)
					wall_dir = dir_to_use
				GLOB.world_edit_helpers.align_object_to_wall(created_object, wall_dir)
		created_object_count++
		changeset.add_created(created_object, target_turf, list(
			"kind" = kind,
			"obj_path" = obj_path,
			"dir" = dir_to_use,
		))
	if(length(runtime_failures))
		result.meta["changed_turf_count"] = changed_turf_count
		result.meta["created_object_count"] = created_object_count
		return fail_building_apply_transaction(result, changeset, "Building apply rolled back: [runtime_failures[1]].", runtime_failures)

	result.created_count = created_object_count
	result.meta["changed_turf_count"] = changed_turf_count
	result.meta["created_object_count"] = created_object_count
	if(changed_turf_count <= 0 && created_object_count <= 0)
		result.message = "Building made no changes."
		result.suppress_history = TRUE
		result.meta["suppress_history"] = TRUE
		stamp_building_apply_validation_verdict(result, WORLD_EDIT_BUILDING_APPLY_FAILED, result.message, list("apply.no_changes"), list(
			"transaction_committed" = FALSE,
			"suppress_history" = TRUE,
			"changed_turf_count" = changed_turf_count,
			"created_object_count" = created_object_count,
		))
		current_plan = null
		current_plan_request_key = null
		return result

	var/list/post_apply_report = validate_building_apply_world_state(plan)
	result.meta["post_apply_validation_report"] = post_apply_report
	result.meta["post_apply_validation_error_count"] = round(text2num("[post_apply_report["error_count"]]") || 0)
	if(result.meta["post_apply_validation_error_count"] > 0)
		var/list/post_apply_errors = post_apply_report["errors"]
		var/post_apply_error = (islist(post_apply_errors) && length(post_apply_errors)) ? "[post_apply_errors[1]]" : "post_apply_validation_failed"
		return fail_building_apply_transaction(result, changeset, "Building apply rolled back after world inspection: [post_apply_error].", post_apply_errors)

	result.success = TRUE
	result.changeset = changeset
	result.meta["transaction_committed"] = TRUE
	result.meta["post_apply_target_state_hash"] = build_building_target_state_hash(plan)
	stamp_building_apply_validation_verdict(result, WORLD_EDIT_BUILDING_APPLY_APPLIED, "Building apply completed.", null, list(
		"transaction_committed" = TRUE,
		"suppress_history" = result.suppress_history ? TRUE : FALSE,
		"changed_turf_count" = changed_turf_count,
		"created_object_count" = created_object_count,
		"post_apply_validation_error_count" = result.meta["post_apply_validation_error_count"] || 0,
		"target_state_hash" = plan.metadata["target_state_hash"],
		"post_apply_target_state_hash" = result.meta["post_apply_target_state_hash"],
	))
	result.message = "Building applied: turfs=[changed_turf_count], objects=[created_object_count]."
	current_plan = null
	current_plan_request_key = null
	return result

#undef WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS
#undef WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT
#undef WORLD_EDIT_BUILDING_MAX_PREVIEW_OBJECT_SPECS
#undef WORLD_EDIT_BUILDING_MAX_HOVER_PREVIEW_OBJECT_SPECS
#undef WORLD_EDIT_BUILDING_MAX_WINDOWS
#undef WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS
#undef WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS
#undef WORLD_EDIT_BUILDING_MAX_VALIDATION_ERRORS
#undef WORLD_EDIT_BUILDING_MAX_REPAIR_ATTEMPTS
#undef WORLD_EDIT_BUILDING_MAX_REGION_ASSIGNMENT_STEPS
#undef WORLD_EDIT_BUILDING_MAX_REGION_ASSIGNMENT_BRANCHES
#undef WORLD_EDIT_BUILDING_MAX_DIVIDER_RUN_ATTEMPTS
#undef WORLD_EDIT_BUILDING_MAX_ROOM_IN_ROOM_CANDIDATES
#undef WORLD_EDIT_BUILDING_MAX_STAGE_REPORTS
#undef WORLD_EDIT_BUILDING_MAX_PATTERN_REPORTS
#undef WORLD_EDIT_BUILDING_MAX_SEMANTIC_SLOT_REPORTS
#undef WORLD_EDIT_BUILDING_MAX_DEGRADED_REGION_REPORTS
#undef WORLD_EDIT_BUILDING_MAX_CANDIDATE_REPORT_DETAILS
#undef WORLD_EDIT_BUILDING_MAX_QUALITY_SAMPLES_STORED
#undef WORLD_EDIT_BUILDING_MAX_QUALITY_FAILURE_SAMPLES
#undef WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS
#undef WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS
#undef WORLD_EDIT_BUILDING_AUTO_SEED
#undef WORLD_EDIT_BUILDING_PRNG_MOD
#undef WORLD_EDIT_BUILDING_HASH_A_MOD
#undef WORLD_EDIT_BUILDING_HASH_B_MOD
#undef WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED
#undef WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED
#undef WORLD_EDIT_BUILDING_SUPPORT_DISABLED
#undef WORLD_EDIT_BUILDING_SUPPORT_FAILED
#undef WORLD_EDIT_BUILDING_SIZE_POLICY_AUTO
#undef WORLD_EDIT_BUILDING_SIZE_POLICY_EXPLICIT
#undef WORLD_EDIT_BUILDING_SIZE_POLICY_ADAPTIVE
#undef WORLD_EDIT_BUILDING_DEGRADE_NONE
#undef WORLD_EDIT_BUILDING_DEGRADE_COMPACT
#undef WORLD_EDIT_BUILDING_DEGRADE_MICRO
