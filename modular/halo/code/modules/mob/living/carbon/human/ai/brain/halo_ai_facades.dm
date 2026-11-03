/datum/human_ai_brain/proc/halo_get_covenant_module()
	RETURN_TYPE(/datum/human_ai_module/halo_covenant)
	return get_module(/datum/human_ai_module/halo_covenant)

/datum/human_ai_brain/proc/halo_get_unggoy_module()
	RETURN_TYPE(/datum/human_ai_module/halo_unggoy)
	return get_module(/datum/human_ai_module/halo_unggoy)

/datum/human_ai_brain/proc/halo_get_sangheili_module()
	RETURN_TYPE(/datum/human_ai_module/halo_sangheili)
	return get_module(/datum/human_ai_module/halo_sangheili)

/datum/human_ai_brain/proc/halo_get_controller()
	RETURN_TYPE(/datum/human_tied_controller)
	var/datum/human_ai_context/context = create_context()
	var/datum/human_tied_controller/controller = context?.controller
	qdel(context)
	return controller

/datum/human_ai_brain/proc/halo_covenant_can_run_movement_action(block_active_grenade = FALSE)
	return halo_get_covenant_module()?.can_run_movement_action(block_active_grenade)

/datum/human_ai_brain/proc/halo_covenant_has_pending_cover()
	return halo_get_covenant_module()?.has_pending_cover()

/datum/human_ai_brain/proc/halo_covenant_has_cover()
	return halo_get_covenant_module()?.has_cover()

/datum/human_ai_brain/proc/halo_covenant_end_cover()
	halo_get_covenant_module()?.end_cover()

/datum/human_ai_brain/proc/halo_covenant_try_cover_retreat(atom/threat)
	return halo_get_covenant_module()?.try_cover_retreat(threat)

/datum/human_ai_brain/proc/halo_covenant_step_away_from_threat(atom/threat, turf/anchor = null, anchor_weight = 0)
	return halo_get_covenant_module()?.step_away_from_threat(threat, anchor, anchor_weight)

/datum/human_ai_brain/proc/halo_covenant_move_to_threat(atom/threat)
	return halo_get_covenant_module()?.move_to_threat(threat)

/datum/human_ai_brain/proc/halo_covenant_move_to_atom(atom/target, use_cached_threat_turf = FALSE)
	return halo_get_covenant_module()?.move_to_atom(target, use_cached_threat_turf)

/datum/human_ai_brain/proc/halo_get_inventory()
	RETURN_TYPE(/datum/human_ai_module/inventory)
	return halo_get_covenant_module()?.get_inventory()

/datum/human_ai_brain/proc/halo_covenant_has_grenade_equipment()
	return halo_get_covenant_module()?.has_grenade_equipment()

/datum/human_ai_brain/proc/halo_covenant_get_stored_grenade(obj/item/explosive/grenade/excluding = null)
	return halo_get_covenant_module()?.get_stored_grenade(excluding)

/datum/human_ai_brain/proc/halo_covenant_clear_both_hands()
	halo_get_covenant_module()?.clear_both_hands()

/datum/human_ai_brain/proc/halo_covenant_equip_grenade(obj/item/explosive/grenade/grenade_item)
	return halo_get_covenant_module()?.equip_grenade(grenade_item)

/datum/human_ai_brain/proc/halo_covenant_get_threat_atom()
	return halo_get_covenant_module()?.get_threat_atom()

/datum/human_ai_brain/proc/halo_covenant_get_cached_threat_turf(cache_duration = 0.5 SECONDS)
	return halo_get_covenant_module()?.get_cached_threat_turf(cache_duration)

/datum/human_ai_brain/proc/invalidate_halo_runtime_caches()
	halo_get_covenant_module()?.invalidate_runtime_caches()
	halo_get_unggoy_module()?.invalidate_runtime_caches()
	halo_get_sangheili_module()?.invalidate_runtime_caches()

/datum/human_ai_brain/proc/modular_invalidate_runtime_extension_caches()
	invalidate_halo_runtime_caches()

/datum/human_ai_brain/proc/halo_apply_navigation_profile(short_step_range = 0, path_retarget_slack = 0, nearby_item_interval = 1 SECONDS)
	halo_get_covenant_module()?.apply_navigation_profile(short_step_range, path_retarget_slack, nearby_item_interval)

/datum/human_ai_brain/proc/halo_should_suspend_nearby_item_search(queued_projectiles_override = null)
	return halo_get_covenant_module()?.should_suspend_nearby_item_search(queued_projectiles_override)

/datum/human_ai_brain/proc/modular_should_suspend_nearby_item_search(queued_projectiles_override = null)
	return halo_should_suspend_nearby_item_search(queued_projectiles_override)

/datum/human_ai_brain/proc/halo_should_disable_cover_retreat(queued_projectiles_override = null)
	return halo_get_covenant_module()?.should_disable_cover_retreat(queued_projectiles_override)

/datum/human_ai_brain/proc/halo_should_defer_ranged_fire(atom/threat = null, queued_projectiles_override = null)
	return halo_get_covenant_module()?.should_defer_ranged_fire(threat, queued_projectiles_override)

/datum/human_ai_brain/proc/modular_should_defer_ranged_fire(atom/threat = null, queued_projectiles_override = null)
	return halo_should_defer_ranged_fire(threat, queued_projectiles_override)

/datum/human_ai_brain/proc/halo_covenant_weapon_is_cooling(obj/item/weapon/gun/gun = null)
	return halo_get_covenant_module()?.weapon_is_cooling(gun)

/datum/human_ai_brain/proc/halo_covenant_clear_hands()
	return halo_get_covenant_module()?.clear_hands()
/datum/human_ai_brain/proc/halo_configure_unggoy_behavior(role, panic_health_pct = 0, panics_without_leader = FALSE, ignore_panic = FALSE, overheat_retreat = TRUE)
	halo_get_unggoy_module()?.configure(role, panic_health_pct, panics_without_leader, ignore_panic, overheat_retreat)

/datum/human_ai_brain/proc/halo_configure_unggoy_suicide_bomber(suicide_prime_range = 5)
	halo_get_unggoy_module()?.configure_suicide_bomber(suicide_prime_range)

/datum/human_ai_brain/proc/halo_unggoy_is_active()
	return halo_get_unggoy_module()?.is_active()

/datum/human_ai_brain/proc/halo_unggoy_is_suicide_bomber()
	return halo_get_unggoy_module()?.is_suicide_bomber()

/datum/human_ai_brain/proc/halo_unggoy_get_panic_retreat_weight()
	return halo_get_unggoy_module()?.get_panic_retreat_weight() || 0

/datum/human_ai_brain/proc/halo_unggoy_run_panic_retreat_step()
	return halo_get_unggoy_module()?.run_panic_retreat_step() || ONGOING_ACTION_COMPLETED

/datum/human_ai_brain/proc/halo_unggoy_get_suicide_bomber_weight()
	return halo_get_unggoy_module()?.get_suicide_bomber_weight() || 0

/datum/human_ai_brain/proc/halo_unggoy_run_suicide_bomber_step()
	return halo_get_unggoy_module()?.run_suicide_bomber_step() || ONGOING_ACTION_COMPLETED
/datum/human_ai_brain/proc/halo_configure_sangheili_behavior(has_sword = FALSE, sword_only = FALSE, sword_charge_range = 5, unarmed_commit_range = 2)
	halo_get_sangheili_module()?.configure(has_sword, sword_only, sword_charge_range, unarmed_commit_range)

/datum/human_ai_brain/proc/halo_sangheili_is_active()
	return halo_get_sangheili_module()?.is_active()

/datum/human_ai_brain/proc/halo_sangheili_is_sword_only()
	return halo_get_sangheili_module()?.is_sword_only()

/datum/human_ai_brain/proc/halo_sangheili_has_melee_commit()
	return halo_get_sangheili_module()?.has_melee_commit()

/datum/human_ai_brain/proc/halo_sangheili_get_drawn_sword()
	return halo_get_sangheili_module()?.get_drawn_sword()

/datum/human_ai_brain/proc/halo_sangheili_find_sword()
	return halo_get_sangheili_module()?.find_sword()

/datum/human_ai_brain/proc/halo_sangheili_primary_weapon_unavailable()
	return halo_get_sangheili_module()?.primary_weapon_unavailable()

/datum/human_ai_brain/proc/halo_sangheili_has_usable_ranged_fallback()
	return halo_get_sangheili_module()?.has_usable_ranged_fallback()

/datum/human_ai_brain/proc/halo_sangheili_should_preserve_drawn_sword()
	return halo_get_sangheili_module()?.should_preserve_drawn_sword()

/datum/human_ai_brain/proc/halo_sangheili_should_use_sword_mode(atom/threat = null)
	return halo_get_sangheili_module()?.should_use_sword_mode(threat)

/datum/human_ai_brain/proc/halo_sangheili_should_sword_charge(atom/charge_target = null)
	return halo_get_sangheili_module()?.should_sword_charge(charge_target)

/datum/human_ai_brain/proc/halo_sangheili_should_overheat_response(atom/threat = null)
	return halo_get_sangheili_module()?.should_overheat_response(threat)

/datum/human_ai_brain/proc/halo_sangheili_should_unarmed_commit(atom/threat = null)
	return halo_get_sangheili_module()?.should_unarmed_commit(threat)

/datum/human_ai_brain/proc/on_halo_sangheili_sword_dropped()
	SIGNAL_HANDLER

	halo_get_sangheili_module()?.on_sword_dropped()

/datum/human_ai_brain/proc/halo_sangheili_get_commit_action_blacklist()
	return halo_get_sangheili_module()?.get_commit_action_blacklist()

/datum/human_ai_brain/proc/halo_sangheili_cancel_committed_actions()
	halo_get_sangheili_module()?.cancel_committed_actions()

/datum/human_ai_brain/proc/halo_sangheili_owns_item(obj/item/item)
	return halo_get_sangheili_module()?.owns_item(item)

/datum/human_ai_brain/proc/halo_sangheili_begin_melee_commit(obj/item/weapon/covenant/energy_sword/sword)
	return halo_get_sangheili_module()?.begin_melee_commit(sword)

/datum/human_ai_brain/proc/halo_sangheili_restore_ranged_state(atom/threat = null)
	return halo_get_sangheili_module()?.restore_ranged_state(threat)

/datum/human_ai_brain/proc/halo_sangheili_clear_melee_commit(restore_firearm = TRUE)
	halo_get_sangheili_module()?.clear_melee_commit(restore_firearm)

/datum/human_ai_brain/proc/halo_sangheili_should_keep_sword_drawn()
	return halo_get_sangheili_module()?.should_keep_sword_drawn()

/datum/human_ai_brain/proc/halo_sangheili_track_drawn_sword(obj/item/weapon/covenant/energy_sword/sword, storage_loc = null)
	return halo_get_sangheili_module()?.track_drawn_sword(sword, storage_loc)

/datum/human_ai_brain/proc/halo_sangheili_try_store_sword(obj/item/weapon/covenant/energy_sword/sword, storage_loc)
	return halo_get_sangheili_module()?.try_store_sword(sword, storage_loc)

/datum/human_ai_brain/proc/halo_sangheili_draw_sword()
	return halo_get_sangheili_module()?.draw_sword()

/datum/human_ai_brain/proc/halo_sangheili_holster_sword(force = FALSE)
	return halo_get_sangheili_module()?.holster_sword(force)

/datum/human_ai_brain/proc/halo_sangheili_on_sword_charge_added()
	get_melee_module()?.halo_sangheili_on_sword_charge_added()

/datum/human_ai_brain/proc/halo_sangheili_get_sword_charge_weight()
	return get_melee_module()?.halo_sangheili_get_sword_charge_weight() || 0

/datum/human_ai_brain/proc/halo_sangheili_cleanup_sword_charge()
	get_melee_module()?.halo_sangheili_cleanup_sword_charge()

/datum/human_ai_brain/proc/halo_sangheili_run_sword_charge_step()
	return get_melee_module()?.halo_sangheili_run_sword_charge_step() || ONGOING_ACTION_COMPLETED

/datum/human_ai_brain/proc/halo_sangheili_on_unarmed_action_added()
	get_melee_module()?.halo_sangheili_on_unarmed_action_added()

/datum/human_ai_brain/proc/halo_sangheili_cleanup_unarmed_action()
	get_melee_module()?.halo_sangheili_cleanup_unarmed_action()

/datum/human_ai_brain/proc/halo_sangheili_get_kick_weight()
	return get_melee_module()?.halo_sangheili_get_kick_weight() || 0

/datum/human_ai_brain/proc/halo_sangheili_run_kick_step()
	return get_melee_module()?.halo_sangheili_run_kick_step() || ONGOING_ACTION_COMPLETED

/datum/human_ai_brain/proc/halo_sangheili_get_overheat_response_weight()
	return get_melee_module()?.halo_sangheili_get_overheat_response_weight() || 0

/datum/human_ai_brain/proc/halo_sangheili_run_overheat_response_step()
	return get_melee_module()?.halo_sangheili_run_overheat_response_step() || ONGOING_ACTION_COMPLETED
