#define WORLD_EDIT_RUNTIME_TRACE_ENABLED FALSE
#define WORLD_EDIT_RUNTIME_DIAGNOSTICS_UI_ENABLED FALSE

/datum/world_edit_manager/proc/build_safe_placement_preview_message(datum/world_edit_plan/plan, list/fallback_meta = null)
	var/list/metadata = plan?.metadata || fallback_meta || list()
	var/list/placements = plan?.placements || list()
	var/anchor_count = metadata["anchor_count"] || 1
	var/entry_count = metadata["entry_count"] || length(placements)
	var/entry_label = "[entry_count]"
	if(!length(placements) && isnull(metadata["entry_count"]) && GLOB.world_edit_helpers.parse_bool(metadata["preview_plan_deferred"]))
		entry_label = "отложено"
	var/collector_point_count = metadata["collector_preview_point_count"] || metadata["collector_point_count"]
	var/mode = metadata["placement_mode"] || get_effective_placement_mode() || "single"
	var/mode_label = mode == "single" ? "один раз" : mode == "repeat" ? "повтор" : "[mode]"
	var/shape_label = metadata["shape_label"] || GLOB.world_edit_placement_shapes.world_edit_get_placement_shape_label(metadata["placement_shape"] || get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT)
	var/message = "Предпросмотр размещения готов: форма=[shape_label], режим=[mode_label], опор=[anchor_count], действий=[entry_label]."
	if(collector_point_count)
		message += " Точек в сборе=[collector_point_count]."
	if(metadata["placement_dir_label"])
		message = "Предпросмотр размещения готов: форма=[shape_label], режим=[mode_label], опор=[anchor_count], действий=[entry_label], направление=[metadata["placement_dir_label"]]."
		if(collector_point_count)
			message += " Точек в сборе=[collector_point_count]."
	if(GLOB.world_edit_helpers.parse_bool(metadata["will_replace_blocked_turfs"]) && round(text2num("[metadata["replace_blocked_turf_count"]]") || 0) > 0)
		message += " Will replace blocked turfs: [metadata["replace_blocked_turf_count"]]."
	return message

/datum/world_edit_manager/proc/build_safe_placement_confirm_text(datum/world_edit_plan/plan)
	var/list/metadata = plan?.metadata || list()
	var/list/placements = plan?.placements || list()
	var/anchor_count = metadata["anchor_count"] || 1
	var/entry_count = metadata["entry_count"] || length(placements)
	var/mode = metadata["placement_mode"] || get_effective_placement_mode() || "single"
	var/mode_label = mode == "single" ? "один раз" : mode == "repeat" ? "повтор" : "[mode]"
	var/shape_label = metadata["shape_label"] || GLOB.world_edit_placement_shapes.world_edit_get_placement_shape_label(metadata["placement_shape"] || get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT)
	var/dir_suffix = ""
	if(metadata["placement_dir_label"])
		dir_suffix = ", направление=[metadata["placement_dir_label"]]"
	var/replacement_suffix = ""
	if(GLOB.world_edit_helpers.parse_bool(metadata["will_replace_blocked_turfs"]) && round(text2num("[metadata["replace_blocked_turf_count"]]") || 0) > 0)
		replacement_suffix = ", заменит блокирующих тайлов=[metadata["replace_blocked_turf_count"]]"
	return "Применить размещение [current_definition?.name_ru || current_definition?.id]? форма=[shape_label], режим=[mode_label], опор=[anchor_count], действий=[entry_count][dir_suffix][replacement_suffix]."

/datum/world_edit_manager/proc/sanitize_preview_feedback_meta(list/meta)
	if(!islist(meta))
		return list()

	var/list/safe_meta = list()
	var/turf/shape_origin_turf = meta["shape_origin_turf"]
	var/turf/requested_end_turf = meta["requested_end_turf"]
	var/turf/resolved_end_turf = meta["resolved_end_turf"]
	var/turf/seed_turf = meta["seed_turf"]
	if(istype(shape_origin_turf))
		safe_meta["shape_origin"] = GLOB.world_edit_helpers.turf_to_text(shape_origin_turf)
	if(istype(requested_end_turf))
		safe_meta["requested_end"] = GLOB.world_edit_helpers.turf_to_text(requested_end_turf)
	if(istype(resolved_end_turf))
		safe_meta["resolved_end"] = GLOB.world_edit_helpers.turf_to_text(resolved_end_turf)
	if(istype(seed_turf))
		safe_meta["seed"] = GLOB.world_edit_helpers.turf_to_text(seed_turf)

	for(var/key in meta)
		var/key_text = "[key]"
		if(key_text in list("shape_result", "shape_origin_turf", "requested_end_turf", "resolved_end_turf", "seed_turf"))
			continue
		safe_meta[key_text] = sanitize_preview_feedback_meta_value(meta[key])
	return safe_meta

/datum/world_edit_manager/proc/sanitize_preview_feedback_meta_value(value)
	if(isnull(value) || isnum(value) || istext(value))
		return value
	if(ispath(value))
		return "[value]"
	if(istype(value, /turf))
		return GLOB.world_edit_helpers.turf_to_text(value)
	if(istype(value, /atom))
		var/atom/atom_value = value
		return "[atom_value.type]"
	if(istype(value, /datum))
		var/datum/datum_value = value
		return "[datum_value.type]"
	if(islist(value))
		return length(value)
	return "[value]"

/datum/world_edit_manager/proc/build_shape_contract_from_plan_metadata(datum/world_edit_plan/plan)
	var/list/metadata = plan?.metadata
	if(!islist(metadata))
		return null

	var/shape_id = metadata["placement_shape"] || metadata["shape_id"]
	var/list/shape_result = metadata["shape_result"]
	if(!length("[shape_id]") || !islist(shape_result) || !length(shape_result))
		return null
	return GLOB.world_edit_shape_geometry.build_shape_contract_from_result(shape_id, shape_result)

/datum/world_edit_manager/proc/mark_shape_contract_preview_deferred(datum/world_edit_shape_contract/shape_contract, list/placement_context = null)
	if(!istype(shape_contract))
		return FALSE

	if(!islist(shape_contract.metadata))
		shape_contract.metadata = list()
	shape_contract.metadata["preview_plan_deferred"] = TRUE
	if(isnull(shape_contract.metadata["anchor_count"]))
		shape_contract.metadata["anchor_count"] = length(shape_contract.anchor_turfs)

	var/placement_dir = islist(placement_context) ? text2num("[placement_context["direction"]]") : null
	if(GLOB.world_edit_helpers.is_cardinal_dir(placement_dir) && !length("[shape_contract.metadata["placement_dir_label"]]"))
		shape_contract.metadata["placement_dir_label"] = GLOB.world_edit_helpers.dir_to_label(placement_dir)
	return TRUE

/datum/world_edit_manager/proc/should_use_placement_layer_preview(datum/world_edit_plan/plan)
	if(!supports_current_placement_ux() || !istype(plan))
		return FALSE
	if(!current_generator?.should_render_preview_via_placement_layers(plan))
		return FALSE
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract_from_plan_metadata(plan)
	return istype(shape_contract, /datum/world_edit_shape_contract) ? TRUE : FALSE

/datum/world_edit_manager/proc/build_placement_candidate_from_plan(datum/world_edit_plan/plan, list/effective_params = null, mob/user = null)
	if(!supports_current_placement_ux() || !istype(plan))
		return null

	var/list/plan_metadata = islist(plan.metadata) ? plan.metadata : list()
	var/raw_shape_id = plan_metadata["placement_shape"] || resolve_supported_placement_shape(placement_shape) || placement_shape
	var/shape_id = length("[raw_shape_id]") ? "[raw_shape_id]" : WORLD_EDIT_SHAPE_POINT
	if(!length(shape_id))
		return null

	var/placement_dir = text2num("[plan_metadata["placement_dir"]]")
	if(!(placement_dir in GLOB.cardinals))
		placement_dir = supports_current_placement_direction() ? get_effective_placement_dir() : NORTH

	var/list/params_to_use = islist(effective_params) ? effective_params.Copy() : build_effective_generator_params(null, shape_id)
	var/datum/world_edit_shape_contract/shape_contract = build_shape_contract_from_plan_metadata(plan)
	var/turf/shape_origin_turf = plan_metadata["shape_origin_turf"] || plan_metadata["center_turf"] || get_turf(user)
	var/turf/requested_end_turf = plan_metadata["requested_end_turf"] || plan_metadata["resolved_end_turf"] || plan_metadata["center_turf"] || shape_origin_turf
	var/turf/resolved_end_turf = plan_metadata["resolved_end_turf"] || requested_end_turf
	var/turf/seed_turf = plan_metadata["seed_turf"] || shape_origin_turf
	if(!istype(shape_contract))
		return null

	var/raw_placement_mode = plan_metadata["placement_mode"] || get_effective_placement_mode()
	var/placement_mode = length("[raw_placement_mode]") ? "[raw_placement_mode]" : "single"
	var/list/placement_context = build_placement_context(shape_contract, shape_origin_turf, resolved_end_turf, requested_end_turf, seed_turf, shape_origin_turf, placement_dir, placement_mode)
	stamp_placement_plan_shape_metadata(plan, shape_contract, placement_context)
	return build_placement_candidate(shape_contract, placement_context, plan, params_to_use)

/datum/world_edit_manager/proc/update_placement_context_shape_metadata(list/placement_context, datum/world_edit_shape_contract/shape_contract)
	if(!islist(placement_context) || !istype(shape_contract))
		return placement_context

	placement_context["shape"] = shape_contract.shape_id
	placement_context["shape_contract"] = shape_contract
	placement_context["shape_metadata"] = shape_contract.copy_metadata()
	placement_context["anchor_turfs"] = shape_contract.copy_anchor_turfs()
	return placement_context

/datum/world_edit_manager/proc/build_placement_context(datum/world_edit_shape_contract/shape_contract, turf/start_turf, turf/end_turf, turf/requested_end_turf = null, turf/seed_turf = null, turf/shape_origin_turf = null, direction_override = null, mode_override = null)
	if(!istype(shape_contract))
		return list()

	var/effective_direction = isnull(direction_override) ? (supports_current_placement_direction() ? get_effective_placement_dir() : NORTH) : direction_override
	return list(
		"mode" = mode_override || get_effective_placement_mode() || "single",
		"shape" = shape_contract.shape_id,
		"shape_contract" = shape_contract,
		"shape_metadata" = shape_contract.copy_metadata(),
		"anchor_turfs" = shape_contract.copy_anchor_turfs(),
		"start_turf" = start_turf,
		"end_turf" = end_turf,
		"shape_origin_turf" = shape_origin_turf || start_turf,
		"seed_turf" = seed_turf || shape_origin_turf || start_turf,
		"requested_end_turf" = requested_end_turf || end_turf,
		"resolved_end_turf" = end_turf,
		"direction" = effective_direction,
	)

/datum/world_edit_manager/proc/apply_shape_contract_runtime_metadata(datum/world_edit_shape_contract/shape_contract, list/shape_metadata_override = null, list/collector_state_summary = null)
	if(!istype(shape_contract))
		return null
	if(!islist(shape_contract.metadata))
		shape_contract.metadata = list()
	if(islist(shape_metadata_override))
		for(var/key in shape_metadata_override)
			shape_contract.metadata[key] = shape_metadata_override[key]
	if(islist(collector_state_summary))
		for(var/key in collector_state_summary)
			shape_contract.metadata[key] = collector_state_summary[key]
	return shape_contract

/datum/world_edit_manager/proc/build_shape_contract_attempt_signature(datum/world_edit_shape_contract/shape_contract)
	if(!istype(shape_contract))
		return null
	if(length("[shape_contract.error]"))
		return "__error__:[shape_contract.shape_id]:[shape_contract.error]"

	var/list/anchor_turfs = shape_contract.anchor_turfs
	if(!islist(anchor_turfs) || !length(anchor_turfs))
		return "__empty__:[shape_contract.shape_id]:[shape_contract.degenerate_kind]"

	var/list/signature_chunks = list(
		"[shape_contract.shape_id]",
		"[shape_contract.degenerate_kind]",
		"[length(anchor_turfs)]",
	)
	for(var/turf/anchor_turf as anything in anchor_turfs)
		if(!istype(anchor_turf))
			continue
		signature_chunks += "[anchor_turf.x],[anchor_turf.y],[anchor_turf.z]"
	return jointext(signature_chunks, ";")

/datum/world_edit_manager/proc/clear_last_resolved_placement_candidate_cache()
	var/datum/world_edit_placement_session/session = placement_session
	if(!istype(session))
		return FALSE

	session.last_resolved_candidate = null
	session.last_resolved_candidate_params_signature = null
	session.last_resolved_candidate_attempt_signature = null
	session.last_resolved_candidate_end_turf = null
	session.last_resolved_candidate_hover_only = FALSE
	return TRUE

/datum/world_edit_manager/proc/reset_runtime_diagnostics()
	runtime_diagnostics = list(
		"started_at_ds" = world.time,
		"hover_preview_requests" = 0,
		"hover_resolve_calls" = 0,
		"hover_plan_skips" = 0,
		"hover_object_plan_builds" = 0,
		"hover_object_plan_throttle_skips" = 0,
		"hover_object_plan_anchor_skips" = 0,
		"preview_plan_defers" = 0,
		"click_resolve_calls" = 0,
		"deferred_apply_plan_builds" = 0,
		"resolve_cache_hits" = 0,
		"resolve_cache_misses" = 0,
		"preview_endpoint_clamp_attempts" = 0,
		"preview_endpoint_clamp_successes" = 0,
		"preview_endpoint_clamp_hover_skips" = 0,
		"preview_render_calls" = 0,
		"preview_render_skips" = 0,
		"preview_image_rebuilds" = 0,
		"preview_image_creations" = 0,
		"preview_image_reuses" = 0,
		"preview_images_last" = 0,
		"preview_images_peak" = 0,
		"preview_eval_hover_total_ds" = 0,
		"preview_eval_hover_peak_ds" = 0,
		"preview_eval_click_total_ds" = 0,
		"preview_eval_click_peak_ds" = 0,
		"preview_shape_contract_total_ds" = 0,
		"preview_shape_contract_peak_ds" = 0,
		"preview_model_build_total_ds" = 0,
		"preview_model_build_peak_ds" = 0,
		"preview_render_token_total_ds" = 0,
		"preview_render_token_peak_ds" = 0,
		"preview_render_total_ds" = 0,
		"preview_render_peak_ds" = 0,
		"preview_render_clear_total_ds" = 0,
		"preview_render_clear_peak_ds" = 0,
		"preview_render_groups_total_ds" = 0,
		"preview_render_groups_peak_ds" = 0,
		"preview_render_specs_total_ds" = 0,
		"preview_render_specs_peak_ds" = 0,
		"preview_render_attach_total_ds" = 0,
		"preview_render_attach_peak_ds" = 0,
		"ui_data_total_ds" = 0,
		"ui_data_peak_ds" = 0,
		"tgui_update_messages" = 0,
		"tgui_update_encode_total_ds" = 0,
		"tgui_update_encode_peak_ds" = 0,
		"tgui_update_output_total_ds" = 0,
		"tgui_update_output_peak_ds" = 0,
		"tgui_update_bytes_last" = 0,
		"tgui_update_bytes_peak" = 0,
		"last_slow_stage" = null,
		"last_slow_duration_ds" = 0,
		"last_slow_details" = null,
		"last_slow_log_signature" = null,
		"last_slow_log_at_ds" = 0,
	)
	reset_runtime_trace()
	return runtime_diagnostics

/datum/world_edit_manager/proc/get_runtime_diagnostics()
	if(!islist(runtime_diagnostics) || !length(runtime_diagnostics))
		reset_runtime_diagnostics()
	return runtime_diagnostics

/datum/world_edit_manager/proc/reset_runtime_trace()
	runtime_trace = list()
	runtime_trace_payload_cache = list()
	runtime_trace_sequence = 0
	return runtime_trace

/datum/world_edit_manager/proc/build_runtime_trace_gc_snapshot()
	if(!SSgarbage)
		return "gc=n/a"

	var/list/queue_sizes = list()
	if(islist(SSgarbage.queues))
		for(var/list/queue as anything in SSgarbage.queues)
			queue_sizes += length(queue)
	var/queue_text = length(queue_sizes) ? queue_sizes.Join(",") : "n/a"
	return "gcQ=[queue_text] D=[SSgarbage.delslasttick] G=[SSgarbage.gcedlasttick] TD=[SSgarbage.totaldels] TG=[SSgarbage.totalgcs]"

/datum/world_edit_manager/proc/build_runtime_trace_gc_snapshot_if_enabled()
#if WORLD_EDIT_RUNTIME_TRACE_ENABLED
	return build_runtime_trace_gc_snapshot()
#else
	return null
#endif

/datum/world_edit_manager/proc/append_runtime_trace(stage, details = null)
#if WORLD_EDIT_RUNTIME_TRACE_ENABLED
	var/stage_text = trim("[stage]")
	if(!length(stage_text))
		return FALSE

	if(!islist(runtime_trace))
		runtime_trace = list()
	if(!placement_click_active && !length(runtime_trace) && findtext(stage_text, "click:") != 1 && findtext(stage_text, "preview:") != 1)
		return FALSE
	runtime_trace_sequence = text2num("[runtime_trace_sequence]") + 1
	var/list/parts = list(
		"[runtime_trace_sequence]. [stage_text]",
		"t=[round(world.time / 10, 1)]s",
	)
	var/details_text = trim("[details]")
	if(length(details_text))
		parts += details_text
	var/entry_text = jointext(parts, " | ")
	runtime_trace += entry_text
	if(length(runtime_trace) > 40)
		runtime_trace.Cut(1, length(runtime_trace) - 39)
	if(!islist(runtime_trace_payload_cache))
		runtime_trace_payload_cache = list()
	var/payload_entry = entry_text
	if(length(payload_entry) > 220)
		payload_entry = "[copytext(payload_entry, 1, 220)]..."
	runtime_trace_payload_cache += payload_entry
	if(length(runtime_trace_payload_cache) > 12)
		runtime_trace_payload_cache.Cut(1, length(runtime_trace_payload_cache) - 11)
	return TRUE
#else
	return FALSE
#endif

/datum/world_edit_manager/proc/get_runtime_trace_entries()
	if(!islist(runtime_trace))
		runtime_trace = list()
	return runtime_trace

/datum/world_edit_manager/proc/build_runtime_trace_payload(max_entries = 12, max_entry_length = 220)
	if(!islist(runtime_trace_payload_cache))
		runtime_trace_payload_cache = list()
	return runtime_trace_payload_cache.Copy()

/datum/world_edit_manager/proc/increment_runtime_diagnostic(counter_id, amount = 1)
	if(!length("[counter_id]"))
		return 0

	var/list/diagnostics = get_runtime_diagnostics()
	var/current_value = text2num("[diagnostics[counter_id]]")
	current_value += amount
	diagnostics[counter_id] = current_value
	return current_value

/datum/world_edit_manager/proc/set_runtime_diagnostic_peak(counter_id, value)
	if(!length("[counter_id]"))
		return 0

	var/list/diagnostics = get_runtime_diagnostics()
	var/current_value = text2num("[diagnostics[counter_id]]")
	var/next_value = max(current_value, value)
	diagnostics[counter_id] = next_value
	return next_value

/datum/world_edit_manager/proc/record_runtime_diagnostic_duration(counter_id_prefix, started_at_ds)
	if(!length("[counter_id_prefix]"))
		return 0

	var/duration_ds = max(REALTIMEOFDAY - started_at_ds, 0)
	increment_runtime_diagnostic("[counter_id_prefix]_total_ds", duration_ds)
	set_runtime_diagnostic_peak("[counter_id_prefix]_peak_ds", duration_ds)
	return duration_ds

/datum/world_edit_manager/proc/format_runtime_diagnostic_duration(duration_ds)
	return "[round(max(text2num("[duration_ds]"), 0) / 10, 1)]s"

/datum/world_edit_manager/proc/record_runtime_stage_duration(counter_id_prefix, stage_label, started_at_ds, details = null, log_threshold_ds = 2)
	var/duration_ds = record_runtime_diagnostic_duration(counter_id_prefix, started_at_ds)
	if(duration_ds < max(text2num("[log_threshold_ds]"), 0))
		return duration_ds

	var/details_text = trim("[details]")
	if(length(details_text) > 180)
		details_text = "[copytext(details_text, 1, 181)]..."

	var/list/diagnostics = get_runtime_diagnostics()
	diagnostics["last_slow_stage"] = "[stage_label]"
	diagnostics["last_slow_duration_ds"] = duration_ds
	diagnostics["last_slow_details"] = details_text
	var/log_signature = "[stage_label]|[details_text]"
	var/last_log_signature = "[diagnostics["last_slow_log_signature"]]"
	var/last_log_at_ds = text2num("[diagnostics["last_slow_log_at_ds"]]")
	if(last_log_signature == log_signature && (world.time - last_log_at_ds) < 10)
		return duration_ds
	diagnostics["last_slow_log_signature"] = log_signature
	diagnostics["last_slow_log_at_ds"] = world.time

	var/generator_id = current_definition?.id || (current_generator ? "[current_generator.type]" : "<none>")
	var/shape_id = resolve_supported_placement_shape(placement_shape) || placement_shape || WORLD_EDIT_SHAPE_POINT
	var/mode_id = resolve_supported_placement_mode(placement_mode) || placement_mode || "single"
	log_world("WORLD EDIT PERF: generator=[generator_id] stage=[stage_label] duration=[duration_ds]ds shape=[shape_id] mode=[mode_id] details=[details_text]")
	return duration_ds

/datum/world_edit_manager/proc/build_runtime_status_entries()
	var/list/entries = list()
	var/list/generator_entries = current_generator?.get_runtime_status()
#if !WORLD_EDIT_RUNTIME_DIAGNOSTICS_UI_ENABLED
	if(islist(generator_entries))
		for(var/list/entry as anything in generator_entries)
			if(!islist(entry))
				continue
			var/label = "[entry["label"]]"
			if(!length(label))
				continue
			entries += list(list(
				"label" = label,
				"value" = "[entry["value"]]",
			))
	return entries
#else
	var/list/diagnostics = get_runtime_diagnostics()
	var/has_placement_activity = FALSE
	for(var/counter_id in list(
		"hover_preview_requests",
		"hover_resolve_calls",
		"hover_plan_skips",
		"preview_plan_defers",
		"click_resolve_calls",
		"deferred_apply_plan_builds",
		"resolve_cache_hits",
		"resolve_cache_misses",
		"preview_endpoint_clamp_attempts",
		"preview_endpoint_clamp_successes",
		"preview_endpoint_clamp_hover_skips",
		"preview_render_calls",
		"preview_render_skips",
		"preview_image_rebuilds",
		"preview_image_creations",
		"preview_image_reuses",
	))
		if(text2num("[diagnostics[counter_id]]") > 0)
			has_placement_activity = TRUE
			break

	if(supports_current_placement_ux() && has_placement_activity)
		var/started_at_ds = diagnostics["started_at_ds"] || world.time
		var/hover_preview_requests = diagnostics["hover_preview_requests"] || 0
		var/hover_resolve_calls = diagnostics["hover_resolve_calls"] || 0
		var/hover_plan_skips = diagnostics["hover_plan_skips"] || 0
		var/preview_plan_defers = diagnostics["preview_plan_defers"] || 0
		var/click_resolve_calls = diagnostics["click_resolve_calls"] || 0
		var/deferred_apply_plan_builds = diagnostics["deferred_apply_plan_builds"] || 0
		var/resolve_cache_hits = diagnostics["resolve_cache_hits"] || 0
		var/resolve_cache_misses = diagnostics["resolve_cache_misses"] || 0
		var/preview_endpoint_clamp_attempts = diagnostics["preview_endpoint_clamp_attempts"] || 0
		var/preview_endpoint_clamp_successes = diagnostics["preview_endpoint_clamp_successes"] || 0
		var/preview_endpoint_clamp_hover_skips = diagnostics["preview_endpoint_clamp_hover_skips"] || 0
		var/preview_image_rebuilds = diagnostics["preview_image_rebuilds"] || 0
		var/preview_image_creations = diagnostics["preview_image_creations"] || 0
		var/preview_image_reuses = diagnostics["preview_image_reuses"] || 0
		var/preview_render_skips = diagnostics["preview_render_skips"] || 0
		var/preview_images_last = diagnostics["preview_images_last"] || 0
		var/preview_images_peak = diagnostics["preview_images_peak"] || 0
		var/preview_eval_hover_total_ds = diagnostics["preview_eval_hover_total_ds"] || 0
		var/preview_eval_hover_peak_ds = diagnostics["preview_eval_hover_peak_ds"] || 0
		var/preview_eval_click_total_ds = diagnostics["preview_eval_click_total_ds"] || 0
		var/preview_eval_click_peak_ds = diagnostics["preview_eval_click_peak_ds"] || 0
		var/preview_shape_contract_peak_ds = diagnostics["preview_shape_contract_peak_ds"] || 0
		var/preview_model_build_peak_ds = diagnostics["preview_model_build_peak_ds"] || 0
		var/preview_render_token_peak_ds = diagnostics["preview_render_token_peak_ds"] || 0
		var/preview_render_total_ds = diagnostics["preview_render_total_ds"] || 0
		var/preview_render_peak_ds = diagnostics["preview_render_peak_ds"] || 0
		var/preview_render_clear_peak_ds = diagnostics["preview_render_clear_peak_ds"] || 0
		var/preview_render_groups_peak_ds = diagnostics["preview_render_groups_peak_ds"] || 0
		var/preview_render_specs_peak_ds = diagnostics["preview_render_specs_peak_ds"] || 0
		var/preview_render_attach_peak_ds = diagnostics["preview_render_attach_peak_ds"] || 0
		var/ui_data_total_ds = diagnostics["ui_data_total_ds"] || 0
		var/ui_data_peak_ds = diagnostics["ui_data_peak_ds"] || 0
		var/tgui_update_messages = diagnostics["tgui_update_messages"] || 0
		var/tgui_update_encode_peak_ds = diagnostics["tgui_update_encode_peak_ds"] || 0
		var/tgui_update_output_peak_ds = diagnostics["tgui_update_output_peak_ds"] || 0
		var/tgui_update_bytes_last = diagnostics["tgui_update_bytes_last"] || 0
		var/tgui_update_bytes_peak = diagnostics["tgui_update_bytes_peak"] || 0
		var/last_slow_stage = diagnostics["last_slow_stage"]
		var/last_slow_duration_ds = diagnostics["last_slow_duration_ds"] || 0
		var/elapsed_seconds = round(max(0, world.time - started_at_ds) / 10, 1)
		entries += list(
			list("label" = "Session", "value" = "[elapsed_seconds]s"),
			list("label" = "Hover preview", "value" = "[hover_preview_requests]"),
			list("label" = "Hover resolve", "value" = "[hover_resolve_calls]"),
			list("label" = "Hover plan skip", "value" = "[hover_plan_skips]"),
			list("label" = "Preview defer", "value" = "[preview_plan_defers]"),
			list("label" = "Click resolve", "value" = "[click_resolve_calls]"),
			list("label" = "Apply plan", "value" = "[deferred_apply_plan_builds]"),
			list("label" = "Cache", "value" = "[resolve_cache_hits]/[resolve_cache_misses]"),
			list("label" = "Clamp tries", "value" = "[preview_endpoint_clamp_attempts]"),
			list("label" = "Clamp ok", "value" = "[preview_endpoint_clamp_successes]"),
			list("label" = "Clamp hover skip", "value" = "[preview_endpoint_clamp_hover_skips]"),
			list("label" = "Render rebuilds", "value" = "[preview_image_rebuilds]"),
			list("label" = "Render skips", "value" = "[preview_render_skips]"),
			list("label" = "Image new", "value" = "[preview_image_creations]"),
			list("label" = "Image reuse", "value" = "[preview_image_reuses]"),
			list("label" = "Images", "value" = "[preview_images_last]/[preview_images_peak]"),
			list("label" = "Hover eval", "value" = "[format_runtime_diagnostic_duration(preview_eval_hover_total_ds)]/[format_runtime_diagnostic_duration(preview_eval_hover_peak_ds)]"),
			list("label" = "Click eval", "value" = "[format_runtime_diagnostic_duration(preview_eval_click_total_ds)]/[format_runtime_diagnostic_duration(preview_eval_click_peak_ds)]"),
			list("label" = "Render time", "value" = "[format_runtime_diagnostic_duration(preview_render_total_ds)]/[format_runtime_diagnostic_duration(preview_render_peak_ds)]"),
			list("label" = "UI data", "value" = "[format_runtime_diagnostic_duration(ui_data_total_ds)]/[format_runtime_diagnostic_duration(ui_data_peak_ds)]"),
			list("label" = "TGUI encode", "value" = "[tgui_update_messages]x/[format_runtime_diagnostic_duration(tgui_update_encode_peak_ds)]"),
			list("label" = "TGUI output", "value" = "[tgui_update_messages]x/[format_runtime_diagnostic_duration(tgui_update_output_peak_ds)]"),
			list("label" = "TGUI bytes", "value" = "[tgui_update_bytes_last]/[tgui_update_bytes_peak]"),
		)
		if(preview_shape_contract_peak_ds > 0)
			entries += list(list("label" = "Shape build", "value" = "[format_runtime_diagnostic_duration(preview_shape_contract_peak_ds)]"))
		if(preview_model_build_peak_ds > 0)
			entries += list(list("label" = "Preview model", "value" = "[format_runtime_diagnostic_duration(preview_model_build_peak_ds)]"))
		if(preview_render_token_peak_ds > 0)
			entries += list(list("label" = "Render token", "value" = "[format_runtime_diagnostic_duration(preview_render_token_peak_ds)]"))
		if(preview_render_clear_peak_ds > 0)
			entries += list(list("label" = "Render clear", "value" = "[format_runtime_diagnostic_duration(preview_render_clear_peak_ds)]"))
		if(preview_render_groups_peak_ds > 0)
			entries += list(list("label" = "Render groups", "value" = "[format_runtime_diagnostic_duration(preview_render_groups_peak_ds)]"))
		if(preview_render_specs_peak_ds > 0)
			entries += list(list("label" = "Render specs", "value" = "[format_runtime_diagnostic_duration(preview_render_specs_peak_ds)]"))
		if(preview_render_attach_peak_ds > 0)
			entries += list(list("label" = "Render attach", "value" = "[format_runtime_diagnostic_duration(preview_render_attach_peak_ds)]"))
		if(length("[last_slow_stage]"))
			entries += list(
				list("label" = "Slow stage", "value" = "[last_slow_stage]"),
				list("label" = "Slow time", "value" = "[format_runtime_diagnostic_duration(last_slow_duration_ds)]"),
			)

	if(islist(generator_entries))
		for(var/list/entry as anything in generator_entries)
			if(!islist(entry))
				continue
			var/label = "[entry["label"]]"
			if(!length(label))
				continue
			entries += list(list(
				"label" = label,
				"value" = "[entry["value"]]",
			))
	return entries
#endif

/datum/world_edit_manager/proc/get_last_resolved_placement_candidate(list/effective_params, datum/world_edit_shape_contract/shape_contract, turf/resolved_end_turf, hover_only = FALSE, turf/requested_end_turf = null, turf/seed_turf = null, turf/shape_origin_turf = null, list/collector_state_summary = null)
	var/datum/world_edit_placement_session/session = placement_session
	if(!istype(session))
		return null

	var/datum/world_edit_placement_candidate/candidate = session.last_resolved_candidate
	var/datum/world_edit_shape_contract/cached_shape_contract = candidate?.shape_contract
	if(!istype(candidate) || !istype(resolved_end_turf))
		return null
	if(session.last_resolved_candidate_hover_only != (hover_only ? TRUE : FALSE))
		return null

	var/params_signature = build_preview_params_signature(effective_params, FALSE)
	if(session.last_resolved_candidate_params_signature != params_signature)
		return null

	var/attempt_signature = build_shape_contract_attempt_signature(shape_contract)
	if(session.last_resolved_candidate_attempt_signature != attempt_signature)
		return null
	if(session.last_resolved_candidate_end_turf != resolved_end_turf)
		return null

	candidate.hover_only = hover_only ? TRUE : FALSE
	increment_runtime_diagnostic(hover_only ? "hover_resolve_calls" : "click_resolve_calls")
	candidate.runtime_params = islist(effective_params) ? effective_params.Copy() : list()
	if(istype(shape_contract) && !istype(candidate.plan) && islist(cached_shape_contract?.metadata))
		if(!islist(shape_contract.metadata))
			shape_contract.metadata = list()
		for(var/key in cached_shape_contract.metadata)
			shape_contract.metadata[key] = cached_shape_contract.metadata[key]
	candidate.shape_contract = shape_contract
	if(islist(collector_state_summary))
		candidate.collector_state_summary = collector_state_summary.Copy()
	if(!islist(candidate.placement_context))
		candidate.placement_context = list()
	candidate.placement_context["requested_end_turf"] = requested_end_turf || resolved_end_turf
	candidate.placement_context["resolved_end_turf"] = resolved_end_turf
	if(istype(seed_turf))
		candidate.placement_context["seed_turf"] = seed_turf
	if(istype(shape_origin_turf))
		candidate.placement_context["shape_origin_turf"] = shape_origin_turf
	update_placement_context_shape_metadata(candidate.placement_context, shape_contract)
	if(istype(candidate.plan))
		stamp_placement_plan_shape_metadata(candidate.plan, shape_contract, candidate.placement_context)
	return candidate

/datum/world_edit_manager/proc/cache_last_resolved_placement_candidate(datum/world_edit_placement_candidate/candidate, datum/world_edit_shape_contract/shape_contract = null)
	var/datum/world_edit_placement_session/session = placement_session
	if(!istype(session) || !istype(candidate) || !candidate.is_confirm_ready())
		return FALSE

	var/turf/resolved_end_turf = islist(candidate.placement_context) ? (candidate.placement_context["resolved_end_turf"] || candidate.placement_context["end_turf"]) : null
	if(!istype(resolved_end_turf))
		return FALSE

	session.last_resolved_candidate = candidate
	session.last_resolved_candidate_params_signature = build_preview_params_signature(candidate.runtime_params, FALSE)
	session.last_resolved_candidate_attempt_signature = build_shape_contract_attempt_signature(shape_contract || candidate.shape_contract)
	session.last_resolved_candidate_end_turf = resolved_end_turf
	session.last_resolved_candidate_hover_only = candidate.hover_only ? TRUE : FALSE
	return TRUE

/datum/world_edit_manager/proc/build_placement_preview_turf_signature(list/turfs)
	if(!islist(turfs) || !length(turfs))
		return "<empty>"

	var/list/turf_chunks = list()
	for(var/turf/target_turf as anything in turfs)
		if(!istype(target_turf))
			continue
		turf_chunks += GLOB.world_edit_helpers.turf_to_text(target_turf)

	if(!length(turf_chunks))
		return "<empty>"
	return md5(jointext(turf_chunks, ";"))

/datum/world_edit_manager/proc/build_placement_preview_layer_render_token(list/turfs, icon_state, color = null, alpha = null)
	var/turf_count = islist(turfs) ? length(turfs) : 0
	var/turf_signature = build_placement_preview_turf_signature(turfs)
	var/list/token_chunks = list(
		length("[icon_state]") ? "[icon_state]" : "greenOverlay",
		isnull(color) ? "" : "[color]",
		isnum(alpha) ? "[clamp(round(alpha), 0, 255)]" : "",
		"[turf_count]",
		turf_signature,
	)
	return jointext(token_chunks, "|")

/datum/world_edit_manager/proc/build_placement_preview_render_token(datum/world_edit_preview_model/preview_model)
	if(!istype(preview_model))
		return null

	var/object_preview_signature = GLOB.world_edit_helpers.build_preview_spec_signature(preview_model.generator_preview_object_specs)
	return jointext(list(
		isnull(preview_model.hover_preview_mode) ? "" : "[preview_model.hover_preview_mode]",
		build_placement_preview_layer_render_token(preview_model.anchor_turfs, "blueOverlay", "#78C8FF", 255),
		build_placement_preview_layer_render_token(preview_model.vertex_turfs, "blueOverlay", "#B8F3FF", 210),
		build_placement_preview_layer_render_token(preview_model.edge_turfs, "greenOverlay", "#4DE1C1", 190),
		build_placement_preview_layer_render_token(preview_model.closure_turfs, "redOverlay", "#FFB347", 180),
		build_placement_preview_layer_render_token(preview_model.final_turfs, "greenOverlay", "#8BFFB5", 120),
		build_placement_preview_layer_render_token(preview_model.guide_turfs, "blueOverlay", "#D7B8FF", 150),
		build_placement_preview_layer_render_token(preview_model.generator_effect_turfs, "redOverlay", "#FF6B6B", 110),
		object_preview_signature,
	), "||")

/datum/world_edit_manager/proc/build_preview_model_runtime_summary(datum/world_edit_preview_model/preview_model)
	if(!istype(preview_model))
		return "preview=0"

	var/mode_label = preview_model.hover_preview_mode || "-"
	return "mode=[mode_label] a=[length(preview_model.anchor_turfs)] v=[length(preview_model.vertex_turfs)] e=[length(preview_model.edge_turfs)] c=[length(preview_model.closure_turfs)] f=[length(preview_model.final_turfs)] g=[length(preview_model.guide_turfs)] eff=[length(preview_model.generator_effect_turfs)] obj=[length(preview_model.generator_preview_object_specs)]"

/datum/world_edit_manager/proc/refresh_candidate_preview_render_token(datum/world_edit_placement_candidate/candidate)
	if(!istype(candidate?.preview_model))
		return null

	var/token_started_at = REALTIMEOFDAY
	candidate.preview_render_token = build_placement_preview_render_token(candidate.preview_model)
	candidate.preview_model.preview_render_token = candidate.preview_render_token
	record_runtime_stage_duration("preview_render_token", "preview-token", token_started_at, build_preview_model_runtime_summary(candidate.preview_model))
	return candidate.preview_render_token

/datum/world_edit_manager/proc/get_compact_hover_preview_effect_turfs(datum/world_edit_placement_candidate/candidate)
	if(!istype(candidate?.preview_model))
		return list()

	var/list/effect_turfs = list()
	if(length(candidate.preview_model.final_turfs))
		effect_turfs = candidate.preview_model.final_turfs
	else if(length(candidate.preview_model.edge_turfs))
		effect_turfs = candidate.preview_model.edge_turfs
	else if(length(candidate.preview_model.vertex_turfs))
		effect_turfs = candidate.preview_model.vertex_turfs
	else if(length(candidate.preview_model.anchor_turfs))
		effect_turfs = candidate.preview_model.anchor_turfs
	else if(istype(candidate.shape_contract))
		effect_turfs = candidate.shape_contract.copy_anchor_turfs()

	return GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(effect_turfs)

/datum/world_edit_manager/proc/apply_hover_preview_presentation_mode(datum/world_edit_placement_candidate/candidate)
	if(!istype(candidate?.preview_model) || !candidate.hover_only)
		return

	if(length(candidate.preview_model.generator_preview_object_specs))
		candidate.preview_model.hover_preview_mode = WORLD_EDIT_HOVER_PREVIEW_MODE_GHOST
	else
		candidate.preview_model.hover_preview_mode = WORLD_EDIT_HOVER_PREVIEW_MODE_COMPACT
		if(!length(candidate.preview_model.generator_effect_turfs))
			candidate.preview_model.generator_effect_turfs = get_compact_hover_preview_effect_turfs(candidate)

	refresh_candidate_preview_render_token(candidate)

/datum/world_edit_manager/proc/build_placement_candidate(datum/world_edit_shape_contract/shape_contract, list/placement_context, datum/world_edit_plan/plan = null, list/runtime_params = null, hover_only = FALSE, list/collector_state_summary = null)
	if(!istype(shape_contract))
		return null

	var/datum/world_edit_placement_candidate/candidate = new
	candidate.hover_only = hover_only ? TRUE : FALSE
	candidate.shape_contract = shape_contract
	var/model_started_at = REALTIMEOFDAY
	candidate.preview_model = GLOB.world_edit_shape_preview.build_shape_preview(shape_contract)
	record_runtime_stage_duration("preview_model_build", "preview-model", model_started_at, "shape=[shape_contract.shape_id] anchors=[length(shape_contract.anchor_turfs)]")
	candidate.plan = plan
	candidate.runtime_params = islist(runtime_params) ? runtime_params.Copy() : list()
	candidate.placement_context = islist(placement_context) ? placement_context.Copy() : list()
	update_placement_context_shape_metadata(candidate.placement_context, shape_contract)
	if(islist(collector_state_summary))
		candidate.collector_state_summary = collector_state_summary.Copy()
	if(istype(candidate.preview_model))
		if(istype(plan))
			candidate.preview_model.generator_effect_turfs = get_safe_placement_generator_effect_turfs(plan)
			candidate.preview_model.generator_preview_object_specs = current_generator?.build_plan_preview_object_specs(plan, candidate.runtime_params, candidate.placement_context, hover_only)
		if(hover_only)
			apply_hover_preview_presentation_mode(candidate)
		else
			refresh_candidate_preview_render_token(candidate)
	return candidate

/datum/world_edit_manager/proc/stamp_placement_plan_shape_metadata(datum/world_edit_plan/plan, datum/world_edit_shape_contract/shape_contract, list/placement_context)
	if(!istype(plan))
		return null

	current_generator?.stamp_plan_shape_metadata(plan, shape_contract, placement_context)
	update_placement_context_shape_metadata(placement_context, shape_contract)
	return plan

/datum/world_edit_manager/proc/populate_resolved_placement_candidate_plan(mob/user, datum/world_edit_placement_candidate/candidate, list/effective_params = null, hover_only = FALSE)
	if(!istype(candidate) || !current_generator)
		return candidate
	if(length("[candidate.support_error]") || length("[candidate.resolve_error]") || istype(candidate.plan))
		return candidate

	var/datum/world_edit_shape_contract/shape_contract = candidate.shape_contract
	if(!istype(shape_contract))
		candidate.resolve_error = "Не удалось определить контур размещения."
		return candidate

	if(!islist(candidate.placement_context))
		candidate.placement_context = list()
	update_placement_context_shape_metadata(candidate.placement_context, shape_contract)

	var/list/runtime_params = islist(effective_params) ? effective_params.Copy() : (islist(candidate.runtime_params) ? candidate.runtime_params.Copy() : list())
	candidate.runtime_params = runtime_params.Copy()

	var/list/support_result = current_generator.evaluate_shape_contract(shape_contract, runtime_params, candidate.placement_context)
	var/datum/world_edit_plan/prebuilt_plan = null
	if(islist(support_result))
		var/list/support_metadata = support_result["metadata"]
		if(islist(support_metadata))
			for(var/key in support_metadata)
				shape_contract.metadata[key] = support_metadata[key]
			update_placement_context_shape_metadata(candidate.placement_context, shape_contract)
		candidate.support_error = support_result["error"]
		prebuilt_plan = support_result["plan"]
	else
		candidate.support_error = support_result
	if(length("[candidate.support_error]"))
		return candidate

	var/datum/world_edit_plan/plan = istype(prebuilt_plan) ? prebuilt_plan : current_generator.build_plan_from_shape_contract(user, shape_contract, runtime_params, candidate.placement_context)
	if(!istype(plan))
		candidate.resolve_error = "Не удалось построить план размещения."
		return candidate

	candidate.plan = plan
	current_generator.finalize_shared_placement_plan_metadata(plan, shape_contract, candidate.placement_context)
	if(plan.metadata["error"])
		candidate.resolve_error = "[plan.metadata["error"]]"
		return candidate
	if(!length(plan.placements) && !length(plan.deletions))
		candidate.resolve_error = "План размещения пуст."
		return candidate
	if(istype(candidate.preview_model))
		candidate.preview_model.generator_effect_turfs = get_safe_placement_generator_effect_turfs(plan)
		candidate.preview_model.generator_preview_object_specs = current_generator?.build_plan_preview_object_specs(plan, runtime_params, candidate.placement_context, hover_only)
		if(hover_only)
			apply_hover_preview_presentation_mode(candidate)
		else
			refresh_candidate_preview_render_token(candidate)
	return candidate

/datum/world_edit_manager/proc/build_safe_placement_plan_from_shape_result(mob/user, shape_id, list/shape_result, turf/start_turf, turf/end_turf, list/shape_metadata_override = null)
	var/datum/world_edit_shape_contract/shape_contract = GLOB.world_edit_shape_geometry.build_shape_contract_from_result(shape_id, shape_result)
	if(islist(shape_metadata_override))
		if(!islist(shape_contract.metadata))
			shape_contract.metadata = list()
		for(var/key in shape_metadata_override)
			shape_contract.metadata[key] = shape_metadata_override[key]

	var/list/placement_context = build_placement_context(shape_contract, start_turf, end_turf, end_turf, start_turf, start_turf, get_effective_placement_dir())
	var/datum/world_edit_plan/plan = current_generator?.build_plan_from_shape_contract(user, shape_contract, build_effective_generator_params(null, shape_id), placement_context)
	stamp_placement_plan_shape_metadata(plan, shape_contract, placement_context)
	return plan

/datum/world_edit_manager/proc/get_safe_placement_generator_effect_turfs(datum/world_edit_plan/plan)
	if(!istype(plan))
		return list()

	var/list/metadata = plan.metadata
	if(islist(metadata) && islist(metadata["generator_effect_turfs"]))
		return GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(metadata["generator_effect_turfs"])
	return GLOB.world_edit_placement_shapes.world_edit_unique_turf_list(plan.affected_turfs)

/datum/world_edit_manager/proc/render_safe_placement_preview(datum/world_edit_placement_candidate/candidate)
	var/render_started_at = REALTIMEOFDAY
	increment_runtime_diagnostic("preview_render_calls")
	append_runtime_trace("render:start", "candidate=[candidate ? TRUE : FALSE] images=[length(preview_images)] [build_runtime_trace_gc_snapshot_if_enabled()]")
	var/incoming_render_token = length("[candidate?.preview_render_token]") ? "[candidate.preview_render_token]" : (length("[candidate?.preview_model?.preview_render_token]") ? "[candidate.preview_model.preview_render_token]" : null)
	var/reused_preview_state = FALSE
	if(length("[incoming_render_token]") && incoming_render_token == placement_preview_render_token)
		update_placement_preview_candidate_state(candidate, TRUE)
		reused_preview_state = TRUE
		if(preview_groups_signature == incoming_render_token)
			increment_runtime_diagnostic("preview_render_skips")
			record_runtime_diagnostic_duration("preview_render", render_started_at)
			append_runtime_trace("render:skip", "reason=token-match token_len=[length(incoming_render_token)] token_hash=[md5(incoming_render_token)]")
			return
	if(!reused_preview_state)
		store_placement_preview_candidate(candidate)
	if(!holder)
		record_runtime_diagnostic_duration("preview_render", render_started_at)
		append_runtime_trace("render:no-holder")
		return
	var/render_token = length("[placement_preview_render_token]") ? "[placement_preview_render_token]" : null
	if(preview_groups_signature == render_token && length("[render_token]"))
		increment_runtime_diagnostic("preview_render_skips")
		record_runtime_diagnostic_duration("preview_render", render_started_at)
		append_runtime_trace("render:skip", "reason=group-signature token_len=[length(render_token)] token_hash=[md5(render_token)]")
		return

	var/previous_image_count = length(preview_images)
	var/clear_started_at = REALTIMEOFDAY
	clear_preview_images()
	record_runtime_stage_duration("preview_render_clear", "render-clear", clear_started_at, "old_images=[previous_image_count]")

	var/groups_started_at = REALTIMEOFDAY
	var/list/images = GLOB.world_edit_helpers.build_grouped_turf_preview_images(get_placement_preview_groups())
	record_runtime_stage_duration("preview_render_groups", "render-groups", groups_started_at, "group_images=[length(images)]")

	var/list/object_specs = candidate?.preview_model?.generator_preview_object_specs
	if(islist(object_specs) && length(object_specs))
		var/specs_started_at = REALTIMEOFDAY
		images += GLOB.world_edit_helpers.build_preview_images_from_specs(object_specs)
		record_runtime_stage_duration("preview_render_specs", "render-specs", specs_started_at, "specs=[length(object_specs)] total_images=[length(images)]")

	var/attach_started_at = REALTIMEOFDAY
	if(length(images))
		holder.images += images
		preview_images = images.Copy()
		increment_runtime_diagnostic("preview_image_creations", length(images))
	record_runtime_stage_duration("preview_render_attach", "render-attach", attach_started_at, "images=[length(images)]")
	increment_runtime_diagnostic("preview_image_rebuilds")
	get_runtime_diagnostics()["preview_images_last"] = length(images)
	set_runtime_diagnostic_peak("preview_images_peak", length(images))
	preview_groups_signature = render_token || GLOB.world_edit_helpers.build_grouped_turf_preview_signature(get_placement_preview_groups())
	record_runtime_diagnostic_duration("preview_render", render_started_at)
	var/render_token_hash = length(render_token) ? md5(render_token) : "<empty>"
	append_runtime_trace("render:done", "mode=grouped specs=[length(object_specs)] images=[length(images)] token_len=[length(render_token)] token_hash=[render_token_hash]")

/datum/world_edit_manager/proc/render_plan_preview_with_placement_layers(mob/user, datum/world_edit_plan/plan, list/effective_params = null)
	var/datum/world_edit_placement_candidate/candidate = build_placement_candidate_from_plan(plan, effective_params, user)
	if(!istype(candidate))
		return FALSE
	render_safe_placement_preview(candidate)
	return TRUE

/datum/world_edit_manager/proc/set_safe_placement_preview_feedback(success, message, list/meta = null, mark_valid = FALSE)
	last_preview_success = success ? TRUE : FALSE
	last_preview_message = "[message]"
	last_preview_meta = sanitize_preview_feedback_meta(meta)
	if(success)
		last_ui_error = ""
	if(mark_valid)
		mark_preview_state()
	else
		invalidate_preview_state()

/datum/world_edit_manager/proc/resolve_placement_candidate_from_shape_contract(mob/user, datum/world_edit_shape_contract/shape_contract, turf/start_turf, turf/end_turf, list/effective_params, effective_direction, hover_only = FALSE, list/shape_metadata_override = null, list/collector_state_summary = null, turf/requested_end_turf = null, turf/seed_turf = null, turf/shape_origin_turf = null)
	var/datum/world_edit_placement_candidate/candidate = new
	candidate.hover_only = hover_only ? TRUE : FALSE
	increment_runtime_diagnostic(hover_only ? "hover_resolve_calls" : "click_resolve_calls")
	if(!istype(shape_contract))
		candidate.resolve_error = "Не удалось построить контракт формы для размещения."
		return candidate

	apply_shape_contract_runtime_metadata(shape_contract, shape_metadata_override, collector_state_summary)
	var/datum/world_edit_placement_candidate/cached_candidate = get_last_resolved_placement_candidate(
		effective_params,
		shape_contract,
		end_turf,
		hover_only,
		requested_end_turf || end_turf,
		seed_turf,
		shape_origin_turf,
		collector_state_summary,
	)
	if(istype(cached_candidate))
		increment_runtime_diagnostic("resolve_cache_hits")
		return cached_candidate
	increment_runtime_diagnostic("resolve_cache_misses")

	var/list/placement_context = build_placement_context(shape_contract, start_turf, end_turf, requested_end_turf || end_turf, seed_turf, shape_origin_turf, effective_direction)
	candidate = build_placement_candidate(shape_contract, placement_context, null, effective_params, hover_only, collector_state_summary)
	if(!istype(candidate))
		candidate = new
		candidate.hover_only = hover_only ? TRUE : FALSE
		candidate.resolve_error = "Не удалось подготовить кандидата размещения."
		return candidate

	if(shape_contract.error)
		candidate.resolve_error = "[shape_contract.error]"
		return candidate
	if(!length(shape_contract.anchor_turfs))
		candidate.resolve_error = "Недопустимый контур размещения."
		return candidate

	var/skip_plan_build = current_generator?.should_skip_plan_build_for_safe_preview(shape_contract, effective_params, candidate.placement_context, hover_only)
	if(skip_plan_build && should_build_hover_object_preview_plan(shape_contract, effective_params, candidate.placement_context, hover_only))
		skip_plan_build = FALSE
		candidate.placement_context["hover_object_preview"] = TRUE
		increment_runtime_diagnostic("hover_object_plan_builds")
	if(skip_plan_build)
		mark_shape_contract_preview_deferred(shape_contract, candidate.placement_context)
		update_placement_context_shape_metadata(candidate.placement_context, shape_contract)
		apply_hover_preview_presentation_mode(candidate)
		increment_runtime_diagnostic("preview_plan_defers")
		if(hover_only)
			increment_runtime_diagnostic("hover_plan_skips")
		return candidate

	populate_resolved_placement_candidate_plan(user, candidate, effective_params, hover_only)
	if(istype(candidate.plan) || length("[candidate.get_failure_message()]"))
		cache_last_resolved_placement_candidate(candidate, shape_contract)
		return candidate

	var/list/support_result = current_generator.evaluate_shape_contract(shape_contract, effective_params, candidate.placement_context)
	var/datum/world_edit_plan/prebuilt_plan = null
	if(islist(support_result))
		var/list/support_metadata = support_result["metadata"]
		if(islist(support_metadata))
			for(var/key in support_metadata)
				shape_contract.metadata[key] = support_metadata[key]
			update_placement_context_shape_metadata(candidate.placement_context, shape_contract)
		candidate.support_error = support_result["error"]
		prebuilt_plan = support_result["plan"]
	else
		candidate.support_error = support_result
	if(length("[candidate.support_error]"))
		return candidate

	var/datum/world_edit_plan/plan = istype(prebuilt_plan) ? prebuilt_plan : current_generator.build_plan_from_shape_contract(user, shape_contract, effective_params, candidate.placement_context)
	if(!istype(plan))
		candidate.resolve_error = "Не удалось построить план размещения."
		return candidate
	candidate.plan = plan
	current_generator.finalize_shared_placement_plan_metadata(plan, shape_contract, candidate.placement_context)
	if(plan.metadata["error"])
		candidate.resolve_error = "[plan.metadata["error"]]"
		return candidate
	if(!length(plan.placements) && !length(plan.deletions))
		candidate.resolve_error = "План размещения пуст."
		return candidate
	if(istype(candidate.preview_model))
		candidate.preview_model.generator_effect_turfs = get_safe_placement_generator_effect_turfs(plan)
		candidate.preview_model.generator_preview_object_specs = current_generator?.build_plan_preview_object_specs(plan, effective_params, candidate.placement_context, hover_only)
		if(hover_only)
			apply_hover_preview_presentation_mode(candidate)
		else
			refresh_candidate_preview_render_token(candidate)
	cache_last_resolved_placement_candidate(candidate, shape_contract)
	return candidate

/datum/world_edit_manager/proc/should_build_hover_object_preview_plan(datum/world_edit_shape_contract/shape_contract, list/effective_params = null, list/placement_context = null, hover_only = FALSE)
	if(!hover_only || !current_generator)
		return FALSE
	if(!istype(shape_contract) || length("[shape_contract.error]"))
		return FALSE
	if(!current_generator.should_build_hover_object_preview_plan(shape_contract, effective_params, placement_context))
		return FALSE

	var/anchor_limit = max(0, current_generator.get_hover_object_preview_anchor_limit())
	var/anchor_count = length(shape_contract.anchor_turfs)
	if(anchor_limit > 0 && anchor_count > anchor_limit)
		increment_runtime_diagnostic("hover_object_plan_anchor_skips")
		return FALSE

	var/min_interval_ds = max(0, current_generator.get_hover_object_preview_min_interval_ds())
	if(min_interval_ds > 0)
		var/datum/world_edit_placement_session/session = get_placement_session()
		if(session.hover_object_preview_next_allowed_ds > world.time)
			increment_runtime_diagnostic("hover_object_plan_throttle_skips")
			return FALSE
		session.hover_object_preview_next_allowed_ds = world.time + min_interval_ds
	return TRUE

/datum/world_edit_manager/proc/resolve_placement_candidate(mob/user, turf/start_turf, turf/end_turf, list/runtime_params = null, hover_only = FALSE, list/shape_metadata_override = null, list/collector_state_summary = null, shape_id_override = null, turf/requested_end_turf = null, turf/seed_turf = null, turf/shape_origin_turf = null)
	if(!current_generator)
		var/datum/world_edit_placement_candidate/candidate = new
		candidate.hover_only = hover_only ? TRUE : FALSE
		candidate.resolve_error = "Генератор не активен."
		return candidate

	var/shape_id = shape_id_override || get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT
	var/effective_direction = supports_current_placement_direction() ? get_effective_placement_dir() : NORTH
	var/list/effective_params = islist(runtime_params) ? runtime_params.Copy() : build_effective_generator_params(null, shape_id)
	var/shape_contract_started_at = REALTIMEOFDAY
	var/datum/world_edit_shape_contract/shape_contract = GLOB.world_edit_shape_geometry.build_shape_contract(shape_id, start_turf, end_turf, effective_params, effective_direction)
	record_runtime_stage_duration("preview_shape_contract", "shape-contract", shape_contract_started_at, "shape=[shape_id] start=[GLOB.world_edit_helpers.turf_to_text(start_turf)] end=[GLOB.world_edit_helpers.turf_to_text(end_turf)]")
	return resolve_placement_candidate_from_shape_contract(user, shape_contract, start_turf, end_turf, effective_params, effective_direction, hover_only, shape_metadata_override, collector_state_summary, requested_end_turf, seed_turf, shape_origin_turf)

/datum/world_edit_manager/proc/can_attempt_preview_endpoint_clamp(shape_id, turf/start_turf, turf/requested_end_turf, turf/segment_start_turf = null, list/runtime_params = null, list/placement_context = null)
	if(!istype(start_turf) || !istype(requested_end_turf))
		return FALSE
	if(!current_generator?.should_attempt_preview_endpoint_clamp(shape_id, start_turf, requested_end_turf, segment_start_turf, runtime_params, placement_context))
		return FALSE

	segment_start_turf = segment_start_turf || start_turf
	if(!istype(segment_start_turf) || segment_start_turf == requested_end_turf)
		return FALSE
	return TRUE

/datum/world_edit_manager/proc/resolve_placement_candidate_with_optional_endpoint_clamp(mob/user, turf/start_turf, turf/end_turf, list/runtime_params = null, hover_only = FALSE, list/shape_metadata_override = null, list/collector_state_summary = null, shape_id_override = null, turf/requested_end_turf = null, turf/seed_turf = null, turf/shape_origin_turf = null, turf/segment_start_turf = null)
	var/requested_shape_id = shape_id_override || get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT
	var/turf/requested_turf = requested_end_turf || end_turf
	var/can_attempt_clamp = can_attempt_preview_endpoint_clamp(requested_shape_id, start_turf, requested_turf, segment_start_turf, runtime_params)
	var/datum/world_edit_placement_candidate/candidate = resolve_placement_candidate(
		user,
		start_turf,
		end_turf,
		runtime_params,
		hover_only,
		shape_metadata_override,
		collector_state_summary,
		requested_shape_id,
		requested_turf,
		seed_turf,
		shape_origin_turf,
	)
	if(!istype(candidate))
		return candidate
	if(candidate.is_confirm_ready() && !length("[candidate.get_failure_message()]"))
		return candidate
	// Hover previews must stay cheap: endpoint clamp can retry many shorter shapes and
	// explode into repeated full plan builds while the cursor is moving.
	if(hover_only)
		if(can_attempt_clamp)
			increment_runtime_diagnostic("preview_endpoint_clamp_hover_skips")
		return candidate
	if(!can_attempt_clamp)
		return candidate

	segment_start_turf = segment_start_turf || start_turf
	var/list/segment_turfs = GLOB.world_edit_helpers.collect_line_turfs(segment_start_turf, requested_turf)
	if(!islist(segment_turfs) || length(segment_turfs) <= 1)
		return candidate

	var/effective_direction = supports_current_placement_direction() ? get_effective_placement_dir() : NORTH
	var/list/effective_params = islist(runtime_params) ? runtime_params.Copy() : build_effective_generator_params(null, requested_shape_id)
	var/list/attempted_signatures = list()
	var/max_clamp_attempts = max(0, current_generator?.get_preview_endpoint_clamp_attempt_limit() || 0)
	if(max_clamp_attempts <= 0)
		return candidate
	var/clamp_attempt_count = 0
	for(var/i = length(segment_turfs) - 1, i >= 1, i--)
		if(clamp_attempt_count >= max_clamp_attempts)
			break
		var/turf/clamped_end_turf = segment_turfs[i]
		if(!istype(clamped_end_turf) || clamped_end_turf == requested_turf || clamped_end_turf == segment_start_turf)
			continue

		var/datum/world_edit_shape_contract/clamped_shape_contract = GLOB.world_edit_shape_geometry.build_shape_contract(requested_shape_id, start_turf, clamped_end_turf, effective_params, effective_direction)
		var/attempt_signature = build_shape_contract_attempt_signature(clamped_shape_contract)
		if(length(attempt_signature))
			if(attempted_signatures[attempt_signature])
				continue
			attempted_signatures[attempt_signature] = TRUE

		clamp_attempt_count++
		increment_runtime_diagnostic("preview_endpoint_clamp_attempts")
		var/datum/world_edit_placement_candidate/clamped_candidate = resolve_placement_candidate_from_shape_contract(
			user,
			clamped_shape_contract,
			start_turf,
			clamped_end_turf,
			effective_params,
			effective_direction,
			hover_only,
			shape_metadata_override,
			collector_state_summary,
			requested_turf,
			seed_turf,
			shape_origin_turf,
		)
		if(!istype(clamped_candidate) || !clamped_candidate.is_confirm_ready() || length("[clamped_candidate.get_failure_message()]"))
			continue
		if(!islist(clamped_candidate.placement_context))
			clamped_candidate.placement_context = list()
		clamped_candidate.placement_context["clamp_reason"] = "endpoint"
		clamped_candidate.placement_context["requested_end_turf"] = requested_turf
		clamped_candidate.placement_context["resolved_end_turf"] = clamped_end_turf
		if(istype(clamped_candidate.plan))
			stamp_placement_plan_shape_metadata(clamped_candidate.plan, clamped_candidate.shape_contract, clamped_candidate.placement_context)
		increment_runtime_diagnostic("preview_endpoint_clamp_successes")
		return clamped_candidate

	return candidate

/datum/world_edit_manager/proc/evaluate_safe_placement_preview(mob/user, shape_id, turf/start_turf, turf/end_turf, list/shape_metadata_override = null, message_prefix = "", silent = FALSE, hover_only = FALSE)
	var/preview_started_at = REALTIMEOFDAY
	var/success = FALSE
	append_runtime_trace(
		hover_only ? "preview:hover:start" : "preview:click:start",
		"shape=[shape_id] start=[GLOB.world_edit_helpers.turf_to_text(start_turf)] end=[GLOB.world_edit_helpers.turf_to_text(end_turf)]",
	)
	set_placement_hover_turf(end_turf)
	if(hover_only)
		increment_runtime_diagnostic("hover_preview_requests")
	var/list/effective_params = build_effective_generator_params(null, shape_id)
	var/datum/world_edit_placement_candidate/candidate = resolve_placement_candidate_with_optional_endpoint_clamp(user, start_turf, end_turf, effective_params, hover_only, shape_metadata_override, null, shape_id, end_turf, start_turf, start_turf, start_turf)
	render_safe_placement_preview(candidate)
	var/failure_message = candidate.get_failure_message()
	var/preview_ready_for_stage = hover_only ? !length("[failure_message]") : candidate.is_confirm_ready()
	if(length("[failure_message]") || !preview_ready_for_stage)
		if(!length("[failure_message]"))
			failure_message = "Предпросмотр размещения ещё не готов."
		set_safe_placement_preview_feedback(FALSE, "[message_prefix][failure_message]", candidate.plan?.metadata || candidate.shape_contract?.metadata, FALSE)
		if(!silent)
			to_chat(user, SPAN_WARNING(last_preview_message))
		append_runtime_trace(hover_only ? "preview:hover:fail" : "preview:click:fail", "message=[failure_message]")
	else
		var/list/preview_feedback_meta = candidate.plan?.metadata || candidate.shape_contract?.metadata || list()
		set_safe_placement_preview_feedback(TRUE, "[message_prefix][build_safe_placement_preview_message(candidate.plan, preview_feedback_meta)]", preview_feedback_meta, hover_only ? FALSE : TRUE)
		if(!silent)
			to_chat(user, SPAN_NOTICE(last_preview_message))
		success = TRUE
		append_runtime_trace(
			hover_only ? "preview:hover:ok" : "preview:click:ok",
			"confirm_ready=[candidate.is_confirm_ready()] apply_ready=[candidate.is_ready_for_apply()] plan=[candidate.plan ? TRUE : FALSE] images=[length(preview_images)]",
		)
	record_runtime_diagnostic_duration(hover_only ? "preview_eval_hover" : "preview_eval_click", preview_started_at)
	return success

/datum/world_edit_manager/proc/apply_resolved_placement_candidate(mob/user, datum/world_edit_placement_candidate/candidate = null, force_confirm = FALSE, cancel_placement_on_confirm_reject = FALSE)
	candidate = candidate || get_placement_preview_candidate()
	if(istype(candidate) && !candidate.hover_only && !istype(candidate.plan) && current_generator?.should_skip_plan_build_for_safe_preview(candidate.shape_contract, candidate.runtime_params, candidate.placement_context, FALSE))
		increment_runtime_diagnostic("deferred_apply_plan_builds")
		populate_resolved_placement_candidate_plan(user, candidate, candidate.runtime_params, FALSE)
		if(length("[candidate.get_failure_message()]"))
			render_safe_placement_preview(candidate)
			set_safe_placement_preview_feedback(FALSE, "[candidate.get_failure_message()]", candidate.plan?.metadata || candidate.shape_contract?.metadata, FALSE)
			to_chat(user, SPAN_WARNING(last_preview_message))
			return TRUE
		cache_last_resolved_placement_candidate(candidate, candidate.shape_contract)
	if(!istype(candidate) || !candidate.is_ready_for_apply() || !is_preview_state_valid())
		to_chat(user, SPAN_WARNING("Предпросмотр размещения ещё не готов."))
		return TRUE

	var/datum/world_edit_plan/plan = candidate.plan
	if(force_confirm || confirm_before_apply)
		var/turf/confirm_turf = islist(candidate.placement_context) ? (candidate.placement_context["resolved_end_turf"] || candidate.placement_context["end_turf"]) : null
		var/confirm_text = build_safe_placement_confirm_text(plan)
		set_placement_preview_locked(TRUE, confirm_turf)
		var/answer = tgui_alert(user, confirm_text, "Панель размещения: подтверждение", list("Подтвердить", "Отмена"))
		if(answer != "Подтвердить")
			set_placement_preview_locked(FALSE, confirm_turf)
			if(cancel_placement_on_confirm_reject)
				return cancel_safe_placement_mode(user, "Размещение отменено пользователем.")
			arm_placement_confirm_for_turf(confirm_turf, candidate)
			return TRUE

	set_placement_preview_locked(FALSE)
	var/mode = get_effective_placement_mode()
	var/start_ds = world.time
	var/datum/world_edit_apply_result/result = current_generator.apply_built_plan(user, candidate.runtime_params, plan)
	if(!istype(result))
		teardown_preview_session_runtime()
		return fail_apply(user, "Генератор вернул некорректный результат применения.")

	record_apply_result(user, result, world.time - start_ds)
	teardown_preview_session_runtime()
	if(mode == "single")
		if(result.success)
			teardown_preview_session_runtime(TRUE, FALSE, FALSE, TRUE)
		else
			sync_click_intercept_state()
			placement_click_active = click_intercept_owned ? TRUE : FALSE
	else if(result.success)
		sync_click_intercept_state()
		placement_click_active = click_intercept_owned ? TRUE : FALSE
		teardown_preview_session_runtime(FALSE, TRUE, is_current_placement_collector())
		to_chat(user, SPAN_NOTICE("Режим размещения остаётся активным."))
	return TRUE

/datum/world_edit_manager/proc/apply_safe_placement_current_plan(mob/user, force_confirm = FALSE, cancel_placement_on_confirm_reject = FALSE)
	return apply_resolved_placement_candidate(user, get_placement_preview_candidate(), force_confirm, cancel_placement_on_confirm_reject)

/datum/world_edit_manager/proc/cancel_safe_placement_mode(mob/user, message = "Режим размещения остановлен.", cancel_reason = null)
	var/reason_text = length("[cancel_reason]") ? "[cancel_reason]" : ""
	reset_preview_runtime()
	if(!user)
		return TRUE
	if(length(reason_text))
		to_chat(user, SPAN_WARNING("Размещение отменено: [reason_text]"))
	else if(length("[message]"))
		to_chat(user, SPAN_NOTICE(message))
	return TRUE

/datum/world_edit_manager/proc/show_anchor_pair_preview(turf/anchor_turf, shape_id)
	teardown_preview_session_runtime()
	set_placement_anchor_turf(anchor_turf)
	set_placement_hover_turf(anchor_turf)
	var/list/effective_params = build_effective_generator_params(null, shape_id)
	var/datum/world_edit_shape_contract/shape_contract = GLOB.world_edit_shape_geometry.build_shape_contract(shape_id, anchor_turf, anchor_turf, effective_params, supports_current_placement_direction() ? get_effective_placement_dir() : NORTH)
	var/list/placement_context = build_placement_context(shape_contract, anchor_turf, anchor_turf, anchor_turf, anchor_turf, anchor_turf)
	var/datum/world_edit_placement_candidate/candidate = build_placement_candidate(shape_contract, placement_context, null, effective_params, TRUE)
	render_safe_placement_preview(candidate)

/datum/world_edit_manager/proc/rebuild_active_safe_placement_preview(mob/user, shape_id = null, turf/preview_turf = null, silent = TRUE, hover_only = TRUE, allow_anchor_placeholder = FALSE)
	shape_id = shape_id || get_effective_placement_shape()
	if(!length("[shape_id]"))
		return FALSE

	var/interaction_kind = get_placement_interaction_kind(shape_id)
	switch(interaction_kind)
		if("anchor_pair")
			if(!istype(placement_anchor_turf))
				return FALSE
			var/turf/effective_preview_turf = preview_turf || placement_hover_turf
			if(!istype(effective_preview_turf) || effective_preview_turf == placement_anchor_turf)
				if(!allow_anchor_placeholder)
					if(!istype(effective_preview_turf))
						return FALSE
					return evaluate_safe_placement_preview(user, shape_id, placement_anchor_turf, effective_preview_turf, null, "", silent, hover_only)
				if(istype(effective_preview_turf) && evaluate_safe_placement_preview(user, shape_id, placement_anchor_turf, effective_preview_turf, null, "", silent, hover_only))
					return TRUE
				show_anchor_pair_preview(placement_anchor_turf, shape_id)
				return TRUE
			return evaluate_safe_placement_preview(user, shape_id, placement_anchor_turf, effective_preview_turf, null, "", silent, hover_only)
		if("collector")
			if(!length(get_placement_collector_points()))
				return FALSE
			var/turf/effective_preview_turf = preview_turf || placement_hover_turf || get_placement_collector_origin_turf() || placement_anchor_turf
			if(!istype(effective_preview_turf))
				return FALSE
			return update_placement_collector_runtime_state(user, effective_preview_turf, "", silent, hover_only)
		if("single", "param_only")
			var/turf/effective_preview_turf = preview_turf || placement_hover_turf || placement_anchor_turf
			if(!istype(effective_preview_turf))
				return FALSE
			return evaluate_safe_placement_preview(user, shape_id, effective_preview_turf, effective_preview_turf, null, "", silent, hover_only)
	return FALSE

/datum/world_edit_manager/proc/handle_safe_placement_hover(mob/user, turf/hover_turf)
	if(!placement_click_active || !supports_current_placement_ux())
		return FALSE
	if(is_placement_preview_locked())
		return TRUE
	if(!istype(hover_turf))
		return FALSE
	if(holder != user?.client)
		return FALSE
	if(is_placement_confirm_armed_for_turf())
		return TRUE
	var/datum/world_edit_placement_candidate/current_candidate = get_placement_preview_candidate()
	var/current_candidate_signature = islist(current_candidate?.placement_context) ? current_candidate.placement_context["preview_signature"] : null
	if(hover_turf == placement_hover_turf && istype(current_candidate) && current_candidate.hover_only && current_candidate_signature == placement_preview_signature)
		return TRUE

	return rebuild_active_safe_placement_preview(user, null, hover_turf, TRUE, TRUE, FALSE)

/datum/world_edit_manager/proc/collector_first_point_click_finishes(shape_id)
	switch("[shape_id]")
		if(WORLD_EDIT_SHAPE_POLYGON, WORLD_EDIT_SHAPE_POLYLINE, WORLD_EDIT_SHAPE_BRUSH_PATH)
			return TRUE
	return FALSE

/datum/world_edit_manager/proc/collector_repeated_last_point_finishes(shape_id)
	switch("[shape_id]")
		if(WORLD_EDIT_SHAPE_POLYGON, WORLD_EDIT_SHAPE_POLYLINE, WORLD_EDIT_SHAPE_CUSTOM_MASK, WORLD_EDIT_SHAPE_BRUSH_PATH)
			return TRUE
	return FALSE

/datum/world_edit_manager/proc/reset_safe_placement_attempt(mob/user, message = "Текущая попытка размещения отменена.")
	teardown_preview_session_runtime(TRUE, TRUE, FALSE)
	set_safe_placement_preview_feedback(FALSE, "[message]", list(), FALSE)
	if(user)
		to_chat(user, SPAN_NOTICE(last_preview_message))
	return TRUE

/datum/world_edit_manager/proc/reset_safe_placement_collection_attempt(mob/user, message = "Сбор точек очищен.")
	teardown_preview_session_runtime(TRUE, TRUE, TRUE)
	set_safe_placement_preview_feedback(FALSE, "[message]", list(), FALSE)
	if(user)
		to_chat(user, SPAN_NOTICE(last_preview_message))
	return TRUE

/datum/world_edit_manager/proc/should_reset_failed_anchor_pair_same_tile_click(turf/start_turf, turf/clicked_turf)
	if(!istype(start_turf) || !istype(clicked_turf))
		return FALSE
	if(clicked_turf != start_turf)
		return FALSE
	if(is_placement_confirm_armed_for_turf(clicked_turf))
		return FALSE
	return TRUE

/datum/world_edit_manager/proc/arm_safe_placement_preview_for_confirm(mob/user, turf/confirm_turf = null)
	if(!arm_placement_confirm_for_turf(confirm_turf))
		return FALSE
	if(user)
		to_chat(user, SPAN_NOTICE("Предпросмотр закреплён. Нажмите ещё раз по этому тайлу для подтверждения."))
	return TRUE

/datum/world_edit_manager/proc/handle_repeated_safe_placement_confirm_click(mob/user, turf/confirm_turf = null)
	if(!is_placement_confirm_armed_for_turf(confirm_turf))
		return FALSE
	clear_placement_confirm_arm()
	return apply_safe_placement_current_plan(user, TRUE)

/datum/world_edit_manager/proc/handle_safe_placement_click(mob/user, params, atom/object)
	if(!placement_click_active || !supports_current_placement_ux())
		return FALSE
	if(is_placement_preview_locked())
		return TRUE

	var/list/modifiers = params2list(params)
	var/turf/clicked_turf = get_turf(object)
	if(!clicked_turf)
		return TRUE

	var/shape_id = get_effective_placement_shape()
	var/interaction_kind = get_placement_interaction_kind(shape_id)
	if(!length(shape_id))
		return TRUE

	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		return TRUE

	append_runtime_trace(
		"click:start",
		"shape=[shape_id] kind=[interaction_kind] turf=[GLOB.world_edit_helpers.turf_to_text(clicked_turf)] images=[length(preview_images)] [build_runtime_trace_gc_snapshot_if_enabled()]",
	)

	if(interaction_kind == "collector")
		var/list/collector_points = get_placement_collector_points()
		var/turf/origin_turf = get_placement_collector_origin_turf()
		if(!length(collector_points))
			set_placement_anchor_turf(clicked_turf)
			set_placement_hover_turf(clicked_turf)
			set_placement_collector_origin_turf(clicked_turf)
			set_placement_collector_points(list(list("x" = 0, "y" = 0)))
			update_placement_collector_runtime_state(user, clicked_turf, "Сбор начат. ", FALSE, FALSE)
			return TRUE

		if(!istype(origin_turf))
			origin_turf = placement_anchor_turf || clicked_turf
			set_placement_collector_origin_turf(origin_turf)
			set_placement_anchor_turf(origin_turf)
		if(handle_repeated_safe_placement_confirm_click(user, clicked_turf))
			return TRUE

		var/new_x = clicked_turf.x - origin_turf.x
		var/new_y = clicked_turf.y - origin_turf.y
		var/new_key = "[new_x],[new_y]"
		var/list/first_point = length(collector_points) ? collector_points[1] : null
		var/first_point_key = null
		if(islist(first_point))
			first_point_key = "[text2num("[first_point["x"]]")],[text2num("[first_point["y"]]")]"
		var/list/last_point = length(collector_points) ? collector_points[length(collector_points)] : null
		var/last_point_key = null
		if(islist(last_point))
			last_point_key = "[text2num("[last_point["x"]]")],[text2num("[last_point["y"]]")]"
		if(length(first_point_key) && new_key == first_point_key && collector_first_point_click_finishes(shape_id) && length(collector_points) >= get_placement_collector_min_points(shape_id))
			set_placement_anchor_turf(origin_turf)
			set_placement_hover_turf(clicked_turf)
			if(!prepare_finished_placement_collection_preview(user, clicked_turf))
				return TRUE
			if(!arm_safe_placement_preview_for_confirm(user))
				to_chat(user, SPAN_WARNING("Предпросмотр размещения ещё не готов."))
			return TRUE
		if(length(last_point_key) && new_key == last_point_key)
			if(length(collector_points) >= get_placement_collector_min_points(shape_id) && collector_repeated_last_point_finishes(shape_id))
				set_placement_anchor_turf(origin_turf)
				set_placement_hover_turf(clicked_turf)
				if(!prepare_finished_placement_collection_preview(user, clicked_turf))
					return TRUE
				if(!arm_safe_placement_preview_for_confirm(user))
					to_chat(user, SPAN_WARNING("Предпросмотр размещения ещё не готов."))
				return TRUE
			to_chat(user, SPAN_NOTICE("Эта точка уже последняя в контуре. Добавьте новую точку или завершите сбор."))
			return TRUE
		var/max_points = get_placement_collector_max_points(shape_id)
		if("[shape_id]" == WORLD_EDIT_SHAPE_CUSTOM_MASK)
			for(var/list/existing_point as anything in collector_points)
				var/existing_x = text2num("[existing_point["x"]]")
				var/existing_y = text2num("[existing_point["y"]]")
				if("[existing_x],[existing_y]" == new_key)
					to_chat(user, SPAN_NOTICE("Эта точка уже есть в маске."))
					return TRUE
		if(length(collector_points) >= max_points)
			to_chat(user, SPAN_WARNING("Достигнут безопасный лимит: [max_points] точек."))
			return TRUE

		var/list/proposed_points = GLOB.world_edit_placement_shapes.world_edit_copy_points(collector_points)
		proposed_points += list(list("x" = new_x, "y" = new_y))
		if(length(proposed_points) >= get_placement_collector_min_points(shape_id) && current_generator?.should_preview_collector_points_before_commit(shape_id, proposed_points))
			set_placement_anchor_turf(origin_turf)
			set_placement_hover_turf(clicked_turf)
			if(!update_placement_collector_runtime_state(user, clicked_turf, "Сбор обновлён. ", FALSE, FALSE, proposed_points))
				return TRUE

			var/datum/world_edit_placement_candidate/collector_candidate = get_placement_preview_candidate()
			var/list/resolved_points = null
			if(istype(collector_candidate?.shape_contract) && islist(collector_candidate.shape_contract.metadata))
				resolved_points = collector_candidate.shape_contract.metadata["normalized_points"]
			if(!islist(resolved_points) || !length(resolved_points))
				resolved_points = proposed_points
			var/turf/resolved_preview_turf = islist(collector_candidate?.placement_context) ? (collector_candidate.placement_context["resolved_end_turf"] || clicked_turf) : clicked_turf
			set_placement_anchor_turf(origin_turf)
			set_placement_hover_turf(resolved_preview_turf)
			set_placement_collector_points(resolved_points)
			mark_preview_state()
			return TRUE

		collector_points = proposed_points
		set_placement_anchor_turf(origin_turf)
		set_placement_hover_turf(clicked_turf)
		set_placement_collector_points(collector_points)
		update_placement_collector_runtime_state(user, clicked_turf, "Сбор обновлён. ", FALSE, FALSE)
		return TRUE

	if(interaction_kind == "anchor_pair" && !istype(placement_anchor_turf))
		append_runtime_trace("click:anchor-arm", "anchor=[GLOB.world_edit_helpers.turf_to_text(clicked_turf)]")
		show_anchor_pair_preview(clicked_turf, shape_id)
		to_chat(user, SPAN_NOTICE("Опорная точка выбрана: [clicked_turf.x],[clicked_turf.y],[clicked_turf.z]."))
		return TRUE

	var/turf/start_turf = (interaction_kind == "anchor_pair") ? placement_anchor_turf : clicked_turf
	var/turf/end_turf = clicked_turf
	if(interaction_kind == "anchor_pair")
		set_placement_hover_turf(clicked_turf)

	if(handle_repeated_safe_placement_confirm_click(user, clicked_turf))
		append_runtime_trace("click:confirm", "turf=[GLOB.world_edit_helpers.turf_to_text(clicked_turf)]")
		return TRUE

	append_runtime_trace("click:before-eval", "start=[GLOB.world_edit_helpers.turf_to_text(start_turf)] end=[GLOB.world_edit_helpers.turf_to_text(end_turf)]")
	if(!evaluate_safe_placement_preview(user, shape_id, start_turf, end_turf, null, "", FALSE, FALSE))
		if(interaction_kind == "anchor_pair")
			set_placement_anchor_turf(start_turf)
			if(should_reset_failed_anchor_pair_same_tile_click(start_turf, clicked_turf))
				return reset_safe_placement_attempt(user, "Текущая попытка размещения отменена: конечная точка совпала с опорной.")
		append_runtime_trace("click:preview-failed", "turf=[GLOB.world_edit_helpers.turf_to_text(clicked_turf)]")
		return TRUE

	if(!arm_safe_placement_preview_for_confirm(user))
		append_runtime_trace("click:arm-failed", "turf=[GLOB.world_edit_helpers.turf_to_text(clicked_turf)]")
		to_chat(user, SPAN_WARNING("Предпросмотр размещения ещё не готов."))
		return TRUE
	append_runtime_trace("click:armed", "turf=[GLOB.world_edit_helpers.turf_to_text(clicked_turf)]")
	return TRUE

/datum/world_edit_manager/proc/start_safe_placement_mode(mob/user)
	if(!holder || !check_rights_for(holder, R_DEBUG))
		return fail_apply(user, "Недостаточно прав для режима размещения в панели редактирования мира.")
	if(!current_generator || !current_definition)
		return fail_apply(user, "Сначала выберите генератор.")
	if(!supports_current_placement_ux())
		return fail_apply(user, "Для текущего генератора безопасный режим размещения сейчас недоступен.")

	var/shape_id = get_effective_placement_shape() || WORLD_EDIT_SHAPE_POINT
	var/interaction_kind = get_placement_interaction_kind(shape_id)
	var/placement_error_text = null
	if(interaction_kind != "collector")
		placement_error_text = current_generator.validate_params(user, build_effective_generator_params(null, shape_id))
	if(placement_error_text)
		return fail_apply(user, placement_error_text)
	if(!acquire_click_intercept("Безопасное размещение"))
		return fail_apply(user, "Перехват клика не активирован.")

	placement_click_active = TRUE
	teardown_preview_session_runtime(TRUE, TRUE, TRUE)
	reset_runtime_diagnostics()
	sync_click_intercept_state()

	var/shape_label = GLOB.world_edit_placement_shapes.world_edit_get_placement_shape_label(shape_id)
	var/dir_suffix = supports_current_placement_direction() ? " Направление: [GLOB.world_edit_helpers.dir_to_label(get_effective_placement_dir())]." : "."
	if(interaction_kind == "anchor_pair")
		to_chat(user, SPAN_NOTICE("Режим размещения для [shape_label] активен: первый ЛКМ ставит опорную точку, второй ЛКМ строит предпросмотр, повторный ЛКМ по тому же тайлу открывает подтверждение. Если контур из той же опорной точки невалиден, повторный ЛКМ по ней сбрасывает текущую попытку.[dir_suffix]"))
	else if(interaction_kind == "collector")
		to_chat(user, SPAN_NOTICE("Режим размещения для [shape_label] активен: ЛКМ добавляет точки, повторный ЛКМ по последней точке строит финальный предпросмотр, клик по первой точке тоже может замкнуть контур там, где это поддерживается, повторный ЛКМ по тому же тайлу открывает подтверждение. Кнопка завершения тоже работает.[dir_suffix]"))
	else if(interaction_kind == "param_only")
		to_chat(user, SPAN_NOTICE("Режим размещения для [shape_label] активен: ЛКМ использует выбранный тайл как опорную точку и строит контур по текущим параметрам формы, повторный ЛКМ по тому же тайлу открывает подтверждение. Интерактивный сбор точек в этом режиме не используется.[dir_suffix]"))
	else
		to_chat(user, SPAN_NOTICE("Режим размещения для [shape_label] активен: ЛКМ закрепляет предпросмотр по выбранному тайлу, повторный ЛКМ по тому же тайлу открывает подтверждение.[dir_suffix]"))
	return TRUE
