/datum/world_edit_building_program
	var/id = ""
	var/label = ""
	var/list/rooms = list()
	var/list/room_lookup = list()
	var/list/connections = list()
	var/datum/world_edit_validation_verdict/verdict

/datum/world_edit_building_program/New(_id = "", _label = "")
	. = ..()
	id = "[_id]"
	label = length("[_label]") ? "[_label]" : id

/datum/world_edit_building_program/proc/add_room_spec(datum/world_edit_building_room_spec/room)
	if(!istype(room) || !length(room.id))
		return FALSE
	if(room_lookup[room.id])
		return FALSE
	rooms += room
	room_lookup[room.id] = room
	return TRUE

/datum/world_edit_building_program/proc/add_connection_spec(datum/world_edit_building_connection_spec/connection)
	if(!istype(connection) || !length(connection.from_room) || !length(connection.to_room))
		return FALSE
	connections += connection
	return TRUE

/datum/world_edit_building_program/proc/as_payload()
	return list(
		"id" = id,
		"label" = label,
		"room_count" = length(rooms),
		"connection_count" = length(connections),
		"verdict" = verdict?.as_payload(),
	)

/datum/world_edit_building_room_spec
	var/id = ""
	var/role = ""
	var/required = TRUE
	var/min_area = 1
	var/preferred_area = 1
	var/max_area = 1
	var/min_aspect = 0.25
	var/max_aspect = 4
	var/privacy = "public"
	var/facade_requirement = ""
	var/list/required_capabilities = list()
	var/optional = FALSE
	var/optional_weight = 0

/datum/world_edit_building_room_spec/New(_id = "", _role = "", _required = TRUE, _min_area = 1, _preferred_area = 1, _max_area = 1, _min_aspect = 0.25, _max_aspect = 4, list/_required_capabilities = null)
	. = ..()
	id = "[_id]"
	role = "[_role]"
	required = _required ? TRUE : FALSE
	optional = !required
	min_area = max(round(text2num("[_min_area]") || 1), 1)
	preferred_area = max(round(text2num("[_preferred_area]") || min_area), min_area)
	max_area = max(round(text2num("[_max_area]") || preferred_area), preferred_area)
	min_aspect = max(text2num("[_min_aspect]") || 0.25, 0.01)
	max_aspect = max(text2num("[_max_aspect]") || 4, min_aspect)
	required_capabilities = islist(_required_capabilities) ? _required_capabilities.Copy() : list()

/datum/world_edit_building_room_spec/proc/as_payload()
	return list(
		"id" = id,
		"role" = role,
		"required" = required ? TRUE : FALSE,
		"min_area" = min_area,
		"preferred_area" = preferred_area,
		"max_area" = max_area,
		"min_aspect" = min_aspect,
		"max_aspect" = max_aspect,
		"privacy" = privacy,
		"facade_requirement" = facade_requirement,
		"required_capabilities" = islist(required_capabilities) ? required_capabilities.Copy() : list(),
		"optional" = optional ? TRUE : FALSE,
		"optional_weight" = optional_weight,
	)

/datum/world_edit_building_connection_spec
	var/from_room = ""
	var/to_room = ""
	var/kind = WORLD_EDIT_BUILDING_CONNECTION_ROUTE
	var/required = TRUE
	var/door_count = 1
	var/min_width = 1

/datum/world_edit_building_connection_spec/New(_from_room = "", _to_room = "", _kind = WORLD_EDIT_BUILDING_CONNECTION_ROUTE, _required = TRUE)
	. = ..()
	from_room = "[_from_room]"
	to_room = "[_to_room]"
	kind = length("[_kind]") ? "[_kind]" : WORLD_EDIT_BUILDING_CONNECTION_ROUTE
	required = _required ? TRUE : FALSE

/datum/world_edit_building_connection_spec/proc/as_payload()
	return list(
		"from_room" = from_room,
		"to_room" = to_room,
		"kind" = kind,
		"required" = required ? TRUE : FALSE,
		"door_count" = door_count,
		"min_width" = min_width,
	)
