/obj/structure/closet/secure_closet/marine_personal
	var/need_check_content = TRUE

/obj/structure/closet/secure_closet/marine_personal/spawn_gear()
	. = ..()
	need_check_content = TRUE

/obj/structure/closet/secure_closet/marine_personal/allowed(mob/M)
	if(owner == M.real_name)
		if(need_check_content && ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.assigned_squad)
				var/found_headset = FALSE // На случай если не найдем и надо будет искать еще раз
				for(var/obj/item/device/radio/headset/headset in contents)
					headset.set_frequency(H.assigned_squad.radio_freq)
					found_headset = TRUE
				if(found_headset)
					need_check_content = FALSE
	. = ..()

/obj/item/device/encryptionkey/mcom/alt/squads
	channels = list(RADIO_CHANNEL_COMMAND = TRUE, SQUAD_MARINE_1 = TRUE, SQUAD_MARINE_2 = TRUE, SQUAD_MARINE_3 = TRUE, SQUAD_MARINE_4 = TRUE, SQUAD_MARINE_5 = TRUE, SQUAD_MARINE_CRYO = TRUE)
