/datum/ai_action/patrol_waypoints
	name = "Patrol Waypoints"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/navigation, /datum/human_ai_module/squad, /datum/human_ai_module/combat)

/datum/ai_action/patrol_waypoints/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	if(brain.is_in_combat())
		return 0

	var/datum/ai_order/patrol/current_order = brain.get_current_order()
	if(!istype(current_order))
		return 0

	if(brain.has_pickup_queue())
		return 0

	if(current_order.waiting)
		return 0

	if(!brain.is_squad_leader())
		if(controller.get_distance_to(current_order.current_waypoint) <= 1)
			return 0

	return 4

/datum/ai_action/patrol_waypoints/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_patrol_waypoint(controller)
