// Shared Human AI weapon-use result.

/datum/human_ai_weapon_result
	var/handled = FALSE
	var/keep_action_active = FALSE

/datum/human_ai_weapon_result/proc/complete()
	handled = TRUE
	keep_action_active = FALSE
	return src

/datum/human_ai_weapon_result/proc/continue_action()
	handled = TRUE
	keep_action_active = TRUE
	return src
