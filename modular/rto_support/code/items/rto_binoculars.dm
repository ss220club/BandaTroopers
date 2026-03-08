/// Dedicated binoculars for the RTO support workflow.
/obj/item/device/binoculars/rto
	name = "RTO binoculars"
	desc = "Бинокль оператора связи. Во время зума Ctrl+Click принимает целеуказание выбранного режима."
	icon_state = "advanced_binoculars"
	uses_camo = FALSE
	zoom_offset = 11
	view_range = 12
	var/obj/item/storage/pouch/sling/rto/paired_pouch
	var/atom/live_marker_target
	var/image/live_marker_overlay
	var/mob/living/carbon/human/live_marker_owner
	var/live_marker_active = FALSE
	var/live_marker_refresh_timer_id = null

/obj/item/device/binoculars/rto/Destroy()
	stop_live_marker(null, TRUE)
	if(paired_pouch?.paired_binocular == src)
		paired_pouch.paired_binocular = null
	paired_pouch = null
	return ..()

/obj/item/device/binoculars/rto/equipped(mob/user, slot)
	. = ..()
	notify_controller_inventory_state(user, slot, COMSIG_HUMAN_EQUIPPED_ITEM)

/obj/item/device/binoculars/rto/unequipped(mob/user, slot)
	. = ..()
	notify_controller_inventory_state(user, slot, COMSIG_HUMAN_UNEQUIPPED_ITEM)

/obj/item/device/binoculars/rto/pickup(mob/user, silent)
	. = ..()
	notify_controller_inventory_state(user, null, COMSIG_MOB_PICKUP_ITEM)

/obj/item/device/binoculars/rto/dropped(mob/user)
	. = ..()
	notify_controller_inventory_state(user, null, COMSIG_MOB_ITEM_DROPPED)

/obj/item/device/binoculars/rto/clicked(mob/user, list/mods)
	if(!ishuman(user))
		return ..()
	if(mods[CTRL_CLICK] && CAN_PICKUP(user, src))
		var/mob/living/carbon/human/human_user = user
		var/datum/rto_support_controller/controller = human_user.ensure_rto_support_controller()
		if(controller?.armed_action_id)
			controller.disarm_action()
			to_chat(user, SPAN_NOTICE("Наведение отменено."))
			return TRUE
	return ..()

/obj/item/device/binoculars/rto/on_unset_interaction(mob/user)
	. = ..()
	if(istype(user) && live_marker_owner == user)
		stop_live_marker(user, TRUE)

/obj/item/device/binoculars/rto/handle_click(mob/living/carbon/human/user, atom/targeted_atom, list/mods)
	if(!istype(user) || !mods[CTRL_CLICK])
		return FALSE
	if(user.stat != CONSCIOUS)
		to_chat(user, SPAN_WARNING("Вы не можете использовать [src] в текущем состоянии."))
		return FALSE
	if(mods[CLICK_CATCHER])
		return FALSE

	var/turf/target_turf = get_turf(targeted_atom)
	if(!target_turf || target_turf.z == 0)
		return FALSE

	var/datum/rto_support_controller/controller = user.ensure_rto_support_controller()
	if(controller?.armed_action_id)
		return controller.handle_binocular_target(target_turf, user)

	if(!can_see_target(target_turf, user))
		to_chat(user, SPAN_WARNING("Нет прямой видимости до точки."))
		return FALSE

	acquire_coordinates(target_turf, user)
	return TRUE

/obj/item/device/binoculars/rto/get_examine_text(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/datum/rto_support_controller/controller = human_user.ensure_rto_support_controller()
	if(!controller)
		return

	. += SPAN_NOTICE("Ctrl+Click во время зума: навести выбранный режим.")
	. += SPAN_NOTICE("Кнопка 'Координаты': постоянный режим получения координат без лазера.")
	. += SPAN_NOTICE("Кнопка 'Лазерная отметка': постоянный режим живой лазерной подсветки через бинокль.")

	if(controller.active_template)
		. += SPAN_NOTICE("Текущий пакет: [controller.active_template.name].")
	else
		. += SPAN_NOTICE("Пакет поддержки ещё не выбран.")

	switch(controller.get_zone_state())
		if(RTO_SUPPORT_ZONE_STATE_ACTIVE)
			. += SPAN_NOTICE("Сектор наведения активен: [round(controller.get_zone_expires_in() / 10)] сек.")
		if(RTO_SUPPORT_ZONE_STATE_COOLDOWN)
			. += SPAN_NOTICE("Сектор наведения перезаряжается: [round(controller.get_zone_ready_in() / 10)] сек.")
		if(RTO_SUPPORT_ZONE_STATE_READY)
			. += SPAN_NOTICE("Сектор наведения готов к развёртыванию.")
		if(RTO_SUPPORT_ZONE_STATE_UNSUPPORTED)
			if(controller.active_template)
				. += SPAN_NOTICE("Текущий пакет работает без сектора наведения.")

	var/armed_mode_name = controller.get_armed_mode_name()
	if(armed_mode_name)
		. += SPAN_NOTICE("Текущий режим наведения: [armed_mode_name].")
	if(is_live_marker_active())
		. += SPAN_NOTICE("Лазерная отметка активна.")

/obj/item/device/binoculars/rto/proc/acquire_coordinates(turf/target_turf, mob/living/carbon/human/user)
	to_chat(user, SPAN_NOTICE("КООРДИНАТЫ: LONGITUDE [obfuscate_x(target_turf.x)]. LATITUDE [obfuscate_y(target_turf.y)]."))
	playsound(src, 'sound/effects/binoctarget.ogg', 35)

/obj/item/device/binoculars/rto/proc/can_see_target(turf/target_turf, mob/living/carbon/human/user)
	if(QDELETED(target_turf))
		return FALSE
	if(target_turf.z != user.z)
		return FALSE
	if(!(user in viewers(zoom_offset + view_range + 1, target_turf)))
		return FALSE
	if(user.sight & SEE_TURFS)
		var/list/turf/path = get_line(user, target_turf, include_start_atom = FALSE)
		for(var/turf/turf_in_path as anything in path)
			if(turf_in_path.opacity)
				return FALSE
	return TRUE

/obj/item/device/binoculars/rto/proc/is_in_user_hands(mob/living/carbon/human/user)
	return istype(user) && (user.l_hand == src || user.r_hand == src)

/obj/item/device/binoculars/rto/proc/notify_controller_inventory_state(mob/user, slot = null, signal_id = null)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	if(human_user.job != JOB_SQUAD_RTO)
		return FALSE
	var/datum/rto_support_controller/controller = human_user.get_rto_support_controller()
	if(!controller)
		controller = human_user.ensure_rto_support_controller()
	return controller?.handle_inventory_changed(src, slot, signal_id)

/obj/item/device/binoculars/rto/proc/pair_with_pouch(obj/item/storage/pouch/sling/rto/pouch)
	if(!istype(pouch))
		return FALSE
	paired_pouch = pouch
	if(pouch.paired_binocular != src)
		pouch.paired_binocular = src
	return TRUE

/obj/item/device/binoculars/rto/proc/is_live_marker_active()
	return live_marker_active && live_marker_target && live_marker_overlay

/obj/item/device/binoculars/rto/proc/start_live_marker(atom/targeted_atom, mob/living/carbon/human/user)
	if(!istype(user) || !targeted_atom)
		return FALSE
	stop_live_marker(user, TRUE)
	live_marker_target = targeted_atom
	live_marker_owner = user
	live_marker_overlay = image('icons/obj/items/weapons/projectiles.dmi', icon_state = "laser_target2", layer = -LASER_LAYER)
	live_marker_target.apply_fire_support_laser(live_marker_overlay)
	live_marker_active = TRUE
	if(!live_marker_refresh_timer_id)
		live_marker_refresh_timer_id = addtimer(CALLBACK(src, PROC_REF(refresh_live_marker)), 0.5 SECONDS, TIMER_LOOP|TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/obj/item/device/binoculars/rto/proc/stop_live_marker(mob/living/carbon/human/user, silent = FALSE)
	if(live_marker_target && live_marker_overlay)
		live_marker_target.remove_fire_support_laser(live_marker_overlay)
	if(live_marker_refresh_timer_id)
		deltimer(live_marker_refresh_timer_id)
	live_marker_refresh_timer_id = null
	live_marker_target = null
	live_marker_owner = null
	live_marker_active = FALSE
	QDEL_NULL(live_marker_overlay)
	if(!silent && user)
		to_chat(user, SPAN_NOTICE("Лазерная отметка снята."))
	return TRUE

/obj/item/device/binoculars/rto/proc/refresh_live_marker()
	if(!can_continue_live_marker(live_marker_owner))
		stop_live_marker(live_marker_owner, TRUE)
	return TRUE

/obj/item/device/binoculars/rto/proc/can_continue_live_marker(mob/living/carbon/human/user)
	if(!istype(user) || QDELETED(user))
		return FALSE
	if(!is_live_marker_active())
		return FALSE
	if(user.stat == DEAD || user.is_mob_incapacitated())
		return FALSE
	if(!is_in_user_hands(user))
		return FALSE
	if(user.interactee != src)
		return FALSE
	var/datum/rto_support_controller/controller = user.get_rto_support_controller()
	if(!controller || !controller.is_action_armed(RTO_SUPPORT_ARM_MARKER))
		return FALSE
	var/turf/target_turf = get_turf(live_marker_target)
	if(!target_turf || QDELETED(target_turf))
		return FALSE
	if(!can_see_target(target_turf, user))
		return FALSE
	return TRUE
