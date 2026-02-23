/mob/living/carbon/human/proc/try_enter_nearby_free_cryopod()
	if(istype(loc, /obj/structure/machinery/cryopod))
		return TRUE

	for(var/cardinal in GLOB.cardinals)
		var/turf/adjacent_turf = get_step(src, cardinal)
		if(!adjacent_turf)
			continue

		var/obj/structure/machinery/cryopod/pod = locate(/obj/structure/machinery/cryopod) in adjacent_turf
		if(!pod || pod.occupant)
			continue

		pod.go_in_cryopod(src, silent = TRUE)
		if(loc == pod)
			return TRUE

	return FALSE
