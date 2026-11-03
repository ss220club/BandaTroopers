/datum/human_ai_module/inventory
	module_id = "inventory"
	required_module_types = list(/datum/human_ai_module/faction)

	/// If an AI takes out an item from their equipment_map, the place it was last stored is added to this dict
	var/list/equipped_items_original_loc = list()
	/// A list of items that the AI is trying to pick up
	var/list/obj/item/to_pickup = list()
	/// Current item selected by the item pickup action.
	var/obj/item/active_pickup_target
	/// The firearm the AI is using as its primary weapon
	var/obj/item/weapon/gun/primary_weapon
	/// Any other firearms the AI has that it considers "secondary"
	var/list/obj/item/weapon/gun/secondary_weapons = list()
	/// Ref to the latest weapon we've drawn as a melee
	var/obj/item/drawn_melee_weapon
	//var/obj/item/weapon/primary_melee
	/// Firearm profile datum
	var/datum/human_ai_firearm_profile/gun_data
	/// If TRUE, the AI won't try to pick up anything
	var/ignore_looting = FALSE
	/// If TRUE, the AI ignores darkness when it comes to determining vision
	var/has_nightvision = FALSE
	/// Optional throttle for nearby item scans. Zero means run every tick.
	var/nearby_item_search_interval = 0
	COOLDOWN_DECLARE(nearby_item_search_cooldown)
	var/nearby_item_search_dirty = FALSE

	/// list("object_type" = list(object_ref = "slot")
	var/list/equipment_map = list(
		HUMAN_AI_HEALTHITEMS = list(),
		HUMAN_AI_AMMUNITION = list(),
		HUMAN_AI_GRENADES = list(),
		HUMAN_AI_TOOLS = list(),
	)

	/// Dict of "storage type" : storage ref
	var/list/container_refs = list(
		HUMAN_AI_STORAGE_BELT = null,
		HUMAN_AI_STORAGE_BACKPACK = null,
		HUMAN_AI_STORAGE_LEFT_POCKET = null,
		HUMAN_AI_STORAGE_RIGHT_POCKET = null,
		HUMAN_AI_STORAGE_ARMOR = null,
		HUMAN_AI_STORAGE_UNIFORM = null,
	)

	/// Static list of storage slots that the AI pays attention to for inventory appraisal
	var/static/list/important_storage_slots = list(
		WEAR_BACK,
		WEAR_WAIST,
		WEAR_L_STORE,
		WEAR_R_STORE,
		WEAR_JACKET,
		WEAR_BODY,
	)

	/// Bitflag equivalent of important_storage_slots
	var/static/important_storage_slots_bitflag = SLOT_BACK | SLOT_WAIST | SLOT_STORE | SLOT_OCLOTHING | SLOT_ICLOTHING

/datum/human_ai_module/inventory/proc/reset_inventory()
	drawn_melee_weapon = null
	primary_weapon = null
	gun_data = null
	active_pickup_target = null
	clear_pickup_queue()
	invalidate_nearby_item_search()

/datum/human_ai_module/inventory/reset_module()
	reset_inventory()

/datum/human_ai_module/inventory/suspend_module(clear_inventory = FALSE)
	if(clear_inventory)
		reset_inventory()
	else
		invalidate_nearby_item_search()

/datum/human_ai_module/inventory/proc/can_continue_inventory_work()
	return brain?.can_continue_runtime_work()

/datum/human_ai_module/inventory/proc/has_valid_owner()
	return brain.has_valid_tied_human()

/datum/human_ai_module/inventory/proc/get_owner_previous_faction()
	return brain.get_previous_faction()

/datum/human_ai_module/inventory/proc/set_owner_previous_faction(new_faction)
	return brain.set_previous_faction(new_faction)

/datum/human_ai_module/inventory/proc/clear_owner_tried_reload()
	return brain.clear_tried_reload()

/datum/human_ai_module/inventory/proc/should_owner_suspend_nearby_item_search()
	return brain.should_suspend_nearby_item_search()

/datum/human_ai_module/inventory/proc/get_owner_active_grenade()
	RETURN_TYPE(/obj/item/explosive/grenade)
	return brain.get_active_grenade()

/datum/human_ai_module/inventory/proc/set_owner_active_grenade(obj/item/explosive/grenade/grenade)
	return brain.set_active_grenade(grenade)

/datum/human_ai_module/inventory/proc/clear_owner_active_grenade()
	return brain.clear_active_grenade()

/datum/human_ai_module/inventory/proc/has_owner_ongoing_action(path)
	return brain.has_ongoing_action(path)

/datum/human_ai_module/inventory/proc/can_owner_throw_back_grenade()
	return brain.can_throw_back_grenade()

/datum/human_ai_module/inventory/proc/notify_owner_inventory_runtime_changed()
	return brain.notify_inventory_runtime_changed()

/datum/human_ai_module/inventory/proc/get_owner_action_delay()
	return brain.get_action_delay()

/datum/human_ai_module/inventory/resume_module(previous_lifecycle_state)
	appraise_inventory()
	invalidate_nearby_item_search()

/datum/human_ai_module/inventory/process_module(delta_time)
	if(!can_continue_inventory_work())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(controller && !controller.is_zombie() && should_run_nearby_item_search())
		item_search(controller.get_range(2))

/datum/human_ai_module/inventory/on_ai_event(datum/human_ai_event/event)
	switch(event.event_type)
		if(HUMAN_AI_EVENT_INITIALIZED)
			on_initialized()
		if(HUMAN_AI_EVENT_TARGET_CHANGED)
			var/atom/movable/old_target = event.get_old_target()
			var/atom/movable/new_target = event.get_new_target()
			on_target_changed(old_target, new_target)
		if(HUMAN_AI_EVENT_COMBAT_EXIT_STARTED)
			on_combat_exit_started(event.should_holster_primary())
		if(HUMAN_AI_EVENT_SPECIES_CHANGED)
			on_species_changed(event.get_new_species())
		if(HUMAN_AI_EVENT_BODY_POSITION_CHANGED)
			on_body_position_changed(event.get_new_body_position(), event.get_old_body_position())

/datum/human_ai_module/inventory/on_target_changed(atom/movable/old_target, atom/movable/new_target)
	invalidate_nearby_item_search()

/datum/human_ai_module/inventory/proc/on_initialized()
	appraise_inventory()

/datum/human_ai_module/inventory/on_species_changed(new_species)
	if((new_species == SPECIES_YAUTJA) || (new_species == SPECIES_ZOMBIE))
		set_looting_disabled(TRUE)
	else
		set_looting_disabled(FALSE)

/datum/human_ai_module/inventory/on_body_position_changed(new_position, old_position)
	invalidate_nearby_item_search() // SS220 EDIT: wake-up should immediately invalidate idle pickup/grenade scan throttles

/datum/human_ai_module/inventory/on_lifecycle_suspended(new_lifecycle_state, clear_inventory = FALSE)
	..()
	if(new_lifecycle_state != HUMAN_AI_LIFECYCLE_HARDCRIT)
		return

	clear_pickup_queue()
	invalidate_nearby_item_search()

/datum/human_ai_module/inventory/on_combat_exit_started(should_holster_primary = TRUE)
	if(should_holster_primary)
		holster_primary()
	holster_melee()

/datum/human_ai_module/inventory/can_ignore_target_darkness()
	return has_nightvision

/datum/human_ai_module/inventory/proc/get_primary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	return primary_weapon

/datum/human_ai_module/inventory/proc/has_primary_weapon()
	return !!primary_weapon

/datum/human_ai_module/inventory/proc/get_gun_data()
	RETURN_TYPE(/datum/human_ai_firearm_profile)
	return gun_data

/datum/human_ai_module/inventory/proc/get_gun_handler()
	RETURN_TYPE(/datum/human_ai_firearm_handler)
	return GLOB.human_ai_firearm_registry?.get_handler(primary_weapon)

/datum/human_ai_module/inventory/proc/has_gun_data()
	return !!gun_data

/datum/human_ai_module/inventory/proc/get_available_firearm_profile(obj/item/weapon/gun/weapon)
	RETURN_TYPE(/datum/human_ai_firearm_profile)

	var/datum/human_ai_firearm_profile/firearm_profile = GLOB.human_ai_firearm_registry?.get_profile(weapon)
	if(!firearm_profile?.available_to_ai)
		return null
	return firearm_profile

/datum/human_ai_module/inventory/proc/can_select_firearm(obj/item/weapon/gun/weapon)
	return !!get_available_firearm_profile(weapon)

/datum/human_ai_module/inventory/proc/has_secondary_weapons()
	return get_secondary_weapon_count()

/datum/human_ai_module/inventory/proc/get_secondary_weapon_count()
	return length(secondary_weapons)

/datum/human_ai_module/inventory/proc/has_secondary_weapon(obj/item/weapon/gun/weapon)
	return weapon && (weapon in secondary_weapons)

/datum/human_ai_module/inventory/proc/is_looting_disabled()
	return ignore_looting

/datum/human_ai_module/inventory/proc/set_looting_disabled(disabled)
	ignore_looting = disabled

/datum/human_ai_module/inventory/proc/has_equipment(equipment_type)
	return get_equipment_count(equipment_type)

/datum/human_ai_module/inventory/proc/clear_main_hand()
	var/datum/human_tied_controller/controller = context?.controller
	if(!can_continue_inventory_work() || !controller)
		return

	var/obj/item/active_hand = controller.get_active_hand()
	if(!active_hand)
		return

	if(primary_weapon == active_hand)
		if(!holster_primary())
			controller.drop_held_item(active_hand)
		return

	var/storage_id = storage_has_room(active_hand)
	if(!storage_id)
		controller.drop_held_item(active_hand)
		return

	store_item(active_hand, storage_id)
