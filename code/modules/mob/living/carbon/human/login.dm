/mob/living/carbon/human/Login()
	..()
	if(client)
		src.handle_cryo_intro()
