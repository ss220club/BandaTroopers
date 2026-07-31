/datum/world_edit_manager/proc/run_preview(mob/user)
	if(!holder || !check_rights_for(holder, R_DEBUG))
		return fail_preview(user, "Недостаточно прав для предпросмотра в панели редактирования мира.")
	if(!current_generator || !current_definition)
		return fail_preview(user, "Сначала выберите генератор.")
	if(!current_definition.supports_preview)
		return fail_preview(user, "Для этого генератора предпросмотр не поддерживается.")
	if(!check_rights_for(holder, current_definition.required_rights))
		return fail_preview(user, "Недостаточно прав для предпросмотра этого генератора.")

	if(click_intercept_owned)
		return fail_preview(user, "Остановите активный режим размещения перед обычным предпросмотром.")

	var/list/effective_params = build_effective_generator_params()
	var/error_text = current_generator.validate_params(user, effective_params)
	if(error_text)
		return fail_preview(user, error_text)

	teardown_preview_session_runtime()
	var/datum/world_edit_preview_result/result = current_generator.preview(user, effective_params)
	if(!istype(result))
		return fail_preview(user, "Генератор вернул некорректный результат предпросмотра.")

	var/rendered_with_placement_layers = FALSE
	if(result.success && should_use_placement_layer_preview(current_generator.current_plan))
		rendered_with_placement_layers = render_plan_preview_with_placement_layers(user, current_generator.current_plan, effective_params)

	if(!rendered_with_placement_layers && length(result.preview_images))
		holder.images += result.preview_images
		preview_images = result.preview_images.Copy()

	last_preview_success = result.success ? TRUE : FALSE
	last_preview_message = result.message
	last_preview_meta = sanitize_preview_feedback_meta(result.meta)

	if(result.success)
		mark_preview_state()
		to_chat(user, SPAN_NOTICE(result.message))
	else
		invalidate_preview_state()
		to_chat(user, SPAN_WARNING(result.message))

	return result

/datum/world_edit_manager/proc/run_apply(mob/user)
	if(!holder || !check_rights_for(holder, R_DEBUG))
		return fail_apply(user, "Недостаточно прав для применения в панели редактирования мира.")
	if(!current_generator || !current_definition)
		return fail_apply(user, "Сначала выберите генератор.")
	if(!check_rights_for(holder, current_definition.required_rights))
		return fail_apply(user, "Недостаточно прав для применения этого генератора.")

	var/list/effective_params = build_effective_generator_params()
	var/error_text = current_generator.validate_params(user, effective_params)
	if(error_text)
		return fail_apply(user, error_text)

	if(current_generator.requires_preview_before_apply && !is_preview_state_valid())
		return fail_apply(user, "Предпросмотр не готов.")

	if(click_intercept_owned)
		return fail_apply(user, "Остановите активный режим размещения перед обычным применением.")

	if(confirm_before_apply)
		var/confirm_text = current_generator.get_apply_confirmation_text(effective_params)
		var/answer = tgui_alert(user, confirm_text, "Панель размещения: подтверждение", list("Подтвердить", "Отмена"))
		if(answer != "Подтвердить")
			return null

	var/start_ds = world.time
	var/datum/world_edit_apply_result/result = current_generator.apply(user, effective_params)
	if(!istype(result))
		return fail_apply(user, "Генератор вернул некорректный результат применения.")

	record_apply_result(user, result, world.time - start_ds)

	if(current_definition.execution_mode != WORLD_EDIT_EXECUTION_CLICK)
		reset_preview_runtime()

	return result

/datum/world_edit_manager/proc/fail_preview(mob/user, message)
	teardown_preview_session_runtime()
	last_preview_success = FALSE
	last_preview_message = message
	last_preview_meta = list()
	invalidate_preview_state()
	to_chat(user, SPAN_WARNING(message))
	return null

/datum/world_edit_manager/proc/fail_apply(mob/user, message)
	last_apply_success = FALSE
	last_apply_message = message
	to_chat(user, SPAN_WARNING(message))
	return null

/datum/world_edit_manager/proc/fail_undo_action(mob/user, action_kind, message)
	last_undo_action = action_kind
	last_undo_success = FALSE
	last_undo_message = message
	to_chat(user, SPAN_WARNING(message))
	return FALSE

/datum/world_edit_manager/proc/record_apply_result(mob/user, datum/world_edit_apply_result/result, duration_ds)
	var/turf/center_turf = result.center_turf || get_turf(user)
	var/params_short = current_generator.get_params_short(build_effective_generator_params())
	var/result_code = result.success ? "ok" : "error"
	var/datum/world_edit_changeset/changeset
	if(result.success && istype(result.changeset))
		changeset = result.changeset
		if(!length(changeset.generator_id))
			changeset.generator_id = current_definition.id
		if(!islist(changeset.metadata))
			changeset.metadata = list()
		if(center_turf && !changeset.metadata["center_turf"])
			changeset.metadata["center_turf"] = center_turf
		changeset = push_changeset(changeset)

	GLOB.world_edit_logging.log_operation(
		holder,
		current_definition.id,
		current_definition.required_rights,
		center_turf,
		result.created_count,
		result.deleted_count,
		duration_ds,
		result_code,
		params_short
	)
	if(!result.suppress_history)
		add_history_entry(
			current_definition.id,
			result_code,
			result.created_count,
			result.deleted_count,
			center_turf,
			params_short,
			result.message,
			duration_ds * 100,
			build_changeset_history_meta(changeset)
		)

	last_apply_success = result.success ? TRUE : FALSE
	last_apply_message = result.message

	if(result.success)
		to_chat(user, SPAN_NOTICE(result.message))
	else
		to_chat(user, SPAN_WARNING(result.message))

	return result

/datum/world_edit_manager/proc/undo_last_operation(mob/user)
	if(!holder || !check_rights_for(holder, R_DEBUG))
		return fail_undo_action(user, "undo", "Недостаточно прав для отката в панели редактирования мира.")

	var/datum/world_edit_changeset/changeset = get_last_changeset()
	if(!istype(changeset))
		return fail_undo_action(user, "undo", "В текущей сессии нет операции для отката.")
	if(!changeset.can_undo())
		return fail_undo_action(user, "undo", "Последняя операция не поддерживает откат на этой стадии.")

	var/list/undo_result = GLOB.world_edit_changesets.revert_changeset(changeset)
	var/reverted_count = text2num("[undo_result["reverted_count"]]") || 0
	var/skipped_count = text2num("[undo_result["skipped_count"]]") || 0
	var/outcome = "[undo_result["outcome"] || "none"]"
	var/message = "Откат [changeset.generator_id] ([changeset.undo_policy]): восстановлено=[reverted_count], пропущено=[skipped_count], итог=[outcome]."
	var/turf/center_turf = changeset.metadata["center_turf"] || get_turf(user)
	var/params_short = "source=[changeset.generator_id]; operation_id=[changeset.operation_id]; policy=[changeset.undo_policy]"
	var/result_code = (outcome == "full") ? "undo_ok" : ((outcome == "partial") ? "undo_partial" : "undo_skipped")

	changeset.created_entries = list()
	changeset.moved_entries = list()
	changeset.changed_turf_entries = list()
	prune_changeset_stack()
	reset_preview_runtime()

	last_undo_action = "undo"
	last_undo_success = reverted_count > 0 ? TRUE : FALSE
	last_undo_message = message

	GLOB.world_edit_logging.log_operation(holder, "undo_last_operation", 0, center_turf, 0, reverted_count, 0, result_code, params_short)
	add_history_entry(
		"undo_last_operation",
		result_code,
		0,
		reverted_count,
		center_turf,
		params_short,
		message,
		0,
		list(
			"undo_policy" = changeset.undo_policy,
			"undo_status" = outcome,
			"reverted_count" = reverted_count,
			"skipped_count" = skipped_count,
			"source_operation_id" = changeset.operation_id,
			"source_generator_id" = changeset.generator_id,
		)
	)

	if(reverted_count > 0)
		to_chat(user, SPAN_NOTICE(message))
	else
		to_chat(user, SPAN_WARNING(message))

	return undo_result

/datum/world_edit_manager/proc/cleanup_last_owned_effects(mob/user)
	if(!holder || !check_rights_for(holder, R_DEBUG))
		return fail_undo_action(user, "cleanup", "Недостаточно прав для очистки связанных эффектов.")

	var/datum/world_edit_changeset/changeset = get_last_changeset()
	if(!istype(changeset))
		return fail_undo_action(user, "cleanup", "В текущей сессии нет операции для очистки связанных эффектов.")
	if(!changeset.can_cleanup_owned_effects())
		return fail_undo_action(user, "cleanup", "Последняя операция не содержит связанных эффектов для очистки.")

	var/list/cleanup_result = GLOB.world_edit_changesets.cleanup_changeset_owned_effects(changeset)
	var/removed_count = text2num("[cleanup_result["reverted_count"]]") || 0
	var/skipped_count = text2num("[cleanup_result["skipped_count"]]") || 0
	var/outcome = "[cleanup_result["outcome"] || "none"]"
	var/message = "Очистка связанных эффектов для [changeset.generator_id]: удалено=[removed_count], пропущено=[skipped_count], итог=[outcome]."
	var/turf/center_turf = changeset.metadata["center_turf"] || get_turf(user)
	var/params_short = "source=[changeset.generator_id]; operation_id=[changeset.operation_id]"
	var/result_code = (outcome == "full") ? "cleanup_ok" : ((outcome == "partial") ? "cleanup_partial" : "cleanup_skipped")

	changeset.owned_effect_entries = list()
	prune_changeset_stack()
	reset_preview_runtime()

	last_undo_action = "cleanup"
	last_undo_success = removed_count > 0 ? TRUE : FALSE
	last_undo_message = message

	GLOB.world_edit_logging.log_operation(holder, "cleanup_last_owned_effects", 0, center_turf, 0, removed_count, 0, result_code, params_short)
	add_history_entry(
		"cleanup_last_owned_effects",
		result_code,
		0,
		removed_count,
		center_turf,
		params_short,
		message,
		0,
		list(
			"undo_policy" = changeset.undo_policy,
			"undo_status" = outcome,
			"reverted_count" = removed_count,
			"skipped_count" = skipped_count,
			"source_operation_id" = changeset.operation_id,
			"source_generator_id" = changeset.generator_id,
		)
	)

	if(removed_count > 0)
		to_chat(user, SPAN_NOTICE(message))
	else
		to_chat(user, SPAN_WARNING(message))

	return cleanup_result
