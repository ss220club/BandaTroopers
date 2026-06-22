/// Сортировка записей персонала: по отряду (алфавит), без отряда в конец.
/proc/sort_personnel_records(list/records)
	if(!islist(records) || !length(records))
		return records
	var/list/sorted = list()
	var/list/no_squad = list()
	for(var/datum/round_cinematics_participant_record/record as anything in records)
		if(!istype(record))
			continue
		if(length(record.squad) && record.squad != "НЕИЗВЕСТНО")
			sorted += record
		else
			no_squad += record
	// Сортировка по имени отряда
	sortTim(sorted, /proc/cmp_participant_squad_asc)
	// Без отряда — в конец
	sorted += no_squad
	return sorted

/proc/cmp_participant_squad_asc(datum/round_cinematics_participant_record/a, datum/round_cinematics_participant_record/b)
	return sorttext(a.squad, b.squad)

/proc/round_cinematics_safe_text(value, fallback = "НЕИЗВЕСТНО")
	if(isnull(value) || !length("[value]"))
		return fallback
	return "[value]"

/proc/round_cinematics_html_block(title, body, color = "#33FF33")
	var/list/chunks = list()
	if(length("[title]"))
		chunks += "<div style='color:[color];font-family:[ROUND_CINEMATICS_FONT_STACK];font-size:12pt;font-weight:bold;text-align:center;'>[html_encode(title)]</div>"
	if(length("[body]"))
		chunks += body
	return chunks.Join("<br>")

/proc/round_cinematics_join_lines(list/lines)
	var/list/chunks = list()
	for(var/line in lines)
		chunks += "[line]"
	return chunks.Join("<br>")

/proc/round_cinematics_paginate(list/items, per_page)
	var/list/pages = list()
	if(!islist(items) || !length(items))
		return pages
	per_page = max(1, per_page)
	for(var/index = 1, index <= length(items), index += per_page)
		var/list/page = list()
		for(var/inner = index, inner <= min(index + per_page - 1, length(items)), inner++)
			page += items[inner]
		pages += list(page)
	return pages

/proc/round_cinematics_paygrade_prefix(obj/item/card/id/card)
	if(!istype(card))
		return "Н/Д"
	var/datum/paygrade/paygrade = GLOB.paygrades[card.paygrade]
	return paygrade?.prefix || "Н/Д"

/proc/round_cinematics_human_rank(mob/living/carbon/human/human)
	if(!istype(human))
		return "Н/Д"
	var/obj/item/card/id/card = human.get_idcard()
	return round_cinematics_paygrade_prefix(card)

/proc/round_cinematics_human_role(mob/living/carbon/human/human)
	if(!istype(human))
		return "НЕИЗВЕСТНО"
	var/obj/item/card/id/card = human.get_idcard()
	return round_cinematics_safe_text(card?.assignment || human.job)

/proc/round_cinematics_human_squad(mob/living/carbon/human/human)
	if(!istype(human))
		return "НЕИЗВЕСТНО"
	return round_cinematics_safe_text(human.assigned_squad?.name)

/proc/round_cinematics_human_ship_profile_label(mob/living/carbon/human/human)
	if(!istype(human))
		return "3-й батальон «Banda Troopers»"

	var/list/ship_profile = null
	if(human.faction == FACTION_UNSC)
		ship_profile = GLOB.RoleAuthority?.get_main_ship_display_profile()

	if(ship_profile && ship_profile["label"])
		return "[ship_profile["label"]]"

	switch(human.faction)
		if(FACTION_MARINE)
			if(human.assigned_squad && human.assigned_squad.name == SQUAD_LRRP)
				return "Пожиратели змей"
			return "3-й батальон «Banda Troopers»"
		if(FACTION_UPP)
			return "Красный рассвет"
		if(FACTION_PMC)
			return "АЗУР-15"
		if(FACTION_TWE)
			return "Гамма-отряд"

	return "3-й батальон «Banda Troopers»"

/proc/round_cinematics_human_status(mob/living/carbon/human/human)
	if(!istype(human))
		return "НЕИЗВЕСТНО"
	if(human.stat == DEAD)
		return "ПОГИБ"
	if(human.stat == UNCONSCIOUS || human.sleeping)
		return "РАНЕН"
	return "В СТРОЮ"

/proc/round_cinematics_mob_status_label(mob/living/M)
	if(!istype(M) || QDELETED(M))
		return "missing"
	if(M.stat == DEAD)
		return "dead"
	if(M.stat == UNCONSCIOUS || M.sleeping)
		return "incapacitated"
	return "active"

/proc/round_cinematics_human_death_reason(mob/living/carbon/human/human)
	if(!istype(human) || human.stat != DEAD)
		return "NOT REQUIRED"

	var/datum/cause_data/cause = human.last_damage_data
	var/cause_name = lowertext(cause?.cause_name || "")
	if(!length(cause_name))
		return "UNKNOWN"

	if(findtext(cause_name, "gib") || findtext(cause_name, "explosion") || findtext(cause_name, "blast") || findtext(cause_name, "grenade") || findtext(cause_name, "bomb") || findtext(cause_name, "rocket"))
		return "EXPLOSION"
	if(findtext(cause_name, "burn") || findtext(cause_name, "fire") || findtext(cause_name, "flame") || findtext(cause_name, "plasma") || findtext(cause_name, "heat"))
		return "THERMAL DAMAGE"
	if(findtext(cause_name, "acid") || findtext(cause_name, "xeno") || findtext(cause_name, "alien") || findtext(cause_name, "hugger") || findtext(cause_name, "slash") || findtext(cause_name, "bite") || findtext(cause_name, "stabb") || findtext(cause_name, "rend"))
		return "XENO AGGRESSION"
	if(findtext(cause_name, "bullet") || findtext(cause_name, "shot") || findtext(cause_name, "gun") || findtext(cause_name, "rifle") || findtext(cause_name, "pistol") || findtext(cause_name, "projectile"))
		return "GUNFIRE"
	if(findtext(cause_name, "crush") || findtext(cause_name, "impact") || findtext(cause_name, "fall") || findtext(cause_name, "roadkill") || findtext(cause_name, "smash"))
		return "CRUSHING TRAUMA"

	return uppertext(cause.cause_name)

/proc/round_cinematics_round_finished_label(value)
	// Числовые значения (Whiskey Outpost: 1 = победа морпехов, 2 = поражение)
	if(isnum(value))
		switch(value)
			if(1)
				return "ПОБЕДА ОПЕРАЦИИ"
			if(2)
				return "ПРОВАЛ ОПЕРАЦИИ"
			if(0)
				return "ИСХОД НЕ ПОДТВЕРЖДЁН"
		return "ИСХОД НЕ ОПРЕДЕЛЁН ([value])"

	switch(value)
		if(MODE_INFESTATION_M_MAJOR, MODE_INFESTATION_M_MINOR)
			return "ПОБЕДА ОПЕРАЦИИ"
		if(MODE_INFESTATION_X_MAJOR, MODE_INFESTATION_X_MINOR)
			return "ПРОВАЛ ОПЕРАЦИИ"
		if(MODE_INFESTATION_DRAW_DEATH)
			return "ИСХОД НЕ ПОДТВЕРЖДЁН"
		if(MODE_INFECTION_ZOMBIE_WIN)
			return "ПРОВАЛ ОПЕРАЦИИ"
	return round_cinematics_safe_text(value, "ИСХОД НЕ ОПРЕДЕЛЁН")

/proc/round_cinematics_round_finished_classification(value)
	// Числовые значения (Whiskey Outpost: 1 = победа морпехов, 2 = поражение)
	if(isnum(value))
		switch(value)
			if(1)
				return ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY
			if(2)
				return ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT
			if(0)
				return ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE
		log_debug("round_cinematics: unknown numeric round_finished value: [value]")
		return ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE

	// Строковые значения
	switch(value)
		if(MODE_INFESTATION_M_MAJOR, MODE_INFESTATION_M_MINOR)
			return ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY
		if(MODE_INFESTATION_X_MAJOR, MODE_INFESTATION_X_MINOR)
			return ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT
		if(MODE_INFESTATION_DRAW_DEATH)
			return ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE
		if(MODE_INFECTION_ZOMBIE_WIN)
			return ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT

	// Неизвестные строки (например, xenovsxeno: "The X hive has won.")
	log_debug("round_cinematics: unknown round_finished value: [value]")
	return ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE

/// Возвращает русское display-имя фракции по faction_id.
/proc/round_cinematics_faction_display_name(faction)
	switch(faction)
		if(FACTION_MARINE)
			return "Корпус Морской Пехоты США"
		if(FACTION_UNSC)
			return "Космическое Командование ООН"
		if(FACTION_PMC)
			return "Корпорация Вейланд-Ютани"
		if(FACTION_UPP)
			return "Союз Прогрессивных Народов"
		if(FACTION_TWE)
			return "Империя Трёх Миров"
	return round_cinematics_safe_text(faction, "НЕИЗВЕСТНАЯ ФРАКЦИЯ")
