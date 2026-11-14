/datum/xeno_ai_movement/crusher
	/// Where we run up from to charge into a group of targets, in line with it
	var/turf/line_up_turf
	/// How far from the group we want to start the charge, so that there is enough room to build momentum
	var/line_up_distance = 7
	var/line_up_search_interval = 1 SECONDS
	COOLDOWN_DECLARE(line_up_search_cooldown)

/datum/xeno_ai_movement/crusher/New(mob/living/carbon/xenomorph/parent)
	. = ..()

	RegisterSignal(parent, COMSIG_XENO_STOPPED_CHARGING, PROC_REF(stop_charging))

#define MAX_CHARGE_DISTANCE 30

/datum/xeno_ai_movement/crusher/ai_move_target(delta_time)
	var/mob/living/carbon/xenomorph/moving_xeno = parent

	if(moving_xeno.throwing)
		return ..()

	var/datum/action/xeno_action/onclick/charger_charge/charge_action = locate() in moving_xeno.actions

	if(!charge_action)
		return ..()

	if(!charge_action.charge_dir)
		// Rooted by the stomp windup, trying to path anywhere meanwhile would only put pathfinding on cooldown.
		if(moving_xeno.action_busy)
			return

		// Already in reach. The base handler would pick a turf around the target to step to, and when it picks our own turf
		// pathfinding finds no path, which leaves us standing around without attacking until the no path cooldown runs out.
		if(ismob(moving_xeno.current_target) && get_dist(moving_xeno, moving_xeno.current_target) <= 1)
			return

		// No point in lining up while the AI could not start the charge anyway.
		if(charge_action.activated || !COOLDOWN_FINISHED(moving_xeno, ai_ability_cooldown) || get_dist(moving_xeno, moving_xeno.current_target) < line_up_distance / 2)
			return ..()

		// The charge only goes in a straight line, so we get in line with a group first and charge_action.process_ai() takes it from there.
		if(COOLDOWN_FINISHED(src, line_up_search_cooldown))
			COOLDOWN_START(src, line_up_search_cooldown, line_up_search_interval)
			line_up_turf = find_line_up_turf(charge_action)

		if(!line_up_turf || get_dist(moving_xeno, line_up_turf) <= 0)
			line_up_turf = null
			return ..()

		if(!moving_xeno.can_move_and_apply_move_delay())
			return

		// Straight steps instead of pathfinding: a turf we can not reach would put pathfinding on cooldown and leave us standing around.
		var/turf/line_up_step = get_step_towards(moving_xeno, line_up_turf)
		if(!moving_xeno.Move(line_up_step, get_dir(moving_xeno, line_up_step)))
			line_up_turf = null
			COOLDOWN_START(src, line_up_search_cooldown, line_up_search_interval * 3)
			return ..()
		return

	if(charge_action.steps_taken > MAX_CHARGE_DISTANCE)
		stop_charging()
		return ..()

	if(!moving_xeno.can_move_and_apply_move_delay())
		return TRUE

	var/turf/next_turf = get_step(moving_xeno, charge_action.charge_dir)
	if(!moving_xeno.Move(next_turf, charge_action.charge_dir))
		stop_charging()

	return TRUE

#undef MAX_CHARGE_DISTANCE

/// The closest turf in line with a group of targets, line_up_distance away from it, with nothing in the way of a charge.
/datum/xeno_ai_movement/crusher/proc/find_line_up_turf(datum/action/xeno_action/onclick/charger_charge/charge_action)
	var/turf/best_turf
	var/best_distance = INFINITY
	for(var/turf/group_turf as anything in charge_action.get_ai_charge_groups(parent))
		for(var/direction in GLOB.cardinals)
			var/turf/candidate = get_ranged_target_turf(group_turf, direction, line_up_distance)
			if(!candidate || candidate.density || get_dist(candidate, group_turf) < line_up_distance)
				continue

			var/distance = get_dist(parent, candidate)
			if(distance >= best_distance)
				continue

			if(!charge_action.is_ai_charge_path_clear(parent, candidate, REVERSE_DIR(direction)))
				continue

			best_distance = distance
			best_turf = candidate

	return best_turf

/datum/xeno_ai_movement/crusher/Destroy(force, ...)
	line_up_turf = null
	return ..()

/datum/xeno_ai_movement/crusher/proc/stop_charging()
	SIGNAL_HANDLER

	var/datum/action/xeno_action/onclick/charger_charge/charge_action = locate() in parent.actions

	if(!charge_action)
		return

	if(!charge_action.activated)
		return

	INVOKE_ASYNC(charge_action, TYPE_PROC_REF(/datum/action/xeno_action/onclick/charger_charge, use_ability_wrapper))
	COOLDOWN_RESET(parent, forced_retarget_cooldown)
