#define ALMAYER_A1_INNER "airlock-almayer-a1-inner"
#define ALMAYER_A2_INNER "airlock-almayer-a2-inner"
#define GENERIC_A_O "airlock-generic-outer"
#define ALMAYER_A1_OUTER "airlock-almayer-a1-outer"
#define ALMAYER_A2_OUTER "airlock-almayer-a2-outer"

GLOBAL_LIST_EMPTY(airlock_projectors)

/datum/controller/subsystem/fz_transitions
	var/list/airlock_active = list()

/datum/controller/subsystem/fz_transitions/proc/toggle_selective_update(update, firing_id)
	airlock_active[firing_id] = update
	for(var/obj/effect/projector/airlock/projector as anything in GLOB.airlock_projectors)
		if(projector.firing_id != firing_id)
			continue
		if(update)
			GLOB.projectors |= projector
		else
			GLOB.projectors -= projector
			projector.clear_projection()
	if(update)
		fire()

/proc/refresh_dropship_destination_lists()
	for(var/obj/structure/machinery/computer/shuttle/dropship/flight/console in GLOB.machines)
		SStgui.update_uis(console)

/atom/movable/lighting_mask/rotating_toggleable
	icon = 'modular/shuttle_flight/icons/effects/lighting_object_big.dmi'
	icon_state = "no_animation_light_rotating-1"
	var/picked_number = 0
	var/toggled = FALSE

/atom/movable/lighting_mask/rotating_toggleable/Initialize(mapload, ...)
	. = ..()
	picked_number = rand(1, 3)
	icon_state = "no_animation_light_rotating-[picked_number]"

/atom/movable/lighting_mask/rotating_toggleable/proc/toggle()
	toggled = !toggled
	icon_state = "[toggled ? "light_rotating" : "no_animation_light_rotating"]-[picked_number]"

/obj/structure/machinery/floodlight/landing/dropship_airlock
	light_power = 2
	on_light_range = 10
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_BLUE
	light_mask_type = /atom/movable/lighting_mask/rotating_toggleable
	needs_power = TRUE
	toggleable = TRUE
	var/obj/docking_port/stationary/marine_dropship/airlock/inner/linked_inner
	var/linked_inner_dropship_airlock_id = "generic"

/obj/structure/machinery/floodlight/landing/dropship_airlock/Initialize(mapload, ...)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/machinery/floodlight/landing/dropship_airlock/LateInitialize()
	. = ..()
	for(var/obj/docking_port/stationary/marine_dropship/airlock/inner/inner_port in GLOB.dropship_airlock_docking_ports)
		if(linked_inner_dropship_airlock_id == inner_port.dropship_airlock_id)
			linked_inner = inner_port
			linked_inner.floodlights |= src
			break

/obj/structure/machinery/floodlight/landing/dropship_airlock/Destroy()
	if(linked_inner)
		linked_inner.floodlights -= src
	. = ..()

/obj/structure/machinery/floodlight/landing/dropship_airlock/proc/toggle_rotating()
	if(!istype(light?.our_mask, /atom/movable/lighting_mask/rotating_toggleable))
		return
	var/atom/movable/lighting_mask/rotating_toggleable/rotating_mask = light.our_mask
	playsound(src, 'sound/machines/switch.ogg', 100, vol_cat = VOLUME_SFX)
	rotating_mask.toggle()

/obj/structure/machinery/floodlight/landing/dropship_airlock/side
	name = "hangar warning light"
	base_icon_state = "floor_flood"
	density = FALSE
	needs_power = FALSE
	light_color = "#ff9e43"
	on_light_range = 5

/obj/structure/machinery/floodlight/landing/dropship_airlock/side/update_icon()
	. = ..()
	icon_state = "floor_flood_[light_on]"

/obj/structure/machinery/floodlight/landing/dropship_airlock/side/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	return TRUE

/obj/docking_port/stationary/marine_dropship/airlock/outer/proc/build_lower_chamber()
	var/center_x = x + airlock_x_offset
	var/center_y = y + airlock_y_offset
	for(var/floor_y in center_y - 12 to center_y + 12)
		for(var/floor_x in center_x - 7 to center_x + 7)
			var/turf/floor_position = locate(floor_x, floor_y, z)
			if(istype(floor_position, /turf/open/space))
				floor_position.ChangeTurf(/turf/open/floor/almayer/plate)
	for(var/wall_y in center_y - 13 to center_y + 13)
		var/turf/left = locate(center_x - 8, wall_y, z)
		var/turf/right = locate(center_x + 8, wall_y, z)
		if(istype(left, /turf/open/space))
			left.ChangeTurf(/turf/closed/wall/almayer/outer)
		if(istype(right, /turf/open/space))
			right.ChangeTurf(/turf/closed/wall/almayer/outer)
	for(var/wall_x in center_x - 7 to center_x + 7)
		var/turf/north = locate(wall_x, center_y + 13, z)
		var/turf/south = locate(wall_x, center_y - 13, z)
		if(istype(north, /turf/open/space))
			north.ChangeTurf(/turf/closed/wall/almayer/outer)
		if(istype(south, /turf/open/space))
			south.ChangeTurf(/turf/closed/wall/almayer/outer)

/obj/docking_port/stationary/marine_dropship/airlock/outer/proc/install_warning_lights()
	var/outer_x = x + airlock_x_offset
	var/outer_y = y + airlock_y_offset
	var/inner_x = linked_inner.x + linked_inner.airlock_x_offset
	var/inner_y = linked_inner.y + linked_inner.airlock_y_offset
	var/list/positions = list(
		locate(outer_x - 7, outer_y, z),
		locate(outer_x + 7, outer_y, z),
		locate(inner_x - 7, inner_y, linked_inner.z),
		locate(inner_x + 7, inner_y, linked_inner.z)
	)
	for(var/turf/position as anything in positions)
		if(!position || locate(/obj/structure/machinery/floodlight/landing/dropship_airlock) in position)
			continue
		var/obj/structure/machinery/floodlight/landing/dropship_airlock/side/light = new(position)
		light.linked_inner_dropship_airlock_id = dropship_airlock_id
		light.linked_inner = linked_inner
		linked_inner.floodlights |= light

/obj/structure/machinery/door/poddoor/almayer/airlock
	density = TRUE
	opacity = TRUE
	unslashable = TRUE
	unacidable = TRUE
	var/linked_inner_dropship_airlock_id = "generic"
	var/obj/docking_port/stationary/marine_dropship/airlock/inner/linked_inner

/obj/structure/machinery/door/poddoor/almayer/airlock/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/machinery/door/poddoor/almayer/airlock/LateInitialize()
	. = ..()
	for(var/obj/docking_port/stationary/marine_dropship/airlock/inner/inner_port in GLOB.dropship_airlock_docking_ports)
		if(linked_inner_dropship_airlock_id == inner_port.dropship_airlock_id)
			linked_inner = inner_port
			linked_inner.poddoors += src
			break

/obj/structure/machinery/door/poddoor/almayer/airlock/Destroy()
	if(linked_inner)
		linked_inner.poddoors -= src
	. = ..()

/obj/structure/machinery/door/poddoor/almayer/airlock/open()
	if(linked_inner?.open_outer_airlock)
		return
	. = ..()

/obj/effect/projector/airlock
	var/firing_id = "airlock"
	var/turf/source_floor
	var/atom/movable/clone/projected_floor
	var/list/projected_movables = list()

/obj/effect/projector/airlock/proc/register()
	GLOB.airlock_projectors |= src
	if(SSfz_transitions.airlock_active[firing_id])
		GLOB.projectors |= src

/obj/effect/projector/airlock/Destroy()
	GLOB.airlock_projectors -= src
	GLOB.projectors -= src
	clear_projection()
	. = ..()

/obj/effect/projector/airlock/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	return TRUE

/obj/effect/projector/airlock/proc/clear_projection()
	if(source_floor && projected_floor && source_floor.clone == projected_floor)
		source_floor.clone = null
	if(projected_floor)
		qdel(projected_floor)
		projected_floor = null
	source_floor = null
	for(var/atom/movable/master in projected_movables)
		var/atom/movable/clone/projected = projected_movables[master]
		qdel(projected)
	projected_movables.Cut()

/obj/effect/projector/airlock/proc/update_projection()
	var/turf/old_floor = get_turf(src)
	var/turf/target_floor = locate(x + vector_x, y + vector_y, z + vector_z)
	if(!old_floor || !target_floor)
		clear_projection()
		return
	if(source_floor != old_floor || !projected_floor || get_turf(projected_floor) != target_floor)
		clear_projection()
		source_floor = old_floor
		projected_floor = new(target_floor)
		projected_floor.mstr = old_floor
		old_floor.clone = projected_floor
	projected_floor.appearance = old_floor.appearance
	projected_floor.overlays = list()
	projected_floor.underlays = list()
	projected_floor.layer = 1.4
	projected_floor.plane = -7
	projected_floor.opacity = FALSE
	projected_floor.density = FALSE
	projected_floor.mouse_opacity = FALSE
	for(var/atom/movable/master in projected_movables)
		if(master?.loc == old_floor)
			continue
		var/atom/movable/clone/stale = projected_movables[master]
		qdel(stale)
		projected_movables -= master
	for(var/atom/movable/master in old_floor)
		if(istype(master, /obj/effect/projector) || istype(master, /atom/movable/clone) || isobserver(master))
			continue
		var/atom/movable/clone/projected = projected_movables[master]
		if(!projected)
			projected = new(target_floor)
			projected.mstr = master
			projected_movables[master] = projected
		else if(projected.loc != target_floor)
			projected.forceMove(target_floor)
		projected.appearance = master.appearance
		projected.layer = 1.4 + master.layer / 10
		projected.plane = -7
		projected.opacity = FALSE
		projected.density = FALSE
		projected.mouse_opacity = FALSE
#define SHUTTLE_AIRLOCK_CEREMONY_REQUIRED "hangar airlock entry required"

/obj/docking_port/mobile/marine_dropship
	var/admin_bypass_ceremony = FALSE

/obj/docking_port/mobile/marine_dropship/canDock(obj/docking_port/stationary/dock)
	. = ..()
	if(. != SHUTTLE_CAN_DOCK || admin_bypass_ceremony)
		return
	if(istype(dock, /obj/docking_port/stationary/marine_dropship/airlock/inner))
		var/obj/docking_port/stationary/marine_dropship/airlock/inner/inner_port = dock
		if(!inner_port.ceremony_satisfied_for(src))
			return SHUTTLE_AIRLOCK_CEREMONY_REQUIRED

/obj/docking_port/mobile/marine_dropship/admin_fly_shuttle(mob/user)
	admin_bypass_ceremony = TRUE
	. = ..()
	admin_bypass_ceremony = FALSE

/obj/structure/machinery/computer/shuttle/dropship/flight/proc/get_linked_airlock()
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	var/obj/docking_port/stationary/current_dock = shuttle?.get_docked()
	if(istype(current_dock, /obj/docking_port/stationary/marine_dropship/airlock/inner))
		return current_dock
	if(istype(current_dock, /obj/docking_port/stationary/marine_dropship/airlock/outer))
		var/obj/docking_port/stationary/marine_dropship/airlock/outer/outer_port = current_dock
		return outer_port.linked_inner

/obj/structure/machinery/computer/shuttle/dropship/flight/proc/get_airlock_ui_data()
	var/obj/docking_port/stationary/marine_dropship/airlock/inner/airlock = get_linked_airlock()
	if(!airlock)
		return null
	return list(
		"processing" = airlock.processing,
		"playing_alarm" = airlock.playing_airlock_alarm,
		"inner_open" = airlock.open_inner_airlock,
		"lowered" = airlock.lowered_dropship,
		"outer_open" = airlock.open_outer_airlock,
		"clamps_disengaged" = airlock.disengaged_clamps
	)

/obj/structure/machinery/computer/shuttle/dropship/flight/proc/handle_airlock_control(step, mob/user)
	var/obj/docking_port/stationary/marine_dropship/airlock/inner/airlock = get_linked_airlock()
	if(!airlock || !airlock.linked_outer || airlock.processing)
		return FALSE
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle || (shuttle.automated_delay && shuttle.automated_hangar_id && shuttle.automated_lz_id))
		return FALSE
	var/list/result
	switch(step)
		if("alarm")
			result = airlock.update_airlock_alarm(!airlock.playing_airlock_alarm)
		if("inner")
			result = airlock.update_inner_airlock(!airlock.open_inner_airlock)
		if("height")
			result = airlock.update_dropship_height(!airlock.lowered_dropship)
		if("outer")
			result = airlock.update_outer_airlock(!airlock.open_outer_airlock)
		if("clamps")
			result = airlock.update_clamps(!airlock.disengaged_clamps)
		else
			return FALSE
	if(result?["to_chat"])
		to_chat(user, result["successful"] ? SPAN_NOTICE(result["to_chat"]) : SPAN_WARNING(result["to_chat"]))
	SStgui.update_uis(src)
	return result?["successful"]
