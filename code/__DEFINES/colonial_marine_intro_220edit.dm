// Colonial Marines Cryo Wake-up Intro System
// Интро система пробуждения из крио-капсулы для Colonial Marines
// Помещать в: code/modules/colonial_marines/ или любой другой модуль

// Исправленная версия для Colonial Marines SS13
// Помещать в: code/modules/colonial_marines/

/proc/show_cryo_intro(mob/living/carbon/human/player)
	if(!player || !player.client)
		return

	// Безопасное получение данных (совместимость с разными билдами)
	var/rank = "РЯДОВОЙ"
	if(player.vars["military_rank"])
		rank = player.vars["military_rank"]

	var/name = player.real_name ? player.real_name : "НЕИЗВЕСТНО"
	var/squad = "АЛЬФА" // В CM обычно player.squad.name

	var/role = "СТРЕЛОК"
	if(player.vars["job"])
		role = player.vars["job"]
	else if(player.mind && player.mind.assigned_role)
		role = player.mind.assigned_role

	// Собираем список отряда
	var/list/squad_data = list()
	var/count = 0
	for(var/mob/living/carbon/human/H in world)
		if(count >= 14) break // Ограничение списка
		if(H.client && H != player && H.stat != 2) // 2 - DEAD
			var/list/mate = list(
				"rank" = (H.vars["military_rank"] ? H.vars["military_rank"] : "РЯДОВОЙ"),
				"name" = H.real_name,
				"role" = (H.vars["job"] ? H.vars["job"] : "СТРЕЛОК")
			)
			squad_data += list(mate)
			count++

	var/list/data_to_send = list(
		"rank" = rank,
		"name" = name,
		"role" = role,
		"squad" = squad,
		"squadmates" = squad_data
	)

	var/json = json_encode(data_to_send)
	var/html_content = file2text("html/colonial_marine_intro.html")

	if(!html_content)
		return

	// Вставка данных
	html_content = replacetext(html_content, "window.ss13Data || {", "[json] || {")

	// Показ окна
	player.client << browse(html_content, "window=cryo_intro;size=1000x800;border=0;can_close=0;can_resize=0;titlebar=0")

// Прок для вызова из Login()
/mob/living/carbon/human/proc/handle_cryo_intro()
	if(client)
		var/mob/living/carbon/human/H = src
		spawn(10) // Замена addtimer
			if(H && H.client)
				show_cryo_intro(H)

// Интеграция в Login()
// Поместите этот вызов в ваш основной файл login.dm внутри /mob/living/carbon/human/Login()
/*
/mob/living/carbon/human/Login()
	. = ..()
	if(client)
		src.handle_cryo_intro()
*/

/mob/living/carbon/human/proc/on_cryo_wakeup()
	src.handle_cryo_intro()

// ===== ИНТЕГРАЦИЯ С СУЩЕСТВУЮЩЕЙ СИСТЕМОЙ SS13 =====
// Добавьте эту линию в файл __DEFINES/game.dm или подобный:
// #define SHOW_CRYO_INTRO 1

// Добавьте в /mob/living/carbon/human/Initialize() или подобный файл инициализации:
// if(SHOW_CRYO_INTRO)
//     addtimer(CALLBACK(GLOBAL_PROC, /proc/show_cryo_intro, src), 2 SECOND)
