GLOBAL_DATUM_INIT(game_rule_state, /datum/game_rule_state, new)

/datum/game_rule_state
	var/rto_support_enabled = TRUE
	var/rto_shared_cooldown_multiplier = 1
	var/rto_personal_cooldown_multiplier = 1
	var/fire_support_enabled = TRUE
	var/list/open_panels = list()
	var/fire_support_defaults_captured = FALSE
	var/list/fire_support_default_points = list()
	var/list/fire_support_default_availability = list()

/datum/game_rule_state/proc/cleanup_open_panels()
	for(var/i = length(open_panels), i >= 1, i--)
		var/datum/game_rule_panel/panel = open_panels[i]
		if(panel && !QDELETED(panel) && panel.holder)
			continue
		open_panels.Cut(i, i + 1)
	return TRUE

/datum/game_rule_state/proc/find_open_panel(client/using_client)
	if(!using_client)
		return null

	cleanup_open_panels()

	for(var/datum/game_rule_panel/panel as anything in open_panels)
		if(panel?.holder == using_client)
			return panel
	return null

/datum/game_rule_state/proc/open_panel(client/using_client)
	if(!using_client)
		return null

	var/datum/game_rule_panel/panel = find_open_panel(using_client)
	if(panel)
		panel.tgui_interact(using_client.mob)
		return panel

	return new /datum/game_rule_panel(using_client)

/datum/game_rule_state/proc/update_panel_uis()
	cleanup_open_panels()
	for(var/datum/game_rule_panel/panel as anything in open_panels)
		SStgui.update_uis(panel)
	return TRUE

/datum/game_rule_state/proc/sanitize_multiplier(value)
	if(!isnum(value))
		return 1
	return clamp(round(value, 0.1), 0.1, 10)

/datum/game_rule_state/proc/ensure_fire_support_defaults_captured()
	if(fire_support_defaults_captured)
		return FALSE

	fire_support_default_points = list()
	for(var/faction in GLOB.fire_support_points)
		fire_support_default_points[faction] = GLOB.fire_support_points[faction]

	fire_support_default_availability = list()
	for(var/fire_support_type in GLOB.fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(!fire_support_option)
			continue
		fire_support_default_availability[fire_support_type] = !!(fire_support_option.fire_support_flags & FIRESUPPORT_AVAILABLE)

	fire_support_defaults_captured = TRUE
	return TRUE

/datum/game_rule_state/proc/reset_rto_rules()
	rto_support_enabled = TRUE
	rto_shared_cooldown_multiplier = 1
	rto_personal_cooldown_multiplier = 1
	return TRUE

/datum/game_rule_state/proc/reset_fire_support_rules()
	ensure_fire_support_defaults_captured()
	fire_support_enabled = TRUE

	for(var/fire_support_type in GLOB.fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(!fire_support_option)
			continue
		if(fire_support_default_availability[fire_support_type])
			fire_support_option.enable_firesupport()
		else
			fire_support_option.disable()

	var/list/current_factions = list()
	for(var/fire_support_type in GLOB.fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(fire_support_option?.faction)
			current_factions |= fire_support_option.faction
	for(var/faction in GLOB.fire_support_points)
		current_factions |= faction

	for(var/faction in current_factions)
		GLOB.fire_support_points[faction] = fire_support_default_points[faction] || 0

	return TRUE

/datum/game_rule_state/proc/grant_fire_support_points(faction, amount)
	if(!length(faction))
		return FALSE
	if(!isnum(amount))
		return FALSE

	ensure_fire_support_defaults_captured()

	var/safe_amount = round(amount)
	if(safe_amount <= 0)
		return FALSE

	GLOB.fire_support_points[faction] = max(0, (GLOB.fire_support_points[faction] || 0) + safe_amount)
	return TRUE

/datum/game_rule_state/proc/set_fire_support_type_enabled(fire_support_type, enabled)
	if(!length(fire_support_type))
		return FALSE

	ensure_fire_support_defaults_captured()

	var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
	if(!fire_support_option)
		return FALSE

	if(enabled)
		fire_support_option.enable_firesupport()
	else
		fire_support_option.disable()
	return TRUE

/datum/game_rule_state/proc/get_fire_support_factions()
	var/list/factions = list()
	for(var/fire_support_type in GLOB.fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(fire_support_option?.faction)
			factions |= fire_support_option.faction
	for(var/faction in GLOB.fire_support_points)
		factions |= faction
	return sortList(factions)

/datum/game_rule_state/proc/build_fire_support_points_data()
	var/list/data = list()
	for(var/faction in get_fire_support_factions())
		data += list(list(
			"faction" = faction,
			"points" = GLOB.fire_support_points[faction] || 0,
		))
	return data

/proc/cmp_game_rule_fire_support_entries(list/a, list/b)
	var/faction_a = a["faction"] || ""
	var/faction_b = b["faction"] || ""
	var/faction_compare = sorttext(faction_b, faction_a)
	if(faction_compare)
		return faction_compare
	return sorttext(b["name"] || "", a["name"] || "")

/datum/game_rule_state/proc/build_fire_support_pool_data()
	var/list/enabled = list()
	var/list/disabled = list()

	for(var/fire_support_type in GLOB.fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(!fire_support_option)
			continue

		var/list/entry = list(
			"type_id" = fire_support_type,
			"name" = initial(fire_support_option.name),
			"faction" = fire_support_option.faction,
			"cost" = fire_support_option.cost,
			"cooldown_duration" = round(fire_support_option.cooldown_duration / 10),
			"fire_support_firer" = fire_support_option.fire_support_firer,
		)

		if(fire_support_option.fire_support_flags & FIRESUPPORT_AVAILABLE)
			enabled += list(entry)
		else
			disabled += list(entry)

	sortTim(enabled, GLOBAL_PROC_REF(cmp_game_rule_fire_support_entries))
	sortTim(disabled, GLOBAL_PROC_REF(cmp_game_rule_fire_support_entries))

	return list(
		"enabled" = enabled,
		"disabled" = disabled,
	)
