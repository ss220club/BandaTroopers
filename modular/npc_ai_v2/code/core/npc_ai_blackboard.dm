/datum/npc_ai_blackboard
	/// Р РЋР Р…Р С‘Р СР С•Р С” РЎРѓР С•РЎРѓРЎвЂљР С•РЎРЏР Р…Р С‘РЎРЏ РЎвЂљР ВµР С”РЎС“РЎвЂ°Р ВµР С–Р С• Р В°Р С–Р ВµР Р…РЎвЂљР В° Р Р† РЎвЂћР С•РЎР‚Р СР В°РЎвЂљР Вµ Р С”Р В»РЎР‹РЎвЂЎ/Р В·Р Р…Р В°РЎвЂЎР ВµР Р…Р С‘Р Вµ.
	var/list/state = list()
	/// Dirty-РЎвЂћР В»Р В°Р С–Р С‘ Р Т‘Р В»РЎРЏ Р С‘Р Р…Р Р†Р В°Р В»Р С‘Р Т‘Р С‘РЎР‚Р С•Р Р†Р В°Р Р…Р С‘РЎРЏ Р В·Р В°Р Р†Р С‘РЎРѓР С‘Р СР С•Р С–Р С• Р С”Р ВµРЎв‚¬Р В° РЎРѓР ВµР Р…РЎРѓР С•РЎР‚Р С•Р Р†/РЎвЂљР В°РЎРѓР С”Р С•Р Р†.
	var/list/dirty_flags = list()
	/// Р С™Р ВµРЎв‚¬ РЎвЂљРЎРЏР В¶РЎвЂР В»РЎвЂ№РЎвЂ¦ Р Р†РЎвЂ№РЎвЂЎР С‘РЎРѓР В»Р ВµР Р…Р С‘Р в„–, Р С‘Р Р…Р Т‘Р ВµР С”РЎРѓР С‘РЎР‚РЎС“Р ВµР СРЎвЂ№Р в„– Р С—РЎР‚Р С•Р С‘Р В·Р Р†Р С•Р В»РЎРЉР Р…РЎвЂ№Р СР С‘ Р С”Р В»РЎР‹РЎвЂЎР В°Р СР С‘.
	var/list/cached_queries = list()

/// RU: Записывает значение ключа в blackboard и возвращает сохраненное значение для цепочки вызовов. EN: Writes a blackboard key and returns stored value for call chaining.
/datum/npc_ai_blackboard/proc/set_value(key, value)
	state[key] = value
	mark_dirty(key)

/// RU: Читает значение ключа из blackboard с fallback по умолчанию, если ключ отсутствует. EN: Reads a key from blackboard with default fallback when the key is missing.
/datum/npc_ai_blackboard/proc/get_value(key, default_value = null)
	if(key in state)
		return state[key]
	return default_value

/// RU: Обновляет runtime состояние в blackboard AI v2 (этап: mark dirty) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the AI v2 blackboard (step: mark dirty) and synchronizes data for subsequent ticks.
/datum/npc_ai_blackboard/proc/mark_dirty(flag)
	dirty_flags[flag] = TRUE

/// RU: Удаляет или освобождает runtime сущности в blackboard AI v2 (этап: clear dirty) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the AI v2 blackboard (step: clear dirty) to avoid dangling references and stale state.
/datum/npc_ai_blackboard/proc/clear_dirty(flag)
	dirty_flags -= flag

/// RU: Проверяет условие в blackboard AI v2 (этап: is dirty) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the AI v2 blackboard (step: is dirty) and returns a boolean used to choose the next step.
/datum/npc_ai_blackboard/proc/is_dirty(flag)
	return !!dirty_flags[flag]

/// RU: Выполняет служебный этап в blackboard AI v2 (этап: cache query) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the AI v2 blackboard (step: cache query) to coordinate state between AI v2 subsystems.
/datum/npc_ai_blackboard/proc/cache_query(key, value)
	cached_queries[key] = value

/// RU: Вычисляет и возвращает данные в blackboard AI v2 (этап: get cached query) для следующего этапа поведения. EN: Computes and returns data in the AI v2 blackboard (step: get cached query) for the next behavior stage.
/datum/npc_ai_blackboard/proc/get_cached_query(key, default_value = null)
	if(key in cached_queries)
		return cached_queries[key]
	return default_value

/// RU: Удаляет или освобождает runtime сущности в blackboard AI v2 (этап: clear cache) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the AI v2 blackboard (step: clear cache) to avoid dangling references and stale state.
/datum/npc_ai_blackboard/proc/clear_cache()
	cached_queries.Cut()
