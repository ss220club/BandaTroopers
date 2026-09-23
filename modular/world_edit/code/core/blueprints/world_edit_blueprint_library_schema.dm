/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_id()
	return copytext(md5("[world.realtime]-[world.time]-[rand(1, 1000000)]"), 1, WORLD_EDIT_BLUEPRINT_ID_LEN + 1)

/datum/world_edit_blueprint_service/proc/world_edit_compute_blueprint_bounds(list/entries)
	var/min_x = 0
	var/max_x = 0
	var/min_y = 0
	var/max_y = 0
	var/min_z = 0
	var/max_z = 0
	var/radius = 0
	var/is_first = TRUE

	for(var/list/entry as anything in entries)
		var/dx = text2num("[entry["dx"]]")
		var/dy = text2num("[entry["dy"]]")
		var/dz = text2num("[entry["dz"]]")
		var/atom_path = text2path("[entry["type"]]")
		var/dir_value = text2num("[entry["dir"]]")
		for(var/list/offset as anything in world_edit_get_blueprint_occupied_offsets(atom_path, dir_value))
			if(!islist(offset) || length(offset) < 2)
				continue
			var/occupied_dx = dx + (text2num("[offset[1]]") || 0)
			var/occupied_dy = dy + (text2num("[offset[2]]") || 0)
			if(is_first)
				min_x = max_x = occupied_dx
				min_y = max_y = occupied_dy
				min_z = max_z = dz
				is_first = FALSE
			else
				min_x = min(min_x, occupied_dx)
				max_x = max(max_x, occupied_dx)
				min_y = min(min_y, occupied_dy)
				max_y = max(max_y, occupied_dy)
				min_z = min(min_z, dz)
				max_z = max(max_z, dz)

			radius = max(radius, abs(occupied_dx), abs(occupied_dy))

	return list(
		"min_x" = min_x,
		"max_x" = max_x,
		"min_y" = min_y,
		"max_y" = max_y,
		"min_z" = min_z,
		"max_z" = max_z,
		"radius" = radius,
	)

/datum/world_edit_blueprint_service/proc/world_edit_blueprint_bounds_match(list/raw_bounds, list/computed_bounds)
	if(!islist(raw_bounds) || !islist(computed_bounds))
		return FALSE

	for(var/key in computed_bounds)
		if(text2num("[raw_bounds[key]]") != text2num("[computed_bounds[key]]"))
			return FALSE

	return TRUE

/datum/world_edit_blueprint_service/proc/world_edit_validate_blueprint_footprint_bounds(list/bounds)
	if(!islist(bounds))
		return "У шаблона отсутствуют bounds."

	var/footprint_width = (text2num("[bounds["max_x"]]") - text2num("[bounds["min_x"]]")) + 1
	var/footprint_height = (text2num("[bounds["max_y"]]") - text2num("[bounds["min_y"]]")) + 1
	if(footprint_width <= 0 || footprint_height <= 0)
		return "Шаблон содержит некорректные границы."
	if(footprint_width > WORLD_EDIT_BLUEPRINT_MAX_DIMENSION || footprint_height > WORLD_EDIT_BLUEPRINT_MAX_DIMENSION)
		return "Шаблон превышает лимит размера [WORLD_EDIT_BLUEPRINT_MAX_DIMENSION]x[WORLD_EDIT_BLUEPRINT_MAX_DIMENSION]."
	return null

/datum/world_edit_blueprint_service/proc/world_edit_validate_blueprint_entry_vars(obj_path, raw_vars)
	var/list/rule = world_edit_get_blueprint_type_rule(obj_path)
	if(!rule)
		return list("error" = "Шаблон содержит неразрешенный тип.")

	var/list/safe_vars = list()
	var/category = "[rule["category"]]"
	if(isnull(raw_vars))
		return list("vars" = safe_vars)
	if(!islist(raw_vars))
		return list("error" = "Поле vars шаблона должно быть списком.")
	if(!length(raw_vars))
		return list("vars" = safe_vars)

	if(!(category in list("sentry", "defense", "mine")))
		return list("error" = "Для '[obj_path]' vars не поддерживаются.")

	for(var/var_id in raw_vars)
		var/key_text = "[var_id]"
		switch(key_text)
			if("faction")
				var/faction = "[raw_vars[var_id]]"
				if(!(faction in GLOB.world_edit_blueprint_valid_factions))
					return list("error" = "В шаблоне указана недопустимая фракция обороны.")
				safe_vars[key_text] = faction
			if("turned_on")
				if(category == "mine")
					return list("error" = "Записи мин в шаблоне не поддерживают 'turned_on'.")
				safe_vars[key_text] = GLOB.world_edit_helpers.parse_bool(raw_vars[var_id]) ? TRUE : FALSE
			else
				return list("error" = "В шаблоне указан неразрешенный var '[key_text]'.")

	return list("vars" = safe_vars)

/datum/world_edit_blueprint_service/proc/world_edit_parse_strict_integer(raw_value)
	var/value_text = trim("[raw_value]")
	if(!length(value_text))
		return null

	var/start_index = 1
	var/first_char = copytext(value_text, 1, 2)
	if(first_char == "+" || first_char == "-")
		start_index = 2
	if(start_index > length(value_text))
		return null

	for(var/i = start_index, i <= length(value_text), i++)
		var/char = copytext(value_text, i, i + 1)
		if(!(char in list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")))
			return null

	return text2num(value_text)

/datum/world_edit_blueprint_service/proc/world_edit_validate_blueprint_entry(list/raw_entry)
	if(!islist(raw_entry))
		return list("error" = "Запись шаблона должна быть списком.")

	var/type_text = "[raw_entry["type"]]"
	var/atom_path = text2path(type_text)
	var/is_turf_entry = ispath(atom_path, /turf)
	var/list/rule = is_turf_entry ? world_edit_get_blueprint_turf_rule(atom_path) : world_edit_get_blueprint_type_rule(atom_path)
	if(!rule)
		return list("error" = "В шаблоне указан неразрешенный тип '[type_text]'.")

	var/dx = world_edit_parse_strict_integer(raw_entry["dx"])
	var/dy = world_edit_parse_strict_integer(raw_entry["dy"])
	var/dz = world_edit_parse_strict_integer(raw_entry["dz"])
	if(isnull(dx) || isnull(dy) || isnull(dz))
		return list("error" = "Координаты шаблона должны быть числовыми.")
	if(dz != 0)
		return list("error" = "Шаблоны Phase 3A должны оставаться на одном z-уровне.")
	if(abs(dx) > WORLD_EDIT_BLUEPRINT_MAX_RADIUS || abs(dy) > WORLD_EDIT_BLUEPRINT_MAX_RADIUS)
		return list("error" = "Шаблон превышает допустимый лимит радиуса.")

	var/dir_value = SOUTH
	if("dir" in raw_entry)
		dir_value = text2num("[raw_entry["dir"]]")
		if(!(dir_value in GLOB.cardinals))
			return list("error" = "В шаблоне указано некардинальное направление.")

	if(is_turf_entry)
		if(islist(raw_entry["vars"]) && length(raw_entry["vars"]))
			return list("error" = "Blueprint turf entries do not support vars.")
		return list("entry" = list(
			"kind" = "turf",
			"type" = "[atom_path]",
			"dx" = dx,
			"dy" = dy,
			"dz" = dz,
			"dir" = SOUTH,
			"vars" = list(),
		))

	var/list/vars_result = world_edit_validate_blueprint_entry_vars(atom_path, raw_entry["vars"])
	if(vars_result["error"])
		return vars_result

	return list("entry" = list(
		"kind" = "object",
		"type" = "[atom_path]",
		"dx" = dx,
		"dy" = dy,
		"dz" = dz,
		"dir" = dir_value,
		"vars" = vars_result["vars"],
	))

/datum/world_edit_blueprint_service/proc/world_edit_validate_outpost_recipe_footprint_offsets(raw_offsets)
	if(isnull(raw_offsets))
		return list("footprint_offsets" = list(list(0, 0)))
	if(!islist(raw_offsets) || !length(raw_offsets))
		return list("error" = "Blueprint outpost_recipe должен содержать хотя бы одно смещение в footprint_offsets.")

	var/list/sanitized_offsets = list()
	var/list/offset_lookup = list()
	for(var/raw_offset as anything in raw_offsets)
		if(!islist(raw_offset) || length(raw_offset) < 2)
			return list("error" = "Элементы Blueprint outpost_recipe.footprint_offsets должны быть списками вида (dx, dy).")
		var/dx = world_edit_parse_strict_integer(raw_offset[1])
		var/dy = world_edit_parse_strict_integer(raw_offset[2])
		if(isnull(dx) || isnull(dy))
			return list("error" = "Смещения в Blueprint outpost_recipe.footprint_offsets должны быть числовыми.")
		var/offset_key = "[dx],[dy]"
		if(offset_lookup[offset_key])
			continue
		offset_lookup[offset_key] = TRUE
		sanitized_offsets += list(list(dx, dy))

	if(!length(sanitized_offsets))
		sanitized_offsets += list(list(0, 0))
	return list("footprint_offsets" = sanitized_offsets)

/datum/world_edit_blueprint_service/proc/world_edit_validate_outpost_recipe(raw_recipe)
	if(isnull(raw_recipe))
		return list("outpost_recipe" = null)
	if(!islist(raw_recipe))
		return list("error" = "Blueprint outpost_recipe должен быть объектом.")

	var/defense_profile = trim(sanitize_text("[raw_recipe["defense_profile"]]", ""))
	var/layout_variant = trim(sanitize_text("[raw_recipe["layout_variant"]]", ""))
	if(length(trim(sanitize_text("[raw_recipe["family"]]", ""))))
		return list("error" = "Blueprint outpost_recipe.family больше не поддерживается. Используйте defense_profile.")
	if(length(trim(sanitize_text("[raw_recipe["barricade_path"]]", ""))))
		return list("error" = "Blueprint outpost_recipe.barricade_path больше не поддерживается. Используйте primary_material_path.")
	if(!isnull(raw_recipe["barricade_concentration_percent"]))
		return list("error" = "Blueprint outpost_recipe.barricade_concentration_percent больше не поддерживается. Используйте primary_material_share_percent.")
	if(!length(defense_profile))
		return list("error" = "Blueprint outpost_recipe должен включать defense_profile.")
	if(!length(layout_variant))
		return list("error" = "Blueprint outpost_recipe должен включать layout_variant.")

	var/placement_dir = text2num("[raw_recipe["placement_dir"]]")
	if(!(placement_dir in GLOB.cardinals))
		return list("error" = "Blueprint outpost_recipe.placement_dir должен быть кардинальным направлением.")

	var/radius = world_edit_parse_strict_integer(raw_recipe["radius"])
	if(isnull(radius) || radius < 1 || radius > 40)
		return list("error" = "Blueprint outpost_recipe.radius must be in range 1..40.")

	var/datum/world_edit_generator/outpost_radius/outpost_generator = new
	var/resolved_defense_profile = outpost_generator.resolve_outpost_defense_profile_id(defense_profile)
	if(!length("[resolved_defense_profile]"))
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.defense_profile не поддерживается.")

	var/resolved_layout_variant = outpost_generator.resolve_outpost_layout_id(layout_variant)
	var/list/layout_profile = outpost_generator.get_outpost_layout_profile(resolved_layout_variant)
	if(!length("[resolved_layout_variant]") || !islist(layout_profile))
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.layout_variant не поддерживается.")

	var/opening_width = outpost_generator.resolve_opening_width(raw_recipe["opening_width"], layout_profile)
	if(isnull(opening_width) || opening_width < 0 || opening_width > (radius * 2) + 1)
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.opening_width недопустим для сохраненного радиуса.")

	var/list/default_materials = list(
		"primary_material_path" = /datum/human_ai_defense/barricade/metal,
		"secondary_material_path" = /datum/human_ai_defense/barricade/metal,
		"barricade_pattern" = "uniform",
		"primary_material_share_percent" = 100,
		"primary_door_path" = "follow_material",
		"secondary_door_path" = "follow_material",
	)
	var/barricade_pattern = outpost_generator.resolve_barricade_pattern(raw_recipe["barricade_pattern"])
	if(isnull(barricade_pattern))
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.barricade_pattern не поддерживается.")

	var/primary_material_share_percent = world_edit_parse_strict_integer(raw_recipe["primary_material_share_percent"])
	if(isnull(primary_material_share_percent))
		var/default_primary_material_share_percent = world_edit_parse_strict_integer(default_materials["primary_material_share_percent"])
		primary_material_share_percent = isnull(default_primary_material_share_percent) ? 100 : default_primary_material_share_percent
	if(primary_material_share_percent < 0 || primary_material_share_percent > 100)
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.primary_material_share_percent должен быть в диапазоне 0..100.")

	var/primary_material_path = outpost_generator.resolve_whitelisted_type(
		raw_recipe["primary_material_path"],
		outpost_generator.allowed_barricade_types,
		/datum/human_ai_defense/barricade,
		default_materials["primary_material_path"] || /datum/human_ai_defense/barricade/metal,
	)
	if(!ispath(primary_material_path, /datum/human_ai_defense/barricade))
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.primary_material_path должен указывать на путь определения баррикады.")

	var/secondary_material_path = outpost_generator.resolve_whitelisted_type(
		raw_recipe["secondary_material_path"],
		outpost_generator.allowed_barricade_types,
		/datum/human_ai_defense/barricade,
		default_materials["secondary_material_path"] || primary_material_path,
	)
	if(!ispath(secondary_material_path, /datum/human_ai_defense/barricade))
		secondary_material_path = default_materials["secondary_material_path"] || primary_material_path
	if(!ispath(secondary_material_path, /datum/human_ai_defense/barricade))
		secondary_material_path = primary_material_path

	var/place_barricade_doors = GLOB.world_edit_helpers.parse_bool(raw_recipe["place_barricade_doors"]) ? TRUE : FALSE
	var/primary_door_path = outpost_generator.resolve_outpost_door_selection(raw_recipe["primary_door_path"] || default_materials["primary_door_path"])
	if(isnull(primary_door_path))
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.primary_door_path не поддерживается.")

	var/secondary_door_path = outpost_generator.resolve_outpost_door_selection(raw_recipe["secondary_door_path"] || default_materials["secondary_door_path"])
	if(isnull(secondary_door_path))
		qdel(outpost_generator)
		return list("error" = "Blueprint outpost_recipe.secondary_door_path не поддерживается.")

	if(barricade_pattern == "uniform")
		secondary_material_path = primary_material_path
		secondary_door_path = primary_door_path
		primary_material_share_percent = 100

	var/list/footprint_result = world_edit_validate_outpost_recipe_footprint_offsets(raw_recipe["footprint_offsets"])
	if(footprint_result["error"])
		qdel(outpost_generator)
		return footprint_result

	var/list/config_params = list(
		"defense_profile" = resolved_defense_profile,
		"layout_variant" = resolved_layout_variant,
		"opening_width" = opening_width,
		"radius" = radius,
		"primary_material_path" = primary_material_path,
		"secondary_material_path" = secondary_material_path,
		"barricade_pattern" = barricade_pattern,
		"primary_material_share_percent" = primary_material_share_percent,
		"place_barricade_doors" = place_barricade_doors,
		"primary_door_path" = primary_door_path,
		"secondary_door_path" = secondary_door_path,
		"faction" = raw_recipe["faction"],
		"turned_on" = raw_recipe["turned_on"],
		"sentry_layer_profile" = raw_recipe["sentry_layer_profile"],
		"sentry_type" = raw_recipe["sentry_type"],
		"extra_defense_layer_profile" = raw_recipe["extra_defense_layer_profile"],
		"extra_defense_type" = raw_recipe["extra_defense_type"],
		"flag_type" = raw_recipe["flag_type"],
		"wire_layer_profile" = raw_recipe["wire_layer_profile"],
		"wire_offset" = raw_recipe["wire_offset"],
		"wire_rows" = raw_recipe["wire_rows"],
		"wire_row_step" = raw_recipe["wire_row_step"],
		"wire_spacing" = raw_recipe["wire_spacing"],
		"wire_concentration_percent" = raw_recipe["wire_concentration_percent"],
		"minefield_profile" = raw_recipe["minefield_profile"],
		"mine_type" = raw_recipe["mine_type"],
		"minefield_offset" = raw_recipe["minefield_offset"],
		"minefield_depth" = raw_recipe["minefield_depth"],
		"minefield_density_percent" = raw_recipe["minefield_density_percent"],
		"minefield_seed" = raw_recipe["minefield_seed"],
	)
	var/list/resolved_config = outpost_generator.resolve_outpost_configuration(config_params, list("direction" = placement_dir))
	if(resolved_config["error"])
		qdel(outpost_generator)
		return list("error" = "[resolved_config["error"]]")

	var/list/sanitized_recipe = list(
		"defense_profile" = resolved_defense_profile,
		"layout_variant" = resolved_layout_variant,
		"placement_dir" = placement_dir,
		"radius" = radius,
		"opening_width" = opening_width,
		"primary_material_path" = "[primary_material_path]",
		"secondary_material_path" = "[secondary_material_path]",
		"barricade_pattern" = barricade_pattern,
		"primary_material_share_percent" = primary_material_share_percent,
		"place_barricade_doors" = place_barricade_doors,
		"primary_door_path" = ispath(primary_door_path, /datum/human_ai_defense/barricade) ? "[primary_door_path]" : "[primary_door_path]",
		"secondary_door_path" = ispath(secondary_door_path, /datum/human_ai_defense/barricade) ? "[secondary_door_path]" : "[secondary_door_path]",
		"faction" = resolved_config["faction"],
		"turned_on" = resolved_config["turned_on"] ? TRUE : FALSE,
		"sentry_layer_profile" = resolved_config["sentry_layer_profile"],
		"sentry_type" = "[resolved_config["sentry_type"]]",
		"extra_defense_layer_profile" = resolved_config["extra_defense_layer_profile"],
		"extra_defense_type" = "[resolved_config["extra_defense_type"]]",
		"flag_type" = ispath(resolved_config["flag_type"], /datum/human_ai_defense/defense/flag) ? "[resolved_config["flag_type"]]" : "none",
		"wire_layer_profile" = resolved_config["wire_layer_profile"],
		"wire_offset" = resolved_config["wire_offset"],
		"wire_rows" = resolved_config["wire_rows"],
		"wire_row_step" = resolved_config["wire_row_step"],
		"wire_spacing" = resolved_config["wire_spacing"],
		"wire_concentration_percent" = resolved_config["wire_concentration_percent"],
		"minefield_profile" = resolved_config["minefield_profile"],
		"mine_type" = "[resolved_config["mine_type"]]",
		"minefield_offset" = resolved_config["minefield_offset"],
		"minefield_depth" = resolved_config["minefield_depth"],
		"minefield_density_percent" = resolved_config["minefield_density_percent"],
		"minefield_seed" = resolved_config["minefield_seed"],
		"footprint_offsets" = footprint_result["footprint_offsets"],
	)
	qdel(outpost_generator)
	return list("outpost_recipe" = sanitized_recipe)

/datum/world_edit_blueprint_service/proc/world_edit_validate_blueprint_definition(list/raw_definition)
	if(!islist(raw_definition))
		return list("error" = "Данные шаблона должны быть объектом.")

	var/blueprint_id = sanitize_filename("[raw_definition["id"]]")
	if(!length(blueprint_id))
		return list("error" = "У шаблона отсутствует id.")
	if(length(blueprint_id) > WORLD_EDIT_BLUEPRINT_ID_LEN)
		return list("error" = "id шаблона превышает лимит длины.")

	var/blueprint_name = trim(sanitize_text("[raw_definition["name"]]", ""))
	if(!length(blueprint_name))
		blueprint_name = blueprint_id
	blueprint_name = copytext(blueprint_name, 1, WORLD_EDIT_BLUEPRINT_NAME_MAX_LEN + 1)

	var/list/raw_entries = raw_definition["entries"]
	if(!islist(raw_entries) || !length(raw_entries))
		return list("error" = "Шаблон не содержит записей.")
	if(length(raw_entries) > WORLD_EDIT_BLUEPRINT_MAX_ENTRIES)
		return list("error" = "Шаблон превышает лимит записей.")

	var/list/sanitized_entries = list()
	var/list/relative_coord_lookup = list()
	for(var/list/raw_entry as anything in raw_entries)
		var/list/entry_result = world_edit_validate_blueprint_entry(raw_entry)
		if(entry_result["error"])
			return entry_result
		var/list/sanitized_entry = entry_result["entry"]
		var/atom_path = text2path("[sanitized_entry["type"]]")
		var/list/coord_keys = list()
		if(ispath(atom_path, /turf))
			coord_keys += "turf:[sanitized_entry["dx"]],[sanitized_entry["dy"]],[sanitized_entry["dz"]]"
		else
			coord_keys = world_edit_build_blueprint_relative_slot_keys(atom_path, sanitized_entry["dx"], sanitized_entry["dy"], sanitized_entry["dz"], sanitized_entry["dir"])
		if(!length(coord_keys))
			return list("error" = "В шаблоне указан недопустимый слот направленного размещения.")
		for(var/coord_key as anything in coord_keys)
			if(relative_coord_lookup[coord_key])
				return list("error" = "В шаблоне несколько размещений для одного и того же относительного слота.")
			relative_coord_lookup[coord_key] = TRUE
		sanitized_entries += list(sanitized_entry)

	var/list/computed_bounds = world_edit_compute_blueprint_bounds(sanitized_entries)
	if(computed_bounds["radius"] > WORLD_EDIT_BLUEPRINT_MAX_RADIUS)
		return list("error" = "Шаблон превышает допустимый лимит радиуса.")
	var/footprint_error = world_edit_validate_blueprint_footprint_bounds(computed_bounds)
	if(footprint_error)
		return list("error" = footprint_error)

	if(islist(raw_definition["bounds"]) && !world_edit_blueprint_bounds_match(raw_definition["bounds"], computed_bounds))
		return list("error" = "Метаданные bounds шаблона устарели или некорректны.")

	var/list/outpost_recipe_result = world_edit_validate_outpost_recipe(raw_definition["outpost_recipe"])
	if(outpost_recipe_result["error"])
		return outpost_recipe_result

	return list("blueprint" = list(
		"id" = blueprint_id,
		"name" = blueprint_name,
		"created_at" = "[raw_definition["created_at"] || ""]",
		"created_by" = ckey("[raw_definition["created_by"]]"),
		"source" = "[raw_definition["source"] || "dmm"]",
		"bounds" = computed_bounds,
		"entries" = sanitized_entries,
		"outpost_recipe" = outpost_recipe_result["outpost_recipe"],
	))

/datum/world_edit_blueprint_service/proc/world_edit_get_blueprint_preview_category_priority(category)
	switch("[category]")
		if("mine")
			return 60
		if("sentry", "defense")
			return 50
		if("wire_object")
			return 40
		if("support_prop")
			return 30
		if("building_wall")
			return 25
		if("barricade")
			return 20
		if("building_object")
			return 15
		if("building_floor")
			return 5
	return 10

/datum/world_edit_blueprint_service/proc/world_edit_get_blueprint_preview_tone(category)
	switch("[category]")
		if("mine")
			return "mine"
		if("sentry", "defense")
			return "defense"
		if("wire_object")
			return "wire"
		if("support_prop")
			return "support"
		if("building_wall")
			return "wall"
		if("building_floor")
			return "floor"
		if("building_object")
			return "support"
		if("barricade")
			return "barricade"
	return "other"

/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_preview_cells(list/blueprint)
	if(!islist(blueprint))
		return list()
	var/list/bounds = blueprint["bounds"]
	var/list/entries = blueprint["entries"]
	if(!islist(bounds) || !islist(entries) || !length(entries))
		return list()

	var/min_x = text2num("[bounds["min_x"]]")
	var/max_x = text2num("[bounds["max_x"]]")
	var/min_y = text2num("[bounds["min_y"]]")
	var/max_y = text2num("[bounds["max_y"]]")
	if(max_x < min_x || max_y < min_y)
		return list()

	var/list/cell_by_coord = list()
	for(var/list/entry as anything in entries)
		var/atom_path = text2path("[entry["type"]]")
		var/list/rule = ispath(atom_path, /turf) ? world_edit_get_blueprint_turf_rule(atom_path) : world_edit_get_blueprint_type_rule(atom_path)
		if(!islist(rule))
			continue

		var/category = "[rule["category"]]"
		var/priority = world_edit_get_blueprint_preview_category_priority(category)
		var/tone = world_edit_get_blueprint_preview_tone(category)
		var/dx = text2num("[entry["dx"]]")
		var/dy = text2num("[entry["dy"]]")
		var/dir_value = text2num("[entry["dir"]]") || SOUTH
		for(var/list/offset as anything in world_edit_get_blueprint_occupied_offsets(atom_path, dir_value))
			if(!islist(offset) || length(offset) < 2)
				continue
			var/occupied_dx = dx + (text2num("[offset[1]]") || 0)
			var/occupied_dy = dy + (text2num("[offset[2]]") || 0)
			var/coord_key = "[occupied_dx],[occupied_dy]"
			var/list/current_cell = cell_by_coord[coord_key]
			if(islist(current_cell) && text2num("[current_cell["priority"]]") > priority)
				continue
			cell_by_coord[coord_key] = list(
				"category" = category,
				"tone" = tone,
				"priority" = priority,
			)

	var/list/preview_cells = list()
	for(var/map_y = max_y, map_y >= min_y, map_y--)
		for(var/map_x = min_x, map_x <= max_x, map_x++)
			var/list/cell = cell_by_coord["[map_x],[map_y]"]
			if(!islist(cell))
				continue
			preview_cells += list(list(
				"x" = (map_x - min_x) + 1,
				"y" = (max_y - map_y) + 1,
				"category" = cell["category"],
				"tone" = cell["tone"],
			))

	return preview_cells

/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_summary(list/blueprint, file_path = null, valid = TRUE, error_text = "")
	var/list/bounds = blueprint["bounds"] || list()
	var/footprint_width = (bounds["max_x"] - bounds["min_x"]) + 1
	var/footprint_height = (bounds["max_y"] - bounds["min_y"]) + 1
	var/list/summary = list(
		"id" = blueprint["id"],
		"name" = blueprint["name"],
		"entry_count" = length(blueprint["entries"]),
		"radius" = bounds["radius"] || 0,
		"footprint_width" = max(footprint_width, 0),
		"footprint_height" = max(footprint_height, 0),
		"created_at" = blueprint["created_at"] || "",
		"created_by" = blueprint["created_by"] || "",
		"source" = blueprint["source"] || "",
		"valid" = valid ? TRUE : FALSE,
		"error" = error_text,
		"preview_mode" = length(blueprint["entries"]) > WORLD_EDIT_BLUEPRINT_COMPACT_PREVIEW_ENTRY_THRESHOLD ? "compact" : "detail",
		"preview_cells" = world_edit_build_blueprint_preview_cells(blueprint),
	)
	if(file_path)
		summary["file_path"] = file_path
	if(islist(blueprint["outpost_recipe"]))
		summary["has_outpost_recipe"] = TRUE
		summary["outpost_defense_profile"] = blueprint["outpost_recipe"]["defense_profile"] || ""
		summary["outpost_layout_variant"] = blueprint["outpost_recipe"]["layout_variant"] || ""
	return summary
