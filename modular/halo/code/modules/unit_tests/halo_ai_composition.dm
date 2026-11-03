#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/halo_ai_composition

/datum/unit_test/halo_ai_composition/Run()
	var/datum/human_ai_module_config/default/module_config = new
	var/list/module_factory_types = module_config.get_module_factory_types()
	if(!module_factory_types[/datum/human_ai_module/halo_covenant])
		return Fail("HALO Covenant module is missing from the Human AI factory.")
	if(!module_factory_types[/datum/human_ai_module/halo_unggoy])
		return Fail("HALO Unggoy module is missing from the Human AI factory.")
	if(!module_factory_types[/datum/human_ai_module/halo_sangheili])
		return Fail("HALO Sangheili module is missing from the Human AI factory.")

	if(!validate_species_policy(
		module_config,
		/datum/equipment_preset/covenant/sangheili/minor,
		/datum/ai_action/sangheili_sword_charge,
		/datum/human_ai_module/halo_sangheili,
	))
		return
	if(!validate_species_policy(
		module_config,
		/datum/equipment_preset/covenant/unggoy/minor,
		/datum/ai_action/unggoy_panic_retreat,
		/datum/human_ai_module/halo_unggoy,
	))
		return

	var/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber/suicide_preset = new
	module_config.read_action_policy(suicide_preset)
	if(!(/datum/ai_action/unggoy_suicide_bomber in module_config.action_whitelist))
		return Fail("Unggoy suicide preset is missing its charge action.")
	if(/datum/ai_action/throw_grenade in module_config.get_effective_action_types())
		return Fail("Unggoy suicide preset can still select the generic grenade action.")
	var/list/suicide_modules = module_config.get_module_types_to_setup()
	if(!(/datum/human_ai_module/halo_unggoy in suicide_modules))
		return Fail("Unggoy suicide action did not compose the Unggoy module.")
	if(!(/datum/human_ai_module/inventory in suicide_modules))
		return Fail("Unggoy suicide action did not compose inventory support.")

	qdel(suicide_preset)
	qdel(module_config)

/datum/unit_test/halo_ai_composition/proc/validate_species_policy(datum/human_ai_module_config/default/module_config, preset_type, action_type, module_type)
	var/datum/equipment_preset/preset = new preset_type
	module_config.read_action_policy(preset)
	if(!(action_type in module_config.action_whitelist))
		Fail("[preset_type] is missing HALO action [action_type].")
		qdel(preset)
		return FALSE
	var/list/module_types = module_config.get_module_types_to_setup()
	if(!(module_type in module_types))
		Fail("[preset_type] action policy did not compose [module_type].")
		qdel(preset)
		return FALSE
	qdel(preset)
	return TRUE

#endif
