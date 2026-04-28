/datum/equipment_preset/unsc/spartan
	name = "Spartan"
	expected_species = SPECIES_SPARTAN
	assignment = JOB_SPARTAN
	rank = JOB_SPARTAN
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	paygrades = list(PAY_SHORT_NE6 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/unsc/spartan
	role_comm_title = "Spartan"
	languages = list(LANGUAGE_ENGLISH)
	var/access_list = ACCESS_LIST_MARINE_MAIN

/datum/equipment_preset/unsc/spartan/New()
	. = ..()
	access = get_access(access_list)

/datum/equipment_preset/unsc/spartan/proc/apply_spartan_identity(mob/living/carbon/human/new_human)
	var/static/list/eye_colors = list(
		"BLACK" = list(15, 15, 10),
		"BROWN" = list(48, 38, 18),
		"BLUE" = list(29, 51, 65),
		"GREEN" = list(40, 61, 39),
		"STEEL" = list(46, 59, 54),
	)
	new_human.set_species(SPECIES_SPARTAN)
	new_human.gender = pick(50; MALE, 50; FEMALE)
	var/chosen_name = capitalize(pick(new_human.gender == MALE ? GLOB.first_names_spartan_male : GLOB.first_names_spartan_female))
	new_human.change_real_name(new_human, "[chosen_name]-[rand(0, 200)]")
	new_human.body_type = "spartan"
	new_human.skin_color = "pale1"
	var/eye_color = pick(eye_colors)
	new_human.r_eyes = eye_colors[eye_color][1]
	new_human.g_eyes = eye_colors[eye_color][2]
	new_human.b_eyes = eye_colors[eye_color][3]
	new_human.age = rand(17, 35)

/datum/equipment_preset/unsc/spartan/load_race(mob/living/carbon/human/new_human, client/mob_client)
	apply_spartan_identity(new_human)

/datum/equipment_preset/unsc/spartan/load_name(mob/living/carbon/human/new_human, randomise, client/mob_client)
	apply_spartan_identity(new_human)

/datum/equipment_preset/unsc/spartan/proc/equip_spartan_basics(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/spartan(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/mjolnir(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/mjolnir(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/spartan(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/spartan(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/foxtrot(new_human), WEAR_L_EAR)

/datum/equipment_preset/unsc/spartan/equipped
	name = "Spartan Equipped"

/datum/equipment_preset/unsc/spartan/equipped/load_gear(mob/living/carbon/human/new_human)
	equip_spartan_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5c(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	for(var/i in 1 to 10)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma5c(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/explosive(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/surgical_line(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/synthgraft(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/unsc/corpsman(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/glass/beaker/unsc/tramadol(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo(new_human), WEAR_IN_BACK)

/datum/equipment_preset/unsc/spartan/sniper
	name = "Spartan Sniper"

/datum/equipment_preset/unsc/spartan/sniper/load_gear(mob/living/carbon/human/new_human)
	equip_spartan_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m7/full/socom(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	for(var/i in 1 to 10)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/m7(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full_bio(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/halo(new_human), WEAR_BACK)

/datum/equipment_preset/unsc/spartan/spnkr
	name = "Spartan SPNKR"

/datum/equipment_preset/unsc/spartan/spnkr/load_gear(mob/living/carbon/human/new_human)
	equip_spartan_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m7/full/socom(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	for(var/i in 1 to 9)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/halo/m7(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/m7(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full_bio(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/spnkr/filled/launcher(new_human), WEAR_BACK)

/datum/equipment_preset/unsc/spartan/spnkr/ai_man
	name = parent_type::name + " (AI)"

/datum/equipment_preset/unsc/spartan/spnkr/ai_man/load_gear(mob/living/carbon/human/new_human)
	equip_spartan_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full_bio(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/spnkr/filled/launcher(new_human), WEAR_BACK)

/datum/equipment_preset/unsc/spartan/cqc
	name = "Spartan CQC"

/datum/equipment_preset/unsc/spartan/cqc/load_gear(mob/living/carbon/human/new_human)
	equip_spartan_basics(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma5b(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/shotgun/unsc(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m52b/mag/ma5b(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6d(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/unsc/full_bio(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/halo/m90(new_human), WEAR_BACK)
