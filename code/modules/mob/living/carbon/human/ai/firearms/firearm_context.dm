// Isolated Human AI firearm context proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_context
	var/datum/human_ai_brain/AI
	var/datum/human_ai_context/ai_context
	var/datum/human_tied_controller/controller
	var/obj/item/weapon/gun/firearm
	var/obj/item/ammo_magazine/mag
	var/obj/item/reload_item
	var/atom/movable/current_target
	var/turf/target_turf

/datum/human_ai_firearm_context/New(obj/item/weapon/gun/new_firearm, datum/human_ai_brain/new_ai, atom/movable/new_current_target = null, turf/new_target_turf = null, obj/item/ammo_magazine/new_mag = null, obj/item/new_reload_item = null)
	firearm = new_firearm
	AI = new_ai
	ai_context = AI?.create_context()
	controller = ai_context?.controller
	current_target = new_current_target
	target_turf = new_target_turf
	mag = new_mag
	reload_item = new_reload_item || new_mag

/datum/human_ai_firearm_context/Destroy(force, ...)
	QDEL_NULL(ai_context)
	AI = null
	controller = null
	firearm = null
	mag = null
	reload_item = null
	current_target = null
	target_turf = null
	return ..()

/datum/human_ai_firearm_context/proc/is_valid()
	return firearm && AI?.can_continue_runtime_work() && controller

/datum/human_ai_firearm_context/proc/can_use()
	if(!is_valid())
		return FALSE
	return controller.can_ai_use_weapon(firearm)

/datum/human_ai_firearm_context/proc/get_profile()
	RETURN_TYPE(/datum/human_ai_firearm_profile)
	return GLOB.human_ai_firearm_registry?.get_profile(firearm)

/datum/human_ai_firearm_context/proc/get_handler()
	RETURN_TYPE(/datum/human_ai_firearm_handler)
	return GLOB.human_ai_firearm_registry?.get_handler(firearm)

/datum/human_ai_firearm_context/proc/set_reload_item(obj/item/new_reload_item)
	reload_item = new_reload_item
	if(istype(new_reload_item, /obj/item/ammo_magazine))
		mag = new_reload_item
	else
		mag = null
	return reload_item

/datum/human_ai_firearm_context/proc/can_continue_reload(obj/item/item = reload_item)
	if(!can_use())
		return FALSE
	if(item && QDELETED(item))
		return FALSE
	if(mag && QDELETED(mag))
		return FALSE
	return TRUE

/datum/human_ai_firearm_context/proc/prepare_primary_weapon()
	if(!is_valid())
		return FALSE
	if(!AI.unholster_primary())
		return FALSE
	return AI.ensure_primary_hand(firearm)

/datum/human_ai_firearm_context/proc/wield_primary()
	if(!is_valid())
		return FALSE
	return AI.wield_primary()

/datum/human_ai_firearm_context/proc/wield_primary_sleep()
	if(!is_valid())
		return FALSE
	return AI.wield_primary_sleep()

/datum/human_ai_firearm_context/proc/unwield_weapon()
	if(!is_valid())
		return FALSE
	return controller.unwield_weapon(firearm)

/datum/human_ai_firearm_context/proc/swap_hand()
	if(!is_valid())
		return FALSE
	return controller.swap_hand()

/datum/human_ai_firearm_context/proc/sleep_short()
	sleep(AI.get_action_delay())
	return can_use()

/datum/human_ai_firearm_context/proc/sleep_micro()
	sleep(AI.get_micro_action_delay())
	return can_use()

/datum/human_ai_firearm_context/proc/ensure_safety_off()
	if(!is_valid() || !(firearm.flags_gun_features & GUN_TRIGGER_SAFETY))
		return TRUE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.ensure_weapon_safety_off(firearm)

/datum/human_ai_firearm_context/proc/unload_for_reload()
	if(!is_valid())
		return FALSE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.unload_weapon_for_reload(firearm)

/datum/human_ai_firearm_context/proc/insert_ammo(obj/item/ammo_magazine/ammo = mag)
	if(!is_valid() || !ammo)
		return FALSE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.attackby_with_item(firearm, ammo)

/datum/human_ai_firearm_context/proc/equip_reload_item(equipment_type = HUMAN_AI_AMMUNITION)
	if(!is_valid() || !reload_item)
		return FALSE
	return AI.equip_item_from_equipment_map(equipment_type, reload_item)

/datum/human_ai_firearm_context/proc/iter_equipment_type(equipment_type)
	if(!is_valid())
		return list()
	return AI.iter_equipment_type(equipment_type)

/datum/human_ai_firearm_context/proc/has_equipment_item(obj/item/item, equipment_type)
	if(!is_valid())
		return FALSE
	return AI.has_equipment_item(item, equipment_type)

/datum/human_ai_firearm_context/proc/can_item_supply_ammo_for_weapon(obj/item/item)
	if(!is_valid())
		return FALSE
	return AI.can_item_supply_ammo_for_weapon(item, firearm)

/datum/human_ai_firearm_context/proc/can_item_supply_grenade(obj/item/item, obj/item/weapon/gun/launcher/grenade/grenade_launcher)
	if(!is_valid())
		return FALSE
	return AI.can_item_supply_grenade(item, grenade_launcher)

/datum/human_ai_firearm_context/proc/storage_has_room(obj/item/item)
	if(!is_valid() || !item)
		return null
	return AI.storage_has_room(item)

/datum/human_ai_firearm_context/proc/store_ammo_item(obj/item/item, storage_slot = null)
	if(!is_valid() || !item)
		return FALSE
	if(!storage_slot)
		storage_slot = storage_has_room(item)
	if(!storage_slot)
		return FALSE
	return AI.store_item(item, storage_slot, HUMAN_AI_AMMUNITION)

/datum/human_ai_firearm_context/proc/insert_reload_item(obj/item/item = reload_item)
	if(!is_valid() || !item)
		return FALSE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.attackby_with_item(firearm, item)

/datum/human_ai_firearm_context/proc/use_unique_action()
	if(!is_valid())
		return FALSE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.use_weapon_unique_action(firearm)

/datum/human_ai_firearm_context/proc/start_unique_action(delay = 0)
	if(!is_valid())
		return FALSE
	return controller.start_weapon_unique_action(firearm, delay)

/datum/human_ai_firearm_context/proc/start_fire(delay = 0)
	if(!is_valid())
		return FALSE
	return controller.start_weapon_fire(firearm, delay)

/datum/human_ai_firearm_context/proc/fire_at_target()
	if(!is_valid() || !target_turf)
		return FALSE
	return controller.fire_weapon_at(firearm, target_turf)

/datum/human_ai_firearm_context/proc/fire_grenade_launcher_at_target()
	if(!is_valid() || !target_turf || !istype(firearm, /obj/item/weapon/gun/launcher/grenade))
		return FALSE
	var/obj/item/weapon/gun/launcher/grenade/grenade_launcher = firearm
	return controller.fire_grenade_launcher_at(grenade_launcher, target_turf)

/datum/human_ai_firearm_context/proc/alt_click_item()
	if(!is_valid())
		return FALSE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.alt_click_item(firearm)

/datum/human_ai_firearm_context/proc/open_weapon_chamber()
	if(!is_valid())
		return FALSE
	// Requires the controller API listed in controller_contract.dm before this subsystem is included.
	return controller.open_weapon_chamber(firearm)

/datum/human_ai_firearm_context/proc/get_followup_fire_callback()
	if(!is_valid())
		return null
	return controller.get_ai_followup_fire_callback(firearm, current_target)

/datum/human_ai_firearm_context/proc/get_followup_fire_delay()
	if(!is_valid())
		return 0
	return controller.get_ai_followup_fire_delay(firearm, current_target)

/datum/human_ai_firearm_context/proc/get_followup_fire_cooldown()
	if(!is_valid())
		return 0
	return controller.get_ai_followup_fire_cooldown(firearm, current_target)
