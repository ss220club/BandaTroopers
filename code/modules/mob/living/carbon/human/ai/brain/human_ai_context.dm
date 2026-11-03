// Lightweight Human AI context for new module/action code.

/datum/human_ai_context
	var/datum/human_ai_brain/brain
	var/datum/human_tied_controller/controller

/datum/human_ai_context/New(datum/human_ai_brain/new_brain)
	brain = new_brain
	controller = brain?.get_tied_controller()

/datum/human_ai_context/Destroy(force, ...)
	controller = null
	brain = null
	return ..()

/datum/human_ai_context/proc/is_valid()
	return brain?.can_continue_runtime_work() && controller

/datum/human_ai_context/proc/can_continue()
	return is_valid()

/datum/human_ai_context/proc/get_module(module_type)
	return brain?.get_module(module_type)

/datum/human_ai_context/proc/has_module(module_type)
	return !!get_module(module_type)

/datum/human_ai_context/proc/get_module_by_id(module_id)
	return brain?.get_module_by_id(module_id)

/datum/human_ai_context/proc/has_module_id(module_id)
	return !!get_module_by_id(module_id)

/datum/human_ai_context/proc/get_controller()
	return controller

/datum/human_ai_context/proc/get_brain()
	return brain

/datum/human_ai_brain/proc/get_tied_controller()
	RETURN_TYPE(/datum/human_tied_controller)
	return tied_controller
