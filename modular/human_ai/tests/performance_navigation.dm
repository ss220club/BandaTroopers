/datum/unit_test/human_ai_navigation_request_budget/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/first_destination = get_step(get_step(start, NORTH), NORTH)
	var/turf/moved_destination = get_step(get_step(start, EAST), EAST)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	TEST_ASSERT(brain.queue_navigation_path_to_turf(first_destination), "Initial navigation request was rejected")
	var/datum/xeno_pathinfo/request = brain.navigation_request
	var/generation = brain.navigation_generation
	var/turf/explored = get_step(start, NORTH)
	request.visited_nodes += explored
	request.prev[explored] = start
	brain.next_path_generation = 0
	TEST_ASSERT(!brain.should_queue_navigation_path(moved_destination), "Moving target admitted a replacement while its search was pending")
	TEST_ASSERT(!brain.queue_navigation_path_to_turf(moved_destination), "Direct request bypassed the pending-search guard")
	TEST_ASSERT_EQUAL(brain.navigation_generation, generation, "Retargeting invalidated the accepted callback")
	TEST_ASSERT_EQUAL(request.finish, first_destination, "Retargeting replaced the pending destination")
	TEST_ASSERT(explored in request.visited_nodes, "Retargeting erased the search frontier")
	TEST_ASSERT_EQUAL(request.prev[explored], start, "Retargeting erased completed search work")

	// Match the subsystem's completion order: callback first, then request deletion.
	var/list/completed_path = list(first_destination, explored)
	request.to_return.Invoke(completed_path)
	TEST_ASSERT_EQUAL(brain.current_path, completed_path, "The original callback no longer installed its completed path")
	TEST_ASSERT_NULL(brain.navigation_request, "Completed callback retained request ownership")
	TEST_ASSERT_EQUAL(SSpathfinding.hash_path[owner], request, "Callback removed the request before the subsystem could finish it")
	qdel(request)
	brain.clear_navigation_path()
	brain.next_path_generation = world.time + 1 SECONDS
	TEST_ASSERT(!brain.should_queue_navigation_path(moved_destination), "An empty path bypassed the request deadline")
	TEST_ASSERT(!brain.queue_navigation_path_to_turf(moved_destination), "Direct request bypassed the request deadline")
	TEST_ASSERT(!(owner in SSpathfinding.hash_path), "Throttled request entered the pathfinding queue")
	brain.next_path_generation = world.time
	TEST_ASSERT(brain.queue_navigation_path_to_turf(moved_destination), "Navigation did not resume at its request deadline")
	brain.clear_navigation_path()

/datum/unit_test/human_ai_navigation_request_cancel/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/destination = get_step(get_step(start, NORTH), NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	TEST_ASSERT(brain.queue_navigation_path_to_turf(destination), "Initial cancellation fixture could not queue a path")
	var/datum/xeno_pathinfo/request = brain.navigation_request
	var/datum/callback/completion = request.to_return
	SSpathfinding.current_processing |= request
	brain.clear_navigation_path()
	TEST_ASSERT(QDELETED(request), "Canceled navigation left its search alive")
	TEST_ASSERT(!(owner in SSpathfinding.hash_path), "Canceled navigation remained in the pathfinding hash")
	TEST_ASSERT(!(request in SSpathfinding.paths_to_calculate), "Canceled navigation remained queued")
	TEST_ASSERT(!(request in SSpathfinding.current_processing), "Canceled navigation remained in the current processing snapshot")
	completion.Invoke(list(destination))
	TEST_ASSERT_NULL(brain.current_path, "Canceled completion restored a stale path")

	brain.next_path_generation = 0
	TEST_ASSERT(brain.queue_navigation_path_to_turf(destination), "Cancellation prevented the next request")
	request = brain.navigation_request
	SSpathfinding.current_processing |= request
	// Component teardown detaches the owner before destroying its brain.
	brain.tied_human = null
	brain.clear_navigation_path()
	TEST_ASSERT(QDELETED(request), "Detached brain failed to cancel its owned request")
	TEST_ASSERT(!(owner in SSpathfinding.hash_path), "Detached brain retained a pathfinding hash entry")
	TEST_ASSERT(!(request in SSpathfinding.paths_to_calculate), "Detached brain retained a queued request")
	TEST_ASSERT(!(request in SSpathfinding.current_processing), "Detached brain retained a processing request")
	brain.tied_human = owner

/datum/unit_test/human_ai_navigation_emergency_preemption/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/routine_destination = get_step(get_step(start, NORTH), NORTH)
	var/turf/escape_destination = get_step(get_step(start, EAST), EAST)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	TEST_ASSERT(brain.queue_navigation_path_to_turf(routine_destination), "Emergency fixture could not queue routine navigation")
	var/datum/xeno_pathinfo/routine_request = brain.navigation_request
	var/obj/item/explosive/grenade/grenade = allocate(/obj/item/explosive/grenade/high_explosive, start)
	grenade.active = TRUE
	brain.active_grenade_found = grenade
	brain.next_path_generation = world.time + 5 SECONDS
	COOLDOWN_START(brain, no_path_found_cooldown, 5 SECONDS)
	TEST_ASSERT(brain.queue_navigation_path_to_turf(escape_destination), "Live grenade escape waited behind routine pathfinding or its cooldown")
	TEST_ASSERT(QDELETED(routine_request), "Emergency preemption retained the unrelated search")
	var/datum/xeno_pathinfo/emergency_request = brain.navigation_request
	TEST_ASSERT_EQUAL(emergency_request.finish, escape_destination, "Emergency request did not use its escape destination")
	TEST_ASSERT_EQUAL(brain.navigation_request_grenade, grenade, "Emergency request lost its threat identity")
	brain.next_path_generation = 0
	COOLDOWN_RESET(brain, no_path_found_cooldown)
	TEST_ASSERT(!brain.queue_navigation_path_to_turf(routine_destination), "The same emergency repeatedly restarted its pending search")
	TEST_ASSERT_EQUAL(brain.navigation_request, emergency_request, "Emergency retargeting replaced accepted work")
	brain.clear_navigation_path()
	grenade.active = FALSE

/datum/unit_test/human_ai_pursuit_safe_arrival/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/observed = get_step(start, NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	brain.settings_snapshot = human_ai_settings_preset("hard")
	brain.settings_snapshot["pursuit_return"] = FALSE
	brain.settings_snapshot["pursuit_radius"] = 1
	brain.settings_snapshot["pursuit_points"] = 1
	var/datum/ai_action/chase_target/action = allocate(/datum/ai_action/chase_target, brain)
	for(var/obstacle_type in list(/obj/structure/machinery/door/firedoor, /obj/structure/barricade/metal))
		var/obj/structure/obstacle = allocate(obstacle_type, observed)
		if(istype(obstacle, /obj/structure/machinery/door))
			obstacle.density = FALSE
			obstacle.opacity = FALSE
		brain.pursuit_observed_turf = observed
		brain.pursuit_observed_at = world.time
		brain.pursuit_consumed_at = -1
		brain.pursuit_start()
		TEST_ASSERT_EQUAL(brain.pursuit_goal, observed, "Safe arrival changed the raw observed goal")
		TEST_ASSERT_EQUAL(brain.human_ai_get_safe_standing_turf_near(observed), start, "Fixture did not normalize scenery to the owner's safe floor")
		TEST_ASSERT(brain.pursuit_has_reached_goal(), "Pursuit did not recognize its navigation endpoint beside scenery")
		action.trigger_action()
		TEST_ASSERT(brain.pursuit_inspecting, "Arrival beside scenery failed to begin inspection")
		TEST_ASSERT_EQUAL(brain.pursuit_anchor, observed, "Inspection moved the raw search anchor")
		TEST_ASSERT(brain.pursuit_visited[observed], "Inspection did not mark the raw observed position as visited")
		TEST_ASSERT_EQUAL(owner.loc, start, "Arrival recognition moved the NPC onto or through scenery")
		TEST_ASSERT_NULL(brain.navigation_request, "Already-reached scenery endpoint queued a path")
		brain.pursuit_clear_search()
		qdel(obstacle)

/datum/unit_test/human_ai_pursuit_safe_arrival_distance/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/observed = get_step(get_step(get_step(start, NORTH), NORTH), NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/obj/structure/machinery/door/firedoor/door = allocate(/obj/structure/machinery/door/firedoor, observed)
	door.density = FALSE
	door.opacity = FALSE
	brain.pursuit_set_goal(observed)
	TEST_ASSERT_NOTNULL(brain.human_ai_get_safe_standing_turf_near(observed), "Distant scenery fixture had no safe endpoint")
	TEST_ASSERT(!brain.pursuit_has_reached_goal(), "Pursuit accepted a distant safe endpoint as reached")
	TEST_ASSERT_EQUAL(owner.loc, start, "Checking distant arrival moved the NPC")
	brain.pursuit_set_goal(null)
	TEST_ASSERT(!brain.pursuit_has_reached_goal(), "Missing pursuit goal was accepted as reached")
