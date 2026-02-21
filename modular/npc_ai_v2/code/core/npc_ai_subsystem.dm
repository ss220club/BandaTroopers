SUBSYSTEM_DEF(npc_ai)
	name = "NPC AI v2"
	init_order = SS_INIT_WHO
	priority = SS_PRIORITY_NPC_AI
	wait = 0.1 SECONDS
	flags = SS_KEEP_TIMING
	/// Р В Р ВµР ВµРЎРѓРЎвЂљРЎР‚ Р С”Р С•Р Р…РЎвЂљРЎР‚Р С•Р В»Р В»Р ВµРЎР‚Р С•Р Р† (human, xeno Р С‘ Р В±РЎС“Р Т‘РЎС“РЎвЂ°Р С‘Р Вµ plugin-Р С”Р С•Р Р…РЎвЂљРЎР‚Р С•Р В»Р В»Р ВµРЎР‚РЎвЂ№).
	var/list/datum/npc_ai_controller/controllers = list()
	/// Р С™Р ВµРЎв‚¬-Р С”Р С•Р С—Р С‘РЎРЏ Р Р…Р В°Р В±Р С•РЎР‚Р В° Р Р…Р В° Р С•Р В±РЎР‚Р В°Р В±Р С•РЎвЂљР С”РЎС“ Р Т‘Р В»РЎРЏ pause/resume РЎвЂЎР ВµРЎР‚Р ВµР В· MC.
	var/list/datum/npc_ai_controller/current_run = list()

	/// Р РЋРЎвЂЎРЎвЂРЎвЂљРЎвЂЎР С‘Р С”Р С‘ Р Р…Р В°Р В±Р В»РЎР‹Р Т‘Р В°Р ВµР СР С•РЎРѓРЎвЂљР С‘.
	var/processed_npc = 0
	var/yielded_ticks = 0
	var/path_requests = 0
	var/path_hits = 0
	var/path_failures = 0
	var/list/tier_counters = list("0" = 0, "1" = 0, "2" = 0, "3" = 0)
	var/list/think_cost_samples_ms = list()
	var/think_cost_sample_cap = 256
	var/avg_think_cost_ms = 0
	var/p95_think_cost_ms = 0

	/// Р СџР В°РЎР‚Р В°Р СР ВµРЎвЂљРЎР‚РЎвЂ№ Р С‘ runtime-РЎРѓР С•РЎРѓРЎвЂљР С•РЎРЏР Р…Р С‘Р Вµ benchmark РЎР‚Р ВµР В¶Р С‘Р СР В°.
	var/benchmark_enabled = FALSE
	var/benchmark_running = FALSE
	var/benchmark_completed = FALSE
	var/benchmark_scenario = "200"
	var/benchmark_seed = 1337
	var/benchmark_duration_seconds = 60
	var/benchmark_output_path = "data/npc_ai_benchmark.json"
	var/benchmark_map_path = "maps/debug/npc_ai_benchmark.dmm"
	var/benchmark_auto_reboot = TRUE
	var/benchmark_xeno_goal_provider_enabled = FALSE
	var/benchmark_xeno_movement_plugins_enabled = FALSE
	var/benchmark_previous_human_enabled = FALSE
	var/benchmark_previous_xeno_enabled = FALSE
	var/benchmark_previous_xeno_goal_provider_enabled = FALSE
	var/benchmark_previous_xeno_movement_plugins_enabled = FALSE
	var/benchmark_started_realtime = null
	var/benchmark_ended_realtime = null
	var/benchmark_started_world_time = null
	var/benchmark_end_world_time = null
	var/list/benchmark_spawned_agents = list()
	var/benchmark_spawned_humans = 0
	var/benchmark_spawned_xenos = 0

/// RU: Инициализирует SSnpc_ai: читает benchmark-настройки, регистрирует human/xeno/squad/director контроллеры и запускает async bootstrap benchmark при необходимости. EN: Initializes SSnpc_ai: reads benchmark settings, registers human/xeno/squad/director controllers, and starts async benchmark bootstrap when needed.
/datum/controller/subsystem/npc_ai/Initialize()
	configure_benchmark_from_world_params()
	register_controller(new /datum/npc_ai_controller/human)
	register_controller(new /datum/npc_ai_controller/xeno)
	register_controller(new /datum/npc_ai_controller/squad)
	register_controller(new /datum/npc_ai_controller/director)
	if(benchmark_enabled)
		INVOKE_ASYNC(src, PROC_REF(start_benchmark_when_ready))
	return SS_INIT_SUCCESS

/// RU: Очищает runtime-состояние перед удалением объекта в подсистеме SSnpc_ai. Побочные эффекты: чистит runtime-объекты. EN: Cleans runtime state before deleting object in the SSnpc_ai subsystem. Side effects: cleans runtime objects.
/datum/controller/subsystem/npc_ai/Destroy(force)
	QDEL_LIST(controllers)
	current_run = null
	think_cost_samples_ms = null
	tier_counters = null
	return ..()

/// RU: Выполняет один тик подсистемы: обрабатывает включенные контроллеры, агрегирует метрики и завершает benchmark по таймеру. EN: Runs one subsystem tick: processes enabled controllers, aggregates metrics, and finishes benchmark on timer.
/datum/controller/subsystem/npc_ai/fire(resumed = FALSE)
	if(!GLOB.npc_ai_v2_human_enabled && !GLOB.npc_ai_v2_xeno_enabled && !GLOB.npc_ai_v2_squad_enabled && !GLOB.npc_ai_v2_director_enabled)
		return

	if(!resumed)
		current_run = controllers.Copy()

	while(length(current_run))
		var/datum/npc_ai_controller/controller = current_run[length(current_run)]
		current_run.len--

		if(QDELETED(controller))
			controllers -= controller
			continue
		if(!controller.is_enabled())
			continue

		var/list/controller_metrics = controller.run_ai_tick(wait * 0.1)
		consume_controller_metrics(controller_metrics)

		if(MC_TICK_CHECK)
			record_yielded_ticks()
			if(benchmark_running && !isnull(benchmark_end_world_time) && world.time >= benchmark_end_world_time)
				finish_benchmark()
			return

	if(benchmark_running && !isnull(benchmark_end_world_time) && world.time >= benchmark_end_world_time)
		finish_benchmark()

/// RU: Формирует строку статуса подсистемы для панели MC: счетчики обработки, think-cost и pathfinding метрики. EN: Builds subsystem status line for MC panel: processing counters, think-cost, and pathfinding metrics.
/datum/controller/subsystem/npc_ai/stat_entry(msg)
	msg = "processed_npc:[processed_npc] yielded_ticks:[yielded_ticks] think_ms(avg/p95):[round(avg_think_cost_ms, 0.01)]/[round(p95_think_cost_ms, 0.01)] tier:[get_tier_counter_value(0)]/[get_tier_counter_value(1)]/[get_tier_counter_value(2)]/[get_tier_counter_value(3)] path(req/hit/fail):[path_requests]/[path_hits]/[path_failures]"
	return ..()

/// RU: Регистрирует AI-контроллер в SSnpc_ai, чтобы он участвовал в fire-цикле подсистемы. EN: Registers an AI controller in SSnpc_ai so it participates in subsystem fire cycles.
/datum/controller/subsystem/npc_ai/proc/register_controller(datum/npc_ai_controller/controller)
	if(!controller)
		return
	controllers |= controller

/// RU: Удаляет AI-контроллер из SSnpc_ai и вычищает его из очереди текущего fire-прогона. EN: Removes an AI controller from SSnpc_ai and clears it from the current fire-run queue.
/datum/controller/subsystem/npc_ai/proc/unregister_controller(datum/npc_ai_controller/controller)
	if(!controller)
		return
	controllers -= controller
	current_run -= controller

/// RU: Возвращает зарегистрированный контроллер по типу, если он существует в реестре SSnpc_ai. EN: Returns a registered controller by type when it exists in the SSnpc_ai registry.
/datum/controller/subsystem/npc_ai/proc/get_controller(controller_type)
	if(!ispath(controller_type, /datum/npc_ai_controller))
		return null
	for(var/datum/npc_ai_controller/controller as anything in controllers)
		if(istype(controller, controller_type))
			return controller
	return null

/// RU: Суммирует метрики отдельного контроллера в агрегированные счетчики подсистемы (processed, tier, path, think samples). EN: Accumulates one controller metrics into subsystem counters (processed, tier, path, think samples).
/datum/controller/subsystem/npc_ai/proc/consume_controller_metrics(list/metrics)
	if(!islist(metrics))
		return

	record_processed_npc(metrics["processed_npc"])
	record_yielded_ticks(metrics["yielded_ticks"])
	record_path_requests(metrics["path_requests"])
	record_path_hits(metrics["path_hits"])
	record_path_failures(metrics["path_failures"])

	var/list/tier_delta = metrics["tier_counters"]
	if(islist(tier_delta))
		for(var/tier in 0 to 3)
			var/amount = tier_delta["[tier]"]
			record_tier_count(tier, amount)

	var/list/samples = metrics["think_samples_ms"]
	if(!islist(samples) || !length(samples))
		return

	for(var/sample in samples)
		add_think_sample(sample)
	recalculate_think_cost_metrics()

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: record processed npc) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: record processed npc) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/record_processed_npc(amount = 1)
	if(!isnum(amount) || amount <= 0)
		return
	processed_npc += amount

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: record yielded ticks) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: record yielded ticks) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/record_yielded_ticks(amount = 1)
	if(!isnum(amount) || amount <= 0)
		return
	yielded_ticks += amount

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: record path requests) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: record path requests) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/record_path_requests(amount = 1)
	if(!isnum(amount) || amount <= 0)
		return
	path_requests += amount

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: record path hits) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: record path hits) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/record_path_hits(amount = 1)
	if(!isnum(amount) || amount <= 0)
		return
	path_hits += amount

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: record path failures) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: record path failures) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/record_path_failures(amount = 1)
	if(!isnum(amount) || amount <= 0)
		return
	path_failures += amount

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: record tier count) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: record tier count) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/record_tier_count(tier, amount = 1)
	if(!isnum(tier) || !isnum(amount) || amount <= 0)
		return
	tier = clamp(tier, 0, 3)
	var/tier_key = "[tier]"
	tier_counters[tier_key] = (tier_counters[tier_key] || 0) + amount

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: add think sample) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: add think sample) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/add_think_sample(cost_ms)
	if(!isnum(cost_ms) || cost_ms < 0)
		return

	if(length(think_cost_samples_ms) >= think_cost_sample_cap)
		think_cost_samples_ms.Cut(1, 2)
	think_cost_samples_ms += cost_ms

/// RU: Обновляет runtime состояние в подсистеме SSnpc_ai (этап: recalculate think cost metrics) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the SSnpc_ai subsystem (step: recalculate think cost metrics) and synchronizes data for subsequent ticks.
/datum/controller/subsystem/npc_ai/proc/recalculate_think_cost_metrics()
	if(!length(think_cost_samples_ms))
		avg_think_cost_ms = 0
		p95_think_cost_ms = 0
		return

	var/total_cost = 0
	for(var/sample in think_cost_samples_ms)
		total_cost += sample
	avg_think_cost_ms = total_cost / length(think_cost_samples_ms)

	var/list/sorted_samples = sortTim(think_cost_samples_ms.Copy(), GLOBAL_PROC_REF(cmp_numeric_asc), FALSE)
	var/p95_index = clamp(CEILING(length(sorted_samples) * 0.95, 1), 1, length(sorted_samples))
	p95_think_cost_ms = sorted_samples[p95_index]

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: configure benchmark from world params) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: configure benchmark from world params) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/configure_benchmark_from_world_params()
	if(world.params && world_param_to_bool(world.params[NPC_AI_V2_BENCHMARK_PARAM], FALSE))
		benchmark_enabled = TRUE
		benchmark_scenario = normalize_benchmark_scenario(world.params[NPC_AI_V2_BENCHMARK_SCENARIO_PARAM])
		benchmark_seed = world_param_to_number(world.params[NPC_AI_V2_BENCHMARK_SEED_PARAM], 1337)
		benchmark_duration_seconds = clamp(world_param_to_number(world.params[NPC_AI_V2_BENCHMARK_DURATION_PARAM], 60), 1, 36000)
		benchmark_auto_reboot = world_param_to_bool(world.params[NPC_AI_V2_BENCHMARK_AUTO_REBOOT_PARAM], TRUE)
		benchmark_xeno_goal_provider_enabled = world_param_to_bool(world.params[NPC_AI_V2_BENCHMARK_XENO_GOAL_PROVIDER_PARAM], FALSE)
		benchmark_xeno_movement_plugins_enabled = world_param_to_bool(world.params[NPC_AI_V2_BENCHMARK_XENO_MOVEMENT_PLUGINS_PARAM], FALSE)

		var/output_path = trim("[world.params[NPC_AI_V2_BENCHMARK_OUTPUT_PARAM]]")
		if(length(output_path))
			benchmark_output_path = output_path

		var/map_path = trim("[world.params[NPC_AI_V2_BENCHMARK_MAP_PATH_PARAM]]")
		if(length(map_path))
			benchmark_map_path = map_path
		return

	configure_benchmark_from_request_file()

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: configure benchmark from request file) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: configure benchmark from request file) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/configure_benchmark_from_request_file()
	if(!fexists(NPC_AI_V2_BENCHMARK_REQUEST_FILE))
		return

	var/raw_request = file2text(NPC_AI_V2_BENCHMARK_REQUEST_FILE)
	if(!length(raw_request))
		return

	var/list/request_data = json_decode(raw_request)
	if(!islist(request_data))
		return

	benchmark_enabled = TRUE
	benchmark_scenario = normalize_benchmark_scenario(request_data["scenario"] || request_data["npc_ai_benchmark_scenario"])
	benchmark_seed = world_param_to_number(request_data["seed"] || request_data["npc_ai_benchmark_seed"], 1337)
	benchmark_duration_seconds = clamp(world_param_to_number(request_data["duration_seconds"] || request_data["npc_ai_benchmark_duration"], 60), 1, 36000)
	benchmark_auto_reboot = world_param_to_bool(request_data["auto_reboot"] || request_data["npc_ai_benchmark_auto_reboot"], TRUE)

	var/xeno_goal_provider_raw = request_data["xeno_goal_provider_enabled"]
	if(isnull(xeno_goal_provider_raw))
		xeno_goal_provider_raw = request_data["npc_ai_benchmark_xeno_goal_provider_enabled"]
	if(isnull(xeno_goal_provider_raw))
		xeno_goal_provider_raw = request_data["npc_ai_v2_xeno_goal_provider_enabled"]
	benchmark_xeno_goal_provider_enabled = world_param_to_bool(xeno_goal_provider_raw, FALSE)

	var/xeno_movement_plugins_raw = request_data["xeno_movement_plugins_enabled"]
	if(isnull(xeno_movement_plugins_raw))
		xeno_movement_plugins_raw = request_data["npc_ai_benchmark_xeno_movement_plugins_enabled"]
	if(isnull(xeno_movement_plugins_raw))
		xeno_movement_plugins_raw = request_data["npc_ai_v2_xeno_movement_plugins_enabled"]
	benchmark_xeno_movement_plugins_enabled = world_param_to_bool(xeno_movement_plugins_raw, FALSE)

	var/output_path = trim("[request_data["output_path"] || request_data["npc_ai_benchmark_output"]]")
	if(length(output_path))
		benchmark_output_path = output_path

	var/map_path = trim("[request_data["map_path"] || request_data["npc_ai_benchmark_map_path"]]")
	if(length(map_path))
		benchmark_map_path = map_path

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: world param to bool) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: world param to bool) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/world_param_to_bool(value, default_value = FALSE)
	if(isnull(value))
		return default_value
	if(isnum(value))
		return value != 0

	var/text_value = lowertext(trim("[value]"))
	if(!length(text_value))
		return default_value
	if(text_value in list("1", "true", "yes", "on", "enable", "enabled"))
		return TRUE
	if(text_value in list("0", "false", "no", "off", "disable", "disabled"))
		return FALSE
	return default_value

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: world param to number) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: world param to number) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/world_param_to_number(value, default_value = 0)
	if(isnull(value))
		return default_value
	if(isnum(value))
		return value

	var/text_value = trim("[value]")
	if(!length(text_value))
		return default_value
	if(text_value == "0")
		return 0

	var/parsed_value = text2num(text_value)
	if(!parsed_value)
		return default_value
	return parsed_value

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: normalize benchmark scenario) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: normalize benchmark scenario) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/normalize_benchmark_scenario(raw_scenario)
	var/scenario_text = lowertext(trim("[raw_scenario]"))
	if(!length(scenario_text))
		return "200"

	scenario_text = replacetext(scenario_text, " ", "")
	scenario_text = replacetext(scenario_text, "_", "+")
	scenario_text = replacetext(scenario_text, "x", "+")
	if(scenario_text == "250250")
		scenario_text = "250+250"

	switch(scenario_text)
		if("200", "500", "250+250")
			return scenario_text
	return "200"

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: decode benchmark targets) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: decode benchmark targets) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/decode_benchmark_targets(scenario)
	var/list/targets = list(
		"human" = 200,
		"xeno" = 0
	)

	switch(scenario)
		if("500")
			targets["human"] = 500
		if("250+250")
			targets["human"] = 250
			targets["xeno"] = 250
	return targets

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: start benchmark when ready) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: start benchmark when ready) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/start_benchmark_when_ready()
	set waitfor = FALSE

	if(!benchmark_enabled || benchmark_running || benchmark_completed)
		return

	while(benchmark_enabled && !benchmark_running && !benchmark_completed)
		if(SSticker && SSticker.initialized && SSticker.current_state >= GAME_STATE_SETTING_UP)
			break
		sleep(1 SECONDS)

	if(!benchmark_enabled || benchmark_running || benchmark_completed)
		return

	if(!(SSticker && SSticker.initialized && SSticker.current_state >= GAME_STATE_SETTING_UP))
		return

	start_benchmark()

/// RU: Стартует benchmark lifecycle: сбрасывает метрики, включает нужные flags, спавнит агентов, фиксирует временные метки и пишет status=running. EN: Starts benchmark lifecycle: resets metrics, enables required flags, spawns agents, stores timestamps, and writes status=running.
/datum/controller/subsystem/npc_ai/proc/start_benchmark()
	if(benchmark_running || benchmark_completed)
		return

	var/list/targets = decode_benchmark_targets(benchmark_scenario)
	var/target_humans = targets["human"] || 0
	var/target_xenos = targets["xeno"] || 0
	if(target_humans <= 0 && target_xenos <= 0)
		return

	reset_metrics()
	rand_seed(benchmark_seed)
	benchmark_completed = FALSE
	benchmark_ended_realtime = null
	benchmark_spawned_agents = list()
	benchmark_spawned_humans = 0
	benchmark_spawned_xenos = 0
	benchmark_previous_human_enabled = GLOB.npc_ai_v2_human_enabled
	benchmark_previous_xeno_enabled = GLOB.npc_ai_v2_xeno_enabled
	benchmark_previous_xeno_goal_provider_enabled = GLOB.npc_ai_v2_xeno_goal_provider_enabled
	benchmark_previous_xeno_movement_plugins_enabled = GLOB.npc_ai_v2_xeno_movement_plugins_enabled

	GLOB.npc_ai_v2_human_enabled = target_humans > 0
	GLOB.npc_ai_v2_xeno_enabled = target_xenos > 0
	GLOB.npc_ai_v2_xeno_goal_provider_enabled = (target_xenos > 0) && benchmark_xeno_goal_provider_enabled
	GLOB.npc_ai_v2_xeno_movement_plugins_enabled = (target_xenos > 0) && benchmark_xeno_movement_plugins_enabled
	refresh_all_human_ai_runtime_ownership()
	refresh_all_xeno_ai_runtime_state()

	var/datum/npc_ai_controller/human/human_controller = get_controller(/datum/npc_ai_controller/human)
	var/datum/npc_ai_controller/xeno/xeno_controller = get_controller(/datum/npc_ai_controller/xeno)
	var/list/turf/spawn_turfs = collect_benchmark_spawn_turfs()

	benchmark_spawned_humans = spawn_benchmark_agents(human_controller, target_humans, /mob/living/carbon/human, spawn_turfs)
	benchmark_spawned_xenos = spawn_benchmark_agents(xeno_controller, target_xenos, /mob/living/carbon/xenomorph/larva, spawn_turfs)

	benchmark_started_realtime = world.realtime
	benchmark_started_world_time = world.time
	benchmark_end_world_time = benchmark_started_world_time + (benchmark_duration_seconds * 10)
	benchmark_running = TRUE
	if(fexists(NPC_AI_V2_BENCHMARK_REQUEST_FILE))
		fdel(NPC_AI_V2_BENCHMARK_REQUEST_FILE)
	write_benchmark_artifact("running")

	log_world("NPC AI v2 benchmark started: scenario=[benchmark_scenario], seed=[benchmark_seed], humans=[benchmark_spawned_humans], xenos=[benchmark_spawned_xenos], duration=[benchmark_duration_seconds]s")

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: collect benchmark spawn turfs) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: collect benchmark spawn turfs) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/collect_benchmark_spawn_turfs()
	var/list/turf/spawn_turfs = list()

	for(var/turf/open/floor/floor_turf as anything in world)
		if(!floor_turf.density)
			spawn_turfs += floor_turf

	if(!length(spawn_turfs))
		for(var/turf/any_turf as anything in world)
			if(!any_turf.density)
				spawn_turfs += any_turf

	if(!length(spawn_turfs))
		var/turf/fallback = locate(1, 1, 1)
		if(fallback)
			spawn_turfs += fallback

	return spawn_turfs

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: spawn benchmark agents) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: spawn benchmark agents) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/spawn_benchmark_agents(datum/npc_ai_controller/controller, target_count, mob_type, list/turf/spawn_turfs)
	if(!controller || !isnum(target_count) || target_count <= 0)
		return 0
	if(!ispath(mob_type, /mob/living))
		return 0
	if(!islist(spawn_turfs) || !length(spawn_turfs))
		return 0

	var/spawned_count = 0
	for(var/index in 1 to target_count)
		var/turf/spawn_turf = get_spawn_turf_for_index(spawn_turfs, index)
		if(!spawn_turf)
			break

		var/mob/living/agent = new mob_type(spawn_turf)
		if(!agent || QDELETED(agent))
			continue

		controller.register_agent(agent)
		benchmark_spawned_agents += agent
		spawned_count++
	return spawned_count

/// RU: Вычисляет и возвращает данные в подсистеме SSnpc_ai (этап: get spawn turf for index) для следующего этапа поведения. EN: Computes and returns data in the SSnpc_ai subsystem (step: get spawn turf for index) for the next behavior stage.
/datum/controller/subsystem/npc_ai/proc/get_spawn_turf_for_index(list/turf/spawn_turfs, index)
	if(!islist(spawn_turfs) || !length(spawn_turfs))
		return null
	var/list_index = ((index - 1) % length(spawn_turfs)) + 1
	return spawn_turfs[list_index]

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: reset metrics) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: reset metrics) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/reset_metrics()
	processed_npc = 0
	yielded_ticks = 0
	path_requests = 0
	path_hits = 0
	path_failures = 0
	tier_counters = list()
	tier_counters["0"] = 0
	tier_counters["1"] = 0
	tier_counters["2"] = 0
	tier_counters["3"] = 0

	think_cost_samples_ms = list()
	avg_think_cost_ms = 0
	p95_think_cost_ms = 0

/// RU: Завершает benchmark: пишет status=completed, чистит спавн, восстанавливает plugin-флаги и при auto_reboot инициирует reboot. EN: Finishes benchmark: writes status=completed, cleans spawned mobs, restores plugin flags, and triggers reboot when auto_reboot is set.
/datum/controller/subsystem/npc_ai/proc/finish_benchmark()
	if(!benchmark_running)
		return

	benchmark_running = FALSE
	benchmark_completed = TRUE
	benchmark_ended_realtime = world.realtime
	write_benchmark_artifact("completed")
	cleanup_benchmark_agents()
	GLOB.npc_ai_v2_human_enabled = benchmark_previous_human_enabled
	GLOB.npc_ai_v2_xeno_enabled = benchmark_previous_xeno_enabled
	GLOB.npc_ai_v2_xeno_goal_provider_enabled = benchmark_previous_xeno_goal_provider_enabled
	GLOB.npc_ai_v2_xeno_movement_plugins_enabled = benchmark_previous_xeno_movement_plugins_enabled
	refresh_all_human_ai_runtime_ownership()
	refresh_all_xeno_ai_runtime_state()

	log_world("NPC AI v2 benchmark finished: scenario=[benchmark_scenario], processed_npc=[processed_npc], avg_ms=[round(avg_think_cost_ms, 0.01)], p95_ms=[round(p95_think_cost_ms, 0.01)]")

	if(benchmark_auto_reboot)
		spawn(2 SECONDS)
			world.Reboot("npc_ai_benchmark_complete")

/// RU: Выполняет служебный этап в подсистеме SSnpc_ai (этап: cleanup benchmark agents) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the SSnpc_ai subsystem (step: cleanup benchmark agents) to coordinate state between AI v2 subsystems.
/datum/controller/subsystem/npc_ai/proc/cleanup_benchmark_agents()
	if(!islist(benchmark_spawned_agents) || !length(benchmark_spawned_agents))
		return

	var/datum/npc_ai_controller/human/human_controller = get_controller(/datum/npc_ai_controller/human)
	var/datum/npc_ai_controller/xeno/xeno_controller = get_controller(/datum/npc_ai_controller/xeno)

	for(var/mob/living/agent as anything in benchmark_spawned_agents.Copy())
		if(!agent)
			continue
		clear_external_references_to_benchmark_agent(agent)
		if(human_controller)
			human_controller.unregister_agent(agent)
		if(xeno_controller)
			xeno_controller.unregister_agent(agent)
		if(!QDELETED(agent))
			qdel(agent)
	benchmark_spawned_agents.Cut()

/// RU: Удаляет внешние ссылки на benchmark-агента в runtime системах (например, retaliate.enemies), чтобы GC не оставлял висячие strong refs после cleanup. EN: Clears external references to benchmark agents in runtime systems (e.g., retaliate.enemies) so GC does not keep dangling strong refs after cleanup.
/datum/controller/subsystem/npc_ai/proc/clear_external_references_to_benchmark_agent(mob/living/agent)
	if(!agent || QDELETED(agent))
		return

	// Wildlife retaliate mobs keep strong refs in enemies list; remove benchmark agents explicitly.
	for(var/mob/living/simple_animal/hostile/retaliate/retaliator in world)
		if(!retaliator || QDELETED(retaliator))
			continue
		if(!islist(retaliator.enemies) || !length(retaliator.enemies))
			continue
		retaliator.enemies -= agent

/// RU: Вычисляет и возвращает данные в подсистеме SSnpc_ai (этап: get tier counter value) для следующего этапа поведения. EN: Computes and returns data in the SSnpc_ai subsystem (step: get tier counter value) for the next behavior stage.
/datum/controller/subsystem/npc_ai/proc/get_tier_counter_value(tier)
	var/value = tier_counters["[tier]"]
	if(isnull(value))
		return 0
	return value

/// RU: Формирует benchmark payload, логирует JSON-маркер для runner fallback и записывает артефакт в output_path. EN: Builds benchmark payload, logs JSON marker for runner fallback, and writes artifact to output_path.
/datum/controller/subsystem/npc_ai/proc/write_benchmark_artifact(status)
	if(!benchmark_enabled)
		return

	var/has_started_realtime = !isnull(benchmark_started_realtime)
	var/has_ended_realtime = !isnull(benchmark_ended_realtime)
	var/has_started_world_time = !isnull(benchmark_started_world_time)
	var/started_utc = has_started_realtime ? time2text(benchmark_started_realtime, "YYYY-MM-DD hh:mm:ss") : null
	var/ended_utc = has_ended_realtime ? time2text(benchmark_ended_realtime, "YYYY-MM-DD hh:mm:ss") : null
	var/running_duration_seconds = has_started_world_time ? round((world.time - benchmark_started_world_time) * 0.1, 0.1) : 0

	var/current_map_path = benchmark_map_path
	var/datum/map_config/ground_map = SSmapping.configs[GROUND_MAP]
	if(ground_map)
		if(ground_map.override_map)
			current_map_path = "data/[ground_map.map_file]"
		else
			var/current_map_file = islist(ground_map.map_file) ? ground_map.map_file[1] : ground_map.map_file
			current_map_path = "maps/[ground_map.map_path]/[current_map_file]"

	var/list/metrics = list(
		"processed_npc" = processed_npc,
		"yielded_ticks" = yielded_ticks,
		"avg_think_cost_ms" = round(avg_think_cost_ms, 0.001),
		"p95_think_cost_ms" = round(p95_think_cost_ms, 0.001),
		"tier0_count" = get_tier_counter_value(0),
		"tier1_count" = get_tier_counter_value(1),
		"tier2_count" = get_tier_counter_value(2),
		"tier3_count" = get_tier_counter_value(3),
		"path_requests" = path_requests,
		"path_hits" = path_hits,
		"path_failures" = path_failures
	)

	var/list/checks = list(
		"overrun_ratio_ok" = null,
		"tier0_latency_ok" = null,
		"reacquire_latency_ok" = null,
		"path_success_ok" = null
	)

	var/list/runtime_flags = list(
		"human_enabled" = GLOB.npc_ai_v2_human_enabled,
		"xeno_enabled" = GLOB.npc_ai_v2_xeno_enabled,
		"xeno_goal_provider_enabled" = GLOB.npc_ai_v2_xeno_goal_provider_enabled,
		"xeno_movement_plugins_enabled" = GLOB.npc_ai_v2_xeno_movement_plugins_enabled,
		"xeno_behavior_stack_active" = get_npc_ai_v2_xeno_behavior_stack_active(),
		"squad_enabled" = GLOB.npc_ai_v2_squad_enabled,
		"director_enabled" = GLOB.npc_ai_v2_director_enabled,
		"director_mood" = GLOB.npc_ai_v2_director_mood,
		"director_pressure_bias" = GLOB.npc_ai_v2_director_pressure_bias
	)

	var/list/benchmark_payload = list(
		"schema_version" = 1,
		"suite" = "npc_ai_v2",
		"scenario" = benchmark_scenario,
		"deterministic_seed" = benchmark_seed,
		"map_path" = current_map_path,
		"started_utc" = started_utc,
		"ended_utc" = ended_utc,
		"status" = status,
		"metrics" = metrics,
		"checks" = checks,
		"runtime_flags" = runtime_flags,
		"notes" = list(
			"Generated by in-game npc_ai_v2 benchmark mode.",
			"duration_seconds=[running_duration_seconds] spawned_humans=[benchmark_spawned_humans] spawned_xenos=[benchmark_spawned_xenos]",
			"xeno_goal_provider_enabled=[benchmark_xeno_goal_provider_enabled] xeno_movement_plugins_enabled=[benchmark_xeno_movement_plugins_enabled]"
		)
	)

	var/payload_json = json_encode(benchmark_payload)
	// Р С’Р В»РЎРЉРЎвЂљР ВµРЎР‚Р Р…Р В°РЎвЂљР С‘Р Р†Р Р…РЎвЂ№Р в„– Р С”Р В°Р Р…Р В°Р В» Р В»Р С•Р С–Р С‘РЎР‚Р С•Р Р†Р В°Р Р…Р С‘РЎРЏ Р Т‘Р В»РЎРЏ CI/runner: РЎвЂЎР С‘РЎвЂљР В°Р ВµР С Р С‘Р В· dd.log Р С—Р С• Р СР В°РЎР‚Р С”Р ВµРЎР‚РЎС“.
	log_world("NPC_AI_V2_BENCHMARK_JSON [payload_json]")

	var/output_path = benchmark_output_path
	if(!length(output_path))
		output_path = "data/npc_ai_benchmark.json"

	rustg_file_write(payload_json, output_path)
