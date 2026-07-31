/datum/world_edit_building_template_cell
	var/dx = 0
	var/dy = 0
	var/slot = "table"
	var/category = "table"
	var/wall_required = FALSE
	var/major = TRUE

/datum/world_edit_building_template_cell/New(_dx = 0, _dy = 0, _slot = "table", _category = "table", _wall_required = FALSE, _major = TRUE)
	. = ..()
	dx = round(text2num("[_dx]") || 0)
	dy = round(text2num("[_dy]") || 0)
	slot = length("[_slot]") ? "[_slot]" : "table"
	category = length("[_category]") ? "[_category]" : "table"
	wall_required = _wall_required ? TRUE : FALSE
	major = _major ? TRUE : FALSE

/datum/world_edit_building_template_chunk
	var/id = ""
	var/category = "generic"
	var/list/cells = list()

/datum/world_edit_building_template_chunk/New(_id = "", _category = "generic")
	. = ..()
	id = "[_id]"
	category = length("[_category]") ? "[_category]" : "generic"
	cells = list()

/datum/world_edit_building_template_chunk/proc/add_cell(dx, dy, slot, category, wall_required = FALSE, major = TRUE)
	if(length(cells) >= WORLD_EDIT_BUILDING_MAX_TEMPLATE_CHUNK_CELLS)
		return src
	cells += new /datum/world_edit_building_template_cell(dx, dy, slot, category, wall_required, major)
	return src

/datum/world_edit_generator/building_layout/proc/register_building_template_chunk(list/catalog, datum/world_edit_building_template_chunk/chunk)
	if(!islist(catalog) || !istype(chunk) || !length(chunk.id) || !length(chunk.cells))
		return
	catalog[chunk.id] = chunk

/datum/world_edit_generator/building_layout/proc/get_building_template_chunk_file_manifest()
	return list(
		"bed_niche_chunk.dmm",
		"bed_run_chunk.dmm",
		"cabinet_run_chunk.dmm",
		"infrastructure_air_alarm_chunk.dmm",
		"infrastructure_fire_alarm_chunk.dmm",
		"infrastructure_light_chunk.dmm",
		"infrastructure_power_chunk.dmm",
		"infrastructure_switch_chunk.dmm",
		"living_chair_group_chunk.dmm",
		"living_dining_cluster_chunk.dmm",
		"living_side_table_chunk.dmm",
		"living_social_cluster_chunk.dmm",
		"living_social_ring_chunk.dmm",
		"living_window_seat_chunk.dmm",
		"sanitation_combined_chunk.dmm",
	)

/datum/world_edit_generator/building_layout/proc/get_building_template_chunk_catalog()
	var/static/list/template_catalog
	if(islist(template_catalog))
		return template_catalog
	template_catalog = list()

	var/list/file_lookup = list()
	var/list/files = flist("maps/templates/world_edit/building_layout/")
	for(var/manifest_file as anything in get_building_template_chunk_file_manifest())
		file_lookup["[manifest_file]"] = TRUE
	for(var/file in files)
		if(length("[file]"))
			file_lookup["[file]"] = TRUE
	for(var/file as anything in file_lookup)
		if(findtext(file, ".dmm"))
			var/template_chunk_id = copytext(file, 1, length(file) - 3) // Remove .dmm
			// Fallback category to generic, actual category could be derived or read from comments, but for now generic
			var/template_category = "generic"
			var/datum/world_edit_building_template_chunk/chunk = load_building_template_chunk_from_dmm("maps/templates/world_edit/building_layout/[file]", template_chunk_id, template_category)
			if(istype(chunk))
				register_building_template_chunk(template_catalog, chunk)

	return template_catalog

/datum/world_edit_generator/building_layout/proc/get_building_template_chunk(template_chunk_id)
	var/list/catalog = get_building_template_chunk_catalog()
	return catalog["[template_chunk_id]"]

/// Secondary lookup for macro_ids that resolve to non-existent chunks but have
/// an existing semantically compatible equivalent (same cell categories).
/// Only aliases where the alias target has matching slot/category cells are added.
/// This is a minimal contract-preserving fix for template_chunk_not_found.
/datum/world_edit_generator/building_layout/proc/resolve_building_template_chunk_alias(macro_id)
	var/static/list/alias_map = list(
		// Micro infrastructure → existing infrastructure (same category, compatible cells)
		"micro_light_chunk" = "infrastructure_light_chunk",
		"micro_power_chunk" = "infrastructure_power_chunk",
		"micro_air_alarm_chunk" = "infrastructure_air_alarm_chunk",
		"micro_fire_alarm_chunk" = "infrastructure_fire_alarm_chunk",
		"micro_switch_chunk" = "infrastructure_switch_chunk",

		// Micro furniture → existing non-micro run chunks (same category, compatible cells)
		"micro_cabinet_chunk" = "cabinet_run_chunk",
		"island_cabinet_chunk" = "cabinet_run_chunk",
		"wall_cabinet_chunk" = "cabinet_run_chunk",
		"micro_bed_chunk" = "bed_niche_chunk",
		"island_bed_chunk" = "bed_niche_chunk",
		"wall_toilet_chunk" = "sanitation_combined_chunk",
	)
	return alias_map["[macro_id]"]

/datum/world_edit_generator/building_layout/proc/resolve_existing_building_template_chunk_id(macro_id)
	var/raw_id = "[macro_id]"
	if(!length(raw_id))
		return ""
	var/list/catalog = get_building_template_chunk_catalog()
	var/datum/world_edit_building_template_chunk/chunk = catalog[raw_id]
	if(istype(chunk) && length(chunk.cells))
		return raw_id
	var/alias_id = resolve_building_template_chunk_alias(raw_id)
	if(!length(alias_id))
		return ""
	chunk = catalog["[alias_id]"]
	if(istype(chunk) && length(chunk.cells))
		return "[alias_id]"
	return ""

/datum/world_edit_generator/building_layout/proc/get_existing_building_template_chunk(macro_id)
	var/resolved_id = resolve_existing_building_template_chunk_id(macro_id)
	if(!length(resolved_id))
		return null
	return get_building_template_chunk(resolved_id)

/datum/world_edit_generator/building_layout/proc/get_template_offset_turf(turf/anchor_turf, dir_to_use, dx, dy)
	if(!istype(anchor_turf))
		return null
	var/turf/result = anchor_turf
	var/right_dir = turn(dir_to_use || SOUTH, 90)
	var/forward_dir = dir_to_use || SOUTH
	var/x_steps = abs(round(text2num("[dx]") || 0))
	for(var/step_index in 1 to x_steps)
		result = get_step(result, dx >= 0 ? right_dir : turn(right_dir, 180))
	var/y_steps = abs(round(text2num("[dy]") || 0))
	for(var/step_index in 1 to y_steps)
		result = get_step(result, dy >= 0 ? forward_dir : turn(forward_dir, 180))
	return result

/datum/world_edit_generator/building_layout/proc/can_place_building_template_chunk_at(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_template_chunk/chunk, turf/anchor_turf, dir_to_use, wall_dir)
	if(!istype(state) || !istype(cluster_spec) || !istype(chunk) || !istype(anchor_turf))
		return FALSE
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/planned_lookup = list()
	var/degraded_tiny_layout = is_building_compact_or_micro_state(state)
	if(!degraded_tiny_layout && istype(state.archetype))
		degraded_tiny_layout = length(state.geometry.floor_turfs) < get_building_program_required_compact_area(state.archetype)
	var/allow_reserved_template = degraded_tiny_layout && findtext(chunk.id, "micro")
	for(var/datum/world_edit_building_template_cell/cell as anything in chunk.cells)
		if(!istype(cell))
			continue
		var/turf/cell_turf = get_template_offset_turf(anchor_turf, dir_to_use, cell.dx, cell.dy)
		if(!istype(cell_turf))
			state.add_template_reject_reason("template_geometry_conflict", list(
				"scope" = "preflight",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"anchor_turf" = "[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]",
				"cell_offset" = "[cell.dx],[cell.dy]",
			))
			return FALSE
		var/owner = state.get_semantic_slot_owner(cell_turf)
		if(length(owner) && owner != requirement_id)
			state.add_template_reject_reason("semantic_reservation_conflict", list(
				"scope" = "preflight",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"owner" = owner,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
			))
			return FALSE
		if(!state.can_place_fixture(cell_turf, allow_reserved_template) || planned_lookup[cell_turf])
			state.add_template_reject_reason("template_geometry_conflict", list(
				"scope" = "preflight",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
				"duplicate_planned" = planned_lookup[cell_turf] ? TRUE : FALSE,
			))
			return FALSE
		if(!building_fixture_matches_semantic_zone_contract(state, cell_turf, cell.slot, cell.category, cluster_spec))
			state.add_template_reject_reason("zone_contract_failed", list(
				"scope" = "preflight",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"slot" = cell.slot,
				"category" = cell.category,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
			))
			return FALSE
		var/list/cell_context = resolve_template_cell_context(state, cell_turf, cell, dir_to_use, wall_dir, cluster_spec)
		if(!islist(cell_context))
			state.add_template_reject_reason(cell.wall_required ? "missing_wall_context" : "place_rule_failed", list(
				"scope" = "preflight",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"slot" = cell.slot,
				"category" = cell.category,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
				"wall_required" = cell.wall_required ? TRUE : FALSE,
			))
			return FALSE
		planned_lookup[cell_turf] = TRUE
	return TRUE

/datum/world_edit_generator/building_layout/proc/build_template_chunk_candidate_turfs(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_template_chunk/chunk, list/anchor_override = null)
	var/list/candidates = list()
	var/list/candidate_scores = list()
	if(!istype(state) || !istype(cluster_spec) || !istype(chunk))
		return list("turfs" = candidates, "scores" = candidate_scores)
	var/list/anchor_ids = islist(anchor_override) ? anchor_override : get_cluster_preflight_anchor_ids(state, cluster_spec, cluster_spec.anchors)
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/degraded_tiny_layout = is_building_compact_or_micro_state(state)
	if(!degraded_tiny_layout && istype(state.archetype))
		degraded_tiny_layout = length(state.geometry.floor_turfs) < get_building_program_required_compact_area(state.archetype)
	var/allow_reserved_template = degraded_tiny_layout && findtext(chunk.id, "micro")
	var/max_layout_candidates = building_layout_solver_enabled(state) ? max(8, cluster_spec.max_count * 4) : 0
	var/max_evaluated_candidates = building_layout_solver_enabled(state) ? 14 : 0
	var/evaluated_candidates = 0
	for(var/turf/floor_turf as anything in get_fixture_candidate_turfs_for_anchors(state, anchor_ids))
		if(max_evaluated_candidates > 0 && evaluated_candidates >= max_evaluated_candidates)
			break
		evaluated_candidates++
		if(!building_fixture_candidate_has_entry_access(state, floor_turf, cluster_spec))
			continue
		var/owner = state.get_semantic_slot_owner(floor_turf)
		if(length(owner) && owner != requirement_id)
			state.add_template_reject_reason("semantic_reservation_conflict", list(
				"scope" = "candidate",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"owner" = owner,
				"anchor_turf" = "[floor_turf.x],[floor_turf.y],[floor_turf.z]",
			))
			continue
		if(!state.can_place_fixture(floor_turf, allow_reserved_template))
			state.add_template_reject_reason("template_geometry_conflict", list(
				"scope" = "candidate",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"anchor_turf" = "[floor_turf.x],[floor_turf.y],[floor_turf.z]",
			))
			continue
		if(!fixture_turf_matches_anchor(state, floor_turf, anchor_ids))
			state.add_template_reject_reason("missing_anchor_match", list(
				"scope" = "candidate",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"anchor_turf" = "[floor_turf.x],[floor_turf.y],[floor_turf.z]",
				"anchors" = islist(anchor_ids) ? anchor_ids.Copy() : list(),
			))
			continue
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
		var/effective_needs_wall = get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
		var/fallback_dir = get_cardinal_dir_toward(floor_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
		var/list/place_context = build_building_fixture_place_context(state, floor_turf, place_rule, fallback_dir, effective_needs_wall, cluster_spec, anchor_ids)
		if(!islist(place_context))
			state.add_template_reject_reason(effective_needs_wall ? "missing_wall_context" : "place_rule_failed", list(
				"scope" = "candidate",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"anchor_turf" = "[floor_turf.x],[floor_turf.y],[floor_turf.z]",
				"needs_wall" = effective_needs_wall ? TRUE : FALSE,
			))
			continue
		if(!can_place_building_template_chunk_at(state, cluster_spec, chunk, floor_turf, place_context["dir"] || fallback_dir, place_context["wall_dir"]))
			continue
		var/score = score_fixture_turf(state, floor_turf, anchor_ids, effective_needs_wall, cluster_spec, place_rule)
		if(cluster_turf_is_preflight_planned(state, cluster_spec, floor_turf))
			score += 5000
		score += length(chunk.cells) * 35
		candidates += floor_turf
		candidate_scores[floor_turf] = score
		if(max_layout_candidates > 0 && length(candidates) >= max_layout_candidates)
			break
	return list("turfs" = candidates, "scores" = candidate_scores)

/datum/world_edit_generator/building_layout/proc/select_best_template_candidate(list/candidates, list/candidate_scores)
	var/turf/best_turf = null
	var/best_score = -999999999
	for(var/turf/candidate as anything in candidates)
		if(!istype(candidate))
			continue
		var/score = round(text2num("[candidate_scores[candidate]]") || 0)
		if(!istype(best_turf) || score > best_score)
			best_turf = candidate
			best_score = score
	return best_turf

/datum/world_edit_generator/building_layout/proc/resolve_template_cell_context(datum/world_edit_building_layout_state/state, turf/cell_turf, datum/world_edit_building_template_cell/cell, dir_to_use, wall_dir, datum/world_edit_building_cluster_spec/cluster_spec)
	var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cell.slot, cell.category)
	var/needs_wall = cell.wall_required || get_cluster_effective_needs_wall(state, cluster_spec, place_rule)
	var/cell_wall_dir = wall_dir
	if(needs_wall && (isnull(cell_wall_dir) || !state.geometry.wall_lookup[get_step(cell_turf, cell_wall_dir)]))
		var/list/wall_context = build_building_fixture_wall_context(state, cell_turf, place_rule, cluster_spec, cluster_spec?.anchors)
		if(!islist(wall_context))
			cell_wall_dir = null
		else
			cell_wall_dir = wall_context["wall_dir"]
			var/context_dir = wall_context["dir"]
			if(building_place_rule_allows_turf(state, cell_turf, place_rule, context_dir, cell_wall_dir))
				return list("rule" = place_rule, "dir" = context_dir, "wall_dir" = cell_wall_dir, "wall_mounted" = TRUE, "dir_source" = wall_context["dir_source"])
	if(needs_wall && isnull(cell_wall_dir))
		return null
	var/cell_dir = !isnull(cell_wall_dir) ? resolve_building_place_rule_dir(cell_wall_dir, place_rule.dir_mode) : dir_to_use
	if(!building_place_rule_allows_turf(state, cell_turf, place_rule, cell_dir, cell_wall_dir))
		return null
	return list("rule" = place_rule, "dir" = cell_dir, "wall_dir" = cell_wall_dir, "wall_mounted" = needs_wall, "dir_source" = needs_wall ? "template_wall" : "template_parent")

/datum/world_edit_generator/building_layout/proc/try_place_building_template_chunk_at(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, datum/world_edit_building_template_chunk/chunk, turf/anchor_turf, dir_to_use, wall_dir, major)
	if(!istype(state) || !istype(cluster_spec) || !istype(chunk) || !istype(anchor_turf))
		return 0
	var/requirement_id = get_building_cluster_requirement_id(cluster_spec)
	var/list/planned_cells = list()
	var/list/planned_lookup = list()
	var/degraded_tiny_layout = is_building_compact_or_micro_state(state)
	if(!degraded_tiny_layout && istype(state.archetype))
		degraded_tiny_layout = length(state.geometry.floor_turfs) < get_building_program_required_compact_area(state.archetype)
	var/allow_reserved_template = degraded_tiny_layout && findtext(chunk.id, "micro")
	for(var/datum/world_edit_building_template_cell/cell as anything in chunk.cells)
		if(!istype(cell))
			continue
		var/turf/cell_turf = get_template_offset_turf(anchor_turf, dir_to_use, cell.dx, cell.dy)
		if(!istype(cell_turf))
			state.add_template_reject_reason("template_geometry_conflict", list(
				"scope" = "placement",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"anchor_turf" = "[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]",
				"cell_offset" = "[cell.dx],[cell.dy]",
			))
			continue
		var/owner = state.get_semantic_slot_owner(cell_turf)
		if(length(owner) && owner != requirement_id)
			state.add_template_reject_reason("semantic_reservation_conflict", list(
				"scope" = "placement",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"owner" = owner,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
			))
			continue
		if(!state.can_place_fixture(cell_turf, allow_reserved_template) || planned_lookup[cell_turf])
			state.add_template_reject_reason("template_geometry_conflict", list(
				"scope" = "placement",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
				"duplicate_planned" = planned_lookup[cell_turf] ? TRUE : FALSE,
			))
			continue
		if(!building_fixture_matches_semantic_zone_contract(state, cell_turf, cell.slot, cell.category, cluster_spec))
			state.add_template_reject_reason("zone_contract_failed", list(
				"scope" = "placement",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"slot" = cell.slot,
				"category" = cell.category,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
			))
			continue
		var/list/cell_context = resolve_template_cell_context(state, cell_turf, cell, dir_to_use, wall_dir, cluster_spec)
		if(!islist(cell_context))
			state.add_template_reject_reason(cell.wall_required ? "missing_wall_context" : "place_rule_failed", list(
				"scope" = "placement",
				"cluster_id" = cluster_spec.id,
				"requirement_id" = requirement_id,
				"chunk_id" = chunk.id,
				"slot" = cell.slot,
				"category" = cell.category,
				"cell_turf" = "[cell_turf.x],[cell_turf.y],[cell_turf.z]",
				"wall_required" = cell.wall_required ? TRUE : FALSE,
			))
			continue
		planned_lookup[cell_turf] = TRUE
		planned_cells += list(list("cell" = cell, "turf" = cell_turf, "context" = cell_context))
	if(!length(planned_cells))
		state.add_template_reject_reason("required_cluster_shortfall", list(
			"scope" = "placement",
			"cluster_id" = cluster_spec.id,
			"requirement_id" = requirement_id,
			"chunk_id" = chunk.id,
			"anchor_turf" = "[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]",
			"detail" = "no_planned_cells",
		))
		return 0
	var/placed = 0
	var/credit_count = 0
	var/list/covered_turfs = list()
	var/template_chunk_instance_id = "[chunk.id]@[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]/[dir_to_use]/[state.fixtures.template_chunk_count + 1]"
	for(var/list/planned as anything in planned_cells)
		var/datum/world_edit_building_template_cell/cell = planned["cell"]
		var/turf/cell_turf = planned["turf"]
		var/list/context = planned["context"]
		if(!place_fixture_at(state, cell_turf, cell.slot, context["dir"], cell.category, major && cell.major && placed <= 0, context["wall_mounted"], context["rule"], context["wall_dir"], cluster_spec, chunk.id, template_chunk_instance_id, context["dir_source"], allow_reserved_template))
			continue
		covered_turfs += cell_turf
		placed++
		credit_count += get_building_fixture_count_credit(cluster_spec, cell.slot, cell.category)
	if(placed > 0)
		state.fixtures.template_chunk_count++
		state.fixtures.template_chunk_cell_count += placed
		state.register_layout_macro(chunk.id, chunk.category, anchor_turf, dir_to_use, covered_turfs, list(cluster_spec.id))
	return credit_count

/datum/world_edit_generator/building_layout/proc/place_building_template_chunk_for_cluster(datum/world_edit_building_layout_state/state, datum/world_edit_building_cluster_spec/cluster_spec, major)
	if(!istype(state) || !istype(cluster_spec) || !length(cluster_spec.macro_id))
		return 0
	var/requested_macro_id = "[cluster_spec.macro_id]"
	var/resolved_macro_id = resolve_existing_building_template_chunk_id(requested_macro_id)
	if(length(resolved_macro_id))
		cluster_spec.macro_id = resolved_macro_id
	var/datum/world_edit_building_template_chunk/chunk = length(resolved_macro_id) ? get_building_template_chunk(resolved_macro_id) : null
	if(!istype(chunk) || !length(chunk.cells))
		state.add_template_reject_reason("template_chunk_unavailable", list(
			"scope" = "placement_entry",
			"cluster_id" = cluster_spec.id,
			"macro_id" = requested_macro_id,
			"resolved_macro_id" = resolved_macro_id,
			"chunk_found" = istype(chunk) ? TRUE : FALSE,
			"chunk_has_cells" = istype(chunk) ? length(chunk.cells) > 0 : FALSE,
		))
		return 0
	var/list/candidate_data = build_template_chunk_candidate_turfs(state, cluster_spec, chunk)
	var/list/candidates = candidate_data["turfs"]
	var/list/candidate_scores = candidate_data["scores"]
	if(!length(candidates))
		state.add_template_reject_reason("template_no_candidates", list(
			"scope" = "placement_entry",
			"cluster_id" = cluster_spec.id,
			"macro_id" = cluster_spec.macro_id,
			"chunk_id" = chunk.id,
			"chunk_cell_count" = length(chunk.cells),
		))
		return 0
	var/attempts = 0
	while(length(candidates) && attempts < 10)
		attempts++
		var/turf/anchor_turf = select_best_template_candidate(candidates, candidate_scores)
		if(!istype(anchor_turf))
			break
		candidates -= anchor_turf
		var/datum/world_edit_building_place_rule/place_rule = resolve_building_place_rule(cluster_spec.slot, cluster_spec.category)
		var/fallback_dir = get_cardinal_dir_toward(anchor_turf, state.geometry.semantic_hub_turf || state.geometry.center_turf, SOUTH)
		var/list/place_context = build_building_fixture_place_context(state, anchor_turf, place_rule, fallback_dir, get_cluster_effective_needs_wall(state, cluster_spec, place_rule), cluster_spec, cluster_spec.anchors)
		if(!islist(place_context))
			continue
		var/placed = try_place_building_template_chunk_at(state, cluster_spec, chunk, anchor_turf, place_context["dir"] || fallback_dir, place_context["wall_dir"], major)
		if(placed > 0)
			return placed
	state.add_template_reject_reason("template_all_candidates_exhausted", list(
		"scope" = "placement_entry",
		"cluster_id" = cluster_spec.id,
		"macro_id" = cluster_spec.macro_id,
		"chunk_id" = chunk.id,
		"attempts" = attempts,
	))
	return 0
