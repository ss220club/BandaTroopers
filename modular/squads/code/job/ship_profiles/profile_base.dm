/datum/modular_ship_platoon_profile
	var/platoon_type
	var/list/family_types
	var/list/family_secondary_types
	var/list/distress_roles
	var/list/lowpop_roles
	var/list/lowpop_personal_weapon_options
	var/list/lowpop_personal_weapon_spawn_types
	var/list/lowpop_personal_weapon_legacy_aliases
	var/lowpop_personal_weapon_default
	var/lowpop_personal_weapon_label
	var/lowpop_personal_weapon_prompt
	var/lowpop_personal_weapon_title
	var/lowpop_personal_weapon_notice_text
	var/list/lowpop_personal_weapon_roles
	var/lowpop_personal_weapon_required_faction
	var/lowpop_personal_weapon_case_type
	var/list/role_mappings
	var/list/spawn_preset_overrides
	var/list/cryo_reinforcement_titles
	var/list/cryo_reinforcement_presets
	var/list/preview_presets
	var/platoon_label
	var/manifest_picture
	var/intro_picture

/datum/modular_ship_platoon_profile/New(new_platoon_type)
	. = ..()
	if(new_platoon_type)
		platoon_type = new_platoon_type
	initialize_profile()

/datum/modular_ship_platoon_profile/proc/initialize_profile()
	return

/datum/modular_ship_platoon_profile/proc/copy_profile_list(list/source_list)
	if(!islist(source_list))
		return null

	return source_list.Copy()

/datum/modular_ship_platoon_profile/proc/get_family_types()
	if(islist(family_types) && length(family_types))
		return family_types.Copy()
	if(platoon_type)
		return list(platoon_type)

	return list()

/datum/modular_ship_platoon_profile/proc/get_family_secondary_types()
	if(islist(family_secondary_types))
		return family_secondary_types.Copy()

	return list()

/datum/modular_ship_platoon_profile/proc/get_distress_roles()
	if(islist(distress_roles))
		return distress_roles.Copy()
	if(islist(GLOB.ROLES_DISTRESS_SIGNAL))
		return GLOB.ROLES_DISTRESS_SIGNAL.Copy()

	return null

/datum/modular_ship_platoon_profile/proc/get_lowpop_roles()
	if(islist(lowpop_roles))
		return lowpop_roles.Copy()

	var/list/default_lowpop_roles = GLOB.platoon_to_role_list[platoon_type]
	if(islist(default_lowpop_roles))
		return default_lowpop_roles.Copy()

	return null

/datum/modular_ship_platoon_profile/proc/get_default_personal_weapon_options()
	return list(
		"Shotgun",
		"Compact shotgun",
		"Double-barrel shotgun",
		"Grenade launcher",
		"Compact grenade launcher",
		"Grenade pack",
	)

/datum/modular_ship_platoon_profile/proc/get_default_personal_weapon_legacy_aliases()
	return list(
		"Ithaca 37 shotgun" = "Shotgun",
		"Ithaca 37 shotgun-stakeout" = "Compact shotgun",
		"Ithaca 37 shotgun-traditional" = "Shotgun",
		"Sawn-off double barrel shotgun" = "Double-barrel shotgun",
		"M79 grenade launcher" = "Grenade launcher",
		"Cut down M79 grenade launcher" = "Compact grenade launcher",
		"4 M15 grenades" = "Grenade pack",
		"M90 CAWS shotgun" = "Shotgun",
		"MA5 M301 40mm grenade launcher" = "Grenade launcher",
	)

/datum/modular_ship_platoon_profile/proc/get_lowpop_personal_weapon_profile()
	if(!islist(lowpop_personal_weapon_options) && !islist(lowpop_personal_weapon_spawn_types) && !istext(lowpop_personal_weapon_default) && !istext(lowpop_personal_weapon_label) && !ispath(lowpop_personal_weapon_case_type))
		return null

	return list(
		"options" = copy_profile_list(lowpop_personal_weapon_options),
		"spawn_types" = copy_profile_list(lowpop_personal_weapon_spawn_types),
		"aliases" = copy_profile_list(lowpop_personal_weapon_legacy_aliases),
		"default" = lowpop_personal_weapon_default,
		"label" = lowpop_personal_weapon_label,
		"prompt" = lowpop_personal_weapon_prompt,
		"title" = lowpop_personal_weapon_title,
		"notice_text" = lowpop_personal_weapon_notice_text,
		"roles" = copy_profile_list(lowpop_personal_weapon_roles),
		"required_faction" = lowpop_personal_weapon_required_faction,
		"case_type" = lowpop_personal_weapon_case_type,
	)

/datum/modular_ship_platoon_profile/proc/get_role_mappings()
	if(islist(role_mappings))
		return role_mappings.Copy()

	return null

/datum/modular_ship_platoon_profile/proc/get_spawn_preset_overrides()
	return copy_profile_list(spawn_preset_overrides)

/datum/modular_ship_platoon_profile/proc/get_cryo_reinforcement_titles()
	return copy_profile_list(cryo_reinforcement_titles)

/datum/modular_ship_platoon_profile/proc/get_cryo_reinforcement_presets()
	return copy_profile_list(cryo_reinforcement_presets)

/datum/modular_ship_platoon_profile/proc/get_preview_presets()
	return copy_profile_list(preview_presets)

/datum/modular_ship_platoon_profile/proc/build_profile()
	if(!platoon_type)
		return null

	return list(
		"platoon_type" = platoon_type,
		"family_types" = get_family_types(),
		"family_secondary_types" = get_family_secondary_types(),
		"distress_roles" = get_distress_roles(),
		"lowpop_roles" = get_lowpop_roles(),
		"role_mappings" = get_role_mappings(),
		"spawn_preset_overrides" = get_spawn_preset_overrides(),
		"cryo_reinforcement_titles" = get_cryo_reinforcement_titles(),
		"cryo_reinforcement_presets" = get_cryo_reinforcement_presets(),
		"platoon_label" = platoon_label,
		"manifest_picture" = manifest_picture,
		"intro_picture" = intro_picture,
	)
