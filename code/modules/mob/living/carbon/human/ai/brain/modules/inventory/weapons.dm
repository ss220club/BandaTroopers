/datum/human_ai_module/inventory/proc/set_primary_weapon(obj/item/weapon/gun/new_gun)
	if(primary_weapon)
		UnregisterSignal(primary_weapon, COMSIG_PARENT_QDELETING)
	if(new_gun && !can_select_firearm(new_gun))
		new_gun = null
	primary_weapon = new_gun
	appraise_primary()
	invalidate_inventory_runtime_caches()
	if(primary_weapon)
		RegisterSignal(primary_weapon, COMSIG_PARENT_QDELETING, PROC_REF(on_primary_delete), TRUE)

/datum/human_ai_module/inventory/proc/add_secondary_weapon(obj/item/weapon/gun/secondary)
	if(!secondary || has_secondary_weapon(secondary) || !can_select_firearm(secondary))
		return

	secondary_weapons += secondary
	RegisterSignal(secondary, COMSIG_PARENT_QDELETING, PROC_REF(on_secondary_delete), TRUE)

/datum/human_ai_module/inventory/proc/remove_secondary_weapon(obj/item/weapon/gun/secondary)
	UnregisterSignal(secondary, COMSIG_PARENT_QDELETING)
	secondary_weapons -= secondary

/datum/human_ai_module/inventory/proc/get_next_secondary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return null

	var/obj/item/weapon/gun/best_secondary
	var/best_secondary_weight = 0
	for(var/obj/item/weapon/gun/secondary as anything in secondary_weapons)
		if(!can_select_firearm(secondary) || !controller.can_use_item(secondary))
			continue

		var/datum/human_ai_firearm_context/context = new(secondary, brain)
		var/datum/human_ai_firearm_handler/handler = context.get_handler()
		var/secondary_weight = handler?.get_primary_weight(context) || 0
		qdel(context)
		if(!best_secondary || secondary_weight > best_secondary_weight)
			best_secondary = secondary
			best_secondary_weight = secondary_weight
			continue

	return best_secondary

/datum/human_ai_module/inventory/proc/select_primary_weapon(datum/human_tied_controller/controller)
	RETURN_TYPE(/obj/item/weapon/gun)
	if(!can_continue_inventory_work() || !controller)
		return null

	var/obj/item/weapon/gun/best_secondary = get_next_secondary_weapon()
	if(!best_secondary)
		return null

	if(primary_weapon && controller.is_holding(primary_weapon))
		var/possible_storage_loc = storage_has_room(primary_weapon)
		if((primary_weapon.flags_equip_slot & SLOT_BACK) && !controller.get_back())
			controller.equip_to_slot(primary_weapon, WEAR_BACK, TRUE)
		else if(!controller.get_s_store() && controller.get_wear_suit() && ((primary_weapon.flags_equip_slot & SLOT_SUIT_STORE) || is_type_in_list(primary_weapon, controller.get_wear_suit().allowed)))
			controller.equip_to_slot(primary_weapon, WEAR_J_STORE, TRUE)
		else if(possible_storage_loc)
			store_item(primary_weapon, possible_storage_loc)

	add_secondary_weapon(primary_weapon)
	set_primary_weapon(best_secondary)
	brain.clear_tried_reload()
	return best_secondary

/// Unholsters the AI's primary weapon, dropping anything that might obstruct it.
/datum/human_ai_module/inventory/proc/unholster_primary()
	var/datum/human_tied_controller/controller = context?.controller
	if(!primary_weapon || !can_continue_inventory_work() || !controller)
		return FALSE
	if(controller.get_l_hand() == primary_weapon || controller.get_r_hand() == primary_weapon)
		return ensure_primary_hand(primary_weapon)

	var/cur_hand = controller.get_active_hand()
	if(cur_hand)
		if(!controller.drop_held_item(cur_hand))
			return FALSE

	if(!controller.u_equip(primary_weapon))
		return FALSE
	if(!controller.put_in_active_hand(primary_weapon))
		return FALSE

	primary_weapon.guaranteed_delay_time = world.time
	primary_weapon.wield_time = world.time
	primary_weapon.pull_time = world.time
	return TRUE

/// Tells the AI to wield their primary weapon, can be called if they aren't holding it or if they are already wielding it
/datum/human_ai_module/inventory/proc/wield_primary()
	var/datum/human_tied_controller/controller = context?.controller
	if(!primary_weapon || !can_continue_inventory_work() || !controller)
		return FALSE
	if(!ensure_primary_hand(primary_weapon))
		return FALSE
	return controller.wield(primary_weapon)

/// wield_primary() with a delay inbuilt
/datum/human_ai_module/inventory/proc/wield_primary_sleep()
	// SS220 EDIT - START: propagate preparation failure and tolerate module deletion during sleep
	// wield_primary()
	if(!wield_primary())
		return FALSE
	sleep(max(primary_weapon?.wield_delay, get_owner_action_delay()))
	return !QDELETED(src) && can_continue_inventory_work()
	// SS220 EDIT - END

/// Tells the AI to unwield *something*, prioritizing melee
/datum/human_ai_module/inventory/proc/unholster_any_weapon()
	var/datum/human_tied_controller/controller = src.context?.controller
	if(!can_continue_inventory_work() || !controller)
		return FALSE

	if(controller.is_zombie())
		var/cur_hand = controller.get_active_hand()
		if(isnull(cur_hand)) //Check if we have a hand. If not try the other one? Claws are stuck to hands so if this is null we've lost the hand
			var/obj/limb/hand/r_hand/right_hand	= controller.get_limb("r_hand")
			var/obj/limb/hand/l_hand/left_hand = controller.get_limb("l_hand")
			if(!(left_hand.status & LIMB_DESTROYED) || !(right_hand.status & LIMB_DESTROYED)) //We have hands?
				controller.swap_hand()
				cur_hand = controller.get_active_hand()
			else
				return FALSE
	if(unholster_melee())
		controller.set_grab_intent()
		return TRUE
	if(primary_weapon)
		unholster_primary()
		ensure_primary_hand(primary_weapon)
		wield_primary()
		controller.set_grab_intent()
		return TRUE
	// insert any viable weapon slot macros in here

/// Holsters the AI's primary weapon if possible
/datum/human_ai_module/inventory/proc/holster_primary()
	var/datum/human_tied_controller/controller = context?.controller
	if(!primary_weapon || !can_continue_inventory_work() || !controller)
		return FALSE

	if(controller.get_s_store() || (controller.get_l_hand() != primary_weapon && controller.get_r_hand() != primary_weapon))
		return FALSE

	if(!ensure_primary_hand(primary_weapon)) // SS220 EDIT: unwield expects the fake offhand to be the inactive hand
		return FALSE
	if((primary_weapon.flags_item & TWOHANDED) && (primary_weapon.flags_item & WIELDED) && !controller.unwield_weapon(primary_weapon))
		return FALSE
	return controller.equip_to_slot_if_possible(primary_weapon, WEAR_J_STORE, TRUE)

/// Assuming an item is in the AI's hands, this ensures it is their actively selected hand
/datum/human_ai_module/inventory/proc/ensure_primary_hand(obj/item/held_item)
	var/datum/human_tied_controller/controller = context?.controller
	if(!held_item || !can_continue_inventory_work() || !controller)
		return FALSE
	if(controller.get_inactive_hand() == held_item)
		controller.swap_hand()
	return controller.get_active_hand() == held_item
