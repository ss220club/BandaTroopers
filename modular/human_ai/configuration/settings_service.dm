GLOBAL_DATUM_INIT(human_ai_settings, /datum/human_ai_settings_service, new)

/datum/human_ai_settings_service
	var/list/profile
	var/revision = 1
	var/loaded = FALSE

/datum/human_ai_settings_service/proc/ensure_loaded()
	if(loaded)
		return
	loaded = TRUE
	profile = human_ai_settings_preset()
	if(!fexists("data/human_ai_settings.sav"))
		return
	var/savefile/storage = new("data/human_ai_settings.sav")
	var/version
	var/list/stored
	storage["version"] >> version
	storage["profile"] >> stored
	var/list/validated = human_ai_settings_import(stored, version)
	if(validated)
		profile = validated

/// Synchronous application: the death check and snapshot replacement cannot yield.
/datum/human_ai_settings_service/proc/apply_global(list/values, expected_revision)
	ensure_loaded()
	var/list/validated = human_ai_settings_validate(values)
	if(!validated || revision != expected_revision)
		return FALSE
	profile = validated
	revision++
	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains.Copy())
		if(!brain.has_valid_tied_human() || brain.tied_human.stat == DEAD)
			continue
		brain.sync_settings(TRUE)
	return TRUE

/datum/human_ai_settings_service/proc/save_default()
	ensure_loaded()
	var/savefile/storage = new("data/human_ai_settings.sav")
	storage["version"] << 6
	storage["profile"] << profile

/datum/human_ai_brain
	var/list/settings_snapshot
	var/settings_revision = 0
	var/settings_reaction_until = 0
	var/settings_last_seen = 0

/datum/human_ai_brain/proc/sync_settings(force = FALSE)
	if(!has_valid_tied_human() || tied_human.stat == DEAD)
		return FALSE
	var/datum/human_ai_settings_service/service = GLOB.human_ai_settings
	service.ensure_loaded()
	if(!force && settings_revision == service.revision)
		return TRUE
	settings_snapshot = service.profile.Copy()
	settings_revision = service.revision
	tied_human.human_ai_health_percent = setting("health_percent")
	tied_human.maxHealth = tied_human.human_ai_health_capacity()
	tied_human.updatehealth()
	if(QDELETED(src) || !has_valid_tied_human() || tied_human.stat == DEAD)
		return TRUE
	if(!setting("cover"))
		end_cover()
	return TRUE

/// Read-only, including for dead brains. Synchronization happens only at explicit living gates.
/datum/human_ai_brain/proc/setting(key)
	if(settings_snapshot && (key in settings_snapshot))
		return settings_snapshot[key]
	var/list/definition = human_ai_settings_schema()[key]
	return definition?["default"]
