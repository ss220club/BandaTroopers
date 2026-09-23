GLOBAL_DATUM_INIT(world_edit_helpers, /datum/world_edit_helpers, new)

/datum/world_edit_helpers

/// Безопасное удаление объектов World Edit (особенно неинициализированных).
/// Защищает от runtimes в Destroy() объектов, которые были созданы и сразу удалены.
/datum/world_edit_helpers/proc/safe_qdel(atom/target)
	if(!target)
		return
	var/turf/current_turf = get_turf(target)
	if(isobj(target) && current_turf)
		if(("area" in target.vars) && isnull(target.vars["area"]))
			target.vars["area"] = current_turf.loc
		if(("alarm_area" in target.vars) && isnull(target.vars["alarm_area"]))
			target.vars["alarm_area"] = current_turf.loc
	qdel(target)

/// Выравнивает настенный объект к стене, смещая его пиксельно.
/// Объект спавнится на полу и визуально сдвигается на стену.
/datum/world_edit_helpers/proc/align_object_to_wall(obj/target, direction)
	if(!istype(target) || !(direction in GLOB.cardinals))
		return
	
	var/should_align = FALSE
	if(istype(target, /obj/structure/machinery/power/apc) || \
		istype(target, /obj/structure/machinery/alarm) || \
		istype(target, /obj/structure/machinery/firealarm) || \
		istype(target, /obj/structure/machinery/light_switch) || \
		istype(target, /obj/structure/machinery/light) || \
		istype(target, /obj/item/device/radio/intercom))
		should_align = TRUE

	if(!should_align)
		return

	switch(direction)
		if(NORTH)
			target.pixel_y = 32
		if(SOUTH)
			target.pixel_y = -32
		if(EAST)
			target.pixel_x = 32
		if(WEST)
			target.pixel_x = -32


/datum/world_edit_helpers/proc/parse_bool(value)
	if(isnull(value))
		return FALSE
	if(isnum(value))
		return value ? TRUE : FALSE

	var/value_text = lowertext("[value]")
	return value_text in list("1", "true", "yes", "on", "да")

/datum/world_edit_helpers/proc/dir_to_label(direction)
	switch(direction)
		if(NORTH)
			return "Север"
		if(EAST)
			return "Восток"
		if(SOUTH)
			return "Юг"
		if(WEST)
			return "Запад"
	return "Север"

/datum/world_edit_helpers/proc/dir_to_ui_value(direction)
	switch(direction)
		if(NORTH)
			return "north"
		if(EAST)
			return "east"
		if(SOUTH)
			return "south"
		if(WEST)
			return "west"
	return "north"

/datum/world_edit_helpers/proc/dir_from_label(label, fallback_dir = NORTH)
	var/normalized_label = lowertext(trim("[label]"))
	switch(normalized_label)
		if("north")
			return NORTH
		if("east")
			return EAST
		if("south")
			return SOUTH
		if("west")
			return WEST
	switch("[label]")
		if("North")
			return NORTH
		if("Север")
			return NORTH
		if("East")
			return EAST
		if("Восток")
			return EAST
		if("South")
			return SOUTH
		if("Юг")
			return SOUTH
		if("West")
			return WEST
		if("Запад")
			return WEST
	return fallback_dir

/datum/world_edit_helpers/proc/turf_to_text(turf/target_turf)
	if(!istype(target_turf))
		return ""
	return "[target_turf.x],[target_turf.y],[target_turf.z]"

/datum/world_edit_helpers/proc/is_cardinal_dir(direction)
	return direction in GLOB.cardinals

/datum/world_edit_helpers/proc/build_turf_dir_slot_key(turf/target_turf, direction)
	if(!istype(target_turf) || !is_cardinal_dir(direction))
		return null
	return "[target_turf.x],[target_turf.y],[target_turf.z]:[direction]"

/datum/world_edit_helpers/proc/has_barricade_in_dir(turf/target_turf, direction)
	if(!istype(target_turf) || !is_cardinal_dir(direction))
		return FALSE

	for(var/obj/structure/barricade/existing_barricade in target_turf)
		if(existing_barricade.dir == direction)
			return TRUE

	return FALSE

/datum/world_edit_helpers/proc/has_dense_nonmob_blocker(turf/target_turf, ignore_barricades = FALSE)
	if(!target_turf)
		return TRUE

	for(var/atom/movable/blocker as anything in target_turf)
		if(ismob(blocker))
			continue
		if(ignore_barricades && istype(blocker, /obj/structure/barricade))
			continue
		if(blocker.density)
			return TRUE

	return FALSE

/datum/world_edit_helpers/proc/get_world_edit_radius_policy(list/params)
	var/list/policy = list(
		"only_clear_tiles" = TRUE,
		"only_reachable_tiles" = FALSE,
		"treat_windows_as_blockers" = TRUE,
	)
	if(!islist(params))
		return policy

	var/only_clear_raw = params[WORLD_EDIT_RADIUS_POLICY_ONLY_CLEAR_TILES]
	var/only_reachable_raw = params[WORLD_EDIT_RADIUS_POLICY_ONLY_REACHABLE_TILES]
	var/windows_blockers_raw = params[WORLD_EDIT_RADIUS_POLICY_WINDOWS_BLOCKERS]

	policy["only_clear_tiles"] = isnull(only_clear_raw) ? TRUE : parse_bool(only_clear_raw)
	policy["only_reachable_tiles"] = isnull(only_reachable_raw) ? FALSE : parse_bool(only_reachable_raw)
	policy["treat_windows_as_blockers"] = isnull(windows_blockers_raw) ? TRUE : parse_bool(windows_blockers_raw)
	if(policy["only_reachable_tiles"])
		policy["only_clear_tiles"] = TRUE

	return policy

/datum/world_edit_helpers/proc/is_radius_turf_center_blocked(turf/checking_turf, treat_windows_as_blockers = TRUE)
	if(!checking_turf || checking_turf.density)
		return TRUE

	for(var/atom/blocker as anything in checking_turf)
		if(ismob(blocker))
			continue
		if(istype(blocker, /obj/structure/window))
			if(treat_windows_as_blockers)
				return TRUE
			continue
		if(!blocker.density)
			continue
		if(blocker.flags_atom & ON_BORDER)
			continue
		return TRUE

	return FALSE

/datum/world_edit_helpers/proc/get_adjacent_radius_turfs(turf/current_turf, treat_windows_as_blockers = TRUE)
	var/list/adjacent_turfs = list()
	if(!current_turf)
		return adjacent_turfs

	if(!treat_windows_as_blockers)
		return current_turf.AdjacentTurfs()

	for(var/turf/adjacent_turf as anything in current_turf.AdjacentTurfs())
		if(is_radius_turf_center_blocked(adjacent_turf, TRUE))
			continue
		adjacent_turfs += adjacent_turf

	return adjacent_turfs

/datum/world_edit_helpers/proc/filter_radius_candidate_turfs(list/start_turfs, list/candidate_turfs, list/traversal_turfs = null, list/radius_policy = null, list/pinned_turfs = null)
	var/list/result = list()
	var/list/result_lookup = list()
	var/list/policy = islist(radius_policy) ? radius_policy : get_world_edit_radius_policy(radius_policy)
	var/only_clear_tiles = !!policy["only_clear_tiles"]
	var/only_reachable_tiles = !!policy["only_reachable_tiles"]
	var/treat_windows_as_blockers = !!policy["treat_windows_as_blockers"]
	var/list/start_lookup = list()
	var/list/pinned_lookup = list()
	var/z_level = null

	if(islist(start_turfs))
		for(var/turf/start_turf as anything in start_turfs)
			if(!istype(start_turf))
				continue
			if(isnull(z_level))
				z_level = start_turf.z
			if(start_turf.z != z_level || start_lookup[start_turf])
				continue
			start_lookup[start_turf] = TRUE

	if(islist(pinned_turfs))
		for(var/turf/pinned_turf as anything in pinned_turfs)
			if(!istype(pinned_turf))
				continue
			if(isnull(z_level))
				z_level = pinned_turf.z
			if(pinned_turf.z != z_level || pinned_lookup[pinned_turf])
				continue
			pinned_lookup[pinned_turf] = TRUE
			if(!result_lookup[pinned_turf])
				result_lookup[pinned_turf] = TRUE
				result += pinned_turf

	var/list/filtered_candidate_lookup = list()
	var/list/filtered_candidates = list()
	if(islist(candidate_turfs))
		for(var/turf/candidate_turf as anything in candidate_turfs)
			if(!istype(candidate_turf))
				continue
			if(isnull(z_level))
				z_level = candidate_turf.z
			if(candidate_turf.z != z_level || filtered_candidate_lookup[candidate_turf])
				continue
			if(!pinned_lookup[candidate_turf] && (only_clear_tiles || only_reachable_tiles) && is_radius_turf_center_blocked(candidate_turf, treat_windows_as_blockers))
				continue
			filtered_candidate_lookup[candidate_turf] = TRUE
			filtered_candidates += candidate_turf
			if(!only_reachable_tiles && !result_lookup[candidate_turf])
				result_lookup[candidate_turf] = TRUE
				result += candidate_turf

	if(!only_reachable_tiles)
		return result

	var/list/traversal_lookup = list()
	var/list/raw_traversal_turfs = islist(traversal_turfs) ? traversal_turfs : filtered_candidates
	for(var/turf/traversal_turf as anything in raw_traversal_turfs)
		if(!istype(traversal_turf))
			continue
		if(isnull(z_level))
			z_level = traversal_turf.z
		if(traversal_turf.z != z_level || traversal_lookup[traversal_turf])
			continue
		if((only_clear_tiles || only_reachable_tiles) && is_radius_turf_center_blocked(traversal_turf, treat_windows_as_blockers))
			continue
		traversal_lookup[traversal_turf] = TRUE

	var/list/visited_lookup = list()
	var/list/open_turfs = list()
	for(var/turf/start_turf as anything in start_lookup)
		if(!istype(start_turf) || visited_lookup[start_turf])
			continue
		visited_lookup[start_turf] = TRUE
		open_turfs += start_turf

	var/search_index = 1
	while(search_index <= length(open_turfs))
		var/turf/current_turf = open_turfs[search_index++]
		if(filtered_candidate_lookup[current_turf] && !result_lookup[current_turf])
			result_lookup[current_turf] = TRUE
			result += current_turf

		for(var/turf/adjacent_turf as anything in get_adjacent_radius_turfs(current_turf, treat_windows_as_blockers))
			if(!traversal_lookup[adjacent_turf] || visited_lookup[adjacent_turf])
				continue
			visited_lookup[adjacent_turf] = TRUE
			open_turfs += adjacent_turf

	return result

/datum/world_edit_helpers/proc/collect_line_turfs(turf/start_turf, turf/end_turf)
	var/list/turfs = list()
	if(!start_turf || !end_turf || start_turf.z != end_turf.z)
		return turfs

	var/x0 = start_turf.x
	var/y0 = start_turf.y
	var/x1 = end_turf.x
	var/y1 = end_turf.y
	var/dx = abs(x1 - x0)
	var/dy = abs(y1 - y0)
	var/sx = x0 < x1 ? 1 : -1
	var/sy = y0 < y1 ? 1 : -1
	var/err = dx - dy

	while(TRUE)
		var/turf/current_turf = locate(x0, y0, start_turf.z)
		if(current_turf)
			turfs += current_turf
		if(x0 == x1 && y0 == y1)
			break

		var/e2 = err * 2
		if(e2 > -dy)
			err -= dy
			x0 += sx
		if(e2 < dx)
			err += dx
			y0 += sy

	return turfs

/datum/world_edit_helpers/proc/collect_rectangle_turfs(turf/start_turf, turf/end_turf)
	var/list/turfs = list()
	if(!start_turf || !end_turf || start_turf.z != end_turf.z)
		return turfs

	var/min_x = min(start_turf.x, end_turf.x)
	var/max_x = max(start_turf.x, end_turf.x)
	var/min_y = min(start_turf.y, end_turf.y)
	var/max_y = max(start_turf.y, end_turf.y)
	var/z_level = start_turf.z

	for(var/y in min_y to max_y)
		for(var/x in min_x to max_x)
			var/turf/target_turf = locate(x, y, z_level)
			if(target_turf)
				turfs += target_turf

	return turfs

/datum/world_edit_helpers/proc/step_turf(turf/start_turf, direction, steps = 1)
	var/turf/current_turf = start_turf
	for(var/i in 1 to steps)
		current_turf = get_step(current_turf, direction)
		if(!current_turf)
			return null
	return current_turf

/datum/world_edit_helpers/proc/build_turf_preview_images(list/turfs, icon_state = "greenOverlay", color = null, alpha = null)
	var/list/images = list()
	if(!length(turfs))
		return images

	for(var/turf/target_turf as anything in turfs)
		var/image/overlay = image('icons/turf/overlays.dmi', target_turf, icon_state)
		overlay.plane = ABOVE_LIGHTING_PLANE
		if(!isnull(color))
			overlay.color = color
		if(isnum(alpha))
			overlay.alpha = clamp(round(alpha), 0, 255)
		images += overlay

	return images

/datum/world_edit_helpers/proc/build_grouped_turf_preview_images(list/groups)
	var/list/images = list()
	if(!islist(groups) || !length(groups))
		return images

	for(var/list/group as anything in groups)
		if(!islist(group))
			continue

		var/list/turfs = group["turfs"]
		var/icon_state = length("[group["icon_state"]]") ? "[group["icon_state"]]" : "greenOverlay"
		var/color = group["color"]
		var/alpha = group["alpha"]
		images += build_turf_preview_images(turfs, icon_state, color, alpha)

	return images

/datum/world_edit_helpers/proc/build_preview_overlay_image(list/spec)
	if(!islist(spec))
		return null

	var/icon_file = spec["icon"]
	if(isnull(icon_file))
		return null

	var/icon_state = length("[spec["icon_state"]]") ? "[spec["icon_state"]]" : null
	var/dir_to_use = text2num("[spec["dir"]]")
	if(!is_cardinal_dir(dir_to_use))
		dir_to_use = SOUTH

	var/image/overlay = image(icon_file, null, icon_state, null, dir_to_use)
	if(!isnull(spec["color"]))
		overlay.color = spec["color"]
	if(!isnull(spec["alpha"]))
		overlay.alpha = clamp(round(text2num("[spec["alpha"]]")), 0, 255)
	if(!isnull(spec["pixel_x"]))
		overlay.pixel_x = round(text2num("[spec["pixel_x"]]"))
	if(!isnull(spec["pixel_y"]))
		overlay.pixel_y = round(text2num("[spec["pixel_y"]]"))
	return overlay

/datum/world_edit_helpers/proc/build_preview_image_from_spec(list/spec)
	if(!islist(spec))
		return null

	var/turf/target_turf = spec["turf"]
	var/icon_file = spec["icon"]
	if(!istype(target_turf) || isnull(icon_file))
		return null

	var/icon_state = length("[spec["icon_state"]]") ? "[spec["icon_state"]]" : null
	var/dir_to_use = text2num("[spec["dir"]]")
	if(!is_cardinal_dir(dir_to_use))
		dir_to_use = SOUTH

	var/layer = isnull(spec["layer"]) ? OBJ_LAYER : spec["layer"]
	var/image/preview = image(icon_file, target_turf, icon_state, layer, dir_to_use)
	if(!isnull(spec["plane"]))
		preview.plane = spec["plane"]
	if(!isnull(spec["color"]))
		preview.color = spec["color"]
	if(!isnull(spec["alpha"]))
		preview.alpha = clamp(round(text2num("[spec["alpha"]]")), 0, 255)
	if(!isnull(spec["pixel_x"]))
		preview.pixel_x = round(text2num("[spec["pixel_x"]]"))
	if(!isnull(spec["pixel_y"]))
		preview.pixel_y = round(text2num("[spec["pixel_y"]]"))

	var/list/overlay_specs = spec["overlays"]
	if(islist(overlay_specs))
		for(var/list/overlay_spec as anything in overlay_specs)
			var/image/overlay = build_preview_overlay_image(overlay_spec)
			if(istype(overlay))
				preview.overlays += overlay

	return preview

/datum/world_edit_helpers/proc/build_preview_images_from_specs(list/specs)
	var/list/images = list()
	if(!islist(specs) || !length(specs))
		return images

	for(var/list/spec as anything in specs)
		var/image/preview = build_preview_image_from_spec(spec)
		if(istype(preview))
			images += preview

	return images

/datum/world_edit_helpers/proc/build_preview_spec_signature_chunk(list/spec, include_turf = TRUE)
	if(!islist(spec))
		return ""

	var/list/chunks = list()
	if(include_turf)
		var/turf/target_turf = spec["turf"]
		chunks += turf_to_text(target_turf)
	else
		chunks += ""
	chunks += isnull(spec["icon"]) ? "" : "[spec["icon"]]"
	chunks += length("[spec["icon_state"]]") ? "[spec["icon_state"]]" : ""
	chunks += isnull(spec["dir"]) ? "" : "[spec["dir"]]"
	chunks += isnull(spec["layer"]) ? "" : "[spec["layer"]]"
	chunks += isnull(spec["plane"]) ? "" : "[spec["plane"]]"
	chunks += isnull(spec["pixel_x"]) ? "" : "[round(text2num("[spec["pixel_x"]]"))]"
	chunks += isnull(spec["pixel_y"]) ? "" : "[round(text2num("[spec["pixel_y"]]"))]"
	chunks += isnull(spec["alpha"]) ? "" : "[clamp(round(text2num("[spec["alpha"]]")), 0, 255)]"
	chunks += isnull(spec["color"]) ? "" : "[spec["color"]]"

	var/list/overlay_chunks = list()
	var/list/overlay_specs = spec["overlays"]
	if(islist(overlay_specs))
		for(var/list/overlay_spec as anything in overlay_specs)
			overlay_chunks += build_preview_spec_signature_chunk(overlay_spec, FALSE)
	chunks += jointext(overlay_chunks, ";;")
	return jointext(chunks, "|")

/datum/world_edit_helpers/proc/build_preview_spec_signature(list/specs)
	if(!islist(specs) || !length(specs))
		return "<empty>"

	var/list/signature_chunks = list()
	for(var/list/spec as anything in specs)
		signature_chunks += build_preview_spec_signature_chunk(spec)
	return md5(jointext(signature_chunks, "||"))

/datum/world_edit_helpers/proc/build_world_edit_preview_overlay_spec(icon_file, icon_state = null, dir_to_use = SOUTH, pixel_x = 0, pixel_y = 0, alpha = 230, color = null)
	if(isnull(icon_file))
		return null

	return list(
		"icon" = icon_file,
		"icon_state" = icon_state,
		"dir" = is_cardinal_dir(dir_to_use) ? dir_to_use : SOUTH,
		"pixel_x" = round(text2num("[pixel_x]")),
		"pixel_y" = round(text2num("[pixel_y]")),
		"alpha" = isnull(alpha) ? null : clamp(round(text2num("[alpha]")), 0, 255),
		"color" = color,
	)

/datum/world_edit_helpers/proc/build_world_edit_preview_appearance_spec(icon_file, icon_state = null, dir_to_use = SOUTH, layer = null, plane = null, pixel_x = 0, pixel_y = 0, alpha = 230, color = null, list/overlays = null)
	if(isnull(icon_file))
		return null

	return list(
		"icon" = icon_file,
		"icon_state" = icon_state,
		"dir" = is_cardinal_dir(dir_to_use) ? dir_to_use : SOUTH,
		"layer" = layer,
		"plane" = plane,
		"pixel_x" = round(text2num("[pixel_x]")),
		"pixel_y" = round(text2num("[pixel_y]")),
		"alpha" = isnull(alpha) ? null : clamp(round(text2num("[alpha]")), 0, 255),
		"color" = color,
		"overlays" = islist(overlays) ? overlays.Copy() : list(),
	)

/datum/world_edit_helpers/proc/build_world_edit_preview_object_spec(turf/target_turf, icon_file, icon_state = null, dir_to_use = SOUTH, layer = null, plane = null, pixel_x = 0, pixel_y = 0, alpha = 230, color = null, list/overlays = null)
	if(!istype(target_turf) || isnull(icon_file))
		return null

	var/list/spec = build_world_edit_preview_appearance_spec(
		icon_file,
		icon_state,
		dir_to_use,
		layer,
		plane,
		pixel_x,
		pixel_y,
		alpha,
		color,
		overlays,
	)
	if(!islist(spec))
		return null
	spec["turf"] = target_turf
	return spec

/datum/world_edit_helpers/proc/get_world_edit_barricade_preview_layer(obj_path, dir_to_use)
	if(!ispath(obj_path, /obj/structure/barricade))
		return OBJ_LAYER

	var/obj/structure/barricade/preview_barricade = obj_path
	var/base_layer = initial(preview_barricade.layer)
	var/resolved_layer = base_layer

	switch(dir_to_use)
		if(SOUTH)
			resolved_layer = ABOVE_MOB_LAYER
		if(NORTH)
			resolved_layer = base_layer - 0.01
		else
			resolved_layer = base_layer

	if((ispath(obj_path, /obj/structure/barricade/metal) || ispath(obj_path, /obj/structure/barricade/sandbags)) && dir_to_use > 2)
		resolved_layer = OBJ_LAYER

	return resolved_layer

/datum/world_edit_helpers/proc/build_world_edit_barricade_preview_appearance_spec(obj_path, dir_to_use = SOUTH, alpha = 230)
	if(!ispath(obj_path, /obj/structure/barricade))
		return null

	var/obj/structure/barricade/preview_barricade = obj_path
	var/icon_file = initial(preview_barricade.icon)
	var/icon_state = initial(preview_barricade.icon_state)
	var/pixel_y = 0
	var/list/overlay_specs = list()
	var/is_wired = ispath(obj_path, /obj/structure/barricade/metal/wired) || ispath(obj_path, /obj/structure/barricade/metal/plasteel/wired) || ispath(obj_path, /obj/structure/barricade/sandbags/wired)
	if(ispath(obj_path, /obj/structure/barricade/sandbags/full))
		icon_state = "sandbag5"
		if(dir_to_use == NORTH)
			pixel_y = 7
		else if(dir_to_use == SOUTH)
			pixel_y = -7
	if(is_wired)
		var/barricade_type = "[initial(preview_barricade.barricade_type)]"
		if(length(barricade_type))
			overlay_specs += list(build_world_edit_preview_overlay_spec(icon_file, "[barricade_type]_wire", dir_to_use, 0, pixel_y, alpha))

	return build_world_edit_preview_appearance_spec(
		icon_file,
		icon_state,
		dir_to_use,
		get_world_edit_barricade_preview_layer(obj_path, dir_to_use),
		initial(preview_barricade.plane),
		0,
		pixel_y,
		alpha,
		null,
		overlay_specs,
	)

/datum/world_edit_helpers/proc/build_world_edit_barricade_preview_spec(obj_path, turf/target_turf, dir_to_use = SOUTH)
	if(!istype(target_turf))
		return null
	var/list/spec = build_world_edit_barricade_preview_appearance_spec(obj_path, dir_to_use)
	if(!islist(spec))
		return null
	spec["turf"] = target_turf
	return spec

/datum/world_edit_helpers/proc/build_world_edit_sentry_preview_appearance_spec(obj_path, dir_to_use = SOUTH, turned_on = TRUE, alpha = 230)
	if(!ispath(obj_path, /obj/structure/machinery/defenses/sentry))
		return null

	var/obj/structure/machinery/defenses/sentry/preview_sentry = obj_path
	var/icon_file = initial(preview_sentry.icon)
	var/icon_state = initial(preview_sentry.icon_state)
	var/defense_type = "[initial(preview_sentry.defense_type)]"
	var/sentry_type = "[initial(preview_sentry.sentry_type)]"
	var/list/overlay_specs = list()
	if(length(defense_type) && length(sentry_type))
		var/overlay_state = turned_on ? "[defense_type] [sentry_type]_on" : "[defense_type] [sentry_type]"
		overlay_specs += list(build_world_edit_preview_overlay_spec(icon_file, overlay_state, dir_to_use, 0, 0, alpha))

	return build_world_edit_preview_appearance_spec(
		icon_file,
		length("[icon_state]") ? "[icon_state]" : null,
		dir_to_use,
		initial(preview_sentry.layer),
		initial(preview_sentry.plane),
		0,
		0,
		alpha,
		null,
		overlay_specs,
	)

/datum/world_edit_helpers/proc/build_world_edit_sentry_preview_spec(obj_path, turf/target_turf, dir_to_use = SOUTH, turned_on = TRUE)
	if(!istype(target_turf))
		return null
	var/list/spec = build_world_edit_sentry_preview_appearance_spec(obj_path, dir_to_use, turned_on)
	if(!islist(spec))
		return null
	spec["turf"] = target_turf
	return spec

/datum/world_edit_helpers/proc/build_world_edit_atom_preview_appearance_spec(obj_path, dir_to_use = SOUTH, list/entry_vars = null, alpha = 230)
	if(!ispath(obj_path, /obj))
		return null

	if(ispath(obj_path, /obj/structure/barricade))
		return build_world_edit_barricade_preview_appearance_spec(obj_path, dir_to_use, alpha)
	if(ispath(obj_path, /obj/structure/covenant_barricade/wide))
		var/obj/structure/covenant_barricade/wide/preview_barrier = obj_path
		var/pixel_x = 0
		var/pixel_y = -16
		var/overlay_pixel_y = 0
		switch(dir_to_use)
			if(NORTH, SOUTH)
				pixel_x = -16
			if(EAST, WEST)
				overlay_pixel_y = 64
		return build_world_edit_preview_appearance_spec(
			initial(preview_barrier.icon),
			initial(preview_barrier.icon_state),
			dir_to_use,
			initial(preview_barrier.layer),
			initial(preview_barrier.plane),
			pixel_x,
			pixel_y,
			alpha,
			null,
			list(build_world_edit_preview_overlay_spec(initial(preview_barrier.icon), "[initial(preview_barrier.icon_state)]_o", dir_to_use, 0, overlay_pixel_y, alpha)),
		)
	if(ispath(obj_path, /obj/structure/machinery/defenses/sentry))
		return build_world_edit_sentry_preview_appearance_spec(obj_path, dir_to_use, parse_bool(islist(entry_vars) ? entry_vars["turned_on"] : null), alpha)

	var/atom/spawn_atom = obj_path
	var/icon_file = initial(spawn_atom.icon)
	if(isnull(icon_file))
		return null

	return build_world_edit_preview_appearance_spec(
		icon_file,
		length("[initial(spawn_atom.icon_state)]") ? "[initial(spawn_atom.icon_state)]" : null,
		is_cardinal_dir(dir_to_use) ? dir_to_use : initial(spawn_atom.dir),
		initial(spawn_atom.layer),
		initial(spawn_atom.plane),
		initial(spawn_atom.pixel_x),
		initial(spawn_atom.pixel_y),
		alpha,
		null,
		null,
	)

/datum/world_edit_helpers/proc/build_world_edit_atom_preview_spec(obj_path, turf/target_turf, dir_to_use = SOUTH, list/entry_vars = null)
	if(!istype(target_turf))
		return null
	var/list/spec = build_world_edit_atom_preview_appearance_spec(obj_path, dir_to_use, entry_vars)
	if(!islist(spec))
		return null
	spec["turf"] = target_turf
	return spec

/datum/world_edit_helpers/proc/build_grouped_turf_preview_signature(list/groups)
	if(!islist(groups) || !length(groups))
		return md5("<empty>")

	var/list/signature_chunks = list()
	for(var/list/group as anything in groups)
		if(!islist(group))
			continue

		var/list/group_chunks = list()
		group_chunks += length("[group["icon_state"]]") ? "[group["icon_state"]]" : "greenOverlay"
		group_chunks += isnull(group["color"]) ? "" : "[group["color"]]"

		var/alpha = group["alpha"]
		group_chunks += isnum(alpha) ? "[clamp(round(alpha), 0, 255)]" : ""

		var/list/turf_chunks = list()
		var/list/turfs = group["turfs"]
		if(islist(turfs))
			for(var/turf/target_turf as anything in turfs)
				if(!istype(target_turf))
					continue
				turf_chunks += turf_to_text(target_turf)
		group_chunks += jointext(turf_chunks, ";")
		signature_chunks += jointext(group_chunks, "|")

	return md5(jointext(signature_chunks, "||"))
