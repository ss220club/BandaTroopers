/// A live throw owns its slots until the asynchronous release has completed.
/datum/human_ai_brain/proc/action_is_committed(datum/ai_action/action)
	if(istype(action, /datum/ai_action/throw_grenade))
		var/datum/ai_action/throw_grenade/throw_action = action
		return throw_action.mid_throw
	if(istype(action, /datum/ai_action/throw_back_nade))
		var/datum/ai_action/throw_back_nade/return_action = action
		return return_action.mid_throw
	return FALSE

/datum/human_ai_brain/proc/has_live_grenade_emergency()
	return has_valid_tied_human() && !QDELETED(active_grenade_found) && active_grenade_found.active && get_dist(tied_human, active_grenade_found) <= 4

/// Faction safety is independent of whether the enemy is currently visible or targetable.
/datum/human_ai_brain/proc/grenade_would_harm_friendly(mob/possible_friendly)
	return possible_friendly == tied_human || faction_check(possible_friendly)
