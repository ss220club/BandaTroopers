// Human AI action policy configured by equipment presets.

// ==================== Preset fields ====================
// Presets expose action policy; configs consume it during module composition.
/datum/equipment_preset
	var/human_ai_module_config_type = /datum/human_ai_module_config/default // SS220 EDIT: Human AI module composition surface
	var/human_ai_action_set_type = /datum/human_ai_action_set/default // SS220 EDIT: Human AI action set composition surface
	var/list/human_ai_action_whitelist // SS220 EDIT: Human AI action composition surface
	var/list/human_ai_action_blacklist // SS220 EDIT: Human AI action composition surface
	var/list/human_ai_action_score_modifiers // SS220 EDIT: Human AI action scoring surface

// ==================== Preset policy hooks ====================
// Subtypes can override these instead of manually deciding which modules to spawn.
/datum/equipment_preset/proc/get_human_ai_action_whitelist()
	return human_ai_action_whitelist?.Copy()

/datum/equipment_preset/proc/get_human_ai_action_blacklist()
	return human_ai_action_blacklist?.Copy()

/datum/equipment_preset/proc/get_human_ai_action_score_modifiers()
	return copy_human_ai_action_score_modifiers(human_ai_action_score_modifiers)

/proc/copy_human_ai_action_score_modifiers(list/source_modifiers)
	if(!length(source_modifiers))
		return null

	var/list/copied_modifiers = list()
	for(var/action_type as anything in source_modifiers)
		var/datum/human_ai_action_score_modifier/modifier = source_modifiers[action_type]
		if(!istype(modifier))
			stack_trace("Human AI action policy issue: invalid score modifier for [action_type]")
			continue
		copied_modifiers[action_type] = modifier.copy_modifier()

	return copied_modifiers

/proc/merge_human_ai_action_score_modifiers(list/base_modifiers, list/override_modifiers)
	var/list/merged_modifiers = copy_human_ai_action_score_modifiers(base_modifiers) || list()
	var/list/copied_overrides = copy_human_ai_action_score_modifiers(override_modifiers)
	if(!length(copied_overrides))
		return merged_modifiers

	for(var/action_type as anything in copied_overrides)
		if(merged_modifiers[action_type])
			qdel(merged_modifiers[action_type])
		merged_modifiers[action_type] = copied_overrides[action_type]

	return merged_modifiers

// ==================== Config policy state ====================
// Reads and tracks the preset policy for one brain setup pass.
/datum/human_ai_module_config/proc/create_action_set(action_set_type = /datum/human_ai_action_set/default)
	if(isnull(action_set_type))
		action_set_type = /datum/human_ai_action_set/default
	else if(!ispath(action_set_type, /datum/human_ai_action_set))
		report_action_policy_issue("invalid action set [action_set_type]")
		return null
	return new action_set_type()

/datum/human_ai_module_config/proc/read_action_policy(datum/equipment_preset/preset)
	var/datum/human_ai_action_set/action_set = create_action_set(preset?.human_ai_action_set_type)
	if(action_set)
		action_whitelist = action_set.get_action_whitelist()
		action_blacklist = action_set.get_action_blacklist()
		action_score_modifiers = action_set.get_action_score_modifiers()
		qdel(action_set)

	var/list/preset_action_whitelist = preset?.get_human_ai_action_whitelist()
	if(!isnull(preset_action_whitelist))
		action_whitelist = preset_action_whitelist

	var/list/preset_action_blacklist = preset?.get_human_ai_action_blacklist()
	if(!isnull(preset_action_blacklist))
		if(isnull(action_blacklist))
			action_blacklist = preset_action_blacklist
		else
			action_blacklist |= preset_action_blacklist

	var/list/preset_action_score_modifiers = preset?.get_human_ai_action_score_modifiers()
	if(!isnull(preset_action_score_modifiers))
		action_score_modifiers = merge_human_ai_action_score_modifiers(action_score_modifiers, preset_action_score_modifiers)
