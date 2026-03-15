GLOBAL_LIST_EMPTY(game_master_droppods)
GLOBAL_DATUM_INIT(droppod_panel, /datum/drop_pod_menu, new)
#define DROPPOD_CLICK_INTERCEPT_ACTION "droppod_click_intercept_action"

/client/proc/toggle_droppod_menu()
	set name = "Drop Pod Menu"
	set category = "Game Master.Extras"
	if(!check_rights(R_ADMIN))
		return

	GLOB.droppod_panel.tgui_interact(mob)

/datum/drop_pod_menu
	var/droppod_click_intercept = FALSE

/datum/drop_pod_menu/ui_data(mob/user)
	. = ..()

	var/list/data = list()

	data["game_master_droppods"] = length(GLOB.game_master_droppods) ? GLOB.game_master_droppods : ""
	data["droppod_click_intercept"] = droppod_click_intercept
	return data

/datum/drop_pod_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)
	if(droppod_click_intercept)
		var/turf/object_turf = get_turf(object)
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			for(var/obj/effect/landmark/droppod/R in object_turf)
				GLOB.game_master_droppods -= R
				QDEL_NULL(R)
			return TRUE

		var/obj/effect/landmark/droppod/droppod = new(object_turf)
		var/droppod_ref = REF(droppod)
		GLOB.game_master_droppods += list(list(
			"droppod" = droppod,
			"droppod_name" = droppod.name,
			"droppod_ref" = droppod_ref,
			"droppod_x" = droppod.x,
			"droppod_y" = droppod.y,
			"droppod_z" = droppod.z,
			))
		return TRUE

/datum/drop_pod_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GameMasterDroppodMenu", "Droppod Menu")
		ui.open()
	user.client?.click_intercept = src
/datum/drop_pod_menu/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE


/datum/drop_pod_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("remove_droppod")
			if(!params["val"])
				return

			var/list/droppod = params["val"]

			var/atom/droppod_atom = locate(droppod["droppod_ref"])

			if(!droppod_atom)
				return TRUE

			if(tgui_alert(ui.user, "Do you want to remove [droppod_atom] ?", "Confirmation", list("Yes", "No")) != "Yes")
				return TRUE

			remove_droppod(droppod_atom)

		if("jump_to_droppod")
			if(!params["val"])
				return

			var/list/droppod = params["val"]

			var/atom/droppod_atom = locate(droppod["droppod_ref"])

			var/turf/droppod_turf = get_turf(droppod_atom)

			if(!droppod_turf)
				return TRUE

			var/client/jumping_client = ui.user.client
			jumping_client.jump_to_turf(droppod_turf)
			return TRUE
		if("set_target")
			for(var/obj/structure/halo_droppod/pod in world)
				if(!params["val"])
					return

				var/list/droppod = params["val"]
				var/atom/droppod_atom = locate(droppod["droppod_ref"])

				if(!droppod_atom)
					return TRUE

				pod.target_x = droppod_atom.x
				pod.target_y = droppod_atom.y
				pod.target_z = droppod_atom.z
			if(!params["val"])
				return

			var/list/droppod = params["val"]
			var/atom/droppod_atom = locate(droppod["droppod_ref"])
			message_admins("[key_name_admin(usr)] set the ODST drop coordinates to [droppod_atom.x], [droppod_atom.y], [droppod_atom.z]", droppod_atom.x, droppod_atom.y, droppod_atom.z)
		if("toggle_click_droppod")
			droppod_click_intercept = !droppod_click_intercept
			return
		if("launch_pods")
			for(var/obj/structure/halo_droppod/pod in world)
				pod.start_launch_pod()

/datum/drop_pod_menu/ui_close(mob/user)
	var/client/user_client = user.client
	if(user_client?.click_intercept == src)
		user_client.click_intercept = null

	droppod_click_intercept = FALSE

/datum/drop_pod_menu/proc/remove_droppod(obj/removing_datum)
	SIGNAL_HANDLER

	for(var/list/cycled_droppod in GLOB.game_master_droppods)
		if(cycled_droppod["droppod"] == removing_datum)
			GLOB.game_master_droppods.Remove(list(cycled_droppod))
			QDEL_NULL(removing_datum)
