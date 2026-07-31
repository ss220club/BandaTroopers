/datum/world_edit_generator/building_layout/proc/build_building_semantic_scene_rules_for_room(datum/world_edit_building_layout_state/state, datum/world_edit_building_semantic_room_field/field, list/global_scene_counts)
	var/list/rules = list()
	if(!istype(state) || !istype(field) || !istype(field.room))
		return rules
	var/room_class = resolve_building_semantic_room_class(state, field.room)
	if(room_class in list(WORLD_EDIT_BUILDING_SEMANTIC_ROOM_ROUTE, WORLD_EDIT_BUILDING_SEMANTIC_ROOM_NONE))
		return rules

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SANITATION)
		var/datum/world_edit_building_semantic_scene_rule/sanitation = new("sanitation_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_SANITATION, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 950)
		sanitation.add_member("toilet", "sanitation", "sanitation_core", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, TRUE, FALSE)
		sanitation.add_member("sink", "sanitation", "sanitation_core", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, FALSE, FALSE)
		rules += sanitation

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SLEEPING)
		var/datum/world_edit_building_semantic_scene_rule/sleeping = new("sleeping_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_BEDROOM, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 920)
		sleeping.add_member("bed", "bed", "sleeping_focal", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, TRUE, FALSE)
		if(field.area >= 10)
			sleeping.add_member("cabinet", "cabinet", "sleeping_storage", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, FALSE, FALSE)
		rules += sleeping
		if(field.area >= 28)
			var/datum/world_edit_building_semantic_scene_rule/sleeping_storage = new("sleeping_secondary_storage", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_BEDROOM, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_SECONDARY, FALSE, FALSE, 520)
			sleeping_storage.add_member("cabinet", "cabinet", "sleeping_storage", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN, FALSE, FALSE)
			rules += sleeping_storage

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_STORAGE)
		var/storage_slot = building_semantic_storage_slot_for_state(state)
		var/storage_category = building_semantic_storage_category_for_state(state)
		var/datum/world_edit_building_semantic_scene_rule/storage = new("storage_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_STORAGE, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 880)
		storage.add_member(storage_slot, storage_category, "storage_run", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN, TRUE, FALSE)
		if(field.area >= 10)
			storage.add_member(storage_slot, storage_category, "storage_run", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN, FALSE, FALSE)
		rules += storage
		if(field.area >= 14)
			var/datum/world_edit_building_semantic_scene_rule/storage_detail = new("storage_crate_detail", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_STORAGE, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_DETAIL, FALSE, FALSE, 430)
			storage_detail.add_member("crate", "crate", "storage_detail", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_FREE_NEAR, FALSE, FALSE)
			rules += storage_detail

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_UTILITY)
		var/datum/world_edit_building_semantic_scene_rule/utility = new("utility_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_STORAGE, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 860)
		utility.add_member(building_semantic_storage_slot_for_state(state), building_semantic_storage_category_for_state(state), "utility_storage", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN, TRUE, FALSE)
		utility.add_member("console", "console", "utility_control", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, FALSE, FALSE)
		rules += utility
		if(field.area >= 14)
			var/datum/world_edit_building_semantic_scene_rule/utility_detail = new("utility_crate_detail", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_STORAGE, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_DETAIL, FALSE, FALSE, 390)
			utility_detail.add_member("crate", "crate", "utility_detail", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_FREE_NEAR, FALSE, FALSE)
			rules += utility_detail

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_WORK)
		var/datum/world_edit_building_semantic_scene_rule/work = new("work_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_WORK, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 840)
		work.add_member("table", "table", "work_surface", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ANCHOR, TRUE, FALSE)
		work.add_member(building_semantic_work_secondary_slot_for_state(state), building_semantic_work_secondary_category_for_state(state), "work_support", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, FALSE, FALSE)
		if(field.area >= 12)
			work.add_member("chair", "chair", "work_seat", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ADJACENT, FALSE, FALSE, FALSE, TRUE)
		rules += work
		if(field.area >= 18)
			var/datum/world_edit_building_semantic_scene_rule/work_secondary = new("work_secondary_console", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_WORK, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_SECONDARY, FALSE, FALSE, 470)
			work_secondary.add_member("console", "console", "work_support", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, FALSE, FALSE)
			rules += work_secondary

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_HYDRO)
		var/datum/world_edit_building_semantic_scene_rule/hydro = new("hydro_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_HYDRO, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 830)
		hydro.add_member("hydro_tray", "hydro_tray", "grow_core", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_CENTER_RING, TRUE, FALSE)
		if(field.area >= 12)
			hydro.add_member("seed_storage", "seed_storage", "grow_storage", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_NEAR, FALSE, FALSE)
		rules += hydro

	if(room_class == WORLD_EDIT_BUILDING_SEMANTIC_ROOM_COMMON)
		var/public_focal_count = round(text2num("[global_scene_counts["public_focal"]]") || 0)
		if(public_focal_count <= 0)
			var/datum/world_edit_building_semantic_scene_rule/common = new("common_dining_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_DINING, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 900, "public_focal", 1)
			common.add_member("table", "table", "dining_focal", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_ANCHOR, TRUE, FALSE, TRUE, TRUE)
			var/chair_count = field.area >= 20 ? 4 : 2
			for(var/i in 1 to chair_count)
				common.add_relative_member("chair", "chair", "dining_focal", 1, 0, FALSE, FALSE, TRUE, TRUE, list(NORTH, EAST, SOUTH, WEST))
			rules += common
		else
			var/datum/world_edit_building_semantic_scene_rule/common_identity = new("common_support_primary", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_LIVING, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_PRIMARY, TRUE, TRUE, 650)
			common_identity.add_member("cabinet", "cabinet", "common_side", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN, TRUE, FALSE)
			rules += common_identity
		var/datum/world_edit_building_semantic_scene_rule/common_side = new("common_side_surface", WORLD_EDIT_BUILDING_SEMANTIC_SCENE_LIVING, WORLD_EDIT_BUILDING_SEMANTIC_PHASE_SECONDARY, FALSE, FALSE, 620)
		common_side.add_member("cabinet", "cabinet", "common_side", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_WALL_RUN, FALSE, FALSE)
		if(field.area >= 16)
			common_side.add_member("chair", "chair", "common_lounge", WORLD_EDIT_BUILDING_SEMANTIC_PLACE_CENTER_RING, FALSE, FALSE, FALSE, TRUE)
		rules += common_side

	return rules

/datum/world_edit_generator/building_layout/proc/resolve_building_semantic_room_class(datum/world_edit_building_layout_state/state, datum/world_edit_building_room/room)
	if(!istype(room))
		return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_NONE
	var/program_id = lowertext("[state?.archetype?.id || ""]")
	var/role = lowertext("[room.role]")
	var/zone_id = lowertext("[room.zone_id]")
	var/datum/world_edit_building_zone_spec/zone_spec = state?.semantic_plan?.get_zone_spec(room.zone_id)
	var/zone_role = lowertext("[zone_spec?.role || ""]")
	var/list/tokens = list(role, zone_id, zone_role)
	for(var/token as anything in tokens)
		if(token in list("route", "corridor", "entry_buffer", "hub"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_ROUTE
		if(token in list("entry_common", "dining", "common", "public", "lobby", "reception", "ready_area", "central_court"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_COMMON
		if(token in list("sleeping", "sleep", "sleep_bay", "living_wing", "private", "dorm", "bunk"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SLEEPING
		if(token in list("sanitation", "toilet", "bath", "washroom"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SANITATION
		if(token in list("grow", "grow_rows", "hydro", "hydroponics"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_HYDRO
		if(token in list("work", "work_bay", "work_counter", "machine_bay", "desk_core", "secure_work", "analysis_core", "prep_core", "lab", "engineering"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_WORK
		if(token in list("storage", "storage_service", "parts_storage", "locker_storage", "locker_strip", "filing_wall", "records_nook", "seed_storage", "cold_storage", "specimen_storage", "rack", "crate", "locker", "parts"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_STORAGE
		if(token in list("utility", "service", "service_room", "generator_nook"))
			return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_UTILITY
	if(program_id == "storage")
		return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_STORAGE
	if(program_id == "workshop")
		return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_WORK
	if(program_id == "office")
		return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_WORK
	if(program_id == "hydroponics")
		return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_HYDRO
	if(program_id == "dormitory")
		return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_SLEEPING
	return WORLD_EDIT_BUILDING_SEMANTIC_ROOM_NONE

/datum/world_edit_generator/building_layout/proc/building_semantic_room_is_common(room_key, datum/world_edit_building_layout_state/state)
	if(findtext(room_key, "common") || findtext(room_key, "dining") || findtext(room_key, "public") || findtext(room_key, "lobby") || findtext(room_key, "court"))
		return TRUE
	return state?.archetype?.id == "living" && findtext(room_key, "main")

/datum/world_edit_generator/building_layout/proc/building_semantic_room_is_sleeping(room_key)
	return findtext(room_key, "sleep") || findtext(room_key, "dorm") || findtext(room_key, "living_wing") || findtext(room_key, "private")

/datum/world_edit_generator/building_layout/proc/building_semantic_room_is_sanitation(room_key)
	return findtext(room_key, "sanitation") || findtext(room_key, "toilet") || findtext(room_key, "bath")

/datum/world_edit_generator/building_layout/proc/building_semantic_room_is_storage(room_key)
	return findtext(room_key, "storage") || findtext(room_key, "rack") || findtext(room_key, "crate") || findtext(room_key, "locker") || findtext(room_key, "parts")

/datum/world_edit_generator/building_layout/proc/building_semantic_room_is_work(room_key, datum/world_edit_building_layout_state/state)
	if(findtext(room_key, "work") || findtext(room_key, "machine") || findtext(room_key, "desk") || findtext(room_key, "office") || findtext(room_key, "engineering") || findtext(room_key, "lab"))
		return TRUE
	return state?.archetype?.id in list("workshop", "office", "engineering", "laboratory")

/datum/world_edit_generator/building_layout/proc/building_semantic_room_is_hydro(room_key, datum/world_edit_building_layout_state/state)
	return state?.archetype?.id == "hydroponics" || findtext(room_key, "grow") || findtext(room_key, "hydro")

/datum/world_edit_generator/building_layout/proc/building_semantic_storage_slot_for_state(datum/world_edit_building_layout_state/state)
	if(state?.archetype?.id == "storage" || state?.archetype?.id == "workshop")
		return "rack"
	if(state?.archetype?.id == "dormitory" || state?.archetype?.id == "living")
		return "cabinet"
	return "rack"

/datum/world_edit_generator/building_layout/proc/building_semantic_storage_category_for_state(datum/world_edit_building_layout_state/state)
	if(state?.archetype?.id == "storage" || state?.archetype?.id == "workshop")
		return "rack"
	return "cabinet"

/datum/world_edit_generator/building_layout/proc/building_semantic_work_secondary_slot_for_state(datum/world_edit_building_layout_state/state)
	if(state?.archetype?.id == "workshop")
		return "console"
	if(state?.archetype?.id == "office")
		return "filing"
	return "console"

/datum/world_edit_generator/building_layout/proc/building_semantic_work_secondary_category_for_state(datum/world_edit_building_layout_state/state)
	if(state?.archetype?.id == "office")
		return "cabinet"
	return "console"
