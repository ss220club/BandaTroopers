#define WORLD_EDIT_BUILDING_MAX_POINT_HALF_EXTENT 12
#define WORLD_EDIT_BUILDING_MAX_FOOTPRINT_TURFS 625
#define WORLD_EDIT_BUILDING_MAX_PREVIEW_OBJECT_SPECS 700
#define WORLD_EDIT_BUILDING_MAX_HOVER_PREVIEW_OBJECT_SPECS 120
#define WORLD_EDIT_BUILDING_MAX_WINDOWS 12
#define WORLD_EDIT_BUILDING_MAX_FIXTURE_OBJECTS 96
#define WORLD_EDIT_BUILDING_MAX_CLUSTER_STEPS 32
#define WORLD_EDIT_BUILDING_MAX_VALIDATION_ERRORS 12
#define WORLD_EDIT_BUILDING_MAX_REPAIR_ATTEMPTS 6
#define WORLD_EDIT_BUILDING_MAX_LAYOUT_CANDIDATES 16
#define WORLD_EDIT_BUILDING_MAX_MASK_VARIANTS 5
#define WORLD_EDIT_BUILDING_MAX_REGION_CANDIDATES_PER_SPEC 10
#define WORLD_EDIT_BUILDING_MAX_REGION_ASSIGNMENT_STEPS 128
#define WORLD_EDIT_BUILDING_MAX_REGION_ASSIGNMENT_BRANCHES 8
#define WORLD_EDIT_BUILDING_MAX_DIVIDER_RUN_ATTEMPTS 12
#define WORLD_EDIT_BUILDING_MAX_ROOM_IN_ROOM_CANDIDATES 96
#define WORLD_EDIT_BUILDING_MAX_TEMPLATE_CHUNK_CELLS 12
#define WORLD_EDIT_BUILDING_MAX_STAGE_REPORTS 512
#define WORLD_EDIT_BUILDING_MAX_PATTERN_REPORTS 96
#define WORLD_EDIT_BUILDING_MAX_SEMANTIC_SLOT_REPORTS 96
#define WORLD_EDIT_BUILDING_MAX_DEGRADED_REGION_REPORTS 32
#define WORLD_EDIT_BUILDING_MAX_CANDIDATE_REPORT_DETAILS 3
#define WORLD_EDIT_BUILDING_MAX_QUALITY_SAMPLES_STORED 120
#define WORLD_EDIT_BUILDING_MAX_QUALITY_FAILURE_SAMPLES 80
#define WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO 64
#define WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS 24
#define WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS 96
#define WORLD_EDIT_BUILDING_AUTO_SEED 0
#define WORLD_EDIT_BUILDING_PRNG_MOD 131071
#define WORLD_EDIT_BUILDING_HASH_A_MOD 4093
#define WORLD_EDIT_BUILDING_HASH_B_MOD 4099
#define WORLD_EDIT_BUILDING_SUPPORT_SUPPORTED "SUPPORTED_AND_VALIDATED"
#define WORLD_EDIT_BUILDING_SUPPORT_UNSUPPORTED "UNSUPPORTED_WITH_CLEAR_ERROR"
#define WORLD_EDIT_BUILDING_SUPPORT_DISABLED "DISABLED"
#define WORLD_EDIT_BUILDING_SUPPORT_FAILED "FAILED"
#define WORLD_EDIT_BUILDING_SIZE_POLICY_AUTO "auto"
#define WORLD_EDIT_BUILDING_SIZE_POLICY_EXPLICIT "explicit"
#define WORLD_EDIT_BUILDING_SIZE_POLICY_ADAPTIVE "adaptive"
#define WORLD_EDIT_BUILDING_DEGRADE_NONE "none"
#define WORLD_EDIT_BUILDING_DEGRADE_COMPACT "compact"
#define WORLD_EDIT_BUILDING_DEGRADE_MICRO "micro"

GLOBAL_LIST_EMPTY(world_edit_building_preset_capability_cache)
GLOBAL_LIST_EMPTY(world_edit_building_faction_catalog)
GLOBAL_LIST_EMPTY(world_edit_building_archetype_catalog)
GLOBAL_VAR(world_edit_building_object_provider_registry)
GLOBAL_VAR(world_edit_building_placement_module_catalog)

/datum/world_edit_building_prng
	var/state = 1

/datum/world_edit_building_prng/New(seed)
	. = ..()
	state = round(text2num("[seed]") || 1) % WORLD_EDIT_BUILDING_PRNG_MOD
	if(state <= 0)
		state += WORLD_EDIT_BUILDING_PRNG_MOD

/datum/world_edit_building_prng/proc/next_value()
	// The maximum intermediate is 16,658,235, below DM's exact integer
	// ceiling.  Larger LCG constants silently discard low bits.
	state = ((state * 127) + 12345) % WORLD_EDIT_BUILDING_PRNG_MOD
	if(state <= 0)
		state += WORLD_EDIT_BUILDING_PRNG_MOD
	return state

/datum/world_edit_building_prng/proc/next_between(min_value, max_value)
	min_value = round(min_value)
	max_value = round(max_value)
	if(max_value <= min_value)
		return min_value
	return min_value + (next_value() % (max_value - min_value + 1))

/datum/world_edit_building_prng/proc/chance(percent)
	percent = clamp(round(percent), 0, 100)
	if(percent <= 0)
		return FALSE
	if(percent >= 100)
		return TRUE
	return next_between(1, 100) <= percent

/datum/world_edit_building_prng/proc/pick_from(list/items)
	if(!islist(items) || !length(items))
		return null
	return items[next_between(1, length(items))]

/datum/world_edit_generator/building_layout/proc/build_seed_from_text(value)
	var/text_value = "[value]"
	var/hash_a = 17
	var/hash_b = 29
	for(var/index in 1 to length(text_value))
		var/ascii_value = text2ascii(text_value, index)
		hash_a = ((hash_a * 33) + ascii_value) % WORLD_EDIT_BUILDING_HASH_A_MOD
		hash_b = ((hash_b * 131) + ascii_value) % WORLD_EDIT_BUILDING_HASH_B_MOD
	return max((hash_a * WORLD_EDIT_BUILDING_HASH_B_MOD) + hash_b, 1)

/datum/world_edit_generator/building_layout/proc/build_effective_building_seed(list/config, datum/world_edit_shape_contract/shape_contract, list/placement_context)
	var/requested_seed = round(text2num("[config["building_seed"]]") || WORLD_EDIT_BUILDING_AUTO_SEED)
	if(requested_seed > 0)
		return requested_seed

	var/turf/seed_turf = get_shape_placement_seed_turf(shape_contract, placement_context)
	var/seed_text = "[config["archetype_id"]]|[config["faction_preset"]]|[config["half_width"]]|[config["half_depth"]]|[config["detail_budget"]]|[config["window_density"]]"
	if(istype(seed_turf))
		seed_text = "[seed_text]|[seed_turf.x],[seed_turf.y],[seed_turf.z]"
	seed_text = "[seed_text]|[placement_context["direction"] || manager?.get_effective_placement_dir() || NORTH]|[shape_contract?.shape_id || WORLD_EDIT_SHAPE_POINT]"
	return build_seed_from_text(seed_text)

/datum/world_edit_generator/building_layout/proc/build_stage_seed(base_seed, stage_name)
	return build_seed_from_text("[base_seed]|[stage_name]")

/datum/world_edit_generator/building_layout/proc/build_building_hash_from_strings(list/values)
	if(!islist(values) || !length(values))
		return build_seed_from_text("")
	var/list/sorted_values = sortList(values.Copy())
	var/hash_a = 17
	var/hash_b = 29
	for(var/value as anything in sorted_values)
		var/text_value = "[value]|"
		for(var/index in 1 to length(text_value))
			var/ascii_value = text2ascii(text_value, index)
			hash_a = ((hash_a * 33) + ascii_value) % WORLD_EDIT_BUILDING_HASH_A_MOD
			hash_b = ((hash_b * 131) + ascii_value) % WORLD_EDIT_BUILDING_HASH_B_MOD
	return max((hash_a * WORLD_EDIT_BUILDING_HASH_B_MOD) + hash_b, 1)

/datum/world_edit_generator/building_layout/proc/build_building_turf_list_hash(list/turfs)
	var/list/values = list()
	if(islist(turfs))
		for(var/turf/target_turf as anything in turfs)
			if(istype(target_turf))
				values += "[target_turf.x],[target_turf.y],[target_turf.z]"
	return build_building_hash_from_strings(values)

/datum/world_edit_generator/building_layout/proc/build_building_turf_lookup_hash(list/lookup)
	var/list/values = list()
	if(islist(lookup))
		for(var/turf/target_turf as anything in lookup)
			if(istype(target_turf) && lookup[target_turf])
				values += "[target_turf.x],[target_turf.y],[target_turf.z]"
	return build_building_hash_from_strings(values)

/datum/world_edit_generator/building_layout/proc/build_building_assoc_hash(list/assoc)
	var/list/values = list()
	if(islist(assoc))
		for(var/key as anything in assoc)
			values += "[key]=[assoc[key]]"
	return build_building_hash_from_strings(values)
