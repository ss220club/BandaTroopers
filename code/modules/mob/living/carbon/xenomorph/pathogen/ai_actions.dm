// Abilities that spread the infection (blight wave, spore sacs, spore injection, mycotoxin) are deliberately left to players.

// ################## Shared ##################

// Delay for actions
/mob/living/carbon/xenomorph/bloodburster
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/sprinter
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/neophyte
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/neomorph
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/blight
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/conditor
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/brute
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/venator
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/harbinger
	ai_ability_delay = 3 SECONDS

/mob/living/carbon/xenomorph/matriarch
	ai_ability_delay = 2 SECONDS
	forced_retarget_time = (5 SECONDS) // Bosses should not tunnel a single marine

/mob/living/carbon/xenomorph/archon
	ai_ability_delay = 2 SECONDS
	forced_retarget_time = (5 SECONDS) // Bosses should not tunnel a single marine

/mob/living/carbon/xenomorph/aberration
	ai_ability_delay = 2 SECONDS
	forced_retarget_time = (5 SECONDS) // Bosses should not tunnel a single marine

/datum/action/xeno_action/activable/tail_stab/pathogen
	default_ai_action = TRUE
	ai_prob_chance = 40
	charge_time = null

/datum/action/xeno_action/onclick/pathogen_paralyze
	default_ai_action = TRUE
	ai_prob_chance = 40

/datum/action/xeno_action/onclick/pathogen_paralyze/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(parent, parent.current_target) > 1)
		return

	var/mob/living/carbon/target = parent.current_target
	if(!istype(target) || target.is_mob_incapacitated())
		return

	use_ability_async()

// ################## Neophyte, Popper ##################

/mob/living/carbon/xenomorph/neophyte/init_movement_handler()
	return new /datum/xeno_ai_movement/drone/neophyte(src)

// Neophytes would rather spread the blight and leave the fighting to others, as long as there are others.
/datum/xeno_ai_movement/drone/neophyte
	/// How far we look for somebody else to do the fighting
	var/fighter_search_range = 7

/datum/xeno_ai_movement/drone/neophyte/ai_move_target(delta_time)
	if(GLOB.ai_xeno_weeding && has_fighters_nearby())
		ai_move_idle(delta_time)
		if(home_turf)
			// Returning TRUE keeps us from attacking or using abilities.
			return TRUE
		// Nowhere to plant, might as well help.
		parent.set_resting(FALSE, FALSE, TRUE)

	return ..()

/datum/xeno_ai_movement/drone/neophyte/proc/has_fighters_nearby()
	for(var/mob/living/carbon/xenomorph/ally in view(fighter_search_range, parent))
		if(ally == parent || ally.stat != CONSCIOUS || ally.hivenumber != parent.hivenumber)
			continue
		if(isneophyte(ally) || ispopper(ally) || isbloodburster(ally))
			continue
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/popper/init_movement_handler()
	return new /datum/xeno_ai_movement/drone(src)

// ################## Sprinter ##################

/datum/action/xeno_action/activable/runner_skillshot/sprinter
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/activable/runner_skillshot/sprinter/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	var/distance = get_dist(parent, parent.current_target)
	return DT_PROB(ai_prob_chance, delta_time) && distance >= 2 && distance <= 6 && !check_for_obstacles_projectile(parent, parent.current_target, GLOB.ammo_list[ammo_type]) && use_ability_async(parent.current_target)

// ################## Bloodburster ##################

/datum/action/xeno_action/activable/pounce/runner/pathogen/bloodburster
	default_ai_action = FALSE

// ################## Neomorph ##################

/datum/action/xeno_action/activable/pounce/runner/pathogen/neomorph
	default_ai_action = FALSE

/datum/action/xeno_action/activable/headbite/neomorph
	default_ai_action = TRUE
	ai_prob_chance = 25

/datum/action/xeno_action/activable/headbite/neomorph/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	var/mob/living/carbon/target = parent.current_target
	if(!istype(target) || !parent.Adjacent(target) || parent.action_busy)
		return

	if(!(HAS_TRAIT(target, TRAIT_KNOCKEDOUT) || target.stat == UNCONSCIOUS))
		return

	return DT_PROB(ai_prob_chance, delta_time) && use_ability_async(target)

// ################## Conditor ##################

/mob/living/carbon/xenomorph/conditor/init_movement_handler()
	return new /datum/xeno_ai_movement/linger(src)

/datum/action/xeno_action/activable/xeno_spit/conditor
	default_ai_action = TRUE

/datum/action/xeno_action/activable/xeno_spit/conditor/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	return DT_PROB(ai_prob_chance, delta_time) && (get_dist(parent, parent.current_target) <= 7) && !check_for_obstacles_projectile(parent, parent.current_target, parent.ammo) && use_ability_async(parent.current_target)

// ################## Brute ##################

/datum/action/xeno_action/activable/oppressor_punch/pathogen
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/activable/oppressor_punch/pathogen/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	return DT_PROB(ai_prob_chance, delta_time) && parent.Adjacent(parent.current_target) && use_ability_async(parent.current_target)

/datum/action/xeno_action/onclick/crusher_shield/pathogen
	default_ai_action = TRUE
	ai_prob_chance = 30

/datum/action/xeno_action/onclick/crusher_shield/pathogen/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(parent, parent.current_target) > 3 || parent.action_busy)
		return

	use_ability_async()

// ################## Venator ##################
// Keeps its distance, drags somebody out with the tentacle grab and goes for the kill.
// If the grab catches nobody, or the prey gets away, it backs off until the grab is ready again.

#define VENATOR_AI_STALK 0
#define VENATOR_AI_HUNT 1
#define VENATOR_AI_RETREAT 2

#define VENATOR_TAUNTS_CAUGHT list("Got you", "Come to me, little host", "You are mine now", "Where do you think you are going?")
#define VENATOR_TAUNTS_MISSED list("Next time", "Slippery little host", "I will be back for you", "You can not hide forever")
#define VENATOR_TAUNTS_ESCAPED list("Run, little host", "We are not done", "I will find you again")
#define VENATOR_TAUNTS_KILL list("One less", "Who is next?", "So fragile")
#define VENATOR_TAUNTS_RETURN list("Did you miss me?", "I am not done with you", "I see you")

/mob/living/carbon/xenomorph/venator/init_movement_handler()
	return new /datum/xeno_ai_movement/linger/venator(src)

/datum/xeno_ai_movement/linger/venator
	linger_range = 6

	var/state = VENATOR_AI_STALK
	/// Who we dragged out and are trying to kill
	var/mob/living/carbon/prey
	/// Where we are running to while retreating
	var/turf/retreat_turf
	/// How long we keep chasing the prey
	var/hunt_duration = 10 SECONDS
	/// If the prey gets this far, it got away
	var/hunt_range = 6
	/// How far from the target we try to retreat
	var/retreat_range = 11

	/// Chance to say something when changing what we are doing
	var/taunt_chance = 60

	COOLDOWN_DECLARE(hunt_cooldown)
	COOLDOWN_DECLARE(retreat_cooldown)

/datum/xeno_ai_movement/linger/venator/Destroy(force, ...)
	prey = null
	retreat_turf = null
	return ..()

/datum/xeno_ai_movement/linger/venator/proc/taunt(list/taunts)
	if(!prob(taunt_chance) || !parent || parent.stat != CONSCIOUS)
		return
	INVOKE_ASYNC(parent, TYPE_PROC_REF(/mob, say), pick(taunts))

/datum/xeno_ai_movement/linger/venator/proc/start_hunt(mob/living/carbon/new_prey)
	state = VENATOR_AI_HUNT
	prey = new_prey
	COOLDOWN_START(src, hunt_cooldown, hunt_duration)
	taunt(VENATOR_TAUNTS_CAUGHT)

/datum/xeno_ai_movement/linger/venator/proc/start_retreat(duration = 15 SECONDS, list/taunts = VENATOR_TAUNTS_MISSED)
	state = VENATOR_AI_RETREAT
	prey = null
	retreat_turf = null
	COOLDOWN_START(src, retreat_cooldown, duration)
	taunt(taunts)

/datum/xeno_ai_movement/linger/venator/proc/find_retreat_turf()
	var/mob/living/carbon/xenomorph/moving_xeno = parent
	var/list/threats = list()
	for(var/mob/living/carbon/human/threat in view(world.view, moving_xeno))
		if(threat.stat == DEAD || moving_xeno.can_not_harm(threat))
			continue
		threats += threat
	if(!length(threats) && moving_xeno.current_target)
		threats += moving_xeno.current_target
	if(!length(threats))
		return

	var/list/blocked_dirs = list()
	for(var/atom/threat as anything in threats)
		var/threat_dir = get_dir(moving_xeno, threat)
		blocked_dirs |= list(threat_dir, turn(threat_dir, 45), turn(threat_dir, -45))

	var/turf/best_turf
	var/best_score = -INFINITY
	for(var/turf/candidate as anything in RANGE_TURFS(retreat_range, moving_xeno))
		if(candidate.density || get_dist(candidate, moving_xeno) < retreat_range - 4)
			continue

		var/blocked = FALSE
		for(var/obj/structure/obstacle in candidate)
			if(obstacle.density)
				blocked = TRUE
				break
		if(blocked)
			continue

		var/closest_threat = INFINITY
		for(var/atom/threat as anything in threats)
			closest_threat = min(closest_threat, get_dist(candidate, threat))

		var/score = closest_threat
		if(get_dir(moving_xeno, candidate) in blocked_dirs)
			score -= retreat_range // Only if there is nowhere else to go.

		if(score > best_score)
			best_score = score
			best_turf = candidate

	return best_turf

/datum/xeno_ai_movement/linger/venator/ai_move_target(delta_time)
	var/mob/living/carbon/xenomorph/moving_xeno = parent
	if(moving_xeno.throwing)
		return

	switch(state)
		if(VENATOR_AI_HUNT)
			if(QDELETED(prey) || prey.stat == DEAD)
				// Done with this one, go look for another.
				prey = null
				state = VENATOR_AI_STALK
				taunt(VENATOR_TAUNTS_KILL)
				return ..()

			if(COOLDOWN_FINISHED(src, hunt_cooldown) || get_dist(moving_xeno, prey) > hunt_range)
				start_retreat(taunts = VENATOR_TAUNTS_ESCAPED)
				return TRUE

			moving_xeno.current_target = prey
			if(get_dist(moving_xeno, prey) > 1 && !moving_xeno.move_to_next_turf(get_turf(prey)))
				start_retreat(taunts = VENATOR_TAUNTS_ESCAPED)
				return TRUE
			return

		if(VENATOR_AI_RETREAT)
			if(COOLDOWN_FINISHED(src, retreat_cooldown))
				state = VENATOR_AI_STALK
				retreat_turf = null
				taunt(VENATOR_TAUNTS_RETURN)
				return ..()

			if(!retreat_turf || get_dist(retreat_turf, moving_xeno) <= 0)
				retreat_turf = find_retreat_turf()

			if(retreat_turf && !moving_xeno.move_to_next_turf(retreat_turf))
				retreat_turf = null

			// Returning TRUE keeps us from attacking or using abilities while we run.
			return TRUE

	return ..()

#undef VENATOR_AI_STALK
#undef VENATOR_AI_HUNT
#undef VENATOR_AI_RETREAT

#undef VENATOR_TAUNTS_CAUGHT
#undef VENATOR_TAUNTS_MISSED
#undef VENATOR_TAUNTS_ESCAPED
#undef VENATOR_TAUNTS_KILL
#undef VENATOR_TAUNTS_RETURN


/datum/action/xeno_action/activable/venator_abduct
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/activable/venator_abduct/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	var/distance = get_dist(parent, parent.current_target)
	if(!DT_PROB(ai_prob_chance, delta_time) || distance < 2 || distance > max_distance || parent.action_busy)
		return

	if(!action_cooldown_check())
		return

	// The tentacle only goes in a straight line.
	for(var/turf/checked_turf as anything in get_line(parent, parent.current_target, include_start_atom = FALSE))
		if(checked_turf.density || checked_turf.opacity)
			return

	ai_abduct(parent, parent.current_target)

/// Uses the grab, then tells the movement handler whether it has caught anybody.
/datum/action/xeno_action/activable/venator_abduct/proc/ai_abduct(mob/living/carbon/xenomorph/parent, atom/target)
	set waitfor = FALSE

	use_ability(target)

	if(QDELETED(parent) || action_cooldown_check()) // Did not even get to try.
		return

	var/datum/xeno_ai_movement/linger/venator/venator_movement = parent.ai_movement_handler
	if(!istype(venator_movement))
		return

	var/mob/living/carbon/prey
	for(var/mob/living/carbon/human/possible_prey in view(2, parent))
		if(possible_prey.stat == DEAD || parent.can_not_harm(possible_prey))
			continue
		prey = possible_prey
		if(possible_prey == target)
			break

	if(prey)
		venator_movement.start_hunt(prey)
	else
		venator_movement.start_retreat(xeno_cooldown)

/datum/action/xeno_action/activable/venator_savage
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/activable/venator_savage/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	return DT_PROB(ai_prob_chance, delta_time) && (get_dist(parent, parent.current_target) <= 3) && use_ability_async(parent.current_target)

/datum/action/xeno_action/activable/prae_impale/venator
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/activable/prae_impale/venator/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	return DT_PROB(ai_prob_chance, delta_time) && parent.Adjacent(parent.current_target) && use_ability_async(parent.current_target)

/datum/action/xeno_action/onclick/empower/venator
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/onclick/empower/venator/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time))
		return

	// It is only worth anything with somebody close by.
	if(!parent.count_ai_targets_in_range(2))
		return

	use_ability_async(parent.current_target)

// ################## Harbinger, Archon ##################

/datum/action/xeno_action/activable/cyclone
	default_ai_action = TRUE
	ai_prob_chance = 40

/datum/action/xeno_action/activable/cyclone/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || parent.action_busy)
		return

	// It roots us in place, so only when somebody is actually in reach.
	if(!parent.count_ai_targets_in_range(base_range))
		return

	use_ability_async(parent.current_target)

/datum/action/xeno_action/onclick/tail_sweep/pathogen
	default_ai_action = TRUE
	ai_prob_chance = 40

/datum/action/xeno_action/onclick/tail_sweep/pathogen/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(parent, parent.current_target) > 1 || parent.action_busy)
		return

	use_ability_async()

// ################## Matriarch ##################

/datum/action/xeno_action/onclick/shatter
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/onclick/shatter/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || parent.action_busy)
		return

	// Only when surrounded.
	if(parent.count_ai_targets_in_range(shatter_range) < 2)
		return

	use_ability_async()

/datum/action/xeno_action/onclick/blight_wave
	default_ai_action = TRUE
	ai_prob_chance = 80
	var/ai_opener_range = 6

/datum/action/xeno_action/onclick/blight_wave/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || parent.action_busy)
		return

	if(get_dist(parent, parent.current_target) > ai_opener_range || !parent.count_ai_targets_in_range(ai_opener_range))
		return

	use_ability_async()

/// Whether the AI still has the blight wave to open with, so that the other abilities wait for it.
/datum/action/xeno_action/onclick/blight_wave/proc/ai_opener_pending(mob/living/carbon/xenomorph/parent)
	return action_cooldown_check() && parent.plasma_stored >= plasma_cost && get_dist(parent, parent.current_target) <= ai_opener_range

/datum/action/xeno_action/activable/rav_spikes/matriarch
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/activable/rav_spikes/matriarch/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	var/datum/behavior_delegate/pathogen_base/matriarch/behavior = parent.behavior_delegate
	if(!istype(behavior) || behavior.shards < shard_cost)
		return

	var/datum/action/xeno_action/onclick/blight_wave/opener = get_action(parent, /datum/action/xeno_action/onclick/blight_wave)
	if(opener?.ai_opener_pending(parent))
		return

	var/distance = get_dist(parent, parent.current_target)
	return DT_PROB(ai_prob_chance, delta_time) && distance >= 2 && distance <= 7 && !check_for_obstacles_projectile(parent, parent.current_target, GLOB.ammo_list[ammo_type]) && use_ability_async(parent.current_target)

/datum/action/xeno_action/onclick/spike_shed/matriarch
	default_ai_action = TRUE
	ai_prob_chance = 40

/datum/action/xeno_action/onclick/spike_shed/matriarch/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	var/datum/behavior_delegate/pathogen_base/matriarch/behavior = parent.behavior_delegate
	if(!istype(behavior) || behavior.shards < shard_cost)
		return

	if(!DT_PROB(ai_prob_chance, delta_time) || parent.action_busy)
		return

	if(parent.count_ai_targets_in_range(2) < 2)
		return

	use_ability_async()

// ################## Aberration ##################

/datum/action/xeno_action/onclick/feralrush/aberration
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/onclick/feralrush/aberration/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || get_dist(parent, parent.current_target) < 3)
		return

	use_ability_async()

/datum/action/xeno_action/onclick/predalien_roar/aberration
	default_ai_action = TRUE
	ai_prob_chance = 50

/datum/action/xeno_action/onclick/predalien_roar/aberration/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	if(!DT_PROB(ai_prob_chance, delta_time) || parent.count_ai_targets_in_range(5) < 2)
		return

	use_ability_async()

/datum/action/xeno_action/activable/feral_smash/aberration
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/activable/feral_smash/aberration/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	var/distance = get_dist(parent, parent.current_target)
	if(!DT_PROB(ai_prob_chance, delta_time) || distance < 2 || distance > grab_range || parent.action_busy)
		return

	for(var/turf/checked_turf as anything in get_line(parent, parent.current_target, include_start_atom = FALSE))
		if(checked_turf.density)
			return

	use_ability_async(parent.current_target)

/datum/action/xeno_action/activable/feralfrenzy/aberration
	default_ai_action = TRUE
	ai_prob_chance = 60

/datum/action/xeno_action/activable/feralfrenzy/aberration/process_ai(mob/living/carbon/xenomorph/parent, delta_time)
	return DT_PROB(ai_prob_chance, delta_time) && !parent.action_busy && parent.Adjacent(parent.current_target) && use_ability_async(parent.current_target)
