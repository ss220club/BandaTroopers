// The Azure-16 platoon uses Commando credentials and training without changing other PMC squads.
/datum/faction/pmc/proc/get_onyx_commando_hud_image(mob/living/carbon/human/human, role_title)
	var/icon_state
	switch(role_title)
		if(JOB_PMCPLAT_SMALL_STANDARD)
			icon_state = "commando_gun"
		if(JOB_PMCPLAT_SMALL_ENGINEER)
			icon_state = "commando_engineer"
		if(JOB_PMCPLAT_SMALL_MEDIC)
			icon_state = "commando_medic"
		if(JOB_PMCPLAT_SMALL_LEADER, JOB_PMCPLAT_SMALL_FTL)
			icon_state = "commando_leader"
		if(JOB_PMCPLAT_SMALL_SG)
			icon_state = "commando_sg"
		if(JOB_PMCPLAT_SMALL_DOGCATCHER)
			icon_state = "commando_dogcatcher"
	if(!icon_state)
		return null
	var/image/role_icon = image(base_icon_file, human, "pmc_[icon_state]")
	if(role_title == JOB_PMCPLAT_SMALL_FTL)
		role_icon.filters += outline_filter(1, "#FFD700", OUTLINE_SHARP)
	return role_icon

/datum/equipment_preset/uscm/pmc/onyx_commando
	name = "Commando Tactical Unit"
	assignment = JOB_PMCPLAT_SMALL_STANDARD
	rank = JOB_PMCPLAT_SMALL_STANDARD
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COM = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando
	minimap_icon = "pmc_gun"
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/onyx_commando/engineer
	name = "Commando Corporate Engineer"
	assignment = JOB_PMCPLAT_SMALL_ENGINEER
	rank = JOB_PMCPLAT_SMALL_ENGINEER
	role_comm_title = "ENG"
	access = list(ACCESS_WY_GENERAL, ACCESS_WY_ENGINEERING)
	skills = /datum/skills/pmc/engineer/onyx_commando

/datum/equipment_preset/uscm/pmc/onyx_commando/dogcatcher
	name = "Commando Dog Catcher"
	assignment = JOB_PMCPLAT_SMALL_DOGCATCHER
	rank = JOB_PMCPLAT_SMALL_DOGCATCHER
	role_comm_title = "DOG"
	paygrades = list(PAY_SHORT_WY_DOG = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/dogcatcher
	minimap_icon = "dogcather"

/datum/equipment_preset/uscm/pmc/sl/onyx_commando
	name = "Commando Operations Leader"
	assignment = JOB_PMCPLAT_SMALL_LEADER
	rank = JOB_PMCPLAT_SMALL_LEADER
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COMLD = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/leader
	minimap_icon = "pmc_ld"
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/tl/onyx_commando
	name = "Commando Team Leader"
	assignment = JOB_PMCPLAT_SMALL_FTL
	rank = JOB_PMCPLAT_SMALL_FTL
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COMLD = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/leader
	minimap_icon = "pmc_ld"
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/tl/onyx_commando/get_minimap_icon(mob/living/carbon/human/user)
	var/image/marker = ..()
	marker.filters += outline_filter(1, "#FFD700", OUTLINE_SHARP)
	return marker

/datum/equipment_preset/uscm/pmc/sg/onyx_commando
	name = "Commando Heavy Weapons Specialist"
	assignment = JOB_PMCPLAT_SMALL_SG
	rank = JOB_PMCPLAT_SMALL_SG
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_GUN = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/commando/gunner
	minimap_icon = "pmc_sg"
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/med/onyx_commando
	name = "Commando Medical Unit"
	assignment = JOB_PMCPLAT_SMALL_MEDIC
	rank = JOB_PMCPLAT_SMALL_MEDIC
	idtype = /obj/item/card/id/pmc/commando
	paygrades = list(PAY_SHORT_WY_COM = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pmc/medic/onyx_commando
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_TSL)

/datum/equipment_preset/uscm/pmc/med/onyx_commando/get_minimap_icon(mob/living/carbon/human/user)
	var/image/marker = ..()
	marker.filters += outline_filter(1, "#FFD700", OUTLINE_SHARP)
	return marker

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
