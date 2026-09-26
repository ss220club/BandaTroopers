// DemonicLynx for BandaMarines
#define HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS 4
#define HUMAN_AI_LIVE_GRENADE_SCAN_INTERVAL (0.5 SECONDS)

/datum/human_ai_brain
	/// Percentage rolled once when a new combat encounter begins.
	var/combat_grenade_use_chance = 40
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
		combat_grenade_selected = prob(combat_grenade_use_chance)
	return combat_grenade_selected

/// Consumes the encounter's selected throw so one NPC cannot throw its whole grenade inventory at once.
/datum/human_ai_brain/proc/consume_combat_grenade_decision()
	combat_grenade_decision_made = TRUE
	combat_grenade_selected = FALSE

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
	if(!can_throw_back_grenades || QDELETED(grenade) || !grenade.active || grenade.fuse_type != TIMED_FUSE)
		return FALSE
	if((tied_human.l_hand?.flags_item & NODROP) && (tied_human.r_hand?.flags_item & NODROP))
		return FALSE
	return TRUE

/// Selects a bounded local escape destination that increases distance from the live grenade.
/datum/human_ai_brain/proc/get_live_grenade_escape_turf(obj/item/explosive/grenade/grenade)
	if(!has_valid_tied_human() || QDELETED(grenade))
		return

	var/current_distance = get_dist(tied_human, grenade)
	var/turf/best_turf
	var/best_score = -INFINITY
	for(var/turf/candidate as anything in range(HUMAN_AI_LIVE_GRENADE_REACTION_RADIUS, tied_human))
		if(candidate.z != tied_human.z || is_blocked_turf(candidate))
			continue
		if((locate(/obj/item/explosive/mine) in candidate.contents) || (locate(/obj/flamer_fire) in candidate.contents))
			continue
		var/grenade_distance = get_dist(candidate, grenade)
		if(grenade_distance <= current_distance)
			continue
		var/travel_distance = get_dist(tied_human, candidate)
		var/score = grenade_distance * 10 - travel_distance
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
