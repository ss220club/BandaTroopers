/// RU: Инициализирует xeno-контроллер: подключает runtime state sensor, goal provider и movement/plugin задачи. EN: Initializes xeno controller with runtime state sensor, goal provider, and movement/plugin tasks.
/datum/npc_ai_controller/xeno/New()
	. = ..()
	if(planner)
		/// Allow goal-provider + runtime core + movement plugin tasks in one think cycle.
		planner.top_k = 3
	register_sensor(new /datum/npc_ai_sensor/xeno_runtime_state)
	register_sensor(new /datum/npc_ai_sensor/xeno_goal_provider)
	register_task(new /datum/npc_ai_task/xeno_goal_provider)
	register_task(new /datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_facehugger)
	register_task(new /datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_lurking)
	register_task(new /datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_linger)
	register_task(new /datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_crusher)
	register_task(new /datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_drone)
	register_task(new /datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_generic)
	register_task(new /datum/npc_ai_task/xeno_v2_runtime_core)
	target_cache = list()

/datum/npc_ai_controller/xeno
	/// Assoc cache: hive -> caste -> valid targets for current runtime target selection.
	var/list/target_cache = list()

/// RU: Выполняет рабочий этап в контроллере xeno AI v2 (этап: run ai tick) в основном пайплайне AI v2. EN: Executes a work stage in the xeno AI v2 controller (step: run ai tick) in the main AI v2 pipeline.
/datum/npc_ai_controller/xeno/run_ai_tick(delta_time)
	clear_target_cache()
	return ..()

/// RU: Удаляет или освобождает runtime сущности в контроллере xeno AI v2 (этап: clear target cache) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the xeno AI v2 controller (step: clear target cache) to avoid dangling references and stale state.
/datum/npc_ai_controller/xeno/proc/clear_target_cache()
	if(!islist(target_cache))
		target_cache = list()
		return
	target_cache.Cut()

/// RU: Строит и кеширует валидные цели xeno по hive/caste с учетом живых мобов, техники и defensive объектов. EN: Builds and caches valid xeno targets by hive/caste from alive mobs, vehicles, and defensive objects.
/datum/npc_ai_controller/xeno/proc/get_valid_targets(mob/living/carbon/xenomorph/xeno)
	if(!istype(xeno))
		return list()

	var/datum/hive_status/hive = xeno.hive
	if(!hive)
		return list()

	LAZYINITLIST(target_cache[hive])
	var/caste = xeno.type
	if(target_cache[hive][caste])
		return target_cache[hive][caste]

	var/list/valid_targets = list()
	target_cache[hive][caste] = valid_targets

	for(var/mob/living/carbon/potential_target in GLOB.alive_mob_list)
		if(!potential_target.ai_can_target(xeno))
			continue

		valid_targets += potential_target

	for(var/obj/vehicle/multitile/potential_vehicle_target as anything in GLOB.all_multi_vehicles)
		if(potential_vehicle_target.health <= 0)
			continue

		if(hive.faction_is_ally(potential_vehicle_target.vehicle_faction))
			continue

		var/list/passengers = potential_vehicle_target.interior?.get_passengers()
		if(!islist(passengers) || !length(passengers))
			continue
		if(!length(valid_targets & passengers))
			continue

		valid_targets += potential_vehicle_target

	valid_targets += GLOB.all_active_defenses
	return valid_targets

/// RU: Регистрирует сущность в контроллере xeno AI v2 (этап: register agent) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the xeno AI v2 controller (step: register agent) and links it to AI v2 runtime state.
/datum/npc_ai_controller/xeno/register_agent(mob/living/agent)
	if(!istype(agent, /mob/living/carbon/xenomorph))
		return
	..()

/// RU: Вычисляет и возвращает данные в контроллере xeno AI v2 (этап: resolve think tier) для следующего этапа поведения. EN: Computes and returns data in the xeno AI v2 controller (step: resolve think tier) for the next behavior stage.
/datum/npc_ai_controller/xeno/resolve_think_tier(mob/living/agent, datum/npc_ai_blackboard/blackboard)
	var/base_tier = ..()
	if(!istype(agent, /mob/living/carbon/xenomorph) || !blackboard)
		return base_tier

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	if(xeno_agent.current_target || blackboard.get_value("legacy_has_target", FALSE))
		return 0
	if(xeno_agent.is_mob_incapacitated(TRUE))
		return 3
	return base_tier

/datum/npc_ai_sensor/xeno_runtime_state
	name = "xeno_runtime_state_sensor"

/// RU: Собирает сенсорные данные для planner/blackboard в AI-сенсоре. Побочные эффекты: обновляет blackboard. EN: Collects sensor data for planner/blackboard in an AI sensor. Side effects: updates blackboard.
/datum/npc_ai_sensor/xeno_runtime_state/sense(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!enabled || !istype(controller, /datum/npc_ai_controller/xeno) || !istype(agent, /mob/living/carbon/xenomorph) || !blackboard)
		return list()

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	var/has_target = !QDELETED(xeno_agent.current_target) && !!xeno_agent.current_target
	blackboard.set_value("legacy_has_target", has_target)
	blackboard.set_value("legacy_in_combat", has_target)
	return has_target ? list("xeno_runtime_has_target") : list()

/datum/npc_ai_task/xeno_v2_runtime_core
	name = "xeno_v2_runtime_core"
	conflict_mask = NONE

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/xeno_v2_runtime_core/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!istype(controller, /datum/npc_ai_controller/xeno) || !istype(agent, /mob/living/carbon/xenomorph))
		return 0

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	if(QDELETED(xeno_agent) || xeno_agent.client || xeno_agent.stat == DEAD)
		return 0
	return 50

/// RU: Выполняет xeno runtime core через process_ai с v2 skip-флагами, чтобы избежать двойной обработки override/movement. EN: Executes xeno runtime core via process_ai with v2 skip flags to avoid duplicate override/movement handling.
/datum/npc_ai_task/xeno_v2_runtime_core/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	if(!istype(agent, /mob/living/carbon/xenomorph))
		return "failed"
	if(!blackboard)
		return "failed"

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	if(QDELETED(xeno_agent))
		return "failed"
	if(GLOB.npc_ai_v2_xeno_goal_provider_enabled && blackboard.get_value("xeno_goal_provider_handled", FALSE))
		return "complete"

	var/original_skip_override = xeno_agent.v2_skip_override_handling
	var/original_skip_movement = xeno_agent.v2_skip_movement_handling
	xeno_agent.v2_skip_override_handling = GLOB.npc_ai_v2_xeno_goal_provider_enabled
	xeno_agent.v2_skip_movement_handling = GLOB.npc_ai_v2_xeno_movement_plugins_enabled
	xeno_agent.process_ai(delta_time)
	if(!QDELETED(xeno_agent))
		xeno_agent.v2_skip_override_handling = original_skip_override
		xeno_agent.v2_skip_movement_handling = original_skip_movement
	return "complete"
