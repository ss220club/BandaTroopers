
/datum/equipment_preset/upp/militia/rto
	name = "UPP People's Territorial Guardsman RTO"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "People's Territorial Guard Radio Transmissions Operator"
	role_comm_title = "PTG-RTO"
	paygrades = list(PAY_SHORT_UE2 = JOB_PLAYTIME_TIER_0, PAY_SHORT_UE3 = JOB_PLAYTIME_TIER_1)

/datum/equipment_preset/upp/militia/rto/load_gear(mob/living/carbon/human/new_human)

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
		new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/ushanka, WEAR_HEAD)
	new_human.undershirt = "Territorial Guard Telnyashka"
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/rto/upp_net/small, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/hatchet, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigar/matchbook/brown, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/brown, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight/flare/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/upp/territorial, WEAR_L_EAR)
	var/random_hat= rand(1,3)
	switch(random_hat)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap, WEAR_HEAD)
		if(2 to 3)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/boonie, WEAR_HEAD)
	var/obj/item/clothing/under/marine/veteran/UPP/uniform = new()
	var/random_uniform = rand(1,2)
	switch(random_uniform)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/patch/upp, WEAR_ACCESSORY)
	var/random_storage = pick(/obj/item/clothing/accessory/storage/webbing, /obj/item/clothing/accessory/storage/droppouch)
	new_human.equip_to_slot_or_del(new random_storage, WEAR_ACCESSORY)
	var/random_jacket= rand(1,5)
	switch(random_jacket)
		if(1 to 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/jacket, WEAR_JACKET)
		if(3 to 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/lamp, WEAR_JACKET)
		if(5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/light, WEAR_JACKET)
	if(prob(95))
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71, WEAR_J_STORE)
	else
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_ACCESSORY)
		new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/double/upp, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp/guard, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/machete/arnold/weak, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/compass, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/tool/shovel/etool/upp/folded, WEAR_IN_R_STORE)

/datum/equipment_preset/upp/rto
	name = "UPP Squad Radio Transmissions Operator (Equipped, Type 71)"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	assignment = JOB_SQUAD_UPP_RTO
	role_comm_title = "RTO"
	rank = JOB_SQUAD_MARINE
	paygrades = list(PAY_SHORT_UE2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pfc
	access = list(ACCESS_UPP_GENERAL)

/datum/equipment_preset/upp/rto/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "Naval Infantry Telnyashka"
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/rto/upp_net(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/packet/high_explosive/upp/impact, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/upp, WEAR_L_EAR)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	add_upp_head(new_human)
	add_upp_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/standard, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/preloaded, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/machete/arnold/weak, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)

/datum/equipment_preset/upp/rto/ag80
	name = "UPP Squad Radio Transmissions Operator (Equipped, AG80)"

/datum/equipment_preset/upp/rto/ag80/load_gear(mob/living/carbon/human/new_human)

	new_human.undershirt = "Naval Infantry Telnyashka"
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/rto/upp_net(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/canteen, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/packet/high_explosive/upp/impact, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/upp, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/upp, WEAR_L_EAR)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	add_upp_head(new_human)
	add_upp_uniform(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/standard, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/ag80/preloaded, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/large_holster/machete/arnold/weak, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ag80, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ag80, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ag80, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate, WEAR_L_STORE)

/datum/human_ai_equipment_preset/upp/rto
	name = "UPP Squad RTO"
	desc = "The standard UPP soldier, but with a radio backpack. These guys are equipped well enough to fight most forces."
	path = /datum/equipment_preset/upp/rto

/datum/human_ai_equipment_preset/upp/rto/ag80
	name = "UPP Squad RTO - AG80"
	desc = "The standard UPP soldier, but with a radio backpack. These guys are equipped well enough to fight most forces."
	path = /datum/equipment_preset/upp/rto/ag80

/datum/human_ai_equipment_preset/upp/militia/rto
	name = "UPP People's Territorial Guardsman RTO"
	desc = "The auxiliary troop of the UPP, armed with second hand equipment for more basic work. This one is a radio transmissions operator."
	path = /datum/equipment_preset/upp/militia/rto

/datum/job/marine/standard/ai/rto/upp
	title = JOB_SQUAD_UPP_RTO
	gear_preset = /datum/equipment_preset/upp/rto
	gear_preset_secondary = /datum/equipment_preset/upp/rto/ag80
	job_options = list(RIFLEMAN_VARIANT = "Rifleman", PULSE_RIFLEMAN_VARIANT = "Pulse Rifleman")

/obj/effect/landmark/start/marine/rto/upp
	name = JOB_SQUAD_UPP_RTO
	squad = SQUAD_UPP
	job = /datum/job/marine/standard/ai/rto/upp

/datum/equipment_preset/uscm/rto/upp
	name = "UPP Radio Transmissions Operator"
	assignment = JOB_SQUAD_UPP_RTO

/datum/equipment_preset/uscm/rto/upp/forecon
	name = "UPP Recon Radio Transmissions Operator"
	assignment = JOB_SQUAD_RTO_FORECON_UPP

/datum/equipment_preset/uscm/rto/upp/forecon/corporal
	name = parent_type::name + " (E3 Rank)"
	paygrades = list(PAY_SHORT_UE3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/rto/upp/forecon/senior_private
	name = parent_type::name + " (E2 Rank)"
	paygrades = list(PAY_SHORT_UE2 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/upp/forecon_preview
	name = "UPP Recon Rifleman (Preview)"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	assignment = JOB_SQUAD_MARINE_FORECON_UPP
	role_comm_title = "RFN"
	paygrades = list(PAY_SHORT_UE2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pfc
	access = list(ACCESS_UPP_GENERAL)
	var/backpack_type = /obj/item/storage/backpack/marine/upp

/datum/equipment_preset/upp/forecon_preview/load_gear(mob/living/carbon/human/new_human)
	new_human.undershirt = "Naval Infantry Telnyashka"
	var/obj/item/storage/backpack/backpack = new backpack_type(new_human)
	new_human.equip_to_slot_or_del(backpack, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/upp/forecon(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/uppcap/beret/para(new_human), WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/UPP(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/patch/upp/recon(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/faction/UPP/recon(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/type71/carbine/recon(new_human), WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/upp(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine(new_human), WEAR_HANDS)

/datum/equipment_preset/upp/forecon_preview/team_leader
	name = "UPP Recon Team Leader (Preview)"
	assignment = JOB_SQUAD_TEAM_LEADER_FORECON_UPP
	role_comm_title = "RTL"
	paygrades = list(PAY_SHORT_UE6 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/upp/forecon_preview/leader
	name = "UPP Recon Squad Sergeant (Preview)"
	assignment = JOB_SQUAD_LEADER_FORECON_UPP
	role_comm_title = "RSS"
	paygrades = list(PAY_SHORT_UE7 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/upp/forecon_preview/medic
	name = "UPP Recon Sanitar (Preview)"
	assignment = JOB_SQUAD_MEDIC_FORECON_UPP
	role_comm_title = "SNA"
	paygrades = list(PAY_SHORT_UE3 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/medic
	backpack_type = /obj/item/storage/backpack/marine/upp/medic

/datum/equipment_preset/upp/forecon_preview/rto
	name = "UPP Recon Radio Transmissions Operator (Preview)"
	assignment = JOB_SQUAD_RTO_FORECON_UPP
	role_comm_title = "RTO"
	paygrades = list(PAY_SHORT_UE3 = JOB_PLAYTIME_TIER_0)
	backpack_type = /obj/item/storage/backpack/marine/satchel/rto/upp_net

/datum/equipment_preset/upp/forecon_preview/smartgunner
	name = "UPP Recon Machinegunner (Preview)"
	assignment = JOB_SQUAD_SMARTGUN_FORECON_UPP
	role_comm_title = "SG"
	paygrades = list(PAY_SHORT_UE4 = JOB_PLAYTIME_TIER_0)
	backpack_type = /obj/item/storage/backpack/marine/ammo_rack/upp/recon
