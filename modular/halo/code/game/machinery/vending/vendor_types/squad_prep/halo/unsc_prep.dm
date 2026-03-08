//===========================//MAIN UNSC PREP\\================================\\

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc
	name = "\improper Uniform Vendor"

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc/populate_product_list(scale)
	listed_products = list(
		list("STANDARD EQUIPMENT", -1, null, null, null),
		list("Marine Combat Boots", floor(scale * 15), /obj/item/clothing/shoes/marine/knife, VENDOR_ITEM_REGULAR),
		list("Marine Uniform, Camo Conforming", floor(scale * 15), /obj/item/clothing/under/marine, VENDOR_ITEM_REGULAR),
		list("Marine Uniform, Jungle BDU", floor(scale * 15), /obj/item/clothing/under/marine/standard, VENDOR_ITEM_REGULAR),
		list("Marine Combat Gloves", floor(scale * 15), /obj/item/clothing/gloves/marine, VENDOR_ITEM_REGULAR),
		list("Marine Radio Headset", floor(scale * 15), /obj/item/device/radio/headset/almayer/marine/solardevils, VENDOR_ITEM_REGULAR),
		list("CH252 Pattern Marine Helmet", floor(scale * 15), /obj/item/clothing/head/helmet/marine/unsc, VENDOR_ITEM_REGULAR),
		list("M5 Pattern Camera Headset", floor(scale * 15), /obj/item/device/overwatch_camera, VENDOR_ITEM_REGULAR),
		list("Utility Cap, Jungle", floor(scale * 15), /obj/item/clothing/head/cmcap, VENDOR_ITEM_REGULAR),
		list("Utility Cap, Snow", floor(scale * 15), /obj/item/clothing/head/cmcap/snow, VENDOR_ITEM_REGULAR),
		list("Utility Cap, Desert", floor(scale * 15), /obj/item/clothing/head/cmcap/desert, VENDOR_ITEM_REGULAR),
		list("Operations Cap, Green", floor(scale * 15), /obj/item/clothing/head/cmcap/bridge, VENDOR_ITEM_REGULAR),
		list("Operations Cap, Tan", floor(scale * 15), /obj/item/clothing/head/cmcap/bridge/tan, VENDOR_ITEM_REGULAR),
		list("Boonie Hat, Jungle", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie, VENDOR_ITEM_REGULAR),
		list("Boonie Hat, Desert", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie/tan, VENDOR_ITEM_REGULAR),
		list("UNSC Shooting Shades", floor(scale * 15), /obj/item/clothing/glasses/sunglasses/big/unsc, VENDOR_ITEM_REGULAR),

		list("WEBBINGS", -1, null, null),
		list("M52B Pattern Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Magazine Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b/mag, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Shotgun Shell Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b/shotgun, VENDOR_ITEM_REGULAR),
		list("M52B Pattern M40 Webbing", 0.75, /obj/item/clothing/accessory/storage/webbing/m52b/grenade, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Small Pouch Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b/small, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 4, /obj/item/clothing/accessory/storage/droppouch, VENDOR_ITEM_REGULAR),
		list("Leg Pouch", 4, /obj/item/clothing/accessory/storage/smallpouch, VENDOR_ITEM_REGULAR),
		list("Shoulder Holster", round(max(1,(scale * 0.5))), /obj/item/clothing/accessory/storage/holster, VENDOR_ITEM_REGULAR),

		list("ARMOR", -1, null, null),
		list("Standard M52B Body Armor Set", round(scale * 15), /obj/item/storage/box/guncase/m52barmor, VENDOR_ITEM_REGULAR),
		list("M52B Body Armor", round(scale * 10), /obj/item/clothing/suit/marine/unsc, VENDOR_ITEM_REGULAR),
		list("M52B Shoulder Pads", round(scale * 10), /obj/item/clothing/accessory/pads/unsc, VENDOR_ITEM_REGULAR),
		list("M52B Groin Plate", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/groin, VENDOR_ITEM_REGULAR),
		list("M52B Greaves", round(scale * 15), /obj/item/clothing/accessory/pads/unsc/greaves, VENDOR_ITEM_REGULAR),
		list("M52B Arm Bracers", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/bracers, VENDOR_ITEM_REGULAR),
		list("M52B Neck Guard", round(scale * 15), /obj/item/clothing/accessory/pads/unsc/neckguard, VENDOR_ITEM_REGULAR),

		list("BACKPACK", -1, null, null, null),
		list("UNSC Rucksack", floor(scale * 15), /obj/item/storage/backpack/marine/unsc, VENDOR_ITEM_REGULAR),
		list("UNSC Buttpack", floor(scale * 15), /obj/item/storage/backpack/marine/satchel/unsc, VENDOR_ITEM_REGULAR),

		list("BELTS", -1, null, null),
		list("M276 Pattern Ammo Load Rig", floor(scale * 15), /obj/item/storage/belt/marine, VENDOR_ITEM_REGULAR),
		list("M276 Pattern Grenade Webbing", floor(scale * 10), /obj/item/storage/belt/grenade, VENDOR_ITEM_REGULAR),
		list("M6 General Pistol Holster Rig", floor(scale * 15), /obj/item/storage/belt/gun/m6, VENDOR_ITEM_REGULAR),
		list("M276 Pattern M82F Holster Rig", floor(scale * 5), /obj/item/storage/belt/gun/flaregun, VENDOR_ITEM_REGULAR),
		list("M276 G8-A General Utility Pouch", floor(scale * 15), /obj/item/storage/backpack/general_belt, VENDOR_ITEM_REGULAR),

		list("POUCHES", -1, null, null, null),
		list("First-Aid Pouch", floor(scale * 15), /obj/item/storage/pouch/firstaid, VENDOR_ITEM_REGULAR),
		list("Flare Pouch (Full)", floor(scale * 15), /obj/item/storage/pouch/flare/full, VENDOR_ITEM_REGULAR),
		list("Large Magazine Pouch", floor(scale * 15), /obj/item/storage/pouch/magazine/large, VENDOR_ITEM_REGULAR),
		list("Medium General Pouch", floor(scale * 15), /obj/item/storage/pouch/general/medium, VENDOR_ITEM_REGULAR),
		list("Pistol Magazine Pouch", floor(scale * 15), /obj/item/storage/pouch/magazine/pistol/unsc, VENDOR_ITEM_REGULAR),
		list("Pistol Pouch", floor(scale * 15), /obj/item/storage/pouch/pistol/unsc, VENDOR_ITEM_REGULAR),

		list("RESTRICTED POUCHES", -1, null, null, null),
		list("Construction Pouch", 1.25, /obj/item/storage/pouch/construction, VENDOR_ITEM_REGULAR),
		list("Explosive Pouch", 1.25, /obj/item/storage/pouch/explosive, VENDOR_ITEM_REGULAR),
		list("First Responder Pouch", 2.5, /obj/item/storage/pouch/first_responder, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", floor(scale * 2), /obj/item/storage/pouch/magazine/pistol/unsc/large, VENDOR_ITEM_REGULAR),
		list("Tools Pouch", 1.25, /obj/item/storage/pouch/tools, VENDOR_ITEM_REGULAR),
		list("Sling Pouch", 1.25, /obj/item/storage/pouch/sling, VENDOR_ITEM_REGULAR),

		list("MASK", -1, null, null, null),
		list("M5 Gas Mask", floor(scale * 15), /obj/item/clothing/mask/gas/military, VENDOR_ITEM_REGULAR),
		list("Tactical Wrap", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf/tacticalmask, VENDOR_ITEM_REGULAR),
		list("Heat Absorbent Coif", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf, VENDOR_ITEM_REGULAR),

		list("MISCELLANEOUS", -1, null, null, null),
		list("Ballistic goggles", round(scale * 10), /obj/item/clothing/glasses/mgoggles, VENDOR_ITEM_REGULAR),
		list("Ballistic goggles, sun-shaded", round(scale * 10), /obj/item/clothing/glasses/mgoggles/black, VENDOR_ITEM_REGULAR),
		list("Ballistic goggles, laser-shaded (brown)", round(scale * 10), /obj/item/clothing/glasses/mgoggles/orange, VENDOR_ITEM_REGULAR),
		list("Ballistic goggles, laser-shaded (green)", round(scale * 10), /obj/item/clothing/glasses/mgoggles/green, VENDOR_ITEM_REGULAR),
		list("Firearm Lubricant", round(scale * 15), /obj/item/prop/helmetgarb/gunoil, VENDOR_ITEM_REGULAR),
		list("LRRP Bedroll", round(scale * 15), /obj/item/roller/bedroll, VENDOR_ITEM_REGULAR),
		list("Marine Issue Compass", round(scale * 15), /obj/item/prop/helmetgarb/compass, VENDOR_ITEM_REGULAR),
		)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc
	name = "\improper Squad Utilities Vendor"

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc/populate_product_list(scale)
	listed_products = list(
		list("FOOD", -1, null, null),
		list("MRE", floor(scale * 5), /obj/item/storage/box/mre, VENDOR_ITEM_REGULAR),
		list("MRE Box", floor(scale * 1), /obj/item/ammo_box/magazine/misc/unsc/mre, VENDOR_ITEM_REGULAR),

		list("MEDICAL", -1, null, null),
		list("Gauze", round(scale * 15), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Ointment", round(scale * 15), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Splints", round(scale * 15), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),

		list("TOOLS", -1, null, null),
		list("Entrenching Tool (ET)", round(scale * 2), /obj/item/tool/shovel/etool/folded, VENDOR_ITEM_REGULAR),
		list("Screwdriver", round(scale * 5), /obj/item/tool/screwdriver, VENDOR_ITEM_REGULAR),
		list("Wirecutters", round(scale * 5), /obj/item/tool/wirecutters, VENDOR_ITEM_REGULAR),
		list("Crowbar", round(scale * 5), /obj/item/tool/crowbar, VENDOR_ITEM_REGULAR),
		list("Wrench", round(scale * 5), /obj/item/tool/wrench, VENDOR_ITEM_REGULAR),
		list("Multitool", round(scale * 1), /obj/item/device/multitool, VENDOR_ITEM_REGULAR),
		list("Welding Tool", round(scale * 1), /obj/item/tool/weldingtool, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", -1, null, null),
		list("Plastic Explosives", round(scale * 2), /obj/item/explosive/plastic, VENDOR_ITEM_REGULAR),
		list("Breaching Charge", round(scale * 2), /obj/item/explosive/plastic/breaching_charge, VENDOR_ITEM_REGULAR),

		list("FLARE AND LIGHT", -1, null, null),
		list("Combat Flashlight", round(scale * 5), /obj/item/device/flashlight/combat, VENDOR_ITEM_REGULAR),
		list("Box of Flashlight", round(scale * 1), /obj/item/ammo_box/magazine/misc/flashlight, VENDOR_ITEM_REGULAR),
		list("Box of Flares", round(scale * 1), /obj/item/ammo_box/magazine/misc/flares, VENDOR_ITEM_REGULAR),
		list("M94 Marking Flare Pack", round(scale * 10), /obj/item/storage/box/flare, VENDOR_ITEM_REGULAR),
		list("M89-S Signal Flare Pack", round(scale * 1), /obj/item/storage/box/flare/signal, VENDOR_ITEM_REGULAR),

		list("SIDEARMS", -1, null, null),
		list("M6C Service Magnum", round(scale * 4), /obj/item/weapon/gun/pistol/halo/m6c/unloaded, VENDOR_ITEM_REGULAR),
		list("M6G Service Magnum", round(scale * 4), /obj/item/weapon/gun/pistol/halo/m6g/unloaded, VENDOR_ITEM_REGULAR),
		list("KFA-2/G smart-linked scope", round(scale * 4), /obj/item/attachable/scope/mini/smartscope/m6g, VENDOR_ITEM_REGULAR),
		list("KFA-2/C smart-linked scope", round(scale * 4), /obj/item/attachable/scope/mini/smartscope/m6c, VENDOR_ITEM_REGULAR),
		list("M6 flashlight", round(scale * 4), /obj/item/attachable/flashlight/m6, VENDOR_ITEM_REGULAR),
		list("M82F Flare Gun", round(scale * 1), /obj/item/weapon/gun/flare, VENDOR_ITEM_REGULAR),

		list("MISCELLANEOUS", -1, null, null),
		list("Extinguisher", round(scale * 5), /obj/item/tool/extinguisher, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", round(scale * 1), /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Roller Bed", round(scale * 2), /obj/item/roller, VENDOR_ITEM_REGULAR),
		list("Machete Scabbard (Full)", round(scale * 5), /obj/item/storage/large_holster/machete/full, VENDOR_ITEM_REGULAR),
		list("Tactical Monocular", round(scale * 2), /obj/item/device/binoculars/range/monocular, VENDOR_ITEM_REGULAR),
		list("M13 Fighting Knife", round(scale * 25), /obj/item/weapon/knife/marine, VENDOR_ITEM_REGULAR),
		)

//===========================//ODST PREP\\================================\\

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc/odst
	name = "\improper ODST Uniform Vendor"

/obj/structure/machinery/cm_vending/sorted/uniform_supply/squad_prep/unsc/odst/populate_product_list(scale)
	listed_products = list(
		list("STANDARD EQUIPMENT", -1, null, null, null),
		list("UNSC Combat Boots", floor(scale * 15), /obj/item/clothing/shoes/marine/jungle/knife, VENDOR_ITEM_REGULAR),
		list("ODST bodyglove", floor(scale * 15), /obj/item/clothing/under/marine/odst, VENDOR_ITEM_REGULAR),
		list("Marine Combat Gloves", floor(scale * 15), /obj/item/clothing/gloves/marine, VENDOR_ITEM_MANDATORY),
		list("ODST Radio Headset", floor(scale * 15), /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/ferrymen, VENDOR_ITEM_REGULAR),
		list("M5 Pattern Camera Headset", floor(scale * 15), /obj/item/device/overwatch_camera, VENDOR_ITEM_REGULAR),
		list("Patrol Cap, Jungle BDU", floor(scale * 15), /obj/item/clothing/head/cmcap, VENDOR_ITEM_REGULAR),
		list("Boonie Hat, Jungle BDU", floor(scale * 15), /obj/item/clothing/head/cmcap/boonie, VENDOR_ITEM_REGULAR),

		list("WEBBINGS", -1, null, null),
		list("M52B Pattern Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Magazine Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b/mag, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Shotgun Shell Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b/shotgun, VENDOR_ITEM_REGULAR),
		list("M52B Pattern M40 Webbing", 0.75, /obj/item/clothing/accessory/storage/webbing/m52b/grenade, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Small Pouch Webbing", 2, /obj/item/clothing/accessory/storage/webbing/m52b/small, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 4, /obj/item/clothing/accessory/storage/droppouch, VENDOR_ITEM_REGULAR),
		list("Leg Pouch", 4, /obj/item/clothing/accessory/storage/smallpouch, VENDOR_ITEM_REGULAR),
		list("Shoulder Holster", round(max(1,(scale * 0.5))), /obj/item/clothing/accessory/storage/holster, VENDOR_ITEM_REGULAR),

		list("ARMOR", -1, null, null),
		list("CH381 ODST helmet", floor(scale * 15), /obj/item/clothing/head/helmet/marine/unsc/odst, VENDOR_ITEM_MANDATORY),
		list("Standard M70DT ODST BDU Set", round(scale * 15), /obj/item/storage/box/guncase/odstarmor, VENDOR_ITEM_MANDATORY),
		list("M70DT ODST BDU", round(scale * 10), /obj/item/clothing/suit/marine/unsc/odst, VENDOR_ITEM_REGULAR),
		list("M70DT Shoulder Pads", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/odst, VENDOR_ITEM_REGULAR),
		list("M70DT Groin Plate", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/groin/odst, VENDOR_ITEM_REGULAR),
		list("M70DT Greaves", round(scale * 15), /obj/item/clothing/accessory/pads/unsc/greaves/odst, VENDOR_ITEM_REGULAR),
		list("M70DT Arm Bracers", round(scale * 10), /obj/item/clothing/accessory/pads/unsc/bracers/odst, VENDOR_ITEM_REGULAR),

		list("BACKPACK", -1, null, null, null),
		list("UNSC Rucksack", floor(scale * 15), /obj/item/storage/backpack/marine/unsc, VENDOR_ITEM_REGULAR),
		list("UNSC Buttpack", floor(scale * 15), /obj/item/storage/backpack/marine/satchel/unsc, VENDOR_ITEM_REGULAR),

		list("BELTS", -1, null, null),
		list("M276 Pattern Ammo Load Rig", floor(scale * 15), /obj/item/storage/belt/marine, VENDOR_ITEM_REGULAR),
		list("M276 Pattern Grenade Webbing", floor(scale * 10), /obj/item/storage/belt/grenade, VENDOR_ITEM_REGULAR),
		list("M6 General Pistol Holster Rig", floor(scale * 15), /obj/item/storage/belt/gun/m6, VENDOR_ITEM_REGULAR),
		list("M276 Pattern M82F Holster Rig", floor(scale * 5), /obj/item/storage/belt/gun/flaregun, VENDOR_ITEM_REGULAR),
		list("M276 G8-A General Utility Pouch", floor(scale * 15), /obj/item/storage/backpack/general_belt, VENDOR_ITEM_REGULAR),
		list("M7 Holster Rig", floor(scale * 15), /obj/item/storage/belt/gun/m7, VENDOR_ITEM_REGULAR),

		list("POUCHES", -1, null, null, null),
		list("First-Aid Pouch", floor(scale * 15), /obj/item/storage/pouch/firstaid, VENDOR_ITEM_REGULAR),
		list("Flare Pouch (Full)", floor(scale * 15), /obj/item/storage/pouch/flare/full, VENDOR_ITEM_REGULAR),
		list("Large Magazine Pouch", floor(scale * 15), /obj/item/storage/pouch/magazine/large, VENDOR_ITEM_REGULAR),
		list("Medium General Pouch", floor(scale * 15), /obj/item/storage/pouch/general/medium, VENDOR_ITEM_REGULAR),
		list("Pistol Magazine Pouch", floor(scale * 15), /obj/item/storage/pouch/magazine/pistol/unsc, VENDOR_ITEM_REGULAR),
		list("Pistol Pouch", floor(scale * 15), /obj/item/storage/pouch/pistol/unsc, VENDOR_ITEM_REGULAR),

		list("RESTRICTED POUCHES", -1, null, null, null),
		list("Construction Pouch", 1.25, /obj/item/storage/pouch/construction, VENDOR_ITEM_REGULAR),
		list("Explosive Pouch", 1.25, /obj/item/storage/pouch/explosive, VENDOR_ITEM_REGULAR),
		list("First Responder Pouch", 2.5, /obj/item/storage/pouch/first_responder, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", floor(scale * 2), /obj/item/storage/pouch/magazine/pistol/unsc/large, VENDOR_ITEM_REGULAR),
		list("Tools Pouch", 1.25, /obj/item/storage/pouch/tools, VENDOR_ITEM_REGULAR),
		list("Sling Pouch", 1.25, /obj/item/storage/pouch/sling, VENDOR_ITEM_REGULAR),

		list("MASK", -1, null, null, null),
		list("M5 Gas Mask", floor(scale * 15), /obj/item/clothing/mask/gas/military, VENDOR_ITEM_REGULAR),
		list("Tactical Wrap", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf/tacticalmask, VENDOR_ITEM_REGULAR),
		list("Heat Absorbent Coif", floor(scale * 10), /obj/item/clothing/mask/rebreather/scarf, VENDOR_ITEM_REGULAR),
		)

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc/odst
	name = "\improper Squad Utilities Vendor"

/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/unsc/odst/populate_product_list(scale)
	listed_products = list(
		list("FOOD", -1, null, null),
		list("MRE", floor(scale * 5), /obj/item/storage/box/mre, VENDOR_ITEM_REGULAR),
		list("MRE Box", floor(scale * 1), /obj/item/ammo_box/magazine/misc/unsc/mre, VENDOR_ITEM_REGULAR),

		list("MEDICAL", -1, null, null),
		list("Gauze", round(scale * 15), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Ointment", round(scale * 15), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Splints", round(scale * 15), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),

		list("TOOLS", -1, null, null),
		list("Entrenching Tool (ET)", round(scale * 2), /obj/item/tool/shovel/etool/folded, VENDOR_ITEM_REGULAR),
		list("Screwdriver", round(scale * 5), /obj/item/tool/screwdriver, VENDOR_ITEM_REGULAR),
		list("Wirecutters", round(scale * 5), /obj/item/tool/wirecutters, VENDOR_ITEM_REGULAR),
		list("Crowbar", round(scale * 5), /obj/item/tool/crowbar, VENDOR_ITEM_REGULAR),
		list("Wrench", round(scale * 5), /obj/item/tool/wrench, VENDOR_ITEM_REGULAR),
		list("Multitool", round(scale * 1), /obj/item/device/multitool, VENDOR_ITEM_REGULAR),
		list("Welding Tool", round(scale * 1), /obj/item/tool/weldingtool, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", -1, null, null),
		list("Plastic Explosives", round(scale * 2), /obj/item/explosive/plastic, VENDOR_ITEM_REGULAR),
		list("Breaching Charge", round(scale * 2), /obj/item/explosive/plastic/breaching_charge, VENDOR_ITEM_REGULAR),

		list("FLARE AND LIGHT", -1, null, null),
		list("Combat Flashlight", round(scale * 5), /obj/item/device/flashlight/combat, VENDOR_ITEM_REGULAR),
		list("Box of Flashlight", round(scale * 1), /obj/item/ammo_box/magazine/misc/flashlight, VENDOR_ITEM_REGULAR),
		list("Box of Flares", round(scale * 1), /obj/item/ammo_box/magazine/misc/flares, VENDOR_ITEM_REGULAR),
		list("M94 Marking Flare Pack", round(scale * 10), /obj/item/storage/box/flare, VENDOR_ITEM_REGULAR),
		list("M89-S Signal Flare Pack", round(scale * 1), /obj/item/storage/box/flare/signal, VENDOR_ITEM_REGULAR),

		list("SIDEARMS", -1, null, null),
		list("M6C/SOCOM Magnum", round(scale * 4), /obj/item/weapon/gun/pistol/halo/m6c/socom/unloaded, VENDOR_ITEM_REGULAR),
		list("M7/SOCOM Submachine Gun", round(scale * 4), /obj/item/weapon/gun/smg/halo/m7/socom/folded_up, VENDOR_ITEM_REGULAR),
		list("KFA-2/G smart-linked scope", round(scale * 4), /obj/item/attachable/scope/mini/smartscope/m6g, VENDOR_ITEM_REGULAR),
		list("M6 flashlight", round(scale * 4), /obj/item/attachable/flashlight/m6, VENDOR_ITEM_REGULAR),
		list("M82F Flare Gun", round(scale * 1), /obj/item/weapon/gun/flare, VENDOR_ITEM_REGULAR),

		list("MISCELLANEOUS", -1, null, null),
		list("Extinguisher", round(scale * 5), /obj/item/tool/extinguisher, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", round(scale * 1), /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Roller Bed", round(scale * 2), /obj/item/roller, VENDOR_ITEM_REGULAR),
		list("Machete Scabbard (Full)", round(scale * 5), /obj/item/storage/large_holster/machete/full, VENDOR_ITEM_REGULAR),
		list("Tactical Monocular", round(scale * 2), /obj/item/device/binoculars/range/monocular, VENDOR_ITEM_REGULAR),
		list("M13 Fighting Knife", round(scale * 25), /obj/item/weapon/knife/marine, VENDOR_ITEM_REGULAR),
		)

//===========================//CORPSMAN\\================================\\

GLOBAL_LIST_INIT(cm_vending_clothing_medic_unsc, list(

		list("ESSENTIALS", 0, null, null, null),
		list("Essential Medical Set", 0, /obj/effect/essentials_set/medic/unsc, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),

		list("MEDICAL OPTIC (CHOOSE 1)", 0, null, null, null),
		list("Medical Helmet Optic", 0, /obj/item/device/helmet_visor/medical/advanced, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_RECOMMENDED),
		list("Medical HUD Glasses", 0, /obj/item/clothing/glasses/hud/health, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_RECOMMENDED),
		list("Mark 2 Battle Medic sight", 0, /obj/item/clothing/glasses/night/medhud/no_nvg, MARINE_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),

		list("BELT (CHOOSE 1)", 0, null, null, null),
		list("M8A Lifesaver Bag (Full)", 0, /obj/item/storage/belt/medical/lifesaver/unsc/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M8A Medical Storage Rig (Full)", 0, /obj/item/storage/belt/medical/unsc/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M8A Lifesaver Bag (Empty)", 0, /obj/item/storage/belt/medical/lifesaver/unsc, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M8A Medical Storage Rig (Empty)", 0, /obj/item/storage/belt/medical/unsc, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),

		list("POUCHES (CHOOSE 2)", 0, null, null, null),
		list("Flare Pouch (Full)", 0, /obj/item/storage/pouch/flare/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Sling Pouch", 0, /obj/item/storage/pouch/sling, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Magazine Pouch", 0, /obj/item/storage/pouch/magazine, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Shotgun Shell Pouch", 0, /obj/item/storage/pouch/shotgun, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Medical Kit Pouch", 0, /obj/item/storage/pouch/medkit/unsc, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Pistol Pouch", 0, /obj/item/storage/pouch/pistol/unsc, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

		list("ACCESSORIES (CHOOSE 1)", 0, null, null, null),
		list("M52B Pattern Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Magazine Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/mag, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Shotgun Shell Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/shotgun, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Grenade Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/m40, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("M52B Pattern Small Pouch Webbing", 0, /obj/item/clothing/accessory/storage/webbing/m3/small, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_RECOMMENDED),
		list("Shoulder Holster", 0, /obj/item/clothing/accessory/storage/holster, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/clothing/medic/unsc
	name = "\improper UNSC Squad Medical Equipment Rack"

/obj/structure/machinery/cm_vending/clothing/medic/unsc/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_medic_unsc

//===========================//PRESETS\\================================\\

/obj/effect/essentials_set/medic/unsc
	spawned_gear_list = list(
		/obj/item/storage/firstaid/unsc/corpsman,
		/obj/item/storage/firstaid/unsc/corpsman,
		/obj/item/device/healthanalyzer/halo,
		/obj/item/tool/surgery/surgical_line,
		/obj/item/tool/surgery/synthgraft,
		/obj/item/storage/surgical_case/regular,
		/obj/item/device/flashlight/pen,
		/obj/item/clothing/accessory/stethoscope,
		/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/antidote,
	)

/obj/item/storage/box/guncase/m52barmor //forgive me, father
	name = "\improper M52B Body Armor case"
	desc = "A case containing the standard issue parts of the M52B body armor set of the UNSC. No parts sold separately."
	can_hold = list(/obj/item/clothing/suit/marine/unsc, /obj/item/clothing/accessory/pads/unsc, /obj/item/clothing/accessory/pads/unsc/greaves)
	storage_slots = 3

/obj/item/storage/box/guncase/m52barmor/fill_preset_inventory()
	new /obj/item/clothing/suit/marine/unsc(src)
	new /obj/item/clothing/accessory/pads/unsc(src)
	new /obj/item/clothing/accessory/pads/unsc/greaves(src)

/obj/item/storage/box/guncase/odstarmor //forgive me, father, SECOND edition
	name = "\improper M70DT ODST BDU case"
	desc = "A case containing the standard issue parts of the M70DT ODST BDU set of the UNSC. No parts sold separately."
	can_hold = list(/obj/item/clothing/suit/marine/unsc/odst, /obj/item/clothing/accessory/pads/unsc/odst, /obj/item/clothing/accessory/pads/unsc/greaves/odst, /obj/item/clothing/accessory/pads/unsc/groin/odst, /obj/item/clothing/accessory/pads/unsc/bracers/odst)
	storage_slots = 5

/obj/item/storage/box/guncase/odstarmor/fill_preset_inventory()
	new /obj/item/clothing/suit/marine/unsc/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/greaves/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/groin/odst(src)
	new /obj/item/clothing/accessory/pads/unsc/bracers/odst(src)
