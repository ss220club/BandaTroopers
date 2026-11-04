/obj/structure/machinery/computer/shuttle/dropship/flight/rasputin
	shuttleId = DROPSHIP_RASPUTIN
	is_remote = FALSE
	can_change_shuttle = FALSE

/obj/structure/machinery/computer/shuttle/dropship/flight/rasputin/alternative_shuttles()
	return list()

/turf/open/space/transit/dropship/rasputin
	shuttle_tag = DROPSHIP_RASPUTIN
	dir = SOUTH

/obj/docking_port/mobile/marine_dropship/rasputin/get_transit_path_type()
	return /turf/open/space/transit/dropship/rasputin

/obj/structure/machinery/computer/shuttle/dropship/flight/rasputin/small
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "cameras_old"

/obj/structure/machinery/computer/dropship_weapons/rasputin/small
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "cameras"

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds2/rasputin
	name = "\improper Rasputin cargo door"

/obj/structure/machinery/door/airlock/hatch/cockpit/two/rasputin
	name = "\improper Rasputin cockpit hatch"

/turf/closed/shuttle/cyclone/rasputin
	name = "\improper Rasputin"
	color = "#AAB99D"

/turf/closed/shuttle/cyclone/transparent/rasputin
	name = "\improper Rasputin"
	color = "#AAB99D"

/obj/structure/shuttle/part/cyclone/transparent/rasputin
	name = "\improper Rasputin"
	color = "#AAB99D"

/obj/structure/shuttle/part/cyclone/transparent/nosecone/rasputin
	name = "\improper Rasputin"
	color = "#AAB99D"

/obj/structure/shuttle/part/cyclone/gunpod_prop/rasputin
	name = "\improper Rasputin"
	color = "#AAB99D"

/obj/structure/shuttle/part/dropship2/lower_right_wall/rasputin
	name = "\improper Rasputin"
	color = "#AAB99D"

/obj/effect/decal/rasputin_insignia
	icon = 'core_ru/code/stuff/rasputin.dmi'
	icon_state = "rasputin_logo"

/obj/effect/decal/rasputin_insignia/other_side
	icon_state = "other_rasputin_logo"
