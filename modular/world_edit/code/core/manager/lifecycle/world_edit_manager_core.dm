GLOBAL_LIST_EMPTY(world_edit_managers_by_client)

/datum/world_edit_manager
	var/client/holder
	var/datum/world_edit_generator_definition/current_definition
	var/datum/world_edit_generator/current_generator
	var/list/current_params = list()
	var/last_ui_error = ""
	var/params_revision = 0
	var/cached_params_hash = null
	var/cached_params_hash_revision = -1

	var/list/preview_images = list()
	var/preview_groups_signature
	var/preview_valid = FALSE
	var/preview_generator_id
	var/preview_params_signature
	var/last_preview_success = FALSE
	var/last_preview_message = ""
	var/list/last_preview_meta = list()

	var/last_apply_success = FALSE
	var/last_apply_message = ""
	var/last_undo_success = FALSE
	var/last_undo_message = ""
	var/last_undo_action = ""

	var/list/history_entries = list()
	var/list/changeset_entries = list()
	var/list/generator_context_cache = list()
	var/list/preset_entries_cache = list()
	var/preset_cache_loaded = FALSE
	var/list/blueprint_entries_cache = list()
	var/blueprint_cache_loaded = FALSE
	var/list/blueprint_recent_usage = list()
	var/blueprint_recent_usage_sequence = 0
	var/active_blueprint_revision_id = null
	var/active_blueprint_revision_hash = ""
	var/active_blueprint_sprite_preview_revision_id = null
	var/active_blueprint_sprite_preview_revision_hash = ""
	var/list/active_blueprint_sprite_preview_cache = null
	var/confirm_before_apply = TRUE

	var/datum/click_intercept_previous
	var/click_intercept_owned = FALSE
	var/placement_click_active = FALSE
	var/placement_shared_mode = "single"
	var/placement_shared_shape = WORLD_EDIT_SHAPE_POINT
	var/placement_shared_dir = NORTH
	var/placement_shared_dir_uses_facing = TRUE
	var/placement_mode = "single"
	var/placement_shape = WORLD_EDIT_SHAPE_POINT
	var/placement_dir = NORTH
	var/placement_dir_uses_facing = TRUE
	var/datum/world_edit_placement_session/placement_session
	var/turf/placement_anchor_turf
	var/turf/placement_hover_turf
	var/list/placement_preview_shape_result = list()
	var/placement_preview_signature
	var/placement_preview_render_token = null
	var/list/placement_preview_anchor_turfs = list()
	var/list/placement_preview_vertex_turfs = list()
	var/list/placement_preview_edge_turfs = list()
	var/list/placement_preview_closure_turfs = list()
	var/list/placement_preview_final_turfs = list()
	var/list/placement_preview_guide_turfs = list()
	var/list/placement_preview_generator_effect_turfs = list()
	var/list/placement_collector_points = list()
	var/turf/placement_collector_origin_turf
	var/list/runtime_diagnostics = list()
	var/list/runtime_trace = list()
	var/list/runtime_trace_payload_cache = list()
	var/runtime_trace_sequence = 0

/datum/world_edit_manager/New(client/new_holder)
	. = ..()
	holder = new_holder
	history_entries = list()
	changeset_entries = list()
	generator_context_cache = list()
	preset_entries_cache = list()
	blueprint_entries_cache = list()
	blueprint_recent_usage = list()
	blueprint_recent_usage_sequence = 0
	active_blueprint_revision_id = null
	active_blueprint_revision_hash = ""
	active_blueprint_sprite_preview_revision_id = null
	active_blueprint_sprite_preview_revision_hash = ""
	active_blueprint_sprite_preview_cache = null
	preview_images = list()
	preview_groups_signature = null
	current_params = list()
	last_preview_meta = list()
	last_ui_error = ""
	confirm_before_apply = TRUE
	placement_session = new
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
	placement_collector_points = list()
	reset_runtime_diagnostics()
	runtime_trace = list()
	runtime_trace_payload_cache = list()
	runtime_trace_sequence = 0

/datum/world_edit_manager/Destroy(force, ...)
	stop_click_mode()
	clear_preview_images()
	detach_current_generator()
	history_entries = null
	if(islist(changeset_entries))
		for(var/datum/world_edit_changeset/changeset as anything in changeset_entries)
			qdel(changeset)
	changeset_entries = null
	generator_context_cache = null
	preset_entries_cache = null
	blueprint_entries_cache = null
	blueprint_recent_usage = null
	active_blueprint_revision_id = null
	active_blueprint_revision_hash = null
	active_blueprint_sprite_preview_revision_id = null
	active_blueprint_sprite_preview_revision_hash = null
	active_blueprint_sprite_preview_cache = null
	if(holder && GLOB.world_edit_managers_by_client[holder] == src)
		GLOB.world_edit_managers_by_client[holder] = null
	holder = null
	return ..()

/// Сбрасывает кеш последнего preview (без изменения изображений/валидности).
/datum/world_edit_manager/proc/reset_preview_feedback()
	last_preview_success = FALSE
	last_preview_message = ""
	last_preview_meta = list()

/// Сбрасывает кеш последнего apply.
/datum/world_edit_manager/proc/reset_apply_feedback()
	last_apply_success = FALSE
	last_apply_message = ""

/datum/world_edit_manager/proc/reset_undo_feedback()
	last_undo_success = FALSE
	last_undo_message = ""
	last_undo_action = ""

/// Полный сброс runtime-состояния preview.
/datum/world_edit_manager/proc/clear_preview_plan_state()
	clear_preview_images()
	current_generator?.clear_built_plan()
	clear_placement_shape_preview_state()
	invalidate_preview_state()
	reset_preview_feedback()

/// Internal teardown switchboard for preview/session/runtime cleanup paths.
/datum/world_edit_manager/proc/teardown_preview_session_runtime(clear_preview_state = TRUE, clear_placement_progress = FALSE, clear_collector_points = FALSE, stop_click_mode = FALSE)
	if(clear_preview_state)
		clear_preview_plan_state()

	if(stop_click_mode)
		current_generator?.disable_click_mode()
		reset_placement_runtime()

		if(holder && click_intercept_owned && holder.click_intercept == src)
			if(click_intercept_previous && !QDELETED(click_intercept_previous))
				holder.click_intercept = click_intercept_previous
			else
				holder.click_intercept = null

		click_intercept_previous = null
		click_intercept_owned = FALSE
		return TRUE

	if(clear_placement_progress)
		clear_active_placement_progress(clear_collector_points)
	return TRUE

/datum/world_edit_manager/proc/reset_preview_runtime()
	return teardown_preview_session_runtime(TRUE, FALSE, FALSE, TRUE)

/// Сбрасывает runtime генератора (preview/apply/click), но не очищает историю.
/datum/world_edit_manager/proc/reset_generator_runtime()
	bump_preview_params_revision()
	reset_preview_runtime()
	reset_apply_feedback()
	last_ui_error = ""
	reset_runtime_diagnostics()

/// Корректно отсоединяет текущий экземпляр генератора.
/datum/world_edit_manager/proc/detach_current_generator()
	bump_preview_params_revision()
	current_generator?.clear_built_plan()
	QDEL_NULL(current_generator)
	current_definition = null
	current_params = list()
	QDEL_NULL(placement_session)
	reset_placement_runtime(TRUE)
