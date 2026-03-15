/datum/human_ai_brain
	/// Delay timer for when the AI can next move, based on the tied_human's move delay
	var/ai_move_delay = 0
	/// The list of turfs that the AI is trying to move through
	var/list/current_path
	/// The next turf in current_path that the AI is moving to
	var/turf/current_path_target
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

	ai_move_delay = world.time + tied_human.move_delay
	if(tied_human.recalculate_move_delay)
		ai_move_delay = world.time + tied_human.movement_delay()
	if(tied_human.next_move_slowdown)
		ai_move_delay += tied_human.next_move_slowdown
		tied_human.next_move_slowdown = 0
	return TRUE

/datum/human_ai_brain/proc/clear_navigation_path()
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
		COOLDOWN_START(src, no_path_found_cooldown, no_path_found_period)
	no_path_found = FALSE
	no_path_found_amount++
	return TRUE

/datum/human_ai_brain/proc/has_reached_navigation_destination(turf/destination)
	return tied_human && destination && (get_dist(destination, tied_human) <= 0)

/datum/human_ai_brain/proc/get_adjacent_move_interactions(turf/next_turf)
	if(!tied_human || !next_turf || get_dist(next_turf, tied_human) != 1)
		return null

	var/list/L = LinkBlocked(tied_human, tied_human.loc, next_turf, list(tied_human), TRUE)
	L += SSpathfinding.check_special_blockers(tied_human, next_turf)
	var/direction = get_dir(tied_human.loc, next_turf)
	for(var/a in L)
		var/atom/A = a
		if(A.human_ai_obstacle(tied_human, src, direction) == INFINITY)
			return null

	return L

/datum/human_ai_brain/proc/complete_adjacent_move_to_turf(turf/next_turf, clear_navigation_state = TRUE, list/interactions)
	if(!tied_human || !next_turf || get_dist(next_turf, tied_human) != 1)
		return FALSE

	if(isnull(interactions))
		interactions = get_adjacent_move_interactions(next_turf)
		if(isnull(interactions))
			return FALSE

	if(!can_move_and_apply_move_delay())
		return TRUE

	for(var/a in interactions)
		var/atom/A = a
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, human_ai_act), tied_human, src)

	var/successful_move = tied_human.Move(next_turf, get_dir(tied_human, next_turf))
	if(successful_move)
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

	if(CALCULATING_PATH(tied_human) && !refresh_path_target)
		return FALSE

	// SS220 EDIT: modular brains may observe or meter path requests without forking shared navigation flow
	if(hascall(src, "modular_on_navigation_path_queued"))
		call(src, "modular_on_navigation_path_queued")(destination, max_range)
	SSpathfinding.calculate_path(tied_human, destination, max_range, tied_human, CALLBACK(src, PROC_REF(set_path)), list(tied_human, current_target))
	current_path_target = destination
	next_path_generation = world.time + path_update_period
	return TRUE

/datum/human_ai_brain/proc/should_queue_navigation_path(turf/destination, refresh_path_target = path_target_needs_refresh(destination))
	if(!destination || !COOLDOWN_FINISHED(src, no_path_found_cooldown))
		return FALSE

	return !current_path || (next_path_generation < world.time && refresh_path_target)

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
	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(get_dist(next_turf, tied_human) > 1)
		clear_navigation_path()
		return TRUE

	var/successful_move = try_adjacent_move_to_turf(next_turf, FALSE)
	if(successful_move)
		trim_current_path_step()
		return TRUE

	if(try_local_detour_towards_turf(destination, next_turf))
		return TRUE

	return TRUE

/datum/human_ai_brain/proc/move_to_next_turf(turf/T, max_range = max_travel_distance)
	if(!tied_human || !T)
		return FALSE

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

	no_path_found_amount = 0

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
