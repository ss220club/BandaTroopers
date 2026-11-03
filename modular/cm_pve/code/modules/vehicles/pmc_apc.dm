/datum/map_template/interior/apc_pmc
	name = "W-Y APC"
	interior_id = "apc_pmc"

/obj/structure/interior_wall/apc_pmc
	name = "\improper APC interior wall"
	icon = 'icons/obj/vehicles/interiors/apc_pmc.dmi'
	icon_state = "apc_right_1"

/obj/structure/interior_exit/vehicle/apc_pmc
	name = "APC side door"
	icon = 'icons/obj/vehicles/interiors/apc_pmc.dmi'
	icon_state = "exit_door"

/obj/structure/interior_exit/vehicle/apc_pmc/rear
	name = "APC rear hatch"
	icon_state = "door_rear_center"

/obj/structure/interior_exit/vehicle/apc_pmc/rear/left
	icon_state = "door_rear_left"

/obj/structure/interior_exit/vehicle/apc_pmc/rear/right
	icon_state = "door_rear_right"

/obj/structure/vehicle_locker/pmc
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'

/obj/structure/machinery/cm_vending/sorted/medical/wall_med/vehicle/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'

/obj/effect/landmark/interior/spawn/vehicle_driver_seat/armor/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'
	icon_state = "armor_chair"

/obj/effect/landmark/interior/spawn/vehicle_gunner_seat/armor/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'
	icon_state = "armor_chair"

/obj/effect/landmark/interior/spawn/vehicle_support_gunner_seat/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'

/obj/effect/landmark/interior/spawn/vehicle_support_gunner_seat/second/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'

/obj/effect/landmark/interior/spawn/weapons_loader/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'

/obj/effect/landmark/interior/spawn/interior_viewport/wy
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'

/obj/item/hardpoint/primary/dualcannon/pmc
	icon = 'icons/obj/vehicles/hardpoints/apc_pmc.dmi'
	icon_state = "dual_cannon_wy"
	disp_icon = 'icons/obj/vehicles/apc_pmc.dmi'
	disp_icon_state = "dual_cannon_wy"

/obj/item/hardpoint/secondary/frontalcannon/pmc
	icon = 'icons/obj/vehicles/hardpoints/apc_pmc.dmi'
	icon_state = "front_cannon_wy"
	disp_icon = 'icons/obj/vehicles/apc_pmc.dmi'
	disp_icon_state = "frontalcannon_wy"

/obj/item/hardpoint/locomotion/apc_wheels/pmc
	icon = 'icons/obj/vehicles/hardpoints/apc_pmc.dmi'
	icon_state = "tires_wy"
	disp_icon = 'icons/obj/vehicles/apc_pmc.dmi'
	disp_icon_state = "wheels_wy"

/obj/item/hardpoint/support/flare_launcher/pmc
	icon = 'icons/obj/vehicles/hardpoints/apc_pmc.dmi'
	disp_icon = 'icons/obj/vehicles/apc_pmc.dmi'

/obj/vehicle/multitile/apc/pmc
	name = "M577-WY Armored Personnel Carrier"
	desc = "An M577 Armored Personnel Carrier designed for W-Y PMC forces."
	icon = 'icons/obj/vehicles/apc_pmc.dmi'
	icon_state = "hull_wy"
	interior_map = /datum/map_template/interior/apc_pmc
	hardpoints_allowed = list(
		/obj/item/hardpoint/primary/dualcannon/pmc,
		/obj/item/hardpoint/secondary/frontalcannon/pmc,
		/obj/item/hardpoint/support/flare_launcher/pmc,
		/obj/item/hardpoint/locomotion/apc_wheels/pmc,
	)
	mob_size_required_to_hit = MOB_SIZE_XENO
	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.6,
		"slash" = 0.8,
		"bullet" = 0.6,
		"explosive" = 0.7,
		"blunt" = 0.7,
		"abstract" = 1,
	)
	move_max_momentum = 2
	move_momentum_build_factor = 1.5
	move_turn_momentum_loss_factor = 0.8
	var/sensor_radius = 45
	var/list/minimap_added = list()

/obj/vehicle/multitile/apc/pmc/Initialize()
	. = ..()
	START_PROCESSING(SSslowobj, src)
	GLOB.command_apc_list += src

/obj/vehicle/multitile/apc/pmc/Destroy()
	GLOB.command_apc_list -= src
	STOP_PROCESSING(SSslowobj, src)
	return ..()

/obj/vehicle/multitile/apc/pmc/process()
	var/turf/apc_turf = get_turf(src)
	if(health == 0 || !visible_in_tacmap || !is_ground_level(apc_turf.z))
		return
	for(var/mob/living/carbon/xenomorph/current_xeno as anything in GLOB.living_xeno_list)
		var/turf/xeno_turf = get_turf(current_xeno)
		if(!is_ground_level(xeno_turf.z))
			continue
		if(get_dist(src, current_xeno) <= sensor_radius)
			if(WEAKREF(current_xeno) in minimap_added)
				continue
			SSminimaps.remove_marker(current_xeno)
			current_xeno.add_minimap_marker(MINIMAP_FLAG_USCM|get_minimap_flag_for_faction(current_xeno.hivenumber))
			minimap_added += WEAKREF(current_xeno)
		else if(WEAKREF(current_xeno) in minimap_added)
			SSminimaps.remove_marker(current_xeno)
			current_xeno.add_minimap_marker()
			minimap_added -= WEAKREF(current_xeno)

/obj/vehicle/multitile/apc/pmc/load_role_reserved_slots()
	var/datum/role_reserved_slots/RRS = new
	RRS.category_name = "Crewmen"
	RRS.roles = list(JOB_PMC_CREWMAN)
	RRS.total = 1
	role_reserved_slots += RRS
	RRS = new
	RRS.category_name = "Command Staff"
	RRS.roles = JOB_COMMAND_ROLES_LIST
	RRS.total = 1
	role_reserved_slots += RRS
	RRS = new
	RRS.category_name = "Synthetic Unit"
	RRS.roles = list(JOB_PMC_SYNTH)
	RRS.total = 1
	role_reserved_slots += RRS

/obj/vehicle/multitile/apc/pmc/initialize_cameras(change_tag = FALSE)
	if(!camera)
		camera = new /obj/structure/machinery/camera/vehicle(src)
	if(change_tag)
		camera.c_tag = "#[rand(1,100)] M577-WY \"[nickname]\" APC"
	else
		camera.c_tag = "#[rand(1,100)] M577-WY APC"
	if(camera_int)
		camera_int.c_tag = camera.c_tag + " interior"

/obj/vehicle/multitile/apc/pmc/unarmed
	interior_map = /datum/map_template/interior/apc_no_fpw

/obj/effect/vehicle_spawner/apc_pmc
	parent_type = /obj/effect/vehicle_spawner/apc
	name = "W-Y APC Transport Spawner"
	icon = 'icons/obj/vehicles/apc_pmc.dmi'
	icon_state = "hull_wy"

/obj/effect/vehicle_spawner/apc_pmc/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/APC = new(loc)
	load_misc(APC)
	load_fpw(APC)
	load_hardpoints(APC)
	handle_direction(APC)
	APC.update_icon()
	return APC

/obj/effect/vehicle_spawner/apc_pmc/plain/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

/obj/effect/vehicle_spawner/apc_pmc/fixed/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

/obj/effect/vehicle_spawner/apc_pmc/decrepit/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/APC = ..()
	load_damage(APC)
	APC.update_icon()
	return APC

/obj/effect/vehicle_spawner/apc_pmc/decrepit/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

/obj/effect/vehicle_spawner/apc_pmc/unarmed/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/unarmed/APC = new(loc)
	load_misc(APC)
	load_hardpoints(APC)
	handle_direction(APC)
	APC.update_icon()
	return APC

/obj/effect/vehicle_spawner/apc_pmc/unarmed/load_hardpoints(obj/vehicle/multitile/apc/V)
	return

/obj/effect/vehicle_spawner/apc_pmc/unarmed/plain/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

/obj/effect/vehicle_spawner/apc_pmc/unarmed/fixed/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

/obj/effect/vehicle_spawner/apc_pmc/unarmed/decrepit/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/unarmed/APC = ..()
	load_damage(APC)
	APC.update_icon()
	return APC

/obj/effect/vehicle_spawner/apc_pmc/unarmed/decrepit/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

/obj/effect/vehicle_spawner/apc_pmc/unarmed/broken/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/unarmed/APC = ..()
	load_damage(APC)
	APC.update_icon()
	return APC
