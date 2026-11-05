/// Active traversal may temporarily occupy scenery; do not cancel a climb halfway through.
/datum/human_ai_brain/proc/has_navigation_in_progress()
	if(current_path_target || tied_human?.action_busy)
		return TRUE
	for(var/datum/ai_action/action as anything in ongoing_actions)
		if((action.action_flags & ACTION_USING_LEGS) && !istype(action, /datum/ai_action/leave_unsafe_turf))
			return TRUE
	return FALSE
