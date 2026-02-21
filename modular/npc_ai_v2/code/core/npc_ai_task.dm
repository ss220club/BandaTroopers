/datum/npc_ai_task
	var/name = "npc_ai_task"
	/// Bitmask that blocks incompatible tasks from running in the same tick.
	var/conflict_mask = NONE
	/// Required state tags that must be present for planner selection.
	var/list/required_tags = list()

/// RU: Выполняет служебный этап в задачах AI v2 (этап: matches tags) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 tasks (step: matches tags) to coordinate state between AI v2 subsystems.
/datum/npc_ai_task/proc/matches_tags(list/state_tags)
	if(!length(required_tags))
		return TRUE
	if(!islist(state_tags) || !length(state_tags))
		return FALSE
	return !length(required_tags - state_tags)

/// RU: Вычисляет utility-вес шага для planner в базовой AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in the base AI task; 0 disables execution.
/datum/npc_ai_task/proc/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return 0

/// RU: Запускает выполнение шага в базовой AI-задаче перед последующими tick-вызовами. EN: Starts step execution in the base AI task before subsequent tick calls.
/datum/npc_ai_task/proc/start(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return TRUE

/// RU: Исполняет один шаг логики в базовой AI-задаче и возвращает состояние выполнения. EN: Executes one logic step in the base AI task and returns execution state.
/datum/npc_ai_task/proc/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	return "complete"

/// RU: Останавливает текущий шаг и освобождает состояние в базовой AI-задаче. EN: Stops current step and releases state in the base AI task.
/datum/npc_ai_task/proc/stop(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, reason)
	return
