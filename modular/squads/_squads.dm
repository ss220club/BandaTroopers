/datum/modpack/squads
	name = "squads modpack"
	desc = "Объекты для разбивки на отряды"
	author = "phantomru"
	
/datum/modpack/squads/pre_initialize()
	. = ..()

/datum/modpack/squads/initialize()
	. = ..()
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(schedule_latejoin_disable)))

/datum/modpack/squads/post_initialize()
	. = ..()
	if(!GLOB.squad_name_manager)
		GLOB.squad_name_manager = new /datum/squad_name_manager()
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	manager.initialize_manager()

/datum/modpack/squads/proc/schedule_latejoin_disable()
	var/latejoin_disable_delay_minutes = CONFIG_GET(number/latejoin_disable_roundstart_minutes)
	addtimer(CALLBACK(src, PROC_REF(disable_latejoin)), latejoin_disable_delay_minutes MINUTES)

/datum/modpack/squads/proc/disable_latejoin()
	GLOB.enter_allowed = FALSE
