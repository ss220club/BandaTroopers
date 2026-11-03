/datum/ai_action/machinegunner_nest
	name = "Machinegunner Nest"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/emplacement, /datum/human_ai_module/guns, /datum/human_ai_module/inventory, /datum/human_ai_module/navigation, /datum/human_ai_module/profile)

/datum/ai_action/machinegunner_nest/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	if(!brain)
		return 0

	return brain.get_machinegunner_nest_weight()

/datum/ai_action/machinegunner_nest/Added()
	var/datum/human_ai_brain/brain = context?.brain
	brain?.start_stationary_nest_action()

/datum/ai_action/machinegunner_nest/Destroy(force, ...)
	brain?.stop_stationary_nest_action()
	return ..()

/datum/ai_action/machinegunner_nest/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_machinegunner_nest(controller)
