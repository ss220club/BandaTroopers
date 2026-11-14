/datum/unit_test/pathogen_port

/datum/unit_test/pathogen_port/Run()
	var/datum/hive_status/pathogen/hive = GLOB.hive_datum[XENO_HIVE_PATHOGEN]
	if(!istype(hive))
		Fail("Pathogen hive is not registered", __FILE__, __LINE__)
		return

	var/list/castes = list(
		PATHOGEN_CREATURE_BURSTER = /mob/living/carbon/xenomorph/bloodburster,
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
		PATHOGEN_CREATURE_ABER_BURSTER = /mob/living/carbon/xenomorph/bloodburster/aberrant
	)
	for(var/caste_name in castes)
		if(GLOB.xeno_race_caste_mobs[caste_name] != castes[caste_name])
			Fail("[caste_name] not registered", __FILE__, __LINE__)
		if(!GLOB.xeno_datum_list[caste_name])
			Fail("[caste_name] has no caste datum", __FILE__, __LINE__)

	var/list/radial_states = icon_states('modular/xeno_races/icons/mob/xenos/pathogen_pr207_radial.dmi')
	if(!("template" in radial_states))
		Fail("Pathogen radial fallback missing", __FILE__, __LINE__)
	for(var/caste_name in castes)
		var/image/radial_image = hive.evolution_menu_images[caste_name]
		if(!radial_image || !(radial_image.icon_state in radial_states))
			Fail("[caste_name] radial icon missing", __FILE__, __LINE__)

	var/list/resin_types = list(
		/datum/resin_construction/resin_turf/wall/pathogen,
		/datum/resin_construction/resin_turf/wall/pathogen/thick,
		/datum/resin_construction/resin_turf/wall/pathogen/overmind,
		/datum/resin_construction/resin_turf/membrane/pathogen,
		/datum/resin_construction/resin_turf/membrane/pathogen/thick,
		/datum/resin_construction/resin_turf/membrane/pathogen/overmind,
		/datum/resin_construction/resin_obj/door/pathogen,
		/datum/resin_construction/resin_obj/door/pathogen/thick,
		/datum/resin_construction/resin_obj/door/pathogen/overmind,
		/datum/resin_construction/resin_obj/popper_cocoon
	)
	for(var/resin_path in resin_types)
		var/datum/resin_construction/resin = new resin_path()
		if(!(resin.get_construction_icon_state() in icon_states(resin.get_construction_icon())))
			Fail("[resin_path] UI icon missing", __FILE__, __LINE__)
		qdel(resin)
