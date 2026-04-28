/obj/item/prop/unsc_status_display
	icon = 'icons/halo/obj/items/prop_display.dmi'
	icon_state = "unsc_default"
	name = "status display"
	desc = "A monitor intended to depict the station's current status. It appears to have frozen."
	anchored = TRUE
	density = FALSE

/obj/structure/barricade/handrail/type_nv
	icon_state = "handrail_nv"

/obj/structure/barricade/handrail/type_nv_chain
	icon_state = "handrail_chain_nv"

/obj/structure/flora/tree/jungle/bigtreeBOT/nomac
	icon_state = "bigtreeBOT_nomac"

/obj/structure/bed/chair/dropship/pelican
	name = "pelican seat"
	desc = "A sturdy metal chair with a brace that lowers over your body. Holds you in place during high altitude drops and high-G maneuvers."
	icon = 'icons/halo/obj/objects.dmi'
	icon_state = "pelican_seat"
	var/image/chairbar = null
	buildstacktype = 0
	unslashable = TRUE
	unacidable = TRUE
	buckling_sound = 'sound/effects/metal_close.ogg'

/obj/structure/bed/chair/dropship/pelican/east
	dir = EAST
	buckling_x = 3

/obj/structure/bed/chair/dropship/pelican/west
	dir = WEST
	buckling_x = -3

/obj/structure/bed/chair/dropship/pelican/handle_rotation()
	if(dir == NORTH)
		layer = north_layer
	else
		layer = non_north_layer
	if(buckled_mob)
		buckled_mob.setDir(dir)

/obj/structure/bed/chair/dropship/pelican/Initialize()
	. = ..()
	chairbar = image('icons/halo/obj/objects.dmi', "hotseat_bars")
	chairbar.layer = 4.2

/obj/structure/bed/chair/dropship/pelican/afterbuckle()
	. = ..()
	if(buckled_mob)
		icon_state = initial(icon_state) + "_buckled"
		overlays += chairbar
		if(dir == NORTH)
			buckled_mob.layer = north_layer - 0.1
		else
			buckled_mob.layer = layer + 0.01
	else
		icon_state = initial(icon_state)
		overlays -= chairbar

/obj/structure/bed/chair/dropship/pelican/unbuckle()
	if(buckled_mob && buckled_mob.buckled == src)
		buckled_mob.layer = MOB_LAYER
	return ..()

/obj/structure/machinery/prop/almayer/CICmap/table/horizontal/segment/seven
	icon_state = "h_maptable7"

/obj/structure/machinery/prop/almayer/CICmap/yautja/empty
	name = "covenant globe"
	desc = "A hologram projector designed by the covenant to display worlds."
	icon_state = "globe_empty"
	faction = FACTION_COVENANT

/obj/structure/platform/stone/new_varadero
	name = "raised rock edges"
	desc = "A collection of stones and rocks that provide ample grappling and vaulting opportunity. Indicates a change in elevation. You could probably climb it."
	icon_state = "nv_rock"

/obj/structure/platform/stone/new_varadero/north
	dir = NORTH

/obj/structure/platform/stone/new_varadero/east
	dir = EAST

/obj/structure/platform/stone/new_varadero/west
	dir = WEST

/obj/structure/platform/stone/new_varadero_concrete
	name = "raised concrete edge"
	desc = "A slab of concrete of which is amalgamation of sediments formed tightly into a hard solid surface that is quick, easy, and durable."
	icon_state = "concrete"

/obj/structure/platform/stone/new_varadero_concrete/north
	dir = NORTH

/obj/structure/platform/stone/new_varadero_concrete/east
	dir = EAST

/obj/structure/platform/stone/new_varadero_concrete/west
	dir = WEST

/obj/structure/platform_decoration/stone/new_varadero
	name = "raised rock corner"
	icon_state = "nv_rock_deco"

/obj/structure/platform_decoration/stone/new_varadero/north
	dir = NORTH

/obj/structure/platform_decoration/stone/new_varadero/east
	dir = EAST

/obj/structure/platform_decoration/stone/new_varadero/west
	dir = WEST

/obj/structure/platform_decoration/stone/new_varadero_concrete
	name = "raised concrete corner"
	icon_state = "concrete_corner"

/obj/structure/platform_decoration/stone/new_varadero_concrete/north
	dir = NORTH

/obj/structure/platform_decoration/stone/new_varadero_concrete/east
	dir = EAST

/obj/structure/platform_decoration/stone/new_varadero_concrete/west
	dir = WEST
