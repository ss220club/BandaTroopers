/datum/equipment_preset/proc/collect_alive_human_names()
	var/list/alive_human_names = list()

	for(var/mob/living/carbon/human/living_human as anything in GLOB.alive_human_list)
		if(!living_human?.real_name)
			continue
		alive_human_names[living_human.real_name] = TRUE

	return alive_human_names

/datum/equipment_preset/proc/collect_active_human_names()
	var/list/active_human_names = list()

	for(var/mob/living/carbon/human/human as anything in GLOB.human_mob_list)
		if(!human?.real_name || !human.client)
			continue
		active_human_names[human.real_name] = TRUE

	squads_debug_log("Collected active human names for locker reclaim: [length(active_human_names)].")
	return active_human_names

/datum/equipment_preset/proc/find_personal_locker_for_player(mob/living/carbon/human/new_human, late_join = FALSE)
	if(!new_human)
		squads_debug_log("find_personal_locker_for_player called with null human.")
		return null

	var/obj/structure/closet/secure_closet/marine_personal/reclaimed_locker
	var/list/active_human_names = late_join ? collect_active_human_names() : null

	for(var/obj/structure/closet/secure_closet/marine_personal/locker in GLOB.personal_closets)
		if(!locker.matches_player_for_personal_locker(new_human))
			continue

		if(!locker.owner)
			squads_debug_log("[new_human] locker match found: free locker [locker], late_join=[late_join].")
			return locker

		if(late_join && !reclaimed_locker && locker.is_abandoned_for_personal_locker(active_human_names))
			squads_debug_log("[new_human] locker candidate for reclaim: [locker], owner=[locker.owner].")
			reclaimed_locker = locker

	if(late_join && reclaimed_locker)
		squads_debug_log("[new_human] using reclaimed locker [reclaimed_locker].")
	if(!reclaimed_locker)
		squads_debug_log("[new_human] no locker matched for late_join=[late_join].")
	return late_join ? reclaimed_locker : null

/datum/equipment_preset/proc/populate_personal_locker_contents(obj/structure/closet/secure_closet/marine_personal/locker, mob/living/carbon/human/new_human, client/mob_client)
	if(!locker || !new_human)
		return

	var/client/real_client = mob_client || new_human.client
	var/list/selected_gear = real_client?.prefs?.gear

	for(var/gear_name in selected_gear)
		var/datum/gear/current_gear = GLOB.gear_datums_by_name[gear_name]
		if(!current_gear)
			continue
		if(current_gear.allowed_roles && !(assignment in current_gear.allowed_roles))
			to_chat(new_human, SPAN_WARNING("Custom gear [current_gear.display_name] cannot be equipped: Invalid Role"))
			continue
		if(current_gear.allowed_origins && !(new_human.origin in current_gear.allowed_origins))
			to_chat(new_human, SPAN_WARNING("Custom gear [current_gear.display_name] cannot be equipped: Invalid Origin"))
			continue
		if(!current_gear.special_conditions())
			to_chat(new_human, SPAN_WARNING("Custom gear [current_gear.display_name] cannot be equipped: Special conditions not met."))
			continue
		new current_gear.path(locker)

	// Выдаем погоны в шкафчик.
	var/current_rank = paygrades[1]
	var/obj/item/card/id/I = new_human.get_idcard()
	if(I)
		current_rank = I.paygrade
	if(current_rank)
		var/rankpath = get_rank_pins(current_rank)
		if(rankpath)
			new rankpath(locker)

	if(flags & EQUIPMENT_PRESET_MARINE && real_client)
		var/playtime = get_job_playtime(real_client, assignment)
		var/medal_type

		switch(playtime)
			if(JOB_PLAYTIME_TIER_1 to JOB_PLAYTIME_TIER_2)
				medal_type = /obj/item/clothing/accessory/medal/bronze/service
			if(JOB_PLAYTIME_TIER_2 to JOB_PLAYTIME_TIER_3)
				medal_type = /obj/item/clothing/accessory/medal/silver/service
			if(JOB_PLAYTIME_TIER_3 to JOB_PLAYTIME_TIER_4)
				medal_type = /obj/item/clothing/accessory/medal/gold/service
			if(JOB_PLAYTIME_TIER_4 to INFINITY)
				medal_type = /obj/item/clothing/accessory/medal/platinum/service

		if(!real_client.prefs.playtime_perks)
			medal_type = null

		if(medal_type)
			var/obj/item/clothing/accessory/medal/medal = new medal_type(locker)
			medal.recipient_name = new_human.real_name
			medal.recipient_rank = current_rank

	// Очки для близоруких тоже кладем в шкафчик.
	if(new_human.disabilities & NEARSIGHTED)
		new /obj/item/clothing/glasses/regular(locker)

	if(real_client?.player_data?.id)
		for(var/datum/view_record/medal_view/medal as anything in DB_VIEW(/datum/view_record/medal_view, DB_COMP("player_id", DB_EQUALS, real_client.player_data.id)))
			if(!medal)
				continue
			if(medal.recipient_name != new_human.real_name)
				continue
			if(medal.recipient_role != new_human.job)
				continue

			var/obj/item/clothing/accessory/medal/given_medal
			switch(medal.medal_type)
				if(MARINE_CONDUCT_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/bronze/conduct(locker)
				if(MARINE_BRONZE_HEART_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/bronze/heart(locker)
				if(MARINE_VALOR_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/silver/valor(locker)
				if(MARINE_HEROISM_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/gold/heroism(locker)
				else
					continue

			given_medal.recipient_name = medal.recipient_name
			given_medal.recipient_rank = medal.recipient_role
			given_medal.medal_citation = medal.citation

/datum/equipment_preset/proc/try_handle_personal_locker_vanity(mob/living/carbon/human/new_human, client/mob_client, late_join = FALSE)
	if(!new_human)
		squads_debug_log("try_handle_personal_locker_vanity called with null human.")
		return FALSE

	var/obj/structure/closet/secure_closet/marine_personal/locker = find_personal_locker_for_player(new_human, late_join)
	if(!locker)
		squads_debug_log("[new_human] no personal locker found, fallback to load_vanity().")
		load_vanity(new_human, mob_client)
		return TRUE

	if(locker.owner)
		squads_debug_log("[new_human] reinitializing reclaimed locker [locker] with owner [locker.owner].")
		locker.reinitialize_for_personal_locker_reuse()

	locker.owner = new_human.real_name
	locker.name = "личный шкафчик [locker.owner]"
	squads_debug_log("[new_human] assigned personal locker [locker].")

	populate_personal_locker_contents(locker, new_human, mob_client)
	return TRUE
