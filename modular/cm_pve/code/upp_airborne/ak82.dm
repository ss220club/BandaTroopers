/obj/item/weapon/gun/rifle/ak82
	name = "\improper AK-82 pulse rifle"
	desc = "Pulse action 9.7x16mm caseless assault rifle, designed for UPP paratroopers. It combines the exceptional durability of AK-pattern rifles while maintaining the essential lightweight design by switching to a smaller caliber."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "ak82"
	item_state = "ak82"
	fire_sound = "gun_ag80"
	reload_sound = 'sound/weapons/handling/m41_reload.ogg'
	unload_sound = 'sound/weapons/handling/m41_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/ak82
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/sling,
		/obj/item/attachable/scope/upp,
		/obj/item/attachable/scope/mini/upp,
		/obj/item/attachable/reddot/upp,
		/obj/item/attachable/reflex/upp,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/attached_gun/grenade/type71/ag80,
		/obj/item/attachable/attached_gun/grenade/type71/ag80/preloaded,
		/obj/item/attachable/verticalgrip/upp,
		/obj/item/attachable/angledgrip/upp,
		/obj/item/attachable/lasersight/upp,
		/obj/item/attachable/flashlight,
	)
	starting_attachment_types = list(/obj/item/attachable/stock/rifle/collapsible/ak82)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	flags_equip_slot = SLOT_BACK
	start_automatic = TRUE

/obj/item/weapon/gun/rifle/ak82/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 18, "rail_x" = 15, "rail_y" = 22, "under_x" = 24, "under_y" = 15, "stock_x" = 23, "stock_y" = 13, "side_rail_x" = 18, "side_rail_y" = 18)

/obj/item/weapon/gun/rifle/ak82/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_4

/obj/item/weapon/gun/rifle/ak82/unloaded
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/ammo_magazine/rifle/ak82
	name = "\improper AK82 magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the AK82 rifle."
	caliber = "9.7x16mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/upp.dmi'
	icon_state = "ag80"
	ammo_band_icon = "+ag80_band"
	ammo_band_icon_empty = "+ag80_band_e"
	default_ammo = /datum/ammo/bullet/rifle/ag80
	max_rounds = 99
	gun_type = /obj/item/weapon/gun/rifle/ak82

/obj/item/ammo_magazine/rifle/ak82/ap
	name = "\improper AK82 AP magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the AK82 rifle. This one is loaded with steelcore armor piercing rounds."
	default_ammo = /datum/ammo/bullet/rifle/ag80/ap
	ammo_band_color = AMMO_BAND_COLOR_AP

/obj/item/ammo_magazine/rifle/ak82/heap
	name = "\improper AK82 HEAP magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the AK82 rifle. This one is loaded with high-explosive armor piercing rounds."
	default_ammo = /datum/ammo/bullet/rifle/ag80/heap
	ammo_band_color = AMMO_BAND_COLOR_HEAP

/obj/item/ammo_magazine/rifle/ak82/rubber
	name = "\improper AK82 rubber magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the AK82 rifle. This one is loaded with less-than lethal rubber rounds."
	default_ammo = /datum/ammo/bullet/rifle/ag80/rubber
	ammo_band_color = AMMO_BAND_COLOR_RUBBER

/obj/item/ammo_box/magazine/ak82
	name = "magazine box (AK82 x 10)"
	icon_state = "base_type64"
	flags_equip_slot = SLOT_BACK
	overlay_ammo_type = "_type71_reg"
	overlay_gun_type = "_ak82"
	overlay_content = "_type71_reg"
	num_of_magazines = 10
	magazine_type = /obj/item/ammo_magazine/rifle/ak82

/obj/item/ammo_box/magazine/ak82/empty
	empty = TRUE

/obj/item/ammo_box/magazine/ak82/rubber
	name = "magazine box (AK82 Rubber x 10)"
	overlay_ammo_type = "_type71_rubber"
	overlay_content = "_type71_reg"
	magazine_type = /obj/item/ammo_magazine/rifle/ak82/rubber

/obj/item/ammo_box/magazine/ak82/rubber/empty
	empty = TRUE

/obj/item/ammo_box/magazine/ak82/ap
	name = "magazine box (AK82 AP x 10)"
	overlay_ammo_type = "_type71_ap"
	overlay_content = "_type71_ap"
	magazine_type = /obj/item/ammo_magazine/rifle/ak82/ap

/obj/item/ammo_box/magazine/ak82/ap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/ak82/heap
	name = "magazine box (AK82 HEAP x 10)"
	overlay_ammo_type = "_type71_heap"
	overlay_content = "_type71_heap"
	magazine_type = /obj/item/ammo_magazine/rifle/ak82/heap

/obj/item/ammo_box/magazine/ak82/heap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/type71/large/ak82
	name = "magazine box (AK82 x 32)"
	magazine_type = /obj/item/ammo_magazine/rifle/ak82

/obj/item/ammo_box/magazine/type71/large/ak82/empty
	empty = TRUE

/obj/item/ammo_box/magazine/type71/large/ak82/ap
	name = "magazine box (AK82 AP x 32)"
	overlay_ammo_type = "_aplarge"
	overlay_content = "_aplarge"
	magazine_type = /obj/item/ammo_magazine/rifle/ak82/ap

/obj/item/ammo_box/magazine/type71/large/ak82/ap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/type71/large/ak82/heap
	name = "magazine box (AK82 HEAP x 32)"
	overlay_ammo_type = "_heaplarge"
	overlay_content = "_heaplarge"
	magazine_type = /obj/item/ammo_magazine/rifle/ak82/heap

/obj/item/ammo_box/magazine/type71/large/ak82/heap/empty
	empty = TRUE

/obj/item/attachable/stock/rifle/collapsible/ak82
	name = "\improper ak82 extendable stock"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	slot = "stock"
	melee_mod = 5
	size_mod = 1
	icon_state = "ak82_folding"
	attach_icon = "ak82_folding_a"
	pixel_shift_x = 39
	pixel_shift_y = 13
	hud_offset_mod = 3
	collapsible = TRUE
	stock_activated = FALSE
	wield_delay_mod = WIELD_DELAY_NONE
	collapse_delay = 0.5 SECONDS
	flags_attach_features = ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle

/obj/item/attachable/stock/rifle/collapsible/ak82/New()
	..()
	accuracy_mod = 0
	recoil_mod = 0
	scatter_mod = 0
	movement_onehanded_acc_penalty_mod = 0
	accuracy_unwielded_mod = 0
	recoil_unwielded_mod = 0
	scatter_unwielded_mod = 0
	aim_speed_mod = 0
	wield_delay_mod = WIELD_DELAY_NONE

/obj/item/attachable/stock/rifle/collapsible/ak82/apply_on_weapon(obj/item/weapon/gun/gun)
	if(stock_activated)
		accuracy_mod = HIT_ACCURACY_MULT_TIER_2
		recoil_mod = -RECOIL_AMOUNT_TIER_5
		scatter_mod = -SCATTER_AMOUNT_TIER_9
		movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_5
		accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_3
		recoil_unwielded_mod = RECOIL_AMOUNT_TIER_4
		scatter_unwielded_mod = SCATTER_AMOUNT_TIER_8
		aim_speed_mod = CONFIG_GET(number/slowdown_med)
		hud_offset_mod = 5
		icon_state = "ak82_folding_on"
		attach_icon = "ak82_folding_a_on"
		wield_delay_mod = WIELD_DELAY_VERY_FAST
	else
		accuracy_mod = 0
		recoil_mod = 0
		scatter_mod = 0
		movement_onehanded_acc_penalty_mod = 0
		accuracy_unwielded_mod = 0
		recoil_unwielded_mod = 0
		scatter_unwielded_mod = 0
		aim_speed_mod = 0
		hud_offset_mod = 3
		icon_state = "ak82_folding"
		attach_icon = "ak82_folding_a"
		wield_delay_mod = WIELD_DELAY_NONE

	gun.recalculate_attachment_bonuses()
	gun.update_overlays(src, "stock")

/obj/structure/gun_rack/ak82
	icon_state = "ak82"
	desc = "Some off-branded gun rack. Per SOF and UPPA regulations, weapons should be stored in secure safes and only given out when necessary. Of course, most (but not all!) units overlook this regulation, only storing their firearms in safes when inspection arrives."
	max_stored = 6
	initial_stored = 6
	allowed_type = /obj/item/weapon/gun/rifle/ak82
	populate_type = /obj/item/weapon/gun/rifle/ak82

/obj/structure/gun_rack/ak82/unloaded
	populate_type = /obj/item/weapon/gun/rifle/ak82/unloaded
