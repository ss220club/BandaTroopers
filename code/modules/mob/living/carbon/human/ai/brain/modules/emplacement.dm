/datum/human_ai_module/emplacement
	module_id = "emplacement"
	required_module_types = list(
		/datum/human_ai_module/cover,
		/datum/human_ai_module/guns,
		/datum/human_ai_module/health,
	)
	var/turf/sniper_home
	var/sniper_dir = SOUTH
	var/turf/machinegunner_home
	var/machinegunner_dir = SOUTH
	var/active_nest_initial_view
	var/active_nest_initial_reload_line_chance

/datum/human_ai_module/emplacement/proc/set_sniper_home(turf/home, new_dir = SOUTH)
	sniper_home = home
	sniper_dir = new_dir

/datum/human_ai_module/emplacement/proc/set_machinegunner_home(turf/home, new_dir = SOUTH)
	machinegunner_home = home
	machinegunner_dir = new_dir

/datum/human_ai_module/emplacement/proc/has_sniper_home()
	return sniper_home && !QDELETED(sniper_home)

/datum/human_ai_module/emplacement/proc/get_sniper_home()
	RETURN_TYPE(/turf)
	return sniper_home

/datum/human_ai_module/emplacement/proc/get_sniper_dir()
	return sniper_dir

/datum/human_ai_module/emplacement/proc/has_machinegunner_home()
	return machinegunner_home && !QDELETED(machinegunner_home)

/datum/human_ai_module/emplacement/proc/get_machinegunner_home()
	RETURN_TYPE(/turf)
	return machinegunner_home

/datum/human_ai_module/emplacement/proc/get_machinegunner_dir()
	return machinegunner_dir

/datum/human_ai_module/emplacement/proc/has_stationary_role()
	return has_sniper_home() || has_machinegunner_home()

/datum/human_ai_module/emplacement/proc/has_owner_tried_reload()
	return brain.has_tried_reload()

/datum/human_ai_module/emplacement/proc/should_owner_block_stationary_fire_for_cover()
	return brain.should_block_stationary_fire_for_cover()

/datum/human_ai_module/emplacement/proc/is_owner_healing_someone()
	return brain.is_healing_someone()

/datum/human_ai_module/emplacement/proc/has_owner_primary_weapon()
	return brain.has_primary_weapon()

/datum/human_ai_module/emplacement/proc/get_owner_primary_weapon()
	RETURN_TYPE(/obj/item/weapon/gun)
	return brain.get_primary_weapon()

/datum/human_ai_module/emplacement/proc/get_owner_view_distance()
	return brain.get_view_distance()

/datum/human_ai_module/emplacement/proc/set_owner_view_distance(new_view_distance)
	return brain.set_view_distance(new_view_distance)

/datum/human_ai_module/emplacement/proc/get_owner_reload_line_chance()
	return brain.get_reload_line_chance()

/datum/human_ai_module/emplacement/proc/set_owner_reload_line_chance(new_chance)
	return brain.set_reload_line_chance(new_chance)

/datum/human_ai_module/emplacement/proc/move_owner_to_turf(turf/destination)
	return brain.move_to_turf(destination)

/datum/human_ai_module/emplacement/proc/should_owner_reload()
	return brain.should_reload()

/datum/human_ai_module/emplacement/proc/unholster_owner_primary()
	return brain.unholster_primary()

/datum/human_ai_module/emplacement/proc/ensure_owner_primary_hand(obj/item/held_item)
	return brain.ensure_primary_hand(held_item)

/datum/human_ai_module/emplacement/proc/wield_owner_primary()
	return brain.wield_primary()

/datum/human_ai_module/emplacement/proc/is_stationary_fire_blocked()
	return has_owner_tried_reload() || should_owner_block_stationary_fire_for_cover() || is_owner_healing_someone()

/datum/human_ai_module/emplacement/proc/get_machinegunner_nest_weight()
	return get_stationary_nest_weight(has_machinegunner_home())

/datum/human_ai_module/emplacement/proc/get_sniper_nest_weight()
	return get_stationary_nest_weight(has_sniper_home())

/datum/human_ai_module/emplacement/proc/get_stationary_nest_weight(has_home)
	if(!has_home)
		return 0

	if(has_owner_tried_reload())
		return 0

	if(should_owner_block_stationary_fire_for_cover())
		return 0

	if(!has_owner_primary_weapon())
		return 0

	if(is_owner_healing_someone())
		return 0

	return 12

/datum/human_ai_module/emplacement/proc/start_stationary_nest_action()
	active_nest_initial_view = get_owner_view_distance()
	active_nest_initial_reload_line_chance = get_owner_reload_line_chance()
	set_owner_reload_line_chance(0)

/datum/human_ai_module/emplacement/proc/stop_stationary_nest_action()
	if(!isnull(active_nest_initial_view))
		set_owner_view_distance(active_nest_initial_view)
	if(!isnull(active_nest_initial_reload_line_chance))
		set_owner_reload_line_chance(active_nest_initial_reload_line_chance)
	active_nest_initial_view = null
	active_nest_initial_reload_line_chance = null

/datum/human_ai_module/emplacement/proc/perform_machinegunner_nest(datum/human_tied_controller/controller)
	return perform_stationary_nest(controller, get_machinegunner_home(), get_machinegunner_dir())

/datum/human_ai_module/emplacement/proc/perform_sniper_nest(datum/human_tied_controller/controller)
	return perform_stationary_nest(controller, get_sniper_home(), get_sniper_dir())

/datum/human_ai_module/emplacement/proc/perform_stationary_nest(datum/human_tied_controller/controller, turf/home, facing_dir)
	if(!controller)
		return ONGOING_ACTION_COMPLETED

	if(is_stationary_fire_blocked())
		return ONGOING_ACTION_COMPLETED

	var/obj/item/weapon/gun/primary_weapon = get_owner_primary_weapon()
	if(!primary_weapon)
		return ONGOING_ACTION_COMPLETED

	if(QDELETED(home))
		return ONGOING_ACTION_COMPLETED

	if(controller.get_distance_to(home) > 0)
		if(!move_owner_to_turf(home))
			return ONGOING_ACTION_COMPLETED

	if(!controller.get_distance_to(home))
		set_owner_view_distance(30)
		controller.face_dir(facing_dir)

	if(!should_owner_reload())
		unholster_owner_primary()
		ensure_owner_primary_hand(primary_weapon)
		wield_owner_primary()

	return ONGOING_ACTION_UNFINISHED
