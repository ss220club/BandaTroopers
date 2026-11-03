/datum/human_ai_module/melee
	module_id = "melee"
	required_module_types = list(
		/datum/human_ai_module/targeting,
		/datum/human_ai_module/navigation,
		/datum/human_ai_module/cover,
		/datum/human_ai_module/grenade,
		/datum/human_ai_module/combat,
		/datum/human_ai_module/guns,
		/datum/human_ai_module/orders,
		/datum/human_ai_module/emplacement,
	)

	var/melee_weight = 3

/datum/human_ai_module/melee/proc/get_owner_current_target()
	RETURN_TYPE(/atom/movable)
	return brain.get_current_target()

/datum/human_ai_module/melee/proc/can_owner_move_for_action()
	return brain.can_move_for_action()

/datum/human_ai_module/melee/proc/has_owner_sniper_home()
	return brain.has_sniper_home()

/datum/human_ai_module/melee/proc/can_owner_use_ranged_weapon()
	return brain.can_use_ranged_weapon()

/datum/human_ai_module/melee/proc/has_owner_active_grenade()
	return brain.has_active_grenade()

/datum/human_ai_module/melee/proc/has_owner_pending_cover()
	return brain.has_pending_cover()

/datum/human_ai_module/melee/proc/move_owner_to_atom(atom/target)
	return brain.move_to_atom(target)

/datum/human_ai_module/melee/proc/can_try_melee()
	if(!context?.is_valid())
		return FALSE

	if(!get_owner_current_target())
		return FALSE

	if(!can_owner_move_for_action())
		return FALSE

	if(has_owner_sniper_home())
		return FALSE

	if(can_owner_use_ranged_weapon())
		return FALSE

	return TRUE

/datum/human_ai_module/melee/proc/get_melee_weight()
	return can_try_melee() ? melee_weight : 0

/datum/human_ai_module/melee/proc/should_continue_melee()
	if(!can_try_melee())
		return FALSE

	if(has_owner_active_grenade())
		return FALSE

	if(has_owner_pending_cover())
		return FALSE

	if(can_owner_use_ranged_weapon())
		return FALSE

	return TRUE

/datum/human_ai_module/melee/proc/attack_current_target_if_adjacent()
	var/datum/human_tied_controller/controller = context?.controller
	var/atom/movable/current_target = get_owner_current_target()
	if(!controller || !current_target)
		return FALSE

	if(controller.get_distance_to(current_target) > 1)
		return FALSE

	var/datum/human_ai_melee_context/melee_context = new(brain, null, current_target)
	. = GLOB.human_ai_melee_handler.attack(melee_context)
	qdel(melee_context)

/datum/human_ai_module/melee/proc/approach_current_target()
	var/atom/movable/current_target = get_owner_current_target()
	if(!current_target)
		return FALSE

	return move_owner_to_atom(current_target)

/datum/human_ai_module/melee/proc/run_melee_step()
	if(!should_continue_melee())
		return FALSE

	attack_current_target_if_adjacent()
	return approach_current_target()
