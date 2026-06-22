/datum/round_cinematics_sequence/round_outro
	/// Кэшированный цвет header из outcome
	var/cached_header_color = "#88CCFF"
	/// Кэшированный цвет accent из outcome
	var/cached_accent_color = "#88CCFF"
	/// Кэшированная фраза исхода (для header/footer отображения)
	var/cached_outcome_phrase = ""
	/// Кэшированный outcome id для выбора эффектов
	var/cached_outcome_id = ROUND_CINEMATICS_OUTCOME_AUTO
	/// Visual profile for colors and styling
	var/datum/round_cinematics_visual_profile/profile

/datum/round_cinematics_sequence/round_outro/get_header_html()
	var/color = profile?.header_color || cached_header_color
	var/logo = profile?.logo_text || "BW"
	var/archive_label = "ФРАГМЕНТ АРХИВА"
	switch(cached_outcome_id)
		if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
			archive_label = "БОЕВОЙ АРХИВ"
		if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
			archive_label = "АВАРИЙНЫЙ АРХИВ"
		if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
			archive_label = "ФРАГМЕНТ АРХИВА"
	var/style_open = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; font-size:10pt; color:[color];'>"
	var/style_close = "</span>"
	. = "[style_open]┌ [logo] █ [archive_label] ┐<br>ЗАСЕКРЕЧЕНО █ СВОДКА ОПЕРАЦИИ"
	if(length(cached_outcome_phrase))
		. += "<br><span style='font-size:10pt;font-weight:bold;'>[html_encode(cached_outcome_phrase)]</span>"
	. += "[style_close]"

/datum/round_cinematics_sequence/round_outro/get_footer_html()
	var/color = profile?.accent_color || cached_accent_color
	var/archive_footer = "НЕПОЛНЫЙ АРХИВ"
	var/archive_status = "АРХИВ: ФРАГМЕНТИРОВАН"
	switch(cached_outcome_id)
		if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
			archive_footer = "АРХИВ ЗАКРЫТ"
			archive_status = "АРХИВ: ЦЕЛОСТЕН"
		if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
			archive_footer = "АВАРИЙНАЯ ЗАПИСЬ"
			archive_status = "АРХИВ: ПОВРЕЖДЁН"
		if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
			archive_footer = "НЕПОЛНЫЙ АРХИВ"
			archive_status = "АРХИВ: ФРАГМЕНТИРОВАН"
	var/style_open = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; font-size:9pt; color:[color];'>"
	var/style_close = "</span>"
	var/final_phrase = ""
	switch(cached_outcome_id)
		if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
			final_phrase = "ОТЧЁТ ПЕРЕДАН В ШТАБ. СТАТУС КАНАЛА: ЗАВЕРШЕНО."
		if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
			final_phrase = "ПОСЛЕДНИЙ ПАКЕТ ДАННЫХ ПЕРЕДАН. СТАТУС КАНАЛА: АВАРИЙНОЕ ЗАВЕРШЕНИЕ."
		if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
			final_phrase = "ОТЧЁТ СОХРАНЁН. СТАТУС КАНАЛА: ОЖИДАНИЕ ПОДТВЕРЖДЕНИЯ."
		else
			final_phrase = "КОНЕЦ ПЕРЕДАЧИ."
	. = "[style_open]└ > [archive_footer] ┘<br>\[[archive_status]\] \[КАНАЛ: ЗАЩИЩЁН\]"
	if(length(final_phrase))
		. += "<br><span style='font-size:8pt;font-weight:bold;'>[html_encode(final_phrase)]</span>"
	. += "[style_close]"

/datum/round_cinematics_sequence/round_outro/New(datum/round_cinematics_outro_context/context, datum/round_cinematics_visual_profile/visual_profile = null)
	..()
	if(!context)
		return

	profile = visual_profile

	// Cache outcome colors and id for header/footer and effects
	if(context.outcome)
		cached_header_color = context.outcome.header_color
		cached_accent_color = context.outcome.accent_color
		cached_outcome_phrase = context.outcome.outcome_phrase
		cached_outcome_id = context.outcome.id

	phases = list()

	// Glitch phase for defeat/intense outcomes
	if(context.outcome && context.outcome.glitch_intensity > 0.2)
		phases += new /datum/round_cinematics_phase
		var/datum/round_cinematics_phase/glitch = phases[phases.len]
		glitch.name = "glitch"
		glitch.raw_html = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; font-size:14pt; color:#FF4444;'>█▓▒░ ПОМЕХИ СИГНАЛА ░▒▓█<br><span style='font-size:8pt;'>\[ПЕРЕДАЧА ПОВРЕЖДЕНА\]</span></span>"
		glitch.fullscreen_specs = list(
			list("category" = ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
			list("category" = ROUND_CINEMATICS_FULLSCREEN_OUTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
		)
		glitch.display_time = 1 SECONDS
		glitch.fade_out_time = 0.3 SECONDS
		glitch.letters_per_update = 8
		glitch.play_delay = 0.1

	// Outcome splash phase — две строки: крупная первая + мелкая вторая
	phases += new /datum/round_cinematics_phase
	var/datum/round_cinematics_phase/splash = phases[phases.len]
	splash.name = "outcome_splash"
	var/splash_line1 = ""
	var/splash_line2 = ""
	var/splash_color = "#FFFFFF"
	if(context.outcome)
		switch(context.outcome.id)
			if(ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
				splash_line1 = "ПОБЕДА ОПЕРАЦИИ"
				splash_line2 = "ОПЕРАТИВНЫЙ КОНТРОЛЬ СОХРАНЁН"
				splash_color = "#44FF44"
			if(ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
				splash_line1 = "ПРОВАЛ ОПЕРАЦИИ"
				splash_line2 = "ОПЕРАТИВНЫЙ КОНТРОЛЬ УТРАЧЕН"
				splash_color = "#FF4444"
			if(ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)
				splash_line1 = "ИСХОД НЕ ПОДТВЕРЖДЁН"
				splash_line2 = "КОМАНДОВАНИЕ НЕ ПОЛУЧИЛО ПОЛНЫХ ДАННЫХ"
				splash_color = "#FFAA44"
			else
				splash_line1 = "ОПЕРАЦИЯ ЗАВЕРШЕНА"
				splash_line2 = ""
				splash_color = "#DCE6F6"
	splash.raw_html = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; color:[splash_color];'><span style='font-size:14pt;font-weight:bold;'>[html_encode(splash_line1)]</span>[splash_line2 ? "<br><span style='font-size:10pt;'>[html_encode(splash_line2)]</span>" : ""]</span>"
	splash.fullscreen_specs = list(
		list("category" = ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
		list("category" = ROUND_CINEMATICS_FULLSCREEN_OUTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
	)
	splash.display_time = 2.5 SECONDS
	splash.fade_out_time = 0.5 SECONDS
	splash.letters_per_update = 2
	splash.play_delay = 0.15

	for(var/page_index = 1, page_index <= context.get_report_page_count(), page_index++)
		phases += new /datum/round_cinematics_phase
		var/datum/round_cinematics_phase/page = phases[phases.len]
		page.name = "report_[page_index]"
		page.raw_html = context.get_report_page(page_index)
		page.fullscreen_specs = list(
			list("category" = ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
			list("category" = ROUND_CINEMATICS_FULLSCREEN_OUTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
		)
		page.display_time = 2 SECONDS
		page.fade_out_time = 0.75 SECONDS
		page.letters_per_update = 4
		page.play_delay = 0.3
		// Sound: terminal_on for first page, terminal_off for last (or terminal_alert for defeat)
		if(page_index == 1)
			page.sound = 'sound/machines/terminal_on.ogg'
			page.sound_volume = 40
		else if(page_index == context.get_report_page_count())
			if(context.outcome && context.outcome.id == ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
				page.sound = 'sound/machines/terminal_alert.ogg'
				page.sound_volume = 45
			else
				page.sound = 'sound/machines/terminal_off.ogg'
				page.sound_volume = 40

/datum/round_cinematics_sequence/round_outro/execute(datum/round_cinematics_session/session)
	if(!session || session.cleaned_up)
		return

	// Determine outcome type for effect selection using cached_outcome_id
	var/is_defeat = (cached_outcome_id == ROUND_CINEMATICS_OUTCOME_MARINE_DEFEAT)
	var/is_victory = (cached_outcome_id == ROUND_CINEMATICS_OUTCOME_MARINE_VICTORY)
	var/is_inconclusive = (cached_outcome_id == ROUND_CINEMATICS_OUTCOME_INCONCLUSIVE)

	// Defeat: glitch before splash, flicker during report
	if(is_defeat)
		session.effect_glitch(0.4, 1 SECONDS, ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK)

	for(var/datum/round_cinematics_phase/phase as anything in phases)
		if(session.cleaned_up)
			break

		// Flicker effects during report phases
		if(is_defeat && findtext(phase.name, "report_"))
			session.effect_flicker(3, 0.5 SECONDS, ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK)
		else if(is_victory && findtext(phase.name, "report_"))
			session.effect_flicker(1, 0.3 SECONDS, ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK)
		else if(is_inconclusive && findtext(phase.name, "report_"))
			session.effect_flicker(2, 0.4 SECONDS, ROUND_CINEMATICS_FULLSCREEN_OUTRO_BLACK)

		phase.play(session)
