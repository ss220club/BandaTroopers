/datum/world_edit_building_archetype/hydroponics
	id = "hydroponics"
	layout_families = list("open_bay_perimeter", "split_wing", "axial_fallback")
	label = "Hydroponics"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "U")
	primary_zone = "grow_rows"
	hub_zone = "service_aisle"
	window_bias = 65
	detail_bias = 80

/datum/world_edit_building_archetype/hydroponics/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("service_aisle", "Service aisle", "route", 5, TRUE, TRUE, FALSE, list("service_aisle", "primary_lane", "work_cluster"), TRUE)
	add_zone("grow_rows", "Grow rows", "hub", 10, TRUE, TRUE, FALSE, list("grow_rows", "grow_strip", "focus_center"), TRUE)
	add_zone("work_counter", "Work counter", "service", 3, TRUE, TRUE, FALSE, list("work_counter", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("seed_storage", "Seed storage", "storage", 3, TRUE, TRUE, FALSE, list("seed_storage", "service_strip", "wall_anchor"), FALSE, "room")
	add_region("entry_front", "entry_buffer", 0, 18, -35, 35, 100)
	add_region("service_spine", "service_aisle", 0, 100, -18, 18, 95)
	add_region("work_back", "work_counter", 62, 100, -42, 42, 85)
	add_region("seed_side", "seed_storage", 35, 100, 45, 100, 80)
	add_region("grow_left", "grow_rows", 18, 92, -100, -22, 75)
	add_region("grow_right", "grow_rows", 18, 92, 22, 100, 75)
	add_region("grow_fill", "grow_rows", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "service_aisle")
	add_adjacency("service_aisle", "grow_rows")
	add_adjacency("service_aisle", "work_counter")
	add_adjacency("work_counter", "seed_storage")
	add_nested_room("service_aisle", "seed_storage", 9, 9, 1)
	add_signature_cluster("hydro_tray_rows", "major", "signature_hydro_rows", "hydro_tray", "hydro_tray", list("grow_rows", "hydro_row", "greenhouse_band"), 6, 10, FALSE, 0, 100, "hydro_tray_rows", 50)
	add_signature_cluster("service_counter", "major", "run", "table", "table", list("work_counter", "service_strip", "service_wall"), 2, 3, TRUE, 0, 95, "hydro_service_counter", 20)
	var/datum/world_edit_building_cluster_spec/seed_cabinet_spec = add_signature_cluster("seed_cabinets", "major", "run", "seed_storage", "seed_storage", list("seed_storage", "service_strip", "storage_wall"), 2, 3, FALSE, 0, 90, "seed_storage_wall", 20)
	seed_cabinet_spec.compact_substitute_id = "seed_cabinets_compact"
	var/datum/world_edit_building_cluster_spec/seed_cabinet_compact = add_signature_cluster("seed_cabinets_compact", "major", "run", "seed_storage", "seed_storage", list("seed_storage", "work_counter", "service_aisle", "grow_rows", "storage_wall", "wall_anchor"), 1, 2, FALSE, 0, 70, "seed_storage_wall", 0, FALSE)
	seed_cabinet_compact.compact_substitute_only = TRUE
	add_cluster("fertilizer_crates", "secondary", "staging_group", "crate", "crate", list("seed_storage", "service_aisle"), 1, 2, FALSE, 0, 60, FALSE)
	add_cluster("tool_rack", "secondary", "wall_object", "rack", "rack", list("work_counter", "seed_storage", "wall_anchor"), 1, 1, TRUE, 0, 55, FALSE)
	add_cluster("grower_chair", "detail", "object", "chair", "chair", list("work_counter", "service_aisle"), 1, 1, FALSE, 0, 35, FALSE)
	object_budgets = list("hydro_tray" = 12, "table" = 4, "chair" = 2, "cabinet" = 4, "rack" = 2, "crate" = 3)
	category_minimums = list("hydro_tray" = 6, "seed_storage" = 2)

/datum/world_edit_building_archetype/kitchen
	id = "kitchen"
	layout_families = list("nested_service", "split_wing", "hub_spoke", "axial_fallback")
	label = "Kitchen"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "U")
	primary_zone = "prep_core"
	hub_zone = "serving_edge"
	window_bias = 45
	detail_bias = 85

/datum/world_edit_building_archetype/kitchen/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("dining_front", "Dining front", "public", 6, TRUE, TRUE, FALSE, list("dining_front", "public_route", "social_focus"), TRUE)
	add_zone("serving_edge", "Serving edge", "choke", 3, TRUE, TRUE, FALSE, list("serving_edge", "counter_front", "barrier_line"), FALSE, "nook")
	add_zone("prep_core", "Prep core", "hub", 7, TRUE, TRUE, FALSE, list("prep_core", "work_cluster", "focus_center"), TRUE)
	add_zone("cooking_line", "Cooking line", "service", 4, TRUE, TRUE, FALSE, list("cooking_line", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("cold_storage", "Cold storage", "storage", 3, TRUE, TRUE, FALSE, list("cold_storage", "service_strip", "wall_anchor"), FALSE, "room")
	add_region("entry_front", "entry_buffer", 0, 16, -32, 32, 100)
	add_region("dining_front", "dining_front", 0, 42, -100, 100, 80)
	add_region("serving_band", "serving_edge", 34, 52, -100, 100, 100)
	add_region("cooking_back_left", "cooking_line", 48, 100, -100, -42, 90)
	add_region("cold_back_right", "cold_storage", 58, 100, 42, 100, 90)
	add_region("prep_core", "prep_core", 45, 100, -40, 40, 75)
	add_region("prep_fill", "prep_core", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "dining_front")
	add_adjacency("dining_front", "serving_edge")
	add_adjacency("serving_edge", "prep_core")
	add_adjacency("prep_core", "cooking_line")
	add_adjacency("prep_core", "cold_storage")
	add_nested_room("prep_core", "cold_storage", 9, 9, 1)
	add_signature_cluster("serving_counter", "major", "counter_line", "table", "table", list("serving_edge", "counter_front", "counter_line_turf"), 3, 4, FALSE, 0, 100, "serving_counter", 25)
	add_signature_cluster("prep_tables", "major", "table_cluster", "table", "table", list("prep_core", "work_cluster", "focus_center"), 1, 2, FALSE, 1, 95, "prep_surface", 15)
	add_signature_cluster("cooking_run", "major", "signature_cook_line", "table", "table", list("cooking_line", "service_wall", "machine_wall"), 4, 5, TRUE, 0, 90, "cook_line", 35)
	add_signature_cluster("cold_storage_wall", "major", "run", "fridge", "cold_storage", list("cold_storage", "cold_storage_wall", "storage_wall"), 2, 3, TRUE, 0, 85, "cold_storage", 20)
	var/datum/world_edit_building_cluster_spec/dining_table_spec = add_cluster("dining_tables", "secondary", "table_cluster", "table", "table", list("dining_front", "social_focus", "window_band"), 1, 2, FALSE, 3, 65, FALSE)
	dining_table_spec.compact_substitute_id = "dining_tables_compact"
	var/datum/world_edit_building_cluster_spec/dining_table_compact = add_cluster("dining_tables_compact", "secondary", "table_cluster", "table", "table", list("dining_front", "social_focus", "window_band"), 1, 1, FALSE, 1, 60, FALSE)
	dining_table_compact.compact_substitute_only = TRUE
	add_cluster("pantry_rack", "secondary", "wall_object", "rack", "rack", list("cold_storage", "wall_anchor"), 1, 1, TRUE, 0, 50, FALSE)
	add_cluster("supply_crates", "detail", "staging_group", "crate", "crate", list("cold_storage", "prep_core"), 1, 2, FALSE, 0, 40, FALSE)
	// The canonical six-room contract requires serving(3), prep(1), cooking(4)
	// and one explicit compact dining identity. Keep that authored demand inside
	// the budget instead of silently dropping the dining room's composition.
	object_budgets = list("table" = 9, "chair" = 8, "cabinet" = 4, "cold_storage" = 3, "console" = 1, "rack" = 2, "crate" = 2)
	category_minimums = list("table" = 4, "cold_storage" = 2)

/datum/world_edit_building_archetype/dormitory
	id = "dormitory"
	layout_families = list("open_bay_perimeter", "split_wing", "hub_spoke", "axial_fallback")
	label = "Dormitory"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "U")
	primary_zone = "sleep_bay"
	hub_zone = "central_aisle"
	window_bias = 40
	detail_bias = 75

/datum/world_edit_building_archetype/dormitory/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	var/datum/world_edit_building_zone_spec/central_aisle = add_zone("central_aisle", "Central aisle", "route", 5, TRUE, TRUE, FALSE, list("central_aisle", "primary_lane", "ready_area"), FALSE)
	central_aisle.circulation_kind = WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE
	central_aisle.circulation_owner_room_id = "sleep_bay"
	central_aisle.circulation_min_width = 2
	add_zone("sleep_bay", "Sleep bay", "private", 10, TRUE, TRUE, TRUE, list("sleep_bay", "privacy_zone", "wall_anchor"), FALSE, "nook")
	add_zone("locker_strip", "Locker strip", "storage", 4, TRUE, TRUE, FALSE, list("locker_strip", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("ready_area", "Ready area", "hub", 4, TRUE, TRUE, FALSE, list("ready_area", "social_focus", "work_cluster"), TRUE)
	add_region("entry_front", "entry_buffer", 0, 16, -35, 35, 100)
	add_region("central_aisle", "central_aisle", 0, 100, -20, 20, 95)
	add_region("ready_front", "ready_area", 18, 46, -52, 52, 85)
	add_region("locker_back", "locker_strip", 55, 100, 42, 100, 90)
	add_region("sleep_left", "sleep_bay", 24, 100, -100, -24, 80)
	add_region("sleep_right", "sleep_bay", 24, 76, 24, 100, 75)
	add_region("sleep_fill", "sleep_bay", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "central_aisle")
	add_adjacency("central_aisle", "ready_area")
	add_adjacency("central_aisle", "sleep_bay")
	add_adjacency("sleep_bay", "locker_strip")
	add_nested_room("sleep_bay", "locker_strip", 9, 9, 1)
	add_signature_cluster("bed_wall_runs", "major", "signature_bed_rows", "bed", "bed", list("sleep_bay", "bunk_row", "bed_wall"), 4, 7, FALSE, 0, 100, "bunk_rows", 50)
	var/datum/world_edit_building_cluster_spec/locker_wall_spec = add_signature_cluster("locker_wall", "major", "run", "cabinet", "cabinet", list("locker_strip", "service_strip", "storage_wall"), 3, 4, FALSE, 0, 95, "locker_wall", 25)
	locker_wall_spec.compact_substitute_id = "locker_wall_compact"
	var/datum/world_edit_building_cluster_spec/locker_wall_compact = add_signature_cluster("locker_wall_compact", "major", "run", "cabinet", "cabinet", list("locker_strip", "storage_wall", "sleep_bay", "ready_area"), 1, 3, FALSE, 0, 75, "locker_wall", 0, FALSE)
	locker_wall_compact.compact_substitute_only = TRUE
	add_signature_cluster("ready_table", "major", "table_cluster", "table", "table", list("ready_area", "social_focus"), 1, 1, FALSE, 2, 60, "ready_area", 15)
	add_cluster("personal_rack", "secondary", "wall_object", "rack", "rack", list("locker_strip", "sleep_bay", "wall_anchor"), 1, 1, TRUE, 0, 50, FALSE)
	add_cluster("footlocker_crates", "detail", "staging_group", "crate", "crate", list("sleep_bay", "locker_strip"), 1, 2, FALSE, 0, 35, FALSE)
	object_budgets = list("bed" = 7, "table" = 2, "chair" = 4, "cabinet" = 5, "rack" = 2, "crate" = 2)
	category_minimums = list("bed" = 4, "cabinet" = 2)

/datum/world_edit_building_archetype/office
	id = "office"
	layout_families = list("hub_spoke", "split_wing", "nested_service", "axial_fallback")
	label = "Office"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L")
	primary_zone = "desk_core"
	hub_zone = "desk_core"
	window_bias = 60
	detail_bias = 75

/datum/world_edit_building_archetype/office/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("visitor_side", "Visitor side", "public", 3, TRUE, TRUE, FALSE, list("visitor_side", "public_route", "social_focus"), TRUE)
	add_zone("desk_core", "Desk core", "hub", 5, TRUE, TRUE, FALSE, list("desk_core", "work_cluster", "focus_center"), TRUE)
	add_zone("filing_wall", "Filing wall", "storage", 3, TRUE, TRUE, FALSE, list("filing_wall", "service_strip", "wall_anchor"), FALSE, "nook")
	add_optional_zone("private_nook", "Private nook", "private", 2, 70, TRUE, TRUE, list("private_nook", "privacy_zone", "wall_anchor"), FALSE, "room", "private", 38)
	add_optional_zone("records_nook", "Records nook", "storage", 2, 45, TRUE, FALSE, list("records_nook", "filing_wall_anchor", "service_strip", "wall_anchor"), FALSE, "nook", "secure", 42)
	add_region("entry_front", "entry_buffer", 0, 18, -35, 35, 100)
	add_region("visitor_front", "visitor_side", 10, 42, -100, 100, 80)
	add_region("filing_side", "filing_wall", 30, 100, 45, 100, 90)
	add_region("private_back", "private_nook", 62, 100, -100, -45, 75)
	add_region("records_back", "records_nook", 58, 100, 38, 100, 68)
	add_region("desk_core", "desk_core", 30, 86, -42, 42, 80)
	add_region("desk_fill", "desk_core", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "visitor_side")
	add_adjacency("visitor_side", "desk_core")
	add_adjacency("desk_core", "filing_wall")
	add_adjacency("desk_core", "private_nook", FALSE)
	add_adjacency("filing_wall", "records_nook", FALSE)
	add_nested_room("desk_core", "private_nook", 8, 8, 1)
	add_signature_cluster("primary_desk_suite", "major", "table_cluster", "table", "table", list("desk_core", "desk_anchor", "work_cluster", "focus_center"), 1, 1, FALSE, 1, 100, "desk_suite", 45)
	add_signature_cluster("filing_cabinets", "major", "run", "filing", "cabinet", list("filing_wall", "filing_wall_anchor", "storage_wall"), 2, 3, TRUE, 0, 90, "filing_wall", 25)
	add_cluster("office_console", "secondary", "wall_object", "console", "console", list("desk_core", "wall_anchor"), 1, 1, TRUE, 0, 70, FALSE)
	add_cluster("visitor_chairs", "secondary", "run", "chair", "chair", list("visitor_side", "public_route"), 2, 2, FALSE, 0, 55, FALSE)
	add_cluster("side_storage", "detail", "wall_object", "rack", "rack", list("private_nook", "wall_anchor"), 1, 1, TRUE, 0, 35, FALSE, "private_nook", "office_private_storage_chunk")
	add_cluster("records_terminal", "secondary", "wall_object", "console", "console", list("records_nook", "filing_wall_anchor", "wall_anchor"), 1, 1, TRUE, 0, 45, FALSE, "records_nook", "office_records_terminal_chunk")
	object_budgets = list("table" = 2, "chair" = 5, "cabinet" = 4, "rack" = 2, "console" = 2)
	category_minimums = list("table" = 1, "cabinet" = 2)

/datum/world_edit_building_archetype/security
	id = "security"
	layout_families = list("secure_core", "hub_spoke", "split_wing", "axial_fallback")
	label = "Security"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "WEDGE")
	primary_zone = "secure_work"
	hub_zone = "desk_line"
	window_bias = 25
	detail_bias = 80

/datum/world_edit_building_archetype/security/build_definition()
	add_zone("public_lobby", "Public lobby", "public", 3, TRUE, TRUE, FALSE, list("public_lobby", "public_route", "entry_buffer"), TRUE)
	add_zone("desk_line", "Desk line", "choke", 3, TRUE, TRUE, FALSE, list("desk_line", "counter_front", "barrier_line"), FALSE, "nook")
	add_zone("secure_work", "Secure work", "secure", 5, TRUE, TRUE, FALSE, list("secure_work", "counter_back", "work_cluster"), FALSE, "nook")
	add_zone("locker_storage", "Locker storage", "storage", 4, TRUE, TRUE, FALSE, list("locker_storage", "service_strip", "wall_anchor"), FALSE, "room")
	add_optional_zone("holding_nook", "Holding nook", "private", 2, 80, TRUE, TRUE, list("holding_nook", "privacy_zone", "wall_anchor"), FALSE, "room", "private", 42)
	add_optional_zone("armory_nook", "Armory nook", "secure", 3, 65, TRUE, TRUE, list("armory_nook", "secure_storage", "wall_anchor"), FALSE, "room", "secure", 44)
	add_optional_zone("evidence_nook", "Evidence nook", "storage", 2, 50, TRUE, FALSE, list("evidence_nook", "storage_wall", "wall_anchor"), FALSE, "nook", "secure", 40)
	add_region("public_front", "public_lobby", 0, 30, -100, 100, 95)
	add_region("desk_band", "desk_line", 28, 48, -100, 100, 100)
	add_region("locker_side", "locker_storage", 48, 100, 42, 100, 88)
	add_region("holding_back_left", "holding_nook", 62, 100, -100, -45, 70)
	add_region("armory_back_right", "armory_nook", 58, 100, 45, 100, 76)
	add_region("evidence_mid_right", "evidence_nook", 42, 82, 35, 100, 68)
	add_region("secure_back", "secure_work", 45, 100, -42, 42, 80)
	add_region("secure_fill", "secure_work", 0, 100, -100, 100, 1)
	add_adjacency("public_lobby", "desk_line")
	add_adjacency("desk_line", "secure_work")
	add_adjacency("secure_work", "locker_storage")
	add_adjacency("secure_work", "holding_nook", FALSE)
	add_adjacency("secure_work", "armory_nook", FALSE)
	add_adjacency("secure_work", "evidence_nook", FALSE)
	add_nested_room("secure_work", "holding_nook", 8, 8, 1)
	add_signature_cluster("security_control_counter", "major", "signature_security_counter", "table", "table", list("desk_line", "counter_front", "counter_line_turf", "secure_side"), 4, 6, FALSE, 0, 100, "security_counter_control", 50)
	add_signature_cluster("locker_run", "major", "run", "cabinet", "cabinet", list("locker_storage", "service_strip", "storage_wall", "secure_side"), 2, 3, TRUE, 0, 90, "security_locker_wall", 20)
	add_signature_cluster("holding_bed", "major", "wall_object", "bed", "bed", list("holding_nook", "privacy_zone", "bed_wall"), 1, 1, TRUE, 0, 75, "holding_cell", 15, FALSE, "holding_nook", "holding_cell_chunk")
	add_cluster("evidence_rack", "secondary", "wall_object", "rack", "rack", list("locker_storage", "wall_anchor"), 1, 1, TRUE, 0, 65, FALSE)
	add_cluster("armory_rack", "secondary", "wall_object", "weapon_rack", "weapon_rack", list("armory_nook", "secure_storage", "wall_anchor"), 1, 2, TRUE, 0, 65, FALSE, "armory_nook", "armory_rack_chunk")
	add_cluster("evidence_storage", "secondary", "wall_object", "cabinet", "cabinet", list("evidence_nook", "storage_wall", "wall_anchor"), 1, 2, TRUE, 0, 55, FALSE, "evidence_nook", "evidence_storage_chunk")
	add_signature_cluster("visitor_chair", "major", "run", "chair", "chair", list("public_lobby", "public_route"), 3, 3, FALSE, 0, 50, "visitor_seating", 10)
	add_cluster("barrier_line", "detail", "run", "barrier", "barrier", list("public_lobby", "barrier_line"), 2, 3, FALSE, 0, 35, FALSE)
	object_budgets = list("table" = 4, "chair" = 3, "cabinet" = 5, "rack" = 2, "console" = 1, "barrier" = 3, "bed" = 1, "weapon_rack" = 2)
	category_minimums = list("table" = 2, "console" = 1, "cabinet" = 2)

/datum/world_edit_building_archetype/chapel
	id = "chapel"
	layout_families = list("hub_spoke", "split_wing", "axial_fallback")
	label = "Chapel"
	suggested_shell_preset = "neutral"
	footprint_families = list("RECT", "T", "RING", "NESTED")
	primary_zone = "sanctum"
	hub_zone = "nave_axis"
	window_bias = 55
	detail_bias = 70

/datum/world_edit_building_archetype/chapel/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("nave_axis", "Nave axis", "route", 6, TRUE, TRUE, FALSE, list("nave_axis", "primary_lane", "social_focus"), TRUE)
	add_zone("seating_rows", "Seating rows", "public", 6, TRUE, TRUE, FALSE, list("seating_rows", "social_focus"), TRUE)
	add_zone("sanctum", "Sanctum", "hub", 4, TRUE, TRUE, TRUE, list("sanctum", "focus_center", "semantic_hub"), TRUE)
	add_zone("reliquary", "Reliquary", "service", 2, FALSE, TRUE, TRUE, list("reliquary", "service_strip", "wall_anchor"), FALSE, "nook")
	add_region("entry_front", "entry_buffer", 0, 16, -35, 35, 100)
	add_region("nave_axis", "nave_axis", 0, 100, -18, 18, 95)
	add_region("seating_left", "seating_rows", 18, 66, -100, -22, 80)
	add_region("seating_right", "seating_rows", 18, 66, 22, 100, 80)
	add_region("reliquary_side", "reliquary", 62, 100, 45, 100, 70)
	add_region("sanctum_back", "sanctum", 62, 100, -42, 42, 100)
	add_region("sanctum_fill", "sanctum", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "nave_axis")
	add_adjacency("nave_axis", "seating_rows")
	add_adjacency("nave_axis", "sanctum")
	add_adjacency("sanctum", "reliquary", FALSE)
	add_nested_room("sanctum", "reliquary", 8, 8, 1)
	add_signature_cluster("altar_focus", "major", "table_cluster", "table", "table", list("sanctum", "focus_center", "semantic_hub"), 1, 1, FALSE, 0, 100, "chapel_altar", 35)
	add_signature_cluster("seating_left_rows", "major", "run", "chair", "chair", list("seating_rows", "social_focus"), 3, 4, FALSE, 0, 90, "chapel_seating", 25)
	add_signature_cluster("seating_right_rows", "major", "run", "chair", "chair", list("seating_rows", "social_focus"), 3, 4, FALSE, 0, 85, "chapel_seating", 25)
	add_cluster("reliquary_cabinet", "secondary", "wall_object", "cabinet", "cabinet", list("reliquary", "wall_anchor"), 1, 1, TRUE, 0, 55, FALSE)
	add_cluster("side_table", "secondary", "table_cluster", "table", "table", list("reliquary", "sanctum"), 1, 1, FALSE, 0, 45, FALSE)
	add_cluster("processional_barriers", "detail", "run", "barrier", "barrier", list("nave_axis", "barrier_line"), 2, 2, FALSE, 0, 35, FALSE)
	object_budgets = list("table" = 3, "chair" = 8, "cabinet" = 2, "barrier" = 2)
	category_minimums = list("table" = 1, "chair" = 4)

/datum/world_edit_building_archetype/ritual_chamber
	id = "ritual_chamber"
	layout_families = list("secure_core", "nested_service", "hub_spoke", "axial_fallback")
	label = "Ritual chamber"
	suggested_shell_preset = "covenant"
	footprint_families = list("RECT", "WEDGE", "RING", "NESTED")
	primary_zone = "ritual_focus"
	hub_zone = "ritual_axis"
	window_bias = 20
	detail_bias = 90
	nested_outer_zone = "ritual_focus"
	nested_inner_zone = "inner_sanctum"
	nested_min_width = 9
	nested_min_height = 9

/datum/world_edit_building_archetype/ritual_chamber/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), FALSE)
	add_zone("ritual_axis", "Ritual axis", "route", 6, TRUE, TRUE, FALSE, list("ritual_axis", "primary_lane", "barrier_line"), FALSE)
	add_zone("outer_ring", "Outer ring", "public", 6, TRUE, TRUE, FALSE, list("outer_ring", "social_focus", "focus_ring"), FALSE)
	add_zone("ritual_focus", "Ritual focus", "hub", 8, TRUE, TRUE, TRUE, list("ritual_focus", "focus_center", "semantic_hub"), FALSE)
	add_zone("reliquary", "Reliquary", "service", 3, TRUE, TRUE, TRUE, list("reliquary", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("inner_sanctum", "Inner sanctum", "nested", 1, FALSE, TRUE, TRUE, list("inner_sanctum", "privacy_zone", "work_cluster"), FALSE)
	add_region("entry_front", "entry_buffer", 0, 16, -35, 35, 100)
	add_region("ritual_axis", "ritual_axis", 0, 100, -18, 18, 95)
	add_region("outer_left", "outer_ring", 18, 76, -100, -22, 75)
	add_region("outer_right", "outer_ring", 18, 76, 22, 100, 75)
	add_region("reliquary_back_right", "reliquary", 58, 100, 45, 100, 85)
	add_region("ritual_focus_back", "ritual_focus", 50, 100, -45, 45, 100)
	add_region("ritual_fill", "ritual_focus", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "ritual_axis")
	add_adjacency("ritual_axis", "outer_ring")
	add_adjacency("ritual_axis", "ritual_focus")
	add_adjacency("ritual_focus", "reliquary")
	add_nested_room("ritual_focus", "inner_sanctum", 9, 9, 1)
	add_signature_cluster("ritual_centerpiece", "major", "object", "table", "table", list("ritual_focus", "focus_center", "semantic_hub"), 1, 1, FALSE, 0, 100, "ritual_centerpiece", 35)
	add_signature_cluster("axis_barriers", "major", "run", "barrier", "barrier", list("ritual_axis", "barrier_line"), 3, 4, FALSE, 0, 95, "ritual_axis_barriers", 25)
	add_signature_cluster("reliquary_wall", "major", "run", "cabinet", "cabinet", list("reliquary", "service_strip", "wall_anchor"), 2, 2, TRUE, 0, 90, "ritual_reliquary_wall", 25)
	add_cluster("outer_observers", "secondary", "run", "chair", "chair", list("outer_ring", "social_focus"), 2, 4, FALSE, 0, 70, FALSE)
	add_cluster("focus_console", "secondary", "wall_object", "console", "console", list("ritual_focus", "inner_sanctum", "wall_anchor"), 1, 1, TRUE, 0, 60, FALSE)
	add_cluster("inner_focus", "detail", "object", "table", "table", list("inner_sanctum", "privacy_zone"), 1, 1, FALSE, 0, 45, FALSE)
	object_budgets = list("table" = 3, "chair" = 5, "cabinet" = 3, "console" = 1, "barrier" = 4)
	category_minimums = list("table" = 1, "barrier" = 2, "cabinet" = 1)

/datum/world_edit_building_archetype/compound_colony
	id = "compound_colony"
	layout_families = list("compound_cells", "hub_spoke", "split_wing", "axial_fallback")
	label = "Compound complex"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "U", "RING", "NESTED", "COMPOUND")
	primary_zone = "central_court"
	hub_zone = "central_court"
	window_bias = 45
	detail_bias = 85
	nested_outer_zone = "central_court"
	nested_inner_zone = "command_nook"
	nested_min_width = 11
	nested_min_height = 11

/datum/world_edit_building_archetype/compound_colony/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("central_court", "Central court", "hub", 8, TRUE, TRUE, FALSE, list("central_court", "focus_center", "social_focus"), TRUE)
	add_zone("living_wing", "Living wing", "private", 6, TRUE, TRUE, TRUE, list("living_wing", "privacy_zone", "wall_anchor"), FALSE, "room")
	add_zone("work_bay", "Work bay", "hub", 6, TRUE, TRUE, FALSE, list("work_bay", "work_cluster", "service_strip"), TRUE)
	add_zone("storage_service", "Storage service", "storage", 4, TRUE, TRUE, FALSE, list("storage_service", "service_strip", "wall_anchor"), FALSE)
	add_optional_zone("clinic_nook", "Clinic nook", "service", 3, 65, TRUE, TRUE, list("clinic_nook", "work_cluster", "wall_anchor"), FALSE, "nook", "secure", 54)
	add_optional_zone("command_nook", "Command nook", "nested", 1, 70, TRUE, TRUE, list("command_nook", "privacy_zone", "work_cluster"), FALSE, "room", "private", 58)
	add_optional_zone("comms_nook", "Comms nook", "secure", 2, 45, TRUE, FALSE, list("comms_nook", "service_strip", "wall_anchor"), FALSE, "nook", "secure", 56)
	add_region("entry_front", "entry_buffer", 0, 16, -35, 35, 100)
	add_region("central_court_core", "central_court", 18, 66, -42, 42, 90)
	add_region("living_left", "living_wing", 40, 100, -100, -45, 85)
	add_region("work_right", "work_bay", 25, 88, 42, 100, 85)
	add_region("storage_back", "storage_service", 66, 100, -20, 100, 80)
	add_region("clinic_back_left", "clinic_nook", 66, 100, -100, -42, 65)
	add_region("comms_back_right", "comms_nook", 62, 100, 42, 100, 62)
	add_region("central_fill", "central_court", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "central_court")
	add_adjacency("central_court", "living_wing")
	add_adjacency("central_court", "work_bay")
	add_adjacency("work_bay", "storage_service")
	add_adjacency("central_court", "clinic_nook", FALSE)
	add_adjacency("work_bay", "comms_nook", FALSE)
	add_nested_room("central_court", "command_nook", 11, 11, 1)
	add_signature_cluster("central_table", "major", "table_cluster", "table", "table", list("central_court", "social_focus", "focus_center"), 1, 1, FALSE, 3, 100, "compound_central_table", 25)
	add_signature_cluster("living_beds", "major", "run", "bed", "bed", list("living_wing", "privacy_zone", "wall_anchor"), 2, 3, TRUE, 0, 95, "compound_living_beds", 25)
	add_signature_cluster("workbench_run", "major", "run", "table", "table", list("work_bay", "service_strip", "wall_anchor"), 2, 3, TRUE, 0, 90, "compound_workbench", 25)
	add_signature_cluster("storage_racks", "major", "run", "rack", "rack", list("storage_service", "service_strip", "wall_anchor"), 2, 3, TRUE, 0, 85, "compound_storage_racks", 25)
	add_cluster("personal_storage", "secondary", "run", "cabinet", "cabinet", list("living_wing", "storage_service", "wall_anchor"), 2, 3, TRUE, 0, 65, FALSE)
	add_cluster("clinic_bed", "secondary", "wall_object", "medical_bed", "medical_bed", list("clinic_nook", "work_cluster", "wall_anchor"), 1, 1, TRUE, 0, 55, FALSE, "clinic_nook", "clinic_bed_chunk")
	add_cluster("command_console", "secondary", "wall_object", "console", "console", list("command_nook", "wall_anchor"), 1, 1, TRUE, 0, 50, FALSE, "command_nook", "command_console_chunk")
	add_cluster("comms_console", "secondary", "wall_object", "security_console", "console", list("comms_nook", "service_strip", "wall_anchor"), 1, 1, TRUE, 0, 45, FALSE, "comms_nook", "comms_console_chunk")
	add_cluster("supply_crates", "detail", "staging_group", "crate", "crate", list("storage_service", "work_bay"), 1, 2, FALSE, 0, 40, FALSE)
	object_budgets = list("bed" = 4, "table" = 5, "chair" = 5, "cabinet" = 4, "rack" = 4, "crate" = 3, "console" = 2, "medical_bed" = 1)
	category_minimums = list("bed" = 2, "table" = 2, "rack" = 2)

/datum/world_edit_building_archetype/engineering
	id = "engineering"
	layout_families = list("compound_cells", "open_bay_perimeter", "split_wing", "axial_fallback")
	label = "Engineering"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "U", "COMPOUND")
	primary_zone = "machine_bay"
	hub_zone = "service_spine"
	window_bias = 20
	detail_bias = 85

/datum/world_edit_building_archetype/engineering/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("service_spine", "Service spine", "route", 5, TRUE, TRUE, FALSE, list("service_spine", "primary_lane", "work_cluster"), FALSE)
	add_zone("machine_bay", "Machine bay", "hub", 8, TRUE, TRUE, FALSE, list("machine_bay", "engineering_bay", "machine_wall", "focus_center"), TRUE)
	add_zone("power_control", "Power/control wall", "service", 4, TRUE, TRUE, FALSE, list("power_control", "engineering_wall", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("parts_storage", "Parts storage", "storage", 4, TRUE, TRUE, FALSE, list("parts_storage", "storage_wall", "service_strip", "wall_anchor"), FALSE, "room")
	add_optional_zone("generator_nook", "Generator nook", "secure", 3, 60, TRUE, FALSE, list("generator_nook", "engineering_wall", "secure_storage", "wall_anchor"), FALSE, "room", "secure", 48)
	add_region("entry_front", "entry_buffer", 0, 16, -35, 35, 100)
	add_region("service_spine", "service_spine", 0, 100, -18, 18, 95)
	add_region("control_left", "power_control", 22, 92, -100, -44, 88)
	add_region("parts_right", "parts_storage", 42, 100, 44, 100, 82)
	add_region("generator_back", "generator_nook", 66, 100, -38, 38, 72)
	add_region("machine_core", "machine_bay", 24, 88, -42, 42, 85)
	add_region("machine_fill", "machine_bay", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "service_spine")
	add_adjacency("service_spine", "machine_bay")
	add_adjacency("machine_bay", "power_control")
	add_adjacency("machine_bay", "parts_storage")
	add_adjacency("machine_bay", "generator_nook", FALSE)
	add_nested_room("machine_bay", "generator_nook", 9, 9, 1)
	add_signature_cluster("engineering_service_wall", "major", "signature_engineering_bay", "engineering_machine", "engineering_machine", list("machine_bay", "engineering_bay", "engineering_wall", "machine_wall"), 4, 6, FALSE, 0, 100, "engineering_service_wall", 45, TRUE, null, "engineering_service_chunk")
	add_signature_cluster("power_console_wall", "major", "run", "power_console", "console", list("power_control", "engineering_wall", "service_strip", "wall_anchor"), 2, 3, TRUE, 0, 95, "engineering_controls", 25)
	add_signature_cluster("parts_racks", "major", "signature_rack_aisles", "rack", "rack", list("parts_storage", "rack_aisle", "storage_wall"), 3, 5, FALSE, 0, 90, "engineering_parts_racks", 25)
	add_signature_cluster("generator_unit", "major", "run", "engineering_machine", "engineering_machine", list("generator_nook", "engineering_wall", "wall_anchor"), 2, 2, TRUE, 0, 88, "engineering_generator_unit", 20)
	add_cluster("cable_crates", "secondary", "staging_group", "crate", "crate", list("parts_storage", "service_spine"), 2, 3, FALSE, 0, 65, FALSE)
	add_cluster("operator_chair", "detail", "object", "chair", "chair", list("power_control", "service_spine"), 1, 1, FALSE, 0, 35, FALSE)
	object_budgets = list("engineering_machine" = 7, "console" = 3, "table" = 3, "rack" = 5, "crate" = 4, "chair" = 2, "cabinet" = 2)
	category_minimums = list("engineering_machine" = 2, "console" = 1, "rack" = 2)

/datum/world_edit_building_archetype/laboratory
	id = "laboratory"
	layout_families = list("secure_core", "nested_service", "split_wing", "axial_fallback")
	label = "Laboratory"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "NESTED")
	primary_zone = "analysis_core"
	hub_zone = "clean_spine"
	window_bias = 30
	detail_bias = 85

/datum/world_edit_building_archetype/laboratory/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("clean_spine", "Clean spine", "route", 4, TRUE, TRUE, FALSE, list("clean_spine", "primary_lane", "work_cluster"), TRUE)
	add_zone("analysis_core", "Analysis core", "hub", 7, TRUE, TRUE, FALSE, list("analysis_core", "lab_bench", "focus_center"), TRUE)
	add_zone("lab_wall", "Lab bench wall", "service", 4, TRUE, TRUE, FALSE, list("lab_wall", "lab_wall", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("specimen_storage", "Specimen storage", "storage", 3, TRUE, TRUE, TRUE, list("specimen_storage", "sample_storage", "storage_wall", "wall_anchor"), FALSE, "room", "secure")
	add_optional_zone("containment_nook", "Containment nook", "private", 3, 55, TRUE, TRUE, list("containment_nook", "privacy_zone", "lab_wall", "wall_anchor"), FALSE, "room", "private", 48)
	add_region("entry_front", "entry_buffer", 0, 16, -35, 35, 100)
	add_region("clean_spine", "clean_spine", 0, 100, -18, 18, 95)
	add_region("lab_left", "lab_wall", 24, 92, -100, -42, 90)
	add_region("specimen_right", "specimen_storage", 44, 100, 42, 100, 88)
	add_region("containment_back", "containment_nook", 64, 100, -38, 38, 76)
	add_region("analysis_core", "analysis_core", 26, 88, -40, 40, 85)
	add_region("analysis_fill", "analysis_core", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "clean_spine")
	add_adjacency("clean_spine", "analysis_core")
	add_adjacency("analysis_core", "lab_wall")
	add_adjacency("analysis_core", "specimen_storage")
	add_adjacency("analysis_core", "containment_nook", FALSE)
	add_nested_room("analysis_core", "containment_nook", 9, 9, 1)
	add_signature_cluster("lab_bench_signature", "major", "signature_lab_bench", "lab_machine", "lab_machine", list("lab_wall", "lab_bench", "lab_wall", "service_strip"), 4, 6, TRUE, 0, 100, "lab_bench_signature", 45, TRUE, null, "lab_bench_chunk")
	add_signature_cluster("sample_storage_wall", "major", "run", "sample_storage", "sample_storage", list("specimen_storage", "storage_wall", "wall_anchor"), 2, 3, TRUE, 0, 95, "sample_storage_wall", 25)
	add_signature_cluster("analysis_table", "major", "table_cluster", "table", "table", list("analysis_core", "lab_bench", "focus_center"), 1, 1, FALSE, 1, 80, "analysis_surface", 20)
	add_cluster("research_console", "secondary", "wall_object", "console", "console", list("analysis_core", "lab_wall", "wall_anchor"), 1, 1, TRUE, 0, 65, FALSE)
	add_cluster("specimen_crates", "detail", "staging_group", "crate", "crate", list("specimen_storage", "clean_spine"), 1, 2, FALSE, 0, 40, FALSE)
	object_budgets = list("lab_machine" = 4, "sample_storage" = 4, "table" = 3, "chair" = 3, "console" = 2, "crate" = 2, "cabinet" = 2)
	category_minimums = list("lab_machine" = 2, "sample_storage" = 2, "table" = 1)
