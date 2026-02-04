// Colonial Marines Cryo Wake-up Intro System
// Интро система пробуждения из крио-капсулы для Colonial Marines
// Помещать в: code/modules/colonial_marines/ или любой другой модуль

/datum/controller/cryo_intro
	var/shown_players = list()

/proc/show_cryo_intro(mob/living/carbon/human/player)
	if(!player || !player.client)
		return
	
	// Получаем данные персонажа (названия переменных могут отличаться в вашем билде)
	var/rank = player.military_rank ? player.military_rank : "РЯДОВОЙ"
	var/name = player.real_name ? player.real_name : "НЕИЗВЕСТНО"
	var/squad = "АЛЬФА" // Если есть переменная squad, используйте player.squad
	var/role = player.job ? player.job : "СТРЕЛОК"
	
	// Собираем список отряда (другие игроки в том же отряде)
	var/list/squad_data = list()
	for(var/mob/living/carbon/human/H in world)
		if(H.client && H.stat != DEAD && H != player)
			// Здесь можно добавить проверку на один и тот же отряд (например H.squad == player.squad)
			var/list/mate = list(
				"rank" = H.military_rank ? H.military_rank : "РЯДОВОЙ",
				"name" = H.real_name,
				"role" = H.job ? H.job : "СТРЕЛОК"
			)
			squad_data += list(mate)

	// Сериализация данных в JS-объект
	var/data_to_send = list(
		"rank" = rank,
		"name" = name,
		"role" = role,
		"squad" = squad,
		"squadmates" = squad_data
	)
	
	var/json = json_encode(data_to_send)
	
	// Подготавливаем HTML (вставляем данные прямо в скрипт)
	var/html_content = file2text("html/colonial_marine_intro.html")
	if(!html_content)
		return
	
	// Инъекция данных через замену метки или вставку перед основным скриптом
	html_content = replacetext(html_content, "window.ss13Data || {", "[json] || {")
	
	// Показ окна (используем стандартный браузер BYOND)
	player.client << browse(html_content, "window=cryo_intro;size=1000x800;border=0;can_close=0;can_resize=0;titlebar=0")

// Хук при заходе (может потребоваться интеграция в вашу систему логина)
/mob/living/carbon/human/proc/handle_cryo_intro()
	if(client)
		// Небольшая задержка, чтобы игрок успел "прогрузиться"
		addtimer(CALLBACK(GLOBAL_PROC, /proc/show_cryo_intro, src), 10)

/mob/living/carbon/human/on_cryo_wakeup()
	// Вызывается при пробуждении из крио
	if(client)
		show_cryo_intro(src)

// HOOK для запуска интро при присоединении игрока
/proc/on_player_login()
	var/mob/living/carbon/human/player = mob
	if(!player)
		return
	
	// Даем небольшую задержку для инициализации всех данных
	addtimer(CALLBACK(GLOBAL_PROC, /proc/show_cryo_intro, player), 1 SECOND)

// Добавляем хук при спавне игрока
/mob/living/carbon/human/Login()
	. = ..()
	
	// Проверяем, в крио ли игрок
	if(stat == UNCONSCIOUS || location_is_cryopod(src))
		addtimer(CALLBACK(GLOBAL_PROC, /proc/show_cryo_intro, src), 0.5 SECOND)

/proc/location_is_cryopod(mob/living/M)
	// Проверяет, находится ли моб в крио-капсуле
	if(!M || !M.loc)
		return FALSE
	
	var/obj/structure/machinery/cryo_cell/cryo = M.loc
	if(istype(cryo))
		return TRUE
	
	return FALSE

// Альтернативный вариант: показывать интро при входе в игру
/mob/living/carbon/human/Life()
	. = ..()
	
	if(client && !shown_intro)
		shown_intro = TRUE
		show_cryo_intro(src)

// Для отслеживания показа интро
/mob/living/carbon/human
	var/shown_intro = FALSE

// ===== ИНТЕГРАЦИЯ С СУЩЕСТВУЮЩЕЙ СИСТЕМОЙ SS13 =====
// Добавьте эту линию в файл __DEFINES/game.dm или подобный:
// #define SHOW_CRYO_INTRO 1

// Добавьте в /mob/living/carbon/human/Initialize() или подобный файл инициализации:
// if(SHOW_CRYO_INTRO)
//     addtimer(CALLBACK(GLOBAL_PROC, /proc/show_cryo_intro, src), 2 SECOND)
