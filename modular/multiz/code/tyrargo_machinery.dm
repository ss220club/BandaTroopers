/obj/structure/machinery/dispersal_initiator/floodgate
	id = "floodgate"

/obj/structure/machinery/dispersal_initiator/floodgate/proc/initiate_floodgate(drain = FALSE)
	sleep(30)
	for(var/obj/effect/blocker/water/W in get_turf(src))
		W.disperse_spread(drain = drain)

/obj/structure/machinery/filtration_button/floodgate
	id = "floodgate"
	icon = 'icons/obj/structures/props/stationobjs.dmi'
	icon_state = "big_red_button_wallv"

/obj/structure/machinery/filtration_button/floodgate/power_change(area/master_area)
	. = ..()
	if(inoperable())
		drain()

/obj/structure/machinery/filtration_button/floodgate/proc/drain()
	for(var/obj/structure/machinery/dispersal_initiator/floodgate/M in GLOB.machines)
		M.initiate_floodgate(TRUE)

/obj/structure/machinery/filtration_button/floodgate/attack_hand(mob/user as mob)
	if(inoperable() || active)
		return
	use_power(5)
	active = TRUE
	icon_state = "big_red_button_wallv1"
	for(var/obj/structure/machinery/dispersal_initiator/floodgate/M in GLOB.machines)
		M.initiate_floodgate()
	marine_announcement("Alert: Tyrargo sewer release valve triggered: Imminent flooding of sewer lines.")
	xeno_announcement("The hosts have triggered the release of a flood of water in to the sewers underneath this battleground. Be wary of the loss our ability to weed the sewer tunnels.")
	sleep(50)
	icon_state = "big_red_button_wallv-p"
	active = FALSE

/obj/effect/mist/steam
	name = "steam"
	icon_state = "steam"

/obj/item/ammo_magazine/flamer_tank/survivor
	name = "improvised flamer tank"
	desc = "A repurposed tank from heavy welding equipment, holding a flammable mix similar to napalm."
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/colony.dmi'
	icon_state = "flamer_fuel"

/obj/item/ammo_magazine/flamer_tank/survivor/empty
	flamer_chem = null

/obj/structure/machinery/light/dropship
	use_power = USE_POWER_IDLE
	active_power_usage = 0
	brightness = 8

/obj/structure/machinery/light/dropship/has_power()
	return TRUE

/obj/structure/machinery/light/dropship/set_pixel_location()
	pixel_x = pixel_y = 0

/obj/structure/machinery/light/dropship/blue
	icon_state = "btube1"
	base_state = "btube"
	desc = "A lighting fixture used by aircraft vehicles. Its glass covering is a bright, fluorescent blue."
	light_color = LIGHT_COLOR_BLUE

/turf/open/shuttle/escapepod/floor1/west
	dir = WEST

/turf/open/shuttle/escapepod/floor3
	icon_state = "floor3"

/turf/open/shuttle/escapepod/floor3/north
	dir = NORTH
