/datum/human_ai_brain/medical_performance_test
	var/treatment_candidates = 0
	var/visibility_checks = 0

/datum/human_ai_brain/medical_performance_test/can_treat_ally(mob/living/carbon/human/patient)
	treatment_candidates++
	return ..()

/datum/human_ai_brain/medical_performance_test/medical_target_in_view(mob/living/carbon/human/patient)
	visibility_checks++
	return ..()

/datum/unit_test/human_ai_medical_scan_filters/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human, start)
	medic.faction = FACTION_UNSC
	var/datum/human_ai_brain/medical_performance_test/brain = allocate(/datum/human_ai_brain/medical_performance_test, medic)
	brain.medical_view_distance = 2
	brain.settings_snapshot["heal_npcs"] = TRUE
	var/obj/item/stack/medical/advanced/bruise_pack/supply = allocate(/obj/item/stack/medical/advanced/bruise_pack, medic)
	brain.equipment_map[HUMAN_AI_HEALTHITEMS][supply] = medic
	var/mob/living/carbon/human/healthy = allocate(/mob/living/carbon/human, get_step(start, NORTH))
	healthy.faction = FACTION_UNSC
	var/mob/living/carbon/human/near_patient = allocate(/mob/living/carbon/human, get_step(start, EAST))
	near_patient.faction = FACTION_UNSC
	near_patient.adjustBruteLoss(10)
	var/mob/living/carbon/human/severe_patient = allocate(/mob/living/carbon/human, get_step(get_step(start, NORTH), NORTH))
	severe_patient.faction = FACTION_UNSC
	severe_patient.adjustBruteLoss(40)
	var/turf/far_turf = get_step(get_step(get_step(start, EAST), EAST), EAST)
	var/mob/living/carbon/human/far_patient = allocate(/mob/living/carbon/human, far_turf)
	far_patient.faction = FACTION_UNSC
	far_patient.adjustBruteLoss(60)
	TEST_ASSERT_EQUAL(brain.get_injured_ally(), severe_patient, "Medical scan did not preserve injury priority over distance")
	TEST_ASSERT_EQUAL(brain.treatment_candidates, 3, "Distant patient reached expensive treatment selection")
	TEST_ASSERT_EQUAL(brain.visibility_checks, 2, "Healthy or distant patient reached visibility enumeration")

	var/obj/container = allocate(/obj, get_turf(severe_patient))
	severe_patient.forceMove(container)
	var/expected_patient = brain.medical_target_in_view(severe_patient) ? severe_patient : near_patient
	TEST_ASSERT_EQUAL(brain.get_injured_ally(), expected_patient, "Medical optimization changed the contained patient's visibility contract")
	TEST_ASSERT(brain.medical_item_has_target(supply), "Nearby medicine no longer finds an actionable ally")

/datum/unit_test/human_ai_first_tile_fire_lane/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	owner.faction = FACTION_UNSC
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/turf/first_tile = get_step(start, EAST)
	var/mob/living/carbon/human/friendly = allocate(/mob/living/carbon/human, first_tile)
	friendly.faction = FACTION_UNSC
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, get_step(first_tile, EAST))
	hostile.faction = FACTION_COVENANT
	TEST_ASSERT(!brain.path_check(hostile), "Target acquisition skipped the friendly on the first fire-lane turf")
	friendly.forceMove(get_step(start, NORTH))
	TEST_ASSERT(brain.path_check(hostile), "Target acquisition rejected the cleared fire lane")

/datum/unit_test/human_ai_live_fire_lane/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	owner.faction = FACTION_UNSC
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	var/turf/first_tile = get_step(start, EAST)
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, get_step(first_tile, EAST))
	hostile.faction = FACTION_COVENANT
	var/datum/ai_action/fire_at_target/action = allocate(/datum/ai_action/fire_at_target, brain)
	TEST_ASSERT(action.firing_line_check(brain, hostile, listen = TRUE), "Initial fire lane was unexpectedly blocked")
	TEST_ASSERT(action.firing_line_check(brain, hostile, listen = TRUE), "Repeated fire lane check changed its result")
	var/obj/blocker = allocate(/obj, first_tile)
	blocker.density = TRUE
	blocker.unacidable = TRUE
	blocker.projectile_coverage = PROJECTILE_COVERAGE_HIGH
	TEST_ASSERT(!action.firing_line_check(brain, hostile, listen = TRUE), "Reused subscriptions hid a new dense projectile blocker")
	qdel(blocker)
	// Turf replacement clears registrations without changing the stored footprint.
	action.UnregisterSignal(first_tile, COMSIG_TURF_ENTERED)
	TEST_ASSERT(action.firing_line_check(brain, hostile, listen = TRUE), "Fire lane did not recover after losing a turf subscription")
	var/mob/living/carbon/human/friendly = allocate(/mob/living/carbon/human, get_step(start, NORTH))
	friendly.faction = FACTION_UNSC
	friendly.forceMove(first_tile)
	TEST_ASSERT(QDELETED(action), "Unchanged turf subscription stopped reacting to a friendly entering the lane")

/obj/item/weapon/gun/pistol/m4a3/human_ai_followup_test
	var/followup_calls = 0

/obj/item/weapon/gun/pistol/m4a3/human_ai_followup_test/start_fire(datum/source, atom/object, turf/location, control, params, bypass_checks = FALSE)
	SIGNAL_HANDLER
	followup_calls++
	return TRUE

/datum/unit_test/human_ai_delayed_fire_cancellation/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	owner.faction = FACTION_UNSC
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	brain.action_whitelist = list()
	var/obj/item/weapon/gun/pistol/m4a3/human_ai_followup_test/weapon = allocate(/obj/item/weapon/gun/pistol/m4a3/human_ai_followup_test, owner)
	brain.set_primary_weapon(weapon)
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, get_step(get_step(start, EAST), EAST))
	hostile.faction = FACTION_COVENANT
	brain.set_target(hostile)
	var/datum/ai_action/fire_at_target/action = allocate(/datum/ai_action/fire_at_target, brain)
	brain.ongoing_actions += action
	action.on_gun_fire(owner, weapon)
	TEST_ASSERT(action.followup_fire_timer, "Semi-auto fire did not schedule an action-owned followup")
	var/first_followup_timer = action.followup_fire_timer
	action.on_gun_fire(owner, weapon)
	TEST_ASSERT_EQUAL(action.followup_fire_timer, first_followup_timer, "Repeated shot signals leaked a second followup timer")
	var/mob/living/carbon/human/friendly = allocate(/mob/living/carbon/human, get_step(start, NORTH))
	friendly.faction = FACTION_UNSC
	friendly.forceMove(get_step(start, EAST))
	TEST_ASSERT(QDELETED(action), "Friendly entering the lane did not cancel the firing action")
	sleep(weapon.get_fire_delay() + 1)
	TEST_ASSERT_EQUAL(weapon.followup_calls, 0, "Cancelled firing action restarted its weapon from a stale timer")
	friendly.forceMove(get_step(start, NORTH))
	var/datum/ai_action/fire_at_target/offscreen_action = allocate(/datum/ai_action/fire_at_target, brain)
	brain.lose_target()
	brain.target_turf = get_turf(hostile)
	COOLDOWN_START(brain, fire_offscreen, 2 SECONDS)
	offscreen_action.fire_followup(weapon, hostile)
	TEST_ASSERT_EQUAL(weapon.followup_calls, 0, "Followup fired at a stale mob after losing the current target")
	offscreen_action.fire_followup(weapon, brain.target_turf)
	TEST_ASSERT_EQUAL(weapon.followup_calls, 1, "Followup lost the permitted offscreen suppression target")
	COOLDOWN_RESET(brain, fire_offscreen)
	offscreen_action.fire_followup(weapon, brain.target_turf)
	TEST_ASSERT_EQUAL(weapon.followup_calls, 1, "Followup fired after offscreen suppression expired")

/datum/unit_test/human_ai_grenade_flight_cancellation
	var/cancelled_during_flight = FALSE

/datum/unit_test/human_ai_grenade_flight_cancellation/proc/cancel_throw(datum/ai_action/throw_grenade/action)
	cancelled_during_flight = TRUE
	qdel(action)

/datum/unit_test/human_ai_grenade_flight_cancellation/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, start)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, owner)
	brain.action_whitelist = list()
	brain.combat_grenade_decision_made = TRUE
	brain.combat_grenade_selected = TRUE
	var/obj/item/explosive/grenade/high_explosive/grenade = allocate(/obj/item/explosive/grenade/high_explosive, owner)
	TEST_ASSERT(owner.put_in_active_hand(grenade), "Grenade cancellation fixture could not hold the grenade")
	grenade.active = TRUE
	var/datum/ai_action/throw_grenade/action = allocate(/datum/ai_action/throw_grenade, brain)
	brain.ongoing_actions += action
	var/turf/destination = get_step(get_step(get_step(start, EAST), EAST), EAST)
	addtimer(CALLBACK(src, PROC_REF(cancel_throw), action), 1)
	TEST_ASSERT(action.launch_grenade_to_target(owner, grenade, destination), "A launched grenade did not complete safely after action cancellation")
	TEST_ASSERT(cancelled_during_flight && QDELETED(action), "Grenade flight did not exercise action deletion while yielding")
	TEST_ASSERT(!brain.combat_grenade_selected, "Deleting an action in flight restored its already-used grenade decision")
