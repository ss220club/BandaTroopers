/*
 * Report construction for all terminal case states.
 *
 * Reports are the primary machine-readable contract of the workbench. A locked
 * shape, generator validation failure, missing post-emit validation report, and
 * successful apply all flow through the same schema so CI/review tools can
 * compare cases without scraping logs.
 */
/datum/world_edit_visual_case/proc/add_error(code, message, stage, turf/T = null, list/details = null)
	var/list/error = list(
		"code" = "[code]",
		"message" = "[message]",
		"severity" = "error",
		"stage" = "[stage]",
	)
	if(istype(T))
		error["x"] = T.x
		error["y"] = T.y
		error["z"] = T.z
	if(islist(details))
		error["details"] = details
	errors += list(error)
	return error

/datum/world_edit_visual_case/proc/add_warning(message)
	warnings += "[message]"

/datum/world_edit_visual_case/proc/base_report(status, stage)
	var/list/out = list(
		"schema" = "world_edit_visual_report/v1",
		"case_id" = id,
		"generator" = generator_id,
		"status" = status,
		"stage" = stage,
		"seed" = seed,
		"program" = generator_config?["archetype_id"] || generator_config?["program"],
		"shape" = shape_config?["id"],
		"style" = generator_config?["faction_preset"],
		"errors" = errors.Copy(),
		"warnings" = warnings.Copy(),
		"metrics" = list(),
		"artifacts" = list(),
	)
	var/list/profile = profiler?.to_json_list()
	if(islist(profile))
		out["profile"] = profile
	if(length(workflow_run_id))
		out["workflow_run_id"] = workflow_run_id
	if(length(source_sha))
		out["source_sha"] = source_sha
	return out

/datum/world_edit_visual_case/proc/write_json_file(path, list/value)
	fdel(path)
	rustg_file_write(json_encode(value), path)
	return fexists(path)

/datum/world_edit_visual_case/proc/write_report(list/report_data)
	report_data["errors"] = errors.Copy()
	report_data["warnings"] = warnings.Copy()
	apply_expectations_to_report(report_data)
	if(!islist(report_data["artifacts"]))
		report_data["artifacts"] = list()
	report_data["artifacts"]["report_json"] = "report.json"
	report_data["artifacts"]["progress_json"] = "progress.json"
	write_json_file("[out_dir]/report.json", report_data)

/datum/world_edit_visual_case/proc/apply_expectations_to_report(list/report_data)
	if(!islist(report_data))
		return
	var/hard_error_count = compute_hard_error_count(report_data)
	report_data["hard_error_count"] = hard_error_count

	var/list/expected = islist(expect_config) ? expect_config.Copy() : list()
	var/list/actual = list()
	var/list/diff = list()
	for(var/key as anything in expected)
		var/actual_value = get_expectation_actual_value(key, report_data)
		actual[key] = actual_value
		if(!visual_expectation_satisfied(key, expected[key], actual_value))
			diff += list(list(
				"key" = "[key]",
				"expected" = expected[key],
				"actual" = actual_value,
			))

	report_data["expectations"] = list(
		"expected" = expected,
		"actual" = actual,
		"diff" = diff,
	)
	report_data["expectation_diff"] = diff
	report_data["passed"] = (!length(diff) && hard_error_count <= 0) ? TRUE : FALSE

/datum/world_edit_visual_case/proc/compute_hard_error_count(list/report_data)
	var/list/report_errors = islist(report_data?["errors"]) ? report_data["errors"] : list()
	var/status = "[report_data?["status"] || ""]"
	var/expected_status = "[expect_config?["status"] || ""]"
	if(status == WORLD_EDIT_VISUAL_STATUS_LOCKED && expected_status == WORLD_EDIT_VISUAL_STATUS_LOCKED)
		return 0
	return length(report_errors)

/datum/world_edit_visual_case/proc/get_expectation_actual_value(key, list/report_data)
	switch("[key]")
		if("status")
			return report_data?["status"]
		if("reason_code")
			return report_data?["reason_code"] || report_data?["error"] || get_first_report_error_code(report_data)
		if("canvas_changed")
			return report_data?["canvas_changed"] ? TRUE : FALSE
		if("direction_honored")
			var/list/direction = report_data?["direction"]
			return direction?["honored"] ? TRUE : FALSE
		if("generation")
			var/list/generation_verdict = report_data?["validation_verdict"]
			return generation_verdict?["status"]
		if("generation_stage")
			var/list/generation_stage_verdict = report_data?["validation_verdict"]
			return generation_stage_verdict?["stage"]
		if("preflight")
			var/list/preflight_verdict = report_data?["support_validation_verdict"]
			return preflight_verdict?["status"]
		if("feasibility_dry_solve")
			var/list/support_report = report_data?["support"]
			return support_report?["feasibility_dry_solve_status"]
		if("same_seed_layout_hash")
			var/list/determinism = report_data?["determinism_replay"]
			return determinism?["same_seed_layout_hash"] ? TRUE : FALSE
		if("mandatory_room_unreachable_count")
			var/list/metrics_for_room_access = report_data?["metrics"]
			return metrics_for_room_access?["mandatory_room_no_access_count"] || 0
		if("post_apply_error_count")
			var/list/apply_error_verdict = report_data?["apply_validation_verdict"]
			var/list/apply_error_metrics = apply_error_verdict?["metrics"]
			return apply_error_metrics?["post_apply_validation_error_count"] || 0
		if("apply")
			var/list/apply_verdict = report_data?["apply_validation_verdict"]
			return apply_verdict?["status"]
		if("apply_stage")
			var/list/apply_stage_verdict = report_data?["apply_validation_verdict"]
			return apply_stage_verdict?["stage"]
		if("undo_validation")
			var/list/undo_verdict = report_data?["undo_validation_verdict"]
			return undo_verdict?["status"]
		if("undo")
			var/list/undo = report_data?["undo"]
			return undo?["status"]
		if("undo_restored")
			var/list/undo = report_data?["undo"]
			return undo?["restored"] ? TRUE : FALSE
		if("hard_error_count")
			return report_data?["hard_error_count"] || 0
		if("layout_min_candidate_count")
			var/list/layout_metrics = report_data?["metrics"]
			return layout_metrics?["layout_hard_valid_candidate_count"] || layout_metrics?["layout_candidate_count"] || 0
		if("semantic_distribution_noise_score_max")
			var/list/semantic_noise_metrics = report_data?["metrics"]
			return semantic_noise_metrics?["semantic_distribution_noise_score"] || 0
		if("semantic_functional_coverage_percent_min")
			var/list/semantic_coverage_metrics = report_data?["metrics"]
			return semantic_coverage_metrics?["semantic_functional_coverage_percent"] || 0
		if("semantic_route_clearance_percent_min")
			var/list/semantic_clearance_metrics = report_data?["metrics"]
			return semantic_clearance_metrics?["semantic_route_clearance_percent"] || 0
	var/list/metrics = report_data?["metrics"]
	var/key_text = "[key]"
	if(length(key_text) > 4 && copytext(key_text, length(key_text) - 3) in list("_min", "_max"))
		var/base_key = copytext(key_text, 1, length(key_text) - 3)
		if(islist(metrics) && !isnull(metrics[base_key]))
			return metrics[base_key]
		if(!isnull(report_data?[base_key]))
			return report_data[base_key]
	if(islist(metrics) && !isnull(metrics[key]))
		return metrics[key]
	return report_data?[key]

/datum/world_edit_visual_case/proc/get_first_report_error_code(list/report_data)
	var/list/report_errors = islist(report_data?["errors"]) ? report_data["errors"] : null
	if(!islist(report_errors) || !length(report_errors))
		return null
	var/list/first_error = report_errors[1]
	if(islist(first_error))
		return first_error["code"]
	return null

/datum/world_edit_visual_case/proc/visual_expectation_values_equal(expected, actual)
	if(isnull(expected) || isnull(actual))
		return isnull(expected) && isnull(actual)
	if(isnum(expected) || isnum(actual))
		return round(text2num("[expected]") * 1000) == round(text2num("[actual]") * 1000)
	return "[expected]" == "[actual]"

/datum/world_edit_visual_case/proc/visual_expectation_satisfied(key, expected, actual)
	if("[key]" == "layout_min_candidate_count")
		return round(text2num("[actual]") || 0) >= round(text2num("[expected]") || 0)
	var/key_text = "[key]"
	if(length(key_text) > 4 && copytext(key_text, length(key_text) - 3) == "_min")
		return round(text2num("[actual]") || 0) >= round(text2num("[expected]") || 0)
	if(length(key_text) > 4 && copytext(key_text, length(key_text) - 3) == "_max")
		return round(text2num("[actual]") || 0) <= round(text2num("[expected]") || 0)
	return visual_expectation_values_equal(expected, actual)

/datum/world_edit_visual_case/proc/mark_semantic_artifacts(list/report_data)
	if(!istype(canvas))
		return
	if(!islist(report_data["artifacts"]))
		report_data["artifacts"] = list()
	report_data["artifacts"]["semantic_json"] = "semantic.json"
	report_data["artifacts"]["semantic_png"] = "semantic.png"

/datum/world_edit_visual_case/proc/attach_support_verdict(list/report_data, list/source, as_top_level = TRUE)
	if(!islist(report_data) || !islist(source))
		return
	var/list/support = null
	if(islist(source["support_status_report"]))
		support = source["support_status_report"]
	else
		var/list/meta = source["metadata"]
		if(islist(meta) && islist(meta["support_status_report"]))
			support = meta["support_status_report"]
	if(!islist(support))
		return
	report_data["support"] = support.Copy()
	var/list/verdict = support["verdict"]
	if(islist(verdict))
		report_data["support_validation_verdict"] = verdict.Copy()
		if(as_top_level)
			report_data["validation_verdict"] = verdict.Copy()

/datum/world_edit_visual_case/proc/attach_generation_validation_verdict(list/report_data, list/source)
	if(!islist(report_data) || !islist(source))
		return
	var/list/verdict = null
	if(islist(source["generation_validation_verdict"]))
		verdict = source["generation_validation_verdict"]
	else if(islist(source["validation_verdict"]))
		verdict = source["validation_verdict"]
	else
		var/list/meta = source["metadata"]
		if(islist(meta))
			if(islist(meta["generation_validation_verdict"]))
				verdict = meta["generation_validation_verdict"]
			else if(islist(meta["validation_verdict"]))
				verdict = meta["validation_verdict"]
	if(islist(verdict))
		report_data["validation_verdict"] = verdict.Copy()

/datum/world_edit_visual_case/proc/attach_apply_validation_verdict(list/report_data, list/source, as_top_level = FALSE)
	if(!islist(report_data) || !islist(source))
		return
	var/list/verdict = null
	if(islist(source["apply_validation_verdict"]))
		verdict = source["apply_validation_verdict"]
	else
		var/list/meta = source["metadata"]
		if(islist(meta) && islist(meta["apply_validation_verdict"]))
			verdict = meta["apply_validation_verdict"]
	if(islist(verdict))
		report_data["apply_validation_verdict"] = verdict.Copy()
		if(as_top_level)
			report_data["validation_verdict"] = verdict.Copy()

/datum/world_edit_visual_case/proc/attach_undo_validation_verdict(list/report_data, list/source, as_top_level = FALSE)
	if(!islist(report_data) || !islist(source))
		return
	var/list/verdict = source["undo_validation_verdict"]
	if(islist(verdict))
		report_data["undo_validation_verdict"] = verdict.Copy()
		if(as_top_level)
			report_data["validation_verdict"] = verdict.Copy()

/datum/world_edit_visual_case/proc/finish_locked(list/support)
	profiler.end_total()
	// Locked is a successful workbench outcome, not a crash. It means the real
	// generator refused the request before preview/apply, so canvas_changed must
	// remain false and the reason must stay visible in both report and PNG.
	add_error(support["reason_code"] || support["lock_code"] || "shape.locked", support["reason"] || "Shape is locked for this generator.", WORLD_EDIT_VISUAL_STAGE_SUPPORT_CHECK)
	var/list/out = base_report(WORLD_EDIT_VISUAL_STATUS_LOCKED, WORLD_EDIT_VISUAL_STAGE_SUPPORT_CHECK)
	out["locked"] = TRUE
	out["reason_code"] = support["reason_code"] || support["lock_code"]
	out["reason"] = support["reason"]
	out["canvas_changed"] = FALSE
	out["support"] = support.Copy()
	var/list/support_source = list("metadata" = support)
	out["metrics"] = merge_metrics(support_source, null, null)
	out["metrics"]["generated_turf_count"] = 0
	out["metrics"]["generated_object_count"] = 0
	out["metrics"]["post_emit_validation_error_count"] = 0
	attach_building_diagnostics(out, support_source)
	attach_support_verdict(out, list("support_status_report" = support))
	mark_semantic_artifacts(out)
	export_semantic_json(out)
	write_report(out)
	return out

/datum/world_edit_visual_case/proc/finish_error(stage, error, list/details = null)
	profiler.end_total()
	// Generator failures are preserved as errors with their original stage. The
	// visualizer must not reinterpret them into supported output.
	add_error(error, error, stage, null, details)
	var/list/out = base_report(WORLD_EDIT_VISUAL_STATUS_ERROR, stage)
	out["error"] = error
	if(islist(details))
		out["details"] = details
		out["metrics"] = merge_metrics(details, null, null)
		attach_building_diagnostics(out, details)
		attach_support_verdict(out, details, FALSE)
		if(stage == WORLD_EDIT_VISUAL_STAGE_APPLY)
			attach_apply_validation_verdict(out, details, TRUE)
		if(!islist(out["validation_verdict"]))
			attach_generation_validation_verdict(out, details)
		if(!islist(out["validation_verdict"]))
			attach_support_verdict(out, details)
	out["canvas_changed"] = canvas?.has_changed() ? TRUE : FALSE
	mark_semantic_artifacts(out)
	export_semantic_json(out)
	write_report(out)
	return out

/datum/world_edit_visual_case/proc/finish_supported(list/preview, list/apply, list/post_emit, list/export_result, list/undo_result = null, list/determinism_result = null)
	profiler.end_total()
	var/list/out = base_report(WORLD_EDIT_VISUAL_STATUS_SUPPORTED, WORLD_EDIT_VISUAL_STAGE_POST_EMIT_VALIDATE)
	out["canvas_changed"] = canvas?.has_changed() ? TRUE : FALSE
	out["metrics"] = merge_metrics(preview, apply, post_emit)
	apply_undo_metrics(out["metrics"], undo_result)
	out["direction"] = build_direction_report(preview)
	out["undo"] = islist(undo_result) ? undo_result.Copy() : list("status" = "not_run", "restored" = FALSE)
	if(islist(determinism_result))
		out["determinism_replay"] = determinism_result.Copy()
		out["same_seed_layout_hash"] = determinism_result["same_seed_layout_hash"] ? TRUE : FALSE
	out["rooms"] = preview?["rooms"] || list()
	out["routes"] = preview?["routes"] || list()
	attach_building_diagnostics(out, preview)
	attach_support_verdict(out, preview, FALSE)
	attach_generation_validation_verdict(out, preview)
	attach_apply_validation_verdict(out, apply)
	attach_undo_validation_verdict(out, undo_result)
	if(islist(post_emit))
		if(islist(post_emit["route_blocking_samples"]))
			out["route_blocking_samples"] = post_emit["route_blocking_samples"].Copy()
		if(islist(post_emit["door_cone_blocking_samples"]))
			out["door_cone_blocking_samples"] = post_emit["door_cone_blocking_samples"].Copy()
	out["artifacts"] = islist(export_result?["artifacts"]) ? export_result["artifacts"] : list()
	mark_semantic_artifacts(out)
	write_report(out)
	return out

/datum/world_edit_visual_case/proc/apply_undo_metrics(list/metrics, list/undo_result)
	if(!islist(metrics) || !islist(undo_result))
		return
	metrics["undo_reverted_count"] = undo_result["reverted_count"] || 0
	metrics["undo_skipped_count"] = undo_result["skipped_count"] || 0
	metrics["undo_restored"] = undo_result["restored"] ? TRUE : FALSE

/datum/world_edit_visual_case/proc/visual_metadata_has_building_metrics(list/meta)
	if(!islist(meta))
		return FALSE
	return !isnull(meta["template_chunk_count"]) || !isnull(meta["footprint_count"]) || islist(meta["template_reject_reason_counts"])

/datum/world_edit_visual_case/proc/select_visual_best_layout_candidate_report(list/candidate_reports)
	if(!islist(candidate_reports) || !length(candidate_reports))
		return null
	var/list/best_report = null
	var/best_score = -999999999
	for(var/list/report as anything in candidate_reports)
		if(!islist(report))
			continue
		var/score = round(text2num("[report["score"]]") || -999999999)
		if(!islist(best_report) || score > best_score)
			best_report = report
			best_score = score
	return best_report

/datum/world_edit_visual_case/proc/get_visual_building_metric_source(list/source)
	var/list/meta = source?["metadata"]
	if(!islist(meta))
		return null
	if(visual_metadata_has_building_metrics(meta))
		return meta
	var/list/selected_report = meta["selected_candidate_report"]
	if(islist(selected_report))
		return selected_report
	var/list/failed_diagnostics = meta["failed_candidate_diagnostics"]
	if(islist(failed_diagnostics))
		return failed_diagnostics
	var/list/dry_solve_selected = meta["feasibility_dry_solve_selected_candidate"]
	if(islist(dry_solve_selected))
		return dry_solve_selected
	var/list/dry_solve_failed = meta["feasibility_dry_solve_failed_candidate"]
	if(islist(dry_solve_failed))
		return dry_solve_failed
	return select_visual_best_layout_candidate_report(meta["layout_candidate_reports"])

/datum/world_edit_visual_case/proc/attach_building_diagnostics(list/report_data, list/source)
	if(!islist(report_data))
		return
	var/list/meta = get_visual_building_metric_source(source)
	if(!islist(meta))
		return
	var/list/diagnostics = list(
		"template_chunk_count" = meta["template_chunk_count"] || 0,
		"template_chunk_cell_count" = meta["template_chunk_cell_count"] || 0,
		"template_reject_reason_counts" = islist(meta["template_reject_reason_counts"]) ? meta["template_reject_reason_counts"] : list(),
		"template_reject_reports" = islist(meta["template_reject_reports"]) ? meta["template_reject_reports"] : list(),
		"template_reject_report_count" = meta["template_reject_report_count"] || 0,
		"template_cluster_reports" = islist(meta["template_cluster_reports"]) ? meta["template_cluster_reports"] : list(),
		"template_cluster_report_count" = meta["template_cluster_report_count"] || 0,
		"stage_reports" = islist(meta["stage_reports"]) ? meta["stage_reports"] : list(),
		"stage_report_count" = meta["stage_report_count"] || 0,
		"route_blocking_samples" = islist(meta["route_blocking_samples"]) ? meta["route_blocking_samples"] : list(),
		"door_cone_blocking_samples" = islist(meta["door_cone_blocking_samples"]) ? meta["door_cone_blocking_samples"] : list(),
		"placed_requirement_counts" = islist(meta["placed_requirement_counts"]) ? meta["placed_requirement_counts"] : list(),
		"semantic_requirement_counts" = islist(meta["semantic_requirement_counts"]) ? meta["semantic_requirement_counts"] : list(),
		"semantic_requirement_minimums" = islist(meta["semantic_requirement_minimums"]) ? meta["semantic_requirement_minimums"] : list(),
	)
	report_data["building_diagnostics"] = diagnostics
	report_data["template_reject_reports"] = diagnostics["template_reject_reports"]
	report_data["template_cluster_reports"] = diagnostics["template_cluster_reports"]
	report_data["placed_requirement_counts"] = diagnostics["placed_requirement_counts"]
	report_data["semantic_requirement_counts"] = diagnostics["semantic_requirement_counts"]

/datum/world_edit_visual_case/proc/merge_metrics(list/preview, list/apply, list/post_emit)
	var/list/metrics = list()
	var/list/meta = get_visual_building_metric_source(preview)
	if(islist(meta))
		var/list/keys = list(
			"footprint_count",
			"wall_count",
			"floor_count",
			"door_count",
			"interior_object_count",
			"room_count",
			"target_room_count",
			"room_count_divider_count",
			"room_count_satisfied",
			"room_count_gap",
			"layout_enabled",
			"layout_pattern_id",
			"layout_candidate_id",
			"layout_candidate_count",
			"layout_hard_valid_candidate_count",
			"layout_scene_count",
			"mandatory_room_missing_count",
			"mandatory_room_no_bounds_count",
			"mandatory_room_no_access_count",
			"mandatory_fixture_access_unreachable_count",
			"reachability_failure_count",
			"reserved_walk_blocked_count",
			"door_cone_blocked_count",
			"door_corner_count",
			"semantic_credit_without_emitted_slots_count",
			"mandatory_pattern_failure_count",
			"post_emit_validation_error_count",
			"counter_wrong_facing_count",
			"direction_fallback_count",
			"forbidden_fallback_count",
			"raw_category_credit_count",
			"scatter_signature_credit_count",
			"provider_path_not_in_build_count",
			"unknown_provider_count",
			"unique_provider_path_count",
			"unique_functional_provider_path_count",
			"unique_decorative_provider_path_count",
			"required_module_missing_count",
			"required_module_not_placeable_count",
			"required_room_without_required_module_count",
			"loose_table_count",
			"loose_chair_count",
			"unpaired_chair_count",
			"table_chair_mosaic_count",
			"furniture_group_fragmented_count",
			"bed_without_access_count",
			"bed_outside_sleeping_count",
			"toilet_outside_sanitation_count",
			"medical_bed_outside_medical_count",
			"hydro_tray_outside_hydroponics_count",
			"weapon_rack_outside_armory_security_count",
			"module_max_per_room_violation_count",
			"module_max_per_building_violation_count",
			"repeat_group_violation_count",
			"room_overfilled_count",
			"route_blocked_by_furniture_count",
			"door_clearance_blocked_count",
			"scene_required_missing_count",
			"room_primary_scene_missing_count",
			"room_identity_missing_count",
			"room_scene_duplicate_count",
			"scene_slot_overflow_count",
			"common_scene_fragmentation_count",
			"excessive_small_social_groups_count",
			"private_room_without_bed_scene_count",
			"sanitation_without_sanitation_scene_count",
			"storage_without_storage_scene_count",
			"scene_blocks_route_count",
			"large_empty_unassigned_floor_count",
			"oversized_role_room_count",
			"unclaimed_interior_wall_count",
			"wall_outside_footprint_count",
			"wall_orphan_island_count",
			"wall_unmapped_interior_count",
			"wall_single_sided_internal_count",
			"thin_room_strip_count",
			"large_sparse_room_count",
			"corridor_ribbon_count",
			"layout_underfurnished_room_count",
			"layout_room_composition_missing_count",
			"layout_room_capacity_shortfall_count",
			"layout_required_adjacency_missing_count",
			"layout_required_adjacency_geometry_missing_count",
			"layout_unassigned_interior_turf_count",
			"layout_unassigned_interior_ratio_percent",
			"layout_unassigned_interior_excess_count",
			"layout_ownerless_open_bay_count",
			"layout_route_component_count",
			"layout_route_component_error_count",
			"layout_wall_stub_count",
			"layout_wall_notch_count",
			"layout_wall_stair_step_count",
			"layout_wall_misaligned_join_count",
			"layout_atomic_module_fragmentation_count",
			"layout_required_module_fallback_count",
			"layout_required_template_reject_count",
			"layout_optional_template_attempt_count",
			"layout_optional_template_reject_count",
			"layout_template_reject_ratio_percent",
			"layout_wall_cleanup_removed_count",
			"layout_wall_cleanup_unmapped_count",
			"layout_wall_cleanup_spur_count",
			"layout_wall_cleanup_ratio_percent",
			"layout_functional_room_count",
			"layout_target_functional_room_count",
			"layout_functional_room_count_gap",
			"layout_circulation_region_count",
			"layout_candidate_metric_mismatch_count",
			"layout_distinct_hard_valid_family_count",
			"layout_selected_topology_family",
			"layout_best_hard_valid_candidate_score",
			"layout_family_winner_count",
			"layout_family_winner_scores",
			"layout_seed_quality_margin",
			"layout_seed_quality_floor",
			"layout_seed_eligible_family_count",
			"layout_seed_selection_index",
			"layout_seed_selection_key",
			"layout_selected_candidate_score_gap",
			"layout_required_connection_missing_count",
			"layout_door_not_shared_wall_count",
			"layout_room_without_door_count",
			"layout_forbidden_room_window_count",
			"layout_empty_large_room_count",
			"layout_isolated_room_count",
			"layout_door_corner_count",
			"layout_door_not_on_shared_wall_count",
			"layout_door_no_shared_wall_count",
			"layout_door_short_segment_count",
			"layout_door_near_other_door_count",
			"layout_door_invalid_clearance_count",
			"layout_room_allocation_failed_count",
			"layout_room_bad_aspect_count",
			"layout_room_thin_strip_count",
			"layout_room_scene_capacity_failed_count",
			"layout_scene_required_missing_count",
			"layout_primary_anchor_missing_count",
			"layout_negative_space_missing_count",
			"layout_scene_blocks_negative_space_count",
			"layout_secondary_anchor_conflict_count",
			"layout_scene_overfill_count",
			"layout_scene_underfill_count",
			"layout_scene_budget_overflow_count",
			"layout_scene_budget_missing_required_count",
			"layout_duplicate_focal_scene_count",
			"layout_window_policy_violation_count",
			"layout_public_room_hard_closed_count",
			"layout_public_opening_missing_count",
			"layout_opposing_route_door_pair_count",
			"layout_corridor_wall_canyon_count",
			"layout_route_wall_canyon_length",
			"layout_excessive_wall_to_floor_ratio_count",
			"layout_template_geometry_reject_count",
			"layout_missing_wall_context_reject_count",
			"layout_hard_valid_candidate_shortage_count",
			"semantic_scene_route_block_count",
			"semantic_scene_door_clearance_block_count",
			"semantic_scene_required_missing_count",
			"semantic_room_primary_scene_missing_count",
			"semantic_major_object_without_scene_count",
			"semantic_pairing_error_count",
			"legacy_fixture_after_scene_count",
			"semantic_distribution_noise_score",
			"semantic_functional_coverage_percent",
			"semantic_route_clearance_percent",
			"structured_scene_owner",
			"structured_scene_count",
			"structured_primary_scene_count",
			"semantic_interiors_scene_count",
			"semantic_interiors_primary_scene_count",
			"module_instance_count",
		)
		for(var/key as anything in keys)
			metrics[key] = meta[key] || 0
		metrics["template_chunk_count"] = meta["template_chunk_count"] || 0
		metrics["template_chunk_cell_count"] = meta["template_chunk_cell_count"] || 0
		metrics["template_reject_reason_counts"] = islist(meta["template_reject_reason_counts"]) ? meta["template_reject_reason_counts"] : list()
		metrics["template_reject_report_count"] = meta["template_reject_report_count"] || 0
		metrics["template_cluster_report_count"] = meta["template_cluster_report_count"] || 0
		metrics["placed_requirement_counts"] = islist(meta["placed_requirement_counts"]) ? meta["placed_requirement_counts"] : list()
		metrics["semantic_requirement_counts"] = islist(meta["semantic_requirement_counts"]) ? meta["semantic_requirement_counts"] : list()
		metrics["semantic_requirement_minimums"] = islist(meta["semantic_requirement_minimums"]) ? meta["semantic_requirement_minimums"] : list()
		metrics["generated_turf_count"] = meta["footprint_count"] || 0
		metrics["generated_object_count"] = (meta["door_count"] || 0) + (meta["window_count"] || 0) + (meta["interior_object_count"] || 0)
		metrics["has_interior_objects"] = round(text2num("[meta["interior_object_count"]]") || 0) > 0
		metrics["has_template_chunks"] = round(text2num("[meta["template_chunk_count"]]") || 0) > 0
		metrics["has_room_count_dividers"] = round(text2num("[meta["room_count_divider_count"]]") || 0) > 0
	if(islist(apply))
		metrics["changed_turf_count"] = apply["changed_turf_count"] || 0
		metrics["created_object_count"] = apply["created_object_count"] || 0
		metrics["post_apply_validation_error_count"] = apply["post_apply_validation_error_count"] || 0
	if(islist(post_emit))
		for(var/key as anything in post_emit)
			if(findtext("[key]", "_count"))
				metrics[key] = post_emit[key]
	return metrics

/datum/world_edit_visual_case/proc/build_direction_report(list/preview)
	var/list/meta = preview?["metadata"]
	return list(
		"requested" = meta?["requested_direction_label"],
		"actual_entry_direction" = meta?["actual_entry_direction_label"],
		"honored" = meta?["direction_honored"] ? TRUE : FALSE,
		"fallback_reason" = meta?["direction_fallback_reason"],
	)
