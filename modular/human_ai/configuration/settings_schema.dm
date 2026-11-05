/// Metadata is also the UI contract. Unknown keys and out-of-range values are rejected.
/proc/human_ai_settings_schema()
	var/static/list/schema = list(
		"combat_spacing" = list("label" = "Держать дистанцию между союзниками", "section" = "Бой", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"health_percent" = list("label" = "Запас здоровья, %", "section" = "Бой", "min" = 10, "max" = 300, "default" = 100, "integer" = TRUE),
		"grenade_safety" = list("label" = "Безопасный бросок во врага", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"throwback_safety" = list("label" = "Безопасное отбрасывание", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"stealth_enabled" = list("label" = "Стелс для ИИ", "section" = "Бой", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"reaction" = list("label" = "Реакция, секунд", "section" = "Бой", "min" = 0.2, "max" = 3, "default" = 0.7),
		"accuracy" = list("label" = "Множитель точности", "section" = "Бой", "min" = 0.3, "max" = 3, "default" = 0.85),
		"scatter" = list("label" = "Множитель разброса оружия", "section" = "Бой", "min" = 0, "max" = 3, "default" = 1),
		"burst_limit" = list("label" = "Максимум выстрелов в очереди", "section" = "Бой", "min" = 1, "max" = 12, "default" = 6, "integer" = TRUE),
		"burst_pause" = list("label" = "Пауза между очередями, секунд", "section" = "Бой", "min" = 0.5, "max" = 5, "default" = 1),
		"pursuit_enabled" = list("label" = "Преследовать потерянную цель", "section" = "Преследование", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"chase_time" = list("label" = "Время осмотра после прибытия, секунд", "section" = "Преследование", "min" = 0, "max" = 30, "default" = 7),
		"pursuit_radius" = list("label" = "Радиус поиска, клеток", "section" = "Преследование", "min" = 1, "max" = 6, "default" = 3, "integer" = TRUE),
		"pursuit_points" = list("label" = "Дополнительных точек поиска", "section" = "Преследование", "min" = 0, "max" = 8, "default" = 3, "integer" = TRUE),
		"pursuit_predict" = list("label" = "Учитывать направление побега", "section" = "Преследование", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pursuit_team" = list("label" = "Роли: поиск, прикрытие, обход", "section" = "Преследование", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"pursuit_share" = list("label" = "Передавать наблюдения отряду", "section" = "Преследование", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pursuit_share_radius" = list("label" = "Дальность связи, клеток", "section" = "Преследование", "min" = 1, "max" = 20, "default" = 7, "integer" = TRUE),
		"pursuit_cautious" = list("label" = "Осторожно проверять углы и двери", "section" = "Преследование", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pursuit_pause" = list("label" = "Пауза осмотра, секунд", "section" = "Преследование", "min" = 0, "max" = 2, "default" = 0.5),
		"pursuit_return" = list("label" = "Возвращаться после поиска", "section" = "Преследование", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"cover" = list("label" = "Использовать укрытия", "section" = "Бой", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"cover_mode" = list("label" = "Выбор укрытия: 0 — ближайшее, 1 — оценка, 2 — смена при попадании", "section" = "Бой", "min" = 0, "max" = 2, "default" = 1, "integer" = TRUE),
		"tactical_distance" = list("label" = "Учитывать вооружение противника при выборе дистанции", "section" = "Бой", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"retreat_health" = list("label" = "Отступление при здоровье ниже, %", "section" = "Бой", "min" = 0, "max" = 70, "default" = 30, "integer" = TRUE),
		"grenades" = list("label" = "Ручные гранаты", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"underbarrel" = list("label" = "Подствольный гранатомёт", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"throwback" = list("label" = "Отбрасывать чужие гранаты", "section" = "Гранаты", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"fuse_reserve" = list("label" = "Резерв запала, секунд", "section" = "Гранаты", "min" = 2, "max" = 6, "default" = 2),
		"grenade_chance" = list("label" = "Шанс броска гранаты, %", "section" = "Гранаты", "min" = 0, "max" = 100, "default" = 100, "integer" = TRUE),
		"medicine" = list("label" = "Разрешить медицину", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"self_heal" = list("label" = "Лечить себя", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"heal_npcs" = list("label" = "Лечить союзных NPC", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"heal_players" = list("label" = "Лечить союзных игроков", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"drugs" = list("label" = "Использовать медикаменты", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"repair_self" = list("label" = "Ремонтировать себя — синтетик", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"repair_allies" = list("label" = "Ремонтировать союзных синтетиков", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"heal_out_of_combat" = list("label" = "Лечить только после завершения боя", "section" = "Медицина", "min" = 0, "max" = 1, "default" = 0, "boolean" = TRUE),
		"open_door" = list("label" = "Открывать двери", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pry_door" = list("label" = "Вскрывать двери инструментом", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"climb_barricade" = list("label" = "Перелезать баррикады", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"climb_structure" = list("label" = "Перелезать конструкции", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"destroy" = list("label" = "Разрушать разрешённые препятствия", "section" = "Препятствия", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"pickup" = list("label" = "Подбирать предметы", "section" = "Снаряжение", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"switch_weapons" = list("label" = "Подбирать основное оружие под дистанцию боя", "section" = "Снаряжение", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"early_reload" = list("label" = "Заранее менять почти пустой магазин вне боя", "section" = "Снаряжение", "min" = 0, "max" = 1, "default" = 1, "boolean" = TRUE),
		"follow_distance" = list("label" = "Дополнительная дистанция следования", "section" = "Движение", "min" = 0, "max" = 5, "default" = 0, "integer" = TRUE),
		"hold_radius" = list("label" = "Радиус удержания: 0 — без дополнительного ограничения", "section" = "Движение", "min" = 0, "max" = 20, "default" = 0, "integer" = TRUE),
		"path_retries" = list("label" = "Неудачные поиски пути до увеличенной паузы", "section" = "Движение", "min" = 1, "max" = 10, "default" = 3, "integer" = TRUE),
	)
	return schema

/proc/human_ai_settings_valid_value(key, value)
	if(!istext(key))
		return FALSE
	var/list/definition = human_ai_settings_schema()[key]
	if(!definition || !isnum(value) || value < definition["min"] || value > definition["max"])
		return FALSE
	if((definition["integer"] || definition["boolean"]) && round(value) != value)
		return FALSE
	return TRUE

/// Returns a new flat list, never a caller-owned profile or shared metadata.
/proc/human_ai_settings_validate(list/values)
	if(!islist(values))
		return null
	var/list/schema = human_ai_settings_schema()
	if(length(values) != length(schema))
		return null
	var/list/result = list()
	for(var/key in values)
		if(!human_ai_settings_valid_value(key, values[key]))
			return null
		result[key] = values[key]
	return result

/// Version 1 lacks the two additive controls. Never accept arbitrary partial saves.
/proc/human_ai_settings_import(list/values, version)
	if(!islist(values) || !(version in list(1, 2, 3, 4, 5, 6)))
		return null
	var/list/migrated = values.Copy()
	if(version == 1)
		if(!("grenade_chance" in migrated))
			migrated["grenade_chance"] = 100
		if(!("stealth_enabled" in migrated))
			migrated["stealth_enabled"] = TRUE
	if(version < 3)
		for(var/key in list("health_percent", "grenade_safety", "throwback_safety"))
			if(!(key in migrated))
				migrated[key] = human_ai_settings_schema()[key]["default"]
	if(version < 4 && !("scatter" in migrated))
		migrated["scatter"] = 1
	if(version < 5 && !("combat_spacing" in migrated))
		migrated["combat_spacing"] = FALSE
	if(version < 6)
		for(var/key in human_ai_settings_schema())
			if(findtext(key, "pursuit_") == 1 && !(key in migrated))
				migrated[key] = human_ai_settings_schema()[key]["default"]
	return human_ai_settings_validate(migrated)

/proc/human_ai_settings_help(key)
	var/static/list/descriptions = list(
		"pursuit_enabled" = "Включает поиск после потери видимости врага. Выключение завершает поиск и освобождает NPC для прежнего приказа. Стрельба и сближение с видимым врагом не отключаются.",
		"pursuit_radius" = "Радиус вокруг последней замеченной позиции, в котором выбираются точки поиска. Не расширяет зрение и не разрешает проход через стены. Недоступные точки пропускаются.",
		"pursuit_points" = "Максимум дополнительных точек после последней известной позиции. 0 — проверять только последнюю позицию. При истечении времени поиск завершится раньше.",
		"pursuit_predict" = "Предпочитать направление между двумя последними реально увиденными позициями врага. Это предположение, а не отслеживание сквозь стены.",
		"pursuit_team" = "Ближайшие участники одного отряда распределяют поиск, прикрытие и боковой подход. Роль фиксируется на время поиска. Не зависит от дистанции между союзниками; одиночный NPC ищет сам.",
		"pursuit_share" = "Передавать ближайшим NPC своего отряда реально замеченную точку, направление и время наблюдения. Сообщение не даёт видимость или цель для стрельбы и не пересылается дальше.",
		"pursuit_share_radius" = "Максимальное расстояние между отправителем и получателем наблюдения на одном уровне карты. Обмен не чаще раза в секунду, до 16 участников отряда. Радиоустройство не требуется.",
		"pursuit_cautious" = "Перед сменой направления у плотного препятствия или рядом с дверью NPC останавливается и смотрит в сторону движения. Каждую клетку проверяет не более одного раза за поиск.",
		"pursuit_pause" = "Длительность осторожной остановки у угла или двери. 0 — без задержки. Пауза входит в общий бюджет поиска и прерывается боем или опасностью.",
		"pursuit_return" = "После поиска продолжить сохранённый приказ. Если приказа нет — вернуться к позиции начала поиска, максимум 10 секунд. Без телепортации. Выключено: закончить поиск на текущем месте; обычные приказы остаются действующими.",
		"combat_spacing" = "В бою NPC стараются разойтись с соседними союзными NPC и не выбирать занятые ими укрытия. Выключено по умолчанию на всех сложностях. Не отключает отступление от противника или бегство от гранат. В тесных проходах дистанция не гарантируется.",
		"scatter" = "Множитель итогового углового разброса выстрела NPC, включая очередь и автоматический огонь: 0 — без отклонения направления, 0.5 — вдвое меньше, 1 — обычный, 3 — втрое больше. Не гарантирует попадание и не меняет точность, урон или собственное рассеивание дробинок. Оружие в руках игрока не изменяется.",
		"health_percent" = "Запас здоровья относительно обычного: 100% — норма, 300% — втрое больше, 50% — вдвое меньше. Уже полученные повреждения сохраняются; снижение может убить тяжело раненого NPC. Не усиливает отдельные конечности и не защищает от потери органов.",
		"grenade_safety" = "Включено: не бросать гранату рядом с союзниками. Выключено: допускается урон союзникам возле врага. Дальность, препятствия и минимальная дистанция до самого NPC сохраняются. Также действует на подствольник.",
		"throwback_safety" = "Включено: проверять союзников возле места падения. Выключено: отбросить гранату даже рядом с союзниками. Подбор только в пределах 2 клеток и при достаточном времени до взрыва; иначе отход до дистанции 5 клеток.",
		"reaction" = "Минимальная задержка перед стрельбой после обнаружения новой цели. Меньше — NPC открывает огонь быстрее. Фактическая реакция зависит также от такта ИИ и готовности оружия. Единицы: секунды.",
		"accuracy" = "Множитель точности создаваемого снаряда. 1 сохраняет исходную точность оружия; 0.65 оставляет 65% от неё. Это не вероятность попадания: дистанция, укрытие и оружие продолжают влиять на результат.",
		"burst_limit" = "Верхний предел выстрелов в автоматической очереди до паузы. Меньше — более короткие очереди. Собственный меньший лимит оружия сохраняется; настройка не превращает одиночный режим в автоматический. Единицы: выстрелы.",
		"burst_pause" = "Минимальная пауза после достижения лимита очереди. Больше — реже длинные серии огня. Собственные задержки ИИ и оружия могут увеличить паузу. Единицы: секунды.",
		"chase_time" = "Время осмотра после достижения последней замеченной позиции. На подход выделяется до 10 секунд; общий предел — 10 секунд плюс это значение. До начала поиска наблюдение должно быть не старше этого значения. Повторные попытки движения не продлевают сроки. 0 отключает преследование. Единицы: секунды.",
		"cover_mode" = "0 — ближайшая безопасная позиция с положительной оценкой защиты. 1 — позиция с лучшей оценкой. 2 — та же оценка плюс повторный поиск при попадании по NPC в укрытии. Работает при включённом использовании укрытий.",
		"retreat_health" = "Порог здоровья в процентах от максимального: ниже него NPC пытается увеличить дистанцию до противника. Это обычное движение, без прохода через стены и нарушения границ приказа. 0 означает отступление только при здоровье ниже нуля.",
		"fuse_reserve" = "Минимальный запас времени для безопасного обратного броска сверх расчётного времени подхода. Больше — NPC реже рискует подбирать гранату. Не меняет запал самой гранаты. Если времени мало, NPC пытается убежать. Единицы: секунды.",
		"grenade_chance" = "Одна проверка вероятности за боевое столкновение для ручной гранаты или подствольного гранатомёта. 0% — не использовать, 100% — выбрать применение при наличии безопасной возможности. Нужны разрешённый тип гранат, боеприпас и безопасная цель. Изменение значения не перебрасывает уже принятое решение; действует со следующей проверкой. Обратный бросок не затрагивает.",
		"follow_distance" = "Добавляет расстояние к стандартной дистанции следования за командиром отряда. 0 оставляет обычное построение; больше — NPC держится дальше. Единицы: тайлы.",
		"hold_radius" = "Дополнительное ограничение удаления от исходной точки приказа удержания. 0 не добавляет радиус, но исходная граница приказа сохраняется. Бегство от активной гранаты может временно выйти за границы. Единицы: тайлы.",
		"path_retries" = "После указанного числа неудачных поисков пути обычная пауза повторного поиска увеличивается втрое. Меньше — быстрее снижает частоту безуспешных попыток. Не разрешает проход сквозь препятствия. Единицы: попытки.",
		"stealth_enabled" = "Включено: NPC не замечает новую цель в трёх направлениях позади себя. Уже обнаруженная цель остаётся известной, а нападение вызывает ответ. Выключено: задней слепой зоны нет. Обычная дальность, стены и проверки видимости сохраняются.",
	)
	return descriptions[key]

/proc/human_ai_settings_preset(level = "medium")
	if(!(level in list("easy", "medium", "hard")))
		return null
	var/list/result = list()
	var/list/schema = human_ai_settings_schema()
	for(var/key in schema)
		var/list/definition = schema[key]
		result[key] = definition["default"]
	if(level == "easy")
		result["reaction"] = 1.2
		result["accuracy"] = 0.65
		result["burst_limit"] = 3
		result["burst_pause"] = 2
		result["chase_time"] = 3
		result["pursuit_points"] = 1
		result["pursuit_radius"] = 2
		result["pursuit_predict"] = FALSE
		result["pursuit_share"] = FALSE
		result["cover_mode"] = 0
		result["switch_weapons"] = FALSE
		result["early_reload"] = FALSE
		for(var/key in list("grenades", "underbarrel", "heal_npcs", "heal_players", "drugs", "repair_allies", "destroy"))
			result[key] = FALSE
		result["heal_out_of_combat"] = TRUE
	else if(level == "hard")
		result["reaction"] = 0.3
		result["accuracy"] = 1
		result["burst_limit"] = 8
		result["burst_pause"] = 0.5
		result["chase_time"] = 12
		result["pursuit_points"] = 5
		result["pursuit_radius"] = 5
		result["pursuit_team"] = TRUE
		result["throwback"] = TRUE
		result["cover_mode"] = 2
		result["tactical_distance"] = TRUE
	return result
