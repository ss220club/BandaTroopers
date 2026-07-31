/datum/world_edit_building_object_provider_registry
	var/list/providers_by_id = list()
	var/list/providers_by_style_slot = list()
	var/list/providers_by_capability = list()
	var/list/audit_errors = list()
	var/provider_path_not_in_build_count = 0
	var/unknown_provider_count = 0
	var/unique_provider_path_count = 0
	var/unique_functional_provider_path_count = 0
	var/unique_decorative_provider_path_count = 0

/datum/world_edit_building_object_provider_registry/proc/register_obj(datum/world_edit_generator/building_layout/generator, id, slot, path_text, list/styles, list/capabilities, list/categories = null, decorative_only = FALSE, dense_expected = TRUE, wall_mountable = FALSE)
	if(!istype(generator) || !length("[id]") || !length("[slot]") || !length("[path_text]"))
		unknown_provider_count++
		audit_errors += "unknown_provider:[id]:[slot]"
		return null
	var/resolved_path = generator.resolve_building_type_path(path_text, /obj)
	if(!ispath(resolved_path, /obj))
		provider_path_not_in_build_count++
		audit_errors += "path_not_obj:[id]:[path_text]"
		return null
	var/slot_key = "[slot]"
	var/datum/world_edit_building_fixture_provider/provider = new
	provider.id = "[id]"
	provider.slot = slot_key
	provider.capability = generator.get_building_fixture_required_capability(slot_key)
	provider.path_text = "[path_text]"
	provider.obj_path = resolved_path
	provider.source = "verified_catalog"
	provider.styles = islist(styles) ? styles.Copy() : list()
	provider.provides_slots = list(slot_key)
	provider.provides_categories = islist(categories) ? categories.Copy() : list(slot_key)
	provider.provides_capabilities = list()
	if(islist(capabilities))
		for(var/capability_id as anything in capabilities)
			generator.add_building_fixture_provider_value(provider.provides_capabilities, capability_id)
	else
		generator.add_building_fixture_provider_value(provider.provides_capabilities, provider.capability)
	provider.decorative_only = decorative_only ? TRUE : FALSE
	provider.functional = provider.decorative_only ? FALSE : TRUE
	provider.dense_expected = dense_expected ? TRUE : FALSE
	provider.wall_mountable = wall_mountable ? TRUE : FALSE
	if(provider.decorative_only)
		provider.provides_slots = list()
		provider.provides_capabilities = list()
		provider.reason_if_not_functional = "provider '[provider.id]' is decorative_only"
	else if(!generator.building_fixture_path_supports_capability(provider.obj_path, provider.capability))
		provider.functional = FALSE
		provider.decorative_only = TRUE
		provider.provides_slots = list()
		provider.provides_capabilities = list()
		provider.reason_if_not_functional = "path '[provider.path_text]' does not provide capability '[provider.capability]' for slot '[provider.slot]'"
	if("[provider.path_text]" in list("/obj/structure/covenant_barricade", "/obj/structure/covenant_barricade/wide", "/obj/structure/machinery/recharger/covenant"))
		provider.functional = FALSE
		provider.decorative_only = TRUE
		provider.provides_slots = list()
		provider.provides_capabilities = list()
		provider.reason_if_not_functional = "Covenant barricade/recharger providers are decorative_only until functional capability is proven"
	providers_by_id[provider.id] = provider
	for(var/style_id as anything in provider.styles)
		var/key = "[style_id]|[provider.slot]"
		var/list/style_slot_providers = providers_by_style_slot[key]
		if(!islist(style_slot_providers))
			style_slot_providers = list()
			providers_by_style_slot[key] = style_slot_providers
		style_slot_providers += provider
	for(var/capability_id as anything in provider.provides_capabilities)
		var/list/capability_providers = providers_by_capability["[capability_id]"]
		if(!islist(capability_providers))
			capability_providers = list()
			providers_by_capability["[capability_id]"] = capability_providers
		capability_providers += provider
	refresh_unique_provider_counts()
	return provider

/datum/world_edit_building_object_provider_registry/proc/get_for_style_slot(style_id, slot)
	var/list/style_slot_providers = providers_by_style_slot["[style_id]|[slot]"]
	if(!islist(style_slot_providers))
		return null
	for(var/datum/world_edit_building_fixture_provider/provider as anything in style_slot_providers)
		if(istype(provider) && provider.functional && !provider.decorative_only)
			return provider
	for(var/datum/world_edit_building_fixture_provider/fallback_provider as anything in style_slot_providers)
		if(istype(fallback_provider))
			return fallback_provider
	return null

/datum/world_edit_building_object_provider_registry/proc/get_all_for_style_slot(style_id, slot)
	var/list/style_slot_providers = providers_by_style_slot["[style_id]|[slot]"]
	return islist(style_slot_providers) ? style_slot_providers.Copy() : list()

/datum/world_edit_building_object_provider_registry/proc/refresh_unique_provider_counts()
	var/list/unique_paths = list()
	var/list/unique_functional_paths = list()
	var/list/unique_decorative_paths = list()
	for(var/provider_id as anything in providers_by_id)
		var/datum/world_edit_building_fixture_provider/provider = providers_by_id[provider_id]
		if(!istype(provider))
			continue
		var/path_key = length(provider.path_text) ? provider.path_text : "[provider.obj_path]"
		if(!length(path_key))
			continue
		unique_paths[path_key] = TRUE
		if(provider.functional && !provider.decorative_only)
			unique_functional_paths[path_key] = TRUE
		else
			unique_decorative_paths[path_key] = TRUE
	unique_provider_path_count = length(unique_paths)
	unique_functional_provider_path_count = length(unique_functional_paths)
	unique_decorative_provider_path_count = length(unique_decorative_paths)

/datum/world_edit_building_object_provider_registry/proc/audit()
	refresh_unique_provider_counts()
	return audit_errors.Copy()

/datum/world_edit_generator/building_layout/proc/get_building_object_provider_registry()
	if(istype(GLOB.world_edit_building_object_provider_registry, /datum/world_edit_building_object_provider_registry))
		return GLOB.world_edit_building_object_provider_registry
	var/datum/world_edit_building_object_provider_registry/registry = new
	var/list/catalog = get_building_faction_catalog()
	for(var/style_id as anything in catalog)
		var/list/preset = catalog[style_id]
		var/list/interior_paths = islist(preset) ? preset["interior_paths"] : null
		if(!islist(interior_paths))
			continue
		for(var/slot as anything in interior_paths)
			var/slot_key = "[slot]"
			var/path_text = "[interior_paths[slot]]"
			var/capability = get_building_fixture_required_capability(slot_key)
			var/list/capabilities = list(capability)
			if(slot_key in list("microwave", "processor", "sink", "fridge"))
				capabilities += "food_preparation"
			if(slot_key == "processor")
				capabilities += "work_machine"
			if(slot_key in list("cabinet", "filing", "medical_storage", "sample_storage", "rack", "crate", "weapon_rack", "seed_storage"))
				capabilities += "storage"
			var/decorative_only = ("[style_id]" == "covenant" && path_text in list("/obj/structure/covenant_barricade", "/obj/structure/covenant_barricade/wide", "/obj/structure/machinery/recharger/covenant"))
			var/wall_mountable = slot_key in list("light", "apc", "air_alarm", "fire_alarm", "light_switch", "security_camera", "medical_storage")
			registry.register_obj(src, "[style_id]_[slot_key]", slot_key, path_text, list("[style_id]"), capabilities, list(slot_key), decorative_only, TRUE, wall_mountable)
	GLOB.world_edit_building_object_provider_registry = registry
	return registry
