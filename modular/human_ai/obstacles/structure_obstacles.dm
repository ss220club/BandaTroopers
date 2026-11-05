/obj/structure/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(!density)
		return HUMAN_AI_OBSTACLE_PASS
	if(climbable && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_CLIMB_STRUCTURE))
		return HUMAN_AI_OBSTACLE_CLIMB_STRUCTURE
	if(human_ai_can_damage_obstacle(brain) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_DESTROY))
		return HUMAN_AI_OBSTACLE_DESTROY
	return null

/obj/structure/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return breakable && !human_ai_destruction_protected(brain) && brain.obstacle_weapon_force() > 0

/obj/structure/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(action == HUMAN_AI_OBSTACLE_CLIMB_STRUCTURE || action == HUMAN_AI_OBSTACLE_CLIMB_BARRICADE)
		// Adjacency-sensitive: do not call can_climb on remote A* nodes.
		if(!can_climb(brain.tied_human))
			return FALSE
		do_climb(brain.tied_human)
		return TRUE
	return ..()

/obj/structure/platform/human_ai_obstacle_cost(action)
	return DOOR_PENALTY

/obj/structure/barricade/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(!density)
		return HUMAN_AI_OBSTACLE_PASS
	if(!is_wired && climbable && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_CLIMB_BARRICADE))
		return HUMAN_AI_OBSTACLE_CLIMB_BARRICADE
	if(human_ai_can_damage_obstacle(brain) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_DESTROY))
		return HUMAN_AI_OBSTACLE_DESTROY
	return null

/obj/structure/barricade/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return !human_ai_destruction_protected(brain) && brain.obstacle_weapon_force() > force_level_absorption

/obj/structure/barricade/human_ai_obstacle_cost(action)
	return BARRICADE_PENALTY

/obj/structure/barricade/handrail/human_ai_obstacle_cost(action)
	return DOOR_PENALTY

/obj/structure/barricade/plasteel/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(density && !closed && !iszombie(brain.tied_human) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_OPEN))
		return HUMAN_AI_OBSTACLE_OPEN
	return ..()

/obj/structure/barricade/plasteel/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(action == HUMAN_AI_OBSTACLE_OPEN)
		attack_hand(brain.tied_human)
		return TRUE
	return ..()

/obj/structure/machinery/defenses/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return FALSE

/obj/structure/machinery/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return FALSE

/obj/vehicle/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return null
