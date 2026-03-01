/mob/living/carbon/human
	var/tmp/datum/modular_squad_spawn_result/cached_modular_spawn_result
	var/tmp/cached_modular_spawn_job_type
	var/tmp/cached_modular_spawn_late_join = FALSE

/mob/living/carbon/human/proc/get_landmark_search_turfs(turf/center_turf)
	var/list/search_turfs = list()
	if(!isturf(center_turf))
		return search_turfs

	var/list/search_offsets = list(
		list(-1, 1),  // северо-запад
		list(0, 1),   // север
		list(1, 1),   // северо-восток
		list(-1, 0),  // запад
		list(0, 0),   // центр
		list(1, 0),   // восток
		list(-1, -1), // юго-запад
		list(0, -1),  // юг
		list(1, -1)   // юго-восток
	)

	for(var/list/offset in search_offsets)
		var/turf/candidate_turf = locate(center_turf.x + offset[1], center_turf.y + offset[2], center_turf.z)
		if(candidate_turf)
			search_turfs += candidate_turf

	return search_turfs

/mob/living/carbon/human/proc/is_spawn_turf_available(turf/candidate_turf)
	if(!isturf(candidate_turf) || candidate_turf.density)
		return FALSE

	for(var/atom/movable/movable as anything in candidate_turf)
		if(movable.density)
			return FALSE

	return TRUE

/mob/living/carbon/human/proc/find_first_spawn_turf_in_search_order(turf/center_turf)
	var/list/search_turfs = get_landmark_search_turfs(center_turf)
	for(var/turf/candidate_turf as anything in search_turfs)
		if(is_spawn_turf_available(candidate_turf))
			return candidate_turf

	return null

/mob/living/carbon/human/proc/find_free_cardinal_cryopod(turf/center_turf)
	if(!isturf(center_turf))
		return null

	var/list/cardinal_search_order = list(WEST, EAST, NORTH, SOUTH)
	for(var/cardinal_dir in cardinal_search_order)
		var/turf/candidate_turf = get_step(center_turf, cardinal_dir)
		if(!isturf(candidate_turf))
			continue

		var/obj/structure/machinery/cryopod/pod = locate(/obj/structure/machinery/cryopod) in candidate_turf
		if(!pod || pod.occupant)
			continue

		return pod

	return null

/mob/living/carbon/human/proc/find_free_cryopod_in_search_order(turf/center_turf)
	return find_free_cardinal_cryopod(center_turf)

/mob/living/carbon/human/proc/cache_modular_spawn_result(datum/modular_squad_spawn_result/spawn_result, datum/job/job_datum, late_join = FALSE)
	if(!istype(spawn_result))
		clear_modular_spawn_result_cache()
		return

	cached_modular_spawn_result = spawn_result
	cached_modular_spawn_job_type = job_datum?.type
	cached_modular_spawn_late_join = late_join

/mob/living/carbon/human/proc/clear_modular_spawn_result_cache()
	cached_modular_spawn_result = null
	cached_modular_spawn_job_type = null
	cached_modular_spawn_late_join = FALSE

/mob/living/carbon/human/proc/get_cached_modular_spawn_result(datum/job/job_datum = null)
	if(!istype(cached_modular_spawn_result))
		return null

	if(istype(job_datum) && cached_modular_spawn_job_type && cached_modular_spawn_job_type != job_datum.type)
		clear_modular_spawn_result_cache()
		return null

	if(!isturf(cached_modular_spawn_result.spawn_turf))
		clear_modular_spawn_result_cache()
		return null

	return cached_modular_spawn_result

/mob/living/carbon/human/proc/resolve_modular_spawn_result(datum/job/job_datum, late_join = FALSE)
	if(!istype(job_datum))
		return null

	var/datum/modular_squad_spawn_resolver/resolver = new(src, job_datum, late_join)
	var/datum/modular_squad_spawn_result/resolve_result = resolver.resolve()

	if(!resolve_result)
		clear_modular_spawn_result_cache()
		squads_debug_log("[src] modular resolver returned null for job=[job_datum.title], late_join=[late_join].")
		return null

	cache_modular_spawn_result(resolve_result, job_datum, late_join)
	return resolve_result

/mob/living/carbon/human/proc/get_modular_spawn_turf(datum/job/job_datum, late_join = FALSE)
	if(!istype(job_datum))
		squads_debug_log("[src] get_modular_spawn_turf called with invalid job_datum.")
		return null

	var/datum/modular_squad_spawn_result/resolve_result = resolve_modular_spawn_result(job_datum, late_join)
	if(resolve_result?.spawn_turf)
		return resolve_result.spawn_turf

	squads_debug_log("[src] no modular spawn turf resolved for [job_datum.title], late_join=[late_join].")
	return null

/mob/living/carbon/human/proc/find_free_squad_cryopod(datum/job/job_datum = null)
	var/datum/modular_squad_spawn_result/cached_result = get_cached_modular_spawn_result(job_datum)
	if(cached_result?.target_pod)
		return cached_result.target_pod

	return find_free_cardinal_cryopod(get_turf(src))

/mob/living/carbon/human/proc/try_enter_selected_cryopod(obj/structure/machinery/cryopod/target_pod)
	if(!target_pod || target_pod.occupant)
		return FALSE

	target_pod.go_in_cryopod(src, silent = TRUE)
	return loc == target_pod

/mob/living/carbon/human/proc/try_enter_nearby_free_cryopod(datum/job/job_datum = null)
	if(istype(loc, /obj/structure/machinery/cryopod))
		squads_debug_log("[src] is already inside cryopod; skipping enter.")
		return TRUE

	var/datum/modular_squad_spawn_result/cached_result = get_cached_modular_spawn_result(job_datum)
	if(cached_result?.target_pod)
		if(try_enter_selected_cryopod(cached_result.target_pod))
			squads_debug_log("[src] entered cached cryopod [cached_result.target_pod], source=[cached_result.source_tag], tier=[cached_result.tier_tag].")
			clear_modular_spawn_result_cache()
			return TRUE

		squads_debug_log("[src] cached cryopod [cached_result.target_pod] is no longer available.")

		if(cached_result.retry_allowed && istype(job_datum))
			cached_result.retry_allowed = FALSE
			var/datum/modular_squad_spawn_result/retry_result = resolve_modular_spawn_result(job_datum, cached_modular_spawn_late_join)
			if(retry_result)
				retry_result.retry_allowed = FALSE
				if(retry_result.target_pod && try_enter_selected_cryopod(retry_result.target_pod))
					squads_debug_log("[src] entered retry cryopod [retry_result.target_pod], source=[retry_result.source_tag], tier=[retry_result.tier_tag].")
					clear_modular_spawn_result_cache()
					return TRUE

		clear_modular_spawn_result_cache()
		squads_debug_log("[src] no available cryopod after retry, player remains on spawn turf.")
		return FALSE
	else if(cached_result)
		squads_debug_log("[src] cached spawn result has no cryopod by design, player remains on spawn turf.")
		return FALSE

	var/obj/structure/machinery/cryopod/local_pod = find_free_cardinal_cryopod(get_turf(src))
	if(local_pod && try_enter_selected_cryopod(local_pod))
		squads_debug_log("[src] entered fallback local cryopod [local_pod].")
		return TRUE

	squads_debug_log("[src] failed to find cryopod for job=[job_datum?.title].")
	return FALSE
