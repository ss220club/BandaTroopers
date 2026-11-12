/datum/ammo/bullet/rifle/w_ek_17
	name = "7.6mm rifle bullet"

	damage = 35
	penetration = ARMOR_PENETRATION_TIER_1
	accurate_range = 14
	effective_range_max = 6
	max_range = 22
	accuracy = HIT_ACCURACY_TIER_3
	scatter = SCATTER_AMOUNT_TIER_10
	shell_speed = AMMO_SPEED_TIER_6
	damage_falloff = DAMAGE_FALLOFF_TIER_5

/datum/ammo/bullet/smg/a_m36
	name = "armor-piercing laserbolt"
	icon_state = "redtrac"
	damage = 30
	accurate_range = 5
	effective_range_max = 6
	penetration = ARMOR_PENETRATION_TIER_1
	shell_speed = AMMO_SPEED_TIER_4
	scatter = SCATTER_AMOUNT_TIER_3
	accuracy = HIT_ACCURACY_TIER_2
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_LASER
	hit_effect_color = "#ff0000"
	var/laser_stacks = 12


/datum/ammo/bullet/smg/a_m36/on_hit_mob(mob/target, obj/projectile/bullet)
	..()
	target.AddComponent(/datum/component/bonus_fire_stack, laser_stacks, world.time)

/obj/item/device/flashlight/lantern/alt
	name = "lantern"
	icon_state = "tactical_lantern"
	item_state = "tactical_lantern"
	desc = "An expensive looking lantern."
	light_range = 7 // luminosity when on
	light_color = "#71cfff"

/obj/item/device/encryptionkey/lasalle_bionational
	name = "\improper Lasalle Bionational encryption key"
	icon_state = "ce_key"
	channels = list(RADIO_CHANNEL_LASALLE_BIONATIONAL = TRUE)
	tracking_options = list("Corporate Liaison" = TRACKER_CL)


/obj/item/storage/pill_bottle/packet/kelo_oxy_mix
	name = "Kelotane/Oxycodone mix pill packet"
	desc = "This packet contains a Kelotane-Oxycodone (2:1) mix of pills. Heals burn damage, while also providing effective pain relief. Once you take them out, they don't go back in. Don't take more than 2 pills in a short period."
	pill_type_to_fill = /obj/item/reagent_container/pill/kelo_oxy_mix

/obj/item/attachable/reddot/small
	name = "S5-Micro dot sight"
	desc = "A lightweight, low-profile dot optic designed for rapid target acquisition with minimal weight penalty. Optimized for submachine guns and sidearms, it's ideal for close-quarters combat where speed and agility matter most."
	desc_lore = "Designated AN/PVQ-64(M), the Micro variant of the S5 collimator sight strips the platform down to essentials. With reduced bulk and weight, it's favored by scouts and boarding teams. Despite the mil-spec designation, it's little more than a civilian reflex sight rebranded with a price hike."
	icon = 'icons/obj/items/weapons/guns/attachments/rail.dmi'
	icon_state = "reddot_small"
	attach_icon = "reddot_small_a"
	slot = "rail"


/obj/item/attachable/reddot/small/New()
	..()
	accuracy_mod = HIT_ACCURACY_MULT_TIER_5
	accuracy_unwielded_mod = HIT_ACCURACY_MULT_TIER_2


/obj/item/attachable/lasersight/micro
	name = "micro laser module"
	desc = "A compact, high-precision laser sight engineered exclusively for the M10 Auto Pistol and M4A4 handgun. Offers exceptional accuracy gains by interfacing directly with the weapon's internal targeting systems."
	desc_lore = "An advanced derivative of the AN/PEQ-42 line, the '42M' variant was precision-tuned by Kessler Optics for use with the M10 Auto Pistol. Its microcontroller syncs with the pistol's fire-control unit for superior point-of-aim fidelity and scatter compensation. Rare, expensive, and typically reserved for elite units or covert applications."
	icon = 'icons/obj/items/weapons/guns/attachments/under.dmi'
	icon_state = "lasersight_micro"
	attach_icon = "lasersight_micro_a"
	slot = "under"
	pixel_shift_x = 17
	pixel_shift_y = 17


/obj/item/attachable/lasersight/micro/New()
	..()
	accuracy_mod = HIT_ACCURACY_MULT_TIER_2
	movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_5
	scatter_mod = -SCATTER_AMOUNT_TIER_10
	scatter_unwielded_mod = -SCATTER_AMOUNT_TIER_10
	accuracy_unwielded_mod = HIT_ACCURACY_MULT_TIER_2


/obj/item/attachable/bayonet/lb
	AUTOWIKI_SKIP(TRUE)

	name = "\improper SA120 L7-B bayonet"
	desc = "A modified SA120-pattern bayonet issued to various Lasalle Bionational security forces. It features a redesigned composite grip and a gold-tinted, high corrosion-resistant blade intended for use in extreme environments."
	icon_state = "lb_bayonet"
	item_state = "lb_bayonet"
	item_icons = list(
		WEAR_FACE = 'icons/mob/humans/onmob/mask.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_0.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_0.dmi'
	)
	attach_icon = "lb_bayonet_a"
	unacidable = TRUE


/obj/item/attachable/bayonet/antique
	AUTOWIKI_SKIP(TRUE)

	name = "\improper antique bayonet"
	desc = "An antique-style bayonet, has a long blade, wooden handle with brass fittings, reflecting historical craftsmanship."
	icon_state = "antique_bayonet"
	item_state = "antique_bayonet"
	attach_icon = "antique_bayonet_a"


/obj/item/attachable/bayonet/rmc_replica
	AUTOWIKI_SKIP(TRUE)

	name = "\improper L5 bayonet"
	desc = "The standard-issue bayonet of the RMC, it's dulled from heavy use."
	icon_state = "twe_bayonet"
	item_state = "twe_bayonet"
	attach_icon = "twe_bayonet_a"


/obj/item/attachable/bayonet/custom
	AUTOWIKI_SKIP(TRUE)

	name = "\improper M5 'Raven's Claw' tactical bayonet"
	desc = "A prototype bayonet-combat knife hybrid, engineered for close-quarters engagements and urban operations. Its rugged construction, quick-detach mechanism and deadly versatility make it a formidable tool."
	icon_state = "bayonet_custom"
	item_state = "bayonet_custom"
	attach_icon = "bayonet_custom_a"


/obj/item/attachable/bayonet/custom/red
	AUTOWIKI_SKIP(TRUE)

	desc = "A prototype bayonet-combat knife hybrid, engineered for close-quarters engagements and urban operations. Its rugged construction, quick-detach mechanism and deadly versatility make it a formidable tool. This version has been customized with a red grip and gold detailing, giving it a unique and distinctive appearance."
	icon_state = "bayonet_custom_red"
	item_state = "bayonet_custom_red"
	attach_icon = "bayonet_custom_red_a"


/obj/item/attachable/bayonet/custom/blue
	AUTOWIKI_SKIP(TRUE)

	desc = "A prototype bayonet-combat knife hybrid, engineered for close-quarters engagements and urban operations. Its rugged construction, quick-detach mechanism and deadly versatility make it a formidable tool. This version has been customized with a blue grip and gold detailing, giving it a unique and distinctive appearance."
	icon_state = "bayonet_custom_blue"
	item_state = "bayonet_custom_blue"
	attach_icon = "bayonet_custom_blue_a"


/obj/item/attachable/bayonet/custom/black
	AUTOWIKI_SKIP(TRUE)

	desc = "A prototype bayonet-combat knife hybrid, engineered for close-quarters engagements and urban operations. Its rugged construction, quick-detach mechanism and deadly versatility make it a formidable tool. This version has been customized with a black grip and gold detailing, giving it a unique and distinctive appearance."
	icon_state = "bayonet_custom_black"
	item_state = "bayonet_custom_black"
	attach_icon = "bayonet_custom_black_a"


/obj/item/attachable/bayonet/tanto
	AUTOWIKI_SKIP(TRUE)

	name = "\improper T9 tactical bayonet"
	desc = "Preferred by TWE colonial military forces in the Neroid Sector, the T9 is designed for urban combat with a durable tanto blade and quick-attach system, reflecting traditional Japanese blade influences. Occasionally seen in the hands of Colonial Liberation Front (CLF) forces, often stolen from TWE detachments and outposts across the sector."
	icon_state = "bayonet_tanto"
	item_state = "bayonet_tanto"
	attach_icon = "bayonet_tanto_a"


/obj/item/attachable/bayonet/tanto/blue
	AUTOWIKI_SKIP(TRUE)

	icon_state = "bayonet_tanto_alt"
	item_state = "bayonet_tanto_alt"
	attach_icon = "bayonet_tanto_alt_a"


/obj/item/attachable/extended_barrel/vented
	name = "AB-RVX extended compensator"
	desc = "A precision-engineered vented barrel extension used by various UA forces. Greatly improves accuracy, muzzle control, and projectile velocity, but reduces terminal damage due to pressure venting."
	desc_lore = "Designed by Armat Battlefield Systems under contract for the United Americas Colonial Marine Corps, the AB-RVX compensator is a general-purpose muzzle device intended primarily for rifles such as the M41A, though it has also been adapted for smaller-caliber weapons like the M39 submachine gun and the M10 auto pistol. Its extended ported design effectively reduces recoil and muzzle rise, enhancing shot stability and control during sustained fire. While the aggressive gas redirection slightly decreases impact force, the compensator improves overall accuracy. Due to its specialized application and manufacturing complexity."
	slot = "muzzle"
	icon = 'icons/obj/items/weapons/guns/attachments/barrel.dmi'
	icon_state = "ebarrel_vented"
	attach_icon = "ebarrel_vented_a"
	pixel_shift_y = 15
	hud_offset_mod = -3
	wield_delay_mod = WIELD_DELAY_FAST


/obj/item/attachable/extended_barrel/vented/Initialize(mapload, ...)
	. = ..()
	select_gamemode_skin(type)


/obj/item/attachable/extended_barrel/vented/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	var/new_attach_icon
	switch(SSmapping.configs[GROUND_MAP].camouflage_type)
		if("snow")
			attach_icon = new_attach_icon ? new_attach_icon : "s_" + attach_icon
			. = TRUE
		if("desert")
			attach_icon = new_attach_icon ? new_attach_icon : "d_" + attach_icon
			. = TRUE
		if("classic")
			attach_icon = new_attach_icon ? new_attach_icon : "c_" + attach_icon
			. = TRUE
		if("urban")
			attach_icon = new_attach_icon ? new_attach_icon : "u_" + attach_icon
			. = TRUE
	return .


/obj/item/attachable/extended_barrel/vented/New()
	..()
	accuracy_mod = HIT_ACCURACY_MULT_TIER_6
	damage_mod = -BULLET_DAMAGE_MULT_TIER_2
	recoil_mod = -RECOIL_AMOUNT_TIER_5

	damage_falloff_mod = -0.1
	accuracy_unwielded_mod = HIT_ACCURACY_MULT_TIER_6
	recoil_unwielded_mod = -RECOIL_AMOUNT_TIER_5
	velocity_mod = AMMO_SPEED_TIER_1


/obj/item/attachable/flashlight/under_barrel
	desc = "A flashlight, for rails, on guns. Can be toggled on and off. A better light source than standard M3 pattern armor lights. This one is set to be mounted to the underbarrel, press unique-action to switch its mount."
	slot = "under"
	pixel_shift_x = 15
	pixel_shift_y = 18


/obj/item/attachable/flashlight/under_barrel/unique_action(mob/user)
	to_chat(user, SPAN_NOTICE("You reconfigure [src] for a rail mount."))
	playsound(user, 'sound/machines/click.ogg', 25, 1)
	user.put_in_hands(new /obj/item/attachable/flashlight(user))
	qdel(src)


/obj/item/attachable/stock/rifle/w_ek_17
	name = "\improper W/EK 17 Carbine skeletal stock"
	desc = "A stock."
	slot = "stock"
	melee_mod = 10
	size_mod = 1
	icon_state = "w_ek_17"
	attach_icon = "w_ek_17_a"
	pixel_shift_x = 40
	pixel_shift_y = 10
	wield_delay_mod = WIELD_DELAY_FAST
	hud_offset_mod = 3


/obj/item/attachable/stock/rifle/w_ek_17/New()
	..()
	accuracy_mod = HIT_ACCURACY_MULT_TIER_5
	recoil_mod = -RECOIL_AMOUNT_TIER_3
	scatter_mod = -SCATTER_AMOUNT_TIER_7
	movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_4
	accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_3
	recoil_unwielded_mod = RECOIL_AMOUNT_TIER_4
	scatter_unwielded_mod = SCATTER_AMOUNT_TIER_8
	aim_speed_mod = CONFIG_GET(number/slowdown_med)


/obj/item/attachable/suppressor/sleek
	name = "compact suppressor"
	desc = "A lightweight, low-profile suppressor designed specifically for SMGs and sidearms. It dampens sound and muzzle flash while marginally improving stability and accuracy, though it slightly reduces projectile velocity and terminal damage."
	icon_state = "suppressor_sleek"
	slot = "muzzle"
	pixel_shift_y = 15
	attach_icon = "suppressor_sleek_a"
	hud_offset_mod = -3
	gun_traits = list(TRAIT_GUN_SILENCED)


/obj/item/attachable/suppressor/sleek/New()
	..()
	damage_falloff_mod = 0.1


/obj/item/attachable/stock/mod88
	AUTOWIKI_SKIP(TRUE)

	name = "\improper Mod 88 burst stock"
	desc = "Increases the fire rate and burst amount on the Mod 88. Some versions act as a holster for the weapon when un-attached. This is a test item and should not be used in normal gameplay (yet)."
	icon_state = "mod88_stock"
	attach_icon = "mod88_stock_a"
	wield_delay_mod = WIELD_DELAY_FAST
	flags_attach_features = NO_FLAGS
	hud_offset_mod = 4
	size_mod = 2
	melee_mod = 5


/obj/item/attachable/stock/mod88/New()
	..()
	accuracy_mod = HIT_ACCURACY_MULT_TIER_3
	recoil_mod = -RECOIL_AMOUNT_TIER_2
	scatter_mod = -SCATTER_AMOUNT_TIER_7
	burst_scatter_mod = -1
	burst_mod = BURST_AMOUNT_TIER_2
	delay_mod = -FIRE_DELAY_TIER_11
	movement_onehanded_acc_penalty_mod = -MOVEMENT_ACCURACY_PENALTY_MULT_TIER_4
	accuracy_unwielded_mod = HIT_ACCURACY_MULT_TIER_1
	recoil_unwielded_mod = -RECOIL_AMOUNT_TIER_5
	scatter_unwielded_mod = -SCATTER_AMOUNT_TIER_10

/obj/item/weapon/gun/pistol/b92fs/suppressed
	starting_attachment_types = list(/obj/item/attachable/suppressor/sleek)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor/sleek,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/burstfire_assembly,
	)
