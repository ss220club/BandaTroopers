/datum/human_tied_controller/proc/halo_should_backpressure_projectile_fire(atom/target_atom, datum/ammo/ammo_datum, queued_projectiles_override = null)
	if(!can_read_puppet() || !target_atom)
		return FALSE
	return halo_should_backpressure_ai_only_projectile_fire(tied_human, target_atom, ammo_datum, queued_projectiles_override)

/datum/human_tied_controller/proc/halo_is_ai_only_human()
	return can_read_puppet() && halo_is_ai_only_human(tied_human)

/datum/human_tied_controller/proc/halo_is_covenant_firearm_user()
	return can_read_puppet() && iscovenant(tied_human)

/datum/human_tied_controller/proc/halo_toggle_weapon_cover(obj/item/weapon/gun/halo_launcher/spnkr/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	weapon.toggle_cover(tied_human)
	return TRUE

/datum/human_tied_controller/proc/halo_cock_weapon(obj/item/weapon/gun/halo_launcher/spnkr/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	weapon.cock(tied_human)
	return TRUE

/datum/human_tied_controller/proc/halo_use_sangheili_kick(atom/target)
	if(!can_directly_control() || !target)
		return FALSE
	var/datum/action/human_action/activable/covenant/sangheili_kick/kick_action = get_action(/datum/action/human_action/activable/covenant/sangheili_kick)
	if(!kick_action)
		return FALSE
	INVOKE_ASYNC(kick_action, TYPE_PROC_REF(/datum/action/human_action/activable/covenant/sangheili_kick, use_ability), target, tied_human)
	return TRUE

/datum/human_tied_controller/proc/halo_set_sword_activation_state(obj/item/weapon/covenant/energy_sword/sword, active)
	if(!can_directly_control() || !sword)
		return FALSE
	sword.set_activation_state(active, tied_human)
	return TRUE
