/obj/effect/blocker/water
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	unacidable = TRUE

	icon = 'icons/turf/floors/desert_water.dmi'
	icon_state = "seadeep"


	alpha = 0
	layer = TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/flooded_alpha = 180
	var/dispersing = FALSE
	var/toxic = FALSE
	var/disperse_group = 1
	var/spread_delay = 5
	var/list/water_sounds = list('sound/effects/slosh.ogg')




/obj/effect/blocker/water/toxic
	icon = 'icons/old_stuff/mark.dmi'
	toxic = TRUE
	disperse_group
	spread_delay = 5
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_FLY_LAYER //to make it visible in the map editor

	icon_state = "spawn_shuttle"

/obj/effect/blocker/water/toxic/Group_1
	disperse_group = 1
	icon_state = "spawn_event"

/obj/effect/blocker/water/toxic/Group_1/delay
	spread_delay = 100
	icon_state = "spawn_shuttle_dock"

/obj/effect/blocker/water/toxic/Group_2
	disperse_group = 2
	icon_state = "spawn_goal"

/obj/effect/blocker/water/toxic/Group_2/delay
	spread_delay = 100
	icon_state = "spawn_shuttle_dock"


/obj/effect/blocker/water/Initialize(mapload, ...)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/blocker/water/toxic/LateInitialize()
	. = ..()
	update_turf()
	icon_state = null


/obj/effect/blocker/water/proc/update_turf()
	if(istype(src.loc, /turf/open/gm/river/desert))
		var/turf/open/gm/river/desert/R = src.loc
		R.toxic = src.toxic
		R.update_icon()

	else if(istype(src.loc, /turf/open/desert/desert_shore))
		var/turf/open/desert/desert_shore/S = src.loc
		S.toxic = src.toxic
		S.update_icon()

	else if(istype(src.loc, /turf/open/desert/cave/cave_shore))
		var/turf/open/desert/cave/cave_shore/C = src.loc
		C.toxic = src.toxic
		C.update_icon()



/obj/effect/blocker/water/Crossed(atom/A)
	if(toxic == 0)
		return

	if(istype(loc, /turf/open/gm/river/desert))
		var/turf/open/gm/river/desert/R = loc
		if(R.covered)
			return
	else
		return

	if(isliving(A))
		var/mob/living/M = A

		if(!istype(M.loc, /turf))
			return

		if(isxeno(M))
			if(M.pulling)
				to_chat(M, SPAN_WARNING("The current forces you to release [M.pulling]!"))
				M.stop_pulling()

		cause_damage(M)
		START_PROCESSING(SSobj, src)
		return
	else if(isVehicleMultitile(A))
		var/obj/vehicle/multitile/V = A

		if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
			V.handle_acidic_environment(src)
			START_PROCESSING(SSobj, src)
		return


/obj/effect/blocker/water/process()

	if(!toxic)
		STOP_PROCESSING(SSobj, src)
		return

	if(istype(src.loc, /turf/open/gm/river/desert))
		var/turf/open/gm/river/desert/R = loc
		if(R.covered)
			return
	else
		return

	var/targets_present = 0
	for(var/mob/living/carbon/M in range(0, src))
		targets_present++
		cause_damage(M)
	for(var/obj/vehicle/multitile/V in range(0, src))
		if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
			targets_present++
			V.handle_acidic_environment(src)

	if(targets_present < 1)
		STOP_PROCESSING(SSobj, src)

/obj/effect/blocker/water/proc/cause_damage(mob/living/M)
	if(M.stat == DEAD)
		return
	M.last_damage_data = create_cause_data("toxic water")
	if(islarva(M))
		M.apply_damage(2,BURN)
	else if(isxeno(M) && !islarva(M))
		M.apply_damage(34,BURN)
	else if(isyautja(M))
		M.apply_damage(0.5,BURN)
	else
		var/dam_amount = 3
		if(M.body_position == LYING_DOWN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
			M.apply_damage(dam_amount,BURN)
		else
			M.apply_damage(dam_amount,BURN,"l_leg")
			M.apply_damage(dam_amount,BURN,"l_foot")
			M.apply_damage(dam_amount,BURN,"r_leg")
			M.apply_damage(dam_amount,BURN,"r_foot")
			M.apply_damage(dam_amount,BURN,"groin")
		M.apply_effect(20,IRRADIATE,0)
		if( !issynth(M) )
			to_chat(M, SPAN_DANGER("The water burns!"))
	playsound(M, 'sound/bullets/acid_impact1.ogg', 13, 1)


/obj/effect/blocker/water/proc/disperse_spread(from_dir = 0, drain = FALSE)
	if((dispersing && !drain) || (!dispersing && drain))
		return

	for(var/direction in GLOB.alldirs)
		if(direction == from_dir)
			continue //doesn't check backwards

		var/effective_spread_delay
		switch(direction)
			if(NORTH,SOUTH,EAST,WEST)
				effective_spread_delay = spread_delay
			else
				effective_spread_delay = spread_delay * 1.414 //diagonal spreading takes longer

		for(var/obj/effect/blocker/water/W in get_step(src,direction) )
			if(W.disperse_group == src.disperse_group)
				spawn(effective_spread_delay)
					W.disperse_spread(turn(direction,180), drain)
	if(drain)
		drain()
	else
		disperse(from_dir)

/obj/effect/blocker/water/proc/drain()
	dispersing = 0
	animate(src, alpha = initial(alpha), time = 60)

/obj/effect/blocker/water/proc/disperse(from_dir)
	dispersing = 1
	if(prob(30))
		var/sound = pick(water_sounds)
		playsound(loc, sound, 10, 1)
	for(var/obj/effect/alien/weeds/weeds_to_clean in loc)
		qdel(weeds_to_clean)

	for(var/obj/effect/alien/resin/resin in loc)
		qdel(resin)

	for(var/obj/flamer_fire/fire in loc)
		qdel(fire)

	for(var/obj/item/item in loc)
		if(item.anchored)
			continue
		if(prob(70))
			item.throw_atom((get_step(loc,turn(from_dir,180))),1)

	animate(src, alpha= flooded_alpha, easing = BACK_EASING | EASE_OUT , time= 40)
	update_icon()

/obj/effect/blocker/water/toxic/disperse()
	.=..()
	toxic = -1

	update_turf()

	addtimer(CALLBACK(src, PROC_REF(do_disperse)), 1 SECONDS)

/obj/effect/blocker/water/toxic/proc/do_disperse()
	toxic = 0
	update_turf()
	dispersing = 0
