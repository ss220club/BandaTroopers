/datum/equipment_preset/uscm/proc/spawn_random_hat(mob/living/carbon/human/new_human)
	var/i = rand(1,10)
	switch(i)
		if (1 , 2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(new_human), WEAR_HEAD)
		if (3 , 4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/beanie(new_human), WEAR_HEAD)
		if (5 , 6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/durag(new_human), WEAR_HEAD)
		if (7 , 8)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie(new_human), WEAR_HEAD)
		if (9)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(new_human), WEAR_HEAD)

// TL
/datum/equipment_preset/uscm/tl_equipped/load_gear(mob/living/carbon/human/new_human)
	. = ..()
	new_human.equip_to_slot_or_del(new 	/obj/item/device/overwatch_camera(new_human), WEAR_R_EAR)
	spawn_random_hat(new_human)
	add_uscm_goggles(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/prop/helmetgarb/gunoil, WEAR_IN_HELMET)

// RTO
/datum/equipment_preset/uscm/rto
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP, ACCESS_MARINE_TL_PREP)
	skills = /datum/skills/military/survivor/forecon_standard

/datum/equipment_preset/uscm/rto/load_gear(mob/living/carbon/human/new_human)
	. = ..()
	GLOB.character_traits[/datum/character_trait/skills/spotter].apply_trait(new_human)

// RTO Equipped
/datum/equipment_preset/uscm/rto/equipped
	name = "USCM Radio Telephone Operator (Equipped)"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE

/datum/equipment_preset/uscm/rto/equipped/load_status(mob/living/carbon/human/new_human)
	. = ..()
	new_human.nutrition = NUTRITION_NORMAL

/datum/equipment_preset/uscm/rto/equipped/load_gear(mob/living/carbon/human/new_human)
	. = ..()
	add_forecon_uniform(new_human)
	add_combat_gloves(new_human)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/ranks/marine/e5(new_human), WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/rto(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(new_human), WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full/alternate(new_human), WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/flask/marine(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre/fsr(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar/tactical(new_human), WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range/designator(new_human), WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/solardevils/forecon(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/marine/rto/forecon(new_human), WEAR_JACKET)

	new_human.equip_to_slot_or_del(new 	/obj/item/device/overwatch_camera(new_human), WEAR_R_EAR)
	spawn_random_hat(new_human)
	// add_uscm_cover(new_human)
	add_uscm_goggles(new_human)
