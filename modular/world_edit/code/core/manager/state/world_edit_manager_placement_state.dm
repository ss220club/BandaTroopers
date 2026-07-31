/datum/world_edit_manager/proc/is_safe_placement_mode_active()
	return (sync_click_intercept_state() && placement_click_active) ? TRUE : FALSE

/datum/world_edit_manager/proc/get_supported_placement_modes()
	var/list/modes = current_generator?.get_supported_placement_modes()
	if(!islist(modes))
		return list()
	return modes.Copy()

/datum/world_edit_manager/proc/get_supported_placement_shapes()
	var/list/shapes = current_generator?.get_supported_placement_shapes()
	if(!islist(shapes))
		return list()
	return shapes.Copy()

/datum/world_edit_manager/proc/supports_current_placement_ux()
	return (length(get_supported_placement_modes()) || length(get_supported_placement_shapes())) ? TRUE : FALSE

/datum/world_edit_manager/proc/supports_current_placement_direction()
	return current_generator?.supports_placement_direction() ? TRUE : FALSE

/datum/world_edit_manager/proc/resolve_supported_placement_mode(requested_mode = null)
	var/list/modes = get_supported_placement_modes()
	if(!length(modes))
		return null

	if(length("[requested_mode]") && (requested_mode in modes))
		return "[requested_mode]"
	return "[modes[1]]"

/datum/world_edit_manager/proc/resolve_supported_placement_shape(requested_shape = null)
	var/list/shapes = get_supported_placement_shapes()
	if(!length(shapes))
		return null

	if(length("[requested_shape]") && (requested_shape in shapes))
		return "[requested_shape]"

	var/default_shape = current_generator?.get_default_placement_shape()
	if(length("[default_shape]") && (default_shape in shapes))
		return "[default_shape]"
	return "[shapes[1]]"

/datum/world_edit_manager/proc/resolve_supported_placement_dir(requested_dir = null)
	var/default_dir = current_generator?.get_default_placement_direction() || NORTH
	if(requested_dir in GLOB.cardinals)
		return requested_dir
	return default_dir

/datum/world_edit_manager/proc/apply_shared_placement_prefs_to_current_generator()
	placement_mode = resolve_supported_placement_mode(placement_shared_mode) || "single"
	placement_shape = resolve_supported_placement_shape(placement_shared_shape) || WORLD_EDIT_SHAPE_POINT
	placement_dir = resolve_supported_placement_dir(placement_shared_dir)
	placement_dir_uses_facing = placement_shared_dir_uses_facing ? TRUE : FALSE
	return TRUE

/datum/world_edit_manager/proc/get_effective_placement_mode()
	var/resolved_mode = resolve_supported_placement_mode(placement_mode)
	if(!length("[resolved_mode]"))
		placement_mode = "single"
		return null

	placement_mode = resolved_mode
	return placement_mode

/datum/world_edit_manager/proc/get_effective_placement_shape()
	var/resolved_shape = resolve_supported_placement_shape(placement_shape)
	if(!length("[resolved_shape]"))
		placement_shape = WORLD_EDIT_SHAPE_POINT
		return null

	placement_shape = resolved_shape
	return placement_shape

/datum/world_edit_manager/proc/get_effective_placement_dir()
	placement_dir = resolve_supported_placement_dir(placement_dir)
	if(placement_dir_uses_facing)
		var/current_facing_dir = holder?.mob?.dir
		if(current_facing_dir in GLOB.cardinals)
			return current_facing_dir
	return placement_dir

/datum/world_edit_manager/proc/build_placement_mode_options()
	var/list/options = list()
	for(var/mode in get_supported_placement_modes())
		var/list/entry = list("value" = "[mode]")
		switch("[mode]")
			if("single")
				entry["label"] = "Один раз"
				entry["description"] = "Одно размещение и выход из режима."
			if("repeat")
				entry["label"] = "Повтор"
				entry["description"] = "Оставлять режим размещения активным после каждого применения."
			else
				entry["label"] = "[mode]"
		options += list(entry)
	return options

/datum/world_edit_manager/proc/build_placement_shape_options()
	var/list/options = list()
	var/list/effective_params = build_effective_generator_params()
	for(var/shape_id in get_supported_placement_shapes())
		var/list/option = GLOB.world_edit_shape_catalog.build_placement_shape_option(shape_id)
		var/list/support_report = current_generator?.get_placement_shape_support_report(shape_id, effective_params, null)
		if(islist(support_report))
			option["status"] = support_report["status"]
			option["locked"] = support_report["locked"] ? TRUE : FALSE
			option["shape_locked"] = support_report["shape_locked"] ? TRUE : FALSE
			option["request_locked"] = support_report["request_locked"] ? TRUE : FALSE
			option["lock_code"] = support_report["lock_code"] || support_report["reason_code"] || ""
			option["lockReason"] = support_report["reason"] || support_report["lock_reason"] || ""
			option["can_preview"] = support_report["can_preview"] ? TRUE : FALSE
			option["can_apply"] = support_report["can_apply"] ? TRUE : FALSE
		options += list(option)
	return options

/datum/world_edit_manager/proc/build_current_placement_shape_fields()
	var/shape_id = get_effective_placement_shape()
	if(!length(shape_id))
		return list()
	return GLOB.world_edit_shape_catalog.build_shape_ui_fields(shape_id, build_effective_generator_params())

/datum/world_edit_manager/proc/build_placement_dir_options()
	return list(
		list("label" = "Север", "value" = "north"),
		list("label" = "Восток", "value" = "east"),
		list("label" = "Юг", "value" = "south"),
		list("label" = "Запад", "value" = "west"),
	)

/datum/world_edit_manager/proc/placement_mode_uses_anchor_pair(mode = null)
	var/shape_id = mode || get_effective_placement_shape()
	return (get_placement_interaction_kind(shape_id) == "anchor_pair") ? TRUE : FALSE

/datum/world_edit_manager/proc/get_placement_interaction_kind(shape_id = null)
	shape_id = shape_id || get_effective_placement_shape()
	if(!length(shape_id))
		return "single"
	return GLOB.world_edit_shape_catalog.get_shape_interaction_kind(shape_id)

/datum/world_edit_manager/proc/get_placement_interaction_label(shape_id = null)
	shape_id = shape_id || get_effective_placement_shape()
	if(!length(shape_id))
		return "Один клик"
	return GLOB.world_edit_shape_catalog.get_shape_interaction_label(shape_id)

/datum/world_edit_manager/proc/get_placement_session() as /datum/world_edit_placement_session
	if(!istype(placement_session))
		placement_session = new
	return placement_session

/datum/world_edit_manager/proc/bump_preview_context_revision()
	var/datum/world_edit_placement_session/session = get_placement_session()
	session.preview_context_revision = (session.preview_context_revision || 0) + 1
	return session.preview_context_revision

/datum/world_edit_manager/proc/rebuild_session_collector_points_text(datum/world_edit_placement_session/session = null)
	session = session || get_placement_session()
	if(!istype(session))
		return ""
	session.collector_points_text = GLOB.world_edit_placement_shapes.world_edit_format_shape_points(session.collector_points)
	return session.collector_points_text

/datum/world_edit_manager/proc/sync_placement_session_cache()
	var/datum/world_edit_placement_session/session = get_placement_session()
	placement_anchor_turf = session.anchor_turf
	placement_hover_turf = session.hover_turf
	placement_collector_origin_turf = session.collector_origin_turf
	placement_collector_points = GLOB.world_edit_placement_shapes.world_edit_copy_points(session.collector_points)
	return session

/datum/world_edit_manager/proc/build_generator_params_for_shape(list/source_params = null, shape_id = null, list/collector_points = null, collector_points_text = null)
	var/list/base_params = islist(source_params) ? source_params : current_params
	var/list/effective_params = sanitize_persistent_generator_params(base_params)
	shape_id = "[shape_id]"
	if(!length(shape_id))
		return effective_params

	var/list/effective_points = islist(collector_points) ? collector_points : list()
	if(shape_id in list(
		WORLD_EDIT_SHAPE_POLYGON,
		WORLD_EDIT_SHAPE_POLYLINE,
		WORLD_EDIT_SHAPE_CUSTOM_MASK,
		WORLD_EDIT_SHAPE_BRUSH_PATH
	))
		effective_params["shape_points_text"] = isnull(collector_points_text) ? GLOB.world_edit_placement_shapes.world_edit_format_shape_points(effective_points) : "[collector_points_text]"

	return effective_params

/datum/world_edit_manager/proc/build_effective_generator_params(list/source_params = null, shape_id = null, list/collector_points_override = null)
	shape_id = shape_id || get_effective_placement_shape()

	var/list/effective_points = collector_points_override
	var/collector_points_text = null
	if(!islist(effective_points))
		effective_points = get_placement_collector_points()
		collector_points_text = get_placement_collector_points_text()
	return build_generator_params_for_shape(source_params, shape_id, effective_points, collector_points_text)

/datum/world_edit_manager/proc/get_placement_preview_candidate() as /datum/world_edit_placement_candidate
	var/datum/world_edit_placement_session/session = get_placement_session()
	return session.preview_candidate

/datum/world_edit_manager/proc/set_placement_anchor_turf(turf/anchor_turf)
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(session.anchor_turf != anchor_turf)
		session.anchor_turf = anchor_turf
		bump_preview_context_revision()
	else
		session.anchor_turf = anchor_turf
	sync_placement_session_cache()
	return anchor_turf

/datum/world_edit_manager/proc/set_placement_hover_turf(turf/hover_turf)
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(session.hover_turf != hover_turf)
		session.hover_turf = hover_turf
		bump_preview_context_revision()
	else
		session.hover_turf = hover_turf
	sync_placement_session_cache()
	return hover_turf

/datum/world_edit_manager/proc/get_placement_confirm_target_turf(datum/world_edit_placement_candidate/candidate = null)
	candidate = candidate || get_placement_preview_candidate()
	if(istype(candidate) && islist(candidate.placement_context))
		var/turf/confirm_turf = candidate.placement_context["resolved_end_turf"] || candidate.placement_context["end_turf"]
		if(istype(confirm_turf))
			return confirm_turf
	return placement_hover_turf

/datum/world_edit_manager/proc/clear_placement_confirm_arm()
	var/datum/world_edit_placement_session/session = get_placement_session()
	session.confirm_arm_turf = null
	session.confirm_arm_signature = null
	return TRUE

/datum/world_edit_manager/proc/arm_placement_confirm_for_turf(turf/confirm_turf = null, datum/world_edit_placement_candidate/candidate = null)
	candidate = candidate || get_placement_preview_candidate()
	if(!istype(candidate) || !candidate.is_confirm_ready() || !is_preview_state_valid())
		return FALSE

	confirm_turf = confirm_turf || get_placement_confirm_target_turf(candidate)
	if(!istype(confirm_turf))
		return FALSE

	var/datum/world_edit_placement_session/session = get_placement_session()
	session.confirm_arm_turf = confirm_turf
	session.confirm_arm_signature = build_preview_params_signature()
	return TRUE

/datum/world_edit_manager/proc/is_placement_confirm_armed_for_turf(turf/confirm_turf = null, datum/world_edit_placement_candidate/candidate = null)
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(!istype(session.confirm_arm_turf))
		return FALSE
	if(session.confirm_arm_signature != build_preview_params_signature())
		return FALSE

	candidate = candidate || get_placement_preview_candidate()
	if(!istype(candidate) || !candidate.is_confirm_ready() || !is_preview_state_valid())
		return FALSE

	confirm_turf = confirm_turf || get_placement_confirm_target_turf(candidate)
	if(!istype(confirm_turf))
		return FALSE
	return (session.confirm_arm_turf == confirm_turf)

/datum/world_edit_manager/proc/is_placement_preview_locked()
	var/datum/world_edit_placement_session/session = get_placement_session()
	return session.preview_locked ? TRUE : FALSE

/datum/world_edit_manager/proc/set_placement_preview_locked(locked, turf/focus_turf = null)
	var/datum/world_edit_placement_session/session = get_placement_session()
	var/previous_lock = session.preview_locked
	var/turf/previous_hover_turf = session.hover_turf
	session.preview_locked = locked ? TRUE : FALSE
	if(locked)
		clear_placement_confirm_arm()
	if(istype(focus_turf))
		session.hover_turf = focus_turf
	if(previous_lock != session.preview_locked || previous_hover_turf != session.hover_turf)
		bump_preview_context_revision()
	sync_placement_session_cache()
	return session.preview_locked

/datum/world_edit_manager/proc/get_current_preview_plan()
	var/datum/world_edit_placement_candidate/candidate = get_placement_preview_candidate()
	if(istype(candidate?.plan))
		return candidate.plan
	return current_generator?.current_plan

/datum/world_edit_manager/proc/get_placement_collector_origin_text()
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(!istype(session.collector_origin_turf))
		return ""
	return "[session.collector_origin_turf.x],[session.collector_origin_turf.y],[session.collector_origin_turf.z]"

/datum/world_edit_manager/proc/get_placement_collector_origin_turf() as /turf
	var/datum/world_edit_placement_session/session = get_placement_session()
	return session.collector_origin_turf

/datum/world_edit_manager/proc/set_placement_collector_origin_turf(turf/origin_turf)
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(session.collector_origin_turf != origin_turf)
		session.collector_origin_turf = origin_turf
		bump_preview_context_revision()
	else
		session.collector_origin_turf = origin_turf
	if(islist(current_params))
		current_params -= "shape_points_origin"
	sync_placement_session_cache()
	if(!istype(origin_turf))
		return ""
	return "[origin_turf.x],[origin_turf.y],[origin_turf.z]"

/datum/world_edit_manager/proc/clear_placement_collector_origin()
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(istype(session.collector_origin_turf))
		session.collector_origin_turf = null
		bump_preview_context_revision()
	else
		session.collector_origin_turf = null
	if(islist(current_params))
		current_params -= "shape_points_origin"
	sync_placement_session_cache()

/datum/world_edit_manager/proc/get_placement_collector_points_snapshot()
	get_placement_session()
	if(!islist(placement_collector_points))
		sync_placement_session_cache()
	return islist(placement_collector_points) ? placement_collector_points : list()

/datum/world_edit_manager/proc/get_placement_collector_points()
	return GLOB.world_edit_placement_shapes.world_edit_copy_points(get_placement_collector_points_snapshot())

/datum/world_edit_manager/proc/get_placement_collector_point_count()
	return length(get_placement_collector_points_snapshot())

/datum/world_edit_manager/proc/get_placement_collector_min_points(shape_id = null)
	shape_id = shape_id || get_effective_placement_shape()
	if(!length(shape_id))
		return 1
	return GLOB.world_edit_shape_catalog.get_shape_collector_min_points(shape_id)

/datum/world_edit_manager/proc/get_placement_collector_max_points(shape_id = null)
	shape_id = shape_id || get_effective_placement_shape()
	if(!length(shape_id))
		return WORLD_EDIT_PLACEMENT_MAX_CUSTOM_POINTS
	return GLOB.world_edit_shape_catalog.get_shape_collector_max_points(shape_id)

/datum/world_edit_manager/proc/is_current_placement_collector(shape_id = null)
	return (get_placement_interaction_kind(shape_id) == "collector") ? TRUE : FALSE

/datum/world_edit_manager/proc/set_placement_collector_points(list/points)
	var/datum/world_edit_placement_session/session = get_placement_session()
	var/list/new_points = islist(points) ? GLOB.world_edit_placement_shapes.world_edit_copy_points(points) : list()
	var/new_points_text = GLOB.world_edit_placement_shapes.world_edit_format_shape_points(new_points)
	session.collector_points = new_points
	if(session.collector_points_text != new_points_text)
		session.collector_points_revision = (session.collector_points_revision || 0) + 1
		session.collector_points_text = new_points_text
	if(islist(current_params))
		current_params -= "shape_points_text"
	sync_placement_session_cache()
	return session.collector_points_text

/datum/world_edit_manager/proc/clear_placement_collector_points()
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(length(session.collector_points) || length(session.collector_points_text))
		session.collector_points = list()
		session.collector_points_text = ""
		session.collector_points_revision = (session.collector_points_revision || 0) + 1
	else
		session.collector_points = list()
		session.collector_points_text = ""
	if(islist(current_params))
		current_params -= "shape_points_text"
	sync_placement_session_cache()

/datum/world_edit_manager/proc/get_placement_collector_points_text()
	var/datum/world_edit_placement_session/session = get_placement_session()
	if(!istext(session.collector_points_text))
		return rebuild_session_collector_points_text(session)
	return session.collector_points_text

/datum/world_edit_manager/proc/get_placement_collector_last_absolute_turf(turf/origin_turf = null)
	origin_turf = origin_turf || get_placement_collector_origin_turf()
	if(!istype(origin_turf))
		return null

	var/list/collector_points = get_placement_collector_points_snapshot()
	if(!length(collector_points))
		return origin_turf

	var/list/last_point = collector_points[length(collector_points)]
	if(!islist(last_point))
		return origin_turf

	var/target_x = origin_turf.x + text2num("[last_point["x"]]")
	var/target_y = origin_turf.y + text2num("[last_point["y"]]")
	return locate(target_x, target_y, origin_turf.z)

/datum/world_edit_manager/proc/reset_placement_collector_state(clear_points = FALSE)
	clear_placement_collector_origin()
	if(clear_points)
		clear_placement_collector_points()

/datum/world_edit_manager/proc/get_placement_collector_summary()
	var/shape_id = get_effective_placement_shape()
	var/shape_label = GLOB.world_edit_shape_catalog.get_placement_shape_label(shape_id)
	var/min_points = get_placement_collector_min_points(shape_id)
	var/max_points = get_placement_collector_max_points(shape_id)
	var/point_count = get_placement_collector_point_count()
	var/origin_desc = get_placement_collector_origin_text()
	if(!length(origin_desc))
		origin_desc = "не задано"
	return "Сборщик [shape_label]: точек=[point_count]/[max_points], минимум=[min_points], начало=[origin_desc]"

/datum/world_edit_manager/proc/clear_placement_shape_preview_state(preserve_lock = FALSE, turf/preserved_hover_turf = null, clear_resolved_candidate_cache = TRUE)
	var/datum/world_edit_placement_session/session = get_placement_session()
	var/should_bump_context = istype(session.preview_candidate) || session.preview_locked || istype(session.confirm_arm_turf) || istype(session.hover_turf) || length(placement_preview_shape_result) || length("[placement_preview_render_token]") || length(placement_preview_anchor_turfs) || length(placement_preview_vertex_turfs) || length(placement_preview_edge_turfs) || length(placement_preview_closure_turfs) || length(placement_preview_final_turfs) || length(placement_preview_guide_turfs) || length(placement_preview_generator_effect_turfs)
	if(clear_resolved_candidate_cache)
		clear_last_resolved_placement_candidate_cache()
	session.preview_candidate = null
	session.preview_locked = preserve_lock ? TRUE : FALSE
	session.confirm_arm_turf = null
	session.confirm_arm_signature = null
	if(!preserve_lock && clear_resolved_candidate_cache)
		session.hover_object_preview_next_allowed_ds = 0
	session.hover_turf = preserve_lock ? preserved_hover_turf : null
	placement_preview_shape_result = list()
	placement_preview_signature = null
	placement_preview_render_token = null
	placement_preview_anchor_turfs = list()
	placement_preview_vertex_turfs = list()
	placement_preview_edge_turfs = list()
	placement_preview_closure_turfs = list()
	placement_preview_final_turfs = list()
	placement_preview_guide_turfs = list()
	placement_preview_generator_effect_turfs = list()
	placement_hover_turf = preserve_lock ? preserved_hover_turf : null
	if(should_bump_context || preserve_lock)
		bump_preview_context_revision()

/datum/world_edit_manager/proc/update_placement_preview_candidate_state(datum/world_edit_placement_candidate/candidate, allow_context_bump = TRUE)
	var/datum/world_edit_placement_session/session = get_placement_session()
	var/keep_lock = session.preview_locked ? TRUE : FALSE
	var/turf/previous_hover_turf = session.hover_turf
	var/had_candidate = istype(session.preview_candidate)
	session.preview_candidate = candidate
	session.confirm_arm_turf = null
	session.confirm_arm_signature = null
	if(!istype(candidate))
		return

	if(!keep_lock)
		session.hover_turf = islist(candidate.placement_context) ? candidate.placement_context["resolved_end_turf"] || candidate.placement_context["end_turf"] : null
	placement_hover_turf = session.hover_turf
	if(allow_context_bump && (!had_candidate || previous_hover_turf != session.hover_turf))
		bump_preview_context_revision()
	placement_preview_signature = build_preview_params_signature(candidate.runtime_params)
	if(islist(candidate.placement_context))
		candidate.placement_context["preview_signature"] = placement_preview_signature
	if(istype(candidate.shape_contract))
		placement_preview_shape_result = islist(candidate.shape_contract.raw_result) ? candidate.shape_contract.raw_result : list()
	placement_preview_render_token = length("[candidate.preview_render_token]") ? "[candidate.preview_render_token]" : null
	if(istype(candidate.preview_model))
		placement_preview_anchor_turfs = islist(candidate.preview_model.anchor_turfs) ? candidate.preview_model.anchor_turfs : list()
		placement_preview_vertex_turfs = islist(candidate.preview_model.vertex_turfs) ? candidate.preview_model.vertex_turfs : list()
		placement_preview_edge_turfs = islist(candidate.preview_model.edge_turfs) ? candidate.preview_model.edge_turfs : list()
		placement_preview_closure_turfs = islist(candidate.preview_model.closure_turfs) ? candidate.preview_model.closure_turfs : list()
		placement_preview_final_turfs = islist(candidate.preview_model.final_turfs) ? candidate.preview_model.final_turfs : list()
		placement_preview_guide_turfs = islist(candidate.preview_model.guide_turfs) ? candidate.preview_model.guide_turfs : list()
		placement_preview_generator_effect_turfs = islist(candidate.preview_model.generator_effect_turfs) ? candidate.preview_model.generator_effect_turfs : list()
		if(!length(placement_preview_render_token) && length("[candidate.preview_model.preview_render_token]"))
			placement_preview_render_token = "[candidate.preview_model.preview_render_token]"

/datum/world_edit_manager/proc/store_placement_preview_candidate(datum/world_edit_placement_candidate/candidate)
	var/datum/world_edit_placement_session/session = get_placement_session()
	var/keep_lock = session.preview_locked ? TRUE : FALSE
	var/turf/locked_hover_turf = keep_lock ? session.hover_turf : null
	clear_placement_shape_preview_state(keep_lock, locked_hover_turf, FALSE)
	update_placement_preview_candidate_state(candidate, FALSE)

/datum/world_edit_manager/proc/get_placement_preview_groups()
	var/list/groups = list(
		list(
			"turfs" = placement_preview_anchor_turfs,
			"icon_state" = "blueOverlay",
			"color" = "#78C8FF",
			"alpha" = 255,
		),
		list(
			"turfs" = placement_preview_vertex_turfs,
			"icon_state" = "blueOverlay",
			"color" = "#B8F3FF",
			"alpha" = 210,
		),
		list(
			"turfs" = placement_preview_edge_turfs,
			"icon_state" = "greenOverlay",
			"color" = "#4DE1C1",
			"alpha" = 190,
		),
		list(
			"turfs" = placement_preview_closure_turfs,
			"icon_state" = "redOverlay",
			"color" = "#FFB347",
			"alpha" = 180,
		),
		list(
			"turfs" = placement_preview_final_turfs,
			"icon_state" = "greenOverlay",
			"color" = "#8BFFB5",
			"alpha" = 120,
		),
		list(
			"turfs" = placement_preview_guide_turfs,
			"icon_state" = "blueOverlay",
			"color" = "#D7B8FF",
			"alpha" = 150,
		),
		list(
			"turfs" = placement_preview_generator_effect_turfs,
			"icon_state" = "redOverlay",
			"color" = "#FF6B6B",
			"alpha" = 110,
		),
	)
	groups["preview_render_token"] = placement_preview_render_token
	return groups

/datum/world_edit_manager/proc/get_placement_anchor_desc()
	return GLOB.world_edit_helpers.turf_to_text(placement_anchor_turf)

/datum/world_edit_manager/proc/reset_placement_runtime(reset_config = FALSE, clear_points = TRUE)
	var/datum/world_edit_placement_session/session = get_placement_session()
	placement_click_active = FALSE
	session.anchor_turf = null
	session.hover_turf = null
	session.preview_candidate = null
	session.confirm_arm_turf = null
	session.confirm_arm_signature = null
	session.preview_locked = FALSE
	clear_placement_shape_preview_state()
	reset_placement_collector_state(clear_points)
	sync_placement_session_cache()

	if(reset_config)
		placement_mode = resolve_supported_placement_mode() || "single"
		placement_shape = resolve_supported_placement_shape() || WORLD_EDIT_SHAPE_POINT
		placement_dir = resolve_supported_placement_dir()
		placement_dir_uses_facing = TRUE
