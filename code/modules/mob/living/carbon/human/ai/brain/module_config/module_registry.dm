// Human AI module construction, ownership, and lookup by module type.

// ==================== Ownership ====================
// The config owns modules it creates; teardown deletes this list.
/datum/human_ai_module_config/proc/register_module(datum/human_ai_module/module)
	if(!module)
		return null

	LAZYOR(owned_modules, module)
	LAZYINITLIST(modules_by_type)
	if(modules_by_type[module.type] && (modules_by_type[module.type] != module))
		report_action_policy_issue("duplicate module type registration [module.type]")
	modules_by_type[module.type] = module
	if(module.module_id)
		LAZYINITLIST(modules_by_id)
		if(modules_by_id[module.module_id] && (modules_by_id[module.module_id] != module))
			report_action_policy_issue("duplicate module id registration [module.module_id]")
		modules_by_id[module.module_id] = module
	return module

// ==================== Factory ====================
// Creates and registers a module for a known module type.
/datum/human_ai_module_config/proc/setup_module_by_type(datum/human_ai_brain/brain, module_type, list/resolving_module_types = null)
	var/datum/human_ai_module/existing_module = get_module_by_type(module_type)
	if(existing_module)
		return existing_module

	var/module_factory_type = get_module_factory_type(module_type)
	if(!module_factory_type)
		report_action_policy_issue("unknown module factory type [module_type]")
		return null

	if(!resolving_module_types)
		resolving_module_types = list()

	if(module_type in resolving_module_types)
		report_action_policy_issue("cyclic module setup dependency [module_type]")
		return null

	resolving_module_types += module_type
	for(var/dependency_type as anything in get_module_dependency_types(module_type))
		setup_module_by_type(brain, dependency_type, resolving_module_types)
	resolving_module_types -= module_type

	var/datum/human_ai_module/module = new module_factory_type(brain)
	return register_module(module)

/datum/human_ai_module_config/proc/get_module_factory_type(module_type)
	var/list/module_factory_types = get_module_factory_types()
	return module_factory_types[module_type]

// ==================== Lookup ====================
// Reads the registry source of truth for a known module type.
/datum/human_ai_module_config/proc/get_module_by_type(module_type)
	if(!ispath(module_type, /datum/human_ai_module) || !modules_by_type)
		return null
	return modules_by_type[module_type]

/datum/human_ai_module_config/proc/get_module_by_id(module_id)
	if(!modules_by_id)
		return null
	return modules_by_id[module_id]

// ==================== Dispatch lists ====================
// Builds ordered process/event lists while omitting modules that were not composed for this brain.
/datum/human_ai_module_config/proc/build_module_list(datum/human_ai_brain/brain, list/module_types)
	var/list/module_list = list()
	for(var/module_type as anything in module_types)
		var/datum/human_ai_module/module = get_module_by_type(module_type)
		if(module)
			module_list += module

	return module_list

/datum/human_ai_module_config/proc/register_module_list_for_event(datum/human_ai_brain/brain, event_type, list/module_types)
	for(var/datum/human_ai_module/module as anything in build_module_list(brain, module_types))
		brain.register_ai_event_subscriber(event_type, module)
