/datum/npc_ai_action_datum
	var/name = "npc_ai_action_datum"
	var/enabled = TRUE
	/// Optional compatibility marker for staged legacy action migration.
	var/legacy_action_type = null
	/// TRUE when behavior is migrated and should execute via action_datum path (without legacy fallback).
	var/migration_ready = FALSE
	/// Bitmask for future action-level conflict resolution.
	var/conflict_mask = NONE
	/// Optional state tags required before action can be considered.
	var/list/required_tags = list()

/// RU: Выполняет служебный этап в action-datum слое AI v2 (этап: matches tags) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the AI v2 action-datum layer (step: matches tags) to coordinate state between AI v2 subsystems.
/datum/npc_ai_action_datum/proc/matches_tags(list/state_tags)
	if(!length(required_tags))
		return TRUE
	if(!islist(state_tags) || !length(state_tags))
		return FALSE
	return !length(required_tags - state_tags)

/// RU: Вычисляет utility-вес шага для planner в базовом action-datum; 0 отключает запуск. EN: Computes utility weight for planner step in the base action datum; 0 disables execution.
/datum/npc_ai_action_datum/proc/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return 0

/// RU: Проверяет условие в action-datum слое AI v2 (этап: can start) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the AI v2 action-datum layer (step: can start) and returns a boolean used to choose the next step.
/datum/npc_ai_action_datum/proc/can_start(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return enabled && !!controller && !!agent && !!blackboard

/// RU: Запускает выполнение шага в базовом action-datum перед последующими tick-вызовами. EN: Starts step execution in the base action datum before subsequent tick calls.
/datum/npc_ai_action_datum/proc/start(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return can_start(controller, agent, blackboard)

/// RU: Исполняет один шаг логики в базовом action-datum и возвращает состояние выполнения. EN: Executes one logic step in the base action datum and returns execution state.
/datum/npc_ai_action_datum/proc/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	return "complete"

/// RU: Останавливает текущий шаг и освобождает состояние в базовом action-datum. EN: Stops current step and releases state in the base action datum.
/datum/npc_ai_action_datum/proc/stop(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, reason)
	return
