/obj/item/clothing/head/cmcap/royal_marine/iasf
	name = "\improper IASF beret"
	desc = "A distinctive crimson beret worn by the Imperial Armed Space Force."
	icon_state = "beret_iasf"
	item_state = "beret_iasf"
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi',
	)

/obj/item/clothing/head/cmcap/royal_marine/iasf/tl
	icon_state = "beret_iasf_tl"
	item_state = "beret_iasf_tl"

/obj/item/clothing/head/cmcap/royal_marine/iasf/commander_cap
	name = "IASF officer's service cap"
	desc = "A distinguished service cap worn by officers of the Imperial Armed Space Force. Featuring a crimson band, gold IASF emblem, and a black patent peak, it reflects the discipline and authority of the Empire’s airborne command."
	icon_state = "iasf_co_cap"
	item_state = "iasf_co_cap"

/obj/item/clothing/head/helmet/marine/veteran/royal_marine/medic
	name = "\improper L5A2 ballistic medic helmet"
	desc = "A High-cut ballistic helmet. Designed by Lindenthal-Ehrenfeld Militärindustrie it is intended to be used by Royal Marines Commando as part of the kestrel armour system. This one comes with an advanced medical HUD and a dark-green patch on the back, denoting that the wearer is a corpsman."
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons = list(WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi')
	icon_state = "rmc_helm_medic"
	item_state = "rmc_helm_medic"
	built_in_visors = list(new /obj/item/device/helmet_visor/medical/advanced)
	start_down_visor_type = /obj/item/device/helmet_visor/medical/advanced

/obj/item/clothing/head/helmet/marine/veteran/royal_marine/pilot
	name = "\improper PH-4 'Spitfire' flight helmet"
	desc = "Standard flight helmet used across the Three World Empire’s aerospace forces, from fighter pilots to atmospheric crews. This PH-4 variant is tailored for dropship operations in space, featuring reinforced plating, HUD optics, and encrypted comms. Essential for high-risk insertions, landings, and exfil missions. Nicknamed “Spitfire” for its reliability under fire."
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons = list(WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi')
	icon_state = "pilot_helm"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HIGH
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEALLHAIR

/obj/item/clothing/head/helmet/marine/veteran/royal_marine/pilot/alt
	icon_state = "pilot_helm_alt"

/obj/item/clothing/head/helmet/marine/veteran/royal_marine/generic
	name = "\improper L1 ballistic helmet"
	desc = "A versatile ballistic helmet designed by Alphatech for general use across various branches of the TWE military and affiliated organizations. Drawing some design inspiration from the USCM’s M10 Pattern Helmet, the L1 offers reliable protection against shrapnel and ballistic threats."
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons = list(WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi')
	icon_state = "generic_helm"
	item_state = "generic_helm"
	flags_marine_helmet = HELMET_GARB_OVERLAY

/obj/item/clothing/under/marine/veteran/iasf
	name = "IASF No.8 combat uniform"
	desc = "Standard issue No.8 Pattern BDU used by the Imperial Armed Space Force. Identical in cut and protection to the Royal Marine Commando variant, but issued in woodland camouflage. Lightweight Kevlar mesh offers limited protection against shrapnel and close-quarters threats."
	icon = 'icons/obj/items/clothing/uniforms/uniforms_by_faction/TWE.dmi'
	item_icons = list(WEAR_BODY = 'icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/TWE.dmi')
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT
	flags_atom = NO_NAME_OVERRIDE|NO_SNOW_TYPE
	flags_jumpsuit = UNIFORM_SLEEVE_ROLLABLE|UNIFORM_JACKET_REMOVABLE
	icon_state = "iasf_uniform"
	worn_state = "iasf_uniform"
	undershirt = TRUE

/obj/item/clothing/under/marine/veteran/iasf/service
	name = "IASF No.2 service uniform"
	desc = "A formal No.2 service uniform worn by IASF officers. Features the same upper torso cut as the No.8 BDU, but paired with pressed khaki trousers. Issued for inspections, ceremonial duties, or when deployed in an advisory role."
	flags_jumpsuit = UNIFORM_SLEEVE_ROLLABLE
	icon_state = "iasf_uniform_service"
	worn_state = "iasf_uniform_service"

/obj/item/device/radio/headset/almayer/marine/solardevils/rmc/iasf
	name = "IASF headset"
	desc = "A robust headset used by the TWE's Imperial Armed Space Force."
	icon_state = "rmc_headset"
	item_state = "rmc_headset"
	minimap_type = MINIMAP_FLAG_TWE
	frequency = IASF_FREQ
	has_hud = TRUE
	hud_type = list(MOB_HUD_FACTION_TWE, MOB_HUD_FACTION_IASF, MOB_HUD_FACTION_WY)

/obj/item/clothing/glasses/night/m42_hms/rmc
	hud_type = list(MOB_HUD_FACTION_TWE, MOB_HUD_FACTION_WY, MOB_HUD_FACTION_IASF)

/obj/item/clothing/glasses/night/m56_goggles/rmc
	hud_type = list(MOB_HUD_FACTION_TWE, MOB_HUD_FACTION_WY, MOB_HUD_FACTION_IASF)

/obj/item/device/overwatch_camera/twe
	hud_type = list(MOB_HUD_FACTION_TWE, MOB_HUD_FACTION_WY, MOB_HUD_FACTION_IASF)

/obj/item/storage/backpack/marine/satchel/rto/twe_net
	name = "\improper Wireless Set No.207 Radio Telephone Pack"
	icon = 'modular/iasf/icons/rto_obj.dmi'
	item_icons = list(WEAR_BACK = 'modular/iasf/icons/rto_back.dmi', WEAR_L_HAND = 'modular/iasf/icons/rto_left.dmi', WEAR_R_HAND = 'modular/iasf/icons/rto_right.dmi')
	icon_state = "rmc_rto_backpack"
	item_state = "rmc_rto_backpack"
	phone_icon = "phone"
	networks_receive = list(FACTION_TWE)
	networks_transmit = list(FACTION_TWE)
	actions_types = list(/datum/action/item_action/rto_pack/use_phone/twe)
	max_storage_space = 18
	worn_accessible = FALSE
	bag_open_time = 2 SECONDS

/obj/item/storage/backpack/marine/satchel/rto/twe_net/Initialize()
	. = ..()
	var/datum/component/phone/phone_component = GetComponent(/datum/component/phone)
	if(phone_component?.phone_handset)
		phone_component.phone_handset.icon = 'modular/iasf/icons/rto_phone.dmi'
		phone_component.phone_handset.icon_state = "rmc_rpb_phone"
		phone_component.phone_handset.item_state = "rmc_rpb_phone"
		phone_component.phone_handset.item_icons = list(WEAR_L_HAND = 'modular/iasf/icons/rto_left.dmi', WEAR_R_HAND = 'modular/iasf/icons/rto_right.dmi')

/obj/item/storage/backpack/marine/satchel/rto/proc/update_iasf_phone_worn_state()
	item_state = icon_state == "[initial(icon_state)]_ear" ? "[initial(item_state)]_ear" : initial(item_state)
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		wearer.update_inv_back()

/obj/item/storage/backpack/marine/satchel/rto/twe_net/phone_picked_up()
	. = ..()
	update_iasf_phone_worn_state()

/obj/item/storage/backpack/marine/satchel/rto/twe_net/phone_hung_up()
	. = ..()
	update_iasf_phone_worn_state()

/obj/item/storage/backpack/marine/satchel/rto/twe_net/phone_stopped_ringing()
	. = ..()
	update_iasf_phone_worn_state()

/datum/action/item_action/rto_pack/use_phone/twe/New(mob/living/user, obj/item/holder)
	..()
	name = "Use Phone"
	button.name = name
	button.overlays.Cut()
	var/image/phone_overlay = image('modular/iasf/icons/rto_phone.dmi', button, "rmc_rpb_phone")
	button.overlays += phone_overlay

/obj/item/storage/backpack/marine/satchel/rto/twe_net/small
	name = "\improper Wireless Set No.207 Small Radio Telephone Pack"
	max_storage_space = 14

/obj/item/storage/backpack/marine/satchel/rto/twe_net/iasf
	name = "\improper IASF Wireless Set No.207 Radio Telephone Pack"
	networks_receive = list(FACTION_IASF, FACTION_TWE)
	networks_transmit = list(FACTION_IASF, FACTION_TWE)

/obj/item/storage/backpack/marine/satchel/rto/pmc_net
	name = "\improper Wireless Set No.208 Radio Telephone Pack"
	icon = 'modular/iasf/icons/rto_obj.dmi'
	item_icons = list(WEAR_BACK = 'modular/iasf/icons/rto_back.dmi', WEAR_L_HAND = 'modular/iasf/icons/rto_left.dmi', WEAR_R_HAND = 'modular/iasf/icons/rto_right.dmi')
	icon_state = "pmc_rto_backpack"
	item_state = "pmc_rto_backpack"
	phone_icon = "phone"
	networks_receive = list(FACTION_PMC)
	networks_transmit = list(FACTION_PMC)
	actions_types = list(/datum/action/item_action/rto_pack/use_phone/pmc)
	max_storage_space = 24
	worn_accessible = FALSE
	bag_open_time = 2 SECONDS

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/Initialize()
	. = ..()
	var/datum/component/phone/phone_component = GetComponent(/datum/component/phone)
	if(phone_component?.phone_handset)
		phone_component.phone_handset.icon = 'modular/iasf/icons/rto_phone.dmi'
		phone_component.phone_handset.icon_state = "pmc_rpb_phone"
		phone_component.phone_handset.item_state = "pmc_rpb_phone"
		phone_component.phone_handset.item_icons = list(WEAR_L_HAND = 'modular/iasf/icons/rto_left.dmi', WEAR_R_HAND = 'modular/iasf/icons/rto_right.dmi')

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/phone_picked_up()
	. = ..()
	update_iasf_phone_worn_state()

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/phone_hung_up()
	. = ..()
	update_iasf_phone_worn_state()

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/phone_stopped_ringing()
	. = ..()
	update_iasf_phone_worn_state()

/datum/action/item_action/rto_pack/use_phone/pmc/New(mob/living/user, obj/item/holder)
	..()
	name = "Use Phone"
	button.name = name
	button.overlays.Cut()
	var/image/phone_overlay = image('modular/iasf/icons/rto_phone.dmi', button, "pmc_rpb_phone")
	button.overlays += phone_overlay

/obj/item/storage/backpack/marine/satchel/rto/pmc_net/small
	name = "\improper Wireless Set No.208 Small Radio Telephone Pack"
	max_storage_space = 18

/obj/structure/phone_base/pmc
	networks_receive = list(FACTION_PMC)
	networks_transmit = list(FACTION_PMC)

/obj/structure/phone_base/rotary/no_dnd/pmc
	networks_receive = list(FACTION_PMC)
	networks_transmit = list(FACTION_PMC)

/obj/item/storage/belt/marine/rmc/f90/fill_preset_inventory()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_magazine/rifle/rmc_f90(src)

/obj/item/storage/belt/gun/l905/l54/fill_preset_inventory()
	handle_item_insertion(new /obj/item/weapon/gun/pistol/l54())
	for(var/i in 1 to storage_slots - 1)
		new /obj/item/ammo_magazine/pistol/l54(src)

/datum/equipment_preset/proc/add_iasf_uniform(mob/living/carbon/human/new_human)
	var/obj/item/clothing/under/marine/veteran/iasf/uniform = new()
	var/random_uniform = rand(1,10)
	switch(random_uniform)
		if(1)
			uniform.roll_suit_jacket(new_human)
		if(2)
			uniform.roll_suit_sleeves(new_human)
	new_human.equip_to_slot_or_del(uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/patch/twe, WEAR_ACCESSORY)

/obj/item/attachable/stock/nsg23/l23
	name = "NSG L23 stock"
	icon = 'modular/iasf/icons/l23_stock.dmi'
	icon_state = "l23_stock"

/obj/item/weapon/gun/rifle/nsg23/l23
	name = "\improper NSG L23 pulse rifle"
	desc = "Pulse action 8.5x33mm caseless assault rifle of the Imperial Armed Space Forces. Comes with semi-auto, automatic and burst-fire firemodes. This one is painted in TWE's purple-blue camouflage."
	icon = 'modular/iasf/icons/l23_obj.dmi'
	item_icons = list(WEAR_L_HAND = 'modular/iasf/icons/l23_left.dmi', WEAR_R_HAND = 'modular/iasf/icons/l23_right.dmi', WEAR_BACK = 'modular/iasf/icons/l23_back.dmi', WEAR_J_STORE = 'modular/iasf/icons/l23_suit.dmi')
	icon_state = "l23"
	item_state = "l23"
	starting_attachment_types = list(/obj/item/attachable/stock/nsg23/l23)

	random_spawn_chance = 100
	random_spawn_under = list(
		/obj/item/attachable/attached_gun/grenade/nsg/preloaded,
		/obj/item/attachable/attached_gun/flamer/advanced,
		/obj/item/attachable/attached_gun/shotgun/af13,
	)
	random_spawn_rail = list(
		/obj/item/attachable/reflex,
		/obj/item/attachable/scope/mini/nsg23/rmc,
	)

/obj/item/weapon/gun/rifle/nsg23/l23/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_10)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_LMG)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	damage_falloff_mult = 0
	fa_max_scatter = SCATTER_AMOUNT_TIER_7

/obj/item/weapon/gun/rifle/nsg23/l23/iasf
	starting_attachment_types = list(
		/obj/item/attachable/scope/mini/nsg23/rmc,
		/obj/item/attachable/attached_gun/grenade/nsg/preloaded,
		/obj/item/attachable/stock/nsg23/l23,
	)

/obj/item/weapon/gun/rifle/rmc_f90/scope/ap
	current_mag = /obj/item/ammo_magazine/rifle/rmc_f90/marksman/ap

/obj/item/weapon/gun/smartgun/rmc/iasf
	current_mag = /obj/item/ammo_magazine/smartgun
	ammo = /obj/item/ammo_magazine/smartgun
	ammo_primary = /datum/ammo/bullet/rifle/heavy/tracer
	ammo_secondary = /datum/ammo/bullet/rifle/heavy/ap/tracer
	ammo_tertiary = /datum/ammo/bullet/rifle/heavy/impdet

/obj/item/ammo_box/magazine/vp70/extended
	name = "magazine box (Ext VP70 x 12)"
	overlay_ammo_type = "_ext"
	num_of_magazines = 12
	magazine_type = /obj/item/ammo_magazine/pistol/vp70/extended

/obj/item/ammo_box/magazine/vp70/extended/empty
	empty = TRUE

/obj/item/ammo_magazine/pistol/vp70/extended
	name = "\improper vp70 extended magazine (9x19mm)"
	icon_state = "vp70_mag_ex"
	max_rounds = 32
