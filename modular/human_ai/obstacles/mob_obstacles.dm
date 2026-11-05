/mob/living/carbon/human/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return HUMAN_AI_OBSTACLE_MOB

/mob/living/carbon/human/human_ai_obstacle_cost(action)
	return HUMAN_PENALTY

/mob/living/carbon/human/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(stat == DEAD)
		return TRUE
	var/mob/living/carbon/human/ai_human = brain.tied_human
	if(brain.faction_check(src))
		if(!iszombie(ai_human))
			var/random_intent = pick(INTENT_DISARM, INTENT_HARM, INTENT_HELP, INTENT_DISARM, INTENT_HARM)
			ai_human.a_intent = random_intent
			if(get_ai_brain())
				a_intent = random_intent
		return TRUE
	if(body_position == LYING_DOWN && brain.current_target != src)
		return TRUE
	if(!brain.unholster_any_weapon())
		ai_human.a_intent_change(INTENT_HARM)
	ai_human.do_click(src, "", list())
	ai_human.face_atom(src)
	return TRUE

/mob/living/carbon/xenomorph/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return HUMAN_AI_OBSTACLE_MOB

/mob/living/carbon/xenomorph/human_ai_obstacle_cost(action)
	return XENO_PENALTY

/mob/living/carbon/xenomorph/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(brain.faction_check(src))
		return TRUE
	if(!brain.unholster_any_weapon())
		brain.tied_human.a_intent_change(INTENT_HARM)
	brain.tied_human.do_click(src, "", list())
	brain.tied_human.face_atom(src)
	return TRUE
