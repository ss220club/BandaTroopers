/datum/ai_action/investigate_lost_target
	name = "Investigate Lost Target"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/targeting, /datum/human_ai_module/navigation)

/datum/ai_action/investigate_lost_target/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	if(brain.has_current_target() || !brain.has_recent_lost_target())
		return 0

	if(!brain.can_move_for_action())
		return 0

	var/turf/last_known_turf = brain.get_last_known_target_turf()
	if(!last_known_turf || controller.get_distance_from(last_known_turf) > brain.get_lost_target_investigation_max_distance())
		return 0

	return 7

/datum/ai_action/investigate_lost_target/get_context_conflicts(datum/human_ai_context/context)
	. = ..()
	. += /datum/ai_action/throw_grenade

/datum/ai_action/investigate_lost_target/Destroy(force, ...)
	brain?.clear_lost_target_investigation()
	return ..()

/datum/ai_action/investigate_lost_target/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_lost_target_investigation(controller)
