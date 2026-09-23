/datum/round_cinematics_outcome_input
	/// The game mode datum for context
	var/datum/game_mode/mode
	/// Explicit result string (e.g. from mode.round_finished)
	var/explicit_result
	/// Admin override outcome id (if set)
	var/admin_override
	/// Source description for logging
	var/source = "unknown"

/datum/round_cinematics_outcome_input/New(datum/game_mode/mode, explicit_result = null, admin_override = null, source = "unknown")
	..()
	src.mode = mode
	src.explicit_result = explicit_result
	src.admin_override = admin_override
	src.source = source

/datum/round_cinematics_outcome
	var/id = ROUND_CINEMATICS_OUTCOME_AUTO
	var/title = "АВТООПРЕДЕЛЕНИЕ"
	var/detail = "ИСХОД НЕ ПОДТВЕРЖДЁН"
	var/raw_result = null
	var/classification = ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE
	var/is_override = FALSE
	/// Цвет заголовка (header) аутро
	var/header_color = "#88CCFF"
	/// Цвет акцента / текста
	var/accent_color = "#DCE6F6"
	/// Интенсивность glitch-эффекта (0-1)
	var/glitch_intensity = 0
	/// Фраза под итогом
	var/outcome_phrase = ""

/datum/round_cinematics_outcome/New(id = ROUND_CINEMATICS_OUTCOME_AUTO, is_override = FALSE)
	..()
	src.id = id
	src.is_override = is_override
	switch(id)
		if(ROUND_CINEMATICS_OUTCOME_AUTO)
			title = "АВТООПРЕДЕЛЕНИЕ"
			detail = "АВТОМАТИЧЕСКОЕ ОПРЕДЕЛЕНИЕ ИСХОДА"
			classification = ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE
		if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
			title = "ПОБЕДА ОПЕРАЦИИ"
			detail = "ОПЕРАТИВНЫЙ КОНТРОЛЬ СОХРАНЁН"
			classification = ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY
		if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
			title = "ПРОВАЛ ОПЕРАЦИИ"
			detail = "ОПЕРАТИВНЫЙ КОНТРОЛЬ УТРАЧЕН"
			classification = ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT
		if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
			title = "ИСХОД НЕ ПОДТВЕРЖДЁН"
			detail = "КОМАНДОВАНИЕ НЕ ПОЛУЧИЛО ПОЛНЫХ ДАННЫХ"
			classification = ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE
	apply_outcome_profile()

/datum/round_cinematics_outcome/proc/apply_outcome_profile()
	switch(id)
		if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
			header_color = "#44FF44"
			accent_color = "#AAFFAA"
			glitch_intensity = 0.05
			outcome_phrase = "ОТЧЁТ ПЕРЕДАН В ШТАБ. СТАТУС КАНАЛА: ЗАВЕРШЕНО."
		if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
			header_color = "#FF4444"
			accent_color = "#FFAAAA"
			glitch_intensity = 0.4
			outcome_phrase = "ПОСЛЕДНИЙ ПАКЕТ ДАННЫХ ПЕРЕДАН. СТАТУС КАНАЛА: АВАРИЙНОЕ ЗАВЕРШЕНИЕ."
		if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
			header_color = "#FFAA44"
			accent_color = "#FFDDAA"
			glitch_intensity = 0.15
			outcome_phrase = "ОТЧЁТ СОХРАНЁН. СТАТУС КАНАЛА: ОЖИДАНИЕ ПОДТВЕРЖДЕНИЯ."
		else
			header_color = "#88CCFF"
			accent_color = "#DCE6F6"
			glitch_intensity = 0
			outcome_phrase = "КОНЕЦ ПЕРЕДАЧИ."

/datum/round_cinematics_outcome/proc/copy()
	var/datum/round_cinematics_outcome/clone = new(id, is_override)
	clone.title = title
	clone.detail = detail
	clone.raw_result = raw_result
	clone.classification = classification
	clone.header_color = header_color
	clone.accent_color = accent_color
	clone.glitch_intensity = glitch_intensity
	clone.outcome_phrase = outcome_phrase
	return clone

/proc/round_cinematics_outcome_from_mode_result(result)
	var/classification_id = round_cinematics_round_finished_classification(result)
	var/datum/round_cinematics_outcome/outcome = new(classification_id, FALSE)
	outcome.raw_result = result
	outcome.title = round_cinematics_round_finished_label(result)
	// detail выставляется по classification_id, а не из raw result
	switch(classification_id)
		if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
			outcome.detail = "СОЮЗНЫЕ СИЛЫ СОХРАНИЛИ ОПЕРАТИВНЫЙ КОНТРОЛЬ"
		if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
			outcome.detail = "СОЮЗНЫЕ СИЛЫ УТРАТИЛИ ОПЕРАТИВНЫЙ КОНТРОЛЬ"
		if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
			outcome.detail = "КОМАНДОВАНИЕ НЕ ПОЛУЧИЛО ДОСТАТОЧНО ДАННЫХ"
		else
			outcome.detail = "ИСХОД НЕ ПОДТВЕРЖДЁН"
	outcome.classification = classification_id
	outcome.apply_outcome_profile()
	return outcome

/proc/resolve_round_outcome(datum/game_mode/mode)
	if(!mode)
		return new /datum/round_cinematics_outcome(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE, FALSE)

	// Huntergames: check mode.finished (1 = victory, 2 = defeat)
	if(istype(mode, /datum/game_mode/huntergames))
		var/datum/game_mode/huntergames/hg = mode
		if(hg.finished == 1)
			return round_cinematics_outcome_from_mode_result(1)
		if(hg.finished == 2)
			return round_cinematics_outcome_from_mode_result(2)
		// fall through to round_finished

	// Whiskey Outpost: check round_statistics.round_result
	if(istype(mode, /datum/game_mode/whiskey_outpost))
		if(GLOB.round_statistics?.round_result)
			var/wo_result = GLOB.round_statistics.round_result
			log_debug("round_cinematics: WO round_result=[wo_result]")
			if(wo_result == 1)
				return round_cinematics_outcome_from_mode_result(1)
			if(wo_result == 2)
				return round_cinematics_outcome_from_mode_result(2)
		// fall through to round_finished

	if(!mode.round_finished)
		var/datum/round_cinematics_outcome/outcome = new(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE, FALSE)
		outcome.title = "РАУНД НЕ ЗАВЕРШЁН"
		outcome.detail = "РАУНД НЕ ДОСТИГ КОНЕЧНОГО СОСТОЯНИЯ"
		return outcome
	return round_cinematics_outcome_from_mode_result(mode.round_finished)
