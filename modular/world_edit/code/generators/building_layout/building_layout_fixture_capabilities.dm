/datum/world_edit_building_fixture_provider
	var/id = ""
	var/slot = ""
	var/capability = ""
	var/path_text = ""
	var/obj_path = null
	var/source = ""
	var/list/styles = list()
	var/list/provides_slots = list()
	var/list/provides_categories = list()
	var/list/provides_capabilities = list()
	var/list/audit_errors = list()
	var/functional = TRUE
	var/decorative_only = FALSE
	var/dense_expected = TRUE
	var/wall_mountable = FALSE
	var/reason_if_not_functional = ""

/datum/world_edit_building_fixture_provider/proc/provides_required_slot(required_slot)
	if(!functional || decorative_only)
		return FALSE
	return "[required_slot]" in provides_slots

/datum/world_edit_building_fixture_provider/proc/provides_required_capability(required_capability)
	if(!functional || decorative_only)
		return FALSE
	return "[required_capability]" in provides_capabilities

/datum/world_edit_building_fixture_provider/proc/as_payload()
	return list(
		"id" = id,
		"slot" = slot,
		"capability" = capability,
		"path_text" = path_text,
		"obj_path" = "[obj_path]",
		"source" = source,
		"styles" = islist(styles) ? styles.Copy() : list(),
		"provides_slots" = islist(provides_slots) ? provides_slots.Copy() : list(),
		"provides_categories" = islist(provides_categories) ? provides_categories.Copy() : list(),
		"provides_capabilities" = islist(provides_capabilities) ? provides_capabilities.Copy() : list(),
		"audit_errors" = islist(audit_errors) ? audit_errors.Copy() : list(),
		"functional" = functional ? TRUE : FALSE,
		"decorative_only" = decorative_only ? TRUE : FALSE,
		"dense_expected" = dense_expected ? TRUE : FALSE,
		"wall_mountable" = wall_mountable ? TRUE : FALSE,
		"reason_if_not_functional" = reason_if_not_functional,
	)

/datum/world_edit_generator/building_layout/proc/add_building_fixture_provider_value(list/values, value)
	if(!islist(values) || !length("[value]"))
		return
	var/value_key = "[value]"
	if(value_key in values)
		return
	values += value_key

/datum/world_edit_generator/building_layout/proc/get_building_fixture_required_capability(slot, category = null)
	var/slot_key = "[slot]"
	var/category_key = "[category]"
	switch(slot_key)
		if("table")
			return "work_surface"
		if("chair")
			return "seating"
		if("cabinet")
			return "storage"
		if("bed")
			return "sleep_surface"
		if("rack")
			return "rack_storage"
		if("crate")
			return "supply_storage"
		if("console")
			return "data_terminal"
		if("barrier")
			return "barrier"
		if("medical_bed")
			return "medical_bed"
		if("medical_storage")
			return "medical_storage"
		if("sleeper")
			return "medical_sleeper"
		if("medical_scanner")
			return "medical_scanner"
		if("wall_monitor")
			return "medical_monitor"
		if("hydro_tray")
			return "hydroponics"
		if("seed_storage")
			return "seed_storage"
		if("water_tank")
			return "water_supply"
		if("fridge")
			return "cold_storage"
		if("microwave")
			return "food_heating"
		if("processor")
			if(category_key == "work_machine")
				return "work_machine"
			return "food_processing"
		if("sink")
			return "sink_wash"
		if("toilet")
			return "sanitation"
		if("filing")
			return "records_storage"
		if("security_console")
			return "security_monitoring"
		if("security_camera")
			return "security_camera"
		if("brig_cell")
			return "brig_cell"
		if("weapon_rack")
			return "weapon_storage"
		if("engineering_machine")
			return "engineering_machine"
		if("power_console")
			return "power_control"
		if("lab_machine")
			return "lab_machine"
		if("sample_storage")
			return "sample_storage"
		if("light")
			return "lighting"
		if("apc")
			return "power_apc"
		if("air_alarm")
			return "air_monitoring"
		if("fire_alarm")
			return "fire_alarm"
		if("light_switch")
			return "light_control"
	return length(category_key) ? category_key : slot_key

/datum/world_edit_generator/building_layout/proc/get_building_fixture_capability_path_roots(capability)
	switch("[capability]")
		if("work_surface")
			return list("/obj/structure/surface/table")
		if("seating")
			return list("/obj/structure/bed/chair")
		if("storage")
			return list("/obj/structure/closet", "/obj/structure/filingcabinet")
		if("sleep_surface")
			return list("/obj/structure/bed")
		if("rack_storage")
			return list("/obj/structure/surface/rack", "/obj/structure/gun_rack")
		if("supply_storage")
			return list("/obj/structure/closet/crate")
		if("data_terminal", "power_control")
			return list("/obj/structure/machinery/computer", "/obj/structure/prop/server_equipment/laptop")
		if("barrier")
			return list("/obj/structure/barricade")
		if("medical_bed")
			return list("/obj/structure/bed/roller", "/obj/structure/bed")
		if("medical_storage", "sample_storage")
			return list("/obj/structure/closet/crate/medical", "/obj/structure/closet/medical_wall")
		if("medical_sleeper")
			return list("/obj/structure/machinery/medical_pod/sleeper")
		if("medical_scanner", "lab_machine")
			return list("/obj/structure/machinery/medical_pod/bodyscanner")
		if("medical_monitor")
			return list("/obj/structure/machinery/body_scanconsole")
		if("hydroponics")
			return list("/obj/structure/machinery/portable_atmospherics/hydroponics")
		if("seed_storage")
			return list("/obj/structure/filingcabinet/seeds")
		if("water_supply")
			return list("/obj/structure/reagent_dispensers/watertank")
		if("cold_storage")
			return list("/obj/structure/machinery/smartfridge")
		if("food_heating")
			return list("/obj/structure/machinery/microwave")
		if("food_processing", "work_machine", "engineering_machine")
			return list("/obj/structure/machinery/processor")
		if("sink_wash")
			return list("/obj/structure/sink")
		if("sanitation")
			return list("/obj/structure/toilet")
		if("records_storage")
			return list("/obj/structure/filingcabinet")
		if("security_monitoring")
			return list("/obj/structure/machinery/computer/cameras")
		if("security_camera")
			return list("/obj/structure/machinery/camera")
		if("brig_cell")
			return list("/obj/structure/machinery/brig_cell")
		if("weapon_storage")
			return list("/obj/structure/gun_rack")
		if("lighting")
			return list("/obj/structure/machinery/light")
		if("power_apc")
			return list("/obj/structure/machinery/power/apc")
		if("air_monitoring")
			return list("/obj/structure/machinery/alarm")
		if("fire_alarm")
			return list("/obj/structure/machinery/firealarm")
		if("light_control")
			return list("/obj/structure/machinery/light_switch")
	return list()

/datum/world_edit_generator/building_layout/proc/building_fixture_path_supports_capability(obj_path, capability)
	if(!obj_path || !length("[capability]"))
		return FALSE
	for(var/path_text as anything in get_building_fixture_capability_path_roots(capability))
		var/allowed_path = resolve_building_type_path(path_text, /obj)
		if(allowed_path && ispath(obj_path, allowed_path))
			return TRUE
	return FALSE

/datum/world_edit_generator/building_layout/proc/build_building_fixture_path_report(list/config, slot)
	var/list/interior_paths = islist(config) ? config["interior_paths"] : null
	var/slot_key = "[slot]"
	var/path_value = islist(interior_paths) ? interior_paths[slot_key] : null
	var/source = "direct"
	if(isnull(path_value))
		source = "missing"
	var/resolved_path = resolve_building_type_path(path_value, /obj)
	return list(
		"path" = resolved_path,
		"source" = source,
		"raw_path" = path_value,
	)

/datum/world_edit_generator/building_layout/proc/build_legacy_fixture_provider(slot, obj_path, source = "direct")
	if(!obj_path)
		return null
	var/slot_key = "[slot]"
	var/datum/world_edit_building_fixture_provider/provider = new
	provider.id = "legacy:[slot_key]:[obj_path]"
	provider.slot = slot_key
	provider.capability = get_building_fixture_required_capability(slot_key)
	provider.obj_path = obj_path
	provider.path_text = "[obj_path]"
	provider.source = "[source]"
	provider.provides_slots = list(slot_key)
	provider.provides_capabilities = list()
	add_building_fixture_provider_value(provider.provides_capabilities, provider.capability)
	if(slot_key in list("microwave", "processor", "sink", "fridge"))
		add_building_fixture_provider_value(provider.provides_capabilities, "food_preparation")
	if(slot_key == "processor")
		add_building_fixture_provider_value(provider.provides_capabilities, "work_machine")
	if(slot_key in list("cabinet", "filing", "medical_storage", "sample_storage", "rack", "crate", "weapon_rack", "seed_storage"))
		add_building_fixture_provider_value(provider.provides_capabilities, "storage")
	provider.functional = TRUE
	if("[source]" != "direct")
		provider.functional = FALSE
		provider.decorative_only = TRUE
		provider.provides_slots = list()
		provider.provides_capabilities = list()
		provider.reason_if_not_functional = "slot '[slot_key]' has no direct functional provider"
	else if(!building_fixture_path_supports_capability(obj_path, provider.capability))
		provider.functional = FALSE
		provider.decorative_only = TRUE
		provider.provides_slots = list()
		provider.provides_capabilities = list()
		provider.reason_if_not_functional = "path '[obj_path]' does not provide capability '[provider.capability]' for required slot '[slot_key]'"
	if("[obj_path]" in list(
		"/obj/structure/covenant_barricade",
		"/obj/structure/covenant_barricade/wide",
		"/obj/structure/machinery/recharger/covenant"
	))
		provider.functional = FALSE
		provider.decorative_only = TRUE
		provider.provides_slots = list()
		provider.provides_capabilities = list()
		provider.reason_if_not_functional = "path '[obj_path]' is a decorative placeholder and does not provide required capability '[provider.capability]'"
	return provider

/datum/world_edit_generator/building_layout/proc/build_fixture_provider_registry(list/config)
	var/list/providers = list()
	var/list/interior_paths = islist(config) ? config["interior_paths"] : null
	if(!islist(interior_paths))
		return providers
	var/style_id = "[config["faction_preset"] || ""]"
	var/datum/world_edit_building_object_provider_registry/verified_registry = get_building_object_provider_registry()
	for(var/slot as anything in interior_paths)
		var/datum/world_edit_building_fixture_provider/verified_provider = verified_registry?.get_for_style_slot(style_id, slot)
		if(istype(verified_provider))
			providers["[slot]"] = verified_provider
			continue
		var/list/path_report = build_building_fixture_path_report(config, slot)
		var/datum/world_edit_building_fixture_provider/provider = build_legacy_fixture_provider(slot, path_report["path"], path_report["source"])
		if(istype(provider))
			providers["[slot]"] = provider
	return providers

/datum/world_edit_generator/building_layout/proc/resolve_fixture_provider(list/config, slot)
	var/list/providers = islist(config) ? config["fixture_providers_by_slot"] : null
	if(islist(providers) && istype(providers["[slot]"], /datum/world_edit_building_fixture_provider))
		return providers["[slot]"]
	var/style_id = "[islist(config) ? config["faction_preset"] : ""]"
	var/datum/world_edit_building_object_provider_registry/verified_registry = get_building_object_provider_registry()
	var/datum/world_edit_building_fixture_provider/verified_provider = verified_registry?.get_for_style_slot(style_id, slot)
	if(istype(verified_provider))
		return verified_provider
	var/list/path_report = build_building_fixture_path_report(config, slot)
	return build_legacy_fixture_provider(slot, path_report["path"], path_report["source"])

/datum/world_edit_generator/building_layout/proc/building_fixture_provider_satisfies_slot(datum/world_edit_building_fixture_provider/provider, slot, category = null)
	if(!istype(provider) || !provider.provides_required_slot(slot))
		return FALSE
	var/required_capability = get_building_fixture_required_capability(slot, category)
	if(!length(required_capability))
		return TRUE
	return provider.provides_required_capability(required_capability)

/datum/world_edit_generator/building_layout/proc/building_placement_provides_capability(list/placement, required_capability)
	if(!islist(placement) || !length("[required_capability]"))
		return FALSE
	var/list/provided_capabilities = placement["provided_capabilities"]
	return islist(provided_capabilities) && ("[required_capability]" in provided_capabilities)

/datum/world_edit_generator/building_layout/proc/build_building_required_capability_payload(datum/world_edit_building_archetype/archetype)
	var/list/required_slots = collect_building_required_slots(archetype)
	var/list/required_capabilities = list()
	for(var/slot as anything in required_slots)
		add_building_fixture_provider_value(required_capabilities, get_building_fixture_required_capability(slot))
	return list(
		"required_slots" = required_slots,
		"required_capabilities" = required_capabilities,
	)

/datum/world_edit_generator/building_layout/proc/build_building_preset_capability_report(list/config, datum/world_edit_building_archetype/archetype)
	var/list/report = list(
		"supported" = TRUE,
		"required_slots" = list(),
		"required_capabilities" = list(),
		"missing_slots" = list(),
		"missing_capabilities" = list(),
	)
	if(!islist(config) || !istype(archetype))
		report["supported"] = FALSE
		return report
	var/list/required_payload = build_building_required_capability_payload(archetype)
	report["required_slots"] = required_payload["required_slots"]
	report["required_capabilities"] = required_payload["required_capabilities"]
	for(var/slot as anything in report["required_slots"])
		var/required_capability = get_building_fixture_required_capability(slot)
		var/datum/world_edit_building_fixture_provider/provider = resolve_fixture_provider(config, slot)
		if(istype(provider) && building_fixture_provider_satisfies_slot(provider, slot))
			continue
		var/reason = istype(provider) ? provider.reason_if_not_functional : "no provider"
		report["missing_slots"] += list(list(
			"slot" = "[slot]",
			"capability" = required_capability,
			"reason" = length(reason) ? reason : "provider is not functionally equivalent",
		))
		add_building_fixture_provider_value(report["missing_capabilities"], required_capability)
	report["supported"] = length(report["missing_slots"]) ? FALSE : TRUE
	return report

/datum/world_edit_generator/building_layout/proc/build_building_style_config(style_id, datum/world_edit_building_archetype/archetype = null)
	var/list/catalog = get_building_faction_catalog()
	var/list/base_preset = catalog["[style_id]"]
	if(!islist(base_preset))
		return null
	var/list/preset = istype(archetype) ? merge_building_preset_overrides(base_preset, archetype) : base_preset
	var/list/config = list(
		"faction_preset" = "[style_id]",
		"interior_paths" = islist(preset["interior_paths"]) ? preset["interior_paths"].Copy() : list(),
	)
	config["fixture_providers_by_slot"] = build_fixture_provider_registry(config)
	return config

/datum/world_edit_generator/building_layout/proc/build_building_program_capability_payload()
	var/list/payload = list()
	var/list/catalog = get_building_archetype_catalog()
	for(var/program_id as anything in catalog)
		var/datum/world_edit_building_archetype/archetype = catalog[program_id]
		if(!istype(archetype))
			continue
		var/list/required_payload = build_building_required_capability_payload(archetype)
		payload["[program_id]"] = list(
			"id" = archetype.id,
			"label" = archetype.label,
			"suggested_style_id" = archetype.suggested_shell_preset,
			"required_slots" = required_payload["required_slots"],
			"required_capabilities" = required_payload["required_capabilities"],
		)
	return payload

/datum/world_edit_generator/building_layout/proc/build_building_style_capability_payload()
	var/list/payload = list()
	var/list/catalog = get_building_faction_catalog()
	for(var/style_id as anything in catalog)
		var/list/preset = catalog[style_id]
		if(!islist(preset))
			continue
		var/list/config = build_building_style_config(style_id)
		var/list/providers = config?["fixture_providers_by_slot"]
		var/list/capabilities = list()
		var/list/providers_by_capability = list()
		if(islist(providers))
			for(var/slot as anything in providers)
				var/datum/world_edit_building_fixture_provider/provider = providers[slot]
				if(!istype(provider) || !provider.functional)
					continue
				for(var/capability as anything in provider.provides_capabilities)
					add_building_fixture_provider_value(capabilities, capability)
					var/list/capability_providers = providers_by_capability["[capability]"]
					if(!islist(capability_providers))
						capability_providers = list()
						providers_by_capability["[capability]"] = capability_providers
					capability_providers += list(provider.as_payload())
		payload["[style_id]"] = list(
			"id" = "[style_id]",
			"label" = "[preset["label"] || style_id]",
			"capabilities" = capabilities,
			"providers_by_capability" = providers_by_capability,
		)
	return payload

/datum/world_edit_generator/building_layout/proc/build_building_program_style_compatibility_payload()
	var/list/rows = list()
	var/list/by_key = list()
	var/list/program_catalog = get_building_archetype_catalog()
	var/list/style_catalog = get_building_faction_catalog()
	for(var/program_id as anything in program_catalog)
		var/datum/world_edit_building_archetype/archetype = program_catalog[program_id]
		if(!istype(archetype))
			continue
		for(var/style_id as anything in style_catalog)
			var/list/config = build_building_style_config(style_id, archetype)
			var/list/report = build_building_preset_capability_report(config, archetype)
			var/supported = report["supported"] ? TRUE : FALSE
			var/list/row = list(
				"program_id" = archetype.id,
				"style_id" = "[style_id]",
				"supported" = supported,
				"lock_code" = supported ? "" : WORLD_EDIT_BUILDING_ERROR_STYLE_MISSING_CAPABILITY,
				"missing_slots" = report["missing_slots"],
				"missing_capabilities" = report["missing_capabilities"],
			)
			rows += list(row)
			by_key["[archetype.id]|[style_id]"] = row
	return list(
		"rows" = rows,
		"by_key" = by_key,
	)

/datum/world_edit_generator/building_layout/proc/build_building_capability_matrix_payload()
	return list(
		"programs" = build_building_program_capability_payload(),
		"styles" = build_building_style_capability_payload(),
		"compatibility" = build_building_program_style_compatibility_payload(),
	)
