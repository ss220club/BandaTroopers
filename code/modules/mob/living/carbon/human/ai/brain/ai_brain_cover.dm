/datum/human_ai_brain
	/// If TRUE, AI is currently in some form of cover
	var/in_cover = FALSE

	/// Reference to atom currently selected as a cover place
	var/atom/current_cover

	COOLDOWN_DECLARE(cover_search_cooldown)

/datum/human_ai_brain/proc/end_cover()
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	if(current_cover)
		current_cover.color = null
		current_cover.maptext = null
#endif
	current_cover = null
	in_cover = FALSE

/datum/human_ai_brain/proc/on_shot_inside_cover(angle, atom/source)
	// Cover isn't working. Charge!
	end_cover()

/// Try to get the AI to find a suitable cover tile based on the angle a projectile came from.
/datum/human_ai_brain/proc/try_cover(angle, atom/source)
	if(!COOLDOWN_FINISHED(src, cover_search_cooldown))
		return

	if(!(cover_without_gun || primary_weapon))
		return

	COOLDOWN_START(src, cover_search_cooldown, 10 SECONDS)

	var/list/turf_dict = list()
	var/cover_dir = reverse_direction(angle2dir4ai(angle))

	recursive_turf_cover_scan(get_turf(tied_human), turf_dict, cover_dir)

#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_cover_value_debug), turf_dict.Copy()), 60 SECONDS)
#endif

	cover_processing(turf_dict)
	squad_cover_processing(turf_dict)

/// If an AI decides to go into cover, any squadmates in their view range will process on the same view dictionary so as to help with performance
/datum/human_ai_brain/proc/squad_cover_processing(list/turf_dict)
	if(!squad_id)
		return

	var/datum/human_ai_squad/squad = get_human_ai_runtime_squad("[squad_id]")
	if(!squad)
		return

	for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
		if(brain == src)
			continue

		if(get_dist(tied_human, brain.tied_human) > view_distance)
			continue

		if(brain.tied_human.is_mob_incapacitated())
			continue

		COOLDOWN_START(brain, cover_search_cooldown, 15 SECONDS)

		brain.cover_processing(turf_dict, TRUE)

/// Iteratively scans nearby tiles (up to 198) and determines cover suitability.
/// Kept under the original proc name for compatibility with existing callsites.
/datum/human_ai_brain/proc/recursive_turf_cover_scan(turf/scan_turf, list/turf_dict, cover_dir, first_iteration = TRUE)
	if(!scan_turf || !islist(turf_dict))
		return FALSE

	var/list/related_cover_dirs = get_related_directions(cover_dir)
	var/list/scan_queue = list(scan_turf)
	var/queue_index = 1

	while(queue_index <= length(scan_queue))
		var/turf/current_scan_turf = scan_queue[queue_index]
		queue_index++

		if(current_scan_turf in turf_dict)
			continue

		if(length(turf_dict) > 198)
			return FALSE

		turf_dict[current_scan_turf] = 0

		var/current_is_first_tile = (current_scan_turf == scan_turf) && first_iteration
		var/should_expand = TRUE

		for(var/atom/movable/thing as anything in current_scan_turf.contents)
			if(thing.density && !istype(thing, /obj/structure/barricade))
				turf_dict[current_scan_turf] -= 1000
				if(!current_is_first_tile)
					should_expand = FALSE
				break

		if(should_expand)
			var/obj/structure/barricade/cade = locate() in current_scan_turf.contents
			if(cade?.density && (cade?.dir in related_cover_dirs))
				turf_dict[current_scan_turf] += cade.projectile_coverage / 2

			var/obj/item/explosive/mine/mine = locate() in current_scan_turf.contents
			if(mine)
				if(!faction_check(mine.iff_signal))
					turf_dict[current_scan_turf] -= 50
				else
					turf_dict[current_scan_turf] -= 5 // even if it's our mine, we don't really want to stand on it

			turf_dict[current_scan_turf] -= get_dist(tied_human, current_scan_turf)
			if(current_target) // Might be smarter to hide in a different direction
				turf_dict[current_scan_turf] += get_dist(current_target, current_scan_turf) * 0.5
				if(get_dir(current_target, current_scan_turf) in related_cover_dirs)
					turf_dict[current_scan_turf] -= 20

			for(var/cardinal in shuffle(GLOB.cardinals))
				var/turf/nearby_turf = get_step(current_scan_turf, cardinal)
				if(!nearby_turf)
					continue

				if(istype(nearby_turf, /turf/closed))
					turf_dict[current_scan_turf] += 2 // Near a wall is a bit safer
					if(cardinal in related_cover_dirs)
						turf_dict[current_scan_turf] += 8
					continue

				var/obj/structure/reagent_dispensers/fueltank/tank = locate() in nearby_turf.contents
				if(tank)
					turf_dict[current_scan_turf] -= 10 // ideally not near any highly explosive fuel tanks if we can help it

				if(!(nearby_turf in turf_dict))
					scan_queue += nearby_turf

#ifdef TESTING
		current_scan_turf.maptext = "<h2>[turf_dict[current_scan_turf]]</h2>"
#endif

	return TRUE

/datum/human_ai_brain/proc/clear_cover_value_debug(list/turf_list)
	for(var/turf/T as anything in turf_list)
		T.maptext = null

/datum/human_ai_brain/proc/cover_processing(list/turf_dict, from_squad = FALSE)
	var/most_weight = -INFINITY
	var/turf/best_cover
	for(var/turf/T as anything in turf_dict)
		var/weight = turf_dict[T]
		if(weight > most_weight)
			most_weight = weight
			best_cover = T

	if(best_cover && best_cover != get_turf(tied_human))
		turf_dict -= best_cover
		// insert cover atom deletion/move comsigs here
		current_cover = best_cover
		if(!from_squad)
			squad_cover_processing(FALSE, turf_dict)
