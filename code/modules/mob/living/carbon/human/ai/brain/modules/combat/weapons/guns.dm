/datum/human_ai_module/guns
	module_id = "guns"
	required_module_types = list(
		/datum/human_ai_module/combat,
		/datum/human_ai_module/grenade,
		/datum/human_ai_module/inventory,
		/datum/human_ai_module/perception,
		/datum/human_ai_module/profile,
		/datum/human_ai_module/targeting,
	)

	/// If we've tried to reload (and failed) with our current inventory
	var/tried_reload = FALSE
	/// Cooldown for if we've fired too many rounds in a burst (for recoil)
	COOLDOWN_DECLARE(fire_overload_cooldown)
	/// Generic cooldown for things like shotgun pumping, bolt racking, etc. This stops us from firing for however long specified
	COOLDOWN_DECLARE(stop_fire_cooldown)
	var/rounds_burst_fired = 0
	var/currently_firing = FALSE
	var/list/watched_turfs = list()
	var/atom/watched_fire_target
	var/datum/ai_action/active_fire_action
	var/currently_reloading = FALSE
	var/datum/ai_action/active_reload_action

/datum/human_ai_module/guns/proc/has_tried_reload()
	return tried_reload

/datum/human_ai_module/guns/proc/mark_tried_reload()
	tried_reload = TRUE

/datum/human_ai_module/guns/proc/clear_tried_reload()
	tried_reload = FALSE

/datum/human_ai_module/guns/resume_module(previous_lifecycle_state)
	clear_tried_reload()
	stop_ranged_fire(TRUE)

/datum/human_ai_module/guns/proc/get_owner_primary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	return brain.get_primary_weapon()

/datum/human_ai_module/guns/proc/get_owner_gun_data()
	RETURN_TYPE(/datum/human_ai_firearm_profile)
	return brain.get_gun_data()

/datum/human_ai_module/guns/proc/has_owner_primary_weapon()
	return brain.has_primary_weapon()

/datum/human_ai_module/guns/proc/can_owner_move_for_action()
	return brain.can_move_for_action()

/datum/human_ai_module/guns/proc/has_owner_secondary_weapons()
	return brain.has_secondary_weapons()

/datum/human_ai_module/guns/proc/get_owner_short_action_delay(use_randomized_delay = FALSE)
	return brain.get_short_action_delay(use_randomized_delay)

/datum/human_ai_module/guns/proc/has_owner_current_target()
	return brain.has_current_target()

/datum/human_ai_module/guns/proc/get_owner_current_target()
	return brain.get_current_target()

/datum/human_ai_module/guns/proc/get_owner_current_target_turf()
	RETURN_TYPE(/turf)
	return brain.get_current_target_turf()

/datum/human_ai_module/guns/proc/get_owner_recent_projectile_threat_turf()
	RETURN_TYPE(/turf)
	return brain.get_recent_projectile_threat_turf()

/datum/human_ai_module/guns/proc/can_owner_fire_offscreen(turf/target_turf, datum/human_ai_firearm_profile/gun_data = null)
	return brain.can_fire_offscreen(target_turf, gun_data)

/datum/human_ai_module/guns/proc/get_owner_view_distance()
	return brain.get_view_distance()

/datum/human_ai_module/guns/proc/get_owner_fire_line_safety(atom/target, datum/human_ai_firearm_profile/gun_data = null)
	return brain.get_fire_line_safety(target, gun_data)

/datum/human_ai_module/guns/proc/is_owner_friendly_target(atom/target)
	return brain.is_friendly_target(target)

/datum/human_ai_module/guns/proc/should_owner_shoot_to_kill()
	return brain.should_shoot_to_kill()

/datum/human_ai_module/guns/proc/lose_owner_target()
	return brain.lose_target()

/datum/human_ai_module/guns/proc/set_owner_shot_at_turf(turf/target_turf)
	return brain.set_shot_at_turf(target_turf)

/datum/human_ai_module/guns/proc/set_owner_primary_weapon(obj/item/weapon/gun/primary_weapon)
	return brain.set_primary_weapon(primary_weapon)

/datum/human_ai_module/guns/proc/unqueue_owner_pickup(obj/item/item)
	return brain.unqueue_pickup(item)

/datum/human_ai_module/guns/proc/say_owner_reload_line()
	return brain.say_reload_line()

/datum/human_ai_module/guns/proc/has_owner_active_grenade()
	return brain.has_active_grenade()

/datum/human_ai_module/guns/proc/is_owner_in_cover()
	return brain.is_in_cover()

/datum/human_ai_module/guns/proc/end_owner_cover()
	return brain.end_cover()

/datum/human_ai_module/guns/proc/should_owner_block_movement_for_pending_cover()
	return brain.should_block_movement_for_pending_cover()

/datum/human_ai_module/guns/proc/move_owner_to_atom(atom/target)
	return brain.move_to_atom(target)

/datum/human_ai_module/guns/proc/move_owner_to_turf(turf/destination)
	return brain.move_to_turf(destination)

/datum/human_ai_module/guns/proc/should_owner_defer_ranged_fire(atom/threat = null)
	return brain.should_defer_ranged_fire(threat)

/datum/human_ai_module/guns/proc/is_owner_in_combat()
	return brain.is_in_combat()

/datum/human_ai_module/guns/proc/can_continue_guns_work()
	return brain.can_continue_runtime_work()

/datum/human_ai_module/guns/proc/has_valid_owner()
	return brain.has_valid_tied_human()

/datum/human_ai_module/guns/proc/should_reload()
	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	if(!primary_weapon)
		return FALSE

	// if(primary_weapon.in_chamber)
	// 	return FALSE

	// if(!primary_weapon.current_mag)
	// 	return TRUE

	// if(primary_weapon.current_mag.current_rounds > 0)
	// 	return FALSE

	// return TRUE

	return !primary_weapon.has_ammunition()	// SS220 EDIT

/datum/human_ai_module/guns/proc/can_start_fire()
	return COOLDOWN_FINISHED(src, stop_fire_cooldown)

/datum/human_ai_module/guns/proc/start_stop_fire_cooldown(cooldown)
	COOLDOWN_START(src, stop_fire_cooldown, cooldown)

/datum/human_ai_module/guns/proc/can_continue_fire_burst()
	return COOLDOWN_FINISHED(src, fire_overload_cooldown)

/datum/human_ai_module/guns/proc/start_fire_overload_cooldown()
	var/short_action_delay = get_owner_short_action_delay()
	COOLDOWN_START(src, fire_overload_cooldown, max(short_action_delay, get_owner_short_action_delay(TRUE)))

/datum/human_ai_module/guns/proc/is_currently_reloading()
	return currently_reloading

/datum/human_ai_module/guns/proc/finish_active_reload_action()
	var/datum/ai_action/reload_action = active_reload_action
	active_reload_action = null
	if(reload_action)
		qdel(reload_action)

/datum/human_ai_module/guns/proc/stop_reload(clear_active_action = FALSE)
	currently_reloading = FALSE
	if(clear_active_action)
		active_reload_action = null

/datum/human_ai_module/guns/proc/perform_reload(datum/human_tied_controller/controller, datum/ai_action/reload_action)
	if(!can_continue_guns_work() || !controller)
		return ONGOING_ACTION_COMPLETED

	if(is_currently_reloading())
		return ONGOING_ACTION_UNFINISHED

	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	if(!primary_weapon || has_tried_reload() || !should_reload())
		return ONGOING_ACTION_COMPLETED

	active_reload_action = reload_action
	start_reload(controller)
	return ONGOING_ACTION_UNFINISHED

/datum/human_ai_module/guns/proc/start_reload(datum/human_tied_controller/controller)
	set waitfor = FALSE

	if(!can_continue_guns_work() || !controller)
		return

	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	var/datum/human_ai_firearm_profile/gun_data = get_owner_gun_data()
	if(!primary_weapon || !gun_data)
		finish_active_reload_action()
		return

	if(gun_data.disposable)
		controller.drop_held_item(primary_weapon)
		unqueue_owner_pickup(primary_weapon)
		set_owner_primary_weapon(null)
		finish_active_reload_action()
		return

	currently_reloading = TRUE

	var/datum/human_ai_firearm_context/firearm_context = new(primary_weapon, brain)
	var/datum/human_ai_firearm_handler/handler = firearm_context.get_handler()
	var/obj/item/reload_item = handler?.find_reload_item(firearm_context)
	if(!reload_item)
		qdel(firearm_context)
		mark_tried_reload()
		finish_active_reload_action()
		return

	firearm_context.set_reload_item(reload_item)
	say_owner_reload_line()
	handler.do_reload(firearm_context)
	qdel(firearm_context)

	if(!can_continue_guns_work())
		return

	currently_reloading = FALSE

/datum/human_ai_module/guns/proc/is_currently_firing()
	return currently_firing

/datum/human_ai_module/guns/proc/finish_active_fire_action()
	var/datum/ai_action/fire_action = active_fire_action
	active_fire_action = null
	if(fire_action)
		qdel(fire_action)

/datum/human_ai_module/guns/proc/clear_watched_turfs()
	if(!length(watched_turfs))
		watched_fire_target = null
		return
	for(var/turf/T as anything in watched_turfs)
		UnregisterSignal(T, COMSIG_TURF_ENTERED)
	watched_turfs.Cut()
	watched_fire_target = null

/datum/human_ai_module/guns/proc/stop_ranged_fire(clear_active_action = FALSE)
	currently_firing = FALSE
	rounds_burst_fired = 0
	clear_watched_turfs()

	var/datum/human_tied_controller/controller = context?.controller
	if(controller && has_valid_owner())
		controller.unregister_signal_for(src, COMSIG_MOB_FIRED_GUN)
	get_owner_primary_weapon()?.set_target(null)
	if(clear_active_action)
		active_fire_action = null

/datum/human_ai_module/guns/proc/register_ranged_fire_callback(datum/human_tied_controller/controller, datum/ai_action/fire_action)
	if(!controller || !fire_action)
		return FALSE
	active_fire_action = fire_action
	return controller.register_signal_for(src, COMSIG_MOB_FIRED_GUN, PROC_REF(on_gun_fire), TRUE)

/datum/human_ai_module/guns/proc/get_ranged_fire_weight(datum/human_tied_controller/controller)
	if(!controller)
		return 0

	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	var/datum/human_ai_firearm_profile/gun_data = get_owner_gun_data()
	if(!can_attempt_ranged_fire(controller, primary_weapon, gun_data))
		return 0

	var/turf/target_turf = get_ranged_fire_target_turf(gun_data)
	var/atom/fire_line_target = target_turf
	var/atom/movable/current_target = get_owner_current_target()
	if(current_target && controller.get_distance_to(current_target) <= 1)
		fire_line_target = current_target
	if(!can_use_ranged_fire_line(controller, fire_line_target, gun_data))
		return 0

	var/datum/human_ai_firearm_context/firearm_context = new(primary_weapon, brain, current_target, target_turf)
	var/datum/human_ai_firearm_handler/handler = firearm_context.get_handler()
	var/can_queue_fire = handler?.can_queue_fire(firearm_context)
	qdel(firearm_context)
	if(!can_queue_fire)
		return 0

	return 10

/datum/human_ai_module/guns/proc/perform_ranged_fire(datum/human_tied_controller/controller, datum/ai_action/fire_action)
	if(!controller)
		return ONGOING_ACTION_COMPLETED

	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	var/datum/human_ai_firearm_profile/gun_data = get_owner_gun_data()
	if(!can_attempt_ranged_fire(controller, primary_weapon, gun_data, require_combat = FALSE, block_active_grenade = TRUE, check_view_distance = FALSE, check_reload = FALSE, check_tried_reload = FALSE))
		return ONGOING_ACTION_COMPLETED

	var/turf/target_turf = get_ranged_fire_target_turf(gun_data)
	var/atom/aim_target = get_ranged_fire_aim_target(controller, get_owner_current_target(), target_turf, gun_data)
	if(!aim_target)
		return ONGOING_ACTION_COMPLETED
	var/turf/aim_turf = get_turf(aim_target)
	var/should_fire_offscreen = can_owner_fire_offscreen(target_turf, gun_data)
	if(is_currently_firing() || !can_continue_fire_burst())
		return ONGOING_ACTION_UNFINISHED

	brain.unholster_primary()

	var/datum/human_ai_firearm_context/firearm_context = new(primary_weapon, brain, get_owner_current_target(), aim_turf)
	var/datum/human_ai_firearm_handler/handler = firearm_context.get_handler()
	if(!handler?.before_fire(firearm_context))
		qdel(firearm_context)
		return ONGOING_ACTION_COMPLETED
	if(should_reload())
		qdel(firearm_context)
		if(gun_data?.disposable)
			controller.drop_held_item(primary_weapon)
			set_owner_primary_weapon(null)
		return ONGOING_ACTION_COMPLETED

	if(!can_reach_ranged_fire_atom(controller, aim_target, gun_data.maximum_range) && !should_fire_offscreen)
		qdel(firearm_context)
		return ONGOING_ACTION_COMPLETED

	if(!can_use_ranged_fire_line(controller, aim_target, gun_data))
		qdel(firearm_context)
		return ONGOING_ACTION_COMPLETED

	controller.face_atom(aim_target)
	controller.set_combat_intent()

	register_ranged_fire_callback(controller, fire_action)

	var/atom/movable/current_target = get_owner_current_target()
	if(current_target && (controller.get_distance_to(current_target) <= 1))
		primary_weapon.set_target(null)
		qdel(firearm_context)
		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/human_tied_controller, do_click), current_target, "", list())
		return ONGOING_ACTION_UNFINISHED

	if(!handler.fire(firearm_context))
		qdel(firearm_context)
		return ONGOING_ACTION_COMPLETED
	var/keep_fire_action_active = handler.keeps_fire_action_active(firearm_context)
	qdel(firearm_context)
	if(!keep_fire_action_active)
		return ONGOING_ACTION_COMPLETED
	return ONGOING_ACTION_UNFINISHED

/datum/human_ai_module/guns/proc/can_use_ranged_weapon()
	return !has_tried_reload() && (has_owner_primary_weapon() || has_owner_secondary_weapons())

/datum/human_ai_module/guns/proc/get_ranged_fire_target_turf(datum/human_ai_firearm_profile/gun_data = null)
	RETURN_TYPE(/turf)
	if(has_owner_current_target())
		return get_owner_current_target_turf()

	var/turf/threat_turf = get_owner_recent_projectile_threat_turf()
	if(can_owner_fire_offscreen(threat_turf, gun_data))
		return threat_turf
	return null

/datum/human_ai_module/guns/proc/can_reach_ranged_fire_target(datum/human_tied_controller/controller, turf/target_turf, maximum_range = null, datum/human_ai_firearm_profile/gun_data = null)
	if(!controller || !target_turf)
		return FALSE
	if(can_owner_fire_offscreen(target_turf, gun_data))
		return TRUE
	if(isnull(maximum_range))
		maximum_range = get_owner_view_distance()
	return controller.get_distance_to(target_turf) <= maximum_range

/datum/human_ai_module/guns/proc/can_reach_ranged_fire_atom(datum/human_tied_controller/controller, atom/target, maximum_range = null, datum/human_ai_firearm_profile/gun_data = null)
	if(!target)
		return FALSE
	return can_reach_ranged_fire_target(controller, get_turf(target), maximum_range, gun_data)

/datum/human_ai_module/guns/proc/can_use_ranged_fire_line(datum/human_tied_controller/controller, atom/target, datum/human_ai_firearm_profile/gun_data = null, listen = FALSE)
	if(!can_continue_guns_work() || !controller || !target)
		return FALSE

	if(isliving(target) && controller.get_distance_to(target) <= 1)
		return TRUE

	var/list/turf_list = controller.get_line_from_current_turf_to(target)
	for(var/turf/tile in turf_list)
		var/tile_dist = controller.get_distance_to(tile)
		if(tile_dist > get_owner_view_distance())
			continue

		if(tile.density)
			return FALSE

		for(var/obj/thing in tile)
			if(!thing.unacidable || !thing.density)
				continue

			if((tile_dist <= 3) && (thing.projectile_coverage >= PROJECTILE_COVERAGE_HIGH))
				return FALSE
			else if((tile_dist > 3) && thing.projectile_coverage >= PROJECTILE_COVERAGE_MEDIUM)
				return FALSE

	if(get_owner_fire_line_safety(target, gun_data) == HUMAN_AI_FIRE_LINE_BLOCKED)
		return FALSE

	if(listen)
		watch_fire_line_turfs(controller, target)

	return TRUE

/datum/human_ai_module/guns/proc/watch_fire_line_turfs(datum/human_tied_controller/controller, atom/target)
	if(!controller || !target)
		return FALSE

	clear_watched_turfs()
	watched_fire_target = target

	var/list/turf_list = controller.get_line_from_current_turf_to(target)
	var/list/checked_turfs = list()
	for(var/i in 2 to length(turf_list))
		var/turf/tile = turf_list[i]
		var/tile_dist = controller.get_distance_to(tile)
		if(tile_dist > get_owner_view_distance())
			continue

		var/list/turfs_to_check = list(tile)
		if(i > 4)
			for(var/turf/neighbor in tile.AdjacentTurfs())
				turfs_to_check += neighbor

		for(var/turf/T as anything in turfs_to_check)
			if(checked_turfs[T])
				continue
			checked_turfs[T] = TRUE

			RegisterSignal(T, COMSIG_TURF_ENTERED, PROC_REF(cheap_friendly_check))
			watched_turfs += T

	return TRUE

/datum/human_ai_module/guns/proc/cheap_friendly_check(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	var/datum/human_tied_controller/controller = context?.controller
	if(!can_continue_guns_work() || !controller)
		return
	if(controller.is_puppet(entering))
		return

	if(!istype(entering, /mob/living))
		return

	var/mob/living/possible_friendly = entering
	if(!is_owner_friendly_target(possible_friendly))
		return

	if(get_owner_fire_line_safety(watched_fire_target || get_ranged_fire_target_turf(get_owner_gun_data()), get_owner_gun_data()) == HUMAN_AI_FIRE_LINE_BLOCKED)
		stop_ranged_fire()
		finish_active_fire_action()

/datum/human_ai_module/guns/proc/get_ranged_fire_aim_target(datum/human_tied_controller/controller, atom/movable/current_target, turf/target_turf, datum/human_ai_firearm_profile/gun_data = null)
	RETURN_TYPE(/atom)
	if(!target_turf)
		return null
	if(!controller || !gun_data?.aim_adjacent_to_human_targets || !ishuman(current_target))
		return current_target || target_turf

	var/roll = rand(1, 100)
	if(roll <= gun_data.direct_human_target_chance)
		return current_target

	var/list/safe_turfs = get_safe_adjacent_human_aim_turfs(controller, target_turf)
	var/list/miss_turfs = get_miss_adjacent_human_aim_turfs(target_turf, safe_turfs)
	var/safe_roll_limit = gun_data.direct_human_target_chance + gun_data.safe_human_adjacent_target_chance
	var/miss_roll_limit = safe_roll_limit + gun_data.miss_human_adjacent_target_chance

	if(roll <= safe_roll_limit)
		if(length(safe_turfs))
			return pick(safe_turfs)
		if(length(miss_turfs))
			return pick(miss_turfs)

	else if(roll <= miss_roll_limit)
		if(length(miss_turfs))
			return pick(miss_turfs)
		if(length(safe_turfs))
			return pick(safe_turfs)

	else
		if(length(safe_turfs))
			return pick(safe_turfs)
		if(length(miss_turfs))
			return pick(miss_turfs)

	return target_turf

/datum/human_ai_module/guns/proc/get_safe_adjacent_human_aim_turfs(datum/human_tied_controller/controller, turf/target_turf)
	var/list/diagonal_candidates = list()
	var/list/safe_turfs = list()
	if(!controller || !target_turf)
		return safe_turfs

	var/target_distance = controller.get_distance_to(target_turf)
	for(var/direction in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		var/turf/candidate = get_step(target_turf, direction)
		if(!candidate || candidate.z != target_turf.z)
			continue
		if(controller.get_distance_to(candidate) >= target_distance)
			continue
		diagonal_candidates += candidate

	while(length(diagonal_candidates) && length(safe_turfs) < 2)
		var/best_index
		var/best_distance = INFINITY
		for(var/i in 1 to length(diagonal_candidates))
			var/turf/candidate = diagonal_candidates[i]
			var/candidate_distance = controller.get_distance_to(candidate)
			if(candidate_distance >= best_distance)
				continue
			best_index = i
			best_distance = candidate_distance
		if(isnull(best_index))
			break
		safe_turfs += diagonal_candidates[best_index]
		diagonal_candidates.Cut(best_index, best_index + 1)

	return safe_turfs

/datum/human_ai_module/guns/proc/get_miss_adjacent_human_aim_turfs(turf/target_turf, list/safe_turfs)
	var/list/miss_turfs = list()
	if(!target_turf)
		return miss_turfs

	for(var/direction in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST, NORTH, SOUTH, EAST, WEST))
		var/turf/candidate = get_step(target_turf, direction)
		if(!candidate || candidate.z != target_turf.z)
			continue
		if((candidate in safe_turfs) || (candidate in miss_turfs))
			continue
		miss_turfs += candidate

	return miss_turfs

/datum/human_ai_module/guns/proc/should_block_ranged_fire_for_throwable()
	return has_owner_active_grenade()

/datum/human_ai_module/guns/proc/should_defer_ranged_fire_target(atom/threat = null)
	return should_owner_defer_ranged_fire(threat)

/datum/human_ai_module/guns/proc/should_defer_current_ranged_fire(datum/human_ai_firearm_profile/gun_data = null)
	return should_defer_ranged_fire_target(get_owner_current_target() || get_ranged_fire_target_turf(gun_data))

/datum/human_ai_module/guns/proc/perform_keep_distance(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	if(!has_owner_current_target())
		return ONGOING_ACTION_COMPLETED

	if(!has_owner_primary_weapon())
		return ONGOING_ACTION_COMPLETED

	if(has_owner_active_grenade())
		return ONGOING_ACTION_COMPLETED

	if(should_owner_block_movement_for_pending_cover())
		return ONGOING_ACTION_COMPLETED

	return approach_keep_distance(controller) || back_up_keep_distance(controller) || ONGOING_ACTION_COMPLETED

/datum/human_ai_module/guns/proc/get_keep_distance_range(atom/movable/current_target, datum/human_ai_firearm_profile/gun_data, use_minimum_for_cover = FALSE)
	if(ismob(current_target))
		var/mob/current_mob_target = current_target
		if(current_mob_target.is_mob_incapacitated())
			return gun_data.minimum_range
	if(use_minimum_for_cover && is_owner_in_cover())
		return gun_data.minimum_range
	return gun_data.optimal_range

/datum/human_ai_module/guns/proc/approach_keep_distance(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/atom/movable/current_target = get_owner_current_target()
	var/datum/human_ai_firearm_profile/gun_data = get_owner_gun_data()
	if(!current_target || !gun_data)
		return ONGOING_ACTION_COMPLETED

	var/range = get_keep_distance_range(current_target, gun_data)
	var/can_fire_from_position = can_use_ranged_fire_line(controller, current_target, gun_data)
	if(controller.get_distance_to(current_target) <= range)
		if(!is_owner_in_cover() || can_fire_from_position)
			return

	if(is_owner_in_cover())
		if(can_fire_from_position)
			return ONGOING_ACTION_UNFINISHED
		end_owner_cover()

	if(!move_owner_to_atom(current_target))
		return ONGOING_ACTION_COMPLETED

	return ONGOING_ACTION_UNFINISHED

/datum/human_ai_module/guns/proc/back_up_keep_distance(datum/human_tied_controller/controller)
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/atom/movable/current_target = get_owner_current_target()
	var/datum/human_ai_firearm_profile/gun_data = get_owner_gun_data()
	if(!current_target || !gun_data)
		return ONGOING_ACTION_COMPLETED

	var/range = get_keep_distance_range(current_target, gun_data, TRUE)
	if(controller.get_distance_to(current_target) >= range)
		return

	var/moved = FALSE
	var/relative_dir = controller.get_compass_dir_from(current_target)
	for(var/direction in list(relative_dir, turn(relative_dir, 90), turn(relative_dir, -90)))
		var/turf/destination = controller.get_step_in_dir(direction)
		if(move_owner_to_turf(destination))
			moved = TRUE
			break

	if(!moved)
		return ONGOING_ACTION_COMPLETED

	return ONGOING_ACTION_UNFINISHED

/datum/human_ai_module/guns/proc/on_gun_fire(datum/source, obj/item/weapon/gun/fired)
	SIGNAL_HANDLER

	var/datum/human_tied_controller/controller = context?.controller
	if(!can_continue_guns_work() || !controller)
		finish_active_fire_action()
		return

	var/datum/human_ai_firearm_profile/gun_data = get_owner_gun_data()
	var/turf/target_turf = get_ranged_fire_target_turf(gun_data)
	if(!target_turf)
		stop_ranged_fire()
		finish_active_fire_action()
		return

	controller.set_combat_intent()

	set_owner_shot_at_turf(target_turf)
	controller.face_atom(target_turf)

	currently_firing = TRUE

	if(should_reload())
		if(gun_data?.disposable)
			var/obj/item/weapon/gun/current_primary_weapon = get_owner_primary_weapon()
			if(current_primary_weapon)
				controller.drop_held_item(current_primary_weapon)
			set_owner_primary_weapon(null)
		stop_ranged_fire()
		finish_active_fire_action()
		return

	var/should_fire_offscreen = can_owner_fire_offscreen(target_turf, gun_data)
	var/atom/movable/current_target = get_owner_current_target()
	var/shoot_next = current_target

	if(QDELETED(current_target))
		if(!should_fire_offscreen)
			stop_ranged_fire()
			finish_active_fire_action()
			return
		shoot_next = target_turf

	else if(ismob(current_target))
		var/mob/mob_target = current_target
		if(mob_target.stat == DEAD)
			stop_ranged_fire()
			lose_owner_target()
			finish_active_fire_action()
			return

		var/is_unconscious = (mob_target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in mob_target.effects_list))
		if(!should_owner_shoot_to_kill() && is_unconscious)
			lose_owner_target()
			finish_active_fire_action()
			return

	if(should_defer_ranged_fire_target(shoot_next))
		stop_ranged_fire()
		finish_active_fire_action()
		return

	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	if(!primary_weapon || !gun_data)
		stop_ranged_fire()
		finish_active_fire_action()
		return
	var/count_shot_against_burst_limit = ((primary_weapon.gun_firemode == GUN_FIREMODE_AUTOMATIC) || gun_data.count_every_shot_toward_burst_limit)
	if(count_shot_against_burst_limit)
		rounds_burst_fired++

	if(rounds_burst_fired >= gun_data.burst_amount_max)
		start_fire_overload_cooldown()
		stop_ranged_fire()
		return

	current_target = get_owner_current_target()
	if(current_target && (controller.get_distance_to(current_target) <= 1))
		currently_firing = FALSE
		return

	shoot_next = get_ranged_fire_aim_target(controller, current_target, target_turf, gun_data)
	if(!shoot_next)
		stop_ranged_fire()
		finish_active_fire_action()
		return

	if(!can_reach_ranged_fire_atom(controller, shoot_next, gun_data.maximum_range, gun_data) && !should_fire_offscreen)
		lose_owner_target()
		stop_ranged_fire()
		finish_active_fire_action()
		return

	if(!can_use_ranged_fire_line(controller, shoot_next, gun_data, listen = TRUE))
		stop_ranged_fire()
		finish_active_fire_action()
		return

	var/turf/shoot_turf = get_turf(shoot_next)

	var/datum/human_ai_firearm_context/firearm_context = new(primary_weapon, brain, current_target, shoot_turf)
	var/datum/human_ai_firearm_handler/handler = firearm_context.get_handler()
	var/datum/human_ai_firearm_result/after_fire_result = handler?.after_fire(firearm_context)
	qdel(firearm_context)
	if(after_fire_result)
		if(after_fire_result.callback)
			addtimer(after_fire_result.callback, after_fire_result.callback_delay)
		if(after_fire_result.cooldown)
			start_stop_fire_cooldown(after_fire_result.cooldown)
		if(after_fire_result.interrupt_burst)
			rounds_burst_fired = 0
		if(after_fire_result.stop_fire)
			currently_firing = FALSE
			stop_ranged_fire()
		if(after_fire_result.handled)
			return

	if(primary_weapon.gun_firemode == GUN_FIREMODE_SEMIAUTO)
		currently_firing = FALSE
		addtimer(CALLBACK(src, PROC_REF(delayed_start_fire), primary_weapon, shoot_next), primary_weapon.get_fire_delay())

	else if(primary_weapon.gun_firemode == GUN_FIREMODE_BURSTFIRE)
		currently_firing = FALSE
		addtimer(CALLBACK(src, PROC_REF(delayed_start_fire), primary_weapon, shoot_next), primary_weapon.get_burst_fire_delay())

	primary_weapon?.set_target(shoot_next)

/datum/human_ai_module/guns/proc/delayed_start_fire(obj/item/weapon/gun/primary_weapon, atom/current_target)
	if(!can_continue_guns_work() || QDELETED(primary_weapon))
		return FALSE
	primary_weapon.start_fire(null, current_target, null, null, null, TRUE)
	return TRUE

/datum/human_ai_module/guns/proc/can_attempt_ranged_fire(datum/human_tied_controller/controller, obj/item/weapon/gun/primary_weapon, datum/human_ai_firearm_profile/gun_data = null, require_combat = TRUE, block_active_grenade = FALSE, check_view_distance = TRUE, check_reload = TRUE, check_tried_reload = TRUE)
	if(!has_valid_owner())
		return FALSE
	if(require_combat && !is_owner_in_combat())
		return FALSE
	if(check_tried_reload && has_tried_reload())
		return FALSE
	if(!primary_weapon)
		return FALSE
	if(block_active_grenade && should_block_ranged_fire_for_throwable())
		return FALSE
	if(!can_start_fire())
		return FALSE

	var/turf/target_turf = get_ranged_fire_target_turf(gun_data)
	if(!target_turf)
		return FALSE
	if(check_view_distance && !can_reach_ranged_fire_target(controller, target_turf, get_owner_view_distance(), gun_data))
		return FALSE
	if(should_defer_current_ranged_fire(gun_data))
		return FALSE
	if(check_reload && should_reload())
		return FALSE
	return TRUE
