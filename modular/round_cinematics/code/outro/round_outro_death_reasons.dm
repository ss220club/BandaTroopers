/// Перевод причин смерти на русский язык для round outro report.
/proc/round_cinematics_human_death_reason_ru(mob/living/carbon/human/human)
	if(!istype(human) || human.stat != DEAD)
		return "НЕ ТРЕБУЕТСЯ"

	var/raw = round_cinematics_human_death_reason(human)
	switch(raw)
		if("GUNFIRE")
			return "ОГНЕСТРЕЛЬНОЕ РАНЕНИЕ"
		if("EXPLOSION")
			return "ВЗРЫВНАЯ ТРАВМА"
		if("THERMAL DAMAGE")
			return "ТЕРМИЧЕСКОЕ ПОРАЖЕНИЕ"
		if("XENO AGGRESSION")
			return "КСЕНОУГРОЗА"
		if("CRUSHING TRAUMA")
			return "ТРАВМА ОТ УДАРА/СДАВЛИВАНИЯ"
		if("NOT REQUIRED")
			return "НЕ ТРЕБУЕТСЯ"
		if("UNKNOWN")
			return "ПРИЧИНА НЕ УСТАНОВЛЕНА"
		else
			return "ПРИЧИНА НЕ УСТАНОВЛЕНА"

/// Расширенная классификация причин смерти с категорией FRIENDLY FIRE.
/proc/round_cinematics_human_death_reason_extended(mob/living/carbon/human/human)
	if(!istype(human) || human.stat != DEAD)
		return "NOT REQUIRED"

	var/datum/cause_data/cause = human.last_damage_data
	var/cause_name = lowertext(cause?.cause_name || "")
	if(!length(cause_name))
		return "UNKNOWN"

	// Проверка friendly fire: если атакующий — той же фракции
	if(cause?.resolve_mob())
		var/mob/attacker = cause.resolve_mob()
		if(istype(attacker) && attacker.faction == human.faction)
			return "FRIENDLY FIRE"

	// Стандартная классификация
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

	return "UNKNOWN"

/// Перевод расширенной причины смерти на русский.
/proc/round_cinematics_human_death_reason_extended_ru(mob/living/carbon/human/human)
	var/raw = round_cinematics_human_death_reason_extended(human)
	switch(raw)
		if("GUNFIRE")
			return "ОГНЕСТРЕЛЬНОЕ РАНЕНИЕ"
		if("EXPLOSION")
			return "ВЗРЫВНАЯ ТРАВМА"
		if("THERMAL DAMAGE")
			return "ТЕРМИЧЕСКОЕ ПОРАЖЕНИЕ"
		if("XENO AGGRESSION")
			return "КСЕНОУГРОЗА"
		if("CRUSHING TRAUMA")
			return "ТРАВМА ОТ УДАРА/СДАВЛИВАНИЯ"
		if("FRIENDLY FIRE")
			return "ДРУЖЕСТВЕННЫЙ ОГОНЬ"
		if("NOT REQUIRED")
			return "НЕ ТРЕБУЕТСЯ"
		if("UNKNOWN")
			return "ПРИЧИНА НЕ УСТАНОВЛЕНА"
		else
			return "ПРИЧИНА НЕ УСТАНОВЛЕНА"
