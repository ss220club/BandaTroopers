/obj/structure/gun_rack/flammenwerfer3/deathsquad
	name = "Flammenwerfer 3 rack"
	desc = "A two-slot rack for Flammenwerfer 3 heavy incineration units."
	icon = 'modular/weapons/icons/wy/flammenwerfer3_rack.dmi'
	icon_state = "fl3rack"
	max_stored = 2
	initial_stored = 2
	allowed_type = /obj/item/weapon/gun/flamer/flammenwerfer3/deathsquad
	populate_type = /obj/item/weapon/gun/flamer/flammenwerfer3/deathsquad

/obj/structure/gun_rack/flammenwerfer3/deathsquad/empty
	initial_stored = 0

/obj/item/storage/box/guncase/heavy/es7
	name = "\improper ES-7 Supernova heavy gun case"
	desc = "A heavy case containing one ES-7 Supernova and five boxes of X21 lethal slugs."
	icon = 'modular/weapons/icons/wy/es7_heavy_case.dmi'
	icon_state = "es7case"
	storage_slots = 6
	can_hold = list(/obj/item/weapon/gun/shotgun/es7, /obj/item/ammo_magazine/shotgun/beanbag/es7/slug)

/obj/item/storage/box/guncase/heavy/es7/fill_preset_inventory()
	new /obj/item/weapon/gun/shotgun/es7(src)
	for(var/i = 1 to 5)
		new /obj/item/ammo_magazine/shotgun/beanbag/es7/slug(src)

/obj/item/storage/box/guncase/heavy/es7/update_icon()
	overlays.Cut()
	if(!opened)
		overlays += image(icon, "es7case_lid")
		return

	overlays += image(icon, "es7case_lid_open")
	if(locate(/obj/item/weapon/gun/shotgun/es7) in contents)
		overlays += image(icon, "+es7gun")
	var/slug_boxes = 0
	for(var/obj/item/ammo_magazine/shotgun/beanbag/es7/slug/box in contents)
		slug_boxes++
	if(slug_boxes)
		overlays += image(icon, "+es7slug_[min(slug_boxes, 5)]")

/obj/item/storage/box/guncase/heavy/fuel/pmc/flammenwerfer3
	name = "\improper Flammenwerfer 3 EX fuel case"
	desc = "A heavy case containing six EX fuel tanks for the Flammenwerfer 3 heavy incinerator."
	can_hold = list(/obj/item/ammo_magazine/flamer_tank/flammenwerfer)

/obj/item/storage/box/guncase/heavy/fuel/pmc/flammenwerfer3/fill_preset_inventory()
	for(var/i = 1 to 6)
		new /obj/item/ammo_magazine/flamer_tank/flammenwerfer/whiteout(src)
