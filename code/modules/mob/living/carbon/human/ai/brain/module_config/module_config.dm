// ==================== State ====================
// Owns created modules and stores resolved action policy for this brain setup.
/datum/human_ai_module_config
	var/list/datum/human_ai_module/owned_modules
	var/list/modules_by_type
	var/list/modules_by_id
	var/list/requested_module_types
	var/list/action_whitelist
	var/list/action_blacklist
	var/list/action_score_modifiers

// ==================== Lifetime ====================
// Releases modules owned by the config datum.
/datum/human_ai_module_config/Destroy(force, ...)
	QDEL_LIST(owned_modules)
	owned_modules = null
	modules_by_type = null
	modules_by_id = null
	requested_module_types = null
	action_whitelist = null
	action_blacklist = null
	QDEL_LIST(action_score_modifiers)
	return ..()

/datum/human_ai_module_config/proc/setup_brain(datum/human_ai_brain/brain, mob/living/carbon/human/new_human)
	return

// ==================== Teardown ====================
// Deletes config-owned modules and clears registry/list state.
/datum/human_ai_module_config/proc/teardown_brain_modules(datum/human_ai_brain/brain)
	QDEL_LIST(owned_modules)
	owned_modules = null
	modules_by_type = null
	modules_by_id = null
	requested_module_types = null
	QDEL_LIST(action_score_modifiers)

// ==================== Process lists ====================
// Wires created modules into lifecycle, process, event, and query dispatch lists.
/datum/human_ai_module_config/proc/configure_module_lists(datum/human_ai_brain/brain)
	configure_lifecycle_module_lists(brain)
	configure_process_module_lists(brain)
	configure_event_module_lists(brain)
	configure_query_module_lists(brain)
	// SS220 EDIT START: modular modules may join existing lifecycle/event dispatch
	if(hascall(src, "modular_configure_module_lists"))
		call(src, "modular_configure_module_lists")(brain)
	// SS220 EDIT END

/datum/human_ai_module_config/proc/configure_lifecycle_module_lists(datum/human_ai_brain/brain)
	return

/datum/human_ai_module_config/proc/configure_process_module_lists(datum/human_ai_brain/brain)
	return

/datum/human_ai_module_config/proc/configure_event_module_lists(datum/human_ai_brain/brain)
	return

/datum/human_ai_module_config/proc/configure_query_module_lists(datum/human_ai_brain/brain)
	return

// ==================== Default setup ====================
// Builds the default Human AI from preset action policy and expanded module dependencies.
/datum/human_ai_module_config/default/setup_brain(datum/human_ai_brain/brain, mob/living/carbon/human/new_human)
	read_action_policy(new_human?.assigned_equipment_preset)

	requested_module_types = get_module_types_to_setup()
	for(var/module_type as anything in requested_module_types)
		setup_module_by_type(brain, module_type)

	validate_module_setup(brain)

	var/datum/human_ai_module/action_runtime/action_runtime = get_module_by_type(/datum/human_ai_module/action_runtime)
	if(action_runtime)
		action_runtime.action_whitelist = action_whitelist?.Copy()
		action_runtime.action_blacklist = action_blacklist?.Copy()
		action_runtime.set_action_score_modifiers(action_score_modifiers)

	var/datum/human_ai_module/perception/perception = get_module_by_type(/datum/human_ai_module/perception)
	perception?.register_signals()
	perception?.setup_detection_radius()

	brain.register_inventory_signals()

/datum/human_ai_module_config/default/configure_lifecycle_module_lists(datum/human_ai_brain/brain)
	register_module_list_for_event(brain, HUMAN_AI_EVENT_RESET_BEFORE_WAKE_CLEAR, list(/datum/human_ai_module/health, /datum/human_ai_module/navigation, /datum/human_ai_module/cover, /datum/human_ai_module/perception))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_RESET_AFTER_WAKE_CLEAR, list(/datum/human_ai_module/combat, /datum/human_ai_module/grenade, /datum/human_ai_module/targeting, /datum/human_ai_module/inventory, /datum/human_ai_module/action_runtime))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_BEFORE_WAKE_CLEAR, list(/datum/human_ai_module/navigation, /datum/human_ai_module/cover, /datum/human_ai_module/perception))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_AFTER_WAKE_CLEAR, list(/datum/human_ai_module/combat, /datum/human_ai_module/grenade, /datum/human_ai_module/targeting, /datum/human_ai_module/health, /datum/human_ai_module/action_runtime, /datum/human_ai_module/inventory))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_LIFECYCLE_RESUMED, list(/datum/human_ai_module/inventory, /datum/human_ai_module/guns))

/datum/human_ai_module_config/default/configure_process_module_lists(datum/human_ai_brain/brain)
	brain.process_modules_before_posture = build_module_list(brain, list(/datum/human_ai_module/perception))
	brain.process_modules_after_posture = build_module_list(brain, list(/datum/human_ai_module/targeting, /datum/human_ai_module/combat, /datum/human_ai_module/inventory, /datum/human_ai_module/cover, /datum/human_ai_module/action_runtime))

/datum/human_ai_module_config/default/configure_event_module_lists(datum/human_ai_brain/brain)
	register_module_list_for_event(brain, HUMAN_AI_EVENT_INITIALIZED, list(/datum/human_ai_module/inventory, /datum/human_ai_module/admin))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_TARGET_CHANGED, list(/datum/human_ai_module/inventory))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_PROJECTILE_THREAT, list(/datum/human_ai_module/combat, /datum/human_ai_module/faction, /datum/human_ai_module/targeting, /datum/human_ai_module/cover))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_COMBAT_ENTERED, list(/datum/human_ai_module/squad, /datum/human_ai_module/communication, /datum/human_ai_module/cover))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_COMBAT_EXIT_STARTED, list(/datum/human_ai_module/targeting, /datum/human_ai_module/communication, /datum/human_ai_module/inventory))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED, list(/datum/human_ai_module/cover, /datum/human_ai_module/targeting))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED, list(/datum/human_ai_module/targeting, /datum/human_ai_module/cover))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_HANDCUFFED, list(/datum/human_ai_module/admin))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_SPECIES_CHANGED, list(/datum/human_ai_module/inventory))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_BODY_POSITION_CHANGED, list(/datum/human_ai_module/inventory, /datum/human_ai_module/targeting))
	register_module_list_for_event(brain, HUMAN_AI_EVENT_MOVED, list(/datum/human_ai_module/perception, /datum/human_ai_module/cover, /datum/human_ai_module/targeting))

/datum/human_ai_module_config/default/configure_query_module_lists(datum/human_ai_brain/brain)
	brain.target_vision_modules = build_module_list(brain, list(/datum/human_ai_module/inventory))
