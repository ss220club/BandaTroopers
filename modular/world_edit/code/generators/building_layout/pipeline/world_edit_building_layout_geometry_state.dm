/datum/world_edit_building_layout_geometry_state
	var/list/footprint = list()
	var/list/boundary = list()
	var/list/interior = list()
	var/list/bounds = list()
	var/list/footprint_lookup = list()
	var/list/boundary_lookup = list()
	var/list/wall_lookup = list()
	var/list/floor_turfs = list()
	var/list/floor_lookup = list()
	var/list/door_turfs = list()
	var/list/door_dirs = list()
	var/list/window_turfs = list()
	var/list/reserved_lookup = list()
	var/list/zone_by_turf = list()
	var/list/zone_turfs = list()
	var/list/zone_focus_turfs = list()
	var/list/adjacent_wall_dirs_by_turf = list()
	var/list/solved_regions = list()
	var/list/solved_rooms = list()
	var/list/room_by_turf = list()
	var/list/corridor_turfs = list()
	var/list/corridor_lookup = list()
	var/list/primary_route_turfs = list()
	var/list/separator_lane_turfs = list()
	var/list/separator_lane_lookup = list()
	var/list/internal_wall_turfs = list()
	var/list/layout_room_plans = list()
	var/list/layout_route_opening_plans = list()
	var/list/layout_route_overlays = list()
	var/turf/center_turf
	var/turf/semantic_hub_turf
	var/turf/front_door_turf
	var/max_front_depth = 1
	var/max_lateral_abs = 1
	var/requested_direction = NORTH
	var/actual_entry_direction = NORTH
	var/direction_fallback_reason = ""
	var/entry_face_readable = FALSE
	var/footprint_hash = 0
	var/room_graph_hash = 0
	var/route_hash = 0
	var/wall_hash = 0
	var/structural_topology_signature = ""
	var/geometry_layout_hash = 0
	var/layout_hash = 0
