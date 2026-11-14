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

/obj/item/storage/box/guncase/heavy/fuel/pmc/flammenwerfer3
	name = "\improper Flammenwerfer 3 EX fuel case"
	desc = "A heavy case containing six EX fuel tanks for the Flammenwerfer 3 heavy incinerator."
	can_hold = list(/obj/item/ammo_magazine/flamer_tank/flammenwerfer)

/obj/item/storage/box/guncase/heavy/fuel/pmc/flammenwerfer3/fill_preset_inventory()
	for(var/i = 1 to 6)
		new /obj/item/ammo_magazine/flamer_tank/flammenwerfer/whiteout(src)
