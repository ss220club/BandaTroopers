/datum/npc_ai_squad_target_candidate
	var/atom/movable/target = null
	var/score = 0
	var/reserver_count = 0
	var/already_assigned_count = 0

/datum/npc_ai_squad_context
	var/id = null
	var/list/mob/living/members = list()
	var/current_order = null
	/// Assoc: agent_ref -> target atom
	var/list/assigned_targets = list()
	/// Assoc: agent_ref -> role string
	var/list/role_assignments = list()
	var/formation_type = NPC_AI_V2_SQUAD_FORMATION_LINE
	var/tactical_pressure = 0
	var/focus_fire_ratio = 0.5
	var/last_director_mood = NPC_AI_V2_DIRECTOR_MOOD_BALANCED

/datum/npc_ai_sensor_datum/squad_runtime_scaffold
	name = "squad_runtime_scaffold_sensor"
	legacy_sensor_id = "human_runtime_squads"
	defer_on_low_tiers = TRUE
	defer_min_tier = 1
	defer_interval_ds = 20

/datum/npc_ai_action_datum/squad_runtime_scaffold
	name = "squad_runtime_scaffold_action"
	legacy_action_type = null

/// RU: Вычисляет utility-вес шага для planner в action-datum; 0 отключает запуск. Побочные эффекты: учитывает target reservation. EN: Computes utility weight for planner step in an action datum; 0 disables execution. Side effects: uses target reservation.
/datum/npc_ai_action_datum/squad_runtime_scaffold/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	return 0

/datum/npc_ai_controller/squad
	name = "npc_ai_controller_squad"
	var/list/datum/npc_ai_squad_context/squad_contexts = list()
	var/datum/npc_ai_target_reservation_service/target_reservations
	/// Per-process reservation diagnostics for assignment policy tuning.
	var/reservation_conflicts_since_process = 0
	var/reservation_assignments_since_process = 0
	var/reservation_releases_since_process = 0

/// RU: Инициализирует runtime-состояние объекта в контроллере squad AI. Побочные эффекты: учитывает target reservation. EN: Initializes runtime state of object in the squad AI controller. Side effects: uses target reservation.
/datum/npc_ai_controller/squad/New()
	. = ..()
	target_reservations = new
	register_sensor_datum(new /datum/npc_ai_sensor_datum/squad_runtime_scaffold)
	register_action_datum(new /datum/npc_ai_action_datum/squad_runtime_scaffold)

/// RU: Очищает runtime-состояние перед удалением объекта в контроллере squad AI. Побочные эффекты: чистит runtime-объекты, учитывает target reservation. EN: Cleans runtime state before deleting object in the squad AI controller. Side effects: cleans runtime objects, uses target reservation.
/datum/npc_ai_controller/squad/Destroy(force, ...)
	if(target_reservations)
		target_reservations.reset()
	QDEL_LIST_ASSOC_VAL(squad_contexts)
	squad_contexts = null
	QDEL_NULL(target_reservations)
	return ..()

/// RU: Проверяет, разрешен ли squad AI глобальными флагами и не отключен ли локальным kill-switch. EN: Checks whether squad AI is enabled by globals and not disabled by local kill-switch.
/datum/npc_ai_controller/squad/is_enabled()
	return GLOB.npc_ai_v2_squad_enabled && !ai_kill

/// RU: Запускает тик squad AI: обходит активные контексты отрядов и применяет orchestration pipeline. EN: Runs a squad AI tick: iterates active squad contexts and applies the orchestration pipeline.
/datum/npc_ai_controller/squad/run_ai_tick(delta_time)
	if(!is_enabled())
		return null

	var/list/metrics = list(
		"processed_npc" = 0,
		"think_samples_ms" = list(),
		"tier_counters" = list("0" = 0, "1" = 1, "2" = 0, "3" = 0),
		"path_requests" = 0,
		"path_hits" = 0,
		"path_failures" = 0
	)

	for(var/squad_key in squad_contexts.Copy())
		var/datum/npc_ai_squad_context/context = squad_contexts[squad_key]
		if(QDELETED(context))
			squad_contexts -= squad_key
			continue
		metrics["processed_npc"] += process_squad_context(context, delta_time)
		if(TICK_CHECK)
			return finalize_process_metrics(metrics)

	return finalize_process_metrics(metrics)

/// RU: Сбрасывает и экспортирует диагностику reservation-политики squad-контроллера в метрики тика. EN: Flushes and resets reservation-policy diagnostics for the squad controller into tick metrics.
/datum/npc_ai_controller/squad/finalize_process_metrics(list/metrics)
	metrics = ..(metrics)
	if(!islist(metrics))
		metrics = list()
	metrics["reservation_conflicts"] = reservation_conflicts_since_process
	metrics["reservation_assignments"] = reservation_assignments_since_process
	metrics["reservation_releases"] = reservation_releases_since_process
	reservation_conflicts_since_process = 0
	reservation_assignments_since_process = 0
	reservation_releases_since_process = 0
	return metrics

/// RU: Выполняет полный цикл squad orchestration: prune, анализ целей, назначения, баланс фокуса, роли, формация и pressure. EN: Runs full squad orchestration cycle: prune, target analysis, assignments, focus balancing, roles, formation, and pressure.
/datum/npc_ai_controller/squad/proc/process_squad_context(datum/npc_ai_squad_context/context, delta_time)
	if(!context || !islist(context.members))
		return 0

	prune_invalid_members(context)
	if(!length(context.members))
		return 0

	var/list/director_packet = get_director_mood_packet()
	context.last_director_mood = director_packet["mood"] || NPC_AI_V2_DIRECTOR_MOOD_BALANCED

	var/list/datum/npc_ai_squad_target_candidate/candidates = analyze_available_targets(context, director_packet)
	coordinate_roles(context, director_packet)
	assign_targets_to_members(context, candidates, director_packet)
	balance_focus_fire(context, candidates, director_packet)
	update_formation(context, director_packet)
	update_tactical_pressure(context, director_packet, candidates)
	return length(context.members)

/// RU: Вычисляет и возвращает данные в контроллере squad AI (этап: get director mood packet) для следующего этапа поведения. EN: Computes and returns data in the squad AI controller (step: get director mood packet) for the next behavior stage.
/datum/npc_ai_controller/squad/proc/get_director_mood_packet()
	var/list/default_packet = list(
		"mood" = NPC_AI_V2_DIRECTOR_MOOD_BALANCED,
		"pressure_bias" = 0,
		"focus_fire_bias" = 0,
		"retreat_bias" = 0
	)
	var/datum/npc_ai_controller/director/director_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/director)
	if(!director_controller || !director_controller.is_enabled())
		return default_packet

	var/list/director_packet = director_controller.get_squad_mood_packet()
	if(!islist(director_packet))
		return default_packet
	return director_packet

/// RU: Выполняет служебный этап в контроллере squad AI (этап: prune invalid members) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the squad AI controller (step: prune invalid members) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/squad/proc/prune_invalid_members(datum/npc_ai_squad_context/context)
	if(!context || !islist(context.members))
		return

	for(var/mob/living/member as anything in context.members.Copy())
		if(!member || QDELETED(member) || member.stat == DEAD)
			context.members -= member
			clear_member_assignment(context, member)
			if(target_reservations)
				target_reservations.clear_agent_reservations(member)

/// RU: Выполняет служебный этап в контроллере squad AI (этап: analyze available targets) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the squad AI controller (step: analyze available targets) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/squad/proc/analyze_available_targets(datum/npc_ai_squad_context/context, list/director_packet)
	var/list/datum/npc_ai_squad_target_candidate/candidates = list()
	if(!context || !islist(context.members) || !length(context.members))
		return candidates

	var/list/seen_targets = list()
	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/human)

	for(var/mob/living/member as anything in context.members)
		if(!member || QDELETED(member))
			continue
		if(!human_controller)
			continue

		var/datum/npc_ai_blackboard/blackboard = human_controller.get_blackboard(member)
		if(!blackboard)
			continue

		var/atom/movable/current_target = blackboard.get_value("legacy_current_target")
		if(!current_target || QDELETED(current_target))
			continue

		var/target_ref = REF(current_target)
		var/datum/npc_ai_squad_target_candidate/candidate = seen_targets[target_ref]
		if(!candidate)
			candidate = new
			candidate.target = current_target
			candidate.score = score_target_candidate(context, current_target, director_packet)
			if(target_reservations)
				candidate.reserver_count = target_reservations.get_reserver_count(current_target)
			seen_targets[target_ref] = candidate
			candidates += candidate

	return candidates

/// RU: Выполняет служебный этап в контроллере squad AI (этап: score target candidate) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the squad AI controller (step: score target candidate) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/squad/proc/score_target_candidate(datum/npc_ai_squad_context/context, atom/movable/target, list/director_packet)
	if(!context || !target)
		return 0

	var/score = 10
	for(var/mob/living/member as anything in context.members)
		if(!member || QDELETED(member))
			continue
		score += max(0, 12 - get_dist(member, target))

	var/retreat_bias = director_packet["retreat_bias"] || 0
	if(retreat_bias > 0)
		score -= round(retreat_bias * 0.1)
	return max(0, score)

/// RU: Назначает цели членам отряда с учетом focus_fire_bias, лимитов reservation и релиза старых назначений. EN: Assigns targets to squad members using focus_fire_bias, reservation caps, and release of previous assignments.
/datum/npc_ai_controller/squad/proc/assign_targets_to_members(datum/npc_ai_squad_context/context, list/datum/npc_ai_squad_target_candidate/candidates, list/director_packet)
	if(!context || !islist(context.members) || !length(context.members))
		return

	if(!islist(candidates) || !length(candidates))
		clear_all_assignments(context)
		return

	var/max_reservers_per_target = 2
	var/focus_bias = director_packet["focus_fire_bias"] || 0
	if(focus_bias >= 15)
		max_reservers_per_target = 4
	else if(focus_bias >= 5)
		max_reservers_per_target = 3

	var/list/assigned_count_by_target = count_current_assignments(context)
	for(var/datum/npc_ai_squad_target_candidate/candidate as anything in candidates)
		candidate.already_assigned_count = assigned_count_by_target[REF(candidate.target)] || 0

	for(var/mob/living/member as anything in context.members)
		if(!member || QDELETED(member))
			continue

		var/atom/movable/previous_target = get_member_assigned_target(context, member)
		var/member_reservation_cap = get_member_reservation_cap(context, member, max_reservers_per_target)
		var/datum/npc_ai_squad_target_candidate/best_candidate = select_best_candidate_for_member(context, member, candidates, member_reservation_cap, previous_target)
		if(!best_candidate || !best_candidate.target)
			clear_member_assignment(context, member)
			continue

		if(target_reservations)
			if(!target_reservations.reserve_target(best_candidate.target, member, member_reservation_cap, TRUE))
				reservation_conflicts_since_process++
				continue
			reservation_assignments_since_process++

		assign_member_target(context, member, best_candidate.target)
		best_candidate.already_assigned_count++
		if(previous_target && previous_target != best_candidate.target)
			release_member_target_reservation(previous_target, member)

/// RU: Вычисляет и возвращает данные в контроллере squad AI (этап: select best candidate for member) для следующего этапа поведения. EN: Computes and returns data in the squad AI controller (step: select best candidate for member) for the next behavior stage.
/datum/npc_ai_controller/squad/proc/select_best_candidate_for_member(datum/npc_ai_squad_context/context, mob/living/member, list/datum/npc_ai_squad_target_candidate/candidates, member_reservation_cap, atom/movable/previous_target = null)
	if(!context || !member || !islist(candidates) || !length(candidates))
		return null

	var/datum/npc_ai_squad_target_candidate/best_candidate = null
	var/best_weight = -1.0e31
	var/member_ref = REF(member)
	var/member_role = islist(context.role_assignments) ? context.role_assignments[member_ref] : null

	for(var/datum/npc_ai_squad_target_candidate/candidate as anything in candidates)
		if(!candidate?.target || QDELETED(candidate.target))
			continue
		if(member_reservation_cap > 0 && candidate.already_assigned_count >= member_reservation_cap)
			continue
		if(member_reservation_cap == 1 && target_reservations && target_reservations.is_target_reserved_for_other(candidate.target, member))
			continue

		var/weight = candidate.score
		weight -= get_dist(member, candidate.target) * 0.5
		weight -= candidate.already_assigned_count * 3
		weight -= candidate.reserver_count * 2
		if(previous_target && previous_target == candidate.target)
			weight += 2

		switch(member_role)
			if(NPC_AI_V2_SQUAD_ROLE_ANCHOR)
				weight -= candidate.already_assigned_count * 1.5
			if(NPC_AI_V2_SQUAD_ROLE_ASSAULT)
				weight += 1.5
			if(NPC_AI_V2_SQUAD_ROLE_SUPPORT)
				weight -= get_dist(member, candidate.target) * 0.2

		if(weight > best_weight)
			best_weight = weight
			best_candidate = candidate

	return best_candidate

/// RU: Вычисляет персональный лимит reservation для участника отряда по роли и настроению director. EN: Computes per-member reservation cap from squad role and director mood.
/datum/npc_ai_controller/squad/proc/get_member_reservation_cap(datum/npc_ai_squad_context/context, mob/living/member, default_cap)
	if(!member || !isnum(default_cap) || default_cap <= 0)
		return default_cap

	var/cap = default_cap
	var/member_ref = REF(member)
	var/member_role = islist(context?.role_assignments) ? context.role_assignments[member_ref] : null
	if(member_role == NPC_AI_V2_SQUAD_ROLE_ANCHOR)
		cap = min(cap, 1)
	else if(member_role == NPC_AI_V2_SQUAD_ROLE_SUPPORT)
		cap = min(cap, 2)

	if(context?.last_director_mood == NPC_AI_V2_DIRECTOR_MOOD_RETREAT)
		cap = max(1, cap - 1)

	return max(1, cap)

/// RU: Освобождает reservation цели для участника и обновляет диагностический счетчик release. EN: Releases member target reservation and updates diagnostic release counter.
/datum/npc_ai_controller/squad/proc/release_member_target_reservation(atom/movable/target, mob/living/member)
	if(!target || !member || !target_reservations)
		return
	target_reservations.release_target(target, member)
	reservation_releases_since_process++

/// RU: Снижает оверфокус на одной цели, перераспределяя часть членов на альтернативные target-кандидаты. EN: Reduces over-focus on a single target by redistributing some members to alternative target candidates.
/datum/npc_ai_controller/squad/proc/balance_focus_fire(datum/npc_ai_squad_context/context, list/datum/npc_ai_squad_target_candidate/candidates, list/director_packet)
	if(!context || !islist(context.members) || length(context.members) <= 1)
		return
	if(!islist(candidates) || !length(candidates))
		return

	var/list/assignment_counts = count_current_assignments(context)
	var/highest_target_ref = null
	var/highest_count = 0
	for(var/target_ref in assignment_counts)
		var/count = assignment_counts[target_ref] || 0
		if(count > highest_count)
			highest_count = count
			highest_target_ref = target_ref
	if(!highest_target_ref)
		return
	var/max_focus_ratio = 0.5
	var/focus_bias = director_packet["focus_fire_bias"] || 0
	if(focus_bias >= 15)
		max_focus_ratio = 0.85
	else if(focus_bias >= 5)
		max_focus_ratio = 0.7

	var/max_focus_count = max(1, round(length(context.members) * max_focus_ratio))
	if(highest_count <= max_focus_count)
		return

	var/excess = highest_count - max_focus_count
	for(var/mob/living/member as anything in context.members)
		if(excess <= 0)
			break
		var/atom/movable/member_target = get_member_assigned_target(context, member)
		if(!member_target || REF(member_target) != highest_target_ref)
			continue

		var/datum/npc_ai_squad_target_candidate/alternative = select_best_alternative_candidate(member, candidates, member_target)
		if(!alternative?.target)
			continue
		if(target_reservations && !target_reservations.reserve_target(alternative.target, member, 0, TRUE))
			reservation_conflicts_since_process++
			continue
		if(target_reservations)
			reservation_assignments_since_process++
			release_member_target_reservation(member_target, member)
		assign_member_target(context, member, alternative.target)
		excess--

/// RU: Вычисляет и возвращает данные в контроллере squad AI (этап: select best alternative candidate) для следующего этапа поведения. EN: Computes and returns data in the squad AI controller (step: select best alternative candidate) for the next behavior stage.
/datum/npc_ai_controller/squad/proc/select_best_alternative_candidate(mob/living/member, list/datum/npc_ai_squad_target_candidate/candidates, atom/movable/current_target)
	var/datum/npc_ai_squad_target_candidate/best_candidate = null
	var/best_weight = -1.0e31
	for(var/datum/npc_ai_squad_target_candidate/candidate as anything in candidates)
		if(!candidate?.target || QDELETED(candidate.target) || candidate.target == current_target)
			continue
		var/weight = candidate.score - (get_dist(member, candidate.target) * 0.4)
		if(weight > best_weight)
			best_weight = weight
			best_candidate = candidate
	return best_candidate

/// RU: Раздает роли (anchor/assault/support) на основе director mood и состава текущего squad context. EN: Assigns roles (anchor/assault/support) based on director mood and current squad composition.
/datum/npc_ai_controller/squad/proc/coordinate_roles(datum/npc_ai_squad_context/context, list/director_packet)
	if(!context || !islist(context.members))
		return
	context.role_assignments = list()

	var/mood = director_packet["mood"] || NPC_AI_V2_DIRECTOR_MOOD_BALANCED
	var/list/mob/living/sorted_members = context.members.Copy()
	var/member_count = length(sorted_members)
	if(!member_count)
		return

	// First member in deterministic list becomes anchor.
	var/mob/living/anchor_member = sorted_members[1]
	context.role_assignments[REF(anchor_member)] = NPC_AI_V2_SQUAD_ROLE_ANCHOR

	for(var/index in 2 to member_count)
		var/mob/living/member = sorted_members[index]
		if(!member || QDELETED(member))
			continue

		if(mood == NPC_AI_V2_DIRECTOR_MOOD_RETREAT)
			context.role_assignments[REF(member)] = (index % 2) ? NPC_AI_V2_SQUAD_ROLE_SUPPORT : NPC_AI_V2_SQUAD_ROLE_ASSAULT
		else if(mood == NPC_AI_V2_DIRECTOR_MOOD_AGGRESSIVE)
			context.role_assignments[REF(member)] = (index <= 2) ? NPC_AI_V2_SQUAD_ROLE_SUPPORT : NPC_AI_V2_SQUAD_ROLE_ASSAULT
		else
			context.role_assignments[REF(member)] = (index % 3 == 0) ? NPC_AI_V2_SQUAD_ROLE_SUPPORT : NPC_AI_V2_SQUAD_ROLE_ASSAULT

/// RU: Обновляет runtime состояние в контроллере squad AI (этап: update formation) и синхронизирует данные для последующих тиков. EN: Updates runtime state in the squad AI controller (step: update formation) and synchronizes data for subsequent ticks.
/datum/npc_ai_controller/squad/proc/update_formation(datum/npc_ai_squad_context/context, list/director_packet)
	if(!context)
		return
	var/mood = director_packet["mood"] || NPC_AI_V2_DIRECTOR_MOOD_BALANCED
	switch(mood)
		if(NPC_AI_V2_DIRECTOR_MOOD_AGGRESSIVE)
			context.formation_type = NPC_AI_V2_SQUAD_FORMATION_WEDGE
		if(NPC_AI_V2_DIRECTOR_MOOD_RETREAT)
			context.formation_type = NPC_AI_V2_SQUAD_FORMATION_COLUMN
		else
			context.formation_type = NPC_AI_V2_SQUAD_FORMATION_LINE

/// RU: Пересчитывает tactical_pressure и focus_fire_ratio по mood, pressure_bias и плотности доступных целей. EN: Recomputes tactical_pressure and focus_fire_ratio from mood, pressure_bias, and available target density.
/datum/npc_ai_controller/squad/proc/update_tactical_pressure(datum/npc_ai_squad_context/context, list/director_packet, list/datum/npc_ai_squad_target_candidate/candidates)
	if(!context)
		return
	var/base_pressure = 0
	var/mood = director_packet["mood"] || NPC_AI_V2_DIRECTOR_MOOD_BALANCED
	switch(mood)
		if(NPC_AI_V2_DIRECTOR_MOOD_AGGRESSIVE)
			base_pressure = 35
		if(NPC_AI_V2_DIRECTOR_MOOD_RETREAT)
			base_pressure = -25
		else
			base_pressure = 10

	var/pressure_bias = director_packet["pressure_bias"] || 0
	var/target_density_bonus = islist(candidates) ? min(20, length(candidates) * 4) : 0
	context.tactical_pressure = clamp(base_pressure + pressure_bias + target_density_bonus, -100, 100)
	context.focus_fire_ratio = clamp(0.5 + ((director_packet["focus_fire_bias"] || 0) * 0.01), 0.25, 0.9)

/// RU: Выполняет служебный этап в контроллере squad AI (этап: count current assignments) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the squad AI controller (step: count current assignments) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/squad/proc/count_current_assignments(datum/npc_ai_squad_context/context)
	var/list/assignment_counts = list()
	if(!context || !islist(context.assigned_targets))
		return assignment_counts

	for(var/agent_ref in context.assigned_targets)
		var/atom/movable/target = context.assigned_targets[agent_ref]
		if(!target || QDELETED(target))
			continue
		var/target_ref = REF(target)
		assignment_counts[target_ref] = (assignment_counts[target_ref] || 0) + 1
	return assignment_counts

/// RU: Вычисляет и возвращает данные в контроллере squad AI (этап: get member assigned target) для следующего этапа поведения. EN: Computes and returns data in the squad AI controller (step: get member assigned target) for the next behavior stage.
/datum/npc_ai_controller/squad/proc/get_member_assigned_target(datum/npc_ai_squad_context/context, mob/living/member)
	if(!context || !member || !islist(context.assigned_targets))
		return null
	return context.assigned_targets[REF(member)]

/// RU: Выполняет служебный этап в контроллере squad AI (этап: assign member target) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the squad AI controller (step: assign member target) to coordinate state between AI v2 subsystems.
/datum/npc_ai_controller/squad/proc/assign_member_target(datum/npc_ai_squad_context/context, mob/living/member, atom/movable/target)
	if(!context || !member || !target)
		return
	context.assigned_targets[REF(member)] = target

/// RU: Удаляет или освобождает runtime сущности в контроллере squad AI (этап: clear member assignment) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the squad AI controller (step: clear member assignment) to avoid dangling references and stale state.
/datum/npc_ai_controller/squad/proc/clear_member_assignment(datum/npc_ai_squad_context/context, mob/living/member)
	if(!context || !member || !islist(context.assigned_targets))
		return
	var/member_ref = REF(member)
	var/atom/movable/current_target = context.assigned_targets[member_ref]
	if(current_target)
		release_member_target_reservation(current_target, member)
	context.assigned_targets -= member_ref
	if(islist(context.role_assignments))
		context.role_assignments -= member_ref

/// RU: Удаляет или освобождает runtime сущности в контроллере squad AI (этап: clear all assignments) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the squad AI controller (step: clear all assignments) to avoid dangling references and stale state.
/datum/npc_ai_controller/squad/proc/clear_all_assignments(datum/npc_ai_squad_context/context)
	if(!context)
		return
	if(islist(context.assigned_targets))
		for(var/member_ref in context.assigned_targets.Copy())
			var/atom/movable/assigned_target = context.assigned_targets[member_ref]
			if(!assigned_target || QDELETED(assigned_target))
				continue
			var/mob/living/member = locate(member_ref)
			if(!member || QDELETED(member))
				continue
			release_member_target_reservation(assigned_target, member)
	if(target_reservations && islist(context.members))
		for(var/mob/living/member as anything in context.members)
			if(!member || QDELETED(member))
				continue
			target_reservations.clear_agent_reservations(member)
	context.assigned_targets = list()
	context.role_assignments = list()

/// RU: Регистрирует сущность в контроллере squad AI (этап: register squad context) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in the squad AI controller (step: register squad context) and links it to AI v2 runtime state.
/datum/npc_ai_controller/squad/proc/register_squad_context(id)
	if(isnull(id))
		return null
	var/key = "[id]"
	var/datum/npc_ai_squad_context/context = squad_contexts[key]
	if(context)
		return context
	context = new
	context.id = key
	squad_contexts[key] = context
	return context

/// RU: Удаляет или освобождает runtime сущности в контроллере squad AI (этап: unregister squad context) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the squad AI controller (step: unregister squad context) to avoid dangling references and stale state.
/datum/npc_ai_controller/squad/proc/unregister_squad_context(id)
	if(isnull(id))
		return
	var/key = "[id]"
	var/datum/npc_ai_squad_context/context = squad_contexts[key]
	if(context && !QDELETED(context))
		clear_all_assignments(context)
	if(context)
		qdel(context)
	squad_contexts -= key

/// RU: Вычисляет и возвращает данные в контроллере squad AI (этап: get squad context) для следующего этапа поведения. EN: Computes and returns data in the squad AI controller (step: get squad context) for the next behavior stage.
/datum/npc_ai_controller/squad/proc/get_squad_context(id)
	if(isnull(id))
		return null
	return squad_contexts["[id]"]
