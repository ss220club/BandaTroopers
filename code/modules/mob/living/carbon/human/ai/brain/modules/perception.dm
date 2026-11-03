/datum/human_ai_module/perception
	module_id = "perception"
	required_module_types = list(/datum/human_ai_module/faction, /datum/human_ai_module/profile)

	/// Nearby turfs that we're watching for bullets
	var/list/detection_turfs = list()
	/// Prevent repeated projectile detection re-entry in the same tick
	var/atom/movable/last_detected_projectile
	var/last_detected_projectile_time = -1
	/// Recent hostile projectile source remembered for offscreen response.
	var/atom/movable/recent_threat_source
	/// Recent hostile projectile source turf remembered for offscreen response.
	var/turf/recent_threat_turf
	/// Recent projectile angle remembered for cover response.
	var/recent_threat_angle

	COOLDOWN_DECLARE(threat_memory)

/datum/human_ai_module/perception/Destroy(force, ...)
	unregister_signals()
	clear_detection_radius()

	return ..()

/datum/human_ai_module/perception/process_module(delta_time)
	if(!can_process_detection())
		clear_detection_radius()
		return

	if(!length(detection_turfs))
		setup_detection_radius()

/datum/human_ai_module/perception/on_ai_event(datum/human_ai_event/event)
	if(event.event_type == HUMAN_AI_EVENT_MOVED)
		on_moved(event.get_old_location(), event.get_direction(), event.was_forced_move())

/datum/human_ai_module/perception/on_moved(atom/oldloc, direction, forced)
	setup_detection_radius()

/datum/human_ai_module/perception/proc/suspend()
	clear_detection_radius()

/datum/human_ai_module/perception/reset_module()
	reset_detection()

/datum/human_ai_module/perception/suspend_module(clear_inventory = FALSE)
	suspend()

/datum/human_ai_module/perception/proc/register_signals()
	if(!has_valid_owner())
		return
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	controller.register_signal_for(src, COMSIG_HUMAN_BULLET_ACT, PROC_REF(on_shot))

/datum/human_ai_module/perception/proc/unregister_signals()
	var/datum/human_tied_controller/controller = context?.controller
	if(controller)
		controller.unregister_signal_for(src, COMSIG_HUMAN_BULLET_ACT)

/datum/human_ai_module/perception/proc/setup_detection_radius()
	if(!has_valid_owner())
		clear_detection_radius()
		return

	if(length(detection_turfs))
		clear_detection_radius()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return

	for(var/turf/open/floor in controller.get_range(1))
		RegisterSignal(floor, COMSIG_TURF_ENTERED, PROC_REF(on_detection_turf_enter))
		detection_turfs += floor

/datum/human_ai_module/perception/proc/clear_detection_radius()
	for(var/turf/open/floor as anything in detection_turfs)
		UnregisterSignal(floor, COMSIG_TURF_ENTERED)

	detection_turfs.Cut()

/datum/human_ai_module/perception/proc/reset_detection()
	clear_detection_radius()
	last_detected_projectile = null
	last_detected_projectile_time = -1
	clear_recent_threat()

/datum/human_ai_module/perception/proc/on_detection_turf_enter(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	if(!can_process_detection())
		return

	var/datum/human_tied_controller/controller = context?.controller
	if(!controller || controller.is_puppet(entering))
		return

	if(!istype(entering, /obj/projectile))
		return

	var/obj/projectile/bullet = entering
	if(is_projectile_debounced(bullet))
		return

	remember_projectile(bullet)

	if(!bullet.firer)
		return

	remember_projectile_threat(bullet)
	emit_owner_projectile_threat(bullet, FALSE)

/datum/human_ai_module/perception/proc/on_shot(datum/source, damage_result, ammo_flags, obj/projectile/bullet)
	SIGNAL_HANDLER

	if(!can_process_detection())
		return

	if(!bullet || !bullet.firer)
		return

	remember_projectile_threat(bullet)
	emit_owner_projectile_threat(bullet, TRUE)

/datum/human_ai_module/perception/proc/can_process_detection()
	return brain?.can_continue_runtime_work()

/datum/human_ai_module/perception/proc/emit_owner_projectile_threat(obj/projectile/bullet, from_direct_hit = FALSE)
	return brain.emit_projectile_threat(bullet, from_direct_hit, get_recent_threat_source(), get_recent_threat_turf(), get_recent_threat_angle())

/datum/human_ai_module/perception/proc/is_owner_friendly_target(atom/target)
	return brain.is_friendly_target(target)

/datum/human_ai_module/perception/proc/get_owner_view_distance()
	return brain.get_view_distance()

/datum/human_ai_module/perception/proc/has_owner_scope_vision()
	return brain.has_scope_vision()

/datum/human_ai_module/perception/proc/get_owner_targeting_view_distance()
	return brain.get_targeting_view_distance()

/datum/human_ai_module/perception/proc/should_owner_shoot_to_kill()
	return brain.should_shoot_to_kill()

/datum/human_ai_module/perception/proc/can_owner_ignore_target_darkness()
	return brain.can_ignore_target_darkness()

/datum/human_ai_module/perception/proc/is_projectile_debounced(obj/projectile/bullet)
	return (last_detected_projectile == bullet) && (last_detected_projectile_time == world.time)

/datum/human_ai_module/perception/proc/remember_projectile(obj/projectile/bullet)
	last_detected_projectile = bullet
	last_detected_projectile_time = world.time

/datum/human_ai_module/perception/proc/remember_projectile_threat(obj/projectile/bullet, duration = 4 SECONDS)
	if(!bullet?.firer)
		return FALSE
	var/atom/movable/firer = bullet.firer
	if(!can_remember_threat_source(firer))
		return FALSE
	var/turf/firer_turf = get_turf(firer)
	if(!firer_turf)
		return FALSE

	recent_threat_source = firer
	recent_threat_turf = firer_turf
	recent_threat_angle = bullet.angle
	COOLDOWN_START(src, threat_memory, duration)
	return TRUE

/datum/human_ai_module/perception/proc/clear_recent_threat()
	recent_threat_source = null
	recent_threat_turf = null
	recent_threat_angle = null

/datum/human_ai_module/perception/proc/has_recent_threat()
	return recent_threat_turf && !COOLDOWN_FINISHED(src, threat_memory)

/datum/human_ai_module/perception/proc/get_recent_threat_turf()
	RETURN_TYPE(/turf)
	if(!has_recent_threat())
		return null
	return recent_threat_turf

/datum/human_ai_module/perception/proc/get_recent_threat_source()
	RETURN_TYPE(/atom/movable)
	if(!has_recent_threat())
		return null
	return recent_threat_source

/datum/human_ai_module/perception/proc/get_recent_threat_angle()
	if(!has_recent_threat())
		return null
	return recent_threat_angle

/datum/human_ai_module/perception/proc/clear_projectile_threat()
	clear_recent_threat()

/datum/human_ai_module/perception/proc/has_recent_projectile_threat()
	return has_recent_threat()

/datum/human_ai_module/perception/proc/get_recent_projectile_threat_turf()
	RETURN_TYPE(/turf)
	return get_recent_threat_turf()

/datum/human_ai_module/perception/proc/get_recent_projectile_threat_source()
	RETURN_TYPE(/atom/movable)
	return get_recent_threat_source()

/datum/human_ai_module/perception/proc/get_recent_projectile_threat_angle()
	return get_recent_threat_angle()

/datum/human_ai_module/perception/proc/can_fire_offscreen(turf/target_turf, datum/human_ai_firearm_profile/gun_data = null)
	if(!target_turf || !has_recent_projectile_threat())
		return FALSE
	if(get_recent_projectile_threat_turf() != target_turf)
		return FALSE
	var/atom/movable/threat_source = get_recent_projectile_threat_source()
	if(threat_source && !QDELETED(threat_source) && is_owner_friendly_target(threat_source))
		return FALSE
	if(!gun_data)
		return TRUE
	return gun_data.maximum_range > get_owner_view_distance()

/datum/human_ai_module/perception/proc/can_remember_projectile_threat_source(atom/movable/source)
	return can_remember_threat_source(source)

/datum/human_ai_module/perception/proc/can_remember_threat_source(atom/movable/source)
	if(!has_valid_owner())
		return FALSE
	if(!is_valid_target_ref(source))
		return FALSE
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller || controller.is_puppet(source))
		return FALSE
	return TRUE

/datum/human_ai_module/perception/proc/get_visible_target_candidates()
	if(!has_valid_owner())
		return list()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return list()

	var/list/viable_targets = list()
	var/list/dir_cone
	var/rear_view_penalty = 0

	if(has_owner_scope_vision())
		dir_cone = controller.get_reverse_dir_cone()
		rear_view_penalty = get_owner_targeting_view_distance() / 7 - 1

	for(var/atom/movable/potential_target in controller.get_view(get_owner_targeting_view_distance()))
		if(controller.is_puppet(potential_target))
			continue

		var/distance = controller.get_distance_to(potential_target)

		if(!can_acquire_from_direction(potential_target, distance, dir_cone, rear_view_penalty))
			continue

		if(!can_target(potential_target))
			continue

		viable_targets += potential_target

	return viable_targets

/datum/human_ai_module/perception/proc/can_acquire_from_direction(atom/movable/target, distance, list/dir_cone, rear_view_penalty)
	if(!has_valid_owner())
		return FALSE
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return FALSE

	if(!is_valid_target_ref(target))
		return FALSE

	if(!has_owner_scope_vision())
		return TRUE

	if((distance > 7) && !(controller.get_direction_to(target) in dir_cone))
		return FALSE

	if(istype(target, /mob/living))
		var/rear_view_check = (controller.get_direction_to(target) in controller.get_reverse_dir_cone())
		if(rear_view_check && (distance > get_owner_targeting_view_distance() - rear_view_penalty))
			return FALSE

	return TRUE

/datum/human_ai_module/perception/proc/can_target(atom/movable/target)
	if(!has_valid_owner())
		return FALSE

	if(!is_valid_target_ref(target))
		return FALSE

	if(istype(target, /mob/living))
		return can_target_mob(target)

	if(istype(target, /obj/vehicle/multitile))
		return can_target_vehicle(target)

	if(istype(target, /obj/structure/machinery/defenses))
		return can_target_defense(target)

	return FALSE

/datum/human_ai_module/perception/proc/can_target_defense(obj/structure/machinery/defenses/defense)
	if(!can_consider_defense_target(defense))
		return FALSE

	if(!can_engage_target(defense))
		return FALSE

	return has_safe_line_to_target(defense)

/datum/human_ai_module/perception/proc/can_consider_defense_target(obj/structure/machinery/defenses/defense)
	if(!istype(defense))
		return FALSE

	if(defense.stat & DEFENSE_DESTROYED)
		return FALSE

	return TRUE

/datum/human_ai_module/perception/proc/can_target_vehicle(obj/vehicle/multitile/vehicle)
	if(!can_consider_vehicle_target(vehicle))
		return FALSE

	if(!can_engage_target(vehicle))
		return FALSE

	return has_safe_line_to_target(vehicle)

/datum/human_ai_module/perception/proc/can_consider_vehicle_target(obj/vehicle/multitile/vehicle)
	if(!istype(vehicle))
		return FALSE

	if(vehicle.health <= 0)
		return FALSE

	return TRUE

/datum/human_ai_module/perception/proc/can_target_mob(mob/living/target)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return FALSE

	if(!can_consider_living_target(target))
		return FALSE

	if(!can_engage_target(target))
		return FALSE

	var/distance = controller.get_distance_to(target)
	if(!can_detect_mob_target(target, distance))
		return FALSE

	if(distance <= 1)
		return TRUE

	if(!has_safe_line_to_target(target))
		return FALSE

	return TRUE

/datum/human_ai_module/perception/proc/can_consider_living_target(mob/living/target)
	if(!istype(target))
		return FALSE

	if(target.stat == DEAD)
		return FALSE

	if(!should_owner_shoot_to_kill() && (target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in target.effects_list)))
		return FALSE

	return TRUE

/datum/human_ai_module/perception/proc/can_engage_target(atom/movable/target)
	return !is_owner_friendly_target(target)

/datum/human_ai_module/perception/proc/can_detect_mob_target(mob/living/target, distance)
	if(!can_owner_ignore_target_darkness() && distance > 1 && !has_lit_turf_near_living_target(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CLOAKED) && distance > get_cloak_visible_range())
		return FALSE

	return TRUE

/datum/human_ai_module/perception/proc/has_lit_turf_near_living_target(mob/living/target)
	for(var/turf/tile in range(1, target))
		if(tile.luminosity || (tile.dynamic_lumcount >= 1))
			return TRUE

	return FALSE

/datum/human_ai_module/perception/proc/has_safe_line_to_target(atom/target)
	return get_fire_line_safety(target) != HUMAN_AI_FIRE_LINE_BLOCKED

/datum/human_ai_module/perception/proc/get_fire_line_safety(atom/target, datum/human_ai_firearm_profile/gun_data = null)
	if(!has_valid_owner())
		return HUMAN_AI_FIRE_LINE_BLOCKED
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return HUMAN_AI_FIRE_LINE_BLOCKED

	if(!is_valid_target_ref(target))
		return HUMAN_AI_FIRE_LINE_BLOCKED

	var/turf/source_turf = controller.get_current_turf()
	var/turf/target_turf = get_turf(target)
	if(!source_turf || !target_turf)
		return HUMAN_AI_FIRE_LINE_BLOCKED

	var/list/turf_list = get_line(source_turf, target_turf, FALSE)
	if(!has_clear_target_line(turf_list, target, controller))
		return HUMAN_AI_FIRE_LINE_BLOCKED

	var/fire_line_safety = get_friendly_fire_line_safety(turf_list, target_turf)
	if((fire_line_safety == HUMAN_AI_FIRE_LINE_CAUTION) && gun_data?.block_cautious_fire_line)
		return HUMAN_AI_FIRE_LINE_BLOCKED
	return fire_line_safety

/datum/human_ai_module/perception/proc/has_clear_target_line(list/turf_list, atom/target, datum/human_tied_controller/controller)
	for(var/turf/tile in turf_list)
		if(tile.density)
			return FALSE
		for(var/atom/movable/obstacle in tile)
			if(obstacle.density && obstacle != target && !controller.is_puppet(obstacle) && !istype(obstacle, /mob))
				if(istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/grille) || istype(obstacle, /obj/structure/barricade))
					continue
				return FALSE
	return TRUE

/datum/human_ai_module/perception/proc/get_friendly_fire_line_safety(list/turf_list, turf/target_turf)
	var/list/checked_turfs = list()
	var/fire_line_safety = HUMAN_AI_FIRE_LINE_CLEAR
	for(var/i in 1 to length(turf_list))
		var/turf/tile = turf_list[i]
		if(!checked_turfs[tile])
			checked_turfs[tile] = TRUE
			if(has_blocking_friendly_on_direct_fire_turf(tile, target_turf))
				return HUMAN_AI_FIRE_LINE_BLOCKED

		if(i <= 3)
			continue

		for(var/turf/neighbor in tile.AdjacentTurfs())
			if(checked_turfs[neighbor])
				continue
			checked_turfs[neighbor] = TRUE
			if(has_standing_friendly_on_fire_turf(neighbor))
				fire_line_safety = HUMAN_AI_FIRE_LINE_CAUTION
	return fire_line_safety

/datum/human_ai_module/perception/proc/has_blocking_friendly_on_direct_fire_turf(turf/tile, turf/target_turf)
	for(var/mob/living/carbon/human/possible_friendly in tile)
		if(!is_owner_friendly_target(possible_friendly))
			continue
		if(tile == target_turf)
			return TRUE
		if(possible_friendly.body_position != LYING_DOWN)
			return TRUE
	return FALSE

/datum/human_ai_module/perception/proc/has_standing_friendly_on_fire_turf(turf/tile)
	for(var/mob/living/carbon/human/possible_friendly in tile)
		if(possible_friendly.body_position == LYING_DOWN)
			continue
		if(is_owner_friendly_target(possible_friendly))
			return TRUE
	return FALSE

/datum/human_ai_module/perception/proc/get_cloak_visible_range()
	return 3

/datum/human_ai_module/perception/proc/has_valid_owner()
	return brain && brain.has_valid_tied_human()

/datum/human_ai_module/perception/proc/is_valid_target_ref(atom/target)
	return target && !QDELETED(target)
