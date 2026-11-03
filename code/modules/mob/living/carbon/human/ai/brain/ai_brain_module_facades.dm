// Human AI module-facing facade procs.
// These wrappers are grouped by the module/theme they expose so callers do not need to know the brain's internal module layout.

// ==================== Modules ====================
// Generic lookup helpers for partial module compositions.
/datum/human_ai_brain/proc/get_module(module_type)
	if(!module_config)
		return null
	return module_config.get_module_by_type(module_type)

/datum/human_ai_brain/proc/has_module(module_type)
	return !!get_module(module_type)

/datum/human_ai_brain/proc/get_module_by_id(module_id)
	return module_config?.get_module_by_id(module_id)

/datum/human_ai_brain/proc/get_action_runtime_module()
	RETURN_TYPE(/datum/human_ai_module/action_runtime)
	return get_module(/datum/human_ai_module/action_runtime)

/datum/human_ai_brain/proc/get_admin_module()
	RETURN_TYPE(/datum/human_ai_module/admin)
	return get_module(/datum/human_ai_module/admin)

/datum/human_ai_brain/proc/get_combat_module()
	RETURN_TYPE(/datum/human_ai_module/combat)
	return get_module(/datum/human_ai_module/combat)

/datum/human_ai_brain/proc/get_communication_module()
	RETURN_TYPE(/datum/human_ai_module/communication)
	return get_module(/datum/human_ai_module/communication)

/datum/human_ai_brain/proc/get_conversation_module()
	RETURN_TYPE(/datum/human_ai_module/conversation)
	return get_module(/datum/human_ai_module/conversation)

/datum/human_ai_brain/proc/get_cover_module()
	RETURN_TYPE(/datum/human_ai_module/cover)
	return get_module(/datum/human_ai_module/cover)

/datum/human_ai_brain/proc/get_emplacement_module()
	RETURN_TYPE(/datum/human_ai_module/emplacement)
	return get_module(/datum/human_ai_module/emplacement)

/datum/human_ai_brain/proc/get_faction_module()
	RETURN_TYPE(/datum/human_ai_module/faction)
	return get_module(/datum/human_ai_module/faction)

/datum/human_ai_brain/proc/get_grenade_module()
	RETURN_TYPE(/datum/human_ai_module/grenade)
	return get_module(/datum/human_ai_module/grenade)

/datum/human_ai_brain/proc/get_guns_module()
	RETURN_TYPE(/datum/human_ai_module/guns)
	return get_module(/datum/human_ai_module/guns)

/datum/human_ai_brain/proc/get_health_module()
	RETURN_TYPE(/datum/human_ai_module/health)
	return get_module(/datum/human_ai_module/health)

/datum/human_ai_brain/proc/get_inventory_module()
	RETURN_TYPE(/datum/human_ai_module/inventory)
	return get_module(/datum/human_ai_module/inventory)

/datum/human_ai_brain/proc/get_melee_module()
	RETURN_TYPE(/datum/human_ai_module/melee)
	return get_module(/datum/human_ai_module/melee)

/datum/human_ai_brain/proc/get_navigation_module()
	RETURN_TYPE(/datum/human_ai_module/navigation)
	return get_module(/datum/human_ai_module/navigation)

/datum/human_ai_brain/proc/get_orders_module()
	RETURN_TYPE(/datum/human_ai_module/orders)
	return get_module(/datum/human_ai_module/orders)

/datum/human_ai_brain/proc/get_perception_module()
	RETURN_TYPE(/datum/human_ai_module/perception)
	return get_module(/datum/human_ai_module/perception)

/datum/human_ai_brain/proc/get_profile_module()
	RETURN_TYPE(/datum/human_ai_module/profile)
	return get_module(/datum/human_ai_module/profile)

/datum/human_ai_brain/proc/get_squad_module()
	RETURN_TYPE(/datum/human_ai_module/squad)
	return get_module(/datum/human_ai_module/squad)

/datum/human_ai_brain/proc/get_targeting_module()
	RETURN_TYPE(/datum/human_ai_module/targeting)
	return get_module(/datum/human_ai_module/targeting)

/datum/human_ai_brain/proc/create_context()
	return new /datum/human_ai_context(src)
