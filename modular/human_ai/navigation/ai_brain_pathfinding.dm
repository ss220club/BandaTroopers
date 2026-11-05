/datum/human_ai_brain
	/// Capture an unexpected enclosure once without changing movement or container behavior.
	var/reported_scenery_containment = FALSE

/datum/human_ai_brain/proc/report_scenery_containment()
	if(reported_scenery_containment || !has_valid_tied_human())
		return
	var/atom/container = tied_human.loc
	if(!istype(container, /obj/structure/bed/chair) && !istype(container, /obj/structure/surface/table) && !istype(container, /obj/structure/barricade) && !istype(container, /obj/structure/machinery/door) && !istype(container, /obj/effect/decal))
		return
	reported_scenery_containment = TRUE
	var/turf/position = get_turf(container)
	stack_trace("Human AI scenery containment: NPC=[tied_human] ([REF(tied_human)]), container=[container.type] ([REF(container)]), turf=[position?.x],[position?.y],[position?.z], path_target=[current_path_target]. No recovery movement performed.")

/datum/human_ai_brain
	var/navigation_generation = 0
	/// Own the pending request even if component teardown has already detached tied_human.
	var/datum/xeno_pathinfo/navigation_request
	/// An emergency may replace routine work once without restarting its own pending search.
	var/obj/item/explosive/grenade/navigation_request_grenade
	var/turf/navigation_failure_destination
	/// Delay timer for when the AI can next move, based on the tied_human's move delay
	var/ai_move_delay = 0
	/// The list of turfs that the AI is trying to move through
	var/list/current_path
	/// The next turf in current_path that the AI is moving to
	var/turf/current_path_target
	/// The turf left by the last successful ordinary movement step, used to discourage immediate A-B-A detours.
	var/turf/last_navigation_turf
	/// How much a moving target may drift before we throw away the current path target.
	var/path_target_retarget_slack = 0
	/// Prefer a cheap local step over full pathfinding while the destination stays nearby.
	var/short_step_pathing_range = 0
	/// How long to wait if the AI can't find a path
	var/path_update_period = (0.5 SECONDS)
	/// If TRUE, pathfinding has failed to find a path and a cooldown will soon begin.
	var/no_path_found = FALSE
	/// The farthest that the AI will try to pathfind
	var/max_travel_distance = HUMAN_AI_MAX_PATHFINDING_RANGE
	/// Time storage for the next time a pathfinding path can try to be generated
	var/next_path_generation = 0
	/// Amount of times no path found has occured
	var/no_path_found_amount = 0
	///
	var/ai_timeout_time = 0

	/// The time interval between calculating new paths if we cannot find a path
	var/no_path_found_period = (2.5 SECONDS)

	/// Cooldown declaration for delaying finding a new path if no path was found
	COOLDOWN_DECLARE(no_path_found_cooldown)

/datum/human_ai_brain/proc/can_move_and_apply_move_delay()
	// Unable to move, try next time.
	if(ai_move_delay > world.time || !(tied_human.mobility_flags & MOBILITY_MOVE) || tied_human.is_mob_incapacitated(TRUE) || (tied_human.body_position != STANDING_UP && !tied_human.can_crawl) || tied_human.anchored)
		return FALSE

	var/calculated_move_delay = tied_human.move_delay // SS220 EDIT: preserve the canonical human movement delay for AI scheduling
	if(tied_human.recalculate_move_delay)
		calculated_move_delay = tied_human.movement_delay()
	// SS220 EDIT - START: retain fractional equipment slowdown without banking idle time into burst movement
	schedule_next_move(world.time, calculated_move_delay, SShuman_ai.wait)
	// SS220 EDIT - END
	if(tied_human.next_move_slowdown)
		ai_move_delay += tied_human.next_move_slowdown
		tied_human.next_move_slowdown = 0
	return TRUE

// SS220 EDIT - START: bounded deadline carry preserves fractional armor slowdown
/// Schedules the next AI step while retaining only the lateness caused by one normal subsystem interval.
/datum/human_ai_brain/proc/schedule_next_move(current_time, calculated_move_delay, carry_limit)
	var/carried_lateness = max(current_time - ai_move_delay, 0)
	if(carried_lateness > carry_limit)
		carried_lateness = 0
	else
		carried_lateness = min(carried_lateness, max(calculated_move_delay - world.tick_lag, 0))

	ai_move_delay = current_time + calculated_move_delay - carried_lateness
	return ai_move_delay
// SS220 EDIT - END

/datum/human_ai_brain/proc/clear_navigation_path()
	navigation_generation++
	var/datum/xeno_pathinfo/pending_request = navigation_request
	navigation_request = null
	navigation_request_grenade = null
	if(pending_request && !QDELETED(pending_request) && SSpathfinding.hash_path[pending_request.agent] == pending_request)
		SSpathfinding.stop_calculating_path(pending_request.agent)
	current_path = null
	current_path_target = null

/datum/human_ai_brain/proc/reset_navigation_failures()
	no_path_found = FALSE
	no_path_found_amount = 0

/datum/human_ai_brain/proc/on_navigation_success(clear_navigation_state = TRUE)
	ai_timeout_time = world.time
	if(clear_navigation_state)
		clear_navigation_path()
	reset_navigation_failures()

/datum/human_ai_brain/proc/consume_no_path_failure()
	if(!no_path_found)
		return FALSE

	if(no_path_found_amount > 0)
		COOLDOWN_START(src, no_path_found_cooldown, no_path_found_period * (no_path_found_amount >= setting("path_retries") ? 3 : 1))
	no_path_found = FALSE
	no_path_found_amount++
	return TRUE

/datum/human_ai_brain/proc/has_reached_navigation_destination(turf/destination)
	return tied_human && destination && get_turf(tied_human) == destination && human_ai_turf_is_safe(destination, ignore_owner = TRUE)

/datum/human_ai_brain/proc/get_adjacent_move_interactions(turf/next_turf)
	if(!tied_human || !isturf(next_turf) || get_dist(next_turf, tied_human) != 1)
		return null
	if(!quick_order_step_within_boundary(next_turf)) // SS220 EDIT: permitted Hold actions still cannot path across their fallback boundary
		return null
	// Transit is decided by the local obstacle handlers below, not destination scenery filters.

	var/list/L = LinkBlocked(tied_human, tied_human.loc, next_turf, list(tied_human), TRUE)
	L += SSpathfinding.check_special_blockers(tied_human, next_turf)
	var/direction = get_dir(tied_human.loc, next_turf)
	for(var/a in L)
		var/atom/A = a
		if(A.human_ai_obstacle(tied_human, src, direction) == INFINITY)
			return null

	return L

/datum/human_ai_brain/proc/complete_adjacent_move_to_turf(turf/next_turf, clear_navigation_state = TRUE, list/interactions)
	if(!tied_human || !isturf(next_turf) || get_dist(next_turf, tied_human) != 1)
		return FALSE
	if(pursuit_moving && pursuit_active && !current_target && !has_live_grenade_emergency() && pursuit_caution(next_turf))
		return TRUE
	// A standard delayed climb owns movement until it finishes or is interrupted.
	if(tied_human.action_busy)
		return TRUE

	if(isnull(interactions))
		interactions = get_adjacent_move_interactions(next_turf)
		if(isnull(interactions))
			return FALSE

	if(!can_move_and_apply_move_delay())
		return TRUE
	if(!quick_order_step_within_boundary(next_turf)) // SS220 EDIT: revalidate the Hold boundary immediately before moving
		return FALSE
	// Recheck actual local obstacle rules after any delay, without destination-only filters.
	interactions = get_adjacent_move_interactions(next_turf)
	if(isnull(interactions))
		return FALSE

	// SS220 EDIT - START: canonical climbing owns movement and must not be followed by Move() into the blocker
	var/interaction_handles_movement = FALSE
	for(var/a in interactions)
		var/atom/A = a
		var/action = A.human_ai_select_obstacle_action(src)
		if(action == HUMAN_AI_OBSTACLE_CLIMB_STRUCTURE || action == HUMAN_AI_OBSTACLE_CLIMB_BARRICADE)
			interaction_handles_movement = TRUE
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, human_ai_act), tied_human, src)
		if(interaction_handles_movement)
			break
	if(interaction_handles_movement)
		// do_climb() moves after a delay; the caller retains this path node until arrival.
		return TRUE
	// SS220 EDIT - END

	var/turf/previous_turf = get_turf(tied_human)
	var/successful_move = tied_human.Move(next_turf, get_dir(tied_human, next_turf))
	if(successful_move)
		if(pursuit_moving)
			pursuit_last_direction = get_dir(previous_turf, get_turf(tied_human))
		last_navigation_turf = previous_turf
		on_navigation_success(clear_navigation_state)

	return successful_move

/datum/human_ai_brain/proc/try_adjacent_move_to_turf(turf/next_turf, clear_navigation_state = TRUE)
	return complete_adjacent_move_to_turf(next_turf, clear_navigation_state)

/datum/human_ai_brain/proc/try_short_step_towards_turf(turf/destination, clear_navigation_state = TRUE)
	if(!tied_human || !destination || short_step_pathing_range <= 1)
		return FALSE

	var/current_distance = get_dist(destination, tied_human)
	if(current_distance <= 1 || current_distance > short_step_pathing_range)
		return FALSE

	var/preferred_direction = get_dir(tied_human, destination)
	var/turf/best_destination
	var/list/best_interactions
	var/best_score = INFINITY

	for(var/direction in GLOB.cardinals)
		var/turf/next_turf = get_step(tied_human, direction)
		if(!next_turf)
			continue

		var/list/interactions = get_adjacent_move_interactions(next_turf)
		if(isnull(interactions))
			continue

		var/next_distance = get_dist(destination, next_turf)
		if(next_distance > current_distance)
			continue

		var/score = next_distance * 10
		if(direction != preferred_direction)
			score++
		if(next_turf == last_navigation_turf)
			score += 100

		if(score < best_score)
			best_score = score
			best_destination = next_turf
			best_interactions = interactions

	if(!best_destination)
		return FALSE

	return complete_adjacent_move_to_turf(best_destination, clear_navigation_state, best_interactions)

/datum/human_ai_brain/proc/try_local_detour_towards_turf(turf/destination, turf/blocked_turf = null, clear_navigation_state = TRUE)
	if(!tied_human || !destination)
		return FALSE

	var/current_distance = get_dist(destination, tied_human)
	if(current_distance <= 0)
		return FALSE

	var/preferred_direction = get_dir(tied_human, blocked_turf || destination)
	var/turf/best_destination
	var/list/best_interactions
	var/best_score = INFINITY

	for(var/direction in GLOB.cardinals)
		var/turf/next_turf = get_step(tied_human, direction)
		if(!next_turf || next_turf == blocked_turf)
			continue

		var/list/interactions = get_adjacent_move_interactions(next_turf)
		if(isnull(interactions))
			continue

		var/next_distance = get_dist(destination, next_turf)
		if(next_distance > (current_distance + 1))
			continue

		var/score = next_distance * 10
		if(next_distance > current_distance)
			score += 5
		if(direction != preferred_direction)
			score++
		if(next_turf == last_navigation_turf)
			score += 100

		if(score < best_score)
			best_score = score
			best_destination = next_turf
			best_interactions = interactions

	if(!best_destination)
		return FALSE

	return complete_adjacent_move_to_turf(best_destination, clear_navigation_state, best_interactions)

/datum/human_ai_brain/proc/path_target_needs_refresh(turf/destination)
	if(!destination || !current_path_target)
		return TRUE

	if(current_path_target == destination)
		return FALSE

	if(path_target_retarget_slack <= 0)
		return TRUE

	return get_dist(current_path_target, destination) > path_target_retarget_slack

/datum/human_ai_brain/proc/queue_navigation_path_to_turf(turf/destination, max_range = max_travel_distance, refresh_path_target = path_target_needs_refresh(destination))
	if(!tied_human || !destination)
		return FALSE
	destination = human_ai_get_safe_standing_turf_near(destination)
	if(!destination)
		return FALSE

	if(!should_queue_navigation_path(destination, refresh_path_target))
		return FALSE
	if(navigation_needs_emergency_preemption())
		clear_navigation_path()
	navigation_request_grenade = has_live_grenade_emergency() ? active_grenade_found : null

	// SS220 EDIT: modular brains may observe or meter path requests without forking shared navigation flow
	if(hascall(src, "modular_on_navigation_path_queued"))
		call(src, "modular_on_navigation_path_queued")(destination, max_range)
	navigation_generation++
	SSpathfinding.calculate_path(tied_human, destination, max_range, tied_human, CALLBACK(src, PROC_REF(accept_navigation_path), navigation_generation), list(tied_human, current_target))
	navigation_request = SSpathfinding.hash_path[tied_human]
	current_path_target = destination
	next_path_generation = world.time + path_update_period
	return TRUE

/datum/human_ai_brain/proc/navigation_needs_emergency_preemption()
	return has_live_grenade_emergency() && navigation_request_grenade != active_grenade_found

/datum/human_ai_brain/proc/should_queue_navigation_path(turf/destination, refresh_path_target = path_target_needs_refresh(destination))
	if(!tied_human || !destination)
		return FALSE
	// A new live-grenade emergency must not wait behind an unrelated route or its cooldown.
	if(navigation_needs_emergency_preemption())
		return TRUE
	if(!COOLDOWN_FINISHED(src, no_path_found_cooldown))
		return FALSE

	// Finish accepted work before retargeting; moving targets must not reset its frontier every AI tick.
	if(CALCULATING_PATH(tied_human) || world.time < next_path_generation)
		return FALSE
	return !current_path || refresh_path_target

/datum/human_ai_brain/proc/trim_current_path_step()
	if(length(current_path))
		current_path.len--

/datum/human_ai_brain/proc/follow_current_path_to_turf(turf/destination)
	if(!tied_human || !destination)
		return FALSE

	// No possible path to target.
	if(!current_path && !has_reached_navigation_destination(destination))
		return FALSE

	// We've reached our destination or consumed the whole path.
	if(!length(current_path) || has_reached_navigation_destination(destination))
		clear_navigation_path()
		return TRUE

	var/turf/next_turf = current_path[length(current_path)]
	// an asynchronous climb has now reached its retained path node.
	if(get_turf(tied_human) == next_turf)
		trim_current_path_step()
		on_navigation_success(FALSE)
		return TRUE
	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(get_dist(next_turf, tied_human) > 1)
		clear_navigation_path()
		return TRUE

	var/successful_move = try_adjacent_move_to_turf(next_turf, FALSE)
	if(successful_move)
		// Delayed do_climb() has not reached the structure yet, so its node must remain at the end of the path.
		if(get_turf(tied_human) == next_turf)
			trim_current_path_step()
		return TRUE

	if(try_local_detour_towards_turf(destination, next_turf))
		return TRUE

	// SS220 EDIT - START: do not endlessly retry a stale path whose next step is a wall or another hard blocker
	clear_navigation_path()
	no_path_found = TRUE
	return FALSE
	// SS220 EDIT - END

/datum/human_ai_brain/proc/move_to_next_turf(turf/T, max_range = max_travel_distance)
	if(!tied_human || !isturf(T))
		return FALSE
	T = human_ai_get_safe_standing_turf_near(T)
	if(!T)
		clear_navigation_path()
		return FALSE
	if(navigation_failure_destination != T)
		navigation_failure_destination = T
		reset_navigation_failures()

	// SS220 EDIT - START: adjacent destinations do not need a full SSpathfinding round-trip
	if(has_reached_navigation_destination(T))
		clear_navigation_path()
		return TRUE

	if(try_adjacent_move_to_turf(T))
		return TRUE

	if(get_dist(T, tied_human) == 1)
		return FALSE
	// SS220 EDIT - END

	if(try_short_step_towards_turf(T))
		return TRUE

	if(consume_no_path_failure())
		return FALSE

	var/refresh_path_target = path_target_needs_refresh(T)

	if(should_queue_navigation_path(T, refresh_path_target))
		queue_navigation_path_to_turf(T, max_range, refresh_path_target)

	if(CALCULATING_PATH(tied_human))
		return TRUE

	return follow_current_path_to_turf(T)

/datum/human_ai_brain/proc/set_path(list/path)
	current_path = path
	if(!path)
		no_path_found = TRUE

/datum/human_ai_brain/proc/accept_navigation_path(generation, list/path)
	if(generation != navigation_generation || !has_valid_tied_human())
		return
	// The completed request is detached before delivery; release our reference too.
	navigation_request = null
	set_path(path)
