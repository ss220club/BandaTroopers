/datum/human_ai_brain
	/// The firearm the AI is using as its primary weapon
	var/obj/item/weapon/gun/primary_weapon
	/// Any other firearms the AI has that it considers "secondary"
	var/list/obj/item/weapon/gun/secondary_weapons = list()
	//var/obj/item/weapon/primary_melee
	/// Appraisal datum
	var/datum/firearm_appraisal/gun_data
	/// If we've tried to reload (and failed) with our current inventory
	var/tried_reload = FALSE
	/// Cooldown for if we've fired too many rounds in a burst (for recoil)
	COOLDOWN_DECLARE(fire_overload_cooldown)
	/// Generic cooldown for things like shotgun pumping, bolt racking, etc. This stops us from firing for however long specified
	COOLDOWN_DECLARE(stop_fire_cooldown)

/datum/human_ai_brain/proc/should_reload()
	if(!primary_weapon)
		return FALSE
	// Proactive reload is only for detachable magazines and a better carried replacement.
	if(setting("early_reload") && !in_combat && !current_target && !has_live_grenade_emergency() && !(primary_weapon.flags_gun_features & GUN_INTERNAL_MAG))
		var/obj/item/ammo_magazine/current_mag = primary_weapon.current_mag
		if(current_mag && current_mag.current_rounds <= current_mag.max_rounds * 0.25)
			var/obj/item/ammo_magazine/replacement = weapon_ammo_search(primary_weapon)
			if(replacement && replacement != current_mag && replacement.current_rounds > current_mag.current_rounds)
				return TRUE

	// if(primary_weapon.in_chamber)
	// 	return FALSE

	// if(!primary_weapon.current_mag)
	// 	return TRUE

	// if(primary_weapon.current_mag.current_rounds > 0)
	// 	return FALSE

	// return TRUE

	return !primary_weapon.has_ammunition()	// SS220 EDIT
