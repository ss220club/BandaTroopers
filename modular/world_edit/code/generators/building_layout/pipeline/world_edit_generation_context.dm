/datum/world_edit_generation_context
	var/datum/world_edit_building_request/request
	var/datum/world_edit_building_layout_state/state
	var/datum/world_edit_generator/building_layout/generator

/datum/world_edit_generation_context/New(datum/world_edit_building_request/req, datum/world_edit_building_layout_state/s, datum/world_edit_generator/building_layout/gen)
	request = req
	state = s
	generator = gen

/datum/world_edit_generation_context/proc/has_errors()
	return state && state.has_errors()
