/datum/equipment_preset/covenant
	name = "COVENANT"
	faction = FACTION_COVENANT
	languages = list(LANGUAGE_SANGHEILI)
	idtype = /obj/item/card/id/covenant
	var/random_name
	var/eye_color

/datum/equipment_preset/covenant/sangheili
	name = "Sangheili"
	rank = JOB_COV_CIV
	assignment = JOB_COV_CIV
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	paygrades = list(PAY_SHORT_COV_CIV = JOB_PLAYTIME_TIER_0)
	faction = FACTION_COVENANT
	skills = /datum/skills/covenant/sangheili
	var/halo_sangheili_sword_only = FALSE
	var/halo_sangheili_sword_charge_range = 5
	var/halo_sangheili_unarmed_commit_range = 2

/datum/equipment_preset/covenant/sangheili/load_race(mob/living/carbon/human/new_human, client/mob_client)
	new_human.set_species(SPECIES_SANGHEILI)
	random_name = capitalize(pick(GLOB.first_names_sangheili)) + " " + capitalize(pick(GLOB.last_names_sangheili))
	var/final_name = random_name
	new_human.change_real_name(new_human, final_name)
	new_human.gender = MALE
	new_human.body_type = "sang"
	new_human.skin_color = pick("sang1", "sang2")
	var/static/list/eye_color_list = list("Magenta" = list(141, 39, 85), "Orange" = list(158, 67, 28), "Green" = list(24, 105, 17))
	eye_color = pick(eye_color_list)
	new_human.r_eyes = eye_color_list[eye_color][1]
	new_human.g_eyes = eye_color_list[eye_color][2]
	new_human.b_eyes = eye_color_list[eye_color][3]

/datum/equipment_preset/covenant/sangheili/load_id(mob/living/carbon/human/new_human)
	. = ..()

/datum/equipment_preset/covenant/sangheili/load_name(mob/living/carbon/human/new_human, randomise, client/mob_client)
	random_name = capitalize(pick(GLOB.first_names_sangheili)) + " " + capitalize(pick(GLOB.last_names_sangheili))
	var/final_name = random_name
	new_human.change_real_name(new_human, final_name)
	new_human.gender = MALE
	new_human.body_type = "sang"
	new_human.skin_color = pick("sang1", "sang2")
	var/static/list/eye_color_list = list("Magenta" = list(141, 39, 85), "Orange" = list(158, 67, 28), "Green" = list(24, 105, 17))
	eye_color = pick(eye_color_list)
	new_human.r_eyes = eye_color_list[eye_color][1]
	new_human.g_eyes = eye_color_list[eye_color][2]
	new_human.b_eyes = eye_color_list[eye_color][3]

/datum/equipment_preset/covenant/sangheili/load_preset(mob/living/carbon/human/new_human, randomise = FALSE, count_participant = FALSE, client/mob_client, show_job_gear = TRUE, late_join)
	. = ..()
	if(new_human)
		new_human.halo_apply_species_tts_seed()

/datum/equipment_preset/covenant/sangheili/proc/equip_sangheili_basics(mob/living/carbon/human/new_human, helmet_type, suit_type, gloves_type, shoes_type, belt_type)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/covenant/sangheili(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new helmet_type(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new suit_type(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new gloves_type(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new shoes_type(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new belt_type(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/covenant(new_human), WEAR_L_EAR)

/datum/equipment_preset/covenant/sangheili/proc/add_needler_crystals(mob/living/carbon/human/new_human, count = 5)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/needler_crystal(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/sangheili/proc/add_carbine_mags(mob/living/carbon/human/new_human, count = 5)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/carbine(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/sangheili/proc/add_sangheili_injectors(mob/living/carbon/human/new_human, list/injector_paths)
	if(!length(injector_paths))
		return

	for(var/injector_path in injector_paths)
		new_human.equip_to_slot_or_del(new injector_path(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/sangheili/proc/add_plasma_grenades(mob/living/carbon/human/new_human, count = 1)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/covenant/plasma(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/sangheili/proc/sangheili_rank_has_sword(rank_value = rank)
	return rank_value in list(JOB_COV_ULTRA, JOB_COV_ZEALOT, "ultra", "zealot")

/datum/equipment_preset/covenant/sangheili/proc/add_energy_sword(mob/living/carbon/human/new_human)
	if(!new_human?.belt)
		return

	if(locate(/obj/item/weapon/covenant/energy_sword) in new_human.belt)
		return

	new_human.equip_to_slot_or_del(new /obj/item/weapon/covenant/energy_sword(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/sangheili/proc/apply_sangheili_ai_behavior(datum/human_ai_brain/brain)
	if(!brain)
		return

	brain.halo_sangheili_runtime = TRUE
	brain.halo_sangheili_has_sword = sangheili_rank_has_sword(rank) || halo_sangheili_sword_only
	brain.halo_sangheili_sword_only = halo_sangheili_sword_only
	brain.halo_sangheili_sword_charge_range = halo_sangheili_sword_charge_range
	brain.halo_sangheili_unarmed_commit_range = halo_sangheili_unarmed_commit_range
	brain.halo_apply_navigation_profile(halo_sangheili_sword_charge_range + 1, 2, 1 SECONDS)
	if(halo_sangheili_sword_only)
		brain.ignore_looting = TRUE

/datum/equipment_preset/covenant/sangheili/proc/modular_apply_human_ai_brain_overrides(datum/human_ai_brain/brain, mob/living/carbon/human/new_human)
	apply_sangheili_ai_behavior(brain)
	var/datum/modpack/localization/localization_pack
	if(SSmodpacks)
		localization_pack = SSmodpacks.get_modpack(/datum/modpack/localization)
	if(localization_pack)
		localization_pack.halo_ai_apply_sangheili_speech_profile(brain, rank, halo_sangheili_sword_only)

/datum/equipment_preset/covenant/sangheili/proc/add_rank_utility(mob/living/carbon/human/new_human, rank_tier)
	switch(rank_tier)
		if("major")
			add_sangheili_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo))
		if("ultra", "zealot")
			add_sangheili_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))
			add_plasma_grenades(new_human, 1)

	if(sangheili_rank_has_sword(rank_tier))
		add_energy_sword(new_human)

// =================================
// Minor
// =================================

/datum/equipment_preset/covenant/sangheili/minor
	name = parent_type::name + " Minor"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_MINOR
	rank = JOB_COV_MINOR
	paygrades = list(PAY_SHORT_SANG_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Minor"
	skills = /datum/skills/covenant/sangheili
	languages = list(LANGUAGE_SANGHEILI)

/datum/equipment_preset/covenant/sangheili/minor/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/minor, /obj/item/clothing/suit/marine/shielded/sangheili/minor, /obj/item/clothing/gloves/marine/sangheili/minor, /obj/item/clothing/shoes/sangheili/minor, /obj/item/storage/belt/marine/covenant/sangheili/minor)
	if(prob(80))
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	else
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
		add_needler_crystals(new_human, 5)

// =================================
// Major
// =================================

/datum/equipment_preset/covenant/sangheili/major
	name = parent_type::name + " Major"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_MAJOR
	rank = JOB_COV_MAJOR
	paygrades = list(PAY_SHORT_SANG_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Major"
	skills = /datum/skills/covenant/sangheili
	languages = list(LANGUAGE_SANGHEILI)

/datum/equipment_preset/covenant/sangheili/major/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/major, /obj/item/clothing/suit/marine/shielded/sangheili/major, /obj/item/clothing/gloves/marine/sangheili/major, /obj/item/clothing/shoes/sangheili/major, /obj/item/storage/belt/marine/covenant/sangheili/major)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	else
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
		add_carbine_mags(new_human, 5)
	add_rank_utility(new_human, "major")

// =================================
// Ultra
// =================================

/datum/equipment_preset/covenant/sangheili/ultra
	name = parent_type::name + " Ultra"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_ULTRA
	rank = JOB_COV_ULTRA
	paygrades = list(PAY_SHORT_SANG_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Ultra"
	skills = /datum/skills/covenant/sangheili
	languages = list(LANGUAGE_SANGHEILI)

/datum/equipment_preset/covenant/sangheili/ultra/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/ultra, /obj/item/clothing/suit/marine/shielded/sangheili/ultra, /obj/item/clothing/gloves/marine/sangheili/ultra, /obj/item/clothing/shoes/sangheili/ultra, /obj/item/storage/belt/marine/covenant/sangheili/ultra)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	else
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
		add_carbine_mags(new_human, 5)
	add_rank_utility(new_human, "ultra")

// =================================
// Zealot
// =================================

/datum/equipment_preset/covenant/sangheili/zealot
	name = parent_type::name + " Zealot"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_ZEALOT
	rank = JOB_COV_ZEALOT
	paygrades = list(PAY_SHORT_SANG_ZEALOT = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Zealot"
	skills = /datum/skills/covenant/sangheili
	languages = list(LANGUAGE_SANGHEILI)

/datum/equipment_preset/covenant/sangheili/zealot/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/zealot, /obj/item/clothing/suit/marine/shielded/sangheili/zealot, /obj/item/clothing/gloves/marine/sangheili/zealot, /obj/item/clothing/shoes/sangheili/zealot, /obj/item/storage/belt/marine/covenant/sangheili/zealot)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	else
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
		add_carbine_mags(new_human, 5)
	add_rank_utility(new_human, "zealot")

// AI-ONLY ROLES

/datum/equipment_preset/covenant/sangheili/ai
	name = "Sangheili AI"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	languages = list(LANGUAGE_SANGHEILI)
	skills = /datum/skills/covenant/sangheili

/datum/equipment_preset/covenant/sangheili/ai/minor_plasma
	name = "Sangheili Minor (Plasma)"
	assignment = JOB_COV_MINOR
	rank = JOB_COV_MINOR
	paygrades = list(PAY_SHORT_SANG_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Minor"

/datum/equipment_preset/covenant/sangheili/ai/minor_plasma/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/minor, /obj/item/clothing/suit/marine/shielded/sangheili/minor, /obj/item/clothing/gloves/marine/sangheili/minor, /obj/item/clothing/shoes/sangheili/minor, /obj/item/storage/belt/marine/covenant/sangheili/minor)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/sangheili/ai/major_carbine
	name = "Sangheili Major (Carbine)"
	assignment = JOB_COV_MAJOR
	rank = JOB_COV_MAJOR
	paygrades = list(PAY_SHORT_SANG_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Major"

/datum/equipment_preset/covenant/sangheili/ai/major_carbine/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/major, /obj/item/clothing/suit/marine/shielded/sangheili/major, /obj/item/clothing/gloves/marine/sangheili/major, /obj/item/clothing/shoes/sangheili/major, /obj/item/storage/belt/marine/covenant/sangheili/major)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/covenant_carbine(new_human), WEAR_J_STORE)
	add_carbine_mags(new_human, 5)
	add_rank_utility(new_human, "major")

/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma
	name = "Sangheili Ultra (Plasma)"
	assignment = JOB_COV_ULTRA
	rank = JOB_COV_ULTRA
	paygrades = list(PAY_SHORT_SANG_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Ultra"

/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/ultra, /obj/item/clothing/suit/marine/shielded/sangheili/ultra, /obj/item/clothing/gloves/marine/sangheili/ultra, /obj/item/clothing/shoes/sangheili/ultra, /obj/item/storage/belt/marine/covenant/sangheili/ultra)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_rank_utility(new_human, "ultra")

/datum/equipment_preset/covenant/sangheili/ai/zealot_command
	name = "Sangheili Zealot (Command)"
	assignment = JOB_COV_ZEALOT
	rank = JOB_COV_ZEALOT
	paygrades = list(PAY_SHORT_SANG_ZEALOT = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Zealot"

/datum/equipment_preset/covenant/sangheili/ai/zealot_command/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/zealot, /obj/item/clothing/suit/marine/shielded/sangheili/zealot, /obj/item/clothing/gloves/marine/sangheili/zealot, /obj/item/clothing/shoes/sangheili/zealot, /obj/item/storage/belt/marine/covenant/sangheili/zealot)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_rank_utility(new_human, "zealot")

/datum/equipment_preset/covenant/sangheili/ai/ultra_sword
	name = "Sangheili Ultra (Sword)"
	assignment = JOB_COV_ULTRA
	rank = JOB_COV_ULTRA
	paygrades = list(PAY_SHORT_SANG_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Ultra"
	halo_sangheili_sword_only = TRUE

/datum/equipment_preset/covenant/sangheili/ai/ultra_sword/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/ultra, /obj/item/clothing/suit/marine/shielded/sangheili/ultra, /obj/item/clothing/gloves/marine/sangheili/ultra, /obj/item/clothing/shoes/sangheili/ultra, /obj/item/storage/belt/marine/covenant/sangheili/ultra)
	add_rank_utility(new_human, "ultra")

/datum/equipment_preset/covenant/sangheili/ai/zealot_sword
	name = "Sangheili Zealot (Sword)"
	assignment = JOB_COV_ZEALOT
	rank = JOB_COV_ZEALOT
	paygrades = list(PAY_SHORT_SANG_ZEALOT = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Zealot"
	halo_sangheili_sword_only = TRUE

/datum/equipment_preset/covenant/sangheili/ai/zealot_sword/load_gear(mob/living/carbon/human/new_human)
	equip_sangheili_basics(new_human, /obj/item/clothing/head/helmet/marine/sangheili/zealot, /obj/item/clothing/suit/marine/shielded/sangheili/zealot, /obj/item/clothing/gloves/marine/sangheili/zealot, /obj/item/clothing/shoes/sangheili/zealot, /obj/item/storage/belt/marine/covenant/sangheili/zealot)
	add_rank_utility(new_human, "zealot")
