/datum/modpack/xeno_races
	name = "xeno races modpack"
	desc = "Ports Bodyburster/Lanky and Pathogen xenomorph race content."
	author = "OpenAI Codex, upstream cmss13-pve contributors"

/datum/modpack/xeno_races/initialize()
	if(!GLOB.hive_datum[XENO_HIVE_PATHOGEN])
		GLOB.hive_datum[XENO_HIVE_PATHOGEN] = new /datum/hive_status/pathogen()

	GLOB.xeno_race_caste_mobs = list(
		XENO_CASTE_BODYBURSTER = /mob/living/carbon/xenomorph/bodyburster,
		XENO_CASTE_LANKY = /mob/living/carbon/xenomorph/lanky,
		PATHOGEN_CREATURE_BURSTER = /mob/living/carbon/xenomorph/bloodburster,
		PATHOGEN_CREATURE_ABER_BURSTER = /mob/living/carbon/xenomorph/bloodburster/aberrant,
		PATHOGEN_CREATURE_SPRINTER = /mob/living/carbon/xenomorph/sprinter,
		PATHOGEN_CREATURE_NEOPHYTE = /mob/living/carbon/xenomorph/neophyte,
		PATHOGEN_CREATURE_POPPER = /mob/living/carbon/xenomorph/popper,
		PATHOGEN_CREATURE_NEOMORPH = /mob/living/carbon/xenomorph/neomorph,
		PATHOGEN_CREATURE_BLIGHT = /mob/living/carbon/xenomorph/blight,
		PATHOGEN_CREATURE_CONDITOR = /mob/living/carbon/xenomorph/conditor,
		PATHOGEN_CREATURE_BRUTE = /mob/living/carbon/xenomorph/brute,
		PATHOGEN_CREATURE_VENATOR = /mob/living/carbon/xenomorph/venator,
		PATHOGEN_CREATURE_HARBINGER = /mob/living/carbon/xenomorph/harbinger,
		PATHOGEN_CREATURE_MATRIARCH = /mob/living/carbon/xenomorph/matriarch,
		PATHOGEN_CREATURE_ABERRATION = /mob/living/carbon/xenomorph/aberration,
		PATHOGEN_CREATURE_ARCHON = /mob/living/carbon/xenomorph/archon,
	)
	GLOB.xeno_race_ai_spawnables = list(
		XENO_CASTE_BODYBURSTER,
		XENO_CASTE_LANKY,
		PATHOGEN_CREATURE_BURSTER,
		PATHOGEN_CREATURE_ABER_BURSTER,
		PATHOGEN_CREATURE_SPRINTER,
		PATHOGEN_CREATURE_NEOPHYTE,
		PATHOGEN_CREATURE_POPPER,
		PATHOGEN_CREATURE_NEOMORPH,
		PATHOGEN_CREATURE_BLIGHT,
		PATHOGEN_CREATURE_CONDITOR,
		PATHOGEN_CREATURE_BRUTE,
		PATHOGEN_CREATURE_VENATOR,
		PATHOGEN_CREATURE_HARBINGER,
		PATHOGEN_CREATURE_MATRIARCH,
		PATHOGEN_CREATURE_ABERRATION,
		PATHOGEN_CREATURE_ARCHON,
	)

	if(islist(GLOB.pp_transformables))
		GLOB.pp_transformables["Alien Tier 2"] += list(
			list(
				name = XENO_CASTE_BODYBURSTER,
				key = /mob/living/carbon/xenomorph/bodyburster,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Alien Tier 3"] += list(
			list(
				name = XENO_CASTE_LANKY,
				key = /mob/living/carbon/xenomorph/lanky,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 0"] = list(
			list(
				name = PATHOGEN_CREATURE_BURSTER,
				key = /mob/living/carbon/xenomorph/bloodburster,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 1"] = list(
			list(
				name = PATHOGEN_CREATURE_SPRINTER,
				key = /mob/living/carbon/xenomorph/sprinter,
				color = "purple"
			),
			list(
				name = PATHOGEN_CREATURE_POPPER,
				key = /mob/living/carbon/xenomorph/popper,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 2"] = list(
			list(
				name = PATHOGEN_CREATURE_NEOMORPH,
				key = /mob/living/carbon/xenomorph/neomorph,
				color = "purple"
			),
			list(
				name = PATHOGEN_CREATURE_BLIGHT,
				key = /mob/living/carbon/xenomorph/blight,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 3"] = list(
			list(
				name = PATHOGEN_CREATURE_BRUTE,
				key = /mob/living/carbon/xenomorph/brute,
				color = "purple"
			),
			list(
				name = PATHOGEN_CREATURE_VENATOR,
				key = /mob/living/carbon/xenomorph/venator,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 1"] += list(list(name = PATHOGEN_CREATURE_NEOPHYTE, key = /mob/living/carbon/xenomorph/neophyte, color = "purple"))
		GLOB.pp_transformables["Pathogen Tier 3"] += list(
			list(name = PATHOGEN_CREATURE_CONDITOR, key = /mob/living/carbon/xenomorph/conditor, color = "purple"),
			list(name = PATHOGEN_CREATURE_HARBINGER, key = /mob/living/carbon/xenomorph/harbinger, color = "purple")
		)
		GLOB.pp_transformables["Pathogen Exotic"] = list(
			list(name = PATHOGEN_CREATURE_ABER_BURSTER, key = /mob/living/carbon/xenomorph/bloodburster/aberrant, color = "purple"),
			list(name = PATHOGEN_CREATURE_ABERRATION, key = /mob/living/carbon/xenomorph/aberration, color = "purple"),
			list(name = PATHOGEN_CREATURE_MATRIARCH, key = /mob/living/carbon/xenomorph/matriarch, color = "purple"),
			list(name = PATHOGEN_CREATURE_ARCHON, key = /mob/living/carbon/xenomorph/archon, color = "purple")
		)

	var/datum/hive_status/main_hive = GLOB.hive_datum[XENO_HIVE_NORMAL]
	if(main_hive?.evolution_menu_images)
		var/list/pathogen_radial_states = icon_states('modular/xeno_races/icons/mob/xenos/pathogen_pr207_radial.dmi')
		for(var/caste_name in ALL_PATHOGEN_CREATURES)
			var/radial_state = (caste_name in pathogen_radial_states) ? caste_name : "template"
			main_hive.evolution_menu_images[caste_name] = image('modular/xeno_races/icons/mob/xenos/pathogen_pr207_radial.dmi', radial_state)

	var/datum/hive_status/pathogen/pathogen_hive = GLOB.hive_datum[XENO_HIVE_PATHOGEN]
	if(pathogen_hive)
		pathogen_hive.hive_structure_types[PATHOGEN_STRUCTURE_CORE] = /datum/construction_template/xenomorph/pathogen_core

	return

/proc/xeno_races_get_embryo_registry()
	return list(
		"standard" = list(
			"label" = "Standard",
			"embryo_type" = /obj/item/alien_embryo,
			"xeno_type" = /mob/living/carbon/xenomorph/larva,
		),
		"bodyburster" = list(
			"label" = "Bodyburster",
			"embryo_type" = /obj/item/alien_embryo/bodyburster,
			"xeno_type" = /mob/living/carbon/xenomorph/bodyburster,
		),
	)

/proc/xeno_races_get_embryo_type(token)
	var/list/registry = xeno_races_get_embryo_registry()
	var/list/entry = registry[token]
	if(entry)
		return entry["embryo_type"]
	return registry["standard"]["embryo_type"]

/proc/xeno_races_get_embryo_xeno_type(token)
	var/list/registry = xeno_races_get_embryo_registry()
	var/list/entry = registry[token]
	if(entry)
		return entry["xeno_type"]
	return registry["standard"]["xeno_type"]

/proc/xeno_races_get_embryo_options()
	var/list/registry = xeno_races_get_embryo_registry()
	var/list/options = list()
	for(var/token in registry)
		var/list/entry = registry[token]
		options += list(list(displayText = entry["label"], value = token))
	return options
