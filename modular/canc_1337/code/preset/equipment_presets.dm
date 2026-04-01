/datum/equipment_preset/canc_dogwar
	name = "CANC Soldier"
	languages = list(LANGUAGE_CHINESE)
	ethnicity = CHINESE_ETHNICITY
	flags = null
	faction = FACTION_CANC_DOGWAR
	faction_group = FACTION_LIST_CANC
	skills = /datum/skills/canc_soldier
	paygrades = list(PAY_SHORT_CA1 = JOB_PLAYTIME_TIER_0)
	origin_override = ORIGIN_CANC
	idtype = /obj/item/card/id/dogtag

/datum/equipment_preset/canc_dogwar/New()
	. = ..()
	access = get_access(ACCESS_LIST_CLF_BASE)

///////////////////////
// CANC Armed Forces //
///////////////////////

/datum/equipment_preset/canc_dogwar/soldier
	name = "CANC Soldier, Rifleman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"

/datum/equipment_preset/canc_dogwar/soldier/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(13))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(8))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	add_dogwar_rifle(new_human)

/datum/equipment_preset/canc_dogwar/soldier/leader
	name = "CANC Soldier, Squad Leader"
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_CA5 = JOB_PLAYTIME_TIER_0)
	assignment = "Squad Leader"
	skills = /datum/skills/canc_soldier/sl

/datum/equipment_preset/canc_dogwar/soldier/leader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/fire_support/upp(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(7))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e5(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_R_STORE)
	add_dogwar_rifle(new_human)

/datum/equipment_preset/canc_dogwar/soldier/pl_leader
	name = "CANC Soldier, Platoon Leader"
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_CA7 = JOB_PLAYTIME_TIER_0)
	assignment = "Platoon Leader"
	skills = /datum/skills/canc_soldier/pl

/datum/equipment_preset/canc_dogwar/soldier/pl_leader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/fire_support/upp(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_ACCESSORY)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e7(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_R_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317, WEAR_IN_BELT)

/datum/equipment_preset/canc_dogwar/soldier/marksman
	name = "CANC Soldier, Marksman"
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_CA2 = JOB_PLAYTIME_TIER_0)
	assignment = "Marksman"

/datum/equipment_preset/canc_dogwar/soldier/marksman/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	if(prob(50))
		var/coolhat = pick(/obj/item/clothing/head/headband/red, /obj/item/clothing/head/cmcap/flap/canc, /obj/item/clothing/head/uppcap/boonie/canc)
		new_human.equip_to_slot_or_del(new coolhat(new_human), WEAR_HEAD)
	var/coolhairdo = pick("Bald", "Shaved Head", "Shaved Balding", "Shaved Mohawk", "Shaved Mohawk 2")
	new_human.h_style = coolhairdo
	new_human.regenerate_icons()
	//glasses
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/canc_monoscope(new_human), WEAR_EYES)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_ACCESSORY)
	if(prob(12))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e2(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317/dmr(new_human), WEAR_J_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/canc_dogwar/soldier/machinegunner
	name = "CANC Soldier, Machinegunner"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Machinegunner"
	skills = /datum/skills/canc_soldier/gunner
	access = list(ACCESS_UPP_GENERAL, ACCESS_UPP_MACHINEGUN)

/datum/equipment_preset/canc_dogwar/soldier/machinegunner/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(75))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(17))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(55))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/general_belt/upp, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pkp/standard_fmj, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pkp/standard_fmj, WEAR_IN_BELT)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/smartgunner/upp/canc(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pkp/iff/standard_fmj, WEAR_J_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_R_STORE)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)

/datum/equipment_preset/canc_dogwar/soldier/antitank
	name = "CANC Soldier, Anti-Tank"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Anti-Tank Specialist"

/datum/equipment_preset/canc_dogwar/soldier/antitank/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/upp, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(75))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(17))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(75))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/general_belt/upp, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/at, WEAR_IN_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp, WEAR_IN_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/incen, WEAR_IN_J_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_R_STORE)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)

/datum/equipment_preset/canc_dogwar/soldier/antitank_loader
	name = "CANC Soldier, Anti-Tank Loader"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"

/datum/equipment_preset/canc_dogwar/soldier/antitank_loader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/rocketpack(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/at(new_human), WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/at(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp(new_human), WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/incen(new_human), WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/incen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/droppouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	//weapon
	add_dogwar_rifle_pouch(new_human)

/datum/equipment_preset/canc_dogwar/soldier/antiair
	name = "CANC Soldier, Anti-Air"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"

/datum/equipment_preset/canc_dogwar/soldier/antiair/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/anti_air/upp(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/droppouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	add_dogwar_rifle(new_human)

/datum/equipment_preset/canc_dogwar/soldier/medic
	name = "CANC Soldier, Field Medic"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Field Medic"
	paygrades = list(PAY_SHORT_CA2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/medic

/datum/equipment_preset/canc_dogwar/soldier/medic/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/adv/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/regular/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/brute/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/surgical/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/medic(new_human), WEAR_L_EAR)
	if(new_human.disabilities & NEARSIGHTED)
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health/prescription, WEAR_EYES)
	else
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, WEAR_EYES)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/droppouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e2(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/upp/full, WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medical, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/ointment, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/bruise_pack, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/tricordrazine, WEAR_IN_L_STORE)
	//weapon
	add_dogwar_rifle_pouch(new_human)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)

///////////////////////////
// CANC Colonial Militia //
///////////////////////////

/datum/equipment_preset/canc_dogwar/militia
	name = "CANC Colonial Militia, Rifleman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"
	idtype = /obj/item/card/id/lanyard

/datum/equipment_preset/canc_dogwar/militia/load_gear(mob/living/carbon/human/new_human)

	var/random_skillset = rand(1,10)
	switch(random_skillset)
		if(1 to 7)
			skills = /datum/skills/canc_soldier/militia/trained
		if(8 to 10)
			skills = /datum/skills/canc_soldier/militia

	new_human.undershirt = "undershirt"
	//back
	add_random_satchel(new_human)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare/upp, WEAR_IN_BACK)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_BACK)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/custom/ied, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/family_photo, WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/boda, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/random, WEAR_IN_BACK)
	if(prob(3))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	var/random_helmet_canc = rand(1,8)
	switch(random_helmet_canc)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
		if(2,3,4)
			add_rebel_upp_helmet(new_human)
	add_dogwar_rifle_newblood(new_human)

/datum/equipment_preset/canc_dogwar/militia/antitank
	name = "CANC Colonial Militia, Anti-Tank"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"
	idtype = /obj/item/card/id/lanyard
	skills = /datum/skills/canc_soldier/militia/trained

/datum/equipment_preset/canc_dogwar/militia/antitank/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "undershirt"
	//back
	add_random_satchel(new_human)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare/upp, WEAR_IN_BACK)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_BACK)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/custom/ied, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/family_photo, WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/boda, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/random, WEAR_IN_BACK)
	if(prob(3))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	var/random_helmet_canc = rand(1,8)
	switch(random_helmet_canc)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
		if(2,3,4)
			add_rebel_upp_helmet(new_human)
	//weapons
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/anti_tank/disposable/canc, WEAR_R_HAND)

/datum/equipment_preset/canc_dogwar/militia/lmg
	name = "CANC Colonial Militia, MAR LMG Machinegunner"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Machinegunner"
	idtype = /obj/item/card/id/lanyard
	skills = /datum/skills/canc_soldier/militia/trained

/datum/equipment_preset/canc_dogwar/militia/lmg/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "undershirt"
	//back
	add_random_satchel(new_human)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare/upp, WEAR_IN_BACK)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/custom/ied, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/family_photo, WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/boda, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/random, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	var/random_helmet_canc = rand(1,8)
	switch(random_helmet_canc)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
		if(2,3,4)
			add_rebel_upp_helmet(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/mar40/lmg, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mar40/lmg, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mar40/lmg, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mar40/lmg, WEAR_IN_BELT)

/datum/equipment_preset/canc_dogwar/militia/medic
	name = "CANC Colonial Militia, Field Medic"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Field Medic"
	idtype = /obj/item/card/id/lanyard
	skills = /datum/skills/canc_soldier/militia/medic

/datum/equipment_preset/canc_dogwar/militia/medic/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/med, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/synthgraft, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/surgery/surgical_line, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/regular, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/regular, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/medic(new_human), WEAR_L_EAR)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/np92(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/np92(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/np92(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/np92(new_human), WEAR_IN_ACCESSORY)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/np92, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(new_human), WEAR_HANDS)
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	var/random_helmet_canc = rand(1,8)
	switch(random_helmet_canc)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
		if(2,3,4)
			add_rebel_upp_helmet(new_human)

/datum/equipment_preset/canc_dogwar/militia/leader
	name = "CANC Colonial Militia, Squad Leader"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Squad Leader"
	idtype = /obj/item/card/id/lanyard
	skills = /datum/skills/canc_soldier/militia/sl

/datum/equipment_preset/canc_dogwar/militia/leader/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "undershirt"
	//back
	add_random_satchel(new_human)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare/upp, WEAR_IN_BACK)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_BACK)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/custom/ied, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/family_photo, WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/boda, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/random, WEAR_IN_BACK)
	if(prob(3))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret/guerilla(new_human), WEAR_HEAD)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown/fingerless(new_human), WEAR_HANDS)
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	add_dogwar_rifle_newblood(new_human)

/datum/equipment_preset/canc_dogwar/militia/marksman
	name = "CANC Colonial Militia, Marksman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Marksman"
	idtype = /obj/item/card/id/lanyard
	skills = /datum/skills/canc_soldier/militia/trained

/datum/equipment_preset/canc_dogwar/militia/marksman/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "undershirt"
	//back
	add_random_satchel(new_human)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare/upp, WEAR_IN_BACK)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_BACK)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/custom/ied, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/family_photo, WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/boda, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/random, WEAR_IN_BACK)
	if(prob(3))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	var/random_helmet_canc = rand(1,8)
	switch(random_helmet_canc)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
		if(2,3,4)
			add_rebel_upp_helmet(new_human)
	//weapons
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/mar40/marksman(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mar40, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mar40, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mar40, WEAR_IN_BELT)

/datum/equipment_preset/canc_dogwar/militia/shotgun
	name = "CANC Colonial Militia, Shotgunner"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Shotgunner"
	idtype = /obj/item/card/id/lanyard

/datum/equipment_preset/canc_dogwar/militia/shotgun/load_gear(mob/living/carbon/human/new_human)

	var/random_skillset = rand(1,10)
	switch(random_skillset)
		if(1 to 7)
			skills = /datum/skills/canc_soldier/militia/trained
		if(8 to 10)
			skills = /datum/skills/canc_soldier/militia

	new_human.undershirt = "undershirt"
	//back
	add_random_satchel(new_human)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/flare/upp, WEAR_IN_BACK)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_BACK)
	if(prob(5))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/custom/ied, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/family_photo, WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/mre_food_packet/clf, WEAR_IN_BACK)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/boda, WEAR_IN_BACK)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/random, WEAR_IN_BACK)
	if(prob(3))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	//uniform
	add_civilian_uniform(new_human)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	var/random_civilian_shoe = rand(1,7)
	switch(random_civilian_shoe)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup/brown(new_human), WEAR_FEET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/brown(new_human), WEAR_FEET)
		if(6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian(new_human), WEAR_FEET)
		if(7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(new_human), WEAR_FEET)
	var/random_helmet_canc = rand(1,8)
	switch(random_helmet_canc)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
		if(2,3,4)
			add_rebel_upp_helmet(new_human)
	//weapons
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/double/upp(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/shotgun/upp, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_BELT)

/////////////////////////////
// CANC Armed Forces (UPP) //
/////////////////////////////

/datum/equipment_preset/canc_dogwar/upp
	name = "CANC Soldier, Rifleman (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"

/datum/equipment_preset/canc_dogwar/upp/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	add_dogwar_rifle_upp(new_human)

/datum/equipment_preset/canc_dogwar/upp/medic
	name = "CANC Soldier, Field Medic (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Field Medic"
	paygrades = list(PAY_SHORT_CA2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/medic

/datum/equipment_preset/canc_dogwar/upp/medic/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/adv/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/regular/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/brute/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/surgical/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/medic(new_human), WEAR_L_EAR)
	if(new_human.disabilities & NEARSIGHTED)
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health/prescription, WEAR_EYES)
	else
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, WEAR_EYES)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/droppouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e2(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/upp/full, WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medical, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/ointment, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/bruise_pack, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/tricordrazine, WEAR_IN_L_STORE)
	//weapon
	add_dogwar_rifle_upp_pouch(new_human)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)

/datum/equipment_preset/canc_dogwar/upp/marksman
	name = "CANC Soldier, Marksman (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_CA2 = JOB_PLAYTIME_TIER_0)
	assignment = "Marksman"

/datum/equipment_preset/canc_dogwar/upp/marksman/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	if(prob(50))
		var/coolhat = pick(/obj/item/clothing/head/headband/red, /obj/item/clothing/head/cmcap/flap/canc, /obj/item/clothing/head/uppcap/boonie/canc)
		new_human.equip_to_slot_or_del(new coolhat(new_human), WEAR_HEAD)
	var/coolhairdo = pick("Bald", "Shaved Head", "Shaved Balding", "Shaved Mohawk", "Shaved Mohawk 2")
	new_human.h_style = coolhairdo
	new_human.regenerate_icons()
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(1))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_ACCESSORY)
	if(prob(70))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e2(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/svd/pve(new_human), WEAR_J_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/svd/pve(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/svd/pve(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/svd/pve(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/canc_dogwar/upp/antitank_loader
	name = "CANC Soldier, Anti-Tank Loader (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"

/datum/equipment_preset/canc_dogwar/upp/antitank_loader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/rocketpack(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/at(new_human), WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/at(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp(new_human), WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/incen(new_human), WEAR_IN_BACK)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/upp/incen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/droppouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	//weapon
	add_dogwar_rifle_upp_pouch(new_human)

/datum/equipment_preset/canc_dogwar/upp/antiair
	name = "CANC Soldier, Anti-Air Specialist (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Anti-Air Specialist"

/datum/equipment_preset/canc_dogwar/upp/antiair/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/anti_air/upp(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/droppouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//belt
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/general_belt/upp(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/anti_air/upp(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/anti_air/upp(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	//weapon
	add_dogwar_rifle_upp_pouch(new_human)

/datum/equipment_preset/canc_dogwar/upp/shotgun
	name = "CANC Soldier, Shotgunner (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Shotgunner"

/datum/equipment_preset/canc_dogwar/upp/shotgun/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(80))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	var/random_canc_shotgun = rand(1,2)
	switch(random_canc_shotgun)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/shotgun/upp/heavybuck(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/type23(new_human), WEAR_J_STORE)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/shotgun/upp/heavyslug(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/type23/slug(new_human), WEAR_J_STORE)

/datum/equipment_preset/canc_dogwar/upp/leader
	name = "CANC Soldier, Squad Leader (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Squad Leader"
	skills = /datum/skills/canc_soldier/sl

/datum/equipment_preset/canc_dogwar/upp/leader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/fire_support/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/regular/upp(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_ACCESSORY)
	if(prob(25))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_R_STORE)
	//weapon
	add_dogwar_rifle_upp(new_human)

/datum/equipment_preset/canc_dogwar/upp/pl_leader
	name = "CANC Soldier, Platoon Leader (UPP)"
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_CA7 = JOB_PLAYTIME_TIER_0)
	assignment = "Platoon Leader"
	skills = /datum/skills/canc_soldier/pl

/datum/equipment_preset/canc_dogwar/upp/pl_leader/load_gear(mob/living/carbon/human/new_human) // SS220 EDIT: fix the proc path so it does not create hidden /soldier/upp preset types
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/fire_support/upp(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc(new_human), WEAR_HEAD)
	if(prob(30))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/orange(new_human), WEAR_IN_HELMET)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/upp, WEAR_IN_ACCESSORY)
	if(prob(15))
		new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/laika, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/storage/box/matches, WEAR_IN_ACCESSORY)
	if(prob(50))
		new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_ACCESSORY)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/e7(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/alt, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_R_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/stripped(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_BELT)

/////////////////////////////
// CANC Armed Forces (SOF) //
/////////////////////////////

/datum/equipment_preset/canc_dogwar/specops
	name = "CANC Soldier, SOF Rifleman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Rifleman"
	paygrades = list(PAY_SHORT_CA2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/sof

/datum/equipment_preset/canc_dogwar/specops/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/plastic/breaching_charge(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/sof(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf/tan(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/black(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc/specops(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/canc(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC/specops(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317/specops(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)

/datum/equipment_preset/canc_dogwar/specops/leader
	name = "CANC Soldier, SOF Squad Leader"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Squad Leader"
	paygrades = list(PAY_SHORT_CA7 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/sof/sl

/datum/equipment_preset/canc_dogwar/specops/leader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/plastic/breaching_charge(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/adv/upp(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/sof(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf/tan(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/black(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc/specops(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/canc(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	//belt
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/type47/np92/suppressed(new_human), WEAR_WAIST)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC/specops(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(new_human), WEAR_L_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317/specops(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_R_STORE)

/datum/equipment_preset/canc_dogwar/specops/marksman
	name = "CANC Soldier, SOF Marksman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Marksman"
	paygrades = list(PAY_SHORT_CA4 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/sof

/datum/equipment_preset/canc_dogwar/specops/marksman/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator/upp(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/sof(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf/tan(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/canc_monoscope(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc/specops(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/black(new_human), WEAR_IN_HELMET)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/canc(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC/specops(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317/dmr/specops(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)

/datum/equipment_preset/canc_dogwar/specops/antitank
	name = "CANC Soldier, SOF Anti-Tank Rifleman"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Anti-Tank Rifleman"
	paygrades = list(PAY_SHORT_CA2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/sof

/datum/equipment_preset/canc_dogwar/specops/antitank/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller/bedroll(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/kitchen/can_opener(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/plastic/breaching_charge(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/prop/folded_anti_tank_sadar/canc(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/sof(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf/tan(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/black(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc/specops(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/canc(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC/specops(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317/specops(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine/upp(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_BELT)

/datum/equipment_preset/canc_dogwar/specops/medic
	name = "CANC Soldier, SOF Field Medic"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "Field Medic"
	paygrades = list(PAY_SHORT_CA3 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/canc_soldier/sof/medic

/datum/equipment_preset/canc_dogwar/specops/medic/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack/upp(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/burn/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/toxin/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/adv/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/surgical/upp(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/roller(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/sof(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf/tan(new_human), WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(new_human), WEAR_EYES)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/canc/specops(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles/black(new_human), WEAR_IN_HELMET)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/canc(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/upp, WEAR_IN_ACCESSORY)
	//belt
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/lifesaver/upp/synth(new_human), WEAR_WAIST)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/CANC/specops(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medical, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/ointment, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/stack/medical/advanced/bruise_pack, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/healthanalyzer, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/tricordrazine, WEAR_IN_L_STORE)
	//weapon
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lw317/specops(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lw317/ap, WEAR_IN_R_STORE)

//OTHER CANC//

/datum/equipment_preset/canc_dogwar/soldier/officer
	name = "CANC Soldier, Officer"
	flags = EQUIPMENT_PRESET_EXTRA
	paygrades = list(PAY_SHORT_CO1 = JOB_PLAYTIME_TIER_0)
	assignment = "Commander"
	skills = /datum/skills/canc_soldier/officer

/datum/equipment_preset/canc_dogwar/soldier/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command(new_human), WEAR_L_EAR)
	var/random_neckwear_canc = rand(1,4)
	switch(random_neckwear_canc)
		if(1,2)
			add_neckerchief(new_human)
		if(3)
			add_facewrap(new_human)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/peaked/canc(new_human), WEAR_HEAD)
	//uniform
	add_canc_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/smallpouch/upp, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/t73, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/canc/o1(new_human), WEAR_ACCESSORY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/jacket/marine/upp/canc(new_human), WEAR_JACKET)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard/canc(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown(new_human), WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/command, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/t73, WEAR_IN_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/fire_support/upp, WEAR_IN_L_STORE)
