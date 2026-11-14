// RT-01 interior definitions required by maps/interiors/rt01.dmm (CM-PVE PR #203).
/area/interior/vehicle/rt01
	name = "RT-01 interior"
	icon_state = "van"

/turf/open/shuttle/vehicle/floor_3_14
	icon_state = "floor_3_14"

/obj/structure/bed/chair/vehicle/comfy
	icon = 'icons/obj/vehicles/interiors/seats.dmi'

/obj/structure/bed/chair/vehicle/comfy/alt
	icon_state = "alt_vehicle_seat"

/obj/structure/interior_exit/vehicle/rt01
	name = "RT-01 side door"
	icon = 'icons/obj/vehicles/interiors/rt01_general.dmi'
	icon_state = "door"

/obj/structure/interior_exit/vehicle/rt01/exterior
	icon_state = "door_ex"

/obj/structure/interior_exit/vehicle/rt01/back
	name = "RT-01 back door"
	icon_state = "back_door"

/obj/structure/prop/vehicle/rt01
	name = "RT-01 chassis"
	icon = 'icons/obj/vehicles/interiors/rt01_chassis.dmi'
	icon_state = "rt01_chassis"
	layer = ABOVE_TURF_LAYER
	mouse_opacity = FALSE

/obj/structure/prop/vehicle/rt01/console
	name = "vehicle console"
	icon_state = "vehicle_console"
	layer = ABOVE_MOB_LAYER
