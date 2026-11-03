/datum/ai_action/select_primary
	name = "Select Primary"
	action_flags = ACTION_USING_HANDS
	required_ai_modules = list(/datum/human_ai_module/guns, /datum/human_ai_module/inventory)

/datum/ai_action/select_primary/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	if(!brain.has_secondary_weapons())
		return 0

	if(!brain.has_tried_reload() && brain.has_primary_weapon())
		return 0

	if(controller.can_use_item(brain.get_primary_weapon()))
		return 0

	return 12

/datum/ai_action/select_primary/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	UNLINT(brain.select_primary_weapon(controller))
	return ONGOING_ACTION_COMPLETED
