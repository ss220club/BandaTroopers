/obj/item/ammo_magazine/sentry/premade/lowammo
	max_rounds = 500
	current_rounds = 500

/obj/structure/bed/nest/kseries
	color = "#ffff80"
	hivenumber = XENO_HIVE_K_SERIES

/turf/closed/wall/resin/kseries
	color = "#ffff80"
	hivenumber = XENO_HIVE_K_SERIES

/obj/structure/blocker/door
	name = "shutter"
	desc = "Containment shutter. Used during routine testing to reduce the risk of a containment breach."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shutter"
	opacity = TRUE

/obj/structure/blocker/door/Initialize(mapload, time_to_dispel)
	. = ..()
	if(!time_to_dispel)
		return INITIALIZE_HINT_QDEL
	dir = pick(CARDINAL_DIRS)
	QDEL_IN(src, time_to_dispel)

/obj/structure/blocker/door/attack_hand(mob/M)
	to_chat(M, SPAN_NOTICE("Won't budge, you'll have to wait until the all-clear is sent."))

/obj/structure/blocker/door/attack_alien(M)
	attack_hand(M)
	return XENO_NONCOMBAT_ACTION

/datum/hive_status/kseries
	name = "K-Series Hive"
	reporting_id = "k-series"
	hivenumber = XENO_HIVE_K_SERIES
	prefix = "K-Series "
	color = "#ffff80"
	ui_color = "#99994d"
	latejoin_burrowed = FALSE
	dynamic_evolution = FALSE

/obj/effect/landmark/xeno_spawn
	var/species
