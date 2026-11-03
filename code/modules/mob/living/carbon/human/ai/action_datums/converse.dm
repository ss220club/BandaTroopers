/datum/ai_action/converse
	name = "Start Conversation"
	action_flags = ACTION_USING_MOUTH
	required_ai_modules = list(/datum/human_ai_module/conversation)

/datum/ai_action/converse/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	if(!brain?.can_try_start_conversation())
		return 0

	return 1

/datum/ai_action/converse/trigger_action()
	. = ..()
	if(.)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.try_start_conversation(controller)
