/mob/living/carbon/human
	var/tmp/personal_locker_spawn_context = null

/mob/living/carbon/human/proc/mark_personal_locker_spawn_context(late_join = FALSE)
	personal_locker_spawn_context = late_join ? "latejoin" : "roundstart"

/mob/living/carbon/human/proc/clear_personal_locker_spawn_context()
	personal_locker_spawn_context = null

/mob/living/carbon/human/proc/consume_personal_locker_spawn_context()
	. = personal_locker_spawn_context
	personal_locker_spawn_context = null

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

/datum/equipment_preset/proc/log_personal_locker_spawn_miss(mob/living/carbon/human/new_human, late_join = FALSE)
	if(!new_human)
		return

	var/turf/current_turf = get_turf(new_human)
	var/area/current_area = get_area(new_human)
	var/mob_ckey = new_human.client?.ckey
	if(!mob_ckey && new_human.key)
		mob_ckey = ckey(new_human.key)
	if(!mob_ckey)
		mob_ckey = "NO_CKEY"
	var/real_name = new_human.real_name || "UNKNOWN"
	var/job_title = new_human.job || assignment || "UNKNOWN"
	var/squad_name = new_human.assigned_squad ? new_human.assigned_squad.name : "NONE"
	var/area_text = current_area ? "[current_area]" : "null area"
	var/coords_text = current_turf ? "([current_turf.x],[current_turf.y],[current_turf.z])" : "(no turf)"
	var/late_join_text = late_join ? "TRUE" : "FALSE"
	var/jump_text = current_turf ? " [ADMIN_JMP(current_turf)]" : ""

	log_game("PERSONAL LOCKER MISS: player=[key_name(new_human)] ckey=[mob_ckey] real_name=[real_name] job=[job_title] squad=[squad_name] late_join=[late_join_text] location=[area_text] [coords_text].")
	message_admins("[key_name_admin(new_human)] spawned without a usable personal locker; loadout fallback used. ckey=[mob_ckey]; real_name=[real_name]; job=[job_title]; squad=[squad_name]; late_join=[late_join_text]; location=[area_text] [coords_text].[jump_text]")

/datum/equipment_preset/proc/try_handle_personal_locker_vanity(mob/living/carbon/human/new_human, client/mob_client, late_join = FALSE)
	if(!new_human)
		squads_debug_log("try_handle_personal_locker_vanity called with null human.")
		return FALSE

	var/spawn_context = new_human.consume_personal_locker_spawn_context()
	var/should_log_spawn_miss = spawn_context != null
	var/obj/structure/closet/secure_closet/marine_personal/locker = find_personal_locker_for_player(new_human, late_join)
	if(!locker)
		squads_debug_log("[new_human] no personal locker found, fallback to load_vanity().")
		if(should_log_spawn_miss)
			log_personal_locker_spawn_miss(new_human, spawn_context == "latejoin")
		load_vanity(new_human, mob_client)
		return TRUE

	if(locker.owner)
		squads_debug_log("[new_human] reinitializing reclaimed locker [locker] with owner [locker.owner].")
		locker.reinitialize_for_personal_locker_reuse()
	else if(locker.has_cryo_gear && !length(locker.contents))
		squads_debug_log("[new_human] matched empty locker [locker], restoring baseline spawn gear before claim.")
		locker.spawn_gear()

	locker.owner = new_human.real_name
	locker.name = "личный шкафчик [locker.owner]"
	squads_debug_log("[new_human] assigned personal locker [locker].")

	populate_personal_locker_contents(locker, new_human, mob_client)
	return TRUE
