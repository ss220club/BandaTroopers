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

	var/obj/item/explosive/grenade/grenade = locate() in brain.equipment_map[HUMAN_AI_GRENADES]
	if(!grenade)
		return 0

	if(brain.active_grenade_found)
		return 0

	if(!brain.should_attempt_combat_grenade()) // SS220 EDIT: roll exactly once per combat encounter, not once per scheduler tick
		return 0
	// keep a successful roll pending until a currently safe hostile-side throw is possible.
	if(!resolve_throw_target(brain.tied_human, grenade, target_turf, brain))
		return 0

	return 100 // SS220 EDIT: a feasible successful encounter roll must preempt routine firing and spacing actions

/datum/ai_action/throw_grenade/get_conflicts(datum/human_ai_brain/brain)
	. = ..()
	. += /datum/ai_action/chase_target
	. += /datum/ai_action/sniper_nest

/datum/ai_action/throw_grenade/Added()
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

/// Stows the personal weapon before the grenade is removed from storage. Failure never drops the weapon.
/datum/ai_action/throw_grenade/proc/try_stow_weapon_for_grenade(mob/living/carbon/human/tied_human)
	if(!brain?.primary_weapon || (tied_human.l_hand != brain.primary_weapon && tied_human.r_hand != brain.primary_weapon))
		return TRUE

	brain.primary_weapon.unwield(tied_human)
	brain.ensure_primary_hand(brain.primary_weapon)
	if(!brain.holster_primary())
		return FALSE
	return tied_human.l_hand != brain.primary_weapon && tied_human.r_hand != brain.primary_weapon

/// Returns an inert grenade to available AI storage after a cancelled preparation step.
/datum/ai_action/throw_grenade/proc/return_unprimed_grenade_to_storage(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade)
	if(!tied_human || QDELETED(grenade) || grenade.active || grenade.loc != tied_human)
		return FALSE
	var/storage_loc = brain.storage_has_room(grenade)
	if(!storage_loc)
		return FALSE
	return brain.store_item(grenade, storage_loc, HUMAN_AI_GRENADES)

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

/datum/ai_action/throw_grenade/proc/has_friendly_near_throw_target(turf/target_turf, datum/human_ai_brain/acting_brain)
	if(!acting_brain)
		acting_brain = brain
	if(!acting_brain || !target_turf)
		return FALSE

	for(var/mob/possible_friendly in range(acting_brain.friendly_throw_check_range, target_turf)) // SS220 EDIT: use configurable range from brain
		if((possible_friendly == acting_brain.tied_human) || (acting_brain.setting("grenade_safety") && acting_brain.grenade_would_harm_friendly(possible_friendly)))
			return TRUE

	return FALSE

/// Try only the hostile's immediate neighborhood, never waste a grenade on a distant short landing.
/datum/ai_action/throw_grenade/proc/get_hostile_direction_throw_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/hostile_turf, datum/human_ai_brain/acting_brain)
	if(!acting_brain)
		acting_brain = brain
	if(!tied_human || !hostile_turf)
		return null

	var/effective_throw_range = get_effective_throw_range(grenade)
	if(!isnum(effective_throw_range) || (effective_throw_range <= min_safe_throw_distance))
		return null

	var/turf/best_target
	for(var/turf/candidate in range(1, hostile_turf))
		var/candidate_distance = get_dist(tied_human, candidate)
		if(candidate_distance > effective_throw_range)
			continue
		if(candidate_distance <= min_safe_throw_distance)
			continue
		if(can_throw_to_target(tied_human, grenade, candidate) && !has_friendly_near_throw_target(candidate, acting_brain))
			best_target = candidate
			break

	return best_target

/datum/ai_action/throw_grenade/proc/resolve_throw_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/original_target, datum/human_ai_brain/acting_brain)
	if(!acting_brain)
		acting_brain = brain
	if(can_throw_to_target(tied_human, grenade, original_target) && !has_friendly_near_throw_target(original_target, acting_brain)) // SS220 EDIT: never accept the primary target without the same friendly-area check as fallbacks
		return original_target

	return get_hostile_direction_throw_target(tied_human, grenade, original_target, acting_brain) // SS220 EDIT: clamp toward the hostile instead of choosing an unrelated cardinal fallback

/// Launches an AI grenade in a high arc so intervening allies do not intercept it.
/datum/ai_action/throw_grenade/proc/launch_grenade_to_target(mob/living/carbon/human/tied_human, obj/item/explosive/grenade/grenade, turf/target_turf)
	if(!tied_human || QDELETED(grenade) || !grenade.active || (tied_human.get_active_hand() != grenade) || !target_turf)
		return FALSE
	if(!grenade.try_to_throw(tied_human))
		return FALSE

	var/effective_throw_range = get_effective_throw_range(grenade)
	if(!isnum(effective_throw_range))
		return FALSE

	tied_human.visible_message(SPAN_WARNING("[tied_human] has thrown [grenade]."), null, null, 5)
	if(!tied_human.drop_inv_item_on_ground(grenade, TRUE))
		return FALSE
	var/datum/human_ai_brain/acting_brain = brain
	grenade.throw_atom(target_turf, effective_throw_range, SPEED_SLOW, tied_human, TRUE, HIGH_LAUNCH, PASS_MOB_THRU)
	// Flight yields between turfs; death or action cancellation can detach this action meanwhile.
	if(!QDELETED(acting_brain) && acting_brain.has_valid_tied_human() && acting_brain.tied_human == tied_human)
		acting_brain.consume_combat_grenade_decision()
	return TRUE

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
		return_unprimed_grenade_to_storage(tied_human, grenade)
		finish_async_throw()
		return

	// SS220 EDIT START: resolve throw target BEFORE priming to avoid holding a live grenade
	var/turf/final_target_turf = resolve_throw_target(tied_human, grenade, target_turf)
	if(!final_target_turf)
		log_game("AI GRENADE: async throw aborted — no valid throw target, target=[target_turf], mob=[key_name(tied_human)]")
		return_unprimed_grenade_to_storage(tied_human, grenade)
		finish_async_throw()
		return

	// activation is legal only while this exact grenade is selected.
	if(tied_human.get_active_hand() != grenade)
		return_unprimed_grenade_to_storage(tied_human, grenade)
		finish_async_throw()
		return
	grenade.attack_self(tied_human)
	log_game("AI GRENADE: grenade primed — grenade=[grenade], target=[final_target_turf], mob=[key_name(tied_human)]")
	if(QDELETED(grenade) || !grenade.active)
		log_game("AI GRENADE: async throw aborted after prime — QDELETED=[QDELETED(grenade)], active=[grenade?.active], mob=[key_name(tied_human)]")
		return_unprimed_grenade_to_storage(tied_human, grenade)
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

	// SS220 EDIT START: keep the primed grenade moving toward the previously validated hostile-side turf
	var/turf/emergency_target = resolve_throw_target(tied_human, grenade, target_turf)
	if(!emergency_target)
		for(var/turf/candidate in range(min(grenade.throw_range, 7), tied_human))
			if(can_throw_to_target(tied_human, grenade, candidate) && !has_friendly_near_throw_target(candidate, brain))
				emergency_target = candidate
				break
	if(!emergency_target)
		tied_human.drop_inv_item_on_ground(grenade)
		brain.active_grenade_found = grenade
		log_game("AI GRENADE: no safe release target; dropped grenade and requesting escape at [AREACOORD(tied_human)]")
		finish_async_throw()
		return
	final_target_turf = emergency_target
	// SS220 EDIT END

	tied_human.face_atom(final_target_turf)
	if(!launch_grenade_to_target(tied_human, grenade, final_target_turf))
		log_game("AI GRENADE: launch failed — grenade=[grenade], target=[final_target_turf], mob=[key_name(tied_human)]")
		finish_async_throw()
		return
	log_game("AI GRENADE: high-arc launch called — grenade=[grenade], target=[final_target_turf], mob=[key_name(tied_human)]")
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
	cancel_conflicting_actions() // SS220 EDIT: cancel any already-running move/fire/reload actions before the grenade is primed
	// weapon storage is a required state transition, not an incidental side effect of clearing a hand.
	if(!try_stow_weapon_for_grenade(tied_human))
		log_game("AI GRENADE: throw action aborted — personal weapon could not be stowed, weapon=[brain.primary_weapon], mob=[key_name(tied_human)]")
		return ONGOING_ACTION_COMPLETED
	if(!try_hold_grenade(tied_human, throwing))
		log_game("AI GRENADE: throw action aborted — could not hold grenade, grenade=[throwing], mob=[key_name(tied_human)]")
		return ONGOING_ACTION_COMPLETED

	if(isnum(throwing.throw_range))
		throw_range_override = throwing.throw_range

	var/turf/planned_throw_target = resolve_throw_target(tied_human, throwing, target_turf)
	if(!planned_throw_target)
		log_game("AI GRENADE: throw action aborted — no safe hostile-direction target, distance=[get_dist(tied_human, target_turf)], throw_range=[throw_range_override], mob=[key_name(tied_human)]")
		return_unprimed_grenade_to_storage(tied_human, throwing)
		return ONGOING_ACTION_COMPLETED

	log_game("AI GRENADE: throw action proceeding to async prime — grenade=[throwing], hostile_target=[target_turf], planned_target=[planned_throw_target], mob=[key_name(tied_human)]")
	mid_throw = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_prime_and_throw), tied_human, throwing, planned_throw_target)
	return ONGOING_ACTION_UNFINISHED_BLOCK

#undef HUMAN_AI_GRENADE_MIN_HOLD_DELAY
#undef HUMAN_AI_GRENADE_POST_PRIME_THROW_DELAY
