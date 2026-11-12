// Render only the levels visible through an opening with depth blur.
GLOBAL_DATUM_INIT(openspace_backdrop_one_for_all, /atom/movable/openspace_backdrop, new)

/atom/movable/openspace_backdrop
	name = "openspace_backdrop"
	anchored = TRUE
	icon = 'icons/turf/floors/floors.dmi'
	icon_state = "grey"
	plane = OPENSPACE_BACKDROP_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/vis_contents_holder
	plane = OPEN_SPACE_PLANE_START
	vis_flags = VIS_HIDE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/vis_contents_holder/Initialize(mapload, turf/below, z_offset)
	. = ..()
	plane -= z_offset
	vis_contents += GLOB.openspace_backdrop_one_for_all
	vis_contents += below
	name = null

/atom/movable/screen/plane_master/open_space
	name = "open space plane"
	plane = OPEN_SPACE_PLANE_START

/atom/movable/screen/plane_master/open_space/Initialize(mapload, z_offset)
	name = "open space plane [z_offset]"
	plane -= z_offset
	. = ..()
	add_filter("multizblur", 1, gauss_blur_filter(0.5 + 0.25 * (z_offset + 1)))

/atom/movable/screen/plane_master/openspace_backdrop
	name = "open space backdrop plane"
	plane = OPENSPACE_BACKDROP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	alpha = 255

/atom/movable/screen/plane_master/openspace_backdrop/Initialize()
	. = ..()
	filters = list(
		filter(type = "drop_shadow", color = "#04080FAA", size = -10),
		filter(type = "drop_shadow", color = "#04080FAA", size = -15),
		filter(type = "drop_shadow", color = "#04080FAA", size = -20),
	)
