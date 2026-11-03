/datum/human_ai_module/targeting
	module_id = "targeting"
	required_module_types = list(/datum/human_ai_module/perception, /datum/human_ai_module/profile)

	/// Ref to the currently focused (and shooting at) target
	var/atom/movable/current_target
	/// Current focused target turf or explicit target turf.
	var/turf/target_turf
	/// Recent turf where a live target was last seen before being lost.
	var/turf/last_known_target_turf
	/// World time when `last_known_target_turf` was stored.
	var/last_known_target_time = 0
	/// How long a lost visible target remains worth investigating.
	var/last_known_target_memory_duration = 10 SECONDS
	/// Cover can break line of sight; retain that target long enough to leave cover and investigate.
	var/last_known_target_cover_memory_duration = 20 SECONDS
	/// TRUE when the current last-known position was recorded during a cover posture.
	var/last_known_target_from_cover = FALSE
	/// If TRUE, we care about the target being in view after shooting at them. If not, then we only do a line check instead
	var/requires_vision = TRUE
	/// Bonus that keeps the current target stable unless another candidate is clearly better.
	var/current_target_stickiness_score = 18
	/// Minimum score delta required to switch away from a valid current target.
	var/retarget_score_margin = 12
	/// Baseline score before range and opportunity modifiers are applied.
	var/target_score_base = 100
	/// Score lost for each tile of distance to the target.
	var/target_score_distance_penalty = 6
	/// Bonus for an adjacent target that is easy to hit and immediately dangerous.
	var/target_score_adjacent_bonus = 36
	/// Bonus for a nearby target that should usually beat a distant target.
	var/target_score_near_bonus = 16
	/// Bonus for a target with a clear direct fire line.
	var/target_score_clear_line_bonus = 12
	/// Bonus for a conscious living target over downed/disabled targets.
	var/target_score_active_living_bonus = 10
	/// Penalty for downed targets when shoot-to-kill still allows selecting them.
	var/target_score_incapacitated_penalty = 24
	/// Bonus for close living targets that can immediately threaten the owner.
	var/target_score_adjacent_living_threat_bonus = 26
	/// Bonus for living targets still healthy enough to remain a relevant combat threat.
	var/target_score_healthy_living_bonus = 14
	/// Bonus for the most recent visible attacker.
	var/target_score_recent_attacker_bonus = 22
	/// Extra bonus when the recent attacker directly hit this AI.
	var/target_score_direct_hit_attacker_bonus = 18
	/// How long a recent attacker should influence target scoring.
	var/recent_attacker_memory_duration = 5 SECONDS
	/// Ref to the most recent visible projectile threat source.
	var/atom/movable/recent_attacker
	/// World time when `recent_attacker` was stored.
	var/recent_attacker_time = 0
	/// TRUE when the recent projectile threat directly hit this AI.
	var/recent_attacker_direct_hit = FALSE
	var/turf/investigation_center
	var/list/investigation_points
	var/current_investigation_point = 1
	var/max_investigation_distance = 20

/datum/human_ai_module/targeting/Destroy(force, ...)
	lose_target(FALSE)
	. = ..()

/datum/human_ai_module/targeting/reset_module()
	clear_target_turf()
	clear_recent_attacker()
	lose_target(FALSE)

/datum/human_ai_module/targeting/suspend_module(clear_inventory = FALSE)
	clear_target_turf()
	clear_recent_attacker()
	lose_target(FALSE)

/datum/human_ai_module/targeting/proc/can_continue_targeting_work()
	return brain?.can_continue_runtime_work()

/datum/human_ai_module/targeting/proc/can_owner_target(atom/movable/target)
	return brain.can_target(target)

/datum/human_ai_module/targeting/proc/get_owner_targeting_view_distance()
	return brain.get_targeting_view_distance()

/datum/human_ai_module/targeting/proc/emit_owner_target_changed(atom/movable/old_target, atom/movable/new_target)
	return brain.emit_target_changed(old_target, new_target)

/datum/human_ai_module/targeting/proc/get_owner_recent_projectile_threat_turf()
	RETURN_TYPE(/turf)
	return brain.get_recent_projectile_threat_turf()

/datum/human_ai_module/targeting/proc/has_owner_recent_projectile_threat()
	return brain.has_recent_projectile_threat()

/datum/human_ai_module/targeting/proc/has_valid_owner()
	return brain && brain.has_valid_tied_human()

/datum/human_ai_module/targeting/proc/can_owner_move_for_action()
	return brain.can_move_for_action()

/datum/human_ai_module/targeting/proc/is_owner_in_cover()
	return brain.is_in_cover()

/datum/human_ai_module/targeting/proc/move_owner_to_turf(turf/destination)
	return brain.move_to_turf(destination)

/datum/human_ai_module/targeting/proc/get_owner_visible_target_candidates()
	return brain.get_visible_target_candidates()

/datum/human_ai_module/targeting/proc/get_owner_fire_line_safety(atom/target)
	return brain.get_fire_line_safety(target)

/datum/human_ai_module/targeting/process_module(delta_time)
	if(!can_continue_targeting_work())
		return

	var/atom/movable/best_target = get_target()
	if(!has_current_target())
		set_target(best_target)
		return

	if(should_retarget(best_target))
		set_target(best_target)

/datum/human_ai_module/targeting/on_ai_event(datum/human_ai_event/event)
	switch(event.event_type)
		if(HUMAN_AI_EVENT_PROJECTILE_THREAT)
			var/obj/projectile/bullet = event.get_projectile()
			on_projectile_threat(bullet, event.is_from_direct_hit(), event.get_threat_source())
		if(HUMAN_AI_EVENT_COMBAT_EXIT_STARTED)
			on_combat_exit_started(event.should_holster_primary())
		if(HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED, HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED)
			on_combat_exit_finished(event.get_combat_exit_context())
		if(HUMAN_AI_EVENT_BODY_POSITION_CHANGED)
			on_body_position_changed(event.get_new_body_position(), event.get_old_body_position())
		if(HUMAN_AI_EVENT_MOVED)
			on_moved(event.get_old_location(), event.get_direction(), event.was_forced_move())

/datum/human_ai_module/targeting/on_projectile_threat(obj/projectile/bullet, from_direct_hit = FALSE, atom/movable/firer = null)
	if(!can_continue_targeting_work())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(!firer)
		return

	if(!can_owner_target(firer))
		return

	if(controller.get_distance_to(firer) > get_owner_targeting_view_distance())
		return

	remember_recent_attacker(firer, from_direct_hit)
	if(!current_target || should_retarget(firer))
		set_target(firer)

/datum/human_ai_module/targeting/on_combat_exit_started(should_holster_primary = TRUE)
	if(!can_continue_targeting_work())
		return
	if(has_current_target())
		lose_target()

/datum/human_ai_module/targeting/on_combat_exit_finished(list/combat_exit_context)
	if(!can_continue_targeting_work())
		return

	if(combat_exit_context?["force_clear"])
		lose_target(FALSE)

	if(combat_exit_context?["clear_target_turf"])
		if(has_recent_lost_target())
			target_turf = null
		else
			clear_target_turf()

/datum/human_ai_module/targeting/on_body_position_changed(new_position, old_position)
	if(!can_continue_targeting_work())
		return
	if(has_current_target())
		update_target_pos() // SS220 EDIT: refresh transient combat targeting state after knockdown recovery

/datum/human_ai_module/targeting/on_moved(atom/oldloc, direction, forced)
	if(!can_continue_targeting_work())
		return
	update_target_pos()

/datum/human_ai_module/targeting/proc/set_target(atom/movable/new_target)
	if(!can_continue_targeting_work())
		return

	lose_target(FALSE)

	if(!is_valid_target_ref(new_target))
		return

	RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_delete), TRUE)
	RegisterSignal(new_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_move), TRUE)
	if(istype(new_target, /mob/living))
		RegisterSignal(new_target, COMSIG_MOB_DEATH, PROC_REF(on_target_death), TRUE)
	if(istype(new_target, /obj/structure/machinery/defenses))
		RegisterSignal(new_target, COMSIG_SENTRY_DESTROYED_ALERT, PROC_REF(on_target_destroy), TRUE)
	// Vehicles do not currently expose a destroyed signal; target validity is checked by perception.
	/*
	if(istype(new_target, /obj/vehicle/multitile))
		RegisterSignal(new_target, COMSIG_VEHICLE_DESTROYED_ALERT, PROC_REF(on_target_destroy), TRUE)
	*/

	current_target = new_target
	target_turf = get_turf(current_target)
	clear_last_known_target()

	if(brain)
		emit_owner_target_changed(null, current_target)

/datum/human_ai_module/targeting/proc/set_target_turf_direct(turf/new_target_turf)
	target_turf = new_target_turf
	clear_last_known_target()

/datum/human_ai_module/targeting/proc/clear_target_turf()
	target_turf = null
	clear_last_known_target()

/datum/human_ai_module/targeting/proc/get_target_turf()
	RETURN_TYPE(/turf)
	return target_turf || get_last_known_target_turf()

/datum/human_ai_module/targeting/proc/has_target_turf()
	return !!get_target_turf()

/datum/human_ai_module/targeting/proc/get_target_or_threat_turf()
	RETURN_TYPE(/turf)
	var/turf/current_target_turf = get_target_turf()
	if(current_target_turf)
		return current_target_turf
	return get_owner_recent_projectile_threat_turf()

/datum/human_ai_module/targeting/proc/has_target_or_threat_turf()
	if(has_target_turf())
		return TRUE
	return has_owner_recent_projectile_threat()

/datum/human_ai_module/targeting/proc/get_shared_combat_target_turf()
	RETURN_TYPE(/turf)
	return get_current_target_turf()

/datum/human_ai_module/targeting/proc/has_shared_combat_target_turf()
	return !!get_shared_combat_target_turf()

/datum/human_ai_module/targeting/proc/get_chase_target_turf()
	RETURN_TYPE(/turf)
	var/turf/shared_target_turf = get_shared_combat_target_turf()
	if(shared_target_turf)
		return shared_target_turf
	return get_owner_recent_projectile_threat_turf()

/datum/human_ai_module/targeting/proc/perform_chase_target(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	if(has_recent_lost_target())
		return ONGOING_ACTION_COMPLETED

	if(is_owner_in_cover())
		return ONGOING_ACTION_COMPLETED

	if(!can_owner_move_for_action())
		return ONGOING_ACTION_COMPLETED

	var/turf/chase_target_turf = get_chase_target_turf()
	if(QDELETED(chase_target_turf) || has_current_target())
		return ONGOING_ACTION_COMPLETED

	if(controller.get_distance_from(chase_target_turf) > 0)
		if(!move_owner_to_turf(chase_target_turf))
			return ONGOING_ACTION_COMPLETED

		if(controller.get_distance_from(chase_target_turf) > 0)
			return ONGOING_ACTION_COMPLETED

	var/direction = turn(controller.get_current_dir(), pick(90,-90))
	controller.face_dir(direction)

	clear_target_turf()
	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/targeting/proc/get_current_target_turf()
	RETURN_TYPE(/turf)
	return target_turf

/datum/human_ai_module/targeting/proc/get_last_known_target_turf()
	RETURN_TYPE(/turf)
	if(!has_recent_lost_target())
		return null
	return last_known_target_turf

/datum/human_ai_module/targeting/proc/get_lost_target_investigation_max_distance()
	return max_investigation_distance

/datum/human_ai_module/targeting/proc/has_recent_lost_target()
	if(!last_known_target_turf)
		return FALSE
	var/memory_duration = last_known_target_from_cover ? last_known_target_cover_memory_duration : last_known_target_memory_duration
	if((world.time - last_known_target_time) > memory_duration)
		return FALSE
	return TRUE

/datum/human_ai_module/targeting/proc/remember_last_known_target_turf(turf/new_target_turf = null)
	var/turf/remembered_turf = new_target_turf
	if(!remembered_turf)
		remembered_turf = target_turf
	if(!remembered_turf && current_target)
		remembered_turf = get_turf(current_target)
	if(!remembered_turf)
		return FALSE

	last_known_target_turf = remembered_turf
	last_known_target_time = world.time
	last_known_target_from_cover = brain?.has_cover()
	return TRUE

/datum/human_ai_module/targeting/proc/clear_last_known_target()
	last_known_target_turf = null
	last_known_target_time = 0
	last_known_target_from_cover = FALSE

/datum/human_ai_module/targeting/proc/clear_lost_target_investigation()
	investigation_center = null
	investigation_points = null
	current_investigation_point = 1

/datum/human_ai_module/targeting/proc/build_lost_target_investigation_points(turf/center)
	investigation_center = center
	current_investigation_point = 1
	investigation_points = list(center)

	for(var/direction in GLOB.cardinals)
		var/turf/nearby_turf = get_step(center, direction)
		if(!nearby_turf || nearby_turf.density || (nearby_turf in investigation_points))
			continue

		investigation_points += nearby_turf

/datum/human_ai_module/targeting/proc/face_lost_target_investigation_center(datum/human_tied_controller/controller)
	if(!controller || !investigation_center)
		return FALSE

	var/direction = controller.get_direction_to(investigation_center)
	if(!direction)
		return FALSE

	return controller.face_dir(direction)

/datum/human_ai_module/targeting/proc/perform_lost_target_investigation(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	if(has_current_target())
		return ONGOING_ACTION_COMPLETED

	if(!can_owner_move_for_action())
		return ONGOING_ACTION_COMPLETED

	var/turf/last_known_turf = get_last_known_target_turf()
	if(QDELETED(last_known_turf) || !has_recent_lost_target())
		return ONGOING_ACTION_COMPLETED

	if(investigation_center != last_known_turf)
		build_lost_target_investigation_points(last_known_turf)

	while(current_investigation_point <= length(investigation_points))
		var/turf/target_turf = investigation_points[current_investigation_point]
		if(QDELETED(target_turf))
			current_investigation_point++
			continue

		if(controller.get_distance_from(target_turf) > 0)
			if(!move_owner_to_turf(target_turf))
				current_investigation_point++
				continue

			if(controller.get_distance_from(target_turf) > 0)
				return ONGOING_ACTION_UNFINISHED

		face_lost_target_investigation_center(controller)
		current_investigation_point++
		return ONGOING_ACTION_UNFINISHED

	clear_last_known_target()
	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/targeting/proc/get_current_target()
	RETURN_TYPE(/atom/movable)
	return current_target

/datum/human_ai_module/targeting/proc/has_current_target()
	return !!current_target

/datum/human_ai_module/targeting/proc/get_aim_target()
	return current_target || target_turf || get_last_known_target_turf()

/datum/human_ai_module/targeting/proc/lose_target(remember_last_known = TRUE)
	var/atom/movable/old_target = current_target
	if(remember_last_known && current_target)
		remember_last_known_target_turf()

	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
		UnregisterSignal(current_target, COMSIG_MOVABLE_MOVED)
		if(istype(current_target, /mob/living))
			UnregisterSignal(current_target, COMSIG_MOB_DEATH)
		if(istype(current_target, /obj/structure/machinery/defenses))
			UnregisterSignal(current_target, COMSIG_SENTRY_DESTROYED_ALERT)
		// Vehicles do not currently expose a destroyed signal; target validity is checked by perception.
		/*
		if(istype(current_target, /obj/vehicle/multitile))
			UnregisterSignal(current_target, COMSIG_VEHICLE_DESTROYED_ALERT)
		*/

	current_target = null
	target_turf = null
	if(!remember_last_known)
		clear_last_known_target()
	if(old_target == recent_attacker)
		clear_recent_attacker()

	if(brain)
		emit_owner_target_changed(old_target, null)

/datum/human_ai_module/targeting/proc/on_target_delete(datum/source, force)
	SIGNAL_HANDLER
	if(source == recent_attacker)
		clear_recent_attacker()
	lose_target(FALSE)

/datum/human_ai_module/targeting/proc/on_target_death(datum/source)
	SIGNAL_HANDLER
	if(source == recent_attacker)
		clear_recent_attacker()
	lose_target(FALSE)

/datum/human_ai_module/targeting/proc/on_target_destroy(datum/source)
	SIGNAL_HANDLER
	if(source == recent_attacker)
		clear_recent_attacker()
	lose_target(FALSE)

/datum/human_ai_module/targeting/proc/can_handle_runtime_target_signal()
	return can_continue_targeting_work()

/datum/human_ai_module/targeting/proc/on_target_move(atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	if(!can_handle_runtime_target_signal())
		return
	update_target_pos()

/datum/human_ai_module/targeting/proc/update_target_pos()
	if(!can_continue_targeting_work() || !has_valid_owner())
		target_turf = null
		return
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		target_turf = null
		return

	if(current_target)
		if(controller.is_in_view_of(current_target, get_owner_targeting_view_distance()))
			target_turf = get_turf(current_target)
		else
			lose_target()

/datum/human_ai_module/targeting/proc/get_target()
	if(!can_continue_targeting_work() || !has_valid_owner())
		return null
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return null

	var/list/viable_targets = get_owner_visible_target_candidates()
	return get_best_scored_target(viable_targets, controller)

/datum/human_ai_module/targeting/proc/get_best_scored_target(list/viable_targets, datum/human_tied_controller/controller)
	RETURN_TYPE(/atom/movable)
	if(!length(viable_targets) || !controller)
		return null

	var/atom/movable/best_target
	var/best_score = -INFINITY
	for(var/atom/movable/potential_target as anything in viable_targets)
		var/target_score = get_target_score(potential_target, controller)
		if(target_score <= best_score)
			continue

		best_target = potential_target
		best_score = target_score

	return best_target

/datum/human_ai_module/targeting/proc/should_retarget(atom/movable/best_target)
	if(!best_target || best_target == current_target)
		return FALSE
	if(!current_target)
		return TRUE
	if(!can_owner_target(current_target))
		return TRUE

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return FALSE

	var/current_score = get_target_score(current_target, controller)
	var/best_score = get_target_score(best_target, controller)
	return best_score >= (current_score + retarget_score_margin)

/datum/human_ai_module/targeting/proc/get_target_score(atom/movable/potential_target, datum/human_tied_controller/controller)
	if(!is_valid_target_ref(potential_target) || !controller)
		return -INFINITY

	var/distance = controller.get_distance_to(potential_target)
	var/score = target_score_base - (distance * target_score_distance_penalty)

	if(potential_target == current_target)
		score += current_target_stickiness_score

	if(distance <= 1)
		score += target_score_adjacent_bonus
	else if(distance <= 3)
		score += target_score_near_bonus

	if(is_recent_attacker(potential_target))
		score += target_score_recent_attacker_bonus
		if(recent_attacker_direct_hit)
			score += target_score_direct_hit_attacker_bonus

	switch(get_owner_fire_line_safety(potential_target))
		if(HUMAN_AI_FIRE_LINE_CLEAR)
			score += target_score_clear_line_bonus
		if(HUMAN_AI_FIRE_LINE_BLOCKED)
			score -= target_score_clear_line_bonus

	if(istype(potential_target, /mob/living))
		var/mob/living/living_target = potential_target
		if(living_target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in living_target.effects_list))
			score -= target_score_incapacitated_penalty
		else
			score += target_score_active_living_bonus
			if(distance <= 1)
				score += target_score_adjacent_living_threat_bonus
			if(get_living_target_health_ratio(living_target) > 0.35)
				score += target_score_healthy_living_bonus

	return score

/datum/human_ai_module/targeting/proc/remember_recent_attacker(atom/movable/attacker, from_direct_hit = FALSE)
	if(!is_valid_target_ref(attacker))
		return FALSE
	recent_attacker = attacker
	recent_attacker_time = world.time
	recent_attacker_direct_hit = from_direct_hit
	return TRUE

/datum/human_ai_module/targeting/proc/clear_recent_attacker()
	recent_attacker = null
	recent_attacker_time = 0
	recent_attacker_direct_hit = FALSE

/datum/human_ai_module/targeting/proc/is_recent_attacker(atom/movable/target)
	if(!recent_attacker || target != recent_attacker)
		return FALSE
	if((world.time - recent_attacker_time) > recent_attacker_memory_duration)
		clear_recent_attacker()
		return FALSE
	return TRUE

/datum/human_ai_module/targeting/proc/get_living_target_health_ratio(mob/living/target)
	if(!target?.maxHealth)
		return 0
	return target.health / target.maxHealth

/datum/human_ai_module/targeting/proc/is_valid_target_ref(atom/movable/target)
	return target && !QDELETED(target)
