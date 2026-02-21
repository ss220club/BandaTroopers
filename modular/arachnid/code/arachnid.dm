/mob/living/carbon/xenomorph
	/// Переменная для проверки кастомных значений под арахнидов
	var/is_arachnid = FALSE

/mob/living/carbon/xenomorph/arachnid
	is_arachnid = TRUE

/mob/living/carbon/xenomorph/arachnid/spawn_gibs()
	agibs(get_turf(src))

/mob/living/carbon/xenomorph/arachnid/death(cause, gibbed)
	. = ..()

// Кастомные останки
/mob/living/carbon/xenomorph/proc/get_custom_remains_icon()
	return 'modular/arachnid/icons/effects/arachnid_blood.dmi'

/mob/living/carbon/xenomorph/proc/get_custom_remains_icon_state()
	return pick("amess1", "amess2", "amess3", "amess4", "amess5", "amess6", "amess7", "amess8")

