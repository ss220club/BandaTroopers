/datum/human_ai_brain
	/// If an AI takes out an item from their equipment_map, the place it was last stored is added to this dict
	var/list/equipped_items_original_loc = list()
	/// Root equipped slot for indexed items; keeps nested-storage entries removable during partial rescans.
	var/list/equipment_item_root_slots = list() // SS220 EDIT: track nested Human AI inventory roots

	/// A list of items that the AI is trying to pick up
	var/list/obj/item/to_pickup = list()

	/// If TRUE, the AI won't try to pick up anything
	var/ignore_looting = FALSE

	/// list("object_type" = list(object_ref = "slot")
	var/list/equipment_map = list(
		HUMAN_AI_HEALTHITEMS = list(),
		HUMAN_AI_AMMUNITION = list(),
		HUMAN_AI_GRENADES = list(),
		HUMAN_AI_TOOLS = list(),
	)

	/// Dict of "storage type" : storage ref
	var/list/container_refs = list(
		"belt" = null,
		"backpack" = null,
		"left_pocket" = null,
		"right_pocket" = null,
		"suit_storage" = null, // SS220 EDIT: containers worn in WEAR_J_STORE are real inventory roots
		"armor" = null,
		"uniform" = null,
	)

	/// Static list of storage slots that the AI pays attention to for inventory appraisal
	var/static/list/important_storage_slots = list(
		WEAR_BACK,
		WEAR_WAIST,
		WEAR_L_STORE,
		WEAR_R_STORE,
		WEAR_J_STORE, // SS220 EDIT: index containers carried in the suit-storage slot
		WEAR_JACKET,
		WEAR_BODY,
	)

	/// Bitflag equivalent of important_storage_slots
	var/static/important_storage_slots_bitflag = SLOT_BACK | SLOT_WAIST | SLOT_STORE | SLOT_SUIT_STORE | SLOT_OCLOTHING | SLOT_ICLOTHING // SS220 EDIT: include suit storage

	/// If TRUE, the AI ignores darkness when it comes to determining vision
	var/has_nightvision = FALSE

/// Given a "storage type", returns the storage item
/datum/human_ai_brain/proc/get_object_from_loc(object_loc)
	RETURN_TYPE(/obj/item/storage)

	// SS220 EDIT - START: nested inventory entries store their actual container rather than only a top-level slot name
	if(istype(object_loc, /obj/item/storage))
		var/obj/item/storage/nested_storage = object_loc
		if(get_storage_root_slot(nested_storage))
			return nested_storage
		return
	// SS220 EDIT - END

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
		if("suit_storage")
			if(istype(tied_human.s_store, /obj/item/storage))
				storage_object = tied_human.s_store
		if("armor")
			if(istype(tied_human.wear_suit, /obj/item/clothing/suit/storage))
				var/obj/item/clothing/suit/storage/storage_suit = tied_human.wear_suit
				storage_object = storage_suit.pockets
		if("uniform")
			if(isclothing(tied_human.w_uniform))
				var/obj/item/clothing/accessory/storage/storage_accessory = locate(/obj/item/clothing/accessory/storage) in tied_human.w_uniform.accessories
				storage_object = storage_accessory.hold
	return storage_object

/// Given a location and a reference, puts a referenced object into the AI's hand if possible
/datum/human_ai_brain/proc/equip_item_from_equipment_map(object_type, obj/item/object_ref)
	if(!object_type || !object_ref)
		return

	var/object_loc = equipment_map[object_type][object_ref]
	var/obj/item/storage/storage_object = get_object_from_loc(object_loc)
	if(object_ref.loc == tied_human)
		equipped_items_original_loc[object_ref] = object_loc
		RegisterSignal(object_ref, COMSIG_ITEM_DROPPED, PROC_REF(on_equipment_dropped), override = TRUE)
		return tied_human.put_in_active_hand(object_ref)

	if(!storage_object)
		equipment_map[object_type] -= object_ref
		equipped_items_original_loc -= object_ref
		equipment_item_root_slots -= object_ref // SS220 EDIT: purge stale nested inventory metadata
		return

	if(object_ref.loc != storage_object)
		equipment_map[object_type] -= object_ref
		equipped_items_original_loc -= object_ref
		equipment_item_root_slots -= object_ref // SS220 EDIT: purge stale nested inventory metadata
		return

	storage_object.remove_from_storage(object_ref, tied_human)
	equipped_items_original_loc[object_ref] = object_loc
	RegisterSignal(object_ref, COMSIG_ITEM_DROPPED, PROC_REF(on_equipment_dropped), override = TRUE)

	return tied_human.put_in_active_hand(object_ref)

/// Given an object path and where it may be stored, returns a ref to that object if it exists
/datum/human_ai_brain/proc/get_item_from_equipment_map_path(object_path, object_type)
	return (locate(object_path) in equipment_map[object_type])

/datum/human_ai_brain/proc/store_item(obj/item/object_ref, object_loc, slot_type, allow_same_turf = FALSE)
	// SS220 EDIT - START: late AI store callbacks can outlive the held item, owner, or original storage slot
	if(!has_valid_tied_human() || QDELETED(object_ref))
		to_pickup -= object_ref
		equipped_items_original_loc -= object_ref
		if(slot_type)
			equipment_map[slot_type] -= object_ref
		equipment_item_root_slots -= object_ref // SS220 EDIT: purge nested inventory metadata with the item
		return FALSE

	if(object_ref.loc != tied_human && (!allow_same_turf || get_turf(object_ref) != get_turf(tied_human)))
		to_pickup -= object_ref
		equipped_items_original_loc -= object_ref
		if(slot_type)
			equipment_map[slot_type] -= object_ref
		equipment_item_root_slots -= object_ref // SS220 EDIT: purge nested inventory metadata with the item
		return FALSE

	var/original_storage_loc
	var/storage_loc = object_loc
	var/obj/item/storage/storage_object

	if(object_ref in equipped_items_original_loc)
		original_storage_loc = equipped_items_original_loc[object_ref]
		storage_loc = original_storage_loc
		storage_object = get_object_from_loc(storage_loc)
	else if(storage_loc) // we assume that we've already checked if something will fit or not
		storage_object = get_object_from_loc(storage_loc) // SS220 EDIT: storage_loc may be a nested storage ref

	if(storage_object?.attempt_item_insertion(object_ref, FALSE, tied_human))
		equipped_items_original_loc -= object_ref
		if(slot_type)
			equipment_map[slot_type][object_ref] = storage_loc
		equipment_item_root_slots[object_ref] = get_storage_root_slot(storage_object) // SS220 EDIT: retain nested root ownership
		to_pickup -= object_ref
		return TRUE

	// If the original container disappeared or rejected the item, try the pre-checked fallback before dropping it.
	if(original_storage_loc && object_loc && object_loc != original_storage_loc)
		storage_loc = object_loc
		storage_object = get_object_from_loc(storage_loc)
		if(storage_object?.attempt_item_insertion(object_ref, FALSE, tied_human))
			equipped_items_original_loc -= object_ref
			if(slot_type)
				equipment_map[slot_type][object_ref] = storage_loc
			equipment_item_root_slots[object_ref] = get_storage_root_slot(storage_object) // SS220 EDIT: retain fallback root ownership
			to_pickup -= object_ref
			return TRUE

	equipped_items_original_loc -= object_ref
	if(slot_type)
		equipment_map[slot_type] -= object_ref
	equipment_item_root_slots -= object_ref // SS220 EDIT: purge nested inventory metadata when storage fails
	if(tied_human.is_holding(object_ref))
		tied_human.drop_held_item(object_ref)
	to_pickup -= object_ref
	return FALSE
	// SS220 EDIT - END

/// Whenever an item is deleted, purge it from anywhere it may be stored in here
/datum/human_ai_brain/proc/on_item_delete(obj/item/source, force)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	to_pickup -= source
	if(source == active_grenade_found) // SS220 EDIT: purge deleted grenade threat refs immediately
		active_grenade_found = null
	invalidate_nearby_item_search()
	invalidate_halo_runtime_caches()
	equipped_items_original_loc -= source // SS220 EDIT: deleted held items must not keep stale original-slot tracking
	equipment_item_root_slots -= source // SS220 EDIT: deleted items must not keep nested root tracking

	for(var/name in container_refs)
		if(source == container_refs[name])
			container_refs[name] = null
			return

	for(var/id in equipment_map)
		for(var/obj/item/item_ref as anything in equipment_map[id])
			if(source == item_ref)
				equipment_map[id] -= item_ref
				return

/datum/human_ai_brain/proc/on_item_equip(datum/source, obj/item/equipment, slot)
	SIGNAL_HANDLER
	to_pickup -= equipment
	invalidate_nearby_item_search()
	invalidate_halo_runtime_caches()

	if((slot in important_storage_slots) && (istype(equipment, /obj/item/storage) || slot == WEAR_J_STORE))
		recalculate_containers()
		appraise_inventory(slot == WEAR_WAIST, slot == WEAR_BACK, slot == WEAR_L_STORE, slot == WEAR_R_STORE, slot == WEAR_JACKET, slot == WEAR_BODY, slot == WEAR_J_STORE)

	if(!primary_weapon && isgun(equipment) && (slot == WEAR_J_STORE))
		set_primary_weapon(equipment)

	if(istype(equipment, /obj/item/clothing/glasses/night) && (slot == WEAR_EYES))
		has_nightvision = TRUE

/datum/human_ai_brain/proc/on_item_unequip(datum/source, obj/item/equipment, slot)
	SIGNAL_HANDLER
	invalidate_nearby_item_search()
	invalidate_halo_runtime_caches()

	if((important_storage_slots_bitflag & slot) && (istype(equipment, /obj/item/storage) || slot == SLOT_SUIT_STORE))
		recalculate_containers()
		appraise_inventory(slot == SLOT_WAIST, slot == SLOT_BACK, slot == SLOT_STORE, slot == SLOT_STORE, slot == SLOT_OCLOTHING, slot == SLOT_ICLOTHING, slot == SLOT_SUIT_STORE)

	if(isgun(equipment))
		appraise_inventory(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)

	if(istype(equipment, /obj/item/clothing/glasses/night) && (slot == WEAR_EYES))
		has_nightvision = FALSE

/// Reappraises what storage items the AI has
/datum/human_ai_brain/proc/recalculate_containers()
	if(!has_valid_tied_human()) // SS220 EDIT AI: equipment signals may finish after the brain detached its owner during qdel
		return

	container_refs = list()
	if(isstorage(tied_human.belt))
		container_refs["belt"] = tied_human.belt
	if(isstorage(tied_human.back))
		container_refs["backpack"] = tied_human.back
	if(isstorage(tied_human.l_store))
		container_refs["left_pocket"] = tied_human.l_store
	if(isstorage(tied_human.r_store))
		container_refs["right_pocket"] = tied_human.r_store
	if(isstorage(tied_human.s_store))
		container_refs["suit_storage"] = tied_human.s_store // SS220 EDIT: UPP RPG rockets are commonly carried here
	if(istype(tied_human.wear_suit, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/storage_suit = tied_human.wear_suit
		container_refs["armor"] = storage_suit.pockets
	if(isclothing(tied_human.w_uniform))
		var/obj/item/clothing/accessory/storage/storage_accessory = locate(/obj/item/clothing/accessory/storage) in tied_human.w_uniform.accessories
		if(storage_accessory)
			container_refs["uniform"] = storage_accessory.hold

// SS220 EDIT - START: bounded helpers for equipped and nested Human AI storage
/datum/human_ai_brain/proc/get_storage_roots()
	var/list/storage_roots = list()
	for(var/root_slot in container_refs)
		var/obj/item/storage/root_storage = container_refs[root_slot]
		if(root_storage)
			storage_roots[root_storage] = root_slot

	if(istype(tied_human.wear_suit, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/worn_suit = tied_human.wear_suit
		for(var/obj/item/clothing/accessory/storage/storage_accessory in worn_suit.accessories)
			if(storage_accessory.hold)
				storage_roots[storage_accessory.hold] = "armor"

	return storage_roots

/datum/human_ai_brain/proc/storage_is_within(obj/item/storage/candidate, obj/item/storage/root_storage)
	var/list/visited = list()
	while(candidate && !(candidate in visited))
		if(candidate == root_storage)
			return TRUE
		visited += candidate
		if(!istype(candidate.loc, /obj/item/storage))
			break
		candidate = candidate.loc
	return FALSE

/datum/human_ai_brain/proc/get_storage_root_slot(obj/item/storage/candidate)
	if(!candidate || !has_valid_tied_human())
		return
	var/list/storage_roots = get_storage_roots()
	for(var/obj/item/storage/root_storage as anything in storage_roots)
		if(storage_is_within(candidate, root_storage))
			return storage_roots[root_storage]

/datum/human_ai_brain/proc/clear_equipment_map_slot(root_slot)
	for(var/id in equipment_map)
		for(var/obj/item/item as anything in equipment_map[id])
			if(equipment_map[id][item] != root_slot && equipment_item_root_slots[item] != root_slot)
				continue
			equipment_map[id] -= item
			equipment_item_root_slots -= item
// SS220 EDIT - END

/// Used to determine what the AI has in their inventory
/datum/human_ai_brain/proc/appraise_inventory(belt = TRUE, back = TRUE, pocket_l = TRUE, pocket_r = TRUE, armor = TRUE, uniform = TRUE, suit_storage = TRUE)
	// SS220 EDIT AI: equipment signals may finish after the component detached its owner during qdel
	if(!has_valid_tied_human())
		return

	if(previous_faction != tied_human.faction)
		previous_faction = tied_human.faction
		var/datum/human_ai_faction/our_faction = SShuman_ai.human_ai_factions[tied_human.faction]
		our_faction?.apply_faction_data(src)

	/*if(tied_human.shoes && !primary_melee) // snowflake bootknife check
		var/obj/item/weapon/knife = locate() in tied_human.shoes
		if(knife)
			set_primary_melee(knife)*/

	// SS220 EDIT - START: preset equipment is commonly loaded before the AI brain exists, so its equip signal was missed.
	// if(isgun(tied_human.s_store) && (tied_human.s_store != primary_weapon))
	// 	add_secondary_weapon(tied_human.s_store)
	if(isgun(tied_human.s_store) && (tied_human.s_store != primary_weapon))
		var/obj/item/weapon/gun/issued_suit_weapon = tied_human.s_store
		if(!primary_weapon)
			set_primary_weapon(issued_suit_weapon)
		else
			add_secondary_weapon(issued_suit_weapon)
	// SS220 EDIT - END

	tried_reload = FALSE // We don't really need to do this in a smart way
	if(belt)
		appraise_belt()

	if(back)
		appraise_back()

	if(pocket_l)
		appraise_left_pocket()

	if(pocket_r)
		appraise_right_pocket()

	if(suit_storage)
		appraise_suit_storage()

	if(armor)
		appraise_armor()

	if(uniform && isclothing(tied_human.w_uniform))
		appraise_uniform()

/datum/human_ai_brain/proc/appraise_belt()
	if(isgun(tied_human.belt) && (tied_human.belt != primary_weapon))
		add_secondary_weapon(tied_human.belt)
		return

	if(!istype(tied_human.belt, /obj/item/storage)) // belts can be backpacks, don't ask
		return

	clear_equipment_map_slot("belt") // SS220 EDIT: also clear nested entries owned by this slot

	RegisterSignal(tied_human.belt, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(tied_human.belt, "belt")

/datum/human_ai_brain/proc/appraise_back()
	if(isgun(tied_human.back) && (tied_human.back != primary_weapon))
		add_secondary_weapon(tied_human.back)
		return

	// SS220 EDIT - START: HALO transport rigs such as the SPNKr pack sit on the back slot as storage,
	// but they are not guaranteed to inherit backpack. AI still needs to appraise their contents.
	if(!istype(tied_human.back, /obj/item/storage))
		return
	// SS220 EDIT - END

	clear_equipment_map_slot("backpack") // SS220 EDIT: also clear nested entries owned by this slot

	RegisterSignal(tied_human.back, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(tied_human.back, "backpack")

/datum/human_ai_brain/proc/appraise_left_pocket()
	if(!istype(tied_human.l_store, /obj/item/storage/pouch))
		return

	clear_equipment_map_slot("left_pocket") // SS220 EDIT: also clear nested entries owned by this slot

	RegisterSignal(tied_human.l_store, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(tied_human.l_store, "left_pocket")

/datum/human_ai_brain/proc/appraise_right_pocket()
	if(!istype(tied_human.r_store, /obj/item/storage/pouch))
		return

	clear_equipment_map_slot("right_pocket") // SS220 EDIT: also clear nested entries owned by this slot

	RegisterSignal(tied_human.r_store, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(tied_human.r_store, "right_pocket")

/datum/human_ai_brain/proc/appraise_suit_storage()
	clear_equipment_map_slot("suit_storage")

	var/obj/item/suit_storage_item = tied_human.s_store
	if(!suit_storage_item)
		return

	RegisterSignal(suit_storage_item, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	if(istype(suit_storage_item, /obj/item/storage))
		item_slot_appraisal_loop(suit_storage_item, "suit_storage")
	else if(suit_storage_item.flags_human_ai & AMMUNITION_ITEM)
		equipment_map[HUMAN_AI_AMMUNITION][suit_storage_item] = "suit_storage"

/datum/human_ai_brain/proc/appraise_armor()
	if(!istype(tied_human.wear_suit, /obj/item/clothing/suit))
		return

	var/obj/item/clothing/suit/worn_armor = tied_human.wear_suit
	if(tied_human.loc && worn_armor.has_light && !worn_armor.light_on) // being in nullspace makes lights play weirdly
		worn_armor.turn_light(tied_human, TRUE) // SS220 EDIT: armor without a light must still have its storage appraised

	clear_equipment_map_slot("armor") // SS220 EDIT: also clear nested entries owned by this slot

	RegisterSignal(worn_armor, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	for(var/obj/item/clothing/accessory/storage/armour_webbing in worn_armor.accessories)
		item_slot_appraisal_loop(armour_webbing.hold, "armor") // SS220 EDIT: appraise the accessory's real storage root
	if(istype(worn_armor, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/storage_suit = worn_armor
		if(!storage_suit.get_pockets())
			return
		item_slot_appraisal_loop(storage_suit.pockets, "armor")

/datum/human_ai_brain/proc/appraise_uniform()
	var/obj/item/clothing/accessory/storage/located_storage = locate(/obj/item/clothing/accessory/storage) in tied_human.w_uniform.accessories
	if(!located_storage)
		return

	clear_equipment_map_slot("uniform") // SS220 EDIT: also clear nested entries owned by this slot

	RegisterSignal(located_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(located_storage.hold, "uniform")

/datum/human_ai_brain/proc/item_slot_appraisal_loop(obj/item/storage/container_to_loop, slot_to_assign)
	// SS220 EDIT - START: recursively index bounded storage descendants and retain each item's immediate source container
	if(!container_to_loop)
		return
	var/list/storage_queue = list(container_to_loop)
	var/list/visited_storages = list()
	var/storage_count = 0
	while(length(storage_queue) && storage_count < 64)
		var/obj/item/storage/current_storage = storage_queue[1]
		storage_queue.Cut(1, 2)
		if(QDELETED(current_storage) || (current_storage in visited_storages))
			continue
		visited_storages += current_storage
		storage_count++

		for(var/obj/item/inv_item as anything in current_storage)
			RegisterSignal(inv_item, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
			if(istype(inv_item, /obj/item/storage))
				storage_queue += inv_item

			if(inv_item.flags_human_ai & HEALING_ITEM)
				equipment_map[HUMAN_AI_HEALTHITEMS][inv_item] = current_storage
			else if(inv_item.flags_human_ai & AMMUNITION_ITEM)
				equipment_map[HUMAN_AI_AMMUNITION][inv_item] = current_storage
			else if(inv_item.flags_human_ai & GRENADE_ITEM)
				equipment_map[HUMAN_AI_GRENADES][inv_item] = current_storage
			else if(inv_item.flags_human_ai & TOOL_ITEM)
				equipment_map[HUMAN_AI_TOOLS][inv_item] = current_storage
			else if(isgun(inv_item) && !(inv_item in secondary_weapons))
				add_secondary_weapon(inv_item)

			if((inv_item in equipment_map[HUMAN_AI_HEALTHITEMS]) || (inv_item in equipment_map[HUMAN_AI_AMMUNITION]) || (inv_item in equipment_map[HUMAN_AI_GRENADES]) || (inv_item in equipment_map[HUMAN_AI_TOOLS]))
				equipment_item_root_slots[inv_item] = slot_to_assign
	// SS220 EDIT - END

/datum/human_ai_brain/proc/clear_main_hand()
	var/obj/item/active_hand = tied_human.get_active_hand()
	if(!active_hand)
		return

	if(primary_weapon == active_hand)
		if(!holster_primary())
			tied_human.drop_held_item(active_hand)
		return

	var/storage_id = storage_has_room(active_hand)
	if(!storage_id)
		tied_human.drop_held_item(active_hand)
		return

	store_item(active_hand, storage_id)

/datum/human_ai_brain/proc/storage_has_room(obj/item/inserting)
	// SS220 EDIT - START: consider every equipped root and its nested storage, not only six top-level refs
	var/list/storage_roots = get_storage_roots()
	var/list/storage_queue = list()
	var/list/visited_storages = list()
	for(var/obj/item/storage/root_storage as anything in storage_roots)
		storage_queue += root_storage

	var/storage_count = 0
	while(length(storage_queue) && storage_count < 64)
		var/obj/item/storage/container = storage_queue[1]
		storage_queue.Cut(1, 2)
		if(QDELETED(container) || (container in visited_storages))
			continue
		visited_storages += container
		storage_count++

		if(container != inserting && (!istype(inserting, /obj/item/storage) || !storage_is_within(container, inserting)) && container.can_be_inserted(inserting, tied_human, TRUE))
			return container

		for(var/obj/item/storage/nested_storage in container)
			storage_queue += nested_storage
	// SS220 EDIT - END

/datum/human_ai_brain/proc/on_equipment_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER

	if(isturf(source.loc))
		equipped_items_original_loc -= source
		equipment_item_root_slots -= source // SS220 EDIT: dropped held items no longer belong to an inventory root
		UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/// Indexes medicine picked up without free storage so it can be used before the AI drops it.
/datum/human_ai_brain/proc/index_held_health_item(obj/item/heal_item)
	if(QDELETED(heal_item) || heal_item.loc != tied_human)
		return FALSE
	equipment_map[HUMAN_AI_HEALTHITEMS][heal_item] = "hands" // SS220 EDIT: allow immediate treatment from a full inventory
	equipment_item_root_slots -= heal_item
	to_pickup -= heal_item
	RegisterSignal(heal_item, COMSIG_ITEM_DROPPED, PROC_REF(on_equipment_dropped), override = TRUE)
	return TRUE

/datum/human_ai_brain/proc/on_item_pickup(datum/source, obj/item/picked_up)
	SIGNAL_HANDLER

	invalidate_halo_runtime_caches()

	if(!primary_weapon && isgun(picked_up))
		set_primary_weapon(picked_up)

	to_pickup -= picked_up
	if(picked_up == active_grenade_found) // SS220 EDIT: once someone holds the grenade, stop floor-threat gating — unless throw-back is active
		if(!has_ongoing_action(/datum/ai_action/throw_back_nade))
			addtimer(CALLBACK(src, PROC_REF(clear_active_grenade_if_stale), picked_up), 1 SECONDS) // SS220 EDIT: delay reset so throw-back action has time to spawn on next scheduler tick
	invalidate_nearby_item_search()

/// SS220 EDIT: delayed reset of active_grenade_found — gives throw-back action one scheduler tick to spawn before clearing
/datum/human_ai_brain/proc/clear_active_grenade_if_stale(obj/item/explosive/grenade/grenade)
	if(active_grenade_found == grenade && !has_ongoing_action(/datum/ai_action/throw_back_nade))
		active_grenade_found = null

/datum/human_ai_brain/proc/on_item_drop(datum/source, obj/item/dropped)
	SIGNAL_HANDLER
	invalidate_nearby_item_search()
	invalidate_halo_runtime_caches()
	if(iszombie(tied_human))
		return

	if(iszombie(tied_human))
		return

	if(dropped == primary_weapon)
		var/datum/firearm_appraisal/current_gun_data = gun_data
		if(!(current_gun_data?.disposable && !primary_weapon.ai_can_use(tied_human, src)))
			to_pickup |= dropped
		set_primary_weapon(null)

	for(var/slot in container_refs)
		if(container_refs[slot] == dropped)
			appraise_inventory(slot == "belt", slot == "backpack", slot == "left_pocket", slot == "right_pocket", slot == "armor", slot == "uniform", slot == "suit_storage")
			break

	for(var/id in equipment_map)
		for(var/obj/item/item_ref as anything in equipment_map[id])
			if(item_ref == dropped)
				equipment_map[id] -= item_ref
				equipment_item_root_slots -= item_ref // SS220 EDIT: purge nested root metadata with dropped item
				return

/datum/human_ai_brain/proc/set_primary_weapon(obj/item/weapon/gun/new_gun)
	if(primary_weapon)
		UnregisterSignal(primary_weapon, COMSIG_PARENT_QDELETING)
	primary_weapon = new_gun
	appraise_primary()
	invalidate_nearby_item_search()
	invalidate_halo_runtime_caches()
	if(primary_weapon)
		RegisterSignal(primary_weapon, COMSIG_PARENT_QDELETING, PROC_REF(on_primary_delete), TRUE)

/datum/human_ai_brain/proc/on_primary_delete(datum/source, force)
	SIGNAL_HANDLER

	set_primary_weapon(null)
	to_pickup -= source
	invalidate_nearby_item_search()
	invalidate_halo_runtime_caches()

/*datum/human_ai_brain/proc/set_primary_melee(obj/item/weapon/new_melee)
	if(primary_melee)
		UnregisterSignal(primary_melee, COMSIG_PARENT_QDELETING)
	primary_melee = new_melee
	appraise_primary()
	if(primary_melee)
		RegisterSignal(primary_melee, COMSIG_PARENT_QDELETING, PROC_REF(on_primary_melee_delete))

/datum/human_ai_brain/proc/on_primary_melee_delete(datum/source, force)
	SIGNAL_HANDLER

	set_primary_melee(null)*/

/datum/human_ai_brain/proc/appraise_primary()
	gun_data = null
	if(!primary_weapon)
		return
	var/static/datum/firearm_appraisal/default = new()
	for(var/datum/firearm_appraisal/appraisal as anything in GLOB.firearm_appraisals)
		if(is_type_in_list(primary_weapon, appraisal.gun_types))
			gun_data = appraisal
			break

	if(!gun_data)
		gun_data = default

/datum/human_ai_brain/proc/item_search(list/things_around)
	// SS220 EDIT - START: preserve a live floor threat throughout the four-tile reaction, or a grenade already held for throw-back.
	var/grenade_threat_is_local = active_grenade_found && !QDELETED(active_grenade_found) && active_grenade_found.active \
		&& ((active_grenade_found.loc == tied_human) || (isturf(active_grenade_found.loc) && get_dist(tied_human, active_grenade_found) <= 4))
	if(!grenade_threat_is_local)
		active_grenade_found = null
	// SS220 EDIT - END
	// SS220 EDIT - START: an issued carried gun must be selected before considering weapons from the floor.
	var/has_usable_carried_weapon = FALSE
	if(!primary_weapon)
		for(var/obj/item/weapon/gun/carried_weapon as anything in secondary_weapons)
			if(!QDELETED(carried_weapon) && carried_weapon.ai_can_use(tied_human, src))
				has_usable_carried_weapon = TRUE
				break
	// SS220 EDIT - END

	search_loop:
		for(var/obj/item/thing in things_around)
			if(!isturf(thing.loc))
				continue

			if(thing in to_pickup)
				continue

			if(thing.flags_human_ai & GRENADE_ITEM)
				var/obj/item/explosive/grenade/nade = thing
				if(nade.active) // SS220 EDIT: every live floor grenade is a threat; the reaction action decides throw-back versus retreat
					active_grenade_found = thing
					continue

			// SS220 EDIT - START: ignore_looting must also suppress pickup candidates, not only the Item Pickup action.
			if(ignore_looting)
				continue
			// SS220 EDIT - END

			// if(!primary_weapon && isgun(thing))
			if(!primary_weapon && !has_usable_carried_weapon && isgun(thing)) // SS220 EDIT: prefer an issued carried weapon over floor loot
				var/obj/item/weapon/gun/thing_gun = thing
				for(var/item in to_pickup)
					if(isgun(item)) // One weapon at a time
						continue search_loop

				for(var/datum/firearm_appraisal/appraisal as anything in GLOB.firearm_appraisals)
					if(is_type_in_list(thing_gun, appraisal.gun_types))
						if(appraisal.disposable && thing_gun.current_mag?.current_rounds <= 0)
							continue search_loop
						break

				add_to_pickup(thing)

			if(istype(thing, /obj/item/storage/belt) && !container_refs["belt"])
				add_to_pickup(thing)

			if(istype(thing, /obj/item/storage/backpack) && !container_refs["backpack"])
				add_to_pickup(thing)

			if(istype(thing, /obj/item/storage/pouch) && (!container_refs["left_pocket"] || !container_refs["right_pocket"]))
				add_to_pickup(thing)

			// SS220 EDIT - START: ally-only medicine is valid loot and may be carried in hand when storage is full
			if(thing.flags_human_ai & HEALING_ITEM)
				if(medical_item_has_target(thing))
					add_to_pickup(thing)
				continue
			// SS220 EDIT - END

			var/storage_spot = storage_has_room(thing)
			if(!storage_spot || !thing.ai_can_use(tied_human, src, tied_human))
				continue

			if((thing.flags_human_ai & AMMUNITION_ITEM) && primary_weapon)
				var/obj/item/ammo_magazine/mag = thing
				if(istype(primary_weapon, mag.gun_type))
					add_to_pickup(thing)

			if(thing.flags_human_ai & GRENADE_ITEM)
				add_to_pickup(thing)

			if(thing.flags_human_ai & TOOL_ITEM)
				add_to_pickup(thing)

/datum/human_ai_brain/proc/add_to_pickup(obj/item/thing)
	RegisterSignal(thing, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	to_pickup += thing

/datum/human_ai_brain/proc/get_tool_from_equipment_map(tool_trait)
	RETURN_TYPE(/obj/item)
	for(var/obj/item/maybe_tool as anything in equipment_map[HUMAN_AI_TOOLS])
		if(!HAS_TRAIT(maybe_tool, tool_trait))
			continue
		return maybe_tool

/datum/human_ai_brain/proc/add_secondary_weapon(obj/item/weapon/gun/secondary)
	if(!secondary || (secondary in secondary_weapons))
		return

	secondary_weapons += secondary
	RegisterSignal(secondary, COMSIG_PARENT_QDELETING, PROC_REF(on_secondary_delete), TRUE)

/datum/human_ai_brain/proc/remove_secondary_weapon(obj/item/weapon/gun/secondary)
	UnregisterSignal(secondary, COMSIG_PARENT_QDELETING)
	secondary_weapons -= secondary

/datum/human_ai_brain/proc/on_secondary_delete(datum/source, force)
	SIGNAL_HANDLER

	remove_secondary_weapon(source)

/datum/human_ai_brain/proc/weapon_ammo_search(obj/item/weapon/gun/weapon)
	for(var/obj/item/ammo_magazine/mag as anything in equipment_map[HUMAN_AI_AMMUNITION])
		if(istype(weapon, mag.gun_type) && mag.ai_can_use(tied_human, src))
			return mag
