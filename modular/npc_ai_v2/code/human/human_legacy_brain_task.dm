#define NPC_AI_V2_HUMAN_LEGACY_READY_TAG "human_legacy_brain_ready"
#define NPC_AI_V2_HUMAN_LEGACY_ONGOING_TICK_SCORE 0.0001
#define NPC_AI_V2_HUMAN_LEGACY_COVER_SCAN_SCORE 0.0002
#define NPC_AI_V2_LEGACY_ACTION_PICKER_KEY "legacy_next_action_type"
#define NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY "legacy_cover_scan_requested"

/datum/npc_ai_task/human_legacy_base
	required_tags = list(NPC_AI_V2_HUMAN_LEGACY_READY_TAG)

/// RU: Вычисляет и возвращает данные в задачах AI v2 (этап: resolve brain) для следующего этапа поведения. EN: Computes and returns data in AI v2 tasks (step: resolve brain) for the next behavior stage.
/datum/npc_ai_task/human_legacy_base/proc/resolve_brain(mob/living/agent, datum/npc_ai_blackboard/blackboard)
	RETURN_TYPE(/datum/human_ai_brain)
	if(!istype(agent, /mob/living/carbon/human) || !blackboard)
		return null

	var/datum/human_ai_brain/current_brain = blackboard.get_value("legacy_brain")
	if(current_brain && !QDELETED(current_brain) && current_brain.tied_human == agent)
		return current_brain

	var/mob/living/carbon/human/human_agent = agent
	current_brain = human_agent.get_ai_brain()
	blackboard.set_value("legacy_brain", current_brain)
	return current_brain

/// RU: Проверяет условие в задачах AI v2 (этап: is brain ready) и возвращает булево значение для выбора следующего шага. EN: Checks condition in AI v2 tasks (step: is brain ready) and returns a boolean used to choose the next step.
/datum/npc_ai_task/human_legacy_base/proc/is_brain_ready(datum/npc_ai_blackboard/blackboard)
	if(!blackboard)
		return FALSE
	return !!blackboard.get_value("legacy_brain_ready_for_actions", FALSE)

/// RU: Вычисляет и возвращает данные в задачах AI v2 (этап: get action candidates) для следующего этапа поведения. EN: Computes and returns data in AI v2 tasks (step: get action candidates) for the next behavior stage.
/datum/npc_ai_task/human_legacy_base/proc/get_action_candidates(datum/npc_ai_controller/controller, datum/human_ai_brain/current_brain)
	if(!istype(controller, /datum/npc_ai_controller/human))
		return list()
	var/datum/npc_ai_controller/human/human_controller = controller
	var/list/candidates = human_controller.get_legacy_action_candidates(current_brain)
	if(!islist(candidates))
		candidates = list()

	// Picker is now a single launch path: include migration-mapped actions too.
	var/list/scaffold_action_map = human_controller.get_human_v2_scaffold_action_map()
	if(!islist(scaffold_action_map) || !length(scaffold_action_map))
		return sort_list(candidates, GLOBAL_PROC_REF(cmp_typepaths_asc))

	if(islist(current_brain?.action_whitelist))
		for(var/action_type as anything in current_brain.action_whitelist)
			if(!ispath(action_type, /datum/ai_action))
				continue
			if(!GLOB.AI_actions[action_type])
				continue
			if(!scaffold_action_map[action_type])
				continue
			candidates |= action_type
	else
		for(var/action_type as anything in scaffold_action_map)
			if(!ispath(action_type, /datum/ai_action))
				continue
			if(!GLOB.AI_actions[action_type])
				continue
			candidates |= action_type

	if(islist(current_brain?.action_blacklist) && length(current_brain.action_blacklist))
		for(var/action_type as anything in current_brain.action_blacklist)
			candidates -= action_type

	return sort_list(candidates, GLOBAL_PROC_REF(cmp_typepaths_asc))

/// RU: Вычисляет и возвращает данные в задачах AI v2 (этап: select best action type) для следующего этапа поведения. EN: Computes and returns data in AI v2 tasks (step: select best action type) for the next behavior stage.
/datum/npc_ai_task/human_legacy_base/proc/select_best_action_type(datum/npc_ai_controller/controller, datum/human_ai_brain/current_brain, datum/npc_ai_blackboard/blackboard)
	var/list/action_candidates = get_action_candidates(controller, current_brain)
	if(!islist(action_candidates) || !length(action_candidates))
		return null

	var/best_score = 0
	var/best_action_type = null
	for(var/action_type as anything in action_candidates)
		if(!current_brain.v2_action_can_start(action_type))
			continue

		var/action_score = score_action_type(controller, action_type, current_brain, blackboard)
		if(!isnum(action_score) || action_score <= 0)
			continue
		if(action_score > best_score)
			best_score = action_score
			best_action_type = action_type

	return best_action_type

/// RU: Вычисляет и возвращает данные в задачах AI v2 (этап: get migrated action datum) для следующего этапа поведения. EN: Computes and returns data in AI v2 tasks (step: get migrated action datum) for the next behavior stage.
/datum/npc_ai_task/human_legacy_base/proc/get_migrated_action_datum(datum/npc_ai_controller/controller, action_type)
	RETURN_TYPE(/datum/npc_ai_action_datum)
	if(!ispath(action_type, /datum/ai_action) || !istype(controller, /datum/npc_ai_controller/human))
		return null

	var/datum/npc_ai_controller/human/human_controller = controller
	return human_controller.get_migrated_action_datum_for_legacy_action(action_type)

/// RU: Выполняет служебный этап в задачах AI v2 (этап: score action type) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 tasks (step: score action type) to coordinate state between AI v2 subsystems.
/datum/npc_ai_task/human_legacy_base/proc/score_action_type(datum/npc_ai_controller/controller, action_type, datum/human_ai_brain/current_brain, datum/npc_ai_blackboard/blackboard)
	var/datum/npc_ai_action_datum/migrated_action = get_migrated_action_datum(controller, action_type)
	if(migrated_action)
		if(!migrated_action.can_start(controller, current_brain?.tied_human, blackboard))
			return 0
		return max(0, migrated_action.score(controller, current_brain?.tied_human, blackboard))

	if(action_type == /datum/ai_action/fire_at_target)
		// Fire-at-target is migrated to human_v2_fire and should not fallback to legacy score path.
		return 0

	var/action_score = current_brain.v2_action_score(action_type)
	if(!isnum(action_score) || action_score <= 0)
		return 0

	return action_score

/// RU: Запускает действие через migrated action datum, если оно доступно; иначе использует legacy v2_start_action. EN: Starts action via migrated action datum when available; otherwise uses legacy v2_start_action.
/datum/npc_ai_task/human_legacy_base/proc/start_action_type(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, datum/human_ai_brain/current_brain, action_type)
	if(!current_brain || !action_type)
		return FALSE

	var/datum/npc_ai_action_datum/migrated_action = get_migrated_action_datum(controller, action_type)
	if(migrated_action)
		if(!migrated_action.can_start(controller, agent, blackboard))
			return FALSE
		if(!migrated_action.start(controller, agent, blackboard))
			return FALSE

		var/action_state = migrated_action.tick(controller, agent, blackboard, 0)
		if(action_state == "complete" || action_state == "failed")
			migrated_action.stop(controller, agent, blackboard, action_state)
		return action_state != "failed"

	return current_brain.v2_start_action(action_type)

/datum/npc_ai_task/human_legacy_base/human_legacy_ongoing_tick
	name = "human_legacy_ongoing_tick"
	conflict_mask = NONE

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/human_legacy_base/human_legacy_ongoing_tick/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!is_brain_ready(blackboard))
		return 0

	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return 0

	return NPC_AI_V2_HUMAN_LEGACY_ONGOING_TICK_SCORE

/// RU: Исполняет один шаг логики в AI-задаче и возвращает состояние выполнения. EN: Executes one logic step in an AI task and returns execution state.
/datum/npc_ai_task/human_legacy_base/human_legacy_ongoing_tick/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return "failed"

	current_brain.v2_tick_ongoing_actions()
	return "complete"

/datum/npc_ai_task/human_legacy_base/human_legacy_cover_scan_tick
	name = "human_legacy_cover_scan_tick"
	conflict_mask = NONE

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/human_legacy_base/human_legacy_cover_scan_tick/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!is_brain_ready(blackboard))
		return 0
	if(!blackboard.get_value(NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY, FALSE))
		return 0

	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return 0
	if(current_brain.current_cover || !current_brain.current_target || !isxeno(current_brain.current_target))
		return 0

	return NPC_AI_V2_HUMAN_LEGACY_COVER_SCAN_SCORE

/// RU: Исполняет один шаг логики в AI-задаче и возвращает состояние выполнения. Побочные эффекты: обновляет blackboard. EN: Executes one logic step in an AI task and returns execution state. Side effects: updates blackboard.
/datum/npc_ai_task/human_legacy_base/human_legacy_cover_scan_tick/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return "failed"

	blackboard.set_value(NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY, FALSE)
	if(!current_brain.current_cover && current_brain.current_target && isxeno(current_brain.current_target))
		current_brain.try_cover(Get_Angle(current_brain.current_target, current_brain.tied_human), current_brain.current_target)
	return "complete"

/datum/npc_ai_task/human_legacy_base/human_legacy_conversation_tick
	name = "human_legacy_conversation_tick"
	conflict_mask = NONE

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/human_legacy_base/human_legacy_conversation_tick/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!is_brain_ready(blackboard))
		return 0

	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return 0

	return current_brain.v2_conversation_score()

/// RU: Запускает выполнение шага в AI-задаче перед последующими tick-вызовами. EN: Starts step execution in an AI task before subsequent tick calls.
/datum/npc_ai_task/human_legacy_base/human_legacy_conversation_tick/start(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return FALSE

	return current_brain.v2_try_start_conversation()

/// RU: Исполняет один шаг логики в AI-задаче и возвращает состояние выполнения. EN: Executes one logic step in an AI task and returns execution state.
/datum/npc_ai_task/human_legacy_base/human_legacy_conversation_tick/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	return "complete"

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single
	name = "human_legacy_action_single"
	conflict_mask = NONE
	var/action_type = /datum/ai_action

/// RU: Инициализирует runtime-состояние объекта в AI-задаче. EN: Initializes runtime state of object in an AI task.
/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/New(new_action_type)
	. = ..()
	if(ispath(new_action_type, /datum/ai_action))
		action_type = new_action_type

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!is_brain_ready(blackboard))
		return 0

	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return 0
	if(!current_brain.v2_action_can_start(action_type))
		return 0

	return score_action_type(controller, action_type, current_brain, blackboard)

/// RU: Запускает выполнение шага в AI-задаче перед последующими tick-вызовами. EN: Starts step execution in an AI task before subsequent tick calls.
/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/start(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return FALSE

	return start_action_type(controller, agent, blackboard, current_brain, action_type)

/// RU: Исполняет один шаг логики в AI-задаче и возвращает состояние выполнения. EN: Executes one logic step in an AI task and returns execution state.
/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	return "complete"

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_inventory_tick
	name = "human_legacy_inventory_tick"
	action_type = /datum/ai_action/item_pickup

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_heal_tick
	name = "human_legacy_heal_tick"
	action_type = /datum/ai_action/treat_self

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_reload_tick
	name = "human_legacy_reload_tick"
	action_type = /datum/ai_action/reload

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_select_primary_tick
	name = "human_legacy_select_primary_tick"
	action_type = /datum/ai_action/select_primary

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_throw_grenade_tick
	name = "human_legacy_throw_grenade_tick"
	action_type = /datum/ai_action/throw_grenade

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_throw_back_nade_tick
	name = "human_legacy_throw_back_nade_tick"
	action_type = /datum/ai_action/throw_back_nade

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_resist_burning_tick
	name = "human_legacy_resist_burning_tick"
	action_type = /datum/ai_action/resist_burning

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_fire_tick
	name = "human_legacy_fire_tick"
	action_type = /datum/ai_action/fire_at_target

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_keep_distance_tick
	name = "human_legacy_keep_distance_tick"
	action_type = /datum/ai_action/keep_distance

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_chase_tick
	name = "human_legacy_chase_tick"
	action_type = /datum/ai_action/chase_target

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_walk_melee_tick
	name = "human_legacy_walk_melee_tick"
	action_type = /datum/ai_action/walk_melee

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_take_cover_tick
	name = "human_legacy_take_cover_tick"
	action_type = /datum/ai_action/take_cover

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_follow_leader_tick
	name = "human_legacy_follow_leader_tick"
	action_type = /datum/ai_action/follow_leader

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_patrol_tick
	name = "human_legacy_patrol_tick"
	action_type = /datum/ai_action/patrol_waypoints

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_quick_approach_tick
	name = "human_legacy_quick_approach_tick"
	action_type = /datum/ai_action/quick_approach

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_mg_nest_tick
	name = "human_legacy_mg_nest_tick"
	action_type = /datum/ai_action/machinegunner_nest

/datum/npc_ai_task/human_legacy_base/human_legacy_action_single/human_legacy_sniper_nest_tick
	name = "human_legacy_sniper_nest_tick"
	action_type = /datum/ai_action/sniper_nest

/datum/npc_ai_task/human_legacy_base/human_legacy_action_picker
	name = "human_legacy_action_picker"
	conflict_mask = NONE
	var/max_new_actions_per_tick = 4

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. Побочные эффекты: обновляет blackboard. EN: Computes utility weight for planner step in an AI task; 0 disables execution. Side effects: updates blackboard.
/datum/npc_ai_task/human_legacy_base/human_legacy_action_picker/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!is_brain_ready(blackboard))
		return 0

	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return 0

	var/best_action_type = select_best_action_type(controller, current_brain, blackboard)
	if(!best_action_type)
		blackboard.set_value(NPC_AI_V2_LEGACY_ACTION_PICKER_KEY, null)
		return 0

	blackboard.set_value(NPC_AI_V2_LEGACY_ACTION_PICKER_KEY, best_action_type)
	var/action_score = score_action_type(controller, best_action_type, current_brain, blackboard)
	return action_score

/// RU: Исполняет один шаг логики в AI-задаче и возвращает состояние выполнения. Побочные эффекты: обновляет blackboard. EN: Executes one logic step in an AI task and returns execution state. Side effects: updates blackboard.
/datum/npc_ai_task/human_legacy_base/human_legacy_action_picker/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	var/datum/human_ai_brain/current_brain = resolve_brain(agent, blackboard)
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return "failed"

	var/actions_started = 0
	var/action_type = blackboard.get_value(NPC_AI_V2_LEGACY_ACTION_PICKER_KEY)
	blackboard.set_value(NPC_AI_V2_LEGACY_ACTION_PICKER_KEY, null)

	while(actions_started < max_new_actions_per_tick)
		if(!action_type)
			action_type = select_best_action_type(controller, current_brain, blackboard)
			if(!action_type)
				break

		if(start_action_type(controller, agent, blackboard, current_brain, action_type))
			actions_started++

		action_type = null

	return "complete"

#undef NPC_AI_V2_HUMAN_LEGACY_ONGOING_TICK_SCORE
#undef NPC_AI_V2_HUMAN_LEGACY_COVER_SCAN_SCORE
#undef NPC_AI_V2_LEGACY_ACTION_PICKER_KEY
#undef NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY
#undef NPC_AI_V2_HUMAN_LEGACY_READY_TAG
