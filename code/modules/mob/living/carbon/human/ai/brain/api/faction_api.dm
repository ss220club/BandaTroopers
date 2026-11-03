// Human AI faction API.
// Friendly/hostile checks and faction memory.

/datum/human_ai_brain/proc/is_friendly_target(atom/target)
	var/datum/human_ai_module/faction/faction_module = get_faction_module()
	return faction_module?.faction_check(target)

/datum/human_ai_brain/proc/get_previous_faction()
	var/datum/human_ai_module/faction/faction_module = get_faction_module()
	return faction_module?.get_previous_faction()

/datum/human_ai_brain/proc/set_previous_faction(new_faction)
	var/datum/human_ai_module/faction/faction_module = get_faction_module()
	faction_module?.set_previous_faction(new_faction)
