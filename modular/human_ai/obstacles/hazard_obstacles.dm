/turf/open/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return HUMAN_AI_OBSTACLE_PASS

/turf/open/human_ai_obstacle_cost(action)
	return OPEN_TURF_PENALTY

/turf/open/space/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return null

/turf/open/gm/river/human_ai_obstacle_cost(action)
	return OPEN_TURF_PENALTY + (covered ? 0 : base_river_slowdown)

/turf/open/gm/river/desert/human_ai_obstacle_cost(action)
	return toxic && !covered ? FIRE_PENALTY : ..()

/obj/flamer_fire/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(iszombie(brain.tied_human) || brain.tied_human.on_fire)
		return HUMAN_AI_OBSTACLE_PASS
	return null

/obj/flamer_fire/human_ai_obstacle_cost(action)
	return FIRE_PENALTY

/turf/closed/wall/resin/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(human_ai_can_damage_obstacle(brain) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_DESTROY))
		return HUMAN_AI_OBSTACLE_DESTROY
	return null

/turf/closed/wall/resin/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return !human_ai_destruction_protected(brain) && brain.obstacle_weapon_force() > 0

/turf/closed/wall/resin/human_ai_obstacle_cost(action)
	return WALL_PENALTY
