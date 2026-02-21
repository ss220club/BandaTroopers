#define MODULAR_ROUND_OUTRO_BG_FADE_IN_TIME (2.5 SECONDS)
#define MODULAR_ROUND_OUTRO_TEXT_FADE_IN_TIME (2.2 SECONDS)
#define MODULAR_ROUND_OUTRO_SCROLL_START_DELAY (1.5 SECONDS)
#define MODULAR_ROUND_OUTRO_SCROLL_TIME (34 SECONDS)
#define MODULAR_ROUND_OUTRO_FADE_TIME (2 SECONDS)
#define MODULAR_ROUND_OUTRO_TOTAL_TIME (MODULAR_ROUND_OUTRO_SCROLL_START_DELAY + MODULAR_ROUND_OUTRO_SCROLL_TIME + MODULAR_ROUND_OUTRO_FADE_TIME + 1 SECONDS)
#define MODULAR_ROUND_OUTRO_TEXT_WIDTH 620
#define MODULAR_ROUND_OUTRO_BASE_HEIGHT 460
#define MODULAR_ROUND_OUTRO_LINE_HEIGHT 16
#define MODULAR_ROUND_OUTRO_PIXEL_PADDING 220

/atom/movable/screen/fullscreen/black/modular_round_outro
	show_when_dead = TRUE
	alpha = 0

/atom/movable/screen/fullscreen/crt/modular_round_outro
	show_when_dead = TRUE
	alpha = 0

/atom/movable/screen/text/screen_text/modular_round_outro
	layer = ABOVE_INTRO_LAYER
	plane = FULLSCREEN_PLANE
	screen_loc = "CENTER,CENTER"
	maptext_width = MODULAR_ROUND_OUTRO_TEXT_WIDTH
	maptext_height = MODULAR_ROUND_OUTRO_BASE_HEIGHT
	maptext_x = -310
	maptext_y = -230
	fade_out_delay = 0
	fade_out_time = MODULAR_ROUND_OUTRO_FADE_TIME
	style_open = "<span style='font-size:11pt; text-align:left; color:#C9FFE9; font-family:Tahoma, Arial, sans-serif; -dm-text-outline: 1 #00120B;' valign='top'>"
	var/scroll_target_pixel_y = 0
	var/layout_base_height = MODULAR_ROUND_OUTRO_BASE_HEIGHT
	var/layout_line_height = MODULAR_ROUND_OUTRO_LINE_HEIGHT
	var/layout_pixel_padding = MODULAR_ROUND_OUTRO_PIXEL_PADDING

/atom/movable/screen/text/screen_text/modular_round_outro/proc/modular_update_layout_for_client()
	if(!player)
		return

	var/list/view_size = getviewsize(player.view)
	if(!islist(view_size) || length(view_size) < 2)
		return

	var/view_px_w = view_size[1] * 32
	var/view_px_h = view_size[2] * 32

	var/new_width = round(view_px_w * 0.82)
	new_width = max(420, min(new_width, 980))
	maptext_width = new_width
	maptext_x = -round(maptext_width * 0.5)

	layout_base_height = round(view_px_h * 0.70)
	layout_base_height = max(320, min(layout_base_height, 760))

	layout_pixel_padding = round(view_px_h * 0.28)
	layout_pixel_padding = max(160, min(layout_pixel_padding, 360))

	var/font_size = round(view_px_w / 90)
	font_size = max(9, min(font_size, 13))
	layout_line_height = round(font_size * 2)
	layout_line_height = max(16, min(layout_line_height, 28))
	style_open = "<span style='font-size:[font_size]pt; text-align:left; color:#C9FFE9; font-family:Tahoma, Arial, sans-serif; -dm-text-outline: 1 #00120B;' valign='top'>"

/atom/movable/screen/text/screen_text/modular_round_outro/play_to_client()
	if(!player)
		qdel(src)
		return

	player.add_to_screen(src)
	modular_update_layout_for_client()

	var/list/message_lines = splittext(text_to_play, "<br>")
	var/line_count = max(1, length(message_lines))
	maptext_height = max(layout_base_height, (line_count * layout_line_height) + 180)
	maptext_y = -round(maptext_height * 0.5)
	pixel_y = -round((maptext_height * 0.5) + layout_pixel_padding)
	scroll_target_pixel_y = round((maptext_height * 0.5) + layout_pixel_padding)
	alpha = 0
	maptext = "[style_open][text_to_play][style_close]"

	animate(src, alpha = 255, time = MODULAR_ROUND_OUTRO_TEXT_FADE_IN_TIME)
	addtimer(CALLBACK(src, PROC_REF(begin_scroll)), MODULAR_ROUND_OUTRO_SCROLL_START_DELAY)

/atom/movable/screen/text/screen_text/modular_round_outro/proc/begin_scroll()
	if(!player || QDELETED(src))
		qdel(src)
		return

	animate(src, pixel_y = scroll_target_pixel_y, time = MODULAR_ROUND_OUTRO_SCROLL_TIME, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(after_play)), MODULAR_ROUND_OUTRO_SCROLL_TIME)

/datum/game_mode/colonialmarines
	/// Guard to avoid double-sending outro in unusual round-end paths.
	var/modular_round_outro_sent = FALSE
	/// Null means auto-detect based on round_finished.
	var/modular_round_outro_forced_marine_win = null
	/// Prevent repeated prompts if announce is called multiple times.
	var/modular_round_outro_choice_prompted = FALSE

/datum/game_mode/colonialmarines/announce_ending()
	..()
	modular_play_round_outro()

/datum/game_mode/colonialmarines/proc/modular_play_round_outro()
	if(modular_round_outro_sent)
		return
	modular_round_outro_sent = TRUE

	modular_prompt_round_outro_result_override()

	var/outro_text = modular_build_round_outro_text()
	if(!outro_text)
		return

	for(var/client/player_client as anything in sortTim(GLOB.clients, GLOBAL_PROC_REF(cmp_ckey_asc)))
		var/mob/player_mob = player_client.mob
		if(!player_mob)
			continue

		var/atom/movable/screen/fullscreen/black/modular_round_outro/black_overlay = player_mob.overlay_fullscreen("modular_round_outro", /atom/movable/screen/fullscreen/black/modular_round_outro)
		if(black_overlay)
			animate(black_overlay, alpha = 245, time = MODULAR_ROUND_OUTRO_BG_FADE_IN_TIME)

		var/atom/movable/screen/fullscreen/crt/modular_round_outro/crt_overlay = player_mob.overlay_fullscreen("modular_round_outro_crt", /atom/movable/screen/fullscreen/crt/modular_round_outro)
		if(crt_overlay)
			animate(crt_overlay, alpha = 85, time = MODULAR_ROUND_OUTRO_BG_FADE_IN_TIME)

		addtimer(CALLBACK(player_mob, TYPE_PROC_REF(/mob, clear_fullscreen), "modular_round_outro", 10), MODULAR_ROUND_OUTRO_TOTAL_TIME)
		addtimer(CALLBACK(player_mob, TYPE_PROC_REF(/mob, clear_fullscreen), "modular_round_outro_crt", 10), MODULAR_ROUND_OUTRO_TOTAL_TIME)
		player_mob.play_screen_text(outro_text, /atom/movable/screen/text/screen_text/modular_round_outro, "#FFFFFF", 9999)

/datum/game_mode/colonialmarines/proc/modular_build_round_outro_text()
	var/list/player_lines = list()
	var/list/seen_ckeys = list()

	for(var/client/player_client as anything in sortTim(GLOB.clients, GLOBAL_PROC_REF(cmp_ckey_asc)))
		var/player_key = player_client.ckey ? player_client.ckey : player_client.key
		var/player_ckey = lowertext(player_key)
		if(!player_ckey || seen_ckeys[player_ckey])
			continue
		seen_ckeys[player_ckey] = TRUE

		var/mob/status_mob = modular_get_round_outro_status_mob(player_client)
		var/is_alive = status_mob && status_mob.stat != DEAD
		var/is_critical = modular_round_outro_is_critical(status_mob)

		var/player_name = status_mob?.real_name ? status_mob.real_name : (player_client.key ? player_client.key : "НЕИЗВЕСТНЫЙ БОЕЦ")
		var/display_name = sanitize(player_name)
		var/display_role = sanitize(status_mob?.job || "")
		var/identity_line = display_role ? "[display_name] | [display_role]" : "[display_name]"
		var/status_alive = "В СТРОЮ"
		var/status_critical = "ТЯЖЕЛО РАНЕН"
		var/status_dead = "ПОГИБ"
		var/reason_label = "причина гибели"

		if(is_alive && !is_critical)
			player_lines += "[identity_line] - [status_alive]"
			continue
		if(is_alive && is_critical)
			player_lines += "[identity_line] - [status_critical]"
			continue

		var/death_cause = sanitize(modular_get_round_outro_death_cause(status_mob, player_client))
		player_lines += "[identity_line] - [status_dead]"
		player_lines += "&nbsp;&nbsp;&nbsp;[reason_label]: [death_cause]"

	if(!length(player_lines))
		return null

	var/tactical_success = modular_round_outro_is_victory()
	var/safe_round_result = modular_round_outro_localize_result()
	var/title_text = "USCMC // ПОСЛЕБОЕВОЙ ОПЕРАТИВНЫЙ ОТЧЕТ"
	var/subtitle_text = "КАНАЛ: ARES TACNET // ДОСТУП: ДЛЯ СЛУЖЕБНОГО ПОЛЬЗОВАНИЯ"
	var/theater_name = sanitize(SSmapping.configs[GROUND_MAP].map_name || "НЕИЗВЕСТНЫЙ ТЕАТР")
	var/operation_name = sanitize(GLOB.round_statistics?.round_name || "НЕ УКАЗАНО")
	var/report_clock = worldtime2text("hh:mm")
	var/report_date = time2text(REALTIMEOFDAY, "DD-MMM-[GLOB.game_year]")
	var/report_time = "[report_clock] / [report_date]"
	var/result_line = tactical_success ? "СТАТУС ОПЕРАЦИИ: ОСНОВНЫЕ ЗАДАЧИ ВЫПОЛНЕНЫ" : "СТАТУС ОПЕРАЦИИ: ОСНОВНЫЕ ЗАДАЧИ НЕ ВЫПОЛНЕНЫ"
	var/readiness_line = tactical_success ? "БОЕСПОСОБНОСТЬ ПОДРАЗДЕЛЕНИЯ: СОХРАНЕНА" : "БОЕСПОСОБНОСТЬ ПОДРАЗДЕЛЕНИЯ: УТРАЧЕНА"

	var/list/outro_lines = list(
		"<b>[title_text]</b>",
		"<span style='color:#B8B8B8;'>[subtitle_text]</span>",
		"",
		"СЕКТОР ОПЕРАЦИИ: [theater_name]",
		"ПОЗЫВНОЙ ОПЕРАЦИИ: [operation_name]",
		"ОТМЕТКА ВРЕМЕНИ: [report_time]",
		"----------------------------------------------------",
		"[result_line]",
		"ШТАБНАЯ КЛАССИФИКАЦИЯ: [safe_round_result]",
		"[readiness_line]",
		"",
		"ЛИЧНЫЙ СОСТАВ (ПОСЛЕДНИЙ КОНТАКТ):",
		""
	)

	outro_lines += player_lines
	return jointext(outro_lines, "<br>")

/datum/game_mode/colonialmarines/proc/modular_round_outro_is_victory()
	if(!isnull(modular_round_outro_forced_marine_win))
		return modular_round_outro_forced_marine_win

	var/result_text = lowertext("[round_finished]")
	return findtext(result_text, "marine major") || findtext(result_text, "marine minor")

/datum/game_mode/colonialmarines/proc/modular_round_outro_localize_result()
	if(!isnull(modular_round_outro_forced_marine_win))
		if(modular_round_outro_forced_marine_win)
			return "ПОБЕДА МОРСКОЙ ПЕХОТЫ"
		return "ПОРАЖЕНИЕ МОРСКОЙ ПЕХОТЫ"

	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			return "ПОРАЖЕНИЕ МОРСКОЙ ПЕХОТЫ"
		if(MODE_INFESTATION_M_MAJOR)
			return "ПОБЕДА МОРСКОЙ ПЕХОТЫ"
		if(MODE_INFESTATION_X_MINOR)
			return "ПОРАЖЕНИЕ МОРСКОЙ ПЕХОТЫ"
		if(MODE_INFESTATION_M_MINOR)
			return "ПОБЕДА МОРСКОЙ ПЕХОТЫ"
		if(MODE_INFESTATION_DRAW_DEATH)
			return "БЕЗ РЕШАЮЩЕГО РЕЗУЛЬТАТА"
	return "РЕЗУЛЬТАТ НЕ КЛАССИФИЦИРОВАН"

/datum/game_mode/colonialmarines/proc/modular_prompt_round_outro_result_override()
	if(modular_round_outro_choice_prompted)
		return
	modular_round_outro_choice_prompted = TRUE

	var/list/admin_candidates = list()
	for(var/client/admin_client as anything in sortTim(GLOB.admins, GLOBAL_PROC_REF(cmp_ckey_asc)))
		if(!admin_client?.mob || !(admin_client.admin_holder?.rights & R_ADMIN))
			continue
		admin_candidates += admin_client

	if(!length(admin_candidates))
		return

	var/client/chooser = admin_candidates[1]
	var/title_text = "USCMC // КЛАССИФИКАЦИЯ ИСХОДА"
	var/prompt_text = "Назначьте официальную штабную формулировку исхода операции:"
	var/option_marine_win = "ПОБЕДА МОРСКОЙ ПЕХОТЫ"
	var/option_marine_loss = "ПОРАЖЕНИЕ МОРСКОЙ ПЕХОТЫ"
	var/option_auto = "АВТООПРЕДЕЛЕНИЕ"
	var/choice = tgui_alert(chooser, prompt_text, title_text, list(option_marine_win, option_marine_loss, option_auto), 20 SECONDS)

	if(choice == option_marine_win)
		modular_round_outro_forced_marine_win = TRUE
		message_admins("[key_name_admin(chooser)] selected marine victory for round outro.")
		return

	if(choice == option_marine_loss)
		modular_round_outro_forced_marine_win = FALSE
		message_admins("[key_name_admin(chooser)] selected marine defeat for round outro.")
		return

	modular_round_outro_forced_marine_win = null

/datum/game_mode/colonialmarines/proc/modular_get_round_outro_status_mob(client/player_client)
	var/mob/current_mob = player_client?.mob
	if(!current_mob)
		return null

	if(!isobserver(current_mob))
		return current_mob

	var/mob/original_mob = current_mob.mind?.original
	if(istype(original_mob, /mob))
		return original_mob

	return current_mob

/datum/game_mode/colonialmarines/proc/modular_get_round_outro_death_cause(mob/status_mob, client/player_client)
	var/death_cause = status_mob?.last_damage_data?.cause_name
	if(!death_cause)
		death_cause = player_client?.mob?.last_damage_data?.cause_name
	if(!death_cause)
		death_cause = player_client?.mob?.mind?.original?.last_damage_data?.cause_name
	if(!death_cause)
		return "неизвестно"

	return modular_round_outro_normalize_cause(death_cause)

/datum/game_mode/colonialmarines/proc/modular_round_outro_normalize_cause(cause_text)
	if(!cause_text)
		return "неуточненное боевое воздействие"

	var/lower_cause = lowertext(cause_text)
	var/static/list/explosion_keywords = list("explosion", "rocket", "grenade", "bomb", "mortar", "strike")
	var/static/list/bullet_keywords = list("bullet", "rifle", "pistol", "shotgun", "smg", "gauss", "railgun")
	var/static/list/fire_keywords = list("flame", "fire", "burn", "napalm", "incendiary")
	var/static/list/xeno_keywords = list("acid", "xeno", "facehugger", "chestburst", "headbite", "queen")
	var/static/list/impact_keywords = list("fall", "crash", "roadkill", "squash")

	if(modular_round_outro_contains_any_keyword(lower_cause, explosion_keywords))
		return "взрывная травма"
	if(modular_round_outro_contains_any_keyword(lower_cause, bullet_keywords))
		return "огнестрельное поражение"
	if(modular_round_outro_contains_any_keyword(lower_cause, fire_keywords))
		return "термическое поражение"
	if(modular_round_outro_contains_any_keyword(lower_cause, xeno_keywords))
		return "поражение ксеноморфной биоформой"
	if(modular_round_outro_contains_any_keyword(lower_cause, impact_keywords))
		return "травма при ударе/падении"
	return "неуточненное боевое воздействие"

/datum/game_mode/colonialmarines/proc/modular_round_outro_contains_any_keyword(text, list/keywords)
	if(!text || !islist(keywords))
		return FALSE

	for(var/keyword in keywords)
		if(findtext(text, "[keyword]"))
			return TRUE

	return FALSE

/datum/game_mode/colonialmarines/proc/modular_round_outro_is_critical(mob/status_mob)
	if(!isliving(status_mob) || status_mob.stat == DEAD)
		return FALSE

	var/mob/living/living_mob = status_mob
	var/has_crit_effect = (locate(/datum/effects/crit) in living_mob.effects_list)
	var/is_unconscious = living_mob.stat == UNCONSCIOUS
	if((has_crit_effect || is_unconscious) && living_mob.health < HEALTH_THRESHOLD_CRIT)
		return TRUE
	return FALSE

#undef MODULAR_ROUND_OUTRO_BG_FADE_IN_TIME
#undef MODULAR_ROUND_OUTRO_TEXT_FADE_IN_TIME
#undef MODULAR_ROUND_OUTRO_SCROLL_START_DELAY
#undef MODULAR_ROUND_OUTRO_SCROLL_TIME
#undef MODULAR_ROUND_OUTRO_FADE_TIME
#undef MODULAR_ROUND_OUTRO_TOTAL_TIME
#undef MODULAR_ROUND_OUTRO_TEXT_WIDTH
#undef MODULAR_ROUND_OUTRO_BASE_HEIGHT
#undef MODULAR_ROUND_OUTRO_LINE_HEIGHT
#undef MODULAR_ROUND_OUTRO_PIXEL_PADDING
