GLOBAL_LIST_EMPTY(human_ai_brains)

/datum/human_ai_brain
	/// The human that this brain ties into
	var/mob/living/carbon/human/tied_human

	var/micro_action_delay = 0.2 SECONDS
	var/short_action_delay = 0.5 SECONDS
	var/medium_action_delay = 2 SECONDS
	var/long_action_delay = 5 SECONDS
	/// Global multiplier for all AI action delays
	var/action_delay_mult = 2 // Doubled from 1, gives hAI a believable time between actions

	/// If TRUE, shoots until the target is dead. Else, stops when downed
	var/shoot_to_kill = TRUE

	/// Distance for view checks
	var/view_distance = 6

	/// Should we limit our FOV in case view_distance is more than 7
	var/scope_vision = TRUE

	/// List of whitelisted/blacklisted action datums
	var/list/action_whitelist = null
	var/list/action_blacklist = null

	/// List of current action datums
	var/list/ongoing_actions = list()

	/// Semi-permanent "order" datum. Does not expire
	var/datum/ai_order/current_order

	/// A targeted turf that we should quickly approach
	var/turf/quick_approach

	// SS220 EDIT - START: upstream AI glue hardens modular HALO actions against owner teardown and projectile re-entry
	/// Nearby turfs that we're watching for bullets
	var/list/detection_turfs = list()
	/// Prevent repeated projectile detection re-entry in the same tick
	var/atom/movable/last_detected_projectile
	var/last_detected_projectile_time = -1
	// SS220 EDIT - END

	/// If TRUE, then we're actively fighting someone or saw a bullet go by or saw someone else go into combat
	var/in_combat = FALSE

	/// The minimum amount of time that can pass before this AI can leave combat
	var/combat_decay_time_min = 15 SECONDS
	/// The maximum amount of time that can pass before this AI can leave combat
	var/combat_decay_time_max = 30 SECONDS
	/// Minimum spacing between AI combat voicelines to avoid runaway chatter loops in prolonged fights.
	var/combat_voiceline_cooldown_time = 4 SECONDS

	/// If this AI can seek cover while not possessing a gun
	var/cover_without_gun = FALSE

	/// The chance that the AI will leave cover when exiting combat
	var/peek_cover_chance = 60

	/// Factions that the AI won't engage in hostilities with. Controlled by the AI's faction
	var/list/friendly_factions = list()
	/// Factions that the AI will not become hostile to unless attacked
	var/list/neutral_factions = list()

	/// The last faction that the AI was/is a part of
	var/previous_faction

	/// If FALSE, cannot be assigned to a squad
	var/can_assign_squad = TRUE

	/// Ref to the latest weapon we've drawn as a melee
	var/obj/item/drawn_melee_weapon

	/// If TRUE, the AI will not move at all
	var/hold_position = FALSE
	/// Optional throttle for nearby item scans. Zero means run every tick.
	var/nearby_item_search_interval = 0
	COOLDOWN_DECLARE(nearby_item_search_cooldown)
	var/nearby_item_search_dirty = FALSE
	var/wake_rethink_queued_at = -1 // SS220 EDIT: wake-up signal should only queue one immediate rethink per tick
	var/last_process_tick = -1 // SS220 EDIT: prevent signal-driven wake rethinks from re-entering the scheduler in the same tick
	COOLDOWN_DECLARE(combat_voiceline_cooldown)

/datum/human_ai_brain/New(mob/living/carbon/human/tied_human)
	. = ..()
	src.tied_human = tied_human
	RegisterSignal(tied_human, COMSIG_PARENT_QDELETING, PROC_REF(on_human_delete))
	RegisterSignal(tied_human, COMSIG_HUMAN_EQUIPPED_ITEM, PROC_REF(on_item_equip))
	RegisterSignal(tied_human, COMSIG_HUMAN_UNEQUIPPED_ITEM, PROC_REF(on_item_unequip))
	RegisterSignal(tied_human, COMSIG_MOB_PICKUP_ITEM, PROC_REF(on_item_pickup))
	RegisterSignal(tied_human, COMSIG_MOB_DROP_ITEM, PROC_REF(on_item_drop))
	RegisterSignal(tied_human, COMSIG_MOB_DEATH, PROC_REF(on_human_death)) // SS220 EDIT: HALO death guard should tear down AI and force corpses prone immediately
	RegisterSignal(tied_human, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(tied_human, COMSIG_HUMAN_BULLET_ACT, PROC_REF(on_shot))
	RegisterSignal(tied_human, COMSIG_HUMAN_HANDCUFFED, PROC_REF(on_handcuffed))
	RegisterSignal(tied_human, COMSIG_HUMAN_GET_AI_BRAIN, PROC_REF(get_ai_brain))
	RegisterSignal(tied_human, COMSIG_HUMAN_SET_SPECIES, PROC_REF(on_species_change))
	RegisterSignal(tied_human, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position_change)) // SS220 EDIT: standing back up should wake shared human AI immediately
	GLOB.human_ai_brains += src
	setup_detection_radius()
	appraise_inventory()
	tied_human.a_intent_change(INTENT_DISARM)

/datum/human_ai_brain/Destroy(force, ...)
	GLOB.human_ai_brains -= src
	tied_human = null

	reset_ai()

	return ..()

/datum/human_ai_brain/proc/has_valid_tied_human()
	return tied_human && !QDELETED(tied_human) && !isnull(tied_human.loc)

/datum/human_ai_brain/proc/reset_ai()
	end_cover()
	clear_detection_radius()
	wake_rethink_queued_at = -1 // SS220 EDIT: reset must always cancel deferred wake-up recovery before owner teardown finishes

	in_combat = FALSE
	active_grenade_found = null // SS220 EDIT: reset stale grenade threat state so AI can leave throw-back mode cleanly
	last_detected_projectile = null // SS220 EDIT: clear projectile detection debounce when brain is reset
	last_detected_projectile_time = -1
	target_turf = null
	shot_at = null
	drawn_melee_weapon = null
	primary_weapon = null
	gun_data = null
	lose_target()

	for(var/action in ongoing_actions)
		qdel(action)

	ongoing_actions.Cut()
	to_pickup.Cut()
	lose_injured_ally()
	invalidate_nearby_item_search()

/datum/human_ai_brain/process(delta_time)
	last_process_tick = world.time // SS220 EDIT: track scheduler entry to guard same-tick wake rethinks
	wake_rethink_queued_at = -1 // SS220 EDIT: any queued wake rethink has been serviced once processing starts
	if(!has_valid_tied_human()) // SS220 EDIT: upstream process loop must no-op once modular AI owner is gone
		clear_detection_radius() // SS220 EDIT: stop listening to turf signals once the owner is gone
		reset_ai()
		return

	if(tied_human.stat == DEAD) // SS220 EDIT: dead HALO AI must never remain in the wake-up recovery path
		clear_detection_radius()
		wake_rethink_queued_at = -1 // SS220 EDIT: death fallback must kill any queued wake rethink that survived until process()
		for(var/action in ongoing_actions)
			qdel(action)
		ongoing_actions.Cut()
		lose_target()
		if(!tied_human.resting)
			tied_human.set_resting(TRUE, TRUE)
		else
			tied_human.set_lying_down()
		return

	if(tied_human.is_mob_incapacitated())
		clear_detection_radius() // SS220 EDIT: stunned or dead AI should not keep turf-enter listeners alive
		for(var/action in ongoing_actions)
			qdel(action)
		ongoing_actions.Cut()
		lose_target()
		return

	if(!length(detection_turfs))
		setup_detection_radius() // SS220 EDIT: restore projectile detection after recovering from incap or reset

	// SS220 EDIT - START: hardcrit AIs should keep resting until the crit loop and knockdown pressure are truly gone
	var/should_force_resting = ((locate(/datum/effects/crit) in tied_human.effects_list) && (tied_human.status_flags & CANKNOCKOUT))
	if(should_force_resting)
		if(!tied_human.resting)
			tied_human.set_resting(TRUE, TRUE)
		else
			tied_human.set_lying_down() // SS220 EDIT: crit-resting AI can keep a stale standing transform unless prone is re-asserted through the shared helper
		clear_detection_radius() // SS220 EDIT: prone hardcrit AI should not keep live projectile listeners or continue active combat movement
		for(var/action in ongoing_actions)
			qdel(action)
		ongoing_actions.Cut()
		to_pickup.Cut() // SS220 EDIT: lying crit AI must drop stale pickup goals so it does not keep chasing far-away weapons after forced prone
		invalidate_nearby_item_search()
		return
	else if((tied_human.stat == CONSCIOUS) && tied_human.resting && !HAS_TRAIT(tied_human, TRAIT_FLOORED))
		// SS220 EDIT - START: final stand-up gate must stay exactly aligned with the existing wake rethink eligibility rules
		if(has_valid_tied_human() && !tied_human.client && !tied_human.buckled && (tied_human.stat == CONSCIOUS) && !tied_human.is_mob_incapacitated())
			tied_human.set_resting(FALSE, TRUE)
		// SS220 EDIT - END
	// SS220 EDIT - END

	if(tied_human.buckled)
		tied_human.set_buckled(FALSE) // AI never buckle themselves into chairs at the moment, change if this becomes the case

	if(!current_target)
		set_target(get_target())

	if(current_target)
		enter_combat()

	if(!iszombie(tied_human) && should_run_nearby_item_search())
		item_search(range(2, tied_human))

	// List all allowed action types for AI to consider
	var/list/allowed_actions = action_whitelist || (GLOB.AI_actions.Copy() - action_blacklist)
	for(var/datum/ongoing_action as anything in ongoing_actions)
		if(is_type_in_list(ongoing_action, allowed_actions))
			allowed_actions -= ongoing_action.type

	// Create assoc list of selected AI actions and their weight
	var/list/possible_actions = list()
	for(var/action_type in shuffle(allowed_actions))
		var/datum/ai_action/glob_ref = GLOB.AI_actions[action_type]
		var/weight = glob_ref.get_weight(src)
		if(weight) // No weight means we shouldn't consider this action at all
			possible_actions[action_type] = weight

	// Sorts all allowed actions by their weight
	var/list/sorted_actions = sortTim(possible_actions, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	// Choose what actions to start in current process() iteration
	for(var/action_type as anything in sorted_actions)
		var/datum/ai_action/possible_action = GLOB.AI_actions[action_type]

		var/list/conflicting_actions = possible_action.get_conflicts(src)
		for(var/datum/ai_action/ongoing_action as anything in ongoing_actions)
			if(ongoing_action.type in conflicting_actions)
				possible_action = null
				break

		if(!possible_action)
			continue

		ongoing_actions += new action_type(src)
#if defined(TESTING) && defined(HUMAN_AI_TESTING)
		message_admins("action of type [action_type] was added to [tied_human.real_name]")
#endif

	for(var/datum/ai_action/action as anything in ongoing_actions)
		var/retval = action.trigger_action()
		switch(retval)
			if(ONGOING_ACTION_UNFINISHED_BLOCK)
				return
			if(ONGOING_ACTION_COMPLETED)
				qdel(action)

/datum/human_ai_brain/proc/set_target(mob/living/new_target)
	if(!new_target)
		return

	RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_delete), TRUE)
	RegisterSignal(new_target, COMSIG_MOB_DEATH, PROC_REF(on_target_death), TRUE)
	RegisterSignal(new_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_move), TRUE)
	current_target = new_target
	target_turf = get_turf(current_target)
	invalidate_nearby_item_search()

/datum/human_ai_brain/proc/lose_target()
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
		UnregisterSignal(current_target, COMSIG_MOB_DEATH)
		UnregisterSignal(current_target, COMSIG_MOVABLE_MOVED)
	current_target = null
	invalidate_nearby_item_search()

/datum/human_ai_brain/proc/should_run_nearby_item_search()
	if(halo_should_suspend_nearby_item_search())
		return FALSE

	if(nearby_item_search_interval <= 0)
		return TRUE

	if(!nearby_item_search_dirty && !COOLDOWN_FINISHED(src, nearby_item_search_cooldown))
		return FALSE

	nearby_item_search_dirty = FALSE
	COOLDOWN_START(src, nearby_item_search_cooldown, nearby_item_search_interval)
	return TRUE

/datum/human_ai_brain/proc/invalidate_nearby_item_search()
	nearby_item_search_dirty = TRUE

/datum/human_ai_brain/proc/update_target_pos()
	if(!has_valid_tied_human())
		target_turf = null
		return

	if(current_target)
		if(tied_human in viewers(view_distance, current_target))
			target_turf = get_turf(current_target)
		else
			COOLDOWN_START(src, fire_offscreen, 2 SECONDS)
			lose_target()

/datum/human_ai_brain/proc/on_target_delete(datum/source, force)
	SIGNAL_HANDLER
	lose_target()
	target_turf = null

/datum/human_ai_brain/proc/on_target_death(datum/source)
	SIGNAL_HANDLER
	lose_target()
	target_turf = null

/datum/human_ai_brain/proc/on_target_move(atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	update_target_pos()

/datum/human_ai_brain/proc/on_human_delete(datum/source, force)
	SIGNAL_HANDLER
	clear_detection_radius() // SS220 EDIT: aggressively tear down brain state before component qdel catches up
	reset_ai()
	wake_rethink_queued_at = -1 // SS220 EDIT: owner delete must not leave a queued wake rethink pointing at a null tied human
	tied_human = null

/datum/human_ai_brain/proc/on_human_death(datum/source)
	SIGNAL_HANDLER
	reset_ai()
	wake_rethink_queued_at = -1 // SS220 EDIT: death signal must immediately invalidate any deferred wake processing
	if(!has_valid_tied_human() || (tied_human.stat != DEAD))
		return
	if(tied_human.buckled) // SS220 EDIT: only the direct death path should release forced-standing buckle state
		tied_human.buckled.unbuckle()
	if(!tied_human.resting)
		tied_human.set_resting(TRUE, TRUE)
	else
		tied_human.set_lying_down()

/datum/human_ai_brain/proc/on_species_change(datum/source, new_species)
	SIGNAL_HANDLER
	if((new_species == SPECIES_YAUTJA) || (new_species == SPECIES_ZOMBIE))
		ignore_looting = TRUE
	else
		ignore_looting = FALSE

/datum/human_ai_brain/proc/on_body_position_change(datum/source, new_position, old_position)
	SIGNAL_HANDLER
	if((new_position != STANDING_UP) || (old_position != LYING_DOWN))
		return

	if(!has_valid_tied_human() || tied_human.client || tied_human.buckled || (tied_human.stat != CONSCIOUS) || tied_human.is_mob_incapacitated())
		return

	invalidate_nearby_item_search() // SS220 EDIT: wake-up should immediately invalidate idle pickup/grenade scan throttles
	if(current_target)
		update_target_pos() // SS220 EDIT: refresh transient combat targeting state after knockdown recovery

	if((last_process_tick == world.time) || (wake_rethink_queued_at == world.time))
		return

	wake_rethink_queued_at = world.time
	INVOKE_ASYNC(src, PROC_REF(run_wake_rethink), world.time) // SS220 EDIT: queue exactly one no-sleep rethink outside the signal stack

/datum/human_ai_brain/proc/run_wake_rethink(queued_tick)
	if(QDELETED(src) || (wake_rethink_queued_at != queued_tick))
		return

	wake_rethink_queued_at = -1
	if(!has_valid_tied_human() || tied_human.client || tied_human.buckled || (tied_human.stat != CONSCIOUS) || tied_human.is_mob_incapacitated())
		return

	if((last_process_tick == queued_tick) || (last_process_tick == world.time))
		return

	process(0) // SS220 EDIT: reuse the existing shared AI loop instead of inventing a separate wake-up behavior

/datum/human_ai_brain/proc/setup_detection_radius()
	if(!has_valid_tied_human())
		clear_detection_radius()
		return

	if(length(detection_turfs))
		clear_detection_radius()

	for(var/turf/open/floor in range(1, tied_human))
		RegisterSignal(floor, COMSIG_TURF_ENTERED, PROC_REF(on_detection_turf_enter))
		detection_turfs += floor

/datum/human_ai_brain/proc/clear_detection_radius()
	for(var/turf/open/floor as anything in detection_turfs)
		UnregisterSignal(floor, COMSIG_TURF_ENTERED)

	detection_turfs.Cut()

/datum/human_ai_brain/proc/on_detection_turf_enter(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	if(!has_valid_tied_human())
		return

	if(tied_human.client)
		return

	if(entering == tied_human)
		return

	if(istype(entering, /obj/projectile))
		var/obj/projectile/bullet = entering
		if((last_detected_projectile == bullet) && (last_detected_projectile_time == world.time)) // SS220 EDIT: debounce same-tick projectile re-entry storms
			return
		last_detected_projectile = bullet
		last_detected_projectile_time = world.time
		if(!bullet.firer)
			return

		enter_combat()

		if(length(neutral_factions))
			if(ismob(bullet.firer))
				var/mob/mob_firer = bullet.firer
				if(mob_firer.faction in neutral_factions)
					on_neutral_faction_betray(mob_firer.faction)

			else if(isdefenses(bullet.firer))
				var/obj/structure/machinery/defenses/defense_firer = bullet.firer
				for(var/faction in defense_firer.faction_group)
					if(faction in neutral_factions)
						on_neutral_faction_betray(faction)

		if(faction_check(bullet.firer))
			return

		if(get_dist(tied_human, bullet.firer) <= view_distance)
			set_target(bullet.firer)
		else
			COOLDOWN_START(src, fire_offscreen, 4 SECONDS)
			target_turf = get_turf(bullet.firer)

/datum/human_ai_brain/proc/on_move(atom/oldloc, direction, forced)
	if(!has_valid_tied_human())
		return

	setup_detection_radius()

	if(in_cover && (get_dist(tied_human, current_cover) > gun_data?.minimum_range))
		end_cover()

	update_target_pos()

/datum/human_ai_brain/proc/enter_combat()
	SIGNAL_HANDLER
	if(!has_valid_tied_human())
		return

	if(squad_id) // call for help
		var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
		for(var/datum/human_ai_brain/squaddie as anything in squad.ai_in_squad)
			if(!squaddie.has_valid_tied_human())
				continue
			if(squaddie.target_turf)
				continue
			if(get_dist(squaddie.tied_human, tied_human) > squaddie.view_distance)
				continue
			if(!squaddie.can_target(current_target))
				continue
			squaddie.target_turf = target_turf

	if(tied_human.client)
		return

	if(!in_combat)
		say_in_combat_line()

	if(isxeno(current_target))
		try_cover(Get_Angle(current_target, tied_human), current_target)

	in_combat = TRUE
	addtimer(CALLBACK(src, PROC_REF(exit_combat)), rand(combat_decay_time_min, combat_decay_time_max), TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)
	SShuman_ai.combat_ever_started = TRUE

/datum/human_ai_brain/proc/exit_combat()
	if(!has_valid_tied_human())
		lose_target()
		target_turf = null
		end_cover()
		in_combat = FALSE
		return

	if(tied_human.client)
		return

	if(in_combat)
		tied_human.a_intent_change(INTENT_DISARM)
		lose_target()
		say_exit_combat_line()
		if(!sniper_home)
			holster_primary()
		holster_melee()

	if(current_cover)
		if(!prob(peek_cover_chance))
			target_turf = null
		end_cover()
	else
		target_turf = null

	in_combat = FALSE

/datum/human_ai_brain/proc/on_shot(datum/source, damage_result, ammo_flags, obj/projectile/bullet)
	SIGNAL_HANDLER
	if(!has_valid_tied_human() || !bullet || !bullet.firer)
		return

	if(tied_human.client)
		return

	enter_combat()

	if(length(neutral_factions))
		if(ismob(bullet.firer))
			var/mob/mob_firer = bullet.firer
			if(mob_firer.faction in neutral_factions)
				on_neutral_faction_betray(mob_firer.faction)

		else if(isdefenses(bullet.firer))
			var/obj/structure/machinery/defenses/defense_firer = bullet.firer
			for(var/faction in defense_firer.faction_group)
				if(faction in neutral_factions)
					on_neutral_faction_betray(faction)

	if(faction_check(bullet.firer))
		return

	if(get_dist(tied_human, bullet.firer) <= view_distance)
		set_target(bullet.firer)
	else
		COOLDOWN_START(src, fire_offscreen, 4 SECONDS)
		target_turf = get_turf(bullet.firer)

	if(!current_cover)
		try_cover(bullet.angle, bullet.firer)
	else if(in_cover)
		on_shot_inside_cover(bullet.angle, bullet.firer)
