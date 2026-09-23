/datum/round_cinematics_affiliation
	/// Internal faction id (e.g. FACTION_MARINE)
	var/faction_id
	/// Display code: КМП США / КК ООН / ОДШВ / В-Ю / СПН / ИТМ / НЕИЗВ
	var/display_code = "НЕИЗВ"
	/// Human-readable display name
	var/display_name = "НЕИЗВЕСТНАЯ ФРАКЦИЯ"
	/// Unit name (e.g. "3-й Батальон 'Банда Десантников'")
	var/unit_name = ""
	/// Squad name if applicable
	var/squad_name = ""
	/// Ship name from SSmapping
	var/ship_name = ""
	/// Ground map name from SSmapping
	var/ground_map_name = ""
	/// Operation name from SSticker.mode
	var/operation_name = ""
	/// Logo text for header
	var/logo_text = "BW"
	/// Visual profile id to use
	var/visual_profile_id = "intro_universal"
	/// Header color for intro sequence
	var/header_color = "#33FF33"
	/// Accent color for intro sequence
	var/accent_color = "#33FF33"
	/// Header label (e.g. "СИСТЕМА КРИОГЕННОГО ПРОБУЖДЕНИЯ")
	var/header_label = "СИСТЕМА КРИОГЕННОГО ПРОБУЖДЕНИЯ"
	/// Footer label (e.g. "ГОТОВ")
	var/footer_label = "ГОТОВ"
	/// Boot sequence prefix (e.g. "КМП-ТЕРМИНАЛ")
	var/boot_prefix = "СИСТ-ТЕРМИНАЛ"
	/// Security classification label (e.g. "ЗАЩИЩЁННЫЙ КАНАЛ")
	var/security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
	/// Identity label for personal dossier (e.g. "ЛИЧНОЕ ДЕЛО КМП США")
	var/identity_label = "ЛИЧНОЕ ДЕЛО"
	/// Manifest section label (e.g. "СОСТАВ ОТРЯДА")
	var/manifest_label = "СОСТАВ ПОДРАЗДЕЛЕНИЯ"
	/// Deployment status line (e.g. "ГОТОВ К РАЗВЁРТЫВАНИЮ")
	var/deployment_label = "ОЖИДАНИЕ РАЗВЁРТЫВАНИЯ"
	/// Final intro line before fade-out (e.g. "СЕМПЕР ФИ")
	var/final_intro_line = "ОЖИДАНИЕ"

/// Build a universal, data-driven list of intro lines from affiliation fields.
/// Returns a list of strings; each non-empty field produces one line.
/// Callers do not need to know which fields exist — the sequence handles all.
/datum/round_cinematics_affiliation/proc/build_intro_lines()
	var/list/lines = list()
	if(length(display_code))
		lines += "[display_code] — [display_name]"
	if(length(unit_name))
		lines += "ЧАСТЬ: [unit_name]"
	// ОТРЯД убран — squad_name уже есть в базовом dossier
	if(length(ship_name))
		lines += "КОРАБЛЬ: [ship_name]"
	if(length(ground_map_name))
		lines += "ЗОНА ОПЕРАЦИИ: [ground_map_name]"
	if(length(operation_name))
		lines += "ОПЕРАЦИЯ: [operation_name]"
	return lines

/// Resolve affiliation data for a human mob.
/// Returns a /datum/round_cinematics_affiliation with populated fields.
/proc/resolve_affiliation(mob/living/carbon/human/human)
	var/datum/round_cinematics_affiliation/aff = new()
	if(!istype(human))
		return aff

	aff.faction_id = human.faction

	// Map faction to display_code — русские аббревиатуры по брифу
	switch(human.faction)
		if(FACTION_MARINE)
			aff.display_code = "КМП США"
			aff.display_name = "Корпус морской пехоты США"
			aff.unit_name = "3-й Батальон 'Банда Десантников'"
			aff.visual_profile_id = "intro_universal"
			aff.header_color = "#33FF33"
			aff.accent_color = "#33FF33"
			aff.logo_text = "КМП"
			aff.header_label = "КОРПУС МОРСКОЙ ПЕХОТЫ США"
			aff.boot_prefix = "КМП-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО КМП США"
			aff.manifest_label = "СОСТАВ ОТРЯДА"
			aff.deployment_label = "ГОТОВ К РАЗВЁРТЫВАНИЮ"
			aff.final_intro_line = "КРИОЗАМОК СНЯТ. ОРУЖИЕ К БОЮ."
		if(FACTION_UNSC)
			aff.display_code = "КК ООН"
			aff.display_name = "Космическое командование ООН"
			aff.unit_name = "СИЛЫ КК ООН"
			aff.visual_profile_id = "intro_universal"
			aff.header_color = "#33CCFF"
			aff.accent_color = "#33CCFF"
			aff.logo_text = "ККООН"
			aff.header_label = "КОСМИЧЕСКОЕ КОМАНДОВАНИЕ ООН"
			aff.boot_prefix = "ККООН-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО КК ООН"
			aff.manifest_label = "СОСТАВ ПОДРАЗДЕЛЕНИЯ"
			aff.deployment_label = "ГОТОВ К РАЗВЁРТЫВАНИЮ"
			aff.final_intro_line = "ЧЕРЕЗ ТЕРНИИ К ЗВЁЗДАМ"
		if(FACTION_PMC)
			aff.display_code = "В-Ю"
			aff.display_name = "Корпорация Вейланд-Ютани"
			aff.unit_name = "АЗУР-15"
			aff.visual_profile_id = "intro_universal"
			aff.header_color = "#4488FF"
			aff.accent_color = "#4488FF"
			aff.logo_text = "В-Ю"
			aff.header_label = "КОРПОРАЦИЯ ВЕЙЛАНД-ЮТАНИ"
			aff.boot_prefix = "ВЮ-ТЕРМИНАЛ"
			aff.security_label = "ШИФРОВАННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО КОНТРАКТНИКА В-Ю"
			aff.manifest_label = "СОСТАВ ГРУППЫ"
			aff.deployment_label = "КОНТРАКТ АКТИВЕН"
			aff.final_intro_line = "СТРОИМ ЛУЧШИЕ МИРЫ"
		if(FACTION_UPP)
			aff.display_code = "СПН"
			aff.display_name = "Союз прогрессивных народов"
			aff.unit_name = "КРАСНЫЙ РАССВЕТ"
			aff.visual_profile_id = "intro_universal"
			aff.header_color = "#FFAA44"
			aff.accent_color = "#FFAA44"
			aff.logo_text = "СПН"
			aff.header_label = "СОЮЗ ПРОГРЕССИВНЫХ НАРОДОВ"
			aff.boot_prefix = "СПН-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО СПН"
			aff.manifest_label = "СОСТАВ ПОДРАЗДЕЛЕНИЯ"
			aff.deployment_label = "ГОТОВ К РАЗВЁРТЫВАНИЮ"
			aff.final_intro_line = "СИСТЕМА ПРОБУЖДЕНИЯ ЗАВЕРШЕНА. ВЫПОЛНЯЙТЕ ПРИКАЗ."
		if(FACTION_TWE)
			aff.display_code = "ИТМ"
			aff.display_name = "Империя трёх миров"
			aff.unit_name = "ГАММА-ОТРЯД"
			aff.visual_profile_id = "intro_universal"
			aff.header_color = "#FFAA44"
			aff.accent_color = "#FFAA44"
			aff.logo_text = "ИТМ"
			aff.header_label = "ИМПЕРИЯ ТРЁХ МИРОВ"
			aff.boot_prefix = "ИТМ-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО ИТМ"
			aff.manifest_label = "СОСТАВ ПОДРАЗДЕЛЕНИЯ"
			aff.deployment_label = "ГОТОВ К РАЗВЁРТЫВАНИЮ"
			aff.final_intro_line = "ПРОБУЖДЕНИЕ ЗАВЕРШЕНО. СЛУЖБА ПРОДОЛЖАЕТСЯ."
		else
			aff.display_code = uppertext(human.faction) || "НЕИЗВ"
			aff.display_name = uppertext(human.faction) || "НЕИЗВЕСТНАЯ ФРАКЦИЯ"
			aff.unit_name = "НЕИЗВЕСТНОЕ ПОДРАЗДЕЛЕНИЕ"
			aff.visual_profile_id = "intro_universal"
			aff.header_color = "#FFAA44"
			aff.accent_color = "#FFAA44"
			aff.logo_text = "СИСТ"
			aff.header_label = "СИСТЕМА КРИОГЕННОГО ПРОБУЖДЕНИЯ"
			aff.boot_prefix = "СИСТ-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО"
			aff.manifest_label = "СОСТАВ ПОДРАЗДЕЛЕНИЯ"
			aff.deployment_label = "ОЖИДАНИЕ РАЗВЁРТЫВАНИЯ"
			aff.final_intro_line = "ОЖИДАНИЕ"

	// ODST override: check if squad/job indicates ODST
	if(human.faction == FACTION_UNSC)
		if(human.assigned_squad && findtext(lowertext(human.assigned_squad.name), "odst"))
			aff.display_code = "ОДШВ"
			aff.display_name = "Орбитальные десантно-штурмовые войска"
			aff.unit_name = "ОРБИТАЛЬНЫЕ ДЕСАНТНО-ШТУРМОВЫЕ ВОЙСКА"
			aff.logo_text = "ОДШВ"
			aff.header_label = "ОРБИТАЛЬНЫЕ ДЕСАНТНО-ШТУРМОВЫЕ ВОЙСКА"
			aff.boot_prefix = "ОДШВ-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО ОДШВ"
			aff.manifest_label = "СОСТАВ ОТРЯДА"
			aff.deployment_label = "ГОТОВ К ДЕСАНТИРОВАНИЮ"
			aff.final_intro_line = "НОГАМИ ВПЕРЁД В АД"
		else if(human.job && findtext(lowertext(human.job), "odst"))
			aff.display_code = "ОДШВ"
			aff.display_name = "Орбитальные десантно-штурмовые войска"
			aff.unit_name = "ОРБИТАЛЬНЫЕ ДЕСАНТНО-ШТУРМОВЫЕ ВОЙСКА"
			aff.logo_text = "ОДШВ"
			aff.header_label = "ОРБИТАЛЬНЫЕ ДЕСАНТНО-ШТУРМОВЫЕ ВОЙСКА"
			aff.boot_prefix = "ОДШВ-ТЕРМИНАЛ"
			aff.security_label = "ЗАЩИЩЁННЫЙ КАНАЛ"
			aff.identity_label = "ЛИЧНОЕ ДЕЛО ОДШВ"
			aff.manifest_label = "СОСТАВ ОТРЯДА"
			aff.deployment_label = "ГОТОВ К ДЕСАНТИРОВАНИЮ"
			aff.final_intro_line = "НОГАМИ ВПЕРЁД В АД"

	// Squad name
	if(human.assigned_squad)
		aff.squad_name = human.assigned_squad.name

	// Ship name from SSmapping
	if(SSmapping?.configs)
		var/datum/map_config/ship_config = SSmapping.configs[SHIP_MAP]
		if(ship_config?.map_name)
			aff.ship_name = ship_config.map_name

	// Ground map name from SSmapping
	if(SSmapping?.configs)
		var/datum/map_config/ground_config = SSmapping.configs[GROUND_MAP]
		if(ground_config?.map_name)
			aff.ground_map_name = ground_config.map_name

	// Operation name from SSticker.mode
	if(SSticker?.mode?.name)
		aff.operation_name = SSticker.mode.name

	// Logo text
	aff.logo_text = aff.display_code

	return aff
