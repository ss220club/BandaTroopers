/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test
	interior_map = null

/obj/effect/vehicle_spawner/bastion/armament_test/spawn_vehicle()
	var/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test/tank = new(loc)
	load_hardpoints(tank)
	return tank

/datum/unit_test/bastion_armament/Run()
	var/turf/test_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	new /obj/effect/vehicle_spawner/bastion/armament_test(test_turf)
	var/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test/tank = locate(/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test) in test_turf
	if(!tank)
		return Fail("Bastion spawner did not create a tank")

	var/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/bastion/turret = locate(/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/bastion) in tank.hardpoints
	if(!turret)
		return Fail("Bastion turret is missing")
	var/obj/item/hardpoint/primary/autocannon/twe_tank/bastion/main_gun = locate(/obj/item/hardpoint/primary/autocannon/twe_tank/bastion) in turret.hardpoints
	var/obj/item/hardpoint/primary/aa_quadcannon/bastion/aa_gun = locate(/obj/item/hardpoint/primary/aa_quadcannon/bastion) in tank.hardpoints
	var/obj/item/hardpoint/secondary/small_flamer/bastion/flamer = locate(/obj/item/hardpoint/secondary/small_flamer/bastion) in tank.hardpoints
	var/obj/item/hardpoint/locomotion/treads/ridgeway/bastion/treads = locate(/obj/item/hardpoint/locomotion/treads/ridgeway/bastion) in tank.hardpoints
	if(!turret || !main_gun || !aa_gun || !flamer || !treads)
		return Fail("Bastion armament is incomplete")
	if(tank.icon != 'icons/obj/vehicles/bastion.dmi' || !(tank.icon_state in icon_states(tank.icon)))
		return Fail("Bastion hull has no matching sprite")
	for(var/obj/item/hardpoint/module in list(turret, main_gun, aa_gun, flamer, treads))
		if(module.disp_icon != tank.icon || !("[module.disp_icon_state]_0" in icon_states(module.disp_icon)) || !("[module.disp_icon_state]_1" in icon_states(module.disp_icon)))
			return Fail("[module.type] has mismatched or missing Bastion module sprites")
		for(var/direction in list(NORTH, SOUTH, EAST, WEST))
			var/list/offset = module.px_offsets["[direction]"]
			if(length(offset) != 2 || offset[1] || offset[2])
				return Fail("[module.type] is misaligned in direction [direction]")
	if(!("damaged_frame" in icon_states(tank.icon)))
		return Fail("Bastion damaged hull sprite is missing")
	var/start_direction = turret.dir
	turret.rotate(90)
	if(turret.dir != turn(start_direction, 90) || main_gun.dir != turret.dir)
		return Fail("Bastion cannon did not follow turret rotation")
	if(main_gun.burst_amount != 2 || main_gun.gun_firemode != GUN_FIREMODE_BURSTFIRE)
		return Fail("Bastion main gun does not fire two-shot bursts")
	if(main_gun.burst_delay > 0.2 SECONDS || main_gun.extra_delay > 0.7 SECONDS)
		return Fail("Bastion main gun has the old firing cadence")
	if(aa_gun.get_origin_turf() == get_turf(tank))
		return Fail("Bastion AA gun still fires from the main turret")
	if(!istype(main_gun.ammo, /obj/item/ammo_magazine/hardpoint/heavy_autocannon/bastion))
		return Fail("Bastion main gun has the wrong ammunition")
	if(!istype(aa_gun.ammo, /obj/item/ammo_magazine/hardpoint/m56_cupola/quad_cannon/bastion))
		return Fail("Bastion AA turret has the wrong ammunition")
	if(!istype(flamer.ammo, /obj/item/ammo_magazine/hardpoint/secondary_flamer))
		return Fail("Bastion roof flamer has the wrong fuel")
	if(!fexists("maps/interiors/bastion.dmm"))
		return Fail("Bastion interior map is missing")

/datum/unit_test/bastion_interior/Run()
	var/turf/test_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test/tank = allocate(/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test, test_turf)
	var/datum/interior/interior = allocate(/datum/interior, tank)
	interior.create_interior(/datum/map_template/interior/bastion)
	if(!interior.ready || !length(interior.entrance_markers))
		return Fail("Bastion interior did not load with an entrance")

/datum/unit_test/bastion_module_service/Run()
	var/turf/test_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	new /obj/effect/vehicle_spawner/bastion/armament_test(test_turf)
	var/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test/tank = locate(/obj/vehicle/multitile/tank/twe_tank/bastion/armament_test) in test_turf
	if(!tank)
		return Fail("M46 Bastion could not spawn", __FILE__, __LINE__)
	var/obj/item/hardpoint/primary/aa_quadcannon/bastion/aa_gun = locate(/obj/item/hardpoint/primary/aa_quadcannon/bastion) in tank.hardpoints
	if(!aa_gun)
		return Fail("M46 Bastion has no serviceable AA gun", __FILE__, __LINE__)
	var/old_module_health = aa_gun.health
	var/old_hull_health = tank.health
	tank.take_damage_type(20, "bullet")
	if(aa_gun.health >= old_module_health || tank.health >= old_hull_health)
		return Fail("M46 Bastion did not take module and hull damage", __FILE__, __LINE__)
	tank.remove_hardpoint(aa_gun)
	if(aa_gun.owner || aa_gun in tank.hardpoints)
		return Fail("M46 Bastion AA gun could not be detached", __FILE__, __LINE__)
	var/mob/living/carbon/human/repairer = allocate(/mob/living/carbon/human, test_turf)
	var/obj/item/tool/weldingtool/experimental/welder = allocate(/obj/item/tool/weldingtool/experimental, repairer)
	welder.toggle()
	var/damaged_health = aa_gun.health
	aa_gun.handle_repair(welder, repairer)
	if(aa_gun.health <= damaged_health)
		return Fail("M46 Bastion AA gun could not be repaired", __FILE__, __LINE__)
	tank.add_hardpoint(aa_gun)
	if(aa_gun.owner != tank || !(aa_gun in tank.hardpoints))
		return Fail("M46 Bastion AA gun could not be reinstalled", __FILE__, __LINE__)
