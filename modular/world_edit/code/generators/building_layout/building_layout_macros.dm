/datum/world_edit_generator/building_layout/proc/apply_building_layout_macro_overlays(datum/world_edit_building_layout_state/state)
	if(!istype(state))
		return
	if(state.config["layout_macro_overlays_applied"])
		return
	state.fixtures.layout_macros.Cut()
	state.fixtures.layout_macro_counts.Cut()

	for(var/turf/door_turf as anything in state.geometry.door_turfs)
		if(!istype(door_turf))
			continue
		var/door_dir = state.geometry.door_dirs[door_turf] || state.placement_dir
		state.register_layout_macro("door_node_chunk", "door", door_turf, door_dir, list(door_turf), list("door_policy"))

	for(var/turf/window_turf as anything in state.geometry.window_turfs)
		if(!istype(window_turf))
			continue
		var/window_dir = get_outward_dir(window_turf, state.geometry.footprint_lookup, (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2, (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2, state.placement_dir)
		state.register_layout_macro("window_panel_chunk", "window", window_turf, window_dir, list(window_turf), list("window_policy"))

	for(var/turf/boundary_turf as anything in state.geometry.boundary)
		if(!istype(boundary_turf) || !state.geometry.wall_lookup[boundary_turf])
			continue
		var/facade_macro = get_building_facade_macro_for_boundary_turf(state, boundary_turf)
		var/facade_dir = get_outward_dir(boundary_turf, state.geometry.footprint_lookup, (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2, (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2, state.placement_dir)
		state.register_layout_macro(facade_macro, "facade", boundary_turf, facade_dir, list(boundary_turf), list("facade_rules"))

	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(!islist(object_placement))
			continue
		var/macro_id = "[object_placement["layout_macro"] || ""]"
		if(!length(macro_id))
			if("[object_placement["kind"]]" == "microvariation")
				macro_id = "microvariation_detail_chunk"
			else
				continue
			object_placement["layout_macro"] = macro_id
		object_placement["template_overlay"] = TRUE
		object_placement["dmm_chunk"] = macro_id
		var/turf/target_turf = object_placement["turf"]
		var/dir_value = text2num("[object_placement["dir"]]") || SOUTH
		var/category = "[object_placement["category"] || object_placement["kind"] || "object"]"
		var/list/sources = list()
		if(length("[object_placement["cluster_id"]]"))
			sources += "[object_placement["cluster_id"]]"
		state.register_layout_macro(macro_id, category, target_turf, dir_value, list(target_turf), sources)
	state.config["layout_macro_overlays_applied"] = TRUE

/datum/world_edit_generator/building_layout/proc/get_building_layout_macro_id_for_turf(datum/world_edit_building_layout_state/state, category, turf/target_turf)
	if(!istype(state) || !istype(target_turf))
		return ""
	for(var/list/macro as anything in state.fixtures.layout_macros)
		if(!islist(macro) || macro["turf"] != target_turf)
			continue
		if(length("[category]") && "[macro["category"]]" != "[category]")
			continue
		return "[macro["id"]]"
	return ""
