/datum/preferences/proc/ensure_banda_character_trait_points()
	if(read_traits)
		return
	read_traits = TRUE
	for(var/trait_path in traits)
		var/datum/character_trait/character_trait = GLOB.character_traits[trait_path]
		trait_points -= character_trait?.cost

/datum/preferences/proc/show_banda_character_traits(mob/user, character_trait_group)
	if(!user?.client || !uses_banda_terminal_interface())
		return FALSE
	ensure_banda_character_trait_points()

	var/datum/character_trait_group/current_trait_group
	var/list/visible_groups = list()
	for(var/trait_group_path in GLOB.character_trait_groups)
		var/datum/character_trait_group/trait_group = GLOB.character_trait_groups[trait_group_path]
		if(trait_group?.group_visible)
			visible_groups += trait_group_path
			if(character_trait_group == trait_group_path)
				current_trait_group = trait_group
	if(!current_trait_group && length(visible_groups))
		current_trait_group = GLOB.character_trait_groups[visible_groups[1]]

	var/title = uses_banda_english_interface() ? "CHARACTER TRAITS" : "ОСОБЕННОСТИ ПЕРСОНАЖА"
	var/subtitle = uses_banda_english_interface() ? "AVAILABLE POINTS: [trait_points]" : "ДОСТУПНО ОЧКОВ: [trait_points]"
	var/html = get_banda_auxiliary_window_header(title, subtitle, "banda-traits-window")
	html += "<div class='banda-trait-tabs'>"
	for(var/trait_group_path in visible_groups)
		var/datum/character_trait_group/trait_group = GLOB.character_trait_groups[trait_group_path]
		var/group_label = uses_banda_english_interface() ? trait_group.trait_group_name : banda_translate_character_preference_text(trait_group.trait_group_name)
		var/active_class = trait_group == current_trait_group ? " active" : ""
		html += "<a class='banda-trait-tab[active_class]' href='byond://?_src_=prefs;preference=traits;task=change_slot;trait_group=[trait_group_path]'>[html_encode(group_label)]</a>"
	html += "</div><div class='banda-trait-list'>"
	if(current_trait_group)
		for(var/datum/character_trait/character_trait as anything in current_trait_group.traits)
			if(!character_trait.applyable)
				continue
			var/has_trait = (character_trait.type in traits)
			var/can_select = has_trait || character_trait.can_give_trait(src)
			var/task = has_trait ? "remove_trait" : "give_trait"
			var/state_class = has_trait ? " selected" : (can_select ? "" : " disabled")
			var/trait_name = uses_banda_english_interface() ? character_trait.trait_name : banda_translate_character_preference_text(character_trait.trait_name)
			var/trait_desc = uses_banda_english_interface() ? character_trait.trait_desc : banda_translate_character_preference_text(character_trait.trait_desc)
			html += "<div class='banda-trait-row[state_class]'>"
			if(can_select)
				html += "<a class='banda-trait-name' href='byond://?_src_=prefs;preference=traits;task=[task];trait=[character_trait.type];trait_group=[current_trait_group.type]'>[html_encode(trait_name)]</a>"
			else
				html += "<span class='banda-trait-name'>[html_encode(trait_name)]</span>"
			html += "<span class='banda-trait-desc'>[html_encode(trait_desc)]</span><span class='banda-trait-cost'>[character_trait.cost] [uses_banda_english_interface() ? "PTS" : "ОЧК."]</span></div>"
	html += "</div><div class='banda-aux-actions'><a href='byond://?_src_=prefs;preference=banda_traits;task=close'>[uses_banda_english_interface() ? "CLOSE" : "ЗАКРЫТЬ"]</a></div>"
	html += get_banda_auxiliary_window_footer()
	show_browser(user, html, uses_banda_english_interface() ? "Character Traits" : "Особенности персонажа", "character_traits", width = 900, height = 700)
	return TRUE

/datum/preferences/proc/show_banda_record_editor(mob/user, record_key)
	if(!user?.client || !uses_banda_terminal_interface())
		return FALSE
	var/current_value
	var/title
	switch(record_key)
		if("med_record")
			current_value = med_record
			title = uses_banda_english_interface() ? "MEDICAL RECORD" : "МЕДИЦИНСКАЯ ЗАПИСЬ"
		if("gen_record")
			current_value = gen_record
			title = uses_banda_english_interface() ? "EMPLOYMENT RECORD" : "СЛУЖЕБНАЯ ЗАПИСЬ"
		if("sec_record")
			current_value = sec_record
			title = uses_banda_english_interface() ? "SECURITY RECORD" : "ОХРАННАЯ ЗАПИСЬ"
		else
			return FALSE
	var/subtitle = uses_banda_english_interface() ? "MAXIMUM [MAX_RECORDS_MESSAGE_LEN] CHARACTERS" : "НЕ БОЛЕЕ [MAX_RECORDS_MESSAGE_LEN] СИМВОЛОВ"
	var/html = get_banda_auxiliary_window_header(title, subtitle, "banda-record-editor-window")
	html += "<textarea id='bandaRecordValue' class='banda-record-editor prefs-no-translate' maxlength='[MAX_RECORDS_MESSAGE_LEN]'>[html_encode(html_decode(current_value))]</textarea>"
	html += "<div class='banda-record-counter'><span id='bandaRecordCount'>0</span> / [MAX_RECORDS_MESSAGE_LEN]</div>"
	html += "<div class='banda-aux-actions'><a href='#' onclick=\"submitBandaRecord('[record_key]');return false;\">[uses_banda_english_interface() ? "CONFIRM" : "ПОДТВЕРДИТЬ"]</a> <a href='byond://?_src_=prefs;preference=banda_record_editor;task=cancel'>[uses_banda_english_interface() ? "CANCEL" : "ОТМЕНА"]</a></div>"
	html += {"
		<script type='text/javascript'>
			function updateBandaRecordCount(){var field=document.getElementById('bandaRecordValue');document.getElementById('bandaRecordCount').innerText=field.value.length;}
			function submitBandaRecord(recordKey){var field=document.getElementById('bandaRecordValue');window.location='byond://?_src_=prefs;preference=banda_record_editor;task=save;record='+encodeURIComponent(recordKey)+';value='+encodeURIComponent(field.value);}
			if(document.addEventListener){document.addEventListener('DOMContentLoaded',function(){var field=document.getElementById('bandaRecordValue');field.onkeyup=updateBandaRecordCount;field.onchange=updateBandaRecordCount;field.focus();updateBandaRecordCount();});}
		</script>
	"}
	html += get_banda_auxiliary_window_footer()
	show_browser(user, html, title, "banda_record_editor", width = 720, height = 560)
	return TRUE

/datum/preferences/proc/save_banda_record_editor(record_key, raw_value)
	var/safe_value = html_encode(copytext_char("[raw_value]", 1, MAX_RECORDS_MESSAGE_LEN + 1))
	switch(record_key)
		if("med_record")
			med_record = safe_value
		if("gen_record")
			gen_record = safe_value
		if("sec_record")
			sec_record = safe_value
		else
			return FALSE
	return TRUE
