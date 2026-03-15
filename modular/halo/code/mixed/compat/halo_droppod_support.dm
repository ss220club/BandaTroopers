/area
	var/no_droppod = FALSE

/area/drop_pod_space
	name = "drop pod transition"

/obj/effect/landmark/droppod
	name = "Droppod LZ Point"
	invisibility_value = SEE_INVISIBLE_OBSERVER
	icon_state = "o_green"

/turf/open/space/transit/drop_pod

/datum/turf_reservation/transit/drop_pod
	turf_type = /turf/open/space/transit/drop_pod
	var/list/turf/taken_turfs = list()

/datum/turf_reservation/transit/drop_pod/reserve(width, height, z_size, z_reservation)
	. = ..()
	if(!.)
		return

	// Make the reserved transit block safe for humans while the pod is in flight.
	for(var/turf/floor in reserved_turfs)
		var/area/old_area = floor.loc
		new /area/drop_pod_space(floor)
		floor.change_area(old_area, floor.loc)
