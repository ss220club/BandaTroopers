/// Used to determine what the AI has in their inventory
/datum/human_ai_module/inventory/proc/appraise_inventory(belt = TRUE, back = TRUE, pocket_l = TRUE, pocket_r = TRUE, armor = TRUE, uniform = TRUE)
	recalculate_containers()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(get_owner_previous_faction() != controller.get_faction())
		set_owner_previous_faction(controller.get_faction())
		var/datum/human_ai_faction/our_faction = SShuman_ai.human_ai_factions[controller.get_faction()]
		our_faction?.apply_faction_data(brain)

	/*if(puppet.shoes && !primary_melee) // snowflake bootknife check
		var/obj/item/weapon/knife = locate() in puppet.shoes
		if(knife)
			set_primary_melee(knife)*/

	// snowflake secondary weapon in suit storage check
	if(isgun(controller.get_s_store()) && (controller.get_s_store() != primary_weapon))
		add_secondary_weapon(controller.get_s_store())

	clear_owner_tried_reload() // We don't really need to do this in a smart way
	if(belt)
		appraise_belt()

	if(back)
		appraise_back()

	if(pocket_l)
		appraise_left_pocket()

	if(pocket_r)
		appraise_right_pocket()

	if(armor)
		appraise_armor()

	if(uniform && isclothing(controller.get_w_uniform()))
		appraise_uniform()

/datum/human_ai_module/inventory/proc/appraise_belt()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(isgun(controller.get_belt()) && (controller.get_belt() != primary_weapon))
		add_secondary_weapon(controller.get_belt())
		return

	if(!istype(controller.get_belt(), /obj/item/storage)) // belts can be backpacks, don't ask
		return

	appraise_storage_contents(controller.get_belt(), controller.get_belt(), HUMAN_AI_STORAGE_BELT)

/datum/human_ai_module/inventory/proc/appraise_back()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(isgun(controller.get_back()) && (controller.get_back() != primary_weapon))
		add_secondary_weapon(controller.get_back())
		return

	// SS220 EDIT - START: some back-slot transport rigs are storage without inheriting backpack.
	// AI still needs to appraise their contents.
	if(!istype(controller.get_back(), /obj/item/storage))
		return
	// SS220 EDIT - END

	appraise_storage_contents(controller.get_back(), controller.get_back(), HUMAN_AI_STORAGE_BACKPACK)

/datum/human_ai_module/inventory/proc/appraise_left_pocket()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(!istype(controller.get_l_store(), /obj/item/storage/pouch))
		return

	appraise_storage_contents(controller.get_l_store(), controller.get_l_store(), HUMAN_AI_STORAGE_LEFT_POCKET)

/datum/human_ai_module/inventory/proc/appraise_right_pocket()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(!istype(controller.get_r_store(), /obj/item/storage/pouch))
		return

	appraise_storage_contents(controller.get_r_store(), controller.get_r_store(), HUMAN_AI_STORAGE_RIGHT_POCKET)

/datum/human_ai_module/inventory/proc/appraise_armor()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(!istype(controller.get_wear_suit(), /obj/item/clothing/suit))
		return

	if(istype(controller.get_wear_suit(), /obj/item/clothing/suit) && controller.get_loc()) // being in nullspace makes lights play weirdly
		var/obj/item/clothing/suit/worn_armor = controller.get_wear_suit()
		if(!worn_armor.has_light)
			return
		else if(!worn_armor.light_on)
			controller.turn_suit_light(worn_armor, TRUE)

	var/obj/item/clothing/suit/storage/storage_suit = controller.get_wear_suit()
	clear_equipment_refs_for_slot(HUMAN_AI_STORAGE_ARMOR)
	RegisterSignal(storage_suit, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	for(var/obj/item/clothing/accessory/storage/armour_webbing in storage_suit.accessories)
		item_slot_appraisal_loop(armour_webbing, HUMAN_AI_STORAGE_ARMOR)
		return
	if(storage_suit.get_pockets())
		item_slot_appraisal_loop(storage_suit.pockets, HUMAN_AI_STORAGE_ARMOR)

/datum/human_ai_module/inventory/proc/appraise_uniform()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	var/obj/item/clothing/accessory/storage/located_storage = locate(/obj/item/clothing/accessory/storage) in controller.get_w_uniform().accessories
	if(!located_storage)
		return

	appraise_storage_contents(located_storage, located_storage.hold, HUMAN_AI_STORAGE_UNIFORM)

/datum/human_ai_module/inventory/proc/appraise_storage_contents(obj/item/signal_source, obj/item/container_to_loop, slot_to_assign)
	clear_equipment_refs_for_slot(slot_to_assign)
	RegisterSignal(signal_source, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(container_to_loop, slot_to_assign)

/datum/human_ai_module/inventory/proc/item_slot_appraisal_loop(obj/item/container_to_loop, slot_to_assign)
	for(var/obj/item/inv_item as anything in container_to_loop)
		RegisterSignal(inv_item, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
		if(!add_item_to_equipment_maps(inv_item, slot_to_assign) && isgun(inv_item) && !has_secondary_weapon(inv_item))
			add_secondary_weapon(inv_item)

		var/obj/item/storage/nested_storage = inv_item
		if(istype(nested_storage) && should_appraise_nested_storage(nested_storage))
			item_slot_appraisal_loop(nested_storage, nested_storage)

		//else if((inv_item.flags_human_ai & MELEE_WEAPON_ITEM) && !primary_melee)
		//	set_primary_melee(inv_item)

/datum/human_ai_module/inventory/proc/add_item_to_equipment_maps(obj/item/inv_item, slot_to_assign)
	return set_equipment_locations_by_flags(inv_item, slot_to_assign)

/datum/human_ai_module/inventory/proc/should_appraise_nested_storage(obj/item/storage/storage_item)
	if(!storage_item)
		return FALSE

	return istype(storage_item, /obj/item/storage/firstaid) || istype(storage_item, /obj/item/storage/pouch/medkit) || istype(storage_item, /obj/item/storage/pouch/medical) || istype(storage_item, /obj/item/storage/pouch/firstaid)

/datum/human_ai_module/inventory/proc/appraise_primary()
	gun_data = null
	if(!primary_weapon)
		return
	gun_data = get_available_firearm_profile(primary_weapon)
