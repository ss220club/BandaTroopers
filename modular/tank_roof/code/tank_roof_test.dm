/obj/vehicle/multitile/tank/roof_test
	interior_map = null

/obj/vehicle/multitile/tank/twe_tank/roof_test
	interior_map = null

/datum/unit_test/tank_roof/Run()
	test_tank(/obj/vehicle/multitile/tank/roof_test)
	if(!succeeded)
		return
	test_tank(/obj/vehicle/multitile/tank/twe_tank/roof_test)

/datum/unit_test/tank_roof/proc/test_tank(tank_type)
	var/turf/tank_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/obj/vehicle/multitile/tank/tank = new tank_type(tank_turf)
	var/datum/component/tank_roof/roof = tank.GetComponent(/datum/component/tank_roof)
	if(!roof)
		return Fail("[tank_type] has no roof component")

	var/turf/approach = locate(tank.x - (tank.bound_width == 96 ? 2 : 1), tank.y, tank.z)
	var/mob/living/carbon/human/rider = allocate(/mob/living/carbon/human, approach)
	if(!roof.mount(rider))
		return Fail("[tank_type] could not be mounted")
	if(rider.tank_roof_vehicle != tank)
		return Fail("[tank_type] lost its rider")
	var/max_module_layer = tank.layer + HDPT_LAYER_MAX * 0.1
	if(rider.layer <= max_module_layer)
		return Fail("[tank_type] modules hide its rider")
	if(!(rider.flags_pass_temp & PASS_HIGH_OVER_ONLY))
		return Fail("[tank_type] rider cannot cross the hull")
	rider.update_layer()
	if(rider.layer <= max_module_layer)
		return Fail("[tank_type] modules hide its rider after a layer update")

	var/turf/next_roof_turf = get_step(rider, EAST)
	if(!(next_roof_turf in tank.locs) || !rider.Move(next_roof_turf, EAST))
		return Fail("[tank_type] rider cannot walk across the roof")
	if(!roof.has_rider(rider))
		return Fail("[tank_type] loses a walking rider")

	var/obj/projectile/shot = allocate(/obj/projectile, rider.loc)
	shot.firer = rider
	if(tank.get_projectile_hit_boolean(shot))
		return Fail("[tank_type] blocks its rider's shot")
	shot.firer = null
	shot.original = rider
	if(tank.get_projectile_hit_boolean(shot))
		return Fail("[tank_type] blocks a shot aimed at its rider")

	var/old_x = rider.x
	if(!tank.try_move(EAST, TRUE))
		return Fail("[tank_type] could not move")
	if(rider.x != old_x + 1)
		return Fail("[tank_type] left its rider behind")
	if(!(rider.loc in tank.locs))
		return Fail("[tank_type] moved its rider off the roof")
	if(rider.layer <= max_module_layer)
		return Fail("[tank_type] modules hide its rider after movement")

	var/list/rotation = list("rider" = list(rider.tank_roof_offset_x, rider.tank_roof_offset_y))
	tank.rotate_origins(turning_angle(tank.dir, turn(tank.dir, 90)), rotation)
	var/list/expected_offset = rotation["rider"]
	if(!tank.try_rotate(90))
		return Fail("[tank_type] could not rotate")
	if(!(rider.loc in tank.locs))
		return Fail("[tank_type] rotated its rider off the roof")
	if(rider.x != tank.x + expected_offset[1] || rider.y != tank.y + expected_offset[2])
		return Fail("[tank_type] placed its rider incorrectly after rotation")
	if(rider.layer <= max_module_layer)
		return Fail("[tank_type] modules hide its rider after rotation")

	var/turf/off_roof = locate(tank.x - 2, tank.y, tank.z)
	rider.forceMove(off_roof)
	if(rider.tank_roof_vehicle)
		return Fail("[tank_type] kept a dismounted rider")
	if(rider.flags_pass_temp & PASS_HIGH_OVER_ONLY)
		return Fail("[tank_type] kept a rider's pass flag")
	if(rider.layer != initial(rider.layer))
		return Fail("[tank_type] kept a rider's roof layer")

	rider.forceMove(locate(tank.x - (tank.bound_width == 96 ? 2 : 1), tank.y, tank.z))
	if(!roof.mount(rider))
		return Fail("[tank_type] could not be remounted")
	qdel(tank, force = TRUE)
	if(rider.tank_roof_vehicle || (rider.flags_pass_temp & PASS_HIGH_OVER_ONLY))
		return Fail("[tank_type] did not clean up its rider on deletion")
	if(rider.layer != initial(rider.layer))
		return Fail("[tank_type] kept a rider's layer on deletion")
