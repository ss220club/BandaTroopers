/datum/human_ai_module/grenade
	module_id = "grenade"
	required_module_types = list(
		/datum/human_ai_module/action_runtime,
		/datum/human_ai_module/combat,
		/datum/human_ai_module/inventory,
		/datum/human_ai_module/perception,
		/datum/human_ai_module/targeting,
	)
	/// A nearby found active grenade which AI will try and toss back
	var/obj/item/explosive/grenade/active_grenade_found
	/// If TRUE, may enter the grenade throw-back action from nearby live grenades.
	var/can_throw_back_grenades = TRUE // SS220 EDIT: equipment presets can opt weak HumanAI out of grenade throw-back
	/// Range in tiles for friendly proximity check when throwing grenades. Default 3. Override in presets.
	var/friendly_throw_check_range = 3 // SS220 EDIT: configurable friendly check range for grenade throws
	/// If TRUE, the AI will throw grenades at enemies who enter cover
	var/grenading_allowed = TRUE
	var/obj/item/explosive/grenade/active_throw_grenade
	var/throw_mid_action = FALSE
	var/throw_finished = FALSE
	var/throw_range_override = null
	var/throwback_min_safe_throw_distance = 4
	var/throwback_ready_time = 0
	var/throwback_mid_action = FALSE
	var/throwback_finished = FALSE

/datum/human_ai_module/grenade/proc/reset_grenade()
	active_grenade_found = null // SS220 EDIT: reset stale grenade threat state so AI can leave throw-back mode cleanly
	reset_grenade_throw_state()
	reset_throwback_state(FALSE)

/datum/human_ai_module/grenade/reset_module()
	reset_grenade()

/datum/human_ai_module/grenade/suspend_module(clear_inventory = FALSE)
	reset_grenade()

/datum/human_ai_module/grenade/proc/get_active_grenade()
	RETURN_TYPE(/obj/item/explosive/grenade)
	return active_grenade_found

/datum/human_ai_module/grenade/proc/has_active_grenade()
	return active_grenade_found && !QDELETED(active_grenade_found)

/datum/human_ai_module/grenade/proc/set_active_grenade(obj/item/explosive/grenade/grenade)
	active_grenade_found = grenade

/datum/human_ai_module/grenade/proc/clear_active_grenade()
	active_grenade_found = null

/datum/human_ai_module/grenade/proc/can_throw_back()
	return can_throw_back_grenades

/datum/human_ai_module/grenade/proc/can_throw_grenades()
	return grenading_allowed

/datum/human_ai_module/grenade/proc/get_friendly_throw_check_range()
	return friendly_throw_check_range

/datum/human_ai_module/grenade/proc/get_throwback_min_safe_throw_distance()
	return throwback_min_safe_throw_distance

/datum/human_ai_module/grenade/proc/get_owner_grenade_throw_target_turf()
	RETURN_TYPE(/turf)
	return brain.get_shared_combat_target_turf() || brain.get_recent_projectile_threat_turf()

/datum/human_ai_module/grenade/proc/find_owner_grenade_for_throw()
	RETURN_TYPE(/obj/item)
	return brain.find_grenade_for_throw()

/datum/human_ai_module/grenade/proc/get_owner_equipment_summary(equipment_type)
	return brain.get_equipment_summary(equipment_type)

/datum/human_ai_module/grenade/proc/get_owner_current_target()
	return brain.get_current_target()

/datum/human_ai_module/grenade/proc/cancel_owner_actions_by_type(list/action_types, datum/ai_action/except = null)
	return brain.cancel_ongoing_actions_by_type(action_types, except)

/datum/human_ai_module/grenade/proc/is_owner_in_combat()
	return brain.is_in_combat()

/datum/human_ai_module/grenade/proc/has_throw_in_progress()
	return throw_mid_action || throwback_mid_action

/datum/human_ai_module/grenade/proc/reset_grenade_throw_state()
	active_throw_grenade = null
	throw_mid_action = FALSE
	throw_finished = FALSE
	throw_range_override = null

/datum/human_ai_module/grenade/proc/set_grenade_throw_mid_action()
	throw_mid_action = TRUE

/datum/human_ai_module/grenade/proc/finish_grenade_throw_action()
	throw_mid_action = FALSE
	throw_finished = TRUE

/datum/human_ai_module/grenade/proc/reset_throwback_state(clear_threat = TRUE)
	if(clear_threat)
		clear_active_grenade()
	throwback_ready_time = 0
	throwback_mid_action = FALSE
	throwback_finished = FALSE

/datum/human_ai_module/grenade/proc/finish_throwback_action()
	throwback_ready_time = 0
	throwback_mid_action = FALSE
	throwback_finished = TRUE

/datum/human_ai_module/grenade/proc/set_throwback_ready_time(new_ready_time)
	throwback_ready_time = new_ready_time

/datum/human_ai_module/grenade/proc/get_throwback_ready_time()
	return throwback_ready_time

/datum/human_ai_module/grenade/proc/set_throwback_mid_action()
	throwback_ready_time = 0
	throwback_mid_action = TRUE

/datum/human_ai_module/grenade/proc/set_throwback_enabled(enabled)
	can_throw_back_grenades = enabled
	if(!enabled)
		clear_active_grenade()

/datum/human_ai_module/grenade/proc/set_throwing_enabled(enabled)
	grenading_allowed = enabled

/datum/human_ai_module/grenade/proc/get_grenade_throw_target_turf()
	RETURN_TYPE(/turf)
	return get_owner_grenade_throw_target_turf()

/datum/human_ai_module/grenade/proc/get_grenade_throw_source()
	RETURN_TYPE(/obj/item)
	return find_owner_grenade_for_throw()

/datum/human_ai_module/grenade/proc/can_attempt_grenade_throw(require_combat = TRUE, require_throw_source = TRUE)
	if(!can_throw_grenades())
		return FALSE
	if(require_combat && !is_owner_in_combat())
		return FALSE
	if(!get_grenade_throw_target_turf())
		return FALSE
	if(require_throw_source && !get_grenade_throw_source())
		return FALSE
	return TRUE

/datum/human_ai_module/grenade/proc/get_active_throwback_grenade()
	RETURN_TYPE(/obj/item/explosive/grenade)
	var/obj/item/explosive/grenade/active_grenade = get_active_grenade()
	if(QDELETED(active_grenade))
		return null
	return active_grenade

/datum/human_ai_module/grenade/proc/can_attempt_grenade_throwback(datum/human_tied_controller/controller, max_distance)
	if(!controller)
		return FALSE
	if(!can_throw_back())
		return FALSE
	var/obj/item/explosive/grenade/active_grenade = get_active_throwback_grenade()
	if(!active_grenade)
		return FALSE
	return controller.get_distance_to(active_grenade) <= max_distance

/datum/human_ai_module/grenade/proc/cancel_throw_conflicting_actions(datum/ai_action/throw_grenade/action, list/action_types)
	if(!action || !length(action_types))
		return
	cancel_owner_actions_by_type(action_types, action)

/datum/human_ai_module/grenade/proc/prepare_grenade_throw_action(datum/human_tied_controller/controller, datum/ai_action/throw_grenade/action, list/conflicting_action_types)
	if(!brain || !action)
		return

	var/datum/human_ai_throwable_context/throwable_context = new(brain)
	active_throw_grenade = GLOB.human_ai_grenade_throw_handler.prepare_grenade_for_throw(throwable_context, get_grenade_throw_source())
	throw_range_override = isnum(active_throw_grenade?.throw_range) ? active_throw_grenade.throw_range : null
	throw_mid_action = FALSE
	throw_finished = FALSE
	log_game("AI GRENADE: throw action created - grenade=[active_throw_grenade] ([active_throw_grenade?.type]), available=[get_owner_equipment_summary(HUMAN_AI_GRENADES)], throw_range=[throw_range_override], mob=[controller?.get_key_name()]")
	qdel(throwable_context)
	cancel_throw_conflicting_actions(action, conflicting_action_types)

/datum/human_ai_module/grenade/proc/cleanup_grenade_throw_action(datum/ai_action/throw_grenade/action)
	reset_grenade_throw_state()

/datum/human_ai_module/grenade/proc/perform_grenade_throw(datum/human_tied_controller/controller, datum/ai_action/throw_grenade/action, list/conflicting_action_types)
	if(!brain)
		return ONGOING_ACTION_COMPLETED

	if(throw_finished)
		return ONGOING_ACTION_COMPLETED

	if(throw_mid_action)
		return ONGOING_ACTION_UNFINISHED_BLOCK

	var/turf/target_turf = get_grenade_throw_target_turf()
	if(QDELETED(active_throw_grenade) || !target_turf)
		log_game("AI GRENADE: throw action aborted - grenade missing or no target, QDELETED=[QDELETED(active_throw_grenade)], target=[target_turf], mob=[controller?.get_key_name()]")
		return ONGOING_ACTION_COMPLETED

	var/datum/human_ai_throwable_context/throwable_context = new(brain, active_throw_grenade, get_owner_current_target(), target_turf, throw_range_override)
	cancel_throw_conflicting_actions(action, conflicting_action_types)
	if(!GLOB.human_ai_grenade_throw_handler.start_throw(throwable_context, action))
		qdel(throwable_context)
		return ONGOING_ACTION_COMPLETED

	throw_range_override = throwable_context.throw_range_override
	qdel(throwable_context)
	return ONGOING_ACTION_UNFINISHED_BLOCK

/datum/human_ai_module/grenade/proc/cleanup_throwback_action(datum/ai_action/throw_back_nade/action)
	reset_throwback_state(TRUE)

/datum/human_ai_module/grenade/proc/perform_throwback(datum/ai_action/throw_back_nade/action)
	if(!brain)
		return ONGOING_ACTION_COMPLETED

	if(throwback_finished)
		return ONGOING_ACTION_COMPLETED

	if(throwback_mid_action)
		return ONGOING_ACTION_UNFINISHED

	var/obj/item/explosive/grenade/active_grenade = get_active_throwback_grenade()
	var/datum/human_ai_throwable_context/throwable_context = new(brain, active_grenade)
	throwable_context.min_safe_throw_distance = throwback_min_safe_throw_distance
	var/result = GLOB.human_ai_grenade_throw_back_handler.continue_throw_back(throwable_context, action)
	qdel(throwable_context)
	return result
