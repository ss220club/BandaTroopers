#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/halo_ai_runtime_coverage

/datum/unit_test/halo_ai_runtime_coverage/Run()
	validate_grenade_throwback_rules()

	var/list/human_ai_presets = list(
		/datum/human_ai_equipment_preset/covenant/sangheili/minor = FACTION_SANGHEILI,
		/datum/human_ai_equipment_preset/covenant/sangheili/stealth = FACTION_SPECOPS_SANGHEILI,
		/datum/human_ai_equipment_preset/covenant/sangheili/stealth_zealot = FACTION_SPECOPS_SANGHEILI,
		/datum/human_ai_equipment_preset/covenant/sangheili/honor_guard = FACTION_SANGHEILI,
		/datum/human_ai_equipment_preset/covenant/unggoy/heavy/needler = FACTION_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/heavy/plasma_rifle = FACTION_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops/needler = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops/plasma_rifle = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops/plasma_rifle/cloaked = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops_lesser = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops_ultra/needler = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle/cloaked = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/specops_unggoy/specops/plasma_pistol = FACTION_SPECOPS_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/unggoy/suicide_bomber = FACTION_UNGGOY,
		/datum/human_ai_equipment_preset/covenant/ruuhtian/minor = FACTION_KIGYAR,
		/datum/human_ai_equipment_preset/covenant/ruuhtian/major/plasma_rifle = FACTION_KIGYAR,
		/datum/human_ai_equipment_preset/covenant/ruuhtian/marksman = FACTION_KIGYAR,
		/datum/human_ai_equipment_preset/unsc/squadleader = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/odst/spnkr = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/spartan/assault = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/spartan/cqc = FACTION_UNSC,
		/datum/human_ai_equipment_preset/unsc/spartan/spnkr = FACTION_UNSC,
		/datum/human_ai_equipment_preset/oni/security = FACTION_ONI,
		/datum/human_ai_equipment_preset/oni/security/sl = FACTION_ONI,
		/datum/human_ai_equipment_preset/oni/field/agent/senior = FACTION_ONI,
		/datum/human_ai_equipment_preset/police/officer/geared/smg = FACTION_UEG_POLICE,
		/datum/human_ai_equipment_preset/police/officer/sergeant/geared = FACTION_UEG_POLICE,
		/datum/human_ai_equipment_preset/insurgent/specialist = FACTION_INSURGENT,
		/datum/human_ai_equipment_preset/insurgent/breacher = FACTION_INSURGENT,
		/datum/human_ai_equipment_preset/insurgent/sl = FACTION_INSURGENT,
	)
	for(var/ai_preset_path as anything in human_ai_presets)
		validate_human_ai_preset(ai_preset_path, human_ai_presets[ai_preset_path])

	validate_halo_covenant_friendship_matrix()

	var/list/squad_presets = list(
		/datum/human_ai_squad_preset/covenant/unggoy_levy,
		/datum/human_ai_squad_preset/covenant/unggoy_lance,
		/datum/human_ai_squad_preset/covenant/ruuhtian_sniper_cell,
		/datum/human_ai_squad_preset/covenant/covenant_specops_strike_cell,
		/datum/human_ai_squad_preset/covenant/kigyar_raider_lance,
		/datum/human_ai_squad_preset/unsc/sniper,
		/datum/human_ai_squad_preset/unsc/atteam,
		/datum/human_ai_squad_preset/unsc/support_section,
		/datum/human_ai_squad_preset/unsc/spartan/sniper_cell,
		/datum/human_ai_squad_preset/unsc/spartan/strike_team,
		/datum/human_ai_squad_preset/unsc/odst/sniper,
		/datum/human_ai_squad_preset/unsc/odst/atteam,
		/datum/human_ai_squad_preset/unsc/odst/strike_team,
		/datum/human_ai_squad_preset/oni/field_cell,
		/datum/human_ai_squad_preset/police/enforcer_response,
		/datum/human_ai_squad_preset/insurgent/command_cell,
	)
	for(var/squad_preset_path as anything in squad_presets)
		validate_squad_preset(squad_preset_path)

/datum/unit_test/halo_ai_runtime_coverage/proc/create_test_human()
	return new /mob/living/carbon/human(run_loc_floor_bottom_left)

/datum/unit_test/halo_ai_runtime_coverage/proc/validate_grenade_throwback_rules()
	var/list/preset_expectations = list(
		/datum/equipment_preset/covenant/unggoy/minor = FALSE,
		/datum/equipment_preset/covenant/sangheili/minor = TRUE,
		/datum/equipment_preset/covenant/ruuhtian/minor = TRUE,
		/datum/equipment_preset/unsc/pfc/equipped = TRUE,
		/datum/equipment_preset/insurgent/partisan = FALSE,
		/datum/equipment_preset/insurgent/rifleman = TRUE,
		/datum/equipment_preset/survivor = FALSE,
		/datum/equipment_preset/colonist/bluecollar = FALSE,
		/datum/equipment_preset/colonist/security = FALSE,
		/datum/equipment_preset/colonist/security/guard = TRUE,
		/datum/equipment_preset/police/officer = FALSE,
		/datum/equipment_preset/police/officer/geared/smg = TRUE,
		/datum/equipment_preset/upp/militia = FALSE,
		/datum/equipment_preset/upp/rifleman = TRUE,
		/datum/equipment_preset/canc/remnant/lowgear = FALSE,
		/datum/equipment_preset/canc/remnant = TRUE,
		/datum/equipment_preset/unsc_crew/generic = FALSE,
		/datum/equipment_preset/synth/working_joe/upp = FALSE,
		/datum/equipment_preset/synth/working_joe/upp/combat = TRUE,
	)

	for(var/preset_path as anything in preset_expectations)
		validate_grenade_throwback_rule(preset_path, preset_expectations[preset_path])

/datum/unit_test/halo_ai_runtime_coverage/proc/validate_grenade_throwback_rule(preset_path, expected_can_throw_back)
	var/mob/living/carbon/human/test_human = create_test_human()
	var/datum/equipment_preset/preset = new preset_path
	var/datum/human_ai_brain/brain = new(test_human)
	if(hascall(preset, "modular_apply_human_ai_brain_capabilities"))
		call(preset, "modular_apply_human_ai_brain_capabilities")(brain, test_human)
	if(hascall(preset, "modular_apply_human_ai_brain_overrides"))
		call(preset, "modular_apply_human_ai_brain_overrides")(brain, test_human)
	var/datum/human_ai_module/grenade/grenade_module = brain.get_grenade_module()
	if(grenade_module?.can_throw_back_grenades != expected_can_throw_back)
		Fail("[preset_path] expected can_throw_back_grenades [expected_can_throw_back], got [grenade_module?.can_throw_back_grenades]", __FILE__, __LINE__)
	qdel(brain)
	qdel(test_human)
	qdel(preset)

/datum/unit_test/halo_ai_runtime_coverage/proc/validate_human_ai_preset(ai_preset_path, expected_faction)
	if(!ispath(ai_preset_path, /datum/human_ai_equipment_preset))
		Fail("[ai_preset_path] is not a HumanAI preset path", __FILE__, __LINE__)
		return
	var/datum/human_ai_equipment_preset/ai_preset = new ai_preset_path
	if(ai_preset.faction != expected_faction)
		Fail("[ai_preset_path] expected faction [expected_faction], got [ai_preset.faction]", __FILE__, __LINE__)
	if(!ispath(ai_preset.path, /datum/equipment_preset))
		Fail("[ai_preset_path] points to missing equipment preset [ai_preset.path]", __FILE__, __LINE__)
	qdel(ai_preset)

/datum/unit_test/halo_ai_runtime_coverage/proc/validate_halo_covenant_friendship_matrix()
	if(!SShuman_ai)
		Fail("HALO Covenant faction friendship matrix could not be validated without SShuman_ai", __FILE__, __LINE__)
		return

	var/list/covenant_factions = list(
		FACTION_COVENANT,
		FACTION_UNGGOY,
		FACTION_KIGYAR,
		FACTION_SANGHEILI,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_KIGYAR,
		FACTION_SPECOPS_UNGGOY,
	)

	for(var/faction_name as anything in covenant_factions)
		var/datum/human_ai_faction/faction_datum = SShuman_ai.human_ai_factions[faction_name]
		if(!faction_datum)
			Fail("HALO Covenant faction [faction_name] is missing from SShuman_ai", __FILE__, __LINE__)
			continue

		var/list/friendly_factions = faction_datum.get_friendly_factions()
		for(var/other_faction as anything in covenant_factions)
			if(other_faction == faction_name)
				continue
			if(!(other_faction in friendly_factions))
				Fail("HALO Covenant faction [faction_name] does not treat [other_faction] as friendly", __FILE__, __LINE__)

/datum/unit_test/halo_ai_runtime_coverage/proc/validate_squad_preset(squad_preset_path)
	if(!ispath(squad_preset_path, /datum/human_ai_squad_preset))
		Fail("[squad_preset_path] is not a HumanAI squad preset path", __FILE__, __LINE__)
		return
	var/datum/human_ai_squad_preset/squad_preset = new squad_preset_path
	if(!length(squad_preset.ai_to_spawn))
		Fail("[squad_preset_path] has no equipment presets", __FILE__, __LINE__)
	for(var/equipment_preset_path as anything in squad_preset.ai_to_spawn)
		if(!ispath(equipment_preset_path, /datum/equipment_preset))
			Fail("[squad_preset_path] points to missing equipment preset [equipment_preset_path]", __FILE__, __LINE__)
	qdel(squad_preset)

#endif
