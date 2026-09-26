// DemonicLynx for BandaMarines
#define HUMAN_AI_COVER_SCAN_LIMIT 198

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
	// SS220 EDIT: keep a lightweight count of human AI cover scans during HALO perf investigations
	halo_perf_bump_cover_scans()

	var/list/turf_dict = list()
	var/cover_dir = reverse_direction(angle2dir4ai(angle))

	// DemonicLynx for BandaMarines
	scan_turfs_for_cover(get_turf(tied_human), turf_dict, cover_dir)

#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_cover_value_debug), turf_dict.Copy()), 60 SECONDS)
#endif

	cover_processing(turf_dict)

/// If an AI decides to go into cover, any squadmates in their view range will process on the same view dictionary so as to help with performance
/datum/human_ai_brain/proc/squad_cover_processing(list/turf_dict)
	if(!squad_id)
		return

	var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
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

// DemonicLynx for BandaMarines
/// Iteratively searches nearby tiles and scores at most HUMAN_AI_COVER_SCAN_LIMIT candidates as cover.
// SS220 EDIT AI - START: recursive flood-fill exhausted BYOND's call stack and aborted Human AI processing
/datum/human_ai_brain/proc/scan_turfs_for_cover(turf/start_turf, list/turf_dict, cover_dir)
	if(!start_turf || !islist(turf_dict))
		return FALSE

	var/list/turf/scan_queue = list(start_turf)
	var/list/queued_turfs = list()
	queued_turfs[start_turf] = TRUE
	var/queue_index = 1

	while(queue_index <= length(scan_queue) && length(turf_dict) < HUMAN_AI_COVER_SCAN_LIMIT)
		var/turf/scan_turf = scan_queue[queue_index++]
		var/first_iteration = (scan_turf == start_turf)
		turf_dict[scan_turf] = 0

		var/tile_blocked = FALSE
		for(var/atom/movable/thing as anything in scan_turf.contents)
			if(!thing.density || istype(thing, /obj/structure/barricade))
				continue
			turf_dict[scan_turf] -= 1000
			// DemonicLynx for BandaMarines
			tile_blocked = TRUE
			break

		// DemonicLynx for BandaMarines
		// The starting turf contains the AI itself. Score it, but still expand from it.
		if(tile_blocked && !first_iteration)
			continue

		// DemonicLynx for BandaMarines
		var/obj/structure/barricade/cade = locate() in scan_turf.contents
		if(cade?.density && (cade?.dir in get_related_directions(cover_dir)))
			turf_dict[scan_turf] += cade.projectile_coverage / 2

		var/obj/item/explosive/mine/mine = locate() in scan_turf.contents
		if(mine)
			if(!faction_check(mine.iff_signal))
				turf_dict[scan_turf] -= 50
			else
				turf_dict[scan_turf] -= 5

		turf_dict[scan_turf] -= get_dist(tied_human, scan_turf)
		if(current_target)
			turf_dict[scan_turf] += get_dist(current_target, scan_turf) * 0.5
			if(get_dir(current_target, scan_turf) in get_related_directions(cover_dir))
				turf_dict[scan_turf] -= 20

		for(var/cardinal in shuffle(GLOB.cardinals))
			var/turf/nearby_turf = get_step(scan_turf, cardinal)
			if(!nearby_turf)
				continue

			if(istype(nearby_turf, /turf/closed))
				turf_dict[scan_turf] += 2
				if(cardinal in get_related_directions(cover_dir))
					turf_dict[scan_turf] += 8
				continue

			var/obj/structure/reagent_dispensers/fueltank/tank = locate() in nearby_turf.contents
			if(tank)
				turf_dict[scan_turf] -= 10

			if(length(scan_queue) >= HUMAN_AI_COVER_SCAN_LIMIT || queued_turfs[nearby_turf])
				continue
			queued_turfs[nearby_turf] = TRUE
			scan_queue += nearby_turf

#ifdef TESTING
		scan_turf.maptext = "<h2>[turf_dict[scan_turf]]</h2>"
#endif

	return TRUE
// DemonicLynx for BandaMarines
// SS220 EDIT AI - END

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
		// SS220 EDIT: forward the resolved cover scan once with the correct turf_dict payload
		if(!from_squad)
			squad_cover_processing(turf_dict)
			// DemonicLynx for BandaMarines

#undef HUMAN_AI_COVER_SCAN_LIMIT
