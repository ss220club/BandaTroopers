/datum/preferences/proc/get_classic_character_preferences_header(mob/user)
	update_preview_icon()
	var/dat = {"
		<style>
			#column1 { width: 30%; float: left; }
			#column2 { width: 30%; float: left; }
			#column3 { width: 40%; float: left; }
			.square { width: 15px; height: 15px; display: inline-block; }
		</style>
		<body onselectstart='return false;'>
	"}
	if(!path)
		return dat

	dat += "<center>"
	dat += "<a href=\"byond://?src=\ref[user];preference=open_load_dialog\"><b>Load Slot</b></a> - "
	dat += "<a href=\"byond://?src=\ref[user];preference=save\"><b>Save Slot</b></a> - "
	dat += "<a href=\"byond://?src=\ref[user];preference=reload\"><b>Reload Slot</b></a>"
	dat += "</center><hr><center>"
	var/first_tab = TRUE
	for(var/list/tab as anything in get_banda_character_menu_tabs())
		if(!first_tab)
			dat += " - "
		first_tab = FALSE
		var/menu_id = tab["id"]
		var/menu_label = tab["label"]
		dat += "<a[current_menu == menu_id ? " class='linkOff'" : ""] href=\"byond://?src=\ref[user];preference=change_menu;menu=[menu_id]\"><b>[menu_label]</b></a>"
	dat += "</center><hr>"
	return dat

/datum/preferences/proc/get_classic_character_preferences_footer()
	return "</body>"

/datum/preferences/proc/show_classic_character_preferences(mob/user, html)
	close_browser(user, "lobbybrowser")
	winset(user.client, "mapwindow.lobbybrowser", "is-visible=false")
	winshow(user, "preferencewindow", TRUE)
	show_browser(user, html, "Preferences", "preferencebrowser", width = 1000, height = 800, existing_container = "preferencewindow")
	onclose(user, "preferencewindow", src)
