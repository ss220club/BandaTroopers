#define CRYO_STATE_LETTERS 10
#define CRYO_PROFILE_LETTERS 12
#define CRYO_ROSTER_LETTERS 12
#define CRYO_ROSTER_PER_PAGE 6
#define CRYO_TEXT_TAIL_TIME (1.25 SECONDS)
#define CRYO_SFX_PHASE_BEEP 'sound/machines/terminal_alert.ogg'
#define CRYO_BLOCK_SFX_VOLUME 16
#define CRYO_BLOCK_SFX_DELAY (0.04 SECONDS)
#define CRYO_BLOCK_END_SFX_OFFSET (0.12 SECONDS)
#define CRYO_SFX_POD_HISS 'sound/machines/hiss.ogg'
#define CRYO_SFX_POD_UNLOCK 'sound/machines/door_open.ogg'
#define CRYO_SFX_SUCCESS 'sound/machines/terminal_success.ogg'

/proc/decode_cryo_ru(entity_text)
	return html_decode(entity_text)

/proc/get_cryo_screen_text_time(text, letters_per_update = 1)
	if(!letters_per_update)
		letters_per_update = 1

	var/visible_length = 0
	var/inside_tag = FALSE
	for(var/i = 1, i <= length(text), i++)
		var/ch = text[i]
		if(ch == "<")
			inside_tag = TRUE
			continue
		if(ch == ">" && inside_tag)
			inside_tag = FALSE
			continue
		if(!inside_tag)
			visible_length++

	var/updates_needed = max(1, floor((visible_length + letters_per_update - 1) / letters_per_update))
	// /atom/movable/screen/text/screen_text/play_delay default is 0.5 deciseconds.
	return updates_needed * 0.5

/proc/get_cryo_block_complete_sfx(block_type, block_index = 1)
	switch(block_type)
		if("state")
			var/list/state_sounds = list(
				'sound/machines/terminal_prompt_confirm.ogg',
				'sound/machines/terminal_select.ogg',
				'sound/machines/twobeep.ogg'
			)
			return state_sounds[((block_index - 1) % length(state_sounds)) + 1]
		if("profile")
			return 'sound/machines/terminal_prompt_confirm.ogg'
		if("roster")
			var/list/roster_sounds = list(
				'sound/machines/terminal_select.ogg',
				'sound/machines/terminal_prompt_confirm.ogg',
				'sound/machines/twobeep.ogg'
			)
			return roster_sounds[((block_index - 1) % length(roster_sounds)) + 1]

	return 'sound/machines/terminal_prompt_confirm.ogg'

/proc/get_cryo_rank_weight(mob/living/carbon/human/H)
	if(!istype(H))
		return 0

	var/obj/item/card/id/card = H.get_idcard()
	if(!card)
		return 0

	var/datum/paygrade/paygrade = GLOB.paygrades[card.paygrade]
	if(!paygrade)
		return 0

	var/rank_weight = 0
	rank_weight += paygrade.ranking * 1000
	rank_weight += paygrade.officer_grade * 100
	rank_weight += round(paygrade.pay_multiplier * 10)
	return rank_weight

/proc/cmp_cryo_roster_members_dsc(mob/living/carbon/human/a, mob/living/carbon/human/b)
	var/a_rank_weight = get_cryo_rank_weight(a)
	var/b_rank_weight = get_cryo_rank_weight(b)
	if(a_rank_weight != b_rank_weight)
		return b_rank_weight - a_rank_weight

	var/a_name = a?.real_name || a?.name || ""
	var/b_name = b?.real_name || b?.name || ""
	return sorttext(b_name, a_name)

/mob/living/carbon/human/proc/get_cryo_intro_alert_type()
	var/alert_type = /atom/movable/screen/text/screen_text/picture/starting/cm_brutal
	switch(faction)
		if(FACTION_UPP)
			alert_type = /atom/movable/screen/text/screen_text/picture/starting/cm_brutal/upp
		if(FACTION_PMC)
			alert_type = /atom/movable/screen/text/screen_text/picture/starting/cm_brutal/wy
		if(FACTION_TWE)
			alert_type = /atom/movable/screen/text/screen_text/picture/starting/cm_brutal/twe
	return alert_type

/mob/living/carbon/human/proc/get_cryo_state_alert_type()
	return /atom/movable/screen/text/screen_text/hypersleep_status/cm_brutal

/mob/living/carbon/human/proc/get_cryo_intro_unit()
	var/unit_name = "3rd Battalion, Banda Troopers"
	switch(faction)
		if(FACTION_MARINE)
			if(assigned_squad?.name == SQUAD_LRRP)
				unit_name = "Snake Eaters"
		if(FACTION_UPP)
			unit_name = "Red Dawn"
		if(FACTION_PMC)
			unit_name = "Azure-15"
		if(FACTION_TWE)
			unit_name = "Gamma Troop"
	return unit_name

/mob/living/carbon/human/proc/get_cryo_squad_roster()
	var/list/squad_roster = list()
	if(!assigned_squad)
		squad_roster += src
		return squad_roster

	for(var/mob/living/carbon/human/H as anything in GLOB.alive_human_list)
		if(H.faction != faction)
			continue
		if(H.assigned_squad != assigned_squad)
			continue
		if(H.stat == DEAD)
			continue
		squad_roster += H

	if(!(src in squad_roster))
		squad_roster += src

	return sortTim(squad_roster, GLOBAL_PROC_REF(cmp_cryo_roster_members_dsc))

/mob/living/carbon/human/proc/get_cryo_roster_line(mob/living/carbon/human/member, index)
	var/full_name = member?.real_name || member?.name || "UNKNOWN"
	var/rank_name = "UNKNOWN RANK"
	var/role_name = member?.get_assignment("UNASSIGNED", "UNASSIGNED")
	if(role_name == "UNASSIGNED" && member?.job)
		role_name = "[member.job]"

	var/obj/item/card/id/member_card = member?.get_idcard()
	if(member_card)
		var/datum/paygrade/paygrade = GLOB.paygrades[member_card.paygrade]
		if(paygrade?.name)
			rank_name = paygrade.name
		if(member_card.assignment)
			role_name = member_card.assignment

	var/self_marker = ""
	if(member == src)
		var/you_label = decode_cryo_ru("&#1042;&#1067;")
		self_marker = " ([you_label])"

	return "[index]. [html_encode(rank_name)] [html_encode(full_name)] - [html_encode(role_name)][self_marker]<br>"

/mob/living/carbon/human/proc/play_cryo_block_complete_sfx(block_type, block_index, block_time, volume = CRYO_BLOCK_SFX_VOLUME, start_delay = CRYO_BLOCK_SFX_DELAY)
	if(!client)
		return

	var/sound_to_play = get_cryo_block_complete_sfx(block_type, block_index)
	if(!sound_to_play)
		return

	var/trigger_delay = start_delay + max(0, block_time - CRYO_BLOCK_END_SFX_OFFSET)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound_client), client, sound_to_play, src, volume, FALSE), max(0, trigger_delay))

/mob/living/carbon/human/proc/has_pending_cryo_intro_texts()
	if(!client || !LAZYLEN(client.screen_texts))
		return FALSE

	for(var/atom/movable/screen/text/screen_text/text_box as anything in client.screen_texts)
		if(istype(text_box, /atom/movable/screen/text/screen_text/hypersleep_status/cm_brutal))
			return TRUE
		if(istype(text_box, /atom/movable/screen/text/screen_text/picture/starting/cm_brutal))
			return TRUE

	return FALSE

/mob/living/carbon/human/proc/wait_for_cryo_intro_text_clear()
	if(!client)
		return

	while(client && has_pending_cryo_intro_texts())
		sleep(1)

/mob/living/carbon/human/proc/play_cryo_manifest_intro()
	cryo_intro_sequence_running = TRUE
	var/state_alert_type = get_cryo_state_alert_type()
	var/list/recovery_states = list(
		decode_cryo_ru("USCMC // &#1042;&#1067;&#1061;&#1054;&#1044; &#1048;&#1047; &#1050;&#1056;&#1048;&#1054;&#1057;&#1053;&#1040; // &#1060;&#1040;&#1047;&#1040; 1/3<br><br>&#1055;&#1054;&#1044;&#1050;&#1051;&#1070;&#1063;&#1045;&#1053;&#1048;&#1045; &#1050; &#1050;&#1040;&#1055;&#1057;&#1059;&#1051;&#1045;: &#1059;&#1057;&#1058;&#1040;&#1053;&#1054;&#1042;&#1051;&#1045;&#1053;&#1054;<br>&#1046;&#1048;&#1047;&#1053;&#1045;&#1053;&#1053;&#1067;&#1045; &#1055;&#1054;&#1050;&#1040;&#1047;&#1040;&#1058;&#1045;&#1051;&#1048;: &#1057;&#1058;&#1040;&#1041;&#1048;&#1051;&#1068;&#1053;&#1067;<br>&#1054;&#1058;&#1042;&#1054;&#1044; &#1043;&#1045;&#1051;&#1071;: &#1040;&#1050;&#1058;&#1048;&#1042;&#1045;&#1053;"),
		decode_cryo_ru("USCMC // &#1042;&#1067;&#1061;&#1054;&#1044; &#1048;&#1047; &#1050;&#1056;&#1048;&#1054;&#1057;&#1053;&#1040; // &#1060;&#1040;&#1047;&#1040; 2/3<br><br>&#1058;&#1045;&#1052;&#1055;&#1045;&#1056;&#1040;&#1058;&#1059;&#1056;&#1040; &#1071;&#1044;&#1056;&#1040;: &#1053;&#1054;&#1056;&#1052;&#1040;<br>&#1053;&#1045;&#1049;&#1056;&#1054;&#1054;&#1058;&#1050;&#1051;&#1048;&#1050;: &#1042;&#1054;&#1057;&#1057;&#1058;&#1040;&#1053;&#1040;&#1042;&#1051;&#1048;&#1042;&#1040;&#1045;&#1058;&#1057;&#1071;<br>&#1052;&#1054;&#1058;&#1054;&#1056;&#1048;&#1050;&#1040;: &#1050;&#1040;&#1051;&#1048;&#1041;&#1056;&#1054;&#1042;&#1050;&#1040;"),
		decode_cryo_ru("USCMC // &#1042;&#1067;&#1061;&#1054;&#1044; &#1048;&#1047; &#1050;&#1056;&#1048;&#1054;&#1057;&#1053;&#1040; // &#1060;&#1040;&#1047;&#1040; 3/3<br><br>&#1057;&#1045;&#1056;&#1044;&#1045;&#1063;&#1053;&#1067;&#1049; &#1056;&#1048;&#1058;&#1052;: &#1057;&#1058;&#1040;&#1041;&#1048;&#1051;&#1045;&#1053;<br>&#1060;&#1054;&#1050;&#1059;&#1057; &#1047;&#1056;&#1045;&#1053;&#1048;&#1071;: &#1042;&#1054;&#1057;&#1057;&#1058;&#1040;&#1053;&#1054;&#1042;&#1051;&#1045;&#1053;<br>&#1043;&#1045;&#1056;&#1052;&#1054;&#1047;&#1040;&#1052;&#1050;&#1048; &#1050;&#1040;&#1055;&#1057;&#1059;&#1051;&#1067;: &#1057;&#1053;&#1071;&#1058;&#1067;")
	)

	var/recovery_stage_index = 1
	for(var/recovery_text as anything in recovery_states)
		var/recovery_text_time = get_cryo_screen_text_time(recovery_text, CRYO_STATE_LETTERS)
		var/recovery_stage_time = max(1 SECONDS, recovery_text_time + CRYO_TEXT_TAIL_TIME)
		sleeping = max(1, (recovery_stage_time - 0.5 SECONDS) / 10)
		if(recovery_stage_index == 1)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound_client), src.client, CRYO_SFX_PHASE_BEEP, src, 20), 0.05 SECONDS)
		play_cryo_block_complete_sfx("state", recovery_stage_index, recovery_text_time)
		play_screen_text(recovery_text, state_alert_type, override_letters_per_update = CRYO_STATE_LETTERS)
		sleep(recovery_stage_time)
		recovery_stage_index++

	var/full_name = real_name || name || "UNKNOWN"
	var/first_name = full_name
	var/last_name = "UNKNOWN"
	var/name_split_pos = findtext(full_name, " ")
	if(name_split_pos)
		first_name = copytext(full_name, 1, name_split_pos)
		last_name = trim(copytext(full_name, name_split_pos + 1))
		if(!length(last_name))
			last_name = "UNKNOWN"
	var/squad_name = assigned_squad?.name || "UNASSIGNED"
	var/specialty = get_assignment("UNASSIGNED", "UNASSIGNED")
	if(specialty == "UNASSIGNED" && job)
		specialty = "[job]"

	var/map_name = SSmapping.configs[SHIP_MAP].map_name || "UNKNOWN AO"
	var/area/current_area = get_area(src)
	var/area_name = current_area?.name || "UNKNOWN SECTOR"

	var/list/squad_roster = get_cryo_squad_roster()
	var/list/roster_lines = list()
	var/member_index = 1
	for(var/mob/living/carbon/human/member as anything in squad_roster)
		roster_lines += get_cryo_roster_line(member, member_index)
		member_index++

	var/roster_count = length(roster_lines)
	var/roster_pages = 0
	if(roster_count)
		roster_pages = floor(roster_count / CRYO_ROSTER_PER_PAGE)
		if(roster_count % CRYO_ROSTER_PER_PAGE)
			roster_pages++

	var/alert_type = get_cryo_intro_alert_type()
	var/unit_name = get_cryo_intro_unit()
	var/profile_title = decode_cryo_ru("&#1051;&#1048;&#1063;&#1053;&#1054;&#1045; &#1044;&#1045;&#1051;&#1054; USCMC")
	var/label_map = decode_cryo_ru("&#1050;&#1040;&#1056;&#1058;&#1040;")
	var/label_unit = decode_cryo_ru("&#1055;&#1054;&#1044;&#1056;&#1040;&#1047;&#1044;&#1045;&#1051;&#1045;&#1053;&#1048;&#1045;")
	var/label_first_name = decode_cryo_ru("&#1048;&#1052;&#1071;")
	var/label_last_name = decode_cryo_ru("&#1060;&#1040;&#1052;&#1048;&#1051;&#1048;&#1071;")
	var/label_squad = decode_cryo_ru("&#1054;&#1058;&#1056;&#1071;&#1044;")
	var/label_role = decode_cryo_ru("&#1044;&#1054;&#1051;&#1046;&#1053;&#1054;&#1057;&#1058;&#1068;")
	var/label_sector = decode_cryo_ru("&#1057;&#1045;&#1050;&#1058;&#1054;&#1056;")
	var/status_ready = decode_cryo_ru("&#1057;&#1058;&#1040;&#1058;&#1059;&#1057;: &#1043;&#1054;&#1058;&#1054;&#1042; &#1050; &#1041;&#1054;&#1070;")
	var/roster_title = decode_cryo_ru("&#1057;&#1055;&#1048;&#1057;&#1054;&#1050; &#1051;&#1048;&#1063;&#1053;&#1054;&#1043;&#1054; &#1057;&#1054;&#1057;&#1058;&#1040;&#1042;&#1040; USCMC")
	var/chain_of_command = decode_cryo_ru("&#1062;&#1045;&#1055;&#1068; &#1050;&#1054;&#1052;&#1040;&#1053;&#1044;&#1054;&#1042;&#1040;&#1053;&#1048;&#1071;")
	var/label_page = decode_cryo_ru("&#1057;&#1058;&#1056;&#1040;&#1053;&#1048;&#1062;&#1040;")
	var/label_roster_count = decode_cryo_ru("&#1057;&#1054;&#1057;&#1058;&#1040;&#1042;")

	var/profile_text = "<b>[profile_title]</b><font size='1' color='#1f1f1f'><i> Cur. S-E 220</i></font><br>"
	profile_text += "--------------------------------<br>"
	profile_text += "[label_map]: [html_encode(map_name)]<br>"
	profile_text += "[label_unit]: [html_encode(unit_name)]<br><br>"
	profile_text += "[label_first_name]: [html_encode(first_name)]<br>"
	profile_text += "[label_last_name]: [html_encode(last_name)]<br>"
	profile_text += "[label_squad]: [html_encode(squad_name)]<br>"
	profile_text += "[label_role]: [html_encode(specialty)]<br>"
	profile_text += "[label_sector]: [html_encode(area_name)]<br>"
	profile_text += "[status_ready]<br>"

	var/list/roster_page_texts = list()
	var/list/roster_page_text_times = list()
	var/list/roster_page_stage_times = list()
	var/total_roster_stage_time = 0
	for(var/page = 1, page <= roster_pages, page++)
		var/start_index = ((page - 1) * CRYO_ROSTER_PER_PAGE) + 1
		var/end_index = min(page * CRYO_ROSTER_PER_PAGE, roster_count)

		var/page_lines = ""
		for(var/i = start_index, i <= end_index, i++)
			page_lines += roster_lines[i]

		var/roster_text = "<b>[roster_title]</b><br>"
		roster_text += "[chain_of_command] // [label_page] [page]/[roster_pages]<br>"
		roster_text += "[label_squad]: [html_encode(squad_name)] // [label_roster_count]: [roster_count]<br>"
		roster_text += "--------------------------------<br>"
		roster_text += page_lines

		var/roster_text_time = get_cryo_screen_text_time(roster_text, CRYO_ROSTER_LETTERS)
		var/roster_stage_time = max(1 SECONDS, roster_text_time + CRYO_TEXT_TAIL_TIME)
		roster_page_texts += roster_text
		roster_page_text_times += roster_text_time
		roster_page_stage_times += roster_stage_time
		total_roster_stage_time += roster_stage_time

	var/profile_text_time = get_cryo_screen_text_time(profile_text, CRYO_PROFILE_LETTERS)
	var/profile_stage_time = max(1.2 SECONDS, profile_text_time + CRYO_TEXT_TAIL_TIME)
	var/remaining_intro_time = profile_stage_time + total_roster_stage_time + 0.6 SECONDS
	sleeping = max(1, (remaining_intro_time - 0.5 SECONDS) / 10)

	overlay_fullscreen_timer(remaining_intro_time, 20, "roundstart_fade", /atom/movable/screen/fullscreen/spawning_in)
	play_cryo_block_complete_sfx("profile", 1, profile_text_time)
	play_screen_text(profile_text, alert_type, override_letters_per_update = CRYO_PROFILE_LETTERS)
	sleep(profile_stage_time)

	for(var/page = 1, page <= roster_pages, page++)
		var/roster_text = roster_page_texts[page]
		var/roster_text_time = roster_page_text_times[page]
		var/roster_stage_time = roster_page_stage_times[page]
		play_cryo_block_complete_sfx("roster", page, roster_text_time)
		play_screen_text(roster_text, alert_type, override_letters_per_update = CRYO_ROSTER_LETTERS)
		sleep(roster_stage_time)

	wait_for_cryo_intro_text_clear()
	playsound_client(src.client, CRYO_SFX_POD_HISS, src, 18, FALSE)
	sleep(0.45 SECONDS)
	playsound_client(src.client, CRYO_SFX_POD_UNLOCK, src, 24, FALSE)
	sleep(0.35 SECONDS)
	playsound_client(src.client, CRYO_SFX_SUCCESS, src, 20, FALSE)
	sleep(0.2 SECONDS)
	cryo_intro_sequence_running = FALSE

#undef CRYO_STATE_LETTERS
#undef CRYO_PROFILE_LETTERS
#undef CRYO_ROSTER_LETTERS
#undef CRYO_ROSTER_PER_PAGE
#undef CRYO_TEXT_TAIL_TIME
#undef CRYO_SFX_PHASE_BEEP
#undef CRYO_BLOCK_SFX_VOLUME
#undef CRYO_BLOCK_SFX_DELAY
#undef CRYO_BLOCK_END_SFX_OFFSET
#undef CRYO_SFX_POD_HISS
#undef CRYO_SFX_POD_UNLOCK
#undef CRYO_SFX_SUCCESS
