/datum/human_ai_module/health/proc/can_self_treat(datum/human_tied_controller/controller)
	if(!controller)
		return FALSE

	var/mob/living/carbon/human/self_target = controller.get_self_target()
	return has_applicable_treatment_for(self_target) && healing_start_check_controller(controller)

/datum/human_ai_module/health/proc/can_treat_under_current_combat_pressure()
	return brain && !has_owner_current_target() && !has_owner_offscreen_fire_target()

/datum/human_ai_module/health/proc/has_emergency_self_treatment_need(datum/human_tied_controller/controller)
	if(!controller?.can_read_puppet() || controller.is_dead())
		return FALSE
	if(controller.is_on_fire())
		return FALSE
	if(controller.get_health() <= HEALTH_THRESHOLD_CRIT)
		return TRUE
	if(controller.get_health_ratio() <= 0.35)
		return TRUE
	if(controller.get_brute_loss() >= 35)
		return TRUE
	if(controller.get_fire_loss() >= 35)
		return TRUE
	if(controller.get_tox_loss() >= 25)
		return TRUE
	if(controller.get_oxy_loss() >= 25)
		return TRUE
	return FALSE

/datum/human_ai_module/health/proc/can_emergency_self_treat(datum/human_tied_controller/controller)
	if(can_treat_under_current_combat_pressure())
		return FALSE
	if(!has_emergency_self_treatment_need(controller))
		return FALSE
	var/mob/living/carbon/human/self_target = controller?.get_self_target()
	return has_applicable_treatment_for(self_target)

/datum/human_ai_module/health/proc/can_continue_emergency_self_treatment(datum/human_tied_controller/controller)
	if(can_treat_under_current_combat_pressure())
		return FALSE
	return has_emergency_self_treatment_need(controller)

/datum/human_ai_module/health/proc/has_tactical_self_treatment_need(datum/human_tied_controller/controller)
	if(!controller?.can_read_puppet() || controller.is_dead() || controller.is_on_fire())
		return FALSE
	if(can_treat_under_current_combat_pressure() || has_emergency_self_treatment_need(controller))
		return FALSE
	if(controller.get_health_ratio() > tactical_treatment_health_threshold && !controller.is_bleeding() && !controller.has_broken_limbs())
		return FALSE

	var/mob/living/carbon/human/self_target = controller.get_self_target()
	return has_applicable_treatment_for(self_target) && healing_start_check_controller(controller)

/datum/human_ai_module/health/proc/can_tactical_self_treat(datum/human_tied_controller/controller)
	return brain?.is_in_cover() && has_tactical_self_treatment_need(controller)

/datum/human_ai_module/health/proc/can_start_self_treatment_now(datum/human_tied_controller/controller)
	return (can_treat_under_current_combat_pressure() || can_emergency_self_treat(controller) || can_tactical_self_treat(controller)) && can_self_treat(controller)

/datum/human_ai_module/health/proc/can_continue_self_treatment_now(datum/human_tied_controller/controller)
	if(!can_treat_under_current_combat_pressure() && !can_continue_emergency_self_treatment(controller) && !can_tactical_self_treat(controller))
		return FALSE
	var/mob/living/carbon/human/self_target = controller?.get_self_target()
	return self_target && !QDELETED(self_target) && self_target.stat != DEAD

/datum/human_ai_module/health/proc/get_self_treatment_weight(datum/human_tied_controller/controller)
	if(!controller)
		return 0

	if(controller.is_zombie())
		return 0

	if(is_treating())
		return 0

	if(brain.has_pickup_queue())
		return 0

	if(!can_retry_self_treatment())
		return 0

	if(!can_start_self_treatment_now(controller))
		return 0

	if(can_emergency_self_treat(controller))
		return 13
	if(can_tactical_self_treat(controller))
		return 13

	return 4

/datum/human_ai_module/health/proc/stop_self_treatment_action()
	cancel_treatment()

/datum/human_ai_module/health/proc/perform_self_treatment(datum/human_tied_controller/controller)
	if(!controller)
		return ONGOING_ACTION_COMPLETED

	if(!can_continue_self_treatment_now(controller))
		return ONGOING_ACTION_COMPLETED

	if(controller.is_on_fire())
		return ONGOING_ACTION_COMPLETED

	if(is_treating())
		return ONGOING_ACTION_UNFINISHED

	if(can_start_self_treatment_now(controller))
		if(!start_healing_controller(controller))
			increment_treatment_stacks()
		return ONGOING_ACTION_UNFINISHED

	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/health/proc/can_treat_ally(mob/living/carbon/human/target)
	if(!target || QDELETED(target) || target.stat == DEAD)
		return FALSE
	if(!is_owner_friendly_target(target))
		return FALSE
	return healing_start_check(target) && has_applicable_treatment_for(target)

/datum/human_ai_module/health/proc/can_start_ally_treatment_now(mob/living/carbon/human/target)
	return can_treat_under_current_combat_pressure() && can_treat_ally(target)

/datum/human_ai_module/health/proc/can_continue_ally_treatment_now(mob/living/carbon/human/target)
	if(!can_treat_under_current_combat_pressure())
		return FALSE
	if(!target || QDELETED(target) || target.stat == DEAD)
		return FALSE
	return is_owner_friendly_target(target)

/datum/human_ai_module/health/proc/get_ally_treatment_priority(mob/living/carbon/human/target, distance = 0)
	if(!target || !target.maxHealth)
		return -INFINITY

	var/health_ratio = target.health / target.maxHealth
	var/score = 0

	if(target.health <= HEALTH_THRESHOLD_CRIT)
		score += 120
	if(health_ratio <= 0.25)
		score += 100
	else if(health_ratio <= 0.5)
		score += 60
	else if(health_ratio <= healing_start_threshold)
		score += 25

	if(target.is_bleeding())
		score += 45
	if(target.has_broken_limbs())
		score += 30

	score += min(target.getBruteLoss(), 40)
	score += min(target.getFireLoss(), 40)
	score += min(target.getToxLoss(), 25)
	score += min(target.getOxyLoss(), 25)
	score -= min(distance * 2, 30)

	return score

/datum/human_ai_module/health/proc/get_ally_treatment_candidate()
	var/mob/living/carbon/human/injured_ally = get_injured_ally()
	if(!can_start_ally_treatment_now(injured_ally))
		return null
	return injured_ally

/datum/human_ai_module/health/proc/get_ally_treatment_weight(datum/human_tied_controller/controller)
	if(!controller)
		return 0

	if(controller.is_zombie())
		return 0

	if(is_treating())
		return 0

	if(brain.has_pickup_queue())
		return 0

	if(!get_ally_treatment_candidate())
		return 0

	return 5

/datum/human_ai_module/health/proc/start_ally_treatment_action()
	active_ally_treatment_target = get_ally_treatment_candidate()
	if(active_ally_treatment_target)
		set_injured_ally(active_ally_treatment_target)
	return !!active_ally_treatment_target

/datum/human_ai_module/health/proc/stop_ally_treatment_action()
	active_ally_treatment_target = null
	lose_injured_ally()
	cancel_treatment()

/datum/human_ai_module/health/proc/perform_ally_treatment(datum/human_tied_controller/controller)
	if(!controller)
		return ONGOING_ACTION_COMPLETED

	if(!can_continue_ally_treatment_now(active_ally_treatment_target))
		return ONGOING_ACTION_COMPLETED

	if(is_treating())
		return ONGOING_ACTION_UNFINISHED

	if(!can_start_ally_treatment_now(active_ally_treatment_target))
		return ONGOING_ACTION_COMPLETED

	if(controller.get_distance_to(active_ally_treatment_target) > 1)
		if(!brain.move_to_atom(active_ally_treatment_target))
			return ONGOING_ACTION_COMPLETED
		if(controller.get_distance_to(active_ally_treatment_target) > 1)
			return ONGOING_ACTION_UNFINISHED

	if(!start_healing(active_ally_treatment_target) && !is_treating())
		return ONGOING_ACTION_COMPLETED

	return ONGOING_ACTION_UNFINISHED
