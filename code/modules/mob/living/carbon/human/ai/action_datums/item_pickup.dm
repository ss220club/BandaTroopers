/datum/ai_action/item_pickup
	name = "Item Pickup"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/inventory, /datum/human_ai_module/navigation)

/datum/ai_action/item_pickup/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	return brain.get_item_pickup_weight(controller)

/datum/ai_action/item_pickup/Added()
	var/datum/human_ai_brain/brain = context?.brain
	brain?.start_item_pickup_action()

/datum/ai_action/item_pickup/Destroy(force, ...)
	brain?.stop_item_pickup_action()
	return ..()

/datum/ai_action/item_pickup/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_item_pickup(controller)
