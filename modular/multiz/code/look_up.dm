// Adapted from RU-CMSS13 PR #82: let players on a lower level inspect the open level above.
/mob/living/var/mob/hologram/look_up/lookup_eye

/mob/living/verb/look_up()
	set name = "Look Up"
	set category = "IC"

	if(lookup_eye)
		QDEL_NULL(lookup_eye)
		return
	if(!client || !isturf(loc))
		return
	if(client.view != world.view || HAS_TRAIT(src, TRAIT_ABILITY_BURROWED))
		to_chat(src, SPAN_WARNING("You cannot look up while zoomed or burrowed."))
		return

	var/turf/above = SSmapping.get_turf_above(src)
	if(!istype(above, /turf/open_space))
		to_chat(src, SPAN_WARNING("There is no open space above you."))
		return
	lookup_eye = new /mob/hologram/look_up(above, src)

/atom/movable/screen/alert/multi_z
	name = "Look Up"
	desc = "Click to look through an opening above you."
	icon_state = "uphint0"
	click_master = FALSE

/atom/movable/screen/alert/multi_z/proc/setup(mob/living/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(update_alert))
	update_alert(user)

/atom/movable/screen/alert/multi_z/Destroy()
	if(owner)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	return ..()

/atom/movable/screen/alert/multi_z/clicked()
	. = ..()
	if(.)
		var/mob/living/living_owner = owner
		living_owner.look_up()

/atom/movable/screen/alert/multi_z/proc/update_alert(mob/living/user)
	SIGNAL_HANDLER
	if(!user || !isturf(user.loc))
		return
	if(!(user.z in SSmapping.levels_by_trait(ZTRAIT_UP)))
		icon_state = "blank"
		return
	var/turf/above = SSmapping.get_turf_above(user)
	var/open_above = istype(above, /turf/open_space)
	if(isxeno(user))
		icon_state = open_above ? "uphint1_xeno" : "uphint0_xeno"
	else
		icon_state = open_above ? "uphint1" : "uphint0"
	desc = open_above ? "Click to look through the opening above you." : "There is no opening above you."

/mob/hologram/look_up
	var/view_registered = TRUE
	var/list/view_blocker_images = list()

/mob/hologram/look_up/Initialize(mapload, mob/viewer)
	. = ..()
	if(viewer)
		UnregisterSignal(viewer, COMSIG_CLIENT_MOB_MOVE)
		RegisterSignal(viewer, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
		RegisterSignal(viewer, COMSIG_MOB_GHOSTIZE, PROC_REF(end_lookup))
		update_view_blockers(viewer)

/mob/hologram/look_up/Destroy()
	if(linked_mob)
		UnregisterSignal(linked_mob, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_GHOSTIZE))
		var/mob/living/living_viewer = linked_mob
		living_viewer.lookup_eye = null
		if(linked_mob.client)
			linked_mob.client.images -= view_blocker_images
	view_blocker_images.Cut()
	return ..()

/mob/hologram/look_up/proc/update_view_blockers(mob/user)
	if(!user?.client)
		return
	user.client.images -= view_blocker_images
	view_blocker_images.Cut()
	var/list/visible_turfs = list()
	for(var/turf/cur_turf in view(world.view + 1, user))
		visible_turfs["[cur_turf.x]-[cur_turf.y]"] = TRUE
	for(var/x in user.x - world.view - 1 to user.x + world.view + 1)
		for(var/y in user.y - world.view - 1 to user.y + world.view + 1)
			if(visible_turfs["[x]-[y]"])
				continue
			var/turf/cur_turf = locate(x, y, user.z + 1)
			if(istype(cur_turf, /turf/open_space))
				var/image/view_blocker = image('icons/turf/floors/floors.dmi', cur_turf, "full_black", 100000)
				view_blocker.plane = GAME_PLANE
				view_blocker_images += view_blocker
				user.client.images += view_blocker

/mob/hologram/look_up/handle_move(mob/M, oldLoc, direct)
	SIGNAL_HANDLER
	if(!isturf(M.loc) || HAS_TRAIT(src, TRAIT_ABILITY_BURROWED))
		qdel(src)
		return
	if(isturf(oldLoc))
		var/turf/old_turf = oldLoc
		if(M.z != old_turf.z)
			qdel(src)
			return
		if(!direct)
			direct = get_dir(old_turf, M.loc)
	var/turf/new_turf = get_step(loc, direct)
	forceMove(new_turf)
	if(!istype(new_turf, /turf/open_space))
		UnregisterSignal(linked_mob, COMSIG_MOB_RESET_VIEW)
		view_registered = FALSE
		linked_mob.reset_view()
	else if(!view_registered)
		RegisterSignal(linked_mob, COMSIG_MOB_RESET_VIEW, PROC_REF(handle_view))
		view_registered = TRUE
		linked_mob.reset_view()
	update_view_blockers(linked_mob)

/mob/hologram/look_up/movement_delay()
	return linked_mob ? linked_mob.movement_delay() : -2

/mob/hologram/look_up/proc/end_lookup()
	SIGNAL_HANDLER
	qdel(src)
