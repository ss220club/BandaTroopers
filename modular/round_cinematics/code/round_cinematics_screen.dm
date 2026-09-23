/atom/movable/screen/text/round_cinematics
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER + 0.25
	maptext_height = ROUND_CINEMATICS_TEXT_HEIGHT
	maptext_width = ROUND_CINEMATICS_TEXT_WIDTH
	maptext_x = -(ROUND_CINEMATICS_TEXT_WIDTH / 2)
	maptext_y = -(ROUND_CINEMATICS_TEXT_HEIGHT / 2)
	screen_loc = "CENTER"
	appearance_flags = NO_CLIENT_COLOR|PIXEL_SCALE
	clear_with_screen = FALSE

	var/client/player
	var/text_to_play
	var/fade_in_time = 0
	var/fade_out_delay = ROUND_CINEMATICS_TEXT_HOLD
	var/fade_out_time = 0.75 SECONDS
	var/play_delay = ROUND_CINEMATICS_TEXT_DELAY
	var/letters_per_update = ROUND_CINEMATICS_TEXT_LETTERS
	var/style_open = "<span class='langchat' style='text-align:center; font-family:\"VCR OSD Mono\", \"Consolas\", \"Courier New\", monospace; font-size:12pt;'>"
	var/style_close = "</span>"
	var/cancelled = FALSE

/// Token types for tokenize_html()
#define TOKEN_TEXT 1
#define TOKEN_TAG 2
#define TOKEN_ENTITY 3

/**
 * Splits raw HTML into a list of tokens.
 * Each token is a list: list(type, text)
 * - TOKEN_TEXT: plain text, printed character by character
 * - TOKEN_TAG: HTML tag, inserted instantly as a whole
 * - TOKEN_ENTITY: HTML entity, inserted instantly as a whole
 */
/atom/movable/screen/text/round_cinematics/proc/tokenize_html(html)
	var/list/tokens = list()
	if(!length(html))
		return tokens

	var/static/entity_name_regex = regex(@"^&[a-zA-Z]+;$")
	var/static/entity_dec_regex = regex(@"^&#\d+;$")
	var/static/entity_hex_regex = regex(@"^&#x[0-9a-fA-F]+;$")

	var/pos = 1
	var/len = length(html)

	while(pos <= len)
		var/char = html[pos]

		if(char == "<")
			// Find matching '>'
			var/end = findtext(html, ">", pos + 1)
			if(end)
				tokens += list(list(TOKEN_TAG, copytext(html, pos, end + 1)))
				pos = end + 1
				continue
			else
				// Malformed: no closing '>', treat as text
				tokens += list(list(TOKEN_TEXT, "<"))
				pos++
				continue

		if(char == "&")
			// Find matching ';'
			var/end = findtext(html, ";", pos + 1)
			if(end)
				var/entity = copytext(html, pos, end + 1)
				// Validate entity format: &name; or &#number; or &#xhex;
				if(findtext(entity, entity_name_regex) || findtext(entity, entity_dec_regex) || findtext(entity, entity_hex_regex))
					tokens += list(list(TOKEN_ENTITY, entity))
					pos = end + 1
					continue
			// Not a valid entity, treat as text
			tokens += list(list(TOKEN_TEXT, "&"))
			pos++
			continue

		// Plain text — collect consecutive text characters
		var/text_start = pos
		while(pos <= len)
			var/c = html[pos]
			if(c == "<" || c == "&")
				break
			pos++
		tokens += list(list(TOKEN_TEXT, copytext(html, text_start, pos)))

	return tokens

/atom/movable/screen/text/round_cinematics/proc/abort_play()
	cancelled = TRUE
	if(player)
		player.remove_from_screen(src)
		player = null
	qdel(src)

/atom/movable/screen/text/round_cinematics/proc/play_to_client()
	if(!player || QDELETED(player) || cancelled)
		qdel(src)
		return

	player.add_to_screen(src)
	if(fade_in_time)
		animate(src, alpha = 255, time = fade_in_time)

	// Tokenize the HTML before playback
	var/list/tokens = tokenize_html(text_to_play)
	if(!length(tokens))
		if(cancelled || !player || QDELETED(player))
			qdel(src)
			return
		addtimer(CALLBACK(src, PROC_REF(after_play)), fade_out_delay)
		return

	// Build displayed text incrementally:
	// - For TEXT_TOKEN: reveal character by character with sleep
	// - For TAG_TOKEN and ENTITY_TOKEN: append instantly (no animation)
	var/displayed = ""
	for(var/list/token as anything in tokens)
		if(cancelled || !player || QDELETED(player))
			qdel(src)
			return

		var/token_type = token[1]
		var/token_text = token[2]

		switch(token_type)
			if(TOKEN_TAG, TOKEN_ENTITY)
				// Insert instantly — no typewriter animation
				displayed += token_text
				maptext = "[style_open][displayed][style_close]"
				continue

			if(TOKEN_TEXT)
				// Print character by character
				var/token_len = length(token_text)
				for(var/i = 1 to token_len step letters_per_update)
					if(cancelled || !player || QDELETED(player))
						qdel(src)
						return
					var/end_pos = min(i + letters_per_update - 1, token_len)
					displayed += copytext(token_text, i, end_pos + 1)
					maptext = "[style_open][displayed][style_close]"
					sleep(play_delay)

	if(cancelled || !player || QDELETED(player))
		qdel(src)
		return

	addtimer(CALLBACK(src, PROC_REF(after_play)), fade_out_delay)

#undef TOKEN_TEXT
#undef TOKEN_TAG
#undef TOKEN_ENTITY

/atom/movable/screen/text/round_cinematics/proc/after_play()
	if(cancelled || !player || QDELETED(player))
		qdel(src)
		return

	if(!fade_out_time)
		end_play()
		return

	animate(src, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, PROC_REF(end_play)), fade_out_time)

/atom/movable/screen/text/round_cinematics/proc/end_play()
	if(player)
		player.remove_from_screen(src)
		player = null
	qdel(src)

/proc/round_cinematics_show_text(client/target_client, text, color = "#FFFFFF", letters_per_update = ROUND_CINEMATICS_TEXT_LETTERS, play_delay = ROUND_CINEMATICS_TEXT_DELAY, hold_time = ROUND_CINEMATICS_TEXT_HOLD, fade_out_time = 0.75 SECONDS)
	if(!istype(target_client))
		return null

	var/atom/movable/screen/text/round_cinematics/text_box = new
	text_box.text_to_play = text
	text_box.player = target_client
	text_box.color = color
	text_box.letters_per_update = max(1, letters_per_update)
	text_box.play_delay = play_delay
	text_box.fade_out_delay = hold_time
	text_box.fade_out_time = fade_out_time
	INVOKE_ASYNC(text_box, TYPE_PROC_REF(/atom/movable/screen/text/round_cinematics, play_to_client))
	return text_box

// ── Static terminal chrome ────────────────────────────────────────────────

/// Header bar — верхняя полоса с логотипом и названием системы
/atom/movable/screen/text/round_cinematics/header
	screen_loc = "CENTER,TOP-1"
	maptext_height = 32
	maptext_y = 0
	maptext_x = -(ROUND_CINEMATICS_TEXT_WIDTH / 2)
	layer = ABOVE_HUD_LAYER + 0.3
	clear_with_screen = FALSE

/// Footer bar — нижняя полоса с мигающим курсором и индикаторами
/atom/movable/screen/text/round_cinematics/footer
	screen_loc = "CENTER,BOTTOM+1"
	maptext_height = 24
	maptext_y = 0
	maptext_x = -(ROUND_CINEMATICS_TEXT_WIDTH / 2)
	layer = ABOVE_HUD_LAYER + 0.3
	clear_with_screen = FALSE

/// Scanline overlay — статический шум
/atom/movable/screen/round_cinematics/scanline
	icon = 'icons/mob/hud/screen1.dmi'
	icon_state = "noise"
	alpha = 10
	layer = ABOVE_HUD_LAYER + 0.5
	plane = ABOVE_HUD_PLANE
	screen_loc = "CENTER,CENTER"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	clear_with_screen = FALSE

/// Vignette — затемнение по краям
/atom/movable/screen/round_cinematics/vignette
	icon = 'icons/mob/hud/screen1.dmi'
	icon_state = "black"
	alpha = 80
	layer = ABOVE_HUD_LAYER + 0.1
	plane = ABOVE_HUD_PLANE
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	clear_with_screen = FALSE

