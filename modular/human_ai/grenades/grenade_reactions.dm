#define HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS 4
#define HUMAN_AI_LIVE_GRENADE_SCAN_INTERVAL (0.5 SECONDS)

/datum/human_ai_brain
	var/combat_grenade_decision_made = FALSE
	var/combat_grenade_selected = FALSE
	COOLDOWN_DECLARE(live_grenade_scan_cooldown)

/// Starts a fresh, single-roll carried-grenade decision for this combat encounter.
/datum/human_ai_brain/proc/begin_combat_grenade_decision()
	combat_grenade_decision_made = FALSE
	combat_grenade_selected = FALSE

/// Returns the stored result of one probability roll for the current encounter.
/datum/human_ai_brain/proc/should_attempt_combat_grenade()
	if(!combat_grenade_decision_made)
		combat_grenade_decision_made = TRUE
		combat_grenade_selected = prob(setting("grenade_chance"))
	return combat_grenade_selected

/// Consumes the encounter's selected throw so one NPC cannot throw its whole grenade inventory at once.
/datum/human_ai_brain/proc/consume_combat_grenade_decision()
	combat_grenade_decision_made = TRUE
	combat_grenade_selected = FALSE

/// Returns a loaded launcher which can fire immediately without inventing a reload or pump action.
/datum/human_ai_brain/proc/get_ready_underbarrel_grenade_launcher()
	if(!primary_weapon)
		return null
	var/obj/item/attachable/attached_gun/grenade/launcher = primary_weapon.attachments["under"]
	if(!istype(launcher))
		return null
	if(launcher.has_breech && (launcher.breech_open || !launcher.cocked))
		return null
	if(istype(launcher, /obj/item/attachable/attached_gun/grenade/mk1))
		return launcher.in_chamber ? launcher : null
	if(!launcher.in_chamber && launcher.current_rounds <= 0)
		return null
	return launcher

/// Returns whether one underbarrel grenade may safely land on this turf.
/datum/human_ai_brain/proc/can_fire_underbarrel_grenade_at(obj/item/attachable/attached_gun/grenade/launcher, turf/candidate)
	if(!launcher || !candidate || !has_valid_tied_human())
		return FALSE
	var/distance = get_dist(tied_human, candidate)
	if(distance <= 2 || distance > launcher.max_range)
		return FALSE
	for(var/turf/path_turf as anything in get_line(tied_human, candidate, include_start_atom = FALSE))
		if(path_turf.density)
			return FALSE
		for(var/obj/path_blocker in path_turf)
			if(path_blocker.density)
				return FALSE
	for(var/mob/possible_friendly in range(friendly_throw_check_range, candidate))
		if((possible_friendly == tied_human) || (setting("grenade_safety") && grenade_would_harm_friendly(possible_friendly)))
			return FALSE
	return TRUE

/// Land on or next to the hostile, or wait until a useful shot is possible.
/datum/human_ai_brain/proc/get_underbarrel_grenade_target(obj/item/attachable/attached_gun/grenade/launcher, turf/hostile_turf)
	if(!launcher || !hostile_turf)
		return null
	if(can_fire_underbarrel_grenade_at(launcher, hostile_turf))
		return hostile_turf
	var/turf/best_target
	for(var/turf/candidate in range(1, hostile_turf))
		if(can_fire_underbarrel_grenade_at(launcher, candidate))
			best_target = candidate
			break
	return best_target

/datum/ai_action/fire_underbarrel_grenade
	name = "Fire Underbarrel Grenade"
	action_flags = ACTION_USING_HANDS

/datum/ai_action/fire_underbarrel_grenade/get_weight(datum/human_ai_brain/brain)
	if(!brain.grenading_allowed || brain.has_live_grenade_emergency())
		return 0
	if(!brain.in_combat || !brain.target_turf || length(brain.equipment_map[HUMAN_AI_GRENADES]))
		return 0
	if(!brain.should_attempt_combat_grenade())
		return 0
	var/obj/item/attachable/attached_gun/grenade/launcher = brain.get_ready_underbarrel_grenade_launcher()
	if(!launcher || !brain.get_underbarrel_grenade_target(launcher, brain.target_turf))
		return 0
	return 100

/datum/ai_action/fire_underbarrel_grenade/trigger_action()
	. = ..()
	if(!brain.grenading_allowed || brain.has_live_grenade_emergency())
		return ONGOING_ACTION_COMPLETED
	var/obj/item/attachable/attached_gun/grenade/launcher = brain.get_ready_underbarrel_grenade_launcher()
	var/turf/launch_target = brain.get_underbarrel_grenade_target(launcher, brain.target_turf)
	if(!launcher || !launch_target)
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/tied_human = brain.tied_human
	brain.unholster_primary()
	brain.ensure_primary_hand(brain.primary_weapon)
	brain.wield_primary()
	if(!(brain.primary_weapon.flags_item & WIELDED))
		return ONGOING_ACTION_COMPLETED

	tied_human.face_atom(launch_target)
	brain.say_grenade_thrown_line()
	launcher.fire_attachment(launch_target, brain.primary_weapon, tied_human)
	brain.consume_combat_grenade_decision()
	return ONGOING_ACTION_COMPLETED

/// Finds the nearest active grenade lying on the floor within the reaction radius.
/datum/human_ai_brain/proc/scan_nearby_live_grenade_threat(force_scan = FALSE)
	if(!has_valid_tied_human())
		active_grenade_found = null
		return

	var/current_threat_is_local = active_grenade_found && !QDELETED(active_grenade_found) && active_grenade_found.active \
		&& ((active_grenade_found.loc == tied_human) || (isturf(active_grenade_found.loc) && get_dist(tied_human, active_grenade_found) <= HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS))
	if(current_threat_is_local && !force_scan)
		return active_grenade_found
	if(!current_threat_is_local)
		active_grenade_found = null

	if(!force_scan && !COOLDOWN_FINISHED(src, live_grenade_scan_cooldown))
		return active_grenade_found
	COOLDOWN_START(src, live_grenade_scan_cooldown, HUMAN_AI_LIVE_GRENADE_SCAN_INTERVAL)

	var/obj/item/explosive/grenade/nearest_grenade
	var/nearest_distance = INFINITY
	for(var/obj/item/explosive/grenade/grenade in range(HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS, tied_human))
		if(QDELETED(grenade) || !grenade.active || !isturf(grenade.loc))
			continue
		var/grenade_distance = get_dist(tied_human, grenade)
		if(grenade_distance >= nearest_distance)
			continue
		nearest_grenade = grenade
		nearest_distance = grenade_distance

	active_grenade_found = nearest_grenade
	return nearest_grenade

/// Whether this NPC may approach and manipulate this particular live grenade.
/datum/human_ai_brain/proc/can_attempt_live_grenade_throwback(obj/item/explosive/grenade/grenade)
	if(!has_valid_tied_human())
		return FALSE
	if(!setting("throwback") || !can_throw_back_grenades || QDELETED(grenade) || !grenade.active || grenade.fuse_type != TIMED_FUSE)
		return FALSE
	if(get_dist(tied_human, grenade) > 2)
		return FALSE
	if((tied_human.l_hand?.flags_item & NODROP) && (tied_human.r_hand?.flags_item & NODROP))
		return FALSE
	var/remaining_fuse = grenade.get_remaining_timed_fuse_ticks()
	var/approach_steps = max(0, get_dist(tied_human, grenade) - 1)
	// Doors, climbing and detours cannot be safely budgeted against a live fuse.
	if(approach_steps)
		for(var/turf/approach_turf as anything in get_line(tied_human, grenade, include_start_atom = FALSE))
			if(approach_turf.density)
				return FALSE
			for(var/obj/blocker in approach_turf)
				if(blocker.density)
					return FALSE
	var/required_time = approach_steps * max(tied_human.move_delay, SShuman_ai.wait) + max(2, setting("fuse_reserve")) * 10
	if(!isnum(remaining_fuse) || remaining_fuse <= required_time)
		return FALSE
	return TRUE

/// Selects a bounded local escape destination that increases distance from the live grenade.
/datum/human_ai_brain/proc/get_live_grenade_escape_turf(obj/item/explosive/grenade/grenade)
	if(!has_valid_tied_human() || QDELETED(grenade))
		return

	var/current_distance = get_dist(tied_human, grenade)
	if(current_distance >= 5)
		return null
	var/turf/best_turf
	var/best_score = -INFINITY
	for(var/turf/candidate in range(5, tied_human))
		if(candidate.z != tied_human.z || !human_ai_turf_is_safe(candidate, TRUE, FALSE))
			continue
		if((locate(/obj/item/explosive/mine) in candidate.contents) || (locate(/obj/flamer_fire) in candidate.contents))
			continue
		var/grenade_distance = get_dist(candidate, grenade)
		if(grenade_distance <= current_distance)
			continue
		var/travel_distance = get_dist(tied_human, candidate)
		var/score = min(grenade_distance, 5) * 100 - travel_distance
		if(score <= best_score)
			continue
		best_score = score
		best_turf = candidate
	return best_turf

/// Takes one pathfinding step toward safety without ever touching the grenade.
/datum/human_ai_brain/proc/move_away_from_live_grenade(obj/item/explosive/grenade/grenade)
	var/turf/escape_turf = get_live_grenade_escape_turf(grenade)
	if(!escape_turf)
		return FALSE
	return move_to_next_turf(escape_turf, HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS * 2)

/// Frees hands and legs immediately so an already-running routine action cannot suppress the emergency reaction.
/datum/human_ai_brain/proc/preempt_actions_for_live_grenade()
	if(QDELETED(active_grenade_found) || !active_grenade_found.active || get_dist(tied_human, active_grenade_found) > HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS)
		return
	for(var/datum/ai_action/ongoing_action as anything in ongoing_actions.Copy())
		if(istype(ongoing_action, /datum/ai_action/throw_back_nade))
			continue
		if(istype(ongoing_action, /datum/ai_action/throw_grenade))
			var/datum/ai_action/throw_grenade/grenade_action = ongoing_action
			if(grenade_action.mid_throw)
				continue
		if(ongoing_action.action_flags & (ACTION_USING_HANDS | ACTION_USING_LEGS))
			qdel(ongoing_action)

#undef HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS
#undef HUMAN_AI_LIVE_GRENADE_SCAN_INTERVAL
