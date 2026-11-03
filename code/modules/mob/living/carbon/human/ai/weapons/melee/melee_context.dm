// Human AI melee weapon-use context.

/datum/human_ai_melee_context
	parent_type = /datum/human_ai_weapon_context

/datum/human_ai_melee_context/proc/is_adjacent_to_target()
	if(!is_valid() || !current_target)
		return FALSE
	return controller.get_distance_to(current_target) <= 1
