/datum/equipment_preset/corpse/tyrargo
	flags = EQUIPMENT_PRESET_STUB

/datum/equipment_preset/corpse/tyrargo/us_army_trooper
	name = "Corpse - US Army - Trooper"
	assignment = JOB_ARMY_TROOPER
	faction = FACTION_ARMY
	rank = JOB_ARMY_TROOPER
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/military/survivor/army_standard
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_CIVILIAN_PUBLIC,ACCESS_CIVILIAN_RESEARCH,ACCESS_CIVILIAN_ENGINEERING,ACCESS_CIVILIAN_LOGISTICS,ACCESS_CIVILIAN_BRIG,ACCESS_CIVILIAN_MEDBAY,ACCESS_CIVILIAN_COMMAND,)

/datum/equipment_preset/corpse/tyrargo/us_army_trooper/proc/spawn_pouch(mob/living/carbon/human/new_human)
	var/i = rand(1,6)
	switch(i)
		if (1)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid(new_human), WEAR_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack/random_amount(new_human), WEAR_IN_L_STORE)
		if (2)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid(new_human), WEAR_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/splint/random_amount(new_human), WEAR_IN_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/tricord/random_amount(new_human), WEAR_IN_L_STORE)
		if (3)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid(new_human), WEAR_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/bicaridine/random_amount(new_human), WEAR_IN_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/tramadol/random_amount(new_human), WEAR_IN_L_STORE)
		if (4)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid(new_human), WEAR_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/emergency(new_human), WEAR_IN_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack/random_amount(new_human), WEAR_IN_L_STORE)
		if (5)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid(new_human), WEAR_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/kelotane/random_amount(new_human), WEAR_IN_L_STORE)
		if (6)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid(new_human), WEAR_L_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/splint/random_amount(new_human), WEAR_IN_L_STORE)


/datum/equipment_preset/corpse/tyrargo/us_army_trooper/load_gear(mob/living/carbon/human/new_human)
	var/choice = rand(1,12)
	var/obj/item/clothing/under/marine/army/uniform = new()
	var/obj/item/clothing/accessory/ranks/marine/e2/pin = new()
	var/obj/item/clothing/accessory/patch/army/patch_army = new()
	var/obj/item/clothing/accessory/patch/army/infantry/patch_infantry = new()
	uniform.attach_accessory(new_human,patch_army)
	uniform.attach_accessory(new_human,pin)
	uniform.attach_accessory(new_human,patch_infantry)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/medium/rto/army(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/molle/army(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/army/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/army(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/orange(new_human), WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/sof/survivor_army(new_human), WEAR_L_EAR)
	spawn_pouch(new_human)

	switch(choice)
		if(1 to 5)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap, WEAR_HEAD)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster, WEAR_ACCESSORY)
		if(6 to 7)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/rto, WEAR_HEAD)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster, WEAR_ACCESSORY)
		if(8 to 10)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/rto, WEAR_HEAD)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/army, WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine, WEAR_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/heap/empty, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/heap/empty, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle, WEAR_IN_BACK)
		if(10 to 12)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap, WEAR_HEAD)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m49a/army, WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine, WEAR_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m49a, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m49a, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m49a, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m49a, WEAR_IN_BACK)
	..()

/datum/equipment_preset/corpse/tyrargo/us_army_trooper/burst
	name = "Corpse - Burst - US Army - Trooper"
	xenovictim = TRUE

/datum/equipment_preset/corpse/tyrargo/us_army_medic
	name = "Corpse - US Army - Medic"
	assignment = JOB_ARMY_MEDIC
	faction = FACTION_ARMY
	rank = JOB_ARMY_MEDIC
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/military/survivor/army_medic
	flags = EQUIPMENT_PRESET_START_OF_ROUND
	idtype = /obj/item/card/id/dogtag
	access = list(ACCESS_CIVILIAN_PUBLIC,ACCESS_CIVILIAN_RESEARCH,ACCESS_CIVILIAN_ENGINEERING,ACCESS_CIVILIAN_LOGISTICS,ACCESS_CIVILIAN_BRIG,ACCESS_CIVILIAN_MEDBAY,ACCESS_CIVILIAN_COMMAND,)

/datum/equipment_preset/corpse/tyrargo/us_army_medic/load_gear(mob/living/carbon/human/new_human)
	var/choice = rand(1,12)
	var/obj/item/clothing/under/marine/army/uniform = new()
	var/obj/item/clothing/accessory/patch/army/patch_army = new()
	var/obj/item/clothing/accessory/patch/army/infantry/patch_infantry = new()
	uniform.attach_accessory(new_human,patch_army)
	uniform.attach_accessory(new_human,patch_infantry)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/medium/rto/army(new_human), WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/molle/backpack/army(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/army/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/army(new_human), WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big/orange(new_human), WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/sof/survivor_army(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/medic(new_human), WEAR_HEAD)

	switch(choice)
		if(1 to 3)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical(new_human), WEAR_WAIST)
		if(4 to 7)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack/random_amount(new_human), WEAR_IN_BELT)
		if(8 to 11)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack/random_amount(new_human), WEAR_IN_BELT)
			new_human.equip_to_slot_or_del(new /obj/item/stack/medical/ointment/random_amount(new_human), WEAR_IN_BELT)
		if(12)
			new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/full/with_defib_and_analyzer(new_human), WEAR_WAIST)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine, WEAR_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/heap/empty, WEAR_IN_R_STORE)
	..()

/datum/equipment_preset/corpse/tyrargo/us_army_medic/burst
	name = "Corpse - Burst - US Army - Medic"
	xenovictim = TRUE
