#define EXTRA_CHECK_DISTANCE_MULTIPLIER 0.20

/datum/human_ai_brain
	/// At how far out the AI can see cloaked enemies
	var/cloak_visible_range = 3
	/// Ref to the currently focused (and shooting at) target
	var/atom/movable/current_target
	/// Last turf our target was seen at
	var/turf/target_turf
	/// Ref to the last turf that the AI shot at
	var/turf/shot_at
	/// If TRUE, the AI will throw grenades at enemies who enter cover
	var/grenading_allowed = TRUE
	/// If TRUE, we care about the target being in view after shooting at them. If not, then we only do a line check instead
	var/requires_vision = TRUE

	COOLDOWN_DECLARE(fire_offscreen)
// SS220 EDIT AI - START
/// Locates a viable target within vision
/datum/human_ai_brain/proc/get_target()
	if(!has_valid_tied_human())
		return

	// Values record fire-lane checks made during this call only, never cached visibility.
	var/list/viable_targets = list()
	var/atom/movable/closest_target
	var/smallest_distance = INFINITY

	/// FOV dirs for if our target is out of base world.view range
	var/list/dir_cone
	if(scope_vision)
		dir_cone = reverse_nearby_direction(reverse_direction(tied_human.dir))

	for(var/atom/movable/potential_target in view(view_distance, tied_human))
		if(potential_target == tied_human)
			continue

		// Проверяем всех живых (включая синтетиков), технику и турели
		var/is_mob = istype(potential_target, /mob/living)
		var/is_vehicle = !is_mob && istype(potential_target, /obj/vehicle/multitile)
		var/is_defense = !is_mob && !is_vehicle && istype(potential_target, /obj/structure/machinery/defenses)

		if(!is_mob && !is_vehicle && !is_defense)
			continue

		// Reject invalid/friendly targets before facing, lighting and fire-lane scans.
		if(is_mob)
			if(!can_target(potential_target, check_fire_lane = FALSE))
				continue
		else if(is_vehicle)
			var/obj/vehicle/multitile/vehicle = potential_target
			if(vehicle.health <= 0 || faction_check(vehicle))
				continue
		else
			var/obj/structure/machinery/defenses/defense = potential_target
			if(tied_human.faction in defense.faction_group)
				continue

		var/distance = get_dist(tied_human, potential_target)

		if(scope_vision && (distance > 7) && !(get_dir(tied_human, potential_target) in dir_cone))
			continue

		if(!human_ai_can_visually_detect_target(potential_target))
			continue

		if(is_mob)
			if(!has_nightvision && (distance > 1))
				var/seen = FALSE
				for(var/turf/T in range(1, potential_target))
					if(T.luminosity || (T.dynamic_lumcount >= 1))
						seen = TRUE
						break
				if(!seen)
					continue

		var/fire_lane_checked = !is_mob
		if(distance < smallest_distance)
			if(is_mob && !path_check(potential_target))
				continue
			fire_lane_checked = TRUE
			closest_target = potential_target
			smallest_distance = distance

		// Farther candidates only need a lane check if they enter the final selection pool.
		viable_targets[potential_target] = fire_lane_checked

	var/extra_check_distance = round(smallest_distance * EXTRA_CHECK_DISTANCE_MULTIPLIER)

	if(extra_check_distance < 1 || !length(viable_targets))
		return closest_target

	var/list/final_targets = list()
	for(var/atom/movable/target as anything in viable_targets)
		if(target == closest_target)
			continue
		if(get_dist(target, closest_target) > extra_check_distance)
			continue
		if(!viable_targets[target] && !path_check(target))
			continue
		final_targets += target

	return length(final_targets) ? pick(final_targets) : closest_target

/datum/human_ai_brain/proc/can_target(mob/living/target, check_fire_lane = TRUE)
	if(!istype(target))
		return FALSE

	if(target.stat == DEAD)
		return FALSE

	if(!shoot_to_kill && (target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in target.effects_list)))
		return FALSE

	if(faction_check(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CLOAKED) && get_dist(tied_human, target) > cloak_visible_range)
		return FALSE

	if(check_fire_lane && !path_check(target))
		return FALSE

	return TRUE

/// Given a target, checks if there are any (not laying down) friendlies in a line between the AI and the target

/datum/human_ai_brain/proc/path_check(atom/target)
	var/list/turf_list = get_line(get_turf(tied_human), get_turf(target), FALSE) // SS220 EDIT AI
	//проверка на препятствия на пути пули. ИИшке незачем стрелять в стену или непростреливаемые препятсвия за исключением разрушаемых.
	for(var/turf/tile in turf_list)
		if(tile.density)
			return FALSE
		for(var/atom/movable/obstacle in tile)
			if(obstacle.density && obstacle != target && obstacle != tied_human && !istype(obstacle, /mob))
				if(istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/grille) || istype(obstacle, /obj/structure/barricade))
					continue
				return FALSE
	// get_line(..., FALSE) already excludes the shooter; keep the first adjacent turf.
	var/list/checked_turfs = list()// SS220 EDIT AI
	for(var/i in 1 to length(turf_list))
		var/turf/tile = turf_list[i]
		if(!checked_turfs[tile])
			checked_turfs[tile] = TRUE
			for(var/mob/living/carbon/human/possible_friendly in tile)
				if(possible_friendly.body_position == LYING_DOWN)
					continue
				if(faction_check(possible_friendly))
					return FALSE

		if(i <= 3)
			continue

		for(var/turf/neighbor in tile.AdjacentTurfs())
			if(checked_turfs[neighbor])
				continue
			checked_turfs[neighbor] = TRUE
			for(var/mob/living/carbon/human/possible_friendly in neighbor)
				if(possible_friendly.body_position == LYING_DOWN)
					continue
				if(faction_check(possible_friendly))
					return FALSE
	return TRUE

// SS220 EDIT AI - END

#undef EXTRA_CHECK_DISTANCE_MULTIPLIER
