/proc/squad_name_get_runtime(static_name)
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager)
		return static_name
	return manager.get_runtime_name_by_static(static_name)

/proc/squad_name_try_apply_leader_preference(mob/living/carbon/human/H)
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager)
		return FALSE
	return manager.try_apply_leader_preference(H)

/proc/squad_name_apply_roundstart_defaults()
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager)
		return FALSE
	return manager.apply_roundstart_defaults()
