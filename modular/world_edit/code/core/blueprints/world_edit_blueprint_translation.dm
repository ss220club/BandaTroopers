/datum/world_edit_blueprint_service/proc/world_edit_build_covenant_barrier_merge_key(turf/target_turf, dir_value)
	if(!istype(target_turf) || !(dir_value in GLOB.cardinals))
		return null
	return "[target_turf.x],[target_turf.y],[target_turf.z]:[dir_value]"

/datum/world_edit_blueprint_service/proc/world_edit_get_single_covenant_barrier_merge_key(list/placement)
	if(!islist(placement) || "[placement["kind"]]" != "blueprint_spawn")
		return null
	if(placement["obj_path"] != /obj/structure/covenant_barricade)
		return null
	return world_edit_build_covenant_barrier_merge_key(placement["turf"], placement["dir"])

/datum/world_edit_blueprint_service/proc/world_edit_merge_covenant_triptych_placements(list/placements)
	var/list/result = list()
	if(!islist(placements) || !length(placements))
		return result

	var/list/single_lookup = list()
	for(var/list/placement as anything in placements)
		var/placement_key = world_edit_get_single_covenant_barrier_merge_key(placement)
		if(length(placement_key))
			single_lookup[placement_key] = placement

	var/list/consumed_lookup = list()
	var/list/center_wide_lookup = list()
	for(var/list/placement as anything in placements)
		var/center_key = world_edit_get_single_covenant_barrier_merge_key(placement)
		if(!length(center_key) || consumed_lookup[center_key])
			continue

		var/turf/center_turf = placement["turf"]
		var/dir_value = placement["dir"]
		var/turf/side_a_turf = get_step(center_turf, turn(dir_value, 90))
		var/turf/side_b_turf = get_step(center_turf, turn(dir_value, -90))
		var/side_a_key = world_edit_build_covenant_barrier_merge_key(side_a_turf, dir_value)
		var/side_b_key = world_edit_build_covenant_barrier_merge_key(side_b_turf, dir_value)
		if(!length(side_a_key) || !length(side_b_key) || consumed_lookup[side_a_key] || consumed_lookup[side_b_key])
			continue
		if(!islist(single_lookup[side_a_key]) || !islist(single_lookup[side_b_key]))
			continue

		var/list/wide_placement = placement.Copy()
		wide_placement["obj_path"] = /obj/structure/covenant_barricade/wide
		wide_placement["merged_from_covenant_triptych"] = TRUE
		center_wide_lookup[center_key] = wide_placement
		consumed_lookup[side_a_key] = TRUE
		consumed_lookup[center_key] = TRUE
		consumed_lookup[side_b_key] = TRUE

	for(var/list/placement as anything in placements)
		var/placement_key = world_edit_get_single_covenant_barrier_merge_key(placement)
		if(length(placement_key))
			if(islist(center_wide_lookup[placement_key]))
				result += list(center_wide_lookup[placement_key])
				continue
			if(consumed_lookup[placement_key])
				continue
		result += list(placement)

	return result

/datum/world_edit_blueprint_service/proc/world_edit_build_plan_from_blueprint(list/blueprint, turf/anchor_turf, placement_dir = NORTH)
	var/datum/world_edit_plan/plan = new
	if(!anchor_turf)
		plan.metadata["error"] = "Не удалось определить опорный тайл шаблона."
		return plan

	if(!islist(blueprint))
		plan.metadata["error"] = "Отсутствуют данные шаблона."
		return plan

	var/list/entries = blueprint["entries"]
	if(!islist(entries) || !length(entries))
		plan.metadata["error"] = "Шаблон не содержит записей."
		return plan

	var/list/affected_lookup = list()
	var/list/placement_lookup = list()
	var/list/turf_lookup = list()
	var/blocked_entry_count = 0
	var/duplicate_entry_count = 0
	for(var/list/entry as anything in entries)
		var/atom_path = text2path("[entry["type"]]")
		var/list/rotated_offset = world_edit_rotate_blueprint_offset(text2num("[entry["dx"]]"), text2num("[entry["dy"]]"), placement_dir)
		var/turf/target_turf = locate(anchor_turf.x + rotated_offset["dx"], anchor_turf.y + rotated_offset["dy"], anchor_turf.z)
		if(!istype(target_turf))
			plan.metadata["error"] = "Шаблон выходит за пределы текущего z-уровня."
			return plan

		var/dir_value = world_edit_rotate_blueprint_dir(text2num("[entry["dir"]]"), placement_dir)
		if(ispath(atom_path, /turf))
			var/turf_key = "[target_turf.x],[target_turf.y],[target_turf.z]"
			if(turf_lookup[turf_key])
				duplicate_entry_count++
				continue
			turf_lookup[turf_key] = TRUE
			affected_lookup[target_turf] = TRUE
			plan.placements += list(list(
				"kind" = "blueprint_turf",
				"turf_path" = atom_path,
				"turf" = target_turf,
				"x" = target_turf.x,
				"y" = target_turf.y,
				"z" = target_turf.z,
				"dir" = SOUTH,
			))
			continue

		var/obj_path = atom_path
		var/list/placement_keys = world_edit_build_blueprint_target_slot_keys(target_turf, obj_path, dir_value)
		if(!length(placement_keys))
			plan.metadata["error"] = "Шаблон содержит недопустимый слот направленного размещения."
			return plan
		var/has_duplicate_slot = FALSE
		for(var/placement_key as anything in placement_keys)
			if(placement_lookup[placement_key])
				has_duplicate_slot = TRUE
				break
		if(has_duplicate_slot)
			duplicate_entry_count++
			continue

		var/error_text = world_edit_validate_blueprint_target_turf(target_turf, obj_path, dir_value)
		if(error_text)
			if(error_text == "Blueprint contains an unsupported placement type." || error_text == "Шаблон содержит неподдерживаемый тип размещения.")
				plan.metadata["error"] = error_text
				return plan
			if(isnull(plan.metadata["first_blocked_turf"]))
				plan.metadata["first_blocked_turf"] = "[target_turf.x],[target_turf.y],[target_turf.z]"
			blocked_entry_count++
			continue

		for(var/placement_key as anything in placement_keys)
			placement_lookup[placement_key] = TRUE
		plan.placements += list(list(
			"kind" = "blueprint_spawn",
			"obj_path" = obj_path,
			"turf" = target_turf,
			"x" = target_turf.x,
			"y" = target_turf.y,
			"z" = target_turf.z,
			"dir" = dir_value,
			"vars" = entry["vars"] || list(),
		))

	var/pre_merge_placement_count = length(plan.placements)
	plan.placements = world_edit_merge_covenant_triptych_placements(plan.placements)
	var/covenant_triptych_merge_count = max(round((pre_merge_placement_count - length(plan.placements)) / 2), 0)
	for(var/list/placement as anything in plan.placements)
		for(var/turf/affected_turf as anything in world_edit_get_blueprint_occupied_turfs(placement["turf"], placement["obj_path"], placement["dir"]))
			affected_lookup[affected_turf] = TRUE

	for(var/turf/affected_turf as anything in affected_lookup)
		plan.affected_turfs += affected_turf

	plan.metadata["center_turf"] = anchor_turf
	plan.metadata["blueprint_id"] = blueprint["id"]
	plan.metadata["blueprint_name"] = blueprint["name"]
	plan.metadata["entry_count"] = length(plan.placements)
	plan.metadata["blocked_entry_count"] = blocked_entry_count
	plan.metadata["duplicate_entry_count"] = duplicate_entry_count
	plan.metadata["skipped_entry_count"] = blocked_entry_count + duplicate_entry_count
	plan.metadata["covenant_triptych_merge_count"] = covenant_triptych_merge_count
	plan.metadata["radius"] = blueprint["bounds"] ? blueprint["bounds"]["radius"] : 0
	plan.metadata["placement_dir"] = placement_dir
	plan.metadata["placement_dir_label"] = GLOB.world_edit_helpers.dir_to_label(placement_dir)
	if(islist(blueprint["outpost_recipe"]))
		plan.metadata["outpost_recipe"] = blueprint["outpost_recipe"]
	return plan
