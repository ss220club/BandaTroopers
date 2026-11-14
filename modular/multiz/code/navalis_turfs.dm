/turf/open/floor/almayer/black2
	icon_state = "black2"

/turf/open/floor/almayer/black2/north
	dir = NORTH

/turf/open/floor/almayer/black2/south
	dir = SOUTH

/turf/open/floor/almayer/black2/east
	dir = EAST

/turf/open/floor/almayer/black2/west
	dir = WEST

/turf/open/floor/almayer/black2/northeast
	dir = NORTHEAST

/turf/open/floor/almayer/black2/northwest
	dir = NORTHWEST

/turf/open/floor/almayer/black2/southeast
	dir = SOUTHEAST

/turf/open/floor/almayer/black2/southwest
	dir = SOUTHWEST


/turf/open/floor/almayer/blackfull2
	icon_state = "blackfull2"


/turf/open/floor/almayer/bluefull2
	icon_state = "bluefull2"


/turf/open/floor/almayer/dark_sterile2
	icon_state = "dark_sterile2"


/turf/open/floor/almayer/greenfull2
	icon_state = "greenfull2"


/turf/open/floor/almayer/plating2
	icon_state = "plating2"

/turf/open/floor/almayer/plating2/north
	dir = NORTH

/turf/open/floor/almayer/plating2/south
	dir = SOUTH

/turf/open/floor/almayer/plating2/east
	dir = EAST

/turf/open/floor/almayer/plating2/west
	dir = WEST

/turf/open/floor/almayer/plating2/northeast
	dir = NORTHEAST

/turf/open/floor/almayer/plating2/northwest
	dir = NORTHWEST

/turf/open/floor/almayer/plating2/southeast
	dir = SOUTHEAST

/turf/open/floor/almayer/plating2/southwest
	dir = SOUTHWEST


/turf/open/floor/almayer/plating_striped/northeast
	dir = NORTHEAST


/turf/open/floor/almayer/plating_striped/northwest
	dir = NORTHWEST


/turf/open/floor/almayer/plating_striped/southeast
	dir = SOUTHEAST


/turf/open/floor/almayer/plating_striped/southwest
	dir = SOUTHWEST


/turf/open/floor/almayer/redfull2
	icon_state = "redfull2"


/turf/open/floor/half_plate
	icon = 'icons/turf/half_plate.dmi'
	icon_state = "green_plate"
	plating_type = /turf/open/floor/plating/almayer

/turf/open/floor/half_plate/green
	dir = SOUTH

/turf/open/floor/half_plate/green/north
	dir = NORTH

/turf/open/floor/half_plate/green/east
	dir = EAST

/turf/open/floor/half_plate/green/west
	dir = WEST

/turf/open/floor/half_plate/dark_yellow
	icon_state = "darkyellow_plate"
	dir = SOUTH

/turf/open/floor/half_plate/dark_yellow/north
	dir = NORTH

/turf/open/floor/half_plate/dark_yellow/east
	dir = EAST

/turf/open/floor/half_plate/dark_yellow/west
	dir = WEST


/turf/open/floor/plating/catwalk/grate
	icon = 'icons/obj/structures/props/hybrisa/grates.dmi'
	icon_state = "solidgrate1"


/turf/open/floor/plating/plating_catwalk/prison/dark
	color = "#aba39d"


/turf/open/floor/roof_weedable
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull"
	name = "roof"
	hull_floor = 1
	allow_construction = FALSE

/turf/open/floor/roof_weedable/outerhull_dir
	icon_state = "outerhull_dir"

/turf/open/floor/roof_weedable/outerhull_dir/southwest
	dir = SOUTHWEST

/turf/open/floor/roof_weedable/outerhull_dir/north
	dir = NORTH

/turf/open/floor/roof_weedable/outerhull_dir/east
	dir = EAST

/turf/open/floor/roof_weedable/outerhull_dir/northeast
	dir = NORTHEAST

/turf/open/floor/roof_weedable/outerhull_dir/southeast
	dir = SOUTHEAST

/turf/open/floor/roof_weedable/outerhull_dir/west
	dir = WEST

/turf/open/floor/roof_weedable/outerhull_dir/northwest
	dir = NORTHWEST


/turf/open/gm/empty/navalis
	desc = "The Xenomorphs appear to have emerged from this gaping maw. However, it appears they not only have refused to retreat back in here, they have barricaded it……"

/turf/open/gm/empty/navalis/dig
	desc = "Worse than Xenomorphs lurk the deepest, darkest, pits of this world. These nameless things await in the dark. Pray they don't find this escape."

/turf/open/gm/river/no_overlay/ocean
	name = "ocean"
	icon = 'icons/turf/floors/desert_water.dmi'
	icon_state = "deep"

/turf/open/gm/river/no_overlay/ocean/Entered(atom/movable/AM)
	..()
	if(!isobserver(AM) && !isliving(AM) && istype(AM, /obj/item) && !istype(AM, /obj/item/lightstick))
		addtimer(CALLBACK(src, PROC_REF(enter_depths), AM), 0.2 SECONDS)

/turf/open/gm/river/no_overlay/ocean/proc/enter_depths(atom/movable/AM)
	if(AM.throwing == 0 && istype(get_turf(AM), /turf/open/gm/river/no_overlay/ocean))
		AM.visible_message(SPAN_WARNING("[AM] falls into the depths!"), SPAN_WARNING("You fall into the depths!"))
		qdel(AM)

/turf/open/gm/river/no_overlay/ocean_no_slowdown
	name = "ocean"
	icon = 'icons/turf/floors/desert_water.dmi'
	icon_state = "deep"
	base_river_slowdown = 0

/turf/open/auto_turf/snow/brown_base/layer0/seabed
	name = "seabed"
	desc = "This dirt looks as if it were drudged from the bottom of the ocean..."





/turf/open/floor/plating/catwalk/grate/alt
	icon_state = "solidgrate5"

/turf/open/floor/plating/catwalk/grate/net
	name = "safety net"
	desc = "Special net intended to catch anyone, or anything, that falls off the rig. Difficult to move around in, but preferable to falling into the endless ocean below."
	icon = 'icons/obj/structures/props/ice_colony/props.dmi'
	icon_state = "soil_grid"
	allow_construction = FALSE
	var/slow_amt = 4

/turf/open/floor/plating/catwalk/grate/net/is_weedable()
	return NOT_WEEDABLE

/turf/open/floor/plating/catwalk/grate/net/Entered(atom/movable/AM)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		var/slow_amount = 0.75
		var/can_stuck = 1
		if(istype(C, /mob/living/carbon/xenomorph)||isyautja(C))
			slow_amount = 0.5
			can_stuck = 0
		var/new_slowdown = C.next_move_slowdown + slow_amount
		if(prob(2))
			to_chat(C, SPAN_WARNING("Moving through the [src] slows you down."))
		else if(can_stuck == 4 && prob(2))
			to_chat(C, SPAN_WARNING("You get stuck in the [src] for a moment!"))
			new_slowdown += 10
		C.next_move_slowdown = new_slowdown
	..()

/turf/open/floor/plating/catwalk/grate/lattice
	icon = 'icons/obj/structures/props/hybrisa/piping_wiring.dmi'
	icon_state = "latticefull"

/turf/open/floor/plating/catwalk/grate/lattice/is_weedable()
	return NOT_WEEDABLE



/turf/open/floor/roof_weedable
