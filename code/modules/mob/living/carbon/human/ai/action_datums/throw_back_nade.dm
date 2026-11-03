/datum/ai_action/throw_back_nade
	name = "Throw Back Grenade"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/grenade, /datum/human_ai_module/inventory)

/datum/ai_action/throw_back_nade/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	if(!brain.can_attempt_grenade_throwback(controller, brain.get_throwback_min_safe_throw_distance())) // SS220 EDIT: weak AI presets must not enter throw-back mode
		return 0

	return 50

/datum/ai_action/throw_back_nade/Destroy(force, ...)
	var/datum/human_ai_brain/brain = context?.brain
	brain?.cleanup_throwback_action(src)
	return ..()

/datum/ai_action/throw_back_nade/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	if(!brain)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_throwback(src)
