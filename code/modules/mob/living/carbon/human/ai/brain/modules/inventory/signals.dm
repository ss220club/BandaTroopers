/datum/human_ai_module/inventory/proc/register_signals()
	if(!has_valid_owner())
		return
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	controller.register_signal_for(src, COMSIG_HUMAN_EQUIPPED_ITEM, PROC_REF(on_item_equip))
	controller.register_signal_for(src, COMSIG_HUMAN_UNEQUIPPED_ITEM, PROC_REF(on_item_unequip))
	controller.register_signal_for(src, COMSIG_MOB_PICKUP_ITEM, PROC_REF(on_item_pickup))
	controller.register_signal_for(src, COMSIG_MOB_DROP_ITEM, PROC_REF(on_item_drop))

/datum/human_ai_module/inventory/proc/can_handle_runtime_inventory_signal()
	return can_continue_inventory_work()

/datum/human_ai_module/inventory/proc/on_equipment_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER

	if(isturf(source.loc))
		forget_equipped_item_origin(source)
		UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/// Whenever an item is deleted, purge it from anywhere it may be stored in here
/datum/human_ai_module/inventory/proc/on_item_delete(obj/item/source, force)
	SIGNAL_HANDLER

	handle_deleted_item_ref(source)

/datum/human_ai_module/inventory/proc/handle_deleted_item_ref(obj/item/source)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	unqueue_pickup(source)
	clear_deleted_active_grenade_ref(source)
	invalidate_inventory_runtime_caches()
	forget_equipped_item_origin(source) // SS220 EDIT: deleted held items must not keep stale original-slot tracking

	clear_container_ref_for_item(source)

	remove_from_equipment_maps(source)

/datum/human_ai_module/inventory/proc/clear_deleted_active_grenade_ref(obj/item/source)
	if(source == get_owner_active_grenade()) // SS220 EDIT: purge deleted grenade threat refs immediately
		clear_owner_active_grenade()

/datum/human_ai_module/inventory/proc/invalidate_inventory_runtime_caches()
	invalidate_nearby_item_search()
	if(can_handle_runtime_inventory_signal())
		notify_owner_inventory_runtime_changed()

/datum/human_ai_module/inventory/proc/on_item_equip(datum/source, obj/item/equipment, slot)
	SIGNAL_HANDLER
	if(!can_handle_runtime_inventory_signal())
		return

	unqueue_pickup(equipment)
	invalidate_inventory_runtime_caches()

	handle_equipped_storage(equipment, slot)
	handle_equipped_primary_weapon(equipment, slot)
	handle_worn_nightvision_change(equipment, slot, TRUE)

/datum/human_ai_module/inventory/proc/handle_equipped_storage(obj/item/equipment, slot)
	if(!(slot in important_storage_slots) || !istype(equipment, /obj/item/storage))
		return

	recalculate_containers()
	appraise_inventory(slot == WEAR_WAIST, slot == WEAR_BACK, slot == WEAR_L_STORE, slot == WEAR_R_STORE, slot == WEAR_JACKET, slot == WEAR_BODY)

/datum/human_ai_module/inventory/proc/handle_equipped_primary_weapon(obj/item/equipment, slot)
	if(!primary_weapon && isgun(equipment) && can_select_firearm(equipment) && (slot == WEAR_J_STORE))
		set_primary_weapon(equipment)

/datum/human_ai_module/inventory/proc/handle_worn_nightvision_change(obj/item/equipment, slot, enabled)
	if(istype(equipment, /obj/item/clothing/glasses/night) && (slot == WEAR_EYES))
		has_nightvision = enabled

/datum/human_ai_module/inventory/proc/on_item_unequip(datum/source, obj/item/equipment, slot)
	SIGNAL_HANDLER
	if(!can_handle_runtime_inventory_signal())
		return

	invalidate_inventory_runtime_caches()

	handle_unequipped_storage(equipment, slot)
	handle_unequipped_weapon(equipment)
	handle_worn_nightvision_change(equipment, slot, FALSE)

/datum/human_ai_module/inventory/proc/handle_unequipped_storage(obj/item/equipment, slot)
	if(!(important_storage_slots_bitflag & slot) || !istype(equipment, /obj/item/storage))
		return

	recalculate_containers()
	appraise_inventory(slot == SLOT_WAIST, slot == SLOT_BACK, slot == SLOT_STORE, slot == SLOT_STORE, slot == SLOT_OCLOTHING, slot == SLOT_ICLOTHING)

/datum/human_ai_module/inventory/proc/handle_unequipped_weapon(obj/item/equipment)
	if(isgun(equipment))
		appraise_inventory(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)

/datum/human_ai_module/inventory/proc/on_item_pickup(datum/source, obj/item/picked_up)
	SIGNAL_HANDLER

	if(!can_handle_runtime_inventory_signal())
		return

	invalidate_inventory_runtime_caches()

	handle_picked_up_primary_weapon(picked_up)

	unqueue_pickup(picked_up)
	handle_picked_up_active_grenade(picked_up)

/datum/human_ai_module/inventory/proc/handle_picked_up_primary_weapon(obj/item/picked_up)
	if(!primary_weapon && isgun(picked_up) && can_select_firearm(picked_up))
		set_primary_weapon(picked_up)

/datum/human_ai_module/inventory/proc/handle_picked_up_active_grenade(obj/item/picked_up)
	if(picked_up != get_owner_active_grenade()) // SS220 EDIT: once someone holds the grenade, stop floor-threat gating - unless throw-back is active
		return

	if(!has_owner_ongoing_action(/datum/ai_action/throw_back_nade))
		addtimer(CALLBACK(src, PROC_REF(clear_active_grenade_if_stale), picked_up), 1 SECONDS) // SS220 EDIT: delay reset so throw-back action has time to spawn on next scheduler tick

/datum/human_ai_module/inventory/proc/on_item_drop(datum/source, obj/item/dropped)
	SIGNAL_HANDLER
	if(!can_handle_runtime_inventory_signal())
		return

	invalidate_inventory_runtime_caches()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller || controller.is_zombie())
		return

	handle_dropped_primary_weapon(dropped)
	handle_dropped_storage(dropped)
	remove_from_equipment_maps(dropped)

/datum/human_ai_module/inventory/proc/handle_dropped_primary_weapon(obj/item/dropped)
	if(dropped != primary_weapon)
		return

	var/datum/human_ai_firearm_profile/current_gun_data = gun_data
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return
	if(!(current_gun_data?.disposable && !controller.can_use_item(primary_weapon)))
		queue_pickup(dropped)
	set_primary_weapon(null)

/datum/human_ai_module/inventory/proc/handle_dropped_storage(obj/item/dropped)
	var/storage_id = get_container_id_for_item(dropped)
	if(storage_id)
		appraise_inventory(storage_id == HUMAN_AI_STORAGE_BELT, storage_id == HUMAN_AI_STORAGE_BACKPACK, storage_id == HUMAN_AI_STORAGE_LEFT_POCKET, storage_id == HUMAN_AI_STORAGE_RIGHT_POCKET, storage_id == HUMAN_AI_STORAGE_ARMOR, storage_id == HUMAN_AI_STORAGE_UNIFORM)

/datum/human_ai_module/inventory/proc/on_primary_delete(datum/source, force)
	SIGNAL_HANDLER

	set_primary_weapon(null)
	unqueue_pickup(source)
	invalidate_inventory_runtime_caches()

/datum/human_ai_module/inventory/proc/on_secondary_delete(datum/source, force)
	SIGNAL_HANDLER
	remove_secondary_weapon(source)

/// Signal for if a melee weapon is dropped
/datum/human_ai_module/inventory/proc/on_melee_dropped()
	SIGNAL_HANDLER

	UnregisterSignal(drawn_melee_weapon, COMSIG_ITEM_DROPPED)
	drawn_melee_weapon = null
