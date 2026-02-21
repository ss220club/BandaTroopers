// Датум для сохранения последних использованных портретов
/datum/screen_alert_save
	var/save_slot_name = "ERROR - СООБЩИТЕ РАЗРАБОТЧИКУ"
	var/icon_choice
	var/icon_choice_state
	var/selectable_factions = list(FACTION_MARINE, FACTION_UPP, FACTION_WY, FACTION_CLF, FACTION_FREELANCER, FACTION_TWE)
	var/selectable_icons = list(
		"marine",
		"marine_2",
		"requisition",
		"requisition_2",
		"overwatch",
		"overwatch_2",
		"overwatch_3",
		"spacesuit",
		"robot",
		"pilot",
		"pilot_2",
		"pilot_3",
		"beret",
		"beret_2",
		"trooper",
		"trooper_2",
		"scientist",
		"messiah",
		"militia",
		"guy",
		"agent",
		"operator",
		"vip",
		"woman_fleet",
		//"pmc_bald", SS220 edit
		)
	var/portrait_color
	var/name
	var/faction_to_send
	var/alert_type
	var/title
	var/text

/datum/screen_alert_save/proc/choose_or_use_save(client/C)
	var/option_text = "Отправить текст сохранения"
	var/option_repeat = "Повтор последнего сообщения"
	var/option_rewrite_and_send = "Перезаписать и отправить"
	var/option_rewrite = "Перезаписать без отправки"
	var/option_write_and_send = "Записать и отправить"
	var/option_write = "Записать без отправки"

	var/choose_list
	if(alert_type)
		choose_list = list(option_text, option_repeat, option_rewrite_and_send, option_rewrite)
	else
		choose_list = list(option_write_and_send, option_write)

	var/choice_save_description = "Настроить слот сохранения перед использованием."
	if(alert_type)
		choice_save_description = "Использовать сохранение слота или перезаписать его? \
			Текущие настройки: [faction_to_send] [name] - [alert_type] ([icon_choice_state])"
	var/choice_save = tgui_input_list(C, choice_save_description, "Настройка - [save_slot_name]", choose_list)
	switch(choice_save)
		if("Отправить текст сохранения")
			input_text(C)
			send_save_alert(C)
		if("Повтор последнего сообщения")
			send_save_alert(C)

		if("Перезаписать и отправить", "Записать и отправить")
			input_type(C)
			input_text(C)
			send_save_alert(C)
		if("Перезаписать без отправки", "Записать без отправки")
			input_type(C)

/datum/screen_alert_save/proc/input_type(client/C)
	faction_to_send = tgui_input_list(C, "Выберите, какой фракции будет отправлено это сообщение; оставьте поле пустым, чтобы отправить всем.", "Faction Type", selectable_factions)

	alert_type = tgui_input_list(C, "Выберите тип уведомления на экране, которое вы хотите отправить.", "Alert Type", list("Standard","Portrait"))

	if(!alert_type)
		return

	icon_choice_state = "message" // Для отображения в информации
	if(alert_type == "Portrait")
		icon_choice = tgui_input_list(C, "Загрузить иконку? (64x64 для наилучшего результата)", "Icon", list("Yes","No"))
		if(icon_choice == "Yes")
			icon_choice = input(usr, "Выбор иконки", "Upload Icon") as null|file
			icon_choice_state = tgui_input_text(C, "Portrait icon state, leave blank for unknown.", "Icon state")
		else
			icon_choice = 'icons/ui_icons/screen_alert_images.dmi'
			icon_choice_state = tgui_input_list(C, "Тип портрета.", "Icon state", selectable_icons)
			portrait_color = tgui_input_list(C, "Цвет портрета, оставьте поле пустым для значения по умолчанию.", "Icon state", list("red", "green", "blue"))
			if(!portrait_color)
				portrait_color = "green"
			icon_choice_state = icon_choice_state + "_[portrait_color]"
		if(!icon_choice_state)
			icon_choice_state = "unknown"

	if(alert_type == "Portrait")
		name = tgui_input_text(C, "Введите имя, которое будет подписано под портретом.", title = "Name")

	title = tgui_input_text(C, "Введите заголовок всплывающего уведомления. Оставьте поле пустым для заголовка по умолчанию.", title = "Announcement Title")
	if(!title)
		title = COMMAND_ANNOUNCE

/datum/screen_alert_save/proc/input_text(client/C)
	text = tgui_input_text(C, "Введите текст сообщения для всплывающего уведомления на экране.", title = "Announcement Body", multiline = TRUE, encode = FALSE)

/datum/screen_alert_save/proc/send_save_alert(client/C)
	if(!text)
		return

	var/list/alert_receivers = list()
	for(var/mob/living/carbon/human/human as anything in GLOB.alive_human_list)
		if(!faction_to_send)
			alert_receivers += human
		else if(faction_to_send == human.faction)
			alert_receivers += human
	alert_receivers += GLOB.observer_list
	for(var/mob/mob_receiver in alert_receivers)
		if(alert_type == "Standard")
			mob_receiver.play_screen_text("<span class='langchat_notification' style=text-align:center valign='top'><u>[uppertext(title)]</u></span><br>" + text, /atom/movable/screen/text/screen_text/command_order) //SS220 Fonts
		else
			mob_receiver.play_screen_text("<span class='langchat_notification' style=text-align:left valign='top'><u>[uppertext(title)]</u></span><br>" + text, new /atom/movable/screen/text/screen_text/potrait(null, null, name, icon_choice, icon_choice_state)) //SS220 Fonts
	message_admins("[key_name_admin(C)] has made an admin screen alert from [save_slot_name] [name]. ")
	log_admin("[key_name_admin(C)] made an admin screen alert: [save_slot_name] [name] - [text]")


// Слоты
/datum/screen_alert_save/save_slot_1
	save_slot_name = "Слот 1"

/datum/screen_alert_save/save_slot_2
	save_slot_name = "Слот 2"

/datum/screen_alert_save/save_slot_3
	save_slot_name = "Слот 3"

/datum/screen_alert_save/save_slot_4
	save_slot_name = "Слот 4"

/datum/screen_alert_save/save_slot_5
	save_slot_name = "Слот 5"

/datum/screen_alert_save/save_slot_6
	save_slot_name = "Слот 6"
