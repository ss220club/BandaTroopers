// Human AI firearm reload source selection and preparation.

/datum/human_ai_firearm_handler/proc/can_reload_with(datum/human_ai_firearm_context/context, obj/item/item)
	if(!can_use(context) || !item || !context.controller.can_use_item(item))
		return FALSE
	return context.can_item_supply_ammo_for_weapon(item)

/datum/human_ai_firearm_handler/proc/find_reload_item(datum/human_ai_firearm_context/context)
	RETURN_TYPE(/obj/item)
	if(!context?.is_valid())
		return null

	for(var/equipment_type as anything in get_reload_equipment_types(context))
		for(var/obj/item/item as anything in context.iter_equipment_type(equipment_type))
			if(can_reload_with(context, item))
				return item

	return null

/datum/human_ai_firearm_handler/proc/get_reload_item_equipment_type(datum/human_ai_firearm_context/context, obj/item/item)
	if(!context?.is_valid() || !item)
		return null

	for(var/equipment_type as anything in get_reload_equipment_types(context))
		if(context.has_equipment_item(item, equipment_type))
			return equipment_type

	return null

/datum/human_ai_firearm_handler/proc/prepare_reload_item(datum/human_ai_firearm_context/context)
	if(can_use(context) && !context.reload_item)
		context.set_reload_item(find_reload_item(context))
	if(!can_use(context) || !context.reload_item)
		return FALSE

	var/obj/item/ammo_magazine/magazine = context.reload_item
	if(istype(magazine))
		if((magazine.flags_magazine & AMMUNITION_HANDFUL_BOX) && !(magazine.flags_magazine & AMMUNITION_HANDFUL))
			var/obj/item/ammo_magazine/handful/handful = context.controller.create_handful_from_ammo_source(magazine)
			if(!handful)
				return FALSE
			context.set_reload_item(handful)
			return TRUE

		var/equipment_type = get_reload_item_equipment_type(context, magazine)
		return equipment_type && context.equip_reload_item(equipment_type)

	var/obj/item/ammo_box/magazine/ammo_box = context.reload_item
	if(istype(ammo_box))
		if(ammo_box.handfuls)
			var/obj/item/ammo_magazine/handful/boxed_handful = context.controller.create_handful_from_ammo_box(ammo_box)
			if(!boxed_handful)
				return FALSE
			context.set_reload_item(boxed_handful)
			return TRUE

		var/obj/item/ammo_magazine/boxed_magazine = context.controller.take_magazine_from_ammo_box(ammo_box)
		if(!boxed_magazine)
			return FALSE
		context.set_reload_item(boxed_magazine)
		return TRUE

	return FALSE

/datum/human_ai_firearm_handler/grenade_launcher/prepare_reload_item(datum/human_ai_firearm_context/context)
	if(can_use(context) && !context.reload_item)
		context.set_reload_item(find_reload_item(context))
	if(!can_use(context) || !context.reload_item)
		return FALSE

	var/obj/item/ammo_box/magazine/nade_box/grenade_box = context.reload_item
	if(istype(grenade_box))
		var/obj/item/weapon/gun/launcher/grenade/grenade_launcher = context.firearm
		var/obj/item/explosive/grenade/boxed_grenade = context.controller.take_grenade_from_grenade_box(grenade_box, grenade_launcher)
		if(!boxed_grenade)
			return FALSE
		context.set_reload_item(boxed_grenade)
		return TRUE

	var/reload_equipment_type = get_reload_item_equipment_type(context, context.reload_item)
	return reload_equipment_type && context.equip_reload_item(reload_equipment_type)
