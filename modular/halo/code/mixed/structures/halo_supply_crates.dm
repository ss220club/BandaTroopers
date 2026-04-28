/obj/structure/largecrate/supply/ammo/halo
	name = "UNSC ammunition case"
	desc = "A UNSC ammunition case containing combat resupply."
	icon_state = "secure_crate_strapped"

/obj/structure/largecrate/supply/ammo/halo/rifle
	name = "UNSC rifle ammunition case"
	desc = "A UNSC ammunition case containing the main rifle reserve for line troops."
	supplies = list(
		/obj/item/ammo_box/magazine/unsc/ma5c = 1,
		/obj/item/ammo_box/magazine/unsc/ma5b = 1,
		/obj/item/ammo_box/magazine/unsc/br55 = 1,
	)

/obj/structure/largecrate/supply/ammo/halo/marksman
	name = "UNSC designated rifle ammunition case"
	desc = "A UNSC ammunition case containing BR55 and M392 DMR ammunition for squad leaders and marksmen."
	supplies = list(
		/obj/item/ammo_box/magazine/unsc/br55 = 2,
		/obj/item/ammo_box/magazine/unsc/dmr = 2,
	)

/obj/structure/largecrate/supply/ammo/halo/pdw
	name = "UNSC secondary weapon ammunition case"
	desc = "A UNSC ammunition case containing M7 magazines and sidearm ammunition for secondary weapons."
	supplies = list(
		/obj/item/ammo_box/magazine/misc/unsc/m7_ammo = 1,
		/obj/item/ammo_box/magazine/unsc/small/m6c = 1,
		/obj/item/ammo_magazine/pistol/halo/m6d = 3,
		/obj/item/ammo_box/magazine/unsc/small/m6g = 1,
	)

/obj/structure/largecrate/supply/ammo/halo/shotgun
	name = "UNSC shotgun ammunition case"
	desc = "A compact UNSC shotgun case intended for one breacher."
	supplies = list(/obj/item/ammo_magazine/shotgun/buckshot/unsc = 4)

/obj/structure/largecrate/supply/ammo/halo/sniper
	name = "UNSC sniper ammunition case"
	desc = "A UNSC ammunition case containing SRS99 magazines."
	supplies = list(/obj/item/ammo_magazine/rifle/halo/sniper = 5)

/obj/structure/largecrate/supply/ammo/halo/spnkr
	name = "UNSC SPNKr ammunition case"
	desc = "A UNSC ammunition case containing SPNKr rocket tubes."
	supplies = list(/obj/item/ammo_magazine/spnkr = 2)

/obj/structure/largecrate/supply/ammo/halo/grenadier
	name = "UNSC grenadier ammunition case"
	desc = "A UNSC ammunition case containing 40mm grenades and fragmentation grenades."
	supplies = list(
		/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable = 1,
		/obj/item/ammo_box/magazine/misc/unsc/grenade = 1,
	)

/obj/structure/largecrate/supply/ammo/halo/emergency_weapon
	name = "UNSC emergency weapon case"
	desc = "A UNSC emergency weapon case containing M6G handgun and some spare ammo"
	supplies = list(
		/obj/item/storage/belt/gun/m6/full_m6g = 1,
	)

/obj/structure/largecrate/supply/medicine/halo
	name = "UNSC medical case"
	desc = "A UNSC medical case containing field treatment supplies."
	icon_state = "secure_crate_strapped"

/obj/structure/largecrate/supply/medicine/halo/medical_packets
	name = "UNSC medical packets case"
	desc = "A UNSC medical case containing trauma packets."
	supplies = list(
		/obj/item/ammo_box/magazine/misc/unsc/medical_packets = 2,
	)

/obj/structure/largecrate/supply/medicine/halo/corpsman_kit
	name = "UNSC corpsman kit case"
	desc = "A UNSC medical case containing a corpsman sustain kit."
	supplies = list(
		/obj/item/storage/firstaid/unsc/corpsman = 2,
		/obj/item/storage/belt/medical/lifesaver/unsc/full = 1,
		/obj/item/storage/pouch/medkit/unsc/full = 1,
	)

/obj/structure/largecrate/supply/medicine/halo/biofoam_reserve
	name = "UNSC biofoam reserve case"
	desc = "A UNSC medical case containing biofoam injectors and burn treatment reserves."
	supplies = list(
		/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam = 4,
		/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/antidote = 2,
		/obj/item/storage/syringe_case/unsc/burnguard = 2,
	)

/obj/structure/largecrate/supply/supplies/halo
	name = "UNSC support case"
	desc = "A UNSC support case containing field supplies."
	icon_state = "secure_crate_strapped"

/obj/structure/largecrate/supply/supplies/halo/toolbox
	name = "UNSC toolbox support case"
	desc = "A UNSC support case containing engineering tools and repair load-bearing gear."
	supplies = list(
		/obj/item/storage/toolbox/traxus/big = 2,
		/obj/item/storage/pouch/electronics/full = 1,
		/obj/item/clothing/glasses/welding = 2,
		/obj/item/storage/backpack/marine/engineerpack/welder_chestrig = 1,
	)

/obj/structure/largecrate/supply/supplies/halo/fortification
	name = "UNSC fortification case"
	desc = "A UNSC support case containing field fortification materials and defensive mines."
	supplies = list(
		/obj/item/stack/sandbags_empty/full = 1,
		/obj/item/stack/sheet/plasteel/large_stack = 1,
		/obj/item/stack/sheet/metal/large_stack = 2,
		/obj/item/stack/folding_barricade/three = 2,
		/obj/item/storage/box/explosive_mines = 1,
	)

/obj/structure/largecrate/supply/supplies/halo/vehicle_service
	name = "UNSC vehicle service case"
	desc = "A UNSC support case containing field repair and power supplies for vehicles."
	supplies = list(
		/obj/item/storage/toolbox/traxus/big = 1,
		/obj/item/tool/weldingtool = 2,
		/obj/item/tool/weldpack/minitank = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/stack/sheet/metal/large_stack = 1,
		/obj/item/stack/sheet/plasteel/med_large_stack = 1,
		/obj/item/cell/high = 1,
	)

/obj/structure/largecrate/supply/supplies/halo/signal
	name = "UNSC signal case"
	desc = "A UNSC support case containing flare and signaling gear."
	supplies = list(
		/obj/item/ammo_box/magazine/misc/flares = 1,
		/obj/item/storage/box/flare/signal = 1,
		/obj/item/storage/pouch/flare/full = 1,
		/obj/item/weapon/gun/flare = 1,
	)

/obj/structure/largecrate/supply/supplies/halo/recon
	name = "UNSC recon case"
	desc = "A UNSC support case containing reconnaissance and navigation gear."
	supplies = list(
		/obj/item/device/binoculars/range/monocular = 2,
		/obj/item/device/motiondetector = 1,
		/obj/item/map/current_map = 1,
		/obj/item/device/flashlight/combat = 1,
	)

/obj/structure/largecrate/supply/supplies/halo/rto_command
	name = "UNSC RTO command case"
	desc = "A UNSC support case containing communications and JTAC coordination gear."
	supplies = list(
		/obj/item/storage/backpack/marine/satchel/rto/unsc = 1,
		/obj/item/device/binoculars/range/designator = 1,
		/obj/item/storage/pouch/radio = 1,
		/obj/item/device/radio = 2,
		/obj/item/device/encryptionkey/jtac = 1,
		/obj/item/storage/box/flare/signal = 1,
	)

/obj/structure/largecrate/supply/explosives/halo
	name = "UNSC explosives case"
	desc = "A UNSC explosives case containing breaching equipment."
	icon_state = "secure_crate_strapped"

/obj/structure/largecrate/supply/explosives/halo/breaching
	name = "UNSC breaching case"
	desc = "A UNSC explosives case containing plastic explosives and entry tools."
	supplies = list(
		/obj/item/explosive/plastic = 4,
		/obj/item/explosive/plastic/breaching_charge = 2,
		/obj/item/tool/shovel/etool/folded = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/clothing/glasses/welding = 1,
	)
