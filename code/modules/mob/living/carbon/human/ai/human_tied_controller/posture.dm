// Raw posture primitives

/datum/human_tied_controller/proc/set_resting(resting, instant = TRUE)
	if(!can_mutate_puppet())
		return FALSE
	tied_human.set_resting(resting, instant)
	return TRUE

/datum/human_tied_controller/proc/set_lying_down()
	if(!can_mutate_puppet())
		return FALSE
	tied_human.set_lying_down()
	return TRUE

// Behavior/migration helpers

// Helper for reconstructing the old prone behavior during migration.
/datum/human_tied_controller/proc/force_prone()
	if(!can_mutate_puppet())
		return FALSE
	if(!tied_human.resting)
		tied_human.set_resting(TRUE, TRUE)
	else
		tied_human.set_lying_down()
	return TRUE

/datum/human_tied_controller/proc/can_stand_up()
	return is_conscious_available() && tied_human.resting && !HAS_TRAIT(tied_human, TRAIT_FLOORED)

// Helper for reconstructing the old stand-up behavior during migration.
/datum/human_tied_controller/proc/try_stand_up()
	if(!can_stand_up())
		return FALSE
	tied_human.set_resting(FALSE, TRUE)
	return TRUE

// Raw buckle primitives

/datum/human_tied_controller/proc/set_buckled(new_value)
	if(!can_mutate_puppet())
		return FALSE
	tied_human.set_buckled(new_value)
	return TRUE

/datum/human_tied_controller/proc/unbuckle()
	if(!can_mutate_puppet() || !tied_human.buckled)
		return FALSE
	tied_human.buckled.unbuckle()
	return TRUE

/datum/human_tied_controller/proc/clear_buckle_state()
	if(!can_mutate_puppet() || !tied_human.buckled)
		return FALSE
	tied_human.set_buckled(FALSE)
	return TRUE
