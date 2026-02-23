/// Пытаемся посадить игрока в свободную соседнюю крио-капсулу.
/proc/ss220_try_put_human_in_free_adjacent_cryopod(mob/living/carbon/human/human)
	if(!istype(human))
		return FALSE

	if(istype(human.loc, /obj/structure/machinery/cryopod))
		return TRUE

	for(var/cardinal in GLOB.cardinals)
		var/turf/adjacent_turf = get_step(human, cardinal)
		if(!adjacent_turf)
			continue

		var/obj/structure/machinery/cryopod/pod = locate(/obj/structure/machinery/cryopod) in adjacent_turf
		if(!pod || pod.occupant)
			continue

		pod.go_in_cryopod(human, silent = TRUE)
		if(human.loc == pod)
			return TRUE

	return FALSE

/// Одинаковая добивка крио-посадки для основного пути экипировки ролей.
/datum/authority/branch/role/proc/equip_role(mob/living/new_mob, datum/job/new_job, late_join)
	. = ..()
	if(!. || !late_join || !ishuman(new_mob))
		return

	var/mob/living/carbon/human/new_human = new_mob
	if(istype(new_human.loc, /obj/structure/machinery/cryopod))
		return

	ss220_try_put_human_in_free_adjacent_cryopod(new_human)

/// Синхронизация поведения со старым путем экипировки.
/datum/job/proc/equip_job(mob/living/M)
	. = ..()
	if(!. || !ishuman(M))
		return

	var/mob/living/carbon/human/human = M
	if(istype(human.loc, /obj/structure/machinery/cryopod))
		return

	ss220_try_put_human_in_free_adjacent_cryopod(human)
