/datum/round_cinematics_phase
	var/name = "phase"
	var/title = null
	var/raw_html = null
	var/list/fullscreen_specs = list()
	var/color = "#DCE6F6"
	var/letters_per_update = ROUND_CINEMATICS_TEXT_LETTERS
	var/play_delay = ROUND_CINEMATICS_TEXT_DELAY
	var/display_time = ROUND_CINEMATICS_TEXT_HOLD
	var/fade_out_time = 0.75 SECONDS
	var/sound = null
	var/sound_volume = 50
	var/sound_channel = 0

/datum/round_cinematics_phase/proc/build_html()
	if(length(raw_html))
		return raw_html

	var/list/chunks = list()
	if(length(title))
		chunks += "<div style='color:[color];font-family:[ROUND_CINEMATICS_FONT_STACK];font-size:12pt;font-weight:bold;text-align:center;'>[html_encode(title)]</div>"
	return chunks.Join("<br>")

/datum/round_cinematics_phase/proc/get_duration()
	var/html = build_html()
	var/lpu = max(1, letters_per_update)
	var/steps = max(1, round((length(html) + lpu - 1) / lpu))
	var/typewriter_time = steps * play_delay
	return max(display_time + fade_out_time, typewriter_time + display_time + fade_out_time)

/datum/round_cinematics_phase/proc/apply_fullscreens(datum/round_cinematics_session/session)
	if(!session || !islist(fullscreen_specs) || !length(fullscreen_specs))
		return

	for(var/list/spec as anything in fullscreen_specs)
		session.apply_fullscreen(spec["category"], spec["type"], spec["severity"] || 0)

/datum/round_cinematics_phase/proc/play(datum/round_cinematics_session/session)
	if(!session || session.cleaned_up)
		return

	apply_fullscreens(session)

	if(sound && session.client)
		playsound_client(session.client, sound, session.owner, sound_volume, FALSE, channel = sound_channel)

	var/text = build_html()
	if(length(text) && session.client)
		var/atom/movable/screen/text/round_cinematics/text_box = round_cinematics_show_text(session.client, text, color, letters_per_update, play_delay, display_time, fade_out_time)
		session.track_text(text_box)

	sleep(get_duration())

