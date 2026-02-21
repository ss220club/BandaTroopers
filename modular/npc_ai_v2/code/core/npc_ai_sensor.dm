/datum/npc_ai_sensor
	var/name = "npc_ai_sensor"
	var/enabled = TRUE
	/// Defer this sensor on low-priority tiers.
	var/defer_on_low_tiers = FALSE
	/// Starting tier where defer policy is applied.
	var/defer_min_tier = 2
	/// Minimum interval (deciseconds) between deferred executions.
	var/defer_interval_ds = 10

/// RU: Проверяет условие в сенсорах AI v2 (этап: should run) и возвращает булево значение для выбора следующего шага. EN: Checks condition in AI v2 sensors (step: should run) and returns a boolean used to choose the next step.
/datum/npc_ai_sensor/proc/should_run(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, think_tier)
	if(!enabled || !controller || !agent || !blackboard)
		return FALSE
	if(!defer_on_low_tiers)
		return TRUE
	if(think_tier < defer_min_tier)
		return TRUE

	var/cache_key = "v2_sensor_last_run_at:[type]"
	var/last_run_at = blackboard.get_cached_query(cache_key, 0)
	if(world.time < (last_run_at + defer_interval_ds))
		return FALSE
	blackboard.cache_query(cache_key, world.time)
	return TRUE

/// RU: Собирает сенсорные данные для planner/blackboard в базовом AI-сенсоре. EN: Collects sensor data for planner/blackboard in the base AI sensor.
/datum/npc_ai_sensor/proc/sense(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!enabled || !controller || !agent || !blackboard)
		return null
	return list()
