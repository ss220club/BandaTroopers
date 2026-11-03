/datum/ai_action/treat_self
	name = "Treat Self"
	action_flags = ACTION_USING_HANDS
	required_ai_modules = list(/datum/human_ai_module/health, /datum/human_ai_module/inventory)

/datum/ai_action/treat_self/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	return brain.get_self_treatment_weight(controller)

/datum/ai_action/treat_self/Destroy(force, ...)
	brain?.stop_self_treatment_action()
	return ..()

/datum/ai_action/treat_self/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_self_treatment(controller)
