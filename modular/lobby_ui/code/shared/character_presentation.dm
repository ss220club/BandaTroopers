/datum/preferences/proc/get_banda_character_preferences_styles()
	return {"
		[get_banda_terminal_styles("character")]
		[get_banda_character_preferences_translation_script(banda_interface_language)]
	"}

/datum/preferences/proc/get_banda_auxiliary_preferences_styles()
	return {"
		[get_banda_terminal_styles("auxiliary")]
	"}

/datum/preferences/proc/get_banda_auxiliary_window_header(title, subtitle, window_class = "")
	var/text_override_class = get_banda_terminal_text_override_class()
	var/text_override_style = get_banda_terminal_palette_style()
	var/effect_class = get_banda_terminal_effect_class()
	var/glow_class = get_banda_terminal_glow_class()
	var/dat = get_banda_auxiliary_preferences_styles()
	dat += "<body onselectstart='return false;'><div class='banda-aux-crt [window_class][text_override_class][effect_class][glow_class]' style='[text_override_style]'><div class='banda-aux-frame'>"
	dat += "<div class='banda-aux-header'><div class='banda-aux-title'>[title]</div><div class='banda-aux-subtitle'>[subtitle]</div></div>"
	dat += "<div class='banda-aux-content'>"
	return dat

/datum/preferences/proc/get_banda_auxiliary_window_footer()
	return "</div></div></div>[get_banda_character_preferences_translation_script(banda_interface_language)]</body>"
