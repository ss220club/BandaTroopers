#define DEFENSE_CREATOR_SPAWN_CLICK_INTERCEPT_ACTION "defense_creator_spawn_click_intercept_action"

/datum/human_defense_creator_menu
	var/static/list/lazy_defense_dict = list()
	var/static/list/lazy_ui_data = list()
	var/current_click_intercept_action
	var/spawn_click_intercept = FALSE
	var/current_path
	var/selected_faction = FACTION_MARINE
	var/selected_place_dir = "Default"
	var/selected_turned_on = TRUE

/datum/human_defense_creator_menu/New()
	if(!length(lazy_ui_data))
		for(var/datum/human_ai_defense/defense_type as anything in subtypesof(/datum/human_ai_defense))
			if(!defense_type::name)
				continue

			var/datum/human_ai_defense/preview_defense = lazy_defense_dict[defense_type]
			if(!istype(preview_defense))
				preview_defense = new defense_type()
				lazy_defense_dict[defense_type] = preview_defense

			if(!lazy_ui_data[defense_type::category])
				lazy_ui_data[defense_type::category] = list()

			lazy_ui_data[defense_type::category] += list(list(
				"name" = preview_defense.name,
				"path" = defense_type,
				"description" = preview_defense.desc,
				"image" = preview_defense.get_ui_icon_key(),
				"uses_faction" = preview_defense.uses_faction,
				"uses_turned_on" = preview_defense.uses_turned_on,
			))

/datum/human_defense_creator_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanDefenseManager")
		ui.open()
	if(spawn_click_intercept)
		user.client?.click_intercept = src

/datum/human_defense_creator_menu/ui_close(mob/user)
	. = ..()

	var/client/user_client = user.client
	if(user_client?.click_intercept == src)
		user_client.click_intercept = null

	spawn_click_intercept = FALSE
	current_click_intercept_action = null

/datum/human_defense_creator_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_defense_creator_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/defense_menu),
	)

/datum/human_defense_creator_menu/ui_data(mob/user)
	var/list/data = list()

	data["selected_faction"] = selected_faction
	data["selected_place_dir"] = selected_place_dir
	data["selected_turned_on"] = selected_turned_on
	data["spawn_click_intercept"] = spawn_click_intercept
	data["current_path"] = current_path

	return data

/datum/human_defense_creator_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["defenses"] = lazy_ui_data
	// SS220 EDIT - START
	// Expose HALO and split Covenant factions to the shared defense creator UI.
	data["valid_factions"] = list(
		FACTION_MARINE,
		FACTION_UA_REBEL,
		FACTION_UPP,
		FACTION_CANC,
		FACTION_WY,
		FACTION_FREELANCER,
		FACTION_TWE,
		FACTION_TWE_REBEL,
		FACTION_MERCENARY,
		FACTION_COVENANT,
		FACTION_UNSC,
		FACTION_INSURGENT,
		FACTION_ONI,
		FACTION_UNSCN,
		FACTION_UEG_POLICE,
		FACTION_UNGGOY,
		FACTION_SANGHEILI,
		FACTION_KIGYAR,
		FACTION_SPECOPS_SANGHEILI,
		FACTION_SPECOPS_UNGGOY,
		FACTION_SPECOPS_KIGYAR
	)
	// SS220 EDIT - END

	return data

/datum/human_defense_creator_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("remember_path")
			current_path = params["path"]
			return TRUE

		if("set_selected_faction")
			if(!params["selected_faction"])
				return

			selected_faction = params["selected_faction"]
			return TRUE

		if("set_selected_place_dir")
			selected_place_dir = params["place_dir"] || "Default"
			return TRUE

		if("toggle_selected_turned_on")
			selected_turned_on = !selected_turned_on
			return TRUE

		if("spawn_defense_here")
			if(!update_selected_settings(params))
				return

			spawn_selected_defense(ui.user, get_turf(ui.user))
			return TRUE

		if("toggle_click_spawn")
			if(!update_selected_settings(params))
				return

			if(spawn_click_intercept)
				spawn_click_intercept = FALSE
				current_click_intercept_action = null
				if(ui.user.client?.click_intercept == src)
					ui.user.client.click_intercept = null
				return TRUE

			spawn_click_intercept = TRUE
			current_click_intercept_action = DEFENSE_CREATOR_SPAWN_CLICK_INTERCEPT_ACTION
			ui.user.client?.click_intercept = src
			return TRUE

/datum/human_defense_creator_menu/proc/update_selected_settings(list/params)
	if(!params["path"])
		return FALSE

	current_path = params["path"]

	if(!isnull(params["faction"]))
		selected_faction = params["faction"]

	if(!isnull(params["place_dir"]))
		selected_place_dir = params["place_dir"] || "Default"

	if(!isnull(params["turned_on"]))
		selected_turned_on = params["turned_on"] ? TRUE : FALSE

	return TRUE

/datum/human_defense_creator_menu/proc/get_selected_direction(mob/user)
	. = user?.dir || SOUTH
	switch(selected_place_dir)
		if("North")
			return NORTH
		if("East")
			return EAST
		if("South")
			return SOUTH
		if("West")
			return WEST

/datum/human_defense_creator_menu/proc/spawn_selected_defense(mob/user, turf/spawn_turf)
	if(!current_path || !isturf(spawn_turf))
		return FALSE

	var/gotten_path = ispath(current_path) ? current_path : text2path(current_path)
	if(!gotten_path)
		return FALSE

	if(!lazy_defense_dict[gotten_path])
		lazy_defense_dict[gotten_path] = new gotten_path()

	var/datum/human_ai_defense/defense_object = lazy_defense_dict[gotten_path]
	defense_object.spawn_object(spawn_turf, get_selected_direction(user), selected_faction, selected_turned_on)
	return TRUE

/datum/human_defense_creator_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	if(!spawn_click_intercept || current_click_intercept_action != DEFENSE_CREATOR_SPAWN_CLICK_INTERCEPT_ACTION)
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return TRUE

	var/turf/spawn_turf = get_turf(object)
	if(!isturf(spawn_turf))
		return TRUE

	spawn_selected_defense(user, spawn_turf)
	return TRUE

/client/proc/open_human_defense_creator_panel()
	set name = "Human Defense Creator Panel"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(human_defense_menu)
		human_defense_menu.tgui_interact(mob)
		return

	human_defense_menu = new /datum/human_defense_creator_menu(src)
	human_defense_menu.tgui_interact(mob)

/datum/human_ai_defense
	var/name = ""
	var/desc = ""
	var/category = "default"
	var/icon = 'icons/misc/human_defense_menu.dmi'
	var/icon_state
	var/uses_faction = TRUE
	var/uses_turned_on = TRUE
	var/path_to_spawn

/datum/human_ai_defense/proc/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	return

/datum/human_ai_defense/proc/get_ui_icon_key()
	return replacetext(replacetext("[type]", "/datum/human_ai_defense/", "human_ai_defense_"), "/", "_")

/datum/human_ai_defense/proc/get_ui_icon_file()
	if(ispath(path_to_spawn))
		var/atom/spawn_atom = path_to_spawn
		var/icon_file = initial(spawn_atom.icon)
		if(icon_file)
			return icon_file
	return icon

/datum/human_ai_defense/proc/get_ui_icon_state()
	if(ispath(path_to_spawn))
		var/atom/spawn_atom = path_to_spawn
		var/icon_file_state = initial(spawn_atom.icon_state)
		if(icon_file_state)
			return icon_file_state
	return icon_state

// Sentries

/datum/human_ai_defense/defense/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/machinery/defenses/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	defense.placed = TRUE
	if(turned_on)
		defense.power_on()
	else
		defense.power_off()
	if(faction)
		defense.handle_iff(faction)

/datum/human_ai_defense/defense/sentry
	category = "Sentries"

/datum/human_ai_defense/defense/sentry/uscm
	name = "USCM Sentry"
	desc = /obj/structure/machinery/defenses/sentry::desc
	icon_state = "uscm_sentry"
	path_to_spawn = /obj/structure/machinery/defenses/sentry

/datum/human_ai_defense/defense/sentry/uscm/static_gun
	name = "USCM Sentry - Static"
	desc = /obj/structure/machinery/defenses/sentry/premade/deployable/almayer::desc
	path_to_spawn = /obj/structure/machinery/defenses/sentry/premade/deployable/almayer

/datum/human_ai_defense/defense/sentry/uscm/dmr
	name = "USCM Sentry - DMR"
	desc = /obj/structure/machinery/defenses/sentry/dmr::desc
	icon_state = "uscm_sentry_dmr"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/dmr

/datum/human_ai_defense/defense/sentry/uscm/shotgun
	name = "USCM Sentry - Shotgun"
	desc = /obj/structure/machinery/defenses/sentry/shotgun::desc
	icon_state = "uscm_sentry_shotgun"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/shotgun

/datum/human_ai_defense/defense/sentry/uscm/mini
	name = "USCM Sentry - Mini"
	desc = /obj/structure/machinery/defenses/sentry/mini::desc
	icon_state = "uscm_sentry_mini"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/mini

/datum/human_ai_defense/defense/sentry/uscm/flamer
	name = "USCM Sentry - Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer::desc
	icon_state = "uscm_flamer"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer

/datum/human_ai_defense/defense/sentry/uscm/flamer/mini
	name = "USCM Sentry - Mini Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer/mini::desc
	icon_state = "uscm_flamer_mini"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer/mini

/datum/human_ai_defense/defense/sentry/upp
	name = "UPP Sentry"
	desc = /obj/structure/machinery/defenses/sentry/upp::desc
	icon_state = "upp_sentry"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/upp

/datum/human_ai_defense/defense/sentry/upp/light
	name = "UPP Sentry - Light"
	desc = /obj/structure/machinery/defenses/sentry/upp/light::desc
	icon_state = "upp_sentry_light"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/upp/light

/datum/human_ai_defense/defense/sentry/upp/flamer
	name = "UPP Sentry - Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer/upp::desc
	icon_state = "upp_flamer"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer/upp

/datum/human_ai_defense/defense/sentry/wy
	name = "W-Y Sentry"
	desc = /obj/structure/machinery/defenses/sentry/wy::desc
	icon_state = "wy_sentry"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/wy

/datum/human_ai_defense/defense/sentry/wy/flamer
	name = "W-Y Sentry - Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer/wy::desc
	icon_state = "wy_flamer"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer/wy

/datum/human_ai_defense/defense/sentry/wy/static_gun
	name = "W-Y Sentry - Static"
	icon_state = "wy_sentry_static"

/datum/human_ai_defense/defense/sentry/wy/mini
	name = "W-Y Sentry - Mini Sentry"
	desc = /obj/structure/machinery/defenses/sentry/mini/wy::desc
	icon_state = "wy_sentry_mini"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/mini/wy

/datum/human_ai_defense/defense/sentry/wy/heavy
	name = "W-Y Sentry - Heavy"
	desc = /obj/structure/machinery/defenses/sentry/dmr/wy::desc
	icon_state = "wy_sentry_heavy"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/dmr/wy

// Bell towers

/datum/human_ai_defense/defense/bell_tower
	name = "USCM Bell Tower"
	desc = /obj/structure/machinery/defenses/bell_tower::desc
	icon_state = "uscm_belltower"
	category = "Bell Towers"
	path_to_spawn = /obj/structure/machinery/defenses/bell_tower

/datum/human_ai_defense/defense/bell_tower/cloaked
	name = "USCM Bell Tower - Cloaked"
	desc = /obj/structure/machinery/defenses/bell_tower/cloaker::desc
	icon_state = "uscm_belltower_cloak"
	path_to_spawn = /obj/structure/machinery/defenses/bell_tower/cloaker

/datum/human_ai_defense/defense/bell_tower/md
	name = "USCM Bell Tower - MD"
	desc = /obj/structure/machinery/defenses/bell_tower/md::desc
	icon_state = "uscm_belltower_md"
	path_to_spawn = /obj/structure/machinery/defenses/bell_tower/md

// Flags

/datum/human_ai_defense/defense/flag
	category = "Planted Flags"

/datum/human_ai_defense/defense/flag/uscm
	name = "USCM Planted Flag"
	desc = /obj/structure/machinery/defenses/planted_flag::desc
	icon_state = "uscm_flag"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag

/datum/human_ai_defense/defense/flag/uscm/range
	name = "USCM Planted Flag - Range+"
	desc = /obj/structure/machinery/defenses/planted_flag/range::desc
	icon_state = "uscm_flag_range"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/range

/datum/human_ai_defense/defense/flag/uscm/warbanner
	name = "USCM Planted Flag - Warbanner"
	desc = /obj/structure/machinery/defenses/planted_flag/warbanner::desc
	icon_state = "uscm_flag_warbanner"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/warbanner

/datum/human_ai_defense/defense/flag/upp
	name = "UPP Planted Flag"
	desc = /obj/structure/machinery/defenses/planted_flag/upp::desc
	icon_state = "upp_flag"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/upp

/datum/human_ai_defense/defense/flag/wy
	name = "W-Y Planted Flag"
	desc = /obj/structure/machinery/defenses/planted_flag/wy::desc
	icon_state = "wy_flag"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/wy

// Teslas

/datum/human_ai_defense/defense/tesla
	name = "USCM Tesla Coil"
	desc = /obj/structure/machinery/defenses/tesla_coil::desc
	icon_state = "uscm_tesla"
	category = "Tesla Coils"
	path_to_spawn = /obj/structure/machinery/defenses/tesla_coil

/datum/human_ai_defense/defense/tesla/stun
	name = "USCM Tesla Coil - Overclocked"
	desc = /obj/structure/machinery/defenses/tesla_coil/stun::desc
	icon_state = "uscm_tesla_stun"
	path_to_spawn = /obj/structure/machinery/defenses/tesla_coil/stun

/datum/human_ai_defense/defense/tesla/micro
	name = "USCM Tesla Coil - Micro"
	desc = /obj/structure/machinery/defenses/tesla_coil/micro::desc
	icon_state = "uscm_tesla_micro"
	path_to_spawn = /obj/structure/machinery/defenses/tesla_coil/micro

// Mines

/datum/human_ai_defense/mine
	uses_turned_on = FALSE
	category = "Landmines"

/datum/human_ai_defense/mine/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/item/explosive/mine/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	if(faction)
		defense.iff_signal = faction

/datum/human_ai_defense/mine/claymore
	name = "Weak Claymore"
	desc = /obj/item/explosive/mine/active::desc
	icon_state = "claymore"
	path_to_spawn = /obj/item/explosive/mine/active

/datum/human_ai_defense/mine/claymore/strong
	name = "Strong Claymore"
	desc = /obj/item/explosive/mine/strong/active::desc
	icon_state = "claymore"
	path_to_spawn = /obj/item/explosive/mine/strong/active

/datum/human_ai_defense/mine/claymore/wy
	name = "Weak PMC Claymore"
	desc = /obj/item/explosive/mine/pmc/active::desc
	icon_state = "claymore_wy"
	path_to_spawn = /obj/item/explosive/mine/pmc/active

// SS220 EDIT - START
/datum/human_ai_defense/mine/claymore/wy/strong
	name = "Strong PMC Claymore"
	desc = /obj/item/explosive/mine/pmc/strong/active::desc
	icon_state = "claymore_wy"
	path_to_spawn = /obj/item/explosive/mine/pmc/strong/active
// SS220 EDIT - END

/datum/human_ai_defense/mine/sebb
	name = "G2 Electroshock"
	desc = /obj/item/explosive/mine/sebb/active::desc
	icon_state = "sebb"
	path_to_spawn = /obj/item/explosive/mine/sebb/active

/datum/human_ai_defense/mine/prox_sensor
	name = "Proximity Sensor"
	desc = /obj/item/device/assembly/prox_sensor::desc
	icon_state = "prox"
	path_to_spawn = /obj/item/device/assembly/prox_sensor/active

/datum/human_ai_defense/mine/m760ap
	name = "Weak M760 Blast Mine"
	desc = /obj/item/explosive/mine/m760ap/active::desc
	icon_state = "m760"
	path_to_spawn = /obj/item/explosive/mine/m760ap/active

/datum/human_ai_defense/mine/m760ap/strong
	name = "Strong M760 Blast Mine"
	desc = /obj/item/explosive/mine/m760ap/strong/active::desc
	icon_state = "m760"
	path_to_spawn = /obj/item/explosive/mine/m760ap/strong/active

/datum/human_ai_defense/mine/m5a3betty
	name = "Weak M5A3 Bounding Mine"
	desc = /obj/item/explosive/mine/m5a3betty/active::desc
	icon_state = "m5"
	path_to_spawn = /obj/item/explosive/mine/m5a3betty/active

/datum/human_ai_defense/mine/m5a3betty/strong
	name = "Strong M5A3 Bounding Mine"
	desc = /obj/item/explosive/mine/m5a3betty/strong/active::desc
	icon_state = "m5"
	path_to_spawn = /obj/item/explosive/mine/m5a3betty/strong/active

/datum/human_ai_defense/mine/fzd91
	name = "Weak FZD-91 Landmine"
	desc = /obj/item/explosive/mine/fzd91/active::desc
	icon_state = "fzd91"
	path_to_spawn = /obj/item/explosive/mine/fzd91/active

/datum/human_ai_defense/mine/fzd91/strong
	name = "Strong FZD-91 Landmine"
	desc = /obj/item/explosive/mine/fzd91/strong/active::desc
	icon_state = "fzd91"
	path_to_spawn = /obj/item/explosive/mine/fzd91/strong/active

/datum/human_ai_defense/mine/tn13
	name = "Weak TN-13 Landmine"
	desc = /obj/item/explosive/mine/tn13/active::desc
	icon_state = "tn13"
	path_to_spawn = /obj/item/explosive/mine/tn13/active

/datum/human_ai_defense/mine/tn13/strong
	name = "Regular TN-13 Landmine"
	desc = /obj/item/explosive/mine/tn13/strong/active::desc
	icon_state = "tn13"
	path_to_spawn = /obj/item/explosive/mine/tn13/strong/active

// Barricades

/datum/human_ai_defense/barricade
	uses_turned_on = FALSE
	uses_faction = FALSE
	category = "Barricades"

/datum/human_ai_defense/barricade/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)

/datum/human_ai_defense/barricade/wooden
	name = "Wooden Barricade"
	desc = /obj/structure/barricade/wooden::desc
	icon_state = "wooden"
	path_to_spawn = /obj/structure/barricade/wooden

/datum/human_ai_defense/barricade/metal
	name = "Metal Barricade"
	desc = /obj/structure/barricade/metal::desc
	icon_state = "metal"
	path_to_spawn = /obj/structure/barricade/metal

/datum/human_ai_defense/barricade/metal/wired
	name = "Metal Barricade - Wired"
	desc = /obj/structure/barricade/metal/wired::desc
	icon_state = "metal_wired"
	path_to_spawn = /obj/structure/barricade/metal/wired

/datum/human_ai_defense/barricade/sandbag
	name = "Sandbags"
	desc = /obj/structure/barricade/sandbags/full::desc
	icon_state = "sandbag"
	path_to_spawn = /obj/structure/barricade/sandbags/full

/datum/human_ai_defense/barricade/plasteel_folding
	name = "Plasteel Folding Barricade"
	desc = /obj/structure/barricade/plasteel::desc
	icon_state = "plasteel_folding"
	path_to_spawn = /obj/structure/barricade/plasteel

/datum/human_ai_defense/barricade/plasteel_folding/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/plasteel/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	defense.open() // closes it

/datum/human_ai_defense/barricade/plasteel_folding/wired
	name = "Plasteel Folding Barricade - Wired"
	desc = /obj/structure/barricade/plasteel/wired::desc
	icon_state = "plasteel_folding_wired"
	path_to_spawn = /obj/structure/barricade/plasteel/wired

/datum/human_ai_defense/barricade/metal_folding
	name = "Metal Folding Barricade"
	desc = /obj/structure/barricade/plasteel/metal::desc
	icon_state = "metal_folding"
	path_to_spawn = /obj/structure/barricade/plasteel/metal

/datum/human_ai_defense/barricade/metal_folding/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/plasteel/metal/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	defense.open() // closes it

/datum/human_ai_defense/barricade/metal_folding/wired
	name = "Metal Folding Barricade - Wired"
	desc = /obj/structure/barricade/plasteel/metal/wired::desc
	icon_state = "metal_folding_wired"
	path_to_spawn = /obj/structure/barricade/plasteel/metal/wired

/datum/human_ai_defense/barricade/wooden
	name = "Wooden Barricade"
	desc = /obj/structure/barricade/wooden::desc
	icon_state = "wooden"
	path_to_spawn = /obj/structure/barricade/wooden

/datum/human_ai_defense/barricade/snow
	name = "Snow Barricade"
	desc = /obj/structure/barricade/snow::desc
	icon_state = "snow"
	path_to_spawn = /obj/structure/barricade/snow

/datum/human_ai_defense/barricade/plasteel
	name = "Plasteel Barricade"
	desc = /obj/structure/barricade/metal/plasteel::desc
	icon_state = "plasteel"
	path_to_spawn = /obj/structure/barricade/metal/plasteel

/datum/human_ai_defense/barricade/plasteel/wired
	name = "Plasteel Barricade - Wired"
	desc = /obj/structure/barricade/metal/plasteel/wired::desc
	icon_state = "plasteel_wired"
	path_to_spawn = /obj/structure/barricade/metal/plasteel/wired

/datum/human_ai_defense/barricade/deployable
	name = "Portable Barricade"
	desc = /obj/structure/barricade/deployable::desc
	icon_state = "folding_0"
	path_to_spawn = /obj/structure/barricade/deployable

/datum/human_ai_defense/misc_defences
	uses_turned_on = FALSE
	uses_faction = FALSE
	category = "Miscellaneous Defenses"

/datum/human_ai_defense/misc_defences/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)

/datum/human_ai_defense/misc_defences/barrier
	name = "Deployable Barrier"
	desc = /obj/structure/machinery/deployable/barrier::desc
	icon_state = "barrier0"
	path_to_spawn = /obj/structure/machinery/deployable/barrier

/datum/human_ai_defense/misc_defences/table
	name = "Table Barricade"
	desc = /obj/structure/barricade/table::desc
	icon_state = "metalflip"
	path_to_spawn = /obj/structure/barricade/table

/datum/human_ai_defense/misc_defences/table/wood
	name = "Wooden Table Barricade"
	desc = /obj/structure/barricade/table/wood::desc
	icon_state = "woodflip"
	path_to_spawn = /obj/structure/barricade/table/wood

/datum/human_ai_defense/misc_defences/table/poor
	name = "Poor Table Barricade"
	desc = /obj/structure/barricade/table/wood/poor::desc
	icon_state = "pwoodflip"
	path_to_spawn = /obj/structure/barricade/table/wood/poor

/datum/human_ai_defense/misc_defences/table/gambling
	name = "Gambling Table Barricade"
	desc = /obj/structure/barricade/table/wood/gambling::desc
	icon_state = "gameflip"
	path_to_spawn = /obj/structure/barricade/table/wood/gambling

/datum/human_ai_defense/misc_defences/table/reinforced
	name = "Reinforced Table Barricade"
	desc = /obj/structure/barricade/table/reinforced::desc
	icon_state = "reinfflip"
	path_to_spawn = /obj/structure/barricade/table/reinforced

/datum/human_ai_defense/misc_defences/table/almayer
	name = "Almayer Table Barricade"
	desc = /obj/structure/barricade/table/almayer::desc
	icon_state = "almflip"
	path_to_spawn = /obj/structure/barricade/table/almayer

/datum/human_ai_defense/misc_defences/table/prison
	name = "Prison Table Barricade"
	desc = /obj/structure/barricade/table/prison::desc
	icon_state = "prisonflip"
	path_to_spawn = /obj/structure/barricade/table/prison

/datum/human_ai_defense/misc_defences/razorwire
	name = "Razorwire"
	desc = /obj/structure/barricade/razorwire::desc
	icon_state = "barbed_wire"
	path_to_spawn = /obj/structure/barricade/razorwire

#undef DEFENSE_CREATOR_SPAWN_CLICK_INTERCEPT_ACTION
