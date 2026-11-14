/datum/authority/branch/role/proc/add_unique_ship_platoon_value(list/target_list, value)
	if(!islist(target_list) || isnull(value))
		return
	if(!(value in target_list))
		target_list += value

/datum/authority/branch/role/proc/normalize_ship_platoon_type(platoon_type)
	if(ispath(platoon_type, /datum/squad))
		return platoon_type
	if(istext(platoon_type))
		return text2path(platoon_type)

	return null

/datum/authority/branch/role/proc/get_known_ship_platoon_types()
	var/list/known_types = list(
		/datum/squad/marine/alpha,
		/datum/squad/marine/upp,
		/datum/squad/marine/pmc,
		/datum/squad/marine/pmc/small,
		/datum/squad/marine/forecon,
		/datum/squad/marine/rmc,
		/datum/squad/marine/iasf,
		/datum/squad/marine/halo/unsc/alpha,
		/datum/squad/marine/halo/odst/alpha,
	)

	if(!SSmapping?.configs)
		return known_types

	for(var/config_key in SSmapping.configs)
		var/datum/map_config/MC = SSmapping.configs[config_key]
		if(!MC?.platoon)
			continue

		var/platoon_type = text2path(MC.platoon)
		if(platoon_type)
			add_unique_ship_platoon_value(known_types, platoon_type)

	return known_types

/datum/authority/branch/role/proc/get_default_ship_platoon_profile(platoon_type)
	var/datum/modular_ship_platoon_profile/profile = get_default_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.build_profile()

/datum/authority/branch/role/proc/get_ship_platoon_profile(platoon_type)
	var/datum/modular_ship_platoon_profile/profile = get_ship_platoon_profile_datum(platoon_type)
	if(!profile)
		return null

	return profile.build_profile()

/datum/authority/branch/role/proc/get_ship_platoon_profile_datum(platoon_type)
	platoon_type = normalize_ship_platoon_type(platoon_type)
	if(!platoon_type)
		return null
	if(platoon_type == /datum/squad/marine/iasf)
		return new /datum/modular_ship_platoon_profile/iasf()

	var/datum/modular_ship_platoon_profile/halo/halo_profile = get_halo_ship_platoon_profile_datum(platoon_type)
	if(halo_profile)
		return halo_profile

	return get_default_ship_platoon_profile_datum(platoon_type)
