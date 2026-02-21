/datum/npc_ai_target_reservation_service
	/// Assoc: target_ref -> assoc(agent_ref = TRUE)
	var/list/target_to_agent_refs = list()

/// RU: Вычисляет и возвращает данные в сервисе target reservation (этап: get target ref) для следующего этапа поведения. EN: Computes and returns data in the target reservation service (step: get target ref) for the next behavior stage.
/datum/npc_ai_target_reservation_service/proc/get_target_ref(atom/target)
	if(!target || QDELETED(target))
		return null
	return REF(target)

/// RU: Вычисляет и возвращает данные в сервисе target reservation (этап: get agent ref) для следующего этапа поведения. EN: Computes and returns data in the target reservation service (step: get agent ref) for the next behavior stage.
/datum/npc_ai_target_reservation_service/proc/get_agent_ref(mob/living/agent)
	if(!agent || QDELETED(agent))
		return null
	return REF(agent)

/// RU: Вычисляет и возвращает данные в сервисе target reservation (этап: get reserver count) для следующего этапа поведения. EN: Computes and returns data in the target reservation service (step: get reserver count) for the next behavior stage.
/datum/npc_ai_target_reservation_service/proc/get_reserver_count(atom/target)
	var/target_ref = get_target_ref(target)
	if(!target_ref)
		return 0
	var/list/agent_refs = target_to_agent_refs[target_ref]
	if(!islist(agent_refs))
		return 0
	return length(agent_refs)

/// RU: Проверяет условие в сервисе target reservation (этап: is target reserved for other) и возвращает булево значение для выбора следующего шага. EN: Checks condition in the target reservation service (step: is target reserved for other) and returns a boolean used to choose the next step.
/datum/npc_ai_target_reservation_service/proc/is_target_reserved_for_other(atom/target, mob/living/requestor)
	var/target_ref = get_target_ref(target)
	var/requestor_ref = get_agent_ref(requestor)
	if(!target_ref || !requestor_ref)
		return FALSE
	var/list/agent_refs = target_to_agent_refs[target_ref]
	if(!islist(agent_refs) || !length(agent_refs))
		return FALSE
	if(length(agent_refs) == 1 && agent_refs[requestor_ref])
		return FALSE
	return !agent_refs[requestor_ref]

/// RU: Выполняет служебный этап в сервисе target reservation (этап: reserve target) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the target reservation service (step: reserve target) to coordinate state between AI v2 subsystems.
/datum/npc_ai_target_reservation_service/proc/reserve_target(atom/target, mob/living/agent, max_reservers = 1, allow_existing_agent = TRUE)
	var/target_ref = get_target_ref(target)
	var/agent_ref = get_agent_ref(agent)
	if(!target_ref || !agent_ref)
		return FALSE

	LAZYINITLIST(target_to_agent_refs[target_ref])
	var/list/agent_refs = target_to_agent_refs[target_ref]
	if(agent_refs[agent_ref])
		return allow_existing_agent

	if(max_reservers > 0 && length(agent_refs) >= max_reservers)
		return FALSE

	agent_refs[agent_ref] = TRUE
	return TRUE

/// RU: Удаляет или освобождает runtime сущности в сервисе target reservation (этап: release target) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the target reservation service (step: release target) to avoid dangling references and stale state.
/datum/npc_ai_target_reservation_service/proc/release_target(atom/target, mob/living/agent)
	var/target_ref = get_target_ref(target)
	var/agent_ref = get_agent_ref(agent)
	if(!target_ref || !agent_ref)
		return

	var/list/agent_refs = target_to_agent_refs[target_ref]
	if(!islist(agent_refs))
		return
	agent_refs -= agent_ref
	if(!length(agent_refs))
		target_to_agent_refs -= target_ref

/// RU: Удаляет или освобождает runtime сущности в сервисе target reservation (этап: clear agent reservations) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in the target reservation service (step: clear agent reservations) to avoid dangling references and stale state.
/datum/npc_ai_target_reservation_service/proc/clear_agent_reservations(mob/living/agent)
	var/agent_ref = get_agent_ref(agent)
	if(!agent_ref || !islist(target_to_agent_refs))
		return

	for(var/target_ref in target_to_agent_refs.Copy())
		var/list/agent_refs = target_to_agent_refs[target_ref]
		if(!islist(agent_refs))
			target_to_agent_refs -= target_ref
			continue
		agent_refs -= agent_ref
		if(!length(agent_refs))
			target_to_agent_refs -= target_ref

/// RU: Выполняет служебный этап в сервисе target reservation (этап: reset) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the target reservation service (step: reset) to coordinate state between AI v2 subsystems.
/datum/npc_ai_target_reservation_service/proc/reset()
	target_to_agent_refs = list()
