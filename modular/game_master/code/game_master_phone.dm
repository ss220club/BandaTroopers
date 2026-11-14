/datum/component/phone/virtual/game_master/get_phones()
	. = ..()

	for(var/datum/component/phone/target_phone as anything in GLOB.phones)
		if(!istype(target_phone.holder, /obj/item/storage/backpack/marine/satchel/rto))
			continue

		target_phone.phone_id = target_phone.force_unique_ids(target_phone.phone_id)
		if(!target_phone.phone_available())
			continue

		.[target_phone.phone_id] = target_phone
