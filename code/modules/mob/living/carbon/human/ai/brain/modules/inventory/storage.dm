/datum/human_ai_module/inventory/proc/get_container_ref(container_id)
	RETURN_TYPE(/obj/item/storage)
	return container_refs[container_id]

/datum/human_ai_module/inventory/proc/has_container_ref(container_id)
	return !!get_container_ref(container_id)

/datum/human_ai_module/inventory/proc/reset_container_refs()
	container_refs = list(
		HUMAN_AI_STORAGE_BELT = null,
		HUMAN_AI_STORAGE_BACKPACK = null,
		HUMAN_AI_STORAGE_LEFT_POCKET = null,
		HUMAN_AI_STORAGE_RIGHT_POCKET = null,
		HUMAN_AI_STORAGE_ARMOR = null,
		HUMAN_AI_STORAGE_UNIFORM = null,
	)

/datum/human_ai_module/inventory/proc/set_container_ref(container_id, obj/item/storage/container)
	if(!container_id)
		return FALSE

	container_refs[container_id] = container
	return TRUE

/datum/human_ai_module/inventory/proc/clear_container_ref(container_id)
	if(!container_id || !(container_id in container_refs))
		return FALSE

	container_refs[container_id] = null
	return TRUE

/datum/human_ai_module/inventory/proc/clear_container_ref_for_item(obj/item/item)
	if(!item)
		return FALSE

	var/cleared = FALSE
	for(var/container_id in container_refs)
		if(get_container_ref(container_id) != item)
			continue

		clear_container_ref(container_id)
		cleared = TRUE

	return cleared

/datum/human_ai_module/inventory/proc/get_container_id_for_item(obj/item/item)
	if(!item)
		return null

	for(var/container_id in container_refs)
		if(get_container_ref(container_id) == item)
			return container_id

	return null

/datum/human_ai_module/inventory/proc/remember_equipped_item_origin(obj/item/item, storage_id)
	if(!item || !storage_id)
		return FALSE

	equipped_items_original_loc[item] = storage_id
	return TRUE

/datum/human_ai_module/inventory/proc/forget_equipped_item_origin(obj/item/item)
	if(!item)
		return FALSE
	if(!(item in equipped_items_original_loc))
		return FALSE

	equipped_items_original_loc -= item
	return TRUE

/datum/human_ai_module/inventory/proc/has_equipped_item_origin(obj/item/item)
	return item && (item in equipped_items_original_loc)

/datum/human_ai_module/inventory/proc/take_equipped_item_origin(obj/item/item)
	if(!has_equipped_item_origin(item))
		return null

	var/storage_id = equipped_items_original_loc[item]
	forget_equipped_item_origin(item)
	return storage_id

/// Given a "storage type", returns the storage item
/datum/human_ai_module/inventory/proc/get_object_from_loc(object_loc)
	RETURN_TYPE(/obj/item/storage)

	var/obj/item/storage/storage_object = object_loc
	if(istype(storage_object))
		return storage_object

	return context?.controller?.get_storage_from_loc(object_loc)

/// Given a location and a reference, puts a referenced object into the AI's hand if possible
/datum/human_ai_module/inventory/proc/equip_item_from_equipment_map(object_type, obj/item/object_ref)
	if(!object_type || !object_ref)
		return
	if(!can_continue_inventory_work())
		return FALSE

	var/object_loc = get_equipment_location(object_ref, object_type)
	var/obj/item/storage/storage_object = get_object_from_loc(object_loc)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(controller.is_item_equipped_or_held(object_ref))
		remember_equipped_item_origin(object_ref, object_loc)
		RegisterSignal(object_ref, COMSIG_ITEM_DROPPED, PROC_REF(on_equipment_dropped), override = TRUE)
		return controller.put_in_active_hand(object_ref)

	if(!storage_object)
		remove_from_equipment_map(object_ref, object_type)
		forget_equipped_item_origin(object_ref)
		return

	if(object_ref.loc != storage_object)
		remove_from_equipment_map(object_ref, object_type)
		forget_equipped_item_origin(object_ref)
		return

	controller.remove_from_storage(storage_object, object_ref)
	remember_equipped_item_origin(object_ref, object_loc)
	RegisterSignal(object_ref, COMSIG_ITEM_DROPPED, PROC_REF(on_equipment_dropped), override = TRUE)

	return controller.put_in_active_hand(object_ref)

/datum/human_ai_module/inventory/proc/store_item(obj/item/object_ref, object_loc, slot_type)
	if(slot_type)
		return store_item_as_types(object_ref, object_loc, list(slot_type))

	return store_item_as_types(object_ref, object_loc)

/datum/human_ai_module/inventory/proc/store_item_by_flags(obj/item/object_ref, object_loc)
	return store_item_as_types(object_ref, object_loc, get_equipment_types_for_item(object_ref))

/datum/human_ai_module/inventory/proc/store_item_as_types(obj/item/object_ref, object_loc, list/slot_types)
	// SS220 EDIT - START: late AI store callbacks can outlive the held item, owner, or original storage slot
	var/datum/human_tied_controller/controller = context?.controller
	if(!can_continue_inventory_work() || !has_valid_owner() || !controller || QDELETED(object_ref))
		unqueue_pickup(object_ref)
		forget_equipped_item_origin(object_ref)
		remove_from_equipment_maps(object_ref)
		return FALSE

	if(!controller.is_item_equipped_or_held(object_ref))
		unqueue_pickup(object_ref)
		forget_equipped_item_origin(object_ref)
		remove_from_equipment_maps(object_ref)
		return FALSE

	var/storage_loc = object_loc
	var/obj/item/storage/storage_object

	if(has_equipped_item_origin(object_ref))
		storage_loc = take_equipped_item_origin(object_ref)
		storage_object = get_object_from_loc(storage_loc)
	else if(storage_loc) // we assume that we've already checked if something will fit or not
		storage_object = get_container_ref(storage_loc)

	if(!storage_object || !controller.attempt_item_insertion(storage_object, object_ref, FALSE))
		remove_from_equipment_maps(object_ref)
		if(controller.is_holding(object_ref))
			controller.drop_held_item(object_ref)
		unqueue_pickup(object_ref)
		return FALSE

	set_equipment_locations(object_ref, storage_loc, slot_types)

	unqueue_pickup(object_ref)
	return TRUE
	// SS220 EDIT - END

/// Reappraises what storage items the AI has
/datum/human_ai_module/inventory/proc/recalculate_containers()
	reset_container_refs()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return
	if(isstorage(controller.get_belt()))
		set_container_ref(HUMAN_AI_STORAGE_BELT, controller.get_belt())
	if(isstorage(controller.get_back()))
		set_container_ref(HUMAN_AI_STORAGE_BACKPACK, controller.get_back())
	if(isstorage(controller.get_l_store()))
		set_container_ref(HUMAN_AI_STORAGE_LEFT_POCKET, controller.get_l_store())
	if(isstorage(controller.get_r_store()))
		set_container_ref(HUMAN_AI_STORAGE_RIGHT_POCKET, controller.get_r_store())
	if(istype(controller.get_wear_suit(), /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/storage_suit = controller.get_wear_suit()
		set_container_ref(HUMAN_AI_STORAGE_ARMOR, storage_suit.pockets)
	if(isclothing(controller.get_w_uniform()))
		var/obj/item/clothing/accessory/storage/storage_accessory = locate(/obj/item/clothing/accessory/storage) in controller.get_w_uniform().accessories
		if(storage_accessory)
			set_container_ref(HUMAN_AI_STORAGE_UNIFORM, storage_accessory.hold)

/datum/human_ai_module/inventory/proc/storage_has_room(obj/item/inserting)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return null

	for(var/container_id in container_refs)
		var/obj/item/storage/container = get_container_ref(container_id)
		if(controller.can_be_inserted(container, inserting, TRUE))
			return container_id
