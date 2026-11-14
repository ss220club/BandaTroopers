/datum/faction/lasalle_bionational
	name = "Lasalle Bionational"
	faction_tag = FACTION_LASALLE_BIONATIONAL
	base_icon_file = 'icons/mob/hud/factions/lasalle_bionational.dmi'

/datum/faction/lasalle_bionational/modify_hud_holder(image/holder, mob/living/carbon/human/user)
	var/obj/item/card/id/id_card = user.get_idcard()
	var/role = user.mind ? user.job : id_card?.rank
	var/hud_icon_state
	switch(role)
		if(JOB_LB_MERC)
			hud_icon_state = "merc"
		if(JOB_LB_MERC_MEDIC)
			hud_icon_state = "medic"
		if(JOB_LB_MERC_ENGI)
			hud_icon_state = "engi"
		if(JOB_LB_MERC_TL)
			hud_icon_state = "leader"
		if(JOB_LB_MERC_SYN)
			hud_icon_state = "synth"
		if(JOB_LB_MERC_COMMANDER)
			hud_icon_state = "com"
		if(JOB_LB_SEC)
			hud_icon_state = "security"
		if(JOB_LB_CORPORATE_LIAISON)
			hud_icon_state = "liaison"
	if(hud_icon_state)
		holder.overlays += image(base_icon_file, user, "ls_[hud_icon_state]")
