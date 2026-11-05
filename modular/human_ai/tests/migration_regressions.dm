/datum/unit_test/human_ai_target_replacement/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/mob/living/carbon/human/old_target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/new_target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	brain.set_target(old_target)
	brain.set_target(new_target)
	SEND_SIGNAL(old_target, COMSIG_MOB_DEATH)
	TEST_ASSERT_EQUAL(brain.current_target, new_target, "Old target death cleared the replacement target")
	brain.on_target_delete(old_target)
	TEST_ASSERT_EQUAL(brain.current_target, new_target, "Stale callback cleared the replacement target")

/datum/unit_test/human_ai_navigation_generation/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/generation = brain.navigation_generation
	brain.clear_navigation_path()
	brain.accept_navigation_path(generation, list(run_loc_floor_bottom_left))
	TEST_ASSERT_NULL(brain.current_path, "Canceled request restored a stale path")
	brain.no_path_found = TRUE
	brain.consume_no_path_failure()
	brain.no_path_found = TRUE
	brain.consume_no_path_failure()
	TEST_ASSERT_EQUAL(brain.no_path_found_amount, 2, "Consecutive failures did not accumulate")
	brain.on_navigation_success()
	TEST_ASSERT_EQUAL(brain.no_path_found_amount, 0, "Successful movement did not reset failures")

/datum/unit_test/human_ai_emergency_order_and_fuse/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/obj/item/explosive/grenade/high_explosive/grenade = allocate(/obj/item/explosive/grenade/high_explosive, run_loc_floor_bottom_left)
	grenade.active = TRUE
	grenade.fuse_type = TIMED_FUSE
	grenade.timed_fuse_deadline = world.time + 1 SECONDS
	brain.active_grenade_found = grenade
	brain.can_throw_back_grenades = TRUE
	brain.settings_snapshot["throwback"] = TRUE // Test fixture, not a production override API.
	brain.hold_position = TRUE
	TEST_ASSERT(!brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/throw_back_nade]), "Hold blocked emergency escape")
	TEST_ASSERT(!brain.can_attempt_live_grenade_throwback(grenade), "NPC attempted an unsafe short-fuse pickup")
	brain.quick_approach = get_step(run_loc_floor_bottom_left, NORTH)
	TEST_ASSERT_EQUAL(GLOB.AI_actions[/datum/ai_action/quick_approach].get_weight(brain), 0, "Approach displaced grenade survival")
	brain.grenading_allowed = FALSE
	TEST_ASSERT_EQUAL(GLOB.AI_actions[/datum/ai_action/fire_underbarrel_grenade].get_weight(brain), 0, "Underbarrel ignored explosive policy")
	grenade.active = FALSE

/datum/unit_test/human_ai_treatment_cancel/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/datum/ai_action/treat_self/action = allocate(/datum/ai_action/treat_self, brain)
	brain.healing_someone = TRUE
	var/generation = brain.treatment_generation
	qdel(action)
	TEST_ASSERT(!brain.treatment_can_continue(generation, owner), "Canceled medical action retained permission")
