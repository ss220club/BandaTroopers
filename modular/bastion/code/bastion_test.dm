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
	if(main_gun.burst_amount != 2 || main_gun.gun_firemode != GUN_FIREMODE_BURSTFIRE)
		return Fail("Bastion main gun does not fire two-shot bursts")
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
