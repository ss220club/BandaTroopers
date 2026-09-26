// DemonicLynx for BandaMarines
#define HUMAN_AI_TEST_COVER_SCAN_LIMIT 198

/datum/unit_test/human_ai_core_behaviors

/datum/unit_test/human_ai_core_behaviors/Run()
	// SS220 EDIT - START: pre-equipped AI must keep its issued weapon instead of chasing floor loot
	var/mob/living/carbon/human/prearmed_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	prearmed_human.faction = FACTION_UNSC
	var/obj/item/weapon/gun/pistol/m4a3/issued_weapon = allocate(/obj/item/weapon/gun/pistol/m4a3, prearmed_human)
	prearmed_human.s_store = issued_weapon
	var/datum/human_ai_brain/prearmed_brain = allocate(/datum/human_ai_brain, prearmed_human)
	TEST_ASSERT_EQUAL(prearmed_brain.primary_weapon, issued_weapon, "Human AI did not recognize its pre-equipped suit-storage weapon as primary.")
	prearmed_brain.set_primary_weapon(null)
	prearmed_brain.add_secondary_weapon(issued_weapon)
	var/obj/item/weapon/gun/pistol/m4a3/floor_weapon = allocate(/obj/item/weapon/gun/pistol/m4a3, get_turf(prearmed_human))
	prearmed_brain.item_search(list(floor_weapon))
	TEST_ASSERT(!(floor_weapon in prearmed_brain.to_pickup), "Human AI queued a floor weapon while it had a usable issued weapon.")
	var/datum/ai_action/select_primary/prearmed_select_action = allocate(/datum/ai_action/select_primary, prearmed_brain)
	prearmed_select_action.trigger_action()
	TEST_ASSERT_EQUAL(prearmed_brain.primary_weapon, issued_weapon, "Human AI did not promote its carried issued weapon before considering floor loot.")
	// SS220 EDIT - END

	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	ai_human.faction = FACTION_UNSC
	// SS220 EDIT - START: reproduce the UPP RPG preset that carries rockets inside a suit-storage container
	var/obj/item/clothing/suit/marine/faction/UPP/standard/upp_armor = allocate(/obj/item/clothing/suit/marine/faction/UPP/standard, ai_human)
	ai_human.equip_to_slot_or_del(upp_armor, WEAR_JACKET)
	TEST_ASSERT_EQUAL(ai_human.wear_suit, upp_armor, "Human AI test could not equip UPP armor required for suit storage.")
	var/obj/item/storage/backpack/general_belt/upp/suit_ammo_storage = allocate(/obj/item/storage/backpack/general_belt/upp, ai_human)
	ai_human.equip_to_slot_or_del(suit_ammo_storage, WEAR_J_STORE)
	TEST_ASSERT_EQUAL(ai_human.s_store, suit_ammo_storage, "Human AI test could not equip the UPP suit-storage container.")
	var/obj/item/ammo_magazine/rocket/upp/at/spare_rocket = allocate(/obj/item/ammo_magazine/rocket/upp/at, ai_human)
	TEST_ASSERT(suit_ammo_storage.attempt_item_insertion(spare_rocket, FALSE, ai_human), "Human AI test could not preload a rocket into suit storage.")
	// SS220 EDIT - END
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, ai_human)
	TEST_ASSERT_EQUAL(brain.container_refs["suit_storage"], suit_ammo_storage, "Human AI did not register its pre-equipped suit-storage container.")
	TEST_ASSERT_EQUAL(brain.equipment_map[HUMAN_AI_AMMUNITION][spare_rocket], suit_ammo_storage, "Human AI did not index RPG ammunition inside suit storage.")

	var/turf/hostile_turf = get_step(run_loc_floor_bottom_left, EAST)
	TEST_ASSERT_NOTNULL(hostile_turf, "Human AI test area must contain an adjacent turf.")
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, hostile_turf)
	hostile.faction = FACTION_COVENANT

	TEST_ASSERT_EQUAL(brain.get_target(), hostile, "Human AI did not acquire an adjacent hostile living target.")
	brain.set_target(hostile)
	brain.in_combat = TRUE
	var/obj/item/weapon/gun/pistol/m4a3/sidearm = allocate(/obj/item/weapon/gun/pistol/m4a3, ai_human)
	brain.set_primary_weapon(sidearm)
	var/datum/ai_action/fire_at_target/fire_action = allocate(/datum/ai_action/fire_at_target, brain)
	TEST_ASSERT(fire_action.get_weight(brain) > 0, "Armed Human AI did not select its fire action against a valid hostile target.")

	var/obj/item/weapon/gun/smartgun/smartgun = allocate(/obj/item/weapon/gun/smartgun, ai_human)
	ai_human.put_in_active_hand(smartgun)
	smartgun.pull_time = world.time
	smartgun.wield_time = world.time
	smartgun.guaranteed_delay_time = world.time
	brain.set_primary_weapon(smartgun)
	TEST_ASSERT(!(smartgun.flags_item & WIELDED), "Human AI smartgun unexpectedly began the test already wielded.")
	TEST_ASSERT_EQUAL(fire_action.trigger_action(), ONGOING_ACTION_UNFINISHED, "Human AI smartgun preparation did not keep the fire action active.")
	TEST_ASSERT(smartgun.flags_item & WIELDED, "Human AI did not take its smartgun in both hands before firing.")
	smartgun.unwield(ai_human)
	ai_human.drop_held_item(smartgun)

	var/obj/item/weapon/gun/launcher/rocket/upp/rpg = allocate(/obj/item/weapon/gun/launcher/rocket/upp, ai_human)
	ai_human.put_in_active_hand(rpg)
	brain.set_primary_weapon(rpg)
	TEST_ASSERT(!brain.gun_data.disposable, "Reloadable Human AI RPG resolved to the disposable launcher appraisal.")
	TEST_ASSERT(!brain.should_reload(), "Loaded Human AI RPG incorrectly requested a reload before its first shot.")
	rpg.current_mag.current_rounds = 0
	var/datum/ai_action/reload/reload_action = allocate(/datum/ai_action/reload, brain)
	TEST_ASSERT_EQUAL(reload_action.primary_ammo_search(), spare_rocket, "Human AI UPP RPG reload did not find compatible ammunition in suit storage.")
	brain.add_secondary_weapon(sidearm)
	brain.tried_reload = TRUE
	var/datum/ai_action/select_primary/select_action = allocate(/datum/ai_action/select_primary, brain)
	TEST_ASSERT_EQUAL(select_action.get_weight(brain), 0, "Human AI tried to replace an empty RPG despite carrying a compatible rocket.")
	brain.equipment_map[HUMAN_AI_AMMUNITION] -= spare_rocket
	TEST_ASSERT(select_action.get_weight(brain) > 0, "Human AI did not permit a fallback weapon after RPG ammunition was exhausted.")

	var/turf/move_destination = get_step(run_loc_floor_bottom_left, NORTH)
	TEST_ASSERT_NOTNULL(move_destination, "Human AI test area must contain a movement destination.")
	TEST_ASSERT(brain.move_to_next_turf(move_destination), "Human AI rejected a valid adjacent movement request.")
	TEST_ASSERT_EQUAL(get_turf(ai_human), move_destination, "Human AI did not move onto the requested adjacent turf.")

	brain.lose_target()
	brain.in_combat = FALSE
	brain.target_turf = null
	brain.to_pickup.Cut()
	qdel(hostile)
	// SS220 EDIT - START: begin outside treatment range so the action must approach an occupied patient turf correctly
	var/turf/ally_turf = get_step(get_step(get_turf(ai_human), EAST), EAST)
	TEST_ASSERT_NOTNULL(ally_turf, "Human AI test area must contain a non-adjacent ally destination.")
	var/mob/living/carbon/human/injured_ally = allocate(/mob/living/carbon/human, ally_turf)
	injured_ally.faction = FACTION_UNSC
	injured_ally.adjustBruteLoss(20)
	TEST_ASSERT_NULL(injured_ally.get_ai_brain(), "Human AI player-compatible treatment fixture unexpectedly had an AI brain.") // SS220 EDIT: friendly players use this same human target path
	var/obj/item/storage/belt/medical/medical_belt = allocate(/obj/item/storage/belt/medical, ai_human)
	ai_human.equip_to_slot_or_del(medical_belt, WEAR_WAIST)
	brain.recalculate_containers()
	var/obj/item/stack/medical/advanced/bruise_pack/medical_supply = allocate(/obj/item/stack/medical/advanced/bruise_pack, ai_human)
	medical_supply.amount = 100
	TEST_ASSERT(medical_belt.attempt_item_insertion(medical_supply, FALSE, ai_human), "Human AI test could not place medical supplies in its source belt.")
	brain.equipment_map[HUMAN_AI_HEALTHITEMS][medical_supply] = "belt"
	var/datum/ai_action/treat_ally/treat_action = allocate(/datum/ai_action/treat_ally, brain)
	brain.ongoing_actions += treat_action
	// SS220 EDIT - START: moderate injuries and medical-only extended perception
	TEST_ASSERT((injured_ally.health / injured_ally.maxHealth) > 0.7, "Human AI moderate-injury fixture unexpectedly fell below the former health gate.")
	TEST_ASSERT(brain.medical_view_distance > brain.view_distance, "Human AI medical awareness is not larger than ordinary vision.")
	var/original_view_distance = brain.view_distance
	brain.view_distance = 0
	TEST_ASSERT_EQUAL(brain.get_injured_ally(), injured_ally, "Human AI did not detect an actionable ally outside ordinary vision but inside medical vision.")
	brain.view_distance = original_view_distance
	// SS220 EDIT - END
	// SS220 EDIT - START: verify deterministic treatment priority
	var/turf/worse_ally_turf = get_step(get_turf(ai_human), WEST)
	TEST_ASSERT_NOTNULL(worse_ally_turf, "Human AI test area must contain a second nearby ally destination.")
	var/mob/living/carbon/human/worse_injured_ally = allocate(/mob/living/carbon/human, worse_ally_turf)
	worse_injured_ally.faction = FACTION_UNSC
	worse_injured_ally.adjustBruteLoss(60)
	TEST_ASSERT_EQUAL(brain.get_injured_ally(), worse_injured_ally, "Human AI did not prioritize the most injured treatable ally.")
	qdel(worse_injured_ally)
	// SS220 EDIT - END
	brain.to_pickup += floor_weapon
	TEST_ASSERT(treat_action.get_weight(brain) > 16, "Human AI let queued floor loot block higher-priority ally treatment.") // SS220 EDIT: treatment must beat Item Pickup
	var/datum/ai_action/item_pickup/interrupted_pickup_action = allocate(/datum/ai_action/item_pickup, brain)
	TEST_ASSERT_EQUAL(interrupted_pickup_action.trigger_action(), ONGOING_ACTION_COMPLETED, "Human AI did not abandon ongoing floor loot for an injured ally.")
	brain.to_pickup -= floor_weapon
	TEST_ASSERT(treat_action.get_weight(brain) > 0, "Human AI did not select ally treatment for a nearby injured friendly.")
	var/initial_ally_damage = injured_ally.getBruteLoss()
	var/approach_timeout = world.time + 5 SECONDS
	while(get_dist(ai_human, injured_ally) > 1 && world.time < approach_timeout)
		TEST_ASSERT_EQUAL(treat_action.trigger_action(), ONGOING_ACTION_UNFINISHED, "Human AI ally treatment did not remain active while approaching its patient.")
		sleep(1)
	TEST_ASSERT_EQUAL(brain.found_injured_ally, injured_ally, "Human AI ally treatment did not retain its selected patient.")
	TEST_ASSERT_EQUAL(get_dist(ai_human, injured_ally), 1, "Human AI medic did not move to a free turf adjacent to its patient.")
	TEST_ASSERT(get_turf(ai_human) != get_turf(injured_ally), "Human AI medic attempted to occupy its patient's turf.")
	TEST_ASSERT_EQUAL(treat_action.trigger_action(), ONGOING_ACTION_UNFINISHED, "Human AI ally treatment did not start after reaching its patient.")
	// SS220 EDIT - END
	var/healing_timeout = world.time + 10 SECONDS
	while(brain.healing_someone && world.time < healing_timeout)
		sleep(1)
	TEST_ASSERT(!brain.healing_someone, "Human AI ally treatment did not finish within the test timeout.")
	TEST_ASSERT(injured_ally.getBruteLoss() < initial_ally_damage, "Human AI medic did not treat its injured ally.")
	TEST_ASSERT(!QDELETED(medical_supply), "Human AI ally-treatment fixture consumed its entire medical supply before storage could be tested.")
	TEST_ASSERT_EQUAL(medical_supply.loc, medical_belt, "Human AI medic did not return its medical supply to the source belt after treatment.")
	TEST_ASSERT_EQUAL(brain.primary_weapon, rpg, "Human AI medic discarded its issued weapon while freeing its hands for treatment.")
	TEST_ASSERT(!isturf(rpg.loc), "Human AI medic left its issued weapon on the floor after treatment.")

	// SS220 EDIT - START: verify nested storage, floor medicine, and allied fracture treatment
	qdel(medical_supply)
	var/obj/item/storage/backpack/test_backpack = allocate(/obj/item/storage/backpack, ai_human)
	ai_human.equip_to_slot_or_del(test_backpack, WEAR_BACK)
	var/obj/item/storage/box/nested_medical_box = allocate(/obj/item/storage/box, ai_human)
	nested_medical_box.w_class = SIZE_SMALL
	nested_medical_box.can_hold = list(/obj/item/stack/medical)
	TEST_ASSERT(test_backpack.attempt_item_insertion(nested_medical_box, FALSE, ai_human), "Human AI test could not place a nested medical box in its backpack.")
	var/obj/item/stack/medical/advanced/bruise_pack/nested_medical_supply = allocate(/obj/item/stack/medical/advanced/bruise_pack, ai_human)
	nested_medical_supply.amount = 100
	TEST_ASSERT(nested_medical_box.attempt_item_insertion(nested_medical_supply, FALSE, ai_human), "Human AI test could not place medicine in nested backpack storage.")
	brain.recalculate_containers()
	brain.appraise_inventory()
	TEST_ASSERT_EQUAL(brain.equipment_map[HUMAN_AI_HEALTHITEMS][nested_medical_supply], nested_medical_box, "Human AI did not index medicine in nested backpack storage.")
	injured_ally.adjustBruteLoss(40)
	brain.start_healing(injured_ally)
	healing_timeout = world.time + 10 SECONDS
	while(brain.healing_someone && world.time < healing_timeout)
		sleep(1)
	TEST_ASSERT(!brain.healing_someone, "Human AI nested-storage treatment did not finish within the test timeout.")
	TEST_ASSERT_EQUAL(nested_medical_supply.loc, nested_medical_box, "Human AI did not return medicine to its nested source container.")

	qdel(nested_medical_supply)
	injured_ally.adjustBruteLoss(40)
	var/obj/item/stack/medical/advanced/bruise_pack/floor_medical_supply = allocate(/obj/item/stack/medical/advanced/bruise_pack, get_turf(ai_human))
	floor_medical_supply.amount = 100
	brain.item_search(list(floor_medical_supply))
	TEST_ASSERT(floor_medical_supply in brain.to_pickup, "Human AI did not select floor medicine suitable for an injured ally.")
	var/datum/ai_action/item_pickup/medical_pickup_action = allocate(/datum/ai_action/item_pickup, brain)
	medical_pickup_action.to_pickup = floor_medical_supply
	TEST_ASSERT_EQUAL(medical_pickup_action.trigger_action(), ONGOING_ACTION_COMPLETED, "Human AI did not complete nearby floor-medicine pickup.")
	TEST_ASSERT(floor_medical_supply in brain.equipment_map[HUMAN_AI_HEALTHITEMS], "Human AI did not retain picked medicine for ally treatment.")
	TEST_ASSERT(!isturf(floor_medical_supply.loc), "Human AI left suitable ally medicine on the floor after pickup.")

	var/obj/item/stack/medical/advanced/ointment/unsuitable_floor_medicine = allocate(/obj/item/stack/medical/advanced/ointment, get_turf(ai_human))
	brain.item_search(list(unsuitable_floor_medicine))
	TEST_ASSERT(!(unsuitable_floor_medicine in brain.to_pickup), "Human AI queued floor medicine that could not treat any current patient.")

	qdel(floor_medical_supply)
	injured_ally.adjustBruteLoss(-injured_ally.getBruteLoss())
	var/obj/limb/fractured_limb = injured_ally.get_limb("l_leg")
	TEST_ASSERT_NOTNULL(fractured_limb, "Human AI fracture test could not find the ally's left leg.")
	fractured_limb.status |= LIMB_BROKEN
	var/obj/item/stack/medical/splint/nested_splint = allocate(/obj/item/stack/medical/splint, ai_human)
	nested_splint.amount = 100
	TEST_ASSERT(nested_medical_box.attempt_item_insertion(nested_splint, FALSE, ai_human), "Human AI test could not place a splint in nested backpack storage.")
	brain.appraise_inventory()
	TEST_ASSERT(brain.medical_item_can_treat(nested_splint, injured_ally), "Human AI did not recognize its nested splint as fracture treatment.")
	brain.start_healing(injured_ally)
	healing_timeout = world.time + 15 SECONDS
	while(brain.healing_someone && world.time < healing_timeout)
		sleep(1)
	TEST_ASSERT(!brain.healing_someone, "Human AI fracture treatment did not finish within the test timeout.")
	TEST_ASSERT(fractured_limb.status & LIMB_SPLINTED, "Human AI did not splint its ally's fracture.")
	TEST_ASSERT_EQUAL(nested_splint.loc, nested_medical_box, "Human AI did not return the splint to nested storage after treatment.")
	// SS220 EDIT - END

	var/list/cover_scores = list()
	TEST_ASSERT(brain.scan_turfs_for_cover(get_turf(ai_human), cover_scores, SOUTH), "Human AI cover scan did not complete.")
	TEST_ASSERT(length(cover_scores) > 1, "Human AI cover scan did not expand beyond its starting turf.")
	TEST_ASSERT(length(cover_scores) <= HUMAN_AI_TEST_COVER_SCAN_LIMIT, "Human AI cover scan exceeded its bounded tile limit.")

#undef HUMAN_AI_TEST_COVER_SCAN_LIMIT

/datum/unit_test/human_ai_medic_scheduler

/datum/unit_test/human_ai_medic_scheduler/Run()
	// SS220 EDIT - START: exercise production scheduling and a patient surrounded by temporary mob blockers
	var/turf/medic_turf = run_loc_floor_bottom_left
	var/turf/patient_turf = medic_turf
	for(var/i in 1 to 5)
		patient_turf = get_step(patient_turf, EAST)
	TEST_ASSERT_NOTNULL(patient_turf, "Human AI medic scheduler test area must contain a patient turf five tiles away.")

	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human, medic_turf)
	medic.faction = FACTION_UNSC
	medic.set_skills(/datum/skills/upp/combat_medic) // SS220 EDIT: exercise the same skill-locked pill bottle path used by AI medics
	// SS220 EDIT - START: reproduce presets that equip medicine before the AI brain exists
	var/obj/item/storage/belt/medical/medical_belt = allocate(/obj/item/storage/belt/medical, medic)
	medic.equip_to_slot_or_del(medical_belt, WEAR_WAIST)
	var/obj/item/stack/medical/advanced/bruise_pack/medical_supply = allocate(/obj/item/stack/medical/advanced/bruise_pack, medic)
	medical_supply.amount = 100
	TEST_ASSERT(medical_belt.attempt_item_insertion(medical_supply, FALSE, medic), "Human AI medic scheduler test could not preload its medical supply.")
	// SS220 EDIT - END
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, medic)
	brain.action_whitelist = list(/datum/ai_action/treat_ally, /datum/ai_action/quick_approach)
	TEST_ASSERT_EQUAL(brain.container_refs["belt"], medical_belt, "Pre-equipped Human AI medic did not initialize its belt storage root.") // SS220 EDIT: regression from 27682a8
	TEST_ASSERT_EQUAL(brain.equipment_map[HUMAN_AI_HEALTHITEMS][medical_supply], medical_belt, "Pre-equipped Human AI medic did not index medicine during brain construction.") // SS220 EDIT: do not mask with manual appraisal

	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, patient_turf)
	patient.faction = FACTION_UNSC
	patient.adjustBruteLoss(40)
	var/initial_patient_damage = patient.getBruteLoss()

	// SS220 EDIT - START: AI chemical treatment must respect patient OD levels and recheck immediately before use
	var/turf/dose_patient_turf = get_step(medic_turf, NORTH)
	TEST_ASSERT_NOTNULL(dose_patient_turf, "Human AI medic scheduler test area must contain an adjacent dose-safety patient turf.")
	var/mob/living/carbon/human/dose_patient = allocate(/mob/living/carbon/human, dose_patient_turf)
	dose_patient.faction = FACTION_UNSC

	var/obj/item/reagent_container/hypospray/autoinjector/tricord/tricord_injector = allocate(/obj/item/reagent_container/hypospray/autoinjector/tricord, medic)
	var/datum/reagent/injector_reagent = tricord_injector.reagents.reagent_list[1]
	var/injector_transfer = min(tricord_injector.amount_per_transfer_from_this, tricord_injector.reagents.total_volume)
	var/injector_dose = injector_reagent.volume * (injector_transfer / tricord_injector.reagents.total_volume)
	dose_patient.reagents.add_reagent(injector_reagent.id, max(0, injector_reagent.overdose - injector_dose))
	TEST_ASSERT(brain.can_safely_administer_reagents(tricord_injector, dose_patient, tricord_injector.amount_per_transfer_from_this), "Human AI rejected an injector dose that only reached the OD boundary.")
	dose_patient.reagents.add_reagent(injector_reagent.id, 1)
	var/injector_amount_before_rejected_use = dose_patient.reagents.get_reagent_amount(injector_reagent.id)
	TEST_ASSERT(!tricord_injector.ai_can_use(medic, brain, dose_patient), "Human AI accepted an injector dose that would exceed the patient's OD threshold.")
	TEST_ASSERT_EQUAL(tricord_injector.ai_use(medic, brain, dose_patient), FALSE, "Human AI did not abort an unsafe injector during final use-time validation.")
	TEST_ASSERT_EQUAL(tricord_injector.attack(dose_patient, medic), 0, "Human AI injector transfer-point guard accepted an unsafe dose.")
	TEST_ASSERT_EQUAL(dose_patient.reagents.get_reagent_amount(injector_reagent.id), injector_amount_before_rejected_use, "Rejected Human AI injector use changed the patient's reagent level.")

	var/obj/item/storage/pill_bottle/tramadol/tramadol_bottle = allocate(/obj/item/storage/pill_bottle/tramadol, medic) // SS220 EDIT: regression for null usr during AI pill return
	var/obj/item/reagent_container/pill/tramadol/tramadol_pill = tramadol_bottle.contents[1]
	var/datum/reagent/pill_reagent = tramadol_pill.reagents.reagent_list[1]
	dose_patient.reagents.add_reagent(pill_reagent.id, max(0, pill_reagent.overdose - pill_reagent.volume))
	TEST_ASSERT(tramadol_bottle.ai_can_use(medic, brain, dose_patient), "Human AI rejected a pill dose that only reached the OD boundary.")
	var/pill_amount_before_race = dose_patient.reagents.get_reagent_amount(pill_reagent.id)
	var/pills_before_rejected_use = length(tramadol_bottle.contents)
	addtimer(CALLBACK(dose_patient.reagents, TYPE_PROC_REF(/datum/reagents, add_reagent), pill_reagent.id, 1), 1)
	TEST_ASSERT_EQUAL(tramadol_bottle.ai_use(medic, brain, dose_patient), FALSE, "Human AI did not abort a pill made unsafe during its internal treatment delay.")
	TEST_ASSERT_EQUAL(dose_patient.reagents.get_reagent_amount(pill_reagent.id), pill_amount_before_race + 1, "Rejected Human AI pill use transferred medicine in addition to the simulated concurrent dose.")
	TEST_ASSERT_EQUAL(length(tramadol_bottle.contents), pills_before_rejected_use, "Rejected Human AI pill use consumed a pill.")
	TEST_ASSERT_EQUAL(tramadol_pill.loc, tramadol_bottle, "Human AI did not return a pill rejected by the transfer-point OD guard to its bottle.")
	qdel(dose_patient)
	// SS220 EDIT - END

	var/list/crowd = list()
	for(var/turf/crowded_turf as anything in patient_turf.AdjacentTurfs())
		var/mob/living/carbon/human/blocker = allocate(/mob/living/carbon/human, crowded_turf)
		blocker.faction = FACTION_UNSC
		crowd += blocker
	TEST_ASSERT(length(crowd), "Human AI medic scheduler test could not create temporary patient blockers.")

	var/turf/staging_turf = brain.get_ally_treatment_approach_turf(patient)
	TEST_ASSERT_NOTNULL(staging_turf, "Human AI medic found no staging turf when allies occupied every treatment position.")
	TEST_ASSERT_EQUAL(get_dist(staging_turf, patient), 2, "Human AI medic staging turf was not in the second ring around a crowded patient.")
	TEST_ASSERT(!is_blocked_turf(staging_turf), "Human AI medic selected a blocked staging turf.")

	brain.quick_approach = get_step(medic_turf, NORTH)
	var/datum/ai_action/quick_approach/stale_routine_action = allocate(/datum/ai_action/quick_approach, brain)
	var/datum/ai_action/idle_defensive_position/stale_idle_position = allocate(/datum/ai_action/idle_defensive_position, brain)
	brain.ongoing_actions += stale_routine_action
	brain.ongoing_actions += stale_idle_position
	brain.process(0)
	TEST_ASSERT(QDELETED(stale_routine_action) || !(stale_routine_action in brain.ongoing_actions), "Human AI medic did not preempt a stale routine movement action.")
	TEST_ASSERT(QDELETED(stale_idle_position) || !(stale_idle_position in brain.ongoing_actions), "Human AI medic did not release its idle defensive post for an injured ally.")

	var/datum/ai_action/treat_ally/scheduled_treatment
	for(var/datum/ai_action/ongoing_action as anything in brain.ongoing_actions)
		if(istype(ongoing_action, /datum/ai_action/treat_ally))
			scheduled_treatment = ongoing_action
			break
	TEST_ASSERT_NOTNULL(scheduled_treatment, "Human AI production scheduler did not start ally treatment after routine-action preemption.")

	var/initial_distance = get_dist(medic, patient)
	var/staging_timeout = world.time + 5 SECONDS
	while(get_dist(medic, patient) > 2 && world.time < staging_timeout)
		brain.process(0)
		sleep(1)
	TEST_ASSERT(get_dist(medic, patient) < initial_distance, "Human AI medic did not close distance to a crowded patient.")
	TEST_ASSERT(get_dist(medic, patient) <= 2, "Human AI medic did not reach the staging ring around a crowded patient.")

	for(var/mob/living/carbon/human/blocker as anything in crowd)
		qdel(blocker)
	sleep(1)

	var/healing_timeout = world.time + 15 SECONDS
	while(patient.getBruteLoss() >= initial_patient_damage && world.time < healing_timeout)
		brain.process(0)
		sleep(1)
	TEST_ASSERT(patient.getBruteLoss() < initial_patient_damage, "Human AI medic did not approach and treat the patient after a treatment turf became free.")
	TEST_ASSERT_EQUAL(medical_supply.loc, medical_belt, "Human AI medic did not return medicine after scheduler-driven treatment.")
	// SS220 EDIT - END

// SS220 EDIT - START: idle Human AI should reserve covered posts without rebuilding a crowd
/datum/unit_test/human_ai_idle_defensive_positions

/datum/unit_test/human_ai_idle_defensive_positions/Run()
	var/turf/cluster_turf = run_loc_floor_bottom_left
	var/mob/living/carbon/human/first_human = allocate(/mob/living/carbon/human, cluster_turf)
	var/mob/living/carbon/human/second_human = allocate(/mob/living/carbon/human, cluster_turf)
	var/mob/living/carbon/human/third_human = allocate(/mob/living/carbon/human, cluster_turf)
	first_human.faction = FACTION_UNSC
	second_human.faction = FACTION_UNSC
	third_human.faction = FACTION_UNSC

	var/datum/human_ai_brain/first_brain = allocate(/datum/human_ai_brain, first_human)
	var/datum/human_ai_brain/second_brain = allocate(/datum/human_ai_brain, second_human)
	var/datum/human_ai_brain/third_brain = allocate(/datum/human_ai_brain, third_human)
	TEST_ASSERT(first_brain.is_in_idle_ai_cluster(), "Human AI did not recognize a three-NPC idle cluster.")
	TEST_ASSERT(first_brain.can_seek_idle_defensive_position(), "Healthy idle Human AI rejected defensive redistribution.")

	var/turf/reserved_post = get_step(cluster_turf, NORTH)
	TEST_ASSERT_NOTNULL(reserved_post, "Human AI idle-position test area must contain a reservable turf.")
	second_brain.idle_defensive_position = reserved_post
	third_brain.idle_defensive_position = reserved_post
	TEST_ASSERT_EQUAL(first_brain.score_idle_defensive_position(reserved_post), -INFINITY, "Human AI accepted a defensive area already reserved by two allies.")
	TEST_ASSERT(first_brain.find_idle_defensive_position() != reserved_post, "Human AI selected a defensive post at its two-NPC capacity.")

	var/turf/cover_candidate = get_step(cluster_turf, EAST)
	var/turf/cover_neighbor = get_step(cover_candidate, EAST)
	TEST_ASSERT_NOTNULL(cover_neighbor, "Human AI idle-position test area must contain an adjacent cover turf.")
	var/cover_score_before = first_brain.get_idle_position_cover_score(cover_candidate)
	allocate(/obj/structure/surface/table, cover_neighbor)
	var/cover_score_after = first_brain.get_idle_position_cover_score(cover_candidate)
	TEST_ASSERT(cover_score_after > cover_score_before, "Human AI idle-position scoring did not prefer newly added physical cover.")

	first_brain.hold_position = TRUE
	TEST_ASSERT(!first_brain.can_seek_idle_defensive_position(), "Human AI idle redistribution ignored a hold-position order.")
// SS220 EDIT - END

// SS220 EDIT - START: live-grenade reaction and one-roll combat grenade behavior
/datum/unit_test/human_ai_grenade_reactions

/datum/unit_test/human_ai_grenade_reactions/Run()
	var/turf/ai_turf = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, ai_turf)
	ai_human.faction = FACTION_UNSC
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, ai_human)

	var/turf/grenade_turf = ai_turf
	for(var/i in 1 to 4)
		grenade_turf = get_step(grenade_turf, EAST)
	TEST_ASSERT_NOTNULL(grenade_turf, "Human AI grenade test area must extend four tiles east.")
	var/obj/item/explosive/grenade/high_explosive/live_grenade = allocate(/obj/item/explosive/grenade/high_explosive, grenade_turf)
	live_grenade.active = TRUE
	live_grenade.fuse_type = TIMED_FUSE
	live_grenade.timed_fuse_deadline = world.time + 10 SECONDS

	brain.can_throw_back_grenades = FALSE
	TEST_ASSERT_EQUAL(brain.scan_nearby_live_grenade_threat(TRUE), live_grenade, "Human AI did not detect a live floor grenade four tiles away.")
	brain.quick_approach = get_step(ai_turf, NORTH)
	var/datum/ai_action/quick_approach/stale_movement = allocate(/datum/ai_action/quick_approach, brain)
	brain.ongoing_actions += stale_movement
	brain.preempt_actions_for_live_grenade()
	TEST_ASSERT(QDELETED(stale_movement) || !(stale_movement in brain.ongoing_actions), "Human AI live-grenade reaction did not preempt routine movement.")
	brain.quick_approach = null
	TEST_ASSERT(!brain.can_attempt_live_grenade_throwback(live_grenade), "Throw-back-disabled Human AI tried to handle a live grenade.")
	var/turf/escape_turf = brain.get_live_grenade_escape_turf(live_grenade)
	TEST_ASSERT_NOTNULL(escape_turf, "Human AI found no local escape turf from a live grenade.")
	TEST_ASSERT(get_dist(escape_turf, live_grenade) > get_dist(ai_human, live_grenade), "Human AI grenade escape turf did not increase separation from the threat.")

	var/datum/ai_action/throw_back_nade/reaction_action = allocate(/datum/ai_action/throw_back_nade, brain)
	TEST_ASSERT(reaction_action.get_weight(brain) > 0, "Human AI without throw-back capability did not schedule a retreat reaction.")
	brain.can_throw_back_grenades = TRUE
	TEST_ASSERT(brain.can_attempt_live_grenade_throwback(live_grenade), "Capable Human AI rejected a timed live grenade.")

	var/turf/hostile_turf = ai_turf
	for(var/i in 1 to 5)
		hostile_turf = get_step(hostile_turf, NORTH)
	TEST_ASSERT_NOTNULL(hostile_turf, "Human AI grenade test area must extend five tiles north.")
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, hostile_turf)
	hostile.faction = FACTION_COVENANT
	TEST_ASSERT_EQUAL(reaction_action.get_hostile_throw_target(ai_human, live_grenade), hostile_turf, "Human AI did not select a safe hostile-side throw-back target.")
	var/turf/friendly_turf = get_step(hostile_turf, EAST)
	TEST_ASSERT_NOTNULL(friendly_turf, "Human AI grenade test area must contain a friendly safety-check turf.")
	var/mob/living/carbon/human/friendly = allocate(/mob/living/carbon/human, friendly_turf)
	friendly.faction = FACTION_UNSC
	TEST_ASSERT_NULL(reaction_action.get_hostile_throw_target(ai_human, live_grenade), "Human AI selected a grenade target whose blast area contained a friendly.")

	var/obj/item/explosive/grenade/high_explosive/carried_grenade = allocate(/obj/item/explosive/grenade/high_explosive, ai_human)
	brain.equipment_map[HUMAN_AI_GRENADES][carried_grenade] = ai_human
	brain.active_grenade_found = null
	brain.in_combat = TRUE
	brain.target_turf = hostile_turf
	TEST_ASSERT_EQUAL(brain.combat_grenade_use_chance, 40, "Human AI carried-grenade chance is not 40 percent by default.")
	brain.combat_grenade_use_chance = 100
	brain.begin_combat_grenade_decision()
	TEST_ASSERT(brain.should_attempt_combat_grenade(), "Human AI failed a forced successful combat-grenade decision.")
	brain.combat_grenade_use_chance = 0
	TEST_ASSERT(brain.should_attempt_combat_grenade(), "Human AI rerolled its stored combat-grenade decision during the same encounter.")
	var/datum/ai_action/throw_grenade/grenade_action_prototype = GLOB.AI_actions[/datum/ai_action/throw_grenade]
	TEST_ASSERT_NOTNULL(grenade_action_prototype, "Human AI carried-grenade action was not registered.")
	TEST_ASSERT_EQUAL(grenade_action_prototype.get_weight(brain), 20, "Human AI successful combat-grenade decision did not enable the throw action.")
	brain.combat_grenade_use_chance = 100
	var/datum/ai_action/throw_grenade/carried_action = allocate(/datum/ai_action/throw_grenade, brain)
	TEST_ASSERT_NOTNULL(carried_action, "Human AI failed to create its selected carried-grenade action.")
	TEST_ASSERT(!brain.combat_grenade_selected, "Human AI did not consume its carried-grenade decision when the throw action started.")
	brain.begin_combat_grenade_decision()
	brain.combat_grenade_use_chance = 0
	TEST_ASSERT(!brain.should_attempt_combat_grenade(), "Human AI failed a forced unsuccessful combat-grenade decision.")
// SS220 EDIT - END
