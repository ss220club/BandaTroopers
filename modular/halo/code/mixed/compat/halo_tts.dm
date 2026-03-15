GLOBAL_LIST_INIT(halo_tts_seed_plans, list(
	SPECIES_SANGHEILI = list(
		"default" = "Alarak",
		"packs" = list(
			"Pack A (Recommended)" = list(
				"Alarak",
				"Arthas",
				"Malganis",
			),
			"Pack B" = list(
				"Arthas",
				"Alarak",
				"Sion",
			),
		),
	),
	SPECIES_UNGGOY = list(
		"default" = "Dobby",
		"packs" = list(
			"Pack A (Recommended)" = list(
				"Dobby",
				"Ziggs",
				"Twitch",
			),
			"Pack B" = list(
				"Ziggs",
				"Twitch",
				"Gazlowe",
			),
			"Pack C" = list(
				"Dobby",
				"Gazlowe",
				"Cicero",
			),
		),
	),
))

/proc/halo_get_tts_seed_plan(species_name)
	return GLOB.halo_tts_seed_plans[species_name]

/proc/halo_get_tts_seed_packs(species_name)
	var/list/tts_seed_plan = halo_get_tts_seed_plan(species_name)
	if(!islist(tts_seed_plan))
		return null

	return tts_seed_plan["packs"]

/proc/halo_get_default_tts_seed(species_name)
	var/list/tts_seed_plan = halo_get_tts_seed_plan(species_name)
	if(!islist(tts_seed_plan))
		return null

	return tts_seed_plan["default"]

/mob/living/carbon/human/proc/halo_apply_species_tts_seed()
	if(!species)
		return FALSE

	var/preferred_seed_name = client?.prefs?.tts_seed
	var/list/tts_seed_registry = SStts220?.tts_seeds
	if(!islist(tts_seed_registry))
		return FALSE

	if(preferred_seed_name && tts_seed_registry[preferred_seed_name])
		return FALSE

	var/seed_name = halo_get_default_tts_seed(species.name)
	if(!istext(seed_name) || !length(seed_name))
		return FALSE

	var/datum/tts_seed/default_seed = tts_seed_registry[seed_name]
	if(!default_seed)
		return FALSE

	AddComponent(/datum/component/tts_component, default_seed)
	tts_seed = default_seed
	return TRUE
