
/datum/human_ai_brain
	/// Position from which the current Hold Position boundary was issued.
	var/turf/hold_position_origin_turf
	/// Maximum fallback boundary assigned by Quick Order: Hold Position.
	var/turf/hold_position_turf
	/// Last turf occupied during a bounded retreat, used to avoid immediate detour oscillation.
	var/turf/hold_position_previous_turf

/// Returns whether this action can change the NPC's turf and is therefore controlled by quick orders.
/datum/human_ai_brain/proc/quick_order_action_may_move(datum/ai_action/action)
	if(!action || !(action.action_flags & ACTION_USING_LEGS))
		return FALSE
	// Rolling to extinguish fire does not change turf and must remain available while holding.
	if(istype(action, /datum/ai_action/resist_burning))
		return FALSE
	// Never tear down a primed grenade while its asynchronous throw is already in flight.
	if(istype(action, /datum/ai_action/throw_grenade))
		var/datum/ai_action/throw_grenade/grenade_action = action
		if(grenade_action.mid_throw)
			return FALSE
	if(istype(action, /datum/ai_action/throw_back_nade))
		var/datum/ai_action/throw_back_nade/throw_back_action = action
		if(throw_back_action.mid_throw)
			return FALSE
	return TRUE

/// Central scheduler gate: Hold Position blocks every action capable of moving the NPC.
/datum/human_ai_brain/proc/quick_order_blocks_action(datum/ai_action/action)
	if(istype(action, /datum/ai_action/throw_back_nade))
		return FALSE
	if(has_live_grenade_emergency() && (action.action_flags & (ACTION_USING_HANDS | ACTION_USING_LEGS)) && !action_is_committed(action))
		return TRUE
	if(!hold_position || !quick_order_action_may_move(action))
		return FALSE
	if(istype(action, /datum/ai_action/hold_position_retreat) || istype(action, /datum/ai_action/take_cover) || istype(action, /datum/ai_action/treat_ally) || istype(action, /datum/ai_action/leave_unsafe_turf))
		return FALSE
	if(istype(action, /datum/ai_action/critical_retreat))
		return FALSE // Every retreat step still respects the issued Hold boundary.
	return TRUE

/// Returns whether a physical movement step stays on the permitted side of the Hold Position boundary.
/datum/human_ai_brain/proc/quick_order_step_within_boundary(turf/candidate)
	if(has_live_grenade_emergency())
		return TRUE
	if(!hold_position)
		return TRUE
	if(!candidate || !hold_position_origin_turf || !hold_position_turf)
		return FALSE
	if(candidate.z != hold_position_origin_turf.z || hold_position_turf.z != hold_position_origin_turf.z)
		return FALSE
	if(setting("hold_radius") > 0 && get_dist(candidate, hold_position_origin_turf) > setting("hold_radius"))
		return FALSE

	var/boundary_x = hold_position_turf.x - hold_position_origin_turf.x
	var/boundary_y = hold_position_turf.y - hold_position_origin_turf.y
	var/boundary_length_squared = boundary_x * boundary_x + boundary_y * boundary_y
	if(!boundary_length_squared)
		return candidate == hold_position_turf

	var/candidate_x = candidate.x - hold_position_origin_turf.x
	var/candidate_y = candidate.y - hold_position_origin_turf.y
	var/candidate_progress = candidate_x * boundary_x + candidate_y * boundary_y
	return candidate_progress <= boundary_length_squared

/// Returns whether one candidate step retreats or moves laterally without crossing the fallback boundary.
/datum/human_ai_brain/proc/hold_position_retreat_step_is_allowed(turf/candidate, allow_lateral = FALSE)
	if(!hold_position || !candidate || !hold_position_turf || !current_target || !has_valid_tied_human())
		return FALSE

	var/turf/current_turf = get_turf(tied_human)
	var/turf/enemy_turf = get_turf(current_target)
	if(!current_turf || !enemy_turf || candidate.z != enemy_turf.z || hold_position_turf.z != enemy_turf.z)
		return FALSE
	if(!quick_order_step_within_boundary(candidate))
		return FALSE

	var/current_enemy_distance = get_dist(current_turf, enemy_turf)
	var/candidate_enemy_distance = get_dist(candidate, enemy_turf)
	var/current_enemy_manhattan = abs(current_turf.x - enemy_turf.x) + abs(current_turf.y - enemy_turf.y)
	var/candidate_enemy_manhattan = abs(candidate.x - enemy_turf.x) + abs(candidate.y - enemy_turf.y)
	if(candidate_enemy_distance < current_enemy_distance || candidate_enemy_manhattan < current_enemy_manhattan)
		return FALSE
	if(!allow_lateral && candidate_enemy_distance == current_enemy_distance && candidate_enemy_manhattan == current_enemy_manhattan)
		return FALSE

	return human_ai_turf_is_safe(candidate, FALSE, TRUE)

/// Selects the safest adjacent step toward the fallback point, including bounded obstacle detours.
/datum/human_ai_brain/proc/get_hold_position_retreat_step()
	if(!hold_position || !current_target || !has_valid_tied_human())
		return null

	var/turf/current_turf = get_turf(tied_human)
	if(!current_turf || current_turf == hold_position_turf)
		return null

	var/preferred_direction = get_dir(current_turf, hold_position_turf)
	var/list/turf/legal_candidates = list()
	for(var/direction in GLOB.alldirs)
		var/turf/candidate = get_step(current_turf, direction)
		if(hold_position_retreat_step_is_allowed(candidate, TRUE))
			legal_candidates += candidate

	if(!length(legal_candidates))
		return null

	var/turf/best_candidate
	var/best_score = INFINITY
	for(var/turf/candidate as anything in legal_candidates)
		if(candidate == hold_position_previous_turf && length(legal_candidates) > 1)
			continue

		var/score = get_dist(candidate, hold_position_turf) * 10
		score += abs(candidate.x - hold_position_turf.x) + abs(candidate.y - hold_position_turf.y)
		if(get_dir(current_turf, candidate) != preferred_direction)
			score++
		if(score < best_score)
			best_score = score
			best_candidate = candidate

	return best_candidate

/// Returns whether Hold Position has at least one legal direct or detour retreat step.
/datum/human_ai_brain/proc/can_hold_position_retreat()
	return !isnull(get_hold_position_retreat_step())

/// Releases all stale movement ownership before applying a new quick order.
/datum/human_ai_brain/proc/preempt_movement_for_quick_order()
	var/list/datum/ai_action/actions_to_cancel = list()
	for(var/datum/ai_action/ongoing_action as anything in ongoing_actions)
		if(quick_order_action_may_move(ongoing_action))
			actions_to_cancel += ongoing_action

	for(var/datum/ai_action/ongoing_action as anything in actions_to_cancel)
		qdel(ongoing_action)

	clear_navigation_path()
	reset_navigation_failures()
	end_cover()
	idle_defensive_position = null
	target_turf = current_target ? get_turf(current_target) : null
	ai_move_delay = 0

/// Applies Approach after preemption so destroying the previous action cannot erase the new target.
/datum/human_ai_brain/proc/apply_quick_approach_order(turf/destination)
	var/turf/safe_destination = human_ai_get_safe_standing_turf_near(destination)
	preempt_movement_for_quick_order()
	hold_position = FALSE
	hold_position_origin_turf = null
	hold_position_turf = null
	hold_position_previous_turf = null
	// orders clicked on furniture or scenery end beside it, never inside its sprite.
	quick_approach = safe_destination
	// Make one safe local step immediately; the normal scheduler/pathfinder owns the remaining route.
	if(has_valid_tied_human() && safe_destination && get_dist(tied_human, safe_destination) > 0)
		try_local_detour_towards_turf(safe_destination)

/// Cancels stale movement and establishes the maximum fallback boundary until Approach releases it.
/datum/human_ai_brain/proc/apply_quick_hold_position_order(turf/fallback_boundary)
	preempt_movement_for_quick_order()
	quick_approach = null
	hold_position_origin_turf = get_turf(tied_human)
	hold_position_turf = fallback_boundary ? fallback_boundary : get_turf(tied_human)
	hold_position_previous_turf = null
	hold_position = TRUE

/// The only positional action admitted by Hold Position: one bounded retreat or obstacle-detour step.
/datum/ai_action/hold_position_retreat
	name = "Hold Position Retreat"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/hold_position_retreat/get_weight(datum/human_ai_brain/brain)
	if(!brain.can_hold_position_retreat())
		return 0
	// Cover (15) and safe ally treatment (20) remain able to claim movement inside the boundary.
	return 10

/datum/ai_action/hold_position_retreat/trigger_action()
	. = ..()
	if(!brain.can_hold_position_retreat())
		return ONGOING_ACTION_COMPLETED

	var/turf/destination = brain.get_hold_position_retreat_step()
	var/turf/previous_turf = get_turf(brain.tied_human)
	if(destination && brain.move_to_next_turf(destination))
		brain.hold_position_previous_turf = previous_turf
		return ONGOING_ACTION_UNFINISHED

	return ONGOING_ACTION_COMPLETED
