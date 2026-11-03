#define HUMAN_AI_GRENADE_MIN_HOLD_DELAY (1 SECONDS)
#define HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY (1 SECONDS)

/datum/human_ai_throwable_handler
	parent_type = /datum/human_ai_weapon_handler
	item_types = list(/obj/item/explosive/grenade)

/datum/human_ai_throwable_handler/proc/try_hold_throwable(datum/human_ai_throwable_context/context)
	if(!context?.can_continue_throw())
		return FALSE

	var/obj/item/explosive/grenade/grenade = context.grenade
	if(context.controller.get_active_hand() == grenade)
		return TRUE

	if(context.controller.get_inactive_hand() == grenade)
		context.controller.swap_hand()
		if(context.controller.get_active_hand() == grenade)
			return TRUE

	var/obj/item/active_hand = context.controller.get_active_hand()
	if(active_hand && (active_hand != grenade))
		if(active_hand.flags_item & NODROP)
			return FALSE
		context.clear_main_hand()
		if(context.controller.get_active_hand())
			return FALSE

	if(!context.controller.is_item_equipped_or_held(grenade))
		if(!context.equip_item_from_equipment_map(HUMAN_AI_GRENADES, grenade))
			return FALSE
	else if(!context.controller.put_in_active_hand(grenade))
		return FALSE

	context.ensure_primary_hand(grenade)
	return context.controller.get_active_hand() == grenade

/datum/human_ai_throwable_handler/grenade

GLOBAL_DATUM_INIT(human_ai_grenade_throw_handler, /datum/human_ai_throwable_handler/grenade, new)

/datum/human_ai_throwable_handler/grenade/proc/start_throw(datum/human_ai_throwable_context/context, datum/ai_action/throw_grenade/action)
	if(!context?.can_continue_throw() || !action)
		return FALSE

	var/obj/item/weapon/gun/primary_weapon = context.get_primary_weapon()
	if(primary_weapon)
		context.controller.unwield_weapon(primary_weapon)
		if(context.controller.get_active_hand() == primary_weapon)
			context.controller.swap_hand()

	if(!try_hold_throwable(context))
		log_game("AI GRENADE: throw action aborted - could not hold grenade, grenade=[context.grenade], mob=[context.controller.get_key_name()]")
		return FALSE

	if(isnum(context.grenade.throw_range))
		context.throw_range_override = context.grenade.throw_range

	if(!context.can_throw_to_target())
		log_game("AI GRENADE: throw action aborted - target unreachable, distance=[context.controller.get_distance_to(context.target_turf)], throw_range=[context.throw_range_override], mob=[context.controller.get_key_name()]")
		return FALSE

	log_game("AI GRENADE: throw action proceeding to async prime - grenade=[context.grenade], target=[context.target_turf], mob=[context.controller.get_key_name()]")
	action.brain?.set_grenade_throw_mid_action()
	INVOKE_ASYNC(src, PROC_REF(async_prime_and_throw), action, context.controller.get_identity_ref(), context.grenade, context.target_turf, context.throw_range_override)
	return TRUE

/datum/human_ai_throwable_handler/grenade/proc/finish_async_throw(datum/ai_action/throw_grenade/action)
	if(!action || QDELETED(action))
		return
	action.brain?.finish_grenade_throw_action()

/datum/human_ai_throwable_handler/grenade/proc/build_async_context(datum/ai_action/throw_grenade/action, obj/item/explosive/grenade/grenade, turf/target_turf, throw_range_override)
	RETURN_TYPE(/datum/human_ai_throwable_context)
	if(!action || QDELETED(action) || !action.brain)
		return null
	return new /datum/human_ai_throwable_context(action.brain, grenade, action.brain.get_current_target(), target_turf, throw_range_override)

/datum/human_ai_throwable_handler/grenade/proc/async_prime_and_throw(datum/ai_action/throw_grenade/action, datum/weakref/puppet_ref, obj/item/explosive/grenade/grenade, turf/target_turf, throw_range_override)
	log_game("AI GRENADE: async throw started - grenade=[grenade] ([grenade?.type]), target=[target_turf], mob=[action?.context?.controller?.get_key_name()]")
	if(!action || QDELETED(action))
		return

	var/datum/human_ai_throwable_context/context = build_async_context(action, grenade, target_turf, throw_range_override)
	if(!context?.can_continue_throw() || !context.controller.matches_identity_ref(puppet_ref))
		log_game("AI GRENADE: async throw aborted - brain invalid or puppet mismatch, mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	var/pre_throw_hold_delay = max(HUMAN_AI_GRENADE_MIN_HOLD_DELAY, context.AI.get_action_delay())
	sleep(pre_throw_hold_delay)

	qdel(context)
	context = build_async_context(action, grenade, target_turf, throw_range_override)
	if(!context?.can_continue_throw() || !context.controller.matches_identity_ref(puppet_ref))
		log_game("AI GRENADE: async throw aborted after pre-hold - brain invalid or mismatch, mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	if(!try_hold_throwable(context) || !context.can_throw_to_target())
		log_game("AI GRENADE: async throw aborted - hold or target check failed, grenade=[grenade], mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	var/turf/final_target_turf = context.resolve_throw_target()
	if(!final_target_turf)
		log_game("AI GRENADE: async throw aborted - no valid throw target, target=[target_turf], mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	context.controller.prime_grenade(grenade)
	log_game("AI GRENADE: grenade primed - grenade=[grenade], target=[final_target_turf], mob=[action?.context?.controller?.get_key_name()]")
	if(QDELETED(grenade) || !grenade.active)
		log_game("AI GRENADE: async throw aborted after prime - QDELETED=[QDELETED(grenade)], active=[grenade?.active], mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	context.ensure_primary_hand(grenade)
	context.AI.say_grenade_thrown_line()
	sleep(HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY)

	qdel(context)
	context = build_async_context(action, grenade, target_turf, throw_range_override)
	if(!context?.can_continue_throw() || QDELETED(grenade) || !context.controller.is_item_equipped_or_held(grenade))
		log_game("AI GRENADE: async throw aborted after post-prime hold - grenade lost, QDELETED=[QDELETED(grenade)], loc=[grenade?.loc], mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	if(!try_hold_throwable(context))
		log_game("AI GRENADE: async throw aborted - final hold failed, grenade=[grenade], mob=[action?.context?.controller?.get_key_name()]")
		qdel(context)
		finish_async_throw(action)
		return

	var/turf/emergency_target = context.resolve_throw_target()
	if(!emergency_target)
		var/list/emergency_directions = context.get_fallback_throw_directions(target_turf)
		if(length(emergency_directions))
			for(var/direction in emergency_directions)
				var/turf/candidate = context.controller.get_ranged_target_turf(direction, context.get_effective_throw_range())
				if(candidate && context.can_throw_to_target(candidate))
					emergency_target = candidate
					break
	if(!emergency_target)
		log_game("AI GRENADE: EMERGENCY - no valid target, dropping live grenade on floor, grenade=[grenade], mob=[context.controller.get_key_name()], loc=[context.controller.get_area_coords()]")
		msg_admin_attack("[context.controller.get_key_name()] (AI) dropped a live [grenade] on the floor - no valid throw target at [context.controller.get_area_coords()].")
		context.controller.drop_live_grenade(grenade)
		qdel(context)
		finish_async_throw(action)
		return

	context.controller.toggle_throw_mode(THROW_MODE_NORMAL)
	context.controller.throw_item(emergency_target)
	log_game("AI GRENADE: throw_item() called - grenade=[grenade], target=[emergency_target], mob=[context.controller.get_key_name()]")
	qdel(context)
	finish_async_throw(action)

#undef HUMAN_AI_GRENADE_MIN_HOLD_DELAY
#undef HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY
