/client/proc/open_admin_music_panel()
	set name = "Admin Music Panel"
	set category = "Admin"

	if(!check_rights(R_SOUNDS))
		return

	new /datum/admin_music_panel(src)

/datum/admin_music_panel
	var/client/holder
	var/datum/admin_music_preset/draft
	var/draft_token = 0
	var/dirty = FALSE
	var/selected_tier_id
	var/selected_variant_id
	var/list/preview_command
	var/preview_nonce = 0
	var/closing = FALSE

/datum/admin_music_panel/New(client/new_holder)
	holder = new_holder
	draft = GLOB.admin_music_service.build_default_preset()
	draft_token = 1
	. = ..()
	sync_selection()
	GLOB.admin_music_service.register_panel(src)
	if(holder && holder.mob)
		tgui_interact(holder.mob)

/datum/admin_music_panel/Destroy()
	GLOB.admin_music_service.unregister_panel(src)
	holder = null
	draft = null
	preview_command = null
	return ..()

/datum/admin_music_panel/proc/sync_selection()
	if(!draft)
		selected_tier_id = null
		selected_variant_id = null
		return

	var/datum/admin_music_tier/selected_tier = draft.find_tier_by_ref(selected_tier_id)
	if(!selected_tier && length(draft.tiers))
		selected_tier = draft.tiers[1]
		selected_tier_id = REF(selected_tier)

	var/datum/admin_music_variant/selected_variant = selected_tier?.find_variant_by_ref(selected_variant_id)
	if(!selected_variant && selected_tier && length(selected_tier.variants))
		selected_variant = selected_tier.variants[1]
		selected_variant_id = REF(selected_variant)

/datum/admin_music_panel/proc/get_selected_tier()
	sync_selection()
	return draft?.find_tier_by_ref(selected_tier_id)

/datum/admin_music_panel/proc/get_selected_variant()
	var/datum/admin_music_tier/tier = get_selected_tier()
	if(!tier)
		return null
	return tier.find_variant_by_ref(selected_variant_id)

/datum/admin_music_panel/proc/get_action_tier(tier_id = null)
	if(isnull(tier_id))
		return get_selected_tier()
	return draft?.find_tier_by_ref(tier_id)

/datum/admin_music_panel/proc/get_action_variant(tier_id = null, variant_id = null)
	var/datum/admin_music_tier/tier = get_action_tier(tier_id)
	if(!tier)
		return null
	if(isnull(variant_id))
		if(isnull(tier_id))
			return get_selected_variant()
		if(REF(tier) == selected_tier_id)
			return tier.find_variant_by_ref(selected_variant_id)
		return null
	return tier.find_variant_by_ref(variant_id)

/datum/admin_music_panel/proc/build_next_scene_name()
	var/index = 1
	var/list/used_names = list()
	for(var/datum/admin_music_tier/tier as anything in draft?.tiers)
		used_names[lowertext(trim("[tier.name]"))] = TRUE
	while(used_names[lowertext("Scene [index]")])
		index++
	return "Scene [index]"

/datum/admin_music_panel/proc/build_next_track_title(datum/admin_music_tier/tier)
	var/index = 1
	var/list/used_titles = list()
	for(var/datum/admin_music_variant/variant as anything in tier?.variants)
		used_titles[lowertext(trim("[variant.title]"))] = TRUE
	while(used_titles[lowertext("Track [index]")])
		index++
	return "Track [index]"

/datum/admin_music_panel/proc/mark_dirty()
	dirty = TRUE
	return update_ui()

/datum/admin_music_panel/proc/update_ui()
	GLOB.admin_music_service.update_open_panels()
	return TRUE

/datum/admin_music_panel/proc/load_draft(datum/admin_music_preset/new_draft, new_dirty = FALSE)
	draft = new_draft
	if(!draft)
		draft = GLOB.admin_music_service.build_default_preset()
	draft_token++
	dirty = new_dirty
	preview_command = null
	sync_selection()
	GLOB.admin_music_service.update_open_panels()
	return TRUE

/datum/admin_music_panel/proc/confirm_discard_changes(message, title = "Unsaved Changes")
	if(!dirty)
		return TRUE
	var/target = holder
	if(holder && holder.mob)
		target = holder.mob
	return tgui_alert(target, message, title, list("Discard Changes", "Cancel")) == "Discard Changes"

/datum/admin_music_panel/proc/prompt_close_action()
	if(!dirty)
		return "Discard Changes"
	var/target = holder
	if(holder && holder.mob)
		target = holder.mob
	return tgui_alert(
		target,
		"Save Admin Music Panel changes before closing?",
		"Unsaved Changes",
		list("Save Changes", "Discard Changes", "Cancel"),
	)

/datum/admin_music_panel/proc/request_close()
	if(closing)
		return FALSE
	if(dirty)
		var/close_choice = prompt_close_action()
		if(close_choice == "Save Changes")
			var/datum/admin_music_preset/saved_preset = GLOB.admin_music_service.save_draft(holder, draft, FALSE)
			if(!saved_preset)
				return FALSE
		else if(close_choice != "Discard Changes")
			return FALSE
	closing = TRUE
	qdel(src)
	return TRUE

/datum/admin_music_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminMusicPanel", "Admin Music Panel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/admin_music_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_music_panel/ui_status(mob/user, datum/ui_state/state)
	if(!holder || !check_rights_for(holder, R_SOUNDS))
		return UI_CLOSE
	if(user != holder.mob)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admin_music_panel/ui_data(mob/user)
	sync_selection()
	return list(
		"library" = GLOB.admin_music_service.build_library_ui_data(),
		"draft" = draft?.to_ui_data(),
		"draft_token" = draft_token,
		"dirty" = dirty,
		"selected_tier_id" = selected_tier_id,
		"selected_variant_id" = selected_variant_id,
		"can_delete_saved_preset" = !!(draft?.preset_id && GLOB.admin_music_service.find_preset(draft.preset_id)),
		"current_session" = GLOB.admin_music_service.build_session_ui_data(),
		"audience_options" = GLOB.admin_music_service.get_audience_options(),
		"sound_type_options" = GLOB.admin_music_service.get_sound_type_options(),
		"preview_command" = preview_command,
	)

/datum/admin_music_panel/ui_close(mob/user)
	if(closing)
		return
	qdel(src)

/datum/admin_music_panel/proc/set_preview_command(command, list/payload = null)
	preview_nonce++
	preview_command = list("nonce" = preview_nonce, "command" = command)
	if(islist(payload))
		for(var/key in payload)
			preview_command[key] = payload[key]
	return TRUE

/datum/admin_music_panel/proc/coerce_ui_boolean(raw_value, fallback = FALSE)
	if(isnull(raw_value))
		return fallback
	if(isnum(raw_value))
		return raw_value ? TRUE : FALSE
	var/text_value = lowertext(trim("[raw_value]"))
	if(text_value in list("1", "true", "yes", "on"))
		return TRUE
	if(text_value in list("0", "false", "no", "off"))
		return FALSE
	return fallback

/datum/admin_music_panel/proc/is_digit_string(text_value)
	if(!length(text_value))
		return FALSE
	for(var/index in 1 to length(text_value))
		var/character = text2ascii(text_value, index)
		if(character < 48 || character > 57)
			return FALSE
	return TRUE

/datum/admin_music_panel/proc/parse_duration_seconds(raw_value)
	if(isnull(raw_value))
		return 0
	if(isnum(raw_value))
		return max(round(raw_value), 0)

	var/text_value = trim("[raw_value]")
	if(!length(text_value))
		return 0
	if(!findtext(text_value, ":"))
		if(!is_digit_string(text_value))
			return 0
		return max(round(text2num(text_value)), 0)

	var/list/parts = splittext(text_value, ":")
	var/part_count = length(parts)
	if(part_count < 2 || part_count > 3)
		return 0

	var/list/numeric_parts = list()
	for(var/part in parts)
		var/trimmed_part = trim("[part]")
		if(!is_digit_string(trimmed_part))
			return 0
		numeric_parts += text2num(trimmed_part)

	if(part_count == 2)
		var/minutes = numeric_parts[1]
		var/seconds = numeric_parts[2]
		if(seconds >= 60)
			return 0
		return max(round(minutes * 60 + seconds), 0)

	var/hours = numeric_parts[1]
	var/remaining_minutes = numeric_parts[2]
	var/remaining_seconds = numeric_parts[3]
	if(remaining_minutes >= 60 || remaining_seconds >= 60)
		return 0
	return max(round(hours * 3600 + remaining_minutes * 60 + remaining_seconds), 0)

/datum/admin_music_panel/proc/select_tier(tier_id)
	if(selected_tier_id != tier_id)
		selected_variant_id = null
	selected_tier_id = tier_id
	sync_selection()
	return update_ui()

/datum/admin_music_panel/proc/select_variant(tier_id, variant_id)
	selected_tier_id = tier_id
	selected_variant_id = variant_id
	sync_selection()
	return update_ui()

/datum/admin_music_panel/proc/get_tier_index(tier_id)
	if(!draft)
		return 0
	for(var/index in 1 to length(draft.tiers))
		var/datum/admin_music_tier/tier = draft.tiers[index]
		if(REF(tier) == tier_id)
			return index
	return 0

/datum/admin_music_panel/proc/get_variant_index(datum/admin_music_tier/tier, variant_id)
	if(!tier)
		return 0
	for(var/index in 1 to length(tier.variants))
		var/datum/admin_music_variant/variant = tier.variants[index]
		if(REF(variant) == variant_id)
			return index
	return 0

/datum/admin_music_panel/proc/move_tier(tier_id, offset)
	var/current_index = get_tier_index(tier_id)
	if(!current_index)
		return FALSE
	var/target_index = current_index + offset
	if(target_index < 1 || target_index > length(draft.tiers))
		return FALSE
	draft.tiers.Swap(current_index, target_index)
	sync_selection()
	return mark_dirty()

/datum/admin_music_panel/proc/move_variant(tier_id, variant_id, offset)
	var/datum/admin_music_tier/tier = draft?.find_tier_by_ref(tier_id)
	if(!tier)
		return FALSE
	var/current_index = get_variant_index(tier, variant_id)
	if(!current_index)
		return FALSE
	var/target_index = current_index + offset
	if(target_index < 1 || target_index > length(tier.variants))
		return FALSE
	tier.variants.Swap(current_index, target_index)
	sync_selection()
	return mark_dirty()

/datum/admin_music_panel/proc/preview_selected_variant()
	var/datum/admin_music_tier/preview_tier = get_selected_tier()
	var/datum/admin_music_variant/preview_variant = get_selected_variant()
	var/list/errors = GLOB.admin_music_service.validate_selected_variant(draft, preview_tier, preview_variant)
	if(length(errors))
		GLOB.admin_music_service.notify_validation_errors(holder, errors)
		return FALSE
	var/datum/media_response/preview_response = GLOB.admin_music_service.resolve_media(holder, preview_variant.source_url)
	if(!preview_response)
		return FALSE
	// DemonicLynx for BandaMarines
	holder?.stop_faction_music_playback()
	set_preview_command("play", list(
		"title" = length(preview_variant.title) ? preview_variant.title : (preview_response.title ? preview_response.title : "Admin sound"),
		"url" = preview_response.url,
		"start" = preview_response.start_time,
		"end" = preview_response.end_time,
	))
	return update_ui()

/datum/admin_music_panel/proc/stop_preview()
	set_preview_command("stop")
	return update_ui()

/datum/admin_music_panel/proc/play_selected_variant(list/params)
	var/datum/admin_music_tier/play_tier = get_selected_tier()
	var/datum/admin_music_variant/play_variant = get_selected_variant()
	return GLOB.admin_music_service.play_panel_variant(
		holder,
		draft,
		play_tier,
		play_variant,
		params["audience_mode"],
		params["sound_type"],
		params["show_title_to_players"],
		params["repeat"],
		params["playback_mode"],
	)

/datum/admin_music_panel/proc/can_autofill_variant_title(datum/admin_music_variant/variant)
	if(!variant)
		return FALSE
	var/title_text = trim("[variant.title]")
	if(!length(title_text))
		return TRUE
	if(findtext(title_text, "Track ") != 1)
		return FALSE
	var/title_suffix = trim(copytext(title_text, 7))
	if(!length(title_suffix))
		return FALSE
	var/parsed_title_index = text2num(title_suffix)
	if(isnull(parsed_title_index))
		return FALSE
	return "[round(parsed_title_index)]" == title_suffix

/datum/admin_music_panel/proc/apply_variant_metadata(datum/admin_music_variant/variant, datum/media_response/response)
	var/list/applied_metadata = list(
		"duration" = FALSE,
		"title" = FALSE,
	)
	if(!variant || !response)
		return applied_metadata

	var/resolved_duration_seconds = round(GLOB.admin_music_service.resolve_media_duration_seconds(response))
	if(resolved_duration_seconds > 0 && variant.duration_seconds != resolved_duration_seconds)
		variant.duration_seconds = max(resolved_duration_seconds, 0)
		applied_metadata["duration"] = TRUE

	var/resolved_title = trim("[response.title]")
	if(length(resolved_title) && can_autofill_variant_title(variant) && variant.title != resolved_title)
		variant.title = resolved_title
		applied_metadata["title"] = TRUE

	return applied_metadata

/datum/admin_music_panel/proc/resolve_variant_metadata(tier_id = null, variant_id = null)
	var/datum/admin_music_variant/target_variant = get_action_variant(tier_id, variant_id)
	if(!target_variant)
		return FALSE
	var/source_url = trim("[target_variant.source_url]")
	if(!length(source_url))
		to_chat(holder, SPAN_WARNING("Set a Source URL before resolving metadata."))
		return FALSE

	var/datum/media_response/response = GLOB.admin_music_service.resolve_media(holder, source_url)
	if(!response)
		return FALSE

	var/list/applied_metadata = apply_variant_metadata(target_variant, response)
	if(!applied_metadata["duration"] && !applied_metadata["title"])
		if(round(GLOB.admin_music_service.resolve_media_duration_seconds(response)) <= 0)
			to_chat(holder, SPAN_WARNING("The media provider did not return a usable end time, so duration could not be resolved automatically."))
			return FALSE
		to_chat(holder, SPAN_NOTICE("Track metadata already matches the resolved media metadata."))
		return update_ui()

	var/list/updated_fields = list()
	if(applied_metadata["duration"])
		updated_fields += "duration"
	if(applied_metadata["title"])
		updated_fields += "title"
	to_chat(holder, SPAN_NOTICE("Resolved media metadata updated [jointext(updated_fields, " and ")]."))
	return mark_dirty()

/datum/admin_music_panel/proc/handle_preset_action(action, list/params)
	switch(action)
		if("request_close")
			return request_close()

		if("new_draft")
			if(!confirm_discard_changes("Discard the current draft and create a new preset?"))
				return FALSE
			return load_draft(GLOB.admin_music_service.build_default_preset(), FALSE)

		if("load_preset")
			if(!confirm_discard_changes("Discard the current draft and load a saved preset?"))
				return FALSE
			var/datum/admin_music_preset/loaded_preset = GLOB.admin_music_service.load_preset_copy(params["preset_id"])
			if(!loaded_preset)
				return FALSE
			return load_draft(loaded_preset, FALSE)

		if("save")
			var/datum/admin_music_preset/saved_preset = GLOB.admin_music_service.save_draft(holder, draft, FALSE)
			if(!saved_preset)
				return FALSE
			return load_draft(saved_preset, FALSE)

		if("save_as_copy")
			var/prompt_target = holder
			if(holder && holder.mob)
				prompt_target = holder.mob
			var/default_copy_name = GLOB.admin_music_service.find_available_copy_name(draft?.name)
			var/new_name = tgui_input_text(prompt_target, "Enter a new preset name for the copy.", "Save As", default_copy_name)
			if(isnull(new_name))
				return FALSE
			var/datum/admin_music_preset/copied_preset = GLOB.admin_music_service.save_draft(holder, draft, TRUE, new_name)
			if(!copied_preset)
				return FALSE
			return load_draft(copied_preset, FALSE)

		if("delete_preset")
			if(!draft?.preset_id)
				return FALSE
			var/delete_message = "Delete the saved preset \"[draft.name]\"?"
			if(dirty)
				delete_message = "Delete the saved preset \"[draft.name]\" and discard current draft changes?"
			var/delete_choice = tgui_alert(holder.mob, delete_message, "Delete Preset", list("Delete", "Cancel"))
			if(delete_choice != "Delete")
				return FALSE
			if(!GLOB.admin_music_service.delete_preset(holder, draft.preset_id))
				return FALSE
			return load_draft(GLOB.admin_music_service.build_default_preset(), FALSE)

		if("export_preset")
			return GLOB.admin_music_service.export_draft(holder, draft)

		if("import_json")
			if(!confirm_discard_changes("Discard the current draft and import a preset from JSON?"))
				return FALSE
			var/datum/admin_music_preset/imported_preset = GLOB.admin_music_service.import_preset_text(holder, params["json_text"])
			if(!imported_preset)
				return FALSE
			return load_draft(imported_preset, FALSE)

		if("set_name")
			draft.name = params["name"]
			return mark_dirty()

		if("set_description")
			draft.description = params["description"]
			return mark_dirty()

		if("set_audience_mode")
			draft.audience_mode = params["audience_mode"]
			return mark_dirty()

		if("set_sound_type")
			draft.sound_type = params["sound_type"]
			return mark_dirty()

		if("set_show_title")
			draft.show_title_to_players = coerce_ui_boolean(params["show_title_to_players"], draft.show_title_to_players)
			return mark_dirty()

		if("set_repeat")
			draft.repeat = coerce_ui_boolean(params["repeat"], draft.repeat)
			return mark_dirty()

	return FALSE

/datum/admin_music_panel/proc/handle_tier_action(action, list/params)
	switch(action)
		if("select_tier")
			return select_tier(params["tier_id"])

		if("add_tier")
			var/datum/admin_music_tier/new_tier = GLOB.admin_music_service.build_default_tier()
			new_tier.name = build_next_scene_name()
			draft.tiers += new_tier
			selected_tier_id = REF(new_tier)
			selected_variant_id = null
			sync_selection()
			return mark_dirty()

		if("remove_tier")
			if(length(draft.tiers) <= 1)
				to_chat(holder, SPAN_WARNING("A preset must keep at least one scene."))
				return FALSE
			var/datum/admin_music_tier/tier_to_remove = draft.find_tier_by_ref(params["tier_id"])
			if(!tier_to_remove)
				return FALSE
			draft.tiers -= tier_to_remove
			if(selected_tier_id == params["tier_id"])
				selected_tier_id = null
				selected_variant_id = null
			sync_selection()
			return mark_dirty()

		if("set_tier_name")
			var/datum/admin_music_tier/named_tier = draft.find_tier_by_ref(params["tier_id"])
			if(!named_tier)
				return FALSE
			named_tier.name = params["name"]
			return mark_dirty()

		if("set_tier_description")
			var/datum/admin_music_tier/described_tier = draft.find_tier_by_ref(params["tier_id"])
			if(!described_tier)
				return FALSE
			described_tier.description = params["description"]
			return mark_dirty()

		if("move_tier_up")
			return move_tier(params["tier_id"], -1)

		if("move_tier_down")
			return move_tier(params["tier_id"], 1)

	return FALSE

/datum/admin_music_panel/proc/handle_variant_action(action, list/params)
	switch(action)
		if("select_variant")
			return select_variant(params["tier_id"], params["variant_id"])

		if("add_variant")
			var/datum/admin_music_tier/add_variant_tier = get_selected_tier()
			if(!add_variant_tier)
				return FALSE
			var/datum/admin_music_variant/new_variant = GLOB.admin_music_service.build_default_variant()
			new_variant.title = build_next_track_title(add_variant_tier)
			add_variant_tier.variants += new_variant
			selected_variant_id = REF(new_variant)
			sync_selection()
			return mark_dirty()

		if("remove_variant")
			var/datum/admin_music_tier/remove_variant_tier = get_action_tier(params["tier_id"])
			if(!remove_variant_tier)
				return FALSE
			if(length(remove_variant_tier.variants) <= 1)
				to_chat(holder, SPAN_WARNING("A scene must keep at least one track."))
				return FALSE
			var/datum/admin_music_variant/variant_to_remove = remove_variant_tier.find_variant_by_ref(params["variant_id"])
			if(!variant_to_remove)
				return FALSE
			remove_variant_tier.variants -= variant_to_remove
			if(selected_variant_id == params["variant_id"])
				selected_variant_id = null
			sync_selection()
			return mark_dirty()

		if("set_variant_title")
			var/datum/admin_music_variant/titled_variant = get_action_variant(params["tier_id"], params["variant_id"])
			if(!titled_variant)
				return FALSE
			titled_variant.title = params["title"]
			return mark_dirty()

		if("set_variant_description")
			var/datum/admin_music_variant/described_variant = get_action_variant(params["tier_id"], params["variant_id"])
			if(!described_variant)
				return FALSE
			described_variant.description = params["description"]
			return mark_dirty()

		if("set_variant_duration")
			var/datum/admin_music_variant/duration_variant = get_action_variant(params["tier_id"], params["variant_id"])
			if(!duration_variant)
				return FALSE
			duration_variant.duration_seconds = parse_duration_seconds(params["duration_seconds"])
			return mark_dirty()

		if("set_variant_source_url")
			var/datum/admin_music_variant/source_variant = get_action_variant(params["tier_id"], params["variant_id"])
			if(!source_variant)
				return FALSE
			var/previous_source_url = source_variant.source_url
			var/previous_title = source_variant.title
			var/previous_duration_seconds = source_variant.duration_seconds
			source_variant.source_url = params["source_url"]
			var/source_url = trim("[source_variant.source_url]")
			if(length(source_url))
				var/datum/media_response/response = GLOB.admin_music_service.resolve_media(holder, source_url, TRUE)
				if(response)
					apply_variant_metadata(source_variant, response)
			if(
				previous_source_url == source_variant.source_url && \
				previous_title == source_variant.title && \
				previous_duration_seconds == source_variant.duration_seconds
			)
				return update_ui()
			return mark_dirty()

		if("resolve_variant_metadata")
			return resolve_variant_metadata(params["tier_id"], params["variant_id"])

		if("move_variant_up")
			return move_variant(params["tier_id"], params["variant_id"], -1)

		if("move_variant_down")
			return move_variant(params["tier_id"], params["variant_id"], 1)

	return FALSE

/datum/admin_music_panel/proc/handle_preview_action(action)
	switch(action)
		if("preview_selected")
			return preview_selected_variant()

		if("stop_preview")
			return stop_preview()

	return FALSE

/datum/admin_music_panel/proc/handle_playback_action(action, list/params)
	switch(action)
		if("play_selected")
			return play_selected_variant(params)

		if("set_live_playback_mode")
			var/datum/admin_music_tier/live_tier = get_selected_tier()
			var/datum/admin_music_variant/live_variant = get_selected_variant()
			if(!live_tier || !live_variant)
				return FALSE
			return GLOB.admin_music_service.set_live_panel_playback_mode(holder, draft, live_tier, live_variant, params["playback_mode"])

		if("stop_broadcast")
			return GLOB.admin_music_service.stop_broadcast(holder, "panel_stop")

	return FALSE

/datum/admin_music_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!holder || !check_rights_for(holder, R_SOUNDS))
		return FALSE

	switch(action)
		if("request_close", "new_draft", "load_preset", "save", "save_as_copy", "delete_preset", "export_preset", "import_json", "set_name", "set_description", "set_audience_mode", "set_sound_type", "set_show_title", "set_repeat")
			return handle_preset_action(action, params)

		if("select_tier", "add_tier", "remove_tier", "set_tier_name", "set_tier_description", "move_tier_up", "move_tier_down")
			return handle_tier_action(action, params)

		if("select_variant", "add_variant", "remove_variant", "set_variant_title", "set_variant_description", "set_variant_duration", "set_variant_source_url", "resolve_variant_metadata", "move_variant_up", "move_variant_down")
			return handle_variant_action(action, params)

		if("preview_selected", "stop_preview")
			return handle_preview_action(action)

		if("play_selected", "set_live_playback_mode", "stop_broadcast")
			return handle_playback_action(action, params)

	return FALSE
