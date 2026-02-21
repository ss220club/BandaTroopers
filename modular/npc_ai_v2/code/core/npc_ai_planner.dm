/datum/npc_ai_planner
	/// Maximum number of tasks selected per planning cycle (top-k by score).
	var/top_k = 3

/// RU: Строит итоговый план: фильтрует task registry по тегам, считает score и выбирает top_k задач без conflict_mask пересечений. EN: Builds final plan: filters task registry by tags, computes score, and picks top_k tasks without conflict_mask overlap.
/datum/npc_ai_planner/proc/plan(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard, list/task_registry, list/state_tags)
	var/list/planned_tasks = list()
	if(!controller || !agent || !blackboard || !islist(task_registry) || !length(task_registry))
		return planned_tasks

	var/list/scored_tasks = list()
	for(var/datum/npc_ai_task/task as anything in task_registry)
		if(QDELETED(task))
			continue
		if(!task.matches_tags(state_tags))
			continue

		var/task_score = task.score(controller, agent, blackboard)
		if(!isnum(task_score) || task_score <= 0)
			continue

		scored_tasks[task] = task_score

	if(!length(scored_tasks))
		return planned_tasks

	var/conflict_mask = NONE
	var/selection_cap = top_k > 0 ? top_k : length(scored_tasks)
	while(length(planned_tasks) < selection_cap)
		var/datum/npc_ai_task/best_task = null
		var/best_score = 0
		for(var/datum/npc_ai_task/task as anything in scored_tasks)
			if(task.conflict_mask & conflict_mask)
				continue
			var/task_score = scored_tasks[task]
			if(task_score > best_score)
				best_score = task_score
				best_task = task

		if(!best_task)
			break

		planned_tasks += best_task
		conflict_mask |= best_task.conflict_mask
		scored_tasks -= best_task

	return planned_tasks
