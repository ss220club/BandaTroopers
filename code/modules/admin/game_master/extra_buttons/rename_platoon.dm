
GLOBAL_VAR_INIT(main_platoon_name, SQUAD_MARINE_1)
GLOBAL_VAR_INIT(main_platoon_initial_name, GLOB.main_platoon_name)

/// Ability to rename the platoon
/client/proc/game_master_rename_platoon()
	set name = "Rename Squad Override" // SS220 EDIT
	set category = "Game Master.Extras"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	rename_platoon()

/client/proc/commander_rename_platoon()
	set name = "Rename Platoon"
	set category = "OOC.Commander"

	to_chat(src, SPAN_NOTICE("Squad rename by Staff Officers is disabled. The first Squad Leader applies each squad name from preferences.")) // SS220 EDIT

/// Actually renames the platoon
/client/proc/rename_platoon()
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager) // SS220 EDIT
		to_chat(src, SPAN_WARNING("Squad rename manager is unavailable."))
		return

	var/list/squad_options = list(
		"Alpha ([squad_name_get_runtime(SQUAD_MARINE_1)])" = SQUAD_MARINE_1,
		"Bravo ([squad_name_get_runtime(SQUAD_MARINE_2)])" = SQUAD_MARINE_2,
		"Charlie ([squad_name_get_runtime(SQUAD_MARINE_3)])" = SQUAD_MARINE_3,
		"Delta ([squad_name_get_runtime(SQUAD_MARINE_4)])" = SQUAD_MARINE_4,
	)
	var/static_name = tgui_input_list(mob, "Choose squad to rename", "Squad Rename", squad_options)
	if(!static_name)
		return

	var/datum/squad/target_squad = manager.get_squad_by_static(static_name)
	if(!target_squad)
		to_chat(src, SPAN_WARNING("Failed to find selected squad datum."))
		return

	var/new_name = tgui_input_text(mob, "New squad name?", "Squad Name", target_squad.name)
	if(!new_name || !istext(new_name))
		return

	var/rename_result = manager.rename_squad(target_squad, new_name, mob, "admin_override", TRUE)
	if(rename_result != TRUE)
		to_chat(src, SPAN_WARNING("[rename_result]"))
		return

	to_chat(src, SPAN_NOTICE("Renamed [static_name] to [target_squad.name]."))

/proc/do_rename_platoon(name, mob/renamer)
	// SS220 EDIT - legacy wrapper for alpha only
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	if(!manager)
		return

	var/datum/squad/alpha_squad = manager.get_squad_by_static(SQUAD_MARINE_1)
	if(!alpha_squad)
		return

	manager.rename_squad(alpha_squad, name, renamer, "legacy_do_rename_platoon", TRUE)


/proc/change_dropship_camo(camo, mob/renamer)
	var/obj/docking_port/mobile/marine_dropship/midway/port = locate(/obj/docking_port/mobile/marine_dropship/midway)
	var/area/area_to_change = get_area(port)

	var/turf_icon
	var/cargo_icon
	var/cockpit_icon

	switch(camo)
		if(DROPSHIP_CAMO_TAN)
			turf_icon = 'icons/turf/dropship.dmi'
			cargo_icon = 'icons/obj/structures/doors/dropship1_cargo.dmi'
			cockpit_icon = 'icons/obj/structures/doors/dropship1_pilot.dmi'
		if(DROPSHIP_CAMO_NAVY)
			turf_icon = 'icons/turf/dropship2.dmi'
			cargo_icon = 'icons/obj/structures/doors/dropship2_cargo.dmi'
			cockpit_icon = 'icons/obj/structures/doors/dropship2_pilot.dmi'
		if(DROPSHIP_CAMO_URBAN)
			turf_icon = 'icons/turf/dropship3.dmi'
			cargo_icon = 'icons/obj/structures/doors/dropship3_cargo.dmi'
			cockpit_icon = 'icons/obj/structures/doors/dropship3_pilot.dmi'
		if(DROPSHIP_CAMO_JUNGLE)
			turf_icon = 'icons/turf/dropship4.dmi'
			cargo_icon = 'icons/obj/structures/doors/dropship4_cargo.dmi'
			cockpit_icon = 'icons/obj/structures/doors/dropship4_pilot.dmi'

	for(var/turf/closed/shuttle/midway/midway_turfs in area_to_change)
		midway_turfs.icon = turf_icon
	for(var/obj/structure/shuttle/part/midway/midway_parts in area_to_change)
		midway_parts.icon = turf_icon
	for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/cargo in area_to_change)
		cargo.icon = cargo_icon
	for(var/obj/structure/machinery/door/airlock/hatch/cockpit/cockpit in area_to_change)
		cockpit.icon = cockpit_icon

/proc/change_dropship_name(name, mob/renamer)
	var/obj/docking_port/mobile/marine_dropship/midway/port = locate(/obj/docking_port/mobile/marine_dropship/midway)
	if(!port)
		return
	else
		port.name = name
		var/area/area_to_change = get_area(port)
		area_to_change.name = "Dropship [name]"
		for(var/turf/closed/shuttle/midway/midway_turfs in area_to_change)
			midway_turfs.name = name
		for(var/obj/structure/shuttle/part/midway/midway_parts in area_to_change)
			midway_parts.name = name
		for(var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/cargo in area_to_change)
			cargo.name = "[name] cargo door"
		for(var/obj/structure/machinery/computer/dropship_weapons/midway/console in area_to_change)
			console.name = "'[name]' weapons controls"

		for(var/obj/structure/machinery/camera/autoname/golden_arrow/midway/camera in area_to_change)
			camera.c_tag = "Dropship [name] #[camera.autonumber]"
