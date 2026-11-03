/datum/ai_action/reload
	name = "Reload"
	action_flags = ACTION_USING_HANDS
	required_ai_modules = list(/datum/human_ai_module/guns, /datum/human_ai_module/inventory)

/datum/ai_action/reload/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	if(!brain)
		return 0

	if(brain.has_tried_reload())
		return 0

	if(!brain.has_gun_data())
		return 0

	if(!brain.should_reload())
		return 0

	return 15

/datum/ai_action/reload/Destroy(force, ...)
	brain?.stop_reload(TRUE)
	return ..()

/datum/ai_action/reload/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_reload(controller, src)
