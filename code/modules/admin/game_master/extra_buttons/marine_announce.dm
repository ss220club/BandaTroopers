/client/proc/admin_marine_announcement()
	set name = "Command Announcement"
	set category = "Game Master.Extras Screen Alert" // SS220 EDIT

	if(!check_rights(R_ADMIN))
		return

	var/body = tgui_input_text(src, "Введите основной текст объявления.", title = "Announcement Body", multiline = TRUE, encode = FALSE)
	if(!body)
		return
	var/title = tgui_input_text(src, "Введите заголовок объявления. Оставьте поле пустым для заголовка по умолчанию.", title = "Announcement Title")
	if(!title)
		title = COMMAND_ANNOUNCE
	marine_announcement(body, "[title]")
	message_admins("[key_name_admin(src)] has made an admin command announcement.")
	log_admin("[key_name_admin(src)] made an admin command announcement: [body]")
