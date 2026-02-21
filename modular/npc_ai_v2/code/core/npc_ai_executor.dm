/datum/npc_ai_executor
	/// Active task map: agent -> list of currently running task datums.
	var/list/active_tasks_by_agent = list()

/// RU: Исполняет план для агента: стартует новые задачи, тикает активные и снимает complete/failed задачи из active map. EN: Executes plan for agent: starts new tasks, ticks active ones, and removes complete/failed tasks from active map.
/datum/npc_ai_executor/proc/execute(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, list/planned_tasks, delta_time)
	if(!controller || !agent || !blackboard)
		return

	LAZYINITLIST(active_tasks_by_agent)
	var/list/active_tasks = active_tasks_by_agent[agent]
	if(!islist(active_tasks))
		active_tasks = list()
		active_tasks_by_agent[agent] = active_tasks

	for(var/datum/npc_ai_task/task as anything in planned_tasks)
		if(QDELETED(task) || (task in active_tasks))
			continue
		if(task.start(controller, agent, blackboard))
			active_tasks += task

	for(var/datum/npc_ai_task/task as anything in active_tasks.Copy())
		if(QDELETED(task))
			active_tasks -= task
			continue

		var/task_state = task.tick(controller, agent, blackboard, delta_time)
		if(task_state == "complete" || task_state == "failed")
			task.stop(controller, agent, blackboard, task_state)
			active_tasks -= task

	if(!length(active_tasks))
		active_tasks_by_agent -= agent

/// RU: Удаляет или освобождает runtime сущности в исполнителе AI (этап: clear agent) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the AI executor (step: clear agent) to avoid dangling references and stale state.
/datum/npc_ai_executor/proc/clear_agent(mob/living/agent)
	if(!agent || !islist(active_tasks_by_agent))
		return
	active_tasks_by_agent -= agent
