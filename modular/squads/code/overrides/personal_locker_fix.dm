/mob/living/carbon/human
	/// Временный флаг latejoin, чтобы do_vanity корректно выбрал шкафчик.
	var/ss220_late_join_for_vanity = FALSE

/// Прокидываем контекст latejoin в do_vanity без правки хардкода.
/datum/equipment_preset/proc/load_preset(mob/living/carbon/human/new_human, randomise = FALSE, count_participant = FALSE, client/mob_client, show_job_gear = TRUE, late_join)
	if(istype(new_human))
		new_human.ss220_late_join_for_vanity = !!late_join
	. = ..()

/// Используем модульный latejoin-флаг для выдачи личного шкафчика.
/datum/equipment_preset/proc/do_vanity(mob/living/carbon/human/new_human, client/mob_client)
	var/late_join = FALSE
	if(istype(new_human))
		late_join = new_human.ss220_late_join_for_vanity
		new_human.ss220_late_join_for_vanity = FALSE

	var/turf/T = get_turf(new_human)
	if(!T)
		return

	if(is_mainship_level(T.z))
		spawn_vanity_in_personal_lockers(new_human, mob_client, late_join)
	else
		load_vanity(new_human, mob_client)

	EquipCustomItems(new_human)

/datum/equipment_preset/proc/ss220_is_abandoned_personal_locker(obj/structure/closet/secure_closet/marine_personal/closet)
	if(!closet?.owner)
		return FALSE

	for(var/mob/living/carbon/human/living_human as anything in GLOB.alive_human_list)
		if(living_human.real_name == closet.owner)
			return FALSE

	return TRUE

/datum/equipment_preset/proc/ss220_personal_locker_matches_player(obj/structure/closet/secure_closet/marine_personal/closet, mob/living/carbon/human/new_human)
	if(!closet || !new_human)
		return FALSE

	var/turf/human_turf = get_turf(new_human)
	if(closet.linked_spawn_turf)
		if(human_turf != closet.linked_spawn_turf)
			return FALSE
	else if(new_human.job != closet.job)
		return FALSE

	// Не ломаем распределение по отрядам.
	if(!closet.is_correct_squad(new_human))
		return FALSE

	return TRUE

/datum/equipment_preset/proc/ss220_reset_reclaimed_personal_locker(obj/structure/closet/secure_closet/marine_personal/closet)
	if(!closet)
		return

	// Закрываем шкаф вручную, чтобы не втягивать предметы с пола через close().
	if(closet.opened)
		closet.opened = FALSE
		closet.density = TRUE

	closet.welded = FALSE

	// Чистим только внутреннее содержимое шкафа.
	for(var/atom/movable/movable as anything in closet.contents)
		if(ismob(movable))
			movable.forceMove(get_turf(closet))
			continue
		qdel(movable)

	closet.broken = FALSE
	closet.locked = TRUE
	closet.update_icon()
	closet.spawn_gear()

/// Расширение сигнатуры нужно для latejoin-переиспользования шкафчика.
/datum/equipment_preset/proc/spawn_vanity_in_personal_lockers(mob/living/carbon/human/new_human, client/mob_client, late_join = FALSE)
	var/obj/structure/closet/secure_closet/marine_personal/closet_to_spawn_in
	var/obj/structure/closet/secure_closet/marine_personal/reclaimed_closet

	for(var/obj/structure/closet/secure_closet/marine_personal/closet in GLOB.personal_closets)
		if(!ss220_personal_locker_matches_player(closet, new_human))
			continue

		if(!closet.owner)
			closet_to_spawn_in = closet
			break

		if(late_join && !reclaimed_closet && ss220_is_abandoned_personal_locker(closet))
			reclaimed_closet = closet

	if(!closet_to_spawn_in && late_join)
		closet_to_spawn_in = reclaimed_closet

	if(!closet_to_spawn_in)
		load_vanity(new_human, mob_client)
		return

	if(closet_to_spawn_in.owner)
		ss220_reset_reclaimed_personal_locker(closet_to_spawn_in)

	closet_to_spawn_in.owner = new_human.real_name
	closet_to_spawn_in.name = "личный шкафчик [closet_to_spawn_in.owner]" // SS220 EDIT

	var/list/selected_gear = new_human?.client?.prefs?.gear
	for(var/gear_name in selected_gear)
		var/datum/gear/current_gear = GLOB.gear_datums_by_name[gear_name]
		if(current_gear)
			if(current_gear.allowed_roles && !(assignment in current_gear.allowed_roles))
				to_chat(new_human, SPAN_WARNING("Custom gear [current_gear.display_name] cannot be equipped: Invalid Role"))
				return
			if(current_gear.allowed_origins && !(new_human.origin in current_gear.allowed_origins))
				to_chat(new_human, SPAN_WARNING("Custom gear [current_gear.display_name] cannot be equipped: Invalid Origin"))
				return
			if(!current_gear.special_conditions())
				to_chat(new_human, SPAN_WARNING("Custom gear [current_gear.display_name] cannot be equipped: Special conditions not met."))
				return
			new current_gear.path(closet_to_spawn_in)

	// Выдаем погоны в шкафчик.
	var/current_rank = paygrades[1]
	var/obj/item/card/id/I = new_human.get_idcard()
	if(I)
		current_rank = I.paygrade
	if(current_rank)
		var/rankpath = get_rank_pins(current_rank)
		if(rankpath)
			new rankpath(closet_to_spawn_in)

	if(flags & EQUIPMENT_PRESET_MARINE && new_human?.client)
		var/playtime = get_job_playtime(new_human.client, assignment)
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

		if(!new_human.client.prefs.playtime_perks)
			medal_type = null

		if(medal_type)
			var/obj/item/clothing/accessory/medal/medal = new medal_type(closet_to_spawn_in)
			medal.recipient_name = new_human.real_name
			medal.recipient_rank = current_rank

	// Очки для близоруких тоже кладем в шкафчик.
	if(new_human.disabilities & NEARSIGHTED)
		new /obj/item/clothing/glasses/regular(closet_to_spawn_in)

	if(new_human?.client?.player_data?.id)
		for(var/datum/view_record/medal_view/medal as anything in DB_VIEW(/datum/view_record/medal_view, DB_COMP("player_id", DB_EQUALS, new_human.client.player_data.id)))
			if(!medal)
				return
			if(medal.recipient_name != new_human.real_name)
				continue
			if(medal.recipient_role != new_human.job)
				continue

			var/obj/item/clothing/accessory/medal/given_medal
			switch(medal.medal_type)
				if(MARINE_CONDUCT_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/bronze/conduct(closet_to_spawn_in)
				if(MARINE_BRONZE_HEART_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/bronze/heart(closet_to_spawn_in)
				if(MARINE_VALOR_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/silver/valor(closet_to_spawn_in)
				if(MARINE_HEROISM_MEDAL)
					given_medal = new /obj/item/clothing/accessory/medal/gold/heroism(closet_to_spawn_in)
				else
					return FALSE

			given_medal.recipient_name = medal.recipient_name
			given_medal.recipient_rank = medal.recipient_role
			given_medal.medal_citation = medal.citation
