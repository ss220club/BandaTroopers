#define LIFEBOAT_BUMBLEBEE_WEST "bumblebee_west"

/obj/structure/shuttle/part/bumblebee
	name = "SKT-9 \"Bumblebee\" Lifeboat"
	icon = 'icons/halo/obj/structures/bumblebee_parts.dmi'
	icon_state = "0,1"
	layer = WALL_LAYER

/obj/structure/shuttle/part/bumblebee/ex_act(severity, direction)
	return FALSE

/obj/structure/shuttle/part/bumblebee/no_dense
	density = FALSE

/obj/structure/shuttle/part/bumblebee/no_dense/opacity_false
	opacity = FALSE

/obj/structure/shuttle/part/bumblebee/opacity_false
	opacity = FALSE

/obj/structure/bed/chair/vehicle/bumblebee

/obj/structure/bed/chair/vehicle/bumblebee/handle_rotation()
	if(dir == NORTH)
		layer = 4.09
	else
		layer = BELOW_MOB_LAYER
	if(buckled_mob)
		buckled_mob.setDir(dir)

/obj/structure/machinery/door/airlock/evacuation/bumblebee
	name = "\improper Bumblebee Evacuation Airlock"
	icon = 'icons/halo/obj/structures/doors/bumblebee_door.dmi'
	unslashable = TRUE
	unacidable = TRUE
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/computer/shuttle/escape_pod_panel/bumblebee
	icon = 'icons/halo/obj/structures/machinery/bumblebee_computer.dmi'
	icon_state = "console_on"

/obj/structure/roof/bumblebee_roof
	icon = 'icons/halo/obj/structures/bumblebee.dmi'
	icon_state = "bumblebee"
	indestructible = TRUE
	unslashable = TRUE
	unacidable = TRUE
	lazy_nodes = FALSE
	mouse_opacity = FALSE
	plane = 900
	alpha = 255
	pixel_y = -32
	pixel_x = -32

/obj/structure/roof/bumblebee_roof/ex_act(severity, direction)
	return

/obj/structure/roof/bumblebee_roof/Initialize()
	. = ..()
	normal_image = image(icon, src, "bumblebee", layer = layer)
	under_image = image(icon, src, "blank", layer = layer)
	under_image.plane = 900
	normal_image.plane = 900
	under_image.alpha = 75

/obj/effect/roof_node/bumblebee
	icon = 'icons/halo/landmarks.dmi'
	icon_state = "roof"

/obj/docking_port/mobile/crashable/escape_shuttle/bumblebee_west
	id = LIFEBOAT_BUMBLEBEE_WEST
	width = 6
	height = 3
	preferred_direction = WEST
	port_direction = WEST

/datum/map_template/shuttle/bumblebee_west
	name = "bumblebee"
	shuttle_id = LIFEBOAT_BUMBLEBEE_WEST

/obj/docking_port/stationary/escape_pod/bumblebee
	id = LIFEBOAT_BUMBLEBEE_WEST
	roundstart_template = /datum/map_template/shuttle/bumblebee_west
	width = 6
	height = 3

#undef LIFEBOAT_BUMBLEBEE_WEST
