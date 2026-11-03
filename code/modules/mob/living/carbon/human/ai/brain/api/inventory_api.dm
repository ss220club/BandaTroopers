// Human AI inventory-facing API.
// These wrappers keep actions independent from the inventory module's internal layout.

// ==================== Setup ====================
// Setup/appraisal hooks used by config, spawners, and admin tooling.
/datum/human_ai_brain/proc/register_inventory_signals()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.register_signals()

/datum/human_ai_brain/proc/appraise_inventory(belt = TRUE, back = TRUE, pocket_l = TRUE, pocket_r = TRUE, armor = TRUE, uniform = TRUE)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.appraise_inventory(belt, back, pocket_l, pocket_r, armor, uniform)

// ==================== Weapon State ====================
// Primary/secondary firearm state and firearm profile access.
/datum/human_ai_brain/proc/get_primary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_primary_weapon()

/datum/human_ai_brain/proc/has_primary_weapon()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_primary_weapon()

/datum/human_ai_brain/proc/set_primary_weapon(obj/item/weapon/gun/new_gun)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.set_primary_weapon(new_gun)

/datum/human_ai_brain/proc/get_gun_data()
	RETURN_TYPE(/datum/human_ai_firearm_profile)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_gun_data()

/datum/human_ai_brain/proc/has_gun_data()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_gun_data()

/datum/human_ai_brain/proc/has_secondary_weapons()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_secondary_weapons()

/datum/human_ai_brain/proc/get_next_secondary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_next_secondary_weapon()

/datum/human_ai_brain/proc/add_secondary_weapon(obj/item/weapon/gun/secondary)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.add_secondary_weapon(secondary)

/datum/human_ai_brain/proc/select_primary_weapon(datum/human_tied_controller/controller)
	RETURN_TYPE(/obj/item/weapon/gun)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.select_primary_weapon(controller)

// ==================== Weapon Handling ====================
// Hand preparation and simple weapon draw/holster helpers.
/datum/human_ai_brain/proc/unholster_primary()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.unholster_primary()

/datum/human_ai_brain/proc/holster_primary()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.holster_primary()

/datum/human_ai_brain/proc/wield_primary()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.wield_primary()

/datum/human_ai_brain/proc/wield_primary_sleep()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.wield_primary_sleep()

/datum/human_ai_brain/proc/ensure_primary_hand(obj/item/held_item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.ensure_primary_hand(held_item)

/datum/human_ai_brain/proc/clear_main_hand()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.clear_main_hand()

/datum/human_ai_brain/proc/unholster_any_weapon()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.unholster_any_weapon()

// ==================== Pickup Queue ====================
// Pickup queue state and item classification for pickup actions.
/datum/human_ai_brain/proc/is_looting_disabled()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.is_looting_disabled()

/datum/human_ai_brain/proc/set_looting_disabled(disabled)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.set_looting_disabled(disabled)

/datum/human_ai_brain/proc/has_pickup_queue()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_pickup_queue()

/datum/human_ai_brain/proc/get_next_pickup()
	RETURN_TYPE(/obj/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_next_pickup()

/datum/human_ai_brain/proc/unqueue_pickup(obj/item/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.unqueue_pickup(item)

/datum/human_ai_brain/proc/get_pickup_storage_equipment_types(obj/item/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_pickup_storage_equipment_types(item) || list()

/datum/human_ai_brain/proc/get_item_pickup_weight(datum/human_tied_controller/controller)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_item_pickup_weight(controller) || 0

/datum/human_ai_brain/proc/start_item_pickup_action()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.start_item_pickup_action()

/datum/human_ai_brain/proc/stop_item_pickup_action()
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	inventory_module?.stop_item_pickup_action()

/datum/human_ai_brain/proc/perform_item_pickup(datum/human_tied_controller/controller)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	if(!inventory_module)
		return ONGOING_ACTION_COMPLETED
	return inventory_module.perform_item_pickup(controller)

// ==================== Equipment Access ====================
// Public lookup/equip/store helpers for item categories.
/datum/human_ai_brain/proc/has_equipment(equipment_type)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_equipment(equipment_type)

/datum/human_ai_brain/proc/get_equipment_summary(equipment_type)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.get_equipment_summary(equipment_type)

/datum/human_ai_brain/proc/find_equipment_by_trait(tool_trait, equipment_type)
	RETURN_TYPE(/obj/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.find_equipment_by_trait(tool_trait, equipment_type)

/datum/human_ai_brain/proc/find_usable_equipment_by_type_list(list/item_types, equipment_type, atom/use_target)
	RETURN_TYPE(/obj/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.find_usable_equipment_by_type_list(item_types, equipment_type, use_target)

/datum/human_ai_brain/proc/iter_equipment_type(equipment_type)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.iter_equipment_type(equipment_type) || list()

/datum/human_ai_brain/proc/has_equipment_item(obj/item/item, equipment_type)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_equipment_item(item, equipment_type)

/datum/human_ai_brain/proc/equip_item_from_equipment_map(equipment_type, obj/item/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.equip_item_from_equipment_map(equipment_type, item)

/datum/human_ai_brain/proc/can_item_supply_ammo_for_weapon(obj/item/item, obj/item/weapon/gun/weapon)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.can_item_supply_ammo_for_weapon(item, weapon)

/datum/human_ai_brain/proc/can_item_supply_grenade(obj/item/item, obj/item/weapon/gun/launcher/grenade/grenade_launcher = null)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.can_item_supply_grenade(item, grenade_launcher)

/datum/human_ai_brain/proc/find_grenade_for_throw()
	RETURN_TYPE(/obj/item/explosive/grenade)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.find_grenade_for_throw()

// ==================== Storage ====================
// Storage capacity checks and item insertion helpers.
/datum/human_ai_brain/proc/has_container_ref(container_id)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.has_container_ref(container_id)

/datum/human_ai_brain/proc/storage_has_room(obj/item/item)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.storage_has_room(item)

/datum/human_ai_brain/proc/store_item(obj/item/item, storage_loc, equipment_type = null)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.store_item(item, storage_loc, equipment_type)

/datum/human_ai_brain/proc/store_item_as_types(obj/item/item, storage_loc, list/equipment_types)
	var/datum/human_ai_module/inventory/inventory_module = get_inventory_module()
	return inventory_module?.store_item_as_types(item, storage_loc, equipment_types)
