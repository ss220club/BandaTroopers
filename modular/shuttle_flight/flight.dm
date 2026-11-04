#define DROPSHIP_TURBULENCE_FREEFALL_PERIOD 15 SECONDS
#define DROPSHIP_TURBULENCE_START_PERIOD 10 SECONDS
#define DROPSHIP_TURBULENCE_PERIOD 5 SECONDS
#define DROPSHIP_TURBULENCE_THROWFORCE_MULTIPLIER 4
#define DROPSHIP_TURBULENCE_GRIPLOSS_PROBABILITY 25
#define DROPSHIP_TURBULENCE_PROBABILITY 50
#define DROPSHIP_TURBULENCE_BONEBREAK_PROBABILITY 10

/obj/docking_port/mobile/marine_dropship
	landing_sound = 'modular/shuttle_flight/sound/dropship_flight_end.ogg'
	ignition_sound = 'modular/shuttle_flight/sound/dropship_flight_start.ogg'
	ambience_flight = 'modular/shuttle_flight/sound/dropship_flight_recurr.ogg'
	var/turbulence = TRUE

/obj/docking_port/mobile/marine_dropship/proc/start_flight_effects()
	if(!turbulence)
		return
	addtimer(CALLBACK(src, PROC_REF(turbulence)), DROPSHIP_TURBULENCE_START_PERIOD)
/obj/docking_port/mobile/marine_dropship/proc/dropship_freefall()
	var/list/affected_list = turbulence_sort_affected()

	for(var/mob/living/affected_mob as anything in affected_list["mobs"])
		to_chat(affected_mob, SPAN_DANGER("The dropship jolts violently as it enters freefall!"))
		shake_camera(affected_mob, DROPSHIP_TURBULENCE_FREEFALL_PERIOD / 2, 1)
		if(!affected_mob.buckled)
			affected_mob.KnockDown(DROPSHIP_TURBULENCE_FREEFALL_PERIOD * 0.1)
			affected_mob.throw_random_direction(2, spin = TRUE)
			affected_mob.apply_armoured_damage(40, ARMOR_MELEE, BRUTE, rand_zone())
			affected_mob.visible_message(SPAN_DANGER("[affected_mob] loses their grip on the floor, flying violenty upwards!"), SPAN_DANGER("You lose your grip on the floor, flying violenty upwards!"))
			if(prob(DROPSHIP_TURBULENCE_BONEBREAK_PROBABILITY * 2) && istype(affected_mob, /mob/living/carbon/human) && affected_mob.body_position == STANDING_UP)
				var/mob/living/carbon/human/affected_human = affected_mob
				var/obj/limb/fracturing_limb = affected_human.get_limb(pick(EXTREMITY_LIMBS))
				fracturing_limb.fracture(100)

	turbulence_item_handle(affected_list["items"])

/obj/docking_port/mobile/marine_dropship/proc/turbulence()
	if(!in_flight())
		return
	var/flight_time_left = timeLeft(1)
	if(flight_time_left >= DROPSHIP_TURBULENCE_PERIOD*2 && !(flight_time_left == INFINITY))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/mobile/marine_dropship, turbulence)), (rand(DROPSHIP_TURBULENCE_PERIOD, max((flight_time_left/2), DROPSHIP_TURBULENCE_PERIOD))))
	if(!prob(DROPSHIP_TURBULENCE_PROBABILITY))
		return

	var/list/affected_list = turbulence_sort_affected()

	for(var/mob/living/affected_mob as anything in affected_list["mobs"])
		to_chat(affected_mob, SPAN_DANGER("The dropship jolts violently!"))
		shake_camera(affected_mob, DROPSHIP_TURBULENCE_PERIOD / 3, 1)
		if(!affected_mob.buckled && affected_mob.body_position == STANDING_UP && affected_mob.m_intent == MOVE_INTENT_RUN)
			if(!prob(DROPSHIP_TURBULENCE_GRIPLOSS_PROBABILITY))
				continue
			to_chat(affected_mob, SPAN_DANGER("You lose your grip!"))
			affected_mob.apply_armoured_damage(50, ARMOR_MELEE, BRUTE, rand_zone())
			affected_mob.KnockDown(DROPSHIP_TURBULENCE_PERIOD * 0.1)
			if(prob(DROPSHIP_TURBULENCE_BONEBREAK_PROBABILITY) && istype(affected_mob, /mob/living/carbon/human))
				var/mob/living/carbon/human/affected_human = affected_mob
				var/obj/limb/fracturing_limb = affected_human.get_limb(pick(ALL_LIMBS))
				fracturing_limb.fracture(100)

	turbulence_item_handle(affected_list["items"])

/obj/docking_port/mobile/marine_dropship/proc/turbulence_item_handle(affected_items)
	for(var/obj/item/affected_item as anything in affected_items)
		if(affected_item.anchored)
			continue
		affected_item.visible_message(SPAN_DANGER("[affected_item] goes flying upwards!"))
		affected_item.throwforce *= DROPSHIP_TURBULENCE_THROWFORCE_MULTIPLIER
		affected_item.throw_random_direction(2, spin = TRUE)
		affected_item.throwforce /= DROPSHIP_TURBULENCE_THROWFORCE_MULTIPLIER

/obj/docking_port/mobile/marine_dropship/proc/turbulence_sort_affected()

	var/list/affected_turfs = list()
	var/list/affected_mobs = list()
	var/list/affected_items = list()

	for(var/area/listed_area as anything in shuttle_areas)
		for(var/turf/affected_turf in listed_area)
			affected_turfs += affected_turf
	for(var/obj/vehicle/multitile/multitile_vehicle as anything in GLOB.all_multi_vehicles)
		if(!multitile_vehicle.interior)
			continue
		if(!locate(multitile_vehicle.loc.loc) in shuttle_areas)
			continue
		var/list/bounds = multitile_vehicle.interior.get_bound_turfs()
		for(var/turf/affected_turf as anything in block(bounds[1], bounds[2]))
			affected_turfs += affected_turf

	for(var/turf/affected_turf as anything in affected_turfs)
		for(var/mob/living/M in affected_turf)
			affected_mobs += M
		for(var/obj/item/I in affected_turf)
			affected_items += I
	return list("mobs" = affected_mobs, "items" = affected_items)
