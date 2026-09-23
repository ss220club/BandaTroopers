/*
 * One JSON case execution.
 *
 * The central rule for this file is: never duplicate building generation logic.
 * A case adapts JSON input into the same shape contract, support report, plan,
 * and apply procs used by the production World Edit building_layout generator.
 * If the generator says "locked" or "error", the workbench records that result
 * instead of manufacturing a prettier preview.
 */
/datum/world_edit_visual_case
	var/id = ""
	var/generator_id = "building_layout"
	var/seed = 0
	var/list/canvas_config = list()
	var/list/shape_config = list()
	var/list/generator_config = list()
	var/list/expect_config = list()
	var/list/render_config = list()
	var/list/profile_config = list()
	var/workflow_run_id = ""
	var/source_sha = ""
	var/source_file = ""
	var/out_dir = ""
	var/datum/world_edit_visual_canvas/canvas
	var/datum/world_edit_visual_profiler/profiler
	var/datum/world_edit_plan/last_plan
	var/list/report = list()
	var/list/errors = list()
	var/list/warnings = list()

/datum/world_edit_visual_case/proc/load_from_json_text(text)
	var/list/data
	try
		data = json_decode(text)
	catch(var/exception/E)
		return list("error" = "invalid_json_case", "message" = E.name)
	if(!islist(data))
		return list("error" = "invalid_json_case")

	id = sanitize_visual_case_id(data["id"])
	generator_id = "[data["generator"] || "building_layout"]"
	seed = round(text2num("[data["seed"]]") || 0)
	canvas_config = islist(data["canvas"]) ? data["canvas"] : list()
	shape_config = islist(data["shape"]) ? data["shape"] : list()
	generator_config = islist(data["config"]) ? data["config"] : list()
	expect_config = islist(data["expect"]) ? data["expect"] : list()
	render_config = islist(data["render"]) ? data["render"] : list()
	profile_config = islist(data["profile"]) ? data["profile"] : list()
	workflow_run_id = "[data["workflow_run_id"] || data["run_id"] || ""]"
	source_sha = "[data["source_sha"] || ""]"

	if(!length(id))
		return list("error" = "missing_case_id")
	if(generator_id != "building_layout")
		return list("error" = "unsupported_visual_generator")
	return list("ok" = TRUE)

/datum/world_edit_visual_case/proc/sanitize_visual_case_id(value)
	var/safe_id = sanitize_filename("[value]")
	if(!length(safe_id))
		return ""
	return safe_id

/datum/world_edit_visual_case/proc/execute()
	profiler = new
	profiler.enabled = profile_config?["enabled"] ? TRUE : FALSE
	profiler.begin_total()

	var/list/output_result = setup_output_dir()
	if(output_result["error"])
		return finish_error(WORLD_EDIT_VISUAL_STAGE_LOAD_CASE, output_result["error"], output_result)
	write_progress(WORLD_EDIT_VISUAL_STAGE_LOAD_CASE, "output_ready")

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_CANVAS_SETUP)
	canvas = new
	var/list/canvas_result = canvas.setup(canvas_config)
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_CANVAS_SETUP, canvas_result)
	write_progress(WORLD_EDIT_VISUAL_STAGE_CANVAS_SETUP, canvas_result["error"] ? "error" : "ok")
	if(canvas_result["error"])
		return finish_error(WORLD_EDIT_VISUAL_STAGE_CANVAS_SETUP, canvas_result["error"], canvas_result)

	var/datum/world_edit_generator/building_layout/generator = get_generator()
	if(!istype(generator))
		return finish_error(WORLD_EDIT_VISUAL_STAGE_LOAD_CASE, "generator_not_found")

	var/list/params = build_generator_params()
	var/list/placement_context = build_placement_context()
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract(placement_context)
	if(!istype(shape_contract))
		return finish_error(WORLD_EDIT_VISUAL_STAGE_LOAD_CASE, "invalid_shape_contract")
	write_progress(WORLD_EDIT_VISUAL_STAGE_LOAD_CASE, "context_ready")

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_SUPPORT_CHECK)
	var/list/support = generator.get_placement_shape_support_report(shape_contract.shape_id, params, placement_context)
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_SUPPORT_CHECK, support)
	apply_support_metadata(shape_contract, placement_context, support)
	write_progress(WORLD_EDIT_VISUAL_STAGE_SUPPORT_CHECK, support["reason"] || "ok")
	// Apply-mode cases must stop when apply is disabled, even if preview would
	// be possible. This keeps "what would be placed" aligned with real runtime
	// acceptance rather than a partial UI hover preview.
	if(support["shape_locked"] || support["locked"] || support["request_locked"] || !support["can_preview"] || !support["can_apply"])
		var/list/locked_support = support.Copy()
		locked_support["reason_code"] = support["lock_code"] || "request.locked"
		locked_support["reason"] = support["reason"] || "Request is locked."
		return finish_locked(locked_support)

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_PREVIEW)
	// This is the production plan builder. Any preview-stage validation error
	// here is a generator issue and must be surfaced as structured data.
	last_plan = generator.build_plan_from_shape_contract(null, shape_contract, params, placement_context)
	var/list/preview_result = build_preview_result(last_plan)
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_PREVIEW, preview_result)
	if(preview_result["error"])
		return finish_error(WORLD_EDIT_VISUAL_STAGE_PREVIEW, preview_result["error"], preview_result)
	var/list/determinism_result = null
	if(should_run_determinism_replay())
		determinism_result = build_determinism_replay_result(generator, shape_contract, params, placement_context, preview_result)

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_APPLY)
	// Apply is also production code. It creates the real turfs/objects and can
	// still fail if runtime blockers or emitted state diverge from the plan.
	var/datum/world_edit_apply_result/apply_result_datum = generator.apply_plan(null, params, last_plan)
	var/list/apply_result = build_apply_result(apply_result_datum)
	if(islist(last_plan?.affected_turfs))
		canvas.mark_changed_turfs(last_plan.affected_turfs)
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_APPLY, apply_result)
	if(apply_result["error"])
		return finish_error(WORLD_EDIT_VISUAL_STAGE_APPLY, apply_result["error"], apply_result)

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_POST_EMIT_VALIDATE)
	var/list/post_emit_result = run_post_emit_validation(last_plan)
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_POST_EMIT_VALIDATE, post_emit_result)

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_EXPORT)
	var/list/export_result = export_artifacts(apply_result, post_emit_result)
	export_semantic_json(list(
		"rooms" = preview_result?["rooms"] || list(),
		"routes" = preview_result?["routes"] || list(),
		"profile" = profiler?.to_json_list(),
	))
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_EXPORT, export_result)

	profiler.enter_stage(WORLD_EDIT_VISUAL_STAGE_UNDO)
	var/list/undo_result = run_undo_validation(apply_result_datum)
	profiler.leave_stage(WORLD_EDIT_VISUAL_STAGE_UNDO, undo_result)

	var/list/final_report = finish_supported(preview_result, apply_result, post_emit_result, export_result, undo_result, determinism_result)
	report = final_report
	return final_report

/datum/world_edit_visual_case/proc/get_generator()
	return new /datum/world_edit_generator/building_layout

/datum/world_edit_visual_case/proc/setup_output_dir()
	return world_edit_visual_ensure_directory(out_dir)

/datum/world_edit_visual_case/proc/write_progress(stage, message)
	var/list/progress = list(
		"schema" = "world_edit_visual_progress/v1",
		"case_id" = id,
		"stage" = "[stage]",
		"message" = "[message]",
		"world_time" = world.time,
	)
	if(length(workflow_run_id))
		progress["workflow_run_id"] = workflow_run_id
	write_json_file("[out_dir]/progress.json", progress)

/datum/world_edit_visual_case/proc/build_generator_params()
	var/list/params = generator_config.Copy()
	// Case JSON uses user-facing names. The generator expects archetype_id and
	// building_seed, so keep this translation at the adapter boundary.
	if(params["program"] && !params["archetype_id"])
		params["archetype_id"] = "[params["program"]]"
	if(seed && !params["building_seed"])
		params["building_seed"] = seed
	// Workbench reports are diagnostic artifacts. Opt into the generator's
	// existing detailed metadata only inside this adapter so gameplay/runtime
	// defaults remain unchanged.
	if(isnull(params["debug_reports"]))
		params["debug_reports"] = TRUE
	return params

/datum/world_edit_visual_case/proc/build_placement_context()
	var/shape_id = "[shape_config["id"] || WORLD_EDIT_SHAPE_POINT]"
	var/list/anchors = build_anchor_turfs(shape_config)
	var/turf/start_turf = length(anchors) ? anchors[1] : canvas.local_turf(1, 1)
	var/turf/end_turf = length(anchors) >= 2 ? anchors[2] : start_turf
	var/direction = parse_visual_direction(generator_config["direction"])
	// Match the manager/runtime placement_context keys consumed by shared
	// generator helpers. Keeping these names stable is what lets the workbench
	// call build_plan_from_shape_contract() instead of a parallel code path.
	return list(
		"mode" = "single",
		"shape" = shape_id,
		"anchor_turfs" = anchors,
		"start_turf" = start_turf,
		"end_turf" = end_turf,
		"shape_origin_turf" = start_turf,
		"seed_turf" = start_turf,
		"requested_end_turf" = end_turf,
		"resolved_end_turf" = end_turf,
		"direction" = direction,
	)

/datum/world_edit_visual_case/proc/build_shape_contract(list/placement_context)
	var/shape_id = "[placement_context["shape"] || WORLD_EDIT_SHAPE_POINT]"
	var/turf/start_turf = placement_context["start_turf"]
	var/turf/end_turf = placement_context["end_turf"]
	var/datum/world_edit_shape_contract/shape_contract = GLOB.world_edit_shape_geometry.build_shape_contract(shape_id, start_turf, end_turf, build_generator_params(), placement_context["direction"] || NORTH)
	if(istype(shape_contract))
		// The support checker and footprint resolver both read these context
		// entries. In particular, rectangle support must see the resolved shape
		// contract, not just the two raw JSON anchors.
		placement_context["shape_contract"] = shape_contract
		placement_context["shape_metadata"] = shape_contract.copy_metadata()
		placement_context["anchor_turfs"] = shape_contract.copy_anchor_turfs()
	return shape_contract

/datum/world_edit_visual_case/proc/apply_support_metadata(datum/world_edit_shape_contract/shape_contract, list/placement_context, list/support)
	if(!istype(shape_contract) || !islist(support))
		return
	var/list/support_metadata = support["metadata"]
	if(islist(support_metadata))
		if(!islist(shape_contract.metadata))
			shape_contract.metadata = list()
		for(var/key in support_metadata)
			shape_contract.metadata[key] = support_metadata[key]
	placement_context["shape_contract"] = shape_contract
	placement_context["shape_metadata"] = shape_contract.copy_metadata()
	placement_context["anchor_turfs"] = shape_contract.copy_anchor_turfs()

/datum/world_edit_visual_case/proc/build_anchor_turfs(list/shape)
	var/list/anchors = list()
	var/list/raw_anchors = islist(shape) ? shape["anchors"] : null
	if(islist(raw_anchors))
		for(var/list/raw_anchor as anything in raw_anchors)
			if(!islist(raw_anchor))
				continue
			var/turf/T = canvas.local_turf(raw_anchor["x"], raw_anchor["y"])
			if(istype(T))
				anchors += T
	if(!length(anchors))
		var/turf/default_turf = canvas.local_turf(round(canvas.width / 2), round(canvas.height / 2))
		if(istype(default_turf))
			anchors += default_turf
	return anchors

/datum/world_edit_visual_case/proc/parse_visual_direction(value)
	switch(lowertext("[value]"))
		if("north")
			return NORTH
		if("south")
			return SOUTH
		if("east")
			return EAST
		if("west")
			return WEST
	return EAST

/datum/world_edit_visual_case/proc/build_preview_result(datum/world_edit_plan/plan)
	if(!istype(plan))
		return list("error" = "preview_returned_no_plan")
	if(plan.metadata["error"])
		return list("error" = "[plan.metadata["error"]]", "metadata" = plan.metadata.Copy())
	if(!length(plan.placements))
		return list("error" = "preview_plan_empty", "metadata" = plan.metadata.Copy())
	return list(
		"ok" = TRUE,
		"metadata" = plan.metadata.Copy(),
		"rooms" = length(plan.metadata["room_reports"]) ? plan.metadata["room_reports"] : (plan.metadata["room_contract_report"] || list()),
		"routes" = plan.metadata["corridor_report"] ? list(plan.metadata["corridor_report"]) : list(),
		"template_reject_reports" = islist(plan.metadata["template_reject_reports"]) ? plan.metadata["template_reject_reports"] : list(),
		"template_cluster_reports" = islist(plan.metadata["template_cluster_reports"]) ? plan.metadata["template_cluster_reports"] : list(),
		"placement_count" = length(plan.placements),
	)

/datum/world_edit_visual_case/proc/should_run_determinism_replay()
	if(!isnull(expect_config?["same_seed_layout_hash"]))
		return TRUE
	if(render_config?["determinism_replay"])
		return TRUE
	return FALSE

/datum/world_edit_visual_case/proc/build_determinism_replay_result(datum/world_edit_generator/building_layout/generator, datum/world_edit_shape_contract/shape_contract, list/params, list/placement_context, list/preview_result)
	var/list/result = list(
		"status" = "not_run",
		"same_seed_layout_hash" = FALSE,
		"all_hashes_match" = FALSE,
		"layout_hash" = null,
		"replay_layout_hash" = null,
		"hash_mismatches" = list(),
	)
	var/list/first_meta = preview_result?["metadata"]
	if(!istype(generator) || !istype(shape_contract) || !islist(first_meta))
		result["status"] = "failed"
		result["error"] = "determinism_replay_missing_inputs"
		return result
	var/datum/world_edit_plan/replay_plan = generator.build_plan_from_shape_contract(null, shape_contract, params, placement_context)
	var/list/replay_preview = build_preview_result(replay_plan)
	if(replay_preview["error"])
		result["status"] = "failed"
		result["error"] = replay_preview["error"]
		result["replay_metadata"] = islist(replay_preview["metadata"]) ? replay_preview["metadata"] : list()
		return result
	var/list/replay_meta = replay_preview["metadata"]
	if(!islist(replay_meta))
		result["status"] = "failed"
		result["error"] = "determinism_replay_missing_metadata"
		return result
	var/list/hash_keys = list(
		"layout_hash",
		"footprint_hash",
		"room_graph_hash",
		"route_hash",
		"wall_hash",
		"pattern_credit_hash",
		"determinism_check_hash",
	)
	var/list/mismatches = list()
	for(var/hash_key as anything in hash_keys)
		var/first_hash = first_meta[hash_key]
		var/replay_hash = replay_meta[hash_key]
		result[hash_key] = first_hash
		result["replay_[hash_key]"] = replay_hash
		if("[first_hash]" != "[replay_hash]")
			mismatches += "[hash_key]"
	result["hash_mismatches"] = mismatches
	result["layout_hash"] = first_meta["layout_hash"]
	result["replay_layout_hash"] = replay_meta["layout_hash"]
	result["same_seed_layout_hash"] = "[first_meta["layout_hash"]]" == "[replay_meta["layout_hash"]]"
	result["all_hashes_match"] = !length(mismatches)
	result["status"] = result["same_seed_layout_hash"] ? "matched" : "mismatched"
	return result

/datum/world_edit_visual_case/proc/build_apply_result(datum/world_edit_apply_result/result)
	if(!istype(result))
		return list("error" = "apply_returned_invalid_result")
	var/list/out = islist(result.meta) ? result.meta.Copy() : list()
	out["success"] = result.success ? TRUE : FALSE
	out["message"] = result.message
	out["created_object_count"] = result.created_count
	if(!result.success)
		out["error"] = result.message || "apply_failed"
	return out

/datum/world_edit_visual_case/proc/run_post_emit_validation(datum/world_edit_plan/plan)
	var/list/post_emit = plan?.metadata?["post_emit_validation_report"]
	if(islist(post_emit))
		return post_emit.Copy()
	// Missing validation is not success. The workbench still emits artifacts so
	// the case is inspectable, but acceptance should treat this as incomplete.
	add_warning("Generator has no post-emit validation entrypoint or report metadata.")
	return list("warning" = "post_emit_validation_missing", "post_emit_validation_error_count" = -1)

/datum/world_edit_visual_case/proc/run_undo_validation(datum/world_edit_apply_result/apply_result)
	var/datum/world_edit_validation_verdict/verdict
	if(!istype(apply_result))
		add_error("undo_apply_result_missing", "Cannot validate undo without a valid apply result.", WORLD_EDIT_VISUAL_STAGE_UNDO)
		verdict = new(WORLD_EDIT_BUILDING_WORKBENCH_FAILED, WORLD_EDIT_BUILDING_STAGE_WORKBENCH)
		verdict.add_hard_error("undo_apply_result_missing", "Cannot validate undo without a valid apply result.")
		return list("status" = "failed", "restored" = FALSE, "error" = "undo_apply_result_missing", "undo_validation_verdict" = verdict.as_payload())
	if(!istype(apply_result.changeset))
		add_error("undo_changeset_missing", "Apply result did not provide a changeset for undo validation.", WORLD_EDIT_VISUAL_STAGE_UNDO)
		verdict = new(WORLD_EDIT_BUILDING_WORKBENCH_FAILED, WORLD_EDIT_BUILDING_STAGE_WORKBENCH)
		verdict.add_hard_error("undo_changeset_missing", "Apply result did not provide a changeset for undo validation.")
		return list("status" = "failed", "restored" = FALSE, "error" = "undo_changeset_missing", "undo_validation_verdict" = verdict.as_payload())
	var/list/undo_result = GLOB.world_edit_changesets.revert_changeset(apply_result.changeset)
	var/outcome = "[undo_result["outcome"] || "none"]"
	var/restored = outcome == "full"
	undo_result["status"] = restored ? "restored" : "failed"
	undo_result["restored"] = restored ? TRUE : FALSE
	verdict = new(restored ? WORLD_EDIT_BUILDING_WORKBENCH_PASSED : WORLD_EDIT_BUILDING_WORKBENCH_FAILED, WORLD_EDIT_BUILDING_STAGE_WORKBENCH)
	verdict.set_metric("undo_status", undo_result["status"])
	verdict.set_metric("undo_outcome", outcome)
	verdict.set_metric("undo_restored", restored ? TRUE : FALSE)
	verdict.set_metric("undo_reverted_count", undo_result["reverted_count"] || 0)
	verdict.set_metric("undo_skipped_count", undo_result["skipped_count"] || 0)
	if(!restored)
		add_error("undo_not_restored", "Undo validation did not fully restore the applied changeset.", WORLD_EDIT_VISUAL_STAGE_UNDO, null, undo_result)
		verdict.add_hard_error("undo_not_restored", "Undo validation did not fully restore the applied changeset.", undo_result)
	undo_result["undo_validation_verdict"] = verdict.as_payload()
	return undo_result
