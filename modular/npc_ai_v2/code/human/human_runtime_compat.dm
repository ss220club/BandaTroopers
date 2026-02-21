/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime controller) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime controller) for the next behavior stage.
/proc/get_human_ai_runtime_controller()
	RETURN_TYPE(/datum/npc_ai_controller/human)
	if(!SSnpc_ai)
		return null

	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/human)
	if(!human_controller || QDELETED(human_controller))
		return null
	return human_controller

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime factions) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime factions) for the next behavior stage.
/proc/get_human_ai_runtime_factions()
	RETURN_TYPE(/list)
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller && islist(human_controller.human_ai_factions))
		return human_controller.human_ai_factions
	return list()

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime faction) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime faction) for the next behavior stage.
/proc/get_human_ai_runtime_faction(faction_name)
	RETURN_TYPE(/datum/human_ai_faction)
	if(!faction_name)
		return null
	var/list/factions = get_human_ai_runtime_factions()
	if(!islist(factions))
		return null
	return factions[faction_name]

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime squads) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime squads) for the next behavior stage.
/proc/get_human_ai_runtime_squads()
	RETURN_TYPE(/list)
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller && islist(human_controller.squads))
		return human_controller.squads
	return list()

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime squad id dict) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime squad id dict) for the next behavior stage.
/proc/get_human_ai_runtime_squad_id_dict()
	RETURN_TYPE(/list)
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller && islist(human_controller.squad_id_dict))
		return human_controller.squad_id_dict
	return list()

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime highest squad id) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime highest squad id) for the next behavior stage.
/proc/get_human_ai_runtime_highest_squad_id()
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller)
		return human_controller.highest_squad_id
	return 0

/// RU: Выполняет служебный этап в human AI v2 (этап: create human ai runtime squad) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in human AI v2 (step: create human ai runtime squad) to coordinate state between AI v2 subsystems.
/proc/create_human_ai_runtime_squad()
	RETURN_TYPE(/datum/human_ai_squad)
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller)
		return human_controller.create_new_squad()
	return null

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime squad) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime squad) for the next behavior stage.
/proc/get_human_ai_runtime_squad(squad_id)
	RETURN_TYPE(/datum/human_ai_squad)
	if(!squad_id)
		return null

	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller)
		return human_controller.get_squad("[squad_id]")
	return null

/// RU: Вычисляет и возвращает данные в human AI v2 (этап: get human ai runtime orders) для следующего этапа поведения. EN: Computes and returns data in human AI v2 (step: get human ai runtime orders) for the next behavior stage.
/proc/get_human_ai_runtime_orders()
	RETURN_TYPE(/list)
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller && islist(human_controller.existing_orders))
		return human_controller.existing_orders
	return list()

/// RU: Регистрирует сущность в human AI v2 (этап: register human ai runtime order) и связывает ее с runtime состоянием AI v2. EN: Registers an entity in human AI v2 (step: register human ai runtime order) and links it to AI v2 runtime state.
/proc/register_human_ai_runtime_order(datum/ai_order/order)
	if(!order)
		return
	var/list/orders = get_human_ai_runtime_orders()
	if(!islist(orders))
		return
	orders |= order

/// RU: Удаляет или освобождает runtime сущности в human AI v2 (этап: unregister human ai runtime order) чтобы не оставлять висячие ссылки и stale-state. EN: Removes or releases runtime entities in human AI v2 (step: unregister human ai runtime order) to avoid dangling references and stale state.
/proc/unregister_human_ai_runtime_order(datum/ai_order/order)
	if(!order)
		return
	var/list/orders = get_human_ai_runtime_orders()
	if(!islist(orders))
		return
	orders -= order

/// RU: Обновляет runtime состояние в human AI v2 (этап: mark human ai runtime combat started) и синхронизирует данные для последующих тиков. EN: Updates runtime state in human AI v2 (step: mark human ai runtime combat started) and synchronizes data for subsequent ticks.
/proc/mark_human_ai_runtime_combat_started()
	var/datum/npc_ai_controller/human/human_controller = get_human_ai_runtime_controller()
	if(human_controller)
		human_controller.combat_ever_started = TRUE
