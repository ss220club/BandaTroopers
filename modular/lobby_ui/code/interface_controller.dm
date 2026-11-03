#define BANDA_MENU_INTERFACE_TERMINAL "terminal"
#define BANDA_MENU_INTERFACE_CLASSIC "classic"
#define BANDA_LOBBY_BROWSER "mapwindow.lobbybrowser"
#define BANDA_TERMINAL_INTERFACE_COLOR "#CCFF66"
#define BANDA_TERMINAL_TEXT_COLOR "#FFFFFF"
#define BANDA_TERMINAL_EFFECTS_FULL "full"
#define BANDA_TERMINAL_EFFECTS_REDUCED "reduced"
#define BANDA_TERMINAL_EFFECTS_OFF "off"
#define BANDA_INTERFACE_LANGUAGE_RUSSIAN "ru"
#define BANDA_INTERFACE_LANGUAGE_ENGLISH "en"

/datum/preferences
	/// Account-wide lobby and character-editor presentation. New players use the terminal theme.
	var/banda_menu_interface = BANDA_MENU_INTERFACE_TERMINAL
	/// Whether the terminal lobby dossier tints its portrait with the selected interface color.
	var/banda_lobby_character_highlight = TRUE
	/// Primary hue used by all terminal menu surfaces.
	var/banda_terminal_interface_color = BANDA_TERMINAL_INTERFACE_COLOR
	/// Text color is independent of the interface accent; missing values use white.
	var/banda_terminal_text_color = BANDA_TERMINAL_TEXT_COLOR
	/// Account-wide intensity of decorative terminal animations and sounds.
	var/banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
	/// Account-wide language of every surface owned by the lobby UI module.
	var/banda_interface_language = BANDA_INTERFACE_LANGUAGE_RUSSIAN
	/// Whether decorative text and panel glow is enabled independently of animations.
	var/banda_terminal_glow = TRUE
	var/banda_category_blocks = FALSE
	/// Invalidates deferred loadout renders when a newer request or close action wins.
	var/banda_loadout_render_generation = 0
	/// Last terminal character-editor tab rendered; used only to animate real tab changes.
	var/banda_last_terminal_menu
	/// Last visual signature rendered in the terminal portrait; presentation-only change detection.
	var/banda_last_preview_signature
	/// Preference href to emphasize after the next confirmed refresh.
	var/banda_pending_highlight_preference
	/// Prevents the opening frame pulse from repeating on ordinary editor refreshes.
	var/banda_character_editor_open = FALSE
	/// Presentation-only dirty marker for character-slot changes not yet saved.
	var/banda_terminal_dirty = FALSE
	/// One-shot terminal notice rendered after save/reload actions.
	var/banda_terminal_notice
	/// One-shot error shake owned by the loadout catalog refresh.
	var/banda_loadout_error_feedback = FALSE

/datum/preferences/proc/uses_banda_terminal_interface()
	return banda_menu_interface != BANDA_MENU_INTERFACE_CLASSIC

/datum/preferences/proc/set_banda_menu_interface(new_interface)
	close_banda_accessory_pickers()
	if(banda_typography_dialog)
		qdel(banda_typography_dialog)
	banda_preview_signature = null
	banda_loadout_render_generation++
	banda_loadout_open = FALSE
	if(owner)
		close_browser(owner, "banda_loadout_picker")
	if(new_interface != BANDA_MENU_INTERFACE_CLASSIC && new_interface != BANDA_MENU_INTERFACE_TERMINAL)
		banda_menu_interface = BANDA_MENU_INTERFACE_TERMINAL
		return
	banda_menu_interface = new_interface

/datum/preferences/proc/set_banda_terminal_effect_intensity(new_intensity)
	if(new_intensity != BANDA_TERMINAL_EFFECTS_FULL && new_intensity != BANDA_TERMINAL_EFFECTS_REDUCED && new_intensity != BANDA_TERMINAL_EFFECTS_OFF)
		banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
		return
	banda_terminal_effect_intensity = new_intensity

/datum/preferences/proc/get_banda_terminal_effect_class()
	switch(banda_terminal_effect_intensity)
		if(BANDA_TERMINAL_EFFECTS_REDUCED)
			return " banda-effects-reduced"
		if(BANDA_TERMINAL_EFFECTS_OFF)
			return " banda-effects-off"
	return ""

/datum/preferences/proc/get_banda_terminal_glow_class()
	return banda_terminal_glow ? "" : " banda-glow-off"

/datum/preferences/proc/uses_banda_english_interface()
	return banda_interface_language == BANDA_INTERFACE_LANGUAGE_ENGLISH

/datum/preferences/proc/set_banda_interface_language(new_language)
	if(new_language != BANDA_INTERFACE_LANGUAGE_RUSSIAN && new_language != BANDA_INTERFACE_LANGUAGE_ENGLISH)
		banda_interface_language = BANDA_INTERFACE_LANGUAGE_RUSSIAN
		return
	banda_interface_language = new_language

/datum/preferences/proc/get_banda_terminal_effect_label()
	switch(banda_terminal_effect_intensity)
		if(BANDA_TERMINAL_EFFECTS_REDUCED)
			return "Сниженная"
		if(BANDA_TERMINAL_EFFECTS_OFF)
			return "Выключена"
	return "Полная"

/datum/preferences/proc/uses_banda_terminal_decorative_effects()
	return banda_terminal_effect_intensity == BANDA_TERMINAL_EFFECTS_FULL

/datum/preferences/proc/set_banda_terminal_interface_color(new_color)
	var/list/channels = istext(new_color) ? ReadRGB(new_color) : null
	if(length(channels) < 3)
		banda_terminal_interface_color = BANDA_TERMINAL_INTERFACE_COLOR
		return
	banda_terminal_interface_color = rgb(channels[1], channels[2], channels[3])

/datum/preferences/proc/set_banda_terminal_text_color(new_color)
	var/list/channels = istext(new_color) ? ReadRGB(new_color) : null
	if(length(channels) < 3)
		banda_terminal_text_color = BANDA_TERMINAL_TEXT_COLOR
		return
	banda_terminal_text_color = rgb(channels[1], channels[2], channels[3])

/datum/preferences/proc/get_banda_terminal_text_override_class()
	return isnull(banda_terminal_text_color) ? "" : " banda-text-override"

/datum/preferences/proc/get_banda_tgui_input_presentation()
	return list(
		"accent_color" = banda_terminal_interface_color,
		"text_color" = banda_terminal_text_color,
		"glow" = banda_terminal_glow,
		"effect_intensity" = banda_terminal_effect_intensity,
		"font_family" = get_banda_terminal_font_family(),
		"font_size" = banda_terminal_font_size,
	)

/datum/preferences/proc/load_banda_menu_interface(savefile/preferences_file)
	var/saved_interface
	preferences_file["banda_menu_interface"] >> saved_interface
	set_banda_menu_interface(saved_interface)
	var/saved_character_highlight
	preferences_file["banda_lobby_character_highlight"] >> saved_character_highlight
	banda_lobby_character_highlight = isnull(saved_character_highlight) ? TRUE : !!saved_character_highlight
	var/saved_interface_color
	preferences_file["banda_terminal_interface_color"] >> saved_interface_color
	set_banda_terminal_interface_color(saved_interface_color)
	var/saved_text_color
	preferences_file["banda_terminal_text_color"] >> saved_text_color
	set_banda_terminal_text_color(saved_text_color)
	var/saved_effect_intensity
	preferences_file["banda_terminal_effect_intensity"] >> saved_effect_intensity
	set_banda_terminal_effect_intensity(saved_effect_intensity)
	var/saved_language
	preferences_file["banda_interface_language"] >> saved_language
	set_banda_interface_language(saved_language)
	var/saved_glow
	preferences_file["banda_terminal_glow"] >> saved_glow
	banda_terminal_glow = isnull(saved_glow) ? TRUE : !!saved_glow
	var/saved_category_blocks
	preferences_file["banda_category_blocks"] >> saved_category_blocks
	banda_category_blocks = isnum(saved_category_blocks) && saved_category_blocks == TRUE
	var/saved_combat_gear
	preferences_file["banda_show_combat_gear"] >> saved_combat_gear
	banda_show_combat_gear = isnull(saved_combat_gear) ? FALSE : !!saved_combat_gear
	var/saved_font
	var/saved_font_size
	preferences_file["banda_terminal_font"] >> saved_font
	preferences_file["banda_terminal_font_size"] >> saved_font_size
	set_banda_terminal_typography(saved_font, saved_font_size)

/datum/preferences/proc/save_banda_menu_interface(savefile/preferences_file)
	preferences_file["banda_menu_interface"] << banda_menu_interface
	preferences_file["banda_lobby_character_highlight"] << banda_lobby_character_highlight
	preferences_file["banda_terminal_interface_color"] << banda_terminal_interface_color
	preferences_file["banda_terminal_text_color"] << banda_terminal_text_color
	preferences_file["banda_terminal_effect_intensity"] << banda_terminal_effect_intensity
	preferences_file["banda_interface_language"] << banda_interface_language
	preferences_file["banda_terminal_glow"] << banda_terminal_glow
	preferences_file["banda_category_blocks"] << banda_category_blocks
	preferences_file["banda_show_combat_gear"] << banda_show_combat_gear
	preferences_file["banda_terminal_font"] << banda_terminal_font
	preferences_file["banda_terminal_font_size"] << banda_terminal_font_size

/datum/preferences/proc/set_and_save_banda_menu_interface(new_interface)
	if(!SSmodpacks?.lobby_ui_provider)
		return FALSE
	var/previous_interface = banda_menu_interface
	set_banda_menu_interface(new_interface)
	if(save_preferences())
		return TRUE
	set_banda_menu_interface(previous_interface)
	return FALSE

/datum/preferences/proc/get_banda_interface_preferences_controls()
	if(!uses_banda_terminal_interface())
		return ""
	var/highlight_label = banda_lobby_character_highlight ? "Вкл" : "Выкл"
	var/text_color_swatch = banda_terminal_text_color || BANDA_TERMINAL_TEXT_COLOR
	var/effect_label = get_banda_terminal_effect_label()
	var/language_label = uses_banda_english_interface() ? "English" : "Русский"
	var/glow_label = banda_terminal_glow ? "Вкл" : "Выкл"
	var/category_label = uses_banda_english_interface() ? "Category blocks NEW" : "Блоки категорий NEW"
	var/category_state = banda_category_blocks ? (uses_banda_english_interface() ? "On" : "Вкл") : (uses_banda_english_interface() ? "Off" : "Выкл")
	return "<section class='prefs-settings-section'><h2><b><u>Личные Настройки Интерфейса:</u></b></h2><b>Подсветка персонажа в личном деле:</b> <a href='byond://?_src_=prefs;preference=banda_lobby_character_highlight'><b>[highlight_label]</b></a><br><b>Интенсивность эффектов:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_effect_intensity'><b>[effect_label]</b></a><br><b>Смена языка:</b> <a href='byond://?_src_=prefs;preference=banda_interface_language'><b>[language_label]</b></a><br><b>Свечение интерфейса:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_glow'><b>[glow_label]</b></a><br><b>[category_label]:</b> <a href='byond://?_src_=prefs;preference=banda_category_blocks'>[category_state]</a><br><b>[uses_banda_english_interface() ? "Fonts" : "Шрифты"]:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_font'>[banda_terminal_font == "default" ? (uses_banda_english_interface() ? "Terminal (default)" : "Терминальный (по умолчанию)") : banda_terminal_font]</a><br><b>[uses_banda_english_interface() ? "Text size" : "Размер текста"]:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_font_size'>[banda_terminal_font_size] px</a><br><b>Смена лобби:</b> <a href='byond://?_src_=prefs;preference=banda_menu_interface'><b>Терминальный</b></a><br><b>Изменение цвета интерфейса:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_interface_color'><b>Color</b> <span class='square banda-real-color' style='background-color: [banda_terminal_interface_color];'></span></a><br><b>Изменение цвета текста интерфейса:</b> <a href='byond://?_src_=prefs;preference=banda_terminal_text_color'><b>Color</b> <span class='square banda-real-color' style='background-color: [text_color_swatch];'></span></a><br><a class='prefs-settings-action' href='byond://?_src_=prefs;preference=banda_terminal_settings_reset'><b>Сброс изменений интерфейса</b></a><br><br></section>"

/datum/preferences/proc/get_banda_terminal_settings_controls()
	var/dat = "<div id='column1' class='prefs-settings-column'>"
	dat += get_banda_interface_preferences_controls()
	dat += "<section class='prefs-settings-section'><h2><b><u>Input Settings:</u></b></h2>"
	dat += "<b>Mode:</b> <a href='byond://?_src_=prefs;preference=hotkeys'><b>[hotkeys ? "Hotkeys Mode" : "Send to Chat"]</b></a><br>"
	dat += "<b>Keybinds:</b> <a href='byond://?_src_=prefs;preference=viewmacros'><b>View Keybinds</b></a><br></section>"
	dat += "<section class='prefs-settings-section'><h2><b><u>HUD Settings:</u></b></h2>"
	dat += "<b>Style:</b> <a href='byond://?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>"
	dat += "<b>Color:</b> <a href='byond://?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b> <table class='banda-real-color' style='display:inline;' bgcolor='[UI_style_color]'><tr><td>__</td></tr></table></a><br>"
	dat += "<b>Alpha:</b> <a href='byond://?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>"
	dat += "<b>Custom Cursors:</b> <a href='byond://?_src_=prefs;preference=customcursors'><b>[custom_cursors ? "Enabled" : "Disabled"]</b></a><br></section>"
	dat += "</div>"

	dat += "<div id='column2' class='prefs-settings-column'>"
	dat += "<section class='prefs-settings-section'><h2><b><u>Ghost Settings:</u></b></h2>"
	dat += "<b>Ghost Ears:</b> <a href='byond://?_src_=prefs;preference=ghost_ears'><b>[(toggles_chat & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a><br>"
	dat += "<b>Ghost Sight:</b> <a href='byond://?_src_=prefs;preference=ghost_sight'><b>[(toggles_chat & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</b></a><br>"
	dat += "<b>Ghost Radio:</b> <a href='byond://?_src_=prefs;preference=ghost_radio'><b>[(toggles_chat & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a><br>"
	dat += "<b>Ghost Spy Radio:</b> <a href='byond://?_src_=prefs;preference=ghost_spyradio'><b>[(toggles_chat & CHAT_LISTENINGBUG) ? "Hear" : "Silence"] listening devices</b></a><br>"
	dat += "<b>Ghost Hivemind:</b> <a href='byond://?_src_=prefs;preference=ghost_hivemind'><b>[(toggles_chat & CHAT_GHOSTHIVEMIND) ? "Show Hivemind" : "Hide Hivemind"]</b></a><br>"
	dat += "<b>Abovehead Chat:</b> <a href='byond://?_src_=prefs;preference=lang_chat_disabled'><b>[lang_chat_disabled ? "Hide" : "Show"]</b></a><br>"
	dat += "<b>Abovehead Emotes:</b> <a href='byond://?_src_=prefs;preference=langchat_emotes'><b>[(toggles_langchat & LANGCHAT_SEE_EMOTES) ? "Show" : "Hide"]</b></a><br>"
	dat += "<b>Play Fax Sounds As Ghost:</b> <a href='byond://?_src_=prefs;preference=hear_faxes'><b>[(toggles_sound & SOUND_FAX_MACHINE) ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Default Ghost Night Vision Level:</b> <a href='byond://?_src_=prefs;preference=ghost_vision_pref;task=input'><b>[ghost_vision_pref]</b></a><br></section>"
	dat += "<section class='prefs-settings-section'><h2><b><u>Music and Effects:</u></b></h2>"
	dat += "<b>Play Lobby Music:</b> <a href='byond://?_src_=prefs;preference=lobby_music'><b>[(toggles_sound & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Play VOX Announcements:</b> <a href='byond://?_src_=prefs;preference=sound_vox'><b>[hear_vox ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Play Admin Sounds:</b> <a href='byond://?_src_=prefs;preference=hear_admin_sounds'><b>[(toggles_sound & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>"
	dat += "<div class='prefs-settings-subgroup-label'>Toggle Meme or Atmospheric Sounds:</div>"
	dat += "<b class='prefs-settings-suboption'>Atmospheric Sounds:</b> <a href='byond://?_src_=prefs;preference=banda_admin_atmospheric_sounds'><b>[(toggles_sound & SOUND_ADMIN_ATMOSPHERIC) ? "On" : "Off"]</b></a><br>"
	dat += "<b class='prefs-settings-suboption'>Meme Sounds:</b> <a href='byond://?_src_=prefs;preference=banda_admin_meme_sounds'><b>[(toggles_sound & SOUND_ADMIN_MEME) ? "On" : "Off"]</b></a><br></section>"
	dat += "<section class='prefs-settings-section'><h2><b><u>Game Window Settings:</u></b></h2>"
	dat += "<b>Ambient Occlusion:</b> <a href='byond://?_src_=prefs;preference=ambientocclusion'><b>[toggle_prefs & TOGGLE_AMBIENT_OCCLUSION ? "Enabled" : "Disabled"]</b></a><br>"
	dat += "<b>Fit Viewport:</b> <a href='byond://?_src_=prefs;preference=auto_fit_viewport'>[auto_fit_viewport ? "Auto" : "Manual"]</a><br>"
	dat += "<b>Adaptive Zoom:</b> <a href='byond://?_src_=prefs;preference=adaptive_zoom'>[adaptive_zoom ? "[adaptive_zoom * 2]x" : "Disabled"]</a><br>"
	dat += "<b>tgui Window Mode:</b> <a href='byond://?_src_=prefs;preference=tgui_fancy'><b>[tgui_fancy ? "Fancy (default)" : "Compatible (slower)"]</b></a><br>"
	dat += "<b>tgui Window Placement:</b> <a href='byond://?_src_=prefs;preference=tgui_lock'><b>[tgui_lock ? "Primary monitor" : "Free (default)"]</b></a><br>"
	dat += "<b>Window Scaling:</b> <a href='byond://?_src_=prefs;preference=window_scale'><b>[window_scale ? "Larger windows (default)" : "Smaller zoom"]</b></a><br></section>"
	dat += "</div>"

	dat += "<div id='column3' class='prefs-settings-column'>"
	dat += "<section class='prefs-settings-section'><h2><b><u>Gameplay Toggles:</u></b></h2>"
	dat += "<b>Toggle Being Able to Hurt Yourself:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_IGNORE_SELF]'><b>[toggle_prefs & TOGGLE_IGNORE_SELF ? "Off" : "On"]</b></a><br>"
	dat += "<b>Toggle Help Intent Safety:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_HELP_INTENT_SAFETY]'><b>[toggle_prefs & TOGGLE_HELP_INTENT_SAFETY ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Ability Deactivation:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_ABILITY_DEACTIVATION_OFF]'><b>[toggle_prefs & TOGGLE_ABILITY_DEACTIVATION_OFF ? "Off" : "On"]</b></a><br>"
	dat += "<b>Toggle Directional Assist:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_DIRECTIONAL_ATTACK]'><b>[toggle_prefs & TOGGLE_DIRECTIONAL_ATTACK ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Magazine Auto-Ejection:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTO_EJECT_MAGAZINE_OFF];flag_undo=[TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND]'><b>[!(toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_OFF) ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Magazine Auto-Ejection to Offhand:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND];flag_undo=[TOGGLE_AUTO_EJECT_MAGAZINE_OFF]'><b>[toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_TO_HAND ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Magazine Manual Ejection to Offhand:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_EJECT_MAGAZINE_TO_HAND]'><b>[toggle_prefs & TOGGLE_EJECT_MAGAZINE_TO_HAND ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Automatic Punctuation:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AUTOMATIC_PUNCTUATION]'><b>[toggle_prefs & TOGGLE_AUTOMATIC_PUNCTUATION ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Combat Click-Drag Override:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_COMBAT_CLICKDRAG_OVERRIDE]'><b>[toggle_prefs & TOGGLE_COMBAT_CLICKDRAG_OVERRIDE ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Combat Point-Blank Override:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_COMBAT_POINTBLANK_OVERRIDE]'><b>[toggle_prefs & TOGGLE_COMBAT_POINTBLANK_OVERRIDE ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Middle-Click Swap Hands:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_MIDDLE_MOUSE_SWAP_HANDS]'><b>[toggle_prefs & TOGGLE_MIDDLE_MOUSE_SWAP_HANDS ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Vendors Vending to Hands:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_VEND_ITEM_TO_HAND]'><b>[toggle_prefs & TOGGLE_VEND_ITEM_TO_HAND ? "On" : "Off"]</b></a><br>"
	dat += "<b>Toggle Semi-Auto Ammo Display Limiter:</b> <a href='byond://?_src_=prefs;preference=toggle_prefs;flag=[TOGGLE_AMMO_DISPLAY_TYPE]'><b>[toggle_prefs & TOGGLE_AMMO_DISPLAY_TYPE ? "On" : "Off"]</b></a><br>"
	dat += "<b>Button To Activate Xenomorph Abilities:</b> <a href='byond://?_src_=prefs;preference=mouse_button_activation;task=input'><b>[xeno_ability_mouse_pref_to_string(xeno_ability_click_mode)]</b></a><br>"
	dat += "<a class='prefs-settings-action' href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/switch_item_animations'>Toggle Item Animations Detail Level</a><br>"
	dat += "<a class='prefs-settings-action' href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/toggle_dualwield'>Toggle Dual Wield Functionality</a><br></section>"
	dat += "<div class='prefs-settings-section prefs-settings-collapsible'>"
	dat += "<h2><a class='prefs-settings-toggle' href='#' role='button' aria-expanded='false' onclick='return toggleBandaAdditional(this);'><span class='prefs-settings-toggle-marker' aria-hidden='true'>+</span><b><u>Additional:</u></b></a></h2>"
	dat += "<div class='prefs-settings-collapsible-body' aria-hidden='true'>"
	dat += "<b>Set Eye Blur Type:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_eye_blur_type'>Set</a><br>"
	dat += "<b>Set Flash Type:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_flash_type'>Set</a><br>"
	dat += "<b>Set Crit Type:</b> <a href='byond://?src=\ref[src];action=proccall;procpath=/client/proc/set_crit_type'>Set</a><br>"
	dat += "<b>Say Input Color:</b> <a href='byond://?_src_=prefs;preference=inputcolor'><b>[tgui_say_light_mode ? "Lightmode" : "Darkmode (default)"]</b></a><br>"
	dat += "<b>Hide Statusbar:</b> <a href='byond://?_src_=prefs;preference=hide_statusbar'><b>[hide_statusbar ? "TRUE" : "FALSE"]</b></a><br>"
	dat += "<b>Prefer input drop down menus to radial menus, where possible:</b> <a href='byond://?_src_=prefs;preference=no_radials_preference'><b>[no_radials_preference ? "TRUE" : "FALSE"]</b></a><br>"
	if(!no_radials_preference)
		dat += "<b>Hide Radial Menu Labels:</b> <a href='byond://?_src_=prefs;preference=no_radial_labels_preference'><b>[no_radial_labels_preference ? "TRUE" : "FALSE"]</b></a><br>"
	dat += "<b>Play Announcement Sounds As Ghost:</b> <a href='byond://?_src_=prefs;preference=hear_observer_announcements'><b>[(toggles_sound & SOUND_OBSERVER_ANNOUNCEMENTS) ? "Yes" : "No"]</b></a><br>"
	dat += "<b>Tooltips:</b> <a href='byond://?_src_=prefs;preference=tooltips'><b>[tooltips ? "Enabled" : "Disabled"]</b></a><br>"
	dat += "</div></div></div>"
	return dat

/datum/preferences/proc/toggle_banda_lobby_character_highlight()
	banda_lobby_character_highlight = !banda_lobby_character_highlight
	save_preferences()

/datum/preferences/proc/cycle_banda_terminal_effect_intensity()
	switch(banda_terminal_effect_intensity)
		if(BANDA_TERMINAL_EFFECTS_FULL)
			banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_REDUCED
		if(BANDA_TERMINAL_EFFECTS_REDUCED)
			banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_OFF
		else
			banda_terminal_effect_intensity = BANDA_TERMINAL_EFFECTS_FULL
	save_preferences()

/datum/preferences/proc/toggle_banda_interface_language()
	set_banda_interface_language(uses_banda_english_interface() ? BANDA_INTERFACE_LANGUAGE_RUSSIAN : BANDA_INTERFACE_LANGUAGE_ENGLISH)
	save_preferences()

/datum/preferences/proc/toggle_banda_terminal_glow()
	banda_terminal_glow = !banda_terminal_glow
	save_preferences()

/datum/preferences/proc/toggle_banda_category_blocks()
	banda_category_blocks = !banda_category_blocks
	save_preferences()

/datum/preferences/proc/toggle_banda_admin_sound_type(sound_flag)
	if(!(sound_flag in list(SOUND_ADMIN_ATMOSPHERIC, SOUND_ADMIN_MEME)))
		return FALSE
	toggles_sound ^= sound_flag
	save_preferences()
	return TRUE

/datum/preferences/proc/select_banda_terminal_interface_color(mob/user)
	var/new_color = input(user, "Выберите цвет терминального интерфейса. Тёмные цвета могут ухудшить читаемость.", "Цвет интерфейса", banda_terminal_interface_color) as color|null
	if(isnull(new_color))
		return
	set_banda_terminal_interface_color(new_color)
	save_preferences()

/datum/preferences/proc/select_banda_terminal_text_color(mob/user)
	var/initial_color = banda_terminal_text_color || BANDA_TERMINAL_TEXT_COLOR
	var/new_color = input(user, "Выберите персональный цвет текста терминального интерфейса.", "Цвет текста интерфейса", initial_color) as color|null
	if(isnull(new_color))
		return
	set_banda_terminal_text_color(new_color)
	save_preferences()

/datum/preferences/proc/reset_banda_terminal_settings()
	if(!uses_banda_terminal_interface())
		return
	// Reset exactly the fields exposed in Personal Interface Settings, not slot/gameplay data.
	set_banda_menu_interface(initial(banda_menu_interface))
	banda_lobby_character_highlight = initial(banda_lobby_character_highlight)
	banda_terminal_effect_intensity = initial(banda_terminal_effect_intensity)
	banda_interface_language = initial(banda_interface_language)
	banda_terminal_glow = initial(banda_terminal_glow)
	banda_category_blocks = initial(banda_category_blocks)
	banda_terminal_font = initial(banda_terminal_font)
	banda_terminal_font_size = initial(banda_terminal_font_size)
	banda_terminal_interface_color = initial(banda_terminal_interface_color)
	banda_terminal_text_color = initial(banda_terminal_text_color)
	save_preferences()

/datum/preferences/proc/get_banda_character_menu_tabs()
	var/list/tabs = list()
	tabs += list(list("id" = "marine", "label" = "Human"))
	tabs += list(list("id" = "pltco", "label" = "Platoon Presets"))
	if(owner.check_whitelist_status(WHITELIST_COMMANDER))
		tabs += list(list("id" = "co", "label" = "Commanding Officer"))
	tabs += list(list("id" = "synth", "label" = "Synthetic"))
	if(owner.check_whitelist_status(WHITELIST_PREDATOR))
		tabs += list(list("id" = "yautja", "label" = "Yautja"))
	if(owner.check_whitelist_status(WHITELIST_MENTOR))
		tabs += list(list("id" = "mentor", "label" = "Mentor"))
	tabs += list(list("id" = "settings", "label" = "Settings"))
	tabs += list(list("id" = "special", "label" = "Special Roles"))
	return tabs

/datum/preferences/proc/get_banda_character_preferences_header(mob/user)
	if(uses_banda_terminal_interface())
		return get_terminal_character_preferences_header(user)
	return get_classic_character_preferences_header(user)

/datum/preferences/proc/get_banda_character_preferences_footer()
	if(uses_banda_terminal_interface())
		return get_terminal_character_preferences_footer()
	return get_classic_character_preferences_footer()

/datum/preferences/proc/show_banda_character_preferences(mob/user, html)
	if(uses_banda_terminal_interface())
		show_terminal_character_preferences(user, html)
		return
	show_classic_character_preferences(user, html)

/datum/preferences/proc/select_classic_accessory_style(mob/user, facial = FALSE)
	var/list/valid_styles = get_banda_valid_accessory_styles(facial)
	var/prompt = facial ? "Выберите растительность на лице персонажа:" : "Выберите причёску персонажа:"
	var/title = "Настройка персонажа"
	var/list/localized_styles = get_banda_localized_preference_choices(valid_styles)
	var/selected_label = input(user, prompt, title) as null|anything in localized_styles
	var/selected_style = localized_styles[selected_label]
	if(!selected_style)
		return
	if(facial)
		f_style = selected_style
	else
		h_style = selected_style

/mob/new_player/proc/show_selected_lobby(refresh = FALSE)
	if(client?.prefs?.uses_banda_terminal_interface())
		show_terminal_lobby(refresh)
		return
	banda_lobby_visible = FALSE
	banda_lobby_render_generation++
	show_classic_lobby(refresh)

/mob/proc/hide_banda_lobby_interface()
	if(!client)
		return
	if(istype(src, /mob/new_player))
		var/mob/new_player/player = src
		player.banda_lobby_visible = FALSE
		player.banda_lobby_render_generation++
	close_browser(src, "lobbybrowser")
	close_browser(src, "playersetup")
	winset(client, BANDA_LOBBY_BROWSER, "is-visible=false")

/mob/new_player/proc/play_banda_lobby_click()
	if(!client?.prefs?.uses_banda_terminal_interface())
		return
	playsound_client(client, 'modular/lobby_ui/assets/menu_click.mp3', null, 45, FALSE, VOLUME_SFX)

/mob/new_player/proc/play_banda_lobby_startup_effect()
	if(!client?.prefs?.uses_banda_terminal_interface() || !client.prefs.uses_banda_terminal_decorative_effects() || !banda_lobby_visible)
		return
	playsound_client(client, 'modular/lobby_ui/assets/terminal_startup.ogg', null, 24, FALSE, VOLUME_SFX)

/mob/new_player/proc/play_banda_lobby_authorized_effect(expected_generation)
	if(!client?.prefs?.uses_banda_terminal_interface() || !client.prefs.uses_banda_terminal_decorative_effects() || !banda_lobby_visible || banda_lobby_render_generation != expected_generation)
		return
	playsound_client(client, 'modular/lobby_ui/assets/terminal_authorized.ogg', null, 22, FALSE, VOLUME_SFX)

/mob/new_player/proc/play_banda_lobby_type_complete_effect(expected_briefing, expected_generation)
	if(!client?.prefs?.uses_banda_terminal_interface() || !client.prefs.uses_banda_terminal_decorative_effects() || !banda_lobby_visible || banda_lobby_render_generation != expected_generation || banda_last_briefing_text != expected_briefing)
		return
	playsound_client(client, 'modular/lobby_ui/assets/terminal_type_complete.ogg', null, 18, FALSE, VOLUME_SFX)

/client/proc/play_banda_lobby_music()
	if(!prefs || !(prefs.toggles_sound & SOUND_LOBBY))
		return FALSE
	if(prefs.uses_banda_terminal_interface())
		var/sound/lobby_track = sound('modular/lobby_ui/assets/menu_bm.mp3', repeat = TRUE, wait = FALSE)
		playsound_client(src, lobby_track, null, 70, FALSE, VOLUME_LOBBY, SOUND_CHANNEL_LOBBY, SOUND_STREAM)
		return TRUE
	if(!SSticker?.login_music)
		return FALSE
	playsound_client(src, SSticker.login_music, null, 70, FALSE, VOLUME_LOBBY, SOUND_CHANNEL_LOBBY, SOUND_STREAM)
	return TRUE

/client/verb/select_banda_menu_interface()
	set name = "Выбрать интерфейс"
	set category = "Preferences.Menu"
	set desc = "Выбор классического или терминального интерфейса лобби и редактора персонажа."

	if(!prefs)
		return
	var/current_label = prefs.uses_banda_terminal_interface() ? "Терминальный" : "Классический"
	var/selection = tgui_alert(src, "Текущий интерфейс: [current_label].\nВыберите оформление лобби и редактора персонажа.", "Интерфейс меню", list("Терминальный", "Классический", "Отмена"))
	if(!selection || selection == "Отмена")
		return
	var/new_interface = selection == "Классический" ? BANDA_MENU_INTERFACE_CLASSIC : BANDA_MENU_INTERFACE_TERMINAL
	if(!prefs.set_and_save_banda_menu_interface(new_interface))
		to_chat(src, SPAN_WARNING("Не удалось сохранить выбор интерфейса. Предыдущее значение восстановлено; повторите попытку."))
		return
	to_chat(src, SPAN_NOTICE("Выбран интерфейс: [selection]. Настройка сохранена."))
	if(mob)
		close_browser(mob, "banda_hair_picker")
		close_browser(mob, "banda_facial_hair_picker")
		close_browser(mob, "preferencebrowser")
		winshow(mob, "preferencewindow", FALSE)

	if(istype(mob, /mob/new_player))
		src << sound(null, repeat = FALSE, wait = FALSE, volume = 0, channel = SOUND_CHANNEL_LOBBY)
		playtitlemusic()
		var/mob/new_player/player = mob
		player.new_player_panel_proc(TRUE)

/datum/custom_event_info/proc/refresh_banda_lobby_panels()
	if(faction != "Global")
		return
	for(var/mob/new_player/player as anything in GLOB.new_player_list)
		player.new_player_panel_proc(TRUE)

#undef BANDA_LOBBY_BROWSER
#undef BANDA_TERMINAL_INTERFACE_COLOR
#undef BANDA_TERMINAL_TEXT_COLOR
#undef BANDA_TERMINAL_EFFECTS_FULL
#undef BANDA_TERMINAL_EFFECTS_REDUCED
#undef BANDA_TERMINAL_EFFECTS_OFF
#undef BANDA_INTERFACE_LANGUAGE_RUSSIAN
#undef BANDA_INTERFACE_LANGUAGE_ENGLISH
#undef BANDA_MENU_INTERFACE_CLASSIC
#undef BANDA_MENU_INTERFACE_TERMINAL
