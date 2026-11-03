// Human AI squad-facing API.
// Squad membership, leader lookup, and current order glue.

/datum/human_ai_brain/proc/is_squad_leader()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.is_leader()

/datum/human_ai_brain/proc/set_squad_leader_status(is_leader)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	squad_module?.set_leader_status(is_leader)

/datum/human_ai_brain/proc/get_squad_id()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.get_squad_id()

/datum/human_ai_brain/proc/has_squad()
	return !!get_squad_id()

/datum/human_ai_brain/proc/set_squad_id(new_squad_id)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	squad_module?.set_squad_id(new_squad_id)

/datum/human_ai_brain/proc/can_assign_squad()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.can_assign()

/datum/human_ai_brain/proc/add_to_squad(new_squad_id)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.add_to_squad(new_squad_id)

/datum/human_ai_brain/proc/get_squad_datum()
	RETURN_TYPE(/datum/human_ai_squad)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.get_squad_datum()

/datum/human_ai_brain/proc/get_squad_leader()
	RETURN_TYPE(/datum/human_ai_brain)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.get_squad_leader()

/datum/human_ai_brain/proc/get_squad_members()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.get_squad_members() || list()

/datum/human_ai_brain/proc/get_squad_follow_distance()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	if(!squad_module)
		return 1
	return squad_module.get_follow_distance()

/datum/human_ai_brain/proc/perform_follow_leader(datum/human_tied_controller/controller)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	if(!squad_module)
		return ONGOING_ACTION_COMPLETED
	return squad_module.perform_follow_leader(controller)

/datum/human_ai_brain/proc/perform_patrol_waypoint(datum/human_tied_controller/controller)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	if(!squad_module)
		return ONGOING_ACTION_COMPLETED
	return squad_module.perform_patrol_waypoint(controller)

/datum/human_ai_brain/proc/get_current_order()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	return squad_module?.get_current_order()

/datum/human_ai_brain/proc/remove_current_order()
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	squad_module?.remove_current_order()

/datum/human_ai_brain/proc/set_current_order(datum/ai_order/order)
	var/datum/human_ai_module/squad/squad_module = get_squad_module()
	squad_module?.set_current_order(order)
