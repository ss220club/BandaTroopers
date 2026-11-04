#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/datum/unit_test/shuttle_flight_airlock/Run()
	var/checked = 0
	for(var/obj/docking_port/stationary/marine_dropship/airlock/inner/inner_port in GLOB.dropship_airlock_docking_ports)
		if(!inner_port.linked_outer)
			return Fail("[inner_port] has no outer port", __FILE__, __LINE__)
		if(inner_port.linked_outer.linked_inner != inner_port)
			return Fail("[inner_port] has an incorrect outer link", __FILE__, __LINE__)
		if(inner_port.linked_outer.dropship_airlock_id != inner_port.dropship_airlock_id)
			return Fail("[inner_port] has mismatched identifiers", __FILE__, __LINE__)
		if(inner_port.roundstart_template && !inner_port.get_docked())
			return Fail("[inner_port] has no loaded dropship", __FILE__, __LINE__)
		if(inner_port.id == "dock" || inner_port.dropship_airlock_id == "generic")
			return Fail("[inner_port] lost its mapped identifiers", __FILE__, __LINE__)
		if(length(inner_port.floodlights) < 4)
			return Fail("[inner_port] has no paired side warning lights", __FILE__, __LINE__)
		for(var/obj/structure/machinery/floodlight/landing/dropship_airlock/light as anything in inner_port.floodlights)
			if(!(light.icon_state in icon_states(light.icon)))
				return Fail("[inner_port] has a warning light without a sprite", __FILE__, __LINE__)
		var/obj/docking_port/stationary/marine_dropship/airlock/outer/outer_port = inner_port.linked_outer
		var/turf/left_wall = locate(outer_port.x + outer_port.airlock_x_offset - 8, outer_port.y + outer_port.airlock_y_offset, outer_port.z)
		var/turf/right_wall = locate(outer_port.x + outer_port.airlock_x_offset + 8, outer_port.y + outer_port.airlock_y_offset, outer_port.z)
		if(!istype(left_wall, /turf/closed/wall) || !istype(right_wall, /turf/closed/wall))
			return Fail("[inner_port] lower chamber has open sides", __FILE__, __LINE__)
		for(var/turf/chamber_turf as anything in block(locate(outer_port.x + outer_port.airlock_x_offset - 7, outer_port.y + outer_port.airlock_y_offset - 12, outer_port.z), locate(outer_port.x + outer_port.airlock_x_offset + 7, outer_port.y + outer_port.airlock_y_offset + 12, outer_port.z)))
			if(istype(chamber_turf, /turf/open/space))
				return Fail("[inner_port] lower chamber has space beside its hatch", __FILE__, __LINE__)
		if(inner_port.get_docked())
			var/obj/docking_port/mobile/marine_dropship/dropship = inner_port.get_docked()
			var/obj/structure/machinery/computer/shuttle/dropship/flight/console = dropship.getControlConsole()
			if(!console || console.get_linked_airlock() != inner_port || !console.get_airlock_ui_data())
				return Fail("[inner_port] cannot be controlled from its dropship console", __FILE__, __LINE__)
		checked++
	if(SSmapping.configs[SHIP_MAP].map_name == "SSV Laituri" && checked != 1)
		return Fail("Laituri must have one linked hangar airlock", __FILE__, __LINE__)
	if(!("close" in icon_states('modular/shuttle_flight/icons/effects/airlock_inner.dmi')))
		return Fail("Inner airlock close sprite is missing", __FILE__, __LINE__)
	if(!("close" in icon_states('modular/shuttle_flight/icons/effects/airlock_outer.dmi')))
		return Fail("Outer airlock close sprite is missing", __FILE__, __LINE__)

/datum/unit_test/shuttle_flight_outer_hatch/Run()
	var/obj/docking_port/stationary/marine_dropship/airlock/inner/inner_port
	for(var/obj/docking_port/stationary/marine_dropship/airlock/inner/candidate in GLOB.dropship_airlock_docking_ports)
		if(candidate.get_docked())
			inner_port = candidate
			break
	if(!inner_port)
		return
	inner_port.linked_outer.get_outer_airlock_turf_lists()
	inner_port.update_outer_airlock(TRUE, forced = TRUE)
	var/start_time = world.time
	while(inner_port.processing && world.time - start_time < 100)
		sleep(1)
	if(inner_port.processing)
		return Fail("Outer hatch did not finish opening", __FILE__, __LINE__)
	var/checked = 0
	for(var/turf/hatch_turf as anything in inner_port.outer_airlock_turf_lists)
		if(!istype(hatch_turf, /turf/open/floor/hangar_airlock/outer))
			continue
		checked++
		if(hatch_turf.icon != 'icons/turf/floors/space.dmi')
			return Fail("Open outer hatch still displays a floor", __FILE__, __LINE__)
	inner_port.update_outer_airlock(FALSE, forced = TRUE)
	start_time = world.time
	while(inner_port.processing && world.time - start_time < 100)
		sleep(1)
	if(inner_port.processing)
		return Fail("Outer hatch did not finish closing", __FILE__, __LINE__)
	if(!checked)
		return Fail("Outer hatch contains no mapped floor turfs", __FILE__, __LINE__)
	for(var/turf/hatch_turf as anything in inner_port.outer_airlock_turf_lists)
		if(istype(hatch_turf, /turf/open/floor/hangar_airlock/outer) && hatch_turf.icon != 'icons/turf/almayer.dmi')
			return Fail("Closed outer hatch still displays space", __FILE__, __LINE__)
#endif
