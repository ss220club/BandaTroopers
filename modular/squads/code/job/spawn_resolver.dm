/datum/modular_squad_spawn_result
	var/obj/effect/landmark/landmark
	var/turf/spawn_turf
	var/obj/structure/machinery/cryopod/target_pod
	var/source_tag
	var/tier_tag
	var/no_pod_expected = FALSE

/datum/modular_squad_spawn_resolver
	var/mob/living/carbon/human/owner
	var/datum/job/job_datum
	var/late_join_mode = FALSE

/datum/modular_squad_spawn_resolver/New(mob/living/carbon/human/new_owner, datum/job/new_job_datum, late_join = FALSE)
	. = ..()
	owner = new_owner
	job_datum = new_job_datum
	late_join_mode = late_join

/datum/modular_squad_spawn_resolver/proc/add_unique_value(list/target_list, value)
	if(!islist(target_list) || !value)
		return
	if(!(value in target_list))
		target_list += value

/datum/modular_squad_spawn_resolver/proc/is_target_job_squad_role()
	if(!istype(job_datum))
		return FALSE
	return !!GLOB.job_squad_roles.Find(GET_DEFAULT_ROLE(job_datum.title))

/datum/modular_squad_spawn_resolver/proc/get_own_squad_keys()
	var/list/squad_keys = list()
	if(!owner?.assigned_squad)
		return squad_keys

	add_unique_value(squad_keys, owner.assigned_squad.name)

	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager)
		return squad_keys

	var/static_name = manager.get_static_name_by_squad(owner.assigned_squad)
	if(static_name)
		add_unique_value(squad_keys, static_name)
		add_unique_value(squad_keys, manager.get_runtime_name_by_static(static_name))

	return squad_keys

/datum/modular_squad_spawn_resolver/proc/get_other_squad_keys(list/own_squad_keys)
	var/list/other_squad_keys = list()

	for(var/squad_key in GLOB.spawns_by_squad_and_job)
		add_unique_value(other_squad_keys, squad_key)

	for(var/squad_key in GLOB.latejoin_by_squad)
		add_unique_value(other_squad_keys, squad_key)

	if(islist(own_squad_keys))
		for(var/squad_key in own_squad_keys)
			other_squad_keys -= squad_key

	return other_squad_keys

/datum/modular_squad_spawn_resolver/proc/is_spawn_turf_available(turf/candidate_turf)
	if(!isturf(candidate_turf) || candidate_turf.density)
		return FALSE

	for(var/atom/movable/movable as anything in candidate_turf)
		if(movable.density)
			return FALSE

	return TRUE

/datum/modular_squad_spawn_resolver/proc/start_job_key_matches_target(job_key)
	if(!ispath(job_key, /datum/job) || !ispath(job_datum?.type, /datum/job))
		return FALSE
	return (job_key == job_datum.type || ispath(job_datum.type, job_key) || ispath(job_key, job_datum.type))

/datum/modular_squad_spawn_resolver/proc/is_squad_role_job_key(job_key)
	if(!ispath(job_key, /datum/job))
		return FALSE

	var/datum/job/job_by_path = GLOB.RoleAuthority?.roles_by_path[job_key]
	if(!job_by_path)
		return FALSE

	return !!GLOB.job_squad_roles.Find(GET_DEFAULT_ROLE(job_by_path.title))

/datum/modular_squad_spawn_resolver/proc/latejoin_landmark_matches_target_job(obj/effect/landmark/late_join/landmark)
	if(!istype(landmark) || !landmark.job || !job_datum?.title)
		return FALSE

	if(ispath(landmark.job, /datum/job))
		return (landmark.job == job_datum.type || ispath(job_datum.type, landmark.job) || ispath(landmark.job, job_datum.type))

	return (landmark.job == job_datum.title || GET_DEFAULT_ROLE(landmark.job) == GET_DEFAULT_ROLE(job_datum.title))

/datum/modular_squad_spawn_resolver/proc/latejoin_job_key_matches_target(job_key)
	if(!job_key || !job_datum?.title)
		return FALSE

	if(ispath(job_key, /datum/job))
		return (job_key == job_datum.type || ispath(job_datum.type, job_key) || ispath(job_key, job_datum.type))

	return (job_key == job_datum.title || GET_DEFAULT_ROLE(job_key) == GET_DEFAULT_ROLE(job_datum.title))

/datum/modular_squad_spawn_resolver/proc/collect_start_landmarks(list/squad_keys, exact_job = FALSE, squad_roles_only = FALSE)
	var/list/landmarks = list()
	if(!islist(squad_keys) || !length(squad_keys))
		return landmarks

	for(var/squad_key in squad_keys)
		var/list/squad_bucket = GLOB.spawns_by_squad_and_job[squad_key]
		if(!islist(squad_bucket))
			continue

		for(var/job_key in squad_bucket)
			if(exact_job && !start_job_key_matches_target(job_key))
				continue
			if(squad_roles_only && !is_squad_role_job_key(job_key))
				continue

			var/list/job_landmarks = squad_bucket[job_key]
			if(!islist(job_landmarks))
				continue

			for(var/obj/effect/landmark/start/landmark as anything in job_landmarks)
				if(!(landmark in landmarks))
					landmarks += landmark

	return landmarks

/datum/modular_squad_spawn_resolver/proc/collect_latejoin_landmarks(list/squad_keys, exact_job = FALSE)
	var/list/landmarks = list()
	if(!islist(squad_keys) || !length(squad_keys))
		return landmarks

	for(var/squad_key in squad_keys)
		var/list/squad_bucket = GLOB.latejoin_by_squad[squad_key]
		if(!islist(squad_bucket))
			continue

		for(var/obj/effect/landmark/late_join/landmark as anything in squad_bucket)
			if(exact_job && !latejoin_landmark_matches_target_job(landmark))
				continue
			if(!(landmark in landmarks))
				landmarks += landmark

	return landmarks

/datum/modular_squad_spawn_resolver/proc/collect_latejoin_job_landmarks()
	var/list/landmarks = list()

	for(var/job_key in GLOB.latejoin_by_job)
		if(!latejoin_job_key_matches_target(job_key))
			continue

		var/list/job_landmarks = GLOB.latejoin_by_job[job_key]
		if(!islist(job_landmarks))
			continue

		for(var/obj/effect/landmark/late_join/landmark as anything in job_landmarks)
			if(!(landmark in landmarks))
				landmarks += landmark

	return landmarks

/datum/modular_squad_spawn_resolver/proc/collect_landmarks_for_step(source_tag, tier_index, list/own_squad_keys, list/other_squad_keys)
	switch(source_tag)
		if("start")
			switch(tier_index)
				if(1)
					return collect_start_landmarks(own_squad_keys, exact_job = TRUE)
				if(2)
					return collect_start_landmarks(own_squad_keys, squad_roles_only = TRUE)
				if(3)
					return collect_start_landmarks(other_squad_keys, exact_job = TRUE)
				if(4)
					return collect_start_landmarks(other_squad_keys, squad_roles_only = TRUE)

		if("latejoin")
			switch(tier_index)
				if(1)
					return collect_latejoin_landmarks(own_squad_keys, exact_job = TRUE)
				if(2)
					return collect_latejoin_landmarks(own_squad_keys)
				if(3)
					return collect_latejoin_landmarks(other_squad_keys, exact_job = TRUE)
				if(4)
					return collect_latejoin_landmarks(other_squad_keys)

		if("latejoin_job")
			return collect_latejoin_job_landmarks()

	return list()

/datum/modular_squad_spawn_resolver/proc/build_results_from_landmarks(list/landmarks, source_tag, tier_tag, require_free_pod = TRUE)
	var/list/results = list()
	if(!islist(landmarks) || !length(landmarks))
		return results

	for(var/obj/effect/landmark/landmark as anything in landmarks)
		if(QDELETED(landmark))
			continue

		var/turf/center_turf = get_turf(landmark)
		if(!is_spawn_turf_available(center_turf))
			continue

		var/obj/structure/machinery/cryopod/pod = owner.find_free_cardinal_cryopod(center_turf)
		if(require_free_pod && !pod)
			continue

		var/datum/modular_squad_spawn_result/result = new
		result.landmark = landmark
		result.spawn_turf = center_turf
		result.target_pod = pod
		result.source_tag = source_tag
		result.tier_tag = tier_tag
		result.no_pod_expected = !pod
		results += result

	return results

/datum/modular_squad_spawn_resolver/proc/pick_result_for_step(source_tag, tier_index, list/own_squad_keys, list/other_squad_keys, require_free_pod = TRUE)
	var/tier_tag = isnull(tier_index) ? "job" : "tier_[tier_index]"
	var/list/landmarks = collect_landmarks_for_step(source_tag, tier_index, own_squad_keys, other_squad_keys)
	if(!length(landmarks))
		return null

	var/list/results = build_results_from_landmarks(landmarks, source_tag, tier_tag, require_free_pod)
	if(!length(results))
		return null

	var/datum/modular_squad_spawn_result/picked_result = pick(results)
	squads_debug_log("[owner] selected [source_tag]/[tier_tag], landmark=[picked_result.landmark], turf=[picked_result.spawn_turf], pod=[picked_result.target_pod].")
	return picked_result

/datum/modular_squad_spawn_resolver/proc/resolve_with_free_pod(list/own_squad_keys, list/other_squad_keys)
	for(var/tier_index in 1 to 4)
		var/datum/modular_squad_spawn_result/start_result = pick_result_for_step("start", tier_index, own_squad_keys, other_squad_keys, require_free_pod = TRUE)
		if(start_result)
			return start_result

	if(!late_join_mode)
		return null

	for(var/tier_index in 1 to 4)
		var/datum/modular_squad_spawn_result/latejoin_result = pick_result_for_step("latejoin", tier_index, own_squad_keys, other_squad_keys, require_free_pod = TRUE)
		if(latejoin_result)
			return latejoin_result

	return pick_result_for_step("latejoin_job", null, own_squad_keys, other_squad_keys, require_free_pod = TRUE)

/datum/modular_squad_spawn_resolver/proc/resolve_without_pod(list/own_squad_keys, list/other_squad_keys)
	var/list/fallback_steps = list(
		list("source" = "start", "tier" = 1),
		list("source" = "start", "tier" = 3)
	)

	if(late_join_mode)
		fallback_steps += list(
			list("source" = "latejoin", "tier" = 1),
			list("source" = "latejoin", "tier" = 3),
			list("source" = "latejoin_job", "tier" = null)
		)

	for(var/list/fallback_step as anything in fallback_steps)
		var/source_tag = fallback_step["source"]
		var/tier_index = fallback_step["tier"]
		var/datum/modular_squad_spawn_result/fallback_result = pick_result_for_step(source_tag, tier_index, own_squad_keys, other_squad_keys, require_free_pod = FALSE)
		if(!fallback_result)
			continue

		fallback_result.target_pod = null
		fallback_result.no_pod_expected = TRUE
		fallback_result.source_tag = "[source_tag]_no_pod"
		return fallback_result

	return null

/datum/modular_squad_spawn_resolver/proc/build_spawn_candidate(datum/modular_squad_spawn_result/resolve_result)
	if(!istype(resolve_result) || !isturf(resolve_result.spawn_turf))
		return null

	return list(
		"spawn_turf" = resolve_result.spawn_turf,
		"preferred_pod" = resolve_result.target_pod,
		"source_tag" = resolve_result.source_tag,
		"tier_tag" = resolve_result.tier_tag,
		"no_pod_expected" = !!resolve_result.no_pod_expected
	)

/datum/modular_squad_spawn_resolver/proc/resolve()
	if(!owner || !istype(job_datum))
		return null

	if(!is_target_job_squad_role())
		squads_debug_log("[owner] job [job_datum.title] is not a squad role, modular resolver skipped.")
		return null

	var/list/own_squad_keys = get_own_squad_keys()
	var/list/other_squad_keys = get_other_squad_keys(own_squad_keys)

	if(!length(own_squad_keys) && !length(other_squad_keys))
		squads_debug_log("[owner] no squad keys available for modular spawn resolver.")
		return null

	var/datum/modular_squad_spawn_result/result_with_pod = resolve_with_free_pod(own_squad_keys, other_squad_keys)
	if(result_with_pod)
		return build_spawn_candidate(result_with_pod)

	squads_debug_log("[owner] no free cryopod found by tiered resolver, switching to spawn-only fallback.")
	var/datum/modular_squad_spawn_result/result_without_pod = resolve_without_pod(own_squad_keys, other_squad_keys)
	return build_spawn_candidate(result_without_pod)
