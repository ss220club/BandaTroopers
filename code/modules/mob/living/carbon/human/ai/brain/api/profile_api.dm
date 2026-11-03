// Human AI profile API.
// Generic timing, vision, and combat profile values.

/datum/human_ai_brain/proc/get_targeting_view_distance()
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.get_view_distance() || 0

/datum/human_ai_brain/proc/has_scope_vision()
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.has_scope_vision()

/datum/human_ai_brain/proc/should_shoot_to_kill()
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.should_shoot_to_kill()

/datum/human_ai_brain/proc/get_view_distance()
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.get_view_distance() || 0

/datum/human_ai_brain/proc/set_view_distance(new_view_distance)
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	profile_module?.set_view_distance(new_view_distance)

/datum/human_ai_brain/proc/get_action_delay()
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.get_action_delay() || 0

/datum/human_ai_brain/proc/get_micro_action_delay()
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.get_micro_action_delay() || 0

/datum/human_ai_brain/proc/get_short_action_delay(apply_multiplier = FALSE)
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.get_short_action_delay(apply_multiplier) || 0

/datum/human_ai_brain/proc/get_medium_action_delay(apply_multiplier = FALSE)
	var/datum/human_ai_module/profile/profile_module = get_profile_module()
	return profile_module?.get_medium_action_delay(apply_multiplier) || 0
