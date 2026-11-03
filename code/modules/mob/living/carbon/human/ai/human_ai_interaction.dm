/atom/proc/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(get_turf(src) == target)
		return 0
	return INFINITY

/atom/proc/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!mouse_opacity || (level < 2))
		return FALSE

	var/datum/human_ai_context/context = brain.create_context()
	var/datum/human_tied_controller/controller = context.controller
	if(!controller)
		qdel(context)
		return FALSE

	if(!brain.unholster_any_weapon())
		controller.set_combat_intent()

	controller.click_atom(src)
	qdel(context)
	return TRUE


/////////////////////////////
//         OBJECTS         //
/////////////////////////////
/obj/structure/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(!density)
		return 0

	return OBJECT_PENALTY

/obj/structure/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(climbable)
		if(!ai_human.action_busy)
			do_climb(ai_human)
		return TRUE

	return ..()

/////////////////////////////
//       MINERAL DOOR      //
/////////////////////////////
/obj/structure/mineral_door/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(!brain.has_primary_weapon())
		return INFINITY

	return DOOR_PENALTY

/obj/structure/mineral_door/resin/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	var/obj/item/weapon/gun/primary_weapon = brain.get_primary_weapon()
	if(!primary_weapon)
		return TRUE

	brain.unholster_primary()
	brain.ensure_primary_hand(primary_weapon)

	return ..()


/////////////////////////////
//        PLATFORMS        //
/////////////////////////////
/obj/structure/platform/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return DOOR_PENALTY


/////////////////////////////
//         PODDDOORS       //
/////////////////////////////
/obj/structure/machinery/door/poddoor/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(!(stat & NOPOWER))
		return INFINITY

	var/has_crowbar = brain.find_equipment_by_trait(TRAIT_TOOL_CROWBAR, HUMAN_AI_TOOLS)
	if(density && !operating && !unacidable && has_crowbar)
		return DOOR_PENALTY

	return INFINITY

/obj/structure/machinery/door/poddoor/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	var/datum/human_ai_context/context = brain.create_context()
	if(!(stat & NOPOWER) || !brain.find_equipment_by_trait(TRAIT_TOOL_CROWBAR, HUMAN_AI_TOOLS))
		qdel(context)
		return

	brain.holster_primary()
	var/obj/item/crowbar = brain.find_equipment_by_trait(TRAIT_TOOL_CROWBAR, HUMAN_AI_TOOLS)
	brain.equip_item_from_equipment_map(HUMAN_AI_TOOLS, crowbar)
	var/datum/human_tied_controller/controller = context.controller
	if(controller)
		controller.do_click(src)
	qdel(context)
	brain.store_item(crowbar, brain.storage_has_room(crowbar), HUMAN_AI_TOOLS)

/////////////////////////////
//         AIRLOCK         //
/////////////////////////////
/obj/structure/machinery/door/airlock/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(locked || welded || (isElectrified() && !iszombie(ai_human)) || !arePowerSystemsOn() || panel_open)
		return LOCKED_DOOR_PENALTY

	var/datum/human_ai_context/context = brain.create_context()
	var/datum/human_tied_controller/controller = context.controller
	if(!controller || !controller.can_access(src))
		qdel(context)
		return LOCKED_DOOR_PENALTY
	qdel(context)

	return DOOR_PENALTY

/obj/structure/machinery/door/airlock/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if((welded || locked || isElectrified()) && !iszombie(ai_human))
		return ..()

	if(!(arePowerSystemsOn() || !panel_open))
		return

	if(layer == DOOR_OPEN_LAYER)
		return

	var/datum/human_ai_context/context = brain.create_context()
	var/datum/human_tied_controller/controller = context.controller
	if(!controller)
		qdel(context)
		return

	if(iszombie(ai_human))
		controller.set_safe_intent()
		controller.do_click(src)
		qdel(context)
		return

	brain.holster_primary()
	var/obj/item/crowbar = brain.find_equipment_by_trait(TRAIT_TOOL_CROWBAR, HUMAN_AI_TOOLS)
	brain.equip_item_from_equipment_map(HUMAN_AI_TOOLS, crowbar)
	controller.do_click(src)
	qdel(context)
	brain.store_item(crowbar, brain.storage_has_room(crowbar), HUMAN_AI_TOOLS)

/////////////////////////////
//         HUMANS         //
/////////////////////////////
/mob/living/carbon/human/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return HUMAN_PENALTY

/mob/living/carbon/human/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(stat == DEAD)
		return TRUE

	if(brain.is_friendly_target(src))
		if(!iszombie(ai_human))
			var/random_intent = pick(INTENT_DISARM, INTENT_HARM, INTENT_HELP, INTENT_DISARM, INTENT_HARM) // lower chance of help intent
			var/datum/human_ai_context/context = brain.create_context()
			var/datum/human_tied_controller/controller = context.controller
			if(controller)
				controller.set_raw_intent(random_intent)
			qdel(context)
			if(get_ai_brain())
				a_intent = random_intent
		return TRUE

	if((body_position == LYING_DOWN) && (brain.get_current_target() != src))
		return TRUE

	return ..()

/////////////////////////////
//          XENOS          //
/////////////////////////////
/mob/living/carbon/xenomorph/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return XENO_PENALTY

/mob/living/carbon/xenomorph/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(brain.is_friendly_target(src))
		return TRUE

	return ..()

/////////////////////////////
//         VEHICLES        //
/////////////////////////////
/obj/vehicle/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return VEHICLE_PENALTY


/////////////////////////////
//         SENTRY          //
/////////////////////////////
/obj/structure/machinery/defenses/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return SENTRY_PENALTY

/////////////////////////////
//       BARRICADES        //
/////////////////////////////
/obj/structure/barricade/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!is_wired)
		if(!ai_human.action_busy)
			do_climb(ai_human)
		return TRUE

	return ..()

/obj/structure/barricade/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return BARRICADE_PENALTY

/obj/structure/barricade/plasteel/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(iszombie(ai_human))
		return ..()
	if(!closed) // this means it's closed
		var/datum/human_ai_context/context = brain.create_context()
		var/datum/human_tied_controller/controller = context.controller
		if(controller)
			controller.do_click(src)
		qdel(context)
	else
		. = ..()
	if(!closed)
		close(src)

/obj/structure/barricade/handrail/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return DOOR_PENALTY


/////////////////////////////
//          FIRE           //
/////////////////////////////
/obj/flamer_fire/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/braineno, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(iszombie(ai_human))
		return OPEN_TURF_PENALTY

	if(ai_human.on_fire)
		return FIRE_PENALTY

	return INFINITY // STOP. TOUCHING. THE FLAMES!

/////////////////////////////
//          WALLS          //
/////////////////////////////
/turf/closed/wall/resin/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/braineno, direction, turf/target)
	. = ..()
	if(!.)
		return

	return WALL_PENALTY


/////////////////////////////
//          FLOOR          //
/////////////////////////////
/*
	Sometimes open turfs are passed back as obstacles due to platforms and such,
	generally it's fast so very slight penalty mainly for handling subtypes properly
*/
/turf/open/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return OPEN_TURF_PENALTY

/turf/open/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	return FALSE

/turf/open/space/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return INFINITY


/////////////////////////////
//          RIVER          //
/////////////////////////////
/turf/open/gm/river/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(. && !covered)
		. += base_river_slowdown

/turf/open/gm/river/desert/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(toxic && !covered)
		return FIRE_PENALTY

	return ..()
