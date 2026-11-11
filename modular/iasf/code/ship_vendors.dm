/obj/structure/closet/secure_closet/marine_personal/iasf/spawn_gear()
	new /obj/item/clothing/head/cmcap/royal_marine/iasf(src)
	new /obj/item/clothing/under/marine/veteran/iasf(src)
	new /obj/item/device/radio/headset/almayer/marine/solardevils/rmc/iasf(src)
	new /obj/item/clothing/shoes/marine/rmc/knife(src)

/obj/structure/closet/secure_closet/marine_personal/iasf/officer
	job = JOB_IASF_OFFICER

/obj/structure/closet/secure_closet/marine_personal/iasf/commander
	job = JOB_IASF_SERGEANT

/obj/structure/closet/secure_closet/marine_personal/iasf/team
	job = JOB_IASF_TEAM

/obj/structure/closet/secure_closet/marine_personal/iasf/team/second

/obj/structure/closet/secure_closet/marine_personal/iasf/rifleman
	job = JOB_IASF_TROOPER

/obj/structure/closet/secure_closet/marine_personal/iasf/medic
	job = JOB_IASF_MEDIC

/obj/structure/closet/secure_closet/marine_personal/iasf/gunner
	job = JOB_IASF_GUNNER

/obj/structure/closet/secure_closet/marine_personal/iasf/sniper
	job = JOB_IASF_SNIPER

/obj/structure/closet/secure_closet/marine_personal/iasf/breacher
	job = JOB_IASF_BREACHER

/obj/structure/closet/secure_closet/marine_personal/iasf/support
	job = JOB_IASF_ENGINEER

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/iasf
	parent_type = /obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/rmc
	name = "\improper WeyTech Surplus Uniform Vendor"
	desc = "An automated supply rack hooked up to a small storage of standard RMC uniforms."
	req_access = list(ACCESS_TWE_COMMANDO)

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/iasf/populate_product_list(scale)
	..()
	for(var/list/product in listed_products)
		switch(product[3])
			if(/obj/item/clothing/under/marine/veteran/royal_marine)
				product[1] = "Turing Watch combat uniform"
				product[3] = /obj/item/clothing/under/marine/veteran/iasf
			if(/obj/item/clothing/head/beanie/royal_marine)
				product[1] = "Turing Watch beret"
				product[3] = /obj/item/clothing/head/cmcap/royal_marine/iasf
			if(/obj/item/device/radio/headset/almayer/marine/solardevils/rmc)
				product[1] = "Turing Watch headset"
				product[3] = /obj/item/device/radio/headset/almayer/marine/solardevils/rmc/iasf
			if(/obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/rmc)
				product[1] = "L1 ballistic helmet"
				product[3] = /obj/item/clothing/head/helmet/marine/veteran/royal_marine/generic
			if(/obj/item/clothing/head/helmet/marine/veteran/pmc/rmc)
				product[1] = "L1 ballistic helmet"
				product[3] = /obj/item/clothing/head/helmet/marine/veteran/royal_marine/generic
			if(/obj/item/clothing/suit/marine/veteran/royal_marine)
				product[1] = "Goshawk light armor"
				product[3] = /obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/iasf
	parent_type = /obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/rmc
	name = "\improper WeyTech Automated Utilities Section Vendor"
	desc = "An automated supply rack hooked up to a small storage of various utilities and tools."
	req_access = list(ACCESS_TWE_COMMANDO)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/iasf/populate_product_list(scale)
	..()
	for(var/i = length(listed_products), i >= 1, i--)
		var/list/product = listed_products[i]
		if(product[3] == /obj/item/weapon/gun/pistol/vp70/unloaded || product[3] == /obj/item/ammo_magazine/pistol/vp70)
			listed_products.Cut(i, i + 1)
	listed_products += list(
		list("FN-TWE P90 AP magazine box", round(scale * 3), /obj/item/ammo_box/magazine/p90/twe, VENDOR_ITEM_REGULAR),
		list("FN-TWE P90 HEAP magazine box", round(scale * 3), /obj/item/ammo_box/magazine/p90/twe/heap, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/clothing/medic/iasf
	name = "\improper WeyTech Section Medical Equipment Rack"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_MEDIC)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/clothing/medic/iasf/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_rmc_medic

/obj/structure/machinery/cm_vending/gear/medic_chemical/rmc/iasf
	name = "\improper WeyTech Section Medical Chemical Rack"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_MEDIC)

/obj/structure/machinery/cm_vending/clothing/specialist/iasf
	name = "\improper WeyTech Section Marksman Equipment Rack"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_SNIPER)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/clothing/specialist/iasf/get_listed_products(mob/user)
	return list(
		list("SNIPER KIT", 0, null, null, null),
		list("F903A1 sniper kit", 0, /obj/item/storage/box/guncase/heavy/sniper/iasf, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),
		list("Reconnaissance vest", 0, /obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
		list("Панама ИАСФ", 0, /obj/item/clothing/head/beret/iasf/roaf_boonie, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Радиопак снайпера ИАСФ", 0, /obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf/sniper, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/clothing/engi/iasf
	name = "\improper WeyTech Section Breacher Equipment Rack"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_BREACHER)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/clothing/engi/iasf/get_listed_products(mob/user)
	return list(
		list("BREACHER KIT", 0, null, null, null),
		list("XM52 penetrator", 0, /obj/item/weapon/gun/rifle/xm52/iasf, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),
		list("XM52 holster rig", 0, /obj/item/storage/belt/gun/xm52, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("N45 battle hammer", 0, /obj/item/weapon/twohanded/breacher_hammer/iasf, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("Ballistic shield", 0, /obj/item/weapon/shield/riot/ballistic/iasf, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("Breacher helmet", 0, /obj/item/clothing/head/helmet/marine/veteran/royal_marine/breacher/iasf, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
		list("Breacher vest", 0, /obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
		list("XM52 AP magazine", 8, /obj/item/ammo_magazine/rifle/xm52/iasf_ap, null, VENDOR_ITEM_REGULAR),
		list("16g AP shell box", 4, /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots/iasf_ap, null, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/clothing/engi/iasf/engineer
	name = "\improper WeyTech Section Engineering Equipment Rack"
	vendor_role = list(JOB_IASF_ENGINEER)

/obj/structure/machinery/cm_vending/clothing/engi/iasf/engineer/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_rmc_engi

/obj/structure/machinery/cm_vending/sorted/marine_food/rmc/iasf
