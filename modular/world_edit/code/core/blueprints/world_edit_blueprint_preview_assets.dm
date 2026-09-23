/datum/world_edit_blueprint_service/proc/world_edit_build_sprite_preview_fallback(reason)
	return list(
		"mode" = "schematic",
		"reason" = "[reason]",
	)

/datum/world_edit_blueprint_service/proc/world_edit_insert_sprite_preview_spec(list/specs, list/new_spec)
	if(!islist(specs) || !islist(new_spec))
		return FALSE

	var/new_layer = text2num("[new_spec["layer"]]")
	for(var/index = 1, index <= length(specs), index++)
		var/list/existing_spec = specs[index]
		if(!islist(existing_spec))
			continue
		var/existing_layer = text2num("[existing_spec["layer"]]")
		if(new_layer < existing_layer)
			specs.Insert(index, null)
			specs[index] = new_spec
			return TRUE

	specs += list(new_spec)
	return TRUE

/datum/world_edit_blueprint_service/proc/world_edit_apply_preview_icon_tint(icon/layer_icon, list/spec)
	if(!istype(layer_icon) || !islist(spec))
		return

	if(!isnull(spec["alpha"]))
		var/alpha = clamp(round(text2num("[spec["alpha"]]")), 0, 255)
		if(alpha < 255)
			layer_icon.Blend(rgb(255, 255, 255, alpha), ICON_MULTIPLY)

	var/color = spec["color"]
	if(!color)
		return
	if(islist(color))
		layer_icon.MapColors(arglist(color))
	else
		layer_icon.Blend(color, ICON_MULTIPLY)

/datum/world_edit_blueprint_service/proc/world_edit_blend_preview_icon_spec(icon/canvas, list/spec, base_x, base_y)
	if(!istype(canvas) || !islist(spec) || isnull(spec["icon"]))
		return FALSE

	var/icon_state = spec["icon_state"]
	if(isnull(icon_state))
		icon_state = ""
	var/dir_value = text2num("[spec["dir"]]") || SOUTH
	var/icon/layer_icon = icon(spec["icon"], "[icon_state]", dir_value)
	if(!istype(layer_icon) || !length(icon_states(layer_icon)))
		return FALSE

	world_edit_apply_preview_icon_tint(layer_icon, spec)
	var/blend_x = round(text2num("[base_x]")) + round(text2num("[spec["pixel_x"]]"))
	var/blend_y = round(text2num("[base_y]")) + round(text2num("[spec["pixel_y"]]"))
	canvas.Blend(layer_icon, ICON_OVERLAY, blend_x, blend_y)

	var/list/overlays = spec["overlays"]
	if(!islist(overlays) || !length(overlays))
		return TRUE

	for(var/list/overlay_spec as anything in overlays)
		if(!islist(overlay_spec) || isnull(overlay_spec["icon"]))
			continue
		var/overlay_state = overlay_spec["icon_state"]
		if(isnull(overlay_state))
			overlay_state = ""
		var/overlay_dir = text2num("[overlay_spec["dir"]]") || dir_value
		var/icon/overlay_icon = icon(overlay_spec["icon"], "[overlay_state]", overlay_dir)
		if(!istype(overlay_icon) || !length(icon_states(overlay_icon)))
			continue
		world_edit_apply_preview_icon_tint(overlay_icon, overlay_spec)
		var/overlay_x = blend_x + round(text2num("[overlay_spec["pixel_x"]]"))
		var/overlay_y = blend_y + round(text2num("[overlay_spec["pixel_y"]]"))
		canvas.Blend(overlay_icon, ICON_OVERLAY, overlay_x, overlay_y)

	return TRUE

/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_sprite_preview_icon(list/blueprint)
	if(!islist(blueprint))
		return null

	var/list/bounds = blueprint["bounds"]
	var/list/entries = blueprint["entries"]
	if(!islist(bounds) || !islist(entries) || !length(entries))
		return null
	if(length(entries) > WORLD_EDIT_BLUEPRINT_COMPACT_PREVIEW_ENTRY_THRESHOLD)
		return null

	var/min_x = text2num("[bounds["min_x"]]")
	var/max_x = text2num("[bounds["max_x"]]")
	var/min_y = text2num("[bounds["min_y"]]")
	var/max_y = text2num("[bounds["max_y"]]")
	var/footprint_width = (max_x - min_x) + 1
	var/footprint_height = (max_y - min_y) + 1
	if(footprint_width <= 0 || footprint_height <= 0)
		return null
	if(footprint_width > WORLD_EDIT_BLUEPRINT_MAX_DIMENSION || footprint_height > WORLD_EDIT_BLUEPRINT_MAX_DIMENSION)
		return null

	var/pixel_size = world.icon_size || 32
	var/padding_tiles = 1
	var/canvas_width = (footprint_width + (padding_tiles * 2)) * pixel_size
	var/canvas_height = (footprint_height + (padding_tiles * 2)) * pixel_size
	var/icon/canvas = icon('icons/effects/effects.dmi', "nothing")
	canvas.Scale(canvas_width, canvas_height)

	var/list/specs = list()
	for(var/list/entry as anything in entries)
		var/dir_value = text2num("[entry["dir"]]") || SOUTH
		var/atom_path = text2path("[entry["type"]]")
		var/list/spec
		if(ispath(atom_path, /turf))
			var/turf/preview_turf = atom_path
			spec = GLOB.world_edit_helpers.build_world_edit_preview_appearance_spec(
				initial(preview_turf.icon),
				length("[initial(preview_turf.icon_state)]") ? "[initial(preview_turf.icon_state)]" : null,
				SOUTH,
				initial(preview_turf.layer),
				initial(preview_turf.plane),
				0,
				0,
				255
			)
		else if(ispath(atom_path, /obj))
			spec = GLOB.world_edit_helpers.build_world_edit_atom_preview_appearance_spec(atom_path, dir_value, entry["vars"], 255)
		if(!islist(spec))
			continue

		spec["dx"] = text2num("[entry["dx"]]")
		spec["dy"] = text2num("[entry["dy"]]")
		world_edit_insert_sprite_preview_spec(specs, spec)

	if(!length(specs))
		return null

	var/drawn_count = 0
	for(var/spec_entry as anything in specs)
		var/list/spec = spec_entry
		if(!islist(spec))
			continue
		var/base_x = ((text2num("[spec["dx"]]") - min_x) + padding_tiles) * pixel_size + 1
		var/base_y = ((text2num("[spec["dy"]]") - min_y) + padding_tiles) * pixel_size + 1
		if(world_edit_blend_preview_icon_spec(canvas, spec, base_x, base_y))
			drawn_count++

	if(!drawn_count)
		return null
	return canvas

/datum/world_edit_blueprint_service/proc/world_edit_build_blueprint_sprite_preview_payload(list/blueprint, client/target)
	if(!target)
		return world_edit_build_sprite_preview_fallback("no_client")
	if(!islist(blueprint))
		return world_edit_build_sprite_preview_fallback("invalid")

	var/list/entries = blueprint["entries"]
	if(!islist(entries) || !length(entries))
		return world_edit_build_sprite_preview_fallback("empty")
	if(length(entries) > WORLD_EDIT_BLUEPRINT_COMPACT_PREVIEW_ENTRY_THRESHOLD)
		return world_edit_build_sprite_preview_fallback("budget")

	var/icon/preview_icon = world_edit_build_blueprint_sprite_preview_icon(blueprint)
	if(!istype(preview_icon))
		return world_edit_build_sprite_preview_fallback("render_failed")

	var/asset_key = icon2html(preview_icon, target, keyonly = TRUE)
	if(!length("[asset_key]"))
		return world_edit_build_sprite_preview_fallback("asset_failed")

	return list(
		"mode" = "sprite",
		"image_url" = SSassets.transport.get_asset_url(asset_key),
		"asset_key" = asset_key,
		"width" = preview_icon.Width(),
		"height" = preview_icon.Height(),
		"entry_count" = length(entries),
	)
