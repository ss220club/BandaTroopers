/datum/squad_name_manager/proc/get_runtime_name_by_static(static_name)
	if(!(static_name in managed_static_names))
		return static_name
	return runtime_name_by_static[static_name] || static_name

/datum/squad_name_manager/proc/get_default_name_by_static(static_name)
	return default_name_by_static[static_name]

/datum/squad_name_manager/proc/get_static_name_by_squad(datum/squad/target)
	if(!target)
		return null
	return static_by_squad_type[target.type]

/datum/squad_name_manager/proc/get_static_name_by_runtime(runtime_name)
	if(!runtime_name)
		return null

	for(var/static_name in managed_static_names)
		if(cmptext(runtime_name, static_name))
			return static_name
		if(cmptext(runtime_name, runtime_name_by_static[static_name]))
			return static_name

	return null

/datum/squad_name_manager/proc/get_squad_by_static(static_name)
	if(!GLOB.RoleAuthority || !islist(GLOB.RoleAuthority.squads_by_type))
		return null
	var/managed_type = squad_type_by_static[static_name]
	if(!managed_type)
		return null
	return GLOB.RoleAuthority.squads_by_type[managed_type]

/datum/squad_name_manager/proc/is_managed_squad(datum/squad/target)
	return !!get_static_name_by_squad(target)

/datum/squad_name_manager/proc/get_preference_name_for_static(datum/preferences/player_prefs, static_name)
	if(!player_prefs)
		return null
	switch(static_name)
		if(SQUAD_MARINE_1)
			return player_prefs.squad_name_alpha_pref
		if(SQUAD_MARINE_2)
			return player_prefs.squad_name_bravo_pref
		if(SQUAD_MARINE_3)
			return player_prefs.squad_name_charlie_pref
		if(SQUAD_MARINE_4)
			return player_prefs.squad_name_delta_pref
	return null
