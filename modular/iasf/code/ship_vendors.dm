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
	job = JOB_IASF_SUPPORT

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/iasf
	name = "IASF equipment vendor"
	desc = "Standard uniform, armor, and field equipment for the Turing detachment."
	icon_state = "rmc_gear"
	req_access = list(ACCESS_TWE_COMMANDO)
	req_one_access = list()
	listed_products = list()
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/iasf/populate_product_list(scale)
	listed_products = list(
		list("UNIFORM", -1, null, null, null),
		list("IASF beret", round(scale * 10), /obj/item/clothing/head/cmcap/royal_marine/iasf, VENDOR_ITEM_REGULAR),
		list("IASF combat uniform", round(scale * 10), /obj/item/clothing/under/marine/veteran/iasf, VENDOR_ITEM_REGULAR),
		list("IASF headset", round(scale * 10), /obj/item/device/radio/headset/almayer/marine/solardevils/rmc/iasf, VENDOR_ITEM_REGULAR),
		list("Combat boots", round(scale * 10), /obj/item/clothing/shoes/marine/rmc/knife, VENDOR_ITEM_REGULAR),
		list("Combat gloves", round(scale * 10), /obj/item/clothing/gloves/marine, VENDOR_ITEM_REGULAR),
		list("ARMOR", -1, null, null, null),
		list("L1 ballistic helmet", round(scale * 10), /obj/item/clothing/head/helmet/marine/veteran/royal_marine/generic, VENDOR_ITEM_REGULAR),
		list("L5A3 breacher helmet", round(scale * 3), /obj/item/clothing/head/helmet/marine/veteran/royal_marine/breacher/iasf, VENDOR_ITEM_REGULAR),
		list("Kestrel cuirass", round(scale * 10), /obj/item/clothing/suit/marine/veteran/royal_marine, VENDOR_ITEM_REGULAR),
		list("Kestrel breacher vest", round(scale * 3), /obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher, VENDOR_ITEM_REGULAR),
		list("Kestrel GPMG harness", round(scale * 2), /obj/item/clothing/suit/marine/veteran/royal_marine/smartgun, VENDOR_ITEM_REGULAR),
		list("POUCHES AND WEBBING", -1, null, null, null),
		list("Magazine webbing", round(scale * 10), /obj/item/clothing/accessory/storage/webbing/m3/uppmags/rmc, VENDOR_ITEM_REGULAR),
		list("Drop pouch", round(scale * 10), /obj/item/clothing/accessory/storage/droppouch/rmc, VENDOR_ITEM_REGULAR),
		list("First responder pouch", round(scale * 10), /obj/item/storage/pouch/first_responder/rmc, VENDOR_ITEM_REGULAR),
		list("Magazine pouch", round(scale * 10), /obj/item/storage/pouch/magazine/large, VENDOR_ITEM_REGULAR),
		list("Pistol pouch", round(scale * 10), /obj/item/storage/pouch/pistol, VENDOR_ITEM_REGULAR),
		list("BACKPACKS", -1, null, null, null),
		list("IASF field backpack", round(scale * 10), /obj/item/storage/backpack/rmc/medium, VENDOR_ITEM_REGULAR),
		list("IASF medic backpack", round(scale * 3), /obj/item/storage/backpack/rmc/medic, VENDOR_ITEM_REGULAR),
		list("BELTS", -1, null, null, null),
		list("F903 magazine belt", round(scale * 10), /obj/item/storage/belt/marine/rmc/f90, VENDOR_ITEM_REGULAR),
		list("L54 gunbelt", round(scale * 10), /obj/item/storage/belt/gun/l905/l54, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/iasf
	name = "IASF armory vendor"
	desc = "Firearms, ammunition, and field supplies for the Turing detachment."
	req_access = list(ACCESS_TWE_COMMANDO)
	req_one_access = list()
	listed_products = list()
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/iasf/populate_product_list(scale)
	listed_products = list(
		list("RIFLES", -1, null, null, null),
		list("F903 rifle", round(scale * 6), /obj/item/weapon/gun/rifle/rmc_f90, VENDOR_ITEM_REGULAR),
		list("F903 marksman rifle", round(scale * 2), /obj/item/weapon/gun/rifle/rmc_f90/scope/ap, VENDOR_ITEM_REGULAR),
		list("F903 magazine box", round(scale * 8), /obj/item/ammo_box/magazine/f90, VENDOR_ITEM_REGULAR),
		list("F903 AP magazine box", round(scale * 4), /obj/item/ammo_box/magazine/f90/ap, VENDOR_ITEM_REGULAR),
		list("F903 marksman AP box", round(scale * 3), /obj/item/ammo_box/magazine/f90/marksman, VENDOR_ITEM_REGULAR),
		list("F903 marksman incendiary box", round(scale * 2), /obj/item/ammo_box/magazine/f90/marksman/incendiary, VENDOR_ITEM_REGULAR),
		list("F903 marksman impact box", round(scale * 2), /obj/item/ammo_box/magazine/f90/marksman/impact, VENDOR_ITEM_REGULAR),
		list("F903 marksman incendiary magazine", round(scale * 6), /obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary, VENDOR_ITEM_REGULAR),
		list("F903 marksman impact magazine", round(scale * 6), /obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact, VENDOR_ITEM_REGULAR),
		list("BREACHING", -1, null, null, null),
		list("Combat shotgun", round(scale * 3), /obj/item/weapon/gun/shotgun/combat, VENDOR_ITEM_REGULAR),
		list("Breaching hammer", round(scale * 3), /obj/item/weapon/twohanded/breacher, VENDOR_ITEM_REGULAR),
		list("IASF ballistic shield", round(scale * 3), /obj/item/weapon/shield/riot/ballistic/iasf, VENDOR_ITEM_REGULAR),
		list("Buckshot box", round(scale * 5), /obj/item/ammo_magazine/shotgun/buckshot, VENDOR_ITEM_REGULAR),
		list("SIDEARMS", -1, null, null, null),
		list("L54 pistol", round(scale * 6), /obj/item/weapon/gun/pistol/l54, VENDOR_ITEM_REGULAR),
		list("L54 magazine", round(scale * 12), /obj/item/ammo_magazine/pistol/l54, VENDOR_ITEM_REGULAR),
		list("FIELD SUPPLIES", -1, null, null, null),
		list("IASF field ration", round(scale * 10), /obj/item/storage/box/mre/twe, VENDOR_ITEM_REGULAR),
		list("Flare box", round(scale * 10), /obj/item/storage/box/flare/rmc, VENDOR_ITEM_REGULAR),
		list("First aid pouch", round(scale * 10), /obj/item/storage/pouch/firstaid/full/alternate, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/clothing/medic/iasf
	name = "IASF medical vendor"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_MEDIC)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/gear/medic_chemical/rmc/iasf
	name = "IASF medical chemical rack"
	req_access = list(ACCESS_TWE_MEDPREP)
	vendor_role = list(JOB_IASF_MEDIC)

/obj/structure/machinery/cm_vending/clothing/medic/iasf/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_rmc_medic

/obj/structure/machinery/cm_vending/clothing/specialist/iasf
	name = "IASF sniper vendor"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_SNIPER)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/clothing/specialist/iasf/get_listed_products(mob/user)
	return list(
		list("PRECISION WEAPONS", 0, null, null, null),
		list("Scoped F903 marksman rifle", 0, /obj/item/weapon/gun/rifle/rmc_f90/scope/ap, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),
		list("Incendiary marksman magazine", 0, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("Impact marksman magazine", 0, /obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("Incendiary magazine box", 15, /obj/item/ammo_box/magazine/f90/marksman/incendiary, null, VENDOR_ITEM_REGULAR),
		list("Impact magazine box", 15, /obj/item/ammo_box/magazine/f90/marksman/impact, null, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/clothing/engi/iasf
	name = "IASF breacher vendor"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_BREACHER)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/clothing/engi/iasf/get_listed_products(mob/user)
	return list(
		list("BREACHER KIT", 0, null, null, null),
		list("XM52 IASF penetrator", 0, /obj/item/weapon/gun/rifle/xm52/iasf, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),
		list("Breaching hammer", 0, /obj/item/weapon/twohanded/breacher, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_REGULAR),
		list("IASF ballistic shield", 0, /obj/item/weapon/shield/riot/ballistic/iasf, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("IASF breacher helmet", 0, /obj/item/clothing/head/helmet/marine/veteran/royal_marine/breacher/iasf, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("IASF breacher vest", 0, /obj/item/clothing/suit/marine/veteran/royal_marine/heavy/iasf_breacher, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_REGULAR),
		list("XM52 AP magazine", 8, /obj/item/ammo_magazine/rifle/xm52/iasf_ap, null, VENDOR_ITEM_REGULAR),
		list("16g AP shell box", 4, /obj/item/ammo_magazine/shotgun/light/breaching/sparkshots/iasf_ap, null, VENDOR_ITEM_REGULAR),
	)

/obj/structure/machinery/cm_vending/gear/mortar_stuff/iasf
	name = "IASF fire support vendor"
	req_access = list(ACCESS_TWE_COMMANDO)
	vendor_role = list(JOB_IASF_SUPPORT)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/sorted/marine_food/rmc/iasf
	name = "IASF ration vendor"
