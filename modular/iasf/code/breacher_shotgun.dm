/datum/ammo/bullet/shotgun/light/breaching/sparkshots/iasf_ap
	name = "16g armor-piercing breaching shell"
	damage = 50
	penetration = ARMOR_PENETRATION_TIER_6
	handful_type = /obj/item/ammo_magazine/handful/shotgun/light/breaching/sparkshots/iasf_ap
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/light/breaching/sparkshots/iasf_ap/spread

/datum/ammo/bullet/shotgun/light/breaching/sparkshots/iasf_ap/spread
	name = "additional armor-piercing fragment"
	damage = 8
	penetration = ARMOR_PENETRATION_TIER_4
	bonus_projectiles_amount = 0

/obj/item/ammo_magazine/rifle/xm52/iasf_ap
	name = "XM52 IASF AP magazine (16g)"
	desc = "A twelve-round magazine of armor-piercing breaching shells for the IASF XM52."
	default_ammo = /datum/ammo/bullet/shotgun/light/breaching/sparkshots/iasf_ap
	gun_type = /obj/item/weapon/gun/rifle/xm52/iasf

/obj/item/ammo_magazine/shotgun/light/breaching/sparkshots/iasf_ap
	name = "box of IASF armor-piercing breaching shells"
	desc = "A box of 16-gauge armor-piercing shells for the IASF XM52."
	default_ammo = /datum/ammo/bullet/shotgun/light/breaching/sparkshots/iasf_ap
	gun_type = /obj/item/weapon/gun/rifle/xm52/iasf

/obj/item/ammo_magazine/handful/shotgun/light/breaching/sparkshots/iasf_ap
	name = "handful of IASF armor-piercing breaching shells"
	default_ammo = /datum/ammo/bullet/shotgun/light/breaching/sparkshots/iasf_ap
	gun_type = /obj/item/weapon/gun/rifle/xm52/iasf

/obj/item/weapon/gun/rifle/xm52/iasf
	name = "XM52 IASF penetrator"
	desc = "An IASF breaching shotgun loaded with armor-piercing 16-gauge shells."
	current_mag = /obj/item/ammo_magazine/rifle/xm52/iasf_ap
	flags_equip_slot = SLOT_BACK|SLOT_WAIST|SLOT_SUIT_STORE
