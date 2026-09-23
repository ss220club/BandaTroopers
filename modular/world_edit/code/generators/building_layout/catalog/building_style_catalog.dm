/datum/world_edit_building_style
	var/id = ""
	var/label = ""
	var/list/shell_paths = list()
	var/list/capabilities = list()
	var/list/providers_by_capability = list()
	var/list/unsupported_programs = list()

/datum/world_edit_building_style/New(_id = "", _label = "")
	. = ..()
	id = "[_id]"
	label = length("[_label]") ? "[_label]" : id

/datum/world_edit_building_style/proc/as_payload()
	return list(
		"id" = id,
		"label" = label,
		"capabilities" = islist(capabilities) ? capabilities.Copy() : list(),
		"providers_by_capability" = islist(providers_by_capability) ? providers_by_capability.Copy() : list(),
		"unsupported_programs" = islist(unsupported_programs) ? unsupported_programs.Copy() : list(),
	)

/datum/world_edit_building_style_catalog
	var/list/styles = list()
	var/initialized = FALSE
	var/datum/world_edit_validation_verdict/last_validation

/datum/world_edit_building_style_catalog/proc/initialize_catalog()
	if(initialized)
		return last_validation
	initialized = TRUE
	for(var/datum/world_edit_building_style/style as anything in build_initial_styles())
		register_style(style)
	last_validation = validate_catalog()
	return last_validation

/datum/world_edit_building_style_catalog/proc/build_initial_styles()
	return list()

/datum/world_edit_building_style_catalog/proc/register_style(datum/world_edit_building_style/style)
	if(!istype(style) || !length(style.id))
		return FALSE
	styles[style.id] = style
	return TRUE

/datum/world_edit_building_style_catalog/proc/get_style(style_id)
	return styles["[style_id]"]

/datum/world_edit_building_style_catalog/proc/validate_catalog()
	var/datum/world_edit_validation_verdict/catalog_verdict = new(WORLD_EDIT_BUILDING_PREFLIGHT_SUPPORTED, WORLD_EDIT_BUILDING_STAGE_CATALOG_VALIDATION)
	if(!length(styles))
		catalog_verdict.add_warning("catalog.styles.empty", "Style catalog skeleton has no registered styles yet.")
	for(var/style_id as anything in styles)
		var/datum/world_edit_building_style/style = styles[style_id]
		if(!istype(style) || !length(style.id))
			catalog_verdict.status = WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST
			catalog_verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_CATALOG_INVALID, "Style catalog contains an invalid style entry.", list("style_id" = "[style_id]"))
	return catalog_verdict

/datum/world_edit_building_style_catalog/proc/build_style_payload()
	var/list/payload = list()
	for(var/style_id as anything in styles)
		var/datum/world_edit_building_style/style = styles[style_id]
		if(istype(style))
			payload[style_id] = style.as_payload()
	return payload
