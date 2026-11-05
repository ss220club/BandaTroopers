/datum/unit_test/human_ai_performance_core/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	brain.combat_voiceline_cooldown_time = 1 HOURS
	brain.in_combat = TRUE
	brain.enter_combat()
	var/timer_id = brain.combat_decay_timer
	TEST_ASSERT(timer_id, "Combat decay timer was not scheduled")
	for(var/index in 1 to 350)
		brain.enter_combat()
		TEST_ASSERT_EQUAL(brain.combat_decay_timer, timer_id, "Combat refresh replaced a pending timer")
	brain.reset_ai()
	TEST_ASSERT_NULL(brain.combat_decay_timer, "Reset left a combat timer alive")
	TEST_ASSERT(!(timer_id in SStimer.timer_id_dict), "Reset kept the original combat timer registered")
	brain.in_combat = TRUE
	brain.combat_decay_deadline = world.time + 1 SECONDS
	brain.check_combat_decay()
	TEST_ASSERT(brain.in_combat && brain.combat_decay_timer, "Combat ended before its refreshed deadline")
	deltimer(brain.combat_decay_timer)
	brain.combat_decay_timer = null
	brain.combat_decay_deadline = world.time
	brain.check_combat_decay()
	TEST_ASSERT(!brain.in_combat, "Combat did not end at its expired deadline")
	brain.setup_detection_radius()
	var/list/sensors = brain.detection_turfs
	brain.setup_detection_radius()
	TEST_ASSERT_EQUAL(length(brain.detection_turfs ^ sensors), 0, "Same-position sensor setup changed its footprint")
	var/turf/destination = get_step(start, NORTH)
	owner.forceMove(destination)
	var/list/expected = list()
	for(var/turf/open/floor in range(1, destination))
		expected += floor
	TEST_ASSERT_EQUAL(length(brain.detection_turfs ^ expected), 0, "Sensor delta did not match the new neighborhood")
	brain.clear_detection_radius()
	TEST_ASSERT_EQUAL(length(brain.detection_turfs), 0, "Sensor cleanup kept old turfs")
	var/datum/ai_action/action = GLOB.AI_actions[/datum/ai_action/fire_at_target]
	var/list/conflicts = action.get_conflicts(brain)
	var/count = length(conflicts)
	TEST_ASSERT(count > 0, "Expected hand-slot conflicts")
	conflicts.Cut()
	TEST_ASSERT_EQUAL(length(action.get_conflicts(brain)), count, "Caller modified shared conflict cache")
	TEST_ASSERT_EQUAL(length(SShuman_ai.performance_headers()), length(SShuman_ai.performance_values()), "Performance CSV columns do not match values")

/datum/human_ai_brain/sensor_performance_test
	var/list/observed_sources = list()

/datum/human_ai_brain/sensor_performance_test/on_detection_turf_enter(datum/source, atom/movable/entering)
	SIGNAL_HANDLER
	observed_sources += source

/datum/unit_test/human_ai_sensor_signal_repair/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/sensor_performance_test/brain = allocate(/datum/human_ai_brain/sensor_performance_test, owner)
	brain.observed_sources.Cut()
	SEND_SIGNAL(start, COMSIG_TURF_ENTERED, owner)
	TEST_ASSERT_EQUAL(length(brain.observed_sources), 1, "Initial sensor did not receive turf signals")
	start = start.ChangeTurf(start.type)
	brain.setup_detection_radius()
	brain.observed_sources.Cut()
	SEND_SIGNAL(start, COMSIG_TURF_ENTERED, owner)
	TEST_ASSERT_EQUAL(length(brain.observed_sources), 1, "ChangeTurf lost the sensor subscription")
	var/turf/overlap = get_step(start, NORTH)
	var/turf/destination = get_step(overlap, NORTH)
	owner.forceMove(destination)
	brain.observed_sources.Cut()
	SEND_SIGNAL(start, COMSIG_TURF_ENTERED, owner)
	TEST_ASSERT_EQUAL(length(brain.observed_sources), 0, "Old sensor footprint still receives signals")
	SEND_SIGNAL(destination, COMSIG_TURF_ENTERED, owner)
	SEND_SIGNAL(overlap, COMSIG_TURF_ENTERED, owner)
	TEST_ASSERT_EQUAL(length(brain.observed_sources), 2, "New or retained sensor footprint lost signal delivery")
