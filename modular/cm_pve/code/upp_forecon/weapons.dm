
/datum/ammo/bullet/pistol/upp/ap
	name = "armor-piercing 9x18 bullet"

	damage = 25
	accuracy = HIT_ACCURACY_TIER_2
	penetration= ARMOR_PENETRATION_TIER_3

/datum/ammo/bullet/pistol/upp/ap/penetrating
	name = "wall-penetrating 9x18 bullet"
	shrapnel_chance = 0

	damage = 30
	penetration = ARMOR_PENETRATION_TIER_10

/datum/ammo/bullet/pistol/upp/ap/penetrating/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating)
	))

/datum/ammo/bullet/pistol/upp/ap/toxin
	name = "toxic 9x18 bullet"
	var/acid_per_hit = 10
	var/organic_damage_mult = 3

/datum/ammo/bullet/pistol/upp/ap/toxin/on_hit_mob(mob/M, obj/projectile/P)
	. = ..()
	M.AddComponent(/datum/component/status_effect/toxic_buildup, acid_per_hit)

/datum/ammo/bullet/pistol/upp/ap/toxin/on_hit_turf(turf/T, obj/projectile/P)
	. = ..()
	if(T.turf_flags & TURF_ORGANIC)
		P.damage *= organic_damage_mult

/datum/ammo/bullet/pistol/upp/ap/toxin/on_hit_obj(obj/O, obj/projectile/P)
	. = ..()
	if(O.flags_obj & OBJ_ORGANIC)
		P.damage *= organic_damage_mult

/datum/ammo/bullet/revolver/upp/shrapnel
	name = "shrapnel shot"
	headshot_state = HEADSHOT_OVERLAY_HEAVY
	debilitate = list(0,0,0,0,0,0,0,0)
	icon_state = "shrapnelshot"
	handful_state = "shrapnel"
	bonus_projectiles_type = /datum/ammo/bullet/revolver/upp/shrapnel_bits

	max_range = 6
	effective_range_max = 0
	damage = 50
	damage_falloff = DAMAGE_FALLOFF_TIER_7
	penetration = -ARMOR_PENETRATION_TIER_1
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_3
	shrapnel_chance = 100
	shrapnel_type = /obj/item/shard/shrapnel/upp

/datum/ammo/bullet/revolver/upp/shrapnel/on_hit_mob(mob/M, obj/projectile/P)
	pushback(M, P, 1)

/obj/item/storage/box/packet/high_explosive/upp/canister
	name = "\improper VShG-80 assault grenade packet"
	desc = "It contains six VShG-80 airburst grenades."
	content_type = /obj/item/explosive/grenade/high_explosive/airburst/upp

/obj/item/ammo_box/magazine/np92/ap
	name = "magazine box (NP92 AP x 16)"
	overlay_ammo_type = "_type71_ap"
	overlay_content = "_type71_ap"
	magazine_type = /obj/item/ammo_magazine/pistol/np92/ap

/obj/item/ammo_box/magazine/np92/ap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/zhnk/shrapnel
	name = "speed loaders box (ZhNK-72 shrap-shot x 12)"
	overlay_ammo_type = "_type73_impact"
	overlay_content = "_zhnk72_shrap"
	magazine_type = /obj/item/ammo_magazine/revolver/upp/shrapnel

/obj/item/ammo_box/magazine/zhnk/shrapnel/empty

/obj/item/attachable/pkpbarrel/para
	name = "QYJ-72 Para Barrel"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	icon = 'icons/obj/items/weapons/guns/attachments/barrel.dmi'
	icon_state = "uppmg_para_barrel"
	attach_icon = "uppmg_para_barrel"
	slot = "muzzle"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0
	size_mod = 0

/obj/item/attachable/stock/pkpstock/para
	name = "QYJ-72 Para Stock"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	icon = 'icons/obj/items/weapons/guns/attachments/stock.dmi'
	icon_state = "uppmg_para_stock"
	attach_icon = "uppmg_para_stock"
	slot = "stock"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 20
	size_mod = 0

/obj/item/attachable/mg82barrel
	name = "MG82 Barrel"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	icon = 'icons/obj/items/weapons/guns/attachments/barrel.dmi'
	icon_state = "mg82_barrel"
	attach_icon = "mg82_barrel"
	slot = "special"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 0

/obj/item/attachable/stock/mg82
	name = "MG82 Stock"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	icon = 'icons/obj/items/weapons/guns/attachments/stock.dmi'
	icon_state = "mg82_stock"
	attach_icon = "mg82_stock"
	slot = "stock"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 25
	size_mod = 0

/obj/item/attachable/stock/mg82/New()
	..()

/obj/item/attachable/bipod/integral/mg82
	name = "MG82 bipod"
	desc = "An integral bipod for the MG82 Machine Gun."
	icon_state = "bipod"
	attach_icon = "uppmg_bipod_a"

/obj/item/attachable/bipod/integral/mg82/New()
	..()

	delay_mod = 0
	wield_delay_mod = WIELD_DELAY_FAST
	accuracy_mod = -HIT_ACCURACY_MULT_TIER_5
	scatter_mod = SCATTER_AMOUNT_TIER_9

/obj/item/weapon/gun/pkp/iff/para
	name = "\improper QYJ-72-IM General Purpose Machine Gun"
	desc = "The QYJ-72-IM is an experimental variant of common UPP GPMG featuring IFF capabilities which were developed by reverse-engineering USCM smartweapons. Aside from that, it has also had some internal parts stripped down to make it easier to deploy with recon units, sacrficing some performance in the process. It's still quite heavy and will overheat quickly, but the platform is able to lay down range unprecedented amounts of lead. \n<b>Alt-click it to open the feed cover and allow for reloading.</b>"
	actions_types = list(/datum/action/item_action/toggle_iff_pkp)
	requires_harness = FALSE

/obj/item/weapon/gun/pkp/iff/para/handle_starting_attachment()
	var/obj/item/attachable/B = new /obj/item/attachable/pkpbarrel/para(src)
	B.flags_attach_features &= ~ATTACH_REMOVABLE
	B.Attach(src)
	update_attachable(B.slot)

	var/obj/item/attachable/S = new /obj/item/attachable/stock/pkpstock/para(src)
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachable(S.slot)

	var/obj/item/attachable/bipod = new /obj/item/attachable/bipod/integral/pkp(src)
	bipod.flags_attach_features &= ~ATTACH_REMOVABLE
	bipod.Attach(src)
	update_attachable(bipod.slot)

/obj/item/weapon/gun/pkp/iff/para/set_gun_config_values()
	..()
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	fa_max_scatter = SCATTER_AMOUNT_TIER_2

/obj/item/weapon/gun/rifle/mg82
	name = "\improper MG82 pulse LMG"
	desc = "Pulse action 9.7x16mm caseless light machinegun of the UPPAC Naval Infantry, nicknamed 'Bianchi'. With addition of AG80 pulse rifle to the armed collective arsenal as the lighter, high-capacity carbine to the standard issue Type 71 rifle, the need for the AG80's caliber-shared machinegun has appeared as well. The design also refers to the AG-80 pulse rifle as basis. Firerate is significantly higher in comparison to the QYJ-72, but this makes the gun very hard to control during automatic fire without using bipods. Magazines for the LMG were also optimised for carriage in standard magazine pouches, with the cost of magazine size itself being downed to the 150 rounds."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "mg82"
	item_state = "mg82"
	mouse_pointer = 'icons/effects/mouse_pointer/lmg_mouse.dmi'
	fire_sound = "gun_mg82"
	reload_sound = 'sound/weapons/handling/hpr_reload.ogg'
	unload_sound = 'sound/weapons/handling/hpr_unload.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/mg82
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/sling,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/pve,
		/obj/item/attachable/scope/upp,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/mini/upp,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot/upp,
		/obj/item/attachable/reflex,
		/obj/item/attachable/reflex/upp,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lasersight/upp,
		/obj/item/attachable/flashlight,
		)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_category = GUN_CATEGORY_HEAVY
	starting_attachment_types = list(/obj/item/attachable/mg82barrel, /obj/item/attachable/stock/mg82, /obj/item/attachable/bipod/integral/mg82)
	start_automatic = TRUE

/obj/item/weapon/gun/rifle/mg82/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 36, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 35, "under_y" = 16, "stock_x" = 13, "stock_y" = 16, "side_rail_x" = 23, "side_rail_y" = 18, "special_x" = 34, "special_y" = 18, "sling_x" = 12, "sling_y" = 22)

/obj/item/weapon/gun/rifle/mg82/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_LMG)
	fa_max_scatter = SCATTER_AMOUNT_TIER_1
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_3
	aim_slowdown = SLOWDOWN_ADS_LMG
	wield_delay = WIELD_DELAY_SLOW

/obj/item/weapon/gun/rifle/mg82/unloaded
	current_mag = null
	flags_gun_features = /obj/item/weapon/gun/rifle/mg82::flags_gun_features | GUN_TRIGGER_SAFETY

/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon
	name = "\improper OG-74 Grenade Launcher"
	desc = "A lightweight, pump-action, magazine-fed grenade launcher, with the barrel below the magazine. First introduced as police enforcement weapon, it found it's way into hands of Armed Collective. Mostly seen used by the recon and NBC troops."
	icon_state = "gm94"
	item_state = "gm94"
	internal_slots = 4
	is_lobbing = TRUE
	actions_types = list()
	flags_equip_slot = SLOT_SUIT_STORE|SLOT_BACK
	aim_slowdown = SLOWDOWN_ADS_RIFLE
	wield_delay = WIELD_DELAY_NORMAL
	var/cocked = TRUE

/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_1 * 1.5)

/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/able_to_fire(mob/living/user)
	. = ..()

	if(!.)
		return FALSE

	if(!cocked)
		to_chat(user, SPAN_WARNING("\The [src] must be cocked! <b>(use unique-action)</b>"))
		return FALSE

	return TRUE

/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/fire_grenade(atom/target, mob/user)
	. = ..()

	cocked = FALSE

/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/unique_action(mob/user)
	. = ..()

	if(cocked)
		to_chat(user, SPAN_WARNING("[src] is already cocked."))
		return

	cocked = TRUE
	to_chat(user, SPAN_NOTICE("You close \the [src]'s breech, cocking it!"))
	playsound(src, "shotgunpump", 25, 1)

/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/stored
	preload = null
	flags_gun_features = /obj/item/weapon/gun/launcher/grenade/m92/upp::flags_gun_features | GUN_TRIGGER_SAFETY

/obj/item/ammo_magazine/pistol/np92
	ammo_band_icon = "+np92mag_band"
	ammo_band_icon_empty = "+np92mag_band_e"

/obj/item/ammo_magazine/pistol/np92/suppressed
	ammo_band_icon = ""
	ammo_band_icon_empty = ""

/obj/item/ammo_magazine/pistol/np92/ap
	name = "\improper NP92 AP magazine (9x18mm Makarov)"
	default_ammo = /datum/ammo/bullet/pistol/upp/ap
	ammo_band_color = AMMO_BAND_COLOR_AP

/obj/item/ammo_magazine/pistol/np92/penetrating
	name = "\improper NP92 wall-penetrating magazine (9x18mm Makarov)"
	default_ammo = /datum/ammo/bullet/pistol/upp/ap/penetrating
	ammo_band_color = AMMO_BAND_COLOR_PENETRATING

/obj/item/ammo_magazine/pistol/np92/toxin
	name = "\improper NP92 toxin magazine (9x18mm Makarov)"
	default_ammo = /datum/ammo/bullet/pistol/upp/ap/toxin
	ammo_band_color = AMMO_BAND_COLOR_TOXIN

/obj/item/ammo_magazine/pistol/np92/suppressed/tranq
	name = "\improper NPZ92 tranq magazine (9x18mm Makarov)"
	default_ammo = /datum/ammo/bullet/pistol/tranq
	icon_state = "npz92tranqmag"

/obj/item/ammo_magazine/rifle/mg82
	name = "\improper MG82 drum magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the MG82 machinegun."
	caliber = "9.7x16mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/upp.dmi'
	icon_state = "mg82"
	ammo_band_icon = "+mg82_band"
	ammo_band_icon_empty = "+mg82_band_e"
	default_ammo = /datum/ammo/bullet/rifle/ag80
	max_rounds = 150
	gun_type = /obj/item/weapon/gun/rifle/mg82
	flags_magazine = AMMUNITION_REFILLABLE|AMMUNITION_SLAP_TRANSFER
	reload_delay = 5

/obj/item/ammo_magazine/rifle/mg82/ap
	name = "\improper MG82 AP drum magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the MG82 machinegun. This one is loaded with steelcore armor piercing rounds."
	default_ammo = /datum/ammo/bullet/rifle/ag80/ap
	ammo_band_color = AMMO_BAND_COLOR_AP

/obj/item/ammo_magazine/rifle/mg82/heap
	name = "\improper MG82 HEAP drum magazine (9.7x16mm)"
	desc = "A 9.7x16mm high-capacity magazine for the MG82 machinegun. This one is loaded with high-explosive armor piercing rounds."
	default_ammo = /datum/ammo/bullet/rifle/ag80/heap
	ammo_band_color = AMMO_BAND_COLOR_HEAP

/obj/item/storage/box/guncase/heavy/mg82
	name = "\improper MG82 LMG case"
	desc = "A case for storing a MG82 light machinegun."
	icon_state = "uppmg82case"
	storage_slots = 9
	can_hold = list(/obj/item/weapon/gun/rifle/mg82, /obj/item/ammo_magazine/rifle/mg82)
	max_w_class = SIZE_HUGE

/obj/item/storage/box/guncase/heavy/mg82/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/mg82/unloaded(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)
	new /obj/item/ammo_magazine/rifle/mg82(src)

/obj/item/storage/box/guncase/heavy/mg82/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(src.icon, "uppbigcase_lid_open")
	else
		overlays += image(src.icon, "uppmg82case_lid")
		return
	if(locate(/obj/item/weapon/gun/rifle/mg82) in src.contents)
		overlays += image(src.icon, "+mg82")

/obj/item/storage/box/guncase/heavy/m92_upp_forecon
	name = "\improper OG-74 grenade launcher case"
	desc = "A case for storing an OG-74 grenade launcher."
	icon_state = "uppgm94case"
	storage_slots = 3
	can_hold = list(/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon, /obj/item/storage/pouch/explosive, /obj/item/storage/large_holster/m39/upp_m92_forecon, /obj/item/storage/box/packet/high_explosive/upp)
	max_w_class = SIZE_HUGE

/obj/item/storage/box/guncase/heavy/m92_upp_forecon/fill_preset_inventory()
	new /obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/stored(src)
	new /obj/item/storage/large_holster/m39/upp_m92_forecon(src)
	new /obj/item/storage/pouch/explosive(src)

/obj/item/storage/box/guncase/heavy/m92_upp_forecon/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(icon, "uppbigcase_lid_open")
	else
		overlays += image(icon, "uppgm94case_lid")
		return
	if(locate(/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon) in contents)
		overlays += image(icon, "+gm94")
	var/obj/item/storage/pouch/explosive/nade_pouch = locate(/obj/item/storage/pouch/explosive) in contents
	if(nade_pouch)
		if(!nade_pouch.contents.len)
			overlays += image(icon, "+nade_pouch")
		else
			overlays += image(icon, "+nade_pouch_full")

/obj/item/storage/box/guncase/heavy/m92_upp_forecon/preloaded
	storage_slots = 6

/obj/item/storage/box/guncase/heavy/m92_upp_forecon/preloaded/fill_preset_inventory()
	new /obj/item/weapon/gun/launcher/grenade/m92/upp/forecon/stored(src)
	new /obj/item/storage/large_holster/m39/upp_m92_forecon(src)
	new /obj/item/storage/pouch/explosive/upp/impact(src)
	new /obj/item/storage/box/packet/high_explosive/upp/impact(src)
	new /obj/item/storage/box/packet/high_explosive/upp/ap(src)
	new /obj/item/storage/box/packet/high_explosive/upp/incend(src)

/obj/item/storage/large_holster/m39/upp_m92_forecon
	name = "\improper Type 44 GL holster rig"
	desc = "A refitted Type 41 SMG holster, able to carry OG-74 grenade launcher. Uncommonly issued to the special forces of Armed Collective."
	icon_state = "upp_smg_holster"
	flags_equip_slot = SLOT_WAIST|SLOT_SUIT_STORE
	max_w_class = 5
	can_hold = list(
		/obj/item/weapon/gun/launcher/grenade/m92/upp/forecon,
	)

/obj/structure/largecrate/supply/ammo/sentry/upp
	name = "\improper UPPAC 32-H ammunition drum case (x6)"
	desc = "An ammunition case containing six UPPAC 32-H sentry ammunition drums."
	supplies = list(/obj/item/ammo_magazine/sentry/upp = 6)

/obj/item/weapon/gun/pistol/np92/suppressed/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 20, "rail_x" = 13, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18, "side_rail_x" = 15, "side_rail_y" = 15)

/obj/item/weapon/gun/pistol/np92/suppressed/tranq
	current_mag = /obj/item/ammo_magazine/pistol/np92/suppressed/tranq

/obj/item/weapon/gun/pistol/np92/suppressed/unloaded
	current_mag = null

/obj/item/attachable/scope/mini/upp/type73
	name = "1P86 1.5x Optic"
	zoom_offset = 4
	dynamic_aim_slowdown = SLOWDOWN_ADS_NONE

/obj/item/weapon/gun/rifle/type71/carbine
	name = "\improper Type-71S pulse carbine"
	desc = "A modified variant of the standard issue Type-71 Pulse Rifle, featuring a shortened barrel and improved fire-rate. Developed at the end of the 'ST' program headed by Vietnam, with assistance provided by material engineers in China, the Type-71S was designed for use by vehicle crews, pilots, territorial-guard, police units and rear-line personnel. While featuring superior handling and its famous blistering fire-rate, the Type-71S has seen little adoption within professional elements thanks to inferior at-range accuracy."
	icon_state = "type71c"
	item_state = "type71c"
	fire_sound = 'sound/weapons/gun_type71.ogg'
	wield_delay = WIELD_DELAY_VERY_FAST
	inherent_traits = null
	bonus_overlay_x = 0
	bonus_overlay_y = 0
	force = 20
	random_spawn_chance = 50
	starting_attachment_types = null
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
		/obj/item/attachable/verticalgrip/upp,
		/obj/item/attachable/angledgrip/upp,
		/obj/item/attachable/lasersight/upp,
		/obj/item/attachable/flashlight,
	)

/obj/item/weapon/gun/rifle/type71/carbine/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17, "rail_x" = 15, "rail_y" = 22, "under_x" = 25, "under_y" = 13, "stock_x" = 15, "stock_y" = 13, "side_rail_x" = 21, "side_rail_y" = 18, "sling_x" = 13, "sling_y" = 21)

/obj/item/weapon/gun/rifle/type71/carbine/recon
	starting_attachment_types = list(/obj/item/attachable/verticalgrip/upp, /obj/item/attachable/lasersight/upp)

/obj/item/weapon/gun/rifle/type71/carbine/recon/unloaded
	current_mag = null
	flags_gun_features = /obj/item/weapon/gun/rifle/type71/carbine/recon::flags_gun_features | GUN_TRIGGER_SAFETY

/obj/item/weapon/gun/rifle/type71/carbine/unloaded
	current_mag = null
	flags_gun_features = /obj/item/weapon/gun/rifle/type71/carbine::flags_gun_features | GUN_TRIGGER_SAFETY
/obj/structure/gun_rack/type71/carbine/unloaded
	populate_type = /obj/item/weapon/gun/rifle/type71/carbine/unloaded

/obj/structure/gun_rack/type71/carbine/recon
	populate_type = /obj/item/weapon/gun/rifle/type71/carbine/recon/unloaded

/obj/structure/gun_rack/type71/carbine_commando
	name = "Type 71 commando rifle rack"
	icon_state = "type73"
	allowed_type = /obj/item/weapon/gun/rifle/type71/carbine/commando
	populate_type = /obj/item/weapon/gun/rifle/type71/carbine/commando
/obj/structure/gun_rack/type71/carbine_commando/unloaded
	populate_type = /obj/item/weapon/gun/rifle/type71/carbine/commando/unloaded

/obj/item/ammo_box/magazine/np92/tranq
	name = "magazine box (NP92 Tranq x 16)"
	overlay_ammo_type = "_type71_rubber"
	overlay_content = "_type71_ap"
	magazine_type = /obj/item/ammo_magazine/pistol/np92/suppressed/tranq

/obj/item/ammo_box/magazine/np92/tranq/empty
	empty = TRUE

/datum/ammo/bullet/revolver/upp/shrapnel_bits
	name = "small shrapnel"
	icon_state = "shrapnelshot_bit"

	max_range = 6
	effective_range_max = 0
	damage = 40
	penetration = -ARMOR_PENETRATION_TIER_2
	scatter = SCATTER_AMOUNT_TIER_1
	bonus_projectiles_amount = 0
	shrapnel_type = /obj/item/shard/shrapnel/upp/bits

/obj/item/attachable/sling/New()
	..()
	accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_1
	recoil_unwielded_mod = -RECOIL_AMOUNT_TIER_5
	scatter_unwielded_mod = -SCATTER_AMOUNT_TIER_10

/obj/item/attachable/bipod/integral/New()
	..()
	delay_mod = 0
	wield_delay_mod = WIELD_DELAY_FAST
	accuracy_mod = -HIT_ACCURACY_MULT_TIER_5
	scatter_mod = SCATTER_AMOUNT_TIER_9
	fa_scatter_peak_mod = 0

/obj/item/attachable/bipod/integral/pkp/New()
	..()
	delay_mod = 0
	wield_delay_mod = WIELD_DELAY_FAST
	accuracy_mod = -HIT_ACCURACY_MULT_TIER_5
	scatter_mod = SCATTER_AMOUNT_TIER_9
	fa_scatter_peak_mod = 0

/obj/item/weapon/gun/launcher/grenade/m92/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18, "rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14, "sling_x" = 12, "sling_y" = 22)

/obj/item/weapon/gun/launcher/grenade/m92/upp
	starting_attachment_types = list(/obj/item/attachable/verticalgrip/upp)

/obj/item/weapon/gun/launcher/grenade/m92/upp/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18, "rail_x" = 14, "rail_y" = 22, "under_x" = 24, "under_y" = 14, "stock_x" = 19, "stock_y" = 14, "sling_x" = 12, "sling_y" = 22)

/obj/item/weapon/gun/launcher/grenade/m92/upp/handle_starting_attachment()
	return ..()

/obj/item/weapon/gun/launcher/grenade/m92/upp/stored
	starting_attachment_types = list(/obj/item/attachable/verticalgrip/upp)

/datum/ammo/bullet/rifle/upp/incendiary
	name = "Incendiary 10x27 bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC
	damage = 37
	shell_speed = AMMO_SPEED_TIER_4
	accuracy = -HIT_ACCURACY_TIER_2
	damage_falloff = DAMAGE_FALLOFF_TIER_9

/datum/ammo/bullet/rifle/upp/incendiary/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_incendiary)
	))

/datum/ammo/bullet/rifle/upp/spec
	name = "high velocity 10x27 bullet"
	shrapnel_chance = 0
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC
	accurate_range_min = 4
	effective_range_max = 24
	max_range = 32

	damage = 60
	scatter = -SCATTER_AMOUNT_TIER_8
	penetration= ARMOR_PENETRATION_TIER_6
	shell_speed = AMMO_SPEED_TIER_7

/datum/ammo/bullet/rifle/upp/spec/incendiary
	name = "high velocity incendiary 10x27 bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

	damage = 45
	penetration= ARMOR_PENETRATION_TIER_4

/datum/ammo/bullet/rifle/upp/spec/incendiary/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_incendiary, /datum/reagent/napalm/high_damage)
	))

/datum/ammo/bullet/rifle/upp/spec/explosive
	name = "high velocity explosive 10x27 bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

	damage = 45
	accuracy = HIT_ACCURACY_TIER_2
	penetration = ARMOR_PENETRATION_TIER_4
	damage_armor_punch = 5

/datum/ammo/bullet/rifle/upp/spec/explosive/on_hit_mob(mob/M, obj/projectile/P)
	knockback(M, P, 6)
	var/slow_duration = 7
	var/mob/living/L = M
	if(isxeno(M))
		var/mob/living/carbon/xenomorph/target = M
		if(target.mob_size >= MOB_SIZE_BIG)
			slow_duration = 2
		M.adjust_effect(slow_duration, SUPERSLOW)
		L.apply_armoured_damage(damage, ARMOR_BULLET, BRUTE, null, penetration)
	else
		M.adjust_effect(slow_duration, SUPERSLOW)
		burst(get_turf(M),P,damage_type, 2 , 2)
		burst(get_turf(M),P,damage_type, 1 , 2 , 0)

/datum/ammo/bullet/rifle/upp/spec/explosive/on_near_target(turf/T, obj/projectile/P)
	burst(T,P,damage_type, 2 , 4)
	burst(T,P,damage_type, 1 , 2, 0)
	return 1

/datum/ammo/bullet/rifle/upp/spec/du
	name = "high velocity depleted uranium 10x27 bullet"

	damage = 45
	penetration = ARMOR_PENETRATION_TIER_8
	accuracy = HIT_ACCURACY_TIER_4
	scatter = -SCATTER_AMOUNT_TIER_8

/datum/ammo/bullet/rifle/upp/spec/du/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating)
	))

/datum/ammo/bullet/rifle/upp/spec/du/on_hit_mob(mob/target, obj/projectile/fired_proj)
	target.AddComponent(/datum/component/status_effect/toxic_buildup, toxic_buildup = 10, toxic_buildup_dissipation = 0.3, max_buildup = 50)
	knockback(target, fired_proj, 8)
	if(target.mob_size >= MOB_SIZE_BIG)
		var/mob/living/L = target
		L.apply_armoured_damage(damage*1.25, ARMOR_BULLET, BRUTE, null, penetration)

/obj/item/attachable/stock/spp
	name = "SPP-48M Stock"
	desc = "This isn't supposed to be separated from the gun, how'd this happen?"
	icon = 'icons/obj/items/weapons/guns/attachments/stock.dmi'
	icon_state = "spp_stock"
	attach_icon = "spp_stock"
	slot = "stock"
	wield_delay_mod = WIELD_DELAY_NONE
	flags_attach_features = NO_FLAGS
	melee_mod = 25
	size_mod = 0

/obj/item/attachable/stock/spp/New()
	..()

/obj/item/weapon/gun/rifle/spp
	name = "\improper SPP-48M Marksman Rifle"
	desc = "Produced by the Serbian 'Primary Manufacturing Union' as part of a collective arms development program in 2168, the SPP-48M, 'Ramonda' as it was nicknamed, is a 10x27mm caseless pulse-action designated marksman rifle, in a bullpup configuration, developed for use by the UPP Army and Space Operating Forces. The 'Ramonda' proves exceptionally popular with frontline infantry units and internal garrisons alike, thanks to its compact design and powerful calibre, allowing it to perform in both wide open colonial expanses and the interior of UPP habitations in equal measure."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "spp"
	item_state = "spp"
	mouse_pointer = 'icons/effects/mouse_pointer/sniper_mouse.dmi'

	fire_sound = 'sound/weapons/gun_mg.ogg'
	reload_sound = 'sound/weapons/handling/l42_reload.ogg'
	unload_sound = 'sound/weapons/handling/l42_unload.ogg'

	current_mag = /obj/item/ammo_magazine/rifle/spp
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

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	wield_delay = WIELD_DELAY_VERY_FAST
	aim_slowdown = -SLOWDOWN_ADS_VERSATILE + -SLOWDOWN_ADS_QUICK_MINUS

/obj/item/weapon/gun/rifle/spp/handle_starting_attachment()
	..()
	var/obj/item/attachable/attachie = new /obj/item/attachable/stock/spp(src)
	attachie.flags_attach_features &= ~ATTACH_REMOVABLE
	attachie.Attach(src)
	update_attachable(attachie.slot)

	var/obj/item/attachable/scope/variable_zoom/integrated/sppsight = new(src)
	sppsight.flags_attach_features &= ~ATTACH_REMOVABLE
	sppsight.hidden = TRUE
	sppsight.Attach(src)
	update_attachable(sppsight.slot)

/obj/item/weapon/gun/rifle/spp/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 10, "rail_y" = 23, "under_x" = 20, "under_y" = 12, "stock_x" = 12, "stock_y" = 14, "side_rail_x" = 19, "side_rail_y" = 17, "sling_x" = 16, "sling_y" = 19)

/obj/item/weapon/gun/rifle/spp/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_5)
	set_burst_amount(0)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	recoil = RECOIL_AMOUNT_TIER_5
	damage_falloff_mult = 0
	scatter = SCATTER_AMOUNT_TIER_9

/obj/item/weapon/gun/rifle/spp/unloaded
	current_mag = null
	flags_gun_features = /obj/item/weapon/gun/rifle/spp::flags_gun_features | GUN_TRIGGER_SAFETY

/obj/item/ammo_magazine/rifle/spp
	name = "\improper SPP-48M magazine (10x27mm)"
	desc = "A 10x27mm high-capacity casket magazine for the SPP-48M rifle."
	caliber = "10x27mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/upp.dmi'
	icon_state = "spp"
	ammo_band_icon = "+spp_band"
	ammo_band_icon_empty = "+spp_band_e"
	default_ammo = /datum/ammo/bullet/rifle/upp
	max_rounds = 30
	gun_type = /obj/item/weapon/gun/rifle/spp

/obj/item/ammo_magazine/rifle/spp/ap
	name = "\improper SPP-48M AP magazine (10x27mm)"
	desc = "A 10x27mm high-capacity casket magazine containing armor piercing rounds for the SPP-48M rifle."
	default_ammo = /datum/ammo/bullet/rifle/upp/ap
	ammo_band_color = AMMO_BAND_COLOR_AP

/obj/item/ammo_magazine/rifle/spp/ap/penetrating
	name = "\improper SPP-48M AP magazine (10x27mm)"
	desc = "A 10x27mm high-capacity casket magazine containing armor piercing rounds for the SPP-48M rifle."
	default_ammo = /datum/ammo/bullet/rifle/upp/ap/penetrating
	ammo_band_color = AMMO_BAND_COLOR_PENETRATING

/obj/item/ammo_magazine/rifle/spp/heap
	name = "\improper SPP-48M HEAP magazine (10x27mm)"
	desc = "A 10x27mm high-capacity casket magazine containing the standard high explosive armor piercing rounds for the SPP-48M rifle."
	default_ammo = /datum/ammo/bullet/rifle/upp/heap
	ammo_band_color = AMMO_BAND_COLOR_HEAP

/obj/item/ammo_magazine/rifle/spp/incendiary
	name = "\improper SPP-48M incendiary magazine (10x27mm)"
	desc = "A 10x27mm high-capacity casket magazine containing incendiary rounds for the SPP-48M rifle."
	default_ammo = /datum/ammo/bullet/rifle/upp/incendiary
	ammo_band_color = AMMO_BAND_COLOR_INCENDIARY

/obj/item/ammo_magazine/rifle/spp/high_velocity
	name = "\improper SPP-48M HV magazine (10x27mm)"
	desc = "A magazine of high velocity rounds for use in the later-model SPP-48M marksman rifles of UPPAC."
	icon_state = "spp_hv"
	default_ammo = /datum/ammo/bullet/rifle/upp/spec
	max_rounds = 30
	gun_type = /obj/item/weapon/gun/rifle/spp
	ammo_band_icon = "+spp_hv_band"
	ammo_band_icon_empty = "+spp_hv_band_e"
	ammo_band_color = AMMO_BAND_COLOR_HIGH_IMPACT

/obj/item/ammo_magazine/rifle/spp/high_velocity/incendiary
	name = "\improper SPP-48M HV incendiary magazine (10x27mm)"
	desc = "A magazine of high velocity incendiary rounds for use in the later-model SPP-48M marksman rifles of UPPAC."
	default_ammo = /datum/ammo/bullet/rifle/upp/spec/incendiary
	gun_type = /obj/item/weapon/gun/rifle/spp
	ammo_band_color = AMMO_BAND_COLOR_INCENDIARY

/obj/item/ammo_magazine/rifle/spp/high_velocity/explosive
	name = "\improper SPP-48M HV explosive magazine (10x27mm)"
	desc = "A magazine of high velocity explosive rounds for use in the later-model SPP-48M marksman rifles of UPPAC."
	default_ammo = /datum/ammo/bullet/rifle/upp/spec/explosive
	gun_type = /obj/item/weapon/gun/rifle/spp
	ammo_band_color = AMMO_BAND_COLOR_EXPLOSIVE

/obj/item/ammo_magazine/rifle/spp/high_velocity/toxic
	name = "\improper SPP-48M HV depleted uranium magazine (10x27mm)"
	desc = "A magazine of high velocity wall-penetrating, body-penetrating, toxic 10x27mm rounds for use in the later-model SPP-48M marksman rifles of UPPAC."
	default_ammo = /datum/ammo/bullet/rifle/upp/spec/du
	gun_type = /obj/item/weapon/gun/rifle/spp
	ammo_band_color = AMMO_BAND_COLOR_TOXIN

/obj/item/storage/box/guncase/heavy/spp
	name = "\improper SPP-48M marksman case"
	desc = "A case for storing a SPP-48M marksman rifle."
	icon_state = "uppsppcase"
	storage_slots = 9
	can_hold = list(/obj/item/weapon/gun/rifle/spp, /obj/item/ammo_magazine/rifle/spp/high_velocity, /obj/item/ammo_magazine/rifle/spp/high_velocity/explosive, /obj/item/ammo_magazine/rifle/spp/high_velocity/incendiary, /obj/item/ammo_magazine/rifle/spp/high_velocity/toxic)
	max_w_class = SIZE_HUGE

/obj/item/storage/box/guncase/heavy/spp/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/spp/unloaded(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity/toxic(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity/toxic(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity/explosive(src)
	new /obj/item/ammo_magazine/rifle/spp/high_velocity/incendiary(src)

/obj/item/storage/box/guncase/heavy/spp/update_icon()
	overlays.Cut()
	if(opened)
		overlays += image(src.icon, "uppbigcase_lid_open")
	else
		overlays += image(src.icon, "uppsppcase_lid")
		return
	if(locate(/obj/item/weapon/gun/rifle/spp) in src.contents)
		overlays += image(src.icon, "+spp")

/obj/item/ammo_box/magazine/spp
	name = "magazine box (SPP-48M x 16)"
	icon_state = "base_zhnk72"
	flags_equip_slot = SLOT_BACK
	overlay_ammo_type = "_type71_reg"
	overlay_content = "_type71_reg"
	overlay_gun_type = "_spp"
	num_of_magazines = 16
	magazine_type = /obj/item/ammo_magazine/rifle/spp

/obj/item/ammo_box/magazine/spp/empty
	empty = TRUE

/obj/item/ammo_box/magazine/spp/ap
	name = "magazine box (SPP-48M AP x 16)"
	overlay_ammo_type = "_type71_ap"
	overlay_content = "_type71_ap"
	magazine_type = /obj/item/ammo_magazine/rifle/spp/ap

/obj/item/ammo_box/magazine/spp/ap/empty
	empty = TRUE

/obj/item/ammo_box/magazine/spp/heap
	name = "magazine box (SPP-48M HEAP x 16)"
	overlay_ammo_type = "_type71_heap"
	overlay_content = "_type71_heap"
	magazine_type = /obj/item/ammo_magazine/rifle/spp/heap

/obj/item/ammo_box/magazine/spp/incendiary
	name = "magazine box (SPP-48M Incen x 16)"
	overlay_ammo_type = "_type71_incen"
	overlay_content = "_type71_incen"
	magazine_type = /obj/item/ammo_magazine/rifle/spp/incendiary

/obj/item/ammo_box/magazine/spp/incendiary/empty
	empty = TRUE

/obj/item/ammo_box/magazine/spp/hv
	name = "magazine box (HV SPP-48M x 10)"
	overlay_ammo_type = "_type73_impact"
	overlay_content = "_type73_impact"
	num_of_magazines = 10
	magazine_type = /obj/item/ammo_magazine/rifle/spp/high_velocity

/obj/item/ammo_box/magazine/spp/hv/empty
	empty = TRUE

/obj/item/ammo_box/magazine/spp/hv/explosive
	name = "magazine box (SPP-48M HV Explosive x 10)"
	overlay_ammo_type = "_type71_expl"
	overlay_content = "_type71_expl"
	magazine_type = /obj/item/ammo_magazine/rifle/spp/high_velocity/explosive

/obj/item/ammo_box/magazine/spp/hv/explosive/empty
	empty = TRUE

/obj/item/ammo_box/magazine/spp/hv/incendiary
	name = "magazine box (SPP-48M HV Incen x 10)"
	overlay_ammo_type = "_type71_incen"
	overlay_content = "_type71_incen"
	magazine_type = /obj/item/ammo_magazine/rifle/spp/high_velocity/incendiary

/obj/item/ammo_box/magazine/spp/hv/incendiary/empty
	empty = TRUE

/obj/item/ammo_box/magazine/spp/hv/toxic
	name = "magazine box (SPP-48M HV DU x 10)"
	overlay_ammo_type = "_type71_toxin"
	overlay_content = "_type71_incen"
	magazine_type = /obj/item/ammo_magazine/rifle/spp/high_velocity/toxic

/obj/item/ammo_box/magazine/spp/hv/toxic/empty
	empty = TRUE

/obj/item/attachable/cawsbarrel
	name = "Type 97 Barrel"

/obj/item/weapon/gun/rifle/nsg23/l23
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

/obj/item/weapon/gun/rifle/ag80/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18, "rail_x" = 12, "rail_y" = 22, "under_x" = 24, "under_y" = 15, "stock_x" = 24, "stock_y" = 15, "side_rail_x" = 23, "side_rail_y" = 18, "sling_x" = 12, "sling_y" = 22)

/obj/item/weapon/gun/rifle/type71/carbine/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_10)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_6
	scatter = SCATTER_AMOUNT_TIER_7
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_4
	damage_falloff_mult = 1.5

/obj/item/weapon/gun/rifle/type71/carbine/assault
	starting_attachment_types = list(/obj/item/attachable/bayonet/upp, /obj/item/attachable/verticalgrip/upp)

/obj/item/weapon/gun/rifle/type71/carbine/commando
	name = "\improper Type 71MS 'Commando' pulse rifle"
	desc = "A much rarer variant of the Type 71, this version contains an integrated suppressor, integrated scope, and extensive fine-tuning. Many parts have been replaced, filed down, and improved upon. As a result, this variant is rarely seen outside of commando units."
	icon_state = "type73"
	item_state = "type73"
	fire_sound = "gun_silenced"
	wield_delay = WIELD_DELAY_VERY_FAST
	inherent_traits = list(TRAIT_GUN_SILENCED)
	bonus_overlay_x = 1
	bonus_overlay_y = 0
	force = 20
	starting_attachment_types = list(/obj/item/attachable/type73suppressor)

/obj/item/weapon/gun/rifle/type71/carbine/commando/handle_starting_attachment()
	..()
	var/obj/item/attachable/scope/mini/upp/type73/scope = new(src)
	scope.hidden = TRUE
	scope.flags_attach_features &= ~ATTACH_REMOVABLE
	scope.Attach(src)
	update_attachable(scope.slot)

/obj/item/weapon/gun/rifle/type71/carbine/commando/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 35, "muzzle_y" = 16, "rail_x" = 13, "rail_y" = 23, "under_x" = 25, "under_y" = 13, "stock_x" = 15, "stock_y" = 13, "side_rail_x" = 24, "side_rail_y" = 17, "sling_x" = 16, "sling_y" = 19)
/obj/item/weapon/gun/rifle/type71/carbine/commando/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_10)
	set_burst_delay(FIRE_DELAY_TIER_LMG)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_8
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_10
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	damage_mult = BASE_BULLET_DAMAGE_MULT
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	recoil_unwielded = RECOIL_AMOUNT_TIER_4
	damage_falloff_mult = 0

/obj/item/weapon/gun/rifle/type71/carbine/commando/unloaded
	current_mag = null
	flags_gun_features = /obj/item/weapon/gun/rifle/type71/carbine/commando::flags_gun_features | GUN_TRIGGER_SAFETY

/obj/item/weapon/gun/rifle/lw317/dmr/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_5)
	set_burst_amount(BURST_AMOUNT_TIER_1)
	accuracy_mult = BASE_ACCURACY_MULT * 3
	scatter = SCATTER_AMOUNT_TIER_8
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_5
	damage_falloff_mult = 0