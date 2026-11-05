/datum/ai_action/chase_target
	name = "Search For Lost Target"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/chase_target/get_weight(datum/human_ai_brain/brain)
	if(brain.current_target || brain.hold_position || brain.has_live_grenade_emergency())
		return 0
	return (brain.pursuit_active || brain.pursuit_returning || brain.pursuit_can_start()) ? 6 : 0

/datum/ai_action/chase_target/get_conflicts(datum/human_ai_brain/brain)
	. = ..()
	. += /datum/ai_action/throw_grenade

/datum/ai_action/chase_target/trigger_action()
	. = ..()
	if(!brain.has_valid_tied_human() || !get_weight(brain))
		return ONGOING_ACTION_COMPLETED
	brain.pursuit_update()
	if(!brain.pursuit_active && !brain.pursuit_returning)
		if(!brain.pursuit_can_start())
			return ONGOING_ACTION_COMPLETED
		brain.pursuit_start()
	var/turf/goal = brain.pursuit_goal
	if(!isturf(goal))
		brain.pursuit_finish(FALSE)
		return ONGOING_ACTION_COMPLETED
	var/turf/position = get_turf(brain.tied_human)
	if(brain.pursuit_has_reached_goal())
		if(brain.pursuit_returning)
			brain.pursuit_clear_search()
		else if(brain.pursuit_role == 1)
			brain.tied_human.face_atom(brain.pursuit_anchor)
		else
			brain.tied_human.face_dir(turn(brain.tied_human.dir, 90))
			brain.pursuit_next_point()
		return ONGOING_ACTION_COMPLETED
	if(position != brain.pursuit_progress_turf)
		brain.pursuit_progress_turf = position
		brain.pursuit_progress_at = world.time
	if(world.time > brain.pursuit_progress_at + 4 SECONDS && !brain.tied_human.action_busy)
		if(brain.pursuit_returning)
			brain.pursuit_clear_search()
		else
			brain.pursuit_next_point()
		return ONGOING_ACTION_COMPLETED
	brain.pursuit_moving = TRUE
	// A failed step may just mean the door is opening. Keep this goal until
	// actual progress or the bounded no-progress timeout above.
	brain.move_to_next_turf(goal)
	brain.pursuit_moving = FALSE
	return ONGOING_ACTION_COMPLETED
