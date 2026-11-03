/datum/ai_action/walk_melee
	name = "Walk Melee"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/melee)

/datum/ai_action/walk_melee/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	return brain?.get_melee_weight() || 0

/datum/ai_action/walk_melee/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	brain?.run_melee_step()

	return ONGOING_ACTION_COMPLETED
