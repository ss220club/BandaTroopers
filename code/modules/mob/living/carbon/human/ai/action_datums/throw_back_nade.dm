/datum/human_ai_brain
	/// A nearby found active grenade which AI will try and toss back
	var/obj/item/explosive/grenade/active_grenade_found

/datum/ai_action/throw_back_nade
	name = "Throw Back Grenade"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	var/min_safe_throw_distance = 4 // SS220 EDIT: throw-back should not deliberately choose turf inside the expected grenade danger radius
	var/throw_ready_time = 0 // SS220 EDIT: picked-up timed grenades roll a random hold window before the actual throw
	var/mid_throw = FALSE // SS220 EDIT: transient async state keeps trigger_action() no-sleep while the real throw runs separately
	var/throw_finished = FALSE // SS220 EDIT: transient async state completes the action on the next scheduler tick
	var/turf/planned_throw_target // SS220 EDIT: prove a safe hostile-side destination exists before approaching the live grenade

/datum/ai_action/throw_back_nade/get_weight(datum/human_ai_brain/brain)
	brain.scan_nearby_live_grenade_threat() // SS220 EDIT: four-tile grenade awareness is independent of ordinary looting range

	if(QDELETED(brain.active_grenade_found) || !brain.active_grenade_found.active)
		return 0

	if(get_dist(brain.tied_human, brain.active_grenade_found) > 4)
		return 0

	return 50

/datum/ai_action/throw_back_nade/Destroy(force, ...)
	brain.active_grenade_found = null // Mr. Grenade is not our friend now
	throw_ready_time = 0
	mid_throw = FALSE // SS220 EDIT: drop transient async throw state when the action is torn down
	throw_finished = FALSE // SS220 EDIT: drop transient async throw state when the action is torn down
	planned_throw_target = null
	return ..()

/datum/ai_action/throw_back_nade/proc/try_hold_grenade(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade)
	if(!grenade || QDELETED(grenade) || (!isturf(grenade.loc) && grenade.loc != tied_human)) // SS220 EDIT: reselect a grenade already picked up for throw-back
		return FALSE

	if(tied_human.get_active_hand() == grenade)
		return TRUE

	if(!(tied_human.get_active_hand()?.flags_item & NODROP))
		brain.clear_main_hand()
		if(tied_human.put_in_active_hand(grenade))
			return TRUE

	tied_human.swap_hand()
	if(tied_human.get_active_hand() == grenade)
		return TRUE

	if(!(tied_human.get_active_hand()?.flags_item & NODROP))
		brain.clear_main_hand()
		if(tied_human.put_in_active_hand(grenade))
			return TRUE

	tied_human.swap_hand()
	return FALSE

// SS220 EDIT START: partial unification with throw_grenade try_hold_grenade - add ensure_primary_hand
/datum/ai_action/throw_back_nade/proc/try_hold_grenade_ensure_primary(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade)
	if(!try_hold_grenade(tied_human, grenade))
		return FALSE
	brain.ensure_primary_hand(grenade)
	return TRUE
// SS220 EDIT END

/datum/ai_action/throw_back_nade/proc/get_directional_throw_target(mob/living/carbon/human/tied_human)
	var/list/directions = list(
		locate(tied_human.x, tied_human.y + min_safe_throw_distance, tied_human.z),
		locate(tied_human.x + min_safe_throw_distance, tied_human.y, tied_human.z),
		locate(tied_human.x, tied_human.y - min_safe_throw_distance, tied_human.z),
		locate(tied_human.x - min_safe_throw_distance, tied_human.y, tied_human.z),
	)

	dir_loop:
		for(var/turf/location as anything in directions)
			if(location)
				var/list/turf/path = get_line(tied_human, location, include_start_atom = FALSE)
				for(var/turf/possible_blocker as anything in path)
					if(possible_blocker.density)
						continue dir_loop

					for(var/obj/possible_object_blocker in possible_blocker) // SS220 EDIT: fix - iterate possible_blocker contents instead of path turfs
						if(possible_object_blocker.density)
							continue dir_loop

				var/has_friendly = FALSE
				for(var/mob/possible_friendly in range(brain.friendly_throw_check_range, location)) // SS220 EDIT: use configurable range from brain
					if(!brain.can_target(possible_friendly))
						has_friendly = TRUE
						break

				if(!has_friendly)
					return location

	return null

/// Returns TRUE only when the live grenade can reach this turf without crossing dense cover or endangering friendlies.
/datum/ai_action/throw_back_nade/proc/can_throw_back_to_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/target_turf)
	if(!tied_human || QDELETED(grenade) || !target_turf)
		return FALSE
	var/distance = get_dist(tied_human, target_turf)
	if(distance < min_safe_throw_distance || distance > grenade.throw_range)
		return FALSE
	for(var/turf/path_turf as anything in get_line(tied_human, target_turf, include_start_atom = FALSE))
		if(path_turf.density)
			return FALSE
		for(var/obj/path_blocker in path_turf)
			if(path_blocker.density)
				return FALSE
	for(var/mob/possible_friendly in range(brain.friendly_throw_check_range, target_turf))
		if(!brain.can_target(possible_friendly))
			return FALSE
	return TRUE

/// Finds a safe visible turf on the hostile side before the NPC risks handling the grenade.
/datum/ai_action/throw_back_nade/proc/get_hostile_throw_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade)
	var/list/possible_targets = list()
	for(var/mob/living/carbon/target in range(brain.view_distance, tied_human))
		if(brain.can_target(target))
			possible_targets += target
	for(var/mob/living/carbon/target as anything in shuffle(possible_targets))
		var/turf/target_turf = get_turf(target)
		if(can_throw_back_to_target(tied_human, grenade, target_turf))
			return target_turf
	return null

/// Keeps the reaction action alive while the NPC creates more than four tiles of separation.
/datum/ai_action/throw_back_nade/proc/evade_live_grenade(obj/item/explosive/grenade/grenade)
	if(QDELETED(grenade) || !grenade.active || get_dist(brain.tied_human, grenade) > 4)
		return ONGOING_ACTION_COMPLETED
	brain.move_away_from_live_grenade(grenade)
	return ONGOING_ACTION_UNFINISHED

/datum/ai_action/throw_back_nade/trigger_action()
	. = ..()
	if(throw_finished)
		return ONGOING_ACTION_COMPLETED

	if(mid_throw)
		return ONGOING_ACTION_UNFINISHED

	var/obj/item/explosive/grenade/active_grenade_found = brain.active_grenade_found
	if(QDELETED(active_grenade_found) || !active_grenade_found.active || (!isturf(active_grenade_found.loc) && active_grenade_found.loc != brain.tied_human))
		log_game("AI GRENADE: throw-back aborted — grenade stale or spent, grenade=[active_grenade_found], mob=[key_name(brain?.tied_human)]")
		brain.active_grenade_found = null // SS220 EDIT: stale or spent grenades must not keep the AI in throw-back mode
		throw_ready_time = 0
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(active_grenade_found.loc != tied_human)
		if(!brain.can_attempt_live_grenade_throwback(active_grenade_found))
			return evade_live_grenade(active_grenade_found) // SS220 EDIT: incapable NPCs retreat and never approach or pick up the grenade

		planned_throw_target = get_hostile_throw_target(tied_human, active_grenade_found)
		if(!planned_throw_target)
			return evade_live_grenade(active_grenade_found) // SS220 EDIT: prove a safe hostile-side throw exists before touching the grenade

		if(get_dist(active_grenade_found, tied_human) > 1)
			if(!brain.move_to_next_turf(get_turf(active_grenade_found)))
				return evade_live_grenade(active_grenade_found) // SS220 EDIT: failed interception falls back to escape

			if(get_dist(active_grenade_found, tied_human) > 1)
				return ONGOING_ACTION_UNFINISHED

		planned_throw_target = get_hostile_throw_target(tied_human, active_grenade_found)
		if(!planned_throw_target)
			return evade_live_grenade(active_grenade_found)

		if(!try_hold_grenade(tied_human, active_grenade_found))
			return evade_live_grenade(active_grenade_found) // SS220 EDIT: failed pickup never leaves the NPC standing beside the threat

		var/remaining_fuse_ticks = active_grenade_found.get_remaining_timed_fuse_ticks()
		if(isnull(remaining_fuse_ticks) || (remaining_fuse_ticks <= 0))
			throw_ready_time = world.time // SS220 EDIT: if this grenade does not expose a usable timed-fuse window, toss it back immediately after pickup
		else
			var/safe_window = max(1, remaining_fuse_ticks - 2) // SS220 EDIT: safety margin — ensure throw happens at least 2 ticks before detonation
			throw_ready_time = world.time + rand(1, safe_window)
		log_game("AI GRENADE: throw-back holding grenade — grenade=[active_grenade_found], remaining_fuse=[remaining_fuse_ticks], throw_ready=[throw_ready_time], mob=[key_name(tied_human)]")
		return ONGOING_ACTION_UNFINISHED

	if(world.time < throw_ready_time)
		return ONGOING_ACTION_UNFINISHED

	var/turf/place_to_throw = get_hostile_throw_target(tied_human, active_grenade_found)
	if(!place_to_throw && can_throw_back_to_target(tied_human, active_grenade_found, planned_throw_target))
		place_to_throw = planned_throw_target // SS220 EDIT: retain the pre-pickup hostile target if it remains safe

	if(!place_to_throw)
		place_to_throw = get_directional_throw_target(tied_human) // SS220 EDIT: fallback keeps the primed grenade moving away from nearby friendlies and the thrower
		if(!place_to_throw)
			// SS220 EDIT: no safe throw target exists — drop the live grenade and clean up throw-back state
			log_game("AI GRENADE: throw-back EMERGENCY — no safe target, dropping live grenade on floor, grenade=[active_grenade_found], mob=[key_name(tied_human)], loc=[AREACOORD(tied_human)]")
			msg_admin_attack("[key_name(tied_human)] (AI) dropped a live [active_grenade_found] on the floor during throw-back — no safe throw target at [AREACOORD(tied_human)].")
			if(tied_human.get_active_hand() == active_grenade_found || tied_human.get_inactive_hand() == active_grenade_found)
				tied_human.drop_inv_item_on_ground(active_grenade_found)
			brain.active_grenade_found = null
			throw_ready_time = 0
			return ONGOING_ACTION_COMPLETED

	if(!try_hold_grenade_ensure_primary(tied_human, active_grenade_found)) // SS220 EDIT: only continue once the live grenade is actually in-hand
		log_game("AI GRENADE: throw-back aborted — final hold failed, grenade=[active_grenade_found], mob=[key_name(tied_human)]")
		brain.active_grenade_found = null
		throw_ready_time = 0
		return ONGOING_ACTION_COMPLETED

	if(QDELETED(active_grenade_found) || (active_grenade_found.loc != tied_human) || !active_grenade_found.active)
		log_game("AI GRENADE: throw-back aborted — grenade lost before throw, grenade=[active_grenade_found], mob=[key_name(tied_human)]")
		brain.active_grenade_found = null // SS220 EDIT: grenade throw-back must abort cleanly if the primed grenade left our hands before scheduling
		throw_ready_time = 0
		return ONGOING_ACTION_COMPLETED

	if(!tied_human.throw_mode)
		tied_human.toggle_throw_mode(THROW_MODE_NORMAL)

	tied_human.face_atom(place_to_throw)
	log_game("AI GRENADE: throw-back proceeding to async throw — grenade=[active_grenade_found], target=[place_to_throw], mob=[key_name(tied_human)]")
	brain.active_grenade_found = null // SS220 EDIT: the grenade is already under this AI's control, stop blocking the rest of its combat state
	brain.to_pickup -= active_grenade_found // Do NOT play fetch. Please.
	throw_ready_time = 0
	mid_throw = TRUE // SS220 EDIT: actual throw runs asynchronously so trigger_action() stays no-sleep for DreamChecker
	INVOKE_ASYNC(src, PROC_REF(async_throw_grenade), tied_human, active_grenade_found, place_to_throw) // SS220 EDIT: async throw avoids DreamChecker sleep violations from throw_item/launch paths
	return ONGOING_ACTION_UNFINISHED

/datum/ai_action/throw_back_nade/proc/finish_async_throw()
	throw_ready_time = 0
	mid_throw = FALSE
	throw_finished = TRUE

/datum/ai_action/throw_back_nade/proc/async_throw_grenade(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/place_to_throw)
	log_game("AI GRENADE: throw-back async throw started — grenade=[grenade], target=[place_to_throw], mob=[key_name(tied_human)]")
	if(QDELETED(src))
		return

	if(!brain || !brain.has_valid_tied_human() || (brain.tied_human != tied_human))
		log_game("AI GRENADE: throw-back async throw aborted — brain invalid or mismatch, mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	if(QDELETED(grenade) || !grenade.active || (grenade.loc != tied_human) || !place_to_throw)
		log_game("AI GRENADE: throw-back async throw aborted — grenade invalid or missing, grenade=[grenade], active=[grenade?.active], loc=[grenade?.loc], target=[place_to_throw], mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	if(tied_human.get_active_hand() != grenade)
		if(tied_human.get_inactive_hand() == grenade)
			tied_human.swap_hand() // SS220 EDIT: async throw must reselect the exact grenade chosen during sync target resolution
		else
			log_game("AI GRENADE: throw-back async throw aborted — grenade not in hands, mob=[key_name(tied_human)]")
			finish_async_throw()
			return

	if(tied_human.get_active_hand() != grenade)
		log_game("AI GRENADE: throw-back async throw aborted — grenade not in active hand after swap, mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	tied_human.throw_item(place_to_throw) // SS220 EDIT: actual throw runs outside SHOULD_NOT_SLEEP action processing
	log_game("AI GRENADE: throw-back throw_item() called — grenade=[grenade], target=[place_to_throw], mob=[key_name(tied_human)]")
	finish_async_throw()
