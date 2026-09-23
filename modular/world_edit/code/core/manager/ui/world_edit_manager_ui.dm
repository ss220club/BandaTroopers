/datum/world_edit_manager/tgui_interact(mob/user, datum/tgui/ui)
	if(!holder || QDELETED(holder) || holder != user?.client)
		return
	if(!check_rights_for(holder, R_DEBUG))
		return
	ensure_default_generator_selected()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WorldEditPanel")
		ui.open()

/datum/world_edit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/world_edit_manager/ui_close(mob/user)
	. = ..()
	reset_preview_runtime()

/datum/world_edit_manager/ui_static_data(mob/user)
	if(!holder || holder != user?.client || !check_rights_for(holder, R_DEBUG))
		return list()

	var/list/data = list()
	data["categories"] = build_available_generator_categories()
	return data

/datum/world_edit_manager/ui_data(mob/user)
	if(!holder || holder != user?.client || !check_rights_for(holder, R_DEBUG))
		return list()

	append_runtime_trace("ui_data:start", build_runtime_trace_gc_snapshot_if_enabled())
	ensure_preset_cache_loaded()
	ensure_blueprint_cache_loaded()
	ensure_default_generator_selected()
	var/ui_data_started_at = REALTIMEOFDAY
	var/list/payload = build_ui_data_payload(user)
	var/field_count = islist(payload["ui_fields"]) ? length(payload["ui_fields"]) : 0
	var/history_count = islist(payload["history_entries"]) ? length(payload["history_entries"]) : 0
	record_runtime_diagnostic_duration("ui_data", ui_data_started_at)
	append_runtime_trace("ui_data:done", "fields=[field_count] history=[history_count]")
	return payload

/datum/world_edit_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!holder || holder != ui.user?.client)
		return
	if(!check_rights_for(holder, R_DEBUG))
		return
	if(handle_generator_ui_action(ui.user, action, params))
		return TRUE
	if(handle_preset_ui_action(ui.user, action, params))
		return TRUE
	if(handle_blueprint_ui_action(ui.user, action, params))
		return TRUE
	if(handle_placement_ui_action(ui.user, action, params))
		return TRUE
	if(handle_runtime_ui_action(ui.user, action, params))
		return TRUE
	return FALSE
