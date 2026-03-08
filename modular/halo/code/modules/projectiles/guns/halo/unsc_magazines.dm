// rifle magazines

/obj/item/ammo_magazine/rifle/halo
	name = "halo magazine"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null

/obj/item/ammo_magazine/rifle/halo/ma5c
	name = "\improper MA5C magazine (7.62x51mm FMJ)"
	desc = "A rectangular box magazine for the MA5C holding 48 rounds of 7.62x51 FMJ ammunitions."
	icon_state = "ma5c"
	max_rounds = 48
	gun_type = /obj/item/weapon/gun/rifle/halo/ma5c
	default_ammo = /datum/ammo/bullet/rifle/ma5c
	caliber = "7.62x51"
	ammo_band_icon = "+ma5c_band"
	ammo_band_icon_empty = "+ma5c_band_e"

/obj/item/ammo_magazine/rifle/halo/ma5c/shredder
	name = "\improper MA5C magazine (7.62x51mm Shredder)"
	desc = "A rectangular box magazine for the MA5C holding 60 rounds of 7.62x51 shredder ammunitions, a specialized ammunition that pierces armor and splinters in the target."
	max_rounds = 48
	gun_type = /obj/item/weapon/gun/rifle/halo/ma5c
	default_ammo = /datum/ammo/bullet/rifle/ma5c/shredder
	caliber = "7.62x51"
	ammo_band_color = "#994545"

/obj/item/ammo_magazine/rifle/halo/ma3a
	name = "\improper MA3A magazine (7.62x51mm FMJ)"
	desc = "A rectangular box magazine for the MA3A holding 32 rounds of 7.62x51 FMJ ammunitions."
	icon_state = "ma3a"
	max_rounds = 32
	gun_type = /obj/item/weapon/gun/rifle/halo/ma3a
	default_ammo = /datum/ammo/bullet/rifle/ma3a
	caliber = "7.62x51"

/obj/item/ammo_magazine/rifle/halo/vk78
	name = "\improper VK78 magazine (6.5x48mm FMJ)"
	desc = "An angular box magazine for the VK78 holding 20 rounds of 6.5x48mm FMJ ammunitions."
	icon_state = "vk78"
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/halo/vk78
	default_ammo = /datum/ammo/bullet/rifle/vk78
	caliber = "6.5x48"

/obj/item/ammo_magazine/rifle/halo/br55
	name = "\improper BR55 magazine (9.5x40mm X-HP SAP-HE)"
	desc = "A rectangular box magazine for the BR55 holding 36 rounds of 9.5x40mm X-HP SAP-HE ammunitions."
	icon_state = "br55"
	max_rounds = 36
	gun_type = /obj/item/weapon/gun/rifle/halo/br55
	default_ammo = /datum/ammo/bullet/rifle/br55
	caliber = "9.5x40mm"
	bonus_overlay = "br55_overlay"

/obj/item/ammo_magazine/rifle/halo/br55/extended
	name = "\improper quad-stack BR55 magazine (9.5x40mm X-HP SAP-HE)"
	desc = "A quad-stack rectangular box magazine for the BR55 holding 60 rounds of 9.5x40mm X-HP SAP-HE ammunitions."
	icon_state = "br55_quadstack"
	max_rounds = 60
	bonus_overlay = "br55_ext_overlay"

/obj/item/ammo_magazine/rifle/halo/dmr
	name = "\improper M392 DMR magazine (7.62x51mm FMJ)"
	desc = "A rectangular 15 round box magazine for the M392 DMR filled with 7.62x51mm FMJ ammo."
	icon_state = "dmr"
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/halo/dmr
	default_ammo = /datum/ammo/bullet/rifle/dmr
	caliber = "7.62x51"

// smg magazines
/obj/item/ammo_magazine/smg/halo
	name = "halo smg magazine"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null

/obj/item/ammo_magazine/smg/halo/m7
	name = "\improper M7 magazine (5×23mm M443 Caseless FMJ)"
	desc = "A rectangular magazine to be inserted into the side of the M7 submachine gun. It holds 60 rounds of 5×23mm M443 Caseless FMJ."
	icon_state = "m7"
	max_rounds = 60
	gun_type = /obj/item/weapon/gun/smg/halo/
	default_ammo = /datum/ammo/bullet/smg/m7
	caliber = "5x23mm"

// sniper magazines

/obj/item/ammo_magazine/rifle/halo/sniper
	name = "\improper SRS99-AM magazine (14.5x114mm APFSDS)"
	desc = "A rectangular box magazine for the SRS99-AM holding four rounds of 14.5x114mm armor-piercing, fin-stabilized, discarding sabot."
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
	name = "UNSC 8-gauge shotgun shell box"
	desc = "A box filled with 8-gauge MAG 15P-00B buckshot shells."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

/obj/item/ammo_magazine/shotgun/beanbag/unsc
	name = "UNSC 8-gauge shotgun beanbag box"
	desc = "A box filled with 8-gauge MAG LLHB beanbag shells."
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g_beanbag"
	default_ammo = /datum/ammo/bullet/shotgun/beanbag/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

// rockets

/obj/item/ammo_magazine/spnkr
	name = "\improper M19 SSM tube assembly"
	desc = "A 102mm dual-tubed rocket assembly intended to be loaded into an M41 spnkr."
	caliber = "102mm"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/special.dmi'
	icon_state = "spnkr_rockets"
	bonus_overlay = "spnkr_rockets"
	max_rounds = 2
	default_ammo = /datum/ammo/rocket/spnkr
	gun_type = /obj/item/weapon/gun/halo_launcher/spnkr
	reload_delay = 30

/obj/item/ammo_magazine/spnkr/update_icon()
	..()
	if(current_rounds <= 0)
		name = "\improper spent M19 SSM tube assembly"
		desc = "A spent 102mm dual-tubed rocket assembly previously loaded into a spnkr. Of no use to you now..."

// pistol magazines

/obj/item/ammo_magazine/pistol/halo
	name = "halo magazine"
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null
	caliber = "12.7x40mm"

/obj/item/ammo_magazine/pistol/halo/m6c
	name = "\improper M6C magazine (12.7x40mm SAP-HE)"
	desc = "A rectangular and slanted magazine for the M6C, holding 12 rounds of 12.7x40mm SAP-HE ammunition."
	icon_state = "m6c"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6c
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12
	bonus_overlay = "m6c_overlay"

/obj/item/ammo_magazine/pistol/halo/m6c/socom
	name = "\improper M6C/SOCOM magazine (12.7x40mm SAP-HE)"
	desc = "An extended capacity M6C magazine, capable of holding 16 rounds compared to the standard 12. Comes in special-ops black, for the true clandestine operative."
	max_rounds = 16
	icon_state = "m6c_socom"
	bonus_overlay = "m6c_ext_overlay"

/obj/item/ammo_magazine/pistol/halo/m6a
	name = "\improper M6A magazine (12.7x40mm SAP-HE)"
	desc = "A rectangular and slanted magazine for the M6A, holding 12 rounds of 12.7x40mm SAP-HE ammunition."
	icon_state = "m6c"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6a
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12

/obj/item/ammo_magazine/pistol/halo/m6g
	name = "\improper M6G magazine (12.7x40mm SAP-HE)"
	desc = "A rectangular slanted magazine for the M6G, holding 8 rounds of 12.7x40mm SAP-HE ammunition"
	icon_state = "m6g"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6g
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 8
