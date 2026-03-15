// rocket launchers

/obj/item/weapon/gun/halo_launcher // im a lazy bastard and dont want to deal with killing all of the dumb procs sorry :)
	icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null

// ====================== SPNKR LAUNCHER ====================== \\

// ===== SPNKR SOUND ====== \\

/datum/looping_sound/spnkr_locking
	start_sound = list('sound/weapons/halo/spnkr_locking/spnkr_aa_startlocking.ogg' = 1)
	start_length = 0.2 SECONDS
	mid_sounds = list('sound/weapons/halo/spnkr_locking/spnkr_aa_locking.ogg' = 1)
	mid_length = 0.35 SECONDS
	volume = 40
	extra_range = 14

/datum/looping_sound/spnkr_lockon
	mid_sounds = list('sound/weapons/halo/spnkr_locking/spnkr_aa_lockon.ogg' = 1)
	mid_length = 0.35 SECONDS
	volume = 40
	extra_range = 14


// ===== SPNKR ====== \\


/obj/item/weapon/gun/halo_launcher/spnkr
	name = "\improper M41 SPNKr"
	desc = "M41 SPNKr - многоцелевая многоразовая ракетная система, способная захватывать как воздушные, так и наземные цели. Среди бойцов ККОН, которым она досталась, её часто называют Jackhammer."
	icon_state = "spnkr"
	item_state = "spnkr"
	layer = ABOVE_OBJ_LAYER
	flags_equip_slot = SLOT_BLOCK_SUIT_STORE|SLOT_BACK
	w_class = SIZE_LARGE
	mouse_pointer = 'icons/halo/effects/mouse_pointer/spnkr.dmi'
	var/cover_open = FALSE
	current_mag = /obj/item/ammo_magazine/spnkr
	aim_slowdown = SLOWDOWN_ADS_RIFLE
	flags_gun_features = GUN_WIELDED_FIRING_ONLY
	fire_sound = "gun_spnkr"
	reload_sound = 'sound/weapons/halo/gun_spnkr_reload.ogg'
	unload_sound = 'sound/weapons/halo/gun_spnkr_unload.ogg'
	item_icons = list(
		WEAR_BACK = 'icons/halo/mob/humans/onmob/clothing/back/guns_by_type/heavy_weapons_32.dmi',
		WEAR_J_STORE = 'icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)
	var/datum/looping_sound/spnkr_lockon/lockon
	var/datum/looping_sound/spnkr_locking/locking
	COOLDOWN_DECLARE(aa_cooldown)
	var/aa_cooldown_time = 7 SECONDS
	var/cancel_sounds
	var/atom/movable/overlay/ammo_overlay

/obj/item/weapon/gun/halo_launcher/spnkr/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_5)
	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_10
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_1

/obj/item/weapon/gun/halo_launcher/spnkr/handle_starting_attachment()
	..()
	var/obj/item/attachable/scope/spnkr/integrated = new(src)
	integrated.flags_attach_features &= ~ATTACH_REMOVABLE
	integrated.Attach(src)
	update_attachable(integrated.slot)

/obj/item/weapon/gun/halo_launcher/spnkr/Initialize()
	. = ..()
	ready_in_chamber()
	locking = new(src)
	lockon = new(src)

/obj/item/weapon/gun/halo_launcher/spnkr/Destroy()
	QDEL_NULL(locking)
	QDEL_NULL(lockon)
	. = ..()

/obj/item/weapon/gun/halo_launcher/spnkr/use_unique_action()
	var/mob/living/carbon/user = get_gun_user()
	var/area/current_area = get_area(user)
	cancel_sounds = FALSE// In case the user moves while while locking on
	if(current_area.ceiling >= CEILING_PROTECTION_TIER_1)
		to_chat(user, SPAN_DANGER("There's a ceiling above you...bad idea."))
		playsound(user, 'sound/weapons/halo/spnkr_locking/spnkr_aa_fail.ogg')
		return
	if(!in_chamber)
		to_chat(user, SPAN_DANGER("You don't have any missiles left to fire!"))
		return
	if(cover_open)
		to_chat(user, SPAN_DANGER("You can't fire with the cover open!"))
		return
	var/obj/item/weapon/twohanded/offhand/off_hand = user.get_inactive_hand()
	if(!off_hand || !istype(off_hand))
		to_chat(user, SPAN_DANGER("You need to wield the [src] with both hands!"))
		return
	if(!COOLDOWN_FINISHED(src, aa_cooldown))
		to_chat(user, SPAN_DANGER("You need to wait before attempting to fire again."))
		return
	COOLDOWN_START(src, aa_cooldown, aa_cooldown_time)
	user.visible_message(SPAN_DANGER("[user] gets down on a knee and aims [user.p_their()] [src] into the air!"), SPAN_DANGER("You get down on a knee and aim your [src] into the air!"))
	locking.start()
	message_admins(FONT_SIZE_XL("[user] is attempting to launch an anti-air missile from their [src]!"), user.x, user.y, user.z)
	addtimer(CALLBACK(src, PROC_REF(stop_locking)), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(play_lockon)), 3 SECONDS)
	if(!do_after(user, 5 SECONDS, show_busy_icon = BUSY_ICON_HOSTILE))
		stop_loops()
		playsound(user, 'sound/weapons/halo/spnkr_locking/spnkr_aa_fail.ogg')
		to_chat(user, SPAN_WARNING("You interrupt the lockon sequence."))
		cancel_sounds = TRUE
		return
	var/missile_name = in_chamber.name
	user.visible_message(FONT_SIZE_LARGE(SPAN_DANGER("[user] fires [user.p_their()] [src] into the air, launching a [in_chamber] from the tube!")), FONT_SIZE_LARGE(SPAN_DANGER("You fire the [src] into the air, launching a [missile_name] from the tube!")))
	QDEL_NULL(in_chamber)
	locking.stop()
	lockon.stop()
	muzzle_flash(get_firing_dir(user))
	playsound(user, fire_sound, firesound_volume)
	ready_in_chamber()
	var/sound_turf = get_turf(user)
	message_admins(FONT_SIZE_XL("[user] launched an anti-air missile from their [src]!"), user.x, user.y, user.z)
	message_admins(FONT_SIZE_XL("<A href='byond://?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];adminacceptspnkr=1;spnkr=\ref[src];turf=\ref[sound_turf];missile_name=[url_encode(missile_name)]'>CLICK TO SUCCEED/FAIL MISSILE LAUNCH</a>"))

/obj/item/weapon/gun/halo_launcher/spnkr/proc/hit_announce(sound_turf, hit_type, missile_name)
	for(var/mob/current_mob as anything in get_mobs_in_z_level_range(sound_turf, 20))
		if(!hit_type)
			to_chat(current_mob, SPAN_HIGHDANGER("You see the [missile_name] miss its target!"))
		else
			if(hit_type == "damage")
				to_chat(current_mob, SPAN_HIGHDANGER("You see the [missile_name] arc into the target and explode, damaging the aircraft!"))
				if(current_mob.client)
					playsound_client(current_mob.client, 'sound/weapons/halo/spnkr_locking/spnkr_aa_damage.ogg', src, 25)
			if(hit_type == "crash")
				to_chat(current_mob, SPAN_HIGHDANGER("You see the [missile_name] arc directly into the aircraft, hitting it with a powerful explosion and sending it crashing down!"))
				if(current_mob.client)
					playsound_client(current_mob.client, 'sound/weapons/halo/spnkr_locking/spnkr_aa_crash.ogg', src, 25)

//

/obj/item/weapon/gun/halo_launcher/spnkr/proc/get_firing_dir(mob/user)
	var/firing_dir
	switch(user.dir)
		if(NORTH)
			firing_dir = 0
		if(EAST)
			firing_dir = 90
		if(SOUTH)
			firing_dir = 180
		if(WEST)
			firing_dir = 270
	return firing_dir

/obj/item/weapon/gun/halo_launcher/spnkr/proc/stop_locking()
	locking.stop()

/obj/item/weapon/gun/halo_launcher/spnkr/proc/play_lockon()
	if(cancel_sounds)
		return
	lockon.start()

/obj/item/weapon/gun/halo_launcher/spnkr/proc/stop_loops()
	lockon.stop()
	locking.stop()

/obj/item/weapon/gun/halo_launcher/spnkr/clicked(mob/user, list/mods)
	if(!mods["alt"] || !CAN_PICKUP(user, src))
		return ..()
	else
		if(!locate(src) in list(user.get_active_hand(), user.get_inactive_hand()))
			return TRUE
		if(user.get_active_hand() && user.get_inactive_hand())
			to_chat(user, SPAN_WARNING("You can't do that with your hands full!"))
			return TRUE
		else
			toggle_cover()
			return TRUE

/obj/item/weapon/gun/halo_launcher/spnkr/get_examine_text(mob/user)
	. = ..()
	if(!cover_open)
		. += SPAN_NOTICE("Крышка закрыта.")
	else
		. += SPAN_NOTICE("Крышка открыта.")

/obj/item/weapon/gun/halo_launcher/spnkr/proc/toggle_cover(mob/user)
	if(!cover_open)
		playsound(src.loc, 'sound/handling/smartgun_open.ogg', 50, TRUE, 3)
		to_chat(user, SPAN_NOTICE("You open [src]'s tube cover, allowing the tubes to be removed."))
		cover_open = TRUE
	else
		playsound(src.loc, 'sound/handling/smartgun_close.ogg', 50, TRUE, 3)
		to_chat(user, SPAN_NOTICE("You close [src]'s tube cover."))
		cover_open = FALSE
	update_icon()

/obj/item/weapon/gun/halo_launcher/spnkr/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("[src]'s cover is closed! You can't put a new [current_mag ? current_mag.name : "rocket"] tube in! <b>(alt-click to open it)</b>"))
		return
	ready_in_chamber()
	return ..()

/obj/item/weapon/gun/halo_launcher/spnkr/unload(mob/user, reload_override, drop_override, loc_override)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("[src]'s cover is closed! You can't take out the [current_mag ? current_mag.name : "rocket tubes"]! <b>(alt-click to open it)</b>"))
		return

	else if(in_chamber)
		to_chat(user, SPAN_WARNING("The safety mechanism prevents you from removing the [current_mag ? current_mag.name : "rocket tubes"] from the [src] until all rounds have been fired."))
		return

	return ..()

/obj/item/weapon/gun/halo_launcher/spnkr/update_icon()
	overlays.Cut()
	vis_contents.Cut()
	. = ..()
	if(cover_open)
		overlays += image("+[base_gun_icon]_cover_open")
	else
		overlays += image("+[base_gun_icon]_cover_closed")
	if(current_mag)
		ammo_overlay = new()
		ammo_overlay.icon = 'icons/halo/obj/items/weapons/guns_by_faction/unsc/special.dmi'
		ammo_overlay.icon_state = "spnkr_rockets"
		ammo_overlay.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
		ammo_overlay.layer = src.layer - 0.1
		ammo_overlay.pixel_x = -2
		ammo_overlay.pixel_y = 1
		if(current_mag.current_rounds <= 0)
			ammo_overlay.icon_state = "spnkr_rockets_e"
		vis_contents += ammo_overlay

/obj/item/weapon/gun/halo_launcher/spnkr/able_to_fire(mob/living/user)
	. = ..()
	if(.)
		if(cover_open)
			to_chat(user, SPAN_WARNING("You can't fire [src] with the feed cover open! <b>(alt-click to close)</b>"))
			return FALSE
	update_icon()

/obj/item/weapon/gun/halo_launcher/spnkr/cock(mob/user)
	if(in_chamber)
		return
	else
		ready_in_chamber()

/obj/item/weapon/gun/halo_launcher/spnkr/unloaded
	current_mag = null
	flags_gun_features = GUN_WIELDED_FIRING_ONLY
