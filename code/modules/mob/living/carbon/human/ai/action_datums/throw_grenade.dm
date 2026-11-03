/datum/ai_action/throw_grenade
	name = "Throw Grenade"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS // SS220 EDIT: grenade priming/throwing should own both hand and movement slots until it resolves
	required_ai_modules = list(/datum/human_ai_module/grenade, /datum/human_ai_module/inventory, /datum/human_ai_module/combat, /datum/human_ai_module/guns, /datum/human_ai_module/action_runtime)

/datum/ai_action/throw_grenade/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	if(!brain.can_attempt_grenade_throw())
		return 0

	if(!brain.has_primary_weapon())
		return 10

	var/turf/target_turf = brain.get_grenade_throw_target_turf()
	if(locate(/turf/closed) in controller.get_line_to(target_turf))
		return 10

	return 0

/datum/ai_action/throw_grenade/get_context_conflicts(datum/human_ai_context/context)
	. = ..()
	. += /datum/ai_action/chase_target
	. += /datum/ai_action/investigate_lost_target
	. += /datum/ai_action/sniper_nest

/datum/ai_action/throw_grenade/Added()
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain)
		return

	brain.prepare_grenade_throw_action(controller, src, get_context_conflicts(context))

/datum/ai_action/throw_grenade/Destroy(force, ...)
	brain?.cleanup_grenade_throw_action(src)
	return ..()

/datum/ai_action/throw_grenade/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_grenade_throw(controller, src, get_context_conflicts(context))
