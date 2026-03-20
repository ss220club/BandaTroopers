/datum/unit_test/human_ai_squad_spawner
	var/list/created_squads
	var/list/created_humans
	var/list/registered_preset_keys

/datum/unit_test/human_ai_squad_spawner/New()
	. = ..()
	created_squads = list()
	created_humans = list()
	registered_preset_keys = list()

/datum/unit_test/human_ai_squad_spawner/Run()
	return

/datum/unit_test/human_ai_squad_spawner/Destroy()
	for(var/mob/living/carbon/human/human as anything in created_humans)
		if(!QDELETED(human))
			qdel(human)

	for(var/datum/human_ai_squad/squad as anything in created_squads)
		if(!QDELETED(squad))
			qdel(squad)

	for(var/preset_key as anything in registered_preset_keys)
		GLOB.human_ai_squad_presets -= preset_key

	created_humans = null
	created_squads = null
	registered_preset_keys = null

	return ..()

/datum/unit_test/human_ai_squad_spawner/proc/get_open_test_origin()
	for(var/turf/floor_tile as anything in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		if(!isfloorturf(floor_tile))
			continue
		var/all_cardinals_open = TRUE
		for(var/direction in GLOB.cardinals)
			if(!isfloorturf(get_step(floor_tile, direction)))
				all_cardinals_open = FALSE
				break

		if(all_cardinals_open)
			return floor_tile

	return run_loc_floor_bottom_left

/datum/unit_test/human_ai_squad_spawner/proc/get_candidate_test_origin(datum/human_ai_squad_preset/preset, radius = 10, min_candidates = 8, only_accessible_tiles = FALSE, only_reachable_tiles = FALSE, treat_windows_as_blockers = TRUE)
	var/list/search_roots = list(run_loc_floor_bottom_left, run_loc_floor_top_right, SSmapping?.get_mainship_center())
	for(var/turf/root as anything in search_roots)
		if(!isfloorturf(root))
			continue
		for(var/turf/floor_tile as anything in range(radius + 3, root))
			if(!isfloorturf(floor_tile))
				continue
			var/list/candidates = preset?.get_spawn_candidate_turfs(floor_tile, radius, only_accessible_tiles, only_reachable_tiles, treat_windows_as_blockers)
			if(length(candidates) >= min_candidates)
				return floor_tile

	return get_open_test_origin()

/datum/unit_test/human_ai_squad_spawner/proc/get_enclosable_target(datum/human_ai_squad_preset/preset, turf/origin, max_distance = 10, treat_windows_as_blockers = TRUE)
	var/list/candidates = preset?.get_spawn_candidate_turfs(origin, max_distance, TRUE, FALSE, treat_windows_as_blockers)
	for(var/turf/open/floor/floor_tile as anything in candidates)
		if(floor_tile == origin)
			continue

		var/all_adjacent_open = TRUE
		for(var/direction in GLOB.alldirs)
			if(!isfloorturf(get_step(floor_tile, direction)))
				all_adjacent_open = FALSE
				break

		if(all_adjacent_open)
			return floor_tile

	return null

/datum/unit_test/human_ai_squad_spawner/proc/get_window_path_test_origin()
	for(var/turf/floor_tile as anything in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		if(!isfloorturf(floor_tile))
			continue
		var/turf/east_one = get_step(floor_tile, EAST)
		var/turf/east_two = get_step(east_one, EAST)
		var/turf/north_tile = get_step(floor_tile, NORTH)
		var/turf/south_tile = get_step(floor_tile, SOUTH)
		var/turf/north_east = get_step(east_one, NORTH)
		var/turf/south_east = get_step(east_one, SOUTH)
		if(isfloorturf(east_one) && isfloorturf(east_two) && isfloorturf(north_tile) && isfloorturf(south_tile) && isfloorturf(north_east) && isfloorturf(south_east))
			return floor_tile

	return get_open_test_origin()

/datum/unit_test/human_ai_squad_spawner/proc/track_spawned_squad(datum/human_ai_squad/squad)
	if(!squad)
		return

	created_squads += squad
	for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
		if(brain?.tied_human)
			created_humans += brain.tied_human

// SS220 EDIT - START: shared assertions for modular Human AI species validation regressions
/datum/unit_test/human_ai_squad_spawner/proc/track_spawned_human(mob/living/carbon/human/human)
	if(human)
		created_humans += human

/datum/unit_test/human_ai_squad_spawner/proc/register_test_preset(datum/human_ai_squad_preset/preset)
	var/preset_key = "[preset.type]"
	GLOB.human_ai_squad_presets[preset_key] = preset
	registered_preset_keys += preset_key
	return preset_key

/datum/unit_test/human_ai_squad_spawner/proc/assert_spawned_ai_species(mob/living/carbon/human/human, expected_species, context)
	TEST_ASSERT_NOTNULL(human, "[context] did not return a spawned human.")
	TEST_ASSERT_NOTNULL(human.get_ai_brain(), "[context] did not attach a human AI brain.")
	TEST_ASSERT_EQUAL(human.species?.name, expected_species, "[context] spawned with an unexpected species.")

/datum/unit_test/human_ai_squad_spawner/proc/assert_spawned_ai_matches_expected_species(mob/living/carbon/human/human, context)
	var/datum/equipment_preset/preset = human?.assigned_equipment_preset
	var/expected_species = preset?.expected_species
	if(!expected_species)
		expected_species = SPECIES_HUMAN
	assert_spawned_ai_species(human, expected_species, context)
// SS220 EDIT - END

/datum/human_ai_squad_preset/unit_test_spawn
	name = ""
	desc = ""
	ai_to_spawn = list(
		/datum/equipment_preset/colonist/cook = 3,
	)

// SS220 EDIT - START: unit-test-only presets for Human AI squad spawner ui_act and failure regressions
/datum/human_ai_squad_preset/unit_test_spawn/ui_capture
	var/last_spawn_radius
	var/last_only_accessible_tiles
	var/last_only_reachable_tiles
	var/last_treat_windows_as_blockers
	var/datum/human_ai_squad/last_spawned_squad

/datum/human_ai_squad_preset/unit_test_spawn/ui_capture/spawn_ai(turf/spawn_loc, spawn_radius = 1, only_accessible_tiles = TRUE, only_reachable_tiles = FALSE, list/precomputed_candidate_turfs = null, treat_windows_as_blockers = TRUE)
	last_spawn_radius = spawn_radius
	last_only_accessible_tiles = only_accessible_tiles
	last_only_reachable_tiles = only_reachable_tiles
	last_treat_windows_as_blockers = treat_windows_as_blockers
	last_spawned_squad = ..()
	return last_spawned_squad

/datum/human_ai_squad_preset/unit_test_spawn/empty_spawn
/datum/human_ai_squad_preset/unit_test_spawn/empty_spawn/spawn_ai(turf/spawn_loc, spawn_radius = 1, only_accessible_tiles = TRUE, only_reachable_tiles = FALSE, list/precomputed_candidate_turfs = null, treat_windows_as_blockers = TRUE)
	return SShuman_ai.create_new_squad()
// SS220 EDIT - END

/datum/unit_test/human_ai_squad_spawner_radius_normalization
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_radius_normalization/Run()
	var/datum/human_ai_squad_preset/unit_test_spawn/preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn)
	TEST_ASSERT_EQUAL(preset.normalize_spawn_radius(null), 1, "Null spawn radius should fall back to 1.")
	TEST_ASSERT_EQUAL(preset.normalize_spawn_radius("oops"), 1, "Nonnumeric spawn radius should fall back to 1.")
	TEST_ASSERT_EQUAL(preset.normalize_spawn_radius(2.6), 2, "Spawn radius should follow the current round() behavior before clamping.")
	TEST_ASSERT_EQUAL(preset.normalize_spawn_radius(0), 1, "Spawn radius should clamp to the minimum.")
	TEST_ASSERT_EQUAL(preset.normalize_spawn_radius(11), 10, "Spawn radius should clamp to the maximum.")
	TEST_ASSERT_EQUAL(preset.normalize_spawn_radius(4), 4, "Valid spawn radius should pass through unchanged.")

/datum/unit_test/human_ai_squad_spawner_candidate_filter
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_candidate_filter/Run()
	var/datum/human_ai_squad_preset/unit_test_spawn/preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn)
	var/turf/origin = get_candidate_test_origin(preset, 10, 20)
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for Human AI squad spawner candidate filtering.")

	var/list/radius_one_candidates = preset.get_spawn_candidate_turfs(origin, 1, FALSE, FALSE)
	var/list/radius_two_candidates = preset.get_spawn_candidate_turfs(origin, 2, FALSE, FALSE)
	TEST_ASSERT(length(radius_two_candidates) > length(radius_one_candidates), "Increasing the spawn radius should expand the candidate pool on an open turf.")

	var/list/base_candidates = preset.get_spawn_candidate_turfs(origin, 10, FALSE, FALSE)
	TEST_ASSERT(length(base_candidates), "Candidate selection without accessibility filtering returned no floor tiles.")
	for(var/turf/candidate as anything in base_candidates)
		TEST_ASSERT(get_dist(origin, candidate) <= 10, "Spawn candidate [candidate] exceeded the configured radius.")

	var/turf/blocked_target = get_enclosable_target(preset, origin)
	TEST_ASSERT_NOTNULL(blocked_target, "Failed to find an enclosable target turf for accessibility filtering.")
	if(!blocked_target)
		return
	var/list/pre_block_local_candidates = preset.get_spawn_candidate_turfs(origin, 10, TRUE, FALSE, TRUE)
	TEST_ASSERT(blocked_target in pre_block_local_candidates, "Failed to choose a target that is locally accessible before route blockers are added.")
	var/list/blockers = list()
	var/list/blocked_ring_turfs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/blocker_turf = get_step(blocked_target, direction)
		TEST_ASSERT(isfloorturf(blocker_turf), "Blocked-target ring turf [blocker_turf] was not a floor.")
		blocked_ring_turfs += blocker_turf
		blockers += allocate(/obj/structure/blocker, blocker_turf)

	var/list/local_filtered_candidates = preset.get_spawn_candidate_turfs(origin, 10, TRUE, FALSE, TRUE)
	var/list/reachable_filtered_candidates = preset.get_spawn_candidate_turfs(origin, 10, FALSE, TRUE, TRUE)
	TEST_ASSERT(!(blocked_target in reachable_filtered_candidates), "A route-blocked turf should not remain a valid spawn candidate when reachability filtering is enabled.")

	var/turf/object_blocked_target = null
	for(var/turf/candidate as anything in base_candidates)
		if(candidate == origin || candidate == blocked_target || (candidate in blocked_ring_turfs)) // SS220 EDIT: disambiguate DreamChecker precedence in candidate filter exclusion
			continue
		object_blocked_target = candidate
		break

	TEST_ASSERT_NOTNULL(object_blocked_target, "Failed to find a secondary candidate turf for center-blocking tests.")
	if(!object_blocked_target)
		return
	var/obj/structure/blocker/object_blocker = allocate(/obj/structure/blocker, object_blocked_target)
	local_filtered_candidates = preset.get_spawn_candidate_turfs(origin, 10, TRUE, FALSE, TRUE)
	TEST_ASSERT(!(object_blocked_target in local_filtered_candidates), "A turf with a dense object on its center should not remain a valid spawn candidate when local accessibility filtering is enabled.")
	reachable_filtered_candidates = preset.get_spawn_candidate_turfs(origin, 10, FALSE, TRUE, TRUE)
	TEST_ASSERT(!(object_blocked_target in reachable_filtered_candidates), "A turf with a dense object on its center should not remain a valid spawn candidate when reachability filtering is enabled.")
	qdel(object_blocker)

	var/turf/mob_origin = get_candidate_test_origin(preset, 1, 2, TRUE, FALSE, TRUE)
	TEST_ASSERT(isfloorturf(mob_origin), "Failed to find an open origin turf for dense-mob accessibility testing.")
	var/list/mob_candidates = preset.get_spawn_candidate_turfs(mob_origin, 1, TRUE, FALSE, TRUE)
	var/turf/mob_target = null
	for(var/turf/candidate as anything in mob_candidates)
		if(candidate == mob_origin)
			continue
		mob_target = candidate
		break
	TEST_ASSERT_NOTNULL(mob_target, "Failed to find a reachable turf for dense-mob accessibility testing.")
	if(!mob_target)
		return
	var/mob/living/carbon/human/dense_mob = allocate(/mob/living/carbon/human, mob_target)
	TEST_ASSERT_NOTNULL(dense_mob, "Failed to allocate a dense mob for accessibility testing.")
	track_spawned_human(dense_mob)
	local_filtered_candidates = preset.get_spawn_candidate_turfs(mob_origin, 1, TRUE, FALSE, TRUE)
	TEST_ASSERT(mob_target in local_filtered_candidates, "A dense mob should not invalidate a turf for Human AI squad spawning.")

	var/turf/window_origin = get_candidate_test_origin(preset, 1, 2, TRUE, FALSE, FALSE)
	TEST_ASSERT(isfloorturf(window_origin), "Failed to find an open origin turf for window-blocker accessibility testing.")
	var/list/window_clear_candidates = preset.get_spawn_candidate_turfs(window_origin, 1, TRUE, FALSE, FALSE)
	var/turf/window_blocked_target = null
	for(var/turf/candidate as anything in window_clear_candidates)
		if(candidate == window_origin)
			continue
		window_blocked_target = candidate
		break
	TEST_ASSERT_NOTNULL(window_blocked_target, "Failed to find a clear adjacent turf for window-blocker accessibility testing.")
	if(!window_blocked_target)
		return
	var/obj/structure/window/full/window_blocker = allocate(/obj/structure/window/full, window_blocked_target)
	local_filtered_candidates = preset.get_spawn_candidate_turfs(window_origin, 1, TRUE, FALSE, TRUE)
	TEST_ASSERT(!(window_blocked_target in local_filtered_candidates), "A turf with a full window on it should not remain a valid spawn candidate when clear-tile filtering treats windows as blockers.")
	reachable_filtered_candidates = preset.get_spawn_candidate_turfs(window_origin, 1, FALSE, TRUE, TRUE)
	TEST_ASSERT(!(window_blocked_target in reachable_filtered_candidates), "A turf with a full window on it should not remain a valid spawn candidate when reachability treats windows as blockers.")
	local_filtered_candidates = preset.get_spawn_candidate_turfs(window_origin, 1, TRUE, FALSE, FALSE)
	TEST_ASSERT(window_blocked_target in local_filtered_candidates, "A turf with a full window on it should remain a valid spawn candidate when window blockers are disabled.")
	qdel(window_blocker)

	for(var/obj/structure/blocker/blocker as anything in blockers)
		if(!QDELETED(blocker))
			qdel(blocker)

/datum/unit_test/human_ai_squad_spawner_border_window_regression
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_border_window_regression/Run()
	var/datum/human_ai_squad_preset/unit_test_spawn/preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn)
	var/turf/origin = get_open_test_origin()
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for the border-window regression test.")

	var/turf/candidate = get_step(origin, EAST)
	TEST_ASSERT(isfloorturf(candidate), "Failed to find an adjacent floor turf for the border-window regression test.")

	var/obj/structure/window/border_window = allocate(/obj/structure/window, candidate)
	border_window.setDir(NORTH)

	var/list/unfiltered_candidates = preset.get_spawn_candidate_turfs(origin, 1, FALSE, FALSE, TRUE)
	TEST_ASSERT(candidate in unfiltered_candidates, "A border window on a candidate turf should not remove it from the unfiltered candidate set.")

	var/list/clear_candidates = preset.get_spawn_candidate_turfs(origin, 1, TRUE, FALSE, TRUE)
	TEST_ASSERT(!(candidate in clear_candidates), "A border window should remove a candidate turf when window blockers are enabled for clear-tile filtering.")

	var/list/reachable_candidates = preset.get_spawn_candidate_turfs(origin, 1, FALSE, TRUE, TRUE)
	TEST_ASSERT(!(candidate in reachable_candidates), "A border window should remove a reachable candidate turf when window blockers are enabled.")

	clear_candidates = preset.get_spawn_candidate_turfs(origin, 1, TRUE, FALSE, FALSE)
	TEST_ASSERT(candidate in clear_candidates, "A border window should not remove a candidate turf when window blockers are disabled.")

	reachable_candidates = preset.get_spawn_candidate_turfs(origin, 1, FALSE, TRUE, FALSE)
	TEST_ASSERT(candidate in reachable_candidates, "A border window should not remove a reachable candidate turf when window blockers are disabled.")
	qdel(border_window)

/datum/unit_test/human_ai_squad_spawner_window_path_blocker
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_window_path_blocker/Run()
	var/datum/human_ai_squad_preset/unit_test_spawn/preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn)
	var/turf/origin = get_window_path_test_origin()
	var/turf/east_one = get_step(origin, EAST)
	var/turf/east_two = get_step(east_one, EAST)
	var/turf/north_tile = get_step(origin, NORTH)
	var/turf/south_tile = get_step(origin, SOUTH)
	var/turf/north_east = get_step(east_one, NORTH)
	var/turf/south_east = get_step(east_one, SOUTH)

	TEST_ASSERT(isfloorturf(origin), "Window-path blocker test origin was not a floor turf.")
	TEST_ASSERT(isfloorturf(east_one), "Window-path blocker test could not find the first floor turf east of origin.")
	TEST_ASSERT(isfloorturf(east_two), "Window-path blocker test could not find the second floor turf east of origin.")
	TEST_ASSERT(isfloorturf(north_tile), "Window-path blocker test could not find the north guard turf.")
	TEST_ASSERT(isfloorturf(south_tile), "Window-path blocker test could not find the south guard turf.")
	TEST_ASSERT(isfloorturf(north_east), "Window-path blocker test could not find the northeast guard turf.")
	TEST_ASSERT(isfloorturf(south_east), "Window-path blocker test could not find the southeast guard turf.")

	var/obj/structure/blocker/north_guard_blocker = allocate(/obj/structure/blocker, north_tile)
	var/obj/structure/blocker/south_guard_blocker = allocate(/obj/structure/blocker, south_tile)
	var/obj/structure/blocker/north_east_guard_blocker = allocate(/obj/structure/blocker, north_east)
	var/obj/structure/blocker/south_east_guard_blocker = allocate(/obj/structure/blocker, south_east)
	var/obj/structure/window/path_window = allocate(/obj/structure/window, east_one)
	path_window.setDir(NORTH)

	var/list/reachable_without_window_blockers = preset.get_spawn_candidate_turfs(origin, 2, FALSE, TRUE, FALSE)
	TEST_ASSERT(east_two in reachable_without_window_blockers, "A window on the route should not block reachability when window blockers are disabled.")

	var/list/reachable_with_window_blockers = preset.get_spawn_candidate_turfs(origin, 2, FALSE, TRUE, TRUE)
	TEST_ASSERT(!(east_two in reachable_with_window_blockers), "A window on the route should block reachability when window blockers are enabled.")

	qdel(path_window)
	qdel(north_guard_blocker)
	qdel(south_guard_blocker)
	qdel(north_east_guard_blocker)
	qdel(south_east_guard_blocker)

/datum/unit_test/human_ai_squad_spawner_spawn_distribution
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_spawn_distribution/Run()
	var/datum/human_ai_squad_preset/unit_test_spawn/preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn)
	var/turf/origin = get_candidate_test_origin(preset, 1, 5)
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for Human AI squad spawn distribution tests.")

	var/list/radius_candidates = preset.get_spawn_candidate_turfs(origin, 1, FALSE, FALSE)
	var/turf/occupied_target = null
	for(var/turf/open/floor/candidate as anything in radius_candidates)
		if(candidate == origin)
			continue
		occupied_target = candidate
		break

	TEST_ASSERT_NOTNULL(occupied_target, "Failed to find an occupied-target turf for open-priority spawn testing.")
	if(!occupied_target)
		return
	var/mob/living/carbon/human/existing_occupant = allocate(/mob/living/carbon/human, occupied_target)
	track_spawned_human(existing_occupant)

	var/datum/human_ai_squad/open_squad = preset.spawn_ai(origin, 1, FALSE, FALSE)
	TEST_ASSERT_NOTNULL(open_squad, "Human AI squad spawner failed to create a squad on open nearby tiles.")
	track_spawned_squad(open_squad)
	TEST_ASSERT_EQUAL(length(open_squad.ai_in_squad), 3, "Open-area spawn should create the full unit-test squad.")

	var/list/open_spawn_turf_keys = list()
	for(var/datum/human_ai_brain/brain as anything in open_squad.ai_in_squad)
		var/turf/spawn_turf = get_turf(brain.tied_human)
		TEST_ASSERT(get_dist(origin, spawn_turf) <= 1, "Unit-test squad member spawned outside radius 1.")
		TEST_ASSERT(spawn_turf != occupied_target, "Open-area spawn should prefer free turfs over an already occupied turf.")
		open_spawn_turf_keys[REF(spawn_turf)] = TRUE

	TEST_ASSERT_EQUAL(length(open_spawn_turf_keys), 3, "Open-area spawn should distribute squad members across unique tiles when enough candidates exist.")

	var/turf/fallback_target = null
	for(var/turf/open/floor/candidate as anything in radius_candidates)
		if(candidate == origin || candidate == occupied_target)
			continue
		var/all_cardinals_open = TRUE
		for(var/direction in GLOB.cardinals)
			if(!isfloorturf(get_step(candidate, direction)))
				all_cardinals_open = FALSE
				break
		if(all_cardinals_open)
			fallback_target = candidate
			break

	TEST_ASSERT_NOTNULL(fallback_target, "Failed to find a nearby fallback turf for repeat-spawn testing.")
	if(!fallback_target)
		return
	var/mob/living/carbon/human/fallback_occupant = allocate(/mob/living/carbon/human, fallback_target)
	track_spawned_human(fallback_occupant)
	for(var/direction in GLOB.cardinals)
		var/turf/blocker_turf = get_step(fallback_target, direction)
		TEST_ASSERT(isfloorturf(blocker_turf), "Fallback ring turf [blocker_turf] was not a floor.")
		allocate(/obj/structure/blocker, blocker_turf)

	var/list/allowed_turfs = preset.get_spawn_candidate_turfs(fallback_target, 1, TRUE, TRUE, TRUE)
	TEST_ASSERT(length(allowed_turfs), "Fallback spawn scenario no longer exposes any backend-approved candidate turfs.")

	var/datum/human_ai_squad/fallback_squad = preset.spawn_ai(fallback_target, 1, TRUE, TRUE, null, TRUE)
	TEST_ASSERT_NOTNULL(fallback_squad, "Human AI squad spawner should still create a squad when only one accessible turf remains.")
	track_spawned_squad(fallback_squad)
	TEST_ASSERT_EQUAL(length(fallback_squad.ai_in_squad), 3, "Fallback spawn should still create the full unit-test squad.")

	for(var/datum/human_ai_brain/brain as anything in fallback_squad.ai_in_squad)
		var/turf/spawn_turf = get_turf(brain.tied_human)
		TEST_ASSERT(spawn_turf in allowed_turfs, "Fallback spawn used a turf outside the filtered candidate set.")

	TEST_ASSERT_EQUAL(fallback_squad.squad_leader, fallback_squad.ai_in_squad[1], "The first spawned unit should remain the squad leader after the radius/filter changes.")

/datum/unit_test/human_ai_squad_spawner_ui_act_flow
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_ui_act_flow/Run()
	var/datum/human_ai_squad_preset/unit_test_spawn/ui_capture/preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn/ui_capture)
	var/preset_key = register_test_preset(preset)
	var/turf/origin = get_open_test_origin()
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for the HumanSquadSpawner ui_act flow test.")

	var/mob/living/carbon/human/admin_user = allocate(/mob/living/carbon/human, origin)
	track_spawned_human(admin_user)
	var/datum/human_squad_spawner_menu/menu = allocate(/datum/human_squad_spawner_menu)
	var/datum/tgui/ui = allocate(/datum/tgui, admin_user, menu, "HumanSquadSpawner")

	var/success = menu.ui_act("create_squad", list(
		"path" = preset_key,
		"radius" = 4,
		"only_accessible" = 0,
		"only_reachable" = 1,
		"windows_blockers" = 0,
	), ui, menu.ui_state(admin_user))
	TEST_ASSERT(success, "HumanSquadSpawner ui_act should succeed for a valid squad spawn request.")
	TEST_ASSERT_EQUAL(preset.last_spawn_radius, 4, "HumanSquadSpawner ui_act did not forward the configured spawn radius.")
	TEST_ASSERT_EQUAL(preset.last_only_accessible_tiles, FALSE, "HumanSquadSpawner ui_act did not forward only_accessible = FALSE.")
	TEST_ASSERT_EQUAL(preset.last_only_reachable_tiles, TRUE, "HumanSquadSpawner ui_act did not forward only_reachable = TRUE.")
	TEST_ASSERT_EQUAL(preset.last_treat_windows_as_blockers, FALSE, "HumanSquadSpawner ui_act did not forward windows_blockers = FALSE.")
	TEST_ASSERT_NOTNULL(preset.last_spawned_squad, "HumanSquadSpawner ui_act did not produce a squad object for a successful request.")
	track_spawned_squad(preset.last_spawned_squad)

	var/default_success = menu.ui_act("create_squad", list(
		"path" = preset_key,
		"radius" = 2,
		"only_accessible" = 1,
		"only_reachable" = 0,
	), ui, menu.ui_state(admin_user))
	TEST_ASSERT(default_success, "HumanSquadSpawner ui_act should keep succeeding when windows_blockers falls back to its default.")
	TEST_ASSERT_EQUAL(preset.last_treat_windows_as_blockers, TRUE, "HumanSquadSpawner ui_act should default windows_blockers to TRUE when the parameter is omitted.")
	TEST_ASSERT_NOTNULL(preset.last_spawned_squad, "HumanSquadSpawner ui_act should still produce a squad object when windows_blockers uses its default.")
	track_spawned_squad(preset.last_spawned_squad)

/datum/unit_test/human_ai_squad_spawner_failure_paths
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_failure_paths/Run()
	var/turf/origin = get_open_test_origin()
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for HumanSquadSpawner failure-path tests.")

	var/mob/living/carbon/human/admin_user = allocate(/mob/living/carbon/human, origin)
	track_spawned_human(admin_user)
	var/datum/human_squad_spawner_menu/menu = allocate(/datum/human_squad_spawner_menu)
	var/datum/tgui/ui = allocate(/datum/tgui, admin_user, menu, "HumanSquadSpawner")

	var/datum/human_ai_squad_preset/unit_test_spawn/no_candidates_preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn)
	var/no_candidates_key = register_test_preset(no_candidates_preset)
	var/obj/structure/window/full/origin_blocker = allocate(/obj/structure/window/full, origin)
	var/no_candidates_result = menu.ui_act("create_squad", list(
		"path" = no_candidates_key,
		"radius" = 1,
		"only_accessible" = 1,
		"only_reachable" = 0,
	), ui, menu.ui_state(admin_user))
	TEST_ASSERT_EQUAL(no_candidates_result, FALSE, "HumanSquadSpawner ui_act should fail when there are no valid spawn candidates.")
	qdel(origin_blocker)

	var/turf/second_origin = get_step(origin, SOUTH)
	TEST_ASSERT(isfloorturf(second_origin), "Failed to find a secondary open turf for the empty-spawn failure-path test.")
	if(!isfloorturf(second_origin))
		return
	var/mob/living/carbon/human/second_admin_user = allocate(/mob/living/carbon/human, second_origin)
	track_spawned_human(second_admin_user)
	var/datum/tgui/second_ui = allocate(/datum/tgui, second_admin_user, menu, "HumanSquadSpawner")

	var/datum/human_ai_squad_preset/unit_test_spawn/empty_spawn/empty_spawn_preset = allocate(/datum/human_ai_squad_preset/unit_test_spawn/empty_spawn)
	var/empty_spawn_key = register_test_preset(empty_spawn_preset)
	var/empty_spawn_result = menu.ui_act("create_squad", list(
		"path" = empty_spawn_key,
		"radius" = 1,
		"only_accessible" = 1,
		"only_reachable" = 0,
		"windows_blockers" = 1,
	), second_ui, menu.ui_state(second_admin_user))
	TEST_ASSERT_EQUAL(empty_spawn_result, FALSE, "HumanSquadSpawner ui_act should fail when squad creation returns no AI members.")

// SS220 EDIT - START: regression coverage for modular Human AI species validation in both single and squad spawners
/datum/unit_test/human_ai_spawner_species_helper
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_spawner_species_helper/Run()
	var/turf/origin = get_open_test_origin()
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for Human AI species helper tests.")

	var/turf/sangheili_turf = origin
	var/turf/unggoy_turf = get_step(origin, NORTH)
	var/turf/human_turf = get_step(origin, SOUTH)
	TEST_ASSERT(isfloorturf(unggoy_turf), "Failed to find an open turf for the Unggoy AI spawn helper test.")
	TEST_ASSERT(isfloorturf(human_turf), "Failed to find an open turf for the human AI spawn helper test.")

	var/mob/living/carbon/human/sangheili = modular_spawn_human_ai_from_equipment_preset(/datum/equipment_preset/covenant/sangheili/ai/minor_plasma, sangheili_turf, TRUE, EAST)
	track_spawned_human(sangheili)
	assert_spawned_ai_species(sangheili, SPECIES_SANGHEILI, "Sangheili AI helper spawn")
	TEST_ASSERT_EQUAL(sangheili.dir, EAST, "Sangheili AI helper spawn did not preserve the requested facing direction.")

	var/mob/living/carbon/human/unggoy = modular_spawn_human_ai_from_equipment_preset(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma, unggoy_turf, TRUE, NORTH)
	track_spawned_human(unggoy)
	assert_spawned_ai_species(unggoy, SPECIES_UNGGOY, "Unggoy AI helper spawn")
	TEST_ASSERT_EQUAL(unggoy.dir, NORTH, "Unggoy AI helper spawn did not preserve the requested facing direction.")

	var/mob/living/carbon/human/unsc_marine = modular_spawn_human_ai_from_equipment_preset(/datum/equipment_preset/unsc/pfc/equipped, human_turf, TRUE, SOUTH)
	track_spawned_human(unsc_marine)
	assert_spawned_ai_species(unsc_marine, SPECIES_HUMAN, "UNSC AI helper spawn")
	TEST_ASSERT_EQUAL(unsc_marine.dir, SOUTH, "Human AI helper spawn did not preserve the requested facing direction.")

/datum/unit_test/human_ai_squad_spawner_species_unggoy_only
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_species_unggoy_only/Run()
	var/datum/human_ai_squad_preset/covenant/unggoy_pair/preset = allocate(/datum/human_ai_squad_preset/covenant/unggoy_pair)
	var/turf/origin = get_open_test_origin()
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for the Unggoy squad species test.")

	var/datum/human_ai_squad/squad = preset.spawn_ai(origin, 2, FALSE, FALSE)
	TEST_ASSERT_NOTNULL(squad, "Unggoy-only squad preset failed to spawn.")
	track_spawned_squad(squad)
	TEST_ASSERT_EQUAL(length(squad.ai_in_squad), 2, "Unggoy-only squad preset spawned an unexpected number of AI members.")

	for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
		assert_spawned_ai_matches_expected_species(brain?.tied_human, "Unggoy-only squad spawn")
		TEST_ASSERT_EQUAL(brain?.tied_human?.species?.name, SPECIES_UNGGOY, "Unggoy-only squad preset spawned a non-Unggoy AI.")

/datum/unit_test/human_ai_squad_spawner_species_mixed_covenant
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_species_mixed_covenant/Run()
	var/datum/human_ai_squad_preset/covenant/covenant_lance/preset = allocate(/datum/human_ai_squad_preset/covenant/covenant_lance)
	var/turf/origin = get_open_test_origin()
	TEST_ASSERT(isfloorturf(origin), "Failed to find an open origin turf for the mixed Covenant squad species test.")

	var/datum/human_ai_squad/squad = preset.spawn_ai(origin, 3, FALSE, FALSE)
	TEST_ASSERT_NOTNULL(squad, "Mixed Covenant squad preset failed to spawn.")
	track_spawned_squad(squad)

	var/found_sangheili = FALSE
	var/found_unggoy = FALSE
	for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
		var/mob/living/carbon/human/human = brain?.tied_human
		assert_spawned_ai_matches_expected_species(human, "Mixed Covenant squad spawn")
		if(human?.species?.name == SPECIES_SANGHEILI)
			found_sangheili = TRUE
		if(human?.species?.name == SPECIES_UNGGOY)
			found_unggoy = TRUE

	TEST_ASSERT(found_sangheili, "Mixed Covenant squad preset should include at least one Sangheili AI.")
	TEST_ASSERT(found_unggoy, "Mixed Covenant squad preset should include at least one Unggoy AI.")
// SS220 EDIT - END

/datum/unit_test/human_ai_squad_spawner_viable_turfs
	parent_type = /datum/unit_test/human_ai_squad_spawner

/datum/unit_test/human_ai_squad_spawner_viable_turfs/Run()
	var/datum/human_ai_squad_preset/preset = allocate(/datum/human_ai_squad_preset)
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/east_one = get_step(origin, EAST)
	var/turf/east_two = get_step(east_one, EAST)

	TEST_ASSERT(isfloorturf(origin), "Spawner unit test origin was not a floor turf.")
	TEST_ASSERT(isfloorturf(east_one), "Spawner radius test could not find the first floor turf east of origin.")
	TEST_ASSERT(isfloorturf(east_two), "Spawner radius test could not find the second floor turf east of origin.")

	var/list/radius_one_turfs = preset.get_viable_spawn_turfs(origin, 1, FALSE, FALSE, TRUE)
	TEST_ASSERT(radius_one_turfs.Find(origin), "Spawner viable turf selection lost the origin turf at radius 1.")
	TEST_ASSERT(radius_one_turfs.Find(east_one), "Spawner viable turf selection lost the adjacent floor turf at radius 1.")
	TEST_ASSERT(!radius_one_turfs.Find(east_two), "Spawner viable turf selection incorrectly included a turf outside radius 1.")

	var/list/radius_two_turfs = preset.get_viable_spawn_turfs(origin, 2, FALSE, FALSE, TRUE)
	TEST_ASSERT(radius_two_turfs.Find(east_two), "Spawner viable turf selection failed to include the farther floor turf at radius 2.")

	var/obj/structure/closet/blocker = allocate(/obj/structure/closet, east_one)
	TEST_ASSERT(blocker.density, "Spawner accessibility test blocker must stay dense.")

	var/list/accessible_turfs = preset.get_viable_spawn_turfs(origin, 1, TRUE, FALSE, TRUE)
	TEST_ASSERT(!accessible_turfs.Find(east_one), "Spawner accessibility filtering failed to remove a blocked floor turf.")

	var/list/unfiltered_turfs = preset.get_viable_spawn_turfs(origin, 1, FALSE, FALSE, TRUE)
	TEST_ASSERT(unfiltered_turfs.Find(east_one), "Spawner raw radius selection should still include the same floor turf when accessibility filtering is disabled.")
	qdel(blocker)
