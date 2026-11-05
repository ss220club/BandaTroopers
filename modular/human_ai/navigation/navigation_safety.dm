
/// Returns whether this structure is one of the map-specific platform staircase families.
/datum/human_ai_brain/proc/human_ai_is_platform_stairs(atom/obstacle)
	return istype(obstacle, /obj/structure/platform/stair_cut) || istype(obstacle, /obj/structure/platform/metal/stair_cut) || istype(obstacle, /obj/structure/platform/stone/stair_cut)

/// Returns whether a turf is a composite staircase tile assembled from a stair cut and platform segments.
/datum/human_ai_brain/proc/human_ai_turf_has_platform_stairs(turf/candidate)
	for(var/obj/structure/platform/platform_segment as anything in candidate.contents)
		if(human_ai_is_platform_stairs(platform_segment))
			return TRUE
	return FALSE

/// Returns whether this is canonical non-dense infrastructure rendered underneath a walkable floor.
/datum/human_ai_brain/proc/human_ai_is_underfloor_infrastructure(atom/movable/obstacle)
	if(obstacle.density)
		return FALSE
	return istype(obstacle, /obj/structure/pipes) || istype(obstacle, /obj/structure/cable) || istype(obstacle, /obj/structure/disposalpipe)

/// Returns whether a normal human can use this structure as an intermediate movement step.
/// LinkBlocked(), special blockers, access checks, and can_climb() remain authoritative after this coarse filter.
/datum/human_ai_brain/proc/human_ai_structure_is_traversable(obj/structure/obstacle, allow_doors = FALSE, has_platform_stairs = FALSE)
	if(istype(obstacle, /obj/structure/machinery/door))
		return allow_doors
	if(!obstacle.density)
		return TRUE
	if(obstacle.climbable)
		return TRUE
	return has_platform_stairs && istype(obstacle, /obj/structure/platform)

/// Finds a nearby real floor position when an order was clicked on scenery or another unsafe standing tile.
/datum/human_ai_brain/proc/human_ai_get_safe_standing_turf_near(turf/requested_turf)
	if(!isturf(requested_turf))
		return null
	if(human_ai_turf_is_safe(requested_turf, ignore_owner = TRUE))
		return requested_turf

	var/turf/best_turf
	var/best_distance = INFINITY
	for(var/turf/candidate as anything in requested_turf.AdjacentTurfs())
		if(!human_ai_turf_is_safe(candidate, ignore_owner = TRUE))
			continue
		var/candidate_distance = tied_human ? get_dist(tied_human, candidate) : 0
		if(candidate_distance >= best_distance)
			continue
		best_distance = candidate_distance
		best_turf = candidate
	return best_turf

/// Returns whether Human AI may stand on this turf without overlapping map scenery.
/// Doors and selected traversal structures may be admitted only as path steps; their own interaction logic remains authoritative.
/datum/human_ai_brain/proc/human_ai_turf_is_safe(turf/candidate, ignore_owner = FALSE, allow_doors = FALSE, allow_traversal_structures = FALSE)
	if(!isturf(candidate) || QDELETED(candidate) || candidate.density || istype(candidate, /turf/closed) || istype(candidate, /turf/open/space) || istype(candidate, /turf/open/gm/river))
		return FALSE

	var/has_platform_stairs = allow_traversal_structures && human_ai_turf_has_platform_stairs(candidate)
	for(var/atom/movable/obstacle as anything in candidate.contents)
		if(istype(obstacle, /obj/flamer_fire) || istype(obstacle, /obj/item/explosive/mine))
			return FALSE
		if(ignore_owner && obstacle == tied_human)
			continue
		if(allow_doors && istype(obstacle, /obj/structure/machinery/door))
			continue
		// infrastructure below the floor never blocks a tile a normal human can walk across.
		if(human_ai_is_underfloor_infrastructure(obstacle))
			continue
		if(istype(obstacle, /obj/vehicle))
			return FALSE
		if(istype(obstacle, /obj/structure))
			var/obj/structure/structure = obstacle
			// traversal follows human physics; strict destinations remain free of scenery.
			if(allow_traversal_structures && human_ai_structure_is_traversable(structure, allow_doors, has_platform_stairs))
				continue
			return FALSE
		if(obstacle.density)
			return FALSE

	return TRUE

/// Returns the active goal used only to rank clean adjacent egress tiles.
/datum/human_ai_brain/proc/get_unsafe_turf_egress_goal()
	if(quick_approach)
		return quick_approach
	if(current_path_target)
		return current_path_target
	if(current_cover)
		return current_cover
	if(target_turf)
		return target_turf
	return idle_defensive_position

/// Chooses a normal adjacent step off scenery without weakening traversal rules.
/datum/human_ai_brain/proc/get_unsafe_turf_egress_destination()
	if(!has_valid_tied_human())
		return null

	var/turf/current_turf = get_turf(tied_human)
	if(!current_turf || human_ai_turf_is_safe(current_turf, TRUE, FALSE))
		return null

	var/turf/goal = get_unsafe_turf_egress_goal()
	var/turf/best_turf
	var/best_score = INFINITY
	for(var/direction in GLOB.alldirs)
		var/turf/candidate = get_step(current_turf, direction)
		if(!candidate || !quick_order_step_within_boundary(candidate) || !human_ai_turf_is_safe(candidate))
			continue
		var/list/interactions = get_adjacent_move_interactions(candidate)
		if(isnull(interactions))
			continue

		var/score = goal ? get_dist(candidate, goal) * 10 : 0
		if(candidate == last_navigation_turf)
			score += 5
		if(score >= best_score)
			continue
		best_score = score
		best_turf = candidate

	return best_turf

/// Releases stale movement ownership so emergency egress can run on this scheduler tick.
/datum/human_ai_brain/proc/preempt_actions_for_unsafe_turf()
	if(has_live_grenade_emergency() || has_navigation_in_progress())
		return
	if(!has_valid_tied_human() || human_ai_turf_is_safe(get_turf(tied_human), TRUE, FALSE))
		return

	var/list/datum/ai_action/actions_to_cancel = list()
	for(var/datum/ai_action/action as anything in ongoing_actions)
		if(istype(action, /datum/ai_action/leave_unsafe_turf))
			continue
		if(quick_order_action_may_move(action))
			actions_to_cancel += action
	for(var/datum/ai_action/action as anything in actions_to_cancel)
		qdel(action)

/datum/ai_action/leave_unsafe_turf
	name = "Leave Unsafe Turf"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/leave_unsafe_turf/get_weight(datum/human_ai_brain/brain)
	if(brain.has_live_grenade_emergency() || brain.has_navigation_in_progress())
		return 0
	if(!brain.has_valid_tied_human() || brain.human_ai_turf_is_safe(get_turf(brain.tied_human), TRUE, FALSE))
		return 0
	return INFINITY

/datum/ai_action/leave_unsafe_turf/trigger_action()
	. = ..()
	if(brain.human_ai_turf_is_safe(get_turf(brain.tied_human), TRUE, FALSE))
		return ONGOING_ACTION_COMPLETED

	var/turf/destination = brain.get_unsafe_turf_egress_destination()
	if(!destination)
		return ONGOING_ACTION_UNFINISHED_BLOCK
	if(!brain.complete_adjacent_move_to_turf(destination))
		return ONGOING_ACTION_UNFINISHED_BLOCK
	return ONGOING_ACTION_COMPLETED
