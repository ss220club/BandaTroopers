// Human AI navigation API.
// Movement requests and pathing profile knobs.

/datum/human_ai_brain/proc/move_to_turf(turf/destination)
	var/datum/human_ai_module/navigation/navigation_module = get_navigation_module()
	return navigation_module?.move_to_next_turf(destination)

/datum/human_ai_brain/proc/move_to_atom(atom/target)
	if(!target)
		return FALSE
	var/datum/human_ai_module/navigation/navigation_module = get_navigation_module()
	return navigation_module?.move_to_next_turf(get_turf(target))

/datum/human_ai_brain/proc/apply_navigation_profile(short_step_range = 0, path_retarget_slack = 0)
	var/datum/human_ai_module/navigation/navigation_module = get_navigation_module()
	navigation_module?.apply_navigation_profile(short_step_range, path_retarget_slack)
