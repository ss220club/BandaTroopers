/datum/map_template/interior/bastion
	name = "M46 Bastion Tank"
	interior_id = "bastion"

/area/interior/vehicle/twe_tank/bastion
	name = "M46 Bastion Tank"

/obj/structure/prop/vehicle/twe_tank/bastion
	name = "корпус танка M46 Bastion"
	color = "#aab3bc"

/obj/structure/vehicle_locker/tank/twe/bastion/main/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/hardpoint/heavy_autocannon/bastion(container)
	new /obj/item/ammo_magazine/hardpoint/heavy_autocannon/bastion(container)

/obj/structure/vehicle_locker/tank/twe/bastion/aa/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/hardpoint/m56_cupola/quad_cannon/bastion(container)
	new /obj/item/ammo_magazine/hardpoint/m56_cupola/quad_cannon/bastion(container)

/obj/structure/vehicle_locker/tank/twe/bastion/utility
	name = "шкаф экипажа M46 Bastion"

/obj/item/ammo_magazine/hardpoint/heavy_autocannon/bastion
	name = "короб 45-мм снарядов M46 Bastion"
	gun_type = /obj/item/hardpoint/primary/autocannon/twe_tank/bastion

/obj/item/ammo_magazine/hardpoint/m56_cupola/quad_cannon/bastion
	name = "короб 20-мм снарядов M46 Bastion"
	gun_type = /obj/item/hardpoint/primary/aa_quadcannon/bastion

/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/bastion
	name = "башня M46 Bastion"
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "tank_turret_0"
	disp_icon = 'icons/obj/vehicles/ridgeway.dmi'
	disp_icon_state = "tank_turret"
	pixel_x = -65
	pixel_y = -65
	px_offsets = list(
		"1" = list(0, 0),
		"2" = list(0, 24),
		"4" = list(-20, 15),
		"8" = list(20, 15),
	)
	accepted_hardpoints = list(/obj/item/hardpoint/primary/autocannon/twe_tank/bastion)

/obj/item/hardpoint/primary/autocannon/twe_tank/bastion
	name = "скорострельная 45-мм автопушка M46 Bastion"
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "ridgeway_cannon_0"
	disp_icon = 'icons/obj/vehicles/ridgeway.dmi'
	disp_icon_state = "ridgeway_cannon"
	ammo = new /obj/item/ammo_magazine/hardpoint/heavy_autocannon/bastion
	gun_firemode = GUN_FIREMODE_BURSTFIRE
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE)
	burst_amount = 2
	burst_delay = 0.2 SECONDS
	extra_delay = 0.7 SECONDS
	px_offsets = list(
		"1" = list(0, 46),
		"2" = list(0, -50),
		"4" = list(61, 0),
		"8" = list(-63, 0),
	)
	muzzle_flash_pos = list(
		"1" = list(16, 100),
		"2" = list(16, -110),
		"4" = list(140, 4),
		"8" = list(-105, 4),
	)

/obj/item/hardpoint/primary/aa_quadcannon/bastion
	name = "20-мм зенитная башенка M46 Bastion"
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "m56cupola_0"
	disp_icon = 'icons/obj/vehicles/ridgeway.dmi'
	disp_icon_state = "m56cupola"
	slot = HDPT_SECONDARY
	hdpt_layer = HDPT_LAYER_TURRET
	allowed_seat = VEHICLE_DRIVER
	firing_arc = 150
	ammo = new /obj/item/ammo_magazine/hardpoint/m56_cupola/quad_cannon/bastion
	use_mz_px_offsets = TRUE
	px_offsets = list(
		"1" = list(-25, -20),
		"2" = list(25, 20),
		"4" = list(-20, 25),
		"8" = list(20, -25),
	)

/obj/item/hardpoint/primary/aa_quadcannon/bastion/get_origin_turf()
	var/turf/center = get_turf(src)
	if(!center || !owner)
		return center
	switch(owner.dir)
		if(NORTH)
			return get_offset_target_turf(center, -1, -1)
		if(SOUTH)
			return get_offset_target_turf(center, 1, 1)
		if(EAST)
			return get_offset_target_turf(center, -1, 1)
		if(WEST)
			return get_offset_target_turf(center, 1, -1)
	return center

/obj/item/hardpoint/secondary/small_flamer/bastion
	name = "крышный огнемёт M46 Bastion"
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "flamer_0"
	disp_icon = 'icons/obj/vehicles/ridgeway.dmi'
	disp_icon_state = "flamer"
	slot = HDPT_SUPPORT
	hdpt_layer = HDPT_LAYER_TURRET
	allowed_seat = VEHICLE_DRIVER
	firing_arc = 105
	px_offsets = list(
		"1" = list(25, -10),
		"2" = list(-25, 10),
		"4" = list(-10, -25),
		"8" = list(10, 25),
	)

/obj/item/hardpoint/secondary/small_flamer/bastion/get_origin_turf()
	var/turf/center = get_turf(src)
	if(!center || !owner)
		return center
	switch(owner.dir)
		if(NORTH)
			return get_offset_target_turf(center, 1, 0)
		if(SOUTH)
			return get_offset_target_turf(center, -1, 0)
		if(EAST)
			return get_offset_target_turf(center, 0, -1)
		if(WEST)
			return get_offset_target_turf(center, 0, 1)
	return center

/obj/item/hardpoint/locomotion/treads/ridgeway/bastion
	name = "гусеницы M46 Bastion"
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "treads_ridgeway_0"
	disp_icon = 'icons/obj/vehicles/ridgeway.dmi'
	disp_icon_state = "treads_ridgeway"

/obj/vehicle/multitile/tank/twe_tank/bastion
	name = "тяжёлый танк M46 Bastion"
	desc = "Тяжёлый танк со скорострельной автоматической пушкой, зенитной башенкой и огнемётом. Вход сзади."
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "tank_base"
	pixel_x = -65
	pixel_y = -65
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	health = 2100
	interior_map = /datum/map_template/interior/bastion
	passengers_slots = 4
	vehicle_flags = VEHICLE_CLASS_MEDIUM
	hardpoints_allowed = list(
		/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/bastion,
		/obj/item/hardpoint/locomotion/treads/ridgeway/bastion,
		/obj/item/hardpoint/primary/aa_quadcannon/bastion,
		/obj/item/hardpoint/secondary/small_flamer/bastion,
	)

/obj/vehicle/multitile/tank/twe_tank/bastion/load_hardpoints()
	add_hardpoint(new /obj/item/hardpoint/holder/tank_turret/twe_tank_turret/bastion)

/obj/vehicle/multitile/tank/twe_tank/bastion/update_icon()
	overlays.Cut()
	if(health < initial(health))
		var/image/damage_overlay = image(icon, icon_state = "tank_base", layer = layer + 0.05)
		damage_overlay.color = "#171717"
		damage_overlay.alpha = round(180 * (1 - (health / initial(health))))
		overlays += damage_overlay
	if(LAZYLEN(hardpoints))
		handle_hardpoint_images()
	if(clamped)
		overlays += image(icon, icon_state = "vehicle_clamp", layer = layer + 0.1)

/obj/effect/vehicle_spawner/bastion
	name = "M46 Bastion с вооружением"
	icon = 'icons/obj/vehicles/ridgeway.dmi'
	icon_state = "tank_base"
	pixel_x = -65
	pixel_y = -65

/obj/effect/vehicle_spawner/bastion/Initialize()
	. = ..()
	spawn_vehicle()
	qdel(src)

/obj/effect/vehicle_spawner/bastion/spawn_vehicle()
	var/obj/vehicle/multitile/tank/twe_tank/bastion/tank = new(loc)
	load_misc(tank)
	load_hardpoints(tank)
	handle_direction(tank)
	tank.update_icon()
	return tank

/obj/effect/vehicle_spawner/bastion/load_hardpoints(obj/vehicle/multitile/tank/twe_tank/bastion/tank)
	tank.add_hardpoint(new /obj/item/hardpoint/locomotion/treads/ridgeway/bastion)
	var/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/bastion/turret = new
	tank.add_hardpoint(turret)
	turret.add_hardpoint(new /obj/item/hardpoint/primary/autocannon/twe_tank/bastion)
	tank.add_hardpoint(new /obj/item/hardpoint/primary/aa_quadcannon/bastion)
	tank.add_hardpoint(new /obj/item/hardpoint/secondary/small_flamer/bastion)

/obj/effect/vehicle_spawner/bastion/hull
	name = "M46 Bastion без башни"

/obj/effect/vehicle_spawner/bastion/hull/load_hardpoints(obj/vehicle/multitile/tank/twe_tank/bastion/tank)
	tank.add_hardpoint(new /obj/item/hardpoint/locomotion/treads/ridgeway/bastion)

/obj/effect/vehicle_spawner/bastion/damaged
	name = "повреждённый M46 Bastion"

/obj/effect/vehicle_spawner/bastion/damaged/spawn_vehicle()
	var/obj/vehicle/multitile/tank/twe_tank/bastion/tank = ..()
	tank.health = round(initial(tank.health) * 0.4)
	tank.healthcheck()
	tank.update_icon()
	return tank

/obj/effect/vehicle_spawner/bastion/wreck
	name = "уничтоженный M46 Bastion"

/obj/effect/vehicle_spawner/bastion/wreck/spawn_vehicle()
	var/obj/vehicle/multitile/tank/twe_tank/bastion/tank = ..()
	load_damage(tank)
	tank.update_icon()
	return tank
