/obj/item/paper/crumpled/bloody/beast

/obj/item/device/radio/intercom/rasputin
	name = "Rasputin intercom"
	frequency = DS3_FREQ

/obj/structure/sign/banners/clf_flag
	name = "\improper CLF flag"
	icon_state = "clfflag"

/obj/structure/sign/banners/clf_worn
	name = "\improper Worn CLF flag"
	icon_state = "clfflag_worn"

/obj/structure/prop/almayer/liberty/deck_turret
	name = "deck turret"
	icon = 'core_ru/code/stuff/deck_turret.dmi'
	icon_state = "deck_turret"

/obj/structure/window/framed/upp/grey/hull
	not_damageable = TRUE
	not_deconstructable = TRUE
	unslashable = TRUE
	unacidable = TRUE
	health = 1000000

/obj/structure/ladder/multiz/LateInitialize()
	. = ..()
	up = locate(/obj/structure/ladder) in SSmapping.get_turf_above(get_turf(src))
	down = locate(/obj/structure/ladder) in SSmapping.get_turf_below(get_turf(src))
	update_icon()

/obj/structure/stairs/multiz
	var/direction

/obj/structure/stairs/multiz/Initialize(mapload, ...)
	. = ..()
	RegisterSignal(loc, COMSIG_TURF_ENTERED, PROC_REF(on_turf_entered))

/obj/structure/stairs/multiz/Destroy()
	UnregisterSignal(loc, COMSIG_TURF_ENTERED)
	return ..()

/obj/structure/stairs/multiz/proc/on_turf_entered(turf/source, atom/movable/enterer)
	SIGNAL_HANDLER
	if(!ismob(enterer))
		return
	RegisterSignal(enterer, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_premove))
	RegisterSignal(enterer, COMSIG_MOVABLE_MOVED, PROC_REF(on_leave))

/obj/structure/stairs/multiz/proc/on_leave(atom/movable/mover)
	SIGNAL_HANDLER
	if(mover.loc == loc)
		return
	UnregisterSignal(mover, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))

/obj/structure/stairs/multiz/proc/on_premove(atom/movable/mover, atom/new_loc)
	SIGNAL_HANDLER
	if(direction == UP && get_dir(src, new_loc) != dir || direction == DOWN && get_dir(src, new_loc) != REVERSE_DIR(dir))
		return
	var/turf/next_step = get_step(src, direction == UP ? dir : REVERSE_DIR(dir))
	var/turf/destination = direction == UP ? SSmapping.get_turf_above(next_step) : SSmapping.get_turf_below(next_step)
	if(!destination || destination.density)
		return
	if(ismob(mover))
		var/mob/traveler = mover
		traveler.trainteleport(destination)
	else
		mover.forceMove(destination)
	return COMPONENT_CANCEL_MOVE

/obj/structure/stairs/multiz/up
	direction = UP

/obj/structure/stairs/multiz/down
	direction = DOWN

/turf/open_space
	name = "open space"
	icon = 'icons/turf/floors/floors.dmi'
	icon_state = "transparent"
	density = FALSE
	opacity = FALSE
	baseturfs = /turf/open_space

/turf/open_space/Initialize(mapload, ...)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open_space/LateInitialize()
	. = ..()
	var/turf/below = SSmapping.get_turf_below(src)
	if(below)
		vis_contents += below

/turf/open_space/Entered(atom/movable/entered_movable, atom/old_loc)
	. = ..()
	var/turf/below = SSmapping.get_turf_below(src)
	while(istype(below, /turf/open_space))
		below = SSmapping.get_turf_below(below)
	if(below && !below.density)
		entered_movable.forceMove(below)

/turf/closed/void/space

/turf/open/floor/plating/catwalk/lattice
	icon = 'icons/obj/structures/props/smoothlattice.dmi'
	icon_state = "lattice0"

/turf/open/floor/almayer_hull/corner
	icon_state = "blackfull_corner"

/turf/open/floor/almayer_hull/corner/northeast
	dir = NORTHEAST

/turf/open/floor/almayer_hull/corner/northwest
	dir = NORTHWEST

/turf/open/floor/almayer_hull/corner/southeast
	dir = SOUTHEAST

/turf/open/floor/almayer_hull/corner/southwest
	dir = SOUTHWEST

/turf/open/floor/corsat/spiral_liberty
	icon = 'core_ru/code/stuff/turfs.dmi'
	icon_state = "spiral_other"

/turf/open/floor/corsat/spiral_other
	icon = 'core_ru/code/stuff/turfs.dmi'
	icon_state = "spiral_other"

/turf/open/floor/strata/liberty
	icon_state = "floor"
