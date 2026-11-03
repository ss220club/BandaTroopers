// Human AI live grenade throw-back behavior.

/datum/human_ai_throwable_handler/throw_back_grenade

GLOBAL_DATUM_INIT(human_ai_grenade_throw_back_handler, /datum/human_ai_throwable_handler/throw_back_grenade, new)

/datum/human_ai_throwable_handler/throw_back_grenade/proc/reset_action(datum/ai_action/throw_back_nade/action)
	if(!action || QDELETED(action))
		return
	action.brain?.finish_throwback_action()

/datum/human_ai_throwable_handler/throw_back_grenade/proc/clear_threat(datum/human_ai_throwable_context/context, datum/ai_action/throw_back_nade/action)
	if(context?.AI)
		context.AI.clear_active_grenade()
	if(action)
		action.brain?.set_throwback_ready_time(0)

/datum/human_ai_throwable_handler/throw_back_grenade/proc/is_throw_back_grenade_valid(datum/human_ai_throwable_context/context)
	if(!context?.can_continue())
		return FALSE
	if(QDELETED(context.grenade) || !context.grenade.active)
		return FALSE
	if(!isturf(context.grenade.loc) && !context.controller.is_item_equipped_or_held(context.grenade))
		return FALSE
	return TRUE

/datum/human_ai_throwable_handler/throw_back_grenade/proc/try_hold_live_grenade(datum/human_ai_throwable_context/context)
	if(!context?.can_continue() || !context.grenade || QDELETED(context.grenade) || !isturf(context.grenade.loc))
		return FALSE

	var/obj/item/explosive/grenade/grenade = context.grenade
	if(context.controller.get_active_hand() == grenade)
		return TRUE

	if(!(context.controller.get_active_hand()?.flags_item & NODROP))
		context.clear_main_hand()
		if(context.controller.put_in_active_hand(grenade))
			return TRUE

	context.controller.swap_hand()
	if(context.controller.get_active_hand() == grenade)
		return TRUE

	if(!(context.controller.get_active_hand()?.flags_item & NODROP))
		context.clear_main_hand()
		if(context.controller.put_in_active_hand(grenade))
			return TRUE

	context.controller.swap_hand()
	return FALSE

/datum/human_ai_throwable_handler/throw_back_grenade/proc/try_hold_live_grenade_ensure_primary(datum/human_ai_throwable_context/context)
	if(!try_hold_live_grenade(context))
		return FALSE
	context.ensure_primary_hand(context.grenade)
	return TRUE

/datum/human_ai_throwable_handler/throw_back_grenade/proc/get_directional_throw_target(datum/human_ai_throwable_context/context)
	RETURN_TYPE(/turf)
	if(!context?.is_valid())
		return null

	var/list/directions = list(
		locate(context.controller.get_x(), context.controller.get_y() + context.min_safe_throw_distance, context.controller.get_z()),
		locate(context.controller.get_x() + context.min_safe_throw_distance, context.controller.get_y(), context.controller.get_z()),
		locate(context.controller.get_x(), context.controller.get_y() - context.min_safe_throw_distance, context.controller.get_z()),
		locate(context.controller.get_x() - context.min_safe_throw_distance, context.controller.get_y(), context.controller.get_z()),
	)

	dir_loop:
		for(var/turf/location as anything in directions)
			if(location)
				var/list/turf/path = context.controller.get_line_to(location, FALSE)
				for(var/turf/possible_blocker as anything in path)
					if(possible_blocker.density)
						continue dir_loop

					for(var/obj/possible_object_blocker in possible_blocker)
						if(possible_object_blocker.density)
							continue dir_loop

				var/has_friendly = FALSE
				for(var/mob/possible_friendly in range(context.AI.get_friendly_throw_check_range(), location))
					if(!context.AI.can_target(possible_friendly))
						has_friendly = TRUE
						break

				if(!has_friendly)
					return location

	return null

/datum/human_ai_throwable_handler/throw_back_grenade/proc/resolve_throw_back_target(datum/human_ai_throwable_context/context)
	RETURN_TYPE(/turf)
	if(!context?.is_valid())
		return null

	var/view_distance = context.AI.get_view_distance()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/target in context.controller.get_range(view_distance))
		if(context.AI.can_target(target))
			possible_targets += target

	var/turf/place_to_throw
	if(length(possible_targets))
		var/mob/living/carbon/chosen_target = pick(possible_targets)
		var/list/turf_pathfind_list = AStar(context.controller.get_current_turf(), get_turf(chosen_target), /turf/proc/AdjacentTurfs, /turf/proc/Distance, view_distance)
		for(var/i = length(turf_pathfind_list); i >= context.min_safe_throw_distance; i--)
			var/turf/target_turf = turf_pathfind_list[i]
			if(context.controller.is_in_view_of(target_turf, view_distance))
				place_to_throw = target_turf
				break

	if(place_to_throw && (context.controller.get_distance_to(place_to_throw) < context.min_safe_throw_distance))
		place_to_throw = null

	if(!place_to_throw)
		place_to_throw = get_directional_throw_target(context)

	return place_to_throw

/datum/human_ai_throwable_handler/throw_back_grenade/proc/continue_throw_back(datum/human_ai_throwable_context/context, datum/ai_action/throw_back_nade/action)
	if(!context?.is_valid() || !action)
		return ONGOING_ACTION_COMPLETED

	if(!context.AI.can_throw_back_grenade())
		log_game("AI GRENADE: throw-back aborted - capability disabled, mob=[context.controller.get_key_name()]")
		clear_threat(context, action)
		return ONGOING_ACTION_COMPLETED

	if(!is_throw_back_grenade_valid(context))
		log_game("AI GRENADE: throw-back aborted - grenade stale or spent, grenade=[context.grenade], mob=[context.controller.get_key_name()]")
		clear_threat(context, action)
		return ONGOING_ACTION_COMPLETED

	if(!context.controller.is_item_equipped_or_held(context.grenade))
		if(context.controller.get_distance_to(context.grenade) > 1)
			if(!context.AI.move_to_turf(get_turf(context.grenade)))
				log_game("AI GRENADE: throw-back aborted - could not move to grenade, grenade=[context.grenade], mob=[context.controller.get_key_name()]")
				return ONGOING_ACTION_COMPLETED

			if(context.controller.get_distance_to(context.grenade) > 1)
				return ONGOING_ACTION_UNFINISHED

		if(!try_hold_live_grenade(context))
			log_game("AI GRENADE: throw-back aborted - could not pick up grenade, grenade=[context.grenade], mob=[context.controller.get_key_name()]")
			clear_threat(context, action)
			return ONGOING_ACTION_COMPLETED

		var/remaining_fuse_ticks = context.grenade.get_remaining_timed_fuse_ticks()
		if(isnull(remaining_fuse_ticks) || (remaining_fuse_ticks <= 0))
			context.AI.set_throwback_ready_time(world.time)
		else
			var/safe_window = max(1, remaining_fuse_ticks - 2)
			context.AI.set_throwback_ready_time(world.time + rand(1, safe_window))
		log_game("AI GRENADE: throw-back holding grenade - grenade=[context.grenade], remaining_fuse=[remaining_fuse_ticks], throw_ready=[context.AI.get_throwback_ready_time()], mob=[context.controller.get_key_name()]")
		return ONGOING_ACTION_UNFINISHED

	if(world.time < context.AI.get_throwback_ready_time())
		return ONGOING_ACTION_UNFINISHED

	var/turf/place_to_throw = resolve_throw_back_target(context)
	if(!place_to_throw)
		log_game("AI GRENADE: throw-back EMERGENCY - no safe target, dropping live grenade on floor, grenade=[context.grenade], mob=[context.controller.get_key_name()], loc=[context.controller.get_area_coords()]")
		msg_admin_attack("[context.controller.get_key_name()] (AI) dropped a live [context.grenade] on the floor during throw-back - no safe throw target at [context.controller.get_area_coords()].")
		context.controller.drop_live_grenade(context.grenade)
		clear_threat(context, action)
		return ONGOING_ACTION_COMPLETED

	if(!try_hold_live_grenade_ensure_primary(context))
		log_game("AI GRENADE: throw-back aborted - final hold failed, grenade=[context.grenade], mob=[context.controller.get_key_name()]")
		clear_threat(context, action)
		return ONGOING_ACTION_COMPLETED

	if(QDELETED(context.grenade) || !context.controller.is_item_equipped_or_held(context.grenade) || !context.grenade.active)
		log_game("AI GRENADE: throw-back aborted - grenade lost before throw, grenade=[context.grenade], mob=[context.controller.get_key_name()]")
		clear_threat(context, action)
		return ONGOING_ACTION_COMPLETED

	context.controller.toggle_throw_mode(THROW_MODE_NORMAL)
	context.controller.face_atom(place_to_throw)
	log_game("AI GRENADE: throw-back proceeding to async throw - grenade=[context.grenade], target=[place_to_throw], mob=[context.controller.get_key_name()]")
	context.AI.clear_active_grenade()
	context.unqueue_pickup(context.grenade)
	context.AI.set_throwback_mid_action()
	INVOKE_ASYNC(src, PROC_REF(async_throw_grenade), action, context.controller.get_identity_ref(), context.grenade, place_to_throw)
	return ONGOING_ACTION_UNFINISHED

/datum/human_ai_throwable_handler/throw_back_grenade/proc/async_throw_grenade(datum/ai_action/throw_back_nade/action, datum/weakref/puppet_ref, obj/item/explosive/grenade/grenade, turf/place_to_throw)
	log_game("AI GRENADE: throw-back async throw started - grenade=[grenade], target=[place_to_throw], mob=[action?.context?.controller?.get_key_name()]")
	if(!action || QDELETED(action))
		return

	var/datum/human_ai_throwable_context/context = new(action.brain, grenade, null, place_to_throw)
	if(!context?.is_valid() || !context.controller.matches_identity_ref(puppet_ref))
		log_game("AI GRENADE: throw-back async throw aborted - brain invalid or mismatch, mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		reset_action(action)
		return

	if(QDELETED(grenade) || !grenade.active || !context.controller.is_item_equipped_or_held(grenade) || !place_to_throw)
		log_game("AI GRENADE: throw-back async throw aborted - grenade invalid or missing, grenade=[grenade], active=[grenade?.active], loc=[grenade?.loc], target=[place_to_throw], mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		reset_action(action)
		return

	if(context.controller.get_active_hand() != grenade)
		if(context.controller.get_inactive_hand() == grenade)
			context.controller.swap_hand()
		else
			log_game("AI GRENADE: throw-back async throw aborted - grenade not in hands, mob=[context.controller.get_key_name()]")
			qdel(context)
			reset_action(action)
			return

	if(context.controller.get_active_hand() != grenade)
		log_game("AI GRENADE: throw-back async throw aborted - grenade not in active hand after swap, mob=[context.controller.get_key_name()]")
		qdel(context)
		reset_action(action)
		return

	context.controller.throw_item(place_to_throw)
	log_game("AI GRENADE: throw-back throw_item() called - grenade=[grenade], target=[place_to_throw], mob=[context.controller.get_key_name()]")
	qdel(context)
	reset_action(action)
