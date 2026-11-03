// Human AI action runtime API.
// Action queue, action blacklists, and currently running action state.

/datum/human_ai_brain/proc/cancel_ongoing_actions_by_type(list/action_types, datum/ai_action/except_action = null)
	var/datum/human_ai_module/action_runtime/action_runtime_module = get_action_runtime_module()
	action_runtime_module?.cancel_ongoing_actions_by_type(action_types, except_action)

/datum/human_ai_brain/proc/remove_ongoing_action(datum/ai_action/action)
	var/datum/human_ai_module/action_runtime/action_runtime_module = get_action_runtime_module()
	action_runtime_module?.remove_ongoing_action(action)

/datum/human_ai_brain/proc/has_ongoing_action(action_type)
	var/datum/human_ai_module/action_runtime/action_runtime_module = get_action_runtime_module()
	return action_runtime_module?.has_ongoing_action(action_type)

/datum/human_ai_brain/proc/add_action_blacklist(list/action_types)
	var/datum/human_ai_module/action_runtime/action_runtime_module = get_action_runtime_module()
	action_runtime_module?.add_action_blacklist(action_types)

/datum/human_ai_brain/proc/remove_action_blacklist(list/action_types)
	var/datum/human_ai_module/action_runtime/action_runtime_module = get_action_runtime_module()
	action_runtime_module?.remove_action_blacklist(action_types)

/datum/human_ai_brain/proc/has_ongoing_throw_action_in_progress()
	var/datum/human_ai_module/action_runtime/action_runtime_module = get_action_runtime_module()
	if(!action_runtime_module)
		return FALSE
	return action_runtime_module.has_ongoing_throw_action_in_progress()
