#ifndef WORLD_EDIT_BUILDING_MAX_QUALITY_SAMPLES_STORED
#define WORLD_EDIT_BUILDING_MAX_QUALITY_SAMPLES_STORED 120
#endif

#ifndef WORLD_EDIT_BUILDING_MAX_QUALITY_FAILURE_SAMPLES
#define WORLD_EDIT_BUILDING_MAX_QUALITY_FAILURE_SAMPLES 80
#endif

#ifndef WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO
#define WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO 64
#endif

/datum/world_edit_generator/building_layout/proc/get_building_quality_shape_ids(list/shape_ids = null)
	if(islist(shape_ids) && length(shape_ids))
		return shape_ids.Copy()
	return get_supported_placement_shapes()

/datum/world_edit_generator/building_layout/proc/build_building_quality_shape_points(width = 8, height = 8, notch = FALSE)
	var/list/points = list()
	width = max(round(text2num("[width]") || 8), 3)
	height = max(round(text2num("[height]") || 8), 3)
	for(var/y in 0 to height - 1)
		for(var/x in 0 to width - 1)
			if(notch && x >= width - 2 && y >= height - 2)
				continue
			points += list(list("x" = x, "y" = y))
	return GLOB.world_edit_placement_shapes.world_edit_format_shape_points(points)

/datum/world_edit_generator/building_layout/proc/build_building_quality_shape_params(shape_id, seed_value = 0, half_width = 4, half_depth = 4)
	var/width = max(round(text2num("[half_width]") || 4) * 2 + 1, 7)
	var/height = max(round(text2num("[half_depth]") || 4) * 2 + 1, 7)
	var/radius = max(min(width, height) / 2, 4)
	var/list/params = list(
		"shape_line_length" = max(width, height),
		"shape_line_spacing" = 1,
		"shape_rect_width" = width,
		"shape_rect_height" = height,
		"shape_radius" = radius,
		"shape_thickness" = 2,
		"shape_radius_x" = max(round(width / 2), 4),
		"shape_radius_y" = max(round(height / 2), 3),
		"shape_triangle_size" = max(width, height),
		"shape_sector_angle" = 100,
		"shape_brush_radius" = 1,
		"shape_scatter_radius" = max(round(max(width, height) / 2), 4),
		"shape_scatter_count" = 8,
		"shape_scatter_seed" = seed_value,
	)
	switch("[shape_id]")
		if(WORLD_EDIT_SHAPE_POLYGON)
			params["shape_points_text"] = "0,0; [width - 1],0; [width - 1],[max(height - 3, 2)]; [round(width / 2)],[height - 1]; 0,[height - 1]"
			params["shape_polygon_filled"] = TRUE
		if(WORLD_EDIT_SHAPE_POLYLINE)
			params["shape_points_text"] = "0,0; [round(width / 2)],0; [round(width / 2)],[height - 1]; [width - 1],[height - 1]"
		if(WORLD_EDIT_SHAPE_CUSTOM_MASK)
			params["shape_points_text"] = build_building_quality_shape_points(width, height, TRUE)
		if(WORLD_EDIT_SHAPE_BRUSH_PATH)
			params["shape_points_text"] = "0,0; [round(width / 2)],0; [round(width / 2)],[height - 1]; [width - 1],[height - 1]"
	return params

/datum/world_edit_generator/building_layout/proc/build_building_quality_shape_context(turf/anchor_turf, shape_id, list/shape_params)
	if(!istype(anchor_turf))
		return null
	var/turf/end_turf = null
	var/datum/world_edit_shape_contract/shape_contract = GLOB.world_edit_shape_geometry.build_shape_contract(shape_id, anchor_turf, end_turf, shape_params, NORTH)
	var/list/anchor_turfs = istype(shape_contract) ? shape_contract.copy_anchor_turfs() : list()
	if(!length(anchor_turfs))
		anchor_turfs += anchor_turf
	var/list/shape_metadata = istype(shape_contract) ? shape_contract.copy_metadata() : list()
	var/list/placement_context = list(
		"mode" = "single",
		"shape" = shape_id,
		"shape_contract" = shape_contract,
		"shape_metadata" = shape_metadata,
		"anchor_turfs" = anchor_turfs,
		"start_turf" = anchor_turf,
		"end_turf" = end_turf,
		"shape_origin_turf" = anchor_turf,
		"seed_turf" = anchor_turf,
		"requested_end_turf" = end_turf,
		"resolved_end_turf" = end_turf,
		"direction" = NORTH,
	)
	return list("shape_contract" = shape_contract, "placement_context" = placement_context)

/datum/world_edit_generator/building_layout/proc/get_building_metadata_counter(list/metadata, counter_name)
	if(!islist(metadata) || !length("[counter_name]"))
		return 0
	return round(text2num("[metadata["[counter_name]"]]") || 0)

/datum/world_edit_generator/building_layout/proc/build_building_metadata_hard_counter_report(list/metadata)
	var/list/report = list()
	for(var/counter_name as anything in get_building_hard_counter_names())
		report["[counter_name]"] = get_building_metadata_counter(metadata, counter_name)
	return report

/datum/world_edit_generator/building_layout/proc/add_building_quality_hard_counter_totals(list/target, list/hard_counters)
	if(!islist(target) || !islist(hard_counters))
		return
	for(var/counter_name as anything in hard_counters)
		target["[counter_name]"] = round(text2num("[target["[counter_name]"]]") || 0) + round(text2num("[hard_counters[counter_name]]") || 0)

/datum/world_edit_generator/building_layout/proc/update_building_quality_support_matrix(list/support_matrix, list/sample)
	if(!islist(support_matrix) || !islist(sample))
		return
	var/matrix_key = "[sample["program"]]|[sample["shape"]]|[sample["style"]]|[sample["scenario"]]"
	var/list/row = support_matrix[matrix_key]
	if(!islist(row))
		row = list(
			"program" = sample["program"],
			"shape" = sample["shape"],
			"style" = sample["style"],
			"scenario" = sample["scenario"],
			"sample_count" = 0,
			"pass_count" = 0,
			"fail_count" = 0,
			"status_counts" = list(),
			"hard_counter_totals" = list(),
			"failure_reasons" = list(),
		)
		support_matrix[matrix_key] = row
	row["sample_count"] = row["sample_count"] + 1
	if(sample["passed"])
		row["pass_count"] = row["pass_count"] + 1
	else
		row["fail_count"] = row["fail_count"] + 1
	var/list/status_counts = row["status_counts"]
	var/status = "[sample["support_status"] || "FAILED"]"
	status_counts[status] = round(text2num("[status_counts[status]]") || 0) + 1
	add_building_quality_hard_counter_totals(row["hard_counter_totals"], sample["hard_counters"])
	if(!sample["passed"])
		var/list/failure_reasons = row["failure_reasons"]
		if(length(failure_reasons) < WORLD_EDIT_BUILDING_MAX_QUALITY_FAILURE_SAMPLES)
			var/reason = "[sample["error"] || sample["user_facing_failure_reason"] || "quality sample failed"]"
			failure_reasons += reason

/datum/world_edit_generator/building_layout/proc/run_building_quality_batch(turf/anchor_turf, list/program_ids = null, list/style_ids = null, seed_start = 1, seed_count = 8, half_width = 4, half_depth = 4, list/shape_ids = null, max_sample_count = 240)
	var/list/result = list(
		"sample_count" = 0,
		"pass_count" = 0,
		"fail_count" = 0,
		"samples" = list(),
		"failure_samples" = list(),
		"support_matrix" = list(),
		"hard_counter_totals" = list(),
	)
	if(!istype(anchor_turf))
		result["error"] = "Quality batch requires an anchor turf."
		return result
	if(!islist(program_ids) || !length(program_ids))
		program_ids = get_building_archetype_ids()
	if(!islist(style_ids) || !length(style_ids))
		style_ids = get_building_faction_options()
	shape_ids = get_building_quality_shape_ids(shape_ids)
	result["shape_ids"] = shape_ids.Copy()
	seed_count = clamp(round(text2num("[seed_count]") || 8), 1, 50)
	max_sample_count = clamp(round(text2num("[max_sample_count]") || 240), 1, 2000)
	var/list/scenarios = list(
		list("id" = "details_0", "auto_size" = FALSE, "detail_budget" = 0, "respect_blockers" = FALSE, "replace_blocked_turfs" = TRUE),
		list("id" = "details_100", "auto_size" = FALSE, "detail_budget" = 100, "respect_blockers" = FALSE, "replace_blocked_turfs" = TRUE),
		list("id" = "blockers_strict", "auto_size" = FALSE, "detail_budget" = 100, "respect_blockers" = TRUE, "replace_blocked_turfs" = FALSE),
		list("id" = "auto_default", "auto_size" = TRUE, "detail_budget" = 60, "respect_blockers" = FALSE, "replace_blocked_turfs" = TRUE),
	)
	for(var/seed_offset in 0 to seed_count - 1)
		var/seed_value = seed_start + seed_offset
		for(var/shape_id as anything in shape_ids)
			var/list/shape_params = build_building_quality_shape_params(shape_id, seed_value, half_width, half_depth)
			var/list/shape_context = build_building_quality_shape_context(anchor_turf, shape_id, shape_params)
			var/datum/world_edit_shape_contract/shape_contract = islist(shape_context) ? shape_context["shape_contract"] : null
			var/list/placement_context = islist(shape_context) ? shape_context["placement_context"] : null
			for(var/program_id as anything in program_ids)
				for(var/style_id as anything in style_ids)
					for(var/list/scenario as anything in scenarios)
						if((round(text2num("[result["sample_count"]]") || 0)) >= max_sample_count)
							result["capped"] = TRUE
							return result
						var/list/params = list(
							"archetype_id" = program_id,
							"faction_preset" = style_id,
							"building_seed" = seed_value,
							"auto_size" = scenario["auto_size"] ? TRUE : FALSE,
							"half_width" = half_width,
							"half_depth" = half_depth,
							"detail_budget" = scenario["detail_budget"],
							"window_density" = 60,
							"back_exit" = TRUE,
							"respect_blockers" = scenario["respect_blockers"],
							"replace_blocked_turfs" = scenario["replace_blocked_turfs"],
						)
						for(var/shape_param as anything in shape_params)
							params[shape_param] = shape_params[shape_param]
						var/datum/world_edit_plan/plan = build_plan_from_shape_contract(null, shape_contract, params, placement_context)
						var/list/sample = build_building_quality_sample(program_id, style_id, seed_value, shape_id, plan, scenario["id"])
						result["sample_count"] = result["sample_count"] + 1
						if(length(result["samples"]) < WORLD_EDIT_BUILDING_MAX_QUALITY_SAMPLES_STORED)
							result["samples"] += list(sample)
						if(sample["passed"])
							result["pass_count"] = result["pass_count"] + 1
						else
							result["fail_count"] = result["fail_count"] + 1
							if(length(result["failure_samples"]) < WORLD_EDIT_BUILDING_MAX_QUALITY_FAILURE_SAMPLES)
								result["failure_samples"] += list(sample)
						add_building_quality_hard_counter_totals(result["hard_counter_totals"], sample["hard_counters"])
						update_building_quality_support_matrix(result["support_matrix"], sample)
	return result

/datum/world_edit_generator/building_layout/proc/build_building_quality_sample(program_id, style_id, seed_value, shape_id, datum/world_edit_plan/plan, scenario_id = "default")
	var/list/metadata = islist(plan?.metadata) ? plan.metadata : list()
	var/support_status = "[metadata["current_request_support_status"] || "FAILED"]"
	var/passed = istype(plan) && !metadata["error"] && support_status == "SUPPORTED_AND_VALIDATED"
	if(!GLOB.world_edit_helpers.parse_bool(metadata["program_signature_ok"]))
		passed = FALSE
	var/empty_floor_ratio = round(text2num("[metadata["empty_floor_ratio"]]") || 0)
	var/template_chunk_count = round(text2num("[metadata["template_chunk_count"]]") || 0)
	var/infrastructure_count = round(text2num("[metadata["infrastructure_count"]]") || 0)
	var/semantic_slot_shortage_count = round(text2num("[metadata["semantic_slot_shortage_count"]]") || 0)
	var/semantic_slot_reservation_conflict_count = round(text2num("[metadata["semantic_slot_reservation_conflict_count"]]") || 0)
	var/mandatory_pattern_failure_count = round(text2num("[metadata["mandatory_pattern_failure_count"]]") || 0)
	var/reserved_walk_blocked_count = round(text2num("[metadata["reserved_walk_blocked_count"]]") || 0)
	var/semantic_credit_without_emitted_slots_count = round(text2num("[metadata["semantic_credit_without_emitted_slots_count"]]") || 0)
	var/forbidden_fallback_count = round(text2num("[metadata["forbidden_fallback_count"]]") || 0)
	var/post_emit_validation_error_count = round(text2num("[metadata["post_emit_validation_error_count"]]") || 0)
	var/raw_category_credit_count = round(text2num("[metadata["raw_category_credit_count"]]") || 0)
	var/scatter_signature_credit_count = round(text2num("[metadata["scatter_signature_credit_count"]]") || 0)
	var/list/hard_counters = build_building_metadata_hard_counter_report(metadata)
	var/list/template_reject_reason_counts = islist(metadata["template_reject_reason_counts"]) ? metadata["template_reject_reason_counts"] : list()
	var/degrade_level = "[metadata["size_degrade_level"] || "none"]"
	if(empty_floor_ratio > WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO)
		passed = FALSE
	if(template_chunk_count <= 0 && !GLOB.world_edit_helpers.parse_bool(metadata["micro_layout"]))
		passed = FALSE
	if(infrastructure_count < 1)
		passed = FALSE
	if(semantic_slot_reservation_conflict_count > 0)
		passed = FALSE
	if(mandatory_pattern_failure_count > 0 || reserved_walk_blocked_count > 0)
		passed = FALSE
	if(forbidden_fallback_count > 0 || post_emit_validation_error_count > 0 || raw_category_credit_count > 0 || scatter_signature_credit_count > 0)
		passed = FALSE
	if(degrade_level == "none" && semantic_slot_shortage_count > 0)
		passed = FALSE
	return list(
		"program" = "[program_id]",
		"style" = "[style_id]",
		"shape" = "[shape_id]",
		"scenario" = "[scenario_id]",
		"seed" = seed_value,
		"passed" = passed ? TRUE : FALSE,
		"support_status" = support_status,
		"user_facing_failure_reason" = metadata["user_facing_failure_reason"],
		"error" = metadata["error"],
		"layout_hash" = metadata["layout_hash"],
		"structural_topology_signature" = metadata["structural_topology_signature"],
		"geometry_layout_hash" = metadata["geometry_layout_hash"],
		"pattern_credit_hash" = metadata["pattern_credit_hash"],
		"footprint_source" = metadata["footprint_source"],
		"placement_shape_used_as_seed_only" = metadata["placement_shape_used_as_seed_only"],
		"signature_score" = metadata["signature_score"],
		"empty_floor_ratio" = empty_floor_ratio,
		"template_chunk_count" = template_chunk_count,
		"infrastructure_count" = infrastructure_count,
		"fixture_count" = metadata["fixture_count"],
		"semantic_requirement_minimums" = metadata["semantic_requirement_minimums"],
		"semantic_requirement_counts" = metadata["semantic_requirement_counts"],
		"template_reject_reason_counts" = template_reject_reason_counts,
		"template_reject_report_count" = metadata["template_reject_report_count"],
		"template_cluster_report_count" = metadata["template_cluster_report_count"],
		"semantic_slot_shortage_count" = semantic_slot_shortage_count,
		"semantic_slot_reservation_conflict_count" = semantic_slot_reservation_conflict_count,
		"mandatory_pattern_failure_count" = mandatory_pattern_failure_count,
		"reserved_walk_blocked_count" = reserved_walk_blocked_count,
		"semantic_credit_without_emitted_slots_count" = semantic_credit_without_emitted_slots_count,
		"forbidden_fallback_count" = forbidden_fallback_count,
		"post_emit_validation_error_count" = post_emit_validation_error_count,
		"raw_category_credit_count" = raw_category_credit_count,
		"scatter_signature_credit_count" = scatter_signature_credit_count,
		"hard_counters" = hard_counters,
		"partition_segment_count" = metadata["partition_segment_count"],
		"nested_room_count" = metadata["nested_room_count"],
		"degraded_region_fallback_count" = metadata["degraded_region_fallback_count"],
	)
