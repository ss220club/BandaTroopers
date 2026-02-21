/datum/human_ai_management_menu

/datum/human_ai_management_menu/New()

/datum/human_ai_management_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanAIManager")
		ui.open()

/datum/human_ai_management_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_ai_management_menu/ui_data(mob/user)
	var/list/data = list()

	data["orders"] = list()
	for(var/datum/ai_order/order as anything in get_human_ai_runtime_orders())
		data["orders"] += list(list(
			"name" = order.name,
			"type" = order.type,
			"data" = order.tgui_data(),
			"ref" = REF(order),
		)
	)

	data["ai_humans"] = list()
	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains)
		if(!brain.tied_human || brain.tied_human.stat == DEAD)
			continue

		data["ai_humans"] += list(list(
			"name" = brain.tied_human.real_name,
			"health" = FLOOR((brain.tied_human.health / brain.tied_human.maxHealth * 100), 1),
			"loc" = list(brain.tied_human.x, brain.tied_human.y, brain.tied_human.z),
			"faction" = brain.tied_human.faction,
			"ref" = REF(brain.tied_human),
			"brain_ref" = REF(brain),
			"in_combat" = brain.in_combat,
			"squad_id" = brain.squad_id,
			"can_assign_squad" = brain.can_assign_squad,
		))

	data["squads"] = list()
	for(var/datum/human_ai_squad/squad as anything in get_human_ai_runtime_squads())
		var/list/name_list = list()
		for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
			name_list += brain.tied_human?.real_name
		data["squads"] += list(list(
			"id" = squad.id,
			"name" = squad.name,
			"members" = english_list(name_list),
			"order" = squad.current_order?.name,
			"ref" = REF(squad),
			"squad_leader" = squad.squad_leader?.tied_human?.real_name,
		))

	return data

/datum/human_ai_management_menu/ui_static_data(mob/user)
	var/list/data = list()

	return data

/datum/human_ai_management_menu/proc/resolve_human_ai_brain(brain_or_human_ref)
	RETURN_TYPE(/datum/human_ai_brain)
	if(!brain_or_human_ref)
		return null

	var/datum/human_ai_brain/brain = locate(brain_or_human_ref)
	if(istype(brain))
		return brain

	var/mob/living/carbon/human/ai_human = locate(brain_or_human_ref)
	if(!istype(ai_human))
		return null
	return ai_human.get_ai_brain()

/datum/human_ai_management_menu/proc/resolve_human_ai_squad(squad_id)
	RETURN_TYPE(/datum/human_ai_squad)
	if(isnull(squad_id))
		return null
	return get_human_ai_runtime_squad("[squad_id]")

/datum/human_ai_management_menu/proc/assign_human_ai_to_squad(brain_or_human_ref, squad_id)
	var/datum/human_ai_squad/squad = resolve_human_ai_squad(squad_id)
	if(!squad)
		return FALSE

	var/datum/human_ai_brain/brain = resolve_human_ai_brain(brain_or_human_ref)
	if(!brain || !brain.can_assign_squad)
		return FALSE

	brain.add_to_squad(squad.id)
	brain.tied_human?.refresh_human_ai_runtime_state()
	return brain.squad_id == squad.id

/datum/human_ai_management_menu/proc/assign_order_to_squad(order_ref, squad_id)
	var/datum/human_ai_squad/squad = resolve_human_ai_squad(squad_id)
	if(!squad)
		return FALSE

	var/datum/ai_order/order = locate(order_ref)
	if(!istype(order))
		return FALSE

	squad.set_current_order(order)
	for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
		brain.tied_human?.refresh_human_ai_runtime_state()
	return squad.current_order == order

/datum/human_ai_management_menu/proc/assign_squad_leader(brain_or_human_ref, squad_id)
	var/datum/human_ai_squad/squad = resolve_human_ai_squad(squad_id)
	if(!squad)
		return FALSE

	var/datum/human_ai_brain/brain = resolve_human_ai_brain(brain_or_human_ref)
	if(!brain || brain.squad_id != squad.id)
		return FALSE

	squad.set_squad_leader(brain)
	brain.tied_human?.refresh_human_ai_runtime_state()
	return squad.squad_leader == brain

/datum/human_ai_management_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("view_variables")
			if(!params["ref"])
				return

			var/datum/gotten_ref = locate(params["ref"])
			if(!istype(gotten_ref))
				return

			ui.user.client?.debug_variables(gotten_ref)
			return TRUE

		if("jump_to")
			if(!params["ref"])
				return

			var/mob/living/carbon/human/ai_human = locate(params["ref"])

			if(istype(ui.user, /mob/dead/observer))
				var/mob/dead/observer/ghost = ui.user
				if(ai_human?.loc)
					ghost.JumpToCoord(ai_human.x, ai_human.y, ai_human.z)
			return TRUE

		if("create_squad")
			create_human_ai_runtime_squad()
			return TRUE

		if("rename_squad")
			if(!params["squad"])
				return

			var/datum/human_ai_squad/squad = resolve_human_ai_squad(params["squad"])
			if(!squad)
				return TRUE

			var/new_squad_name = tgui_input_text(ui.user, "Input new squad name", "Input")
			if(isnull(new_squad_name))
				return TRUE
			new_squad_name = trim(new_squad_name)
			if(!length(new_squad_name))
				return TRUE
			squad.name = new_squad_name
			return TRUE

		if("assign_to_squad")
			if(!params["squad"] || !params["ai"])
				return

			assign_human_ai_to_squad(params["ai"], params["squad"])
			return TRUE

		if("assign_order")
			if(!params["squad"] || !params["order"])
				return

			assign_order_to_squad(params["order"], params["squad"])
			return TRUE

		if("assign_sl")
			if(!params["squad"] || !params["ai"])
				return

			assign_squad_leader(params["ai"], params["squad"])
			return TRUE

		if("delete_object") // This UI is fully GM-only so I'm not worried about someone abusing this
			if(!params["ref"])
				return

			var/datum/ref_to_del = locate(params["ref"])
			qdel(ref_to_del)
			return TRUE

/client/proc/open_human_ai_management_panel()
	set name = "Human AI Management Panel"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(human_ai_menu)
		human_ai_menu.tgui_interact(mob)
		return

	human_ai_menu = new /datum/human_ai_management_menu(src)
	human_ai_menu.tgui_interact(mob)

/client/proc/create_human_ai()
	set name = "Create Human AI - Expanded"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	var/mob/living/carbon/human/ai_human = new()
	ai_human.AddComponent(get_human_ai_component_type())

	if(!cmd_admin_dress_human(ai_human, randomize = TRUE))
		qdel(ai_human)
		return

	ai_human.face_dir(mob.dir)
	ai_human.forceMove(get_turf(mob))
	ai_human.refresh_human_ai_runtime_state(armor = TRUE)

/client/proc/make_human_ai(mob/living/carbon/human/mob in GLOB.human_mob_list)
	set name = "Make AI"
	set desc = "Add AI functionality to a human."
	set category = null

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	if(QDELETED(mob))
		return

	if(mob.get_ai_brain())
		to_chat(usr, SPAN_WARNING("[mob] already has an assigned AI."))
		return

	if(mob.ckey && tgui_alert(mob, "This mob is being controlled by [mob.ckey]. Are you sure you wish to add AI to it?","Make AI", list("Yes","No")) != "Yes")
		return

	mob.AddComponent(get_human_ai_component_type())
	mob.refresh_human_ai_runtime_state()

	message_admins("[key_name_admin(usr)] assigned an AI component to [mob.real_name].")

/client/proc/toggle_human_ai_tweaks()
	set name = "Toggle Human AI Tweaks"
	set category = "Game Master.Flags"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	if(!SSticker.mode)
		to_chat(usr, SPAN_WARNING("A mode hasn't been selected yet!"))
		return

	SSticker.mode.toggleable_flags ^= MODE_HUMAN_AI_TWEAKS
	message_admins("[src] has [MODE_HAS_TOGGLEABLE_FLAG(MODE_HUMAN_AI_TWEAKS) ? "toggled Human AI tweaks on" : "toggled Human AI tweaks off"].")
