/datum/modpack
	/// A string name for the modpack. Used for looking up other modpacks in init.
	var/name
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	var/desc
	/// A string with authors of this modpack.
	var/author

/datum/modpack/proc/pre_initialize()
	if(!name)
		return "Modpack name is unset."

/datum/modpack/proc/initialize()
	return

/datum/modpack/proc/post_initialize()
	return

// SS220 DemonicLynx "Lobby UI" - neutral optional provider contract; null/no-op behavior keeps the upstream classic interface.
/datum/modpack/proc/lobby_ui_show_lobby(mob/new_player/player, refresh = FALSE)
	return FALSE

/datum/modpack/proc/lobby_ui_hide(mob/user)
	return

/datum/modpack/proc/lobby_ui_play_click(mob/new_player/player)
	return

/datum/modpack/proc/lobby_ui_play_title_music(client/player_client)
	return FALSE

/datum/modpack/proc/lobby_ui_show_manifest(mob/new_player/player, manifest_html)
	return FALSE

/datum/modpack/proc/lobby_ui_load_preferences(datum/preferences/preferences, savefile/preferences_file)
	return

/datum/modpack/proc/lobby_ui_save_preferences(datum/preferences/preferences, savefile/preferences_file)
	return

/datum/modpack/proc/lobby_ui_refresh_event_panels(datum/custom_event_info/event_info)
	return

/datum/modpack/proc/lobby_ui_equip_character_preview(datum/preferences/preferences, mob/living/carbon/human/preview_dummy, datum/job/job)
	return FALSE

/datum/modpack/proc/lobby_ui_flavor_text_presentation(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_flavor_text_window_title(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_keybind_presentation(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_uses_custom_character_editor(datum/preferences/preferences)
	return FALSE

/datum/modpack/proc/lobby_ui_character_header(datum/preferences/preferences, mob/user)
	return null

/datum/modpack/proc/lobby_ui_character_footer(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_show_character_editor(datum/preferences/preferences, mob/user, html)
	return FALSE

/datum/modpack/proc/lobby_ui_character_equipment_controls(datum/preferences/preferences, mob/user)
	return null

/datum/modpack/proc/lobby_ui_interface_controls(datum/preferences/preferences)
	return null

/datum/modpack/proc/lobby_ui_show_job_preferences(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return FALSE

/datum/modpack/proc/lobby_ui_show_job_slots(datum/preferences/preferences, mob/user, limit, list/split_jobs, width, height)
	return FALSE

/datum/modpack/proc/lobby_ui_show_records(datum/preferences/preferences, mob/user)
	return FALSE

/datum/modpack/proc/lobby_ui_show_load_dialog(datum/preferences/preferences, mob/user)
	return FALSE

/datum/modpack/proc/lobby_ui_handle_preferences_topic(datum/preferences/preferences, mob/user, list/href_list)
	return FALSE

/datum/modpack/proc/lobby_ui_localized_choice(datum/preferences/preferences, mob/user, prompt, title, list/options)
	return tgui_input_list(user, prompt, title, options)

/datum/modpack/proc/lobby_ui_translate_text(datum/preferences/preferences, text)
	return text

/datum/modpack/proc/lobby_ui_text_input(datum/preferences/preferences, mob/user, prompt, title, default_value, max_length = MAX_MESSAGE_LEN, multiline = FALSE)
	return tgui_input_text(user, prompt, title, default_value, max_length, multiline, encode = FALSE)

/datum/modpack/proc/lobby_ui_number_input(datum/preferences/preferences, mob/user, prompt, title, default_value, max_value, min_value)
	return tgui_input_number(user, prompt, title, default_value, max_value, min_value)

/// Optional post-success notification. Never changes persistence or classic rendering.
/datum/modpack/proc/lobby_ui_character_persisted(datum/preferences/preferences, action)
	return
