/mob/living/carbon/human/proc/modular_start_cryo_intro_hud_lock()
	if(!client || cryo_intro_hud_hidden)
		return

	if(!hud_used)
		create_hud()
	if(!hud_used)
		return

	cryo_intro_hud_restore_style = hud_used.hud_version
	if(!cryo_intro_hud_restore_style || cryo_intro_hud_restore_style == HUD_STYLE_NOHUD)
		cryo_intro_hud_restore_style = HUD_STYLE_STANDARD

	hud_used.show_hud(HUD_STYLE_NOHUD)
	cryo_intro_hud_hidden = TRUE
	modular_enforce_cryo_intro_hud_lock()
	if(!cryo_intro_hud_monitor_running)
		cryo_intro_hud_monitor_running = TRUE
		INVOKE_ASYNC(src, PROC_REF(modular_wait_for_cryo_intro_hud_unlock))

/mob/living/carbon/human/proc/modular_is_cryo_intro_screen_allowed(thing)
	if(istype(thing, /obj/render_plane_relay))
		return TRUE

	if(!istype(thing, /atom/movable/screen))
		return FALSE

	if(istype(thing, /atom/movable/screen/fullscreen))
		return TRUE
	if(istype(thing, /atom/movable/screen/text))
		return TRUE
	if(istype(thing, /atom/movable/screen/plane_master))
		return TRUE
	if(istype(thing, /atom/movable/screen/click_catcher))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/modular_enforce_cryo_intro_hud_lock()
	if(!client || !cryo_intro_hud_hidden)
		return

	for(var/thing as anything in client.screen.Copy())
		if(modular_is_cryo_intro_screen_allowed(thing))
			continue
		client.remove_from_screen(thing)

	for(var/datum/action/A as anything in actions)
		if(A?.button)
			A.button.screen_loc = null

	if(hud_used?.hide_actions_toggle)
		hud_used.hide_actions_toggle.screen_loc = null

/mob/living/carbon/human/proc/modular_wait_for_cryo_intro_hud_unlock()
	while(cryo_intro_hud_hidden)
		if(QDELETED(src) || !client)
			cryo_intro_hud_monitor_running = FALSE
			return

		if(!hud_used)
			create_hud()
		if(hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			hud_used.show_hud(HUD_STYLE_NOHUD)
		modular_enforce_cryo_intro_hud_lock()

		var/in_cryopod = istype(loc, /obj/structure/machinery/cryopod)
		if(!in_cryopod && !cryo_intro_sequence_running)
			break
		sleep(1)

	modular_finish_cryo_intro_hud_lock()
	cryo_intro_hud_monitor_running = FALSE

/mob/living/carbon/human/proc/modular_finish_cryo_intro_hud_lock()
	if(!cryo_intro_hud_hidden)
		return
	cryo_intro_hud_hidden = FALSE

	if(!client || !hud_used)
		return

	hud_used.show_hud(cryo_intro_hud_restore_style)

/mob/living/carbon/human/proc/modular_play_opening_sequence()
	if(SSticker.intro_sequence)
		cryo_intro_sequence_running = TRUE
		var/opening_text = html_decode("USCMC // &#1050;&#1054;&#1053;&#1057;&#1054;&#1051;&#1068; &#1042;&#1067;&#1061;&#1054;&#1044;&#1040; &#1048;&#1047; &#1050;&#1056;&#1048;&#1054;&#1057;&#1053;&#1040;<br><br>&#1057;&#1054;&#1057;&#1058;&#1054;&#1071;&#1053;&#1048;&#1045; &#1057;&#1048;&#1057;&#1058;&#1045;&#1052;: &#1053;&#1054;&#1056;&#1052;&#1040;<br>&#1046;&#1048;&#1047;&#1053;&#1045;&#1054;&#1041;&#1045;&#1057;&#1055;&#1045;&#1063;&#1045;&#1053;&#1048;&#1045;: &#1057;&#1058;&#1040;&#1041;&#1048;&#1051;&#1068;&#1053;&#1054;<br>&#1062;&#1048;&#1050;&#1051; &#1056;&#1040;&#1047;&#1052;&#1054;&#1056;&#1054;&#1047;&#1050;&#1048;: &#1040;&#1050;&#1058;&#1048;&#1042;&#1045;&#1053;<br>&#1053;&#1045;&#1049;&#1056;&#1054;&#1055;&#1056;&#1054;&#1042;&#1045;&#1056;&#1050;&#1040;: &#1055;&#1056;&#1054;&#1049;&#1044;&#1045;&#1053;&#1040;<br>&#1057;&#1054;&#1057;&#1058;&#1054;&#1071;&#1053;&#1048;&#1045; &#1041;&#1054;&#1049;&#1062;&#1040;: &#1043;&#1054;&#1058;&#1054;&#1042; &#1050; &#1041;&#1054;&#1070;")
		var/opening_start_delay = 0.2 SECONDS
		var/opening_letters_per_update = 8
		var/opening_text_time = get_cryo_screen_text_time(opening_text, opening_letters_per_update)
		var/opening_sound_delay = opening_start_delay + 0.05 SECONDS
		var/intro_delay = opening_start_delay + opening_text_time + 1.7 SECONDS
		sleeping = max(1, (intro_delay + 2.5 SECONDS - 1 SECONDS) / 10)
		modular_start_cryo_intro_hud_lock()
		addtimer(CALLBACK(src, PROC_REF(play_screen_text), opening_text, /atom/movable/screen/text/screen_text/hypersleep_status/cm_brutal, "#FFFFFF", opening_letters_per_update), opening_start_delay)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound_client), src.client, 'sound/effects/cryo_intro.ogg', src, 65), opening_sound_delay)
		addtimer(CALLBACK(src, PROC_REF(play_cryo_manifest_intro)), intro_delay)
		overlay_fullscreen_timer(intro_delay, 10, "roundstart1", /atom/movable/screen/fullscreen/black)
		overlay_fullscreen_timer(intro_delay, 10, "roundstartcrt1", /atom/movable/screen/fullscreen/crt)
