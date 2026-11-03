/datum/ai_action/take_cover
	name = "Take Cover"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/cover, /datum/human_ai_module/navigation, /datum/human_ai_module/inventory)

/datum/ai_action/take_cover/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain?.has_valid_tied_human() || !controller) // SS220 EDIT: upstream cover action must not score after modular owner teardown
		return 0

	return brain.get_cover_action_weight(controller, brain.get_gun_data())

/datum/ai_action/take_cover/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_cover_move(controller)
