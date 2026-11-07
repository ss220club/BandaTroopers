/mob/living/carbon/human
	var/obj/vehicle/multitile/tank/tank_roof_vehicle
	var/tank_roof_offset_x = 0
	var/tank_roof_offset_y = 0

/mob/living/carbon/human/update_layer()
	. = ..()
	if(tank_roof_vehicle)
		layer = tank_roof_vehicle.layer + HDPT_LAYER_MAX * 0.1 + 0.01

/obj/vehicle/multitile/tank/Initialize()
	. = ..()
	AddComponent(/datum/component/tank_roof)

/obj/vehicle/multitile/tank/verb/climb_onto_roof()
	set name = "Climb onto roof"
	set category = "Object"
	set src in view(3)

	var/mob/living/carbon/human/climber = usr
	if(!istype(climber))
		return

	var/datum/component/tank_roof/roof = GetComponent(/datum/component/tank_roof)
	if(!roof || !roof.can_mount(climber))
		return

	climber.visible_message(SPAN_NOTICE("[climber] begins climbing onto [src]."), SPAN_NOTICE("You begin climbing onto [src]."))
	if(!do_after(climber, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
		return

	if(QDELETED(src) || QDELETED(roof) || !roof.mount(climber))
		return

	climber.visible_message(SPAN_NOTICE("[climber] climbs onto [src]."), SPAN_NOTICE("You climb onto [src]."))

/obj/vehicle/multitile/tank/get_projectile_hit_boolean(obj/projectile/projectile)
	var/datum/component/tank_roof/roof = GetComponent(/datum/component/tank_roof)
	if(roof && (roof.has_rider(projectile.firer) || roof.has_rider(projectile.original)))
		return FALSE
	return ..()

/datum/component/tank_roof
	var/list/riders = list()
	var/following_vehicle = FALSE

/datum/component/tank_roof/Initialize()
	. = ..()
	if(!istype(parent, /obj/vehicle/multitile/tank))
		return COMPONENT_INCOMPATIBLE

/datum/component/tank_roof/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_tank_moved))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_tank_rotated))

/datum/component/tank_roof/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	for(var/mob/living/carbon/human/rider as anything in riders.Copy())
		dismount(rider)

/datum/component/tank_roof/proc/has_rider(atom/target)
	if(!target)
		return FALSE
	return riders[target]

/datum/component/tank_roof/proc/get_climb_turf(mob/living/carbon/human/climber)
	var/obj/vehicle/multitile/tank/tank = parent
	if(!isturf(climber.loc) || climber.z != tank.z)
		return

	var/turf/closest
	var/closest_distance = INFINITY
	for(var/turf/roof_turf as anything in tank.locs)
		if(roof_turf.density)
			continue
		if(get_dist(climber, roof_turf) > 1)
			continue
		var/distance = abs(climber.x - roof_turf.x) + abs(climber.y - roof_turf.y)
		if(distance >= closest_distance)
			continue
		closest = roof_turf
		closest_distance = distance
	return closest

/datum/component/tank_roof/proc/can_mount(mob/living/carbon/human/climber)
	if(QDELETED(climber) || climber.tank_roof_vehicle || climber.buckled || climber.is_mob_incapacitated() || !(climber.mobility_flags & MOBILITY_MOVE))
		return FALSE
	return !!get_climb_turf(climber)

/datum/component/tank_roof/proc/mount(mob/living/carbon/human/climber)
	if(!can_mount(climber))
		return FALSE

	var/obj/vehicle/multitile/tank/tank = parent
	var/turf/roof_turf = get_climb_turf(climber)
	if(!climber.forceMove(roof_turf))
		return FALSE

	climber.tank_roof_vehicle = tank
	climber.tank_roof_offset_x = climber.x - tank.x
	climber.tank_roof_offset_y = climber.y - tank.y
	climber.add_temp_pass_flags(PASS_HIGH_OVER_ONLY)
	riders[climber] = TRUE
	RegisterSignal(climber, COMSIG_MOVABLE_MOVED, PROC_REF(on_rider_moved))
	RegisterSignal(climber, COMSIG_PARENT_QDELETING, PROC_REF(on_rider_deleted))
	climber.update_layer()
	return TRUE

/datum/component/tank_roof/proc/dismount(mob/living/carbon/human/rider)
	if(!has_rider(rider))
		return

	riders -= rider
	UnregisterSignal(rider, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	rider.tank_roof_vehicle = null
	rider.tank_roof_offset_x = 0
	rider.tank_roof_offset_y = 0
	rider.remove_temp_pass_flags(PASS_HIGH_OVER_ONLY)
	if(!QDELETED(rider))
		rider.update_layer()

/datum/component/tank_roof/proc/on_rider_deleted(mob/living/carbon/human/rider)
	SIGNAL_HANDLER
	dismount(rider)

/datum/component/tank_roof/proc/on_rider_moved(mob/living/carbon/human/rider)
	SIGNAL_HANDLER
	if(following_vehicle)
		return

	var/obj/vehicle/multitile/tank/tank = parent
	if(!(rider.loc in tank.locs))
		dismount(rider)
		return

	rider.tank_roof_offset_x = rider.x - tank.x
	rider.tank_roof_offset_y = rider.y - tank.y
	rider.update_layer()

/datum/component/tank_roof/proc/on_tank_moved(obj/vehicle/multitile/tank/tank)
	SIGNAL_HANDLER
	following_vehicle = TRUE
	for(var/mob/living/carbon/human/rider as anything in riders.Copy())
		var/turf/destination = locate(tank.x + rider.tank_roof_offset_x, tank.y + rider.tank_roof_offset_y, tank.z)
		if(!(destination in tank.locs))
			dismount(rider)
			continue
		rider.forceMove(destination)
	following_vehicle = FALSE

/datum/component/tank_roof/proc/on_tank_rotated(obj/vehicle/multitile/tank/tank, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir)
		return

	var/angle = turning_angle(old_dir, new_dir)
	following_vehicle = TRUE
	for(var/mob/living/carbon/human/rider as anything in riders.Copy())
		var/list/coordinates = list("rider" = list(rider.tank_roof_offset_x, rider.tank_roof_offset_y))
		tank.rotate_origins(angle, coordinates)
		var/list/rotated = coordinates["rider"]
		var/turf/destination = locate(tank.x + rotated[1], tank.y + rotated[2], tank.z)
		if(!(destination in tank.locs))
			dismount(rider)
			continue
		rider.tank_roof_offset_x = rotated[1]
		rider.tank_roof_offset_y = rotated[2]
		rider.forceMove(destination)
	following_vehicle = FALSE
