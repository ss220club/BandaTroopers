/datum/human_ai_module/orders
	module_id = "orders"
	/// A targeted turf that we should quickly approach
	var/turf/quick_approach
	/// If TRUE, the AI will not move at all
	var/hold_position = FALSE

/datum/human_ai_module/orders/proc/set_hold_position(new_value)
	hold_position = new_value

/datum/human_ai_module/orders/proc/set_quick_approach(turf/new_turf)
	quick_approach = new_turf

/datum/human_ai_module/orders/proc/get_quick_approach()
	RETURN_TYPE(/turf)
	return quick_approach

/datum/human_ai_module/orders/proc/clear_quick_approach()
	quick_approach = null

/datum/human_ai_module/orders/proc/perform_quick_approach(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/turf/approach_turf = get_quick_approach()
	if(QDELETED(approach_turf))
		return ONGOING_ACTION_COMPLETED

	if(controller.get_distance_from(approach_turf) > 0)
		if(!brain.move_to_turf(approach_turf))
			return ONGOING_ACTION_UNFINISHED

		if(controller.get_distance_from(approach_turf) > 0)
			return ONGOING_ACTION_UNFINISHED

	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/orders/proc/can_move_for_action()
	return !hold_position
