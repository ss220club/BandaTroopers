/datum/equipment_preset/covenant/unggoy
	name = "Унггой"
	expected_species = SPECIES_UNGGOY
	rank = JOB_COV_CIV
	assignment = JOB_COV_MINOR
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_COV_CIV = JOB_PLAYTIME_TIER_0)
	faction = FACTION_UNGGOY
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	var/halo_unggoy_role = "minor"
	var/halo_unggoy_panic_health_pct = 0.55
	var/halo_unggoy_panics_without_leader = TRUE
	var/halo_unggoy_ignore_panic = FALSE
	var/halo_unggoy_overheat_retreat = TRUE

/datum/equipment_preset/covenant/unggoy/load_race(mob/living/carbon/human/new_human, client/mob_client)
	new_human.set_species(SPECIES_UNGGOY)
	random_name = capitalize(pick(GLOB.first_names_unggoy)) + pick(GLOB.last_names_unggoy)
	var/final_name = random_name
	new_human.change_real_name(new_human, final_name)
	new_human.gender = MALE
	new_human.body_type = "ung"
	new_human.skin_color = "unggoy1"
	var/static/list/eye_color_list = list("Magenta" = list(141, 39, 85), "Orange" = list(158, 67, 28), "Green" = list(24, 105, 17))
	eye_color = pick(eye_color_list)
	new_human.r_eyes = eye_color_list[eye_color][1]
	new_human.g_eyes = eye_color_list[eye_color][2]
	new_human.b_eyes = eye_color_list[eye_color][3]

/datum/equipment_preset/covenant/unggoy/load_id(mob/living/carbon/human/new_human)
	. = ..()

/datum/equipment_preset/covenant/unggoy/load_name(mob/living/carbon/human/new_human, randomise, client/mob_client)
	random_name = capitalize(pick(GLOB.first_names_unggoy)) + pick(GLOB.last_names_unggoy)
	var/final_name = random_name
	new_human.change_real_name(new_human, final_name)
	new_human.gender = MALE
	new_human.body_type = "ung"
	new_human.skin_color = "unggoy1"
	var/static/list/eye_color_list = list("Magenta" = list(141, 39, 85), "Orange" = list(158, 67, 28), "Green" = list(24, 105, 17))
	eye_color = pick(eye_color_list)
	new_human.r_eyes = eye_color_list[eye_color][1]
	new_human.g_eyes = eye_color_list[eye_color][2]
	new_human.b_eyes = eye_color_list[eye_color][3]

/datum/equipment_preset/covenant/unggoy/load_preset(mob/living/carbon/human/new_human, randomise = FALSE, count_participant = FALSE, client/mob_client, show_job_gear = TRUE, late_join)
	. = ..()
	if(new_human)
		new_human.halo_apply_species_tts_seed()

/datum/equipment_preset/covenant/unggoy/proc/equip_unggoy_basics(mob/living/carbon/human/new_human, suit_type, belt_type = null)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/covenant/unggoy(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new suit_type(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/unggoy(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/covenant(new_human), WEAR_L_EAR)
	if(belt_type)
		new_human.equip_to_slot_or_del(new belt_type(new_human), WEAR_WAIST)

/datum/equipment_preset/covenant/unggoy/proc/add_unggoy_needler_crystals(mob/living/carbon/human/new_human, count = 5)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/needler_crystal(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/unggoy/proc/add_plasma_pistol_package(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/proc/add_needler_package(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_unggoy_needler_crystals(new_human, 5)

/datum/equipment_preset/covenant/unggoy/proc/add_plasma_rifle_package(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)

/datum/equipment_preset/covenant/unggoy/proc/apply_unggoy_ai_behavior(datum/human_ai_brain/brain)
	if(!brain)
		return

	brain.halo_unggoy_runtime = TRUE
	brain.halo_unggoy_role = halo_unggoy_role
	brain.halo_unggoy_panic_health_pct = halo_unggoy_panic_health_pct
	brain.halo_unggoy_panics_without_leader = halo_unggoy_panics_without_leader
	brain.halo_unggoy_ignore_panic = halo_unggoy_ignore_panic
	brain.halo_unggoy_overheat_retreat = halo_unggoy_overheat_retreat
	brain.halo_apply_navigation_profile(4, 1, 1 SECONDS)

/datum/equipment_preset/covenant/unggoy/proc/modular_apply_human_ai_brain_overrides(datum/human_ai_brain/brain, mob/living/carbon/human/new_human)
	apply_unggoy_ai_behavior(brain)
	var/datum/modpack/localization/localization_pack
	if(SSmodpacks)
		localization_pack = SSmodpacks.get_modpack(/datum/modpack/localization)
	if(localization_pack)
		localization_pack.halo_ai_apply_unggoy_speech_profile(brain, halo_unggoy_role)

// BASIC ROLES

// MINOR
/datum/equipment_preset/covenant/unggoy/minor
	name = parent_type::name + " минор"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_MINOR
	rank = JOB_COV_MINOR
	paygrades = list(PAY_SHORT_COV_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Минор"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	halo_unggoy_role = "minor"
	halo_unggoy_panic_health_pct = 0.55
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/minor/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/minor, /obj/item/storage/belt/marine/covenant/unggoy/minor)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/minor/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/minor/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/minor, /obj/item/storage/belt/marine/covenant/unggoy/minor)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/minor/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/minor/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/minor, /obj/item/storage/belt/marine/covenant/unggoy/minor)
	add_plasma_rifle_package(new_human)

// MAJOR
/datum/equipment_preset/covenant/unggoy/major
	name = parent_type::name + " мажор"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_MAJOR
	rank = JOB_COV_MAJOR
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Мажор"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	halo_unggoy_role = "major"
	halo_unggoy_panic_health_pct = 0.4
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/major/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/major/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/major/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/major, /obj/item/storage/belt/marine/covenant/unggoy/major)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/major/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/major/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/major, /obj/item/storage/belt/marine/covenant/unggoy/major)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/major/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/major/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/major, /obj/item/storage/belt/marine/covenant/unggoy/major)
	add_plasma_rifle_package(new_human)

// HEAVY
/datum/equipment_preset/covenant/unggoy/heavy
	name = parent_type::name + " тяжелый"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_HEAVY
	rank = JOB_COV_HEAVY
	paygrades = list(PAY_SHORT_COV_HEAVY = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Тяжелый"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	halo_unggoy_role = "heavy"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/heavy/load_gear(mob/living/carbon/human/new_human)
	add_grunt_heavy(new_human)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/heavy/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/heavy/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/heavy, /obj/item/storage/belt/marine/covenant/unggoy/heavy)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/heavy/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/heavy/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/heavy, /obj/item/storage/belt/marine/covenant/unggoy/heavy)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/heavy, /obj/item/storage/belt/marine/covenant/unggoy/heavy)
	add_plasma_rifle_package(new_human)

// Ultra
/datum/equipment_preset/covenant/unggoy/ultra
	name = parent_type::name + " ультра"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_ULTRA
	rank = JOB_COV_ULTRA
	paygrades = list(PAY_SHORT_COV_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Ультра"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	halo_unggoy_role = "ultra"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/ultra/load_gear(mob/living/carbon/human/new_human)
	add_grunt_ultra(new_human)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/ultra/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/ultra/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/ultra, /obj/item/storage/belt/marine/covenant/unggoy/ultra)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/ultra/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/ultra/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/ultra, /obj/item/storage/belt/marine/covenant/unggoy/ultra)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/ultra, /obj/item/storage/belt/marine/covenant/unggoy/ultra)
	add_plasma_rifle_package(new_human)

// SpecOps
/datum/equipment_preset/covenant/unggoy/specops
	name = parent_type::name + " SpecOps"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_SPECOPS
	rank = JOB_COV_SPECOPS
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	faction = FACTION_SPECOPS_UNGGOY
	halo_unggoy_role = "specops"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/specops/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/specops/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops, /obj/item/storage/belt/marine/covenant/unggoy/specops)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/specops/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops, /obj/item/storage/belt/marine/covenant/unggoy/specops)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops, /obj/item/storage/belt/marine/covenant/unggoy/specops)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops/cloaking
	name = parent_type::name + " (Plasma Rifle) !!CLOAKED!!"

/datum/equipment_preset/covenant/unggoy/specops/cloaking/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops, /obj/item/storage/belt/marine/covenant/unggoy/specops)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops/lesser
	name = parent_type::name + " (пониженный ранг)"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_SPECOPS
	rank = JOB_COV_SPECOPS
	paygrades = list(PAY_SHORT_COV_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)

/datum/equipment_preset/covenant/unggoy/specops/lesser/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	add_plasma_rifle_package(new_human)

// SpecOps Ultra
/datum/equipment_preset/covenant/unggoy/specops_ultra
	name = parent_type::name + " SpecOps-ультра"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_SPECOPS_ULTRA
	rank = JOB_COV_SPECOPS_ULTRA
	paygrades = list(PAY_SHORT_COV_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps-ультра"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	faction = FACTION_SPECOPS_UNGGOY
	halo_unggoy_role = "specops_ultra"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/specops_ultra/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops_ultra(new_human)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops/ultra, /obj/item/storage/belt/marine/covenant/unggoy/specops_ultra)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops_ultra/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops/ultra, /obj/item/storage/belt/marine/covenant/unggoy/specops_ultra)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops/ultra, /obj/item/storage/belt/marine/covenant/unggoy/specops_ultra)
	add_plasma_rifle_package(new_human)

/datum/equipment_preset/covenant/unggoy/specops_ultra/cloaking
	name = parent_type::name + " (Plasma Rifle) !!CLOAKED!!"

/datum/equipment_preset/covenant/unggoy/specops_ultra/cloaking/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/stealth/unggoy_specops/ultra, /obj/item/storage/belt/marine/covenant/unggoy/specops_ultra)
	add_plasma_rifle_package(new_human)

// Deacon
/datum/equipment_preset/covenant/unggoy/deacon
	name = parent_type::name + " дьякон"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	assignment = JOB_COV_DEACON
	rank = JOB_COV_DEACON
	paygrades = list(PAY_SHORT_COV_DEACON = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Дьякон"
	skills = /datum/skills/covenant/unggoy
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	halo_unggoy_role = "deacon"
	halo_unggoy_panic_health_pct = 0.65
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/deacon/load_gear(mob/living/carbon/human/new_human)
	add_grunt_deacon(new_human)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/deacon/plasma_pistol
	name = parent_type::name + " (Plasma Pistol)"

/datum/equipment_preset/covenant/unggoy/deacon/plasma_pistol/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/deacon, /obj/item/storage/belt/marine/covenant/unggoy/ultra)
	add_plasma_pistol_package(new_human)

/datum/equipment_preset/covenant/unggoy/deacon/needler
	name = parent_type::name + " (Needler)"

/datum/equipment_preset/covenant/unggoy/deacon/needler/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/deacon, /obj/item/storage/belt/marine/covenant/unggoy/ultra)
	add_needler_package(new_human)

/datum/equipment_preset/covenant/unggoy/deacon/plasma_rifle
	name = parent_type::name + " (Plasma Rifle)"

/datum/equipment_preset/covenant/unggoy/deacon/plasma_rifle/load_gear(mob/living/carbon/human/new_human)
	equip_unggoy_basics(new_human, /obj/item/clothing/suit/marine/unggoy/deacon, /obj/item/storage/belt/marine/covenant/unggoy/ultra)
	add_plasma_rifle_package(new_human)

// AI-ONLY ROLES

/datum/equipment_preset/covenant/unggoy/ai
	name = "Унггой AI"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	idtype = /obj/item/card/id/covenant
	access = list(ACCESS_MARINE_PREP)
	languages = list(LANGUAGE_SANGHEILI, LANGUAGE_UNGGOY)
	skills = /datum/skills/covenant/unggoy
/datum/equipment_preset/covenant/unggoy/ai/proc/equip_unggoy_ai_basics(mob/living/carbon/human/new_human, suit_type, belt_type)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/covenant/unggoy(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new suit_type(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/unggoy(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/covenant(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new belt_type(new_human), WEAR_WAIST)

/datum/equipment_preset/covenant/unggoy/ai/proc/add_needler_crystals(mob/living/carbon/human/new_human, count = 5)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/needler_crystal(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/unggoy/ai/proc/add_ai_injectors(mob/living/carbon/human/new_human, list/injector_paths)
	if(!length(injector_paths))
		return

	for(var/injector_path in injector_paths)
		new_human.equip_to_slot_or_del(new injector_path(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/unggoy/ai/proc/add_plasma_grenades(mob/living/carbon/human/new_human, count = 2)
	for(var/i in 1 to count)
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/covenant/plasma(new_human), WEAR_IN_BELT)

/datum/equipment_preset/covenant/unggoy/ai/minor_plasma
	name = "Унггой-минор (плазма)"
	assignment = JOB_COV_MINOR
	rank = JOB_COV_MINOR
	paygrades = list(PAY_SHORT_COV_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Минор"
	halo_unggoy_role = "minor"
	halo_unggoy_panic_health_pct = 0.55
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/ai/minor_plasma/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo))

/datum/equipment_preset/covenant/unggoy/ai/minor_needler
	name = "Унггой-минор (игольник)"
	assignment = JOB_COV_MINOR
	rank = JOB_COV_MINOR
	paygrades = list(PAY_SHORT_COV_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Минор"
	halo_unggoy_role = "minor"
	halo_unggoy_panic_health_pct = 0.55
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/ai/minor_needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 4)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo))

/datum/equipment_preset/covenant/unggoy/ai/major_plasma
	name = "Унггой-мажор (плазма)"
	assignment = JOB_COV_MAJOR
	rank = JOB_COV_MAJOR
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Мажор"
	halo_unggoy_role = "major"
	halo_unggoy_panic_health_pct = 0.4
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/ai/major_plasma/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/major_needler
	name = "Унггой-мажор (игольник)"
	assignment = JOB_COV_MAJOR
	rank = JOB_COV_MAJOR
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Мажор"
	halo_unggoy_role = "major"
	halo_unggoy_panic_health_pct = 0.4
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/ai/major_needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma
	name = "Унггой-тяжелый (плазменная винтовка)"
	assignment = JOB_COV_HEAVY
	rank = JOB_COV_HEAVY
	paygrades = list(PAY_SHORT_COV_HEAVY = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Тяжелый"
	halo_unggoy_role = "heavy"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma/load_gear(mob/living/carbon/human/new_human)
	add_grunt_heavy(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/kelotane/halo))

/datum/equipment_preset/covenant/unggoy/ai/heavy_needler
	name = "Унггой-тяжелый (игольник)"
	assignment = JOB_COV_HEAVY
	rank = JOB_COV_HEAVY
	paygrades = list(PAY_SHORT_COV_HEAVY = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Тяжелый"
	halo_unggoy_role = "heavy"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/ai/heavy_needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_heavy(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/kelotane/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/ultra
	name = "Унггой-ультра (AI)"
	assignment = JOB_COV_ULTRA
	rank = JOB_COV_ULTRA
	paygrades = list(PAY_SHORT_COV_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Ультра"
	halo_unggoy_role = "ultra"
	halo_unggoy_ignore_panic = TRUE

/datum/equipment_preset/covenant/unggoy/ai/ultra/load_gear(mob/living/carbon/human/new_human)
	add_grunt_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/support_medical
	name = "Унггой поддержки (медик)"
	assignment = JOB_COV_MAJOR
	rank = JOB_COV_MAJOR
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Поддержка"
	halo_unggoy_role = "support"
	halo_unggoy_panic_health_pct = 0.5
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/ai/support_medical/load_gear(mob/living/carbon/human/new_human)
	add_grunt_major(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/kelotane/halo))

/datum/equipment_preset/covenant/unggoy/ai/specops_plasma
	name = "Унггой SpecOps (плазма)"
	assignment = JOB_COV_SPECOPS
	rank = JOB_COV_SPECOPS
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps"
	halo_unggoy_role = "specops"
	halo_unggoy_ignore_panic = TRUE
	faction = FACTION_SPECOPS_UNGGOY

/datum/equipment_preset/covenant/unggoy/ai/specops_plasma/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/specops_needler
	name = "Унггой SpecOps (игольник)"
	assignment = JOB_COV_SPECOPS
	rank = JOB_COV_SPECOPS
	paygrades = list(PAY_SHORT_COV_MAJOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps"
	halo_unggoy_role = "specops"
	halo_unggoy_ignore_panic = TRUE
	faction = FACTION_SPECOPS_UNGGOY

/datum/equipment_preset/covenant/unggoy/ai/specops_needler/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/covenant_needler(new_human), WEAR_J_STORE)
	add_needler_crystals(new_human, 5)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/kelotane/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/specops_ultra
	name = "Унггой SpecOps-ультра (AI)"
	assignment = JOB_COV_SPECOPS_ULTRA
	rank = JOB_COV_SPECOPS_ULTRA
	paygrades = list(PAY_SHORT_COV_ULTRA = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SpecOps-ультра"
	halo_unggoy_role = "specops_ultra"
	halo_unggoy_ignore_panic = TRUE
	faction = FACTION_SPECOPS_UNGGOY

/datum/equipment_preset/covenant/unggoy/ai/specops_ultra/load_gear(mob/living/carbon/human/new_human)
	add_grunt_specops_ultra(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_rifle(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/deacon_command
	name = "Унггой-дьякон (командный)"
	assignment = JOB_COV_DEACON
	rank = JOB_COV_DEACON
	paygrades = list(PAY_SHORT_COV_DEACON = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Дьякон"
	halo_unggoy_role = "deacon"
	halo_unggoy_panic_health_pct = 0.65
	halo_unggoy_panics_without_leader = TRUE
	halo_unggoy_ignore_panic = FALSE

/datum/equipment_preset/covenant/unggoy/ai/deacon_command/load_gear(mob/living/carbon/human/new_human)
	add_grunt_deacon(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/plasma/plasma_pistol(new_human), WEAR_J_STORE)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo))

/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber
	name = "Унггой-смертник"
	assignment = JOB_COV_MINOR
	rank = JOB_COV_MINOR
	paygrades = list(PAY_SHORT_COV_MINOR = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Смертник"
	halo_unggoy_role = "bomber"
	halo_unggoy_ignore_panic = TRUE
	halo_unggoy_overheat_retreat = FALSE

/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber/load_gear(mob/living/carbon/human/new_human)
	add_grunt_minor(new_human)
	add_plasma_grenades(new_human, 2)
	add_ai_injectors(new_human, list(/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo, /obj/item/reagent_container/hypospray/autoinjector/kelotane/halo))

/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber/modular_apply_human_ai_brain_overrides(datum/human_ai_brain/brain, mob/living/carbon/human/new_human)
	..()
	if(!brain)
		return

	brain.halo_suicide_bomber = TRUE
	brain.halo_suicide_prime_range = 5
	brain.grenading_allowed = FALSE
	brain.ignore_looting = TRUE
