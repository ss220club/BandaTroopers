/datum/ammo/bullet/rifle/f90
	name = "5.5x50mm bullet"
	damage = 45
	penetration = ARMOR_PENETRATION_TIER_1
	shell_casing = /obj/effect/decal/ammo_casing/cartridge

/datum/ammo/bullet/rifle/f90/ap
	name = "armor-piercing 5.5x50mm bullet"
	damage = 50
	penetration = ARMOR_PENETRATION_TIER_5

/datum/ammo/bullet/rifle/f90/heap
	name = "high-explosive armor-piercing 5.5x50mm bullet"
	damage = 65
	penetration = ARMOR_PENETRATION_TIER_6

/obj/item/ammo_magazine/rifle/rmc_f90
	name = "\improper F903 magazine (5.5x50mm)"
	desc = "A 5.5x50mm assault rifle magazine used by the Imperial Armed Space Force."
	caliber = "5.5x50mm"
	default_ammo = /datum/ammo/bullet/rifle/f90
	max_rounds = 60

/obj/item/ammo_magazine/rifle/rmc_f90/ap
	name = "\improper F903 AP magazine (5.5x50mm)"
	desc = "A 5.5x50mm armor-piercing magazine for the F903 rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/ap

/obj/item/ammo_magazine/rifle/rmc_f90/heap
	name = "\improper F903 HEAP magazine (5.5x50mm)"
	desc = "A 5.5x50mm high-explosive armor-piercing magazine for the F903 rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/heap

/obj/item/ammo_magazine/rifle/rmc_f90/marksman
	name = "\improper F903A1 Marksman magazine (5.5x50mm)"
	desc = "A 5.5x50mm marksman magazine for the F903 rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90
	max_rounds = 60
	ammo_band_color = null

/obj/item/ammo_magazine/rifle/rmc_f90/marksman/ap
	name = "\improper F903A1 AP Marksman magazine (5.5x50mm)"
	desc = "A 5.5x50mm armor-piercing marksman magazine for the F903 rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/ap
	ammo_band_color = AMMO_BAND_COLOR_AP

/obj/item/ammo_magazine/rifle/rmc_f90/marksman/heap
	name = "\improper F903A1 HEAP Marksman magazine (5.5x50mm)"
	desc = "A 5.5x50mm high-explosive armor-piercing marksman magazine for the F903 rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/heap
	ammo_band_color = AMMO_BAND_COLOR_HEAP

/obj/item/weapon/gun/rifle/rmc_f90
	name = "\improper F903 Rifle"
	desc = "The former standard rifle of the royal marines, now used by the Imperial Armed Space Force. Uses 5.5x50mm ammunition."
	icon = 'modular/iasf/icons/f90_guns.dmi'
	fire_sound = 'sound/weapons/gun_F90_1.ogg'
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AUTO_EJECT_CASINGS
	start_automatic = TRUE

/obj/item/weapon/gun/rifle/rmc_f90/play_firing_sounds(obj/projectile/projectile_to_fire, mob/user)
	fire_sound = pick('sound/weapons/gun_F90_1.ogg', 'sound/weapons/gun_F90_2.ogg', 'sound/weapons/gun_F90_3.ogg', 'sound/weapons/gun_F90_4.ogg')
	return ..()

/obj/item/weapon/gun/rifle/rmc_f90/a_grip
	desc = "An F903A2 rifle with an angled foregrip. Uses 5.5x50mm ammunition."

/obj/item/weapon/gun/rifle/rmc_f90/scope
	desc = "A scoped F903A1 marksman rifle with a 60-round 5.5x50mm magazine."
	start_automatic = FALSE

/obj/item/weapon/gun/rifle/rmc_f90/shotgun
	desc = "An F903A1/B rifle with an underbarrel shotgun. Uses 5.5x50mm ammunition."
