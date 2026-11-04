
/obj/structure/machinery/cm_vending/sorted/cargo_guns/squad/upp/forecon/populate_product_list(scale)
	listed_products = list(
		list("FOOD", -1, null, null),
		list("Individual Meal Ration", round(scale * 15), /obj/item/storage/box/mre/upp, VENDOR_ITEM_REGULAR),
		list("IMR Box", floor(scale * 1), /obj/item/ammo_box/magazine/misc/mre/upp, VENDOR_ITEM_REGULAR),

		list("MEDICAL", -1, null, null),
		list("Gauze", round(scale * 15), /obj/item/stack/medical/bruise_pack, VENDOR_ITEM_REGULAR),
		list("Ointment", round(scale * 15), /obj/item/stack/medical/ointment, VENDOR_ITEM_REGULAR),
		list("Splints", round(scale * 15), /obj/item/stack/medical/splint, VENDOR_ITEM_REGULAR),
		list("Emergency Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/emergency, VENDOR_ITEM_REGULAR),
		list("Bicaridine Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/bicaridine/skillless, VENDOR_ITEM_REGULAR),
		list("Kelotane Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/kelotane/skillless, VENDOR_ITEM_REGULAR),
		list("Tricordrazine Autoinjector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/tricord/skillless, VENDOR_ITEM_REGULAR),
		list("Tramadol Injector", round(scale * 15), /obj/item/reagent_container/hypospray/autoinjector/tramadol/skillless, VENDOR_ITEM_REGULAR),

		list("TOOLS", -1, null, null),
		list("Type 50 Entrenching Tool", round(scale * 2), /obj/item/tool/shovel/etool/upp/folded, VENDOR_ITEM_REGULAR),
		list("Screwdriver", round(scale * 5), /obj/item/tool/screwdriver/tactical, VENDOR_ITEM_REGULAR),
		list("Wirecutters", round(scale * 5), /obj/item/tool/wirecutters/tactical, VENDOR_ITEM_REGULAR),
		list("Crowbar", round(scale * 5), /obj/item/tool/crowbar/tactical, VENDOR_ITEM_REGULAR),
		list("Wrench", round(scale * 5), /obj/item/tool/wrench, VENDOR_ITEM_REGULAR),
		list("Multitool", round(scale * 1), /obj/item/device/multitool/upp, VENDOR_ITEM_REGULAR),
		list("Welding Tool", round(scale * 1), /obj/item/tool/weldingtool, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", -1, null, null),
		list("Plastic Explosives", round(scale * 2), /obj/item/explosive/plastic, VENDOR_ITEM_REGULAR),
		list("Breaching Charge", round(scale * 2), /obj/item/explosive/plastic/breaching_charge, VENDOR_ITEM_REGULAR),

		list("FLARE AND LIGHT", -1, null, null),
		list("Box of R52 Flare Packs", round(scale * 1), /obj/item/ammo_box/magazine/misc/flares/upp, VENDOR_ITEM_REGULAR),
		list("R52 Marking Flare Pack", round(scale * 10), /obj/item/storage/box/flare/upp, VENDOR_ITEM_REGULAR),

		list("SIDEARMS", -1, null, null),
		list("NPZ92 Suppressed Pistol", round(scale * 2), /obj/item/weapon/gun/pistol/np92/suppressed/unloaded, VENDOR_ITEM_REGULAR),
		list("Type 73 Service Pistol", round(scale * 2), /obj/item/weapon/gun/pistol/t73/unloaded, VENDOR_ITEM_REGULAR),
		list("ZHNK-72 Revolver", round(scale * 1), /obj/item/weapon/gun/revolver/upp, VENDOR_ITEM_REGULAR),
		list("M82F Flare Gun", round(scale * 3), /obj/item/weapon/gun/flare, VENDOR_ITEM_REGULAR),

		list("MISCELLANEOUS", -1, null, null),
		list("Extinguisher", round(scale * 5), /obj/item/tool/extinguisher, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", round(scale * 1), /obj/item/tool/extinguisher/mini, VENDOR_ITEM_REGULAR),
		list("Roller Bed", round(scale * 2), /obj/item/roller, VENDOR_ITEM_REGULAR),
		list("Machete Scabbard (Full)", round(scale * 5), /obj/item/storage/large_holster/machete/arnold/weak, VENDOR_ITEM_REGULAR),
		list("Binoculars", round(scale * 2), /obj/item/device/binoculars/civ, VENDOR_ITEM_REGULAR),
		list("Spare PDT/L Battle Buddy Kit", round(scale * 3), /obj/item/storage/box/pdt_kit/advanced, VENDOR_ITEM_REGULAR),
		list("Rail Flashlight", round(scale * 5), /obj/item/attachable/flashlight, VENDOR_ITEM_REGULAR),
		list("Two-point Sling", round(scale * 5), /obj/item/attachable/sling, VENDOR_ITEM_REGULAR),
		list("Type 80 Bayonet", round(scale * 5), /obj/item/attachable/bayonet/upp, null, VENDOR_ITEM_REGULAR),
		)
