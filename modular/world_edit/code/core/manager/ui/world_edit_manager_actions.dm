/datum/world_edit_manager/proc/handle_generator_ui_action(mob/user, action, list/params)
	switch(action)
		if("select_generator")
			if(set_generator_by_id(params["generator_id"]))
				last_ui_error = ""
			return TRUE

		if("reset_generator")
			reset_current_generator()
			to_chat(user, SPAN_NOTICE("Текущий генератор сброшен."))
			return TRUE

		if("set_param")
			return handle_set_param_action(user, params)

	return FALSE

/datum/world_edit_manager/proc/handle_preset_ui_action(mob/user, action, list/params)
	switch(action)
		if("save_preset")
			save_current_preset(user)
			return TRUE

		if("load_preset")
			load_preset_by_id(user, params["preset_id"])
			return TRUE

		if("delete_preset")
			delete_preset_by_id(user, params["preset_id"])
			return TRUE

	return FALSE

/datum/world_edit_manager/proc/handle_blueprint_ui_action(mob/user, action, list/params)
	switch(action)
		if("list_blueprints")
			refresh_blueprint_cache()
			last_ui_error = ""
			return TRUE

		if("save_blueprint")
			save_blueprint_from_current_plan(user)
			return TRUE

		if("import_blueprint")
			import_blueprint_file(user)
			return TRUE

		if("export_blueprint")
			export_blueprint_file(user, params["blueprint_id"])
			return TRUE

		if("rename_blueprint")
			rename_blueprint_file(user, params["blueprint_id"])
			return TRUE

		if("delete_blueprint")
			delete_blueprint_file(user, params["blueprint_id"])
			return TRUE

		if("load_blueprint")
			load_blueprint_into_manager(user, params["blueprint_id"])
			return TRUE

		if("preview_blueprint")
			preview_blueprint_by_id(user, params["blueprint_id"])
			return TRUE

		if("apply_blueprint")
			apply_blueprint_by_id(user, params["blueprint_id"])
			return TRUE

	return FALSE

/datum/world_edit_manager/proc/handle_placement_ui_action(mob/user, action, list/params)
	switch(action)
		if("set_placement_mode")
			var/new_mode = "[params["mode"]]"
			if(!(new_mode in get_supported_placement_modes()))
				last_ui_error = "Выбранный режим размещения недоступен для текущего генератора."
				to_chat(user, SPAN_WARNING(last_ui_error))
				return TRUE
			placement_shared_mode = new_mode
			placement_mode = new_mode
			last_ui_error = ""
			rebuild_runtime_after_generator_config_change(user, TRUE, FALSE, FALSE, TRUE)
			return TRUE

		if("set_placement_shape")
			var/old_shape = get_effective_placement_shape()
			var/new_shape = "[params["shape"]]"
			if(!(new_shape in get_supported_placement_shapes()))
				last_ui_error = "Выбранная форма размещения недоступна для текущего генератора."
				to_chat(user, SPAN_WARNING(last_ui_error))
				return TRUE
			placement_shared_shape = new_shape
			placement_shape = new_shape
			last_ui_error = ""
			var/preserve_shape_progress = can_preserve_active_placement_for_shape_change(old_shape, new_shape)
			rebuild_runtime_after_generator_config_change(user, preserve_shape_progress, !preserve_shape_progress, !preserve_shape_progress, preserve_shape_progress)
			return TRUE

		if("set_placement_dir")
			if(!supports_current_placement_direction())
				return TRUE
			placement_shared_dir = GLOB.world_edit_helpers.dir_from_label("[params["direction"]]", current_generator?.get_default_placement_direction() || NORTH)
			placement_shared_dir_uses_facing = FALSE
			placement_dir = resolve_supported_placement_dir(placement_shared_dir)
			placement_dir_uses_facing = FALSE
			last_ui_error = ""
			rebuild_runtime_after_generator_config_change(user, TRUE, FALSE, FALSE, TRUE)
			return TRUE

		if("set_placement_dir_uses_facing")
			if(!supports_current_placement_direction())
				return TRUE
			placement_shared_dir_uses_facing = GLOB.world_edit_helpers.parse_bool(params["enabled"])
			placement_dir_uses_facing = placement_shared_dir_uses_facing
			last_ui_error = ""
			rebuild_runtime_after_generator_config_change(user, TRUE, FALSE, FALSE, TRUE)
			return TRUE

		if("set_confirm_before_apply")
			confirm_before_apply = GLOB.world_edit_helpers.parse_bool(params["enabled"])
			last_ui_error = ""
			return TRUE

		if("start_placement_mode")
			start_safe_placement_mode(user)
			return TRUE

		if("finish_placement_collection")
			finish_placement_collection(user)
			return TRUE

	return FALSE

/datum/world_edit_manager/proc/handle_runtime_ui_action(mob/user, action, list/params)
	switch(action)
		if("run_preview")
			run_preview(user)
			return TRUE

		if("run_apply")
			run_apply(user)
			return TRUE

		if("undo_last_operation")
			undo_last_operation(user)
			return TRUE

		if("cleanup_last_owned_effects")
			cleanup_last_owned_effects(user)
			return TRUE

		if("clear_preview")
			refresh_runtime_after_config_change()
			to_chat(user, SPAN_NOTICE("Предпросмотр очищен."))
			return TRUE

		if("stop_click_mode")
			reset_preview_runtime()
			to_chat(user, SPAN_NOTICE("Режим размещения остановлен."))
			return TRUE

		if("clear_history")
			clear_operation_history(user)
			return TRUE

	return FALSE

/datum/world_edit_manager/proc/clear_operation_history(mob/user)
	history_entries = list()
	if(islist(changeset_entries))
		for(var/datum/world_edit_changeset/changeset as anything in changeset_entries)
			qdel(changeset)
	changeset_entries = list()
	reset_undo_feedback()
	to_chat(user, SPAN_NOTICE("История операций и undo-стек очищены."))
	return TRUE
