/datum/unit_test/proc/assert_human_ai_localized_lines(list/lines, context, allow_empty = FALSE)
	var/static/list/allowed_emotes = list("*warcry", "*pain", "*scream")
	var/static/regex/latin_regex = regex("\[A-Za-z\]")

	if(!allow_empty)
		if(!length(lines))
			Fail("[context] unexpectedly resolved to an empty line list.", __FILE__, __LINE__)
			return

	for(var/line as anything in lines)
		if(!istext(line))
			Fail("[context] contains a non-text entry: [line]", __FILE__, __LINE__)
			return

		if(line in allowed_emotes)
			continue

		if(latin_regex.Find(line))
			Fail("[context] leaked a Latin-script line: [line]", __FILE__, __LINE__)
			return

/datum/unit_test/proc/get_localization_modpack()
	var/datum/modpack/localization/localization_pack
	if(SSmodpacks)
		localization_pack = SSmodpacks.get_modpack(/datum/modpack/localization)
	TEST_ASSERT_NOTNULL(localization_pack, "Failed to resolve the Localization modpack.")
	return localization_pack

/datum/unit_test/proc/get_human_ai_line_bank(datum/source, key)
	if(!source || !key)
		return null

	var/list/line_bank = source.vars[key]
	return line_bank

/datum/unit_test/halo_ai_localization/proc/create_human_ai_brain_for_faction(faction_name)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	human.faction = faction_name
	var/datum/component/human_ai/ai_component = human.AddComponent(/datum/component/human_ai)
	if(!ai_component)
		TEST_FAIL("Failed to add a human AI component to the localization test human for [faction_name].")
		return null
	if(!ai_component.ai_brain)
		TEST_FAIL("Failed to resolve a human AI brain for [faction_name].")
		return null
	return ai_component.ai_brain

/datum/unit_test/halo_ai_localization/Run()
	return

/datum/unit_test/halo_ai_localization_faction_banks
	parent_type = /datum/unit_test/halo_ai_localization

/datum/unit_test/halo_ai_localization_faction_banks/Run()
	var/datum/modpack/localization/localization_pack = get_localization_modpack()
	var/list/representative_factions = list(
		FACTION_COLONIST,
		FACTION_CONTRACTOR,
		FACTION_TWE_REBEL,
		FACTION_UA_REBEL,
		FACTION_MARSHAL,
		FACTION_MARINE,
		FACTION_ARMY,
		FACTION_NAVY,
		FACTION_UPP,
		FACTION_WY,
		FACTION_WY_DEATHSQUAD,
		FACTION_TWE,
		FACTION_XENOMORPH,
		FACTION_ZOMBIE,
		FACTION_UNSC,
		FACTION_UNSCN,
		FACTION_ONI,
		FACTION_UEG_POLICE,
		FACTION_INSURGENT,
		FACTION_COVENANT,
	)

	for(var/faction_name as anything in representative_factions)
		var/datum/human_ai_faction/faction_datum = SShuman_ai.human_ai_factions[faction_name]
		TEST_ASSERT_NOTNULL(faction_datum, "Failed to resolve [faction_name] from the Human AI faction registry.")

		var/list/expected_pack = localization_pack.halo_ai_get_faction_localization_pack(faction_name)
		TEST_ASSERT(islist(expected_pack), "No localization pack was returned for [faction_name].")

		for(var/key in localization_pack.halo_ai_line_pack_keys())
			var/list/expected_lines = expected_pack[key]
			if(!islist(expected_lines) || !length(expected_lines))
				continue

			var/list/actual_lines = faction_datum.vars[key]
			TEST_ASSERT(islist(actual_lines), "[faction_name] did not expose a list for [key].")
			assert_human_ai_localized_lines(actual_lines, "[faction_name] [key]")

/datum/unit_test/halo_ai_localization_brain_fallback
	parent_type = /datum/unit_test/halo_ai_localization

/datum/unit_test/halo_ai_localization_brain_fallback/Run()
	var/datum/modpack/localization/localization_pack = get_localization_modpack()
	var/datum/human_ai_faction/deathsquad_faction = SShuman_ai.human_ai_factions[FACTION_WY_DEATHSQUAD]
	TEST_ASSERT_NOTNULL(deathsquad_faction, "Failed to resolve the WY deathsquad faction for fallback testing.")
	var/list/deathsquad_reload_lines = get_human_ai_line_bank(deathsquad_faction, "reload_lines")
	TEST_ASSERT_EQUAL(length(deathsquad_reload_lines), 0, "WY deathsquad reload lines should stay empty at the faction layer so the fallback path remains testable.")

	var/datum/human_ai_brain/deathsquad_brain = create_human_ai_brain_for_faction(FACTION_WY_DEATHSQUAD)
	TEST_ASSERT_NOTNULL(deathsquad_brain, "Failed to create the WY deathsquad AI brain for fallback testing.")
	assert_human_ai_localized_lines(deathsquad_brain.enter_combat_lines, "WY deathsquad enter_combat_lines")
	assert_human_ai_localized_lines(deathsquad_brain.reload_lines, "WY deathsquad reload fallback")
	var/list/deathsquad_enter_combat_lines = get_human_ai_line_bank(deathsquad_faction, "enter_combat_lines")
	TEST_ASSERT_EQUAL(deathsquad_brain.enter_combat_lines[1], deathsquad_enter_combat_lines[1], "Fallback should not replace existing faction combat lines.")

	var/datum/human_ai_brain/malf_brain = create_human_ai_brain_for_faction(FACTION_MALF_SYNTH)
	TEST_ASSERT_NOTNULL(malf_brain, "Failed to create the malfunctioning synth AI brain for fallback testing.")
	for(var/key in localization_pack.halo_ai_line_pack_keys())
		var/list/brain_lines = malf_brain.vars[key]
		assert_human_ai_localized_lines(brain_lines, "Malf synth fallback [key]")
