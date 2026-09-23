/datum/world_edit_manager/proc/fail_blueprint_action(mob/user, message)
	last_ui_error = message
	to_chat(user, SPAN_WARNING(message))
	return FALSE

/datum/world_edit_manager/proc/check_blueprint_library_runtime_action_allowed(mob/user)
	return TRUE

/datum/world_edit_manager/proc/import_blueprint_file(mob/user)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE

	var/import_file = input(user, "Выберите .dmm blueprint для импорта в серверную библиотеку.", "World Edit: импорт DMM blueprint") as null|file
	if(!import_file)
		return FALSE

	var/list/import_result = GLOB.world_edit_blueprints.world_edit_import_blueprint_file(import_file)
	if(import_result["error"])
		return fail_blueprint_action(user, import_result["error"])

	refresh_blueprint_cache()
	last_ui_error = ""
	to_chat(user, SPAN_NOTICE("DMM blueprint '[import_result["blueprint"]["id"]]' импортирован в серверную библиотеку."))
	return TRUE

/datum/world_edit_manager/proc/export_blueprint_file(mob/user, blueprint_id)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE
	if(!user?.client)
		return fail_blueprint_action(user, "Не удалось определить клиента для экспорта DMM blueprint.")
	if(user.client.file_spam_check())
		return FALSE

	var/list/entry = find_cached_blueprint_entry(blueprint_id)
	if(!islist(entry))
		return fail_blueprint_action(user, "DMM blueprint не найден.")
	if(!entry["valid"])
		return fail_blueprint_action(user, entry["error"] || "DMM blueprint невалиден.")

	var/file_path = entry["file_path"]
	var/expected_path = GLOB.world_edit_blueprints.world_edit_get_blueprint_file_path(entry["id"])
	if(!length("[file_path]") || !expected_path || file_path != expected_path || !fexists(file_path))
		return fail_blueprint_action(user, "Файл DMM blueprint не найден.")

	user << ftp(file(file_path), "[entry["id"]][WORLD_EDIT_BLUEPRINT_EXTENSION]")
	last_ui_error = ""
	to_chat(user, SPAN_NOTICE("Экспорт DMM blueprint '[entry["id"]]' отправлен клиенту."))
	return TRUE

/datum/world_edit_manager/proc/rename_blueprint_file(mob/user, blueprint_id)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE

	var/raw_current_id = "[blueprint_id]"
	var/current_id = sanitize_filename(raw_current_id)
	if(!length(current_id) || current_id != raw_current_id)
		return fail_blueprint_action(user, "DMM blueprint не найден.")

	var/raw_name = tgui_input_text(user, "Введите новое имя файла без расширения .dmm.", "World Edit: переименовать DMM blueprint", current_id, WORLD_EDIT_BLUEPRINT_ID_LEN, FALSE, FALSE)
	if(isnull(raw_name))
		return FALSE

	var/new_id = trim("[raw_name]")
	if(!length(new_id))
		return fail_blueprint_action(user, "Новое имя DMM blueprint пустое.")
	var/safe_new_id = sanitize_filename(new_id)
	if(safe_new_id != new_id)
		return fail_blueprint_action(user, "Новое имя DMM blueprint содержит запрещенные символы.")

	var/was_active = get_active_blueprint_id() == current_id
	var/list/rename_result = GLOB.world_edit_blueprints.world_edit_rename_blueprint_file(current_id, safe_new_id)
	if(rename_result["error"])
		return fail_blueprint_action(user, rename_result["error"])

	refresh_blueprint_cache()
	if(was_active && current_definition?.id == "blueprint_stamp")
		if(!islist(current_params))
			current_params = list()
		current_params["blueprint_id"] = rename_result["blueprint_id"]
		save_current_generator_context()
		invalidate_active_blueprint_revision_cache()
	last_ui_error = ""
	to_chat(user, SPAN_NOTICE("DMM blueprint '[current_id]' переименован в '[rename_result["blueprint_id"]]'."))
	return TRUE

/datum/world_edit_manager/proc/delete_blueprint_file(mob/user, blueprint_id)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE

	var/raw_current_id = "[blueprint_id]"
	var/current_id = sanitize_filename(raw_current_id)
	if(!length(current_id) || current_id != raw_current_id)
		return fail_blueprint_action(user, "DMM blueprint не найден.")

	var/confirmation = tgui_alert(user, "Удалить DMM blueprint '[current_id]' из серверной библиотеки?", "World Edit: удалить DMM blueprint", list("Удалить", "Отмена"))
	if(confirmation != "Удалить")
		return FALSE

	var/was_active = get_active_blueprint_id() == current_id
	var/list/delete_result = GLOB.world_edit_blueprints.world_edit_delete_blueprint_file(current_id)
	if(delete_result["error"])
		return fail_blueprint_action(user, delete_result["error"])

	if(was_active)
		reset_current_generator()
	refresh_blueprint_cache()
	last_ui_error = ""
	to_chat(user, SPAN_NOTICE("DMM blueprint '[current_id]' удален из серверной библиотеки."))
	return TRUE

/datum/world_edit_manager/proc/load_blueprint_into_manager(mob/user, blueprint_id)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE

	if(!activate_blueprint_generator(user, blueprint_id, FALSE))
		return FALSE

	to_chat(user, SPAN_NOTICE("Шаблон '[blueprint_id]' загружен в генератор Штамп шаблона."))
	return TRUE

/datum/world_edit_manager/proc/preview_blueprint_by_id(mob/user, blueprint_id)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE

	if(!activate_blueprint_generator(user, blueprint_id, FALSE))
		return FALSE
	return run_preview(user)

/datum/world_edit_manager/proc/apply_blueprint_by_id(mob/user, blueprint_id)
	if(!check_blueprint_library_runtime_action_allowed(user))
		return FALSE

	if(!activate_blueprint_generator(user, blueprint_id, TRUE))
		return FALSE
	if(has_active_safe_placement_preview())
		return apply_safe_placement_current_plan(user)
	if(is_safe_placement_mode_active())
		return fail_blueprint_action(user, "Сначала выполните предпросмотр выбранного шаблона.")

	var/datum/world_edit_preview_result/preview_result = run_preview(user)
	if(!istype(preview_result))
		return null
	if(!preview_result.success)
		return preview_result
	if(!is_preview_state_valid())
		return fail_blueprint_action(user, "Сначала выполните предпросмотр выбранного шаблона.")
	return run_apply(user)

/datum/world_edit_manager/proc/can_save_blueprint_from_current_plan()
	if(!("[current_definition?.id]" in list("outpost_radius", "building_layout")))
		return FALSE
	return is_preview_state_valid() && istype(get_current_preview_plan(), /datum/world_edit_plan)

/datum/world_edit_manager/proc/save_blueprint_from_current_plan(mob/user)
	if(!can_save_blueprint_from_current_plan())
		return fail_blueprint_action(user, "Run a supported generator preview before saving a DMM blueprint.")

	var/datum/world_edit_plan/current_plan = get_current_preview_plan()
	var/turf/anchor_turf = current_plan?.metadata["center_turf"]
	if(!anchor_turf)
		anchor_turf = get_turf(user)

	var/default_name = current_definition?.id == "building_layout" ? "building_layout_blueprint" : "outpost_blueprint"
	var/raw_name = tgui_input_text(user, "Enter blueprint file name. The current preview plan will be saved as a DMM blueprint.", "World Edit: save DMM blueprint", default_name, WORLD_EDIT_BLUEPRINT_NAME_MAX_LEN, FALSE, FALSE)
	if(isnull(raw_name))
		return FALSE

	var/blueprint_name = trim("[raw_name]")
	if(!length(sanitize_filename(blueprint_name)))
		blueprint_name = default_name

	var/list/export_result = GLOB.world_edit_blueprints.world_edit_export_blueprint_from_plan(current_definition?.id, current_plan, anchor_turf, blueprint_name, holder?.ckey)
	if(export_result["error"])
		return fail_blueprint_action(user, export_result["error"])

	var/file_path = GLOB.world_edit_blueprints.world_edit_get_blueprint_file_path(export_result["blueprint"]["id"])
	if(!file_path)
		return fail_blueprint_action(user, "Некорректное имя DMM blueprint.")
	if(fexists(file_path))
		return fail_blueprint_action(user, "DMM blueprint с именем '[export_result["blueprint"]["id"]]' уже существует.")

	file_path = GLOB.world_edit_blueprints.world_edit_save_blueprint_definition(export_result["blueprint"])
	if(!file_path)
		return fail_blueprint_action(user, "Не удалось сохранить шаблон на сервере.")

	refresh_blueprint_cache()
	last_ui_error = ""
	to_chat(user, SPAN_NOTICE("Шаблон '[export_result["blueprint"]["name"]]' сохранён в библиотеку."))
	return TRUE
