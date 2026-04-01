/obj/item/weapon/gun/rifle/mar40/marksman
	desc = "A cheap, reliable assault rifle chambered in 8.8x29mm. Commonly found in the hands of criminals or mercenaries, or in the hands of the UPP or CLF."
	starting_attachment_types = list(/obj/item/attachable/scope/slavic, /obj/item/attachable/extended_barrel)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AUTO_EJECT_CASINGS

/obj/item/weapon/gun/rifle/type71/stripped
	starting_attachment_types = list(/obj/item/attachable/stock/type71)

/obj/item/weapon/gun/rifle/lw317/specops
	current_mag = /obj/item/ammo_magazine/rifle/lw317/ap
	starting_attachment_types = list(/obj/item/attachable/suppressor, /obj/item/attachable/reflex/upp, /obj/item/attachable/verticalgrip/upp)

/obj/item/weapon/gun/rifle/lw317/dmr/specops
	starting_attachment_types = list(/obj/item/attachable/verticalgrip/upp)

/obj/item/weapon/gun/rifle/lw317/dmr/specops/handle_starting_attachment()
	..()
	var/obj/item/attachable/barrel = new /obj/item/attachable/suppressor(src)
	barrel.flags_attach_features &= ~ATTACH_REMOVABLE
	barrel.Attach(src)
	update_attachable(barrel.slot)

	var/obj/item/attachable/scope/variable_zoom/canc/scope = new(src)
	scope.flags_attach_features &= ~ATTACH_REMOVABLE
	scope.Attach(src)
	update_attachable(scope.slot)
