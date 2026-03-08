// rifle ammo

/datum/ammo/bullet/rifle/ma5c
	name = "FMJ bullet"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	damage = 40
	penetration = ARMOR_PENETRATION_TIER_1
	accurate_range = 16
	accuracy = HIT_ACCURACY_TIER_6
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = AMMO_SPEED_TIER_6
	effective_range_max = 7
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 24
	shell_casing = /obj/effect/decal/ammo_casing/cartridge/halo

/datum/ammo/bullet/rifle/ma5c/shredder
	name = "shredder bullet"
	damage = 52
	penetration = ARMOR_PENETRATION_TIER_2

/datum/ammo/bullet/rifle/ma3a
	name = "FMJ bullet"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	damage = 40
	penetration = ARMOR_PENETRATION_TIER_2
	accurate_range = 16
	accuracy = HIT_ACCURACY_TIER_4
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = AMMO_SPEED_TIER_6
	effective_range_max = 7
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 24
	shell_casing = /obj/effect/decal/ammo_casing/cartridge/halo

/datum/ammo/bullet/rifle/vk78
	name = "FMJ bullet"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	damage = 35
	penetration = ARMOR_PENETRATION_TIER_1
	accurate_range = 14
	accuracy = HIT_ACCURACY_TIER_6
	scatter = SCATTER_AMOUNT_TIER_7
	shell_speed = AMMO_SPEED_TIER_5
	effective_range_max = 7
	damage_falloff = DAMAGE_FALLOFF_TIER_5
	max_range = 22
	shell_casing = /obj/effect/decal/ammo_casing/cartridge/halo

/datum/ammo/bullet/rifle/br55
	name = "X-HP SAP-HE bullet"
	headshot_state = HEADSHOT_OVERLAY_MEDIUM
	damage = 50
	penetration = ARMOR_PENETRATION_TIER_3
	accurate_range = 16
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = 1.5*AMMO_SPEED_TIER_6
	effective_range_max = 16
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 24
	shell_casing = /obj/effect/decal/ammo_casing/cartridge/halo

/datum/ammo/bullet/rifle/dmr
	name = "FMJ bullet"
	headshot_state = HEADSHOT_OVERLAY_HEAVY
	damage = 60
	penetration = ARMOR_PENETRATION_TIER_4
	accurate_range = 24
	accuracy = HIT_ACCURACY_TIER_8
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = AMMO_SPEED_TIER_6
	effective_range_max = 12
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 36
	shell_casing = /obj/effect/decal/ammo_casing/cartridge/halo

// smg ammo
/datum/ammo/bullet/smg/m7
	name = "5×23mm M443 FMJ"
	penetration = 0
	damage = 34
	penetration = ARMOR_PENETRATION_TIER_1
	scatter = SCATTER_AMOUNT_TIER_8
	accuracy = HIT_ACCURACY_TIER_4

// shotgun ammo

/datum/ammo/bullet/shotgun/buckshot/unsc
	name = "MAG 15P-00B"
	handful_state = "8g_shell"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread/unsc
	accurate_range = 8
	max_range = 8
	damage = 60
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_8
	firing_freq_offset = SOUND_FREQ_LOW
	shell_casing = /obj/effect/decal/ammo_casing/redshell

/datum/ammo/bullet/shotgun/spread/unsc
	name = "additional buckshot, USCM special type"
	accurate_range = 8
	max_range = 8
	damage = 90
	firing_freq_offset = SOUND_FREQ_LOW

/datum/ammo/bullet/shotgun/beanbag/unsc
	name = "MAG LLHB"
	handful_state = "8g_beanbag"
	accurate_range = 10
	max_range = 10
	stamina_damage = 75
	damage = 35
	shell_casing = /obj/effect/decal/ammo_casing/blueshell

// rocket ammo

/datum/ammo/rocket/spnkr
	name = "M19 missile"
	icon = 'icons/halo/obj/items/weapons/halo_projectiles.dmi'
	icon_state = "spnkr_missile"
	damage = 200
	shell_speed = AMMO_SPEED_TIER_6
	accuracy = HIT_ACCURACY_TIER_4
	accurate_range = 14
	max_range = 14


// sniper ammo

/datum/ammo/bullet/rifle/srs99
	name = "APFSDS bullet"
	headshot_state = HEADSHOT_OVERLAY_HEAVY
	damage = 200
	penetration = ARMOR_PENETRATION_TIER_8
	accurate_range = 24
	accuracy = HIT_ACCURACY_TIER_10
	scatter = SCATTER_AMOUNT_TIER_10
	effective_range_max = 24
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	max_range = 48
	shell_speed = AMMO_SPEED_TIER_6 + AMMO_SPEED_TIER_2
	shell_casing = /obj/effect/decal/ammo_casing/cartridge/halo

// pistol ammo

/datum/ammo/bullet/pistol/magnum
	name = "SAP-HE bullet"
	headshot_state = HEADSHOT_OVERLAY_HEAVY
	accuracy = HIT_ACCURACY_TIER_4
	accuracy_var_low = PROJECTILE_VARIANCE_TIER_6
	damage = 40
	penetration= ARMOR_PENETRATION_TIER_2
	shrapnel_chance = SHRAPNEL_CHANCE_TIER_2
	shell_casing = /obj/effect/decal/ammo_casing/bullet/halo
