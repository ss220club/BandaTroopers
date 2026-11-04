/obj/item/weapon/gun/pistol/heavy/pvp
	name = "Desert Eagle (PvP)"
	desc = "A powerful .50-caliber Desert Eagle from the BandaMarines arsenal."
	icon = 'modular/weapons/icons/pvp/world/deagle.dmi'
	icon_state = "deagle"
	item_state = "deagle"
	firesound_volume = 40
	item_icons = list(
		WEAR_WAIST = 'modular/weapons/icons/pvp/onmob/belts_guns.dmi',
		WEAR_J_STORE = 'modular/weapons/icons/pvp/onmob/suit_pistols.dmi',
		WEAR_L_HAND = 'modular/weapons/icons/pvp/onmob/pistols_lefthand.dmi',
		WEAR_R_HAND = 'modular/weapons/icons/pvp/onmob/pistols_righthand.dmi',
	)
	item_state_slots = list(WEAR_WAIST = "gun", WEAR_J_STORE = "m4a3")

/obj/item/weapon/gun/revolver/mateba/pvp_m2006
	name = "Spearhead 2006M autorevolver (PvP)"
	desc = "A recoil-operated .454 autorevolver with a modern attachment rail."
	icon = 'modular/weapons/icons/pvp/world/m2006.dmi'
	icon_state = "mateba_2006m"
	item_state = "mateba_2006m"
	lineart_gun_icon = "mateba"
	current_mag = /obj/item/ammo_magazine/internal/revolver/mateba/impact
	fire_sound = 'modular/weapons/sound/pvp/m2006_fire.ogg'
	chamber_close_sound = 'modular/weapons/sound/pvp/m2006_close.ogg'
	unload_sound = 'modular/weapons/sound/pvp/m2006_open.ogg'
	reload_sound = 'modular/weapons/sound/pvp/m2006_load.ogg'
	starting_attachment_types = list()
	item_icons = list(
		WEAR_WAIST = 'modular/weapons/icons/pvp/onmob/belts_guns.dmi',
		WEAR_J_STORE = 'modular/weapons/icons/pvp/onmob/suit_revolvers.dmi',
		WEAR_L_HAND = 'modular/weapons/icons/pvp/onmob/revolvers_lefthand.dmi',
		WEAR_R_HAND = 'modular/weapons/icons/pvp/onmob/revolvers_righthand.dmi',
	)
	item_state_slots = list(WEAR_WAIST = "44", WEAR_J_STORE = "m44r")

/obj/item/weapon/gun/revolver/mateba/pvp_m2006/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 23, "rail_x" = 19, "rail_y" = 23, "under_x" = 19, "under_y" = 17, "stock_x" = 19, "stock_y" = 17, "special_x" = 23, "special_y" = 22)

/obj/item/attachable/stock/smg/collapsible/pvp_mp5a5
	name = "MP5A5 folding stock"
	icon = 'modular/weapons/icons/pvp/world/stock.dmi'
	icon_state = "mp5_stockc"
	attach_icon = "mp5_stockc_a"
	flags_attach_features = ATTACH_ACTIVATION
	stock_activated = FALSE

/obj/item/attachable/stock/smg/collapsible/pvp_mp5a5/apply_on_weapon(obj/item/weapon/gun/gun)
	. = ..()
	icon_state = stock_activated ? "mp5_stockc" : "mp5_stockcc"
	attach_icon = stock_activated ? "mp5_stockc_a" : "mp5_stockcc_a"
	gun.update_overlays(src, "stock")

/obj/item/weapon/gun/smg/mp5/pvp_mp5a5
	name = "MP5A5 submachinegun (PvP)"
	desc = "A modernized MP5A5 with an integrated folding stock."
	icon = 'modular/weapons/icons/pvp/world/mp5a5.dmi'
	icon_state = "mp5_alt"
	item_state = "mp5_alt"
	lineart_gun_icon = "mp5"
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/bayonet/wy,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/gyro,
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/attached_gun/grenade/m203,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/stock/smg/collapsible/pvp_mp5a5,
	)
	item_icons = list(
		WEAR_BACK = 'modular/weapons/icons/pvp/onmob/back_smgs.dmi',
		WEAR_J_STORE = 'modular/weapons/icons/pvp/onmob/suit_smgs.dmi',
		WEAR_L_HAND = 'modular/weapons/icons/pvp/onmob/smgs_lefthand.dmi',
		WEAR_R_HAND = 'modular/weapons/icons/pvp/onmob/smgs_righthand.dmi',
	)
	item_state_slots = list(WEAR_BACK = "m39b2", WEAR_J_STORE = "mp5a5")

/obj/item/weapon/gun/smg/mp5/pvp_mp5a5/handle_starting_attachment()
	..()
	var/obj/item/attachable/stock/smg/collapsible/pvp_mp5a5/stock = new(src)
	stock.hidden = FALSE
	stock.Attach(src)
	stock.apply_on_weapon(src)
	update_attachable(stock.slot)

/obj/item/weapon/gun/smg/mp5/pvp_mp5a5/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 26, "muzzle_y" = 17, "rail_x" = 8, "rail_y" = 19, "under_x" = 19, "under_y" = 13, "stock_x" = 39, "stock_y" = 11)

/obj/item/weapon/gun/rifle/m16/pvp_m16a5_tactical
	name = "M16A5 tactical rifle (PvP)"
	desc = "A modernized M16A5 with a tactical accessory setup."
	icon = 'modular/weapons/icons/pvp/world/m16a5.dmi'
	icon_state = "m16a5"
	item_state = "m16a5"
	lineart_gun_icon = "m16"
	random_spawn_chance = 100
	random_spawn_rail = list(/obj/item/attachable/reddot, /obj/item/attachable/reflex)
	random_spawn_under = list(/obj/item/attachable/angledgrip, /obj/item/attachable/verticalgrip, /obj/item/attachable/lasersight)
	random_spawn_muzzle = list(/obj/item/attachable/suppressor)
	item_icons = list(
		WEAR_BACK = 'modular/weapons/icons/pvp/onmob/back_assault_rifles.dmi',
		WEAR_J_STORE = 'modular/weapons/icons/pvp/onmob/suit_assault_rifles.dmi',
		WEAR_L_HAND = 'modular/weapons/icons/pvp/onmob/assault_rifles_lefthand.dmi',
		WEAR_R_HAND = 'modular/weapons/icons/pvp/onmob/assault_rifles_righthand.dmi',
	)
	item_state_slots = list(WEAR_BACK = "m16", WEAR_J_STORE = "m16a5")

/obj/item/weapon/gun/rifle/m16/pvp_m16a5_tactical/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 17, "rail_x" = 11, "rail_y" = 20, "under_x" = 24, "under_y" = 14, "stock_x" = 15, "stock_y" = 14)

/datum/ammo/bullet/pistol/pvp_l54_gold
	penetration = ARMOR_PENETRATION_TIER_3

/obj/item/ammo_magazine/pistol/pvp_l54_gold
	name = "L54-S magazine (9x20mm)"
	desc = "A proprietary magazine for the gold L54 custom pistol."
	caliber = "9mm (special)"
	icon = 'modular/weapons/icons/pvp/world/l54_ammo.dmi'
	icon_state = "l54"
	max_rounds = 12
	w_class = SIZE_SMALL
	default_ammo = /datum/ammo/bullet/pistol/pvp_l54_gold
	gun_type = /obj/item/weapon/gun/pistol/pvp_l54_gold
	ammo_band_icon = "+l54_band"
	ammo_band_icon_empty = "+l54_band_e"
	ammo_band_color = AMMO_BAND_COLOR_HIGH_VELOCITY

/obj/item/weapon/gun/pistol/pvp_l54_gold
	name = "gold L54 custom service pistol (PvP)"
	desc = "A gold-alloy L54 with a compensated barrel and precision-tuned internals."
	icon = 'modular/weapons/icons/pvp/world/l54_gold.dmi'
	icon_state = "l54_custom"
	item_state = "l54_custom"
	lineart_gun_icon = "l54"
	fire_sound = 'sound/weapons/gun_vp78_v2.ogg'
	reload_sound = 'sound/weapons/gun_vp78_reload.ogg'
	unload_sound = 'sound/weapons/gun_vp78_unload.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/pvp_l54_gold
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/burstfire_assembly,
	)
	item_icons = list(
		WEAR_WAIST = 'modular/weapons/icons/pvp/onmob/belts_guns.dmi',
		WEAR_J_STORE = 'modular/weapons/icons/pvp/onmob/suit_pistols.dmi',
		WEAR_L_HAND = 'modular/weapons/icons/pvp/onmob/pistols_lefthand.dmi',
		WEAR_R_HAND = 'modular/weapons/icons/pvp/onmob/pistols_righthand.dmi',
	)
	item_state_slots = list(WEAR_WAIST = "m4a3", WEAR_J_STORE = "m4a3")

/obj/item/weapon/gun/pistol/pvp_l54_gold/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20, "rail_x" = 10, "rail_y" = 21, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/pvp_l54_gold/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_5
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_AUTO_EJECTOR
