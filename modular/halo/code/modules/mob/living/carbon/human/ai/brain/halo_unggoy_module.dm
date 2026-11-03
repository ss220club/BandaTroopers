/datum/human_ai_module/halo_unggoy/proc/configure(new_role, new_panic_health_pct = 0, new_panics_without_leader = FALSE, new_ignore_panic = FALSE, new_overheat_retreat = TRUE)
	runtime = TRUE
	role = new_role
	panic_health_pct = new_panic_health_pct
	panics_without_leader = new_panics_without_leader
	ignore_panic = new_ignore_panic
	overheat_retreat = new_overheat_retreat
	invalidate_runtime_caches()

/datum/human_ai_module/halo_unggoy/proc/configure_suicide_bomber(new_suicide_prime_range = 5)
	runtime = TRUE
	suicide_bomber = TRUE
	suicide_prime_range = new_suicide_prime_range

/datum/human_ai_module/halo_unggoy/proc/invalidate_runtime_caches()
	cached_squad_anchor_time = -1
	cached_squad_anchor = null

/datum/human_ai_module/halo_unggoy/proc/is_active()
	return runtime

/datum/human_ai_module/halo_unggoy/proc/is_suicide_bomber()
	return suicide_bomber

/datum/human_ai_module/halo_unggoy/proc/get_squad_leader()
	return brain.get_squad_leader()

/datum/human_ai_module/halo_unggoy/proc/has_active_squad_leader()
	var/datum/human_ai_brain/leader = get_squad_leader()
	if(!leader)
		return FALSE
	if(leader == brain)
		return TRUE
	if(!leader.has_valid_tied_human())
		return FALSE
	var/datum/human_tied_controller/leader_controller = leader.halo_get_controller()
	if(!leader_controller)
		return FALSE
	if(leader_controller.is_dead())
		return FALSE
	if(leader_controller.is_incapacitated())
		return FALSE
	return TRUE

/datum/human_ai_module/halo_unggoy/proc/get_squad_anchor()
	if(!runtime)
		return null

	if(cached_squad_anchor_time == world.time)
		return cached_squad_anchor

	var/datum/human_ai_brain/leader = get_squad_leader()
	var/datum/human_tied_controller/leader_controller = leader?.halo_get_controller()
	var/turf/anchor = leader_controller?.get_current_turf()
	if(anchor)
		cached_squad_anchor_time = world.time
		cached_squad_anchor = anchor
		return anchor

	var/list/squad_members = brain.get_squad_members()
	if(!length(squad_members))
		cached_squad_anchor_time = world.time
		cached_squad_anchor = null
		return null

	var/anchor_x = 0
	var/anchor_y = 0
	var/anchor_z = 0
	var/valid_members = 0
	for(var/datum/human_ai_brain/member as anything in squad_members)
		if(!member?.has_valid_tied_human())
			continue
		var/datum/human_tied_controller/member_controller = member.halo_get_controller()
		if(!member_controller)
			continue

		var/turf/member_turf = member_controller.get_current_turf()
		if(!member_turf)
			continue

		if(member_controller.is_dead() || member_controller.is_incapacitated())
			continue

		anchor_x += member_turf.x
		anchor_y += member_turf.y
		anchor_z = member_turf.z
		valid_members++

	if(!valid_members)
		cached_squad_anchor_time = world.time
		cached_squad_anchor = null
		return null

	cached_squad_anchor_time = world.time
	cached_squad_anchor = locate(round(anchor_x / valid_members), round(anchor_y / valid_members), anchor_z)
	return cached_squad_anchor

/datum/human_ai_module/halo_unggoy/proc/get_health_pct()
	if(!brain.has_valid_tied_human())
		return 1
	var/datum/human_tied_controller/controller = brain.halo_get_controller()
	if(!controller)
		return 1
	return controller.get_health_ratio()

/datum/human_ai_module/halo_unggoy/proc/should_panic()
	if(!runtime || ignore_panic || !brain.has_valid_tied_human())
		return FALSE

	if((panic_health_pct > 0) && (get_health_pct() <= panic_health_pct))
		return TRUE

	if(!panics_without_leader || !brain.has_squad() || brain.is_squad_leader())
		return FALSE

	return !has_active_squad_leader()

/datum/human_ai_module/halo_unggoy/proc/should_retreat_on_overheat()
	if(!runtime || !overheat_retreat || !brain.has_valid_tied_human())
		return FALSE

	if(!brain.halo_covenant_get_threat_atom())
		return FALSE

	return brain.halo_covenant_weapon_is_cooling(brain.halo_get_inventory()?.get_primary_weapon())

/datum/human_ai_module/halo_unggoy/proc/should_hold_anchor_on_overheat()
	if(!should_retreat_on_overheat())
		return FALSE

	return has_active_squad_leader()

/datum/human_ai_module/halo_unggoy/proc/should_flee_on_overheat()
	if(!should_retreat_on_overheat())
		return FALSE

	return !has_active_squad_leader()

/datum/human_ai_module/halo_unggoy/proc/should_use_cover_retreat()
	if(brain.halo_should_disable_cover_retreat())
		return FALSE

	return should_panic() || should_hold_anchor_on_overheat()

/datum/human_ai_module/halo_unggoy/proc/should_retreat()
	return should_panic() || should_retreat_on_overheat()

/datum/human_ai_module/halo_unggoy/proc/get_panic_retreat_weight()
	if(!is_active() || !brain.halo_covenant_can_run_movement_action())
		return 0
	if(!should_retreat() || !brain.halo_covenant_get_threat_atom())
		return 0
	return 25

/datum/human_ai_module/halo_unggoy/proc/run_panic_retreat_step()
	if(!is_active() || !brain.has_valid_tied_human() || !brain.halo_covenant_can_run_movement_action() || !should_retreat())
		return ONGOING_ACTION_COMPLETED

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!threat)
		return ONGOING_ACTION_COMPLETED

	if(should_use_cover_retreat() && brain.halo_covenant_try_cover_retreat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(!should_use_cover_retreat() && brain.halo_covenant_has_cover())
		brain.halo_covenant_end_cover()

	var/keep_anchor = !should_flee_on_overheat()
	var/turf/anchor = keep_anchor ? get_squad_anchor() : null
	if(brain.halo_covenant_step_away_from_threat(threat, anchor, 1))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/halo_unggoy/proc/get_suicide_bomber_weight()
	if(!brain.has_valid_tied_human() || !is_suicide_bomber())
		return 0
	if(!brain.halo_covenant_can_run_movement_action() || !brain.halo_covenant_get_threat_atom())
		return 0
	if(find_active_held_grenade())
		return 80
	if(!brain.halo_covenant_has_grenade_equipment())
		return 0
	return 70

/datum/human_ai_module/halo_unggoy/proc/run_suicide_bomber_step()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain.has_valid_tied_human() || !controller || !is_suicide_bomber())
		return ONGOING_ACTION_COMPLETED

	brain.halo_covenant_end_cover()
	var/obj/item/explosive/grenade/active_grenade = find_active_held_grenade()
	if(!active_grenade)
		var/atom/charge_target = brain.halo_covenant_get_threat_atom()
		if(!charge_target)
			return ONGOING_ACTION_COMPLETED

		if(controller.get_distance_to(charge_target) > suicide_prime_range)
			if(!move_towards_charge_target(charge_target))
				return ONGOING_ACTION_COMPLETED
			return ONGOING_ACTION_UNFINISHED_BLOCK

		if(!prime_suicide_grenades())
			return ONGOING_ACTION_COMPLETED
		active_grenade = find_active_held_grenade()
		if(!active_grenade)
			return ONGOING_ACTION_COMPLETED

	var/atom/current_target = brain.halo_covenant_get_threat_atom()
	if(!current_target)
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(controller.get_distance_to(current_target) <= 1)
		controller.face_atom(current_target)
		return ONGOING_ACTION_UNFINISHED_BLOCK

	move_towards_charge_target(current_target)
	return ONGOING_ACTION_UNFINISHED_BLOCK

/datum/human_ai_module/halo_unggoy/proc/find_active_held_grenade()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain.has_valid_tied_human() || !controller)
		return null

	if(istype(controller.get_l_hand(), /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/left_grenade = controller.get_l_hand()
		if(left_grenade.active)
			return left_grenade

	if(istype(controller.get_r_hand(), /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/right_grenade = controller.get_r_hand()
		if(right_grenade.active)
			return right_grenade
	return null

/datum/human_ai_module/halo_unggoy/proc/prime_suicide_grenades()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain.has_valid_tied_human() || !controller)
		return FALSE

	brain.halo_covenant_clear_both_hands()
	if(!brain.has_valid_tied_human())
		return FALSE

	var/obj/item/explosive/grenade/first_grenade = brain.halo_covenant_get_stored_grenade()
	if(!first_grenade)
		return FALSE

	brain.halo_covenant_equip_grenade(first_grenade)
	if(QDELETED(first_grenade) || !controller.is_item_equipped_or_held(first_grenade))
		return FALSE

	var/obj/item/explosive/grenade/second_grenade = brain.halo_covenant_get_stored_grenade(first_grenade)
	if(second_grenade)
		controller.swap_hand()
		brain.halo_covenant_equip_grenade(second_grenade)
		if(QDELETED(second_grenade) || !controller.is_item_equipped_or_held(second_grenade))
			second_grenade = null
		controller.swap_hand()

	if(!controller.prime_grenade_no_sleep(first_grenade))
		return FALSE
	if(second_grenade)
		controller.prime_grenade_no_sleep(second_grenade)
	if(controller.has_throw_mode())
		controller.disable_throw_mode()
	return TRUE

/datum/human_ai_module/halo_unggoy/proc/move_towards_charge_target(atom/charge_target)
	if(!brain.has_valid_tied_human())
		return FALSE
	return brain.halo_covenant_move_to_atom(charge_target, is_active())
