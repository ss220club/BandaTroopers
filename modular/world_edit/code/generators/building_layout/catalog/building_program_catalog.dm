/datum/world_edit_building_program_catalog
	var/list/programs = list()
	var/initialized = FALSE
	var/datum/world_edit_validation_verdict/last_validation

/datum/world_edit_building_program_catalog/proc/initialize_catalog()
	if(initialized)
		return last_validation
	initialized = TRUE
	for(var/datum/world_edit_building_program/program as anything in build_initial_programs())
		register_program(program)
	last_validation = validate_catalog()
	return last_validation

/datum/world_edit_building_program_catalog/proc/build_initial_programs()
	return list()

/datum/world_edit_building_program_catalog/proc/register_program(datum/world_edit_building_program/program)
	if(!istype(program) || !length(program.id))
		return FALSE
	programs[program.id] = program
	return TRUE

/datum/world_edit_building_program_catalog/proc/get_program(program_id)
	return programs["[program_id]"]

/datum/world_edit_building_program_catalog/proc/validate_catalog()
	var/datum/world_edit_validation_verdict/catalog_verdict = new(WORLD_EDIT_BUILDING_PREFLIGHT_SUPPORTED, WORLD_EDIT_BUILDING_STAGE_CATALOG_VALIDATION)
	if(!length(programs))
		catalog_verdict.add_warning("catalog.programs.empty", "Program catalog skeleton has no registered programs yet.")
	for(var/program_id as anything in programs)
		var/datum/world_edit_building_program/program = programs[program_id]
		if(!istype(program) || !length(program.id))
			catalog_verdict.status = WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST
			catalog_verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_CATALOG_INVALID, "Program catalog contains an invalid program entry.", list("program_id" = "[program_id]"))
	return catalog_verdict

/datum/world_edit_building_program_catalog/proc/build_capability_payload()
	var/list/payload = list()
	for(var/program_id as anything in programs)
		var/datum/world_edit_building_program/program = programs[program_id]
		if(!istype(program))
			continue
		var/list/required_capabilities = list()
		for(var/datum/world_edit_building_room_spec/room as anything in program.rooms)
			if(!istype(room) || !islist(room.required_capabilities))
				continue
			for(var/capability_id as anything in room.required_capabilities)
				if(!(capability_id in required_capabilities))
					required_capabilities += capability_id
		payload[program_id] = list(
			"id" = program.id,
			"label" = program.label,
			"required_capabilities" = required_capabilities,
		)
	return payload
