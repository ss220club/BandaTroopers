/obj/structure/machinery/door/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(!density)
		return HUMAN_AI_OBSTACLE_PASS
	if(!operating && allowed(brain.tied_human) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_OPEN))
		return HUMAN_AI_OBSTACLE_OPEN
	return null

/obj/structure/machinery/door/human_ai_obstacle_cost(action)
	return action == HUMAN_AI_OBSTACLE_PRY ? LOCKED_DOOR_PENALTY : DOOR_PENALTY

/obj/structure/machinery/door/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(action == HUMAN_AI_OBSTACLE_OPEN)
		try_to_activate_door(brain.tied_human)
		return TRUE
	if(action == HUMAN_AI_OBSTACLE_PRY)
		var/obj/item/crowbar = brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR)
		if(QDELETED(crowbar) || !crowbar.pry_capable)
			return FALSE
		brain.holster_primary()
		brain.equip_item_from_equipment_map(HUMAN_AI_TOOLS, crowbar)
		if(brain.tied_human.get_active_hand() != crowbar)
			return FALSE
		brain.tied_human.do_click(src, "", list())
		if(!QDELETED(crowbar) && brain.has_valid_tied_human())
			brain.store_item(crowbar, brain.storage_has_room(crowbar), HUMAN_AI_TOOLS)
		return TRUE
	return ..()

/obj/structure/machinery/door/airlock/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(!density)
		return HUMAN_AI_OBSTACLE_PASS
	if(operating)
		return null
	if(iszombie(brain.tied_human) && istype(brain.primary_weapon, /obj/item/weapon/zombie_claws) && (welded || locked) && layer == DOOR_CLOSED_LAYER && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_PRY))
		return HUMAN_AI_OBSTACLE_PRY
	if(locked || welded || isElectrified() || panel_open)
		return null
	if(arePowerSystemsOn())
		if(allowed(brain.tied_human) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_OPEN))
			return HUMAN_AI_OBSTACLE_OPEN
		return null
	var/obj/item/crowbar = brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR)
	if(crowbar?.pry_capable && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_PRY))
		return HUMAN_AI_OBSTACLE_PRY
	return null

/obj/structure/machinery/door/airlock/human_ai_execute_obstacle_action(datum/human_ai_brain/brain, action)
	if(action == HUMAN_AI_OBSTACLE_PRY && iszombie(brain.tied_human) && istype(brain.primary_weapon, /obj/item/weapon/zombie_claws))
		brain.unholster_primary()
		brain.ensure_primary_hand(brain.primary_weapon)
		brain.tied_human.a_intent_change(INTENT_DISARM)
		brain.tied_human.do_click(src, "", list())
		return TRUE
	return ..()

/obj/structure/machinery/door/poddoor/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(!density)
		return HUMAN_AI_OBSTACLE_PASS
	var/obj/item/crowbar = brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR)
	if((stat & NOPOWER) && !operating && !unacidable && crowbar?.pry_capable && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_PRY))
		return HUMAN_AI_OBSTACLE_PRY
	return null

// Fire shutters require their own alarm/confirmation workflow; never bypass it.
/obj/structure/machinery/door/firedoor/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	return density ? null : HUMAN_AI_OBSTACLE_PASS

/obj/structure/mineral_door/human_ai_select_obstacle_action(datum/human_ai_brain/brain)
	if(!density)
		return HUMAN_AI_OBSTACLE_PASS
	if(human_ai_can_damage_obstacle(brain) && brain.obstacle_action_allowed(src, HUMAN_AI_OBSTACLE_DESTROY))
		return HUMAN_AI_OBSTACLE_DESTROY
	return null

/obj/structure/mineral_door/human_ai_can_damage_obstacle(datum/human_ai_brain/brain)
	return !human_ai_destruction_protected(brain) && brain.obstacle_weapon_force() > 0

/obj/structure/mineral_door/human_ai_obstacle_cost(action)
	return DOOR_PENALTY
