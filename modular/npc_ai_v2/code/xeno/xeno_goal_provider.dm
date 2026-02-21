#define NPC_AI_V2_XENO_GOAL_PROVIDER_KEY "xeno_goal_provider_override"
#define NPC_AI_V2_XENO_GOAL_PROVIDER_HANDLED_KEY "xeno_goal_provider_handled"

/datum/npc_ai_sensor/xeno_goal_provider
	name = "xeno_goal_provider_sensor"

/// RU: Считывает override компонент поведения xeno и сохраняет его в blackboard для xeno_goal_provider task. EN: Reads xeno behavior override component and stores it in blackboard for xeno_goal_provider task.
/datum/npc_ai_sensor/xeno_goal_provider/sense(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!enabled || !GLOB.npc_ai_v2_xeno_goal_provider_enabled || !istype(controller, /datum/npc_ai_controller/xeno) || !istype(agent, /mob/living/carbon/xenomorph) || !blackboard)
		if(blackboard)
			blackboard.set_value(NPC_AI_V2_XENO_GOAL_PROVIDER_KEY, null)
			blackboard.set_value(NPC_AI_V2_XENO_GOAL_PROVIDER_HANDLED_KEY, FALSE)
		return list()

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	var/datum/component/ai_behavior_override/override_goal = xeno_agent.check_overrides()
	blackboard.set_value(NPC_AI_V2_XENO_GOAL_PROVIDER_KEY, override_goal)
	blackboard.set_value(NPC_AI_V2_XENO_GOAL_PROVIDER_HANDLED_KEY, FALSE)
	if(override_goal)
		return list("xeno_goal_provider_override")
	return list()

/datum/npc_ai_task/xeno_goal_provider
	name = "xeno_goal_provider_task"
	conflict_mask = NONE

/// RU: Вычисляет utility-вес шага для planner в AI-задаче; 0 отключает запуск. EN: Computes utility weight for planner step in an AI task; 0 disables execution.
/datum/npc_ai_task/xeno_goal_provider/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!GLOB.npc_ai_v2_xeno_goal_provider_enabled || !istype(controller, /datum/npc_ai_controller/xeno) || !istype(agent, /mob/living/carbon/xenomorph) || !blackboard)
		return 0

	var/datum/component/ai_behavior_override/override_goal = blackboard.get_value(NPC_AI_V2_XENO_GOAL_PROVIDER_KEY)
	if(!override_goal || QDELETED(override_goal))
		return 0
	return 100

/// RU: Выполняет override behavior для xeno и пишет в blackboard, обработан ли весь тик этим override. EN: Executes xeno override behavior and writes whether full tick was handled by override into blackboard.
/datum/npc_ai_task/xeno_goal_provider/tick(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, delta_time)
	if(!GLOB.npc_ai_v2_xeno_goal_provider_enabled || !istype(agent, /mob/living/carbon/xenomorph) || !blackboard)
		return "failed"

	var/mob/living/carbon/xenomorph/xeno_agent = agent
	var/datum/component/ai_behavior_override/override_goal = blackboard.get_value(NPC_AI_V2_XENO_GOAL_PROVIDER_KEY)
	if(!override_goal || QDELETED(override_goal))
		return "failed"

	var/handled_entire_tick = !!override_goal.process_override_behavior(xeno_agent, delta_time)
	blackboard.set_value(NPC_AI_V2_XENO_GOAL_PROVIDER_HANDLED_KEY, handled_entire_tick)
	return "complete"

#undef NPC_AI_V2_XENO_GOAL_PROVIDER_KEY
#undef NPC_AI_V2_XENO_GOAL_PROVIDER_HANDLED_KEY
