// ========== ВЫЗОВ ==========
/mob/living/carbon/human/Login()
	. = ..()
	if(stat == UNCONSCIOUS && istype(loc, /obj/structure/machinery/cryopod))
		spawn(10)
			play_opening_sequence()
