/datum/human_ai_module/halo_sangheili/proc/configure(new_has_sword = FALSE, new_sword_only = FALSE, new_sword_charge_range = 5, new_unarmed_commit_range = 2)
	runtime = TRUE
	has_sword = new_has_sword
	sword_only = new_sword_only
	sword_charge_range = new_sword_charge_range
	unarmed_commit_range = new_unarmed_commit_range
	invalidate_runtime_caches()

/datum/human_ai_module/halo_sangheili/proc/invalidate_runtime_caches()
	cached_ranged_fallback_time = -1
	cached_ranged_fallback_available = null

/datum/human_ai_module/halo_sangheili/proc/is_active()
	return runtime

/datum/human_ai_module/halo_sangheili/proc/is_sword_only()
	return sword_only

/datum/human_ai_module/halo_sangheili/proc/has_melee_commit()
	return melee_committed

/datum/human_ai_module/halo_sangheili/proc/get_drawn_sword()
	return drawn_sword

/datum/human_ai_module/halo_sangheili/proc/find_sword()
	if(QDELETED(drawn_sword))
		drawn_sword = null
		sword_storage_loc = null

	if(istype(drawn_sword))
		return drawn_sword
	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller)
		return null

	if(istype(controller.get_l_hand(), /obj/item/weapon/covenant/energy_sword))
		return controller.get_l_hand()

	if(istype(controller.get_r_hand(), /obj/item/weapon/covenant/energy_sword))
		return controller.get_r_hand()

	if(istype(controller.get_s_store(), /obj/item/weapon/covenant/energy_sword))
		return controller.get_s_store()

	if(istype(controller.get_belt(), /obj/item/storage))
		return locate(/obj/item/weapon/covenant/energy_sword) in controller.get_belt()

	if(melee_committed)
		clear_melee_commit()

/datum/human_ai_module/halo_sangheili/proc/primary_weapon_unavailable()
	if(!brain.has_valid_tied_human())
		return TRUE

	var/datum/human_ai_module/inventory/inventory = brain.halo_get_inventory()
	var/obj/item/weapon/gun/primary_weapon = inventory?.get_primary_weapon()
	if(!primary_weapon)
		return TRUE

	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller || !controller.can_ai_use_weapon(primary_weapon))
		return TRUE

	if(brain.halo_covenant_weapon_is_cooling(primary_weapon))
		return TRUE

	return brain.should_reload()

/datum/human_ai_module/halo_sangheili/proc/has_usable_ranged_fallback()
	if(!runtime)
		return FALSE

	if(cached_ranged_fallback_time == world.time)
		return cached_ranged_fallback_available

	var/datum/human_ai_module/inventory/inventory = brain.halo_get_inventory()
	var/obj/item/weapon/gun/fallback_weapon = committed_primary_weapon || inventory?.get_primary_weapon()
	if(!brain.has_valid_tied_human() || !fallback_weapon || QDELETED(fallback_weapon))
		cached_ranged_fallback_time = world.time
		cached_ranged_fallback_available = FALSE
		return FALSE

	if(!owns_item(fallback_weapon))
		cached_ranged_fallback_time = world.time
		cached_ranged_fallback_available = FALSE
		return FALSE

	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller || !controller.can_ai_use_weapon(fallback_weapon))
		cached_ranged_fallback_time = world.time
		cached_ranged_fallback_available = FALSE
		return FALSE

	if(fallback_weapon.has_ammunition())
		cached_ranged_fallback_time = world.time
		cached_ranged_fallback_available = TRUE
		return TRUE

	cached_ranged_fallback_time = world.time
	cached_ranged_fallback_available = !isnull(inventory?.find_ammo_for_weapon(fallback_weapon))
	return cached_ranged_fallback_available

/datum/human_ai_module/halo_sangheili/proc/should_preserve_drawn_sword()
	if(!find_sword())
		return FALSE

	if(sword_only)
		return TRUE

	return !has_usable_ranged_fallback()

/datum/human_ai_module/halo_sangheili/proc/should_use_sword_mode(atom/threat = null)
	if(!runtime)
		return FALSE

	if(!threat)
		threat = brain.halo_covenant_get_threat_atom()

	if(!brain.has_valid_tied_human() || !threat)
		return FALSE

	if(!has_sword && !sword_only)
		return FALSE

	if(!find_sword())
		return FALSE

	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller)
		return FALSE
	var/distance_to_threat = controller.get_distance_to(threat)
	if(distance_to_threat > sword_charge_range)
		return FALSE

	if(sword_only)
		return TRUE

	if(distance_to_threat <= unarmed_commit_range)
		return TRUE

	return primary_weapon_unavailable()

/datum/human_ai_module/halo_sangheili/proc/should_sword_charge(atom/charge_target = null)
	return should_use_sword_mode(charge_target)

/datum/human_ai_module/halo_sangheili/proc/should_overheat_response(atom/threat = null)
	if(!runtime)
		return FALSE

	if(!threat)
		threat = brain.halo_covenant_get_threat_atom()

	if(!brain.has_valid_tied_human() || !threat)
		return FALSE

	if(!brain.halo_covenant_weapon_is_cooling(brain.halo_get_inventory()?.get_primary_weapon()))
		return FALSE

	if(should_sword_charge(threat))
		return FALSE

	return TRUE

/datum/human_ai_module/halo_sangheili/proc/should_unarmed_commit(atom/threat = null)
	if(!runtime)
		return FALSE

	if(!threat)
		threat = brain.halo_covenant_get_threat_atom()

	if(!brain.has_valid_tied_human() || !threat)
		return FALSE

	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	return controller && (controller.get_distance_to(threat) <= unarmed_commit_range)

/datum/human_ai_module/halo_sangheili/proc/on_sword_dropped()
	SIGNAL_HANDLER

	if(drawn_sword)
		UnregisterSignal(drawn_sword, COMSIG_ITEM_DROPPED)

	invalidate_runtime_caches()
	drawn_sword = null
	sword_storage_loc = null
	clear_melee_commit()

/datum/human_ai_module/halo_sangheili/proc/get_commit_action_blacklist()
	var/static/list/commit_action_blacklist = list(
		/datum/ai_action/fire_at_target,
		/datum/ai_action/keep_distance,
		/datum/ai_action/reload,
		/datum/ai_action/select_primary,
		/datum/ai_action/machinegunner_nest,
		/datum/ai_action/sniper_nest,
	)
	return commit_action_blacklist

/datum/human_ai_module/halo_sangheili/proc/cancel_committed_actions()
	brain.cancel_ongoing_actions_by_type(get_commit_action_blacklist())

/datum/human_ai_module/halo_sangheili/proc/owns_item(obj/item/item)
	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	return controller?.is_item_equipped_or_in_direct_storage(item)

/datum/human_ai_module/halo_sangheili/proc/begin_melee_commit(obj/item/weapon/covenant/energy_sword/sword)
	if(melee_committed)
		return TRUE

	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!brain.has_valid_tied_human() || !sword || !controller?.is_item_equipped_or_held(sword))
		return FALSE

	melee_committed = TRUE
	var/datum/human_ai_module/inventory/inventory = brain.halo_get_inventory()
	committed_primary_weapon = inventory?.get_primary_weapon()
	committed_tried_reload = brain.has_tried_reload()
	committed_ignore_looting = inventory?.is_looting_disabled()
	brain.invalidate_halo_runtime_caches()

	if(inventory?.get_primary_weapon())
		inventory.set_primary_weapon(null)

	brain.mark_tried_reload()
	inventory?.set_looting_disabled(TRUE)

	var/list/commit_action_blacklist = get_commit_action_blacklist()
	brain.add_action_blacklist(commit_action_blacklist)

	cancel_committed_actions()
	return TRUE

/datum/human_ai_module/halo_sangheili/proc/restore_ranged_state(atom/threat = null)
	if(sword_only || !melee_committed)
		return FALSE

	if(!has_usable_ranged_fallback())
		return FALSE

	if(should_use_sword_mode(threat))
		return FALSE

	if(holster_sword())
		return TRUE

	clear_melee_commit()
	return TRUE

/datum/human_ai_module/halo_sangheili/proc/clear_melee_commit(restore_firearm = TRUE)
	if(!melee_committed && !committed_primary_weapon)
		return

	var/obj/item/weapon/gun/restored_primary_weapon = committed_primary_weapon
	var/restored_tried_reload = committed_tried_reload
	var/restored_ignore_looting = committed_ignore_looting

	melee_committed = FALSE
	committed_primary_weapon = null
	committed_tried_reload = FALSE
	committed_ignore_looting = FALSE
	brain.invalidate_halo_runtime_caches()

	brain.remove_action_blacklist(get_commit_action_blacklist())

	brain.set_tried_reload(restored_tried_reload)
	var/datum/human_ai_module/inventory/inventory = brain.halo_get_inventory()
	inventory?.set_looting_disabled(restored_ignore_looting)

	if(!restore_firearm || inventory?.get_primary_weapon() || !restored_primary_weapon || !owns_item(restored_primary_weapon))
		return

	inventory.set_primary_weapon(restored_primary_weapon)

/datum/human_ai_module/halo_sangheili/proc/should_keep_sword_drawn()
	if(should_preserve_drawn_sword())
		return TRUE

	if(!melee_committed)
		return FALSE

	return should_use_sword_mode()

/datum/human_ai_module/halo_sangheili/proc/track_drawn_sword(obj/item/weapon/covenant/energy_sword/sword, storage_loc = null)
	if(!sword)
		return null

	if(drawn_sword && drawn_sword != sword)
		UnregisterSignal(drawn_sword, COMSIG_ITEM_DROPPED)

	drawn_sword = sword
	if(storage_loc)
		sword_storage_loc = storage_loc
	RegisterSignal(sword, COMSIG_ITEM_DROPPED, PROC_REF(on_sword_dropped), override = TRUE)
	return sword

/datum/human_ai_module/halo_sangheili/proc/try_store_sword(obj/item/weapon/covenant/energy_sword/sword, storage_loc)
	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!brain.has_valid_tied_human() || !sword || !controller?.is_item_equipped_or_held(sword))
		return FALSE

	switch(storage_loc)
		if("belt")
			if(istype(controller.get_belt(), /obj/item/storage))
				var/obj/item/storage/belt_storage = controller.get_belt()
				return controller.attempt_item_insertion(belt_storage, sword)
		if("suit_slot")
			if(!controller.get_s_store())
				return controller.equip_to_slot_if_possible(sword, WEAR_J_STORE, TRUE)

	return FALSE

/datum/human_ai_module/halo_sangheili/proc/draw_sword()
	if(!brain.has_valid_tied_human())
		return null
	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller)
		return null

	var/obj/item/weapon/covenant/energy_sword/sword = find_sword()
	if(!sword)
		return null

	var/storage_loc = sword_storage_loc

	if(sword == controller.get_l_hand() || sword == controller.get_r_hand())
		if(controller.get_inactive_hand() == sword)
			controller.swap_hand()
		track_drawn_sword(sword, storage_loc)
		begin_melee_commit(sword)
		if(!sword.activated && !sword.nonfunctional)
			controller.halo_set_sword_activation_state(sword, TRUE)
		brain.halo_get_inventory()?.ensure_primary_hand(sword)
		return sword

	if(!brain.halo_covenant_clear_hands())
		return null

	if(sword == controller.get_s_store())
		storage_loc = "suit_slot"
		controller.u_equip(sword)
	else if(sword.loc == controller.get_belt())
		storage_loc = "belt"
		var/obj/item/storage/belt_storage = controller.get_belt()
		controller.remove_from_storage(belt_storage, sword)
	else if(istype(sword.loc, /obj/item/storage))
		var/obj/item/storage/storage = sword.loc
		controller.remove_from_storage(storage, sword)

	if(!controller.is_item_equipped_or_held(sword))
		return null

	if(!controller.put_in_hands(sword, FALSE))
		return null

	track_drawn_sword(sword, storage_loc)
	begin_melee_commit(sword)

	if(!sword.activated && !sword.nonfunctional)
		controller.halo_set_sword_activation_state(sword, TRUE)
	brain.halo_get_inventory()?.ensure_primary_hand(sword)
	return sword

/datum/human_ai_module/halo_sangheili/proc/holster_sword(force = FALSE)
	var/obj/item/weapon/covenant/energy_sword/sword = drawn_sword || find_sword()
	if(!brain.has_valid_tied_human() || !sword)
		on_sword_dropped()
		return TRUE

	if(!force && should_preserve_drawn_sword())
		return FALSE

	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller)
		on_sword_dropped()
		return TRUE

	if(sword.activated)
		controller.halo_set_sword_activation_state(sword, FALSE)

	if(!controller.is_item_equipped_or_held(sword))
		on_sword_dropped()
		return TRUE

	var/storage_loc = sword_storage_loc || "belt"
	var/success = try_store_sword(sword, storage_loc)
	if(!success && (storage_loc != "belt"))
		success = try_store_sword(sword, "belt")
	if(!success && (storage_loc != "suit_slot"))
		success = try_store_sword(sword, "suit_slot")

	if(success)
		on_sword_dropped()
		return TRUE

