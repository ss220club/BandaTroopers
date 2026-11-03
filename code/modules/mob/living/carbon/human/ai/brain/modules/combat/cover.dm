/datum/human_ai_module/cover
	module_id = "cover"
	required_module_types = list(/datum/human_ai_module/faction, /datum/human_ai_module/orders, /datum/human_ai_module/targeting, /datum/human_ai_module/profile)

	/// If TRUE, AI is currently in some form of cover
	var/in_cover = FALSE
	/// Reference to atom currently selected as a cover place
	var/atom/current_cover
	/// TRUE while cover is being used as a temporary self-treatment posture.
	var/medical_retreat = FALSE
	COOLDOWN_DECLARE(cover_search_cooldown)

	/// If this AI can seek cover while not possessing a gun
	var/cover_without_gun = FALSE
	/// The chance that the AI will leave cover when exiting combat
	var/peek_cover_chance = 60

/datum/human_ai_module/cover/proc/is_in_cover()
	return in_cover

/datum/human_ai_module/cover/proc/has_cover()
	return !!current_cover

/datum/human_ai_module/cover/proc/has_pending_cover()
	return has_cover() && !is_in_cover()

/datum/human_ai_module/cover/proc/get_current_cover()
	RETURN_TYPE(/turf)
	return current_cover

/datum/human_ai_module/cover/proc/start_cover_search_cooldown(cooldown)
	COOLDOWN_START(src, cover_search_cooldown, cooldown)

/datum/human_ai_module/cover/proc/get_cover_destination()
	RETURN_TYPE(/turf)
	return get_current_cover()

/datum/human_ai_module/cover/proc/get_cover_action_weight(datum/human_tied_controller/controller, datum/human_ai_firearm_profile/gun_data = null)
	if(!can_attempt_cover_move(controller, gun_data))
		return 0
	return medical_retreat ? 18 : 15

/datum/human_ai_module/cover/proc/perform_cover_move(datum/human_tied_controller/controller)
	if(!controller)
		return ONGOING_ACTION_COMPLETED

	var/turf/cover_destination = get_cover_destination()
	if(!cover_destination)
		return ONGOING_ACTION_COMPLETED

#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	cover_destination.color = "#b80505"
	cover_destination.maptext = "[controller.get_real_name()] | [controller.get_distance_from(cover_destination)]"
#endif

	if(controller.get_distance_from(cover_destination) > 0)
		if(!brain.move_to_turf(cover_destination))
			end_cover()
			return ONGOING_ACTION_COMPLETED

		if(!brain.can_continue_runtime_work())
			return ONGOING_ACTION_COMPLETED

		if(controller.get_distance_from(cover_destination) > 0)
			return ONGOING_ACTION_UNFINISHED

	enter_cover()
	return ONGOING_ACTION_COMPLETED

/datum/human_ai_module/cover/proc/perform_burning_resist(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	if(!controller.is_on_fire())
		return ONGOING_ACTION_COMPLETED

	if(locate(/obj/flamer_fire) in controller.get_current_turf())
		try_cover()
		return ONGOING_ACTION_COMPLETED

	controller.resist()
	return ONGOING_ACTION_UNFINISHED

/datum/human_ai_module/cover/proc/get_owner_current_target()
	RETURN_TYPE(/atom/movable)
	return brain.get_current_target()

/datum/human_ai_module/cover/proc/get_owner_gun_data()
	RETURN_TYPE(/datum/human_ai_firearm_profile)
	return brain.get_gun_data()

/datum/human_ai_module/cover/proc/has_valid_owner()
	return brain.has_valid_tied_human()

/datum/human_ai_module/cover/proc/can_owner_move_for_action()
	return brain.can_move_for_action()

/datum/human_ai_module/cover/proc/has_owner_primary_weapon()
	return brain.has_primary_weapon()

/datum/human_ai_module/cover/proc/notify_owner_cover_scan_started()
	return brain?.notify_cover_scan_started()

/datum/human_ai_module/cover/proc/has_owner_squad()
	return brain.has_squad()

/datum/human_ai_module/cover/proc/get_owner_squad_members()
	return brain.get_squad_members()

/datum/human_ai_module/cover/proc/get_owner_view_distance()
	return brain.get_view_distance()

/datum/human_ai_module/cover/proc/is_owner_friendly_target(atom/target)
	return brain.is_friendly_target(target)

/datum/human_ai_module/cover/proc/can_owner_use_ranged_fire_line(datum/human_tied_controller/controller, atom/target, datum/human_ai_firearm_profile/gun_data = null)
	return brain.can_use_ranged_fire_line(controller, target, gun_data)

/datum/human_ai_module/cover/proc/can_use_cover_as_firing_position(datum/human_tied_controller/controller, datum/human_ai_firearm_profile/gun_data = null)
	if(!is_in_cover())
		return FALSE
	var/atom/movable/current_target = get_owner_current_target()
	if(!current_target || !controller)
		return FALSE
	return can_owner_use_ranged_fire_line(controller, current_target, gun_data)

/datum/human_ai_module/cover/proc/needs_medical_cover(datum/human_tied_controller/controller)
	return brain?.has_tactical_self_treatment_need(controller)

/datum/human_ai_module/cover/proc/validate_cover_position(datum/human_tied_controller/controller, datum/human_ai_firearm_profile/gun_data = null)
	if(!is_in_cover())
		return TRUE
	if(medical_retreat && needs_medical_cover(controller))
		return TRUE
	if(can_use_cover_as_firing_position(controller, gun_data))
		return TRUE
	end_cover()
	return FALSE

/datum/human_ai_module/cover/proc/should_hold_cover_position_against_target(datum/human_tied_controller/controller, datum/human_ai_firearm_profile/gun_data = null)
	if(!is_in_cover())
		return FALSE
	if(medical_retreat && needs_medical_cover(controller))
		return TRUE
	var/atom/movable/current_target = get_owner_current_target()
	if(!current_target || !controller)
		return FALSE
	return !(controller.get_distance_to(current_target) > gun_data?.minimum_range)

/datum/human_ai_module/cover/proc/can_attempt_cover_move(datum/human_tied_controller/controller, datum/human_ai_firearm_profile/gun_data = null)
	if(!has_valid_owner() || !controller)
		return FALSE
	if(!has_cover())
		return FALSE
	if(!can_owner_move_for_action())
		return FALSE
	if(should_hold_cover_position_against_target(controller, gun_data))
		return FALSE
	return TRUE

/datum/human_ai_module/cover/proc/should_block_movement_for_pending_cover()
	return has_pending_cover() || (is_in_cover() && medical_retreat)

/datum/human_ai_module/cover/proc/should_block_stationary_fire_for_cover()
	if(!get_owner_current_target())
		return FALSE
	return has_cover()

/datum/human_ai_module/cover/proc/enter_cover()
	in_cover = TRUE
	var/datum/human_tied_controller/controller = context?.controller
	validate_cover_position(controller, get_owner_gun_data())

/datum/human_ai_module/cover/proc/end_cover()
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	if(current_cover)
		current_cover.color = null
		current_cover.maptext = null
#endif
	current_cover = null
	in_cover = FALSE
	medical_retreat = FALSE

/datum/human_ai_module/cover/reset_module()
	end_cover()

/datum/human_ai_module/cover/suspend_module(clear_inventory = FALSE)
	end_cover()

/datum/human_ai_module/cover/proc/can_continue_cover_work()
	return brain?.can_continue_runtime_work()

/datum/human_ai_module/cover/process_module(delta_time)
	if(!can_continue_cover_work())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(!needs_medical_cover(controller))
		if(medical_retreat)
			medical_retreat = FALSE
			validate_cover_position(controller, get_owner_gun_data())
		return

	medical_retreat = TRUE
	if(has_cover() || !can_owner_move_for_action())
		return

	var/atom/threat = brain.get_aim_target()
	if(!threat)
		return
	try_cover(controller.get_angle_from(threat), threat)

/datum/human_ai_module/cover/on_ai_event(datum/human_ai_event/event)
	if(!can_continue_cover_work())
		return

	switch(event.event_type)
		if(HUMAN_AI_EVENT_PROJECTILE_THREAT)
			var/obj/projectile/bullet = event.get_projectile()
			on_projectile_threat(bullet, event.is_from_direct_hit(), event.get_threat_source(), event.get_threat_angle())
		if(HUMAN_AI_EVENT_COMBAT_ENTERED)
			on_combat_entered(event.was_in_combat())
		if(HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED, HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED)
			on_combat_exit_finished(event.get_combat_exit_context())
		if(HUMAN_AI_EVENT_MOVED)
			on_moved(event.get_old_location(), event.get_direction(), event.was_forced_move())

/datum/human_ai_module/cover/on_projectile_threat(obj/projectile/bullet, from_direct_hit = FALSE, atom/movable/threat_source = null, threat_angle = null)
	if(!can_continue_cover_work())
		return

	if(!from_direct_hit)
		return
	if(!threat_source || isnull(threat_angle))
		return

	react_to_incoming_fire(threat_angle, threat_source)

/datum/human_ai_module/cover/on_combat_exit_finished(list/combat_exit_context)
	if(!can_continue_cover_work())
		return

	if(combat_exit_context?["force_clear"])
		end_cover()
		return

	if(has_cover())
		if(!prob(peek_cover_chance))
			combat_exit_context["clear_target_turf"] = TRUE
		end_cover()
	else
		combat_exit_context["clear_target_turf"] = TRUE

/datum/human_ai_module/cover/on_combat_entered(was_in_combat)
	if(!can_continue_cover_work())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	var/atom/movable/current_target = get_owner_current_target()
	if(isxeno(current_target))
		try_cover(controller.get_angle_from(current_target), current_target)

/datum/human_ai_module/cover/on_moved(atom/oldloc, direction, forced)
	if(!can_continue_cover_work())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	if(is_in_cover() && (controller.get_distance_to(get_current_cover()) > get_owner_gun_data()?.minimum_range))
		end_cover()
		return

	validate_cover_position(controller, get_owner_gun_data())

/datum/human_ai_module/cover/proc/react_to_incoming_fire(angle, atom/firer)
	if(!can_continue_cover_work() || !has_valid_owner())
		return

	if(!current_cover)
		try_cover(angle, firer)
	else if(in_cover)
		on_shot_inside_cover(angle, firer)

/// Try to get the AI to find a suitable cover tile based on the angle a projectile came from.
/datum/human_ai_module/cover/proc/try_cover(angle, atom/source)
	if(!can_continue_cover_work())
		return

	if(!COOLDOWN_FINISHED(src, cover_search_cooldown))
		return

	if(!(cover_without_gun || has_owner_primary_weapon()))
		return

	COOLDOWN_START(src, cover_search_cooldown, 10 SECONDS)
	notify_owner_cover_scan_started()

	var/list/turf_dict = list()
	var/cover_dir = reverse_direction(angle2dir4ai(angle))
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	recursive_turf_cover_scan(controller.get_current_turf(), turf_dict, cover_dir)

#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_cover_value_debug), turf_dict.Copy()), 60 SECONDS)
#endif

	cover_processing(turf_dict)

/datum/human_ai_module/cover/proc/on_shot_inside_cover(angle, atom/source)
	if(!can_continue_cover_work())
		return

	// Cover isn't working. Charge!
	end_cover()

/datum/human_ai_module/cover/proc/cover_processing(list/turf_dict, from_squad = FALSE)
	if(!can_continue_cover_work())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	var/most_weight = -INFINITY
	var/turf/best_cover
	for(var/turf/T as anything in turf_dict)
		var/weight = turf_dict[T]
		if(weight > most_weight)
			most_weight = weight
			best_cover = T

	if(best_cover && best_cover != controller.get_current_turf())
		turf_dict -= best_cover
		// insert cover atom deletion/move comsigs here
		current_cover = best_cover
		// SS220 EDIT: forward the resolved cover scan once with the correct turf_dict payload
		if(!from_squad)
			squad_cover_processing(turf_dict)

/// If an AI decides to go into cover, any squadmates in their view range will process on the same view dictionary so as to help with performance
/datum/human_ai_module/cover/proc/squad_cover_processing(list/turf_dict)
	if(!can_continue_cover_work())
		return

	if(!has_owner_squad())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	for(var/datum/human_ai_brain/squaddie as anything in get_owner_squad_members())
		if(squaddie == brain)
			continue

		if(!squaddie.has_valid_tied_human())
			continue

		var/datum/human_ai_context/squaddie_context = squaddie.create_context()
		var/datum/human_tied_controller/squaddie_controller = squaddie_context.controller
		if(!squaddie_controller || controller.get_distance_to(squaddie_controller.get_current_turf()) > get_owner_view_distance())
			qdel(squaddie_context)
			continue

		if(squaddie_controller.is_incapacitated())
			qdel(squaddie_context)
			continue

		qdel(squaddie_context)
		squaddie.start_cover_search_cooldown(15 SECONDS)
		squaddie.apply_cover_processing(turf_dict, TRUE)

/// Searches each nearby tile and determines how suitable it is as cover, giving it a numerical score and adding it to turf_dict.
/datum/human_ai_module/cover/proc/recursive_turf_cover_scan(turf/scan_turf, list/turf_dict, cover_dir, first_iteration = TRUE)
	if(!can_continue_cover_work())
		return FALSE

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller || !scan_turf)
		return FALSE

	var/list/turfs_to_scan = list(scan_turf)
	var/current_index = 1
	var/list/related_cover_dirs = get_related_directions(cover_dir)
	var/atom/movable/current_target = get_owner_current_target()

	while(current_index <= length(turfs_to_scan) && length(turf_dict) < 198)
		var/turf/current_scan_turf = turfs_to_scan[current_index++]
		if(!current_scan_turf || (current_scan_turf in turf_dict))
			continue

		var/is_first_turf = (current_scan_turf == scan_turf)
		turf_dict[current_scan_turf] = 0

		var/blocked_scan_turf = FALSE
		for(var/atom/movable/thing as anything in current_scan_turf.contents)
			if(thing.density && !istype(thing, /obj/structure/barricade))
				turf_dict[current_scan_turf] -= 1000
				if(!is_first_turf)
					blocked_scan_turf = TRUE
				break

		if(blocked_scan_turf)
			continue

		var/obj/structure/barricade/cade = locate() in current_scan_turf.contents
		if(cade?.density && (cade?.dir in related_cover_dirs))
			turf_dict[current_scan_turf] += cade.projectile_coverage / 2

		var/obj/item/explosive/mine/mine = locate() in current_scan_turf.contents
		if(mine)
			if(!is_owner_friendly_target(mine.iff_signal))
				turf_dict[current_scan_turf] -= 50
			else
				turf_dict[current_scan_turf] -= 5 // even if it's our mine, we don't really want to stand on it

		turf_dict[current_scan_turf] -= controller.get_distance_to(current_scan_turf)
		if(current_target) // Might be smarter to hide in a different direction
			turf_dict[current_scan_turf] += get_dist(current_target, current_scan_turf) * 0.5

			if(get_dir(current_target, current_scan_turf) in related_cover_dirs)
				turf_dict[current_scan_turf] -= 20

		for(var/cardinal in shuffle(GLOB.cardinals))
			var/turf/nearby_turf = get_step(current_scan_turf, cardinal)
			if(!nearby_turf)
				continue

			if(istype(nearby_turf, /turf/closed))
				turf_dict[current_scan_turf] += 2 // Near a wall is a bit safer
				if(cardinal in related_cover_dirs)
					turf_dict[current_scan_turf] += 8
				continue

			var/obj/structure/reagent_dispensers/fueltank/tank = locate() in nearby_turf.contents
			if(tank)
				turf_dict[current_scan_turf] -= 10 // ideally not near any highly explosive fuel tanks if we can help it

			if(!(nearby_turf in turf_dict) && !(nearby_turf in turfs_to_scan) && length(turfs_to_scan) < 198)
				turfs_to_scan += nearby_turf

#ifdef TESTING
		current_scan_turf.maptext = "<h2>[turf_dict[current_scan_turf]]</h2>"
#endif

	return TRUE

/datum/human_ai_module/cover/proc/clear_cover_value_debug(list/turf_list)
	if(QDELETED(src))
		return

	for(var/turf/T as anything in turf_list)
		T.maptext = null
