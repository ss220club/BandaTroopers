/datum/npc_ai_task/xeno_v2_movement_base
	name = "xeno_v2_movement_base"
	conflict_mask = NPC_AI_V2_CONFLICT_XENO_MOVEMENT
	var/expected_handler_type = /datum/xeno_ai_movement

/// RU: Выполняет служебный этап в задачах AI v2 (этап: matches handler) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 tasks (step: matches handler) to coordinate state between AI v2 subsystems.
/datum/npc_ai_task/xeno_v2_movement_base/proc/matches_handler(mob/living/carbon/xenomorph/xeno_agent)
	if(!xeno_agent || !xeno_agent.ai_movement_handler || !ispath(expected_handler_type, /datum/xeno_ai_movement))
		return FALSE
	return istype(xeno_agent.ai_movement_handler, expected_handler_type)

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/xeno_v2_movement_base/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!GLOB.npc_ai_v2_xeno_movement_plugins_enabled || !istype(controller, /datum/npc_ai_controller/xeno) || !istype(agent, /mob/living/carbon/xenomorph))
		return 0

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	if(QDELETED(xeno_agent) || xeno_agent.client || xeno_agent.stat == DEAD)
		return 0
	if(!matches_handler(xeno_agent))
		return 0
	if(xeno_agent.current_target)
		return 20
	return 10

/// RU: Делегирует шаг движения xeno в ai_move_target/ai_move_idle по active movement handler plugin. EN: Delegates xeno movement step to ai_move_target/ai_move_idle according to active movement handler plugin.
/datum/npc_ai_task/xeno_v2_movement_base/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	if(!GLOB.npc_ai_v2_xeno_movement_plugins_enabled || !istype(agent, /mob/living/carbon/xenomorph))
		return "failed"
	if(blackboard && GLOB.npc_ai_v2_xeno_goal_provider_enabled && blackboard.get_value("xeno_goal_provider_handled", FALSE))
		return "complete"

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	if(!matches_handler(xeno_agent))
		return "failed"

	if(xeno_agent.current_target)
		xeno_agent.ai_move_target(delta_time)
		return "complete"

	xeno_agent.ai_move_idle(delta_time)
	return "complete"

/datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_generic
	name = "xeno_v2_movement_generic"
	expected_handler_type = /datum/xeno_ai_movement

/datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_drone
	name = "xeno_v2_movement_drone"
	expected_handler_type = /datum/xeno_ai_movement/drone

/datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_crusher
	name = "xeno_v2_movement_crusher"
	expected_handler_type = /datum/xeno_ai_movement/crusher

/datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_linger
	name = "xeno_v2_movement_linger"
	expected_handler_type = /datum/xeno_ai_movement/linger

/datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_lurking
	name = "xeno_v2_movement_lurking"
	expected_handler_type = /datum/xeno_ai_movement/linger/lurking

/datum/npc_ai_task/xeno_v2_movement_base/xeno_v2_movement_facehugger
	name = "xeno_v2_movement_facehugger"
	expected_handler_type = /datum/xeno_ai_movement/linger/facehugger
