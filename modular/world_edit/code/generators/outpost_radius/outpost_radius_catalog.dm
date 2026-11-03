/datum/world_edit_generator/outpost_radius/proc/build_type_options(list/type_list)
	var/list/options = list()
	for(var/datum/human_ai_defense/type_path as anything in type_list)
		options += list(list(
			"label" = type_path::name || "[type_path]",
			"value" = "[type_path]",
			"description" = type_path::desc || "",
		))
	return options

/datum/world_edit_generator/outpost_radius/proc/build_type_options_with_none(list/type_list)
	var/list/options = list(list(
		"label" = "None",
		"value" = "none",
		"description" = "",
	))
	options += build_type_options(type_list)
	return options

/datum/world_edit_generator/outpost_radius/proc/build_id_options(list/ids, list/labels = null)
	var/list/options = list()
	for(var/id as anything in ids)
		options += list(list(
			"label" = islist(labels) ? (labels[id] || "[id]") : "[id]",
			"value" = "[id]",
		))
	return options

/datum/world_edit_generator/outpost_radius/proc/build_faction_options()
	var/list/labels = get_faction_option_labels()
	var/list/options = list()
	for(var/faction as anything in valid_factions)
		options += list(list(
			"label" = labels[faction] || "[faction]",
			"value" = "[faction]",
		))
	return options

/datum/world_edit_generator/outpost_radius/proc/get_faction_option_labels()
	var/list/labels = list(
		FACTION_MARINE = "USCM",
		FACTION_UA_REBEL = "UA Rebel",
		FACTION_UPP = "UPP",
		FACTION_CANC = "CANC",
		FACTION_WY = "W-Y",
		FACTION_FREELANCER = "Freelancer",
		FACTION_TWE = "TWE",
		FACTION_TWE_REBEL = "TWE Rebel",
		FACTION_MERCENARY = "Mercenary",
	)
	if(hascall(src, "modular_append_outpost_radius_faction_option_labels"))
		call(src, "modular_append_outpost_radius_faction_option_labels")(labels)
	return labels

/datum/world_edit_generator/outpost_radius/proc/build_sentry_layer_profile_options()
	return build_id_options(list("none", "guard", "rear", "corners", "guard_corners"), list(
		"none" = "None",
		"guard" = "Interior guard",
		"rear" = "Rear support",
		"corners" = "Corners",
		"guard_corners" = "Guard + corners",
	))

/datum/world_edit_generator/outpost_radius/proc/build_extra_defense_layer_profile_options()
	return build_id_options(list("none", "rear", "corners"), list(
		"none" = "None",
		"rear" = "Rear support",
		"corners" = "Corners",
	))

/datum/world_edit_generator/outpost_radius/proc/build_wire_layer_profile_options()
	return build_id_options(list("none", "openings", "perimeter"), list(
		"none" = "None",
		"openings" = "Outside openings",
		"perimeter" = "Outside perimeter",
	))

/datum/world_edit_generator/outpost_radius/proc/build_minefield_profile_options()
	return build_id_options(list("none", "light", "medium", "dense"), list(
		"none" = "None",
		"light" = "Light field",
		"medium" = "Medium field",
		"dense" = "Dense field",
	))

/datum/world_edit_generator/outpost_radius/proc/resolve_id_option(value, list/allowed_ids, default_value = "none")
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return default_value
	var/id = lowertext("[value]")
	if(id in allowed_ids)
		return id
	return null

/datum/world_edit_generator/outpost_radius/proc/resolve_outpost_faction(value, default_value = FACTION_MARINE)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return default_value
	var/faction = "[value]"
	if(faction in valid_factions)
		return faction
	return null

/datum/world_edit_generator/outpost_radius/proc/resolve_optional_whitelisted_type(value, list/type_list, expected_root, default_value = "none")
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		value = default_value
	if("[value]" == "none")
		return "none"
	return resolve_whitelisted_type(value, type_list, expected_root, ispath(default_value, expected_root) ? default_value : null)

/datum/world_edit_generator/outpost_radius/proc/build_outpost_door_type_options()
	var/list/options = list(
		list(
			"label" = "По материалу",
			"value" = "follow_material",
			"description" = "Подобрать складную дверь автоматически по выбранному материалу секции.",
		),
		list(
			"label" = "Без дверей",
			"value" = "none",
			"description" = "Оставлять проходы этой секции пустыми, даже если двери включены.",
		),
	)
	options += build_type_options(allowed_outpost_door_types)
	return options

/datum/world_edit_generator/outpost_radius/proc/get_default_outpost_defense_profile_id()
	return "none"

/datum/world_edit_generator/outpost_radius/proc/get_default_outpost_layout_id()
	return "crossroads"

/datum/world_edit_generator/outpost_radius/proc/get_outpost_effective_placement_dir(list/placement_context = null)
	var/dir_to_use = islist(placement_context) ? placement_context["direction"] : null
	if(!GLOB.world_edit_helpers.is_cardinal_dir(dir_to_use))
		dir_to_use = manager?.get_effective_placement_dir()
	if(!GLOB.world_edit_helpers.is_cardinal_dir(dir_to_use))
		dir_to_use = get_default_placement_direction()
	return dir_to_use

/datum/world_edit_generator/outpost_radius/proc/resolve_relative_outpost_dir(dir_value, placement_dir)
	if(GLOB.world_edit_helpers.is_cardinal_dir(dir_value))
		return dir_value

	switch(lowertext("[dir_value]"))
		if("forward")
			return placement_dir
		if("back")
			return get_cardinal_opposite_dir(placement_dir)
		if("left")
			return turn(placement_dir, 90)
		if("right")
			return turn(placement_dir, -90)

	return null

/datum/world_edit_generator/outpost_radius/proc/resolve_outpost_dir_list(raw_dir_list, placement_dir)
	var/list/resolved_dirs = list()
	var/list/seen_lookup = list()
	if(!islist(raw_dir_list) || !length(raw_dir_list))
		return resolved_dirs

	for(var/dir_value as anything in raw_dir_list)
		var/resolved_dir = resolve_relative_outpost_dir(dir_value, placement_dir)
		if(!GLOB.world_edit_helpers.is_cardinal_dir(resolved_dir) || seen_lookup["[resolved_dir]"])
			continue
		seen_lookup["[resolved_dir]"] = TRUE
		resolved_dirs += resolved_dir

	return resolved_dirs


/datum/world_edit_generator/outpost_radius/proc/resolve_outpost_defense_profile_id(value)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return get_default_outpost_defense_profile_id()

	var/profile_id = "[value]"
	if(profile_id in outpost_defense_profiles)
		return profile_id
	return null

/datum/world_edit_generator/outpost_radius/proc/get_outpost_defense_profile(profile_id)
	if(!(profile_id in outpost_defense_profiles))
		return null
	return outpost_defense_profiles[profile_id]

/datum/world_edit_generator/outpost_radius/proc/resolve_outpost_layout_id(value)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return get_default_outpost_layout_id()

	var/layout_id = "[value]"
	if(layout_id in outpost_layout_profiles)
		return layout_id
	return null

/datum/world_edit_generator/outpost_radius/proc/get_outpost_layout_profile(layout_id)
	if(!(layout_id in outpost_layout_profiles))
		return null
	return outpost_layout_profiles[layout_id]

/datum/world_edit_generator/outpost_radius/proc/build_defense_profile_options()
	var/list/options = list()
	for(var/profile_id in outpost_defense_profiles)
		var/list/profile = outpost_defense_profiles[profile_id]
		options += list(list(
			"label" = profile["label"] || profile_id,
			"value" = profile_id,
			"description" = profile["description"] || "",
		))
	return options

/datum/world_edit_generator/outpost_radius/proc/build_layout_options()
	var/list/options = list()
	for(var/layout_id in outpost_layout_profiles)
		var/list/profile = outpost_layout_profiles[layout_id]
		options += list(list(
			"label" = profile["label"] || layout_id,
			"value" = layout_id,
			"description" = profile["description"] || "",
		))
	return options

/datum/world_edit_generator/outpost_radius/proc/build_opening_width_options()
	return list(
		list(
			"label" = "По схеме",
			"value" = "layout",
			"description" = "Использовать ширину проходов, рекомендованную выбранной схемой.",
		),
		list(
			"label" = "0 тайлов",
			"value" = "zero",
			"description" = "Не создавать плановые проходы в периметре.",
		),
		list(
			"label" = "1 клетка",
			"value" = "narrow",
			"description" = "Каждый проход шириной в одну клетку.",
		),
		list(
			"label" = "2 клетки",
			"value" = "double",
			"description" = "Каждый проход шириной в две клетки.",
		),
		list(
			"label" = "3 клетки",
			"value" = "wide",
			"description" = "Каждый проход шириной в три клетки.",
		),
		list(
			"label" = "4 клетки",
			"value" = "quad",
			"description" = "Каждый проход шириной в четыре клетки.",
		),
		list(
			"label" = "5 клеток",
			"value" = "broad",
			"description" = "Каждый проход шириной в пять клеток.",
		),
	)

/datum/world_edit_generator/outpost_radius/proc/get_outpost_opening_width_option_id(value)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return "layout"

	switch(lowertext("[value]"))
		if("layout")
			return "layout"
		if("zero", "0")
			return "zero"
		if("narrow", "1")
			return "narrow"
		if("double", "2")
			return "double"
		if("wide", "3")
			return "wide"
		if("quad", "4")
			return "quad"
		if("broad", "5")
			return "broad"
	return null

/datum/world_edit_generator/outpost_radius/proc/build_barricade_pattern_options()
	return list(
		list(
			"label" = "Равномерно",
			"value" = "uniform",
			"description" = "Использовать основной материал по всему контуру.",
		),
		list(
			"label" = "Чередование",
			"value" = "alternating",
			"description" = "Чередовать основной и вспомогательный материалы по каждому слоту.",
		),
		list(
			"label" = "Парные секции",
			"value" = "paired",
			"description" = "Чередовать материалы более широкими парными секциями.",
		),
	)

/datum/world_edit_generator/outpost_radius/proc/get_layout_opening_dirs(list/layout_profile, placement_dir = NORTH)
	var/list/opening_dirs = islist(layout_profile) ? layout_profile["opening_dirs"] : null
	return resolve_outpost_dir_list(opening_dirs, placement_dir)

/datum/world_edit_generator/outpost_radius/proc/get_layout_opening_width(list/layout_profile)
	var/opening_width = null
	if(islist(layout_profile) && !isnull(layout_profile["opening_width"]))
		opening_width = text2num("[layout_profile["opening_width"]]")
	if(isnum(opening_width) && opening_width >= 0)
		return clamp(round(opening_width), 0, 5)

	var/opening_half_width = 0
	if(islist(layout_profile))
		opening_half_width = text2num("[layout_profile["opening_half_width"]]")
	if(!isnum(opening_half_width))
		return 1
	return clamp((round(opening_half_width) * 2) + 1, 1, 5)

/datum/world_edit_generator/outpost_radius/proc/get_layout_opening_slots_per_dir(list/layout_profile)
	var/slots_per_dir = islist(layout_profile) ? text2num("[layout_profile["opening_slots_per_dir"]]") : null
	if(isnum(slots_per_dir) && slots_per_dir >= 1)
		return clamp(round(slots_per_dir), 1, 2)
	return 1

/datum/world_edit_generator/outpost_radius/proc/get_layout_opening_slot_mode(list/layout_profile)
	var/slot_mode = lowertext("[islist(layout_profile) ? (layout_profile["opening_slot_mode"] || "centered") : "centered"]")
	switch(slot_mode)
		if("centered", "split_pair")
			return slot_mode
	return "centered"

/datum/world_edit_generator/outpost_radius/proc/get_layout_total_opening_tiles_per_dir(list/layout_profile)
	return get_layout_opening_slots_per_dir(layout_profile) * get_layout_opening_width(layout_profile)

/datum/world_edit_generator/outpost_radius/proc/get_layout_expected_opening_count(list/layout_profile, placement_dir = NORTH)
	var/list/opening_dirs = get_layout_opening_dirs(layout_profile, placement_dir)
	if(!length(opening_dirs))
		return 0
	return length(opening_dirs) * get_layout_total_opening_tiles_per_dir(layout_profile)

/datum/world_edit_generator/outpost_radius/proc/resolve_barricade_pattern(value)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return "uniform"

	switch(lowertext("[value]"))
		if("uniform", "alternating", "paired")
			return lowertext("[value]")
	return null

/datum/world_edit_generator/outpost_radius/proc/resolve_opening_width(value, list/layout_profile)
	var/default_width = get_layout_opening_width(layout_profile)
	var/option_id = get_outpost_opening_width_option_id(value)
	if(isnull(option_id))
		return null

	switch(option_id)
		if("layout")
			return default_width
		if("zero")
			return 0
		if("narrow")
			return 1
		if("double")
			return 2
		if("wide")
			return 3
		if("quad")
			return 4
		if("broad")
			return 5
	return null

/datum/world_edit_generator/outpost_radius/proc/resolve_whitelisted_type(value, list/type_list, expected_root, default_value = null)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		if(ispath(default_value, expected_root) && (default_value in type_list))
			return default_value
		return null

	var/path_value = ispath(value) ? value : null
	if(!path_value)
		for(var/allowed_path as anything in type_list)
			if("[allowed_path]" == "[value]")
				path_value = allowed_path
				break
	if(!ispath(path_value, expected_root))
		return null
	if(!(path_value in type_list))
		return null
	return path_value

/datum/world_edit_generator/outpost_radius/proc/resolve_outpost_door_selection(value)
	if(isnull(value) || !length("[value]") || "[value]" == "null")
		return "follow_material"

	var/path_value = ispath(value) ? value : null
	if(!path_value)
		for(var/allowed_path as anything in allowed_outpost_door_types)
			if("[allowed_path]" == "[value]")
				path_value = allowed_path
				break
	if(ispath(path_value, /datum/human_ai_defense/barricade) && (path_value in allowed_outpost_door_types))
		return path_value

	switch(lowertext("[value]"))
		if("follow_material")
			return "follow_material"
		if("none")
			return "none"
	return null

/datum/world_edit_generator/outpost_radius/proc/format_opening_dirs(list/opening_dirs)
	if(!islist(opening_dirs) || !length(opening_dirs))
		return "none"

	var/list/labels = list()
	for(var/dir_value as anything in opening_dirs)
		labels += GLOB.world_edit_helpers.dir_to_label(dir_value)
	return jointext(labels, ", ")
