/datum/human_ai_module/action_runtime
	module_id = "action_runtime"

	/// List of whitelisted/blacklisted action datums
	var/list/action_whitelist = null
	var/list/action_blacklist = null
	var/list/action_score_modifiers = null

	/// List of current action datums
	var/list/ongoing_actions = list()

/datum/human_ai_module/action_runtime/Destroy(force, ...)
	QDEL_LIST(action_score_modifiers)
	return ..()

/datum/human_ai_module/action_runtime/proc/clear_actions()
	for(var/action in ongoing_actions.Copy())
		qdel(action)

	ongoing_actions.Cut()

/datum/human_ai_module/action_runtime/reset_module()
	clear_actions()

/datum/human_ai_module/action_runtime/suspend_module(clear_inventory = FALSE)
	clear_actions()

/datum/human_ai_module/action_runtime/process_module(delta_time)
	return process_actions(delta_time)

/datum/human_ai_module/action_runtime/proc/has_ongoing_action(path)
	if(!ispath(path))
		return FALSE

	for(var/datum/ai_action/action as anything in ongoing_actions)
		if(istype(action, path))
			return TRUE

	return FALSE

/datum/human_ai_module/action_runtime/proc/cancel_ongoing_actions_by_type(list/action_types, datum/ai_action/except_action = null)
	if(!length(action_types))
		return

	var/list/actions_to_cancel = ongoing_actions.Copy()
	for(var/datum/ai_action/ongoing_action as anything in actions_to_cancel)
		if(!(ongoing_action in ongoing_actions))
			continue
		if((ongoing_action != except_action) && (ongoing_action.type in action_types))
			qdel(ongoing_action)

/datum/human_ai_module/action_runtime/proc/remove_ongoing_action(datum/ai_action/action)
	ongoing_actions -= action

/datum/human_ai_module/action_runtime/proc/add_action_blacklist(list/action_types)
	if(!length(action_types))
		return
	if(!action_blacklist)
		action_blacklist = list()
	for(var/action_type as anything in action_types)
		action_blacklist |= action_type
	cancel_ongoing_actions_by_type(action_types)

/datum/human_ai_module/action_runtime/proc/remove_action_blacklist(list/action_types)
	if(!length(action_types) || !action_blacklist)
		return
	for(var/action_type as anything in action_types)
		action_blacklist -= action_type
	if(!length(action_blacklist))
		action_blacklist = null

/datum/human_ai_module/action_runtime/proc/has_ongoing_throw_action_in_progress()
	return brain.has_throw_in_progress()

/datum/human_ai_module/action_runtime/proc/set_action_score_modifiers(list/new_score_modifiers)
	QDEL_LIST(action_score_modifiers)
	action_score_modifiers = copy_human_ai_action_score_modifiers(new_score_modifiers)

/datum/human_ai_module/action_runtime/proc/get_action_score_modifier(action_type)
	RETURN_TYPE(/datum/human_ai_action_score_modifier)
	if(!action_score_modifiers)
		return null
	return action_score_modifiers[action_type]

/datum/human_ai_module/action_runtime/proc/get_modified_action_weight(action_type, base_weight)
	var/datum/human_ai_action_score_modifier/modifier = get_action_score_modifier(action_type)
	if(!modifier)
		return base_weight
	return modifier.apply(base_weight)

/datum/human_ai_module/action_runtime/proc/get_allowed_action_types()
	var/list/allowed_actions = action_whitelist?.Copy() || list() // SS220 EDIT: runtime selection must not mutate preset whitelists
	if(action_blacklist)
		allowed_actions -= action_blacklist
	for(var/datum/ongoing_action as anything in ongoing_actions.Copy())
		if(is_type_in_list(ongoing_action, allowed_actions))
			allowed_actions -= ongoing_action.type
	return allowed_actions

/datum/human_ai_module/action_runtime/proc/create_owner_context()
	RETURN_TYPE(/datum/human_ai_context)
	return brain.create_context()

/datum/human_ai_module/action_runtime/proc/has_owner_throw_in_progress()
	return brain.has_throw_in_progress()

/datum/human_ai_module/action_runtime/proc/create_owner_action(action_type)
	return new action_type(brain)

/datum/human_ai_module/action_runtime/proc/start_selected_actions(datum/human_ai_context/runtime_context, list/allowed_actions, grenade_throw_in_progress = FALSE)
	// Create assoc list of selected AI actions and their weight
	var/list/possible_actions = list()
	for(var/action_type in shuffle(allowed_actions))
		var/datum/ai_action/glob_ref = GLOB.AI_actions[action_type]
		if(!glob_ref)
			continue
		// SS220 EDIT: skip hand-using actions while a grenade throw is in async flight
		if(grenade_throw_in_progress && (glob_ref.action_flags & ACTION_USING_HANDS))
			continue
		var/weight = get_modified_action_weight(action_type, glob_ref.get_context_weight(runtime_context))
		if(weight) // No weight means we shouldn't consider this action at all
			possible_actions[action_type] = weight

	// Sorts all allowed actions by their weight
	var/list/sorted_actions = sortTim(possible_actions, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	// Choose what actions to start in current process() iteration
	for(var/action_type as anything in sorted_actions)
		var/datum/ai_action/possible_action = GLOB.AI_actions[action_type]

		var/list/conflicting_actions = possible_action.get_context_conflicts(runtime_context)
		for(var/datum/ai_action/ongoing_action as anything in ongoing_actions)
			if(ongoing_action.type in conflicting_actions)
				possible_action = null
				break

		if(!possible_action)
			continue

		ongoing_actions += create_owner_action(action_type)
#if defined(TESTING) && defined(HUMAN_AI_TESTING)
		message_admins("action of type [action_type] was added to [runtime_context.controller.get_real_name()]")
#endif

/datum/human_ai_module/action_runtime/proc/process_actions(delta_time)
	var/datum/human_ai_context/runtime_context = create_owner_context()
	if(!runtime_context.can_continue())
		qdel(runtime_context)
		return FALSE

	// List all allowed action types for AI to consider
	if(isnull(action_whitelist))
		stack_trace("Human AI action runtime issue: missing action whitelist")
		qdel(runtime_context)
		return FALSE

	var/list/allowed_actions = get_allowed_action_types()
	var/grenade_throw_in_progress = has_owner_throw_in_progress()
	start_selected_actions(runtime_context, allowed_actions, grenade_throw_in_progress)

	var/list/actions_to_process = ongoing_actions.Copy()
	for(var/datum/ai_action/action as anything in actions_to_process)
		if(!(action in ongoing_actions))
			continue
		if(!action.brain)
			ongoing_actions -= action
			continue
		// SS220 EDIT: suppress hand-using actions while a grenade throw is in async flight
		if(grenade_throw_in_progress && (action.action_flags & ACTION_USING_HANDS))
			continue
		var/retval = action.trigger_action()
		if(QDELETED(action) || !(action in ongoing_actions))
			continue
		switch(retval)
			if(ONGOING_ACTION_UNFINISHED_BLOCK)
				qdel(runtime_context)
				return TRUE
			if(ONGOING_ACTION_COMPLETED)
				qdel(action)

	qdel(runtime_context)
	return FALSE
