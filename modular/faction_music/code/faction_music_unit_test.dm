/datum/unit_test/faction_music_resolver/Run()
	if(get_faction_music_key_for_values(JOB_SQUAD_MARINE_ODST, FACTION_UNSC) != "ODST")
		Fail("ODST jobs must take precedence over the generic UNSC faction.", __FILE__, __LINE__)
	if(get_faction_music_key_for_values(null, FACTION_UNSC) != "UNSC")
		Fail("Non-ODST UNSC roles must use the independent UNSC music key.", __FILE__, __LINE__)
	if(get_faction_music_key_for_values(JOB_UACG_MEDIC, FACTION_COLONIST) != "COLONIAL_MILITIA")
		Fail("Colonial militia jobs must resolve independently of their inherited faction.", __FILE__, __LINE__)
	if(get_faction_music_key_for_values(null, FACTION_WY) != "WY")
		Fail("Weyland-Yutani must use the stable WY music key.", __FILE__, __LINE__)
	if(get_faction_music_key_for_values(null, FACTION_PMC) != "PMC")
		Fail("PMC must retain its distinct music key.", __FILE__, __LINE__)
	if(!isnull(get_faction_music_key_for_values(null, FACTION_UNSCN)))
		Fail("Unconfigured factions must remain silent instead of borrowing another faction's music.", __FILE__, __LINE__)

	var/list/original_odst_tracks = GLOB.faction_music_tracks["ODST"]
	GLOB.faction_music_tracks["ODST"] = list()
	if(length(get_faction_music_tracks("ODST")))
		Fail("An empty ODST track list must not fall back to USCM music.", __FILE__, __LINE__)
	GLOB.faction_music_tracks["ODST"] = original_odst_tracks

	var/list/original_unsc_tracks = GLOB.faction_music_tracks["UNSC"]
	GLOB.faction_music_tracks["UNSC"] = list()
	if(length(get_faction_music_tracks("UNSC")))
		Fail("An empty UNSC track list must not fall back to USCM or ODST music.", __FILE__, __LINE__)
	GLOB.faction_music_tracks["UNSC"] = original_unsc_tracks
