/datum/authority/branch/role/proc/get_ship_platoon_label(platoon_type)
	platoon_type = normalize_ship_platoon_type(platoon_type)
	if(!platoon_type)
		return null

	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	var/platoon_label = profile?.platoon_label
	if(istext(platoon_label) && length(platoon_label))
		return platoon_label

	if(ispath(platoon_type, /datum/squad/marine))
		var/datum/squad/marine/platoon_datum = platoon_type
		var/static_name = initial(platoon_datum.name)
		if(static_name)
			return static_name

	return "[platoon_type]"

/datum/authority/branch/role/proc/get_active_ship_platoon_type(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	var/datum/map_config/map_cfg = SSmapping?.configs?[SHIP_MAP]
	if(map_cfg?.platoon)
		var/map_platoon_type = text2path(map_cfg.platoon)
		if(map_platoon_type)
			return map_platoon_type

	var/platoon_type = MAIN_SHIP_PLATOON
	if(platoon_type)
		return platoon_type

	return text2path(MAIN_SHIP_DEFAULT_PLATOON)

/datum/authority/branch/role/proc/is_lowpop_ship_mode(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	if(istype(mode_datum, /datum/game_mode/colonialmarines/ai))
		return TRUE

	return !!(mode_name && findtext(mode_name, "Distress Signal: Lowpop") == 1)

/datum/authority/branch/role/proc/get_active_ship_profile(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	return get_ship_platoon_profile(get_active_ship_platoon_type(mode_name, mode_datum))

/datum/authority/branch/role/proc/get_main_ship_faction(mode_name = GLOB.master_mode, datum/game_mode/mode_datum = SSticker.mode)
	var/platoon_type = get_active_ship_platoon_type(mode_name, mode_datum)
	if(!ispath(platoon_type, /datum/squad/marine))
		return null

	var/datum/squad/marine/platoon_datum = platoon_type
	return initial(platoon_datum.faction)

/datum/authority/branch/role/proc/sync_pending_same_ship_platoon_for_round_start()
	var/datum/map_config/current_ship_config = SSmapping?.configs?[SHIP_MAP]
	var/datum/map_config/pending_ship_config = SSmapping?.next_map_configs?[SHIP_MAP]
	if(!current_ship_config || !pending_ship_config)
		return FALSE

	if(current_ship_config.map_name != pending_ship_config.map_name || current_ship_config.map_path != pending_ship_config.map_path)
		return FALSE
	if(!pending_ship_config.platoon || current_ship_config.platoon == pending_ship_config.platoon)
		return FALSE

	current_ship_config.platoon = pending_ship_config.platoon
	current_ship_config.allowed_platoons = pending_ship_config.allowed_platoons ? pending_ship_config.allowed_platoons.Copy() : list()
	return TRUE

/datum/authority/branch/role/proc/refresh_main_ship_gamemode_roles()
	GLOB.gamemode_roles["Distress Signal"] = get_active_ship_distress_roles("Distress Signal", null)
	GLOB.gamemode_roles["Distress Signal: Lowpop"] = get_active_ship_lowpop_roles("Distress Signal: Lowpop", null)
	return TRUE

/datum/authority/branch/role/proc/handle_main_ship_mode_changed(apply_surfaces = TRUE)
	refresh_main_ship_gamemode_roles()
	if(apply_surfaces)
		apply_main_ship_surface_profile()
	return TRUE

/datum/authority/branch/role/proc/get_gamemode_role_titles(mode_name = GLOB.master_mode)
	var/list/role_titles = GLOB.gamemode_roles[mode_name]
	if(role_titles)
		return role_titles

	switch(mode_name)
		if("Distress Signal")
			return get_active_ship_distress_roles(mode_name, null)
		if("Distress Signal: Lowpop")
			return get_active_ship_lowpop_roles(mode_name, null)
	if(is_lowpop_ship_mode(mode_name, null))
		return get_active_ship_lowpop_roles(mode_name, null)
	return null

/datum/authority/branch/role/proc/get_main_ship_display_profile()
	var/platoon_type = get_active_ship_platoon_type()
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	if(!profile.platoon_label && !profile.manifest_picture && !profile.intro_picture)
		return null

	return list(
		"label" = profile.platoon_label,
		"manifest_picture" = profile.manifest_picture,
		"intro_picture" = profile.intro_picture,
	)

/datum/authority/branch/role/proc/get_main_ship_distress_roles()
	return get_active_ship_distress_roles()

/datum/authority/branch/role/proc/get_main_ship_lowpop_roles()
	return get_active_ship_lowpop_roles()

/datum/authority/branch/role/proc/get_main_ship_role_mappings(lowpop = FALSE)
	return get_active_ship_role_mappings(lowpop)

/datum/authority/branch/role/proc/get_main_ship_primary_family_types()
	return get_active_ship_primary_family_types()

/datum/authority/branch/role/proc/get_main_ship_lowpop_keep_types()
	return get_active_ship_lowpop_keep_types()

/datum/authority/branch/role/proc/get_main_ship_personal_weapon_profile()
	var/platoon_type = get_active_ship_platoon_type()
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	return profile?.get_lowpop_personal_weapon_profile()

/datum/authority/branch/role/proc/get_main_ship_lowpop_personal_weapon_profile()
	return get_main_ship_personal_weapon_profile()
