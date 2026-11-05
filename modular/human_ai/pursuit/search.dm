/datum/human_ai_brain
	var/pursuit_active = FALSE
	var/datum/ai_order/pursuit_order_snapshot
	var/pursuit_moving = FALSE
	var/pursuit_returning = FALSE
	var/turf/pursuit_origin
	var/turf/pursuit_anchor
	var/turf/pursuit_goal
	var/turf/pursuit_progress_turf
	var/pursuit_progress_at = 0
	var/pursuit_return_until = 0
	var/pursuit_points_left = 0
	var/pursuit_role = 0 // scout, cover, flank
	var/list/pursuit_visited = list()
	var/list/pursuit_checked_corners = list()
	var/pursuit_pause_until = 0
	var/pursuit_last_direction = NONE
	var/pursuit_search_depth = 0
	var/pursuit_search_heading = NONE
	var/pursuit_deadline = 0
	var/pursuit_total_deadline = 0
	var/pursuit_inspecting = FALSE

/datum/human_ai_brain/proc/pursuit_clear_search()
	if(pursuit_active || pursuit_returning)
		clear_navigation_path()
	pursuit_active = FALSE
	pursuit_returning = FALSE
	pursuit_goal = null
	pursuit_anchor = null
	pursuit_origin = null
	pursuit_order_snapshot = null
	pursuit_visited.Cut()
	pursuit_checked_corners.Cut()
	pursuit_pause_until = 0
	pursuit_inspecting = FALSE
	pursuit_deadline = 0
	pursuit_total_deadline = 0

/datum/human_ai_brain/proc/pursuit_can_start()
	return setting("pursuit_enabled") && setting("chase_time") > 0 && !current_target && !hold_position && pursuit_observed_turf && pursuit_observed_at > pursuit_consumed_at && world.time < pursuit_observed_at + setting("chase_time") * 10 && tied_human.z == pursuit_observed_turf.z && get_dist(tied_human, pursuit_observed_turf) <= 20

/datum/human_ai_brain/proc/pursuit_choose_role()
	if(!setting("pursuit_team") || !squad_id)
		return 0
	var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
	if(!squad)
		return 0
	var/rank = 0
	var/checked = 0
	for(var/datum/human_ai_brain/member as anything in squad.ai_in_squad)
		if(++checked > 16)
			break
		if(member == src)
			return rank % 3
		if(!member.has_valid_tied_human() || member.tied_human.stat == DEAD || member.tied_human.client || member.hold_position || !member.setting("pursuit_team") || !member.setting("pursuit_enabled") || !faction_check(member.tied_human))
			continue
		if(member.tied_human.z != tied_human.z || get_dist(member.tied_human, tied_human) > setting("pursuit_share_radius"))
			continue
		if(!member.pursuit_observed_turf || member.pursuit_observed_at <= member.pursuit_consumed_at || world.time >= member.pursuit_observed_at + member.setting("chase_time") * 10 || get_dist(member.pursuit_observed_turf, pursuit_observed_turf) > 2)
			continue
		rank++
	return 0

/datum/human_ai_brain/proc/pursuit_start()
	end_cover()
	pursuit_active = TRUE
	pursuit_inspecting = FALSE
	pursuit_deadline = world.time + 10 SECONDS
	pursuit_total_deadline = pursuit_deadline + setting("chase_time") * 10
	pursuit_order_snapshot = current_order
	pursuit_origin = get_turf(tied_human)
	pursuit_anchor = pursuit_observed_turf
	pursuit_role = pursuit_choose_role()
	pursuit_points_left = setting("pursuit_points")
	pursuit_last_direction = tied_human.dir
	pursuit_search_depth = 0
	pursuit_search_heading = setting("pursuit_predict") ? pursuit_observed_heading : NONE
	if(!pursuit_search_heading)
		pursuit_search_heading = get_dir(pursuit_origin, pursuit_anchor)
	if(!pursuit_search_heading)
		pursuit_search_heading = tied_human.dir
	pursuit_visited.Cut()
	pursuit_checked_corners.Cut()
	pursuit_set_goal(pursuit_role == 1 ? pursuit_origin : pursuit_anchor)
	if(pursuit_role == 2)
		var/turf/flank = pursuit_pick_point(TRUE)
		if(flank)
			pursuit_set_goal(flank)

/datum/human_ai_brain/proc/pursuit_set_goal(turf/position)
	clear_navigation_path()
	pursuit_goal = position
	pursuit_progress_turf = get_turf(tied_human)
	pursuit_progress_at = world.time

/// Keep the observed goal as the search anchor, but recognize navigation's safe standing endpoint.
/datum/human_ai_brain/proc/pursuit_has_reached_goal()
	return has_reached_navigation_destination(human_ai_get_safe_standing_turf_near(pursuit_goal))

/// Three bounded rays, not a room scan. Native navigation handles intervening doors.
/datum/human_ai_brain/proc/pursuit_pick_point(flanking = FALSE)
	if(!pursuit_anchor)
		return null
	var/heading = pursuit_search_heading
	if(flanking)
		heading = turn(heading, 90)
	var/radius = setting("pursuit_radius")
	var/depth = flanking ? 0 : pursuit_search_depth
	while(depth < radius)
		depth = min(depth + 2, radius)
		if(!flanking)
			pursuit_search_depth = depth
		for(var/angle in list(0, 45, -45))
			var/turf/candidate = pursuit_anchor
			var/direction = turn(heading, angle)
			for(var/step_index in 1 to depth)
				candidate = get_step(candidate, direction)
				if(!candidate)
					break
			if(!candidate || candidate == get_turf(tied_human) || candidate in pursuit_visited)
				continue
			if(!human_ai_turf_is_safe(candidate, TRUE, FALSE) || !quick_order_step_within_boundary(candidate))
				continue
			return candidate
	return null

/datum/human_ai_brain/proc/pursuit_next_point()
	if(pursuit_goal == pursuit_anchor && !pursuit_inspecting)
		if(!pursuit_has_reached_goal())
			pursuit_finish()
			return
		pursuit_inspecting = TRUE
		pursuit_deadline = min(world.time + setting("chase_time") * 10, pursuit_total_deadline)
	if(pursuit_goal)
		pursuit_visited[pursuit_goal] = TRUE
	if(!(pursuit_anchor in pursuit_visited))
		pursuit_set_goal(pursuit_anchor)
		return
	if(pursuit_points_left-- > 0)
		var/turf/next_point = pursuit_pick_point()
		if(next_point)
			pursuit_set_goal(next_point)
			return
	pursuit_finish()

/datum/human_ai_brain/proc/pursuit_finish(allow_return = TRUE)
	var/turf/return_to = pursuit_origin
	pursuit_consumed_at = pursuit_observed_at
	pursuit_clear_search()
	if(current_target)
		return
	target_turf = null
	in_combat = FALSE
	end_cover()
	var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
	var/resume_following = squad?.squad_leader && !is_squad_leader
	if(allow_return && setting("pursuit_return") && !current_order && !resume_following && return_to && get_turf(tied_human) != return_to && !hold_position)
		pursuit_returning = TRUE
		pursuit_return_until = world.time + 10 SECONDS
		pursuit_set_goal(return_to)

/// Nonblocking hesitation, once per tile in this search.
/datum/human_ai_brain/proc/pursuit_caution(turf/next_step)
	if(world.time < pursuit_pause_until)
		return TRUE
	if(!setting("pursuit_cautious") || setting("pursuit_pause") <= 0 || !next_step)
		return FALSE
	var/turf/position = get_turf(tied_human)
	if(position in pursuit_checked_corners)
		return FALSE
	var/direction = get_dir(position, next_step)
	var/near_door = (locate(/obj/structure/machinery/door) in next_step)
	var/at_corner = FALSE
	if(direction != pursuit_last_direction)
		for(var/cardinal in GLOB.cardinals)
			var/turf/neighbor = get_step(position, cardinal)
			if(neighbor?.density)
				at_corner = TRUE
	if(!near_door && !at_corner)
		return FALSE
	pursuit_checked_corners[position] = TRUE
	pursuit_pause_until = world.time + setting("pursuit_pause") * 10
	tied_human.face_dir(direction)
	return TRUE
