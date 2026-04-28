/obj/structure/magazine_box/unsc
	icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	icon_state = "base"
	text_markings_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/text.dmi'
	magazines_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/magazines.dmi'

/obj/item/ammo_box/magazine/misc/unsc
	name = "\improper UNSC storage crate"
	desc = "Типовой ящик снабжения ККОН. Похоже, сейчас он пуст... и вы вообще не должны были этого видеть."
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
	desc = "Типовой ящик снабжения ККОН с индивидуальными рационами."
	icon_state = "base_mre"
	magazine_type = /obj/item/storage/box/mre
	num_of_magazines = 14
	overlay_content = "_mre"

/obj/item/ammo_box/magazine/misc/unsc/mre/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/flare
	name = "\improper UNSC storage crate  (Flares x 14)"
	desc = "Типовой ящик снабжения ККОН с фальшфейерами."
	icon_state = "base_flare"
	magazine_type = /obj/item/storage/box/flare
	num_of_magazines = 14
	overlay_content = "_flare"

/obj/item/ammo_box/magazine/misc/unsc/flare/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/flare/signal
	name = "\improper UNSC storage crate - (Signal Flares x 14)"
	desc = "Типовой ящик снабжения ККОН с сигнальными фальшфейерами."
	icon_state = "base_flare"
	magazine_type = /obj/item/storage/box/flare/signal
	num_of_magazines = 14
	overlay_content = "_signal"

/obj/item/ammo_box/magazine/misc/unsc/flare/signal/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/grenade
	name = "\improper UNSC storage crate - (Grenades x 9)"
	desc = "Типовой ящик снабжения ККОН с осколочными гранатами."
	icon_state = "base_frag"
	magazine_type = /obj/item/explosive/grenade/high_explosive/m15/unsc
	num_of_magazines = 9
	overlay_content = "_frag"

/obj/item/ammo_box/magazine/misc/unsc/grenade/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable
	name = "\improper UNSC storage crate - (40mm Grenades x 30)"
	desc = "Типовой ящик снабжения ККОН с 40-мм гранатами."
	icon_state = "base_40mm"
	magazine_type = /obj/item/explosive/grenade/high_explosive/m15/unsc/launchable
	num_of_magazines = 30
	overlay_content = "_40mm"

/obj/item/ammo_box/magazine/misc/unsc/grenade/launchable/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/medical_packets
	name = "\improper UNSC storage crate - (First Aid Packets x 10)"
	desc = "Типовой ящик снабжения ККОН с полевыми медицинскими пакетами."
	icon_state = "base_medpack"
	magazine_type = /obj/item/storage/box/tear_packet/medical_packet
	num_of_magazines = 10
	overlay_content = "_medpack"

/obj/item/ammo_box/magazine/misc/unsc/medical_packets/empty
	empty = TRUE

/obj/item/ammo_box/magazine/misc/unsc/m7_ammo
	name = "UNSC storage crate - (M7 Magazine Packets x 16)"
	desc = "Типовой ящик снабжения ККОН для пакетов с магазинами M7."
	magazine_type = /obj/item/storage/box/tear_packet/m7
	num_of_magazines = 16
	overlay_content = "_riflepack"

/obj/item/ammo_box/magazine/misc/unsc/m7_ammo/empty
	empty = TRUE

/obj/item/ammo_box/magazine/unsc
	name = "UNSC magazine box"
	desc = "Типовой ящик с боеприпасами для оружия ККОН."
	icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/boxes_and_lids.dmi'
	icon_state = "base_ammo"
	magazines_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/magazines.dmi'
	text_markings_icon = 'icons/halo/obj/items/weapons/guns/ammo_boxes/text.dmi'
	limit_per_tile = 1
	deployed_object = /obj/structure/magazine_box/unsc

/obj/item/ammo_box/magazine/unsc/ma5c
	name = "UNSC magazine box (MA5C x 48)"
	desc = "Ящик с 48 магазинами для MA5C."
	icon_state = "base_ammo"
	overlay_gun_type = "_ma5c"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/ma5c
	num_of_magazines = 48

/obj/item/ammo_box/magazine/unsc/ma5b
	name = "UNSC magazine box (MA5B x 48)"
	desc = "Ящик с 48 магазинами для MA5B."
	icon_state = "base_ammo3"
	overlay_gun_type = "_ma5b"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/ma5b
	num_of_magazines = 48

/obj/item/ammo_box/magazine/unsc/ma5c/shredder
	name = "UNSC magazine box (MA5C x 48, shredder)"
	desc = "Ящик с 48 магазинами Shredder для MA5C."
	overlay_ammo_type = "_shred"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/ma5c/shredder

/obj/item/ammo_box/magazine/unsc/ma5b/shredder
	name = "UNSC magazine box (MA5B x 48, shredder)"
	desc = "Ящик с 48 магазинами Shredder для MA5B."
	overlay_ammo_type = "_shred"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/ma5b/shredder

/obj/item/ammo_box/magazine/unsc/br55
	name = "UNSC magazine box (BR55 x 32)"
	desc = "Ящик с 32 магазинами для BR55."
	icon_state = "base_ammo"
	overlay_gun_type = "_br55"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/br55
	num_of_magazines = 32

/obj/item/ammo_box/magazine/unsc/br55/extended
	name = "UNSC magazine box (BR55 x 32, extended)"
	desc = "Ящик с 32 увеличенными магазинами для BR55."
	overlay_ammo_type = "_ext"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/br55/extended

/obj/item/ammo_box/magazine/unsc/dmr
	name = "UNSC magazine box (DMR x 24)"
	desc = "Ящик с 24 магазинами для M392 DMR."
	icon_state = "base_ammo"
	overlay_gun_type = "_dmr"
	magazine_type = /obj/item/ammo_magazine/rifle/halo/dmr
	num_of_magazines = 24

/obj/item/ammo_box/magazine/unsc/dmr/empty
	empty = TRUE

/obj/item/ammo_box/magazine/unsc/small
	name = "UNSC magazine box"
	icon_state = "base_ammosmall"
	limit_per_tile = 2
	overlay_gun_type = null
	overlay_content = "_small"

/obj/item/ammo_box/magazine/unsc/small/m6c
	name = "UNSC magazine box (M6C x 22)"
	desc = "Ящик с 22 магазинами для M6C."
	icon_state = "base_ammosmall"
	magazine_type = /obj/item/ammo_magazine/pistol/halo/m6c
	num_of_magazines = 22

/obj/item/ammo_box/magazine/unsc/small/m6c/socom
	name = "UNSC magazine box (M6C/SOCOM x 22)"
	desc = "Ящик с 22 магазинами для M6C/SOCOM."
	overlay_ammo_type = "_extsmall"
	magazine_type = /obj/item/ammo_magazine/pistol/halo/m6c/socom

/obj/item/ammo_box/magazine/unsc/small/m6g
	name = "UNSC magazine box (M6G x 22)"
	desc = "Ящик с 22 магазинами для M6G."
	icon_state = "base_ammosmall2"
	magazine_type = /obj/item/ammo_magazine/pistol/halo/m6g
	num_of_magazines = 22
