// The Azure-16 platoon uses Commando credentials and training without changing other PMC squads.
/datum/equipment_preset/uscm/pmc/onyx_commando
	name = "Commando Tactical Unit"
	assignment = JOB_PMCPLAT_SMALL_STANDARD
	rank = JOB_PMCPLAT_SMALL_STANDARD
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COM = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/onyx_commando/engineer
	name = "Commando Corporate Engineer"
	assignment = JOB_PMCPLAT_SMALL_ENGINEER
	rank = JOB_PMCPLAT_SMALL_ENGINEER
	role_comm_title = "ENG"
	access = list(ACCESS_WY_GENERAL, ACCESS_WY_ENGINEERING)
	skills = /datum/skills/pmc/engineer

/datum/equipment_preset/uscm/pmc/onyx_commando/dogcatcher
	name = "Commando Dog Catcher"
	assignment = JOB_PMCPLAT_SMALL_DOGCATCHER
	rank = JOB_PMCPLAT_SMALL_DOGCATCHER
	role_comm_title = "DOG"
	paygrades = list(PAY_SHORT_WY_DOG = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/dogcatcher

/datum/equipment_preset/uscm/pmc/sl/onyx_commando
	name = "Commando Operations Leader"
	assignment = JOB_PMCPLAT_SMALL_LEADER
	rank = JOB_PMCPLAT_SMALL_LEADER
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COMLD = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/leader
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/tl/onyx_commando
	name = "Commando Team Leader"
	assignment = JOB_PMCPLAT_SMALL_FTL
	rank = JOB_PMCPLAT_SMALL_FTL
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COMLD = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/leader
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/sg/onyx_commando
	name = "Commando Heavy Weapons Specialist"
	assignment = JOB_PMCPLAT_SMALL_SG
	rank = JOB_PMCPLAT_SMALL_SG
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_GUN = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/gunner
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/med/onyx_commando
	name = "Commando Medical Unit"
	assignment = JOB_PMCPLAT_SMALL_MEDIC
	rank = JOB_PMCPLAT_SMALL_MEDIC
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COM = JOB_PLAYTIME_TIER_0)
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/job/marine/standard/ai/pmc/small
	gear_preset = /datum/equipment_preset/uscm/pmc/onyx_commando

/datum/job/marine/tl/ai/pmc/small
	gear_preset = /datum/equipment_preset/uscm/pmc/tl/onyx_commando

/datum/job/marine/smartgunner/ai/pmc/small
	gear_preset = /datum/equipment_preset/uscm/pmc/sg/onyx_commando

/datum/job/marine/medic/ai/pmc/small
	gear_preset = /datum/equipment_preset/uscm/pmc/med/onyx_commando

/datum/job/marine/leader/ai/pmc/small
	gear_preset = /datum/equipment_preset/uscm/pmc/sl/onyx_commando

/datum/job/marine/engineer/ai/pmc/small
	title = JOB_PMCPLAT_SMALL_ENGINEER
	total_positions = 1
	spawn_positions = 1
	job_options = null
	gear_preset = /datum/equipment_preset/uscm/pmc/onyx_commando/engineer

/datum/job/marine/standard/ai/pmc/small/dogcatcher
	title = JOB_PMCPLAT_SMALL_DOGCATCHER
	total_positions = 1
	spawn_positions = 1
	gear_preset = /datum/equipment_preset/uscm/pmc/onyx_commando/dogcatcher

/obj/effect/landmark/start/marine/engineer/pmc/small
	name = JOB_PMCPLAT_SMALL_ENGINEER
	squad = SQUAD_PMCPLT_SMALL
	job = /datum/job/marine/engineer/ai/pmc/small

/obj/effect/landmark/start/marine/pmc/small/dogcatcher
	name = JOB_PMCPLAT_SMALL_DOGCATCHER
	job = /datum/job/marine/standard/ai/pmc/small/dogcatcher
