/datum/human_ai_brain
	var/halo_sangheili_runtime = FALSE
	var/halo_unggoy_runtime = FALSE
	var/halo_unggoy_role
	var/halo_unggoy_panic_health_pct = 0
	var/halo_unggoy_panics_without_leader = FALSE
	var/halo_unggoy_ignore_panic = FALSE
	var/halo_unggoy_overheat_retreat = TRUE

	var/halo_sangheili_has_sword = FALSE
	var/halo_sangheili_sword_only = FALSE
	var/halo_sangheili_sword_charge_range = 5
	var/halo_sangheili_unarmed_commit_range = 2
	var/obj/item/weapon/covenant/energy_sword/halo_sangheili_drawn_sword
	var/halo_sangheili_sword_storage_loc
	var/halo_sangheili_melee_committed = FALSE
	var/obj/item/weapon/gun/halo_sangheili_committed_primary_weapon
	var/halo_sangheili_committed_tried_reload = FALSE
	var/halo_sangheili_committed_ignore_looting = FALSE
	var/halo_cached_ranged_fallback_time = -1
	var/halo_cached_ranged_fallback_available
	var/halo_cached_squad_anchor_time = -1
	var/turf/halo_cached_squad_anchor
	var/halo_cached_threat_turf_time = -1
	var/atom/halo_cached_threat_atom
	var/turf/halo_cached_threat_turf
	var/halo_ranged_fire_backoff_until = 0

/datum/human_ai_brain/proc/halo_covenant_get_threat_atom()
	return current_target || target_turf

/datum/human_ai_brain/proc/halo_covenant_get_cached_threat_turf(cache_duration = 0.5 SECONDS)
	var/atom/threat = halo_covenant_get_threat_atom()
	if(!threat)
		halo_cached_threat_turf_time = -1
		halo_cached_threat_atom = null
		halo_cached_threat_turf = null
		return null

	if(halo_cached_threat_atom == threat && halo_cached_threat_turf_time >= (world.time - cache_duration))
		return halo_cached_threat_turf

	halo_cached_threat_atom = threat
	halo_cached_threat_turf = get_turf(threat)
	halo_cached_threat_turf_time = world.time
	return halo_cached_threat_turf

/datum/human_ai_brain/proc/invalidate_halo_runtime_caches()
	halo_cached_ranged_fallback_time = -1
	halo_cached_ranged_fallback_available = null
	halo_cached_squad_anchor_time = -1
	halo_cached_squad_anchor = null
	halo_cached_threat_turf_time = -1
	halo_cached_threat_atom = null
	halo_cached_threat_turf = null
	halo_ranged_fire_backoff_until = 0

/datum/human_ai_brain/proc/halo_runtime_uses_projectile_pressure_controls()
	return halo_unggoy_runtime || halo_sangheili_runtime

/datum/human_ai_brain/proc/halo_apply_navigation_profile(short_step_range = 0, path_retarget_slack = 0, nearby_item_interval = 1 SECONDS)
	if(short_step_range > 0)
		short_step_pathing_range = max(short_step_pathing_range, short_step_range)

	if(path_retarget_slack > 0)
		path_target_retarget_slack = max(path_target_retarget_slack, path_retarget_slack)

	nearby_item_search_interval = nearby_item_interval
	nearby_item_search_dirty = TRUE

/datum/human_ai_brain/proc/halo_should_suspend_nearby_item_search(queued_projectiles_override = null)
	if(!halo_runtime_uses_projectile_pressure_controls() || !in_combat)
		return FALSE

	return halo_is_projectile_queue_soft_limited(queued_projectiles_override)

/datum/human_ai_brain/proc/halo_should_disable_cover_retreat(queued_projectiles_override = null)
	if(!halo_runtime_uses_projectile_pressure_controls() || !in_combat)
		return FALSE

	return halo_is_projectile_queue_hard_limited(queued_projectiles_override)

/datum/human_ai_brain/proc/halo_should_defer_ranged_fire(atom/threat = null, queued_projectiles_override = null)
	if(!halo_runtime_uses_projectile_pressure_controls())
		return FALSE

	if(halo_ranged_fire_backoff_until > world.time)
		return TRUE

	if(!threat)
		threat = halo_covenant_get_threat_atom()

	if(!tied_human || !primary_weapon || !threat)
		return FALSE

	var/datum/ammo/gun_ammo = halo_get_gun_combat_ammo(primary_weapon)
	if(halo_should_backpressure_ai_only_projectile_fire(tied_human, threat, gun_ammo, queued_projectiles_override))
		halo_ranged_fire_backoff_until = world.time + 0.6 SECONDS
		halo_perf_bump_projectile_throttles()
		return TRUE

	// When the AI has only a remembered threat turf, still shed ranged pressure for HALO runtime loops.
	if(!isturf(threat) || !halo_is_ai_only_human(tied_human) || !halo_is_projectile_pressure_relevant_ammo(gun_ammo))
		return FALSE

	if(!halo_is_projectile_queue_soft_limited(queued_projectiles_override))
		return FALSE

	halo_ranged_fire_backoff_until = world.time + 0.6 SECONDS
	halo_perf_bump_projectile_throttles()
	return TRUE

/datum/human_ai_brain/proc/halo_covenant_weapon_is_cooling(obj/item/weapon/gun/gun = null)
	if(!gun)
		gun = primary_weapon

	if(!istype(gun, /obj/item/weapon/gun/energy/plasma))
		return FALSE

	var/obj/item/weapon/gun/energy/plasma/plasma_gun = gun
	return !COOLDOWN_FINISHED(plasma_gun, cooldown) || !COOLDOWN_FINISHED(plasma_gun, manual_cooldown)

/datum/human_ai_brain/proc/halo_covenant_clear_hands()
	var/mob/living/carbon/human/human = tied_human
	if(!human)
		return FALSE

	if(!human.get_active_hand())
		return TRUE

	if(!human.get_inactive_hand())
		human.swap_hand()
		return !human.get_active_hand()

	clear_main_hand()
	if(!human.get_active_hand())
		return TRUE

	human.swap_hand()
	if(!human.get_active_hand())
		return TRUE

	clear_main_hand()
	if(!human.get_active_hand())
		return TRUE

	return FALSE

/datum/human_ai_brain/proc/halo_unggoy_get_squad()
	if(!squad_id)
		return null
	return SShuman_ai.squad_id_dict["[squad_id]"]

/datum/human_ai_brain/proc/halo_unggoy_get_squad_leader()
	var/datum/human_ai_squad/squad = halo_unggoy_get_squad()
	return squad?.squad_leader

/datum/human_ai_brain/proc/halo_unggoy_has_active_squad_leader()
	var/datum/human_ai_brain/leader = halo_unggoy_get_squad_leader()
	if(!leader)
		return FALSE
	if(leader == src)
		return TRUE
	if(!leader.tied_human)
		return FALSE
	if(leader.tied_human.stat >= DEAD)
		return FALSE
	if(leader.tied_human.is_mob_incapacitated())
		return FALSE
	return TRUE

/datum/human_ai_brain/proc/halo_unggoy_get_squad_anchor()
	if(!halo_unggoy_runtime)
		return null

	if(halo_cached_squad_anchor_time == world.time)
		return halo_cached_squad_anchor

	var/datum/human_ai_brain/leader = halo_unggoy_get_squad_leader()
	var/turf/anchor = get_turf(leader?.tied_human)
	if(anchor)
		halo_cached_squad_anchor_time = world.time
		halo_cached_squad_anchor = anchor
		return anchor

	var/datum/human_ai_squad/squad = halo_unggoy_get_squad()
	if(!squad)
		halo_cached_squad_anchor_time = world.time
		halo_cached_squad_anchor = null
		return null

	var/anchor_x = 0
	var/anchor_y = 0
	var/anchor_z = 0
	var/valid_members = 0
	for(var/datum/human_ai_brain/member as anything in squad.ai_in_squad)
		if(!member?.tied_human)
			continue

		var/turf/member_turf = get_turf(member.tied_human)
		if(!member_turf)
			continue

		if(member.tied_human.stat >= DEAD || member.tied_human.is_mob_incapacitated())
			continue

		anchor_x += member_turf.x
		anchor_y += member_turf.y
		anchor_z = member_turf.z
		valid_members++

	if(!valid_members)
		halo_cached_squad_anchor_time = world.time
		halo_cached_squad_anchor = null
		return null

	halo_cached_squad_anchor_time = world.time
	halo_cached_squad_anchor = locate(round(anchor_x / valid_members), round(anchor_y / valid_members), anchor_z)
	return halo_cached_squad_anchor

/datum/human_ai_brain/proc/halo_unggoy_get_health_pct()
	if(!tied_human?.maxHealth)
		return 1
	return max(tied_human.health, 0) / tied_human.maxHealth

/datum/human_ai_brain/proc/halo_unggoy_should_panic()
	if(!halo_unggoy_runtime || halo_unggoy_ignore_panic || !tied_human)
		return FALSE

	if((halo_unggoy_panic_health_pct > 0) && (halo_unggoy_get_health_pct() <= halo_unggoy_panic_health_pct))
		return TRUE

	if(!halo_unggoy_panics_without_leader || !squad_id || is_squad_leader)
		return FALSE

	return !halo_unggoy_has_active_squad_leader()

/datum/human_ai_brain/proc/halo_unggoy_should_retreat_on_overheat()
	if(!halo_unggoy_runtime || !halo_unggoy_overheat_retreat || !tied_human)
		return FALSE

	if(!halo_covenant_get_threat_atom())
		return FALSE

	return halo_covenant_weapon_is_cooling(primary_weapon)

/datum/human_ai_brain/proc/halo_unggoy_should_hold_anchor_on_overheat()
	if(!halo_unggoy_should_retreat_on_overheat())
		return FALSE

	return halo_unggoy_has_active_squad_leader()

/datum/human_ai_brain/proc/halo_unggoy_should_flee_on_overheat()
	if(!halo_unggoy_should_retreat_on_overheat())
		return FALSE

	return !halo_unggoy_has_active_squad_leader()

/datum/human_ai_brain/proc/halo_unggoy_should_use_cover_retreat()
	if(halo_should_disable_cover_retreat())
		return FALSE

	return halo_unggoy_should_panic() || halo_unggoy_should_hold_anchor_on_overheat()

/datum/human_ai_brain/proc/halo_unggoy_should_retreat()
	return halo_unggoy_should_panic() || halo_unggoy_should_retreat_on_overheat()

/datum/human_ai_brain/proc/halo_sangheili_find_sword()
	if(QDELETED(halo_sangheili_drawn_sword))
		halo_sangheili_drawn_sword = null
		halo_sangheili_sword_storage_loc = null

	if(istype(halo_sangheili_drawn_sword))
		return halo_sangheili_drawn_sword

	if(istype(tied_human?.l_hand, /obj/item/weapon/covenant/energy_sword))
		return tied_human.l_hand

	if(istype(tied_human?.r_hand, /obj/item/weapon/covenant/energy_sword))
		return tied_human.r_hand

	if(istype(tied_human?.s_store, /obj/item/weapon/covenant/energy_sword))
		return tied_human.s_store

	if(istype(tied_human?.belt, /obj/item/storage))
		return locate(/obj/item/weapon/covenant/energy_sword) in tied_human.belt

	if(halo_sangheili_melee_committed)
		halo_sangheili_clear_melee_commit()

/datum/human_ai_brain/proc/halo_sangheili_primary_weapon_unavailable()
	if(!tied_human)
		return TRUE

	if(!primary_weapon)
		return TRUE

	if(!primary_weapon.ai_can_use(tied_human, src))
		return TRUE

	if(halo_covenant_weapon_is_cooling(primary_weapon))
		return TRUE

	return should_reload()

/datum/human_ai_brain/proc/halo_sangheili_has_usable_ranged_fallback()
	if(!halo_sangheili_runtime)
		return FALSE

	if(halo_cached_ranged_fallback_time == world.time)
		return halo_cached_ranged_fallback_available

	var/obj/item/weapon/gun/fallback_weapon = halo_sangheili_committed_primary_weapon || primary_weapon
	if(!tied_human || !fallback_weapon || QDELETED(fallback_weapon))
		halo_cached_ranged_fallback_time = world.time
		halo_cached_ranged_fallback_available = FALSE
		return FALSE

	if(!halo_sangheili_owns_item(fallback_weapon))
		halo_cached_ranged_fallback_time = world.time
		halo_cached_ranged_fallback_available = FALSE
		return FALSE

	if(!fallback_weapon.ai_can_use(tied_human, src))
		halo_cached_ranged_fallback_time = world.time
		halo_cached_ranged_fallback_available = FALSE
		return FALSE

	if(fallback_weapon.has_ammunition())
		halo_cached_ranged_fallback_time = world.time
		halo_cached_ranged_fallback_available = TRUE
		return TRUE

	halo_cached_ranged_fallback_time = world.time
	halo_cached_ranged_fallback_available = !isnull(weapon_ammo_search(fallback_weapon))
	return halo_cached_ranged_fallback_available

/datum/human_ai_brain/proc/halo_sangheili_should_preserve_drawn_sword()
	if(!halo_sangheili_find_sword())
		return FALSE

	if(halo_sangheili_sword_only)
		return TRUE

	return !halo_sangheili_has_usable_ranged_fallback()

/datum/human_ai_brain/proc/halo_sangheili_should_use_sword_mode(atom/threat = null)
	if(!halo_sangheili_runtime)
		return FALSE

	if(!threat)
		threat = halo_covenant_get_threat_atom()

	if(!tied_human || !threat)
		return FALSE

	if(!halo_sangheili_has_sword && !halo_sangheili_sword_only)
		return FALSE

	if(!halo_sangheili_find_sword())
		return FALSE

	var/distance_to_threat = get_dist(tied_human, threat)
	if(distance_to_threat > halo_sangheili_sword_charge_range)
		return FALSE

	if(halo_sangheili_sword_only)
		return TRUE

	if(distance_to_threat <= halo_sangheili_unarmed_commit_range)
		return TRUE

	return halo_sangheili_primary_weapon_unavailable()

/datum/human_ai_brain/proc/halo_sangheili_should_sword_charge(atom/charge_target = null)
	return halo_sangheili_should_use_sword_mode(charge_target)

/datum/human_ai_brain/proc/halo_sangheili_should_overheat_response(atom/threat = null)
	if(!halo_sangheili_runtime)
		return FALSE

	if(!threat)
		threat = halo_covenant_get_threat_atom()

	if(!tied_human || !threat)
		return FALSE

	if(!halo_covenant_weapon_is_cooling(primary_weapon))
		return FALSE

	if(halo_sangheili_should_sword_charge(threat))
		return FALSE

	return TRUE

/datum/human_ai_brain/proc/halo_sangheili_should_unarmed_commit(atom/threat = null)
	if(!halo_sangheili_runtime)
		return FALSE

	if(!threat)
		threat = halo_covenant_get_threat_atom()

	if(!tied_human || !threat)
		return FALSE

	return get_dist(tied_human, threat) <= halo_sangheili_unarmed_commit_range

/datum/human_ai_brain/proc/on_halo_sangheili_sword_dropped()
	SIGNAL_HANDLER

	if(halo_sangheili_drawn_sword)
		UnregisterSignal(halo_sangheili_drawn_sword, COMSIG_ITEM_DROPPED)

	invalidate_halo_runtime_caches()
	halo_sangheili_drawn_sword = null
	halo_sangheili_sword_storage_loc = null
	halo_sangheili_clear_melee_commit()

/datum/human_ai_brain/proc/halo_sangheili_get_commit_action_blacklist()
	var/static/list/commit_action_blacklist = list(
		/datum/ai_action/fire_at_target,
		/datum/ai_action/keep_distance,
		/datum/ai_action/reload,
		/datum/ai_action/select_primary,
		/datum/ai_action/machinegunner_nest,
		/datum/ai_action/sniper_nest,
	)
	return commit_action_blacklist

/datum/human_ai_brain/proc/halo_sangheili_cancel_committed_actions()
	var/list/commit_action_blacklist = halo_sangheili_get_commit_action_blacklist()
	for(var/datum/ai_action/action as anything in ongoing_actions)
		if(action.type in commit_action_blacklist)
			qdel(action)

/datum/human_ai_brain/proc/halo_sangheili_owns_item(obj/item/item)
	if(!tied_human || !item || QDELETED(item))
		return FALSE

	if(item.loc == tied_human)
		return TRUE

	var/atom/item_loc = item.loc
	return item_loc?.loc == tied_human

/datum/human_ai_brain/proc/halo_sangheili_begin_melee_commit(obj/item/weapon/covenant/energy_sword/sword)
	if(halo_sangheili_melee_committed)
		return TRUE

	if(!tied_human || !sword || sword.loc != tied_human)
		return FALSE

	halo_sangheili_melee_committed = TRUE
	halo_sangheili_committed_primary_weapon = primary_weapon
	halo_sangheili_committed_tried_reload = tried_reload
	halo_sangheili_committed_ignore_looting = ignore_looting
	invalidate_halo_runtime_caches()

	if(primary_weapon)
		set_primary_weapon(null)

	tried_reload = TRUE
	ignore_looting = TRUE

	if(!action_blacklist)
		action_blacklist = list()

	var/list/commit_action_blacklist = halo_sangheili_get_commit_action_blacklist()
	for(var/action_type as anything in commit_action_blacklist)
		action_blacklist |= action_type

	halo_sangheili_cancel_committed_actions()
	return TRUE

/datum/human_ai_brain/proc/halo_sangheili_restore_ranged_state(atom/threat = null)
	if(halo_sangheili_sword_only || !halo_sangheili_melee_committed)
		return FALSE

	if(!halo_sangheili_has_usable_ranged_fallback())
		return FALSE

	if(halo_sangheili_should_use_sword_mode(threat))
		return FALSE

	if(halo_sangheili_holster_sword())
		return TRUE

	halo_sangheili_clear_melee_commit()
	return TRUE

/datum/human_ai_brain/proc/halo_sangheili_clear_melee_commit(restore_firearm = TRUE)
	if(!halo_sangheili_melee_committed && !halo_sangheili_committed_primary_weapon)
		return

	var/obj/item/weapon/gun/committed_primary_weapon = halo_sangheili_committed_primary_weapon
	var/committed_tried_reload = halo_sangheili_committed_tried_reload
	var/committed_ignore_looting = halo_sangheili_committed_ignore_looting

	halo_sangheili_melee_committed = FALSE
	halo_sangheili_committed_primary_weapon = null
	halo_sangheili_committed_tried_reload = FALSE
	halo_sangheili_committed_ignore_looting = FALSE
	invalidate_halo_runtime_caches()

	var/list/commit_action_blacklist = halo_sangheili_get_commit_action_blacklist()
	if(action_blacklist)
		for(var/action_type as anything in commit_action_blacklist)
			action_blacklist -= action_type
		if(!length(action_blacklist))
			action_blacklist = null

	tried_reload = committed_tried_reload
	ignore_looting = committed_ignore_looting

	if(!restore_firearm || primary_weapon || !committed_primary_weapon || !halo_sangheili_owns_item(committed_primary_weapon))
		return

	set_primary_weapon(committed_primary_weapon)

/datum/human_ai_brain/proc/halo_sangheili_should_keep_sword_drawn()
	if(halo_sangheili_should_preserve_drawn_sword())
		return TRUE

	if(!halo_sangheili_melee_committed)
		return FALSE

	return halo_sangheili_should_use_sword_mode()

/datum/human_ai_brain/proc/halo_sangheili_track_drawn_sword(obj/item/weapon/covenant/energy_sword/sword, storage_loc = null)
	if(!sword)
		return null

	if(halo_sangheili_drawn_sword && halo_sangheili_drawn_sword != sword)
		UnregisterSignal(halo_sangheili_drawn_sword, COMSIG_ITEM_DROPPED)

	halo_sangheili_drawn_sword = sword
	if(storage_loc)
		halo_sangheili_sword_storage_loc = storage_loc
	RegisterSignal(sword, COMSIG_ITEM_DROPPED, PROC_REF(on_halo_sangheili_sword_dropped), override = TRUE)
	return sword

/datum/human_ai_brain/proc/halo_sangheili_try_store_sword(obj/item/weapon/covenant/energy_sword/sword, storage_loc)
	var/mob/living/carbon/human/human = tied_human
	if(!human || !sword || (sword.loc != human))
		return FALSE

	switch(storage_loc)
		if("belt")
			if(istype(human.belt, /obj/item/storage))
				var/obj/item/storage/belt_storage = human.belt
				return belt_storage.attempt_item_insertion(sword, FALSE, human)
		if("suit_slot")
			if(!human.s_store)
				return human.equip_to_slot_if_possible(sword, WEAR_J_STORE, TRUE)

	return FALSE

/datum/human_ai_brain/proc/halo_sangheili_draw_sword()
	var/mob/living/carbon/human/human = tied_human
	if(!human)
		return null

	var/obj/item/weapon/covenant/energy_sword/sword = halo_sangheili_find_sword()
	if(!sword)
		return null

	var/storage_loc = halo_sangheili_sword_storage_loc

	if(sword.loc == human)
		if(human.get_inactive_hand() == sword)
			human.swap_hand()
		else if(!human.get_active_hand())
			human.put_in_active_hand(sword)
		halo_sangheili_track_drawn_sword(sword, storage_loc)
		halo_sangheili_begin_melee_commit(sword)
		return sword

	if(!halo_covenant_clear_hands())
		return null

	if(sword == human.s_store)
		storage_loc = "suit_slot"
		human.u_equip(sword)
	else if(sword.loc == human.belt)
		storage_loc = "belt"
		var/obj/item/storage/belt_storage = human.belt
		belt_storage.remove_from_storage(sword, human)
	else if(istype(sword.loc, /obj/item/storage))
		var/obj/item/storage/storage = sword.loc
		storage.remove_from_storage(sword, human)

	if(sword.loc != human)
		return null

	if(!human.put_in_hands(sword, FALSE))
		return null

	halo_sangheili_track_drawn_sword(sword, storage_loc)
	halo_sangheili_begin_melee_commit(sword)

	if(!sword.activated && !sword.nonfunctional)
		sword.set_activation_state(TRUE, human)
	ensure_primary_hand(sword)
	return sword

/datum/human_ai_brain/proc/halo_sangheili_holster_sword(force = FALSE)
	var/mob/living/carbon/human/human = tied_human
	var/obj/item/weapon/covenant/energy_sword/sword = halo_sangheili_drawn_sword || halo_sangheili_find_sword()
	if(!human || !sword)
		on_halo_sangheili_sword_dropped()
		return TRUE

	if(!force && halo_sangheili_should_preserve_drawn_sword())
		return FALSE

	if(sword.activated)
		sword.set_activation_state(FALSE, human)

	if(sword.loc != human)
		on_halo_sangheili_sword_dropped()
		return TRUE

	var/storage_loc = halo_sangheili_sword_storage_loc || "belt"
	var/success = halo_sangheili_try_store_sword(sword, storage_loc)
	if(!success && (storage_loc != "belt"))
		success = halo_sangheili_try_store_sword(sword, "belt")
	if(!success && (storage_loc != "suit_slot"))
		success = halo_sangheili_try_store_sword(sword, "suit_slot")

	if(success)
		on_halo_sangheili_sword_dropped()
		return TRUE

	return FALSE

/datum/human_ai_brain/reset_ai()
	. = ..()
	invalidate_halo_runtime_caches()
	halo_sangheili_clear_melee_commit(FALSE)

/datum/human_ai_brain/exit_combat()
	. = ..()
	if(halo_sangheili_should_preserve_drawn_sword())
		halo_sangheili_clear_melee_commit(FALSE)
		return
	if(halo_sangheili_melee_committed || halo_sangheili_drawn_sword)
		halo_sangheili_holster_sword()
