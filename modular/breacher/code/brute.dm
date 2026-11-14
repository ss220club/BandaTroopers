/datum/ammo/rocket/brute
	flags_ammo_behavior = AMMO_SKIPS_ALIENS|AMMO_HITS_TARGET_TURF|AMMO_SNIPER
	name = "M5510 Laser-Guided Rocket"
	icon_state = "brute"

	var/smoke_chance = 30

	var/spark_chance = 30

	var/fire_chance = 30

	var/throw_chance = 20

	var/structure_damage = 1200

	var/edge_lower_dmg = 400

	var/edge_upper_dmg = 700

	var/max_distance = 7

/datum/ammo/rocket/brute/on_hit_mob(mob/mob, obj/projectile/projectile)
	INVOKE_ASYNC(src,PROC_REF(prime), mob, projectile)

/datum/ammo/rocket/brute/on_hit_obj(obj/object, obj/projectile/projectile)
	INVOKE_ASYNC(src,PROC_REF(prime), object, projectile)

/datum/ammo/rocket/brute/on_hit_turf(turf/turf, obj/projectile/projectile)
	INVOKE_ASYNC(src,PROC_REF(prime), turf, projectile)

/datum/ammo/rocket/brute/do_at_max_range(obj/projectile/projectile)
	INVOKE_ASYNC(src,PROC_REF(prime), null, projectile)

/datum/ammo/rocket/brute/proc/prime(atom/atom, obj/projectile/projectile)
	if(istype(projectile.firer, /mob/living/carbon))
		var/mob/living/carbon/firer = projectile.firer
		if(atom)
			log_game("[key_name(firer)] fired [name] targeting [atom], at [AREACOORD(atom)]")
			msg_admin_niche("[key_name(firer, TRUE)] fired [name] targeting [atom], at [ADMIN_VERBOSEJMP(atom)]")
			firer.attack_log += "\[[time_stamp()]\] <font color='red'> [key_name(firer)] fired [name] targeting [atom], at [AREACOORD(atom)]</font>"
		else
			log_game("[key_name(firer)] fired [name] at [AREACOORD(projectile)]")
			msg_admin_niche("[key_name(firer, TRUE)] fired [name] at [ADMIN_VERBOSEJMP(projectile)]")
			firer.attack_log += "\[[time_stamp()]\] <font color='red'> [key_name(firer)] fired [name] at [AREACOORD(projectile)]</font>"
	var/angle = projectile.angle
	var/right_angle = (angle + 90 ) % 360
	var/left_angle = (angle -90) % 360
	var/diagonal_left = (angle - 135) % 360
	var/diagonal_right = (angle + 135) % 360
	var/turf/initial_location = projectile.loc
	var/list/cleared_locations = list(initial_location)
	var/edge = FALSE
	for(var/i = 0 to max_distance)
		var/turf/new_turf = get_angle_target_turf(initial_location, angle , i)
		INVOKE_ASYNC(src, PROC_REF(detonate),new_turf, initial_location, cleared_locations)
		cleared_locations |= new_turf
		var/max_width = 2
		if(i == 1 || i == max_distance)
			max_width = 1
		for(var/ii = 1 to max_width)
			edge = FALSE
			if(ii == max_width)
				edge = TRUE
			var/turf/right_turf = get_angle_target_turf(new_turf, right_angle , ii)
			INVOKE_ASYNC(src, PROC_REF(detonate),right_turf, initial_location, cleared_locations)
			cleared_locations |= right_turf
			var/turf/left_turf = get_angle_target_turf(new_turf, left_angle , ii)
			INVOKE_ASYNC(src, PROC_REF(detonate),left_turf, initial_location, cleared_locations)
			cleared_locations |= left_turf
			if(i > 2)
				right_turf = get_angle_target_turf(new_turf, diagonal_right , ii)
				INVOKE_ASYNC(src, PROC_REF(detonate),right_turf, initial_location, cleared_locations,edge)
				left_turf = get_angle_target_turf(new_turf, diagonal_left , ii)
				INVOKE_ASYNC(src, PROC_REF(detonate),left_turf, initial_location, cleared_locations,edge)
				cleared_locations |= right_turf
				cleared_locations |= left_turf
		sleep(1)


/datum/ammo/rocket/brute/proc/detonate(turf/location, turf/initial_location, list/detonated_locations, edge = FALSE)
	if(!location || location in detonated_locations)
		return


	if(prob(fire_chance))
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flame_radius), null, 0, location, BURN_TIME_INSTANT, BURN_LEVEL_TIER_1, FLAMESHAPE_LINE, null, FIRE_VARIANT_DEFAULT)

	if(prob(spark_chance))
		var/datum/effect_system/spark_spread/spark = new /datum/effect_system/spark_spread
		spark.set_up(5, 1, location)
		spark.start()

	if(prob(smoke_chance))
		var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread
		smoke.set_up(0, 0, location, null, 3 DECISECONDS)
		smoke.start()

	var/damage = edge ? rand(edge_lower_dmg, edge_upper_dmg) : structure_damage
	if(istype(location,/turf/closed/wall))
		location.ex_act(damage)
	for(var/obj/structure/structure in location.contents)
		structure.ex_act(damage)
	if(location != initial_location)
		var/throw_direction = Get_Angle(initial_location, location)
		for(var/obj/atom in location.contents)
			if(atom.anchored)
				continue
			if(prob(throw_chance))
				continue
			atom.throw_atom(get_angle_target_turf(location,throw_direction,1),range = 1,speed = SPEED_INSTANT, spin = FALSE)
		for(var/mob/living/living in location.contents)
			if(prob(throw_chance + living.mob_size * 5 ))
				continue
			living.throw_atom(get_angle_target_turf(location,throw_direction,1),range = 1,speed = SPEED_INSTANT, spin = FALSE)

/obj/item/ammo_magazine/rocket/brute
	name = "\improper M5510 Laser-Guided Rocket"
	icon = 'modular/breacher/assets/icons/obj/items/weapons/guns/ammo_by_faction/USCM/rocket_launchers.dmi'
	icon_state = "brute_rocket"
	default_ammo = /datum/ammo/rocket/brute
	gun_type = /obj/item/weapon/gun/launcher/rocket/brute
	desc = "The M5510 rockets are high-explosive anti-structure munitions designed to rapidly accelerate to nearly 1,000 miles per hour in any atmospheric conditions. The warhead itself uses an inflection stabilized shaped-charge to generate a low-frequency pressure wave that can flatten nearly any fortification in an elliptical radius of several meters. These rockets are known to have reduced lethality to personnel, but will put just about any ol' backwater mud-hut right into orbit."


/obj/item/weapon/gun/launcher/rocket/brute
	name = "\improper M6H-BRUTE launcher system"
	desc = "Breaching Rocket Unit for Tactical Entry, or BRUTE, is a shoulder-mounted, man-portable launcher system designed to give combat technicians rapid structure defeating capabilities at reasonable range. The launcher fits a fore-mounted laser guidance module that steers the 90mm shaped-charge rockets towards a fortified position. Try not to drool on it."
	icon = 'modular/breacher/assets/icons/obj/items/weapons/guns/guns_by_faction/USCM/rocket_launchers.dmi'
	item_icons = list(
		WEAR_L_HAND = 'modular/breacher/assets/icons/mob/humans/onmob/inhands/weapons/guns/rocket_launchers_lefthand.dmi',
		WEAR_R_HAND = 'modular/breacher/assets/icons/mob/humans/onmob/inhands/weapons/guns/rocket_launchers_righthand.dmi'
	)
	icon_state = "m6h"
	item_state = "m6h"

	current_mag = /obj/item/ammo_magazine/rocket/brute
	skill_locked = FALSE
	var/f_aiming_time = 4 SECONDS
	var/aiming = FALSE

/obj/item/weapon/gun/launcher/rocket/brute/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 8, "rail_y" = 17, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

/obj/item/weapon/gun/launcher/rocket/brute/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))

/obj/item/weapon/gun/launcher/rocket/brute/retrieve_to_slot(mob/living/carbon/human/user, retrieval_slot, check_loc, silent)
	if(retrieval_slot == WEAR_J_STORE)
		if(..(user, WEAR_IN_BACK, check_loc, silent))
			return TRUE
	return ..()

/obj/item/weapon/gun/launcher/rocket/brute/handle_fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield, check_for_attachment_fire, akimbo, fired_by_akimbo)
	if(aiming)
		return

	if(!(istype(target, /obj/structure) || istype(target,/turf/closed/wall)) )
		to_chat(user, SPAN_WARNING("Invalid target!"))
		return

	var/list/turf/path = get_line(user, target, include_start_atom = FALSE)
	for(var/turf/turf_path in path)
		if(turf_path.opacity && turf_path != target)
			to_chat(user, SPAN_WARNING("Target obscured!"))
			return
	aiming = TRUE
	var/beam = "laser_beam_guided"
	var/lockon = "sniper_lockon_guided"
	var/image/lockon_icon = image(icon = 'icons/effects/Targeted.dmi', icon_state = lockon)
	target.overlays += lockon_icon

	var/image/lockon_direction_icon
	lockon_direction_icon = image(icon = 'icons/effects/Targeted.dmi', icon_state = "[lockon]_direction", dir = get_cardinal_dir(target, user))
	target.overlays += lockon_direction_icon
	var/datum/beam/laser_beam
	laser_beam = target.beam(user, beam, 'icons/effects/beam.dmi', (f_aiming_time + 1 SECONDS), beam_type = /obj/effect/ebeam/laser/intense)
	laser_beam.visuals.alpha = 0
	animate(laser_beam.visuals, alpha = initial(laser_beam.visuals.alpha), f_aiming_time, easing = SINE_EASING|EASE_OUT)


	if(do_after(user, f_aiming_time, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		if(!QDELETED(target))
			. = ..()

	target.overlays -= lockon_icon
	target.overlays -= lockon_direction_icon
	qdel(laser_beam)
	aiming = FALSE

/obj/item/weapon/gun/launcher/rocket/brute/make_rocket(mob/user, drop_override = 0, empty = 1)
	if(empty)
		return
	. = ..()



/obj/item/weapon/gun/launcher/rocket/brute/breacher
	name = "\improper M6H-BREACHER launcher system"

/obj/item/weapon/gun/launcher/rocket/brute/breacher/able_to_fire(mob/living/user)
	if(!istype(user) || (!skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_BREACHER))
		return FALSE
	return ..()
