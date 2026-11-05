/datum/unit_test/human_ai_obstacle_permissions/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/neighbor = get_step(start, NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/datum/human_ai_obstacle_policy/original = GLOB.human_ai_obstacle_policy
	var/datum/human_ai_obstacle_policy/policy = allocate(/datum/human_ai_obstacle_policy)
	GLOB.human_ai_obstacle_policy = policy
	var/obj/structure/barricade/barricade = allocate(/obj/structure/barricade, neighbor)
	policy.set_permission(HUMAN_AI_OBSTACLE_DESTROY, FALSE)
	var/climb_allowed = barricade.human_ai_select_obstacle_action(brain) == HUMAN_AI_OBSTACLE_CLIMB_BARRICADE
	policy.set_permission(HUMAN_AI_OBSTACLE_CLIMB_BARRICADE, FALSE)
	var/path_denied = barricade.human_ai_obstacle(owner, brain, NORTH, neighbor) == INFINITY
	var/action_denied = !barricade.human_ai_act(owner, brain)
	var/not_moved = get_turf(owner) == start
	policy.set_permission(HUMAN_AI_OBSTACLE_CLIMB_BARRICADE, TRUE)
	policy.set_permission(HUMAN_AI_OBSTACLE_CLIMB_BARRICADE, FALSE, /obj/structure)
	barricade.human_ai_navigation_permissions = list(HUMAN_AI_OBSTACLE_CLIMB_BARRICADE = TRUE)
	var/type_denied = barricade.human_ai_obstacle(owner, brain, NORTH) == INFINITY
	var/invalid_denied = !policy.set_permission("invalid_action", TRUE)
	GLOB.human_ai_obstacle_policy = original
	TEST_ASSERT(climb_allowed, "A global destruction ban disabled climbing")
	TEST_ASSERT(path_denied && action_denied && not_moved, "Global policy failed planning/execution restrictions")
	TEST_ASSERT(type_denied && invalid_denied, "Global type deny or action validation failed")

/datum/unit_test/human_ai_obstacle_physics/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/neighbor = get_step(start, NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/obj/structure/unknown = allocate(/obj/structure, neighbor)
	unknown.density = TRUE
	unknown.climbable = FALSE
	unknown.breakable = FALSE
	unknown.human_ai_navigation_permissions = list(HUMAN_AI_OBSTACLE_DESTROY = TRUE)
	TEST_ASSERT_EQUAL(unknown.human_ai_obstacle(owner, brain, NORTH, neighbor), INFINITY, "Permission invented a physical destruction capability")
	TEST_ASSERT(!brain.human_ai_turf_is_safe(neighbor), "Scenery accepted as a final destination")
	var/turf/safe_destination = brain.human_ai_get_safe_standing_turf_near(neighbor)
	TEST_ASSERT(safe_destination && safe_destination != neighbor, "Unsafe destination was not normalized")
	TEST_ASSERT(brain.human_ai_turf_is_safe(safe_destination, ignore_owner = TRUE), "Destination normalization selected more scenery")
	unknown.human_ai_navigation_protected = TRUE
	TEST_ASSERT(!brain.obstacle_action_allowed(unknown, HUMAN_AI_OBSTACLE_DESTROY), "Explicit protection was overridden")
	var/obj/structure/machinery/door/poddoor/door = allocate(/obj/structure/machinery/door/poddoor, neighbor)
	door.stat |= NOPOWER
	door.density = TRUE
	TEST_ASSERT_EQUAL(door.human_ai_obstacle(owner, brain, NORTH), INFINITY, "NPC without crowbar planned a pry")

/datum/unit_test/human_ai_live_obstacle_policy/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/existing = allocate(/datum/human_ai_brain, owner)
	var/obj/structure/barricade/barricade = allocate(/obj/structure/barricade, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/human_ai_obstacle_policy/shared_policy = GLOB.human_ai_obstacle_policy
	var/previous = shared_policy.permissions[HUMAN_AI_OBSTACLE_CLIMB_BARRICADE]
	shared_policy.set_permission(HUMAN_AI_OBSTACLE_CLIMB_BARRICADE, FALSE)
	var/existing_observed_change = !existing.obstacle_action_allowed(barricade, HUMAN_AI_OBSTACLE_CLIMB_BARRICADE)
	var/mob/living/carbon/human/new_owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/new_brain = allocate(/datum/human_ai_brain, new_owner)
	var/new_observed_change = !new_brain.obstacle_action_allowed(barricade, HUMAN_AI_OBSTACLE_CLIMB_BARRICADE)
	// Restore shared state before any assertion can terminate this test.
	shared_policy.set_permission(HUMAN_AI_OBSTACLE_CLIMB_BARRICADE, previous)
	TEST_ASSERT(existing_observed_change && new_observed_change, "Existing/new NPCs did not read the same live policy")
