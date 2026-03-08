/datum/ammo/energy/halo_plasma
	name = "plasma bolt"
	icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	shell_speed = AMMO_SPEED_TIER_3
	flags_ammo_behavior = AMMO_BALLISTIC
	sound_hit = "plasma_impact"
	sound_miss = "plasma_miss"
	ammo_glowing = TRUE
	bullet_light_color = COLOR_PLASMA_TEAL

/datum/ammo/energy/halo_plasma/plasma_pistol
	name = "light plasma bolt"
	icon_state = "plasma_teal"
	accurate_range = 10
	max_range = 20
	damage = 28
	accuracy = HIT_ACCURACY_TIER_3
	scatter = SCATTER_AMOUNT_TIER_10

/datum/ammo/energy/halo_plasma/plasma_pistol/overcharge
	name = "overcharged light plasma bolt"
	damage = 80
	shell_speed = AMMO_SPEED_TIER_4

/datum/ammo/energy/halo_plasma/plasma_rifle
	name = "plasma bolt"
	icon_state = "plasma_blue"
	shell_speed = AMMO_SPEED_TIER_4
	accurate_range = 14
	max_range = 24
	damage = 38
	ammo_glowing = TRUE
	bullet_light_color = COLOR_PLASMA_BLUE

/datum/ammo/needler
	name = "needle"
	icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	icon_state = "needle"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	damage = 28
	penetration = ARMOR_PENETRATION_TIER_3
	accurate_range = 16
	accuracy = HIT_ACCURACY_TIER_MAX
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = AMMO_SPEED_TIER_3
	effective_range_max = 7
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 24
	shrapnel_type = /obj/item/shard/shrapnel/needler
	shrapnel_chance = SHRAPNEL_CHANCE_TIER_10
	ammo_glowing = TRUE
	bullet_light_color = COLOR_NEEDLER_PINK

/datum/ammo/needler/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	if(ishuman(M))
		M.AddComponent(/datum/component/supercombine, M, P.dir)

/datum/ammo/bullet/rifle/carbine
	name = "carbine bullet"
	icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	icon_state = "carbine"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	damage = 50
	penetration = ARMOR_PENETRATION_TIER_3
	accurate_range = 24
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = 1.5*AMMO_SPEED_TIER_6
	effective_range_max = 24
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 32
	shrapnel_chance = null
	ammo_glowing = TRUE
	bullet_light_color = COLOR_CARBINE_GREEN
