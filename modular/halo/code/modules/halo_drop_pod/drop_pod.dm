GLOBAL_LIST_INIT(blocked_droppod_tiles, typecacheof(list(/turf/open/space/transit, /turf/open/space))) // Don't drop at these tiles.


/obj/structure/halo_droppod
	name = "\improper M8823 HEV drop pod"
	health = 4000 //Hopefully immune to most things. Probably not.
	icon = 'icons/halo/obj/structures/drop_pod.dmi'
	icon_state = "drop_pod"
	layer = 5.1
	pixel_x = -16
	density = TRUE

// Vars that are important when interacting with the pod as a player
	var/gm_locked = TRUE // whether or not the pod is locked to only be able to be controlled by the gm
	var/locked = FALSE // if the pod is locked and unable to be opened
	var/closed = TRUE
	var/can_launch = TRUE
	var/pod_state = POD_READY
	var/chute_state = CHUTE_READY
	var/start_open

// Vars of importance when launching
	var/landing_scatter = 18 // Scatter from the landing point
	var/time_to_land = 30 SECONDS // time it takes from launching to reach the ground
	var/landing_time = 1 SECONDS
	var/time_to_chute
	var/time_to_thruster
	var/pod_group
	var/target_x = 1
	var/target_y = 1
	var/target_z = 2

// failure vars
	var/failure_chance = 10
	var/failure_type

// other vars
	var/image/occupant_image
	var/image/door_image
	var/overlay_icon_state = "pod_overlay"
	var/door_icon_state = "pod_door"
	var/chute_icon_state = "chute"
	var/occupant_angle = -90
	var/occupant_x = 16
	var/occupant_y = 10
	var/occupant_dir = 2
	var/mob/living/occupant
	var/door_delay = 2 SECONDS
	COOLDOWN_DECLARE(door_cooldown)
	var/datum/turf_reservation/reservation

	var/image/pod_overlay
	var/image/rocket_image
	var/obj/structure/drop_pod_chute/chute_obj
	var/obj/item/drop_pod_door/door_obj

/obj/structure/halo_droppod/testpod
	target_x = 75
	target_y = 100

/obj/structure/halo_droppod/start_open
	start_open = TRUE

/obj/item/drop_pod_door
	name = "\improper M8823 HEV pod door"
	icon = 'icons/halo/obj/structures/drop_pod.dmi'
	icon_state = "pod_door"
	layer = 5.8
	anchored = 1
	drop_sound = 'sound/effects/odst_pod/door_clang_1.ogg'

/obj/item/drop_pod_door/launch_impact(hit_atom)
	. = ..()
	playsound(src, 'sound/effects/odst_pod/door_clang_1.ogg')

/obj/structure/drop_pod_chute
	name = "\improper M8823 HEV pod chute"
	icon = 'icons/halo/obj/structures/drop_pod.dmi'
	icon_state = "chute"
	layer = 5.7

/obj/structure/halo_droppod/Initialize()
	. = ..()
	handle_overlays()
	chute_obj = new()
	chute_obj.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	vis_contents += chute_obj

	door_obj = new()
	door_obj.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	vis_contents += door_obj
	if(start_open)
		open_door()

/obj/structure/halo_droppod/proc/handle_overlays(mob/living/user)
	overlays.Cut()
	pod_overlay = image(src.icon, loc, overlay_icon_state, 5.4)
	overlays += pod_overlay
	if(occupant && user)
		occupant_image = image(user.appearance, loc, layer = 5.2)
		occupant_image.pixel_x = occupant_x
		occupant_image.pixel_y = occupant_y
		occupant_image.dir = occupant_dir
		if(user.body_position == LYING_DOWN)
			occupant_image.transform = occupant.transform.Turn(occupant_angle)
		overlays += occupant_image

/obj/structure/halo_droppod/proc/toggle_door(mob/living/user)
	if(pod_state == POD_LANDED)
		return
	if(closed)
		open_door(user)
		return
	if(!closed)
		close_door(user)
		return

/obj/structure/halo_droppod/proc/open_door(mob/living/user)
	if(pod_state == POD_LANDED)
		return
	if(closed)
		if(user)
			visible_message(SPAN_NOTICE("[user] pulls a lever and opens the [src]s door."), SPAN_NOTICE("You pull a lever and open the [src]s door."))
		playsound(src, 'sound/effects/odst_pod/pod_door_open.ogg')
		door_obj.icon_state = "pod_door_open"
		var/open_time = 1 SECONDS
		animate(door_obj, pixel_y = 24, time = open_time, easing = SINE_EASING)
		closed = FALSE
		return

/obj/structure/halo_droppod/proc/close_door(mob/living/user)
	if(pod_state == POD_LANDED)
		return
	if(!closed)
		if(user)
			visible_message(SPAN_NOTICE("[user] pulls a lever and closes the [src]s door."), SPAN_NOTICE("You pull a lever and close the [src]s door."))
		playsound(src, 'sound/effects/odst_pod/pod_door_close.ogg')
		var/close_time = 1 SECONDS
		animate(door_obj, pixel_y = 0, time = close_time, easing = SINE_EASING)
		sleep(close_time+1)
		door_obj.icon_state = "pod_door"
		closed = TRUE
		return

/obj/structure/halo_droppod/proc/enter_pod(mob/living/user)
	if(!door_obj)
		to_chat(user, SPAN_NOTICE("Why would you want to enter it now?"))
		return
	if(closed)
		to_chat(user, SPAN_NOTICE("You try to enter the pod, but it's closed."))
		return
	if(locked)
		to_chat(user, SPAN_NOTICE("You try to enter the pod, but it's locked."))
		return
	if(occupant)
		to_chat(user, SPAN_NOTICE("There's someone already in the pod."))
		return
	to_chat(user, SPAN_NOTICE("You enter the pod."))
	user.forceMove(src)
	occupant = user
	playsound(src, "droppod_enter")
	addtimer(CALLBACK(src, PROC_REF(close_door), user), 2.5 SECONDS)
	handle_overlays(user)

/obj/structure/halo_droppod/proc/exit_pod(mob/living/user)
	if(locked)
		to_chat(user, SPAN_NOTICE("The pod is locked, you can't exit."))
		return
	if(pod_state == POD_INFLIGHT)
		to_chat(user, SPAN_BOLDWARNING("Are you crazy!?"))
		return
	if(closed)
		open_door(user)
	if(!occupant)
		return
	var/turf/exit_turf = get_step(src, SOUTH)
	occupant.forceMove(get_turf(exit_turf))
	occupant.dir = SOUTH
	occupant = null
	to_chat(user, SPAN_NOTICE("You exit the pod."))
	playsound(src, "droppod_enter")
	handle_overlays(user)

/obj/structure/halo_droppod/attack_hand(mob/living/user)
	if(!COOLDOWN_FINISHED(src, door_cooldown))
		return
	if(locked)
		to_chat(user, SPAN_NOTICE("You try to open the pod, but it's locked."))
		return
	if(occupant)
		to_chat(user, SPAN_NOTICE("You try to open the pod, but it's locked from the inside."))
		return
	toggle_door(user)
	COOLDOWN_START(src, door_cooldown, door_delay)

/obj/structure/halo_droppod/MouseDrop_T(mob/target, mob/user)
	. = ..()
	if(ishuman(target))
		visible_message(SPAN_NOTICE("[user] begins to enter the [src]."), SPAN_NOTICE("You begin to enter the [src]."))
		if(!do_after(user, 3 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, target, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC))
			to_chat(user, SPAN_NOTICE("You are interrupted!"))
		enter_pod(target)
	else
		to_chat(user, SPAN_NOTICE("[target] cannot enter the pod."))

// ============== CODE TO DROP ==============

/obj/structure/halo_droppod/return_temperature()
	if(loc)
		return 290

/obj/structure/halo_droppod/proc/set_target(mob/living/user, new_x, new_y)
	target_x = new_x
	target_y = new_y
	var/mob/notified_user = occupant
	. = checklanding(notified_user)
	if(notified_user && .)
		to_chat(user, SPAN_NOTICE("Coordinates set!"))

/obj/structure/halo_droppod/proc/checklanding(mob/living/user, optional_turf)
	var/turf/target = optional_turf ? optional_turf : locate(target_x, target_y, target_z)
	if(target.density)
		if(user)
			to_chat(user, SPAN_NOTICE("Dense area!"))
		return FALSE
	if(is_type_in_typecache(target, GLOB.blocked_droppod_tiles))
		if(user)
			to_chat(user, SPAN_NOTICE("Hazardous area!"))
		return FALSE
	var/area/targetarea = get_area(target)
	if(targetarea.no_droppod) // Thou shall not pass!
		if(user)
			to_chat(user, SPAN_NOTICE("Invalid area!"))
		return FALSE
	if(targetarea.ceiling > CEILING_METAL)
		if(user)
			to_chat(user, SPAN_NOTICE("Area underground!"))
		return FALSE
	for(var/atom/movable/object in target.contents)
		if(object.density)
			if(user)
				to_chat(user, SPAN_NOTICE("Dense object detected!"))
			return FALSE
	return TRUE

/obj/structure/halo_droppod/proc/find_new_target(mob/user)
	var/turf/turf_1 = locate(target_x + landing_scatter, target_y + landing_scatter, target_z)
	var/turf/turf_2 = locate(target_x - landing_scatter, target_y - landing_scatter, target_z)
	var/list/block = block(turf_1, turf_2)
	shuffle_inplace(block)
	for(var/turf/attemptdrop in block)
		if(!checklanding(optional_turf = attemptdrop))
			continue
		return attemptdrop

	if(user)
		to_chat(user, SPAN_WARNING("RECALCULATION FAILED!"))
	return locate(target_x, target_y, target_z) //no other alt spots found, we return our orig

/obj/structure/halo_droppod/proc/start_launch_pod(mob/user, commanded_drop = FALSE)
	if(!occupant)
		return
	user = occupant
	handle_overlays(user)

	// if(!locate(/obj/structure/drop_pod_launcher) in get_turf(src))
	//	if(user)
	//		to_chat(user, SPAN_NOTICE("Error. Cannot launch [src] without a droppod launcher."))
	//	return

	if(pod_state != POD_READY)
		if(user)
			to_chat(user, SPAN_NOTICE("Error. Unable to drop."))
		return

	var/turf/target = locate(target_x, target_y, target_z)
	if(!commanded_drop) //we randomise the landing slightly, its already randomised for mass launch
		target = find_new_target()
		target_x = target.x
		target_y = target.y

	if(!checklanding(user))
		return

	for(var/mob/podder in occupant)
		podder.forceMove(src)

	if(user)
		log_game("[key_name(user)] launched pod [src] at [AREACOORD(target)]")

	pod_state = POD_INFLIGHT
	var/random_delay = rand(0, 20)*0.1
	addtimer(CALLBACK(src, PROC_REF(delay_pod), user), random_delay SECONDS)

/obj/structure/halo_droppod/proc/delay_pod(mob/user)
	playsound_client(occupant.client, 'sound/effects/odst_pod/drop_timer.ogg', src, 25)
	addtimer(CALLBACK(src, PROC_REF(launch_pod), user), 3.5 SECONDS)


/obj/structure/halo_droppod/proc/launch_pod(mob/user)
	if(!can_launch)
		return

	playsound(src, 'sound/effects/escape_pod_launch.ogg', 70)
	sleep(1 SECONDS)
	reservation = SSmapping.request_turf_block_reservation(5, 5, 1, reservation_type = /datum/turf_reservation/transit/drop_pod)
	if(!reservation)
		CRASH("No droppod turf reservation available")
	var/turf/bottom_left_turf = reservation.bottom_left_turfs[1]
	var/turf/top_right_turf = reservation.top_right_turfs[1]
	var/middle_x = bottom_left_turf.x + floor((top_right_turf.x - bottom_left_turf.x) / 2)
	var/middle_y = bottom_left_turf.y + floor((top_right_turf.y - bottom_left_turf.y) / 2)
	var/turf/selectedturf = locate(middle_x, middle_y, bottom_left_turf.z)
	if(!selectedturf)
		CRASH("No droppod free turf found")
	forceMove(selectedturf)
	time_to_chute = time_to_land - 12 SECONDS
	if(occupant)
		shake_camera(user, time_to_land, 0.1)
	addtimer(CALLBACK(src, PROC_REF(chute_deploy), user), time_to_chute)
	addtimer(CALLBACK(src, PROC_REF(finish_drop), user, selectedturf), time_to_land)

/obj/structure/halo_droppod/proc/chute_deploy(mob/user)
	playsound(src, 'sound/effects/escape_pod_launch.ogg')
	if(occupant)
		shake_camera(user, 3, 3)
	chute_obj.pixel_y = 32
	chute_obj.icon_state = "chute_open"
	time_to_thruster = 6 SECONDS
	addtimer(CALLBACK(src, PROC_REF(thruster_fire), user), time_to_thruster)

/obj/structure/halo_droppod/proc/thruster_fire(mob/user)
	if(occupant)
		shake_camera(user, 3, 3)
	animate(chute_obj, pixel_z = 500, time = 1 SECONDS, easing = LINEAR_EASING)
	sleep(2 SECONDS)
	rocket_image = image(src.icon, loc, "rocket_burn")
	rocket_image.pixel_y = -32
	overlays += rocket_image
	animate(src, pixel_z = 500, time = 4 SECONDS, easing = LINEAR_EASING)
	playsound(src, 'sound/effects/odst_pod/pod_jet.ogg')
	sleep(4 SECONDS)
	qdel(chute_obj)
	handle_overlays(user)


/obj/structure/halo_droppod/proc/finish_drop(mob/user, turf/reservedturf)
	var/turf/targetturf = locate(target_x, target_y, target_z)
	for(var/atom/target in targetturf.contents)
		if(!target.density)
			continue
		if(user)
			to_chat(user, SPAN_WARNING("WARNING! TARGET ZONE OCCUPIED! EVADING!"))
		targetturf = find_new_target(user)
		break
	forceMove(targetturf)
	QDEL_NULL(reservation)
	animate(src, pixel_z = initial(pixel_z), time = landing_time, easing = LINEAR_EASING)
	if(occupant)
		shake_camera(user, landing_time, 1)
	addtimer(CALLBACK(src, PROC_REF(do_drop), targetturf, user), landing_time)
	handle_overlays(user)

/obj/structure/halo_droppod/proc/do_drop(turf/targetturf, mob/user)
	var/datum/cause_data/cause_data = create_cause_data("[src]", user)
	explosion(targetturf, light_impact_range = 2, explosion_cause_data = cause_data)
	playsound(targetturf, "droppod_land", 100)
	addtimer(CALLBACK(src, PROC_REF(complete_drop), user), 2 SECONDS)

/obj/structure/halo_droppod/proc/complete_drop(mob/user)
	playsound(src, 'sound/effects/odst_pod/door_kaboom.ogg')
	addtimer(CALLBACK(src, PROC_REF(door_explode), user), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(exit_pod), user), 4 SECONDS)

/obj/structure/halo_droppod/proc/door_explode(mob/user)
	qdel(door_obj)
	var/obj/item/drop_pod_door/new_door_obj
	new_door_obj = new /obj/item/drop_pod_door(loc)
	new_door_obj.icon_state = "pod_door_open"
	new_door_obj.layer = 3
	new_door_obj.pixel_x = -16
	var/turf/target = get_offset_target_turf(loc, 0, -5)
	var/target_turf = get_turf(target)
	new_door_obj.throw_atom(target_turf, 16, SPEED_FAST, loc, FALSE)
	if(occupant)
		shake_camera(user, 3, 1)
	pod_state = POD_LANDED
	new_door_obj.icon_state = "pod_door_floor"
	sleep(0.8 SECONDS)

	playsound(new_door_obj, 'sound/effects/odst_pod/door_clang_1.ogg')
