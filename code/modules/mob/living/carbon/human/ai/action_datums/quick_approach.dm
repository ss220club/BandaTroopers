/datum/ai_action/quick_approach
	name = "Quick Approach"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/orders, /datum/human_ai_module/navigation)

/datum/ai_action/quick_approach/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	if(!brain?.get_quick_approach_turf())
		return 0

	if(!brain.can_move_for_action())
		return 0

	return INFINITY

/datum/ai_action/quick_approach/Destroy(force, ...)
	brain?.clear_quick_approach()
	return ..()

/datum/ai_action/quick_approach/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_quick_approach(controller)
