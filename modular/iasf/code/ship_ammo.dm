/datum/ammo/bullet/rifle/f90/incendiary
	name = "incendiary 5.5x50mm bullet"
	damage_type = BURN
	damage = 35
	shrapnel_chance = 0
	icon_state = "bullet_red"
	ammo_glowing = TRUE
	bullet_light_color = COLOR_SOFT_RED

/datum/ammo/bullet/rifle/f90/incendiary/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_incendiary)))

/datum/ammo/bullet/rifle/f90/impact
	name = "impact-detonating 5.5x50mm bullet"
	damage = 35
	penetration = -ARMOR_PENETRATION_TIER_2
	damage_falloff = DAMAGE_FALLOFF_TIER_5
	icon_state = "bullet_red"
	ammo_glowing = TRUE
	bullet_light_color = COLOR_SOFT_RED

/datum/ammo/bullet/rifle/f90/impact/on_hit_mob(mob/entity, obj/projectile/bullet)
	knockback(entity, bullet, max_range = INFINITY)

/datum/ammo/bullet/rifle/f90/flak
	name = "flak 5.5x50mm bullet"
	damage = 24
	penetration = 0
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_3
	bonus_projectiles_type = /datum/ammo/bullet/rifle/f90/flak/spread

/datum/ammo/bullet/rifle/f90/flak/spread
	name = "5.5x50mm flak fragment"
	damage = 12
	scatter = SCATTER_AMOUNT_TIER_2
	bonus_projectiles_amount = 0
	bonus_projectiles_type = null

/obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary
	name = "F903A1 incendiary marksman magazine (5.5x50mm)"
	desc = "A 60-round incendiary magazine for the F903A1 marksman rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/incendiary
	ammo_band_color = AMMO_BAND_COLOR_INCENDIARY

/obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact
	name = "F903A1 impact marksman magazine (5.5x50mm)"
	desc = "A 60-round impact-detonating magazine for the F903A1 marksman rifle."
	default_ammo = /datum/ammo/bullet/rifle/f90/impact
	ammo_band_color = AMMO_BAND_COLOR_IMPACT

/obj/item/ammo_magazine/rifle/rmc_f90/marksman/flak
	name = "F903A1 flak marksman magazine (5.5x50mm)"
	default_ammo = /datum/ammo/bullet/rifle/f90/flak
	ammo_band_color = AMMO_BAND_COLOR_HIGH_VELOCITY

/obj/item/ammo_box/magazine/f90/marksman/incendiary
	name = "magazine box (F903A1 Marksman incendiary x 10)"
	overlay_ammo_type = "_incen"
	overlay_content = "_incen"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary

/obj/item/ammo_box/magazine/f90/marksman/impact
	name = "magazine box (F903A1 Marksman impact x 10)"
	overlay_ammo_type = "_impact"
	overlay_content = "_impact"
	magazine_type = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact

/obj/item/ammo_magazine/smg/p90/twe/heap
	name = "\improper FN-TWE P90 HEAP magazine (5.7×28mm)"
	desc = "A 50-round high-explosive armor-piercing magazine for the FN-TWE P90."
	default_ammo = /datum/ammo/bullet/smg/heap
	ammo_band_color = AMMO_BAND_COLOR_HEAP

/obj/item/ammo_box/magazine/p90/twe
	parent_type = /obj/item/ammo_box/magazine
	name = "magazine box (FN-TWE P90 AP x 12)"
	icon_state = "base_fn"
	flags_equip_slot = SLOT_BACK
	overlay_gun_type = "_fnfp9000"
	overlay_ammo_type = "_ap"
	overlay_content = "_ap"
	num_of_magazines = 12
	magazine_type = /obj/item/ammo_magazine/smg/p90/twe

/obj/item/ammo_box/magazine/p90/twe/empty
	empty = TRUE

/obj/item/ammo_box/magazine/p90/twe/heap
	name = "magazine box (FN-TWE P90 HEAP x 12)"
	overlay_ammo_type = "_heap"
	overlay_content = "_heap"
	magazine_type = /obj/item/ammo_magazine/smg/p90/twe/heap

/obj/item/ammo_box/magazine/p90/twe/heap/empty
	empty = TRUE
