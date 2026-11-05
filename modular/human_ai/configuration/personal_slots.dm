/// No client-supplied path, account or slot count reaches the filesystem.
/datum/human_ai_personal_slots
	var/account
	var/list/slots = list(null, null, null)

/datum/human_ai_personal_slots/New(owner_key)
	account = ckey(owner_key)
	if(!length(account))
		return
	var/path = save_path()
	if(!fexists(path))
		return
	var/savefile/storage = new(path)
	var/version
	storage["version"] >> version
	if(!(version in list(1, 2, 3, 4, 5, 6)))
		return
	for(var/index in 1 to 3)
		var/list/entry
		storage["slot[index]"] >> entry
		if(!islist(entry) || !valid_name(entry["name"]))
			continue
		var/list/profile = human_ai_settings_import(entry["profile"], version)
		if(profile)
			slots[index] = list("name" = entry["name"], "profile" = profile)

/datum/human_ai_personal_slots/proc/save_path()
	return "data/player_saves/[copytext(account, 1, 2)]/[account]/human_ai_settings.sav"

/datum/human_ai_personal_slots/proc/valid_name(value)
	if(!istext(value) || !length(trim(value)) || length_char(value) > 40)
		return FALSE
	var/regex/allowed = regex(@{"^[a-zA-Zа-яА-ЯёЁ0-9 ]+$"})
	return !!allowed.Find(value)

/datum/human_ai_personal_slots/proc/store_slot(index, name, list/values)
	var/list/validated = human_ai_settings_validate(values)
	if(!isnum(index) || index != round(index) || index < 1 || index > 3 || !valid_name(name) || !validated || !length(account))
		return FALSE
	slots[index] = list("name" = trim(name), "profile" = validated)
	persist()
	return TRUE

/datum/human_ai_personal_slots/proc/delete_slot(index)
	if(!isnum(index) || index != round(index) || index < 1 || index > 3 || !length(account))
		return FALSE
	slots[index] = null
	persist()
	return TRUE

/datum/human_ai_personal_slots/proc/persist()
	var/savefile/storage = new(save_path())
	storage["version"] << 6
	for(var/index in 1 to 3)
		storage["slot[index]"] << slots[index]
