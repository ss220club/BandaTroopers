/datum/world_edit_manager/proc/build_preset_ui_payload()
	return list(
		"can_manage_presets" = can_manage_current_generator_presets(),
		"preset_entries" = get_current_generator_presets(),
	)

/datum/world_edit_manager/proc/build_blueprint_ui_payload(mob/user = null)
	return list(
		"blueprint_entries" = get_blueprint_entries_for_ui(),
		"active_blueprint_id" = get_active_blueprint_id(),
		"active_blueprint_preview" = get_active_blueprint_sprite_preview_for_ui(user),
		"can_save_blueprint_from_plan" = can_save_blueprint_from_current_plan(),
	)
