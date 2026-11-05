#define FRIENDLY_FIRE_ADJACENT_CHECK_START_INDEX 4

/datum/ai_action/fire_at_target
	name = "Fire At Target"
	action_flags = ACTION_USING_HANDS
	var/rounds_burst_fired = 0
	var/currently_firing
	var/list/watched_turfs = list()
	var/followup_fire_timer

/datum/ai_action/fire_at_target/get_weight(datum/human_ai_brain/brain)
	if(world.time < brain.settings_reaction_until)
		return 0
	if(!brain.has_valid_tied_human()) // SS220 EDIT: upstream action glue must not schedule work for detached modular AI owners
		return 0

	if(!brain.in_combat)
		return 0

	if(brain.tried_reload)
		return 0

	if(!brain.primary_weapon)
		return 0

	if(!COOLDOWN_FINISHED(brain, stop_fire_cooldown))
		return 0

	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen) && (brain.gun_data.maximum_range > brain.view_distance))

	if(!brain.current_target && !should_fire_offscreen)
		return 0

	if((get_dist(brain.tied_human, brain.target_turf) > brain.view_distance) && !should_fire_offscreen)
		return 0

	if(brain.halo_should_defer_ranged_fire(brain.current_target || brain.target_turf))
		return 0

	if(!firing_line_check(brain, brain.target_turf))
		return 0

	if(brain.should_reload())
		return 0

	// SS220 EDIT - START: HALO plasma weapons should not queue fire actions while their vent cycle is still active
	if(istype(brain.primary_weapon, /obj/item/weapon/gun/energy/plasma))
		var/obj/item/weapon/gun/energy/plasma/plasma_weapon = brain.primary_weapon
		if(plasma_weapon.dispersing)
			return 0
	// SS220 EDIT - END

	return 10

/datum/ai_action/fire_at_target/Destroy(force, ...)
	stop_firing(brain)
	return ..()

/datum/ai_action/fire_at_target/proc/stop_firing(datum/human_ai_brain/brain)
	currently_firing = FALSE
	rounds_burst_fired = 0
	if(followup_fire_timer)
		deltimer(followup_fire_timer)
		followup_fire_timer = null
	clear_watched_turfs()

	if(!brain)
		return

	if(brain.has_valid_tied_human())
		UnregisterSignal(brain.tied_human, COMSIG_MOB_FIRED_GUN)
	brain.primary_weapon?.set_target(null)

/datum/ai_action/fire_at_target/proc/clear_watched_turfs()
	if(!length(watched_turfs))
		return
	for(var/turf/T as anything in watched_turfs)
		UnregisterSignal(T, COMSIG_TURF_ENTERED)
	watched_turfs.Cut()

/datum/ai_action/fire_at_target/trigger_action()
	. = ..()
	if(brain && world.time < brain.settings_reaction_until)
		stop_firing(brain)
		return ONGOING_ACTION_UNFINISHED
	if(!brain || !brain.has_valid_tied_human()) // SS220 EDIT: firing action exits cleanly if the modular AI owner disappears mid-combat
		return ONGOING_ACTION_COMPLETED

	var/obj/item/weapon/gun/primary_weapon = brain.primary_weapon
	if(!primary_weapon || brain.active_grenade_found || !COOLDOWN_FINISHED(brain, stop_fire_cooldown))
		return ONGOING_ACTION_COMPLETED

	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	if(!brain.current_target && !should_fire_offscreen)
		return ONGOING_ACTION_COMPLETED

	if(brain.halo_should_defer_ranged_fire(brain.current_target || brain.target_turf))
		return ONGOING_ACTION_COMPLETED

	if(currently_firing || followup_fire_timer || !COOLDOWN_FINISHED(brain, fire_overload_cooldown))
		return ONGOING_ACTION_UNFINISHED

	var/mob/living/carbon/tied_human = brain.tied_human
	brain.unholster_primary()
	brain.ensure_primary_hand(primary_weapon)

	// SS220 EDIT - START: establish a real two-handed grip before entering the gun firing loop
	// before_fire() may perform delayed weapon-specific setup asynchronously. Starting fire in
	// the same tick used to make wield-required guns (notably the M56 smartgun and RPGs) fail
	// their core WIELDED check without ever producing a shot callback.
	if((primary_weapon.flags_gun_features & GUN_WIELDED_FIRING_ONLY) && !(primary_weapon.flags_item & WIELDED))
		brain.wield_primary()
		return ONGOING_ACTION_UNFINISHED
	// SS220 EDIT - END

	var/datum/firearm_appraisal/gun_data = brain.gun_data
	gun_data.before_fire(primary_weapon, tied_human, brain)
	// SS220 EDIT: weapon-specific setup must not bypass the core wield requirement either
	if((primary_weapon.flags_gun_features & GUN_WIELDED_FIRING_ONLY) && !(primary_weapon.flags_item & WIELDED))
		return ONGOING_ACTION_UNFINISHED
	if(brain.should_reload())
		if(gun_data?.disposable)
			tied_human.drop_held_item(primary_weapon)
			brain.set_primary_weapon(null)
		return ONGOING_ACTION_COMPLETED

	var/turf/target_turf = brain.target_turf
	if((get_dist(tied_human, target_turf) > gun_data.maximum_range) && !should_fire_offscreen)
		return ONGOING_ACTION_COMPLETED

	if(!firing_line_check(brain, target_turf))
		return ONGOING_ACTION_COMPLETED

	tied_human.face_atom(target_turf)
	tied_human.a_intent_change(INTENT_HARM)

	RegisterSignal(tied_human, COMSIG_MOB_FIRED_GUN, PROC_REF(on_gun_fire), TRUE)

	// Handling point-blank through attack()
	var/atom/movable/current_target = brain.current_target
	if(current_target && (get_dist(tied_human, current_target) <= 1))
		currently_firing = FALSE
		primary_weapon.set_target(null)
		INVOKE_ASYNC(tied_human, TYPE_PROC_REF(/mob, do_click), current_target, "", list())
		return ONGOING_ACTION_UNFINISHED

	primary_weapon?.set_target(target_turf)
	primary_weapon?.start_fire(object = target_turf, bypass_checks = TRUE)
	return ONGOING_ACTION_UNFINISHED

/datum/ai_action/fire_at_target/proc/firing_line_check(datum/human_ai_brain/brain, atom/target, listen = FALSE)
	if(!brain.has_valid_tied_human()) // SS220 EDIT: avoid post-delete signal work from upstream firing callbacks
		return FALSE
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

			if((tile_dist <= 3) && (thing.projectile_coverage >= PROJECTILE_COVERAGE_HIGH)) // short range we allow for higher projectile coverage to be shot over
				return FALSE
			else if((tile_dist > 3) && thing.projectile_coverage >= PROJECTILE_COVERAGE_MEDIUM)
				return FALSE

	var/list/checked_turfs = list()
	for(var/i in 2 to length(turf_list))
		var/turf/tile = turf_list[i]
		var/tile_dist = get_dist(tied_human, tile)
		if(tile_dist > brain.view_distance)
			continue

		var/list/turfs_to_check = list(tile)
		if(i > FRIENDLY_FIRE_ADJACENT_CHECK_START_INDEX)
			for(var/turf/neighbor in tile.AdjacentTurfs())
				turfs_to_check += neighbor

		for(var/turf/T as anything in turfs_to_check)
			if(checked_turfs[T])
				continue
			checked_turfs[T] = TRUE

			for(var/mob/living/possible_friendly in T)
				if(possible_friendly == tied_human)
					continue

				if(possible_friendly.body_position == LYING_DOWN)
					continue

				if(brain.faction_check(possible_friendly))
					return FALSE

	if(listen)
		// Every shot still checks live contents; only unchanged subscriptions are reused.
		for(var/turf/old_turf as anything in watched_turfs)
			if(!checked_turfs[old_turf])
				UnregisterSignal(old_turf, COMSIG_TURF_ENTERED)
		for(var/turf/new_turf as anything in checked_turfs)
			if(!signal_procs?[new_turf]?[COMSIG_TURF_ENTERED])
				RegisterSignal(new_turf, COMSIG_TURF_ENTERED, PROC_REF(cheap_friendly_check))
		watched_turfs = checked_turfs

	return TRUE

/// Delayed semi-auto/burst shots belong to this action, so cancellation also cancels the shot.
/datum/ai_action/fire_at_target/proc/fire_followup(obj/item/weapon/gun/weapon, atom/target)
	HAI_PROFILE_BEGIN(event)
	followup_fire_timer = null
	if(QDELETED(src) || !brain || !brain.has_valid_tied_human())
		HAI_PROFILE_END(event, "fire_followup")
		return
	var/mob/living/carbon/human/owner = brain.tied_human
	if(owner.client || owner.stat == DEAD || owner.is_mob_incapacitated())
		HAI_PROFILE_END(event, "fire_followup")
		return
	if(QDELETED(weapon) || brain.primary_weapon != weapon || QDELETED(target))
		HAI_PROFILE_END(event, "fire_followup")
		return
	var/current_target_matches = brain.current_target == target
	var/offscreen_target_matches = !brain.current_target && target == brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen)
	if(!current_target_matches && !offscreen_target_matches)
		HAI_PROFILE_END(event, "fire_followup")
		return
	if(brain.active_grenade_found || !COOLDOWN_FINISHED(brain, stop_fire_cooldown) || !COOLDOWN_FINISHED(brain, fire_overload_cooldown))
		HAI_PROFILE_END(event, "fire_followup")
		return
	if(brain.halo_should_defer_ranged_fire(target))
		HAI_PROFILE_END(event, "fire_followup")
		return
	if(!firing_line_check(brain, target))
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_followup")
		return
	weapon.start_fire(object = target, bypass_checks = TRUE)
	HAI_PROFILE_END(event, "fire_followup")


/datum/ai_action/fire_at_target/proc/cheap_friendly_check(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	HAI_PROFILE_BEGIN(event)
	if(!brain)
		HAI_PROFILE_END(event, "fire_safety")
		return
	if(entering == brain.tied_human)
		HAI_PROFILE_END(event, "fire_safety")
		return

	if(!istype(entering, /mob/living))
		HAI_PROFILE_END(event, "fire_safety")
		return

	var/mob/living/H = entering
	if(H.body_position == LYING_DOWN)
		HAI_PROFILE_END(event, "fire_safety")
		return

	if(brain.faction_check(H))
		stop_firing(brain)
		qdel(src)
	HAI_PROFILE_END(event, "fire_safety")


/datum/ai_action/fire_at_target/proc/on_gun_fire(datum/source, obj/item/weapon/gun/fired)
	SIGNAL_HANDLER
	HAI_PROFILE_BEGIN(event)

	if(!brain || !brain.has_valid_tied_human()) // SS220 EDIT: late gun callbacks can outlive the modular AI owner for a tick
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	var/turf/target_turf = brain.target_turf

	var/mob/living/carbon/tied_human = brain.tied_human
	tied_human.a_intent_change(INTENT_HARM)

	brain.shot_at = get_turf(target_turf)
	tied_human.face_atom(target_turf)

	currently_firing = TRUE

	var/datum/firearm_appraisal/gun_data = brain.gun_data
	if(brain.should_reload()) // note that bullet removal comes after comsig is triggered
		if(gun_data?.disposable)
			tied_human.drop_held_item(brain.primary_weapon)
			brain.set_primary_weapon(null)
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	var/should_fire_offscreen = (target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	var/shoot_next = brain.current_target

	if(QDELETED(brain.current_target))
		if(!should_fire_offscreen)
			stop_firing(brain)
			qdel(src)
			HAI_PROFILE_END(event, "fire_event")
			return
		shoot_next = target_turf

	else if(ismob(brain.current_target))
		var/mob/mob_target = brain.current_target
		if(mob_target.stat == DEAD)
			stop_firing(brain)
			brain.lose_target()
			qdel(src)
			HAI_PROFILE_END(event, "fire_event")
			return

		var/is_unconscious = (mob_target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in mob_target.effects_list))
		if(!brain.shoot_to_kill && is_unconscious)
			brain.lose_target()
			qdel(src)
			HAI_PROFILE_END(event, "fire_event")
			return

	if(brain.halo_should_defer_ranged_fire(shoot_next))
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	var/count_shot_against_burst_limit = ((brain.primary_weapon.gun_firemode == GUN_FIREMODE_AUTOMATIC) || gun_data.count_every_shot_toward_burst_limit)
	if(count_shot_against_burst_limit)
		rounds_burst_fired++

	if(rounds_burst_fired >= min(gun_data.burst_amount_max, brain.setting("burst_limit")))
		var/short_action_delay = brain.short_action_delay
		COOLDOWN_START(brain, fire_overload_cooldown, max(short_action_delay, short_action_delay * brain.action_delay_mult, brain.setting("burst_pause") * 10))
		stop_firing(brain)
		HAI_PROFILE_END(event, "fire_event")
		return

	if((get_dist(tied_human, shoot_next) > gun_data.maximum_range) && !should_fire_offscreen)
		brain.lose_target()
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	if(brain.current_target && (get_dist(tied_human, brain.current_target) <= 1))
		currently_firing = FALSE
		HAI_PROFILE_END(event, "fire_event")
		return

	if(!firing_line_check(brain, shoot_next, listen = TRUE))
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	// SS220 EDIT - START: HALO covenant AI vents overheating plasma guns before they hard-lock in sustained fire
	if(istype(brain.primary_weapon, /obj/item/weapon/gun/energy/plasma))
		var/obj/item/weapon/gun/energy/plasma/plasma_weapon = brain.primary_weapon
		if(plasma_weapon.heat >= 60)
			var/vent_decision = 0
			if(brain.current_target)
				vent_decision = max(0, -20 + (6 * get_dist(tied_human, brain.current_target)))
			else if(target_turf)
				vent_decision = max(0, -20 + (12 * get_dist(tied_human, target_turf)))

			vent_decision += max(0, plasma_weapon.heat - 65)
			if(prob(max(0, vent_decision)))
				currently_firing = FALSE
				brain.unholster_primary()
				brain.ensure_primary_hand(plasma_weapon)
				plasma_weapon.unload(tied_human)
				HAI_PROFILE_END(event, "fire_event")
				return
			else if(plasma_weapon.heat >= 100)
				currently_firing = FALSE
	// SS220 EDIT - END

	if(istype(brain.primary_weapon, /obj/item/weapon/gun/shotgun))
		currently_firing = FALSE
		if(istype(brain.primary_weapon, /obj/item/weapon/gun/shotgun/pump))
			var/obj/item/weapon/gun/shotgun/pump/shotgun = brain.primary_weapon
			addtimer(CALLBACK(shotgun, TYPE_PROC_REF(/obj/item/weapon/gun/shotgun/pump, pump_shotgun), tied_human), shotgun.pump_delay)
			COOLDOWN_START(brain, stop_fire_cooldown, max(shotgun.pump_delay, shotgun.get_fire_delay()) + 1)
			stop_firing(brain)
			qdel(src)
			HAI_PROFILE_END(event, "fire_event")
			return
		else
			var/obj/item/weapon/gun/shotgun/autoshotty = brain.primary_weapon
			addtimer(CALLBACK(autoshotty, TYPE_PROC_REF(/obj/item/weapon/gun/shotgun, start_fire), tied_human), autoshotty.get_fire_delay()*3)
			COOLDOWN_START(brain, stop_fire_cooldown, max(autoshotty.get_fire_delay()) + 3)
			stop_firing(brain)
			qdel(src)
			HAI_PROFILE_END(event, "fire_event")
			return

	else if(istype(brain.primary_weapon, /obj/item/weapon/gun/rifle/xm51))
		currently_firing = FALSE
		var/obj/item/weapon/gun/rifle/xm51/scattergun = brain.primary_weapon
		addtimer(CALLBACK(scattergun, TYPE_PROC_REF(/obj/item/weapon/gun/rifle/xm51, unique_action), tied_human), scattergun.pump_delay)
		COOLDOWN_START(brain, stop_fire_cooldown, max(scattergun.pump_delay, scattergun.get_fire_delay()) + 1)
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	else if(istype(brain.primary_weapon, /obj/item/weapon/gun/boltaction))
		var/obj/item/weapon/gun/boltaction/bolt = brain.primary_weapon
		currently_firing = FALSE
		addtimer(CALLBACK(bolt, TYPE_PROC_REF(/obj/item/weapon/gun/boltaction, unique_action), tied_human), 1)
		addtimer(CALLBACK(bolt, TYPE_PROC_REF(/obj/item/weapon/gun/boltaction, unique_action), tied_human), bolt.bolt_delay + 1)
		COOLDOWN_START(brain, stop_fire_cooldown, max(bolt.bolt_delay * 2, bolt.get_fire_delay()) + 1)
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return

	// SS220 EDIT - START
	// else if(istype(brain.primary_weapon, /obj/item/weapon/gun/energy/plasma/plasma_pistol))
	// else if(istype(brain.primary_weapon, /obj/item/weapon/gun/rifle/covenant_carbine))
	var/datum/callback/followup_fire_callback = brain.primary_weapon.get_ai_followup_fire_callback(tied_human, brain.current_target)
	if(followup_fire_callback)
		currently_firing = FALSE
		var/followup_fire_delay = brain.primary_weapon.get_ai_followup_fire_delay(tied_human, brain.current_target)
		var/followup_fire_cooldown = brain.primary_weapon.get_ai_followup_fire_cooldown(tied_human, brain.current_target)
		addtimer(followup_fire_callback, followup_fire_delay)
		COOLDOWN_START(brain, stop_fire_cooldown, max(followup_fire_cooldown, followup_fire_delay))
		stop_firing(brain)
		qdel(src)
		HAI_PROFILE_END(event, "fire_event")
		return
	// SS220 EDIT - END

	else if(brain.primary_weapon.gun_firemode == GUN_FIREMODE_SEMIAUTO)
		currently_firing = FALSE
		if(!followup_fire_timer)
			followup_fire_timer = addtimer(CALLBACK(src, PROC_REF(fire_followup), brain.primary_weapon, shoot_next), brain.primary_weapon.get_fire_delay(), TIMER_STOPPABLE)

	else if(brain.primary_weapon.gun_firemode == GUN_FIREMODE_BURSTFIRE)
		currently_firing = FALSE
		if(!followup_fire_timer)
			followup_fire_timer = addtimer(CALLBACK(src, PROC_REF(fire_followup), brain.primary_weapon, shoot_next), brain.primary_weapon.get_burst_fire_delay(), TIMER_STOPPABLE)

	brain.primary_weapon?.set_target(shoot_next)
	HAI_PROFILE_END(event, "fire_event")

#undef FRIENDLY_FIRE_ADJACENT_CHECK_START_INDEX
