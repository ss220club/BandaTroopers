// Human AI orders API.
// Order-gated movement and quick-approach transient state.

/datum/human_ai_brain/proc/can_move_for_action()
	var/datum/human_ai_module/orders/orders_module = get_orders_module()
	return !orders_module || orders_module.can_move_for_action()

/datum/human_ai_brain/proc/get_quick_approach_turf()
	RETURN_TYPE(/turf)
	var/datum/human_ai_module/orders/orders_module = get_orders_module()
	return orders_module?.get_quick_approach()

/datum/human_ai_brain/proc/clear_quick_approach()
	var/datum/human_ai_module/orders/orders_module = get_orders_module()
	orders_module?.clear_quick_approach()

/datum/human_ai_brain/proc/set_quick_approach(turf/new_turf)
	var/datum/human_ai_module/orders/orders_module = get_orders_module()
	orders_module?.set_quick_approach(new_turf)

/datum/human_ai_brain/proc/perform_quick_approach(datum/human_tied_controller/controller)
	var/datum/human_ai_module/orders/orders_module = get_orders_module()
	if(!orders_module)
		return ONGOING_ACTION_COMPLETED
	return orders_module.perform_quick_approach(controller)

/datum/human_ai_brain/proc/set_hold_position(new_value)
	var/datum/human_ai_module/orders/orders_module = get_orders_module()
	orders_module?.set_hold_position(new_value)
