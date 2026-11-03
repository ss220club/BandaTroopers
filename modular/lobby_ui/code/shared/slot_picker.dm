/datum/preferences/proc/show_banda_load_slot_dialog(mob/user)
	if(!user?.client || !uses_banda_terminal_interface())
		return FALSE

	var/title = uses_banda_english_interface() ? "LOAD CHARACTER SLOT" : "ЗАГРУЗКА СЛОТА ПЕРСОНАЖА"
	var/subtitle = uses_banda_english_interface() ? "SELECT AN ARCHIVE RECORD" : "ВЫБЕРИТЕ ЗАПИСЬ ИЗ АРХИВА"
	var/html = get_banda_auxiliary_window_header(title, subtitle, "banda-slot-window")
	html += "<div class='banda-slot-grid'>"
	var/savefile/character_file = new /savefile(path)
	if(character_file)
		for(var/slot_number in 1 to MAX_SAVE_SLOTS)
			character_file.cd = "/character[slot_number]"
			var/loaded_name
			var/loaded_slot_label
			character_file["real_name"] >> loaded_name
			character_file["slot_label"] >> loaded_slot_label
			if(!loaded_name)
				loaded_name = "Character[slot_number]"
			if(!loaded_slot_label)
				loaded_slot_label = uses_banda_english_interface() ? "NO LABEL" : "БЕЗ МЕТКИ"
			var/active_class = slot_number == default_slot ? " active" : ""
			html += "<a class='banda-slot-card[active_class]' href='byond://?_src_=prefs;preference=changeslot;num=[slot_number]'>"
			html += "<span class='banda-slot-index'>[uses_banda_english_interface() ? "SLOT" : "СЛОТ"] // [slot_number]</span>"
			html += "<span class='banda-slot-name prefs-no-translate'>[html_encode(loaded_name)]</span><span class='banda-slot-label prefs-no-translate'>[html_encode(loaded_slot_label)]</span></a>"
	html += "</div><div class='banda-aux-actions'><a href='byond://?src=\ref[user];preference=close_load_dialog'>[uses_banda_english_interface() ? "CLOSE" : "ЗАКРЫТЬ"]</a></div>"
	html += get_banda_auxiliary_window_footer()
	close_browser(user, "saves")
	show_browser(user, html, uses_banda_english_interface() ? "Load Character" : "Загрузить слот", "saves", width = 760, height = 620)
	return TRUE
