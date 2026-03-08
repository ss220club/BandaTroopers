/obj/structure/closet/secure_closet/halo/job_locker
	name = "occupation locker"

/obj/structure/closet/secure_closet/halo/job_locker/squad_leader
	name = "Squad Leader locker"
	desc = "Contains the equipment for a squad leader."
	req_access = list(ACCESS_MARINE_LEADER)

/obj/structure/closet/secure_closet/halo/job_locker/rto
	name = "Radio Telephone Operator locker"
	req_access = list(ACCESS_MARINE_SMARTPREP)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec
	name = "Weapons Specialist locker"
	req_access = list(ACCESS_MARINE_SPECPREP)
	var/claimed = FALSE
	var/role_lock = TRUE

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/togglelock(mob/living/user)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("You do not have access to the contents of the locker."))
		return
	if(claimed)
		return ..()
	if(role_lock && ishuman(user))
		var/mob/living/carbon/human/human = user
		var/obj/item/card/id/card = human.get_idcard()
		if(card)
			if(human.job != "Weapons Specialist")
				to_chat(user, SPAN_WARNING("You aren't the right occupation for this locker."))
				return
			equipment_giver(user)
		else if(!role_lock && ishuman(user))
			equipment_giver(user)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/equipment_giver(mob/living/user)
	var/static/list/spec_equipment_list = list(
		"SPNKr kit" = /obj/item/storage/unsc_speckit/spnkr,
		"SRS-99AM kit" = /obj/item/storage/unsc_speckit/srs99,
	)

	var/chosen_kit = tgui_input_list(user, "Equipment Selection", "Select your equipment", spec_equipment_list)

	if(!chosen_kit)
		to_chat(user, SPAN_WARNING("You decide to think on it."))
		return

	if(claimed)
		to_chat(user, SPAN_WARNING("You already got a kit!"))
		return

	chosen_kit = spec_equipment_list[chosen_kit]
	claimed = TRUE
	new chosen_kit(src)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/ft1
	name = "fireteam one Weapons Specialist locker"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_SQUAD_ONE)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/ft2
	name = "fireteam two Weapons Specialist locker"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_SQUAD_TWO)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader
	name = "Fireteam Leader locker"
	req_access = list(ACCESS_MARINE_TL_PREP)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader/ft1
	name = "fireteam one Fireteam Leader locker"
	req_access = list(ACCESS_MARINE_TL_PREP, ACCESS_SQUAD_ONE)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader/ft2
	name = "fireteam two Fireteam Leader locker"
	req_access = list(ACCESS_MARINE_TL_PREP, ACCESS_SQUAD_TWO)
