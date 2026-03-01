/datum/squad_name_manager/proc/rename_squad(datum/squad/target_squad, raw_name, mob/renamer, rename_source, bypass_lock = FALSE)
	if(!is_managed_squad(target_squad))
		return "Selected squad is not managed by squad rename manager."

	var/static_name = get_static_name_by_squad(target_squad)
	if(!static_name)
		return "Failed to resolve static squad identifier."

	if(leader_lock_by_static[static_name] && !bypass_lock)
		return "This squad has already been renamed by the first Squad Leader this round."

	var/new_name = normalize_squad_name(raw_name)
	if(!new_name)
		return "Name must be 1-32 chars and may contain Latin/Cyrillic letters, numbers, spaces, apostrophe, hyphen and dot."

	var/old_name = target_squad.name
	var/conflict_error = validate_name_conflicts(new_name, old_name)
	if(conflict_error)
		return conflict_error

	update_global_mappings(target_squad, old_name, new_name)
	runtime_name_by_static[static_name] = new_name

	if(old_name != new_name)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SQUAD_NAME_CHANGE, target_squad, new_name, old_name)

	if(static_name == SQUAD_MARINE_1)
		GLOB.main_platoon_name = new_name
		if(old_name != new_name)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PLATOON_NAME_CHANGE, new_name, old_name)

	if(renamer)
		log_admin("[key_name(renamer)] has renamed squad [old_name] to [new_name]. Source: [rename_source].")

	return TRUE

/datum/squad_name_manager/proc/apply_roundstart_defaults()
	reset_runtime_names()
	reset_leader_locks()

	for(var/static_name in managed_static_names)
		var/datum/squad/target_squad = get_squad_by_static(static_name)
		if(!target_squad)
			continue

		var/default_name = get_default_name_by_static(static_name)
		if(!default_name)
			continue

		var/rename_result = rename_squad(target_squad, default_name, null, "roundstart_default", TRUE)
		if(rename_result != TRUE)
			log_debug("SS220 squad rename default failed for [static_name]: [rename_result]")

	var/current_alpha_name = get_runtime_name_by_static(SQUAD_MARINE_1)
	GLOB.main_platoon_name = current_alpha_name
	GLOB.main_platoon_initial_name = current_alpha_name
	return TRUE

/datum/squad_name_manager/proc/try_apply_leader_preference(mob/living/carbon/human/H)
	if(!H || GET_DEFAULT_ROLE(H.job) != JOB_SQUAD_LEADER || !H.assigned_squad)
		return FALSE

	var/datum/squad/assigned_squad = H.assigned_squad
	var/static_name = get_static_name_by_squad(assigned_squad)
	if(!static_name)
		squads_debug_log("leader preference static resolve failed: squad_name=[assigned_squad.name], squad_type=[assigned_squad.type], player=[H.ckey]")
		return FALSE

	if(leader_lock_by_static[static_name])
		return FALSE

	var/datum/preferences/player_prefs = H.client?.prefs
	var/preferred_name = get_preference_name_for_static(player_prefs, static_name)
	var/default_name = get_default_name_by_static(static_name)
	var/desired_name = preferred_name
	if(!desired_name)
		desired_name = default_name

	var/rename_result = rename_squad(assigned_squad, desired_name, H, "first_squad_leader", FALSE)
	if(rename_result == TRUE)
		leader_lock_by_static[static_name] = TRUE
		return TRUE

	if(desired_name != default_name)
		rename_result = rename_squad(assigned_squad, default_name, H, "first_squad_leader_fallback", FALSE)
		if(rename_result == TRUE)
			leader_lock_by_static[static_name] = TRUE
			return TRUE

	to_chat(H, SPAN_WARNING("Failed to apply your squad name preference: [rename_result]"))
	return FALSE
