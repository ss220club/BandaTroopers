/datum/round_cinematics_sequence/cryo_intro
	/// Visual profile for colors and styling
	var/datum/round_cinematics_visual_profile/profile

/datum/round_cinematics_sequence/cryo_intro/execute(datum/round_cinematics_session/session)
	if(!session || session.cleaned_up)
		return

	// Boot phase: power-on + flicker effects
	session.effect_power_on(1 SECONDS)
	session.effect_flicker(2, 0.5 SECONDS)

	for(var/datum/round_cinematics_phase/phase as anything in phases)
		if(session.cleaned_up)
			break
		phase.play(session)

	// Finish: fade from black
	session.effect_power_on(0.5 SECONDS)

/datum/round_cinematics_sequence/cryo_intro/get_header_html()
	var/color = profile?.header_color || "#33FF33"
	var/logo = profile?.logo_text || "СИСТ"
	var/label = profile?.header_label || "СИСТЕМА КРИОГЕННОГО ПРОБУЖДЕНИЯ"
	var/style_open = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; font-size:10pt; color:[color];'>"
	var/style_close = "</span>"
	return "[style_open]┌ [html_encode(logo)] █ [html_encode(label)] ┐<br>ЗАЩИЩЁННЫЙ КАНАЛ █ ДОСТУП ПОДТВЕРЖДЁН[style_close]"

/datum/round_cinematics_sequence/cryo_intro/get_footer_html()
	var/color = profile?.accent_color || "#33FF33"
	var/footer = profile?.footer_label || "ГОТОВ"
	var/style_open = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; font-size:9pt; color:[color];'>"
	var/style_close = "</span>"
	return "[style_open]└ > [footer] ┘<br>\[ПИТАНИЕ: НОРМА\] \[ЖИЗНЕОБЕСПЕЧЕНИЕ: АКТИВНО\][style_close]"

/datum/round_cinematics_sequence/cryo_intro/New(datum/round_cinematics_intro_context/context, datum/round_cinematics_visual_profile/visual_profile = null)
	..()
	if(!context)
		return

	profile = visual_profile

	// Override profile visual fields from affiliation if available
	if(context.affiliation)
		var/datum/round_cinematics_affiliation/aff = context.affiliation
		if(profile)
			profile.header_color = aff.header_color
			profile.accent_color = aff.accent_color
			profile.logo_text = aff.logo_text
			profile.header_label = aff.header_label
			profile.footer_label = aff.footer_label

	var/header_color = profile?.header_color || "#33FF33"
	var/boot_sound = profile?.sound_boot || 'sound/effects/cryo_beep.ogg'
	var/speed = profile?.typewriter_speed || ROUND_CINEMATICS_TEXT_DELAY

	phases = list()

	phases += new /datum/round_cinematics_phase
	var/datum/round_cinematics_phase/boot = phases[phases.len]
	boot.name = "boot"
	boot.raw_html = context.build_boot_text()
	boot.fullscreen_specs = list(
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
	)
	boot.sound = boot_sound
	boot.sound_volume = 45
	boot.display_time = 2 SECONDS
	boot.fade_out_time = 0.75 SECONDS
	boot.letters_per_update = 3
	boot.play_delay = speed

	phases += new /datum/round_cinematics_phase
	var/datum/round_cinematics_phase/personal = phases[phases.len]
	personal.name = "personal"
	personal.raw_html = context.build_personal_text()
	personal.fullscreen_specs = list(
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
	)
	personal.display_time = 2 SECONDS
	personal.fade_out_time = 0.75 SECONDS
	personal.letters_per_update = 3
	personal.play_delay = speed

	for(var/page_index = 1, page_index <= context.get_manifest_page_count(), page_index++)
		phases += new /datum/round_cinematics_phase
		var/datum/round_cinematics_phase/manifest = phases[phases.len]
		manifest.name = "manifest_[page_index]"
		manifest.raw_html = context.build_manifest_text(page_index)
		manifest.fullscreen_specs = list(
			list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
			list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
		)
		manifest.display_time = 2 SECONDS
		manifest.fade_out_time = 0.75 SECONDS
		manifest.letters_per_update = 3
		manifest.play_delay = speed

	// Phase 4: deployment
	phases += new /datum/round_cinematics_phase
	var/datum/round_cinematics_phase/deployment = phases[phases.len]
	deployment.name = "deployment"
	deployment.raw_html = "<span class='langchat' style='text-align:center; font-family:[ROUND_CINEMATICS_FONT_STACK]; font-size:10pt; color:[header_color];'>[html_encode(context.affiliation?.final_intro_line || "СТАТУС: ГОТОВ К РАЗВЁРТЫВАНИЮ")]</span>"
	deployment.fullscreen_specs = list(
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0),
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_CRT, "type" = /atom/movable/screen/fullscreen/crt, "severity" = 0)
	)
	deployment.sound = 'sound/effects/cryo_opening.ogg'
	deployment.sound_volume = 50
	deployment.display_time = 2 SECONDS
	deployment.fade_out_time = 0.5 SECONDS
	deployment.letters_per_update = 5
	deployment.play_delay = 0.2

	// Phase 5: finish (fade-out)
	phases += new /datum/round_cinematics_phase
	var/datum/round_cinematics_phase/finish = phases[phases.len]
	finish.name = "finish"
	finish.raw_html = ""
	finish.fullscreen_specs = list(
		list("category" = ROUND_CINEMATICS_FULLSCREEN_INTRO_BLACK, "type" = /atom/movable/screen/fullscreen/black, "severity" = 0)
	)
	finish.display_time = 1 SECONDS
	finish.fade_out_time = 0.5 SECONDS
	finish.letters_per_update = 1
	finish.play_delay = 0

