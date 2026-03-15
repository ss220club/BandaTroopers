/obj/structure/machinery/cryopod/big/halo
	name = "криокапсула"
	icon = 'icons/halo/obj/structures/machinery/64x64cryogenics.dmi'
	icon_state = "map_tool"
	dir = WEST
	bound_height = 64
	bound_width = 64
	occupant_angle = 65
	occupant_x = 16
	occupant_y = 8

/obj/structure/machinery/cryopod/big/halo/flipped
	dir = EAST
	bound_x = -32
	pixel_x = -32
	occupant_angle = 295
	occupant_x = 16
	occupant_y = 8

/obj/structure/machinery/cryopod/big/halo/Initialize()
	. = ..()
	icon_state = "cryo_base"
