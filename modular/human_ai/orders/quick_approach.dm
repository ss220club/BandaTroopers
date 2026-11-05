/datum/ai_action/quick_approach
	name = "Quick Approach"
	action_flags = ACTION_USING_LEGS
	var/navigation_failure_count = 0
	var/oscillation_returns = 0
	var/turf/previous_turf

/datum/ai_action/quick_approach/get_weight(datum/human_ai_brain/brain)
	if(!brain.quick_approach || brain.hold_position)
		return 0

	if(brain.has_live_grenade_emergency() || brain.healing_someone || brain.get_priority_ally_treatment_target())
		return 0

	return INFINITY

/datum/ai_action/quick_approach/Destroy(force, ...)
	previous_turf = null
	return ..()

/datum/ai_action/quick_approach/trigger_action()
	. = ..()

	var/turf/approach_turf = brain.quick_approach
	if(QDELETED(approach_turf))
		brain.quick_approach = null
		return ONGOING_ACTION_COMPLETED

	var/mob/tied_human = brain.tied_human
	if(get_dist(approach_turf, tied_human) > 0)
		var/turf/before_move = get_turf(tied_human)
		if(!brain.move_to_next_turf(approach_turf))
			navigation_failure_count++
			if(navigation_failure_count >= 3)
				brain.quick_approach = null
				brain.clear_navigation_path()
				return ONGOING_ACTION_COMPLETED
			return ONGOING_ACTION_UNFINISHED

		var/turf/after_move = get_turf(tied_human)
		if(after_move != before_move)
			navigation_failure_count = 0
			if(after_move == previous_turf)
				oscillation_returns++
			else
				oscillation_returns = 0
			previous_turf = before_move
			if(oscillation_returns >= 2)
				brain.quick_approach = null
				brain.clear_navigation_path()
				return ONGOING_ACTION_COMPLETED

		if(get_dist(approach_turf, tied_human) > 0)
			return ONGOING_ACTION_UNFINISHED

	brain.quick_approach = null
	return ONGOING_ACTION_COMPLETED
