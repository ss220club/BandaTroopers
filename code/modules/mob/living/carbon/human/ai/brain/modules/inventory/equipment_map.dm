/datum/human_ai_module/inventory/proc/get_equipment_types_for_item(obj/item/item)
	var/list/equipment_types = list()
	if(!item)
		return equipment_types

	if(item.flags_human_ai & HEALING_ITEM)
		equipment_types += HUMAN_AI_HEALTHITEMS
	if(item.flags_human_ai & AMMUNITION_ITEM)
		equipment_types += HUMAN_AI_AMMUNITION
	if(item.flags_human_ai & GRENADE_ITEM)
		equipment_types += HUMAN_AI_GRENADES
	if(item.flags_human_ai & TOOL_ITEM)
		equipment_types += HUMAN_AI_TOOLS

	return equipment_types

/datum/human_ai_module/inventory/proc/set_equipment_location(obj/item/item, storage_loc, equipment_type)
	if(!item || !equipment_type || !(equipment_type in equipment_map))
		return FALSE

	equipment_map[equipment_type][item] = storage_loc
	return TRUE

/datum/human_ai_module/inventory/proc/get_equipment_location(obj/item/item, equipment_type)
	if(!has_equipment_item(item, equipment_type))
		return null

	return equipment_map[equipment_type][item]

/datum/human_ai_module/inventory/proc/has_equipment_item(obj/item/item, equipment_type)
	return item && equipment_type && (equipment_type in equipment_map) && (item in equipment_map[equipment_type])

/datum/human_ai_module/inventory/proc/get_equipment_count(equipment_type)
	if(!equipment_type || !(equipment_type in equipment_map))
		return 0

	return length(equipment_map[equipment_type])

/datum/human_ai_module/inventory/proc/get_first_equipment_item(equipment_type, obj/item/excluding = null)
	RETURN_TYPE(/obj/item)

	if(!equipment_type || !(equipment_type in equipment_map))
		return null

	for(var/obj/item/item as anything in equipment_map[equipment_type])
		if(item == excluding)
			continue
		return item

	return null

/datum/human_ai_module/inventory/proc/iter_equipment_type(equipment_type)
	RETURN_TYPE(/list)

	if(!equipment_type || !(equipment_type in equipment_map))
		return list()

	var/list/equipment_bucket = equipment_map[equipment_type]
	return equipment_bucket.Copy()

/datum/human_ai_module/inventory/proc/find_equipment_by_path(object_path, equipment_type)
	RETURN_TYPE(/obj/item)

	if(!equipment_type || !(equipment_type in equipment_map))
		return null

	return locate(object_path) in equipment_map[equipment_type]

/datum/human_ai_module/inventory/proc/find_equipment_by_trait(tool_trait, equipment_type)
	RETURN_TYPE(/obj/item)

	if(!tool_trait || !equipment_type || !(equipment_type in equipment_map))
		return null

	for(var/obj/item/item as anything in equipment_map[equipment_type])
		if(HAS_TRAIT(item, tool_trait))
			return item

	return null

/datum/human_ai_module/inventory/proc/find_usable_equipment_by_type_list(list/item_types, equipment_type, atom/use_target)
	RETURN_TYPE(/obj/item)

	if(!length(item_types) || !equipment_type || !(equipment_type in equipment_map))
		return null
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return null

	for(var/obj/item/item as anything in equipment_map[equipment_type])
		if(is_type_in_list(item, item_types) && controller.can_use_item(item, use_target))
			return item

	return null

/datum/human_ai_module/inventory/proc/can_item_supply_ammo_for_weapon(obj/item/item, obj/item/weapon/gun/weapon)
	var/datum/human_tied_controller/controller = context?.controller
	if(!item || !weapon || !controller?.can_use_item(item))
		return FALSE

	var/obj/item/ammo_magazine/magazine = item
	if(istype(magazine))
		return can_magazine_supply_ammo_for_weapon(magazine, weapon)

	var/obj/item/ammo_box/magazine/ammo_box = item
	if(!istype(ammo_box) || !ammo_box.is_loaded())
		return FALSE

	if(ammo_box.handfuls)
		var/obj/item/ammo_magazine/source = locate(/obj/item/ammo_magazine) in ammo_box.contents
		return can_magazine_supply_ammo_for_weapon(source, weapon)

	for(var/obj/item/ammo_magazine/boxed_magazine as anything in ammo_box.contents)
		if(can_magazine_supply_ammo_for_weapon(boxed_magazine, weapon))
			return TRUE

	return FALSE

/datum/human_ai_module/inventory/proc/can_magazine_supply_ammo_for_weapon(obj/item/ammo_magazine/magazine, obj/item/weapon/gun/weapon)
	if(!magazine || !weapon || magazine.current_rounds <= 0)
		return FALSE

	var/obj/item/ammo_magazine/handful/handful = magazine
	if(istype(handful))
		return can_handful_supply_ammo_for_weapon(handful, weapon)

	return istype(weapon, magazine.gun_type)

/datum/human_ai_module/inventory/proc/can_handful_supply_ammo_for_weapon(obj/item/ammo_magazine/handful/handful, obj/item/weapon/gun/weapon)
	if(!handful || !weapon || handful.current_rounds <= 0)
		return FALSE

	var/obj/item/ammo_magazine/current_mag = weapon.current_mag
	if(current_mag)
		if(!current_mag.current_rounds && current_mag.caliber == handful.caliber)
			return TRUE
		if(current_mag.default_ammo == handful.default_ammo)
			return TRUE

	return istype(weapon, handful.gun_type)

/datum/human_ai_module/inventory/proc/find_ammo_for_weapon(obj/item/weapon/gun/weapon)
	RETURN_TYPE(/obj/item)

	if(!weapon)
		return null

	for(var/obj/item/item as anything in equipment_map[HUMAN_AI_AMMUNITION])
		if(can_item_supply_ammo_for_weapon(item, weapon))
			return item

	return null

/datum/human_ai_module/inventory/proc/can_item_supply_grenade(obj/item/item, obj/item/weapon/gun/launcher/grenade/grenade_launcher)
	var/datum/human_tied_controller/controller = context?.controller
	if(!item || !controller?.can_use_item(item))
		return FALSE

	var/obj/item/explosive/grenade/grenade = item
	if(istype(grenade))
		return !grenade.active && (!grenade_launcher || grenade_launcher.allowed_ammo_type(grenade))

	var/obj/item/ammo_box/magazine/nade_box/grenade_box = item
	if(!istype(grenade_box) || !grenade_box.is_loaded())
		return FALSE

	for(var/obj/item/explosive/grenade/boxed_grenade as anything in grenade_box.contents)
		if(boxed_grenade.w_class == SIZE_HUGE)
			continue
		if(!grenade_launcher || grenade_launcher.allowed_ammo_type(boxed_grenade))
			return TRUE

	return FALSE

/datum/human_ai_module/inventory/proc/find_grenade_for_throw()
	RETURN_TYPE(/obj/item)

	for(var/obj/item/item as anything in equipment_map[HUMAN_AI_GRENADES])
		if(can_item_supply_grenade(item))
			return item

	return null

/datum/human_ai_module/inventory/proc/find_grenade_for_launcher(obj/item/weapon/gun/launcher/grenade/grenade_launcher)
	RETURN_TYPE(/obj/item)

	if(!grenade_launcher)
		return null

	for(var/obj/item/item as anything in equipment_map[HUMAN_AI_GRENADES])
		if(can_item_supply_grenade(item, grenade_launcher))
			return item

	return null

/datum/human_ai_module/inventory/proc/get_equipment_summary(equipment_type)
	if(!equipment_type || !(equipment_type in equipment_map))
		return ""

	return english_list(equipment_map[equipment_type])

/datum/human_ai_module/inventory/proc/set_equipment_locations(obj/item/item, storage_loc, list/equipment_types)
	if(!item || !length(equipment_types))
		return FALSE

	var/any_set = FALSE
	for(var/equipment_type as anything in equipment_types)
		if(set_equipment_location(item, storage_loc, equipment_type))
			any_set = TRUE

	return any_set

/datum/human_ai_module/inventory/proc/set_equipment_locations_by_flags(obj/item/item, storage_loc)
	return set_equipment_locations(item, storage_loc, get_equipment_types_for_item(item))

/datum/human_ai_module/inventory/proc/remove_from_equipment_map(obj/item/item, equipment_type)
	if(!has_equipment_item(item, equipment_type))
		return FALSE

	equipment_map[equipment_type] -= item
	return TRUE

/datum/human_ai_module/inventory/proc/remove_from_equipment_maps(obj/item/item)
	if(!item)
		return FALSE

	var/removed = FALSE
	for(var/equipment_type in equipment_map)
		if(remove_from_equipment_map(item, equipment_type))
			removed = TRUE

	return removed

/datum/human_ai_module/inventory/proc/clear_equipment_refs_for_slot(slot_to_clear)
	for(var/equipment_type in equipment_map)
		for(var/obj/item/item as anything in equipment_map[equipment_type])
			if(equipment_map[equipment_type][item] != slot_to_clear)
				continue

			equipment_map[equipment_type] -= item
