/datum/authority/branch/role/proc/get_ship_spawn_preset_override(job_title, current_preset, platoon_type)
	if(!job_title || !current_preset || !platoon_type)
		return null

	job_title = get_job_preference_bucket_key(job_title) || job_title

	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/list/spawn_preset_overrides = profile ? profile.get_spawn_preset_overrides() : null
	if(!islist(spawn_preset_overrides))
		return null

	var/list/job_overrides = spawn_preset_overrides[job_title]
	if(!islist(job_overrides))
		return null

	return job_overrides[current_preset]

/datum/authority/branch/role/proc/get_active_ship_spawn_preset_override(job_title, current_preset, platoon_type = get_active_ship_platoon_type())
	return get_ship_spawn_preset_override(job_title, current_preset, platoon_type)

/datum/authority/branch/role/proc/get_active_ship_distress_roles(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	var/platoon_type = get_active_ship_platoon_type(mode_name, mode_datum)
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/list/distress_roles = profile ? profile.get_distress_roles() : null
	if(islist(distress_roles))
		return distress_roles

	return GLOB.ROLES_DISTRESS_SIGNAL

/datum/authority/branch/role/proc/get_active_ship_lowpop_roles(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	var/platoon_type = get_active_ship_platoon_type(mode_name, mode_datum)
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/list/lowpop_roles = profile ? profile.get_lowpop_roles() : null
	if(islist(lowpop_roles))
		return lowpop_roles

	return GLOB.platoon_to_role_list[platoon_type]

/datum/authority/branch/role/proc/get_active_ship_role_mappings(lowpop = null, mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	if(isnull(lowpop))
		lowpop = is_lowpop_ship_mode(mode_name, mode_datum)

	var/platoon_type = get_active_ship_platoon_type(mode_name, mode_datum)
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/list/role_mappings = profile ? profile.get_role_mappings() : null
	if(islist(role_mappings))
		return role_mappings

	if(lowpop)
		return GLOB.platoon_to_jobs[platoon_type]

	return null

/datum/authority/branch/role/proc/get_active_ship_primary_family_types(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	var/platoon_type = get_active_ship_platoon_type(mode_name, mode_datum)
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/list/family_types = profile ? profile.get_family_types() : null
	if(islist(family_types) && length(family_types))
		return family_types

	return list(platoon_type)

/datum/authority/branch/role/proc/get_main_ship_conflicting_family_types()
	var/list/conflicting_types = list()
	for(var/platoon_type in list(
		/datum/squad/marine/alpha,
		/datum/squad/marine/halo/unsc/alpha,
		/datum/squad/marine/halo/odst/alpha,
	))
		var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
		var/list/family_types = profile ? profile.get_family_types() : null
		if(!islist(family_types) || !length(family_types))
			family_types = list(platoon_type)
		for(var/family_type in family_types)
			add_unique_ship_platoon_value(conflicting_types, family_type)

	return conflicting_types

/datum/authority/branch/role/proc/get_active_ship_lowpop_keep_types(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	var/platoon_type = get_active_ship_platoon_type(mode_name, mode_datum)
	var/list/keep_types = list(platoon_type)
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/list/family_secondary_types = profile ? profile.get_family_secondary_types() : null
	if(islist(family_secondary_types))
		for(var/family_type in family_secondary_types)
			add_unique_ship_platoon_value(keep_types, family_type)
	else if(platoon_type == /datum/squad/marine/alpha)
		keep_types += list(/datum/squad/marine/bravo, /datum/squad/marine/charlie, /datum/squad/marine/delta)

	for(var/extra_type in list(/datum/squad/marine/sof/forecon, /datum/squad/marine/upp/secondary, /datum/squad/marine/pmc/secondary))
		add_unique_ship_platoon_value(keep_types, extra_type)

	return keep_types

/datum/authority/branch/role/proc/get_role_bucket_title(job_or_title, active_only = FALSE)
	var/job_title = resolve_job_title(job_or_title)
	if(!job_title)
		return null

	if(active_only)
		return get_default_role_title(job_title)

	return get_job_preference_bucket_key(job_title)

/datum/authority/branch/role/proc/is_marine_equivalent_role(job_or_title, active_only = FALSE)
	var/bucket_title = get_role_bucket_title(job_or_title, active_only)
	return !!(bucket_title && GLOB.ROLES_MARINES.Find(bucket_title))

/datum/authority/branch/role/proc/get_marine_equivalent_role_titles(active_only = FALSE)
	var/list/role_titles = active_only ? list() : GLOB.ROLES_MARINES.Copy()
	var/list/source_titles = active_only ? roles_for_mode : roles_by_name

	if(!islist(source_titles) || !length(source_titles))
		return role_titles

	for(var/role_title in source_titles)
		if(!is_marine_equivalent_role(role_title, active_only))
			continue
		add_unique_ship_platoon_value(role_titles, role_title)

	return role_titles

/datum/authority/branch/role/proc/is_shipside_role(job_or_title, active_only = FALSE)
	var/job_title = resolve_job_title(job_or_title)
	if(!job_title)
		return FALSE

	var/bucket_title = get_role_bucket_title(job_title, active_only)
	if(bucket_title && GLOB.ROLES_USCM.Find(bucket_title))
		return TRUE

	return is_marine_equivalent_role(bucket_title || job_title, active_only)

/datum/authority/branch/role/proc/get_shipside_role_titles(active_only = FALSE)
	var/list/role_titles = active_only ? list() : GLOB.ROLES_USCM.Copy()
	var/list/source_titles = active_only ? roles_for_mode : roles_by_name

	if(!islist(source_titles) || !length(source_titles))
		return role_titles

	for(var/role_title in source_titles)
		if(!is_shipside_role(role_title, active_only))
			continue
		add_unique_ship_platoon_value(role_titles, role_title)

	return role_titles

/datum/authority/branch/role/proc/get_non_marine_shipside_role_titles(active_only = FALSE)
	var/list/role_titles = get_shipside_role_titles(active_only)
	if(!islist(role_titles))
		return active_only ? list() : (GLOB.ROLES_USCM - GLOB.ROLES_MARINES)

	var/list/non_marine_titles = role_titles.Copy()
	var/list/marine_titles = get_marine_equivalent_role_titles(active_only)
	if(islist(marine_titles) && length(marine_titles))
		non_marine_titles -= marine_titles

	return non_marine_titles

/datum/authority/branch/role/proc/is_halo_shipboard_command_role(job_or_title)
	var/job_title = resolve_job_title(job_or_title)
	if(!job_title)
		return FALSE

	return !!list(
		JOB_UNSC_CREW_ENGI_CHIEF,
		JOB_UNSC_CREW_FLIGHT_CHIEF,
		JOB_UNSC_CREW_MED_CHIEF,
		JOB_UNSC_CREW_OPS_CHIEF,
		JOB_UNSC_CREW_COM,
		JOB_UNSC_CREW_COM_XO,
		JOB_UNSC_CREW_COM_CPT
	).Find(job_title)

/datum/authority/branch/role/proc/get_halo_shipboard_headset_type(job_or_title, platoon_type)
	var/job_title = resolve_job_title(job_or_title)
	if(!job_title)
		return null

	var/target_family = get_ship_surface_family(platoon_type)
	var/unsc_family = get_ship_surface_family(/datum/squad/marine/halo/unsc/alpha)
	var/odst_family = get_ship_surface_family(/datum/squad/marine/halo/odst/alpha)
	var/command_role = is_halo_shipboard_command_role(job_title)
	if(target_family == odst_family)
		return command_role ? /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/command/odst : /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/crew/odst
	if(target_family == unsc_family)
		return command_role ? /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/command : /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/crew

	return command_role ? /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/command : /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/crew

/datum/authority/branch/role/proc/get_active_halo_shipboard_headset_type(job_or_title, platoon_type = get_active_ship_platoon_type())
	return get_halo_shipboard_headset_type(job_or_title, platoon_type)

/datum/authority/branch/role/proc/filter_role_authority_squads_to_types(list/keep_types, conflict_only = FALSE)
	if(!islist(keep_types) || !length(keep_types))
		return FALSE

	var/list/conflict_types = conflict_only ? get_main_ship_conflicting_family_types() : null
	for(var/datum/squad/squad as anything in squads.Copy())
		if(conflict_only && !(squad.type in conflict_types))
			continue
		if(squad.type in keep_types)
			continue
		squads -= squad
		squads_by_type -= squad.type
	return TRUE

/datum/authority/branch/role/proc/get_modular_job_pref_to_gear_preset(job_title)
	var/canonical_role = get_job_preference_bucket_key(job_title)
	if(!canonical_role)
		return null

	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(get_active_ship_platoon_type())
	if(!profile)
		return null

	var/list/preview_presets = profile.get_preview_presets()
	if(!islist(preview_presets))
		return null

	return preview_presets[canonical_role]

/datum/authority/branch/role/proc/get_halo_job_preference_preview_presets(platoon_type)
	var/datum/modular_ship_platoon_profile/halo/profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.get_preview_presets()

/datum/authority/branch/role/proc/get_halo_job_family_types(job_title)
	var/platoon_type = get_halo_platoon_type_for_job(job_title)
	if(!platoon_type)
		return null

	var/datum/modular_ship_platoon_profile/halo/profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return list(platoon_type)

	return profile.get_family_types()

/datum/authority/branch/role/proc/get_halo_ship_spawn_preset_overrides(platoon_type)
	var/datum/modular_ship_platoon_profile/halo/profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.get_spawn_preset_overrides()

/datum/authority/branch/role/proc/get_halo_ship_cryo_reinforcement_titles(platoon_type)
	var/datum/modular_ship_platoon_profile/halo/profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.get_cryo_reinforcement_titles()

/datum/authority/branch/role/proc/get_halo_ship_cryo_reinforcement_presets(platoon_type)
	var/datum/modular_ship_platoon_profile/halo/profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.get_cryo_reinforcement_presets()
