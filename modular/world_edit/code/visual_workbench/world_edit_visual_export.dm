/*
 * Semantic export for visual review rendering.
 *
 * The Python renderers intentionally consume semantic.json instead of parsing a
 * DMM file. DM owns the live atom appearance data; Python visualizes the
 * exported semantic flags and DMI-backed icon/icon_state metadata.
 */
/datum/world_edit_visual_case/proc/export_artifacts(list/apply_result, list/post_emit_result)
	var/list/artifacts = list()
	artifacts["semantic_json"] = "semantic.json"
	artifacts["semantic_png"] = "semantic.png"

	if(render_config?["after_dmm"])
		add_warning("after.dmm export not available in MVP; semantic.json was exported instead.")
		artifacts["after_dmm"] = null

	return list("artifacts" = artifacts)

/datum/world_edit_visual_case/proc/export_semantic_json(list/report_data)
	if(!istype(canvas))
		return null

	var/list/semantic = list(
		"schema" = "world_edit_visual_semantic/v1",
		"appearance_schema" = 1,
		"features" = list("appearance" = TRUE),
		"case_id" = id,
		"width" = canvas.width,
		"height" = canvas.height,
		"origin" = list("x" = canvas.min_x, "y" = canvas.min_y, "z" = canvas.z),
		"tiles" = list(),
		"rooms" = report_data?["rooms"] || build_semantic_rooms(),
		"routes" = report_data?["routes"] || build_semantic_routes(),
		"markers" = build_semantic_markers(report_data),
		"errors" = errors.Copy(),
	)
	if(length(workflow_run_id))
		semantic["workflow_run_id"] = workflow_run_id
	if(length(source_sha))
		semantic["source_sha"] = source_sha
	if(islist(report_data?["profile"]))
		semantic["profile"] = report_data["profile"]

	for(var/x in canvas.min_x to canvas.max_x)
		for(var/y in canvas.min_y to canvas.max_y)
			var/turf/T = locate(x, y, canvas.z)
			if(!istype(T))
				continue
			semantic["tiles"] += list(serialize_semantic_tile(T, x, y))

	var/path = "[out_dir]/semantic.json"
	write_json_file(path, semantic)
	return path

/datum/world_edit_visual_case/proc/serialize_semantic_tile(turf/T, x, y)
	refresh_semantic_turf_appearance(T)

	var/area/A = get_area(T)
	var/list/tile = list(
		"x" = x,
		"y" = y,
		"local_x" = x - canvas.min_x + 1,
		"local_y" = y - canvas.min_y + 1,
		"turf" = "[T.type]",
		"area" = "[A?.type]",
		"density" = T.density ? TRUE : FALSE,
		"opacity" = T.opacity ? TRUE : FALSE,
	)
	tile["appearance"] = serialize_semantic_appearance(T)
	tile["flags"] = list(
		// Flags are deliberately higher-level than raw type paths. They are the
		// stable contract used by render_semantic.py and future CI review sheets.
		"floor" = is_visual_floor(T),
		"wall" = is_visual_wall(T),
		"door" = has_visual_door(T),
		"reserved_walk" = is_reserved_walk_tile(T),
		"blocked" = is_blocked_tile(T),
		"changed" = canvas.changed_turfs[T] ? TRUE : FALSE,
		"error" = has_error_marker_at(x, y),
	)
	var/list/objects = list()
	for(var/obj/O as anything in T)
		if(!should_export_semantic_obj(O))
			continue
		objects += list(serialize_semantic_obj(O))
	tile["objects"] = objects
	return tile

/datum/world_edit_visual_case/proc/refresh_semantic_turf_appearance(turf/T)
	if(!istype(T, /turf/closed/wall))
		return
	var/turf/closed/wall/W = T
	W.update_connections(FALSE)
	W.update_icon()

/datum/world_edit_visual_case/proc/should_export_semantic_obj(obj/O)
	if(!istype(O))
		return FALSE
	if(istype(O, /obj/effect/landmark/world_edit_visual_canvas_origin))
		return FALSE
	if(O.invisibility)
		return FALSE
	return TRUE

/datum/world_edit_visual_case/proc/serialize_semantic_obj(obj/O)
	var/list/out = list(
		"path" = "[O.type]",
		"density" = O.density ? TRUE : FALSE,
		"dir" = GLOB.world_edit_helpers.dir_to_label(O.dir),
		"invisibility" = O.invisibility,
	)
	out["appearance"] = serialize_semantic_appearance(O)
	var/list/meta = lookup_object_placement_metadata(O)
	if(islist(meta))
		out["slot"] = meta["requested_slot"] || meta["slot"]
		out["provider_id"] = meta["fixture_provider_id"]
		out["functional"] = isnull(meta["functional"]) ? TRUE : (meta["functional"] ? TRUE : FALSE)
		out["category"] = meta["category"]
		out["zone_id"] = meta["zone_id"]
		out["anchor_id"] = meta["anchor_id"]
		out["semantic_requirement_id"] = meta["semantic_requirement_id"] || meta["requirement_id"]
		out["dir_source"] = meta["dir_source"]
		out["dir_mode"] = meta["dir_mode"]
		out["wall_dir"] = meta["wall_dir_label"] || (isnull(meta["wall_dir"]) ? null : GLOB.world_edit_helpers.dir_to_label(meta["wall_dir"]))
		out["front_dir"] = meta["front_dir_label"] || (isnull(meta["front_dir"]) ? null : GLOB.world_edit_helpers.dir_to_label(meta["front_dir"]))
		out["wall_mounted"] = meta["wall_mounted"] ? TRUE : FALSE
		var/list/preview_appearance = null
		if(islist(meta["appearance"]))
			preview_appearance = meta["appearance"]
		else if(islist(meta["preview_appearance"]))
			preview_appearance = meta["preview_appearance"]
		else if(islist(meta["appearance_spec"]))
			preview_appearance = meta["appearance_spec"]
		var/list/live_appearance = out["appearance"]
		if(islist(preview_appearance) && islist(live_appearance))
			var/list/overlay_specs = preview_appearance["overlays"]
			if(islist(overlay_specs))
				live_appearance["overlays"] = overlay_specs.Copy()
	return out

/datum/world_edit_visual_case/proc/serialize_semantic_appearance(appearance_source, include_overlays = TRUE)
	if(!is_semantic_appearance_source(appearance_source))
		return null
	var/icon_path = get_icon_dmi_path(appearance_source)
	var/base_icon_exists = icon_exists(appearance_source:icon, appearance_source:icon_state)
	var/list/out = list(
		"icon" = icon_path || (isnull(appearance_source:icon) ? null : "[appearance_source:icon]"),
		"icon_state" = isnull(appearance_source:icon_state) ? "" : "[appearance_source:icon_state]",
		"dir_value" = appearance_source:dir,
		"dir" = GLOB.world_edit_helpers.dir_to_label(appearance_source:dir),
		"pixel_x" = appearance_source:pixel_x,
		"pixel_y" = appearance_source:pixel_y,
		"layer" = appearance_source:layer,
		"plane" = appearance_source:plane,
		"alpha" = appearance_source:alpha,
		"color" = isnull(appearance_source:color) ? null : "[appearance_source:color]",
		"invisibility" = appearance_source:invisibility,
		"base_icon_exists" = base_icon_exists ? TRUE : FALSE,
	)
	if(include_overlays)
		var/list/overlay_specs = serialize_semantic_appearance_list(appearance_source:overlays)
		if(!length(overlay_specs) && istype(appearance_source, /turf/closed/wall))
			var/turf/closed/wall/W = appearance_source
			overlay_specs = build_wall_semantic_overlay_specs(W)
		if(length(overlay_specs))
			out["overlays"] = overlay_specs
	return out

/datum/world_edit_visual_case/proc/is_semantic_appearance_source(value)
	return isatom(value) || istype(value, /image) || istype(value, /mutable_appearance)

/datum/world_edit_visual_case/proc/serialize_semantic_appearance_list(list/appearances)
	var/list/out = list()
	if(!islist(appearances))
		return out
	for(var/appearance_entry as anything in appearances)
		var/list/appearance_spec = serialize_semantic_appearance(appearance_entry, FALSE)
		if(islist(appearance_spec))
			out += list(appearance_spec)
	return out

/datum/world_edit_visual_case/proc/build_wall_semantic_overlay_specs(turf/closed/wall/W)
	var/list/out = list()
	if(!istype(W) || W.special_icon || !W.density || !islist(W.wall_connections))
		return out
	var/icon_path = get_icon_dmi_path(W)
	for(var/i = 1 to 4)
		if(i > length(W.wall_connections))
			break
		var/state = "[W.walltype][W.wall_connections[i]]"
		if(!icon_exists(W.icon, state))
			continue
		var/dir_to_use = 1 << (i - 1)
		out += list(list(
			"icon" = icon_path || (isnull(W.icon) ? null : "[W.icon]"),
			"icon_state" = state,
			"dir_value" = dir_to_use,
			"dir" = GLOB.world_edit_helpers.dir_to_label(dir_to_use),
			"pixel_x" = 0,
			"pixel_y" = 0,
			"layer" = W.layer,
			"plane" = W.plane,
			"alpha" = W.alpha,
			"color" = isnull(W.color) ? null : "[W.color]",
			"invisibility" = W.invisibility,
			"base_icon_exists" = TRUE,
		))
	return out

/datum/world_edit_visual_case/proc/lookup_object_placement_metadata(obj/O)
	if(!istype(O) || !islist(last_plan?.placements))
		return null
	// Placement metadata is stored on the plan, not on emitted atoms. Match by
	// coordinate and type so semantic.json can still show slot/provider details.
	for(var/list/placement as anything in last_plan.placements)
		if(!islist(placement))
			continue
		if("[placement["x"]]" != "[O.x]" || "[placement["y"]]" != "[O.y]" || "[placement["z"]]" != "[O.z]")
			continue
		if("[placement["obj_path"]]" != "[O.type]")
			continue
		return placement
	return null

/datum/world_edit_visual_case/proc/is_visual_floor(turf/T)
	return istype(T, /turf/open) && !T.density

/datum/world_edit_visual_case/proc/is_visual_wall(turf/T)
	return T.density ? TRUE : FALSE

/datum/world_edit_visual_case/proc/has_visual_door(turf/T)
	for(var/obj/O as anything in T)
		if(findtext("[O.type]", "/door"))
			return TRUE
	return FALSE

/datum/world_edit_visual_case/proc/is_reserved_walk_tile(turf/T)
	var/list/route_turfs = last_plan?.metadata?["generator_effect_turfs"]
	return islist(route_turfs) && (T in route_turfs) && !T.density

/datum/world_edit_visual_case/proc/is_blocked_tile(turf/T)
	if(T.density)
		return TRUE
	for(var/atom/movable/A as anything in T)
		if(ismob(A))
			continue
		if(A.density)
			return TRUE
	return FALSE

/datum/world_edit_visual_case/proc/has_error_marker_at(x, y)
	for(var/list/error as anything in errors)
		if(!islist(error))
			continue
		if(text2num("[error["x"]]") == x && text2num("[error["y"]]") == y)
			return TRUE
	return FALSE

/datum/world_edit_visual_case/proc/build_semantic_rooms()
	var/list/rooms = list()
	var/list/raw_rooms = last_plan?.metadata?["room_reports"]
	if(!length(raw_rooms))
		raw_rooms = last_plan?.metadata?["room_contract_report"]
	if(islist(raw_rooms))
		for(var/list/room as anything in raw_rooms)
			if(islist(room))
				rooms += list(room.Copy())
	return rooms

/datum/world_edit_visual_case/proc/build_semantic_routes()
	var/list/routes = list()
	var/list/corridor_report = last_plan?.metadata?["corridor_report"]
	if(islist(corridor_report))
		routes += list(corridor_report.Copy())
	return routes

/datum/world_edit_visual_case/proc/build_semantic_markers(list/report_data)
	var/list/markers = list()
	var/list/anchors = shape_config?["anchors"]
	if(islist(anchors))
		for(var/list/anchor as anything in anchors)
			if(!islist(anchor))
				continue
			markers += list(list(
				"kind" = "anchor",
				"x" = text2num("[anchor["x"]]") || 0,
				"y" = text2num("[anchor["y"]]") || 0,
				"label" = "anchor",
			))
	if(last_plan?.metadata?["center_turf"])
		var/turf/center = last_plan.metadata["center_turf"]
		if(istype(center))
			markers += list(list("kind" = "center", "x" = center.x, "y" = center.y, "label" = "center"))
	return markers
