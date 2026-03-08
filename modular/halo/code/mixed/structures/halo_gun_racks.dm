/obj/structure/gun_rack/halo
	name = "halo gun rack holder"
	desc = "A UNSC weapon rack."
	icon = 'icons/halo/obj/structures/gun_racks.dmi'
	icon_state = "template"

/obj/structure/gun_rack/halo/medkit
	name = "medkit station"
	desc = "A wall-mounted medkit station."
	icon_state = "medkit"
	max_stored = 1
	initial_stored = 1
	density = FALSE
	allowed_type = /obj/item/storage/firstaid/unsc
	populate_type = /obj/item/storage/firstaid/unsc

/obj/structure/gun_rack/halo/armory/Initialize()
	. = ..()
	if(prob(50))
		var/image/picked_image
		picked_image = pick("+decorator_1", "+decorator_2", "+decorator_3")
		overlays += picked_image

/obj/structure/gun_rack/halo/armory/ma5c
	name = "MA5C weapon rack"
	icon_state = "ma5c"
	max_stored = 6
	initial_stored = 6
	allowed_type = /obj/item/weapon/gun/rifle/halo/ma5c
	populate_type = /obj/item/weapon/gun/rifle/halo/ma5c

/obj/structure/gun_rack/halo/armory/ma5c/unloaded
	populate_type = /obj/item/weapon/gun/rifle/halo/ma5c/unloaded

/obj/structure/gun_rack/halo/armory/ma5c/empty
	initial_stored = 0

/obj/structure/gun_rack/halo/big
	name = "weapon rack"
	icon = 'icons/halo/obj/structures/gun_racks_32x48.dmi'
	max_stored = 5
	initial_stored = 5

/obj/structure/gun_rack/halo/big/ma5c
	name = "MA5C weapon rack"
	icon_state = "ma5c"
	allowed_type = /obj/item/weapon/gun/rifle/halo/ma5c
	populate_type = /obj/item/weapon/gun/rifle/halo/ma5c

/obj/structure/gun_rack/halo/big/ma5c/unloaded
	populate_type = /obj/item/weapon/gun/rifle/halo/ma5c/unloaded

/obj/structure/gun_rack/halo/big/ma5c/empty
	initial_stored = 0

/obj/structure/gun_rack/halo/big/br55
	name = "BR55 weapon rack"
	icon_state = "br55"
	allowed_type = /obj/item/weapon/gun/rifle/halo/br55
	populate_type = /obj/item/weapon/gun/rifle/halo/br55

/obj/structure/gun_rack/halo/big/br55/unloaded
	populate_type = /obj/item/weapon/gun/rifle/halo/br55/unloaded

/obj/structure/gun_rack/halo/big/br55/empty
	initial_stored = 0
