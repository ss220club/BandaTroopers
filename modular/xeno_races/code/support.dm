GLOBAL_LIST_EMPTY(xeno_race_caste_mobs)
GLOBAL_LIST_EMPTY(xeno_race_ai_spawnables)

GLOBAL_LIST_INIT(resin_build_order_pathogen_overmind, list(
	/datum/resin_construction/resin_turf/wall/pathogen/overmind,
	/datum/resin_construction/resin_turf/membrane/pathogen/overmind,
	/datum/resin_construction/resin_obj/door/pathogen/overmind,
	/datum/resin_construction/resin_obj/popper_cocoon
))

GLOBAL_LIST_INIT(resin_build_order_pathogen_base, list(
	/datum/resin_construction/resin_turf/wall/pathogen,
	/datum/resin_construction/resin_turf/membrane/pathogen,
	/datum/resin_construction/resin_obj/door/pathogen
))

GLOBAL_LIST_INIT(resin_build_order_pathogen_better, list(
	/datum/resin_construction/resin_turf/wall/pathogen/thick,
	/datum/resin_construction/resin_turf/membrane/pathogen/thick,
	/datum/resin_construction/resin_obj/door/pathogen/thick
))

GLOBAL_VAR_INIT(overmind_cancel, FALSE)

/mob/living
	/// Optional alternate weed merge icon used by Pathogen weeds.
	var/mycelium_food_icon = 'modular/xeno_races/icons/mob/pathogen/pathogen_weeds.dmi'

/mob/living/get_weed_food_icon(obj/effect/alien/weeds/absorbing_weeds)
	if(absorbing_weeds?.hivenumber == XENO_HIVE_PATHOGEN)
		return mycelium_food_icon
	return ..()

/mob/living/proc/grant_spawn_protection(duration)
	status_flags |= GODMODE
	RegisterSignal(src, list(COMSIG_LIVING_FLAMER_CROSSED, COMSIG_LIVING_FLAMER_FLAMED), PROC_REF(handle_fire_protection))
	addtimer(CALLBACK(src, PROC_REF(end_spawn_protection)), duration)

/mob/living/proc/end_spawn_protection()
	status_flags &= ~GODMODE
	UnregisterSignal(src, list(COMSIG_LIVING_FLAMER_CROSSED, COMSIG_LIVING_FLAMER_FLAMED))

/mob/living/proc/handle_fire_protection(mob/living/living, datum/reagent/chem)
	SIGNAL_HANDLER
	if(status_flags & GODMODE)
		return COMPONENT_NO_IGNITE

/obj/item/organ/xeno/pathogen
	name = "mycelium heart"
	desc = "Mycelium heart removed from a strange creature."
	black_market_value = 120

/mob/living/carbon/xenomorph/get_xeno_organ_type()
	if(hivenumber == XENO_HIVE_PATHOGEN)
		return /obj/item/organ/xeno/pathogen
	return ..()

/mob/living/carbon/xenomorph/apply_modular_xeno_name()
	if(HAS_TRAIT(src, TRAIT_PATHOGEN_OVERMIND))
		name = "Overmind ([full_designation])"
		return TRUE
	return ..()

/mob/living/carbon/xenomorph/after_set_hive_and_update(new_hivenumber)
	if(new_hivenumber == XENO_HIVE_PATHOGEN)
		make_pathogen_speaker()
		return TRUE
	return ..()

/mob/living/carbon/xenomorph/get_weed_type()
	if(hivenumber == XENO_HIVE_PATHOGEN)
		return /obj/effect/alien/weeds/pathogen
	return ..()

/mob/living/carbon/xenomorph/get_weed_node_type()
	if(hivenumber == XENO_HIVE_PATHOGEN)
		return /obj/effect/alien/weeds/node/pathogen
	return ..()

/datum/hive_status/pathogen
	name = FACTION_PATHOGEN
	var/max_poppers = 8
	var/matriarch_enabled = FALSE
	var/last_overmind
	reporting_id = "pathogen"
	hivenumber = XENO_HIVE_PATHOGEN
	prefix = ""
	color = "#bdc9c4"
	ui_color = "#bdc9c4"

	hive_inherant_traits = list(TRAIT_NO_COLOR)
	latejoin_burrowed = FALSE
	allow_no_queen_actions = TRUE
	allow_queen_evolve = FALSE
	allow_no_queen_evo = TRUE
	queen_leader_limit = 5

	destruction_allowed = NORMAL_XENO

	larva_gestation_multiplier = 1.5
	hive_orders = "Kill everyone and everything."

	free_slots = list(
		/datum/caste_datum/pathogen/neomorph = 6,
		/datum/caste_datum/pathogen/blight = 4,
		/datum/caste_datum/pathogen/brute = 1,
		/datum/caste_datum/pathogen/venator = 2,
		/datum/caste_datum/pathogen/conditor = 2,
	)

	restricted_castes = list(
		PATHOGEN_CREATURE_ARCHON = 1,
		PATHOGEN_CREATURE_HARBINGER = 2,
	)
	blacklisted_castes = ALL_XENO_CASTES

	hive_structures_limit = list(
		PATHOGEN_STRUCTURE_CORE = 1,
		PATHOGEN_STRUCTURE_COCOON = 6,
		PATHOGEN_STRUCTURE_CLUSTER = 8,
		PATHOGEN_STRUCTURE_PYLON = 2,
		PATHOGEN_STRUCTURE_RECOVERY = 6,
		PATHOGEN_STRUCTURE_PLASMA = 3,
		PATHOGEN_STRUCTURE_SPORECASTER = 3,
		PATHOGEN_STRUCTURE_FOGGER = 3,
	)

	hive_structure_types = list(
		PATHOGEN_STRUCTURE_CORE = /datum/construction_template/xenomorph/pathogen_core,
		PATHOGEN_STRUCTURE_CLUSTER = /datum/construction_template/xenomorph/pathogen_cluster,
		PATHOGEN_STRUCTURE_RECOVERY = /datum/construction_template/xenomorph/patho_recovery,
		PATHOGEN_STRUCTURE_PLASMA = /datum/construction_template/xenomorph/patho_plasma,
		PATHOGEN_STRUCTURE_SPORECASTER = /datum/construction_template/xenomorph/sporecaster,
		PATHOGEN_STRUCTURE_FOGGER = /datum/construction_template/xenomorph/fogger
	)

/datum/hive_status/pathogen/New()
	. = ..()
	blacklisted_castes -= ALL_PATHOGEN_CREATURES

/datum/hive_status/pathogen/get_xeno_counts()
	var/list/xeno_counts = list(
		list(PATHOGEN_CREATURE_BURSTER = 0, PATHOGEN_CREATURE_POPPER = 0, PATHOGEN_CREATURE_ARCHON = 0),
		list(PATHOGEN_CREATURE_NEOPHYTE = 0, PATHOGEN_CREATURE_SPRINTER = 0),
		list(PATHOGEN_CREATURE_NEOMORPH = 0, PATHOGEN_CREATURE_BLIGHT = 0),
		list(PATHOGEN_CREATURE_CONDITOR = 0, PATHOGEN_CREATURE_BRUTE = 0, PATHOGEN_CREATURE_VENATOR = 0, PATHOGEN_CREATURE_HARBINGER = 0)
	)

	for(var/mob/living/carbon/xenomorph/xeno as anything in totalXenos)
		if(should_block_game_interaction(xeno))
			var/area/current_area = get_area(xeno)
			if(!(current_area.flags_atom & AREA_ALLOW_XENO_JOIN))
				continue

		if(xeno.caste && xeno.counts_for_slots)
			xeno_counts[xeno.caste.tier + 1][xeno.caste.caste_type]++

	return xeno_counts

/datum/hive_status/pathogen/set_hive_location(obj/effect/alien/resin/special/pylon/core/core)
	if(!core || core == hive_location)
		return

	var/area/core_area = get_area(core)
	xeno_message(SPAN_XENOANNOUNCE("The confluence location has been set as \the [core_area]."), 3, hivenumber)
	hive_location = core
	hive_ui.update_hive_location()
