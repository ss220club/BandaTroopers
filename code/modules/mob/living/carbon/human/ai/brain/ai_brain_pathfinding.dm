/datum/human_ai_brain
	/// Delay timer for when the AI can next move, based on the tied_human's move delay
	var/ai_move_delay = 0
	/// The list of turfs that the AI is trying to move through
	var/list/current_path
	/// The next turf in current_path that the AI is moving to
	var/turf/current_path_target
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
	/// Max cooldown cap for no-path backoff.
	var/no_path_found_period_max = (10 SECONDS)
	/// Prevents duplicate path requests with identical signatures in a short window.
	var/path_request_dedupe_window = 2
	/// Time window for retarget throttling.
	var/path_retarget_window = (1 SECONDS)
	/// Hard cap of retargets within one retarget window.
	var/path_retarget_hard_cap = 4
	/// Current retarget count inside active retarget window.
	var/path_retargets_in_window = 0
	/// World time when current retarget window started.
	var/path_retarget_window_started = 0
	/// Last submitted path request signature for dedupe.
	var/last_path_request_signature = null
	/// World time when last path request signature was submitted.
	var/last_path_request_at = 0

	/// Cooldown declaration for delaying finding a new path if no path was found
	COOLDOWN_DECLARE(no_path_found_cooldown)

/datum/human_ai_brain/proc/build_path_request_signature(turf/T, max_range, list/ignore)
	if(!T)
		return null

	var/list/chunks = list("[REF(tied_human)]", "[REF(T)]", "[max_range]")
	if(islist(ignore) && length(ignore))
		for(var/entry as anything in ignore)
			if(isnull(entry))
				chunks += "null"
				continue
			if(isatom(entry))
				chunks += REF(entry)
				continue
			chunks += "[entry]"
	return jointext(chunks, "|")

/datum/human_ai_brain/proc/can_retarget_path(turf/new_target)
	if(current_path_target == new_target)
		return TRUE

	if((world.time - path_retarget_window_started) >= path_retarget_window)
		path_retarget_window_started = world.time
		path_retargets_in_window = 0

	if(path_retargets_in_window >= path_retarget_hard_cap)
		return FALSE

	path_retargets_in_window++
	return TRUE

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

/datum/human_ai_brain/proc/move_to_next_turf(turf/T, max_range = max_travel_distance)
	if(!T)
		return FALSE

	if(no_path_found)
		var/failure_streak = max(1, no_path_found_amount + 1)
		var/backoff_duration = min(no_path_found_period * (1 << (failure_streak - 1)), no_path_found_period_max)
		COOLDOWN_START(src, no_path_found_cooldown, backoff_duration)
		no_path_found = FALSE
		no_path_found_amount = failure_streak
		return FALSE

	if((!current_path || (next_path_generation < world.time && current_path_target != T)) && COOLDOWN_FINISHED(src, no_path_found_cooldown))
		if(!can_retarget_path(T))
			next_path_generation = world.time + path_update_period
		else
			var/list/path_ignore = list(tied_human, current_target)
			var/request_signature = build_path_request_signature(T, max_range, path_ignore)
			var/is_duplicate_request = request_signature && (request_signature == last_path_request_signature) && ((world.time - last_path_request_at) < path_request_dedupe_window)
			if(!is_duplicate_request && (!CALCULATING_PATH(tied_human) || current_path_target != T))
				var/datum/npc_ai_controller/human/human_controller = get_npc_ai_v2_controller()
				if(human_controller)
					human_controller.record_path_request()
				SSpathfinding.calculate_path(tied_human, T, max_range, tied_human, CALLBACK(src, PROC_REF(set_path)), path_ignore)
				last_path_request_signature = request_signature
				last_path_request_at = world.time
				current_path_target = T
		next_path_generation = world.time + path_update_period

	if(CALCULATING_PATH(tied_human))
		return TRUE

	// No possible path to target.
	if(!current_path && get_dist(T, tied_human) > 0)
		return FALSE

	// We've reached our destination
	if(!length(current_path) || get_dist(T, tied_human) <= 0)
		current_path = null
		return TRUE

	var/turf/next_turf = current_path[length(current_path)]
	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(get_dist(next_turf, tied_human) > 1)
		current_path = null
		return TRUE

	// Unable to move, try next time.
	if(!can_move_and_apply_move_delay())
		return TRUE

	var/list/L = LinkBlocked(tied_human, tied_human.loc, next_turf, list(tied_human), TRUE)
	L += SSpathfinding.check_special_blockers(tied_human, next_turf)
	for(var/a in L)
		var/atom/A = a
		if(A.human_ai_obstacle(tied_human, src, get_dir(tied_human.loc, next_turf)) == INFINITY)
			return FALSE
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, human_ai_act), tied_human, src)
	var/successful_move = tied_human.Move(next_turf, get_dir(tied_human, next_turf))
	if(successful_move)
		ai_timeout_time = world.time
		current_path.len--

	return TRUE

/datum/human_ai_brain/proc/set_path(list/path)
	current_path = path
	var/datum/npc_ai_controller/human/human_controller = get_npc_ai_v2_controller()
	if(!path)
		no_path_found = TRUE
		if(human_controller)
			human_controller.record_path_failure()
		return

	no_path_found_amount = 0
	if(human_controller)
		human_controller.record_path_hit()
