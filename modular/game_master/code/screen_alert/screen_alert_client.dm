/client/proc/screen_alert_menu_saves(slot)
	if(!check_rights(R_ADMIN))
		return

	if(slot < 1 || slot > length(GLOB.screen_alert_saves))
		return

	var/datum/screen_alert_save/datum = GLOB.screen_alert_saves[slot]
	datum.choose_or_use_save(src)

/client/proc/screen_alert_menu_save_1()
	set name = "Send Screen Alert - Save 1"
	set category = "Game Master.Extras Screen Alert"
	screen_alert_menu_saves(1)

/client/proc/screen_alert_menu_save_2()
	set name = "Send Screen Alert - Save 2"
	set category = "Game Master.Extras Screen Alert"
	screen_alert_menu_saves(2)

/client/proc/screen_alert_menu_save_3()
	set name = "Send Screen Alert - Save 3"
	set category = "Game Master.Extras Screen Alert"
	screen_alert_menu_saves(3)

/client/proc/screen_alert_menu_save_4()
	set name = "Send Screen Alert - Save 4"
	set category = "Game Master.Extras Screen Alert"
	screen_alert_menu_saves(4)

/client/proc/screen_alert_menu_save_5()
	set name = "Send Screen Alert - Save 5"
	set category = "Game Master.Extras Screen Alert"
	screen_alert_menu_saves(5)

/client/proc/screen_alert_menu_save_6()
	set name = "Send Screen Alert - Save 6"
	set category = "Game Master.Extras Screen Alert"
	screen_alert_menu_saves(6)
