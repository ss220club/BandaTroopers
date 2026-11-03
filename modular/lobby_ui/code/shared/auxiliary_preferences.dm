/datum/preferences/proc/show_banda_job_preferences(mob/user, limit = 21, list/split_jobs = list(JOB_CHIEF_REQUISITION, JOB_WO_CMO), width = 950, height = 750)
	if(!uses_banda_terminal_interface() || !GLOB.RoleAuthority)
		return FALSE

	var/host_bypass = user.client?.admin_holder?.check_for_rights(R_HOST)
	var/html = get_banda_auxiliary_window_header("ПРИОРИТЕТЫ ДОЛЖНОСТЕЙ", "ВЫБЕРИТЕ ВЕРОЯТНОСТЬ НАЗНАЧЕНИЯ", "banda-job-window")
	html += "<div class='banda-aux-actions'><a href='byond://?_src_=prefs;preference=job;task=close'>ЗАКРЫТЬ</a></div>"
	html += "<table width='100%' cellpadding='1' cellspacing='0' style='color: black;'><tr><td valign='top' width='20%'>"
	html += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1
	var/datum/authority/branch/role/role_authority = GLOB.RoleAuthority
	var/list/active_role_names = role_authority?.get_gamemode_role_titles() || GLOB.gamemode_roles[GLOB.master_mode]
	if(!active_role_names)
		active_role_names = GLOB.ROLES_DISTRESS_SIGNAL

	for(var/role_name as anything in active_role_names)
		var/datum/job/job = role_authority?.roles_by_name[role_name]
		if(!job)
			debug_log("Missing job for prefs: [role_name]")
			continue
		index++
		if(index >= limit || (job.title in split_jobs))
			html += "</table></td><td valign='top' width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		html += "<tr class='[job.selection_class]'><td width='30%' align='center'>"
		if(jobban_isbanned(user, job.title))
			html += "<b><del>[job.disp_title]</del></b></td><td width='10%' align='center'></td><td><b>ЗАБЛОКИРОВАНО</b></td></tr>"
			continue
		if(!job.check_whitelist_status(user))
			html += "<b><del>[job.disp_title]</del></b></td><td width='10%' align='center'></td><td>ТРЕБУЕТСЯ ВАЙТЛИСТ</td></tr>"
			continue
		if(!job.can_play_role(user.client))
			var/list/missing_requirements = job.get_role_requirements(user.client)
			html += "<b><del>[job.disp_title]</del></b></td><td width='10%' align='center'></td><td>НЕДОСТАТОЧНО ВРЕМЕНИ</td></tr>"
			for(var/requirement in missing_requirements)
				var/datum/timelock/timelock = requirement
				html += "<tr class='[job.selection_class]'><td width='40%' align='middle'>[timelock.name]</td><td width='10%' align='center'></td><td>[duration2text(missing_requirements[requirement])] ч.</td></tr>"
			continue

		html += "<b>[job.disp_title]</b></td><td width='10%' align='center'>"
		if(job.job_options)
			if(pref_special_job_options)
				pref_special_job_options[role_name] = sanitize_inlist(pref_special_job_options[role_name], job.job_options, job.job_options[1])
			else
				pref_special_job_options[role_name] = job.job_options[1]
			var/option_text = job.job_options[pref_special_job_options[role_name]]
			html += "<a href='byond://?_src_=prefs;preference=special_job_select;task=input;text=[job.title]'><b>[banda_translate_character_preference_text(option_text)]</b></a>"
		html += "</td><td width='50%'>"

		var/current_priority = get_job_priority(job.title)
		var/button_color
		var/priority_text
		for(var/priority in NEVER_PRIORITY to LOW_PRIORITY)
			switch(priority)
				if(NEVER_PRIORITY)
					button_color = "red"
					priority_text = "НИКОГДА"
				if(PRIME_PRIORITY)
					button_color = "purple"
					priority_text = "ГЛАВНЫЙ"
				if(HIGH_PRIORITY)
					button_color = "blue"
					priority_text = "ВЫСОКИЙ"
				if(MED_PRIORITY)
					button_color = "green"
					priority_text = "СРЕДНИЙ"
				if(LOW_PRIORITY)
					button_color = "orange"
					priority_text = "НИЗКИЙ"
			if(priority == PRIME_PRIORITY && !host_bypass && (!job.prime_priority || user.client?.get_total_human_playtime() < JOB_PLAYTIME_TIER_2))
				continue
			var/priority_class = priority == current_priority ? "[button_color] selected" : "inactive"
			html += "<a class='[priority_class]' href='byond://?_src_=prefs;preference=job;task=input;text=[job.title];target_priority=[priority];'>[priority_text]</a>"
			if(priority < LOW_PRIORITY)
				html += "&nbsp"
		html += "</td></tr>"

	html += "</table></td></tr></table>"
	if(user.client?.prefs)
		var/button_color = "green"
		var/message = "Случайная должность, если выбранные недоступны"
		if(user.client.prefs.alternate_option == BE_MARINE)
			button_color = "red"
			message = "Стать морпехом, если выбранные должности недоступны"
		else if(user.client.prefs.alternate_option == RETURN_TO_LOBBY)
			button_color = "purple"
			message = "Вернуться в лобби, если выбранные должности недоступны"
		html += "<div class='banda-aux-note'><a class='[button_color]' href='byond://?_src_=prefs;preference=job;task=random'>[message]</a></div>"
	html += "<div class='banda-aux-actions'><a href='byond://?_src_=prefs;preference=job;task=reset'>СБРОСИТЬ</a></div>"
	html += get_banda_auxiliary_window_footer()
	close_browser(user, "preferences")
	show_browser(user, html, "Приоритеты должностей", "mob_occupation", width = width, height = height)
	onclose(user, "mob_occupation", user.client, list("_src_" = "prefs", "preference" = "job", "task" = "close"))
	return TRUE

/datum/preferences/proc/show_banda_job_slots(mob/user, limit = 21, list/split_jobs = list(JOB_CHIEF_REQUISITION, JOB_WO_CMO), width = 950, height = 750)
	if(!uses_banda_terminal_interface() || !GLOB.RoleAuthority)
		return FALSE

	var/html = get_banda_auxiliary_window_header("НАЗНАЧЕНИЕ СЛОТОВ", "ЗАКРЕПИТЕ ПЕРСОНАЖЕЙ ЗА ДОЛЖНОСТЯМИ", "banda-job-window")
	html += "<div class='banda-aux-actions'><a href='byond://?_src_=prefs;preference=job_slot;task=close'>ЗАКРЫТЬ</a></div>"
	html += "<table width='100%' cellpadding='1' cellspacing='0' style='color: black;'><tr><td valign='top' width='20%'>"
	html += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1
	var/datum/authority/branch/role/role_authority = GLOB.RoleAuthority
	var/list/active_role_names = role_authority?.get_gamemode_role_titles() || GLOB.gamemode_roles[GLOB.master_mode]
	if(!active_role_names)
		active_role_names = GLOB.ROLES_DISTRESS_SIGNAL

	for(var/role_name as anything in active_role_names)
		var/datum/job/job = role_authority?.roles_by_name[role_name]
		if(!job)
			debug_log("Missing job for prefs: [role_name]")
			continue
		index++
		if(index >= limit || (job.title in split_jobs))
			html += "</table></td><td valign='top' width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0
		html += "<tr class='[job.selection_class]'><td width='40%' align='right'>"
		if(jobban_isbanned(user, job.title))
			html += "<b><del>[job.disp_title]</del></b></td><td width='60%'><b>ЗАБЛОКИРОВАНО</b></td></tr>"
			continue
		if(!job.check_whitelist_status(user))
			html += "<b><del>[job.disp_title]</del></b></td><td width='60%'>ТРЕБУЕТСЯ ВАЙТЛИСТ</td></tr>"
			continue
		if(!job.can_play_role(user.client))
			html += "<b><del>[job.disp_title]</del></b></td><td width='60%'>НЕДОСТАТОЧНО ВРЕМЕНИ</td></tr>"
			continue
		html += "<b>[job.disp_title]</b></td>"
		var/slot_name = get_job_slot_name(job.title)
		html += "<td width='60%'><a href='byond://?_src_=prefs;preference=job_slot;task=assign;target_job=[job.title];'>[slot_name]</a></td></tr>"

	html += "</table></td></tr></table>"
	var/button_color
	var/message
	if(toggle_prefs & TOGGLE_START_JOIN_CURRENT_SLOT)
		button_color = "red"
		message = "Назначение слота не используется при входе в начале раунда"
	else
		button_color = "green"
		message = "Назначение слота используется при входе в начале раунда"
	html += "<div class='banda-aux-note'><a class='[button_color]' href='byond://?_src_=prefs;preference=job_slot;task=start_join'>[message]</a></div>"
	if(toggle_prefs & TOGGLE_LATE_JOIN_CURRENT_SLOT)
		button_color = "red"
		message = "Назначение слота не используется при входе в текущий раунд"
	else
		button_color = "green"
		message = "Назначение слота используется при входе в текущий раунд"
	html += "<div class='banda-aux-note'><a class='[button_color]' href='byond://?_src_=prefs;preference=job_slot;task=late_join'>[message]</a></div>"
	html += "<div class='banda-aux-actions'><a href='byond://?_src_=prefs;preference=job_slot;task=reset'>СБРОСИТЬ</a></div>"
	html += get_banda_auxiliary_window_footer()
	close_browser(user, "preferences")
	show_browser(user, html, "Назначение слотов", "job_slots_assignment", width = width, height = height)
	onclose(user, "job_slots_assignment", user.client, list("_src_" = "prefs", "preference" = "job_slot", "task" = "close"))
	return TRUE
