/obj/structure/magazine_box/unsc
	icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	icon_state = "base"
	text_markings_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/text.dmi'
	magazines_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/magazines.dmi'

/obj/item/ammo_box/magazine/misc/unsc
	name = "\improper UNSC storage crate"
	desc = "A generic storage crate for the UNSC. Looks like it holds...nothing? You shouldn't be seeing this..."
	icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	magazines_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/magazines.dmi'
	deployed_object = /obj/structure/magazine_box/unsc
	icon_state = "base"
	magazine_type = null
	limit_per_tile = 1
	num_of_magazines = 0
	overlay_content = null

/obj/item/ammo_box/magazine/misc/unsc/mre
	name = "\improper UNSC storage crate - (MRE x 14)"
	desc = "A generic storage crate for the UNSC holding MREs."
	icon_state = "base_mre"
	magazine_type = /obj/item/storage/box/mre
	num_of_magazines = 14
	overlay_content = "_mre"

/obj/item/ammo_box/magazine/misc/unsc/mre/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/flare
	name = "\improper UNSC storage crate  (Flares x 14)"
	desc = "A generic storage crate for the UNSC holding flares."
	icon_state = "base_flare"
	magazine_type = /obj/item/storage/box/flare
	num_of_magazines = 14
	overlay_content = "_flare"

/obj/item/ammo_box/magazine/misc/unsc/flare/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/flare/signal
	name = "\improper UNSC storage crate - (Signal Flares x 14)"
	desc = "A generic storage crate for the UNSC holding signal flares."
	icon_state = "base_flare"
	magazine_type = /obj/item/storage/box/flare/signal
	num_of_magazines = 14
	overlay_content = "_signal"

/obj/item/ammo_box/magazine/misc/unsc/flare/signal/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/grenade
	name = "\improper UNSC storage crate - (Grenades x 9)"
	desc = "A generic storage crate for the UNSC holding fragmentation grenades."
	icon_state = "base_frag"
	magazine_type = /obj/item/explosive/grenade/high_explosive/m15/unsc
	num_of_magazines = 9
	overlay_content = "_frag"

/obj/item/ammo_box/magazine/misc/unsc/grenade/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable
	name = "\improper UNSC storage crate - (40mm Grenades x 30)"
	desc = "A generic storage crate for the UNSC holding 40MM grenades."
	icon_state = "base_40mm"
	magazine_type = /obj/item/explosive/grenade/high_explosive/m15/unsc/launchable
	num_of_magazines = 30
	overlay_content = "_40mm"

/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/medical_packets
	name = "\improper UNSC storage crate - (First Aid Packets x 10)"
	desc = "A generic storage crate for the UNSC holding MREs."
	icon_state = "base_medpack"
	magazine_type = /obj/item/storage/box/tear_packet/medical_packet
	num_of_magazines = 10
	overlay_content = "_medpack"

/obj/item/ammo_box/magazine/misc/unsc/medical_packets/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/m7_ammo
	name = "UNSC storage crate - (M7 Magazine Packets x 16)"
	desc = "A generic UNSC storage crate for holding M7 magazine packets."
	magazine_type = /obj/item/storage/box/tear_packet/m7
	num_of_magazines = 16
	overlay_content = "_riflepack"

/obj/item/ammo_box/magazine/misc/unsc/m7_ammo/empty
	empty = TRUE

/obj/item/ammo_box/magazine/unsc
	name = "UNSC magazine box"
	desc = "A generic ammo box for UNSC weapons."
	icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	icon_state = "base_ammo"
	magazines_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/magazines.dmi'
	text_markings_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/text.dmi'
	limit_per_tile = 1
	deployed_object = /obj/structure/magazine_box/unsc

/obj/item/ammo_box/magazine/unsc/ma5c
	name = "UNSC magazine box (MA5C x 48)"
	desc = "An ammo box storing 48 magazines of MA5C ammunition"
	icon_state = "base_ammo"
	overlay_gun_type = "_ma5c"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/ma5c
	num_of_magazines = 48

/obj/item/ammo_box/magazine/unsc/ma5c/shredder
	name = "UNSC magazine box (MA5C x 48, shredder)"
	desc = "An ammo box storing 48 magazines of MA5C ammunition"
	overlay_ammo_type = "_shred"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/ma5c/shredder

/obj/item/ammo_box/magazine/unsc/br55
	name = "UNSC magazine box (BR55 x 32)"
	desc = "An ammo box storing 32 magazines of BR55 ammunition"
	icon_state = "base_ammo"
	overlay_gun_type = "_br55"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/br55
	num_of_magazines = 32

/obj/item/ammo_box/magazine/unsc/br55/extended
	name = "UNSC magazine box (BR55 x 32, extended)"
	desc = "An ammo box storing 32 magazines of BR55 ammunition"
	overlay_ammo_type = "_ext"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/br55/extended

/obj/item/ammo_box/magazine/unsc/small
	name = "UNSC magazine box"
	icon_state = "base_ammosmall"
	limit_per_tile = 2
	overlay_gun_type = null
	overlay_content = "_small"

/obj/item/ammo_box/magazine/unsc/small/m6c
	name = "UNSC magazine box (M6C x 22)"
	desc = "An ammo box storing 22 magazines of M6C ammunition."
	icon_state = "base_ammosmall"
	magazine_type = /obj/item/ammo_magazine/pistol/halo/m6c
	num_of_magazines = 22

/obj/item/ammo_box/magazine/unsc/small/m6c/socom
	name = "UNSC magazine box (M6C/SOCOM x 22)"
	desc = "An ammo box storing 22 magazines of M6C/SOCOM ammunition."
	overlay_ammo_type = "_extsmall"
	magazine_type = /obj/item/ammo_magazine/pistol/halo/m6c/socom

/obj/item/ammo_box/magazine/unsc/small/m6g
	name = "UNSC magazine box (M6G x 22)"
	desc = "An ammo box storing 22 magazines of M6G ammunition."
	icon_state = "base_ammosmall2"
	magazine_type = /obj/item/ammo_magazine/pistol/halo/m6g
	num_of_magazines = 22
