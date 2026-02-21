/datum/npc_ai_blackboard
	/// Agent state map: key/value runtime context used by sensors/tasks/actions.
	var/list/state = list()
	/// Dirty flags used for lazy cache invalidation between sensor/task stages.
	var/list/dirty_flags = list()
	/// Query cache for expensive derived values keyed by deterministic query id.
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
