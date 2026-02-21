#define EXTRA_CHECK_DISTANCE_MULTIPLIER 0.20
#define PATH_CHECK_NEIGHBOR_START 4
#define FIRING_LINE_NEIGHBOR_START 5
#define FIRING_LINE_SHORT_RANGE_MAX 3

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

	var/list/watched_turfs = list()

	COOLDOWN_DECLARE(fire_offscreen)
// SS220 EDIT AI - START
/// Locates a viable target within vision
/datum/human_ai_brain/proc/get_target()
	var/list/viable_targets = list()
	var/atom/movable/closest_target
	var/smallest_distance = INFINITY

	/// FOV dirs for if our target is out of base world.view range
	var/list/dir_cone
	var/list/rear_dirs
	var/rear_view_penalty = 0
	if(scope_vision)
		dir_cone = reverse_nearby_direction(reverse_direction(tied_human.dir))
		rear_dirs = reverse_nearby_direction(tied_human.dir)
		rear_view_penalty = view_distance / 7 - 1

	for(var/atom/movable/potential_target in view(view_distance, tied_human))
		if(potential_target == tied_human)
			continue

		// Проверяем всех живых (включая синтетиков), технику и турели
		var/is_mob = istype(potential_target, /mob/living)
		var/is_vehicle = !is_mob && istype(potential_target, /obj/vehicle/multitile)
		var/is_defense = !is_mob && !is_vehicle && istype(potential_target, /obj/structure/machinery/defenses)

		if(!is_mob && !is_vehicle && !is_defense)
			continue

		var/distance = get_dist(tied_human, potential_target)

		if(scope_vision && (distance > 7) && !(get_dir(tied_human, potential_target) in dir_cone))
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

			var/rear_view_check = scope_vision && (get_dir(tied_human, potential_target) in rear_dirs)
			if(rear_view_check && (distance > view_distance - rear_view_penalty))
				continue

			if(!can_target(potential_target))
				continue

		else if(is_vehicle)
			var/obj/vehicle/multitile/vehicle = potential_target
			if(vehicle.health <= 0)
				continue
			if(faction_check(vehicle))
				continue

		else if(is_defense)
			var/obj/structure/machinery/defenses/defense = potential_target
			if(tied_human.faction in defense.faction_group)
				continue

		viable_targets += potential_target

		if(smallest_distance <= distance)
			continue

		closest_target = potential_target
		smallest_distance = distance

	var/extra_check_distance = round(smallest_distance * EXTRA_CHECK_DISTANCE_MULTIPLIER)

	if(extra_check_distance < 1 || !length(viable_targets))
		return closest_target

	var/list/final_targets = list()
	for(var/atom/movable/target as anything in viable_targets)
		if(target == closest_target)
			continue
		if(get_dist(target, closest_target) <= extra_check_distance)
			final_targets += target

	return length(final_targets) ? pick(final_targets) : closest_target

/datum/human_ai_brain/proc/can_target(mob/living/target)
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

	if(!path_check(target))
		return FALSE

	return TRUE

/// Given a target, checks if there are any (not laying down) friendlies in a line between the AI and the target

/datum/human_ai_brain/proc/should_ignore_path_obstacle(atom/movable/obstacle, atom/target)
	if(!obstacle.density || obstacle == target || obstacle == tied_human || istype(obstacle, /mob))
		return TRUE

	if(istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/grille) || istype(obstacle, /obj/structure/barricade))
		return TRUE

	return FALSE

/datum/human_ai_brain/proc/is_blocking_friendly(mob/living/possible_friendly, mob/living/excluded = null, datum/human_ai_brain/brain_override = null)
	if(possible_friendly == excluded)
		return FALSE

	if(possible_friendly.body_position == LYING_DOWN)
		return FALSE

	if(brain_override)
		return brain_override.faction_check(possible_friendly)

	return faction_check(possible_friendly)

/datum/human_ai_brain/proc/turf_has_blocking_friendly(turf/T, mob/living/excluded = null, datum/human_ai_brain/brain_override = null, human_only = FALSE)
	if(human_only)
		for(var/mob/living/carbon/human/possible_friendly in T)
			if(is_blocking_friendly(possible_friendly, excluded, brain_override))
				return TRUE
	else
		for(var/mob/living/possible_friendly in T)
			if(is_blocking_friendly(possible_friendly, excluded, brain_override))
				return TRUE

	return FALSE

/datum/human_ai_brain/proc/register_and_check_turf(turf/T, list/checked_turfs, listen = FALSE, mob/living/excluded = null, datum/human_ai_brain/brain_override = null, human_only = FALSE)
	if(checked_turfs[T])
		return FALSE

	checked_turfs[T] = TRUE
	if(listen)
		add_turf_to_watch(T)

	return turf_has_blocking_friendly(T, excluded, brain_override, human_only)

/datum/human_ai_brain/proc/path_check(atom/target)
	var/list/turf_list = get_line(get_turf(tied_human), get_turf(target), FALSE) // SS220 EDIT AI

	//проверка на препятствия на пути пули. ИИшке незачем стрелять в стену или непростреливаемые препятсвия за исключением разрушаемых.
	for(var/turf/tile in turf_list)
		if(tile.density)
			return FALSE
		for(var/atom/movable/obstacle in tile)
			if(!should_ignore_path_obstacle(obstacle, target))
				return FALSE

	//модифицируем список для проверки на союзников, добавляя соседние тайлы и уберая тайл стрелка.
	turf_list.Cut(1, 2) // starting turf
	var/list/checked_turfs = list()// SS220 EDIT AI
	for(var/i in 1 to length(turf_list))
		var/turf/tile = turf_list[i]
		if(register_and_check_turf(tile, checked_turfs, FALSE, null, null, TRUE))
			return FALSE

		if(i < PATH_CHECK_NEIGHBOR_START)
			continue

		for(var/turf/neighbor in tile.AdjacentTurfs())
			if(register_and_check_turf(neighbor, checked_turfs, FALSE, null, null, TRUE))
				return FALSE
	return TRUE

/datum/human_ai_brain/proc/firing_line_check(datum/human_ai_brain/brain, atom/target, listen = FALSE)
	var/mob/living/carbon/tied_human = brain.tied_human
	var/list/turf_list = get_line(get_turf(tied_human), get_turf(target))
	for(var/turf/tile in turf_list)
		var/tile_dist = get_dist(tied_human, tile)
		if(tile_dist > brain.view_distance)
			continue

		if(tile.density)
			return FALSE

		for(var/obj/thing in tile)
			if(!thing.unacidable || !thing.density)
				continue

			if((tile_dist <= FIRING_LINE_SHORT_RANGE_MAX) && (thing.projectile_coverage >= PROJECTILE_COVERAGE_HIGH)) // short range we allow for higher projectile coverage to be shot over
				return FALSE
			else if((tile_dist > FIRING_LINE_SHORT_RANGE_MAX) && thing.projectile_coverage >= PROJECTILE_COVERAGE_MEDIUM)
				return FALSE

	if(listen)
		clear_watched_turfs()

	var/list/checked_turfs = list()
	for(var/i in 2 to length(turf_list))
		var/turf/tile = turf_list[i]
		var/tile_dist = get_dist(tied_human, tile)
		if(tile_dist > brain.view_distance)
			continue

		var/list/turfs_to_check = list(tile)
		if(i >= FIRING_LINE_NEIGHBOR_START)
			for(var/turf/neighbor in tile.AdjacentTurfs())
				turfs_to_check += neighbor

		for(var/turf/T as anything in turfs_to_check)
			if(register_and_check_turf(T, checked_turfs, listen, tied_human, brain))
				return FALSE

	return TRUE

/datum/human_ai_brain/proc/add_turf_to_watch(turf/T)
	RegisterSignal(T, COMSIG_TURF_ENTERED, PROC_REF(on_watched_turf_enter))
	watched_turfs += T

/datum/human_ai_brain/proc/on_watched_turf_enter(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	if(!istype(entering, /mob/living))
		return

	var/mob/living/living = entering
	if(is_blocking_friendly(living, tied_human))
		SEND_SIGNAL(src, COMSIG_HUMAN_AI_FRIENDLY_IN_FIRING_LINE, living)

/datum/human_ai_brain/proc/clear_watched_turfs()
	if(!length(watched_turfs))
		return
	for(var/turf/T as anything in watched_turfs)
		UnregisterSignal(T, COMSIG_TURF_ENTERED)
	watched_turfs.Cut()

// SS220 EDIT AI - END

#undef EXTRA_CHECK_DISTANCE_MULTIPLIER
#undef PATH_CHECK_NEIGHBOR_START
#undef FIRING_LINE_NEIGHBOR_START
#undef FIRING_LINE_SHORT_RANGE_MAX
