// Human AI emplacement API.
// Stationary sniper and machinegunner home positions.

/datum/human_ai_brain/proc/has_sniper_home()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.has_sniper_home()

/datum/human_ai_brain/proc/set_sniper_home(turf/home, new_dir = SOUTH)
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	emplacement_module?.set_sniper_home(home, new_dir)

/datum/human_ai_brain/proc/get_sniper_home()
	RETURN_TYPE(/turf)
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.get_sniper_home()

/datum/human_ai_brain/proc/get_sniper_dir()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.get_sniper_dir()

/datum/human_ai_brain/proc/has_machinegunner_home()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.has_machinegunner_home()

/datum/human_ai_brain/proc/set_machinegunner_home(turf/home, new_dir = SOUTH)
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	emplacement_module?.set_machinegunner_home(home, new_dir)

/datum/human_ai_brain/proc/get_machinegunner_home()
	RETURN_TYPE(/turf)
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.get_machinegunner_home()

/datum/human_ai_brain/proc/get_machinegunner_dir()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.get_machinegunner_dir()

/datum/human_ai_brain/proc/is_stationary_fire_blocked()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	if(!emplacement_module)
		return FALSE
	return emplacement_module.is_stationary_fire_blocked()

/datum/human_ai_brain/proc/get_machinegunner_nest_weight()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.get_machinegunner_nest_weight() || 0

/datum/human_ai_brain/proc/get_sniper_nest_weight()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	return emplacement_module?.get_sniper_nest_weight() || 0

/datum/human_ai_brain/proc/start_stationary_nest_action()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	emplacement_module?.start_stationary_nest_action()

/datum/human_ai_brain/proc/stop_stationary_nest_action()
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	emplacement_module?.stop_stationary_nest_action()

/datum/human_ai_brain/proc/perform_machinegunner_nest(datum/human_tied_controller/controller)
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	if(!emplacement_module)
		return ONGOING_ACTION_COMPLETED
	return emplacement_module.perform_machinegunner_nest(controller)

/datum/human_ai_brain/proc/perform_sniper_nest(datum/human_tied_controller/controller)
	var/datum/human_ai_module/emplacement/emplacement_module = get_emplacement_module()
	if(!emplacement_module)
		return ONGOING_ACTION_COMPLETED
	return emplacement_module.perform_sniper_nest(controller)
