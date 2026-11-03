/datum/preferences/proc/get_terminal_character_preferences_header(mob/user)
	close_banda_accessory_pickers(stale_only = TRUE)
	update_banda_character_feedback()
	var/character_name = html_encode(real_name || "UNKNOWN")
	var/character_preview
	var/preview_effect_duration = 0
	if(current_menu == "marine")
		ensure_banda_character_preview()
		character_preview = get_banda_character_preferences_preview(user.client)
		preview_effect_duration = get_banda_preview_effect_duration()

	var/text_override_class = get_banda_terminal_text_override_class()
	var/text_override_style = get_banda_terminal_palette_style()
	var/effect_class = get_banda_terminal_effect_class()
	var/glow_class = get_banda_terminal_glow_class()
	var/name_length = length_char(real_name || "")
	var/name_size_class = name_length > 46 ? " name-very-long" : (name_length > 34 ? " name-long" : (name_length > 22 ? " name-medium" : ""))
	var/tab_transition_class = !isnull(banda_last_terminal_menu) && banda_last_terminal_menu != current_menu ? " tab-switching" : ""
	var/opening_class = banda_character_editor_open ? "" : " terminal-opening"
	var/decode_title = !banda_character_editor_open && uses_banda_terminal_decorative_effects()
	banda_character_editor_open = TRUE
	var/highlight_preference = html_encode(banda_pending_highlight_preference || "")
	banda_pending_highlight_preference = null
	var/terminal_notice = banda_terminal_notice
	banda_terminal_notice = null
	var/notice_class = terminal_notice ? " notice" : (banda_terminal_dirty ? " dirty" : "")
	var/notice_text
	if(terminal_notice == "save")
		notice_text = uses_banda_english_interface() ? "DATA SYNCHRONIZED" : "ДАННЫЕ СИНХРОНИЗИРОВАНЫ"
	else if(terminal_notice == "reload")
		notice_text = uses_banda_english_interface() ? "CONNECTION RESTORED // ARCHIVE VERIFIED" : "СВЯЗЬ ВОССТАНОВЛЕНА // АРХИВ ПРОВЕРЕН"
	else if(banda_terminal_dirty)
		notice_text = uses_banda_english_interface() ? "UNSAVED CHANGES" : "ЕСТЬ НЕСОХРАНЁННЫЕ ИЗМЕНЕНИЯ"
	else
		notice_text = "&nbsp;"
	banda_last_terminal_menu = current_menu
	var/dat = get_banda_character_preferences_styles()
	dat += "<body onselectstart='return false;'>"
	if(!path)
		return dat

	dat += "<div class='prefs-crt[text_override_class][tab_transition_class][opening_class][effect_class][glow_class]' data-category-blocks='[current_menu == "marine" && banda_category_blocks ? "1" : "0"]' data-category-language='[uses_banda_english_interface() ? "en" : "ru"]' data-highlight='[highlight_preference]' style='[text_override_style]'><div class='prefs-crt-speckle'></div><div class='prefs-crt-frame'></div>"
	dat += "<div class='prefs-terminal'>"
	dat += "<div class='prefs-header'>"
	dat += "<div class='prefs-brand'><div class='prefs-brand-title[name_size_class]' data-terminal-decode='[decode_title ? "1" : "0"]'>ЛИЧНОЕ ДЕЛО &quot;<span class='prefs-no-translate'>[character_name]</span>&quot;</div><div class='prefs-save-state[notice_class]'>[notice_text]</div></div>"
	dat += "<div class='prefs-slot-tools'>"
	dat += "<a class='prefs-tool' href=\"byond://?src=\ref[user];preference=open_load_dialog\"><b>Load Slot</b></a>"
	dat += "<a class='prefs-tool' onclick=\"terminalActionFeedback('save');\" href=\"byond://?src=\ref[user];preference=save\"><b>Save Slot</b></a>"
	dat += "<a class='prefs-tool' onclick=\"terminalActionFeedback('reload');\" href=\"byond://?src=\ref[user];preference=reload\"><b>Reload Slot</b></a>"
	dat += "</div></div>"
	dat += "<div class='prefs-tabs'>"
	for(var/list/tab as anything in get_banda_character_menu_tabs())
		var/menu_id = tab["id"]
		var/menu_label = tab["label"]
		dat += "<a class='prefs-tab[current_menu == menu_id ? " active linkOff" : ""]' href=\"byond://?src=\ref[user];preference=change_menu;menu=[menu_id]\"><b>[menu_label]</b></a>"
	dat += "</div>"
	dat += "<div class='prefs-workspace[current_menu == "marine" ? " human" : " full"]'>"
	if(current_menu == "marine")
		var/rotate_left_label = uses_banda_english_interface() ? "Rotate left" : "Повернуть влево"
		var/rotate_right_label = uses_banda_english_interface() ? "Rotate right" : "Повернуть вправо"
		dat += "<div class='prefs-human-layout'><div class='prefs-personal-column'>"
		dat += "<div class='prefs-preview-panel' data-static-duration='[preview_effect_duration]'><div class='prefs-preview-title prefs-no-translate'>[character_name]</div>"
		dat += "<div class='prefs-preview-stage'>"
		dat += "<a class='prefs-preview-arrow left' title='[rotate_left_label]' aria-label='[rotate_left_label]' href='byond://?_src_=prefs;preference=rotate_preview;direction=left'><svg viewBox='0 0 24 36' aria-hidden='true' focusable='false'><path d='M16 6 L8 18 L16 30'/></svg></a>"
		dat += "[character_preview]"
		dat += "<a class='prefs-preview-arrow right' title='[rotate_right_label]' aria-label='[rotate_right_label]' href='byond://?_src_=prefs;preference=rotate_preview;direction=right'><svg viewBox='0 0 24 36' aria-hidden='true' focusable='false'><path d='M8 6 L16 18 L8 30'/></svg></a>"
		dat += "</div></div><div class='prefs-identity prefs-fields'></div></div>"
	dat += "<div class='prefs-content prefs-fields'>"
	return dat

/datum/preferences/proc/get_terminal_character_preferences_footer()
	var/human_layout_end = current_menu == "marine" ? "</div>" : ""
	return "</div>[human_layout_end]</div><a class='prefs-back-button' href='byond://?_src_=prefs;preference=return_to_lobby'>вернуться назад</a></div></div></body>"

/datum/preferences/proc/show_terminal_character_preferences(mob/user, html)
	if(istype(user, /mob/new_player))
		var/mob/new_player/player = user
		player.banda_lobby_visible = FALSE
		player.banda_lobby_render_generation++
		winshow(user, "preferencewindow", FALSE)
		winset(user.client, "mapwindow.lobbybrowser", "is-visible=true")
		show_browser(user, html, null, "lobbybrowser", "can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0", existing_container = "mapwindow")
		return
	winshow(user, "preferencewindow", TRUE)
	show_browser(user, html, "Настройки персонажа", "preferencebrowser", width = 1000, height = 800, existing_container = "preferencewindow")
	onclose(user, "preferencewindow", src)
