// Human AI throwable target and trajectory helpers.

/datum/human_ai_throwable_context/proc/can_throw_to_target(turf/target = target_turf)
	if(!AI?.has_valid_tied_human() || !grenade || QDELETED(grenade) || !target)
		return FALSE

	var/distance = controller.get_distance_to(target)
	if(distance <= min_safe_throw_distance)
		return FALSE

	var/effective_throw_range = get_effective_throw_range()
	if(!isnum(effective_throw_range))
		return FALSE

	if(distance > effective_throw_range)
		return FALSE

	var/list/turf_line = controller.get_line_to(target)
	for(var/turf/turf as anything in turf_line)
		if(turf.density)
			return FALSE

		for(var/obj/object in turf)
			if(object.density)
				return FALSE

	return TRUE

/datum/human_ai_throwable_context/proc/get_effective_throw_range()
	if(!grenade || QDELETED(grenade))
		return null

	var/effective_throw_range = isnum(grenade.throw_range) ? grenade.throw_range : throw_range_override
	if(!isnum(effective_throw_range))
		return null

	return effective_throw_range

/datum/human_ai_throwable_context/proc/get_fallback_throw_directions(turf/original_target)
	var/list/directions = list()
	var/original_dir = original_target ? controller.get_direction_to(original_target) : 0

	if(original_dir)
		for(var/direction in make_dir_cardinal(original_dir))
			if(!(direction in directions))
				directions += direction

	if(controller.get_current_dir())
		for(var/direction in make_dir_cardinal(controller.get_current_dir()))
			if(!(direction in directions))
				directions += direction

	for(var/direction in GLOB.cardinals)
		if(!(direction in directions))
			directions += direction

	return directions

/datum/human_ai_throwable_context/proc/has_friendly_near_throw_target(turf/target)
	if(!AI || !target)
		return FALSE

	for(var/mob/possible_friendly in range(AI.get_friendly_throw_check_range(), target))
		if(!AI.can_target(possible_friendly))
			return TRUE

	return FALSE

/datum/human_ai_throwable_context/proc/resolve_throw_target(turf/original_target = target_turf)
	if(can_throw_to_target(original_target))
		return original_target

	var/effective_throw_range = get_effective_throw_range()
	if(!isnum(effective_throw_range) || (effective_throw_range <= min_safe_throw_distance))
		return null

	var/list/fallback_directions = get_fallback_throw_directions(original_target)
	for(var/direction in fallback_directions)
		var/turf/cardinal_target = controller.get_ranged_target_turf(direction, effective_throw_range)
		if(can_throw_to_target(cardinal_target) && !has_friendly_near_throw_target(cardinal_target))
			return cardinal_target

	for(var/direction in fallback_directions)
		for(var/candidate_range = effective_throw_range; candidate_range > min_safe_throw_distance; candidate_range--)
			var/turf/cardinal_target = controller.get_ranged_target_turf(direction, candidate_range)
			if(can_throw_to_target(cardinal_target))
				return cardinal_target

	return null
