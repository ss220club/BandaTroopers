/datum/squad_name_manager/proc/is_valid_squad_name_char(ascii_char)
	switch(ascii_char)
		if(32, 39, 45, 46) // пробел, ', -, .
			return TRUE
		if(48 to 57) // цифры 0-9
			return TRUE
		if(65 to 90, 97 to 122) // латиница
			return TRUE
		if(1025, 1040 to 1103, 1105) // кириллица + Ё/ё
			return TRUE
	return FALSE

/datum/squad_name_manager/proc/normalize_squad_name(raw_name)
	if(!istext(raw_name))
		return null
	var/trimmed_name = trim_right(trim_left(raw_name))
	if(!length_char(trimmed_name) || length_char(trimmed_name) > 32)
		return null
	for(var/i in 1 to length_char(trimmed_name))
		var/ascii_char = text2ascii_char(trimmed_name, i)
		if(!is_valid_squad_name_char(ascii_char))
			return null
	return trimmed_name

/datum/squad_name_manager/proc/validate_name_conflicts(new_name, old_name)
	for(var/channel_name in GLOB.radiochannels)
		if(cmptext(channel_name, new_name) && !cmptext(channel_name, old_name))
			return "This name is already used by another radio channel or squad."

	for(var/static_name in managed_static_names)
		var/runtime_name = get_runtime_name_by_static(static_name)
		if(cmptext(runtime_name, new_name) && !cmptext(runtime_name, old_name))
			return "This name is already used by another squad."

	for(var/squad_name in GLOB.ROLES_SQUAD_ALL)
		if(cmptext(squad_name, new_name) && !cmptext(squad_name, old_name))
			return "This name is already used by another squad."

	return null
