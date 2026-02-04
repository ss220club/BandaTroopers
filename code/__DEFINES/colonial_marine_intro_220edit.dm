// Colonial Marines Cryo Wake-up Intro System
// Интро система пробуждения из крио-капсулы для Colonial Marines
// Помещать в: code/modules/colonial_marines/ или любой другой модуль

// Финальная "безопасная" версия для Colonial Marines
// Этот код использует динамический поиск переменных, чтобы избежать ошибок компиляции

/proc/show_cryo_intro(mob/living/carbon/human/player)
	if(!player || !player.client)
		return

	// Безопасное получение Звания
	var/rank = "РЯДОВОЙ"
	if("military_rank" in player.vars)
		rank = player.vars["military_rank"]

	// Безопасное получение Имени
	var/name = player.real_name ? player.real_name : "НЕИЗВЕСТНО"

	// Безопасное получение Отряда
	var/squad_name = "АЛЬФА"
	if("squad" in player.vars)
		var/datum/S = player.vars["squad"]
		if(S && ("name" in S.vars))
			squad_name = S.vars["name"]

	// Безопасное получение Роли (Специальности)
	var/role = "СТРЕЛОК"
	if("job" in player.vars)
		role = player.vars["job"]
	else if("mind" in player.vars)
		var/datum/M = player.vars["mind"]
		if(M && ("assigned_role" in M.vars))
			role = M.vars["assigned_role"]
		else if(M && ("assigned_job" in M.vars)) // Попытка альтернативного имени переменной
			role = M.vars["assigned_job"]

	// Собираем список отряда (макс 14 человек + игрок)
	var/list/squad_data = list()
	var/list/all_mobs = world.contents
	var/found_count = 0

	for(var/mob/living/carbon/human/H in all_mobs)
		if(found_count >= 14) break
		if(H.client && H != player && H.stat != 2) // 2 - DEAD
			var/m_rank = "РЯДОВОЙ"
			if("military_rank" in H.vars) m_rank = H.vars["military_rank"]

			var/m_role = "СТРЕЛОК"
			if("job" in H.vars) m_role = H.vars["job"]

			var/list/mate = list(
				"rank" = m_rank,
				"name" = H.real_name,
				"role" = m_role
			)
			squad_data += list(mate)
			found_count++

	var/list/data_to_send = list(
		"rank" = rank,
		"name" = name,
		"role" = role,
		"squad" = squad_name,
		"squadmates" = squad_data
	)

	var/json = json_encode(data_to_send)
	var/html_content = file2text("html/colonial_marine_intro.html")

	if(!html_content)
		return

	// Вставка данных в HTML
	html_content = replacetext(html_content, "window.ss13Data || {", "[json] || {")

	// Показ окна браузера
	player.client << browse(html_content, "window=cryo_intro;size=1000x800;border=0;can_close=0;can_resize=0;titlebar=0")

// Прок для вызова из моба
/mob/living/carbon/human/proc/handle_cryo_intro()
	if(!client) return
	var/mob/living/carbon/human/H = src
	spawn(10) // Задержка в 1 секунду перед показом
		if(H && H.client)
			show_cryo_intro(H)
