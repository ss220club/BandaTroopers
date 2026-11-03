// Human AI conversation API.
// Idle conversation participation checks.

/datum/human_ai_brain/proc/can_try_start_conversation()
	var/datum/human_ai_module/conversation/conversation_module = get_conversation_module()
	return conversation_module?.can_try_start()

/datum/human_ai_brain/proc/can_participate_in_conversation()
	var/datum/human_ai_module/conversation/conversation_module = get_conversation_module()
	return conversation_module?.can_participate()

/datum/human_ai_brain/proc/can_continue_conversation()
	var/datum/human_ai_module/conversation/conversation_module = get_conversation_module()
	return conversation_module?.can_continue()

/datum/human_ai_brain/proc/try_start_conversation(datum/human_tied_controller/controller)
	var/datum/human_ai_module/conversation/conversation_module = get_conversation_module()
	if(!conversation_module)
		return ONGOING_ACTION_COMPLETED
	return conversation_module.try_start_conversation(controller)
