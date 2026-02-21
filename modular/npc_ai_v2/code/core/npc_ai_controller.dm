/datum/npc_ai_controller
	var/name = "npc_ai_controller"
	var/list/mob/living/agents = list()
	var/list/datum/npc_ai_sensor/sensors = list()
	var/list/datum/npc_ai_task/task_registry = list()
	/// Dedicated action-datum registry for staged migration from legacy ai_action datums.
	var/list/datum/npc_ai_action_datum/action_registry = list()
	var/list/blackboards = list()
	var/datum/npc_ai_planner/planner
	var/datum/npc_ai_executor/executor
	/// Tier0..Tier3 think cadence in deciseconds.
	var/list/think_interval_ds_by_tier = list("0" = 2, "1" = 4, "2" = 8, "3" = 12)
	/// Hard cap of processed agents per fire for each tier. Zero means unlimited.
	var/list/work_quota_by_tier = list("0" = 0, "1" = 64, "2" = 48, "3" = 32)
	/// Round-robin cursor for fairness when quotas cut due queues.
	var/list/tier_round_robin_cursor = list("0" = 1, "1" = 1, "2" = 1, "3" = 1)

	/// Р РЋРЎвЂЎРЎвЂРЎвЂљРЎвЂЎР С‘Р С”Р С‘ pathfinding Р В·Р В° Р С•Р Т‘Р С‘Р Р… process; Р С—Р С•Р Т‘РЎРѓР С‘РЎРѓРЎвЂљР ВµР СР В° Р В°Р С–РЎР‚Р ВµР С–Р С‘РЎР‚РЎС“Р ВµРЎвЂљ Р С‘РЎвЂ¦ Р Р† Р С”Р В°Р В¶Р Т‘Р С•Р С fire.
	var/path_requests_since_process = 0
	var/path_hits_since_process = 0
	var/path_failures_since_process = 0
	/// Soft kill switch for runtime toggles.
	var/ai_kill = FALSE

/// RU: Инициализирует runtime-состояние объекта в базовом AI-контроллере. EN: Initializes runtime state of object in the base AI controller.
/datum/npc_ai_controller/New()
	. = ..()
	planner = new
	executor = new

/// RU: Очищает runtime-состояние перед удалением объекта в базовом AI-контроллере. Побочные эффекты: чистит runtime-объекты. EN: Cleans runtime state before deleting object in the base AI controller. Side effects: cleans runtime objects.
/datum/npc_ai_controller/Destroy(force, ...)
	agents = null
	QDEL_LIST(sensors)
	QDEL_LIST(task_registry)
	QDEL_LIST(action_registry)
	QDEL_LIST_ASSOC_VAL(blackboards)
	QDEL_NULL(planner)
	QDEL_NULL(executor)
	return ..()

/// RU: Проверяет, может ли контроллер обрабатываться в текущем тике (feature-flag и runtime kill-switch). EN: Checks whether the controller can run this tick (feature flags and runtime kill-switch).
/datum/npc_ai_controller/proc/is_enabled()
	return FALSE

/// RU: Добавляет агента в контроллер, создает его blackboard и вешает сигнал QDELETING для автоматической отписки. EN: Adds agent to controller, creates its blackboard, and hooks QDELETING signal for automatic unregister.
/datum/npc_ai_controller/proc/register_agent(mob/living/agent)
	if(!agent)
		return
	if(agent in agents)
		return
	agents |= agent
	get_blackboard(agent)
	RegisterSignal(agent, COMSIG_PARENT_QDELETING, PROC_REF(on_registered_agent_qdeleting), TRUE)

/// RU: Удаляет агента из контроллера, очищает executor state и удаляет привязанный blackboard. EN: Removes agent from controller, clears executor state, and deletes attached blackboard.
/datum/npc_ai_controller/proc/unregister_agent(mob/living/agent)
	if(!agent)
		return
	UnregisterSignal(agent, COMSIG_PARENT_QDELETING)
	agents -= agent
	if(executor)
		executor.clear_agent(agent)
	var/datum/npc_ai_blackboard/blackboard = null
	if(islist(blackboards))
		blackboard = blackboards[agent]
	if(blackboard)
		qdel(blackboard)
	blackboards -= agent

/// RU: Выполняет служебный этап в базовом AI-контроллере (этап: on registered agent qdeleting) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the base AI controller (step: on registered agent qdeleting) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/proc/on_registered_agent_qdeleting(datum/source)
	SIGNAL_HANDLER
	if(!source)
		return
	unregister_agent(source)

/// RU: Регистрирует сущность в базовом AI-контроллере (этап: register sensor) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the base AI controller (step: register sensor) and links it to AI v2 runtime state.
/datum/npc_ai_controller/proc/register_sensor(datum/npc_ai_sensor/sensor)
	if(!sensor)
		return
	sensors |= sensor

/// RU: Регистрирует сущность в базовом AI-контроллере (этап: register sensor datum) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the base AI controller (step: register sensor datum) and links it to AI v2 runtime state.
/datum/npc_ai_controller/proc/register_sensor_datum(datum/npc_ai_sensor_datum/sensor_datum)
	if(!sensor_datum)
		return
	register_sensor(sensor_datum)

/// RU: Регистрирует сущность в базовом AI-контроллере (этап: register task) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the base AI controller (step: register task) and links it to AI v2 runtime state.
/datum/npc_ai_controller/proc/register_task(datum/npc_ai_task/task)
	if(!task)
		return
	task_registry |= task

/// RU: Регистрирует сущность в базовом AI-контроллере (этап: register action datum) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the base AI controller (step: register action datum) and links it to AI v2 runtime state.
/datum/npc_ai_controller/proc/register_action_datum(datum/npc_ai_action_datum/action_datum)
	if(!action_datum)
		return
	action_registry |= action_datum

/// RU: Удаляет или освобождает runtime сущности в базовом AI-контроллере (этап: unregister action datum) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the base AI controller (step: unregister action datum) to avoid dangling references and stale state.
/datum/npc_ai_controller/proc/unregister_action_datum(datum/npc_ai_action_datum/action_datum)
	if(!action_datum)
		return
	action_registry -= action_datum

/// RU: Вычисляет и возвращает данные в базовом AI-контроллере (этап: get blackboard) для следующего этапа поведения. EN: Computes and returns data in the base AI controller (step: get blackboard) for the next behavior stage.
/datum/npc_ai_controller/proc/get_blackboard(mob/living/agent)
	RETURN_TYPE(/datum/npc_ai_blackboard)
	if(!agent)
		return null

	LAZYINITLIST(blackboards)
	var/datum/npc_ai_blackboard/blackboard = blackboards[agent]
	if(!blackboard)
		blackboard = new
		blackboards[agent] = blackboard
	return blackboard

/// RU: Запускает подходящие сенсоры контроллера, удаляет qdeleted сенсоры и объединяет собранные state tags. EN: Runs eligible controller sensors, drops qdeleted sensors, and merges collected state tags.
/datum/npc_ai_controller/proc/gather_senses(mob/living/agent, datum/npc_ai_blackboard/blackboard, think_tier = 0)
	var/list/sensed_tags = list()
	for(var/datum/npc_ai_sensor/sensor as anything in sensors)
		if(QDELETED(sensor))
			sensors -= sensor
			continue
		if(!sensor.should_run(src, agent, blackboard, think_tier))
			continue
		var/list/sensor_tags = sensor.sense(src, agent, blackboard)
		if(length(sensor_tags))
			sensed_tags |= sensor_tags
	return sensed_tags

/// RU: Вычисляет и возвращает данные в базовом AI-контроллере (этап: resolve think tier) для следующего этапа поведения. EN: Computes and returns data in the base AI controller (step: resolve think tier) for the next behavior stage.
/datum/npc_ai_controller/proc/resolve_think_tier(mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!agent || !blackboard)
		return 3
	if(blackboard.get_value("legacy_in_combat", FALSE) || blackboard.get_value("legacy_has_target", FALSE))
		return 0
	if(is_agent_near_client_cached(agent, blackboard))
		return 1
	return 3

/// RU: Вычисляет и возвращает данные в базовом AI-контроллере (этап: get think interval deciseconds) для следующего этапа поведения. EN: Computes and returns data in the base AI controller (step: get think interval deciseconds) for the next behavior stage.
/datum/npc_ai_controller/proc/get_think_interval_deciseconds(think_tier)
	think_tier = clamp(think_tier, 0, 3)
	var/list/intervals = think_interval_ds_by_tier
	if(!islist(intervals))
		return 0
	return max(0, intervals["[think_tier]"] || 0)

/// RU: Вычисляет и возвращает данные в базовом AI-контроллере (этап: get tier quota) для следующего этапа поведения. EN: Computes and returns data in the base AI controller (step: get tier quota) for the next behavior stage.
/datum/npc_ai_controller/proc/get_tier_quota(think_tier)
	think_tier = clamp(think_tier, 0, 3)
	var/list/quotas = work_quota_by_tier
	if(!islist(quotas))
		return 0
	return max(0, quotas["[think_tier]"] || 0)

/// RU: Проверяет условие в базовом AI-контроллере (этап: is agent due for think) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the base AI controller (step: is agent due for think) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/proc/is_agent_due_for_think(mob/living/agent, datum/npc_ai_blackboard/blackboard, think_tier)
	if(!agent || !blackboard)
		return FALSE
	var/next_think_at = blackboard.get_value("v2_next_think_at", 0)
	if(world.time < next_think_at)
		return FALSE
	return TRUE

/// RU: Обновляет runtime состояние в базовом AI-контроллере (этап: mark agent think executed) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the base AI controller (step: mark agent think executed) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/proc/mark_agent_think_executed(datum/npc_ai_blackboard/blackboard, think_tier)
	if(!blackboard)
		return
	var/interval_ds = get_think_interval_deciseconds(think_tier)
	blackboard.set_value("v2_last_think_tier", think_tier)
	blackboard.set_value("v2_last_think_at", world.time)
	blackboard.set_value("v2_next_think_at", world.time + interval_ds)

/// RU: Проверяет условие в базовом AI-контроллере (этап: is agent near client cached) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the base AI controller (step: is agent near client cached) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/proc/is_agent_near_client_cached(mob/living/agent, datum/npc_ai_blackboard/blackboard, refresh_interval_ds = 10, view_range = 7)
	if(!agent || !blackboard)
		return FALSE

	var/last_check_at = blackboard.get_value("v2_visibility_checked_at", 0)
	if(world.time >= (last_check_at + refresh_interval_ds))
		var/near_client = is_agent_near_client(agent, view_range)
		blackboard.set_value("v2_visibility_near_client", near_client)
		blackboard.set_value("v2_visibility_checked_at", world.time)

	return !!blackboard.get_value("v2_visibility_near_client", FALSE)

/// RU: Проверяет условие в базовом AI-контроллере (этап: is agent near client) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the base AI controller (step: is agent near client) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/proc/is_agent_near_client(mob/living/agent, view_range = 7)
	if(!agent)
		return FALSE
	for(var/mob/nearby in viewers(view_range, agent))
		if(nearby?.client)
			return TRUE
	return FALSE

/// RU: Переносит path-счетчики process-цикла в метрики ответа и обнуляет локальные накопители. EN: Flushes process-cycle path counters into response metrics and resets local accumulators.
/datum/npc_ai_controller/proc/finalize_process_metrics(list/metrics)
	if(!islist(metrics))
		return metrics

	metrics["path_requests"] = path_requests_since_process
	metrics["path_hits"] = path_hits_since_process
	metrics["path_failures"] = path_failures_since_process

	path_requests_since_process = 0
	path_hits_since_process = 0
	path_failures_since_process = 0

	return metrics

/// RU: Основной цикл контроллера: строит due-очереди по think-tier, применяет квоты/round-robin и выполняет sensor->planner->executor pipeline. EN: Controller main loop: builds think-tier due queues, applies quotas/round-robin, and runs sensor->planner->executor pipeline.
/datum/npc_ai_controller/proc/run_ai_tick(delta_time)
	if(!is_enabled())
		return null

	if(!planner)
		planner = new
	if(!executor)
		executor = new

	var/list/metrics = list(
		"processed_npc" = 0,
		"think_samples_ms" = list(),
		"tier_counters" = list("0" = 0, "1" = 0, "2" = 0, "3" = 0),
		"path_requests" = 0,
		"path_hits" = 0,
		"path_failures" = 0
	)

	var/list/think_samples = metrics["think_samples_ms"]
	var/list/tier_counters = metrics["tier_counters"]
	var/list/due_agents_by_tier = list("0" = list(), "1" = list(), "2" = list(), "3" = list())

	for(var/mob/living/agent as anything in agents)
		if(QDELETED(agent))
			unregister_agent(agent)
			continue
		if(agent.client)
			continue

		var/datum/npc_ai_blackboard/blackboard = get_blackboard(agent)
		var/think_tier = clamp(resolve_think_tier(agent, blackboard), 0, 3)
		if(!is_agent_due_for_think(agent, blackboard, think_tier))
			continue
		due_agents_by_tier["[think_tier]"] += agent

	for(var/think_tier in 0 to 3)
		var/tier_key = "[think_tier]"
		var/list/tier_due_agents = due_agents_by_tier[tier_key]
		if(!islist(tier_due_agents) || !length(tier_due_agents))
			continue

		var/tier_quota = get_tier_quota(think_tier)
		var/target_count = length(tier_due_agents)
		if(tier_quota > 0)
			target_count = min(target_count, tier_quota)
		if(target_count <= 0)
			continue

		var/current_index = clamp(tier_round_robin_cursor[tier_key] || 1, 1, length(tier_due_agents))
		var/processed_for_tier = 0

		while(processed_for_tier < target_count)
			if(current_index > length(tier_due_agents))
				current_index = 1

			var/mob/living/agent = tier_due_agents[current_index]
			current_index++
			if(!agent || QDELETED(agent) || agent.client)
				continue

			var/start_tick_usage = TICK_USAGE_REAL
			var/datum/npc_ai_blackboard/blackboard = get_blackboard(agent)
			var/list/sensed_tags = gather_senses(agent, blackboard, think_tier)
			var/list/planned_tasks = planner.plan(src, agent, blackboard, task_registry, sensed_tags)
			executor.execute(src, agent, blackboard, planned_tasks, delta_time)
			mark_agent_think_executed(blackboard, think_tier)

			metrics["processed_npc"]++
			think_samples += TICK_USAGE_TO_MS(start_tick_usage)
			tier_counters[tier_key] = (tier_counters[tier_key] || 0) + 1
			processed_for_tier++

			if(TICK_CHECK)
				tier_round_robin_cursor[tier_key] = current_index
				return finalize_process_metrics(metrics)

		tier_round_robin_cursor[tier_key] = current_index

	return finalize_process_metrics(metrics)

/// RU: Обновляет runtime состояние в базовом AI-контроллере (этап: record path request) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the base AI controller (step: record path request) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/proc/record_path_request()
	path_requests_since_process++

/// RU: Обновляет runtime состояние в базовом AI-контроллере (этап: record path hit) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the base AI controller (step: record path hit) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/proc/record_path_hit()
	path_hits_since_process++

/// RU: Обновляет runtime состояние в базовом AI-контроллере (этап: record path failure) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the base AI controller (step: record path failure) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/proc/record_path_failure()
	path_failures_since_process++

/datum/npc_ai_controller/human
	name = "npc_ai_controller_human"
	var/list/legacy_action_registry = list()
	/// List of current squads.
	var/list/datum/human_ai_squad/squads = list()
	/// Dict of "id": squad.
	var/list/squad_id_dict = list()
	/// The current highest ID of any squad.
	var/highest_squad_id = 0
	/// List of all existing orders.
	var/list/datum/ai_order/existing_orders = list()
	/// Runtime faction datums used by legacy human brain logic.
	var/list/human_ai_factions = list()
	/// Legacy optimization flag used by old human AI code.
	var/combat_ever_started = FALSE

/// RU: Инициализирует human runtime-контроллер: строит faction registry, подключает legacy sensors/tasks и регистрирует migration scaffold. EN: Initializes human runtime controller: builds faction registry, wires legacy sensors/tasks, and registers migration scaffold.
/datum/npc_ai_controller/human/New()
	. = ..()
	for(var/faction_path in subtypesof(/datum/human_ai_faction))
		var/datum/human_ai_faction/faction_obj = new faction_path
		human_ai_factions[faction_obj.faction] = faction_obj
	npc_ai_v2_refresh_human_faction_relation_matrix(TRUE)
	if(planner)
		/// Human migration stage keeps feature parity with legacy and does not hard-cap selected tasks yet.
		planner.top_k = 0
	register_sensor(new /datum/npc_ai_sensor/human_legacy_brain)
	register_sensor(new /datum/npc_ai_sensor/human_legacy_targeting)
	register_task(new /datum/npc_ai_task/human_legacy_base/human_legacy_ongoing_tick)
	register_task(new /datum/npc_ai_task/human_legacy_base/human_legacy_cover_scan_tick)
	register_task(new /datum/npc_ai_task/human_legacy_base/human_legacy_conversation_tick)
	/// Stage-2 migration: action_picker is the single path for both legacy and migrated actions.
	rebuild_legacy_action_registry()
	register_task(new /datum/npc_ai_task/human_legacy_base/human_legacy_action_picker)
	register_human_v2_action_sensor_scaffold()

/// RU: Очищает runtime-состояние перед удалением объекта в контроллере human AI. EN: Cleans runtime state before deleting object in the human AI controller.
/datum/npc_ai_controller/human/Destroy(force, ...)
	squads = null
	squad_id_dict = null
	existing_orders = null
	human_ai_factions = null
	return ..()

/// RU: Пересобирает список legacy action типов, исключая уже вынесенные в v2 scaffold действия. EN: Rebuilds legacy action type list while excluding actions already moved to v2 scaffold.
/datum/npc_ai_controller/human/proc/rebuild_legacy_action_registry()
	var/list/new_registry = list()
	if(!islist(GLOB.AI_actions) || !length(GLOB.AI_actions))
		legacy_action_registry = new_registry
		return

	for(var/action_type as anything in GLOB.AI_actions)
		if(!ispath(action_type, /datum/ai_action))
			continue
		if(!should_include_legacy_action(action_type))
			continue
		new_registry += action_type

	legacy_action_registry = sort_list(new_registry, GLOBAL_PROC_REF(cmp_typepaths_asc))

/// RU: Проверяет условие в контроллере human AI v2 (этап: should include legacy action) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the human AI v2 controller (step: should include legacy action) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/human/proc/should_include_legacy_action(action_type)
	if(!ispath(action_type, /datum/ai_action))
		return FALSE
	if(action_type == /datum/ai_action/converse)
		return FALSE

	var/list/scaffold_action_map = get_human_v2_scaffold_action_map()
	if(islist(scaffold_action_map) && scaffold_action_map[action_type])
		return FALSE
	return TRUE

/// RU: Вычисляет и возвращает данные в контроллере human AI v2 (этап: get legacy action candidates) для следующего этапа поведения. EN: Computes and returns data in the human AI v2 controller (step: get legacy action candidates) for the next behavior stage.
/datum/npc_ai_controller/human/proc/get_legacy_action_candidates(datum/human_ai_brain/current_brain)
	if(!islist(legacy_action_registry) || !length(legacy_action_registry))
		rebuild_legacy_action_registry()
	if(!current_brain)
		return list()

	var/list/candidates = list()
	if(islist(current_brain.action_whitelist))
		for(var/action_type as anything in current_brain.action_whitelist)
			if(!ispath(action_type, /datum/ai_action))
				continue
			if(!GLOB.AI_actions[action_type])
				continue
			if(!should_include_legacy_action(action_type))
				continue
			candidates += action_type
	else
		candidates = legacy_action_registry.Copy()

	if(islist(current_brain.action_blacklist) && length(current_brain.action_blacklist))
		for(var/action_type as anything in current_brain.action_blacklist)
			candidates -= action_type

	return candidates

/// RU: Регистрирует сущность в контроллере human AI v2 (этап: register agent) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the human AI v2 controller (step: register agent) and links it to AI v2 runtime state.
/datum/npc_ai_controller/human/register_agent(mob/living/agent, datum/human_ai_brain/legacy_brain = null)
	if(!istype(agent, /mob/living/carbon/human))
		return
	..(agent)

	var/datum/npc_ai_blackboard/blackboard = get_blackboard(agent)
	if(!legacy_brain)
		var/mob/living/carbon/human/human_agent = agent
		legacy_brain = human_agent.get_ai_brain()
	blackboard.set_value("legacy_brain", legacy_brain)

/// RU: Проверяет условие в контроллере human AI v2 (этап: is enabled) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the human AI v2 controller (step: is enabled) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/human/is_enabled()
	return GLOB.npc_ai_v2_human_enabled && !ai_kill

/// RU: Выполняет служебный этап в контроллере human AI v2 (этап: create new squad) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human AI v2 controller (step: create new squad) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/human/proc/create_new_squad()
	RETURN_TYPE(/datum/human_ai_squad)
	highest_squad_id++
	var/datum/human_ai_squad/new_squad = new
	squads |= new_squad
	squad_id_dict["[highest_squad_id]"] = new_squad
	return new_squad

/// RU: Вычисляет и возвращает данные в контроллере human AI v2 (этап: get squad) для следующего этапа поведения. EN: Computes and returns data in the human AI v2 controller (step: get squad) for the next behavior stage.
/datum/npc_ai_controller/human/proc/get_squad(squad_id)
	RETURN_TYPE(/datum/human_ai_squad)
	if(!squad_id || !(squad_id in squad_id_dict))
		return null
	return squad_id_dict[squad_id]

/// RU: Уточняет think-tier человека по legacy brain состоянию (combat/heal/orders/cover scan). EN: Refines human think-tier from legacy brain state (combat/heal/orders/cover scan).
/datum/npc_ai_controller/human/resolve_think_tier(mob/living/agent, datum/npc_ai_blackboard/blackboard)
	var/base_tier = ..()
	if(base_tier <= 1)
		return base_tier

	if(!blackboard)
		return base_tier

	var/datum/human_ai_brain/current_brain = blackboard.get_value("legacy_brain")
	if(current_brain && !QDELETED(current_brain))
		if(current_brain.in_combat || current_brain.current_target)
			return 0
		if(current_brain.healing_someone)
			return 1
		if(current_brain.target_turf || blackboard.get_value("legacy_cover_scan_requested", FALSE))
			return 1
		if(length(current_brain.to_pickup) || current_brain.current_order || current_brain.squad_id)
			return 2

	return base_tier

/datum/npc_ai_controller/xeno
	name = "npc_ai_controller_xeno"

/// RU: Проверяет условие в контроллере xeno AI v2 (этап: is enabled) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the xeno AI v2 controller (step: is enabled) and returns a boolean used to choose the next step.
/datum/npc_ai_controller/xeno/is_enabled()
	return GLOB.npc_ai_v2_xeno_enabled && !ai_kill

