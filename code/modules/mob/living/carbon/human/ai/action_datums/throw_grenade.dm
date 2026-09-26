#define HUMAN_AI_GRENADE_MIN_HOLD_DELAY (1 SECONDS)
#define HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY (1 SECONDS)

/datum/ai_action/throw_grenade
	name = "Throw Grenade"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS // SS220 EDIT: grenade priming/throwing should own both hand and movement slots until it resolves
	var/obj/item/explosive/grenade/throwing
	var/mid_throw = FALSE
	var/throw_finished = FALSE
	var/min_safe_throw_distance = 2
	var/throw_range_override = null

/datum/ai_action/throw_grenade/get_weight(datum/human_ai_brain/brain)
	if(!brain.grenading_allowed)
		return 0

	if(!brain.in_combat)
		return 0

	var/turf/target_turf = brain.target_turf
	if(!target_turf)
		return 0

	if(!length(brain.equipment_map[HUMAN_AI_GRENADES]))
		return 0

	// DemonicLynx for BandaMarines
	if(brain.active_grenade_found)
		return 0

	// DemonicLynx for BandaMarines
	if(!brain.should_attempt_combat_grenade()) // SS220 EDIT: roll exactly once per combat encounter, not once per scheduler tick
		return 0

	// DemonicLynx for BandaMarines
	return 20 // SS220 EDIT: a selected grenade throw preempts routine firing and spacing actions

/datum/ai_action/throw_grenade/get_conflicts(datum/human_ai_brain/brain)
	. = ..()
	. += /datum/ai_action/chase_target
	. += /datum/ai_action/sniper_nest

/datum/ai_action/throw_grenade/Added()
	// DemonicLynx for BandaMarines
	brain.consume_combat_grenade_decision() // SS220 EDIT: at most one carried-grenade attempt per combat encounter
	throwing = locate() in brain.equipment_map[HUMAN_AI_GRENADES]
	throw_range_override = isnum(throwing?.throw_range) ? throwing.throw_range : null
	log_game("AI GRENADE: throw action created — grenade=[throwing] ([throwing?.type]), available=[english_list(brain?.equipment_map[HUMAN_AI_GRENADES])], throw_range=[throw_range_override], mob=[key_name(brain?.tied_human)]")
	cancel_conflicting_actions()

/datum/ai_action/throw_grenade/Destroy(force, ...)
	throwing = null
	mid_throw = FALSE
	throw_finished = FALSE
	throw_range_override = null
	return ..()

/datum/ai_action/throw_grenade/proc/cancel_conflicting_actions()
	if(!brain)
		return

	var/list/conflicts = get_conflicts(brain)
	for(var/datum/ai_action/conflicting_action as anything in brain.ongoing_actions)
		if((conflicting_action != src) && (conflicting_action.type in conflicts))
			qdel(conflicting_action)

/datum/ai_action/throw_grenade/proc/try_hold_grenade(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade)
	if(!grenade || QDELETED(grenade) || !brain || !brain.has_valid_tied_human())
		return FALSE

	if(tied_human.get_active_hand() == grenade)
		return TRUE

	if(tied_human.get_inactive_hand() == grenade)
		tied_human.swap_hand()
		if(tied_human.get_active_hand() == grenade)
			return TRUE

	var/obj/item/active_hand = tied_human.get_active_hand()
	if(active_hand && (active_hand != grenade))
		if(active_hand.flags_item & NODROP)
			return FALSE
		brain.clear_main_hand()
		if(tied_human.get_active_hand())
			return FALSE

	if(grenade.loc != tied_human)
		if(!brain.equip_item_from_equipment_map(HUMAN_AI_GRENADES, grenade))
			return FALSE
	else if(!tied_human.put_in_active_hand(grenade))
		return FALSE

	brain.ensure_primary_hand(grenade)
	return tied_human.get_active_hand() == grenade

/datum/ai_action/throw_grenade/proc/can_throw_to_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/target_turf)
	if(!tied_human || !grenade || QDELETED(grenade) || !target_turf)
		return FALSE

	var/distance = get_dist(tied_human, target_turf)
	if(distance <= min_safe_throw_distance)
		return FALSE

	var/effective_throw_range = isnum(grenade.throw_range) ? grenade.throw_range : throw_range_override
	if(!isnum(effective_throw_range))
		return FALSE

	if(distance > effective_throw_range)
		return FALSE

	var/list/turf_line = get_line(tied_human, target_turf)
	for(var/turf/turf as anything in turf_line)
		if(turf.density)
			return FALSE

		for(var/obj/object in turf)
			if(object.density)
				return FALSE

	return TRUE

/datum/ai_action/throw_grenade/proc/get_effective_throw_range(obj/item/explosive/grenade/grenade)
	if(!grenade || QDELETED(grenade))
		return null

	var/effective_throw_range = isnum(grenade.throw_range) ? grenade.throw_range : throw_range_override
	if(!isnum(effective_throw_range))
		return null

	return effective_throw_range

/datum/ai_action/throw_grenade/proc/get_fallback_throw_directions(mob/living/carbon/human/tied_human, turf/original_target)
	var/list/directions = list()
	var/original_dir = original_target ? get_dir(tied_human, original_target) : 0

	if(original_dir)
		for(var/direction in make_dir_cardinal(original_dir))
			if(!(direction in directions))
				directions += direction

	if(tied_human?.dir)
		for(var/direction in make_dir_cardinal(tied_human.dir))
			if(!(direction in directions))
				directions += direction

	for(var/direction in GLOB.cardinals)
		if(!(direction in directions))
			directions += direction

	return directions

/datum/ai_action/throw_grenade/proc/has_friendly_near_throw_target(turf/target_turf)
	if(!brain || !target_turf)
		return FALSE

	for(var/mob/possible_friendly in range(brain.friendly_throw_check_range, target_turf)) // SS220 EDIT: use configurable range from brain
		if(!brain.can_target(possible_friendly))
			return TRUE

	return FALSE

/datum/ai_action/throw_grenade/proc/resolve_throw_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/original_target)
	// DemonicLynx for BandaMarines
	if(can_throw_to_target(tied_human, grenade, original_target) && !has_friendly_near_throw_target(original_target)) // SS220 EDIT: never accept the primary target without the same friendly-area check as fallbacks
		return original_target

	var/effective_throw_range = get_effective_throw_range(grenade)
	if(!isnum(effective_throw_range) || (effective_throw_range <= min_safe_throw_distance))
		return null

	var/list/fallback_directions = get_fallback_throw_directions(tied_human, original_target)
	for(var/direction in fallback_directions)
		var/turf/cardinal_target = get_ranged_target_turf(tied_human, direction, effective_throw_range)
		if(can_throw_to_target(tied_human, grenade, cardinal_target) && !has_friendly_near_throw_target(cardinal_target))
			return cardinal_target

	// DemonicLynx for BandaMarines
	return null

/datum/ai_action/throw_grenade/proc/finish_async_throw()
	mid_throw = FALSE
	throw_finished = TRUE

/datum/ai_action/throw_grenade/proc/async_prime_and_throw(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/target_turf)
	log_game("AI GRENADE: async throw started — grenade=[grenade] ([grenade?.type]), target=[target_turf], mob=[key_name(tied_human)]")
	if(QDELETED(src))
		return

	if(!brain || !brain.has_valid_tied_human() || (brain.tied_human != tied_human))
		log_game("AI GRENADE: async throw aborted — brain invalid or tied_human mismatch, mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	var/pre_throw_hold_delay = max(HUMAN_AI_GRENADE_MIN_HOLD_DELAY, brain.short_action_delay * brain.action_delay_mult)
	sleep(pre_throw_hold_delay) // SS220 EDIT: NPCs should visibly commit to the throw and hold the grenade for at least one second before priming/throwing

	if(!brain || !brain.has_valid_tied_human() || (brain.tied_human != tied_human))
		log_game("AI GRENADE: async throw aborted after pre-hold — brain invalid or mismatch, mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	if(!try_hold_grenade(tied_human, grenade) || !can_throw_to_target(tied_human, grenade, target_turf))
		log_game("AI GRENADE: async throw aborted — hold or target check failed, grenade=[grenade], mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	// SS220 EDIT START: resolve throw target BEFORE priming to avoid holding a live grenade
	var/turf/final_target_turf = resolve_throw_target(tied_human, grenade, target_turf)
	if(!final_target_turf)
		log_game("AI GRENADE: async throw aborted — no valid throw target, target=[target_turf], mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	grenade.attack_self(tied_human)
	log_game("AI GRENADE: grenade primed — grenade=[grenade], target=[final_target_turf], mob=[key_name(tied_human)]")
	if(QDELETED(grenade) || !grenade.active)
		log_game("AI GRENADE: async throw aborted after prime — QDELETED=[QDELETED(grenade)], active=[grenade?.active], mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	brain.ensure_primary_hand(grenade)
	brain.say_grenade_thrown_line() // SS220 EDIT: keep the voiceline inside the fixed one-second post-prime throw window
	sleep(HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY) // SS220 EDIT: generic AI should release its own primed grenade after one second, not after burning most of the fuse in hand
	if(QDELETED(grenade) || (grenade.loc != tied_human))
		log_game("AI GRENADE: async throw aborted after post-prime hold — grenade lost, QDELETED=[QDELETED(grenade)], loc=[grenade?.loc], mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	if(!try_hold_grenade(tied_human, grenade))
		log_game("AI GRENADE: async throw aborted — final hold failed, grenade=[grenade], mob=[key_name(tied_human)]")
		finish_async_throw()
		return

	// SS220 EDIT START: emergency fallback if target became invalid after prime
	var/turf/emergency_target = resolve_throw_target(tied_human, grenade, target_turf)
	if(!emergency_target)
		emergency_target = get_fallback_throw_directions(tied_human, target_turf)
		if(length(emergency_target))
			for(var/direction in emergency_target)
				var/turf/candidate = get_ranged_target_turf(tied_human, direction, get_effective_throw_range(grenade))
				// DemonicLynx for BandaMarines
				if(candidate && can_throw_to_target(tied_human, grenade, candidate) && !has_friendly_near_throw_target(candidate)) // SS220 EDIT: emergency retargeting keeps the same friendly-area safety rule
					emergency_target = candidate
					break
			if(!isturf(emergency_target))
				emergency_target = null
	if(!emergency_target)
		log_game("AI GRENADE: EMERGENCY — no valid target, dropping live grenade on floor, grenade=[grenade], mob=[key_name(tied_human)], loc=[AREACOORD(tied_human)]")
		msg_admin_attack("[key_name(tied_human)] (AI) dropped a live [grenade] on the floor — no valid throw target at [AREACOORD(tied_human)].")
		tied_human.drop_inv_item_on_ground(grenade)
		finish_async_throw()
		return
	final_target_turf = emergency_target
	// SS220 EDIT END

	if(!tied_human.throw_mode)
		tied_human.toggle_throw_mode(THROW_MODE_NORMAL)

	tied_human.face_atom(final_target_turf)
	tied_human.throw_item(final_target_turf) // SS220 EDIT: still release the primed grenade if the original target turf became invalid during the one-second wind-up
	log_game("AI GRENADE: throw_item() called — grenade=[grenade], target=[final_target_turf], mob=[key_name(tied_human)]")
	finish_async_throw()

/datum/ai_action/throw_grenade/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	if(throw_finished)
		return ONGOING_ACTION_COMPLETED

	if(mid_throw)
		return ONGOING_ACTION_UNFINISHED_BLOCK

	var/turf/target_turf = brain.target_turf
	if(QDELETED(throwing) || !target_turf)
		log_game("AI GRENADE: throw action aborted — grenade missing or no target, QDELETED=[QDELETED(throwing)], target=[target_turf], mob=[key_name(brain?.tied_human)]")
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(brain.primary_weapon)
		brain.primary_weapon.unwield(tied_human)
		if(tied_human.get_active_hand() == brain.primary_weapon)
			tied_human.swap_hand()

	cancel_conflicting_actions() // SS220 EDIT: cancel any already-running move/fire/reload actions before the grenade is primed
	if(!try_hold_grenade(tied_human, throwing))
		log_game("AI GRENADE: throw action aborted — could not hold grenade, grenade=[throwing], mob=[key_name(tied_human)]")
		return ONGOING_ACTION_COMPLETED

	if(isnum(throwing.throw_range))
		throw_range_override = throwing.throw_range

	if(!can_throw_to_target(tied_human, throwing, target_turf))
		log_game("AI GRENADE: throw action aborted — target unreachable, distance=[get_dist(tied_human, target_turf)], throw_range=[throw_range_override], mob=[key_name(tied_human)]")
		return ONGOING_ACTION_COMPLETED

	log_game("AI GRENADE: throw action proceeding to async prime — grenade=[throwing], target=[target_turf], mob=[key_name(tied_human)]")
	mid_throw = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_prime_and_throw), tied_human, throwing, target_turf)
	return ONGOING_ACTION_UNFINISHED_BLOCK

#undef HUMAN_AI_GRENADE_MIN_HOLD_DELAY
#undef HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY
