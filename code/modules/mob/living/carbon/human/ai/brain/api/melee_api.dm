// Human AI melee API.
// The melee module owns target stepping and hit logic.

/datum/human_ai_brain/proc/can_attempt_melee()
	var/datum/human_ai_module/melee/melee_module = get_melee_module()
	return melee_module?.can_try_melee()

/datum/human_ai_brain/proc/get_melee_weight()
	var/datum/human_ai_module/melee/melee_module = get_melee_module()
	return melee_module?.get_melee_weight() || 0

/datum/human_ai_brain/proc/should_continue_melee()
	var/datum/human_ai_module/melee/melee_module = get_melee_module()
	return melee_module?.should_continue_melee()

/datum/human_ai_brain/proc/run_melee_step()
	var/datum/human_ai_module/melee/melee_module = get_melee_module()
	return melee_module?.run_melee_step()
