/mob/living/carbon/human/proc/get_landmark_search_turfs(turf/center_turf)
	var/list/search_turfs = list()
	if(!isturf(center_turf))
		return search_turfs

	var/list/y_offsets = list(1, 0, -1)
	var/list/x_offsets = list(-1, 0, 1)
	for(var/y_offset in y_offsets)
		for(var/x_offset in x_offsets)
			var/turf/candidate_turf = locate(center_turf.x + x_offset, center_turf.y + y_offset, center_turf.z)
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

/mob/living/carbon/human/proc/find_free_cryopod_in_search_order(turf/center_turf)
	var/list/search_turfs = get_landmark_search_turfs(center_turf)
	for(var/turf/candidate_turf as anything in search_turfs)
		var/obj/structure/machinery/cryopod/pod = locate(/obj/structure/machinery/cryopod) in candidate_turf
		if(!pod || pod.occupant)
			continue
		return pod

	return null

/mob/living/carbon/human/proc/add_spawn_key_if_missing(list/spawn_keys, spawn_key)
	if(!islist(spawn_keys) || !spawn_key)
		return
	if(!(spawn_key in spawn_keys))
		spawn_keys += spawn_key

/mob/living/carbon/human/proc/get_assigned_squad_spawn_keys()
	var/list/spawn_keys = list()
	if(!assigned_squad)
		squads_debug_log("[src] has no assigned_squad while collecting spawn keys.")
		return spawn_keys

	add_spawn_key_if_missing(spawn_keys, assigned_squad.name)

	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager)
		return spawn_keys

	var/static_squad_name = manager.get_static_name_by_squad(assigned_squad)
	if(static_squad_name)
		add_spawn_key_if_missing(spawn_keys, static_squad_name)
		add_spawn_key_if_missing(spawn_keys, manager.get_runtime_name_by_static(static_squad_name))

	squads_debug_log("[src] spawn keys: [jointext(spawn_keys, ", ")].")
	return spawn_keys

/mob/living/carbon/human/proc/add_job_landmarks_for_squad_key(list/landmarks, squad_key, datum/job/job_datum)
	if(!islist(landmarks) || !squad_key || !istype(job_datum))
		return

	var/list/squad_job_landmarks = GLOB.spawns_by_squad_and_job[squad_key]
	if(!islist(squad_job_landmarks))
		return

	for(var/job_key in squad_job_landmarks)
		if(!(job_key == job_datum.type || ispath(job_datum.type, job_key) || ispath(job_key, job_datum.type)))
			continue

		var/list/job_landmarks = squad_job_landmarks[job_key]
		if(!islist(job_landmarks))
			continue

		for(var/obj/effect/landmark/start/landmark as anything in job_landmarks)
			if(!(landmark in landmarks))
				landmarks += landmark

/mob/living/carbon/human/proc/get_job_landmarks_for_assigned_squad(datum/job/job_datum)
	var/list/landmarks = list()
	if(!istype(job_datum))
		return landmarks

	var/list/spawn_keys = get_assigned_squad_spawn_keys()
	for(var/squad_key in spawn_keys)
		add_job_landmarks_for_squad_key(landmarks, squad_key, job_datum)

	return landmarks

/mob/living/carbon/human/proc/add_all_job_landmarks_for_squad_key(list/landmarks, squad_key)
	if(!islist(landmarks) || !squad_key)
		return

	var/list/squad_job_landmarks = GLOB.spawns_by_squad_and_job[squad_key]
	if(!islist(squad_job_landmarks))
		return

	for(var/job_key in squad_job_landmarks)
		var/list/job_landmarks = squad_job_landmarks[job_key]
		if(!islist(job_landmarks))
			continue
		for(var/obj/effect/landmark/start/landmark as anything in job_landmarks)
			if(!(landmark in landmarks))
				landmarks += landmark

/mob/living/carbon/human/proc/get_all_job_landmarks_for_assigned_squad()
	var/list/landmarks = list()
	var/list/spawn_keys = get_assigned_squad_spawn_keys()
	for(var/squad_key in spawn_keys)
		add_all_job_landmarks_for_squad_key(landmarks, squad_key)

	return landmarks

/mob/living/carbon/human/proc/add_latejoin_landmarks_for_squad_key(list/landmarks, squad_key)
	if(!islist(landmarks) || !squad_key)
		return

	var/list/source_landmarks = GLOB.latejoin_by_squad[squad_key]
	if(!islist(source_landmarks))
		return

	for(var/obj/effect/landmark/late_join/landmark as anything in source_landmarks)
		if(!(landmark in landmarks))
			landmarks += landmark

/mob/living/carbon/human/proc/get_latejoin_landmarks_for_assigned_squad()
	var/list/landmarks = list()
	var/list/spawn_keys = get_assigned_squad_spawn_keys()
	for(var/squad_key in spawn_keys)
		add_latejoin_landmarks_for_squad_key(landmarks, squad_key)

	return landmarks

/mob/living/carbon/human/proc/pick_spawn_turf_from_landmarks(list/landmarks, debug_source)
	if(!islist(landmarks) || !length(landmarks))
		return null

	var/list/landmarks_pool = landmarks.Copy()
	while(length(landmarks_pool))
		var/obj/effect/landmark/landmark = pick_n_take(landmarks_pool)
		if(!landmark)
			continue

		var/turf/spawn_turf = find_first_spawn_turf_in_search_order(get_turf(landmark))
		if(spawn_turf)
			squads_debug_log("[src] spawn turf [spawn_turf] resolved from [debug_source] landmark [landmark].")
			return spawn_turf

	squads_debug_log("[src] no spawn turf found in 3x3 search for [debug_source].")
	return null

/mob/living/carbon/human/proc/pick_free_cryopod_from_landmarks(list/landmarks, debug_source)
	if(!islist(landmarks) || !length(landmarks))
		return null

	var/list/landmarks_pool = landmarks.Copy()
	while(length(landmarks_pool))
		var/obj/effect/landmark/landmark = pick_n_take(landmarks_pool)
		if(!landmark)
			continue

		var/obj/structure/machinery/cryopod/pod = find_free_cryopod_in_search_order(get_turf(landmark))
		if(pod)
			squads_debug_log("[src] cryopod [pod] resolved from [debug_source] landmark [landmark].")
			return pod

	squads_debug_log("[src] no free cryopod found in 3x3 search for [debug_source].")
	return null

/mob/living/carbon/human/proc/get_modular_spawn_turf(datum/job/job_datum, late_join = FALSE)
	if(!istype(job_datum))
		squads_debug_log("[src] get_modular_spawn_turf called with invalid job_datum.")
		return null

	if(late_join)
		var/list/job_landmarks = get_job_landmarks_for_assigned_squad(job_datum)
		var/turf/spawn_turf = pick_spawn_turf_from_landmarks(job_landmarks, "squad_job_exact/[job_datum.title]")
		if(spawn_turf)
			return spawn_turf

		var/list/any_squad_job_landmarks = get_all_job_landmarks_for_assigned_squad()
		spawn_turf = pick_spawn_turf_from_landmarks(any_squad_job_landmarks, "squad_job_any/[job_datum.title]")
		if(spawn_turf)
			return spawn_turf

		var/list/squad_landmarks = get_latejoin_landmarks_for_assigned_squad()
		spawn_turf = pick_spawn_turf_from_landmarks(squad_landmarks, "squad_latejoin/[job_datum.title]")
		if(spawn_turf)
			return spawn_turf

		spawn_turf = pick_spawn_turf_from_landmarks(GLOB.latejoin_by_job[job_datum.title], "job_latejoin/[job_datum.title]")
		if(spawn_turf)
			return spawn_turf

	squads_debug_log("[src] no modular latejoin spawn turf resolved for [job_datum?.title].")
	return null

/mob/living/carbon/human/proc/find_free_squad_cryopod(datum/job/job_datum = null)
	if(istype(job_datum))
		var/obj/structure/machinery/cryopod/pod = pick_free_cryopod_from_landmarks(get_job_landmarks_for_assigned_squad(job_datum), "squad_job_exact/[job_datum.title]")
		if(pod)
			return pod

		pod = pick_free_cryopod_from_landmarks(get_all_job_landmarks_for_assigned_squad(), "squad_job_any/[job_datum.title]")
		if(pod)
			return pod

		pod = pick_free_cryopod_from_landmarks(get_latejoin_landmarks_for_assigned_squad(), "squad_latejoin/[job_datum.title]")
		if(pod)
			return pod

		pod = pick_free_cryopod_from_landmarks(GLOB.latejoin_by_job[job_datum.title], "job_latejoin/[job_datum.title]")
		if(pod)
			return pod

	var/obj/structure/machinery/cryopod/fallback_pod = find_free_cryopod_in_search_order(get_turf(src))
	if(fallback_pod)
		squads_debug_log("[src] fallback cryopod [fallback_pod] resolved from current turf 3x3 search.")
	else
		squads_debug_log("[src] no free cryopod found for job=[job_datum?.title].")
	return fallback_pod

/mob/living/carbon/human/proc/try_enter_nearby_free_cryopod(datum/job/job_datum = null)
	if(istype(loc, /obj/structure/machinery/cryopod))
		squads_debug_log("[src] is already inside cryopod; skipping enter.")
		return TRUE

	var/obj/structure/machinery/cryopod/target_pod = find_free_squad_cryopod(job_datum)
	if(!target_pod)
		squads_debug_log("[src] failed to find cryopod for job=[job_datum?.title].")
		return FALSE

	target_pod.go_in_cryopod(src, silent = TRUE)
	squads_debug_log("[src] attempted cryopod enter [target_pod], success=[loc == target_pod].")
	return loc == target_pod
