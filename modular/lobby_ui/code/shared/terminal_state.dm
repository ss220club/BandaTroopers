/// Presentation-only state. The classic editor never calls these helpers.
/datum/preferences
	var/banda_saved_character_signature
	var/banda_presented_character_signature
	var/banda_preview_signature
	/// Deadline survives consecutive ShowChoices calls for the same appearance change.
	var/banda_preview_effect_until = 0
	var/list/banda_preview_assets = list()
	var/banda_highlight_source
	var/banda_highlight_asset

/datum/preferences/proc/get_banda_character_state_signature()
	var/static/list/fields = list(
		"metadata",
		"real_name",
		"slot_label",
		"be_random_name",
		"be_random_body",
		"gender",
		"age",
		"ethnicity",
		"skin_color",
		"body_type",
		"body_size",
		"language",
		"r_hair",
		"g_hair",
		"b_hair",
		"r_gradient",
		"g_gradient",
		"b_gradient",
		"r_facial",
		"g_facial",
		"b_facial",
		"r_skin",
		"g_skin",
		"b_skin",
		"h_style",
		"grad_style",
		"f_style",
		"r_eyes",
		"g_eyes",
		"b_eyes",
		"underwear",
		"undershirt",
		"backbag",
		"spawnpoint",
		"alternate_option",
		"job_preference_list",
		"flavor_texts",
		"med_record",
		"sec_record",
		"gen_record",
		"be_special",
		"organ_data",
		"gear",
		"origin",
		"faction",
		"religion",
		"traits",
		"weyland_yutani_relation",
		"preferred_squad",
		"preferred_armor",
		"uplinklocation",
		"exploit_record",
		"dropship_camo",
		"platoon_name",
		"squad_name_alpha_pref",
		"squad_name_bravo_pref",
		"squad_name_charlie_pref",
		"squad_name_delta_pref",
		"dropship_name",
		"personal_weapon",
		"tts_seed",
	)
	var/list/state = list()
	for(var/field in fields)
		state[field] = vars[field]
	return md5(json_encode(state))

/datum/modpack/lobby_ui/lobby_ui_character_persisted(datum/preferences/preferences, action)
	if(!preferences?.uses_banda_terminal_interface())
		return
	preferences.banda_saved_character_signature = preferences.get_banda_character_state_signature()
	preferences.banda_terminal_dirty = FALSE
	if(preferences.banda_character_editor_open)
		preferences.banda_terminal_notice = action
	if(action == "reload")
		preferences.close_banda_accessory_pickers()
		preferences.banda_preview_signature = null
		preferences.banda_loadout_render_generation++
		preferences.banda_loadout_open = FALSE
		if(preferences.owner)
			close_browser(preferences.owner, "banda_loadout_picker")

/datum/preferences/proc/update_banda_character_feedback()
	var/signature = get_banda_character_state_signature()
	if(isnull(banda_saved_character_signature))
		banda_saved_character_signature = signature
	banda_terminal_dirty = signature != banda_saved_character_signature
	if(signature == banda_presented_character_signature)
		banda_pending_highlight_preference = null
	banda_presented_character_signature = signature

/// Include every input copied to the mannequin and used by its equipment preset.
/datum/preferences/proc/get_banda_preview_signature()
	return md5(json_encode(list(
		species, age, gender, skin_color, body_type, body_size,
		r_eyes, g_eyes, b_eyes, r_hair, g_hair, b_hair, h_style,
		r_facial, g_facial, b_facial, f_style, r_skin, g_skin, b_skin,
		r_gradient, g_gradient, b_gradient, grad_style, organ_data, traits,
		underwear, undershirt, backbag, gear, preferred_armor,
		banda_show_combat_gear, job_preference_list, pref_special_job_options,
		preferred_squad, real_name, personal_weapon, job_pref_to_gear_preset()
	)))

/datum/preferences/proc/ensure_banda_character_preview()
	// Login can show the terminal before atoms initialize. As in show_preferences,
	// wait for pregame so the mannequin's limbs receive their owner in Initialize.
	if(SSticker.current_state < GAME_STATE_PREGAME)
		return FALSE
	var/signature = get_banda_preview_signature()
	if(QDELETED(preview_dummy) || signature != banda_preview_signature)
		update_preview_icon(TRUE)
		if(QDELETED(preview_dummy) || !(preview_dummy.flags_atom & INITIALIZED))
			return FALSE
		banda_preview_signature = get_banda_preview_signature()
		banda_preview_assets.Cut()
	return TRUE

/// Remaining milliseconds, not a one-render flag: apparel handlers render twice.
/datum/preferences/proc/get_banda_preview_effect_duration()
	var/signature = get_banda_preview_signature()
	if(!banda_character_editor_open || !uses_banda_terminal_decorative_effects())
		banda_preview_effect_until = 0
	else if(!isnull(banda_last_preview_signature) && banda_last_preview_signature != signature)
		banda_preview_effect_until = world.time + 0.25 SECONDS
	banda_last_preview_signature = signature
	return max(0, (banda_preview_effect_until - world.time) * 100)

/datum/preferences/proc/get_banda_preview_asset(client/viewer, direction)
	if(!viewer || !ensure_banda_character_preview())
		return null
	var/key = banda_preview_assets["[direction]"]
	if(!key)
		var/previous_direction = preview_dummy.dir
		preview_dummy.setDir(direction)
		var/icon/flattened = getFlatIcon(preview_dummy, defdir = direction, no_anim = TRUE)
		preview_dummy.setDir(previous_direction)
		key = icon2html(flattened, viewer, keyonly = TRUE)
		if(!key)
			return null
		banda_preview_assets["[direction]"] = key
	else
		SSassets.transport.send_assets(viewer, key)
	return SSassets.transport.get_asset_url(key)

/// Only the lobby's optional monochrome portrait is tinted; editor/COLOR stay raw.
/datum/preferences/proc/get_banda_lobby_preview_asset(client/viewer)
	var/original_url = get_banda_preview_asset(viewer, SOUTH)
	if(!original_url || !banda_lobby_character_highlight || !banda_terminal_glow)
		return original_url
	var/source_key = banda_preview_assets["[SOUTH]"]
	var/signature = "[source_key]|[banda_terminal_interface_color]"
	if(signature != banda_highlight_source || !banda_highlight_asset)
		var/datum/asset_cache_item/source_asset = SSassets.cache[source_key]
		var/icon/portrait = icon(source_asset.resource)
		portrait.GrayScale()
		portrait.Blend(banda_terminal_interface_color, ICON_MULTIPLY)
		banda_highlight_asset = icon2html(portrait, viewer, keyonly = TRUE)
		banda_highlight_source = signature
	else
		SSassets.transport.send_assets(viewer, banda_highlight_asset)
	return SSassets.transport.get_asset_url(banda_highlight_asset)
