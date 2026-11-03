GLOBAL_LIST_INIT_TYPED(AI_actions, /datum/ai_action, setup_ai_actions())

/proc/setup_ai_actions()
	var/list/action_list = list()
	for(var/action in subtypesof(/datum/ai_action))
		var/datum/ai_action/A = new action
		action_list[A.type] = A
	return action_list


/datum/ai_action
	var/name
	var/datum/human_ai_brain/brain
	var/datum/human_ai_context/context
	var/action_flags = null
	var/list/required_ai_modules = list()

/datum/ai_action/proc/get_context_weight(datum/human_ai_context/context)
	return 0

/datum/ai_action/proc/get_action_flag_conflicts()
	RETURN_TYPE(/list)
	. = list()

	if(!action_flags)
		return

	for(var/action_type as anything in GLOB.AI_actions)
		if(GLOB.AI_actions[action_type].action_flags & action_flags)
			. += action_type

/// Proc to determine what actions aren't compatible with any that the AI currently have ongoing
/// If you want to add one, override this on child and add a typepath of an action to .
/datum/ai_action/proc/get_context_conflicts(datum/human_ai_context/context)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	return get_action_flag_conflicts()

/datum/ai_action/New(datum/human_ai_brain/brain)
	. = ..()

	if(!brain)
		return

	src.brain = brain
	context = brain.create_context()
	Added()

/// Called when an action is created and assigned a brain
/datum/ai_action/proc/Added()
	return

/datum/ai_action/Destroy(force, ...)
	brain?.remove_ongoing_action(src)
	QDEL_NULL(context)
	brain = null
	return ..()

/// Everything that the action should do should go in this proc
/datum/ai_action/proc/trigger_action()
	SHOULD_NOT_SLEEP(TRUE)
	// Child trigger_action() overrides must return parent completion before reading src.brain.
	if(!context?.can_continue()) // SS220 EDIT: delayed/ongoing actions must re-check lifecycle before side effects
		return ONGOING_ACTION_COMPLETED
