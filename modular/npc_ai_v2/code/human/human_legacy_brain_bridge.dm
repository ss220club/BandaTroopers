/// RU: Готовит legacy brain к v2-тику: применяет faction matrix, чистит action state при incapacitated и нормализует rest/buckle. EN: Prepares legacy brain for v2 tick: applies faction matrix, clears action state on incapacitation, and normalizes rest/buckle.
/datum/human_ai_brain/proc/v2_prepare_tick()
	if(!tied_human)
		return FALSE

	npc_ai_v2_apply_faction_matrix_to_brain(src)

	if(tied_human.is_mob_incapacitated())
		for(var/action in ongoing_actions)
			qdel(action)
		ongoing_actions.Cut()
		lose_target()
		return FALSE

	if(tied_human.resting)
		tied_human.set_resting(FALSE, TRUE)

	if(tied_human.buckled)
		tied_human.set_buckled(FALSE)

	return TRUE

/// RU: Обновляет target/combat состояние brain: пытается reacquire цель и включает combat mode при успешном захвате. EN: Updates brain target/combat state: attempts target reacquire and enters combat mode when target is acquired.
/datum/human_ai_brain/proc/v2_update_target_and_combat()
	if(!tied_human)
		return FALSE

	if(!current_target)
		set_target(get_target())

	if(current_target)
		enter_combat()

	return !!current_target

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 run item search) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 run item search) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_run_item_search(search_radius = 2)
	if(!tied_human || search_radius <= 0)
		return
	item_search(range(search_radius, tied_human))

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 is action allowed) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 is action allowed) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_is_action_allowed(action_type)
	if(!ispath(action_type, /datum/ai_action))
		return FALSE

	if(islist(action_whitelist))
		return action_type in action_whitelist

	if(islist(action_blacklist) && (action_type in action_blacklist))
		return FALSE

	return TRUE

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 is action ongoing) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 is action ongoing) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_is_action_ongoing(action_type)
	if(!ispath(action_type, /datum/ai_action))
		return FALSE

	for(var/datum/ai_action/action as anything in ongoing_actions)
		if(istype(action, action_type))
			return TRUE

	return FALSE

/// RU: Проверяет старт action по whitelist/blacklist, отсутствию дубля и конфликтов с ongoing_actions. EN: Validates action start via whitelist/blacklist, no duplicate, and no conflicts with ongoing_actions.
/datum/human_ai_brain/proc/v2_action_can_start(action_type)
	if(!v2_is_action_allowed(action_type))
		return FALSE

	if(v2_is_action_ongoing(action_type))
		return FALSE

	var/datum/ai_action/action_singleton = GLOB.AI_actions[action_type]
	if(!action_singleton)
		return FALSE

	var/list/conflicting_actions = action_singleton.get_conflicts(src)
	for(var/datum/ai_action/ongoing_action as anything in ongoing_actions)
		if(ongoing_action.type in conflicting_actions)
			return FALSE

	return TRUE

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 action score) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 action score) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_action_score(action_type)
	if(!v2_is_action_allowed(action_type))
		return 0

	var/datum/ai_action/action_singleton = GLOB.AI_actions[action_type]
	if(!action_singleton)
		return 0

	return action_singleton.get_weight(src)

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 start action) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 start action) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_start_action(action_type)
	if(!v2_action_can_start(action_type))
		return FALSE

	ongoing_actions += new action_type(src)
	return TRUE

/// RU: Тикает ongoing_actions и удаляет завершенные; при блокирующем action завершает цикл раньше. EN: Ticks ongoing_actions and removes completed ones; returns early on blocking action.
/datum/human_ai_brain/proc/v2_tick_ongoing_actions()
	for(var/datum/ai_action/action as anything in ongoing_actions)
		var/retval = action.trigger_action()
		switch(retval)
			if(ONGOING_ACTION_UNFINISHED_BLOCK)
				return TRUE
			if(ONGOING_ACTION_COMPLETED)
				qdel(action)

	return FALSE

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 conversation score) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 conversation score) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_conversation_score()
	if(!COOLDOWN_FINISHED(src, conversation_start_cooldown))
		return 0
	COOLDOWN_START(src, conversation_start_cooldown, 1 SECONDS)

	if(in_combat || in_conversation || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return 0

	if(!prob(conversation_start_prob))
		return 0

	return 1

/// RU: Выполняет служебный этап в bridge-слое human brain (этап: v2 try start conversation) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in the human brain bridge layer (step: v2 try start conversation) to coordinate state between AI v2 subsystems.
/datum/human_ai_brain/proc/v2_try_start_conversation()
	var/list/ai_nearby = list()
	for(var/mob/living/carbon/human/nearby_human in view(2, tied_human))
		var/datum/human_ai_brain/other_brain = nearby_human.get_ai_brain()
		if(!other_brain || other_brain.in_combat || other_brain.in_conversation || other_brain.tied_human.client || (other_brain.tied_human.health < HEALTH_THRESHOLD_CRIT))
			continue

		ai_nearby += other_brain

	if(length(ai_nearby) <= 1)
		return FALSE

	var/datum/human_ai_conversation/picked_convo
	var/picked_index
	for(var/i = length(GLOB.human_ai_conversations), i > 1, i--)
		var/list/viable_conversations = list()
		for(var/datum/human_ai_conversation/convo as anything in GLOB.human_ai_conversations[i])
			if(!convo.conversation_allowed(src))
				continue
			viable_conversations += convo

		if(!length(viable_conversations))
			continue

		picked_index = i
		picked_convo = pick(viable_conversations)
		break

	if(!picked_convo || !picked_index)
		return FALSE

	if(length(ai_nearby) > picked_index)
		var/list/cut_down_ai_nearby = list()
		for(var/i in 1 to picked_index)
			cut_down_ai_nearby += pick_n_take(ai_nearby)
		ai_nearby = cut_down_ai_nearby

	var/datum/human_ai_conversation/gotten_convo = picked_convo
	INVOKE_ASYNC(gotten_convo, TYPE_PROC_REF(/datum/human_ai_conversation, initiate_conversation), ai_nearby)
	return TRUE
