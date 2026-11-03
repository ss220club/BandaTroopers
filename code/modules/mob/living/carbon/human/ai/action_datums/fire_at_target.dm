/datum/ai_action/fire_at_target
	name = "Fire At Target"
	action_flags = ACTION_USING_HANDS
	required_ai_modules = list(/datum/human_ai_module/combat, /datum/human_ai_module/guns, /datum/human_ai_module/inventory)

/datum/ai_action/fire_at_target/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	return brain.get_ranged_fire_weight(controller)

/datum/ai_action/fire_at_target/Destroy(force, ...)
	brain?.stop_ranged_fire(TRUE)
	return ..()

/datum/ai_action/fire_at_target/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_ranged_fire(controller, src)
