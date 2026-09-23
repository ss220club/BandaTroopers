/datum/world_edit_building_semantic_room_field
	var/datum/world_edit_building_room/room
	var/list/floor_turfs = list()
	var/list/wall_band_turfs = list()
	var/list/corner_turfs = list()
	var/list/center_turfs = list()
	var/list/free_turfs = list()
	var/list/door_buffer_turfs = list()
	var/list/route_edge_turfs = list()
	var/list/service_wall_turfs = list()
	var/turf/focus_turf
	var/area = 0

/datum/world_edit_building_semantic_scene_member_spec
	var/slot = ""
	var/category = ""
	var/scene_slot = ""
	var/placement_mode = "free_near_anchor"
	var/dx = 0
	var/dy = 0
	var/list/allowed_relative_dirs = list()
	var/list/clearance_offsets = list()
	var/list/forbidden_anchor_tags = list()
	var/major = FALSE
	var/wall_required = FALSE
	var/requires_table_pairing = FALSE
	var/seating_group_ok = FALSE

/datum/world_edit_building_semantic_scene_member_spec/New(_slot, _category, _scene_slot, _placement_mode = "free_near_anchor", _major = FALSE, _wall_required = FALSE, _requires_table_pairing = FALSE, _seating_group_ok = FALSE, _dx = 0, _dy = 0, list/_allowed_relative_dirs = null, list/_clearance_offsets = null, list/_forbidden_anchor_tags = null)
	. = ..()
	slot = "[_slot]"
	category = "[_category]"
	scene_slot = "[_scene_slot]"
	placement_mode = "[_placement_mode]"
	dx = round(text2num("[_dx]") || 0)
	dy = round(text2num("[_dy]") || 0)
	allowed_relative_dirs = islist(_allowed_relative_dirs) ? _allowed_relative_dirs.Copy() : list()
	clearance_offsets = islist(_clearance_offsets) ? _clearance_offsets.Copy() : list()
	forbidden_anchor_tags = islist(_forbidden_anchor_tags) ? _forbidden_anchor_tags.Copy() : list()
	major = _major ? TRUE : FALSE
	wall_required = _wall_required ? TRUE : FALSE
	requires_table_pairing = _requires_table_pairing ? TRUE : FALSE
	seating_group_ok = _seating_group_ok ? TRUE : FALSE

/datum/world_edit_building_semantic_scene_rule
	var/id = ""
	var/scene_kind = ""
	var/phase = WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY
	var/primary = TRUE
	var/required = TRUE
	var/priority = 0
	var/global_limit_id = ""
	var/global_limit = 0
	var/list/member_specs = list()

/datum/world_edit_building_semantic_scene_rule/New(_id, _scene_kind, _phase = WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, _primary = TRUE, _required = TRUE, _priority = 0, _global_limit_id = null, _global_limit = 0)
	. = ..()
	id = "[_id]"
	scene_kind = "[_scene_kind]"
	phase = "[_phase]"
	primary = _primary ? TRUE : FALSE
	required = _required ? TRUE : FALSE
	priority = round(text2num("[_priority]") || 0)
	global_limit_id = length("[_global_limit_id]") ? "[_global_limit_id]" : ""
	global_limit = max(round(text2num("[_global_limit]") || 0), 0)

/datum/world_edit_building_semantic_scene_rule/proc/add_member(_slot, _category, _scene_slot, _placement_mode = "free_near_anchor", _major = FALSE, _wall_required = FALSE, _requires_table_pairing = FALSE, _seating_group_ok = FALSE)
	var/datum/world_edit_building_semantic_scene_member_spec/member = new(_slot, _category, _scene_slot, _placement_mode, _major, _wall_required, _requires_table_pairing, _seating_group_ok)
	member_specs += member
	return member

/datum/world_edit_building_semantic_scene_rule/proc/add_relative_member(_slot, _category, _scene_slot, _dx, _dy, _major = FALSE, _wall_required = FALSE, _requires_table_pairing = FALSE, _seating_group_ok = FALSE, list/_allowed_relative_dirs = null, list/_clearance_offsets = null, list/_forbidden_anchor_tags = null)
	var/datum/world_edit_building_semantic_scene_member_spec/member = new(_slot, _category, _scene_slot, WORLD_EDIT_BUILDING_SEMANTIC_PLACE_RELATIVE, _major, _wall_required, _requires_table_pairing, _seating_group_ok, _dx, _dy, _allowed_relative_dirs, _clearance_offsets, _forbidden_anchor_tags)
	member_specs += member
	return member

/datum/world_edit_building_semantic_scene_candidate
	var/datum/world_edit_building_semantic_scene_rule/rule
	var/datum/world_edit_building_semantic_room_field/field
	var/datum/world_edit_building_room/room
	var/list/members = list()
	var/score = 0

/datum/world_edit_building_semantic_scene_candidate/New(datum/world_edit_building_semantic_room_field/_field, datum/world_edit_building_semantic_scene_rule/_rule)
	. = ..()
	field = _field
	rule = _rule
	room = _field?.room
