#define WORLD_EDIT_EXECUTION_BATCH "batch"
#define WORLD_EDIT_EXECUTION_CLICK "click"
#define WORLD_EDIT_STATUS_DRAFT "draft"
#define WORLD_EDIT_STATUS_READY "ready"
#define WORLD_EDIT_HISTORY_LIMIT 125
#define WORLD_EDIT_PLACEMENT_MAX_ANCHORS 2400
#define WORLD_EDIT_PLACEMENT_MAX_TOTAL_PLACEMENTS 6000
#define WORLD_EDIT_HOVER_OBJECT_PREVIEW_MIN_INTERVAL_DS 0
#define WORLD_EDIT_HOVER_OBJECT_PREVIEW_MAX_ANCHORS 8
#define WORLD_EDIT_HOVER_PREVIEW_MODE_GHOST "ghost"
#define WORLD_EDIT_HOVER_PREVIEW_MODE_COMPACT "compact"
#define WORLD_EDIT_RADIUS_POLICY_ONLY_CLEAR_TILES "radius_only_clear_tiles"
#define WORLD_EDIT_RADIUS_POLICY_ONLY_REACHABLE_TILES "radius_only_reachable_tiles"
#define WORLD_EDIT_RADIUS_POLICY_WINDOWS_BLOCKERS "radius_windows_blockers"

/// Результат этапа предпросмотра генератора.
/datum/world_edit_preview_result
	var/success = FALSE
	var/message = ""
	var/list/preview_images = list()
	var/list/meta = list()

/// Результат этапа применения генератора.
/datum/world_edit_apply_result
	var/success = FALSE
	var/message = ""
	var/created_count = 0
	var/deleted_count = 0
	var/turf/center_turf
	var/list/meta = list()
	/// Opt-in for failed/rolled-back results that should keep logs/chat but skip manager history.
	var/suppress_history = FALSE
	var/datum/world_edit_changeset/changeset

/datum/world_edit_plan
	var/list/placements = list()
	var/list/deletions = list()
	var/list/affected_turfs = list()
	var/list/metadata = list()

/// Базовый контракт генератора World Edit.
/datum/world_edit_generator
	var/datum/world_edit_manager/manager
	var/datum/world_edit_generator_definition/definition
	var/requires_preview_before_apply = FALSE
	var/datum/world_edit_plan/current_plan

/datum/world_edit_generator/proc/attach(datum/world_edit_manager/new_manager, datum/world_edit_generator_definition/new_definition)
	manager = new_manager
	definition = new_definition
	current_plan = null

/// Возвращает null при валидных параметрах либо текст ошибки.
/datum/world_edit_generator/proc/validate_params(mob/user, list/params)
	return null

/datum/world_edit_generator/proc/build_plan(list/params)
	return null

/datum/world_edit_generator/proc/preview(mob/user, list/params)
	var/datum/world_edit_preview_result/result = new
	result.success = FALSE
	result.message = "Для этого генератора предпросмотр не реализован."
	return result

/datum/world_edit_generator/proc/apply(mob/user, list/params)
	var/datum/world_edit_apply_result/result = new
	result.success = FALSE
	result.message = "Для этого генератора применение не реализовано."
	return result

/datum/world_edit_generator/proc/cleanup_preview(mob/user)
	return

/// Вызывается только в click-режиме.
/datum/world_edit_generator/proc/clear_built_plan()
	current_plan = null

/datum/world_edit_generator/proc/InterceptClickOn(mob/user, params, atom/object)
	return FALSE

/datum/world_edit_generator/proc/disable_click_mode()
	return

/datum/world_edit_generator/proc/get_apply_confirmation_text(list/params)
	return "Подтвердить применение генератора '[definition?.name_ru]'?"

/datum/world_edit_generator/proc/get_params_short(list/params)
	return GLOB.world_edit_logging.params_to_text(params)

/// Возвращает описание полей для live inline-настройки в TGUI.
/datum/world_edit_generator/proc/get_ui_fields(list/current_params)
	return null

/// Возвращает generator-specific payload для TGUI/acceptance.
/datum/world_edit_generator/proc/get_ui_payload(list/current_params)
	return list()

/// Возвращает новые параметры после изменения одного поля через TGUI.
/// По умолчанию выполняется простое присваивание.
/datum/world_edit_generator/proc/set_ui_param(mob/user, list/current_params, param_id, value)
	if(!islist(current_params))
		current_params = list()

	var/list/new_params = current_params.Copy()
	new_params[param_id] = value
	return new_params

/// Хук для принудительного обновления UI-состояния генератора.
/// Нужен для динамических каталогов и сброса кэшей без смены генератора.
/datum/world_edit_generator/proc/refresh_ui_state(mob/user, list/current_params)
	return

/// Возвращает runtime-статус генератора для панели World Edit.
/datum/world_edit_generator/proc/get_runtime_status()
	return list()

/// Возвращает опциональные object-preview specs для runtime/placement preview.
/// По умолчанию генератор не добавляет свои объектные слои.
/datum/world_edit_generator/proc/build_plan_preview_object_specs(datum/world_edit_plan/plan, list/runtime_params = null, list/placement_context = null, hover_only = FALSE)
	return list()

/datum/world_edit_generator/proc/should_skip_plan_build_for_safe_preview(datum/world_edit_shape_contract/shape_contract, list/runtime_params = null, list/placement_context = null, hover_only = FALSE)
	return hover_only ? should_skip_plan_build_for_hover_only_placement(shape_contract, runtime_params, placement_context) : FALSE

/datum/world_edit_generator/proc/should_skip_plan_build_for_hover_only_placement(datum/world_edit_shape_contract/shape_contract, list/runtime_params = null, list/placement_context = null)
	return FALSE

/datum/world_edit_generator/proc/should_build_hover_object_preview_plan(datum/world_edit_shape_contract/shape_contract, list/runtime_params = null, list/placement_context = null)
	return FALSE

/datum/world_edit_generator/proc/get_hover_object_preview_anchor_limit()
	return WORLD_EDIT_HOVER_OBJECT_PREVIEW_MAX_ANCHORS

/datum/world_edit_generator/proc/get_hover_object_preview_min_interval_ds()
	return WORLD_EDIT_HOVER_OBJECT_PREVIEW_MIN_INTERVAL_DS

/datum/world_edit_generator/proc/should_attempt_preview_endpoint_clamp(shape_id, turf/start_turf, turf/requested_end_turf, turf/segment_start_turf = null, list/runtime_params = null, list/placement_context = null)
	return FALSE

/datum/world_edit_generator/proc/get_preview_endpoint_clamp_attempt_limit()
	return 24

/datum/world_edit_generator/proc/should_preview_collector_points_before_commit(shape_id, list/proposed_points = null)
	return FALSE

/// Явный opt-in для manager-owned placement-layer preview во время обычного preview.
/// Нужен только тем генераторам, у которых placement layers эквивалентны их runtime preview.
/datum/world_edit_generator/proc/should_render_preview_via_placement_layers(datum/world_edit_plan/plan)
	return FALSE

/datum/world_edit_generator/proc/get_supported_placement_modes()
	return list()

/datum/world_edit_generator/proc/get_supported_placement_shapes()
	return list()

/datum/world_edit_generator/proc/get_default_placement_shape()
	var/list/shapes = get_supported_placement_shapes()
	if(!length(shapes))
		return null
	return "[shapes[1]]"

/datum/world_edit_generator/proc/supports_placement_direction()
	return FALSE

/datum/world_edit_generator/proc/get_default_placement_direction()
	return NORTH

/datum/world_edit_generator/proc/get_shape_support_error(shape_id, list/anchor_turfs, list/params, list/placement_context)
	return null

/datum/world_edit_generator/proc/get_placement_shape_support_report(shape_id, list/params, list/placement_context)
	return list(
		"shape_id" = "[shape_id]",
		"status" = "supported",
		"visible" = TRUE,
		"locked" = FALSE,
		"lock_code" = "",
		"reason" = "",
		"can_preview" = TRUE,
		"can_apply" = TRUE,
	)

/datum/world_edit_generator/proc/build_placement_plan(mob/user, list/params, list/placement_context)
	return null

/datum/world_edit_generator/proc/get_shape_placement_seed_turf(datum/world_edit_shape_contract/shape_contract, list/placement_context)
	var/turf/seed_turf = islist(placement_context) ? placement_context["seed_turf"] : null
	if(istype(seed_turf))
		return seed_turf

	var/turf/origin_turf = islist(placement_context) ? (placement_context["shape_origin_turf"] || placement_context["start_turf"]) : null
	if(istype(origin_turf))
		return origin_turf

	var/list/anchor_turfs = shape_contract?.copy_anchor_turfs() || (islist(placement_context) ? placement_context["anchor_turfs"] : null)
	if(islist(anchor_turfs) && length(anchor_turfs))
		var/turf/first_anchor = anchor_turfs[1]
		if(istype(first_anchor))
			return first_anchor
	return null

/datum/world_edit_generator/proc/stamp_plan_shape_metadata(datum/world_edit_plan/plan, datum/world_edit_shape_contract/shape_contract, list/placement_context)
	if(!istype(plan))
		return null
	if(!islist(plan.metadata))
		plan.metadata = list()
	if(!istype(shape_contract))
		shape_contract = build_shape_contract_from_placement_context(null, null, placement_context)
	if(!istype(shape_contract))
		return plan

	var/turf/shape_origin_turf = islist(placement_context) ? (placement_context["shape_origin_turf"] || placement_context["start_turf"]) : null
	var/turf/requested_end_turf = islist(placement_context) ? (placement_context["requested_end_turf"] || placement_context["end_turf"]) : null
	var/turf/resolved_end_turf = islist(placement_context) ? (placement_context["resolved_end_turf"] || placement_context["end_turf"]) : null
	var/turf/seed_turf = get_shape_placement_seed_turf(shape_contract, placement_context)
	var/list/shape_result = shape_contract.as_shape_result()

	plan.metadata["shape_result"] = shape_result
	plan.metadata["shape_origin_turf"] = shape_origin_turf
	plan.metadata["requested_end_turf"] = requested_end_turf
	plan.metadata["resolved_end_turf"] = resolved_end_turf
	plan.metadata["seed_turf"] = seed_turf
	plan.metadata["placement_shape"] = plan.metadata["placement_shape"] || shape_contract.shape_id
	plan.metadata["shape_label"] = plan.metadata["shape_label"] || shape_contract.shape_label
	return plan

/datum/world_edit_generator/proc/finalize_shared_placement_plan_metadata(datum/world_edit_plan/plan, datum/world_edit_shape_contract/shape_contract, list/placement_context)
	if(!istype(plan))
		return null
	if(!islist(plan.metadata))
		plan.metadata = list()
	if(!istype(shape_contract))
		shape_contract = build_shape_contract_from_placement_context(null, null, placement_context)

	var/raw_shape_id = shape_contract?.shape_id || placement_context["shape"] || manager?.get_effective_placement_shape()
	var/placement_shape = length("[raw_shape_id]") ? "[raw_shape_id]" : WORLD_EDIT_SHAPE_POINT
	var/raw_mode = placement_context["mode"]
	var/placement_mode = length("[raw_mode]") ? "[raw_mode]" : "single"
	var/placement_dir = islist(placement_context) ? placement_context["direction"] : null
	if(!(placement_dir in GLOB.cardinals) && manager?.supports_current_placement_direction())
		placement_dir = manager.get_effective_placement_dir()
	var/list/anchor_turfs = shape_contract?.copy_anchor_turfs() || (islist(placement_context) ? placement_context["anchor_turfs"] : null)
	var/list/shape_metadata = istype(shape_contract) ? shape_contract.copy_metadata() : (islist(placement_context) ? placement_context["shape_metadata"] : null)

	plan.metadata["placement_mode"] = plan.metadata["placement_mode"] || placement_mode
	plan.metadata["placement_shape"] = plan.metadata["placement_shape"] || placement_shape
	plan.metadata["shape_label"] = plan.metadata["shape_label"] || shape_contract?.shape_label || GLOB.world_edit_shape_catalog.get_placement_shape_label(placement_shape)
	if(placement_dir in GLOB.cardinals)
		plan.metadata["placement_dir"] = plan.metadata["placement_dir"] || placement_dir
		plan.metadata["placement_dir_label"] = plan.metadata["placement_dir_label"] || GLOB.world_edit_helpers.dir_to_label(placement_dir)
	if(islist(anchor_turfs) && !plan.metadata["anchor_count"])
		plan.metadata["anchor_count"] = length(anchor_turfs)
	if(islist(shape_metadata))
		for(var/key in shape_metadata)
			if(!(key in plan.metadata))
				plan.metadata[key] = shape_metadata[key]
	return stamp_plan_shape_metadata(plan, shape_contract, placement_context)
