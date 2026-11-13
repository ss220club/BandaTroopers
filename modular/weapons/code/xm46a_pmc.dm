// Corporate XM46A variant. The original M46C remains USCM equipment.
/obj/item/weapon/gun/rifle/m46c/pmc
	name = "\improper XM46A PMC pulse rifle"
	desc = "A black Weyland-Yutani XM46A with a corporate firing lock and a PN 30mm underslung grenade launcher. Accepts M41A MK1 and MK2 magazines."
	icon = 'modular/weapons/icons/wy/xm46a_black_inventory.dmi'
	icon_state = "xm46a"
	current_mag = /obj/item/ammo_magazine/rifle/ap
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade/mk1, /obj/item/attachable/stock/rifle/collapsible)
	item_icons = list(
		WEAR_L_HAND = 'modular/weapons/icons/wy/xm46a_black_lefthand.dmi',
		WEAR_R_HAND = 'modular/weapons/icons/wy/xm46a_black_righthand.dmi',
		WEAR_BACK = 'modular/weapons/icons/wy/xm46a_black_back.dmi',
		WEAR_J_STORE = 'modular/weapons/icons/wy/xm46a_black_suit_slot.dmi',
	)
	item_state_slots = list(WEAR_J_STORE = "m46c")
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_FAST
	accepted_ammo = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/incendiary,
		/obj/item/ammo_magazine/rifle/explosive,
		/obj/item/ammo_magazine/rifle/heap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/le,
		/obj/item/ammo_magazine/rifle/penetrating,
		/obj/item/ammo_magazine/rifle/toxin,
		/obj/item/ammo_magazine/rifle/rubber,
		/obj/item/ammo_magazine/rifle/tracer,
		/obj/item/ammo_magazine/rifle/m41aMK1,
		/obj/item/ammo_magazine/rifle/m41aMK1/rubber,
		/obj/item/ammo_magazine/rifle/m41aMK1/training,
		/obj/item/ammo_magazine/rifle/m41aMK1/ap,
		/obj/item/ammo_magazine/rifle/m41aMK1/heap,
		/obj/item/ammo_magazine/rifle/m41aMK1/incendiary,
		/obj/item/ammo_magazine/rifle/m41aMK1/toxin,
		/obj/item/ammo_magazine/rifle/m41aMK1/penetrating,
		/obj/item/ammo_magazine/rifle/m41aMK1/recon,
		/obj/item/ammo_magazine/rifle/m41aMK1/tracer,
	)

/obj/item/weapon/gun/rifle/m46c/pmc/set_gun_config_values()
	set_fire_delay(FIRE_DELAY_TIER_LMG)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	set_burst_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4 + 2*HIT_ACCURACY_MULT_TIER_1
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_5
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_falloff_mult = 0
