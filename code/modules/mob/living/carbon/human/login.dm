// ========== ВЫЗОВ С ЗАДЕРЖКОЙ ==========
/mob/living/carbon/human/Login()
	. = ..()
	if(stat == UNCONSCIOUS)
		// ВАЖНО: Ждём 5 секунд, пока SSticker назначит отряды!
		spawn(5 SECONDS)
			play_opening_sequence()
