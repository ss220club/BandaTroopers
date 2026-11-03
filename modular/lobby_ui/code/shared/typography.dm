/datum/preferences
	var/banda_terminal_font = "default"
	var/banda_terminal_font_size = 14
	var/datum/banda_terminal_typography/banda_typography_dialog

/datum/preferences/proc/get_banda_terminal_fonts()
	var/static/list/fonts = list(
		"default" = "",
		"Consolas" = "Consolas, 'Lucida Console', monospace",
		"Lucida Console" = "'Lucida Console', Consolas, monospace",
		"Courier New" = "'Courier New', monospace",
		"Arial" = "Arial, sans-serif",
		"Verdana" = "Verdana, sans-serif",
	)
	return fonts

/datum/preferences/proc/set_banda_terminal_typography(font, size)
	var/list/fonts = get_banda_terminal_fonts()
	banda_terminal_font = (font in fonts) ? font : "default"
	banda_terminal_font_size = isnum(size) ? clamp(round(size), 10, 20) : 14

/datum/preferences/proc/get_banda_terminal_font_family()
	var/list/fonts = get_banda_terminal_fonts()
	return fonts[banda_terminal_font]

/// The main lobby is intentionally more readable than the shared editor baseline.
/datum/preferences/proc/get_banda_terminal_font_size_offset(sheet)
	return sheet == "lobby" ? 3 : 0

/// Resolve trusted template declarations once per cached typography variant.
/datum/preferences/proc/apply_banda_terminal_typography(css, pixel_offset = 0)
	var/font = get_banda_terminal_font_family()
	var/effective_base_size = banda_terminal_font_size + pixel_offset
	var/capped_font_size = min(banda_terminal_font_size, 14)
	var/dossier_name_size = round(13 * capped_font_size / 14, 0.1)
	var/dossier_name_line_height = round(17 * capped_font_size / 14, 0.1)
	var/dossier_row_size = round(11 * capped_font_size / 14, 0.1)
	var/dossier_row_line_height = round(13 * capped_font_size / 14, 0.1)
	if(font)
		// Do not rename @font-face registrations to a selected system font.
		css += "\nhtml body, body a, body input, body textarea, body button, body select, body div, body span, body h1, body h2, body h3, body td, body th {font-family: [font] !important;}"
	if(effective_base_size > 14)
		css += "\n.brand-title, .menu-title, .menu-subtitle, .dossier-title, .data-label {white-space: normal; overflow-wrap: break-word; word-wrap: break-word;} .dossier-title {text-align: center;} .prefs-slot-tools {flex-wrap: wrap; max-width: 55%;} .prefs-tabs a.prefs-tab {white-space: normal;}"
	// Host browser styles also set fonts on tables, links and form controls.
	// Explicit terminal declarations must win; everything else inherits our base.
	var/regex/sizes = regex("(font-size|line-height):\\s*([0-9.]+)px(/\\*banda-no-lobby-offset(?:-cap14)?\\*/)?(?:\\s*!important)?", "g")
	var/list/parts = list()
	var/cursor = 1
	while(sizes.Find(css, cursor))
		parts += copytext(css, cursor, sizes.index)
		var/declaration_font_size = sizes.group[3] && findtext(sizes.group[3], "-cap14") ? min(banda_terminal_font_size, 14) : banda_terminal_font_size
		var/declaration_offset = sizes.group[3] ? 0 : pixel_offset
		parts += "[sizes.group[1]]: [round(text2num(sizes.group[2]) * declaration_font_size / 14 + declaration_offset, 0.1)]px !important"
		cursor = sizes.index + length(sizes.match)
	parts += copytext(css, cursor)
	css = jointext(parts, "")
	// Low specificity preserves scaled component/heading rules, including pseudo-text.
	css += "\nhtml body {--banda-terminal-base-size: [banda_terminal_font_size]px; --banda-terminal-effective-size: [effective_base_size]px; --banda-terminal-capped-size: [capped_font_size]px; --banda-dossier-name-size: [dossier_name_size]px; --banda-dossier-name-line-height: [dossier_name_line_height]px; --banda-dossier-row-size: [dossier_row_size]px; --banda-dossier-row-line-height: [dossier_row_line_height]px; font-size: [effective_base_size]px !important; line-height: 1.4 !important;} html body * {font-size: inherit !important; line-height: inherit !important;}"
	return css

/datum/preferences/proc/show_banda_typography_dialog(mob/user, mode)
	if(user?.client != owner || !uses_banda_terminal_interface())
		return
	if(banda_typography_dialog)
		qdel(banda_typography_dialog)
	banda_typography_dialog = new(src, mode)
	banda_typography_dialog.tgui_interact(user)

/datum/banda_terminal_typography
	var/datum/preferences/preferences
	var/mode

/datum/banda_terminal_typography/New(datum/preferences/preferences, mode)
	src.preferences = preferences
	src.mode = mode

/datum/banda_terminal_typography/Destroy()
	if(preferences?.banda_typography_dialog == src)
		preferences.banda_typography_dialog = null
	preferences = null
	SStgui.close_uis(src)
	return ..()

/datum/banda_terminal_typography/ui_state(mob/user)
	return GLOB.always_state

/datum/banda_terminal_typography/ui_status(mob/user, datum/ui_state/state)
	return user?.client && user.client == preferences?.owner && preferences.uses_banda_terminal_interface() ? UI_INTERACTIVE : UI_CLOSE

/datum/banda_terminal_typography/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LobbyTypography", preferences.uses_banda_english_interface() ? "Interface typography" : "Шрифт интерфейса")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/banda_terminal_typography/ui_close(mob/user)
	. = ..()
	if(!QDELETED(src))
		qdel(src)

/datum/banda_terminal_typography/ui_data(mob/user)
	var/list/options = list()
	for(var/font in preferences.get_banda_terminal_fonts())
		options += list(list("value" = font, "displayText" = font == "default" ? (preferences.uses_banda_english_interface() ? "Terminal (default)" : "Терминальный (по умолчанию)") : font))
	return list("mode" = mode, "english" = preferences.uses_banda_english_interface(), "font" = preferences.banda_terminal_font, "size" = preferences.banda_terminal_font_size, "fonts" = options, "presentation" = preferences.get_banda_tgui_input_presentation())

/datum/banda_terminal_typography/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(ui.user?.client != preferences?.owner || !preferences?.uses_banda_terminal_interface())
		return FALSE
	if(action == "cancel")
		qdel(src)
		return TRUE
	if(action != "apply")
		return FALSE
	var/datum/preferences/target = preferences
	var/font = mode == "font" ? params["font"] : target.banda_terminal_font
	var/size = mode == "size" ? params["size"] : target.banda_terminal_font_size
	if(!(font in target.get_banda_terminal_fonts()) || !isnum(size) || size < 10 || size > 20)
		return FALSE
	target.set_banda_terminal_typography(font, size)
	target.save_preferences()
	var/mob/user = ui.user
	qdel(src)
	target.ShowChoices(user)
	return TRUE
