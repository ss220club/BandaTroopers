/datum/flavor_text_editor/ui_data(mob/user)
	. = ..()

	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	.["categories"] = list()
	// SS220 DemonicLynx "Lobby UI" - optional presentation data; TGUI defaults remain classic.
	var/list/custom_presentation = SSmodpacks?.lobby_ui_provider?.lobby_ui_flavor_text_presentation(prefs)
	if(custom_presentation)
		.["custom_presentation"] = custom_presentation

	for (var/category in prefs.flavor_texts)
		.["categories"] += category
		.[category] = prefs.flavor_texts[category]

/datum/flavor_text_editor/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		// SS220 DemonicLynx "Lobby UI" - optional title provider; upstream title is the fallback.
		var/window_title = SSmodpacks?.lobby_ui_provider?.lobby_ui_flavor_text_window_title(user.client?.prefs) || "Flavor Text Editor"
		ui = new(user, src, "FlavorTextEditor", window_title)
		ui.open()
		ui.set_autoupdate(FALSE)

	winset(user, ui.window.id, "focus=true")

/datum/flavor_text_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	var/datum/preferences/prefs = ui.user.client?.prefs
	if(!prefs)
		return

	switch(action)
		if("set_flavor_text")
			if(!params["category"])
				return
			prefs.flavor_texts[params["category"]] = params["text"]
			return TRUE

	return TRUE


/datum/flavor_text_editor/ui_state(mob/user)
	return GLOB.always_state
