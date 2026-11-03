/datum/human_ai_module/health/proc/set_injured_ally(mob/living/new_target)
	if(!can_continue_health_work() || !new_target)
		return

	if(found_injured_ally == new_target)
		return

	lose_injured_ally()
	RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(lose_injured_ally), TRUE)
	RegisterSignal(new_target, COMSIG_MOB_DEATH, PROC_REF(lose_injured_ally), TRUE)
	found_injured_ally = new_target

/datum/human_ai_module/health/proc/lose_injured_ally()
	if(QDELETED(src))
		return

	if(found_injured_ally)
		UnregisterSignal(found_injured_ally, COMSIG_PARENT_QDELETING)
		UnregisterSignal(found_injured_ally, COMSIG_MOB_DEATH)
	found_injured_ally = null

/datum/human_ai_module/health/proc/get_injured_ally()
	if(!can_continue_health_work())
		return null

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return null

	var/mob/living/carbon/human/best_target
	var/best_score = -INFINITY
	var/best_distance = INFINITY

	for(var/mob/living/carbon/human/possible_buddy as anything in GLOB.alive_human_list)
		if(controller.is_puppet(possible_buddy))
			continue

		if(controller.get_z() != possible_buddy.z)
			continue

		if(!is_owner_friendly_target(possible_buddy))
			continue

		if(!controller.is_in_view_of(possible_buddy, get_owner_view_distance()))
			continue

		var/distance = controller.get_distance_to(possible_buddy)
		if(distance > get_owner_view_distance())
			continue

		if(!can_treat_ally(possible_buddy))
			continue

		var/score = get_ally_treatment_priority(possible_buddy, distance)
		if(score < best_score)
			continue

		if(score == best_score && distance >= best_distance)
			continue

		best_target = possible_buddy
		best_score = score
		best_distance = distance

	return best_target

/datum/human_ai_module/health/proc/healing_start_check(mob/living/carbon/human/target)
	if(!target)
		return FALSE
	return ((target.health / target.maxHealth) <= healing_start_threshold) || target.is_bleeding() || target.has_broken_limbs()

/datum/human_ai_module/health/proc/healing_start_check_controller(datum/human_tied_controller/controller)
	return controller && ((controller.get_health_ratio() <= healing_start_threshold) || controller.is_bleeding() || controller.has_broken_limbs())
