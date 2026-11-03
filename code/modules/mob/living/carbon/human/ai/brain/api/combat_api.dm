// Human AI combat state API.
// These wrappers keep callers independent from the brain's internal module layout.

/datum/human_ai_brain/proc/is_in_combat()
	var/datum/human_ai_module/combat/combat_module = get_combat_module()
	return combat_module?.is_in_combat()

/datum/human_ai_brain/proc/set_shot_at_turf(turf/target_turf)
	var/datum/human_ai_module/combat/combat_module = get_combat_module()
	combat_module?.set_shot_at_turf(target_turf)

/datum/human_ai_brain/proc/enter_combat()
	var/datum/human_ai_module/combat/combat_module = get_combat_module()
	return combat_module?.enter_combat()

/datum/human_ai_brain/proc/exit_combat()
	var/datum/human_ai_module/combat/combat_module = get_combat_module()
	return combat_module?.exit_combat()
