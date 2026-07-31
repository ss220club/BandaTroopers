/datum/world_edit_generator/blueprint_stamp/proc/normalize_anchor_turfs(list/raw_anchor_turfs)
	var/list/anchor_turfs = list()
	var/list/anchor_lookup = list()
	if(!islist(raw_anchor_turfs))
		return anchor_turfs

	for(var/turf/anchor_turf as anything in raw_anchor_turfs)
		if(!istype(anchor_turf))
			continue
		if(anchor_lookup[anchor_turf])
			continue
		anchor_lookup[anchor_turf] = TRUE
		anchor_turfs += anchor_turf

	return anchor_turfs

/datum/world_edit_generator/blueprint_stamp/proc/build_blueprint_placement_key(list/placement)
	var/turf/target_turf = placement["turf"]
	if(!istype(target_turf))
		return null

	if("[placement["kind"]]" == "blueprint_turf")
		return "turf:[target_turf.x],[target_turf.y],[target_turf.z]"

	var/obj_path = placement["obj_path"]
	if(ispath(obj_path, /obj/structure/barricade))
		return GLOB.world_edit_helpers.build_turf_dir_slot_key(target_turf, placement["dir"])

	return "[target_turf.x],[target_turf.y],[target_turf.z]"

/datum/world_edit_generator/blueprint_stamp/proc/build_blueprint_placement_physical_cell_keys(list/placement)
	var/list/cell_keys = list()
	var/turf/target_turf = placement["turf"]
	if(!istype(target_turf))
		return cell_keys

	if("[placement["kind"]]" == "blueprint_turf")
		cell_keys += GLOB.world_edit_helpers.turf_to_text(target_turf)
		return cell_keys

	var/obj_path = placement["obj_path"]
	if(!ispath(obj_path, /obj))
		cell_keys += GLOB.world_edit_helpers.turf_to_text(target_turf)
		return cell_keys

	for(var/turf/occupied_turf as anything in GLOB.world_edit_blueprints.world_edit_get_blueprint_occupied_turfs(target_turf, obj_path, placement["dir"]))
		var/cell_key = GLOB.world_edit_helpers.turf_to_text(occupied_turf)
		if(length(cell_key))
			cell_keys += cell_key

	return cell_keys

/datum/world_edit_generator/blueprint_stamp/evaluate_shape_contract(datum/world_edit_shape_contract/shape_contract, list/params, list/placement_context)
	var/list/load_result = load_active_blueprint(params)
	if(load_result["error"])
		return list(
			"support_class" = "unsupported",
			"error" = "[load_result["error"]]",
			"metadata" = list("shape_support_class" = "full"),
		)

	return list(
		"support_class" = "full",
		"error" = null,
		"metadata" = list("shape_support_class" = "full"),
	)

/datum/world_edit_generator/blueprint_stamp/build_plan_from_shape_contract(mob/user, datum/world_edit_shape_contract/shape_contract, list/params, list/placement_context)
	var/datum/world_edit_plan/plan = new
	var/list/load_result = load_active_blueprint(params)
	if(load_result["error"])
		plan.metadata["error"] = "[load_result["error"]]"
		return plan

	var/list/blueprint = load_result["blueprint"]
	var/list/anchor_turfs = normalize_anchor_turfs(shape_contract?.copy_anchor_turfs() || placement_context["anchor_turfs"])
	anchor_turfs = apply_stamp_spacing(anchor_turfs, params, blueprint)
	if(!length(anchor_turfs))
		plan.metadata["error"] = "Не удалось определить опорный тайл шаблона."
		return plan
	if(length(anchor_turfs) > WORLD_EDIT_PLACEMENT_MAX_ANCHORS)
		plan.metadata["error"] = "Запрошенный контур превышает безопасный лимит опор ([WORLD_EDIT_PLACEMENT_MAX_ANCHORS])."
		return plan

	var/placement_dir = text2num("[placement_context["direction"]]")
	if(!(placement_dir in GLOB.cardinals))
		placement_dir = manager?.get_effective_placement_dir() || NORTH

	var/list/affected_lookup = list()
	var/list/occupied_lookup = list()
	var/blocked_entry_count = 0
	var/duplicate_entry_count = 0
	var/overlap_entry_count = 0
	var/effective_spacing = get_effective_stamp_spacing(params, blueprint)
	var/list/dimensions = get_blueprint_footprint_dimensions(blueprint)
	for(var/turf/anchor_turf as anything in anchor_turfs)
		var/datum/world_edit_plan/anchor_plan = GLOB.world_edit_blueprints.world_edit_build_plan_from_blueprint(blueprint, anchor_turf, placement_dir)
		if(!istype(anchor_plan))
			plan.metadata["error"] = "Не удалось построить план шаблона."
			return plan
		if(anchor_plan.metadata["error"])
			plan.metadata = anchor_plan.metadata.Copy()
			plan.metadata["anchor_turf"] = "[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]"
			return plan
		blocked_entry_count += anchor_plan.metadata["blocked_entry_count"] || 0
		duplicate_entry_count += anchor_plan.metadata["duplicate_entry_count"] || 0

		var/list/anchor_placement_lookup = list()
		var/list/anchor_cell_lookup = list()
		var/list/anchor_placements = list()
		for(var/list/placement as anything in anchor_plan.placements)
			var/turf/target_turf = placement["turf"]
			var/placement_key = build_blueprint_placement_key(placement)
			if(!length(placement_key))
				overlap_entry_count++
				continue
			if(anchor_placement_lookup[placement_key])
				overlap_entry_count++
				continue

			var/list/physical_cell_keys = build_blueprint_placement_physical_cell_keys(placement)
			if(!length(physical_cell_keys))
				overlap_entry_count++
				continue

			var/has_cross_anchor_overlap = FALSE
			for(var/physical_cell_key as anything in physical_cell_keys)
				if(occupied_lookup[physical_cell_key])
					has_cross_anchor_overlap = TRUE
					break
			if(has_cross_anchor_overlap)
				overlap_entry_count++
				continue

			anchor_placement_lookup[placement_key] = TRUE
			for(var/physical_cell_key as anything in physical_cell_keys)
				anchor_cell_lookup[physical_cell_key] = TRUE
			affected_lookup[target_turf] = TRUE
			anchor_placements += list(placement.Copy())

		for(var/physical_cell_key as anything in anchor_cell_lookup)
			occupied_lookup[physical_cell_key] = TRUE
		plan.placements += anchor_placements

		if(length(plan.placements) > WORLD_EDIT_PLACEMENT_MAX_TOTAL_PLACEMENTS)
			plan.metadata["error"] = "Запрошенное размещение превышает безопасный лимит размещений ([WORLD_EDIT_PLACEMENT_MAX_TOTAL_PLACEMENTS])."
			return plan

	for(var/turf/affected_turf as anything in affected_lookup)
		plan.affected_turfs += affected_turf

	var/turf/center_turf = placement_context["end_turf"]
	if(!istype(center_turf))
		center_turf = anchor_turfs[clamp(round((length(anchor_turfs) + 1) / 2), 1, length(anchor_turfs))]

	plan.metadata["center_turf"] = center_turf
	plan.metadata["blueprint_id"] = blueprint["id"]
	plan.metadata["blueprint_name"] = blueprint["name"]
	plan.metadata["entry_count"] = length(plan.placements)
	plan.metadata["blueprint_entry_count"] = length(blueprint["entries"])
	plan.metadata["blocked_entry_count"] = blocked_entry_count
	plan.metadata["duplicate_entry_count"] = duplicate_entry_count
	plan.metadata["overlap_entry_count"] = overlap_entry_count
	plan.metadata["skipped_entry_count"] = blocked_entry_count + duplicate_entry_count + overlap_entry_count
	plan.metadata["radius"] = blueprint["bounds"] ? blueprint["bounds"]["radius"] : 0
	plan.metadata["footprint_width"] = dimensions["width"]
	plan.metadata["footprint_height"] = dimensions["height"]
	plan.metadata["stamp_spacing"] = effective_spacing
	finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
	plan.metadata["anchor_count"] = length(anchor_turfs)
	return plan

/datum/world_edit_generator/blueprint_stamp/build_placement_plan(mob/user, list/params, list/placement_context)
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract_from_placement_context(placement_context["shape"], placement_context["anchor_turfs"], placement_context)
	return build_plan_from_shape_contract(user, shape_contract, params, placement_context)

/datum/world_edit_generator/blueprint_stamp/get_shape_support_error(shape_id, list/anchor_turfs, list/params, list/placement_context)
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract_from_placement_context(shape_id, anchor_turfs, placement_context)
	var/list/support_result = evaluate_shape_contract(shape_contract, params, placement_context)
	return support_result["error"]

/datum/world_edit_generator/blueprint_stamp/build_plan(list/params)
	var/turf/anchor_turf = resolve_shape_anchor_turf(manager?.holder?.mob)
	var/list/shape_result = GLOB.world_edit_placement_shapes.world_edit_build_shape_turfs(manager?.get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT, anchor_turf, null, params, manager?.get_effective_placement_dir() || NORTH)
	if(shape_result["error"])
		var/datum/world_edit_plan/error_plan = new
		error_plan.metadata["error"] = "[shape_result["error"]]"
		return error_plan
	return build_placement_plan(manager?.holder?.mob, params, list(
		"mode" = manager?.get_effective_placement_mode() || "single",
		"shape" = manager?.get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT,
		"shape_metadata" = shape_result["metadata"] || list(),
		"anchor_turfs" = shape_result["turfs"] || list(anchor_turf),
		"direction" = manager?.get_effective_placement_dir(),
		"end_turf" = anchor_turf,
	))
