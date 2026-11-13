/datum/action/xeno_action/activable/throw_hugger/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/carrier/X = owner
	X.throw_hugger(A)
	return ..()

/datum/action/xeno_action/activable/throw_hugger/process_ai(mob/living/carbon/xenomorph/carrier/X, delta_time)
	if(!istype(X) || X.huggers_cur <= 0 || X.action_busy || !action_cooldown_check())
		return

	// Sentries, vehicles and hosts are a waste of a hugger.
	var/mob/living/carbon/target = X.current_target
	if(!can_hug(target, X.hivenumber) || check_for_obstacles_projectile(X, target))
		return

	// Somebody who is down can not dodge, and we walk right up to them instead of keeping our distance.
	var/distance = get_dist(X, target)
	if(!DT_PROB(ai_prob_chance, delta_time) || (distance < 3 && !target.is_mob_incapacitated()) || distance > 8)
		return

	// The first use only takes a hugger out of storage, the second one throws it.
	if(!istype(X.get_active_hand(), /obj/item/clothing/mask/facehugger))
		use_ability_async(target)
	X.start_ai_ability_delay()
	use_ability_async(target)

/datum/action/xeno_action/activable/retrieve_egg/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/carrier/X = owner
	X.retrieve_egg(A)
	return ..()

/datum/action/xeno_action/onclick/set_hugger_reserve/use_ability(atom/Atom)
	var/mob/living/carbon/xenomorph/carrier/carrier = owner
	carrier.huggers_reserved = tgui_input_number(usr,
		"How many facehuggers would you like to keep safe from Observers wanting to join as facehuggers?",
		"How many to reserve?",
		carrier.huggers_reserved, carrier.huggers_max, 0
	)
	to_chat(carrier, SPAN_XENONOTICE("We reserve [carrier.huggers_reserved] facehuggers for ourself."))
	return ..()
