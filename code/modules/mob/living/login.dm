
/mob/living/Login()
	//Mind updates
	mind_initialize() //updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1 //indicates that the mind is currently synced with a client

	..()
	// SS220 EDIT: show the multiz look-up control to connected players.
	var/atom/movable/screen/alert/multi_z/look_up_alert = throw_alert("multi_z", /atom/movable/screen/alert/multi_z)
	if(look_up_alert)
		look_up_alert.setup(src)

	if(LAZYLEN(pipes_shown)) //ventcrawling, need to reapply pipe vision
		var/obj/structure/pipes/A = loc
		if(istype(A)) //a sanity check just to be safe
			remove_ventcrawl()
			update_pipe_icons(A)

