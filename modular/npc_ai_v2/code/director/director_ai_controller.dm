/datum/npc_ai_director_objective
	var/id = null
	var/title = "objective"
	var/priority = 0
	var/active = TRUE
	var/list/context = list()

/datum/npc_ai_sensor_datum/director_runtime_scaffold
	name = "director_runtime_scaffold_sensor"
	legacy_sensor_id = "high_level_director"
	defer_on_low_tiers = TRUE
	defer_min_tier = 2
	defer_interval_ds = 30

/datum/npc_ai_action_datum/director_runtime_scaffold
	name = "director_runtime_scaffold_action"
	legacy_action_type = null

/// RU: Вычисляет utility-вес шага для planner в action-datum; 0 отключает запуск. EN: Computes utility weight for planner step in an action datum; 0 disables execution.
/datum/npc_ai_action_datum/director_runtime_scaffold/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return 0

/datum/npc_ai_controller/director
	name = "npc_ai_controller_director"
	var/list/datum/npc_ai_director_objective/objectives = list()
	/// Scene-level mood policy used by squad AI to choose aggression/retreat behavior.
	var/current_mood = NPC_AI_V2_DIRECTOR_MOOD_BALANCED
	/// Additional tactical pressure bias applied to squad decisions (-100..100).
	var/pressure_bias = 0

/// RU: Инициализирует runtime-состояние объекта в контроллере director AI. EN: Initializes runtime state of object in the director AI controller.
/datum/npc_ai_controller/director/New()
	. = ..()
	current_mood = normalize_mood(GLOB.npc_ai_v2_director_mood)
	pressure_bias = clamp(GLOB.npc_ai_v2_director_pressure_bias, -100, 100)
	register_sensor_datum(new /datum/npc_ai_sensor_datum/director_runtime_scaffold)
	register_action_datum(new /datum/npc_ai_action_datum/director_runtime_scaffold)

/// RU: Очищает runtime-состояние перед удалением объекта в контроллере director AI. Побочные эффекты: чистит runtime-объекты. EN: Cleans runtime state before deleting object in the director AI controller. Side effects: cleans runtime objects.
/datum/npc_ai_controller/director/Destroy(force, ...)
	QDEL_LIST(objectives)
	objectives = null
	return ..()

/// RU: Проверяет условие в контроллере director AI (этап: is enabled) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the director AI controller (step: is enabled) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/director/is_enabled()
	return GLOB.npc_ai_v2_director_enabled && !ai_kill

/// RU: Синхронизирует состояние director с админскими глобалами и возвращает легковесные метрики тика. EN: Synchronizes director state with admin globals and returns lightweight tick metrics.
/datum/npc_ai_controller/director/run_ai_tick(delta_time)
	if(!is_enabled())
		return null

	// Keep controller state aligned with admin-facing globals.
	current_mood = normalize_mood(GLOB.npc_ai_v2_director_mood)
	pressure_bias = clamp(GLOB.npc_ai_v2_director_pressure_bias, -100, 100)

	var/list/metrics = list(
		"processed_npc" = 1,
		"think_samples_ms" = list(),
		"tier_counters" = list("0" = 0, "1" = 0, "2" = 1, "3" = 0),
		"path_requests" = 0,
		"path_hits" = 0,
		"path_failures" = 0
	)
	return finalize_process_metrics(metrics)

/// RU: Выполняет служебный этап в контроллере director AI (этап: normalize mood) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the director AI controller (step: normalize mood) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/director/proc/normalize_mood(mood_value)
	var/mood_text = lowertext(trim("[mood_value]"))
	switch(mood_text)
		if(NPC_AI_V2_DIRECTOR_MOOD_AGGRESSIVE, NPC_AI_V2_DIRECTOR_MOOD_BALANCED, NPC_AI_V2_DIRECTOR_MOOD_RETREAT)
			return mood_text
	return NPC_AI_V2_DIRECTOR_MOOD_BALANCED

/// RU: Обновляет runtime состояние в контроллере director AI (этап: set current mood) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the director AI controller (step: set current mood) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/director/proc/set_current_mood(new_mood)
	current_mood = normalize_mood(new_mood)
	GLOB.npc_ai_v2_director_mood = current_mood

/// RU: Обновляет runtime состояние в контроллере director AI (этап: set pressure bias) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the director AI controller (step: set pressure bias) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/director/proc/set_pressure_bias(new_pressure_bias)
	pressure_bias = clamp(new_pressure_bias, -100, 100)
	GLOB.npc_ai_v2_director_pressure_bias = pressure_bias

/// RU: Собирает mood packet для Squad AI: mood + pressure_bias + focus/retreat bias. EN: Builds mood packet for Squad AI: mood + pressure_bias + focus/retreat bias.
/datum/npc_ai_controller/director/proc/get_squad_mood_packet()
	var/mood = normalize_mood(current_mood)
	var/focus_bias = 0
	var/retreat_bias = 0

	switch(mood)
		if(NPC_AI_V2_DIRECTOR_MOOD_AGGRESSIVE)
			focus_bias = 20
			retreat_bias = -30
		if(NPC_AI_V2_DIRECTOR_MOOD_RETREAT)
			focus_bias = -10
			retreat_bias = 35

	return list(
		"mood" = mood,
		"pressure_bias" = clamp(pressure_bias, -100, 100),
		"focus_fire_bias" = focus_bias,
		"retreat_bias" = retreat_bias
	)

/// RU: Регистрирует сущность в контроллере director AI (этап: register objective) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the director AI controller (step: register objective) and links it to AI v2 runtime state.
/datum/npc_ai_controller/director/proc/register_objective(id, title = "objective", priority = 0)
	if(isnull(id))
		return null
	var/datum/npc_ai_director_objective/objective = new
	objective.id = "[id]"
	objective.title = "[title]"
	objective.priority = priority
	objectives += objective
	return objective

/// RU: Удаляет или освобождает runtime сущности в контроллере director AI (этап: clear objectives) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the director AI controller (step: clear objectives) to avoid dangling references and stale state.
/datum/npc_ai_controller/director/proc/clear_objectives()
	if(!islist(objectives) || !length(objectives))
		return
	QDEL_LIST(objectives)
	objectives = list()
