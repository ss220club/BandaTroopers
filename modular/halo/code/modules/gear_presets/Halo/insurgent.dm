/datum/equipment_preset/insurgent
	name = FACTION_INSURGENT
	languages = list(LANGUAGE_ENGLISH)
	assignment = JOB_INSURGENT
	rank = FACTION_INSURGENT
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	faction = FACTION_INSURGENT
	origin_override = ORIGIN_CIVILIAN
	idtype = /obj/item/card/id/data

/datum/equipment_preset/insurgent/New()
	. = ..()
	access = get_access(ACCESS_LIST_CLF_BASE)

/datum/equipment_preset/insurgent/load_name(mob/living/carbon/human/new_human, randomise)
	new_human.gender = pick(60;MALE,40;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance(new_human)
	var/random_name
	random_name = capitalize(pick(new_human.gender == MALE ? GLOB.first_names_male : GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	new_human.change_real_name(new_human, random_name)
	new_human.name = new_human.real_name
	new_human.age = rand(22,45)

	var/static/list/colors = list("BLACK" = list(15, 15, 25), "BROWN" = list(102, 51, 0), "AUBURN" = list(139, 62, 19))
	var/static/list/hair_colors = colors.Copy() + list("BLONDE" = list(197, 164, 30), "CARROT" = list(174, 69, 42))
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
	idtype = /obj/item/card/id/data
	if(new_human.gender == MALE)
		new_human.h_style = pick("Crewcut", "Shaved Head", "Buzzcut", "Undercut", "Side Undercut", "Pvt. Joker", "Marine Fade", "Low Fade", "Medium Fade", "High Fade", "No Fade", "Coffee House Cut", "Flat Top",)
		new_human.f_style = pick("5 O'clock Shadow", "Shaved", "Full Beard", "3 O'clock Moustache", "5 O'clock Shadow", "5 O'clock Moustache", "7 O'clock Shadow", "7 O'clock Moustache",)
	else
		new_human.h_style = pick("Ponytail 1", "Ponytail 2", "Ponytail 3", "Ponytail 4", "Pvt. Redding", "Pvt. Clarison", "Cpl. Dietrich", "Pvt. Vasquez", "Marine Bun", "Marine Bun 2", "Marine Flat Top",)
	new_human.change_real_name(new_human, random_name)
	new_human.age = rand(20,45)
	new_human.r_hair = rand(15,35)
	new_human.g_hair = rand(15,35)
	new_human.b_hair = rand(25,45)

//*****************************************************************************************************/
//    PARTISANS

/datum/equipment_preset/insurgent/partisan
	name = "Partisan (Pistol)"
	assignment = JOB_INSURGENT_PARTISAN
	rank = JOB_INSURGENT_PARTISAN
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "PRT"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/civilian

/datum/equipment_preset/insurgent/partisan/load_gear(mob/living/carbon/human/new_human)
	var/random_partisan_clothes = rand(1,2)
	switch(random_partisan_clothes)
		if(1)
			add_civilian_uniform(new_human)
		if(2)
			add_worker_uniform(new_human)
	add_rebel_ua_shoes(new_human)
	add_rebel_gloves(new_human)
	add_rebel_ua_suit(new_human)
	if(prob(10))
		new_human.equip_to_slot_or_del(new /obj/item/weapon/twohanded/fireaxe, WEAR_L_HAND)

	if(prob(80))
		var/random_helmet = rand(1,4)
		switch(random_helmet)
			if(1)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white, WEAR_HEAD)
			if(2)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/dblue, WEAR_HEAD)
			if(3)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/headband/red, WEAR_HEAD)
			if(4)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/welding, WEAR_HEAD)

	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_R_STORE)
	var/random_pistol = rand(1,2)
	switch(random_pistol)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6a, WEAR_WAIST)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6c/m4a, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre, WEAR_IN_BACK)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)

/datum/equipment_preset/insurgent/partisan/smg
	name = "Partisan (SMG/Rifles)"

/datum/equipment_preset/insurgent/partisan/smg/load_gear(mob/living/carbon/human/new_human)
	var/random_partisan_clothes = rand(1,2)
	switch(random_partisan_clothes)
		if(1)
			add_civilian_uniform(new_human)
		if(2)
			add_worker_uniform(new_human)
	add_rebel_ua_shoes(new_human)
	add_rebel_gloves(new_human)
	add_rebel_ua_suit(new_human)

	if(prob(80))
		var/random_helmet = rand(1,4)
		switch(random_helmet)
			if(1)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white, WEAR_HEAD)
			if(2)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/dblue, WEAR_HEAD)
			if(3)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/headband/red, WEAR_HEAD)
			if(4)
				new_human.equip_to_slot_or_del(new /obj/item/clothing/head/welding, WEAR_HEAD)

	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_R_STORE)
	var/random_longarms = rand(1,2)
	switch(random_longarms)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m7/full, WEAR_WAIST)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/vk78(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre, WEAR_IN_BACK)
	if(prob(60))
		new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, WEAR_IN_BACK)

/datum/equipment_preset/insurgent/partisan/plainclothes
	name = "Partisan (Plainclothes, Pistol)"

/datum/equipment_preset/insurgent/partisan/plainclothes/load_gear(mob/living/carbon/human/new_human)
	var/random_partisan_clothes_plain = rand(1,2)
	switch(random_partisan_clothes_plain)
		if(1)
			add_civilian_uniform(new_human)
			add_civilian_shoe(new_human)
			add_civilian_jacket(new_human)
		if(2)
			add_worker_uniform(new_human)
			add_worker_shoe(new_human)
			add_worker_gloves(new_human)
			if(prob(50))
				add_worker_jacket(new_human)

	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_R_STORE)
	add_random_satchel(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6a, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6a, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6a, WEAR_IN_BACK)

/datum/equipment_preset/insurgent/partisan/plainclothes/smg
	name = "Partisan (Plainclothes, SMG/Rifle)"

/datum/equipment_preset/insurgent/partisan/plainclothes/smg/load_gear(mob/living/carbon/human/new_human)
	var/random_partisan_clothes_plain = rand(1,2)
	switch(random_partisan_clothes_plain)
		if(1)
			add_civilian_uniform(new_human)
			add_civilian_shoe(new_human)
			add_civilian_jacket(new_human)
		if(2)
			add_worker_uniform(new_human)
			add_worker_shoe(new_human)
			add_worker_gloves(new_human)
			if(prob(50))
				add_worker_jacket(new_human)

	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_R_STORE)
	add_random_satchel(new_human)
	var/random_longarms_plain = rand(1,2)
	switch(random_longarms_plain)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/halo/m7, WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/halo/m7(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/halo/m7(new_human), WEAR_IN_BACK)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/vk78, WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BACK)

/datum/equipment_preset/insurgent/partisan/breach
	name = "Partisan Breacher"
	assignment = JOB_INSURGENT_PARTISAN_BREACH
	rank = JOB_INSURGENT_PARTISAN_BREACH
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "PRTL"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/cmb

/datum/equipment_preset/insurgent/partisan/breach/load_gear(mob/living/carbon/human/new_human)
	add_worker_uniform(new_human)
	add_rebel_ua_shoes(new_human)
	add_rebel_gloves(new_human)

	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/police, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/neckguard/police, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/groin/police, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/bracers/police, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/police, WEAR_HEAD)

	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/halo/m90/police, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6a, WEAR_WAIST)

	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/civ, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/beanbag/unsc, WEAR_IN_BACK)

//*****************************************************************************************************/
//    INSURGENTS

/datum/equipment_preset/insurgent/rifleman
	name = "Insurgent Soldier (Rifleman)"
	assignment = JOB_INSURGENT
	rank = JOB_INSURGENT
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/trooper

/datum/equipment_preset/insurgent/rifleman/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/insurrection(new_human), WEAR_HEAD)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/vk78(new_human), WEAR_J_STORE)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m3/small(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

/datum/equipment_preset/insurgent/rifleman/breacher
	name = "Insurgent Soldier (Breacher)"
	assignment = JOB_INSURGENT
	rank = JOB_INSURGENT
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/trooper

/datum/equipment_preset/insurgent/rifleman/breacher/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot/unsc, WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/beret/cm/tan(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/military, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/halo/m90(new_human), WEAR_J_STORE)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/m3/small(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6a, WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

/datum/equipment_preset/insurgent/technician
	name = "Insurgent Soldier (Technician)"
	assignment = JOB_INSURGENT_TECHNICIAN
	rank = JOB_INSURGENT_TECHNICIAN
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-TECH"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/mainttech

/datum/equipment_preset/insurgent/technician/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/khaki(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/groin/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/tool_webbing/small/equipped(new_human), WEAR_ACCESSORY)
	//weapon
	var/random_longarms_insurgent = rand(1,3)
	switch(random_longarms_insurgent)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma3a(new_human), WEAR_J_STORE)
		if(2 to 3)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/vk78(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/vk78(new_human), WEAR_J_STORE)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/construction/low_grade_full(new_human), WEAR_R_STORE)

/datum/equipment_preset/insurgent/specialist
	name = "Insurgent Soldier (Specialist, SPNKr)"
	assignment = JOB_INSURGENT_SPECIALIST
	rank = JOB_INSURGENT_SPECIALIST
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-SPEC"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/nco

/datum/equipment_preset/insurgent/specialist/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/halo_launcher/spnkr(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/insurrection(new_human), WEAR_HEAD)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma3a(new_human), WEAR_J_STORE)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/groin/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/neckguard/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/bracers/insurrection(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/general_belt(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/spnkr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/spnkr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/insurgent/specialist/sniper
	name = "Insurgent Soldier (Specialist, Sniper)"
	assignment = JOB_INSURGENT_SPECIALIST
	rank = JOB_INSURGENT_SPECIALIST
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-SPEC"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/nco

/datum/equipment_preset/insurgent/specialist/sniper/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/halo/m6c(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(new_human), WEAR_HEAD)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/dmr(new_human), WEAR_J_STORE)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/dmr(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c/m4a(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/insurgent/specialist/sniper/srs
	name = "Insurgent Soldier (Specialist, Sniper, SRS)"
	assignment = JOB_INSURGENT_SPECIALIST
	rank = JOB_INSURGENT_SPECIALIST
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-SPEC"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/nco

/datum/equipment_preset/insurgent/specialist/sniper/srs/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/halo(new_human), WEAR_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie/tan(new_human), WEAR_HEAD)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/sniper(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/pistol/unsc(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/halo/m6c/m4a(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/insurgent/rifleman/sl
	name = "Insurgent Soldier (Squad Leader)"
	assignment = JOB_INSURGENT_SL
	rank = JOB_INSURGENT_SL
	paygrades = list(PAY_SHORT_REB = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-SL"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/snco

/datum/equipment_preset/insurgent/rifleman/sl/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/civ(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/unsc/insurrection(new_human), WEAR_HEAD)
	if(prob(20))
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma3a(new_human), WEAR_J_STORE)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/bracers/insurrection(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/marine(new_human), WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_BELT)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(new_human), WEAR_R_STORE)

/datum/equipment_preset/insurgent/officer
	name = "Insurgent Officer"
	assignment = JOB_INSURGENT_LEAD
	rank = JOB_INSURGENT_LEAD
	paygrades = list(PAY_SHORT_REBC = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-O"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/lt

/datum/equipment_preset/insurgent/officer/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/civ(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/beret/cm/red(new_human), WEAR_HEAD)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/ma3a(new_human), WEAR_J_STORE)
	//accessories
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/insurrection(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/pads/unsc/greaves/insurrection(new_human), WEAR_ACCESSORY)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6c(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/civilian/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/ma3a(new_human), WEAR_IN_R_STORE)

/datum/equipment_preset/insurgent/cell_leader
	name = "Insurgent Cell Leader"
	assignment = JOB_INSURGENT_CELL_LEAD
	rank = JOB_INSURGENT_CELL_LEAD
	paygrades = list(PAY_SHORT_REBC = JOB_PLAYTIME_TIER_0)
	role_comm_title = "SLDR-CL"
	flags = EQUIPMENT_PRESET_EXTRA
	skills = /datum/skills/SL

/datum/equipment_preset/insurgent/cell_leader/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "undershirt"
	//back
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/unsc(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/folded(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre(new_human), WEAR_IN_BACK)
	//face
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/CLF(new_human), WEAR_L_EAR)
	//head
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/beret/cm/black(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf/tacticalmask/tan, WEAR_FACE)
	//uniform
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/khaki, WEAR_BODY)
	//jacket
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/unsc/odst/insurrection(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/halo/br55(new_human), WEAR_J_STORE)
	//waist
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m6/full_m6g(new_human), WEAR_WAIST)
	//limbs
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	//pockets
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/halo/br55(new_human), WEAR_IN_R_STORE)
