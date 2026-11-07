/datum/equipment_preset/iasf/standard/ship
	name = "IASF Turing Trooper"
	assignment = JOB_IASF_TROOPER
	rank = JOB_IASF_TROOPER
	skills = /datum/skills/iasf/ship

/datum/equipment_preset/iasf/medic/ship
	name = "IASF Turing Medic"
	assignment = JOB_IASF_MEDIC
	rank = JOB_IASF_MEDIC
	skills = /datum/skills/iasf/ship/medic

/datum/equipment_preset/iasf/machinegun/ship
	name = "IASF Turing Gunner"
	assignment = JOB_IASF_GUNNER
	rank = JOB_IASF_GUNNER
	skills = /datum/skills/iasf/ship/gunner

/datum/equipment_preset/iasf/sniper/light/ship
	name = "IASF Turing Sniper"
	assignment = JOB_IASF_SNIPER
	rank = JOB_IASF_SNIPER
	skills = /datum/skills/iasf/ship

/datum/equipment_preset/iasf/leader/lesser/ship
	name = "IASF Turing Team Leader"
	assignment = JOB_IASF_TEAM
	rank = JOB_IASF_TEAM
	skills = /datum/skills/iasf/ship/leader

/datum/equipment_preset/iasf/troopsergeant/ship
	name = "IASF Turing Platoon Sergeant"
	assignment = JOB_IASF_SERGEANT
	rank = JOB_IASF_SERGEANT
	skills = /datum/skills/iasf/ship/commander

/datum/equipment_preset/iasf/lieutenant/ship
	name = "IASF Turing Officer"
	assignment = JOB_IASF_OFFICER
	rank = JOB_IASF_OFFICER
	skills = /datum/skills/iasf/ship/officer

/datum/equipment_preset/iasf/engineer/ship
	name = "IASF Turing Fire Support"
	assignment = JOB_IASF_SUPPORT
	rank = JOB_IASF_SUPPORT
	skills = /datum/skills/iasf/ship

/obj/item/clothing/head/helmet/marine/veteran/royal_marine/breacher/iasf
	name = "IASF L5A3 breacher helmet"
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons = list(WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi')

/obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher
	name = "IASF Kestrel breacher vest"
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/TWE.dmi'
	item_icons = list(WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/TWE.dmi')
	icon_state = "rmc_pointman"
	item_state = "rmc_pointman"
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/weapon/shield/riot/ballistic/iasf
	name = "IASF ballistic shield"
	desc = "A reinforced ballistic shield issued to IASF entry teams."

/datum/equipment_preset/iasf/breacher
	name = "IASF, Breacher (Equipped)"
	paygrades = list(PAY_SHORT_RMC2 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "BR"
	assignment = JOB_IASF_BREACHER
	rank = JOB_IASF_BREACHER
	skills = /datum/skills/iasf/ship/breacher
	access = list(ACCESS_WY_GENERAL, ACCESS_TWE_COMMANDO, ACCESS_TWE_ARMORY)

/datum/equipment_preset/iasf/breacher/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/rmc/medium(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/slugs(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/twe(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/royal_marine/iasf(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/rmc/iasf(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/royal_marine/breacher/iasf(new_human), WEAR_HEAD)
	add_iasf_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m3/uppmags/rmc(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/rmc(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/rmc/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/ballistic/iasf(new_human), WEAR_L_HAND)
