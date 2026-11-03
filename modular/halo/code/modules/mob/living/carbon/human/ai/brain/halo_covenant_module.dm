/datum/human_ai_module/halo_covenant/reset_module()
	invalidate_runtime_caches()
	brain.halo_sangheili_clear_melee_commit(FALSE)

/datum/human_ai_module/halo_covenant/on_ai_event(datum/human_ai_event/event)
	switch(event.event_type)
		if(HUMAN_AI_EVENT_RESET_AFTER_WAKE_CLEAR)
			on_reset()
		if(HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED, HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED)
			on_combat_exit_finished(event.get_combat_exit_context())

/datum/human_ai_module/halo_covenant/on_combat_exit_finished(list/combat_exit_context)
	if(brain.halo_sangheili_should_preserve_drawn_sword())
		brain.halo_sangheili_clear_melee_commit(FALSE)
		return
	if(brain.halo_sangheili_has_melee_commit() || brain.halo_sangheili_get_drawn_sword())
		brain.halo_sangheili_holster_sword()

/datum/human_ai_module/halo_covenant/proc/get_controller()
	RETURN_TYPE(/datum/human_tied_controller)
	return context?.controller

/datum/human_ai_module/halo_covenant/proc/get_inventory()
	RETURN_TYPE(/datum/human_ai_module/inventory)
	return context?.get_module(/datum/human_ai_module/inventory)

/datum/human_ai_module/halo_covenant/proc/can_run_movement_action(block_active_grenade = FALSE)
	if(!brain.is_in_combat() || !brain.can_move_for_action())
		return FALSE
	if(block_active_grenade && brain.has_active_grenade())
		return FALSE
	return TRUE

/datum/human_ai_module/halo_covenant/proc/has_pending_cover()
	return brain.has_pending_cover()

/datum/human_ai_module/halo_covenant/proc/has_cover()
	return brain.has_cover()

/datum/human_ai_module/halo_covenant/proc/end_cover()
	brain.end_cover()

/datum/human_ai_module/halo_covenant/proc/try_cover_retreat(atom/threat)
	if(!brain.get_cover_module())
		return FALSE
	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return FALSE

	if(!brain.get_current_cover())
		brain.try_cover(controller.get_angle_from(threat), threat)

	var/turf/cover_turf = get_turf(brain.get_current_cover())
	if(!cover_turf)
		return FALSE

	if(controller.get_distance_to(cover_turf) > 0)
		if(!brain.move_to_turf(cover_turf))
			brain.end_cover()
			return FALSE

		return TRUE

	brain.enter_cover()
	controller.face_atom(threat)
	return TRUE

/datum/human_ai_module/halo_covenant/proc/step_away_from_threat(atom/threat, turf/anchor = null, anchor_weight = 0)
	var/turf/threat_turf = get_cached_threat_turf()
	if(!brain.has_valid_tied_human() || !threat_turf)
		return FALSE
	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return FALSE

	var/turf/best_destination
	var/best_score = -INFINITY

	for(var/direction in GLOB.cardinals)
		var/turf/destination = controller.get_step_in_dir(direction)
		if(!destination || destination.density)
			continue

		var/score = get_dist(destination, threat_turf) * 3
		if(anchor)
			score -= get_dist(destination, anchor) * anchor_weight

		if(score > best_score)
			best_score = score
			best_destination = destination

	if(!best_destination && anchor && (controller.get_distance_to(anchor) > 0))
		best_destination = anchor

	if(!best_destination)
		return FALSE

	if(!brain.move_to_turf(best_destination))
		return FALSE

	controller.face_atom(threat)
	return TRUE

/datum/human_ai_module/halo_covenant/proc/move_to_threat(atom/threat)
	var/turf/threat_turf = get_cached_threat_turf()
	if(!threat_turf)
		return FALSE

	if(!brain.move_to_turf(threat_turf))
		return FALSE

	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return FALSE
	controller.face_atom(threat)
	return TRUE

/datum/human_ai_module/halo_covenant/proc/move_to_atom(atom/target, use_cached_threat_turf = FALSE)
	if(!brain.has_valid_tied_human() || !target)
		return FALSE

	var/turf/target_turf = use_cached_threat_turf ? get_cached_threat_turf() : get_turf(target)
	if(!target_turf)
		return FALSE

	if(!brain.move_to_turf(target_turf))
		return FALSE

	if(!brain.has_valid_tied_human())
		return FALSE

	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return FALSE
	controller.face_atom(target)
	return TRUE

/datum/human_ai_module/halo_covenant/proc/has_grenade_equipment()
	return get_inventory()?.has_equipment(HUMAN_AI_GRENADES)

/datum/human_ai_module/halo_covenant/proc/get_stored_grenade(obj/item/explosive/grenade/excluding = null)
	return get_inventory()?.get_first_equipment_item(HUMAN_AI_GRENADES, excluding)

/datum/human_ai_module/halo_covenant/proc/clear_both_hands()
	if(!brain.has_valid_tied_human())
		return

	var/datum/human_ai_module/inventory/inventory = get_inventory()
	inventory?.clear_main_hand()
	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return
	controller.swap_hand()
	inventory?.clear_main_hand()
	controller.swap_hand()

/datum/human_ai_module/halo_covenant/proc/equip_grenade(obj/item/explosive/grenade/grenade_item)
	return get_inventory()?.equip_item_from_equipment_map(HUMAN_AI_GRENADES, grenade_item)

/datum/human_ai_module/halo_covenant/proc/get_threat_atom()
	return brain.get_current_target() || brain.get_target_turf()

/datum/human_ai_module/halo_covenant/proc/get_cached_threat_turf(cache_duration = 0.5 SECONDS)
	var/atom/threat = get_threat_atom()
	if(!threat)
		cached_threat_turf_time = -1
		cached_threat_atom = null
		cached_threat_turf = null
		return null

	if(cached_threat_atom == threat && cached_threat_turf_time >= (world.time - cache_duration))
		return cached_threat_turf

	cached_threat_atom = threat
	cached_threat_turf = get_turf(threat)
	cached_threat_turf_time = world.time
	return cached_threat_turf

/datum/human_ai_module/halo_covenant/proc/invalidate_runtime_caches()
	cached_threat_turf_time = -1
	cached_threat_atom = null
	cached_threat_turf = null
	ranged_fire_backoff_until = 0

/datum/human_ai_module/halo_covenant/proc/uses_projectile_pressure_controls()
	return brain.halo_unggoy_is_active() || brain.halo_sangheili_is_active()

/datum/human_ai_module/halo_covenant/proc/apply_navigation_profile(short_step_range = 0, path_retarget_slack = 0, nearby_item_interval = 1 SECONDS)
	brain.apply_navigation_profile(short_step_range, path_retarget_slack)
	var/datum/human_ai_module/inventory/inventory = get_inventory()
	if(inventory)
		inventory.nearby_item_search_interval = nearby_item_interval
		inventory.invalidate_nearby_item_search()

/datum/human_ai_module/halo_covenant/proc/should_suspend_nearby_item_search(queued_projectiles_override = null)
	if(!uses_projectile_pressure_controls() || !brain.is_in_combat())
		return FALSE

	return halo_is_projectile_queue_soft_limited(queued_projectiles_override)

/datum/human_ai_module/halo_covenant/proc/should_disable_cover_retreat(queued_projectiles_override = null)
	if(!uses_projectile_pressure_controls() || !brain.is_in_combat())
		return FALSE

	return halo_is_projectile_queue_hard_limited(queued_projectiles_override)

/datum/human_ai_module/halo_covenant/proc/should_defer_ranged_fire(atom/threat = null, queued_projectiles_override = null)
	if(!uses_projectile_pressure_controls())
		return FALSE

	if(ranged_fire_backoff_until > world.time)
		return TRUE

	if(!threat)
		threat = get_threat_atom()

	var/datum/human_ai_module/inventory/inventory = get_inventory()
	var/obj/item/weapon/gun/primary_weapon = inventory?.get_primary_weapon()
	if(!brain.has_valid_tied_human() || !primary_weapon || !threat)
		return FALSE

	var/datum/ammo/gun_ammo = halo_get_gun_combat_ammo(primary_weapon)
	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return FALSE
	if(controller.halo_should_backpressure_projectile_fire(threat, gun_ammo, queued_projectiles_override))
		ranged_fire_backoff_until = world.time + 0.6 SECONDS
		halo_perf_bump_projectile_throttles()
		return TRUE

	// When the AI has only a remembered threat turf, still shed ranged pressure for HALO runtime loops.
	if(!isturf(threat) || !controller.halo_is_ai_only_human() || !halo_is_projectile_pressure_relevant_ammo(gun_ammo))
		return FALSE

	if(!halo_is_projectile_queue_soft_limited(queued_projectiles_override))
		return FALSE

	ranged_fire_backoff_until = world.time + 0.6 SECONDS
	halo_perf_bump_projectile_throttles()
	return TRUE

/datum/human_ai_module/halo_covenant/proc/weapon_is_cooling(obj/item/weapon/gun/gun = null)
	if(!gun)
		gun = get_inventory()?.get_primary_weapon()

	if(!istype(gun, /obj/item/weapon/gun/energy/plasma))
		return FALSE

	var/obj/item/weapon/gun/energy/plasma/plasma_gun = gun
	return !COOLDOWN_FINISHED(plasma_gun, cooldown) || !COOLDOWN_FINISHED(plasma_gun, manual_cooldown)

/datum/human_ai_module/halo_covenant/proc/clear_hands()
	if(!brain.has_valid_tied_human())
		return FALSE
	var/datum/human_tied_controller/controller = get_controller()
	if(!controller)
		return FALSE

	if(!controller.get_active_hand())
		return TRUE

	if(!controller.get_inactive_hand())
		controller.swap_hand()
		return !controller.get_active_hand()

	var/datum/human_ai_module/inventory/inventory = get_inventory()
	inventory?.clear_main_hand()
	if(!controller.get_active_hand())
		return TRUE

	controller.swap_hand()
	if(!controller.get_active_hand())
		return TRUE

	inventory?.clear_main_hand()
	if(!controller.get_active_hand())
		return TRUE

	return FALSE
