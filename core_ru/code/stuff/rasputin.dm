
/turf/closed/shuttle/rasputin
	name = "\improper Rasputin"
	icon = 'core_ru/code/stuff/rasputin.dmi'
	icon_state = "rasputin"

/turf/closed/shuttle/rasputin/transparent
	opacity = FALSE

/obj/structure/shuttle/part/rasputin
	name = "\improper Rasputin"
	icon = 'core_ru/code/stuff/rasputin.dmi'
	icon_state = "rasputin"

/turf/closed/shuttle/rasputin/transparent/window
	icon_state = "97"

/obj/structure/shuttle/part/rasputin/transparent
	opacity = FALSE

/obj/structure/shuttle/part/rasputin/transparent/nose_top_right
	icon_state = "100"

/obj/structure/shuttle/part/rasputin/transparent/nose_center
	icon_state = "101"

/obj/structure/shuttle/part/rasputin/transparent/nose_top_left
	icon_state = "102"

/obj/structure/shuttle/part/rasputin/nose_front_left
	icon_state = "95"

/obj/structure/shuttle/part/rasputin/nose_front_right
	icon_state = "99"

/obj/structure/shuttle/part/rasputin/transparent/right_weapons
	icon_state = "91"

/obj/structure/shuttle/part/rasputin/transparent/right_systems
	icon_state = "90"

/obj/structure/shuttle/part/rasputin/transparent/left_systems
	icon_state = "85"

/obj/structure/shuttle/part/rasputin/transparent/left_weapons
	icon_state = "84"

/obj/structure/shuttle/part/rasputin/transparent/upper_right_wing
	icon_state = "74"

/obj/structure/shuttle/part/rasputin/transparent/middle_right_wing
	icon_state = "70"

/obj/structure/shuttle/part/rasputin/transparent/lower_right_wing
	icon_state = "65"

/obj/structure/shuttle/part/rasputin/transparent/upper_left_wing
	icon_state = "71"

/obj/structure/shuttle/part/rasputin/transparent/middle_left_wing
	icon_state = "66"

/obj/structure/shuttle/part/rasputin/transparent/lower_left_wing
	icon_state = "61"

/obj/structure/shuttle/part/rasputin/lower_left_wall
	icon_state = "46"

/obj/structure/shuttle/part/rasputin/lower_right_wall
	icon_state = "49"

/obj/structure/shuttle/part/rasputin/transparent/engine_left_cap
	icon_state = "40"

/obj/structure/shuttle/part/rasputin/transparent/engine_right_cap
	icon_state = "41"

/obj/structure/shuttle/part/rasputin/transparent/engine_left_exhaust
	icon_state = "16"

/obj/structure/shuttle/part/rasputin/transparent/engine_right_exhaust
	icon_state = "17"

/obj/structure/shuttle/part/rasputin/bottom_left_wall
	icon_state = "9"

/obj/structure/shuttle/part/rasputin/bottom_right_wall
	icon_state = "15"

/obj/structure/shuttle/part/rasputin/left_inner_wing_connector
	icon_state = "7"

/obj/structure/shuttle/part/rasputin/right_inner_wing_connector
	icon_state = "8"

/obj/structure/shuttle/part/rasputin/left_outer_wing_connector
	icon_state = "3"

/obj/structure/shuttle/part/rasputin/right_outer_wing_connector
	icon_state = "4"

/obj/structure/shuttle/part/rasputin/transparent/left_inner_bottom_wing
	icon_state = "1"

/obj/structure/shuttle/part/rasputin/transparent/left_outer_bottom_wing
	icon_state = "2"

/obj/structure/shuttle/part/rasputin/transparent/right_inner_bottom_wing
	icon_state = "5"

/obj/structure/shuttle/part/rasputin/transparent/right_outer_bottom_wing
	icon_state = "6"

/obj/structure/shuttle/part/rasputin/transparent/logo
	icon_state = "rasputin_logo"

/obj/structure/shuttle/part/rasputin/transparent/logo/other_side
	icon_state = "other_rasputin_logo"


/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds3
	name = "\improper Rasputin cargo door"
	icon = 'icons/obj/structures/doors/dropship3_cargo.dmi'

/obj/structure/machinery/door/airlock/dropship_hatch/three
	icon = 'icons/obj/structures/doors/dropship3_side.dmi'
	id = "sh_dropship3"

/obj/structure/machinery/door/airlock/hatch/cockpit/three
	icon = 'icons/obj/structures/doors/dropship3_pilot.dmi'


/area/shuttle/rasputin
	name = "\improper Dropship Rasputin"
	icon_state = "shuttlered"
	base_muffle = MUFFLE_HIGH
	soundscape_interval = 30
	is_landing_zone = TRUE
	ceiling = CEILING_REINFORCED_METAL
	base_lighting_alpha = 0

/area/shuttle/rasputin/Enter(atom/movable/O, atom/oldloc)
	if(istype(O, /obj/structure/barricade))
		return FALSE
	return TRUE


/datum/map_template/shuttle/rasputin
	name = "Rasputin"
	shuttle_id = DROPSHIP_RASPUTIN

/obj/docking_port/mobile/marine_dropship/rasputin
	name = "Rasputin"
	id = DROPSHIP_RASPUTIN
	width = 9
	height = 16

	dwidth = 4
	dheight = 8

/obj/docking_port/stationary/marine_dropship/ss_liberty
	name = "SS Liberty Hangar Bay"
	id = GOLDEN_ARROW_LZ
	auto_open = TRUE
	roundstart_template = /datum/map_template/shuttle/rasputin

/obj/structure/machinery/computer/shuttle/dropship/flight/remote_control/rasputin
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "shuttle"
	shuttleId = DROPSHIP_RASPUTIN
	is_remote = TRUE
	needs_power = TRUE


/obj/effect/attach_point/computer/rasputin
	ship_tag = DROPSHIP_RASPUTIN

/obj/effect/attach_point/electronics/rasputin
	ship_tag = DROPSHIP_RASPUTIN

/obj/effect/attach_point/fuel/rasputin
	ship_tag = DROPSHIP_RASPUTIN

/obj/effect/attach_point/weapon/rasputin
	ship_tag = DROPSHIP_RASPUTIN

/obj/effect/attach_point/crew_weapon/rasputin
	ship_tag = DROPSHIP_RASPUTIN

/obj/item/rappel_harness/extract/rasputin
	shuttle_id = DROPSHIP_RASPUTIN

/obj/effect/attach_point/weapon/rasputin/left_fore
	name = "port fore weapon attach point"
	attach_id = 1
	dir = NORTH
	firing_arc_min = -6
	firing_arc_max =  0
	transverse  =  0
	long    =  0

/obj/effect/attach_point/weapon/rasputin/left_wing
	name = "port wing weapon attach point"
	icon_state = "equip_base_l_wing"
	attach_id = 3
	dir = WEST
	firing_arc_min = -3
	firing_arc_max =  3
	transverse  = -3
	long    =  0

/obj/effect/attach_point/weapon/rasputin/right_fore
	name = "starboard fore weapon attach point"
	attach_id = 2
	dir = NORTH
	firing_arc_min =  0
	firing_arc_max =  6
	transverse  =  0
	long    =  0

/obj/effect/attach_point/weapon/rasputin/right_wing
	name = "starboard wing weapon attach point"
	icon_state = "equip_base_r_wing";
	attach_id = 4
	dir = EAST
	firing_arc_min = -3
	firing_arc_max =  3
	transverse  =  3
	long    =  0


/obj/structure/machinery/camera/autoname/golden_arrow/rasputin
	network = list(CAMERA_NET_GOLDEN_ARROW, CAMERA_NET_RASPUTIN)

/obj/structure/machinery/computer/cameras/dropship/rasputin
	name = "\improper 'Rasputin' camera controls"
	network = list(CAMERA_NET_RASPUTIN, CAMERA_NET_LASER_TARGETS)

/obj/structure/machinery/computer/cameras/dropship/rasputin/update_icon()
	return

/obj/structure/machinery/computer/dropship_weapons/rasputin
	name = "\improper 'Rasputin' weapons controls"
	shuttle_tag = DROPSHIP_RASPUTIN

/obj/structure/machinery/computer/dropship_weapons/rasputin/update_icon()
	return

/obj/structure/machinery/computer/shuttle/dropship/flight/rasputin
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "shuttle"
	linked_lz = DROPSHIP_LZ1
	is_remote = TRUE
	can_change_shuttle = TRUE

/obj/structure/machinery/computer/shuttle/dropship/flight/rasputin/update_icon()
	return
