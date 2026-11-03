/datum/ai_action/treat_ally
	name = "Treat Ally"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/health, /datum/human_ai_module/inventory, /datum/human_ai_module/navigation)

/datum/ai_action/treat_ally/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	return brain.get_ally_treatment_weight(controller)

/datum/ai_action/treat_ally/Added()
	var/datum/human_ai_brain/brain = context?.brain
	brain?.start_ally_treatment_action()

/datum/ai_action/treat_ally/Destroy(force, ...)
	brain?.stop_ally_treatment_action()
	return ..()

/datum/ai_action/treat_ally/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_ally_treatment(controller)
