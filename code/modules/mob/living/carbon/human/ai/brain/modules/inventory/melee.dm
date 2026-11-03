/// Quick and dirty proc to holster a melee weapon if the AI is holding one.
/datum/human_ai_module/inventory/proc/holster_melee()
	if(!drawn_melee_weapon)
		return TRUE
	var/datum/human_tied_controller/controller = context?.controller
	if(!can_continue_inventory_work() || !controller)
		return FALSE

	if(!controller.is_item_equipped_or_held(drawn_melee_weapon))
		on_melee_dropped()
		return TRUE

	if(controller.can_insert_into_shoes(drawn_melee_weapon))
		return controller.attempt_insert_into_shoes(drawn_melee_weapon)

	controller.drop_held_item(drawn_melee_weapon)
	return FALSE

/// Melee system currently only supports bootknives.
/datum/human_ai_module/inventory/proc/unholster_melee()
	var/datum/human_tied_controller/controller = context?.controller
	if(!can_continue_inventory_work() || !controller)
		return FALSE

	if(controller.has_item_in_hands())
		return TRUE

	var/cur_hand = controller.get_active_hand()
	if(cur_hand)
		controller.drop_held_item(cur_hand)

	if(controller.get_shoes())
		var/obj/item/melee_weapon = controller.remove_item_from_shoes()
		drawn_melee_weapon = melee_weapon
		RegisterSignal(drawn_melee_weapon, COMSIG_ITEM_DROPPED, PROC_REF(on_melee_dropped))
		return melee_weapon
