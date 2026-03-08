/proc/squads_is_local_server()
	if(world.params && world.params["local_test"])
		return TRUE

	if(!world.TgsAvailable())
		return TRUE

	return FALSE

/proc/squads_debug_log(message)
	if(!message || !squads_is_local_server())
		return

	log_world("SS220 SQUADS DEBUG: [message]")
