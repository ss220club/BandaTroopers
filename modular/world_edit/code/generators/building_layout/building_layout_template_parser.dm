/datum/world_edit_generator/building_layout/proc/get_building_template_object_mapping()
	var/static/list/mapping
	if(mapping)
		return mapping

	mapping = list(
		/obj/structure/bed = list("slot" = "bed", "category" = "bed", "wall_required" = FALSE, "major" = TRUE),
		/obj/structure/bed/chair = list("slot" = "chair", "category" = "chair", "wall_required" = FALSE, "major" = FALSE),
		/obj/structure/surface/table = list("slot" = "table", "category" = "table", "wall_required" = FALSE, "major" = FALSE),
		/obj/structure/closet = list("slot" = "cabinet", "category" = "cabinet", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/surface/rack = list("slot" = "rack", "category" = "rack", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/computer = list("slot" = "console", "category" = "console", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/portable_atmospherics/hydroponics = list("slot" = "hydro_tray", "category" = "hydro_tray", "wall_required" = FALSE, "major" = FALSE),
		/obj/structure/sink = list("slot" = "sink", "category" = "kitchen_machine", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/medical_pod/sleeper = list("slot" = "sleeper", "category" = "medical_bed", "wall_required" = FALSE, "major" = FALSE),
		/obj/structure/machinery/medical_pod/bodyscanner = list("slot" = "medical_scanner", "category" = "medical_bed", "wall_required" = FALSE, "major" = FALSE),
		/obj/structure/machinery/power/apc = list("slot" = "apc", "category" = "apc", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/alarm = list("slot" = "air_alarm", "category" = "air_alarm", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/light_switch = list("slot" = "light_switch", "category" = "light_switch", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/firealarm = list("slot" = "fire_alarm", "category" = "fire_alarm", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/machinery/light = list("slot" = "light", "category" = "light", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/extinguisher_cabinet = list("slot" = "extinguisher", "category" = "wall_object", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/toilet = list("slot" = "toilet", "category" = "sanitation", "wall_required" = TRUE, "major" = TRUE),
		/obj/structure/reagent_dispensers/watertank = list("slot" = "water_tank", "category" = "water_or_chem", "wall_required" = TRUE, "major" = TRUE)
	)

	return mapping

/datum/world_edit_generator/building_layout/proc/resolve_template_cell_from_model(list/members, list/attributes)
	var/list/mapping = get_building_template_object_mapping()

	var/list/cell_params = null

	for(var/i in 1 to length(members))
		var/atom_path = members[i]
		var/list/vars = attributes[i]

		if(ispath(atom_path, /obj/effect/world_edit_slot_marker))
			var/slot = "table"
			var/category = "table"
			var/wall_required = FALSE
			var/major = TRUE

			if(vars)
				if("slot" in vars) slot = vars["slot"]
				if("category" in vars) category = vars["category"]
				if("wall_required" in vars) wall_required = !!vars["wall_required"]
				if("major" in vars) major = !!vars["major"]

			cell_params = list("slot" = slot, "category" = category, "wall_required" = wall_required, "major" = major)
			break // Marker takes precedence

		// Check if the object path matches any in our mapping list (or is a subtype)
		for(var/map_path in mapping)
			if(ispath(atom_path, map_path))
				cell_params = mapping[map_path]
				break // Stop checking mapping for this atom

	return cell_params

/datum/world_edit_generator/building_layout/proc/load_building_template_chunk_from_dmm(file_path, template_chunk_id, template_category)
	var/static/list/cached_parsed_chunks = list()
	if(cached_parsed_chunks[file_path])
		return cached_parsed_chunks[file_path]

	var/datum/parsed_map/pm = new(file(file_path))
	pm.build_cache()

	var/datum/world_edit_building_template_chunk/chunk = new /datum/world_edit_building_template_chunk(template_chunk_id, template_category)

	var/list/model_cells = list() // model_key -> list of params
	for(var/model_key in pm.modelCache)
		var/list/model = pm.modelCache[model_key]
		var/list/members = model[1]
		var/list/attributes = model[2]

		var/list/cell_params = resolve_template_cell_from_model(members, attributes)
		if(cell_params)
			model_cells[model_key] = cell_params

	var/list/cell_entries = list()
	var/min_x = null
	var/min_y = null
	for(var/datum/grid_set/grid_set as anything in pm.gridSets)
		if(!istype(grid_set) || !islist(grid_set.gridLines) || pm.key_len <= 0)
			continue
		var/y = grid_set.ycrd
		for(var/line_index in 1 to length(grid_set.gridLines))
			var/line = grid_set.gridLines[line_index]
			var/x = grid_set.xcrd
			for(var/str_pos in 1 to length(line) step pm.key_len)
				var/model_key = copytext(line, str_pos, str_pos + pm.key_len)
				var/list/params = model_cells[model_key]
				if(islist(params))
					cell_entries += list(list("x" = x, "y" = y, "params" = params))
					min_x = isnull(min_x) ? x : min(min_x, x)
					min_y = isnull(min_y) ? y : min(min_y, y)
				x++
			y--

	for(var/list/entry as anything in cell_entries)
		var/list/params = entry["params"]
		var/dx = round(text2num("[entry["x"]]") || 0) - min_x
		var/dy = round(text2num("[entry["y"]]") || 0) - min_y
		chunk.add_cell(dx, dy, params["slot"], params["category"], params["wall_required"], params["major"])

	cached_parsed_chunks[file_path] = chunk
	return chunk
