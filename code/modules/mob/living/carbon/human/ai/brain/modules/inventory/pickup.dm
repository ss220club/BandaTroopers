#define HUMAN_AI_PICKUP_SCAN_CONTINUE 0
#define HUMAN_AI_PICKUP_SCAN_SKIP 1
#define HUMAN_AI_PICKUP_SCAN_STOP 2
#define HUMAN_AI_PICKUP_APPROACH_IN_RANGE 1
#define HUMAN_AI_PICKUP_APPROACH_MOVING 2
#define HUMAN_AI_PICKUP_APPROACH_FAILED 3

/datum/human_ai_module/inventory/proc/has_pickup_queue()
	return length(to_pickup)

/datum/human_ai_module/inventory/proc/get_next_pickup()
	RETURN_TYPE(/obj/item)
	if(!length(to_pickup))
		return null
	return to_pickup[1]

/datum/human_ai_module/inventory/proc/get_item_pickup_weight(datum/human_tied_controller/controller)
	if(!controller)
		return 0

	if(is_looting_disabled())
		return 0

	if(!has_pickup_queue())
		return 0

	if(controller.has_trait_from(TRAIT_UNDENSE, LYING_DOWN_TRAIT))
		return 0

	if(controller.is_health_below(HEALTH_THRESHOLD_CRIT))
		return 0

	if(controller.get_l_hand()?.flags_item & NODROP)
		return 0

	if(controller.get_r_hand()?.flags_item & NODROP)
		return 0

	if(!has_primary_weapon())
		return 16

	return 11

/datum/human_ai_module/inventory/proc/start_item_pickup_action()
	active_pickup_target = get_next_pickup()
	// If we already have a primary weapon, discard stale queued gun pickups.
	if(isgun(active_pickup_target) && has_primary_weapon())
		cleanup_pickup_target()
		active_pickup_target = null
		return FALSE
	return !!active_pickup_target

/datum/human_ai_module/inventory/proc/stop_item_pickup_action()
	active_pickup_target = null

/datum/human_ai_module/inventory/proc/perform_item_pickup(datum/human_tied_controller/controller)
	if(!controller)
		return ONGOING_ACTION_COMPLETED

	if(is_pickup_target_invalid())
		cleanup_pickup_target()
		return ONGOING_ACTION_COMPLETED

	var/obj/item/weapon/gun/primary_weapon = get_primary_weapon()
	if(primary_weapon && isgun(active_pickup_target))
		cleanup_pickup_target()
		return ONGOING_ACTION_COMPLETED

	var/approach_result = approach_pickup_target(controller)
	if(approach_result == HUMAN_AI_PICKUP_APPROACH_FAILED)
		return ONGOING_ACTION_COMPLETED
	if(approach_result == HUMAN_AI_PICKUP_APPROACH_MOVING)
		return ONGOING_ACTION_UNFINISHED

	prepare_hands_for_pickup(controller, primary_weapon)

	if(try_pickup_primary_weapon(controller))
		return ONGOING_ACTION_COMPLETED

	if(try_equip_pickup_storage(controller))
		return ONGOING_ACTION_COMPLETED

	var/storage_spot = storage_has_room(active_pickup_target)
	var/mob/living/carbon/human/self_target = controller.get_self_target()
	if(!storage_spot || !self_target || !controller.can_use_item(active_pickup_target, self_target))
		cleanup_pickup_target()
		return ONGOING_ACTION_COMPLETED

	try_store_pickup_item(controller, storage_spot)

	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/inventory/proc/is_pickup_target_invalid()
	return !active_pickup_target || QDELETED(active_pickup_target) || !isturf(active_pickup_target.loc)

/datum/human_ai_module/inventory/proc/cleanup_pickup_target()
	UnregisterSignal(active_pickup_target, COMSIG_PARENT_QDELETING)
	unqueue_pickup(active_pickup_target)

/datum/human_ai_module/inventory/proc/approach_pickup_target(datum/human_tied_controller/controller)
	if(controller.get_distance_to(active_pickup_target) <= 1)
		return HUMAN_AI_PICKUP_APPROACH_IN_RANGE

	if(!brain.move_to_atom(active_pickup_target))
		cleanup_pickup_target()
		return HUMAN_AI_PICKUP_APPROACH_FAILED

	if(controller.get_distance_to(active_pickup_target) > 1)
		return HUMAN_AI_PICKUP_APPROACH_MOVING

	return HUMAN_AI_PICKUP_APPROACH_IN_RANGE

/datum/human_ai_module/inventory/proc/prepare_hands_for_pickup(datum/human_tied_controller/controller, obj/item/weapon/gun/primary_weapon)
	if(primary_weapon)
		controller.unwield_weapon(primary_weapon)

	if(controller.get_held_item())
		controller.swap_hand()

/datum/human_ai_module/inventory/proc/try_pickup_primary_weapon(datum/human_tied_controller/controller)
	if(!isgun(active_pickup_target))
		return FALSE

	controller.put_in_hands(active_pickup_target, TRUE)
	var/obj/item/weapon/gun/primary = active_pickup_target
	// Make the newly picked gun immediately usable by later fire actions.
	primary.wield_time = world.time
	primary.pull_time = world.time
	primary.guaranteed_delay_time = world.time
	return TRUE

/datum/human_ai_module/inventory/proc/try_equip_pickup_storage(datum/human_tied_controller/controller)
	if(try_equip_pickup_storage_to_slot(controller, /obj/item/storage/belt, HUMAN_AI_STORAGE_BELT, WEAR_WAIST))
		return TRUE

	if(try_equip_pickup_storage_to_slot(controller, /obj/item/storage/backpack, HUMAN_AI_STORAGE_BACKPACK, WEAR_BACK))
		return TRUE

	if(try_equip_pickup_storage_to_slot(controller, /obj/item/storage/pouch, HUMAN_AI_STORAGE_LEFT_POCKET, WEAR_L_STORE))
		return TRUE

	return try_equip_pickup_storage_to_slot(controller, /obj/item/storage/pouch, HUMAN_AI_STORAGE_RIGHT_POCKET, WEAR_R_STORE)

/datum/human_ai_module/inventory/proc/try_equip_pickup_storage_to_slot(datum/human_tied_controller/controller, storage_type, container_id, wear_slot)
	if(!istype(active_pickup_target, storage_type) || has_container_ref(container_id))
		return FALSE

	controller.put_in_hands(active_pickup_target, TRUE)
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/human_tied_controller, equip_to_slot), active_pickup_target, wear_slot)
	return TRUE

/datum/human_ai_module/inventory/proc/try_store_pickup_item(datum/human_tied_controller/controller, storage_spot)
	var/list/equipment_types = get_pickup_storage_equipment_types(active_pickup_target)
	if(!length(equipment_types))
		return FALSE

	controller.put_in_hands(active_pickup_target, TRUE)
	if(store_item_as_types(active_pickup_target, storage_spot, equipment_types) && (HUMAN_AI_AMMUNITION in equipment_types))
		clear_owner_tried_reload() // not appraising inventory there, let's say we can reload now
	return TRUE

/datum/human_ai_module/inventory/proc/queue_pickup(obj/item/item)
	if(!item || is_pickup_queued(item))
		return FALSE
	RegisterSignal(item, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	to_pickup += item
	return TRUE

/datum/human_ai_module/inventory/proc/unqueue_pickup(obj/item/item)
	if(!item || !is_pickup_queued(item))
		return FALSE
	to_pickup -= item
	return TRUE

/datum/human_ai_module/inventory/proc/is_pickup_queued(obj/item/item)
	return item && (item in to_pickup)

/datum/human_ai_module/inventory/proc/clear_pickup_queue()
	to_pickup.Cut()

/datum/human_ai_module/inventory/proc/should_run_nearby_item_search()
	if(!can_continue_inventory_work())
		return FALSE

	if(should_owner_suspend_nearby_item_search())
		return FALSE

	if(nearby_item_search_interval <= 0)
		return TRUE

	if(!nearby_item_search_dirty && !COOLDOWN_FINISHED(src, nearby_item_search_cooldown))
		return FALSE

	nearby_item_search_dirty = FALSE
	COOLDOWN_START(src, nearby_item_search_cooldown, nearby_item_search_interval)
	return TRUE

/// SS220 EDIT: delayed reset of active_grenade_found - gives throw-back action one scheduler tick to spawn before clearing
/datum/human_ai_module/inventory/proc/clear_active_grenade_if_stale(obj/item/explosive/grenade/grenade)
	if(QDELETED(src) || !can_continue_inventory_work() || QDELETED(grenade))
		return
	if(get_owner_active_grenade() == grenade && !has_owner_ongoing_action(/datum/ai_action/throw_back_nade))
		clear_owner_active_grenade()

/datum/human_ai_module/inventory/proc/item_search(list/things_around)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	// SS220 EDIT - START: grenade threat must come only from the current local scan, not from stale refs.
	// Preserve active_grenade_found across ticks if it is already the currently held, still-active timed grenade.
	var/obj/item/explosive/grenade/active_grenade = get_owner_active_grenade()
	if(!active_grenade || QDELETED(active_grenade) || !active_grenade.active || (active_grenade.fuse_type != TIMED_FUSE) || !controller.is_item_equipped_or_held(active_grenade))
		clear_owner_active_grenade()
	var/can_handle_live_grenade = can_owner_throw_back_grenade() && !((controller.get_l_hand()?.flags_item & NODROP) && (controller.get_r_hand()?.flags_item & NODROP))
	// SS220 EDIT - END
	for(var/obj/item/thing in things_around)
		if(!isturf(thing.loc))
			continue

		if(is_pickup_queued(thing))
			continue

		var/live_grenade_result = handle_live_grenade_candidate(thing, can_handle_live_grenade)
		if(live_grenade_result == HUMAN_AI_PICKUP_SCAN_STOP)
			return
		if(live_grenade_result == HUMAN_AI_PICKUP_SCAN_SKIP)
			continue

		// SS220 EDIT - START: ignore_looting must also suppress pickup candidates, not only the Item Pickup action.
		if(ignore_looting)
			continue
		// SS220 EDIT - END

		if(should_pickup_weapon(thing))
			queue_pickup(thing)

		if(should_pickup_storage(thing))
			queue_pickup(thing)

		var/storage_spot = storage_has_room(thing)
		var/mob/living/carbon/human/self_target = controller.get_self_target()
		if(!storage_spot || !self_target || !controller.can_use_item(thing, self_target))
			continue

		if(thing.flags_human_ai & HEALING_ITEM)
			queue_pickup(thing)

		if(should_pickup_ammo(thing))
			queue_pickup(thing)

		if(should_pickup_grenade(thing))
			queue_pickup(thing)

		if(should_pickup_tool(thing))
			queue_pickup(thing)

/datum/human_ai_module/inventory/proc/handle_live_grenade_candidate(obj/item/thing, can_handle_live_grenade)
	if(!(thing.flags_human_ai & GRENADE_ITEM))
		return HUMAN_AI_PICKUP_SCAN_CONTINUE

	var/obj/item/explosive/grenade/nade = thing
	if(!istype(nade))
		return HUMAN_AI_PICKUP_SCAN_CONTINUE
	if(nade.active && (nade.fuse_type == IMPACT_FUSE))
		return HUMAN_AI_PICKUP_SCAN_STOP
	if(nade.active && (nade.fuse_type == TIMED_FUSE) && can_handle_live_grenade) // SS220 EDIT: only enter throw-back mode if we can actually manipulate the grenade
		set_owner_active_grenade(nade)
		return HUMAN_AI_PICKUP_SCAN_SKIP
	return HUMAN_AI_PICKUP_SCAN_CONTINUE

/datum/human_ai_module/inventory/proc/should_pickup_weapon(obj/item/thing)
	if(primary_weapon || !isgun(thing))
		return FALSE

	if(has_queued_weapon_pickup())
		return FALSE

	var/obj/item/weapon/gun/thing_gun = thing
	var/datum/human_ai_firearm_profile/firearm_profile = get_available_firearm_profile(thing_gun)
	if(!firearm_profile)
		return FALSE
	if(firearm_profile?.disposable && thing_gun.current_mag?.current_rounds <= 0)
		return FALSE

	return TRUE

/datum/human_ai_module/inventory/proc/should_pickup_storage(obj/item/thing)
	if(istype(thing, /obj/item/storage/belt) && !has_container_ref(HUMAN_AI_STORAGE_BELT))
		return TRUE
	if(istype(thing, /obj/item/storage/backpack) && !has_container_ref(HUMAN_AI_STORAGE_BACKPACK))
		return TRUE
	if(istype(thing, /obj/item/storage/pouch) && (!has_container_ref(HUMAN_AI_STORAGE_LEFT_POCKET) || !has_container_ref(HUMAN_AI_STORAGE_RIGHT_POCKET)))
		return TRUE
	return FALSE

/datum/human_ai_module/inventory/proc/should_pickup_ammo(obj/item/thing)
	if(!(thing.flags_human_ai & AMMUNITION_ITEM) || !primary_weapon)
		return FALSE
	if(istype(thing, /obj/item/ammo_box/magazine))
		return FALSE
	return can_item_supply_ammo_for_weapon(thing, primary_weapon)

/datum/human_ai_module/inventory/proc/should_pickup_grenade(obj/item/thing)
	if(istype(thing, /obj/item/ammo_box/magazine/nade_box))
		return FALSE
	return (thing.flags_human_ai & GRENADE_ITEM) && can_item_supply_grenade(thing)

/datum/human_ai_module/inventory/proc/should_pickup_tool(obj/item/thing)
	return thing.flags_human_ai & TOOL_ITEM

/datum/human_ai_module/inventory/proc/get_pickup_storage_equipment_types(obj/item/thing)
	var/list/equipment_types = list()
	if(!thing)
		return equipment_types

	if(thing.flags_human_ai & HEALING_ITEM)
		equipment_types += HUMAN_AI_HEALTHITEMS

	if(should_pickup_ammo(thing))
		equipment_types += HUMAN_AI_AMMUNITION

	if(istype(thing, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/nade = thing
		if(!nade.active)
			equipment_types += HUMAN_AI_GRENADES
	else if(!istype(thing, /obj/item/ammo_box/magazine/nade_box) && can_item_supply_grenade(thing))
		equipment_types += HUMAN_AI_GRENADES

	if(should_pickup_tool(thing))
		equipment_types += HUMAN_AI_TOOLS

	return equipment_types

/datum/human_ai_module/inventory/proc/has_queued_weapon_pickup()
	for(var/item in to_pickup)
		if(isgun(item)) // One weapon at a time
			return TRUE
	return FALSE

/datum/human_ai_module/inventory/proc/invalidate_nearby_item_search()
	nearby_item_search_dirty = TRUE

#undef HUMAN_AI_PICKUP_SCAN_CONTINUE
#undef HUMAN_AI_PICKUP_SCAN_SKIP
#undef HUMAN_AI_PICKUP_SCAN_STOP
#undef HUMAN_AI_PICKUP_APPROACH_IN_RANGE
#undef HUMAN_AI_PICKUP_APPROACH_MOVING
#undef HUMAN_AI_PICKUP_APPROACH_FAILED
