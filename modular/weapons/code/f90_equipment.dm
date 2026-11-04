/obj/item/ammo_magazine/rifle/rmc_f90/ap
	name = "\improper F903 AP magazine (5.5x50mm)"
	desc = "A 5.5x50mm armor-piercing magazine for the F903 rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/ap
	ammo_band_color = AMMO_BAND_COLOR_AP

/obj/item/ammo_magazine/rifle/rmc_f90/marksman/ap
	name = "\improper F903A1 Marksman AP magazine (5.5x50mm)"

/obj/structure/gun_rack/f90
	name = "F903A1 rifle rack"
	desc = "A rack configured to hold six F903A1 rifles."
	icon = 'modular/weapons/icons/f90/gun_racks.dmi'
	icon_state = "f90"
	max_stored = 6
	initial_stored = 6
	allowed_type = /obj/item/weapon/gun/rifle/rmc_f90
	populate_type = /obj/item/weapon/gun/rifle/rmc_f90

/obj/structure/gun_rack/f90/empty
	initial_stored = 0

/obj/structure/gun_rack/f90/a_grip
	name = "F903A2 rifle rack"
	desc = "A rack configured to hold six F903A2 rifles."
	icon_state = "f90_a2"
	allowed_type = /obj/item/weapon/gun/rifle/rmc_f90/a_grip
	populate_type = /obj/item/weapon/gun/rifle/rmc_f90/a_grip

/obj/structure/gun_rack/f90/a_grip/empty
	initial_stored = 0

/obj/structure/gun_rack/f90/marksman
	name = "F903A1 marksman rifle rack"
	desc = "A rack configured to hold six F903A1 marksman rifles."
	icon_state = "f90_marksman"
	allowed_type = /obj/item/weapon/gun/rifle/rmc_f90/scope
	populate_type = /obj/item/weapon/gun/rifle/rmc_f90/scope

/obj/structure/gun_rack/f90/marksman/empty
	initial_stored = 0

/obj/structure/gun_rack/f90/breacher
	name = "F903A1/B breacher rifle rack"
	desc = "A rack configured to hold six F903A1/B breacher rifles."
	icon_state = "f90_breacher"
	allowed_type = /obj/item/weapon/gun/rifle/rmc_f90/shotgun
	populate_type = /obj/item/weapon/gun/rifle/rmc_f90/shotgun

/obj/structure/gun_rack/f90/breacher/empty
	initial_stored = 0

/obj/structure/magazine_box/f90
	text_markings_icon = 'modular/weapons/icons/f90/box_text.dmi'

/obj/item/ammo_box/magazine/f90
	name = "magazine box (F903 x 10)"
	icon_state = "base_nsg23"
	flags_equip_slot = SLOT_BACK
	overlay_gun_type = "_f90"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90
	text_markings_icon = 'modular/weapons/icons/f90/box_text.dmi'
	deployed_object = /obj/structure/magazine_box/f90

/obj/item/ammo_box/magazine/f90/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/ap
	name = "magazine box (F903 AP x 10)"
	overlay_ammo_type = "_ap"
	overlay_content = "_ap"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/ap

/obj/item/ammo_box/magazine/f90/ap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/heap
	name = "magazine box (F903 HEAP x 10)"
	overlay_ammo_type = "_heap"
	overlay_content = "_heap"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/heap

/obj/item/ammo_box/magazine/f90/heap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/marksman
	name = "magazine box (F903A1 Marksman AP x 10)"
	overlay_gun_type = "_f90_m"
	overlay_ammo_type = "_ap"
	overlay_content = "_ap"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/ap

/obj/item/ammo_box/magazine/f90/marksman/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/marksman/heap
	name = "magazine box (F903A1 Marksman HEAP x 10)"
	overlay_ammo_type = "_heap"
	overlay_content = "_heap"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/heap

/obj/item/ammo_box/magazine/f90/marksman/heap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/large
	name = "magazine box (F903 x 32)"
	icon_state = "base_rmclarge"
	overlay_ammo_type = "_reglarge"
	overlay_content = "_reglarge"
	flags_equip_slot = null
	limit_per_tile = 1
	num_of_magazines = 32
	var/move_delay_mult = 2

/obj/item/ammo_box/magazine/f90/large/pickup(mob/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY, PROC_REF(handle_movedelay))

/obj/item/ammo_box/magazine/f90/large/proc/handle_movedelay(mob/user, list/movedata)
	SIGNAL_HANDLER
	if(locate(/obj/item/ammo_box/magazine/f90/large) in user.contents)
		movedata["move_delay"] += move_delay_mult

/obj/item/ammo_box/magazine/f90/large/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY)

/obj/item/ammo_box/magazine/f90/large/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/large/ap
	name = "magazine box (F903 AP x 32)"
	overlay_ammo_type = "_aplarge"
	overlay_content = "_aplarge"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/ap

/obj/item/ammo_box/magazine/f90/large/ap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/large/heap
	name = "magazine box (F903 HEAP x 32)"
	overlay_ammo_type = "_heaplarge"
	overlay_content = "_heaplarge"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/heap

/obj/item/ammo_box/magazine/f90/large/heap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/large/marksman
	name = "magazine box (F903A1 Marksman AP x 32)"
	overlay_gun_type = "_f90_m"
	overlay_ammo_type = "_aplarge"
	overlay_content = "_aplarge"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/ap

/obj/item/ammo_box/magazine/f90/large/marksman/empty
	empty = TRUE

/obj/item/ammo_box/magazine/f90/large/marksman/heap
	name = "magazine box (F903A1 Marksman HEAP x 32)"
	overlay_ammo_type = "_heaplarge"
	overlay_content = "_heaplarge"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/heap

/obj/item/ammo_box/magazine/f90/large/marksman/heap/empty
	empty = TRUE
