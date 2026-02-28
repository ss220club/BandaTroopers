/datum/modpack/squads
	name = "squads modpack"
	desc = "Объекты для разбивки на отряды"
	author = "phantomru"
	
/datum/modpack/squads/pre_initialize()
	. = ..()

/datum/modpack/squads/initialize()
	. = ..()

/datum/modpack/squads/post_initialize()
	. = ..()
	
	if(!GLOB.squad_name_manager)
		GLOB.squad_name_manager = new /datum/squad_name_manager()
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	manager.initialize_manager()
