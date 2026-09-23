/datum/world_edit_blueprint_service/proc/world_edit_is_open_construction_turf_for_blueprint(turf/target_turf)
	if(!istype(target_turf, /turf/open))
		return FALSE

	var/turf/open/open_turf = target_turf
	return open_turf.allow_construction ? TRUE : FALSE

/datum/world_edit_blueprint_service/proc/world_edit_has_dense_blocker_for_blueprint(turf/target_turf)
	return GLOB.world_edit_helpers.has_dense_nonmob_blocker(target_turf)

/datum/world_edit_blueprint_service/proc/world_edit_can_place_blueprint_wall_detail(turf/target_turf, obj_path, list/rule = null)
	if(!istype(target_turf) || !target_turf.density)
		return FALSE
	if(!islist(rule))
		rule = world_edit_get_blueprint_type_rule(obj_path)
	if(!GLOB.world_edit_helpers.parse_bool(rule?["allow_wall_turf"]))
		return FALSE
	return !world_edit_has_dense_blocker_for_blueprint(target_turf)

/datum/world_edit_blueprint_service/proc/world_edit_validate_blueprint_target_turf(turf/target_turf, obj_path, dir_value = SOUTH)
	var/list/rule = world_edit_get_blueprint_type_rule(obj_path)
	if(!world_edit_is_open_construction_turf_for_blueprint(target_turf))
		if(world_edit_can_place_blueprint_wall_detail(target_turf, obj_path, rule))
			return null
		return "Blueprint target must be an open construction turf."

	if(ispath(obj_path, /obj/structure/barricade) || (islist(rule) && "[rule["category"]]" == "barricade"))
		for(var/turf/occupied_turf as anything in world_edit_get_blueprint_occupied_turfs(target_turf, obj_path, dir_value))
			if(!world_edit_is_open_construction_turf_for_blueprint(occupied_turf))
				return "Blueprint barricade target must be open construction turf."
			if(GLOB.world_edit_helpers.has_dense_nonmob_blocker(occupied_turf, TRUE))
				return "Blueprint barricade target is blocked."
			if(GLOB.world_edit_helpers.has_barricade_in_dir(occupied_turf, dir_value))
				return "Blueprint target already contains a barricade in that direction."
		return null

	if(ispath(obj_path, /obj/structure/machinery/defenses))
		if(world_edit_has_dense_blocker_for_blueprint(target_turf))
			return "Blueprint defense target is blocked."
		for(var/obj/structure/machinery/defenses/existing_defense in target_turf)
			return "Blueprint target already contains a defense structure."
		return null

	if(islist(rule) && "[rule["category"]]" == "mine")
		if(world_edit_has_dense_blocker_for_blueprint(target_turf))
			return "Blueprint mine target is blocked."
		for(var/obj/item/existing_item as anything in target_turf)
			if(istype(existing_item, /obj/item/explosive/mine) || istype(existing_item, /obj/item/device/assembly/prox_sensor/active))
				return "Blueprint target already contains a mine."
		return null

	if(islist(rule) && "[rule["category"]]" == "support_prop")
		if(world_edit_has_dense_blocker_for_blueprint(target_turf))
			return "Blueprint support object target is blocked."
		for(var/obj/existing_object as anything in target_turf)
			if(!istype(existing_object, /obj/structure/barricade))
				return "Blueprint target already contains a non-barricade structure."
		return null

	if(islist(rule) && "[rule["category"]]" == "building_object")
		if(world_edit_has_dense_blocker_for_blueprint(target_turf))
			return "Building blueprint target is blocked for an object."
		return null

	return "Blueprint contains an unsupported placement type."

/datum/world_edit_blueprint_service/proc/world_edit_spawn_blueprint_entry(list/placement)
	var/obj_path = placement["obj_path"]
	var/turf/target_turf = placement["turf"]
	var/dir_value = placement["dir"]
	var/list/entry_vars = placement["vars"] || list()
	if(!istype(target_turf) || !ispath(obj_path, /obj))
		return null
	var/list/rule = world_edit_get_blueprint_type_rule(obj_path)

	if(ispath(obj_path, /obj/structure/barricade) || (islist(rule) && "[rule["category"]]" == "barricade"))
		var/obj/barricade_object = new obj_path(target_turf)
		if(istype(barricade_object))
			barricade_object.setDir(dir_value)
		return barricade_object

	if(ispath(obj_path, /obj/structure/machinery/defenses))
		var/obj/structure/machinery/defenses/defense = new obj_path(target_turf)
		defense.setDir(dir_value)
		defense.placed = TRUE
		if(entry_vars["faction"])
			defense.handle_iff(entry_vars["faction"])
		if(GLOB.world_edit_helpers.parse_bool(entry_vars["turned_on"]))
			defense.power_on()
		else
			defense.power_off()
		return defense

	if(islist(rule) && "[rule["category"]]" == "mine")
		var/obj/item/mine_object = new obj_path(target_turf)
		if(istype(mine_object))
			mine_object.setDir(dir_value)
			if(entry_vars["faction"] && ("iff_signal" in mine_object.vars))
				mine_object.vars["iff_signal"] = entry_vars["faction"]
		return mine_object

	if(islist(rule) && "[rule["category"]]" == "support_prop")
		var/obj/structure/support_object = new obj_path(target_turf)
		if(istype(support_object))
			support_object.setDir(dir_value)
			if(GLOB.world_edit_helpers.parse_bool(placement["wall_mounted"]))
				var/wall_dir = text2num("[placement["wall_dir"]]")
				if(!wall_dir)
					wall_dir = dir_value
				GLOB.world_edit_helpers.align_object_to_wall(support_object, wall_dir)
		return support_object

	if(islist(rule) && "[rule["category"]]" == "building_object")
		var/obj/building_object = new obj_path(target_turf)
		if(istype(building_object))
			building_object.setDir(dir_value)
			if(GLOB.world_edit_helpers.parse_bool(placement["wall_mounted"]))
				var/wall_dir = text2num("[placement["wall_dir"]]")
				if(!wall_dir)
					wall_dir = dir_value
				GLOB.world_edit_helpers.align_object_to_wall(building_object, wall_dir)
		return building_object

	return null
