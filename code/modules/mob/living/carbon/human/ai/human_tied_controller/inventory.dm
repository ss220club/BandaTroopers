// Raw hand read primitives

/datum/human_tied_controller/proc/get_active_hand()
	RETURN_TYPE(/obj/item)
	return tied_human?.get_active_hand()

/datum/human_tied_controller/proc/get_inactive_hand()
	RETURN_TYPE(/obj/item)
	return tied_human?.get_inactive_hand()

/datum/human_tied_controller/proc/get_held_item()
	RETURN_TYPE(/obj/item)
	return tied_human?.get_held_item()

/datum/human_tied_controller/proc/is_holding(obj/item/item)
	return tied_human?.is_holding(item)

/datum/human_tied_controller/proc/get_hand_holding(obj/item/item)
	if(!can_read_puppet() || !item)
		return null
	if(tied_human.get_active_hand() == item)
		return "active"
	if(tied_human.get_inactive_hand() == item)
		return "inactive"
	return null

// Raw hand mutation primitives

/datum/human_tied_controller/proc/swap_hand()
	if(!can_mutate_puppet())
		return FALSE
	tied_human.swap_hand()
	return TRUE

/datum/human_tied_controller/proc/put_in_active_hand(obj/item/item)
	if(!can_mutate_puppet() || !item)
		return FALSE
	return tied_human.put_in_active_hand(item)

/datum/human_tied_controller/proc/put_in_hands(obj/item/item, force = TRUE)
	if(!can_mutate_puppet() || !item)
		return FALSE
	return tied_human.put_in_hands(item, force)

/datum/human_tied_controller/proc/drop_held_item(obj/item/item)
	if(!can_mutate_puppet() || !item)
		return FALSE
	return tied_human.drop_held_item(item)

/datum/human_tied_controller/proc/drop_inv_item_on_ground(obj/item/item)
	if(!can_mutate_puppet() || !item)
		return FALSE
	return tied_human.drop_inv_item_on_ground(item)

/datum/human_tied_controller/proc/u_equip(obj/item/item)
	if(!can_mutate_puppet() || !item)
		return FALSE
	return tied_human.u_equip(item)

/datum/human_tied_controller/proc/equip_to_slot(obj/item/item, slot, force = TRUE)
	if(!can_mutate_puppet() || !item || !slot)
		return FALSE
	return tied_human.equip_to_slot(item, slot, force)

/datum/human_tied_controller/proc/equip_to_slot_if_possible(obj/item/item, slot, force = TRUE)
	if(!can_mutate_puppet() || !item || !slot)
		return FALSE
	return tied_human.equip_to_slot_if_possible(item, slot, force)

/datum/human_tied_controller/proc/equip_to_slot_or_del(obj/item/item, slot, force = TRUE)
	if(!can_mutate_puppet() || !item || !slot)
		return FALSE
	return tied_human.equip_to_slot_or_del(item, slot, force)

/datum/human_tied_controller/proc/get_equipped_items(include_pockets = FALSE)
	if(!can_read_puppet())
		return list()
	return tied_human.get_equipped_items(include_pockets)

/datum/human_tied_controller/proc/get_l_hand()
	RETURN_TYPE(/obj/item)
	return tied_human?.l_hand

/datum/human_tied_controller/proc/get_r_hand()
	RETURN_TYPE(/obj/item)
	return tied_human?.r_hand

/datum/human_tied_controller/proc/get_shoes()
	RETURN_TYPE(/obj/item)
	return tied_human?.shoes

/datum/human_tied_controller/proc/get_s_store()
	RETURN_TYPE(/obj/item)
	return tied_human?.s_store

/datum/human_tied_controller/proc/get_back()
	RETURN_TYPE(/obj/item)
	return tied_human?.back

/datum/human_tied_controller/proc/get_belt()
	RETURN_TYPE(/obj/item)
	return tied_human?.belt

/datum/human_tied_controller/proc/get_l_store()
	RETURN_TYPE(/obj/item)
	return tied_human?.l_store

/datum/human_tied_controller/proc/get_r_store()
	RETURN_TYPE(/obj/item)
	return tied_human?.r_store

/datum/human_tied_controller/proc/get_wear_suit()
	RETURN_TYPE(/obj/item/clothing/suit)
	return tied_human?.wear_suit

/datum/human_tied_controller/proc/get_w_uniform()
	RETURN_TYPE(/obj/item/clothing/under)
	return tied_human?.w_uniform

/datum/human_tied_controller/proc/get_wear_id()
	RETURN_TYPE(/obj/item)
	return tied_human?.wear_id

/datum/human_tied_controller/proc/get_limb(limb_name)
	if(!can_read_puppet())
		return null
	return tied_human.get_limb(limb_name)

/datum/human_tied_controller/proc/has_item_in_hands()
	return istype(tied_human?.l_hand, /obj/item) || istype(tied_human?.r_hand, /obj/item)

/datum/human_tied_controller/proc/is_item_equipped_or_held(obj/item/item)
	return item && (item.loc == tied_human)

/datum/human_tied_controller/proc/is_item_equipped_or_in_direct_storage(obj/item/item)
	if(!can_read_puppet() || !item || QDELETED(item))
		return FALSE
	if(item.loc == tied_human)
		return TRUE
	var/atom/item_loc = item.loc
	return item_loc?.loc == tied_human

/datum/human_tied_controller/proc/is_item_in_primary_storage_or_hands(obj/item/item)
	if(!item)
		return FALSE
	return (tied_human?.s_store == item) || (tied_human?.l_hand == item) || (tied_human?.r_hand == item)

/datum/human_tied_controller/proc/can_insert_into_shoes(obj/item/item)
	return item && tied_human?.shoes && tied_human.shoes.can_be_inserted(item)

/datum/human_tied_controller/proc/attempt_insert_into_shoes(obj/item/item)
	if(!can_mutate_puppet() || !can_insert_into_shoes(item))
		return FALSE
	return tied_human.shoes.attempt_insert_item(tied_human, item)

/datum/human_tied_controller/proc/remove_item_from_shoes()
	if(!can_mutate_puppet() || !tied_human.shoes)
		return null
	return tied_human.shoes.remove_item(tied_human)

/datum/human_tied_controller/proc/get_storage_from_loc(object_loc)
	RETURN_TYPE(/obj/item/storage)

	if(!can_read_puppet())
		return null

	var/obj/item/storage/storage_object
	switch(object_loc)
		if("belt")
			storage_object = tied_human.belt
		if("backpack")
			storage_object = tied_human.back
		if("left_pocket")
			storage_object = tied_human.l_store
		if("right_pocket")
			storage_object = tied_human.r_store
		if("armor")
			if(istype(tied_human.wear_suit, /obj/item/clothing/suit/storage))
				var/obj/item/clothing/suit/storage/storage_suit = tied_human.wear_suit
				storage_object = storage_suit.pockets
		if("uniform")
			if(isclothing(tied_human.w_uniform))
				var/obj/item/clothing/accessory/storage/storage_accessory = locate(/obj/item/clothing/accessory/storage) in tied_human.w_uniform.accessories
				storage_object = storage_accessory.hold
	return storage_object

/datum/human_tied_controller/proc/remove_from_storage(obj/item/storage/storage_object, obj/item/item)
	if(!can_mutate_puppet() || !storage_object || !item)
		return FALSE
	storage_object.remove_from_storage(item, tied_human)
	return TRUE

/datum/human_tied_controller/proc/attempt_item_insertion(obj/item/storage/storage_object, obj/item/item, silent = FALSE)
	if(!can_mutate_puppet() || !storage_object || !item)
		return FALSE
	return storage_object.attempt_item_insertion(item, silent, tied_human)

/datum/human_tied_controller/proc/can_be_inserted(obj/item/storage/storage_object, obj/item/item, stop_messages = TRUE)
	if(!can_read_puppet() || !storage_object || !item)
		return FALSE
	return storage_object.can_be_inserted(item, tied_human, stop_messages)

/datum/human_tied_controller/proc/turn_suit_light(obj/item/clothing/suit/suit, new_state)
	if(!can_mutate_puppet() || !suit)
		return FALSE
	suit.turn_light(tied_human, new_state)
	return TRUE

// Behavior helpers

/datum/human_tied_controller/proc/ensure_active_hand(obj/item/held_item)
	if(!can_mutate_puppet() || !held_item)
		return FALSE
	if(tied_human.get_inactive_hand() == held_item)
		tied_human.swap_hand()
	return tied_human.get_active_hand() == held_item

/datum/human_tied_controller/proc/can_clear_active_hand()
	var/obj/item/active_item = get_active_hand()
	return can_mutate_puppet() && active_item && !(active_item.flags_item & NODROP)

/datum/human_tied_controller/proc/clear_active_hand_if_possible()
	if(!can_clear_active_hand())
		return FALSE
	return drop_held_item(get_active_hand())
