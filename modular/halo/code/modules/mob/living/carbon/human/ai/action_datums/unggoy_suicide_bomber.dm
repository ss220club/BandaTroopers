/datum/ai_action/unggoy_suicide_bomber
	name = "Унггой-смертник"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/targeting, /datum/human_ai_module/navigation, /datum/human_ai_module/inventory, /datum/human_ai_module/action_runtime, /datum/human_ai_module/halo_covenant, /datum/human_ai_module/halo_unggoy)

/datum/ai_action/unggoy_suicide_bomber/get_context_weight(datum/human_ai_context/context)
	return context?.brain?.halo_unggoy_get_suicide_bomber_weight() || 0

/datum/ai_action/unggoy_suicide_bomber/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .
	return context?.brain?.halo_unggoy_run_suicide_bomber_step() || ONGOING_ACTION_COMPLETED
