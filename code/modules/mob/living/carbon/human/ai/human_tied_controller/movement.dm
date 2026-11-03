// Movement gates

/datum/human_tied_controller/proc/can_move()
	if(!can_directly_control())
		return FALSE
	if(tied_human.action_busy || !(tied_human.mobility_flags & MOBILITY_MOVE) || tied_human.is_mob_incapacitated(TRUE) || (tied_human.body_position != STANDING_UP && !tied_human.can_crawl) || tied_human.anchored)
		return FALSE
	return TRUE

/datum/human_tied_controller/proc/has_move_delay()
	return ai_move_delay > world.time

// Move delay primitives

/datum/human_tied_controller/proc/get_current_move_delay()
	if(!can_read_puppet())
		return 0
	if(tied_human.recalculate_move_delay)
		return tied_human.movement_delay()
	return tied_human.move_delay

/datum/human_tied_controller/proc/consume_next_move_slowdown()
	if(!can_mutate_puppet() || !tied_human.next_move_slowdown)
		return 0
	var/consumed_slowdown = tied_human.next_move_slowdown
	tied_human.next_move_slowdown = 0
	return consumed_slowdown

/datum/human_tied_controller/proc/set_move_delay_until(target_time)
	ai_move_delay = target_time
	return TRUE

/datum/human_tied_controller/proc/apply_move_delay()
	if(!can_mutate_puppet())
		return FALSE
	set_move_delay_until(world.time + get_current_move_delay() + consume_next_move_slowdown())
	return TRUE

/datum/human_tied_controller/proc/request_run_movement_intent()
	if(!can_mutate_puppet() || tied_human.legcuffed)
		return FALSE
	if(tied_human.m_intent == MOVE_INTENT_RUN)
		return TRUE
	tied_human.set_movement_intent(MOVE_INTENT_RUN)
	return TRUE

// Raw movement primitives

/datum/human_tied_controller/proc/get_move_direction(turf/target_turf)
	if(!can_read_puppet() || !target_turf)
		return null
	return get_dir(tied_human, target_turf)

/datum/human_tied_controller/proc/get_direction_to(atom/target)
	if(!can_read_puppet() || !target)
		return null
	return get_dir(tied_human, target)

/datum/human_tied_controller/proc/get_direction_from(atom/source)
	if(!can_read_puppet() || !source)
		return null
	return get_dir(source, tied_human)

/datum/human_tied_controller/proc/get_compass_dir_from(atom/source)
	if(!can_read_puppet() || !source)
		return null
	return Get_Compass_Dir(source, tied_human)

/datum/human_tied_controller/proc/get_angle_from(atom/source)
	if(!can_read_puppet() || !source)
		return null
	return Get_Angle(source, tied_human)

/datum/human_tied_controller/proc/get_reverse_dir_cone()
	if(!can_read_puppet())
		return null
	return reverse_nearby_direction(reverse_direction(tied_human.dir))

/datum/human_tied_controller/proc/get_distance_to(atom/target)
	if(!can_read_puppet() || !target)
		return INFINITY
	return get_dist(tied_human, target)

/datum/human_tied_controller/proc/get_distance_to_controller(datum/human_tied_controller/other_controller)
	if(!can_read_puppet() || !other_controller?.can_read_puppet())
		return INFINITY
	var/turf/other_turf = other_controller.get_current_turf()
	if(!other_turf)
		return INFINITY
	return get_dist(tied_human, other_turf)

/datum/human_tied_controller/proc/get_distance_from(atom/source)
	if(!can_read_puppet() || !source)
		return INFINITY
	return get_dist(source, tied_human)

/datum/human_tied_controller/proc/is_in_view_of(atom/center, distance)
	if(!can_read_puppet() || !center)
		return FALSE
	return tied_human in viewers(distance, center)

/datum/human_tied_controller/proc/get_view(distance)
	if(!can_read_puppet())
		return list()
	return view(distance, tied_human)

/datum/human_tied_controller/proc/get_range(distance)
	if(!can_read_puppet())
		return list()
	return range(distance, tied_human)

/datum/human_tied_controller/proc/get_line_to(atom/target, include_start = TRUE)
	if(!can_read_puppet() || !target)
		return list()
	return get_line(tied_human, target, include_start)

/datum/human_tied_controller/proc/get_line_from_current_turf_to(atom/target, include_start = TRUE)
	var/turf/source_turf = get_current_turf()
	var/turf/target_turf = get_turf(target)
	if(!source_turf || !target_turf)
		return list()
	return get_line(source_turf, target_turf, include_start)

/datum/human_tied_controller/proc/get_step_in_dir(direction)
	if(!can_read_puppet() || !direction)
		return null
	return get_step(tied_human, direction)

/datum/human_tied_controller/proc/is_cardinal_step_to(turf/target_turf)
	if(!can_read_puppet() || !target_turf || get_dist(tied_human, target_turf) != 1)
		return FALSE
	return get_dir(tied_human, target_turf) in GLOB.cardinals

/datum/human_tied_controller/proc/is_calculating_path()
	return can_read_puppet() && CALCULATING_PATH(tied_human)

// SS220 EDIT - START: lifecycle cleanup must cancel by agent before detach clears tied_human
/datum/human_tied_controller/proc/cancel_pathfinding()
	if(!tied_human)
		return FALSE
	SSpathfinding.stop_calculating_path(tied_human)
	return TRUE
// SS220 EDIT - END

/datum/human_tied_controller/proc/calculate_path_to(turf/destination, max_range, datum/callback/path_callback, list/additional_exclusions)
	if(!can_read_puppet() || !destination || !path_callback)
		return FALSE
	var/list/exclusions = list(tied_human)
	if(length(additional_exclusions))
		exclusions += additional_exclusions
	SSpathfinding.calculate_path(tied_human, destination, max_range, tied_human, path_callback, exclusions)
	return TRUE

/datum/human_tied_controller/proc/get_ranged_target_turf(direction, distance)
	if(!can_read_puppet() || !direction)
		return null
	return get_ranged_target_turf(tied_human, direction, distance)

/datum/human_tied_controller/proc/is_puppet(atom/target)
	return can_read_puppet() && (target == tied_human)

/datum/human_tied_controller/proc/get_identity_ref()
	if(!can_read_puppet())
		return null
	return WEAKREF(tied_human)

/datum/human_tied_controller/proc/matches_identity_ref(datum/weakref/identity_ref)
	return can_read_puppet() && identity_ref && (identity_ref.resolve() == tied_human)

/datum/human_tied_controller/proc/Move(turf/target_turf, direction)
	if(!can_directly_control() || !target_turf)
		return FALSE
	if(isnull(direction))
		direction = get_move_direction(target_turf)
	if(!(direction in GLOB.cardinals))
		return FALSE
	return tied_human.Move(target_turf, direction)

/datum/human_tied_controller/proc/forceMove(turf/target_turf)
	if(!can_force_control() || !target_turf)
		return FALSE
	tied_human.forceMove(target_turf)
	return TRUE

// Raw facing primitives

/datum/human_tied_controller/proc/face_atom(atom/target)
	if(!can_directly_control() || !target)
		return FALSE
	tied_human.face_atom(target)
	return TRUE

/datum/human_tied_controller/proc/face_dir(direction)
	if(!can_directly_control() || !direction)
		return FALSE
	tied_human.face_dir(direction)
	return TRUE

/datum/human_tied_controller/proc/setDir(direction)
	if(!can_directly_control() || !direction)
		return FALSE
	tied_human.setDir(direction)
	return TRUE
