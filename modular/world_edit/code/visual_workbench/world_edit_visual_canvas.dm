/*
 * Isolated map surface for visual workbench cases.
 *
 * Preferred mode is the compiled canvas map landmark from
 * modular/world_edit/maps/world_edit_visual_canvas.dmm. That avoids touching
 * live game z-levels and avoids depending on dynamic z allocation during early
 * DreamDaemon startup. Dynamic/static fallback modes stay guarded for local
 * development, but acceptance evidence should come from the compiled canvas.
 */
/datum/world_edit_visual_canvas
	var/id = ""
	var/preset = "blank_64"
	var/width = 64
	var/height = 64
	var/z = WORLD_EDIT_VISUAL_FALLBACK_Z
	var/canvas_mode = "unallocated"
	var/min_x = 1
	var/min_y = 1
	var/max_x = 64
	var/max_y = 64
	var/list/baseline_turf_types = list()
	var/list/changed_turfs = list()

/area/world_edit_visual
	name = "World Edit Visual Canvas"

GLOBAL_VAR(world_edit_visual_canvas_origin)

/obj/effect/landmark/world_edit_visual_canvas_origin
	name = "world edit visual canvas origin"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/world_edit_visual_canvas_origin/New()
	. = ..()
	var/obj/effect/landmark/world_edit_visual_canvas_origin/registered_origin = GLOB.world_edit_visual_canvas_origin
	if(!istype(registered_origin) || QDELETED(registered_origin))
		GLOB.world_edit_visual_canvas_origin = src

/obj/effect/landmark/world_edit_visual_canvas_origin/Destroy()
	if(GLOB.world_edit_visual_canvas_origin == src)
		GLOB.world_edit_visual_canvas_origin = null
	return ..()

/datum/world_edit_visual_canvas/proc/setup(list/config)
	preset = "[islist(config) && config["preset"] ? config["preset"] : "blank_64"]"
	width = clamp(round(text2num("[islist(config) ? config["width"] : null]") || 64), WORLD_EDIT_VISUAL_MIN_CANVAS_SIZE, WORLD_EDIT_VISUAL_MAX_CANVAS_SIZE)
	height = clamp(round(text2num("[islist(config) ? config["height"] : null]") || 64), WORLD_EDIT_VISUAL_MIN_CANVAS_SIZE, WORLD_EDIT_VISUAL_MAX_CANVAS_SIZE)

	var/list/z_result = acquire_test_z()
	if(z_result["error"])
		return z_result
	z = z_result["z"]
	max_x = min_x + width - 1
	max_y = min_y + height - 1
	return apply_preset(preset)

/datum/world_edit_visual_canvas/proc/acquire_test_z()
	var/obj/effect/landmark/world_edit_visual_canvas_origin/origin = GLOB.world_edit_visual_canvas_origin
	if(istype(origin))
		min_x = origin.x
		min_y = origin.y
		canvas_mode = "static_compiled_canvas"
		return list("z" = origin.z, "mode" = canvas_mode)

	var/new_z = world.maxz + 1
	world.incrementMaxZ()
	var/turf/probe = locate(min_x, min_y, new_z)
	if(istype(probe))
		canvas_mode = "dynamic_runtime_z"
		return list("z" = new_z, "mode" = canvas_mode)

	probe = locate(min_x, min_y, WORLD_EDIT_VISUAL_FALLBACK_Z)
	if(!istype(probe))
		return list("error" = "no_visual_test_z_available")
	canvas_mode = "static_fallback_z"
	return list("z" = WORLD_EDIT_VISUAL_FALLBACK_Z, "mode" = canvas_mode)

/datum/world_edit_visual_canvas/proc/apply_preset(preset_id)
	if(canvas_mode == "dynamic_runtime_z")
		reset_tracking()
	else
		clear_canvas()
	switch("[preset_id]")
		if("blank_64", "blank_96", "blank_128")
			return build_blank()
		else
			return list("error" = "unknown_canvas_preset:[preset_id]")

/datum/world_edit_visual_canvas/proc/reset_tracking()
	baseline_turf_types.Cut()
	changed_turfs.Cut()

/datum/world_edit_visual_canvas/proc/build_blank()
	for(var/x in min_x to max_x)
		for(var/y in min_y to max_y)
			var/turf/T = locate(x, y, z)
			if(!istype(T))
				continue
			baseline_turf_types[T] = T.type
	return list("ok" = TRUE, "canvas_mode" = canvas_mode, "width" = width, "height" = height, "z" = z)

/datum/world_edit_visual_canvas/proc/clear_canvas()
	baseline_turf_types.Cut()
	changed_turfs.Cut()
	for(var/x in min_x to max_x)
		for(var/y in min_y to max_y)
			var/turf/T = locate(x, y, z)
			if(!istype(T))
				continue
			for(var/obj/O as anything in T)
				// Preserve the origin landmark; losing it would make the next
				// case fall back to less predictable z acquisition.
				if(istype(O, /obj/effect/landmark/world_edit_visual_canvas_origin))
					continue
				GLOB.world_edit_helpers.safe_qdel(O)
			if(T.type != /turf/open/floor)
				T.ChangeTurf(/turf/open/floor)

/datum/world_edit_visual_canvas/proc/mark_changed_turfs(list/turfs)
	if(!islist(turfs))
		return
	for(var/turf/T as anything in turfs)
		if(istype(T) && T.z == z && T.x >= min_x && T.x <= max_x && T.y >= min_y && T.y <= max_y)
			changed_turfs[T] = TRUE

/datum/world_edit_visual_canvas/proc/has_changed()
	return length(changed_turfs) > 0

/datum/world_edit_visual_canvas/proc/local_turf(local_x, local_y)
	var/x = min_x + round(text2num("[local_x]") || 1) - 1
	var/y = min_y + round(text2num("[local_y]") || 1) - 1
	if(x < min_x || x > max_x || y < min_y || y > max_y)
		return null
	return locate(x, y, z)
