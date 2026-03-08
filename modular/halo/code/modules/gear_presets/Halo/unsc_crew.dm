/datum/equipment_preset/unsc_crew
	name = "UNSC crewmen personnel"
	faction = FACTION_UNSCN
	faction_group = FACTION_LIST_UNSC
	languages = list(LANGUAGE_ENGLISH)
	idtype = /obj/item/card/id/dogtag
	var/auto_squad_name_unsc
	var/ert_squad_halo = FALSE

/datum/equipment_preset/unsc_crew/load_name(mob/living/carbon/human/new_human, randomise)
	new_human.gender = pick(MALE, FEMALE)
	var/datum/preferences/A = new
	A.randomize_appearance(new_human)
	var/random_name = capitalize(pick(new_human.gender == MALE ? GLOB.first_names_male : GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	var/static/list/colors = list("BLACK" = list(15, 15, 10), "BROWN" = list(48, 38, 18), "BROWN" = list(48, 38, 18),"BLUE" = list(29, 51, 65), "GREEN" = list(40, 61, 39), "STEEL" = list(46, 59, 54))
	var/static/list/hair_colors = list("BLACK" = list(15, 15, 10), "BROWN" = list(48, 38, 18), "AUBURN" = list(77, 48, 36), "BLONDE" = list(95, 76, 44))
	var/hair_color = pick(hair_colors)
	new_human.r_hair = hair_colors[hair_color][1]
	new_human.g_hair = hair_colors[hair_color][2]
	new_human.b_hair = hair_colors[hair_color][3]
	new_human.r_facial = hair_colors[hair_color][1]
	new_human.g_facial = hair_colors[hair_color][2]
	new_human.b_facial = hair_colors[hair_color][3]
	var/eye_color = pick(colors)
	new_human.r_eyes = colors[eye_color][1]
	new_human.g_eyes = colors[eye_color][2]
	new_human.b_eyes = colors[eye_color][3]
	if(new_human.gender == MALE)
		new_human.h_style = pick("Undercut", "Partly Shaved", "Side Undercut", "Side Hang Undercut (Reverse)", "Undercut, Top", "Medium Fade", "High Fade", "Coffee House Cut")
		new_human.f_style = pick("Shaved", "Shaved", "Shaved", "3 O'clock Shadow", "3 O'clock Moustache", "5 O'clock Shadow", "5 O'clock Moustache", "7 O'clock Shadow", "7 O'clock Moustache",)
	else
		new_human.h_style = pick("Side Undercut", "Side Hang Undercut (Reverse)", "Undercut, Top", "CIA", "Mulder", "Pvt. Redding", "Pixie Cut Left", "Pixie Cut Right", "Bun")
	new_human.change_real_name(new_human, random_name)
	new_human.age = rand(20,35)
//*****************************************************************************************************/
//    UNSC CREW PRESETS


/datum/equipment_preset/unsc_crew/generic
	name = "UNSC Crewman"
	assignment = JOB_UNSC_CREW
	rank = JOB_UNSC_CREW
	paygrades = list(PAY_SHORT_NE3 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/CT

/datum/equipment_preset/unsc_crew/generic/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew(new_human), WEAR_BODY)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/engi
	name = "UNSC Engineering Technician"
	assignment = JOB_UNSC_CREW_ENGI
	rank = JOB_UNSC_CREW_ENGI
	paygrades = list(PAY_SHORT_NE4 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN ET"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/MT

/datum/equipment_preset/unsc_crew/engi/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/engi(new_human), WEAR_BODY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/engi/officer
	name = "UNSC Engineering Officer"
	assignment = JOB_UNSC_CREW_ENGI_CHIEF
	rank = JOB_UNSC_CREW_ENGI_CHIEF
	paygrades = list(PAY_SHORT_NO3 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN EO"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/CE

/datum/equipment_preset/unsc_crew/engi/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/engi/officer(new_human), WEAR_BODY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6c(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(new_human), WEAR_R_STORE)

/datum/equipment_preset/unsc_crew/flight
	name = "UNSC Flight-Deck Technician"
	assignment = JOB_UNSC_CREW_FLIGHT
	rank = JOB_UNSC_CREW_FLIGHT
	paygrades = list(PAY_SHORT_NE4 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN FT"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/flight_crew

/datum/equipment_preset/unsc_crew/flight/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/flight(new_human), WEAR_BODY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/flight/officer
	name = "UNSC Flight-Deck Officer"
	assignment = JOB_UNSC_CREW_FLIGHT_CHIEF
	rank = JOB_UNSC_CREW_FLIGHT_CHIEF
	paygrades = list(PAY_SHORT_NO2 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN FDO"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/flightboss

/datum/equipment_preset/unsc_crew/flight/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/flight/officer(new_human), WEAR_BODY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6c(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(new_human), WEAR_R_STORE)

/datum/equipment_preset/unsc_crew/operations
	name = "UNSC Operations Specialist"
	assignment = JOB_UNSC_CREW_OPS
	rank = JOB_UNSC_CREW_OPS
	paygrades = list(PAY_SHORT_NE4 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN OS"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/crew_chief

/datum/equipment_preset/unsc_crew/operations/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/operations(new_human), WEAR_BODY)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/operations/officer
	name = "UNSC Operations Officer"
	assignment = JOB_UNSC_CREW_OPS_CHIEF
	rank = JOB_UNSC_CREW_OPS_CHIEF
	paygrades = list(PAY_SHORT_NW1 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN OO"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/crew_chief

/datum/equipment_preset/unsc_crew/operations/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/operations/officer(new_human), WEAR_BODY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6c(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)

/datum/equipment_preset/unsc_crew/medical
	name = "UNSC Medical Specialist"
	assignment = JOB_UNSC_CREW_MED
	rank = JOB_UNSC_CREW_MED
	paygrades = list(PAY_SHORT_NE5 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN MS"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/doctor

/datum/equipment_preset/unsc_crew/medical/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer/halo(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/surgical_line(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/synthgraft(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/med(new_human), WEAR_BODY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/unsc/full(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/medical/officer
	name = "UNSC Chief Medical Officer"
	assignment = JOB_UNSC_CREW_MED_CHIEF
	rank = JOB_UNSC_CREW_MED_CHIEF
	paygrades = list(PAY_SHORT_NO6 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "CRMN CMO"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/CMO

/datum/equipment_preset/unsc_crew/medical/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer/halo(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/surgical_line(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/synthgraft(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/med/officer(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(new_human), WEAR_JACKET)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/unsc/full(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6c(new_human), WEAR_J_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)

/datum/equipment_preset/unsc_crew/command
	name = "UNSC Bridge Officer"
	assignment = JOB_UNSC_CREW_COM
	rank = JOB_UNSC_CREW_COM
	paygrades = list(PAY_SHORT_NO3 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "BO"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/SO

/datum/equipment_preset/unsc_crew/command/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/command(new_human), WEAR_BODY)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/command/weapons
	name = "UNSC Bridge Officer - Weapons"
	assignment = "UNSC Bridge Weapons Officer"

/datum/equipment_preset/unsc_crew/command/navigations
	name = "UNSC Bridge Officer - Navigations"
	assignment = "UNSC Bridge Navigation Officer"

/datum/equipment_preset/unsc_crew/command/communications
	name = "UNSC Bridge Officer - Communications"
	assignment = "UNSC Bridge Communications Officer"

/datum/equipment_preset/unsc_crew/command/xo
	name = "UNSC Bridge Officer - Executive Officer"
	assignment = JOB_UNSC_CREW_COM_XO
	rank = JOB_UNSC_CREW_COM_XO
	paygrades = list(PAY_SHORT_NO4 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc_crew/command/xo/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6g(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6g(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/command(new_human), WEAR_BODY)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6g(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/unsc_crew/command/xo/cpt
	name = "UNSC Bridge Officer - Captain"
	assignment = JOB_UNSC_CREW_COM_CPT
	rank = JOB_UNSC_CREW_COM_CPT
	paygrades = list(PAY_SHORT_NO5 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/unsc_crew/rnd
	name = "UNSC Science Officer"
	assignment = JOB_UNSC_CREW_RND
	rank = JOB_UNSC_CREW_RND
	paygrades = list(PAY_SHORT_NO4 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SO"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/researcher

/datum/equipment_preset/unsc_crew/rnd/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(new_human), WEAR_L_EAR)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/crew/rnd(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(new_human), WEAR_FEET)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c(new_human), WEAR_IN_R_STORE)
