// Reusable Human AI action policy objects; presets can select one and optionally override it.

/datum/human_ai_action_score_modifier
	var/minimum_base_weight = 0
	var/weight_multiplier = 1
	var/weight_add = 0
	var/minimum_final_weight = 0

/datum/human_ai_action_score_modifier/proc/apply(base_weight)
	if(!base_weight)
		return 0
	if(minimum_base_weight && base_weight < minimum_base_weight)
		return 0

	var/modified_weight = (base_weight * weight_multiplier) + weight_add
	if(modified_weight <= 0)
		return 0
	if(minimum_final_weight && modified_weight < minimum_final_weight)
		return 0
	return modified_weight

/datum/human_ai_action_score_modifier/proc/copy_modifier()
	var/datum/human_ai_action_score_modifier/modifier_copy = new type()
	modifier_copy.minimum_base_weight = minimum_base_weight
	modifier_copy.weight_multiplier = weight_multiplier
	modifier_copy.weight_add = weight_add
	modifier_copy.minimum_final_weight = minimum_final_weight
	return modifier_copy

/datum/human_ai_action_set
	var/list/included_action_set_types = list()
	var/list/action_whitelist = list()
	var/list/action_blacklist = list()
	var/list/action_score_modifiers = list()

/datum/human_ai_action_set/Destroy(force, ...)
	QDEL_LIST(action_score_modifiers)
	return ..()

/datum/human_ai_action_set/proc/get_action_whitelist(list/resolving_action_set_types = null)
	return get_resolved_action_list(FALSE, resolving_action_set_types)

/datum/human_ai_action_set/proc/get_action_blacklist(list/resolving_action_set_types = null)
	return get_resolved_action_list(TRUE, resolving_action_set_types)

/datum/human_ai_action_set/proc/get_action_score_modifiers(list/resolving_action_set_types = null)
	return get_resolved_score_modifiers(resolving_action_set_types)

/datum/human_ai_action_set/proc/get_local_action_list(resolve_blacklist = FALSE)
	var/list/local_actions = resolve_blacklist ? action_blacklist : action_whitelist
	return local_actions || list()

/datum/human_ai_action_set/proc/get_resolved_action_list(resolve_blacklist = FALSE, list/resolving_action_set_types = null)
	if(!resolving_action_set_types)
		resolving_action_set_types = list()
	if(type in resolving_action_set_types)
		stack_trace("Human AI action set issue: cyclic included action set [type]")
		return list()

	resolving_action_set_types += type
	var/list/resolved_actions = list()
	for(var/action_set_type as anything in included_action_set_types)
		if(!ispath(action_set_type, /datum/human_ai_action_set))
			stack_trace("Human AI action set issue: invalid included action set [action_set_type]")
			continue

		var/datum/human_ai_action_set/action_set = new action_set_type()
		resolved_actions |= action_set.get_resolved_action_list(resolve_blacklist, resolving_action_set_types)
		qdel(action_set)

	resolving_action_set_types -= type
	resolved_actions |= get_local_action_list(resolve_blacklist)
	return resolved_actions

/datum/human_ai_action_set/proc/get_local_score_modifiers()
	return action_score_modifiers || list()

/datum/human_ai_action_set/proc/get_resolved_score_modifiers(list/resolving_action_set_types = null)
	if(!resolving_action_set_types)
		resolving_action_set_types = list()
	if(type in resolving_action_set_types)
		stack_trace("Human AI action set issue: cyclic included action score policy [type]")
		return list()

	resolving_action_set_types += type
	var/list/resolved_modifiers = list()
	for(var/action_set_type as anything in included_action_set_types)
		if(!ispath(action_set_type, /datum/human_ai_action_set))
			stack_trace("Human AI action set issue: invalid included action set [action_set_type]")
			continue

		var/datum/human_ai_action_set/action_set = new action_set_type()
		resolved_modifiers |= action_set.get_resolved_score_modifiers(resolving_action_set_types)
		qdel(action_set)

	resolving_action_set_types -= type
	for(var/action_type as anything in get_local_score_modifiers())
		var/datum/human_ai_action_score_modifier/modifier = action_score_modifiers[action_type]
		if(!istype(modifier))
			stack_trace("Human AI action set issue: invalid score modifier for [action_type] in [type]")
			continue
		resolved_modifiers[action_type] = modifier.copy_modifier()

	return resolved_modifiers

/datum/human_ai_action_set/movement
	action_whitelist = list(
		/datum/ai_action/chase_target,
		/datum/ai_action/follow_leader,
		/datum/ai_action/investigate_lost_target,
		/datum/ai_action/patrol_waypoints,
		/datum/ai_action/quick_approach,
	)

/datum/human_ai_action_set/combat
	action_whitelist = list(
		/datum/ai_action/fire_at_target,
		/datum/ai_action/keep_distance,
		/datum/ai_action/reload,
		/datum/ai_action/select_primary,
	)

/datum/human_ai_action_set/survival
	action_whitelist = list(
		/datum/ai_action/resist_burning,
		/datum/ai_action/take_cover,
		/datum/ai_action/treat_ally,
		/datum/ai_action/treat_self,
	)

/datum/human_ai_action_set/grenade
	action_whitelist = list(
		/datum/ai_action/throw_back_nade,
		/datum/ai_action/throw_grenade,
	)

/datum/human_ai_action_set/melee
	action_whitelist = list(
		/datum/ai_action/walk_melee,
	)

/datum/human_ai_action_set/emplacement
	action_whitelist = list(
		/datum/ai_action/machinegunner_nest,
		/datum/ai_action/sniper_nest,
	)

/datum/human_ai_action_set/default
	included_action_set_types = list(
		/datum/human_ai_action_set/movement,
		/datum/human_ai_action_set/combat,
		/datum/human_ai_action_set/survival,
		/datum/human_ai_action_set/grenade,
		/datum/human_ai_action_set/melee,
		/datum/human_ai_action_set/emplacement,
	)
	action_whitelist = list(
		/datum/ai_action/converse,
		/datum/ai_action/item_pickup,
	)
