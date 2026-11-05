/datum/unit_test/human_ai_pursuit_team/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/list/brains = list()
	for(var/i in 1 to 3)
		var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
		var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
		brain.settings_snapshot = human_ai_settings_preset("hard")
		brains += brain
	var/datum/human_ai_squad/squad = SShuman_ai.create_new_squad()
	allocated += squad
	for(var/datum/human_ai_brain/brain as anything in brains)
		squad.add_to_squad(brain)
	var/datum/human_ai_brain/scout = brains[1]
	var/datum/human_ai_brain/cover = brains[2]
	var/datum/human_ai_brain/flank = brains[3]
	flank.tied_human.forceMove(get_step(get_step(start, EAST), EAST))
	scout.settings_snapshot["pursuit_share_radius"] = 1
	var/mob/living/carbon/human/enemy = allocate(/mob/living/carbon/human, get_step(start, NORTH))
	scout.pursuit_record_observation(enemy)
	TEST_ASSERT_EQUAL(cover.pursuit_observed_turf, get_turf(enemy), "Nearby squadmate received no report")
	TEST_ASSERT_NULL(flank.pursuit_observed_turf, "Report exceeded configured range")
	TEST_ASSERT_NULL(cover.current_target, "Shared report assigned a live target")
	scout.settings_snapshot["pursuit_share_radius"] = 7
	scout.pursuit_next_report = 0
	scout.pursuit_record_observation(enemy)
	TEST_ASSERT_EQUAL(flank.pursuit_observed_turf, get_turf(enemy), "In-range squadmate received no report")
	TEST_ASSERT_EQUAL(scout.pursuit_choose_role(), 0, "First member was not scout")
	TEST_ASSERT_EQUAL(cover.pursuit_choose_role(), 1, "Second member was not cover")
	TEST_ASSERT_EQUAL(flank.pursuit_choose_role(), 2, "Third member was not flanker")
	flank.pursuit_start()
	TEST_ASSERT(flank.pursuit_goal && flank.pursuit_goal != flank.pursuit_anchor, "Flanker did not choose a lateral waypoint")
	cover.settings_snapshot["pursuit_share"] = FALSE
	cover.pursuit_observed_turf = null
	cover.pursuit_observed_at = -1
	scout.pursuit_next_report = 0
	scout.pursuit_record_observation(enemy)
	TEST_ASSERT_NULL(cover.pursuit_observed_turf, "Disabled reporting accepted a report")

/datum/unit_test/human_ai_turf_destinations/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next_tile = get_step(start, NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/obj/structure/bed/chair/chair = allocate(/obj/structure/bed/chair, next_tile)
	var/obj/structure/machinery/door/firedoor/shutter = allocate(/obj/structure/machinery/door/firedoor, next_tile)
	var/obj/effect/decal/cleanable/blood/splatter/blood = allocate(/obj/effect/decal/cleanable/blood/splatter, next_tile)
	chair.density = FALSE
	shutter.density = FALSE
	for(var/atom/object as anything in list(chair, shutter, blood))
		TEST_ASSERT(!brain.human_ai_turf_is_safe(object), "Scenery accepted as a turf")
		TEST_ASSERT_NULL(brain.human_ai_get_safe_standing_turf_near(object), "Scenery normalized as a destination")
		TEST_ASSERT(!brain.move_to_next_turf(object), "Navigation accepted an object")
		TEST_ASSERT(!brain.complete_adjacent_move_to_turf(object), "Adjacent movement accepted an object")
		TEST_ASSERT_EQUAL(owner.loc, start, "NPC entered scenery")
	TEST_ASSERT(brain.complete_adjacent_move_to_turf(next_tile), "Nondense scenery blocked normal turf transit")
	TEST_ASSERT_EQUAL(owner.loc, next_tile, "NPC did not remain directly on the turf")


/datum/unit_test/human_ai_pursuit/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/observed = get_step(start, NORTH)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/mob/living/carbon/human/enemy = allocate(/mob/living/carbon/human, observed)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	brain.settings_snapshot = human_ai_settings_preset("hard")
	brain.pursuit_record_observation(enemy)
	var/turf/second = get_step(observed, EAST)
	enemy.forceMove(second)
	brain.pursuit_record_observation(enemy)
	TEST_ASSERT_EQUAL(brain.pursuit_observed_heading, EAST, "Observed movement did not establish heading")
	enemy.forceMove(get_step(second, NORTH))
	TEST_ASSERT_EQUAL(brain.pursuit_observed_turf, second, "Unobserved enemy movement leaked into memory")
	TEST_ASSERT(brain.pursuit_can_start(), "Fresh observation did not allow search")
	brain.in_cover = TRUE
	brain.pursuit_update()
	TEST_ASSERT(!brain.in_cover, "Stale cover prevented eligible lost-contact search")
	brain.pursuit_start()
	TEST_ASSERT_EQUAL(brain.pursuit_deadline, world.time + 10 SECONDS, "Approach did not get a separate budget")
	var/total_deadline = brain.pursuit_total_deadline
	TEST_ASSERT_EQUAL(brain.pursuit_goal, second, "Solo search did not begin at last seen position")
	TEST_ASSERT_EQUAL(brain.pursuit_search_heading, EAST, "Search ignored observed heading")
	var/turf/point = brain.pursuit_pick_point()
	if(point)
		TEST_ASSERT(get_dist(point, second) <= brain.setting("pursuit_radius"), "Search candidate escaped radius")
		brain.pursuit_visited[point] = TRUE
		TEST_ASSERT_NOTEQUAL(brain.pursuit_pick_point(), point, "Search repeated a visited point")
	brain.pursuit_search_depth = brain.setting("pursuit_radius")
	TEST_ASSERT_NULL(brain.pursuit_pick_point(), "Directional search exceeded its depth limit")
	brain.settings_snapshot["pursuit_predict"] = FALSE
	brain.pursuit_start()
	TEST_ASSERT_EQUAL(brain.pursuit_search_heading, get_dir(start, second), "Prediction off did not use approach direction")
	brain.settings_snapshot["pursuit_predict"] = TRUE
	owner.forceMove(second)
	brain.pursuit_next_point()
	TEST_ASSERT(brain.pursuit_inspecting, "Anchor arrival did not start inspection")
	TEST_ASSERT_EQUAL(brain.pursuit_deadline, min(world.time + brain.setting("chase_time") * 10, total_deadline), "Inspection deadline is incorrect")
	owner.forceMove(start)
	brain.settings_snapshot["pursuit_enabled"] = FALSE
	brain.pursuit_update()
	TEST_ASSERT(!brain.pursuit_active && !brain.pursuit_returning && !brain.pursuit_can_start(), "Master off did not cancel search")
	brain.settings_snapshot["pursuit_enabled"] = TRUE
	TEST_ASSERT(!brain.pursuit_receive_report(second, brain.pursuit_consumed_at, EAST), "Consumed report restarted search")
	brain.pursuit_observed_at = world.time - 1000
	brain.pursuit_consumed_at = -1
	TEST_ASSERT(!brain.pursuit_can_start(), "Expired memory started search")
	brain.pursuit_observed_at = world.time
	brain.pursuit_consumed_at = -1
	brain.pursuit_start()
	owner.forceMove(observed)
	brain.pursuit_finish()
	TEST_ASSERT(brain.pursuit_returning && brain.pursuit_goal == start, "Search did not return to origin without an order")
	brain.pursuit_clear_search()
	brain.pursuit_consumed_at = -1
	var/datum/ai_order/order = allocate(/datum/ai_order)
	brain.current_order = order
	brain.pursuit_start()
	brain.pursuit_finish()
	TEST_ASSERT(brain.current_order == order && !brain.in_combat && !brain.pursuit_returning, "Completion replaced existing order")
	brain.current_order = null
	brain.pursuit_consumed_at = -1
	brain.pursuit_start()
	var/turf/door_turf = get_step(observed, EAST)
	allocate(/obj/structure/machinery/door/airlock, door_turf)
	TEST_ASSERT(brain.pursuit_caution(door_turf), "Door did not trigger caution pause")
	brain.pursuit_pause_until = 0
	TEST_ASSERT(!brain.pursuit_caution(door_turf), "Same position paused repeatedly")
	brain.pursuit_clear_search()
	brain.pursuit_observed_at = -1
	brain.pursuit_consumed_at = -1
	TEST_ASSERT(brain.pursuit_receive_report(second, world.time, EAST), "Fresh report rejected")
	TEST_ASSERT_NULL(brain.current_target, "Report granted a hidden shooting target")
	TEST_ASSERT(!brain.pursuit_receive_report(start, world.time - 1, WEST), "Older report replaced newer observation")
	var/list/legacy = human_ai_settings_preset()
	for(var/key in legacy.Copy())
		if(findtext(key, "pursuit_") == 1)
			legacy -= key
	TEST_ASSERT(human_ai_settings_import(legacy, 5), "Version5 migration failed")
	TEST_ASSERT(!human_ai_settings_import(legacy, 6), "Version6 accepted incomplete pursuit profile")

/datum/unit_test/human_ai_settings_schema/Run()
	for(var/level in list("easy", "medium", "hard"))
		TEST_ASSERT(human_ai_settings_validate(human_ai_settings_preset(level)), "Invalid built-in difficulty profile")
	var/list/profile = human_ai_settings_preset()
	var/list/copy = human_ai_settings_validate(profile)
	copy["medicine"] = FALSE
	TEST_ASSERT(profile["medicine"], "Validation returned an alias")
	TEST_ASSERT(!human_ai_settings_valid_value("unknown", TRUE), "Unknown control accepted")
	TEST_ASSERT(!human_ai_settings_valid_value("fuse_reserve", 0), "Unsafe fuse reserve accepted")
	TEST_ASSERT(!human_ai_settings_valid_value("medicine", 0.5), "Fractional boolean accepted")
	TEST_ASSERT(!human_ai_settings_validate(list("medicine" = TRUE)), "Incomplete profile accepted")
	TEST_ASSERT(!human_ai_settings_validate(list("medicine" = FALSE)), "Partial global profile accepted")
	var/datum/human_ai_personal_slots/slots = allocate(/datum/human_ai_personal_slots, null)
	TEST_ASSERT_EQUAL(length(slots.slots), 3, "Personal slot limit changed")
	TEST_ASSERT(slots.valid_name("Мой профиль 3"), "Cyrillic personal name rejected")
	TEST_ASSERT(!slots.valid_name("../other"), "Invalid personal name accepted")
	TEST_ASSERT(!slots.valid_name("   "), "Blank name accepted")

/datum/unit_test/human_ai_settings_lifecycle/Run()
	var/datum/human_ai_settings_service/original = GLOB.human_ai_settings
	var/datum/human_ai_settings_service/service = allocate(/datum/human_ai_settings_service)
	service.loaded = TRUE
	service.profile = human_ai_settings_preset()
	GLOB.human_ai_settings = service
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	service.apply_global(human_ai_settings_preset("hard"), service.revision)
	var/inherited = brain.setting("reaction") == 0.3 && brain.setting("medicine")
	var/list/strong_profile = human_ai_settings_preset()
	strong_profile["health_percent"] = 300
	service.apply_global(strong_profile, service.revision)
	var/triple_health = owner.maxHealth == owner.species.total_health * 3 && owner.health == owner.maxHealth
	service.apply_global(human_ai_settings_preset("hard"), service.revision)
	owner.stat = DEAD
	var/dead_revision = brain.settings_revision
	service.apply_global(human_ai_settings_preset("easy"), service.revision)
	var/dead_untouched = brain.settings_revision == dead_revision && brain.setting("reaction") == 0.3
	var/dead_rejected = !brain.sync_settings(TRUE)
	owner.stat = CONSCIOUS
	brain.sync_settings()
	var/revived = brain.setting("reaction") == 1.2 && !brain.setting("drugs")
	var/mob/living/carbon/human/new_owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/new_brain = allocate(/datum/human_ai_brain, new_owner)
	var/new_inherits = new_brain.setting("reaction") == 1.2
	var/stale_rejected = !service.apply_global(human_ai_settings_preset(), service.revision - 1)
	var/datum/ai_action/emergency = GLOB.AI_actions[/datum/ai_action/throw_back_nade]
	var/escape_available = brain.settings_allow_action(emergency)
	GLOB.human_ai_settings = original
	TEST_ASSERT(inherited, "Living NPC did not adopt global profile")
	TEST_ASSERT(triple_health, "Global health setting did not change the actual health pool")
	TEST_ASSERT(dead_untouched && dead_rejected, "Dead NPC settings were modified")
	TEST_ASSERT(revived && new_inherits, "Living lifecycle did not inherit latest settings")
	TEST_ASSERT(stale_rejected, "Stale editor overwrote current settings")
	TEST_ASSERT(escape_available, "Disabling throwback disabled emergency escape")

/datum/unit_test/human_ai_settings_help_and_migration/Run()
	var/list/schema = human_ai_settings_schema()
	for(var/key in schema)
		var/list/definition = schema[key]
		if(!definition["boolean"])
			TEST_ASSERT(length(human_ai_settings_help(key)), "Numeric control lacks help: [key]")
	var/list/old_profile = human_ai_settings_preset()
	old_profile -= "grenade_chance"
	old_profile -= "stealth_enabled"
	old_profile -= "health_percent"
	old_profile -= "grenade_safety"
	old_profile -= "throwback_safety"
	old_profile -= "scatter"
	old_profile -= "combat_spacing"
	old_profile["reaction"] = 2
	var/list/migrated = human_ai_settings_import(old_profile, 1)
	TEST_ASSERT(migrated && migrated["reaction"] == 2 && migrated["grenade_chance"] == 100 && migrated["stealth_enabled"], "Old saved profile failed migration")
	TEST_ASSERT(!("grenade_chance" in old_profile), "Migration mutated saved source")
	old_profile -= "medicine"
	TEST_ASSERT(!human_ai_settings_import(old_profile, 1), "Migration accepted arbitrary partial profile")
	TEST_ASSERT(!human_ai_settings_valid_value("grenade_chance", -1), "Negative probability accepted")
	TEST_ASSERT(!human_ai_settings_valid_value("grenade_chance", 101), "Probability over 100 accepted")
	TEST_ASSERT(human_ai_settings_valid_value("accuracy", 3), "Increased accuracy rejected")
	TEST_ASSERT(human_ai_settings_valid_value("health_percent", 300), "Triple health rejected")
	TEST_ASSERT_EQUAL(migrated["health_percent"], 100, "Legacy health default changed")
	TEST_ASSERT_EQUAL(migrated["scatter"], 1, "Legacy scatter default changed")
	TEST_ASSERT_EQUAL(migrated["combat_spacing"], FALSE, "Legacy spacing must default off")
	for(var/level in list("easy", "medium", "hard"))
		var/list/preset = human_ai_settings_preset(level)
		TEST_ASSERT_EQUAL(preset["combat_spacing"], FALSE, "Spacing enabled in preset [level]")
	var/list/legacy_spacing = human_ai_settings_preset()
	legacy_spacing -= "combat_spacing"
	var/list/current_spacing = human_ai_settings_import(legacy_spacing, 4)
	TEST_ASSERT_EQUAL(current_spacing["combat_spacing"], FALSE, "Version4 spacing migration failed")
	TEST_ASSERT(!human_ai_settings_import(legacy_spacing, 5), "Current profile accepted missing spacing")
	TEST_ASSERT(human_ai_settings_valid_value("scatter", 0) && human_ai_settings_valid_value("scatter", 3), "Scatter limits rejected")
	TEST_ASSERT(!human_ai_settings_valid_value("scatter", -0.1) && !human_ai_settings_valid_value("scatter", 3.1), "Invalid scatter accepted")
	var/list/v3_profile = human_ai_settings_preset()
	v3_profile -= "scatter"
	var/list/v4_profile = human_ai_settings_import(v3_profile, 3)
	TEST_ASSERT_EQUAL(v4_profile["scatter"], 1, "Version3 scatter migration failed")
	TEST_ASSERT(!human_ai_settings_import(v3_profile, 4), "Current version accepted missing scatter")
	TEST_ASSERT(migrated["grenade_safety"] && migrated["throwback_safety"], "Legacy safety not preserved")

/datum/unit_test/human_ai_pending_oral_dose/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, patient)
	brain.settings_snapshot = human_ai_settings_preset()
	var/obj/item/reagent_container/hypospray/autoinjector/tricord/injector = allocate(/obj/item/reagent_container/hypospray/autoinjector/tricord)
	var/datum/reagent/medicine = injector.reagents.reagent_list[1]
	var/datum/reagents/vessel/pending = allocate(/datum/reagents/vessel, 100)
	pending.add_reagent(medicine.id, medicine.overdose)
	pending.human_ai_track_ingestion(patient)
	TEST_ASSERT(!brain.can_safely_administer_reagents(injector, patient, injector.amount_per_transfer_from_this), "Pending oral dose was invisible to injector safety")
	qdel(pending)
	TEST_ASSERT_EQUAL(patient.human_ai_pending_dose(medicine.id), 0, "Deleted vessel leaked a pending dose")

/datum/unit_test/human_ai_global_grenade_and_stealth/Run()
	var/datum/human_ai_settings_service/original = GLOB.human_ai_settings
	var/datum/human_ai_settings_service/service = allocate(/datum/human_ai_settings_service)
	service.loaded = TRUE
	service.profile = human_ai_settings_preset()
	GLOB.human_ai_settings = service
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	owner.dir = SOUTH
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/rear_hidden = !brain.human_ai_can_visually_detect_target(target)
	var/list/profile = human_ai_settings_preset()
	profile["grenade_chance"] = 0
	profile["stealth_enabled"] = FALSE
	service.apply_global(profile, service.revision)
	brain.begin_combat_grenade_decision()
	var/zero_rejected = !brain.should_attempt_combat_grenade()
	var/rear_visible = brain.human_ai_can_visually_detect_target(target)
	profile["grenade_chance"] = 100
	service.apply_global(profile, service.revision)
	var/no_reroll = !brain.should_attempt_combat_grenade()
	brain.begin_combat_grenade_decision()
	var/hundred_selected = brain.should_attempt_combat_grenade()
	brain.consume_combat_grenade_decision()
	var/consumed = !brain.should_attempt_combat_grenade()
	GLOB.human_ai_settings = original
	TEST_ASSERT(rear_hidden && rear_visible, "Global stealth switch did not control rear-facing exclusion")
	TEST_ASSERT(zero_rejected && no_reroll && hundred_selected && consumed, "Global grenade probability broke encounter caching")
