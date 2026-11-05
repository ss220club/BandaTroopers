/datum/human_ai_brain
	/// What items the AI considers when trying to heal brute damage
	var/static/list/brute_heal_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/reagent_container/hypospray/autoinjector/bicaridine,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/merabica,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/tool/weldingtool,
		/obj/item/stack/nanopaste,
	)

	/// What items the AI considers when trying to heal burn damage
	var/static/list/burn_heal_items = list(
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/reagent_container/hypospray/autoinjector/kelotane,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/keloderm,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/stack/cable_coil,
		/obj/item/stack/nanopaste,
	)

	/// What items the AI considers when trying to heal toxin damage
	var/static/list/tox_heal_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/antitoxin,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/antitox,
		/obj/item/storage/pill_bottle/tricord,
	)

	/// What items the AI considers when trying to heal oxygen damage
	var/static/list/oxy_heal_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/dexalinp,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/dexalin,
		/obj/item/storage/pill_bottle/dexalinplus,
		/obj/item/storage/pill_bottle/tricord,
	)

	/// What items the AI considers when trying to fix bleeding
	var/static/list/bleed_heal_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
	)

	/// What items the AI considers when trying to fix bonebreaks
	var/static/list/bonebreak_heal_items = list(
		/obj/item/stack/medical/splint,
	)

	/// What items the AI considers when trying to reduce pain
	var/static/list/painkiller_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/tramadol,
		/obj/item/reagent_container/hypospray/autoinjector/oxycodone,
		/obj/item/storage/pill_bottle/tramadol,
	)

	/// Requires this much damage of one type to consider it a problem
	var/damage_problem_threshold = 5
	/// Pain percentage (out of 100) for the AI to consider using painkillers
	var/pain_percentage_threshold = 1
	/// How far the AI can notice an ally who needs medical assistance. This does not affect combat vision.
	var/medical_view_distance = 10

	/// Are we currently treating someone?
	var/healing_someone = FALSE
	/// Incremented whenever treatment starts or combat cancels it, preventing delayed medical work from resuming.
	var/treatment_generation = 0

	/// Reference for found injured ally
	var/mob/living/carbon/human/found_injured_ally
	/// Scoped to synchronous preemption/selection; never an authorization to administer treatment.
	var/ally_treatment_decision_active = FALSE
	var/ally_treatment_decision_checked = FALSE
	var/mob/living/carbon/human/ally_treatment_decision_target

	/// Cooldown on using pills to avoid OD. This isn't the best solution as it prevents the AI from using more than 1 pill of any kind every 20s, but it'll work for now
	COOLDOWN_DECLARE(pill_use_cooldown)

	/// How many stacks of "wasn't able to treat" this AI has. If these stacks pass a certain threshold, the AI can no longer be treated by others for a small period of time. Stacks decay when not being accumulated
	var/cant_be_treated_stacks = 0

	/// How many stacks are required to stop this AI from recieving treatment
	var/treatment_stack_threshold = 10

/datum/human_ai_brain/proc/set_injured_ally(mob/living/carbon/human/new_target)
	if(!new_target)
		return
	if(found_injured_ally == new_target)
		return
	lose_injured_ally()

	RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(lose_injured_ally), TRUE)
	RegisterSignal(new_target, COMSIG_MOB_DEATH, PROC_REF(lose_injured_ally), TRUE)
	found_injured_ally = new_target

/datum/human_ai_brain/proc/lose_injured_ally()
	if(found_injured_ally)
		UnregisterSignal(found_injured_ally, COMSIG_PARENT_QDELETING)
		UnregisterSignal(found_injured_ally, COMSIG_MOB_DEATH)
	found_injured_ally = null

/datum/human_ai_brain/proc/get_injured_ally()
	// SS220 EDIT - START: treat the most injured actionable ally; distance only breaks equal-priority ties
	var/mob/living/carbon/human/best_target
	var/best_priority = -INFINITY
	var/best_distance = INFINITY

	for(var/mob/living/carbon/human/possible_buddy as anything in GLOB.alive_human_list)
		if(possible_buddy == tied_human)
			continue
		// Preserve contained patients and tie ordering, but reject distant mobs before treatment or LOS work.
		if(possible_buddy.z != tied_human.z || get_dist(tied_human, possible_buddy) > medical_view_distance)
			continue

		if(!faction_check(possible_buddy))
			continue

		if(!can_treat_ally(possible_buddy))
			continue

		if(!medical_target_in_view(possible_buddy))
			continue

		var/distance = get_dist(tied_human, possible_buddy)
		var/treatment_priority = get_ally_treatment_priority(possible_buddy)
		if(treatment_priority < best_priority || (treatment_priority == best_priority && distance >= best_distance))
			continue

		best_target = possible_buddy
		best_priority = treatment_priority
		best_distance = distance

	// SS220 EDIT - END
	return best_target

/// Medical awareness is intentionally wider than combat vision, but still respects z-level and line of sight.
/datum/human_ai_brain/proc/medical_target_in_view(mob/living/carbon/human/target)
	if(QDELETED(target) || tied_human.z != target.z)
		return FALSE
	if(get_dist(tied_human, target) > medical_view_distance)
		return FALSE
	return (tied_human in viewers(medical_view_distance, target))

/datum/human_ai_brain/proc/get_ally_treatment_priority(mob/living/carbon/human/target)
	var/priority = max(0, target.maxHealth - target.health)
	if(target.is_bleeding())
		priority += target.maxHealth
	if(target_has_unsplinted_fracture(target))
		priority += target.maxHealth
	return priority

/// Returns the closest free turf from which the AI can treat the patient without trying to occupy their turf.
/datum/human_ai_brain/proc/get_ally_treatment_approach_turf(mob/living/carbon/human/target)
	// SS220 EDIT - START: treatment pathing must stop beside a dense patient instead of pathing onto them
	if(QDELETED(target) || !has_valid_tied_human() || tied_human.z != target.z)
		return
	if(get_dist(tied_human, target) <= 1)
		return get_turf(tied_human)

	var/turf/target_turf = get_turf(target)
	var/turf/best_turf
	var/best_distance = INFINITY
	var/list/crowded_treatment_turfs = list()
	for(var/turf/candidate as anything in target_turf.AdjacentTurfs())
		if(candidate == target_turf || candidate.density)
			continue
		if(!quick_order_step_within_boundary(candidate)) // SS220 EDIT: Hold Position permits treatment movement only inside its boundary
			continue

		var/permanently_blocked = FALSE
		var/temporarily_occupied = FALSE
		for(var/atom/movable/blocker as anything in candidate)
			if(!blocker.density)
				continue
			if(ismob(blocker))
				temporarily_occupied = TRUE
				continue
			permanently_blocked = TRUE
			break

		if(permanently_blocked)
			continue
		if(temporarily_occupied)
			crowded_treatment_turfs += candidate
			continue

		var/candidate_distance = get_dist(tied_human, candidate)
		if(candidate_distance >= best_distance)
			continue
		best_turf = candidate
		best_distance = candidate_distance

	if(best_turf)
		return best_turf

	// If allies temporarily fill every usable treatment position, close to the second ring and retry next tick.
	for(var/turf/crowded_turf as anything in crowded_treatment_turfs)
		for(var/turf/staging_turf as anything in crowded_turf.AdjacentTurfs())
			if(staging_turf == target_turf || get_dist(staging_turf, target_turf) > 2 || is_blocked_turf(staging_turf))
				continue
			if(!quick_order_step_within_boundary(staging_turf)) // SS220 EDIT: fallback treatment staging also obeys Hold Position
				continue
			var/staging_distance = get_dist(tied_human, staging_turf)
			if(staging_distance >= best_distance)
				continue
			best_turf = staging_turf
			best_distance = staging_distance
	return best_turf
	// SS220 EDIT - END

/datum/human_ai_brain/proc/target_has_unsplinted_fracture(mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if((limb.status & LIMB_BROKEN) && !(limb.status & LIMB_SPLINTED))
			return TRUE
	return FALSE

/// Whether an existing ally-treatment target is still safe and useful to pursue.
/datum/human_ai_brain/proc/can_treat_ally(mob/living/carbon/human/possible_buddy)
	if(QDELETED(possible_buddy) || possible_buddy == tied_human || possible_buddy.stat == DEAD)
		return FALSE
	if(tied_human.z != possible_buddy.z || !faction_check(possible_buddy))
		return FALSE
	if(!healing_start_check(possible_buddy))
		return FALSE
	return has_usable_treatment(possible_buddy)

/// End the decision snapshot before actions can move, change equipment or start asynchronous treatment.
/datum/human_ai_brain/proc/clear_ally_treatment_decision()
	ally_treatment_decision_active = FALSE
	ally_treatment_decision_checked = FALSE
	ally_treatment_decision_target = null

/// Returns the patient that should preempt routine movement or looting, if medical action is currently safe.
/datum/human_ai_brain/proc/get_priority_ally_treatment_target()
	if(has_live_grenade_emergency())
		return
	if(iszombie(tied_human) || healing_someone || current_target)
		return
	var/should_fire_offscreen = (target_turf && !COOLDOWN_FINISHED(src, fire_offscreen))
	if(should_fire_offscreen || !length(equipment_map[HUMAN_AI_HEALTHITEMS]))
		return
	var/mob/living/carbon/human/treatment_target
	if(ally_treatment_decision_active && ally_treatment_decision_checked)
		treatment_target = ally_treatment_decision_target
		// A rejected candidate waits for the next decision, rather than repeating the world scan.
		if(!can_treat_ally(treatment_target) || !medical_target_in_view(treatment_target))
			ally_treatment_decision_target = null
			return
	else
		treatment_target = get_injured_ally()
		if(ally_treatment_decision_active)
			ally_treatment_decision_checked = TRUE
			ally_treatment_decision_target = treatment_target
	if(treatment_target)
		// Deleting a conflicting treatment action can clear found_injured_ally during selection.
		set_injured_ally(treatment_target)
	return treatment_target

/// Frees synchronous routine action slots so a safe medical emergency can enter the scheduler this tick.
/datum/human_ai_brain/proc/preempt_routine_actions_for_ally_treatment()
	// SS220 EDIT - START: action weight alone cannot displace an already-running conflicting movement action
	var/mob/living/carbon/human/treatment_target = get_priority_ally_treatment_target()
	if(!treatment_target)
		return

	var/static/list/preemptible_action_types = list(
		/datum/ai_action/item_pickup,
		/datum/ai_action/follow_leader,
		/datum/ai_action/idle_defensive_position, // SS220 EDIT: urgent ally treatment releases a reserved idle post
		/datum/ai_action/patrol_waypoints,
		/datum/ai_action/quick_approach,
		/datum/ai_action/chase_target,
	)
	for(var/datum/ai_action/ongoing_action as anything in ongoing_actions.Copy())
		if(ongoing_action.type in preemptible_action_types)
			qdel(ongoing_action)
	return treatment_target
	// SS220 EDIT - END

/// Prevents ally treatment from repeatedly selecting injuries this AI has no usable supplies for.
/datum/human_ai_brain/proc/has_usable_treatment(mob/living/carbon/human/target)
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(medical_item_can_treat(heal_item, target))
			return TRUE
	return FALSE

// SS220 EDIT - START: one suitability and reagent-safety contract for carried treatment and nearby floor medicine
/datum/human_ai_brain/proc/medical_item_can_treat(obj/item/heal_item, mob/living/carbon/human/target)
	if(!settings_allow_treatment(target) || (!setting("drugs") && (istype(heal_item, /obj/item/reagent_container) || istype(heal_item, /obj/item/storage/pill_bottle))))
		return FALSE
	if(QDELETED(heal_item) || QDELETED(target) || target.stat == DEAD)
		return FALSE
	if(!heal_item.ai_can_use(tied_human, src, target))
		return FALSE
	if((target.getBruteLoss() > damage_problem_threshold) && is_type_in_list(heal_item, brute_heal_items))
		return TRUE
	if(target.is_bleeding() && is_type_in_list(heal_item, bleed_heal_items))
		return TRUE
	if(target_has_unsplinted_fracture(target) && is_type_in_list(heal_item, bonebreak_heal_items))
		return TRUE
	if((target.getFireLoss() > damage_problem_threshold) && is_type_in_list(heal_item, burn_heal_items))
		return TRUE
	if((target.pain?.get_pain_percentage() > pain_percentage_threshold) && is_type_in_list(heal_item, painkiller_items))
		return TRUE
	if((target.getToxLoss() > damage_problem_threshold) && is_type_in_list(heal_item, tox_heal_items))
		return TRUE
	if((target.getOxyLoss() > damage_problem_threshold) && is_type_in_list(heal_item, oxy_heal_items))
		return TRUE
	return FALSE

/datum/human_ai_brain/proc/medical_item_has_target(obj/item/heal_item)
	if(healing_start_check(tied_human) && medical_item_can_treat(heal_item, tied_human))
		return TRUE

	for(var/mob/living/carbon/human/possible_buddy as anything in GLOB.alive_human_list)
		if(possible_buddy.z != tied_human.z || get_dist(tied_human, possible_buddy) > medical_view_distance)
			continue
		if(possible_buddy == tied_human || !faction_check(possible_buddy))
			continue
		if(!healing_start_check(possible_buddy) || !medical_item_can_treat(heal_item, possible_buddy))
			continue
		if(medical_target_in_view(possible_buddy))
			return TRUE
	return FALSE

/// Returns whether transferring this dose would keep every contained reagent at or below its OD threshold.
/datum/human_ai_brain/proc/can_safely_administer_reagents(obj/item/reagent_container/source, mob/living/carbon/human/target, transfer_amount)
	if(!setting("drugs") || !settings_allow_treatment(target))
		return FALSE
	// Patient reagent levels, not a per-medic cooldown, are the shared OD safety contract.
	if(QDELETED(source) || QDELETED(target) || !source.reagents || !target.reagents || source.reagents.total_volume <= 0)
		return FALSE

	var/actual_transfer = min(max(transfer_amount, 0), source.reagents.total_volume)
	if(actual_transfer <= 0)
		return FALSE
	var/transfer_ratio = actual_transfer / source.reagents.total_volume
	for(var/datum/reagent/source_reagent as anything in source.reagents.reagent_list)
		if(source_reagent.overdose <= 0)
			continue
		var/resulting_volume = target.reagents.get_reagent_amount(source_reagent.id) + target.human_ai_pending_dose(source_reagent.id) + (source_reagent.volume * transfer_ratio)
		if(resulting_volume > source_reagent.overdose)
			return FALSE
	return TRUE
// SS220 EDIT - END

/// All medics see the same swallowed-but-not-yet-absorbed medication, including player-fed pills.
/atom/movable
	var/list/human_ai_ingestion_vessels

/atom/movable/proc/human_ai_pending_dose(reagent_id)
	var/amount = 0
	for(var/datum/reagents/vessel/pending as anything in human_ai_ingestion_vessels)
		if(!QDELETED(pending))
			amount += pending.get_reagent_amount(reagent_id)
	return amount

/datum/reagents/vessel
	var/datum/weakref/human_ai_ingestion_patient

/datum/reagents/vessel/proc/human_ai_track_ingestion(atom/movable/patient)
	human_ai_ingestion_patient = WEAKREF(patient)
	LAZYADD(patient.human_ai_ingestion_vessels, src)

/datum/reagents/vessel/Destroy()
	var/atom/movable/patient = human_ai_ingestion_patient?.resolve()
	if(patient)
		LAZYREMOVE(patient.human_ai_ingestion_vessels, src)
	human_ai_ingestion_patient = null
	return ..()

/datum/human_ai_brain/proc/healing_start_check(mob/living/carbon/human/target)
	if(!settings_allow_treatment(target))
		return FALSE
	// SS220 EDIT - START: respond to every actionable injury instead of waiting for 30% total health loss
	return (target.getBruteLoss() > damage_problem_threshold) \
		|| (target.getFireLoss() > damage_problem_threshold) \
		|| (target.getToxLoss() > damage_problem_threshold) \
		|| (target.getOxyLoss() > damage_problem_threshold) \
		|| (target.pain?.get_pain_percentage() > pain_percentage_threshold) \
		|| target.is_bleeding() \
		|| target_has_unsplinted_fracture(target)
	// SS220 EDIT - END

/// Frees the AI's hands for medical work without treating its issued weapon as disposable floor clutter.
/datum/human_ai_brain/proc/prepare_hands_for_treatment()
	// SS220 EDIT - START: unwind and holster the personal weapon before touching carried medicine
	if(primary_weapon && tied_human.is_holding(primary_weapon))
		primary_weapon.unwield(tied_human)
		ensure_primary_hand(primary_weapon)
		if(!holster_primary())
			var/primary_storage = storage_has_room(primary_weapon)
			if(primary_storage)
				store_item(primary_weapon, primary_storage)

	for(var/obj/item/held_item as anything in tied_human.get_hands())
		if(!held_item)
			continue
		if(held_item == primary_weapon)
			continue // Keep issued weapons in the free hand when every valid holster/storage is occupied.
		var/available_storage = storage_has_room(held_item)
		if(available_storage && store_item(held_item, available_storage))
			continue
		tied_human.drop_held_item(held_item)

	if(tied_human.get_active_hand() && !tied_human.get_inactive_hand())
		tied_human.swap_hand()
	return !tied_human.get_active_hand()
	// SS220 EDIT - END

/datum/human_ai_brain/proc/increment_treatment_stacks()
	cant_be_treated_stacks++
	addtimer(CALLBACK(src, PROC_REF(clear_treatment_stacks)), 5 SECONDS, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/datum/human_ai_brain/proc/clear_treatment_stacks()
	cant_be_treated_stacks = 0

/// Releases medical action slots and safely stows held medicine as soon as combat begins.
// SS220 EDIT - START: combat takes priority over both queued and sleeping treatment actions
/datum/human_ai_brain/proc/cancel_treatment_for_combat()
	var/has_treatment_action = FALSE
	for(var/datum/ai_action/ongoing_action as anything in ongoing_actions)
		if(istype(ongoing_action, /datum/ai_action/treat_ally) || istype(ongoing_action, /datum/ai_action/treat_self))
			has_treatment_action = TRUE
			break
	if(!healing_someone && !found_injured_ally && !has_treatment_action)
		return

	treatment_generation++
	healing_someone = FALSE
	lose_injured_ally()

	for(var/datum/ai_action/ongoing_action as anything in ongoing_actions.Copy())
		if(!istype(ongoing_action, /datum/ai_action/treat_ally) && !istype(ongoing_action, /datum/ai_action/treat_self))
			continue
		ongoing_actions -= ongoing_action
		qdel(ongoing_action)

	for(var/obj/item/held_item as anything in tied_human.get_hands())
		if(!held_item || !(held_item in equipment_map[HUMAN_AI_HEALTHITEMS]))
			continue
		return_health_item(held_item)

/// A delayed treatment step may proceed only while it still owns the active generation.
/datum/human_ai_brain/proc/treatment_can_continue(treatment_id, mob/living/carbon/human/target)
	if(!settings_allow_treatment(target))
		return FALSE
	return (treatment_id == treatment_generation) && healing_someone && has_valid_tied_human() && !tied_human.client && !tied_human.is_mob_incapacitated() && !current_target && !has_live_grenade_emergency() && !QDELETED(target) && (target.stat != DEAD) && get_dist(tied_human, target) <= 1

/// Waits for the medical action and restores its item if combat invalidated this treatment meanwhile.
/datum/human_ai_brain/proc/wait_for_treatment(obj/item/heal_item, mob/living/carbon/human/target, treatment_id)
	sleep(short_action_delay * action_delay_mult)
	if(treatment_can_continue(treatment_id, target))
		return TRUE
	if(!QDELETED(heal_item))
		return_health_item(heal_item)
	if(treatment_id == treatment_generation)
		healing_someone = FALSE
	return FALSE
// SS220 EDIT - END

/datum/human_ai_brain/proc/start_healing(mob/living/carbon/human/target)
	set waitfor = FALSE

	var/treatment_id = ++treatment_generation // SS220 EDIT: identify this asynchronous treatment chain
	healing_someone = TRUE
	. = FALSE // if . is TRUE, some form of healing has been done
	if(!treatment_can_continue(treatment_id, target))
		healing_someone = FALSE
		return

	// Prioritize brute, then bleed, then broken bones, then burn, then pain, then tox, then oxy.
	if(target.getBruteLoss() > damage_problem_threshold)
		if(brute_heal(target, treatment_id))
			. = TRUE
	if(!treatment_can_continue(treatment_id, target))
		if(treatment_id == treatment_generation)
			healing_someone = FALSE
		return

	if(target.is_bleeding())
		if(bleed_heal(target, treatment_id))
			. = TRUE
	if(!treatment_can_continue(treatment_id, target))
		if(treatment_id == treatment_generation)
			healing_someone = FALSE
		return

	// Doesn't support bone-healing chems
	if(target_has_unsplinted_fracture(target)) // SS220 EDIT: only apply splints to untreated fractures
		if(bone_heal(target, treatment_id))
			. = TRUE
	if(!treatment_can_continue(treatment_id, target))
		if(treatment_id == treatment_generation)
			healing_someone = FALSE
		return

	if(target.getFireLoss() > damage_problem_threshold)
		if(burn_heal(target, treatment_id))
			. = TRUE
	if(!treatment_can_continue(treatment_id, target))
		if(treatment_id == treatment_generation)
			healing_someone = FALSE
		return

	// This has the issue of the AI taking multiple painkillers if high on pain, despite them not stacking. Not worth fixing atm
	if(target.pain?.get_pain_percentage() > pain_percentage_threshold)
		if(pain_heal(target, treatment_id))
			. = TRUE
	if(!treatment_can_continue(treatment_id, target))
		if(treatment_id == treatment_generation)
			healing_someone = FALSE
		return

	if(target.getToxLoss() > damage_problem_threshold)
		if(tox_heal(target, treatment_id))
			. = TRUE
	if(!treatment_can_continue(treatment_id, target))
		if(treatment_id == treatment_generation)
			healing_someone = FALSE
		return

	if(target.getOxyLoss() > damage_problem_threshold)
		if(oxy_heal(target, treatment_id))
			. = TRUE

	if(treatment_id == treatment_generation)
		healing_someone = FALSE

// SS220 EDIT - START: return reusable medical supplies to their source container before using fallback storage
/datum/human_ai_brain/proc/return_health_item(obj/item/heal_item)
	if(QDELETED(heal_item))
		return FALSE

	// A long medical action may have dropped the item and cleared its transient source record.
	var/original_storage_loc = equipped_items_original_loc[heal_item] || equipment_map[HUMAN_AI_HEALTHITEMS][heal_item]
	if(original_storage_loc)
		equipped_items_original_loc[heal_item] = original_storage_loc

	return store_item(heal_item, storage_has_room(heal_item), HUMAN_AI_HEALTHITEMS, allow_same_turf = TRUE)
// SS220 EDIT - END

/datum/human_ai_brain/proc/brute_heal(mob/living/carbon/human/target, treatment_id)
	. = FALSE
	if(!treatment_can_continue(treatment_id, target))
		return
	var/obj/item/brute_heal
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, brute_heal_items) && heal_item.ai_can_use(tied_human, src, target))
			brute_heal = heal_item
			break

	if(!brute_heal)
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, brute_heal))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(brute_heal, target, treatment_id))
		return FALSE
	brute_heal.ai_use(tied_human, src, target)
	if(QDELETED(brute_heal))
		return

	return_health_item(brute_heal) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] healed brute damage of [target.name] using [brute_heal].")
#endif

/datum/human_ai_brain/proc/bleed_heal(mob/living/carbon/human/target, treatment_id)
	if(!treatment_can_continue(treatment_id, target))
		return FALSE
	var/obj/item/bleed_heal
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, bleed_heal_items) && heal_item.ai_can_use(tied_human, src, target))
			bleed_heal = heal_item
			break

	if(!bleed_heal)
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, bleed_heal))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(bleed_heal, target, treatment_id))
		return FALSE
	bleed_heal.ai_use(tied_human, src, target)
	if(QDELETED(bleed_heal))
		return

	return_health_item(bleed_heal) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] fixed bleeding of [target.name] using [bleed_heal].")
#endif

/datum/human_ai_brain/proc/bone_heal(mob/living/carbon/human/target, treatment_id)
	if(!treatment_can_continue(treatment_id, target))
		return FALSE
	var/obj/item/bone_heal
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, bonebreak_heal_items) && heal_item.ai_can_use(tied_human, src, target))
			bone_heal = heal_item
			break

	if(!bone_heal)
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, bone_heal))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(bone_heal, target, treatment_id))
		return FALSE
	bone_heal.ai_use(tied_human, src, target)
	if(QDELETED(bone_heal))
		return

	return_health_item(bone_heal) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] splinted a fracture of [target.name] using [bone_heal].")
#endif

/datum/human_ai_brain/proc/burn_heal(mob/living/carbon/human/target, treatment_id)
	if(!treatment_can_continue(treatment_id, target))
		return FALSE
	var/obj/item/burn_heal
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, burn_heal_items) && heal_item.ai_can_use(tied_human, src, target))
			burn_heal = heal_item
			break

	if(!burn_heal)
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, burn_heal))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(burn_heal, target, treatment_id))
		return FALSE
	burn_heal.ai_use(tied_human, src, target)
	if(QDELETED(burn_heal))
		return

	return_health_item(burn_heal) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] healed burn damage of [target.name] using [burn_heal].")
#endif

/datum/human_ai_brain/proc/pain_heal(mob/living/carbon/human/target, treatment_id)
	if(!treatment_can_continue(treatment_id, target))
		return FALSE
	var/obj/item/painkiller
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, painkiller_items) && heal_item.ai_can_use(tied_human, src, target))
			painkiller = heal_item
			break

	if(!painkiller)
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, painkiller))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(painkiller, target, treatment_id))
		return FALSE
	painkiller.ai_use(tied_human, src, target)
	if(QDELETED(painkiller))
		return

	return_health_item(painkiller) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] healed pain of [target.name] using [painkiller].")
#endif

/datum/human_ai_brain/proc/tox_heal(mob/living/carbon/human/target, treatment_id)
	if(!treatment_can_continue(treatment_id, target))
		return FALSE
	var/obj/item/tox_heal
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, tox_heal_items) && heal_item.ai_can_use(tied_human, src, target))
			tox_heal = heal_item
			break

	if(!tox_heal)
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, tox_heal))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(tox_heal, target, treatment_id))
		return FALSE
	tox_heal.ai_use(tied_human, src, target)
	if(QDELETED(tox_heal))
		return

	return_health_item(tox_heal) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] healed tox damage of [target.name] using [tox_heal].")
#endif

/datum/human_ai_brain/proc/oxy_heal(mob/living/carbon/human/target, treatment_id)
	if(!treatment_can_continue(treatment_id, target))
		return FALSE
	var/obj/item/oxy_heal
	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(is_type_in_list(heal_item, oxy_heal_items) && heal_item.ai_can_use(tied_human, src, target))
			oxy_heal = heal_item

	if(!oxy_heal)
		healing_someone = FALSE
		return

	if(!prepare_hands_for_treatment()) // SS220 EDIT: medicine needs a free active hand
		healing_someone = FALSE
		return
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, oxy_heal))
		healing_someone = FALSE
		return

	. = TRUE
	healing_someone = TRUE
	if(!wait_for_treatment(oxy_heal, target, treatment_id))
		return FALSE
	oxy_heal.ai_use(tied_human, src, target)
	if(QDELETED(oxy_heal))
		healing_someone = FALSE
		return

	return_health_item(oxy_heal) // SS220 EDIT: restore medical item to its source container
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	to_chat(world, "[tied_human.name] healed oxygen damage of [target.name] using [oxy_heal].")
#endif
