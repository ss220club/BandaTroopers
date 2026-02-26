/proc/squad_name_get_runtime(static_name)
	if(!GLOB.squad_name_manager)
		return static_name
	return GLOB.squad_name_manager.get_runtime_name_by_static(static_name)

/proc/squad_name_try_apply_leader_preference(mob/living/carbon/human/H)
	if(!GLOB.squad_name_manager)
		return FALSE
	return GLOB.squad_name_manager.try_apply_leader_preference(H)

/proc/squad_name_apply_roundstart_defaults()
	if(!GLOB.squad_name_manager)
		return FALSE
	return GLOB.squad_name_manager.apply_roundstart_defaults()
