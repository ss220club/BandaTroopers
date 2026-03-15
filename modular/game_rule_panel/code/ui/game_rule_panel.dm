/client/proc/toggle_game_rule_panel()
	set name = "Game Rule Panel"
	set category = "Game Master"

	if(!check_rights(R_ADMIN))
		return

	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(src && rules)
		rules.open_panel(src)

/datum/game_rule_panel
	var/client/holder

/datum/game_rule_panel/New(client/using_client)
	holder = using_client
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(rules && !(src in rules.open_panels))
		rules.open_panels += src
	. = ..()
	tgui_interact(holder.mob)

/datum/game_rule_panel/Destroy()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(rules)
		rules.open_panels -= src
	holder = null
	return ..()

/datum/game_rule_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/game_rule_panel/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE

/datum/game_rule_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GameRulePanel", "Game Rule Panel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/game_rule_panel/ui_data(mob/user)
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.ensure_fire_support_defaults_captured()
	var/list/fire_support_pool = rules.build_fire_support_pool_data()

	return list(
		"rto_support_enabled" = rules.rto_support_enabled,
		"rto_shared_cooldown_multiplier" = rules.rto_shared_cooldown_multiplier,
		"rto_personal_cooldown_multiplier" = rules.rto_personal_cooldown_multiplier,
		"fire_support_enabled" = rules.fire_support_enabled,
		"fire_support_points" = rules.build_fire_support_points_data(),
		"fire_support_enabled_entries" = fire_support_pool["enabled"],
		"fire_support_disabled_entries" = fire_support_pool["disabled"],
	)

/datum/game_rule_panel/ui_close(mob/user)
	qdel(src)

/datum/game_rule_panel/proc/log_rule_change(mob/user, message)
	if(!length(message))
		return FALSE

	var/log_message = "[key_name_admin(user)] [message]"
	message_admins(log_message)
	log_admin(log_message)
	return TRUE

/datum/game_rule_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!check_rights(R_ADMIN))
		return FALSE

	var/mob/user = ui?.user
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/updated = FALSE

	switch(action)
		if("set_rto_support_enabled")
			var/enabled = !!text2num(params["enabled"])
			if(rules.rto_support_enabled == enabled)
				return FALSE
			rules.rto_support_enabled = enabled
			GLOB.rto_support_registry?.propagate_rules_update()
			log_rule_change(user, "set RTO Support to [enabled ? "enabled" : "disabled"] in Game Rule Panel.")
			updated = TRUE

		if("set_rto_shared_multiplier")
			var/new_value = rules.sanitize_multiplier(text2num(params["value"]))
			if(rules.rto_shared_cooldown_multiplier == new_value)
				return FALSE
			rules.rto_shared_cooldown_multiplier = new_value
			GLOB.rto_support_registry?.propagate_rules_update()
			log_rule_change(user, "set RTO shared cooldown multiplier to [new_value].")
			updated = TRUE

		if("set_rto_personal_multiplier")
			var/new_value = rules.sanitize_multiplier(text2num(params["value"]))
			if(rules.rto_personal_cooldown_multiplier == new_value)
				return FALSE
			rules.rto_personal_cooldown_multiplier = new_value
			GLOB.rto_support_registry?.propagate_rules_update()
			log_rule_change(user, "set RTO personal cooldown multiplier to [new_value].")
			updated = TRUE

		if("reset_rto_rules")
			rules.reset_rto_rules()
			GLOB.rto_support_registry?.propagate_rules_update()
			log_rule_change(user, "reset RTO Game Rule Panel settings to defaults.")
			updated = TRUE

		if("set_fire_support_enabled")
			var/enabled = !!text2num(params["enabled"])
			if(rules.fire_support_enabled == enabled)
				return FALSE
			rules.fire_support_enabled = enabled
			log_rule_change(user, "set Fire Support to [enabled ? "enabled" : "disabled"] in Game Rule Panel.")
			updated = TRUE

		if("grant_fire_support_points")
			var/faction = params["faction"]
			var/amount = text2num(params["amount"])
			if(!rules.grant_fire_support_points(faction, amount))
				return FALSE
			log_rule_change(user, "granted [round(amount)] Fire Support points to [faction].")
			updated = TRUE

		if("set_fire_support_type_enabled")
			var/fire_support_type = params["type_id"]
			var/enabled = !!text2num(params["enabled"])
			if(!rules.set_fire_support_type_enabled(fire_support_type, enabled))
				return FALSE
			var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
			log_rule_change(user, "[enabled ? "enabled" : "disabled"] [fire_support_option ? initial(fire_support_option.name) : fire_support_type] Fire Support.")
			updated = TRUE

		if("reset_fire_support_rules")
			rules.reset_fire_support_rules()
			log_rule_change(user, "reset Fire Support Game Rule Panel settings to defaults.")
			updated = TRUE

	if(updated)
		rules.update_panel_uis()
	return updated
