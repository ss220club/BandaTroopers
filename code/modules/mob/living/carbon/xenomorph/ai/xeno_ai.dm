/mob/living/carbon/xenomorph
	// AI stuff
	var/atom/movable/current_target

	var/next_path_generation = 0
	var/list/current_path
	var/turf/current_target_turf

	var/ai_move_delay = 0
	var/path_update_period = (0.5 SECONDS)
	var/ai_range = 16
	var/max_travel_distance = 24

	var/ai_timeout_time = 0
	var/ai_timeout_period = 2 SECONDS

	var/list/datum/action/xeno_action/registered_ai_abilities = list()

	var/datum/xeno_ai_movement/ai_movement_handler

	/// The time interval before this xeno should forcefully get a new target
	var/forced_retarget_time = (10 SECONDS)

	/// The actual cooldown declaration for forceful retargeting, reference forced_retarget_time for time in between checks
	COOLDOWN_DECLARE(forced_retarget_cooldown)

	/// The time interval between calculating new paths if we cannot find a path
	var/no_path_found_period = (2.5 SECONDS)

	/// Cooldown declaration for delaying finding a new path if no path was found
	COOLDOWN_DECLARE(no_path_found_cooldown)

	var/ai_active_intent = INTENT_HARM
	var/target_unconscious = FALSE
	/// When TRUE, legacy process_ai will skip override component handling.
	var/v2_skip_override_handling = FALSE
	/// When TRUE, legacy process_ai will skip movement handling (delegated to v2 movement plugins).
	var/v2_skip_movement_handling = FALSE

/mob/living/carbon/xenomorph/proc/init_movement_handler()
	return new /datum/xeno_ai_movement(src)

/mob/living/carbon/xenomorph/proc/handle_ai_shot(obj/projectile/P)
	SEND_SIGNAL(src, COMSIG_XENO_HANDLE_AI_SHOT, P)

	if(current_target || !P.firer)
		return

	var/distance = get_dist(src, P.firer)
	if(distance > max_travel_distance)
		return

	SSpathfinding.calculate_path(src, P.firer, distance, src, CALLBACK(src, PROC_REF(set_path)), list(src, P.firer))

/mob/living/carbon/xenomorph/proc/register_ai_action(datum/action/xeno_action/XA)
	if(XA.owner != src)
		XA.give_to(src)
	registered_ai_abilities |= XA
	XA.ai_registered(src)

/mob/living/carbon/xenomorph/proc/unregister_ai_action(datum/action/xeno_action/XA)
	registered_ai_abilities -= XA
	XA.ai_unregistered(src)

/mob/living/carbon/xenomorph/proc/process_ai(delta_time)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(!hive || !get_turf(src))
		return TRUE

	if(is_mob_incapacitated(TRUE)) ///If they are incapacitated, the rest doesn't matter.
		current_path = null
		return TRUE

	if(!v2_skip_override_handling)
		var/datum/component/ai_behavior_override/behavior_override = check_overrides()
		if(behavior_override?.process_override_behavior(src, delta_time))
			return TRUE

	if(QDELETED(current_target) || !current_target.ai_check_stat(src) || get_dist(current_target, src) > ai_range || COOLDOWN_FINISHED(src, forced_retarget_cooldown))
		current_target = get_target(ai_range)
		COOLDOWN_START(src, forced_retarget_cooldown, forced_retarget_time)
		if(QDELETED(src))
			return TRUE

		if(current_target)
			set_resting(FALSE, FALSE, TRUE)
			if(prob(5))
				emote("hiss")

	a_intent = ai_active_intent

	if(!current_target)
		if(!v2_skip_movement_handling)
			ai_move_idle(delta_time)
		return TRUE

	if(!v2_skip_movement_handling && ai_move_target(delta_time))
		return TRUE

	for(var/x in registered_ai_abilities)
		var/datum/action/xeno_action/XA = x
		if(QDELETED(XA) || XA.owner != src)
			unregister_ai_action(XA)
			continue

		if(XA.hidden)
			continue

		if(XA.process_ai(src, delta_time) == PROCESS_KILL)
			unregister_ai_action(XA)

	if(!current_target || !DT_PROB(XENO_SLASH, delta_time))
		return

	var/list/turf/turfs_to_dist_check = list(get_turf(current_target))

	if(istype(current_target, /atom/movable) && length(current_target.locs) > 1)
		turfs_to_dist_check = get_multitile_turfs_to_check()

	for(var/turf/checked_turf as anything in turfs_to_dist_check)
		if(get_dist(src, checked_turf) > 1)
			continue
		INVOKE_ASYNC(src, PROC_REF(do_click), current_target, "", list())
		return

/** Controls movement when idle. Called by process_ai */
/mob/living/carbon/xenomorph/proc/ai_move_idle(delta_time)
	if(!ai_movement_handler)
		CRASH("No valid movement handler for [src]!")
	ai_movement_handler.ai_move_idle(delta_time)

/** Controls movement towards target. Called by process_ai */
/mob/living/carbon/xenomorph/proc/ai_move_target(delta_time)
	if(!ai_movement_handler)
		CRASH("No valid movement handler for [src]!")
	return ai_movement_handler.ai_move_target(delta_time)

/atom/proc/xeno_ai_obstacle(mob/living/carbon/xenomorph/X, direction, turf/target)
	if(get_turf(src) == target)
		return 0
	return INFINITY

/atom/proc/ai_check_stat(mob/living/carbon/xenomorph/X)
	return TRUE // So we aren't trying to find a new target on attack override

// Called whenever an obstacle is encountered but xeno_ai_obstacle returned something else than infinite
// and now it is considered a valid path.
/atom/proc/xeno_ai_act(mob/living/carbon/xenomorph/X)
	X.do_click(src, "", list())
	return TRUE

/mob/living/carbon/xenomorph/proc/can_move_and_apply_move_delay()
	// Unable to move, try next time.
	if(ai_move_delay > world.time || !(mobility_flags & MOBILITY_MOVE) || is_mob_incapacitated(TRUE) || (body_position != STANDING_UP && !can_crawl) || anchored)
		return FALSE

	ai_move_delay = world.time + move_delay
	if(recalculate_move_delay)
		ai_move_delay = world.time + movement_delay()
	if(next_move_slowdown)
		ai_move_delay += next_move_slowdown
		next_move_slowdown = 0
	return TRUE

/mob/living/carbon/xenomorph/proc/set_path(list/path)
	current_path = path
	if(!path)
		COOLDOWN_START(src, no_path_found_cooldown, no_path_found_period)

/mob/living/carbon/xenomorph/proc/move_to_next_turf(turf/T, max_range = ai_range)
	if(!T)
		return FALSE

	if((!current_path || (next_path_generation < world.time && current_target_turf != T)) && COOLDOWN_FINISHED(src, no_path_found_cooldown))
		if(!CALCULATING_PATH(src) || current_target_turf != T)
			SSpathfinding.calculate_path(src, T, max_range, src, CALLBACK(src, PROC_REF(set_path)), list(src, current_target))
			current_target_turf = T
		next_path_generation = world.time + path_update_period

	if(CALCULATING_PATH(src))
		return TRUE

	// No possible path to target.
	if(!current_path && get_dist(T, src) > 0)
		return FALSE

	// We've reached our destination
	if(!length(current_path) || get_dist(T, src) <= 0)
		current_path = null
		return TRUE

	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(get_dist(current_path[current_path.len], src) > 1)
		current_path = null
		return TRUE

	// Unable to move, try next time.
	if(!can_move_and_apply_move_delay())
		return TRUE

	var/turf/next_turf = current_path[current_path.len]
	var/list/L = LinkBlocked(src, loc, next_turf, list(src), TRUE)
	L += SSpathfinding.check_special_blockers(src, next_turf)
	for(var/a in L)
		var/atom/A = a
		if(A.xeno_ai_obstacle(src, get_dir(loc, next_turf)) == INFINITY)
			return FALSE
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, xeno_ai_act), src)
	var/successful_move = Move(next_turf, get_dir(src, next_turf))
	if(successful_move)
		ai_timeout_time = world.time
		current_path.len--

	if(ai_timeout_time < world.time - ai_timeout_period)
		return FALSE

	return TRUE

/// Checks and returns the nearest override for behavior
/mob/living/carbon/xenomorph/proc/check_overrides()
	var/shortest_distance = INFINITY
	var/datum/component/ai_behavior_override/closest_valid_override
	for(var/datum/component/ai_behavior_override/cycled_override in GLOB.all_ai_behavior_overrides)
		var/distance = get_dist(src, cycled_override.parent)
		var/validity = cycled_override.check_behavior_validity(src, distance)

		if(!validity)
			continue

		if(distance >= shortest_distance)
			continue

		shortest_distance = distance
		closest_valid_override = cycled_override

	return closest_valid_override

#define EXTRA_CHECK_DISTANCE_MULTIPLIER 0.20

/mob/living/carbon/xenomorph/proc/get_target(range)
	var/list/viable_targets = list()
	var/atom/movable/closest_target
	var/smallest_distance = INFINITY

	var/list/valid_targets = get_xeno_ai_valid_targets(src)

	for(var/atom/movable/potential_target as anything in valid_targets)
		if(z != potential_target.z)
			continue

		var/distance = get_dist(src, potential_target)

		if(distance > ai_range)
			continue

		viable_targets += potential_target

		if(smallest_distance <= distance)
			continue

		closest_target = potential_target
		smallest_distance = distance

	var/extra_check_distance = round(smallest_distance * EXTRA_CHECK_DISTANCE_MULTIPLIER)

	if(extra_check_distance < 1)
		return closest_target

	var/list/extra_checked = orange(extra_check_distance, closest_target)

	var/list/final_targets = extra_checked & viable_targets

	return length(final_targets) ? pick(final_targets) : closest_target

#undef EXTRA_CHECK_DISTANCE_MULTIPLIER

/mob/living/carbon/xenomorph/proc/make_ai()
	SHOULD_CALL_PARENT(TRUE)
	create_hud()
	if(!client)
		refresh_xeno_ai_runtime_state()

	if(!ai_movement_handler)
		set_movement_handler(init_movement_handler())

/mob/living/carbon/xenomorph/proc/set_movement_handler(datum/xeno_ai_movement/XAM)
	if(!XAM)
		CRASH("Passed null value to set_movement_handler on [type].")

	if(ai_movement_handler)
		qdel(ai_movement_handler)
	ai_movement_handler = XAM

/mob/living/carbon/xenomorph/proc/remove_ai()
	SHOULD_CALL_PARENT(TRUE)
	var/removed_v2_component = FALSE
	var/v2_component_type = text2path("/datum/component/xeno_ai_v2")
	if(v2_component_type)
		var/datum/component/v2_component = GetComponent(v2_component_type)
		if(v2_component)
			removed_v2_component = TRUE
			qdel(v2_component)

	if(removed_v2_component)
		unregister_xeno_ai_runtime_agent_soft(src)
		return

	unregister_xeno_ai_runtime_agent(src)

/// Refreshes xeno AI runtime ownership after feature-flag or control-state changes.
/// Returns TRUE if runtime ownership changed, FALSE otherwise.
/mob/living/carbon/xenomorph/proc/refresh_xeno_ai_runtime_state()
	var/state_changed = FALSE

	var/v2_component_type = text2path("/datum/component/xeno_ai_v2")
	var/datum/component/v2_component = null
	if(v2_component_type)
		v2_component = GetComponent(v2_component_type)

	if(client || !GLOB.npc_ai_v2_xeno_enabled)
		if(v2_component)
			qdel(v2_component)
			state_changed = TRUE

		if(mob_flags & AI_CONTROLLED)
			state_changed = TRUE
		unregister_xeno_ai_runtime_agent(src)
		return state_changed

	if(v2_component_type)
		var/datum/npc_ai_controller/xeno/xeno_controller = get_xeno_ai_runtime_controller()
		var/was_registered = FALSE
		if(xeno_controller)
			was_registered = !!xeno_controller.agents?.Find(src)
		var/was_ai_controlled = !!(mob_flags & AI_CONTROLLED)

		if(!v2_component)
			AddComponent(v2_component_type)
			state_changed = TRUE
		else
			var/datum/component/xeno_ai_v2/v2_runtime_component = v2_component
			v2_runtime_component.register_with_npc_ai()

		if(!was_ai_controlled && (mob_flags & AI_CONTROLLED))
			state_changed = TRUE
		if(xeno_controller && !was_registered && xeno_controller.agents?.Find(src))
			state_changed = TRUE
		return state_changed

	var/was_ai_controlled = !!(mob_flags & AI_CONTROLLED)
	register_xeno_ai_runtime_agent(src)
	if(!was_ai_controlled && (mob_flags & AI_CONTROLLED))
		state_changed = TRUE
	return state_changed

/// Returns the active xeno AI component path for staged rollout.
/proc/get_xeno_ai_component_type()
	if(GLOB.npc_ai_v2_xeno_enabled)
		var/component_path = text2path("/datum/component/xeno_ai_v2")
		if(component_path)
			return component_path
	return null

/proc/get_xeno_ai_runtime_controller()
	RETURN_TYPE(/datum/npc_ai_controller/xeno)
	if(!SSnpc_ai)
		return null

	var/datum/npc_ai_controller/xeno/xeno_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/xeno)
	if(!xeno_controller || QDELETED(xeno_controller))
		return null
	return xeno_controller

/proc/register_xeno_ai_runtime_agent(mob/living/carbon/xenomorph/xeno)
	if(!istype(xeno))
		return

	var/datum/npc_ai_controller/xeno/xeno_controller = get_xeno_ai_runtime_controller()
	if(!xeno_controller)
		return

	xeno_controller.register_agent(xeno)
	xeno.mob_flags |= AI_CONTROLLED

/proc/unregister_xeno_ai_runtime_agent(mob/living/carbon/xenomorph/xeno)
	if(!istype(xeno))
		return

	var/datum/npc_ai_controller/xeno/xeno_controller = get_xeno_ai_runtime_controller()
	if(xeno_controller)
		xeno_controller.unregister_agent(xeno)
	xeno.mob_flags &= ~AI_CONTROLLED

/proc/unregister_xeno_ai_runtime_agent_soft(mob/living/carbon/xenomorph/xeno)
	if(!istype(xeno))
		return

	var/datum/npc_ai_controller/xeno/xeno_controller = get_xeno_ai_runtime_controller()
	if(!xeno_controller)
		return

	xeno_controller.agents -= xeno

/proc/refresh_all_xeno_ai_runtime_state()
	var/updated_agents = 0
	for(var/mob/living/carbon/xenomorph/xeno as anything in GLOB.living_xeno_list)
		if(!istype(xeno))
			continue
		if(xeno.refresh_xeno_ai_runtime_state())
			updated_agents++
	return updated_agents

/proc/get_xeno_ai_valid_targets(mob/living/carbon/xenomorph/xeno)
	RETURN_TYPE(/list)
	if(!istype(xeno))
		return list()

	var/datum/npc_ai_controller/xeno/xeno_controller = get_xeno_ai_runtime_controller()
	if(!xeno_controller || !xeno_controller.is_enabled())
		return list()

	var/list/targets = xeno_controller.get_valid_targets(xeno)
	if(!islist(targets))
		return list()
	return targets

/mob/living/carbon/xenomorph/proc/get_multitile_turfs_to_check()
	var/angle = Get_Angle(current_target, src)
	var/turf/base_turf = current_target.locs[1]

	switch(angle)
		if(315 to 360, 0 to 45) //northerly
			var/max_y_value = base_turf.y + (round(current_target.bound_height / 32) - 1)
			var/list/turf/max_y_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.y == max_y_value)
					max_y_turfs += cycled_turf
			return max_y_turfs
		if(45 to 135) //easterly
			var/max_x_value = base_turf.x + (round(current_target.bound_width / 32) - 1)
			var/list/turf/max_x_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.x == max_x_value)
					max_x_turfs += cycled_turf
			return max_x_turfs
		if(135 to 225) //southerly
			var/min_y_value = base_turf.y
			var/list/turf/min_y_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.y == min_y_value)
					min_y_turfs += cycled_turf
			return min_y_turfs
		if(225 to 315) //westerly
			var/min_x_value = base_turf.x
			var/list/turf/min_x_turfs = list()
			for(var/turf/cycled_turf as anything in current_target.locs)
				if(cycled_turf.x == min_x_value)
					min_x_turfs += cycled_turf
			return min_x_turfs

/// Override as necessary to check for more specific triggers for an ability activation.
/mob/living/carbon/xenomorph/proc/check_additional_ai_activation()
	return TRUE
