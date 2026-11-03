// Raw weapon callback primitives

/datum/human_tied_controller/proc/unload_weapon(obj/item/weapon/gun/gun)
	if(!can_directly_control() || !gun)
		return FALSE
	gun.unload(tied_human)
	return TRUE

/datum/human_tied_controller/proc/ensure_weapon_safety_off(obj/item/weapon/gun/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	if(!(weapon.flags_gun_features & GUN_TRIGGER_SAFETY))
		return TRUE
	if(weapon.flags_gun_features & GUN_BURST_FIRING)
		return FALSE
	weapon.flags_gun_features &= ~GUN_TRIGGER_SAFETY
	weapon.gun_safety_handle(tied_human)
	return TRUE

/datum/human_tied_controller/proc/unload_weapon_for_reload(obj/item/weapon/gun/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	weapon.unload(tied_human, FALSE, TRUE, FALSE)
	return TRUE

/datum/human_tied_controller/proc/attackby_with_item(obj/item/target, obj/item/used_item)
	if(!can_directly_control() || !target || !used_item)
		return FALSE
	target.attackby(used_item, tied_human)
	return TRUE

/datum/human_tied_controller/proc/use_weapon_unique_action(obj/item/weapon/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	weapon.unique_action(tied_human)
	return TRUE

/datum/human_tied_controller/proc/alt_click_item(obj/item/item)
	if(!can_directly_control() || !item)
		return FALSE
	item.clicked(tied_human, list(ALT_CLICK = TRUE))
	return TRUE

/datum/human_tied_controller/proc/open_weapon_chamber(obj/item/weapon/gun/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	if(istype(weapon, /obj/item/weapon/gun/launcher/grenade))
		var/obj/item/weapon/gun/launcher/grenade/grenade_launcher = weapon
		if(grenade_launcher.open_chamber)
			return TRUE
		grenade_launcher.open_chamber = TRUE
		grenade_launcher.update_icon()
		return TRUE
	return use_weapon_unique_action(weapon)

/datum/human_tied_controller/proc/start_weapon_fire(obj/item/weapon/gun/weapon, delay = 0)
	if(!can_directly_control() || !weapon)
		return FALSE
	addtimer(CALLBACK(src, PROC_REF(delayed_start_weapon_fire), weapon, get_identity_ref()), delay)
	return TRUE

/datum/human_tied_controller/proc/delayed_start_weapon_fire(obj/item/weapon/gun/weapon, datum/weakref/identity_ref)
	if(!brain?.can_continue_runtime_work() || !matches_identity_ref(identity_ref) || !weapon)
		return FALSE
	weapon.start_fire(tied_human)
	return TRUE

/datum/human_tied_controller/proc/fire_weapon_at(obj/item/weapon/gun/weapon, atom/target)
	if(!can_directly_control() || !weapon || !target)
		return FALSE
	weapon.set_target(target)
	weapon.start_fire(object = target, bypass_checks = TRUE)
	return TRUE

/datum/human_tied_controller/proc/fire_grenade_launcher_at(obj/item/weapon/gun/launcher/grenade/weapon, atom/target)
	if(!can_directly_control() || !weapon || !target)
		return FALSE
	weapon.afterattack(target, tied_human, TRUE)
	return TRUE

/datum/human_tied_controller/proc/start_weapon_unique_action(obj/item/weapon/weapon, delay = 0)
	if(!can_directly_control() || !weapon)
		return FALSE
	addtimer(CALLBACK(src, PROC_REF(delayed_weapon_unique_action), weapon, get_identity_ref()), delay)
	return TRUE

/datum/human_tied_controller/proc/delayed_weapon_unique_action(obj/item/weapon/weapon, datum/weakref/identity_ref)
	if(!brain?.can_continue_runtime_work() || !matches_identity_ref(identity_ref) || !weapon)
		return FALSE
	weapon.unique_action(tied_human)
	return TRUE

/datum/human_tied_controller/proc/get_ai_followup_fire_callback(obj/item/weapon/gun/weapon, atom/movable/current_target)
	if(!can_read_puppet() || !weapon)
		return null
	return weapon.get_ai_followup_fire_callback(tied_human, current_target)

/datum/human_tied_controller/proc/get_ai_followup_fire_delay(obj/item/weapon/gun/weapon, atom/movable/current_target)
	if(!can_read_puppet() || !weapon)
		return 0
	return weapon.get_ai_followup_fire_delay(tied_human, current_target)

/datum/human_tied_controller/proc/get_ai_followup_fire_cooldown(obj/item/weapon/gun/weapon, atom/movable/current_target)
	if(!can_read_puppet() || !weapon)
		return 0
	return weapon.get_ai_followup_fire_cooldown(tied_human, current_target)

/datum/human_tied_controller/proc/can_ai_use_weapon(obj/item/weapon/gun/weapon)
	if(!can_read_puppet() || !weapon)
		return FALSE
	return weapon.ai_can_use(tied_human, brain)
