/datum/human_ai_module/profile
	module_id = "profile"
	var/micro_action_delay = 0.2 SECONDS
	var/short_action_delay = 0.5 SECONDS
	var/medium_action_delay = 2 SECONDS
	var/long_action_delay = 5 SECONDS
	/// Global multiplier for all AI action delays
	var/action_delay_mult = 2 // Doubled from 1, gives hAI a believable time between actions

	/// Distance for view checks
	var/view_distance = 6
	/// If TRUE, shoots until the target is dead. Else, stops when downed
	var/shoot_to_kill = TRUE
	/// Should we limit our FOV in case view_distance is more than 7
	var/scope_vision = TRUE

/datum/human_ai_module/profile/proc/get_view_distance()
	return view_distance

/datum/human_ai_module/profile/proc/set_view_distance(new_view_distance)
	view_distance = new_view_distance

/datum/human_ai_module/profile/proc/has_scope_vision()
	return scope_vision

/datum/human_ai_module/profile/proc/should_shoot_to_kill()
	return shoot_to_kill

/datum/human_ai_module/profile/proc/set_shoot_to_kill(new_value)
	shoot_to_kill = new_value

/datum/human_ai_module/profile/proc/get_action_delay()
	return get_short_action_delay(TRUE)

/datum/human_ai_module/profile/proc/get_micro_action_delay()
	return micro_action_delay * action_delay_mult

/datum/human_ai_module/profile/proc/get_short_action_delay(apply_multiplier = FALSE)
	if(apply_multiplier)
		return short_action_delay * action_delay_mult
	return short_action_delay

/datum/human_ai_module/profile/proc/get_medium_action_delay(apply_multiplier = FALSE)
	if(apply_multiplier)
		return medium_action_delay * action_delay_mult
	return medium_action_delay
