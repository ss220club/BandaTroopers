// rifle magazines

/obj/item/ammo_magazine/rifle/halo
	name = "магазин Halo"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null

/obj/item/ammo_magazine/rifle/halo/ma5c
	name = "\improper магазин MA5C (7.62x51 мм FMJ)"
	desc = "Прямоугольный коробчатый магазин для MA5C, вмещающий 48 патронов 7.62x51 FMJ."
	icon_state = "ma5c"
	max_rounds = 48
	gun_type = /obj/item/weapon/gun/rifle/halo/ma5c
	default_ammo = /datum/ammo/bullet/rifle/ma5
	caliber = "7.62x51"
	ammo_band_icon = "+ma5c_band"
	ammo_band_icon_empty = "+ma5c_band_e"

/obj/item/ammo_magazine/rifle/halo/ma5c/shredder
	name = "\improper магазин MA5C (7.62x51 мм Shredder)"
	desc = "Прямоугольный коробчатый магазин для MA5C, вмещающий 48 патронов 7.62x51 Shredder - специализированных боеприпасов, пробивающих броню и фрагментирующихся в цели."
	max_rounds = 48
	gun_type = /obj/item/weapon/gun/rifle/halo/ma5c
	default_ammo = /datum/ammo/bullet/rifle/ma5/shredder
	caliber = "7.62x51"
	ammo_band_color = "#994545"

/obj/item/ammo_magazine/rifle/halo/ma5b
	name = "\improper магазин MA5B (7.62x51 мм FMJ)"
	desc = "Прямоугольный коробчатый магазин для MA5B, вмещающий 60 патронов 7.62x51 FMJ."
	icon_state = "ma5b"
	max_rounds = 60
	gun_type = /obj/item/weapon/gun/rifle/halo/ma5b
	default_ammo = /datum/ammo/bullet/rifle/ma5
	caliber = "7.62x51"
	ammo_band_icon = "+ma5b_band"
	ammo_band_icon_empty = "+ma5b_band_e"

/obj/item/ammo_magazine/rifle/halo/ma5b/shredder
	name = "\improper магазин MA5B (7.62x51 мм Shredder)"
	desc = "Прямоугольный коробчатый магазин для MA5B, вмещающий 60 патронов 7.62x51 Shredder - специализированных боеприпасов, пробивающих броню и фрагментирующихся в цели."
	max_rounds = 60
	gun_type = /obj/item/weapon/gun/rifle/halo/ma5b
	default_ammo = /datum/ammo/bullet/rifle/ma5/shredder
	caliber = "7.62x51"
	ammo_band_color = "#994545"

/obj/item/ammo_magazine/rifle/halo/ma3a
	name = "\improper магазин MA3A (7.62x51 мм FMJ)"
	desc = "Прямоугольный коробчатый магазин для MA3A, вмещающий 32 патрона 7.62x51 FMJ."
	icon_state = "ma3a"
	max_rounds = 32
	gun_type = /obj/item/weapon/gun/rifle/halo/ma3a
	default_ammo = /datum/ammo/bullet/rifle/ma3a
	caliber = "7.62x51"

/obj/item/ammo_magazine/rifle/halo/vk78
	name = "\improper магазин VK78 (6.5x48 мм FMJ)"
	desc = "Угловатый коробчатый магазин для VK78, вмещающий 20 патронов 6.5x48 мм FMJ."
	icon_state = "vk78"
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/halo/vk78
	default_ammo = /datum/ammo/bullet/rifle/vk78
	caliber = "6.5x48"

/obj/item/ammo_magazine/rifle/halo/br55
	name = "\improper магазин BR55 (9.5x40 мм X-HP SAP-HE)"
	desc = "Прямоугольный коробчатый магазин для BR55, вмещающий 36 патронов 9.5x40 мм X-HP SAP-HE."
	icon_state = "br55"
	max_rounds = 36
	gun_type = /obj/item/weapon/gun/rifle/halo/br55
	default_ammo = /datum/ammo/bullet/rifle/br55
	caliber = "9.5x40mm"
	bonus_overlay = "br55_overlay"

/obj/item/ammo_magazine/rifle/halo/br55/extended
	name = "\improper четырёхрядный магазин BR55 (9.5x40 мм X-HP SAP-HE)"
	desc = "Четырёхрядный прямоугольный магазин для BR55, вмещающий 60 патронов 9.5x40 мм X-HP SAP-HE."
	icon_state = "br55_quadstack"
	max_rounds = 60
	bonus_overlay = "br55_ext_overlay"

/obj/item/ammo_magazine/rifle/halo/dmr
	name = "\improper магазин M392 DMR (7.62x51 мм FMJ)"
	desc = "Прямоугольный 15-зарядный магазин для M392 DMR, снаряжённый патронами 7.62x51 мм FMJ."
	icon_state = "dmr"
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/halo/dmr
	default_ammo = /datum/ammo/bullet/rifle/dmr
	caliber = "7.62x51"

// smg magazines
/obj/item/ammo_magazine/smg/halo
	name = "магазин ПП Halo"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null

/obj/item/ammo_magazine/smg/halo/m7
	name = "\improper магазин M7 (5×23 мм M443 Caseless FMJ)"
	desc = "Прямоугольный магазин, вставляемый сбоку в пистолет-пулемёт M7. Вмещает 60 патронов 5×23 мм M443 Caseless FMJ."
	icon_state = "m7"
	max_rounds = 60
	gun_type = /obj/item/weapon/gun/smg/halo/
	default_ammo = /datum/ammo/bullet/smg/m7
	caliber = "5x23mm"

// sniper magazines

/obj/item/ammo_magazine/rifle/halo/sniper
	name = "\improper магазин SRS99-AM (14.5x114 мм APFSDS)"
	desc = "Прямоугольный коробчатый магазин для SRS99-AM, вмещающий четыре бронебойных подкалиберных оперённых снаряда 14.5x114 мм."
	icon_state = "srs99"
	max_rounds = 4
	gun_type = /obj/item/weapon/gun/rifle/sniper/halo
	default_ammo = /datum/ammo/bullet/rifle/srs99
	caliber = "14.5x114mm"

// shotgun internal magazines

/obj/item/ammo_magazine/internal/shotgun/m90
	caliber = "8g"
	max_rounds = 12
	current_rounds = 12
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc

/obj/item/ammo_magazine/internal/shotgun/m90/unloaded
	current_rounds = 0

/obj/item/ammo_magazine/internal/shotgun/m90/police
	default_ammo = /datum/ammo/bullet/shotgun/beanbag/unsc

// shotgun shells

/obj/item/ammo_magazine/shotgun/buckshot/unsc
	name = "коробка дробовых патронов ККОН 8-го калибра"
	desc = "Коробка, заполненная дробовыми патронами MAG 15P-00B 8-го калибра."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

/obj/item/ammo_magazine/shotgun/beanbag/unsc
	name = "коробка травматических патронов ККОН 8-го калибра"
	desc = "Коробка, заполненная травматическими патронами MAG LLHB 8-го калибра."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g_beanbag"
	default_ammo = /datum/ammo/bullet/shotgun/beanbag/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

// rockets

/obj/item/ammo_magazine/spnkr
	name = "\improper трубный блок M19 SSM"
	desc = "Двухтрубный 102-мм ракетный блок, предназначенный для загрузки в M41 SPNKr."
	caliber = "102mm"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/special.dmi'
	icon_state = "spnkr_rockets"
	w_class = SIZE_LARGE
	max_rounds = 2
	default_ammo = /datum/ammo/rocket/spnkr
	gun_type = /obj/item/weapon/gun/halo_launcher/spnkr
	reload_delay = 30

/obj/item/ammo_magazine/spnkr/update_icon()
	..()
	if(current_rounds <= 0)
		name = "\improper отстрелянный трубный блок M19 SSM"
		desc = "Отстрелянный двухтрубный 102-мм ракетный блок, ранее заряженный в SPNKr. Теперь он вам уже ни к чему..."

/obj/item/ammo_magazine/spnkr/attack(mob/living/carbon/human/carbon, mob/living/carbon/human/user)
	if(!istype(carbon) || !istype(user) || get_dist(user, carbon) > 1)
		return
	var/obj/item/weapon/gun/halo_launcher/spnkr/in_hand = carbon.get_active_hand()
	if(!in_hand || !istype(in_hand))
		return
	if(!skillcheck(carbon, SKILL_FIREARMS, SKILL_FIREARMS_TRAINED))
		to_chat(user, SPAN_WARNING("You don't know how to reload \the [in_hand]!"))
		return
	var/obj/item/weapon/twohanded/offhand/off_hand = carbon.get_inactive_hand()
	if(!off_hand || !istype(off_hand))
		to_chat(user, SPAN_WARNING("\the [carbon] needs to be wielding \the [in_hand] in order to reload!"))
		to_chat(carbon, SPAN_WARNING("You need to be wielding \the [in_hand] in order for [user] to reload it for you!"))
		return
	if(in_hand.current_mag && in_hand.current_mag.current_rounds > 0)
		to_chat(user, SPAN_WARNING("\the [in_hand] still has ammo left!"))
		to_chat(carbon, SPAN_WARNING("[user] tries to reload \the [in_hand] but it still has ammo left!"))
		return
	if(user.action_busy)
		return
	if(!in_hand.cover_open)
		in_hand.toggle_cover(user)
	to_chat(user, SPAN_NOTICE("You begin reloading \the [carbon]'s [in_hand]! Hold still..."))
	to_chat(carbon, SPAN_NOTICE("[user] begins reloading your [in_hand]! Hold still..."))
	if(!do_after(user,(reload_delay / 2), INTERRUPT_ALL, BUSY_ICON_FRIENDLY, carbon, INTERRUPT_ALL, BUSY_ICON_GENERIC))
		to_chat(user, SPAN_WARNING("Your reload was interrupted!"))
		to_chat(carbon, SPAN_WARNING("[user]'s reload was interrupted!"))
		return
	if(off_hand != carbon.get_inactive_hand())
		to_chat(user, SPAN_WARNING("\the [carbon] needs to be wielding \the [in_hand] in order to reload!"))
		to_chat(carbon, SPAN_WARNING("You need to be wielding \the [in_hand] in order for [user] to reload it for you!"))
		return
	user.drop_inv_item_on_ground(src)
	if(in_hand.current_mag)
		in_hand.current_mag.forceMove(get_turf(carbon))
	in_hand.replace_ammo(user,src)
	in_hand.current_mag = src
	forceMove(in_hand)
	to_chat(user, SPAN_NOTICE("You load \the [src] into \the [carbon]'s [in_hand]."))
	to_chat(carbon, SPAN_WARNING("[user] loads \the [src] into your [in_hand]."))
	in_hand.toggle_cover(user)
	if(in_hand.reload_sound)
		playsound(carbon, in_hand.reload_sound, 25, 1)
	else
		playsound(carbon,'sound/machines/click.ogg', 25, 1)

	return 1

// pistol magazines

/obj/item/ammo_magazine/pistol/halo
	name = "магазин Halo"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null
	caliber = "12.7x40mm"

/obj/item/ammo_magazine/pistol/halo/m6c
	name = "\improper магазин M6C (12.7x40 мм SAP-HE)"
	desc = "Прямоугольный скошенный магазин для M6C, вмещающий 12 патронов 12.7x40 мм SAP-HE."
	icon_state = "m6c"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6c
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12
	bonus_overlay = "m6c_overlay"

/obj/item/ammo_magazine/pistol/halo/m6c/socom
	name = "\improper магазин M6C/SOCOM (12.7x40 мм SAP-HE)"
	desc = "Увеличенный магазин для M6C, вмещающий 16 патронов вместо стандартных 12. Выполнен в спецоперативном чёрном цвете - для настоящего скрытного оперативника."
	max_rounds = 16
	icon_state = "m6c_socom"
	bonus_overlay = "m6c_ext_overlay"

/obj/item/ammo_magazine/pistol/halo/m6a
	name = "\improper магазин M6A (12.7x40 мм SAP-HE)"
	desc = "Прямоугольный скошенный магазин для M6A, вмещающий 12 патронов 12.7x40 мм SAP-HE."
	icon_state = "m6c"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6a
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12

/obj/item/ammo_magazine/pistol/halo/m6g
	name = "\improper магазин M6G (12.7x40 мм SAP-HE)"
	desc = "Прямоугольный скошенный магазин для M6G, вмещающий 8 патронов 12.7x40 мм SAP-HE."
	icon_state = "m6g"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6g
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 8

/obj/item/ammo_magazine/pistol/halo/m6d
	name = "\improper магазин M6D (12.7x40 мм SAP-HE)"
	desc = "Прямоугольный скошенный магазин для M6D, вмещающий 12 патронов 12.7x40 мм SAP-HE. Хромированная отделка."
	icon_state = "m6d"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6d
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12
