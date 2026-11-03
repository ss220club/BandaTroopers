// Shared Human AI weapon-use context.

/datum/human_ai_weapon_context
	var/datum/human_ai_brain/AI
	var/datum/human_ai_context/ai_context
	var/datum/human_tied_controller/controller
	var/obj/item/weapon_item
	var/atom/movable/current_target
	var/turf/target_turf

/datum/human_ai_weapon_context/New(datum/human_ai_brain/new_ai, obj/item/new_weapon_item = null, atom/movable/new_current_target = null, turf/new_target_turf = null)
	AI = new_ai
	ai_context = AI?.create_context()
	controller = ai_context?.controller
	weapon_item = new_weapon_item
	current_target = new_current_target
	target_turf = new_target_turf

/datum/human_ai_weapon_context/Destroy(force, ...)
	QDEL_NULL(ai_context)
	AI = null
	controller = null
	weapon_item = null
	current_target = null
	target_turf = null
	return ..()

/datum/human_ai_weapon_context/proc/is_valid()
	return AI?.can_continue_runtime_work() && controller

/datum/human_ai_weapon_context/proc/can_continue(obj/item/item = weapon_item)
	if(!is_valid())
		return FALSE
	if(item && QDELETED(item))
		return FALSE
	return TRUE

/datum/human_ai_weapon_context/proc/sleep_short()
	sleep(AI.get_action_delay())
	return can_continue()

/datum/human_ai_weapon_context/proc/sleep_micro()
	sleep(AI.get_micro_action_delay())
	return can_continue()

/datum/human_ai_weapon_context/proc/get_primary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	if(!is_valid())
		return null
	return AI.get_primary_weapon()

/datum/human_ai_weapon_context/proc/clear_main_hand()
	if(!is_valid())
		return
	AI.clear_main_hand()

/datum/human_ai_weapon_context/proc/ensure_primary_hand(obj/item/item)
	if(!is_valid())
		return FALSE
	return AI.ensure_primary_hand(item)

/datum/human_ai_weapon_context/proc/equip_item_from_equipment_map(equipment_type, obj/item/item)
	if(!is_valid())
		return FALSE
	return AI.equip_item_from_equipment_map(equipment_type, item)

/datum/human_ai_weapon_context/proc/unqueue_pickup(obj/item/item)
	if(!is_valid())
		return FALSE
	return AI.unqueue_pickup(item)

/datum/human_ai_weapon_context/proc/unholster_any_weapon()
	if(!is_valid())
		return FALSE
	return AI.unholster_any_weapon()
