// Only the Onyx prep vendors dispense Commando armor; other PMC vendors keep their stock.
/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/pmc/onyx_commando
	name = "\improper Azure-16 Commando Uniform Vendor"

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/pmc/onyx_commando/populate_product_list(scale)
	..(scale)
	var/list/commando_products = list()
	var/current_section = ""
	for(var/list/product as anything in listed_products)
		if(isnull(product[3]))
			current_section = product[1]
		if(product[1] == "MASK")
			commando_products += list(list("W-Y Large Auto-Injector Pouch", round(scale * 12), /obj/item/storage/pouch/autoinjector/full/wy/large, VENDOR_ITEM_REGULAR))
			commando_products += list(list("Commando Large Medical Pouch", round(scale * 12), /obj/item/storage/pouch/medical/socmed/commando, VENDOR_ITEM_REGULAR))
		var/product_type = product[3]
		if(ispath(product_type, /obj/item/storage/pouch) && product_type != /obj/item/storage/pouch/general/large && product_type != /obj/item/storage/pouch/magazine/pistol/large && product_type != /obj/item/storage/pouch/magazine/large/wy && product_type != /obj/item/storage/pouch/tools/tactical)
			continue
		if(product_type == /obj/item/clothing/accessory/storage/smallpouch/wy)
			continue
		if(product_type == /obj/item/clothing/suit/marine/veteran/pmc/light)
			continue
		if((current_section == "BACKPACK" || current_section == "RESTRICTED BACKPACKS") && ispath(product_type, /obj/item/storage/backpack) && product_type != /obj/item/storage/backpack/pmc/backpack)
			continue
		if(product_type == /obj/item/clothing/gloves/marine/veteran/pmc/black)
			continue
		switch(product[3])
			if(/obj/item/clothing/shoes/veteran/pmc/knife)
				product[1] = "Commando Combat Boots"
				product[3] = /obj/item/clothing/shoes/veteran/pmc/commando/knife
			if(/obj/item/clothing/under/marine/veteran/pmc)
				product[1] = "Commando Fatigues"
				product[3] = /obj/item/clothing/under/marine/veteran/pmc/leader/commando
			if(/obj/item/clothing/gloves/marine/veteran/pmc)
				product[1] = "Commando Combat Gloves"
				product[3] = /obj/item/clothing/gloves/marine/veteran/pmc/commando
			if(/obj/item/device/radio/headset/distress/pmc/platoon)
				product[1] = "Commando Radio Headset"
				product[3] = /obj/item/device/radio/headset/distress/pmc/commando
			if(/obj/item/clothing/head/helmet/marine/veteran/pmc)
				product[1] = "W-Y Mk17 Commando Helmet"
				product[3] = /obj/item/clothing/head/helmet/marine/veteran/pmc/enclosed/commando
			if(/obj/item/clothing/suit/marine/veteran/pmc)
				product[1] = "MY7 Commando Armor"
				product[3] = /obj/item/clothing/suit/marine/veteran/pmc/commando
			if(/obj/item/storage/backpack/pmc/backpack)
				product[1] = "Commando Combat Backpack"
				product[3] = /obj/item/storage/backpack/pmc/backpack/commando
			if(/obj/item/storage/pouch/tools/tactical)
				product[1] = "Tactical Engineering Tools Pouch"
				product[2] = round(scale * 12)
				product[3] = /obj/item/storage/pouch/tools/tactical/full
			if(/obj/item/storage/pouch/magazine/large/wy, /obj/item/storage/pouch/general/large)
				product[2] = round(scale * 15)
		commando_products += list(product)
	listed_products = commando_products

// Category counters are per marine, shared across these vendors and never tied to machine stock.
/obj/structure/machinery/cm_vending/gear/onyx_commando
	name = "Azure-16 Commando Equipment Vendor"
	icon_state = "pmc_gear"
	vendor_theme = VENDOR_THEME_COMPANY
	squad_tag = SQUAD_PMCPLT_SMALL
	req_access = list(ACCESS_WY_GENERAL)

/obj/structure/machinery/cm_vending/gear/onyx_commando/proc/initialize_commando_choices(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/commando = user
	if(!islist(commando.marine_buyable_categories))
		return
	if(!("onyx_leader_rifle" in commando.marine_buyable_categories))
		commando.marine_buyable_categories["onyx_leader_rifle"] = 1
		commando.marine_buyable_categories["onyx_leader_sidearm"] = 1
		commando.marine_buyable_categories["onyx_engineer_weapon"] = 1
		commando.marine_buyable_categories["onyx_engineer_sentry"] = 2
		commando.marine_buyable_categories["onyx_engineer_materials"] = 1
		commando.marine_buyable_categories["onyx_leader_supplies"] = 1

/obj/structure/machinery/cm_vending/gear/onyx_commando/leader
	name = "Azure-16 Commando Operations Leader Vendor"
	vendor_role = list(JOB_PMCPLAT_SMALL_LEADER)
	req_access = list(ACCESS_WY_SENIOR_LEAD)

/obj/structure/machinery/cm_vending/gear/onyx_commando/leader/get_listed_products(mob/user)
	initialize_commando_choices(user)
	return list(
		list("LEADER ARMOR AND GEAR", 0, null, null, null),
		list("Commando Leader Fatigues", 0, /obj/item/clothing/under/marine/veteran/pmc/leader/commando/leader, MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_MANDATORY),
		list("Commando Leader Armor", 0, /obj/item/clothing/suit/marine/veteran/pmc/commando/leader, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_MANDATORY),
		list("Commando Leader Helmet", 0, /obj/item/clothing/head/helmet/marine/veteran/pmc/enclosed/commando/leader, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_MANDATORY),
		list("Commando Leader Gloves", 0, /obj/item/clothing/gloves/marine/veteran/pmc/commando/leader, MARINE_CAN_BUY_GLOVES, VENDOR_ITEM_MANDATORY),
		list("Commando Leader Backpack", 0, /obj/item/storage/backpack/pmc/backpack/commando/leader, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_MANDATORY),
		list("Leader Pouches: Socmed, Large Magazine, Tactical Tools", 0, list(/obj/item/storage/pouch/medical/socmed/commando, /obj/item/storage/pouch/magazine/large/wy, /obj/item/storage/pouch/tools/tactical/full), "onyx_leader_supplies", VENDOR_ITEM_MANDATORY),
		list("PRIMARY WEAPON", 0, null, null, null),
		list("Black PMC M46C with two AP magazines", 0, list(/obj/item/weapon/gun/rifle/m46c/pmc, /obj/item/ammo_magazine/rifle/ap, /obj/item/ammo_magazine/rifle/ap), "onyx_leader_rifle", VENDOR_ITEM_MANDATORY),
		list("SIDEARM (CHOOSE ONE)", 0, null, null, null),
		list("VP78M6", 0, /obj/item/weapon/gun/pistol/vp78m6, "onyx_leader_sidearm", VENDOR_ITEM_RECOMMENDED),
		list("Commando Mateba with ammunition belt", 0, /obj/item/storage/belt/gun/mateba/commando/full, "onyx_leader_sidearm", VENDOR_ITEM_RECOMMENDED),
	)

/obj/structure/machinery/cm_vending/gear/onyx_commando/engineer
	name = "Azure-16 Corporate Engineer Vendor"
	vendor_role = list(JOB_PMCPLAT_SMALL_ENGINEER)
	req_access = list(ACCESS_WY_ENGINEERING)

/obj/structure/machinery/cm_vending/gear/onyx_commando/engineer/get_listed_products(mob/user)
	initialize_commando_choices(user)
	return list(
		list("W-Y TURRETS (CHOOSE TWO)", 0, null, null, null),
		list("W-Y Sentry", 0, /obj/item/defenses/handheld/sentry/wy, "onyx_engineer_sentry", VENDOR_ITEM_RECOMMENDED),
		list("W-Y Mini Sentry", 0, /obj/item/defenses/handheld/sentry/wy/mini, "onyx_engineer_sentry", VENDOR_ITEM_RECOMMENDED),
		list("W-Y Heavy Sentry", 0, /obj/item/defenses/handheld/sentry/wy/heavy, "onyx_engineer_sentry", VENDOR_ITEM_RECOMMENDED),
		list("W-Y Flamer Sentry", 0, /obj/item/defenses/handheld/sentry/flamer/wy, "onyx_engineer_sentry", VENDOR_ITEM_RECOMMENDED),
		list("HEAVY WEAPON (CHOOSE ONE)", 0, null, null, null),
		list("XM52 Breacher", 0, /obj/item/weapon/gun/rifle/xm52, "onyx_engineer_weapon", VENDOR_ITEM_RECOMMENDED),
		list("Flammenwerfer 3", 0, /obj/item/weapon/gun/flamer/flammenwerfer3/deathsquad, "onyx_engineer_weapon", VENDOR_ITEM_RECOMMENDED),
		list("CONSTRUCTION MATERIALS", 0, null, null, null),
		list("Tactical Engineering Tools Pouch", 0, /obj/item/storage/pouch/tools/tactical/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Metal, Plasteel and Sandbags", 0, list(/obj/item/stack/sheet/metal/large_stack, /obj/item/stack/sheet/plasteel/medium_stack, /obj/item/stack/sandbags_empty/half), "onyx_engineer_materials", VENDOR_ITEM_MANDATORY),
	)

/obj/structure/machinery/cm_vending/clothing/medic/pmc/onyx_commando
	name = "Azure-16 Commando Medical Vendor"
	squad_tag = SQUAD_PMCPLT_SMALL

/obj/structure/machinery/cm_vending/clothing/medic/pmc/onyx_commando/get_listed_products(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/commando = user
		if(islist(commando.marine_buyable_categories))
			if(!("onyx_med_bruise" in commando.marine_buyable_categories))
				commando.marine_buyable_categories["onyx_med_bruise"] = 5
				commando.marine_buyable_categories["onyx_med_ointment"] = 5
	return list(
		list("COMMANDO MEDICAL EQUIPMENT", 0, null, null, null),
		list("MY7 Commando Armor", 0, /obj/item/clothing/suit/marine/veteran/pmc/commando, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_MANDATORY),
		list("Commando Helmet", 0, /obj/item/clothing/head/helmet/marine/veteran/pmc/enclosed/commando, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_MANDATORY),
		list("Commando Combat Backpack", 0, /obj/item/storage/backpack/pmc/backpack/commando, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_MANDATORY),
		list("Commando Socmed Pouch", 0, /obj/item/storage/pouch/medical/socmed/commando, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("W-Y Large Auto-Injector Pouch", 0, /obj/item/storage/pouch/autoinjector/full/wy/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("W-Y Medical Belt (Full)", 0, /obj/item/storage/belt/medical/lifesaver/wy/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("Upgraded Bruise Pack", 0, /obj/item/stack/medical/advanced/bruise_pack/upgraded, "onyx_med_bruise", VENDOR_ITEM_RECOMMENDED),
		list("Upgraded Ointment", 0, /obj/item/stack/medical/advanced/ointment/upgraded, "onyx_med_ointment", VENDOR_ITEM_RECOMMENDED),
	)
