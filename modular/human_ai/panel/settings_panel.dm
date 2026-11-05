/// Panel implementation; runtime policy remains in ../configuration.
/client
	var/datum/human_ai_settings_panel/human_ai_settings_panel

/client/proc/open_human_ai_settings_panel()
	set name = "Human AI Settings"
	set category = "Game Master.HumanAI"
	if(!check_rights_for(src, R_DEBUG))
		return
	if(QDELETED(human_ai_settings_panel))
		human_ai_settings_panel = new(src)
	human_ai_settings_panel.tgui_interact(mob)

/datum/human_ai_settings_panel
	var/client/owner
	var/datum/human_ai_personal_slots/personal
	var/list/draft
	var/base_revision
	var/busy = FALSE
	var/status = "Загрузка профиля не применяет его. Изменения нужно подтвердить."

/datum/human_ai_settings_panel/New(client/client_owner)
	owner = client_owner
	personal = new(owner.ckey)
	load_current()

/datum/human_ai_settings_panel/Destroy()
	if(owner?.human_ai_settings_panel == src)
		owner.human_ai_settings_panel = null
	owner = null
	QDEL_NULL(personal)
	return ..()

/datum/human_ai_settings_panel/ui_close(mob/user)
	qdel(src)

/datum/human_ai_settings_panel/proc/authorized(mob/user)
	return user?.client == owner && check_rights_for(owner, R_DEBUG)

/datum/human_ai_settings_panel/proc/load_current()
	GLOB.human_ai_settings.ensure_loaded()
	base_revision = GLOB.human_ai_settings.revision
	draft = GLOB.human_ai_settings.profile.Copy()

/datum/human_ai_settings_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_ai_settings_panel/tgui_interact(mob/user, datum/tgui/ui)
	if(!authorized(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanAISettings", "Human AI — настройки")
		ui.open()

/datum/human_ai_settings_panel/ui_data(mob/user)
	if(!authorized(user))
		return list()
	var/alive = 0
	var/dead = 0
	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains)
		if(!brain.has_valid_tied_human())
			continue
		if(brain.tied_human.stat == DEAD)
			dead++
			continue
		alive++
	var/list/fields = list()
	var/list/schema = human_ai_settings_schema()
	for(var/key in schema)
		var/list/field = schema[key].Copy()
		field["key"] = key
		field["value"] = draft[key]
		field["help"] = human_ai_settings_help(key)
		fields += list(field)
	var/list/slots = list()
	for(var/index in 1 to 3)
		var/list/entry = personal.slots[index]
		slots += list(list("index" = index, "name" = entry ? entry["name"] : null))
	var/list/performance_profile = list(
		"enabled" = SShuman_ai.performance_profile_enabled,
		"session" = SShuman_ai.performance_profile_generation,
		"path" = SShuman_ai.performance_profile_path,
		"error" = SShuman_ai.performance_profile_error,
	)
	return list("fields" = fields, "alive" = alive, "slots" = slots, "busy" = busy, "status" = status, "revision" = GLOB.human_ai_settings.revision, "base_revision" = base_revision, "dead" = dead, "performance_profile" = performance_profile)

/datum/human_ai_settings_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || busy || !authorized(ui.user))
		return
	var/key = params["key"]
	switch(action)
		if("profile_set_enabled")
			var/value = params["value"]
			if(!isnum(value) || (value != FALSE && value != TRUE))
				return
			var/was_enabled = SShuman_ai.performance_profile_enabled
			if(value == was_enabled)
				return TRUE
			var/updated = SShuman_ai.set_performance_profile(value)
			if(SShuman_ai.performance_profile_enabled != was_enabled)
				log_admin("[key_name(owner)] [SShuman_ai.performance_profile_enabled ? "enabled" : "disabled"] Human AI performance diagnostics.")
				message_admins("[key_name_admin(owner)] [SShuman_ai.performance_profile_enabled ? "enabled" : "disabled"] Human AI performance diagnostics.")
			if(!updated)
				status = "Ошибка записи диагностики нагрузки. Подробности — во вкладке «Диагностика»."
				return TRUE
			status = SShuman_ai.performance_profile_enabled ? "Диагностика нагрузки включена сразу. Черновик и поведение NPC не изменены." : "Диагностика нагрузки выключена. Накопленные измерения сохранены."
		if("reload")
			load_current()
			status = "Показаны текущие настройки с сервера. Неприменённый черновик сброшен."
		if("edit")
			var/value = params["value"]
			if(!human_ai_settings_valid_value(key, value))
				return
			draft[key] = value
		if("preset")
			var/list/profile = human_ai_settings_preset(params["level"])
			if(!profile)
				return
			draft = profile
			status = "Пресет загружен в черновик. NPC пока не изменены."
		if("apply")
			busy = TRUE
			var/list/current = GLOB.human_ai_settings.profile
			var/list/changes = list()
			var/list/schema = human_ai_settings_schema()
			for(var/field_key in draft)
				if(draft[field_key] != current[field_key])
					var/list/definition = schema[field_key]
					changes += "[definition["label"]]: [current[field_key]] → [draft[field_key]]"
			var/answer = tgui_alert(ui.user, "Применить ко всем живым и будущим NPC? Мёртвые исключены.\n[jointext(changes, "\n")]", "Применить настройки?", list("Применить", "Отмена"))
			if(QDELETED(src))
				return
			busy = FALSE
			if(answer != "Применить" || !authorized(ui.user))
				return TRUE
			if(base_revision != GLOB.human_ai_settings.revision)
				status = "Применение отменено: глобальный профиль изменился. Загрузите текущие настройки с сервера."
				return TRUE
			if(GLOB.human_ai_settings.apply_global(draft, base_revision))
				log_admin("[key_name(owner)] applied global Human AI settings; changes=[jointext(changes, "; ")]")
				message_admins("[key_name_admin(owner)] applied global Human AI settings.")
				load_current()
				status = "Настройки применены ко всем живым и будущим NPC. Мёртвые NPC не изменены."
		if("save_default")
			busy = TRUE
			var/revision = GLOB.human_ai_settings.revision
			var/answer = tgui_alert(ui.user, "Сохранить действующий глобальный профиль после перезапуска? Черновик не сохраняется.", "Настройки сервера", list("Сохранить", "Отмена"))
			if(QDELETED(src))
				return
			busy = FALSE
			if(answer == "Сохранить" && authorized(ui.user) && revision == GLOB.human_ai_settings.revision)
				GLOB.human_ai_settings.save_default()
				log_admin("[key_name(owner)] saved Human AI server defaults revision [revision].")
				status = "Глобальный профиль сохранён для следующего запуска."
		if("slot_load", "slot_save", "slot_rename", "slot_delete")
			var/index = params["index"]
			if(!isnum(index) || index != round(index) || index < 1 || index > 3)
				return
			var/list/entry = personal.slots[index]
			if(action == "slot_load")
				if(!entry)
					return
				draft = entry["profile"].Copy()
				status = "Личный слот загружен в черновик, без применения."
				return TRUE
			busy = TRUE
			var/name = entry ? entry["name"] : "Конфигурация [index]"
			if(action != "slot_delete")
				name = tgui_input_text(ui.user, "Название: до 40 символов, буквы, цифры и пробелы.", "Личная конфигурация", name, 40)
				if(QDELETED(src))
					return
				if(!personal.valid_name(name))
					busy = FALSE
					status = "Название не сохранено: допустимы буквы, цифры и пробелы, до 40 символов."
					return TRUE
			var/answer = tgui_alert(ui.user, "[action == "slot_delete" ? "Удалить" : "Сохранить"] слот [index]: [name]? [entry && action == "slot_save" ? "Существующий профиль будет перезаписан." : ""]", "Личный слот", list("Подтвердить", "Отмена"))
			if(QDELETED(src))
				return
			busy = FALSE
			if(answer != "Подтвердить" || !authorized(ui.user))
				return TRUE
			if(action == "slot_delete")
				personal.delete_slot(index)
			else
				personal.store_slot(index, name, action == "slot_rename" && entry ? entry["profile"] : draft)
			status = "Личный слот обновлён. Поведение NPC не изменено."
	return TRUE
