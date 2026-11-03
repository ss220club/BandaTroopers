// Isolated HALO extension for the Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/covenant
	gun_types = list()

/datum/human_ai_firearm_handler/covenant/get_primary_weight(datum/human_ai_firearm_context/context)
	// Requires a HALO-owned controller bridge before this subsystem is included.
	if(context?.controller?.halo_is_covenant_firearm_user())
		var/datum/human_ai_firearm_profile/profile = context.get_profile()
		return (profile?.primary_weight || 0) * 3
	return ..()

/datum/human_ai_firearm_handler/covenant/plasma
	gun_types = list(/obj/item/weapon/gun/energy/plasma)

/datum/human_ai_firearm_handler/covenant/plasma/can_queue_fire(datum/human_ai_firearm_context/context)
	if(!..())
		return FALSE
	var/obj/item/weapon/gun/energy/plasma/plasma = context.firearm
	return !plasma.dispersing

#define HUMAN_AI_PLASMA_VENT_CHANCE_DIRECT_COMBAT 6
#define HUMAN_AI_PLASMA_VENT_CHANCE_INDIRECT_COMBAT 12

/datum/human_ai_firearm_handler/covenant/plasma/proc/get_vent_chance(datum/human_ai_firearm_context/context)
	if(!context?.is_valid())
		return 0
	var/obj/item/weapon/gun/energy/plasma/plasma = context.firearm
	var/vent_decision = 0
	if(context.current_target)
		vent_decision = max(0, -20 + (HUMAN_AI_PLASMA_VENT_CHANCE_DIRECT_COMBAT * context.controller.get_distance_to(context.current_target)))
	else if(context.target_turf)
		vent_decision = max(0, -20 + (HUMAN_AI_PLASMA_VENT_CHANCE_INDIRECT_COMBAT * context.controller.get_distance_to(context.target_turf)))
	vent_decision += max(0, plasma.heat - 65)
	return max(0, vent_decision)

/datum/human_ai_firearm_handler/covenant/plasma/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	var/obj/item/weapon/gun/energy/plasma/plasma = context.firearm
	if(!. || plasma.heat < 60)
		return
	if(plasma.dispersing)
		context.AI.try_cover()
		return
	if(prob(get_vent_chance(context)))
		context.prepare_primary_weapon()
		context.unwield_weapon()
		context.swap_hand()
		context.controller.unload_weapon(plasma)
		context.swap_hand()
		context.wield_primary()

/datum/human_ai_firearm_handler/covenant/plasma/after_fire(datum/human_ai_firearm_context/context)
	if(!can_use(context))
		return null
	var/obj/item/weapon/gun/energy/plasma/plasma = context.firearm
	if(plasma.heat < 60)
		return ..()
	if(prob(get_vent_chance(context)))
		var/datum/human_ai_firearm_result/result = new()
		context.prepare_primary_weapon()
		context.controller.unload_weapon(plasma)
		return result.consume()
	if(plasma.heat >= 100)
		var/datum/human_ai_firearm_result/result = ..()
		if(!result)
			result = new()
		result.interrupt_burst = TRUE
		return result
	return ..()

#undef HUMAN_AI_PLASMA_VENT_CHANCE_DIRECT_COMBAT
#undef HUMAN_AI_PLASMA_VENT_CHANCE_INDIRECT_COMBAT

/datum/human_ai_firearm_handler/covenant/plasma/pistol
	gun_types = list(/obj/item/weapon/gun/energy/plasma/plasma_pistol)

/datum/human_ai_firearm_handler/covenant/plasma/rifle
	gun_types = list(/obj/item/weapon/gun/energy/plasma/plasma_rifle)

/datum/human_ai_firearm_handler/covenant/needler
	gun_types = list(/obj/item/weapon/gun/smg/covenant_needler)

/datum/human_ai_firearm_handler/halo_carbine
	gun_types = list(/obj/item/weapon/gun/rifle/covenant_carbine)

/datum/human_ai_firearm_handler/halo_carbine/get_primary_weight(datum/human_ai_firearm_context/context)
	// Requires a HALO-owned controller bridge before this subsystem is included.
	if(context?.controller?.halo_is_covenant_firearm_user())
		var/datum/human_ai_firearm_profile/profile = context.get_profile()
		return (profile?.primary_weight || 0) * 3
	return ..()

/datum/human_ai_firearm_handler/halo_spnkr
	gun_types = list(/obj/item/weapon/gun/halo_launcher/spnkr)

/datum/human_ai_firearm_handler/halo_spnkr/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!.)
		return
	var/obj/item/weapon/gun/halo_launcher/spnkr/spnkr = context.firearm
	// Requires a HALO-owned controller bridge before this subsystem is included.
	if(spnkr.cover_open)
		context.controller.halo_toggle_weapon_cover(spnkr)
	// Requires a HALO-owned controller bridge before this subsystem is included.
	if(!spnkr.in_chamber && spnkr.current_mag?.current_rounds > 0)
		context.controller.halo_cock_weapon(spnkr)

/datum/human_ai_firearm_handler/halo_spnkr/do_reload(datum/human_ai_firearm_context/context)
	if(!can_use(context) || !context.mag)
		return FALSE
	var/obj/item/weapon/gun/halo_launcher/spnkr/spnkr = context.firearm
	context.prepare_primary_weapon()
	context.unwield_weapon()
	// Requires a HALO-owned controller bridge before this subsystem is included.
	if(!spnkr.cover_open)
		context.controller.halo_toggle_weapon_cover(spnkr)
	context.sleep_short()
	if(!can_use(context) || QDELETED(context.mag))
		return FALSE
	if(spnkr.current_mag)
		context.unload_for_reload()
	context.swap_hand()
	context.sleep_micro()
	if(!can_use(context) || QDELETED(context.mag))
		return FALSE
	context.equip_reload_item(HUMAN_AI_AMMUNITION)
	context.sleep_short()
	if(!can_use(context) || QDELETED(context.mag))
		return FALSE
	context.insert_ammo()
	context.sleep_short()
	if(!can_use(context))
		return FALSE
	// Requires a HALO-owned controller bridge before this subsystem is included.
	if(spnkr.cover_open)
		context.controller.halo_toggle_weapon_cover(spnkr)
	context.sleep_micro()
	if(!context.is_valid())
		return FALSE
	context.swap_hand()
	return context.wield_primary_sleep()
