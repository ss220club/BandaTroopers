/// Shared selection for A* and movement. A destination never waives a blocker.
/atom/proc/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(!brain || QDELETED(ai_human))
		return INFINITY
	var/action = human_ai_select_obstacle_action(brain)
	if(!action || !brain.obstacle_action_allowed(src, action))
		return INFINITY
	return human_ai_obstacle_cost(action)

/atom/proc/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return null

/atom/proc/human_ai_obstacle_cost(action)
	return OBJECT_PENALTY

/// Queued paths grant no permission: resolve again immediately before interacting.
/atom/proc/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!brain || !brain.has_valid_tied_human() || brain.tied_human != ai_human || QDELETED(src) || !Adjacent(ai_human) || ai_human.action_busy)
		return FALSE
	var/action = human_ai_select_obstacle_action(brain)
	if(!action || !brain.obstacle_action_allowed(src, action))
		return FALSE
	return human_ai_execute_obstacle_action(brain, action)

/atom/proc/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(action == HUMAN_AI_OBSTACLE_PASS)
		return TRUE
	if(action != HUMAN_AI_OBSTACLE_DESTROY || !human_ai_can_damage_obstacle(brain))
		return FALSE
	brain.unholster_primary()
	brain.ensure_primary_hand(brain.primary_weapon)
	if(brain.tied_human.get_active_hand() != brain.primary_weapon)
		return FALSE
	brain.tied_human.a_intent_change(INTENT_HARM)
	brain.tied_human.do_click(src, "", list())
	brain.tied_human.face_atom(src)
	return TRUE

/// Unknown atoms are never assumed damageable, even when allowlisted.
/atom/proc/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return FALSE

/datum/human_ai_brain/proc/obstacle_weapon_force()
	if(QDELETED(primary_weapon))
		return 0
	return primary_weapon.force
