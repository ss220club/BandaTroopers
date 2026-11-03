/datum/human_ai_module/navigation
	module_id = "navigation"
	required_module_types = list(/datum/human_ai_module/targeting)

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

/datum/human_ai_module/navigation/proc/clear_navigation_path()
	current_path = null
	current_path_target = null

// SS220 EDIT - START: cancel queued work while the controller still owns the pathfinding agent
/datum/human_ai_module/navigation/proc/cancel_navigation()
	context?.controller?.cancel_pathfinding()
	clear_navigation_path()
	reset_navigation_failures()
	COOLDOWN_RESET(src, no_path_found_cooldown)

/datum/human_ai_module/navigation/reset_module()
	cancel_navigation()

/datum/human_ai_module/navigation/suspend_module(clear_inventory = FALSE)
	cancel_navigation()

/datum/human_ai_module/navigation/Destroy(force, ...)
	cancel_navigation()
	return ..()
// SS220 EDIT - END

/datum/human_ai_module/navigation/proc/reset_navigation_failures()
	no_path_found = FALSE
	no_path_found_amount = 0

/datum/human_ai_module/navigation/proc/has_owner_navigation_path_queued_hook()
	return hascall(brain, "modular_on_navigation_path_queued")

/datum/human_ai_module/navigation/proc/notify_owner_navigation_path_queued(turf/destination, max_range)
	return call(brain, "modular_on_navigation_path_queued")(destination, max_range)

/datum/human_ai_module/navigation/proc/get_owner_current_target()
	RETURN_TYPE(/atom/movable)
	return brain.get_current_target()

/datum/human_ai_module/navigation/proc/apply_navigation_profile(short_step_range = 0, path_retarget_slack = 0)
	if(short_step_range > 0)
		short_step_pathing_range = max(short_step_pathing_range, short_step_range)
	if(path_retarget_slack > 0)
		path_target_retarget_slack = max(path_target_retarget_slack, path_retarget_slack)

/datum/human_ai_module/navigation/proc/on_navigation_success(clear_navigation_state = TRUE)
	ai_timeout_time = world.time
	if(clear_navigation_state)
		clear_navigation_path()
	reset_navigation_failures()

/datum/human_ai_module/navigation/proc/consume_no_path_failure()
	if(!no_path_found)
		return FALSE

	if(no_path_found_amount > 0)
		COOLDOWN_START(src, no_path_found_cooldown, no_path_found_period)
	no_path_found = FALSE
	no_path_found_amount++
	return TRUE

/datum/human_ai_module/navigation/proc/has_reached_navigation_destination(turf/destination)
	var/datum/human_tied_controller/controller = context?.controller
	return destination && controller && (controller.get_distance_from(destination) <= 0)

/datum/human_ai_module/navigation/proc/get_adjacent_move_interactions(turf/next_turf)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller?.has_valid_tied_human() || !next_turf || !controller.is_cardinal_step_to(next_turf))
		return null

	var/list/L = controller.get_move_blockers(next_turf)
	var/direction = controller.get_direction_to(next_turf)
	for(var/a in L)
		var/atom/A = a
		if(controller.get_obstacle_cost(A, direction, next_turf) == INFINITY)
			return null

	return L

// SS220 EDIT - START: shared bounded candidate selection and movement execution
/datum/human_ai_module/navigation/proc/get_local_step(turf/destination, turf/blocked_turf = null, allow_retreat = FALSE)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return null

	var/current_distance = controller.get_distance_from(destination)
	var/preferred_direction = controller.get_direction_to(blocked_turf || destination)
	var/turf/best_destination
	var/best_score = INFINITY
	for(var/direction in GLOB.cardinals)
		var/turf/next_turf = controller.get_step_in_dir(direction)
		if(!next_turf || next_turf == blocked_turf)
			continue
		var/next_distance = get_dist(destination, next_turf)
		if(next_distance > current_distance + allow_retreat || isnull(get_adjacent_move_interactions(next_turf)))
			continue
		var/score = next_distance * 10
		if(next_distance > current_distance)
			score += 5
		if(direction != preferred_direction)
			score++
		if(score < best_score)
			best_score = score
			best_destination = next_turf
	return best_destination

/datum/human_ai_module/navigation/proc/attempt_navigation_step(turf/next_turf)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller?.can_move())
		return FALSE
	var/list/interactions = get_adjacent_move_interactions(next_turf)
	if(isnull(interactions))
		return FALSE
	if(length(interactions))
		controller.act_on_blockers(interactions)
		return TRUE
	return controller.Move(next_turf, controller.get_direction_to(next_turf))
// SS220 EDIT - END

/datum/human_ai_module/navigation/proc/path_target_needs_refresh(turf/destination)
	if(!destination || !current_path_target)
		return TRUE

	if(current_path_target == destination)
		return FALSE

	if(path_target_retarget_slack <= 0)
		return TRUE

	return get_dist(current_path_target, destination) > path_target_retarget_slack

/datum/human_ai_module/navigation/proc/queue_navigation_path_to_turf(turf/destination, max_range = max_travel_distance, refresh_path_target = path_target_needs_refresh(destination))
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller?.has_valid_tied_human() || !destination)
		return FALSE

	if(controller.is_calculating_path() && !refresh_path_target)
		return FALSE

	// SS220 EDIT: modular brains may observe or meter path requests without forking shared navigation flow
	if(has_owner_navigation_path_queued_hook())
		notify_owner_navigation_path_queued(destination, max_range)
	controller.calculate_path_to(destination, max_range, CALLBACK(src, PROC_REF(set_path)), list(get_owner_current_target()))
	current_path_target = destination
	next_path_generation = world.time + path_update_period
	return TRUE

/datum/human_ai_module/navigation/proc/should_queue_navigation_path(turf/destination, refresh_path_target = path_target_needs_refresh(destination))
	if(!destination || !COOLDOWN_FINISHED(src, no_path_found_cooldown))
		return FALSE

	return !current_path || (next_path_generation < world.time && refresh_path_target)

// SS220 EDIT - START: one admitted opportunity, main step then at most one detour
/datum/human_ai_module/navigation/proc/move_to_next_turf(turf/T, max_range = max_travel_distance)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller?.has_valid_tied_human() || !T)
		return FALSE
	if(has_reached_navigation_destination(T))
		clear_navigation_path()
		return TRUE
	if(!controller.can_move() || controller.has_move_delay())
		return TRUE

	var/turf/next_turf
	var/following_path = FALSE
	var/distance = controller.get_distance_from(T)
	if(controller.is_cardinal_step_to(T))
		next_turf = T
	else if(!length(current_path) && short_step_pathing_range > 1 && distance <= short_step_pathing_range)
		next_turf = get_local_step(T)

	if(!next_turf)
		if(consume_no_path_failure())
			return FALSE
		var/refresh_path_target = path_target_needs_refresh(T)
		if(should_queue_navigation_path(T, refresh_path_target))
			queue_navigation_path_to_turf(T, max_range, refresh_path_target)
		if(controller.is_calculating_path())
			return TRUE
		if(!current_path)
			return FALSE
		if(!length(current_path))
			clear_navigation_path()
			return TRUE
		next_turf = current_path[length(current_path)]
		if(controller.get_distance_from(next_turf) == 0)
			current_path.len--
			return TRUE
		if(!controller.is_cardinal_step_to(next_turf))
			clear_navigation_path()
			return TRUE
		following_path = TRUE

	controller.request_run_movement_intent()
	if(!controller.can_move() || controller.has_move_delay() || !controller.apply_move_delay())
		return TRUE
	var/turf/start_turf = controller.get_current_turf()
	var/list/path_before_move = current_path
	if(attempt_navigation_step(next_turf))
		if(following_path && current_path == path_before_move && length(current_path))
			current_path.len--
		on_navigation_success(!following_path)
		return TRUE
	if(!controller.can_move() || controller.get_current_turf() != start_turf)
		return TRUE

	var/turf/detour = get_local_step(T, next_turf, TRUE)
	if(detour && attempt_navigation_step(detour))
		on_navigation_success()
		return TRUE
	if(!controller.can_move() || controller.get_current_turf() != start_turf)
		return TRUE
	if(following_path)
		return TRUE
	if(controller.is_cardinal_step_to(T) || consume_no_path_failure())
		return FALSE
	if(should_queue_navigation_path(T))
		queue_navigation_path_to_turf(T, max_range)
	return controller.is_calculating_path()
// SS220 EDIT - END

/datum/human_ai_module/navigation/proc/set_path(list/path)
	current_path = path
	if(!path)
		no_path_found = TRUE
