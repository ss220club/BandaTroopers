#define HALO_TEST_R_HAND_LAYER 5
#define HALO_TEST_L_HAND_LAYER 6

/datum/unit_test/halo_sangheili_equipment/proc/create_sangheili(preset_type)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	arm_equipment(human, preset_type, FALSE)
	return human

/datum/unit_test/halo_sangheili_equipment/proc/create_sangheili_ai_brain(preset_type)
	var/mob/living/carbon/human/human = create_sangheili(preset_type)
	var/datum/component/human_ai/ai_component = human.AddComponent(/datum/component/human_ai)
	if(!ai_component)
		TEST_FAIL("Failed to add a human AI component to the HALO Sangheili test mob.")
		return null
	if(!ai_component.ai_brain)
		TEST_FAIL("Failed to resolve a human AI brain for the HALO Sangheili test mob.")
		return null
	ai_component.ai_brain.appraise_inventory(armor = TRUE)
	if(isgun(human.s_store))
		ai_component.ai_brain.set_primary_weapon(human.s_store)
	return ai_component.ai_brain

/datum/unit_test/halo_sangheili_equipment/proc/count_belt_items(mob/living/carbon/human/human, item_type)
	if(!human || !human.belt)
		return 0

	var/count = 0
	for(var/obj/item/item as anything in human.belt.contents)
		if(istype(item, item_type))
			count++
	return count

/datum/unit_test/halo_sangheili_equipment/proc/create_test_projectile(mob/living/carbon/human/firer, ammo_type)
	var/obj/projectile/projectile = allocate(/obj/projectile, run_loc_floor_top_right)
	var/datum/ammo/ammo = allocate(ammo_type)
	projectile.generate_bullet(ammo, 0, 0, firer)
	projectile.starting = get_turf(firer)
	projectile.def_zone = "chest"
	projectile.firer = firer
	return projectile

/datum/unit_test/halo_sangheili_equipment/proc/set_target_turf(datum/human_ai_brain/brain, distance)
	var/turf/origin = get_turf(brain?.tied_human)
	if(!origin)
		return null

	return locate(origin.x + distance, origin.y, origin.z)

/datum/unit_test/halo_sangheili_equipment/proc/get_belt_sword(mob/living/carbon/human/human)
	if(!human?.belt)
		return null

	return locate(/obj/item/weapon/covenant/energy_sword) in human.belt

/datum/unit_test/halo_sangheili_equipment/proc/find_accessible_sword(mob/living/carbon/human/human)
	if(!human)
		return null

	var/obj/item/weapon/covenant/energy_sword/sword = get_belt_sword(human)
	if(sword)
		return sword

	if(istype(human.l_hand, /obj/item/weapon/covenant/energy_sword))
		return human.l_hand

	if(istype(human.r_hand, /obj/item/weapon/covenant/energy_sword))
		return human.r_hand

	if(istype(human.s_store, /obj/item/weapon/covenant/energy_sword))
		return human.s_store

	return locate(/obj/item/weapon/covenant/energy_sword) in get_turf(human)

/datum/unit_test/halo_sangheili_equipment/proc/put_sword_in_active_hand(mob/living/carbon/human/human)
	var/obj/item/weapon/covenant/energy_sword/sword = find_accessible_sword(human)
	if(!human || !sword)
		return null

	if(istype(sword.loc, /obj/item/storage))
		var/obj/item/storage/storage = sword.loc
		storage.remove_from_storage(sword, human)

	if(sword.loc != human && sword.loc != get_turf(human))
		return null

	if(human.get_active_hand())
		human.drop_held_item(human.get_active_hand())

	if(!human.put_in_hands(sword, FALSE))
		return null

	return sword

/datum/unit_test/halo_sangheili_equipment/proc/put_sword_in_hand(mob/living/carbon/human/human, slot)
	if(!human)
		return null

	var/obj/item/weapon/covenant/energy_sword/sword = find_accessible_sword(human)
	if(!sword)
		return null

	if(human.l_hand)
		human.drop_held_item(human.l_hand)
	if(human.r_hand)
		human.drop_held_item(human.r_hand)

	if(istype(sword.loc, /obj/item/storage))
		var/obj/item/storage/storage = sword.loc
		storage.remove_from_storage(sword, human)

	if(sword.loc != human && sword.loc != get_turf(human))
		return null

	if(slot == WEAR_L_HAND)
		return human.put_in_l_hand(sword) ? sword : null

	return human.put_in_r_hand(sword) ? sword : null

/datum/unit_test/halo_sangheili_equipment/proc/get_held_sword_overlay_icon_state(mob/living/carbon/human/human, obj/item/weapon/covenant/energy_sword/sword)
	if(!human || !sword)
		return null

	if(human.r_hand == sword)
		var/image/held_overlay = human.overlays_standing[HALO_TEST_R_HAND_LAYER] // SS220 EDIT: type overlay lookup for DreamChecker before reading icon_state
		return held_overlay?.icon_state

	if(human.l_hand == sword)
		var/image/held_overlay = human.overlays_standing[HALO_TEST_L_HAND_LAYER] // SS220 EDIT: type overlay lookup for DreamChecker before reading icon_state
		return held_overlay?.icon_state

	return null

/datum/unit_test/halo_sangheili_equipment/proc/image_has_visible_pixels(image/image_to_check)
	if(!image_to_check)
		return FALSE

	var/icon/flat_icon = getFlatIcon(image_to_check, SOUTH, null, null, image_to_check.blend_mode || BLEND_OVERLAY, TRUE, TRUE)
	if(!flat_icon)
		return FALSE

	for(var/x in 1 to flat_icon.Width())
		for(var/y in 1 to flat_icon.Height())
			if(!isnull(flat_icon.GetPixel(x, y)))
				return TRUE

	return FALSE

/datum/unit_test/halo_sangheili_equipment/proc/icon_state_has_visible_pixels(icon/icon_file, state, direction)
	var/icon/state_icon = icon(icon_file, state, direction)
	for(var/x in 1 to state_icon.Width())
		for(var/y in 1 to state_icon.Height())
			if(!isnull(state_icon.GetPixel(x, y)))
				return TRUE

	return FALSE

/datum/unit_test/halo_sangheili_equipment/Run()
	return

/datum/unit_test/halo_sangheili_equipment_matrix
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_equipment_matrix/Run()
	var/list/preset_matrix = list(
		/datum/equipment_preset/covenant/sangheili/minor = list(
			"helmet" = /obj/item/clothing/head/helmet/marine/sangheili/minor,
			"suit" = /obj/item/clothing/suit/marine/shielded/sangheili/minor,
			"gloves" = /obj/item/clothing/gloves/marine/sangheili/minor,
			"shoes" = /obj/item/clothing/shoes/sangheili/minor,
			"belt" = /obj/item/storage/belt/marine/covenant/sangheili/minor,
		),
		/datum/equipment_preset/covenant/sangheili/major = list(
			"helmet" = /obj/item/clothing/head/helmet/marine/sangheili/major,
			"suit" = /obj/item/clothing/suit/marine/shielded/sangheili/major,
			"gloves" = /obj/item/clothing/gloves/marine/sangheili/major,
			"shoes" = /obj/item/clothing/shoes/sangheili/major,
			"belt" = /obj/item/storage/belt/marine/covenant/sangheili/major,
		),
		/datum/equipment_preset/covenant/sangheili/ultra = list(
			"helmet" = /obj/item/clothing/head/helmet/marine/sangheili/ultra,
			"suit" = /obj/item/clothing/suit/marine/shielded/sangheili/ultra,
			"gloves" = /obj/item/clothing/gloves/marine/sangheili/ultra,
			"shoes" = /obj/item/clothing/shoes/sangheili/ultra,
			"belt" = /obj/item/storage/belt/marine/covenant/sangheili/ultra,
		),
		/datum/equipment_preset/covenant/sangheili/zealot = list(
			"helmet" = /obj/item/clothing/head/helmet/marine/sangheili/zealot,
			"suit" = /obj/item/clothing/suit/marine/shielded/sangheili/zealot,
			"gloves" = /obj/item/clothing/gloves/marine/sangheili/zealot,
			"shoes" = /obj/item/clothing/shoes/sangheili/zealot,
			"belt" = /obj/item/storage/belt/marine/covenant/sangheili/zealot,
		),
	)

	for(var/preset_type as anything in preset_matrix)
		var/mob/living/carbon/human/human = create_sangheili(preset_type)
		var/list/expected = preset_matrix[preset_type]

		TEST_ASSERT_EQUAL(human.species?.name, SPECIES_SANGHEILI, "[preset_type] did not set the expected Sangheili species.")
		TEST_ASSERT(istype(human.head, expected["helmet"]), "[preset_type] did not equip the expected Sangheili helmet.")
		TEST_ASSERT(istype(human.wear_suit, expected["suit"]), "[preset_type] did not equip the expected Sangheili harness.")
		TEST_ASSERT(istype(human.gloves, expected["gloves"]), "[preset_type] did not equip the expected Sangheili gloves.")
		TEST_ASSERT(istype(human.shoes, expected["shoes"]), "[preset_type] did not equip the expected Sangheili greaves.")
		TEST_ASSERT(istype(human.belt, expected["belt"]), "[preset_type] did not equip the expected Sangheili belt.")

/datum/unit_test/halo_sangheili_equipment_item_states
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_equipment_item_states/Run()
	var/list/item_state_matrix = list(
		/obj/item/clothing/head/helmet/marine/sangheili/major = "sanghelmet_major",
		/obj/item/clothing/head/helmet/marine/sangheili/ultra = "sanghelmet_ultra",
		/obj/item/clothing/head/helmet/marine/sangheili/zealot = "sanghelmet_zealot",
		/obj/item/clothing/gloves/marine/sangheili = "sanggauntlets_minor",
		/obj/item/clothing/gloves/marine/sangheili/major = "sanggauntlets_major",
		/obj/item/clothing/gloves/marine/sangheili/ultra = "sanggauntlets_ultra",
		/obj/item/clothing/gloves/marine/sangheili/zealot = "sanggauntlets_zealot",
		/obj/item/clothing/shoes/sangheili/major = "sangboots_major",
		/obj/item/clothing/shoes/sangheili/ultra = "sangboots_ultra",
		/obj/item/clothing/shoes/sangheili/zealot = "sangboots_zealot",
		/obj/item/clothing/suit/marine/shielded/sangheili/major = "sang_major",
		/obj/item/clothing/suit/marine/shielded/sangheili/ultra = "sang_ultra",
		/obj/item/clothing/suit/marine/shielded/sangheili/zealot = "sang_zealot",
	)

	for(var/item_type as anything in item_state_matrix)
		var/obj/item/item = allocate(item_type, run_loc_floor_top_right)
		TEST_ASSERT_EQUAL(item.item_state, item_state_matrix[item_type], "[item_type] lost the expected onmob item_state.")

/datum/unit_test/halo_sangheili_player_rank_utility
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_player_rank_utility/Run()
	var/list/utility_matrix = list(
		/datum/equipment_preset/covenant/sangheili/minor = list("bicaridine" = 0, "oxycodone" = 0, "grenades" = 0, "swords" = 0),
		/datum/equipment_preset/covenant/sangheili/major = list("bicaridine" = 1, "oxycodone" = 0, "grenades" = 0, "swords" = 0),
		/datum/equipment_preset/covenant/sangheili/ultra = list("bicaridine" = 1, "oxycodone" = 1, "grenades" = 1, "swords" = 1),
		/datum/equipment_preset/covenant/sangheili/zealot = list("bicaridine" = 1, "oxycodone" = 1, "grenades" = 1, "swords" = 1),
	)

	for(var/preset_type as anything in utility_matrix)
		var/mob/living/carbon/human/human = create_sangheili(preset_type)
		var/list/expected = utility_matrix[preset_type]

		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo), expected["bicaridine"], "[preset_type] drifted from the intended Sangheili bicaridine count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo), expected["oxycodone"], "[preset_type] drifted from the intended Sangheili oxycodone count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/explosive/grenade/high_explosive/covenant/plasma), expected["grenades"], "[preset_type] drifted from the intended Sangheili plasma grenade count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/weapon/covenant/energy_sword), expected["swords"], "[preset_type] drifted from the intended Sangheili energy sword count.")

/datum/unit_test/halo_sangheili_ai_rank_utility
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_rank_utility/Run()
	var/list/utility_matrix = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = list(
			"weapon" = /obj/item/weapon/gun/energy/plasma/plasma_rifle,
			"carbine_mags" = 0,
			"bicaridine" = 0,
			"oxycodone" = 0,
			"grenades" = 0,
			"swords" = 0,
		),
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = list(
			"weapon" = /obj/item/weapon/gun/rifle/covenant_carbine,
			"carbine_mags" = 5,
			"bicaridine" = 1,
			"oxycodone" = 0,
			"grenades" = 0,
			"swords" = 0,
		),
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = list(
			"weapon" = /obj/item/weapon/gun/energy/plasma/plasma_rifle,
			"carbine_mags" = 0,
			"bicaridine" = 1,
			"oxycodone" = 1,
			"grenades" = 1,
			"swords" = 1,
		),
		/datum/equipment_preset/covenant/sangheili/ai/zealot_command = list(
			"weapon" = /obj/item/weapon/gun/energy/plasma/plasma_rifle,
			"carbine_mags" = 0,
			"bicaridine" = 1,
			"oxycodone" = 1,
			"grenades" = 1,
			"swords" = 1,
		),
	)

	for(var/preset_type as anything in utility_matrix)
		var/mob/living/carbon/human/human = create_sangheili(preset_type)
		var/list/expected = utility_matrix[preset_type]

		TEST_ASSERT(istype(human.s_store, expected["weapon"]), "[preset_type] no longer equips its expected primary weapon into suit storage.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/ammo_magazine/carbine), expected["carbine_mags"], "[preset_type] drifted from the intended Sangheili carbine magazine count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo), expected["bicaridine"], "[preset_type] drifted from the intended Sangheili bicaridine count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo), expected["oxycodone"], "[preset_type] drifted from the intended Sangheili oxycodone count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/explosive/grenade/high_explosive/covenant/plasma), expected["grenades"], "[preset_type] drifted from the intended Sangheili plasma grenade count.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/weapon/covenant/energy_sword), expected["swords"], "[preset_type] drifted from the intended Sangheili energy sword count.")

/datum/unit_test/halo_sangheili_ai_sword_presets
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_sword_presets/Run()
	var/list/sword_presets = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword,
		/datum/equipment_preset/covenant/sangheili/ai/zealot_sword,
	)

	for(var/preset_type as anything in sword_presets)
		var/datum/human_ai_brain/brain = create_sangheili_ai_brain(preset_type)
		TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO Sangheili sword AI for [preset_type].")
		var/mob/living/carbon/human/human = brain.tied_human
		var/obj/item/weapon/gun/energy/plasma/plasma_rifle/loose_plasma = allocate(/obj/item/weapon/gun/energy/plasma/plasma_rifle, get_turf(human))

		TEST_ASSERT_NULL(human.s_store, "[preset_type] should not keep a firearm in suit storage.")
		TEST_ASSERT_EQUAL(count_belt_items(human, /obj/item/weapon/covenant/energy_sword), 1, "[preset_type] should equip exactly one energy sword in the belt.")
		TEST_ASSERT(brain.halo_sangheili_has_sword, "[preset_type] lost its HALO sword-bearing metadata.")
		TEST_ASSERT(brain.halo_sangheili_sword_only, "[preset_type] should commit to the sword-only behavior tree.")
		TEST_ASSERT(brain.ignore_looting, "[preset_type] should ignore looting to remain sword-only.")
		TEST_ASSERT_NOTNULL(loose_plasma, "Failed to allocate a dropped plasma rifle for the ignore_looting Sangheili test.")
		brain.item_search(range(1, human))
		TEST_ASSERT(!length(brain.to_pickup), "[preset_type] should not queue dropped firearms while ignore_looting is enabled.")

/datum/unit_test/halo_sangheili_ai_mixed_sword_flags
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_mixed_sword_flags/Run()
	var/list/mixed_presets = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma,
		/datum/equipment_preset/covenant/sangheili/ai/zealot_command,
	)

	for(var/preset_type as anything in mixed_presets)
		var/datum/human_ai_brain/brain = create_sangheili_ai_brain(preset_type)
		TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO mixed Sangheili AI for [preset_type].")
		var/mob/living/carbon/human/human = brain.tied_human

		TEST_ASSERT(istype(human.s_store, /obj/item/weapon/gun), "[preset_type] should retain its primary firearm.")
		TEST_ASSERT(brain.halo_sangheili_has_sword, "[preset_type] should expose the HALO sword-bearing metadata.")
		TEST_ASSERT(!brain.halo_sangheili_sword_only, "[preset_type] should remain a mixed ranged/melee archetype.")

/datum/unit_test/halo_sangheili_ai_action_weights
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_action_weights/Run()
	var/datum/human_ai_brain/ultra_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma, "Failed to create the HALO Ultra plasma AI for action-weight testing.")
	ultra_plasma.in_combat = TRUE
	ultra_plasma.target_turf = set_target_turf(ultra_plasma, 4)
	TEST_ASSERT_NOTNULL(ultra_plasma.target_turf, "Failed to allocate an Ultra plasma target turf for action-weight testing.")
	var/obj/item/weapon/gun/energy/plasma/ultra_plasma_weapon = ultra_plasma.primary_weapon
	COOLDOWN_START(ultra_plasma_weapon, cooldown, 5 SECONDS)
	TEST_ASSERT(GLOB.AI_actions[/datum/ai_action/sangheili_sword_charge].get_weight(ultra_plasma) > 0, "An overheated Ultra plasma AI should prefer the HALO sword charge when the target is nearby.")
	TEST_ASSERT_EQUAL(GLOB.AI_actions[/datum/ai_action/sangheili_overheat_response].get_weight(ultra_plasma), 0, "Sword-bearing Sangheili should not take the generic overheat fallback while sword charge is available.")

	var/datum/human_ai_brain/ultra_plasma_close = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma_close, "Failed to create the HALO Ultra plasma AI for close-range sword switching tests.")
	ultra_plasma_close.in_combat = TRUE
	ultra_plasma_close.target_turf = set_target_turf(ultra_plasma_close, ultra_plasma_close.halo_sangheili_unarmed_commit_range)
	TEST_ASSERT_NOTNULL(ultra_plasma_close.target_turf, "Failed to allocate a close-range target turf for the HALO sword-switch action-weight test.")
	TEST_ASSERT(GLOB.AI_actions[/datum/ai_action/sangheili_sword_charge].get_weight(ultra_plasma_close) > 0, "Mixed HALO Sangheili should switch to the sword when a target is too close even if the firearm is still usable.")

	var/datum/human_ai_brain/ultra_sword = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_sword)
	TEST_ASSERT_NOTNULL(ultra_sword, "Failed to create the HALO Ultra sword AI for action-weight testing.")
	ultra_sword.in_combat = TRUE
	ultra_sword.target_turf = set_target_turf(ultra_sword, 4)
	TEST_ASSERT_NOTNULL(ultra_sword.target_turf, "Failed to allocate an Ultra sword target turf for action-weight testing.")
	TEST_ASSERT(GLOB.AI_actions[/datum/ai_action/sangheili_sword_charge].get_weight(ultra_sword) > 0, "Sword-only Sangheili should always favor the HALO sword charge when a target exists.")

	var/datum/human_ai_brain/minor_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/minor_plasma)
	TEST_ASSERT_NOTNULL(minor_plasma, "Failed to create the HALO Minor plasma AI for action-weight testing.")
	minor_plasma.in_combat = TRUE
	minor_plasma.target_turf = set_target_turf(minor_plasma, 2)
	TEST_ASSERT_NOTNULL(minor_plasma.target_turf, "Failed to allocate a Minor plasma target turf for action-weight testing.")
	var/obj/item/weapon/gun/energy/plasma/minor_plasma_weapon = minor_plasma.primary_weapon
	COOLDOWN_START(minor_plasma_weapon, cooldown, 5 SECONDS)
	TEST_ASSERT(GLOB.AI_actions[/datum/ai_action/sangheili_overheat_response].get_weight(minor_plasma) > 0, "A non-sword Sangheili should use the HALO overheat fallback while its plasma weapon cools.")

/datum/unit_test/halo_sangheili_ai_pathing_tuning
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_pathing_tuning/Run()
	var/datum/human_ai_brain/ultra_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma, "Failed to create the HALO Ultra plasma AI for pathing-tuning tests.")
	TEST_ASSERT_EQUAL(ultra_plasma.short_step_pathing_range, ultra_plasma.halo_sangheili_sword_charge_range + 1, "HALO Sangheili AI should use nearby short-step movement for sword-charge range fights.")
	TEST_ASSERT_EQUAL(ultra_plasma.path_target_retarget_slack, 2, "HALO Sangheili AI should tolerate small target drift before rebuilding a melee path.")

	// SS220 EDIT - START: keep the retarget-slack test inside the tiny unit-test template floor band
	var/turf/origin = run_loc_floor_bottom_left
	TEST_ASSERT(isfloorturf(origin), "The HALO Sangheili pathing-tuning origin turf was not a floor ([origin]).")
	ultra_plasma.tied_human.forceMove(origin)
	var/turf/reference_target = set_target_turf(ultra_plasma, 1)
	// SS220 EDIT - END
	TEST_ASSERT_NOTNULL(reference_target, "Failed to allocate the HALO Sangheili reference target turf for pathing-tuning tests.")
	var/turf/slack_target = get_step(reference_target, EAST)
	var/turf/far_target = get_step(get_step(slack_target, EAST), EAST)
	TEST_ASSERT(isfloorturf(slack_target), "The one-tile HALO Sangheili drift target for pathing-tuning tests was not a floor ([slack_target]).")
	TEST_ASSERT(isfloorturf(far_target), "The far HALO Sangheili drift target for pathing-tuning tests was not a floor ([far_target]).")

	ultra_plasma.current_path = list(reference_target)
	ultra_plasma.current_path_target = reference_target
	TEST_ASSERT(!ultra_plasma.path_target_needs_refresh(slack_target), "HALO Sangheili melee pathing should keep the current target while the enemy only drifts by one tile.")
	TEST_ASSERT(ultra_plasma.path_target_needs_refresh(far_target), "HALO Sangheili melee pathing should refresh once the enemy drifts beyond the configured slack.")

/datum/unit_test/halo_sangheili_ai_sword_auto_activation
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_sword_auto_activation/Run()
	var/datum/human_ai_brain/ultra_sword = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_sword)
	TEST_ASSERT_NOTNULL(ultra_sword, "Failed to create the HALO Ultra sword AI for sword auto-activation testing.")

	var/mob/living/carbon/human/human = ultra_sword.tied_human
	var/obj/item/weapon/covenant/energy_sword/sword = ultra_sword.halo_sangheili_draw_sword()
	TEST_ASSERT_NOTNULL(sword, "Failed to draw the HALO AI Sangheili sword for sword auto-activation testing.")
	TEST_ASSERT(sword.activated, "The HALO AI sword draw helper should still activate the sword before the test reset.")

	sword.toggle_activation(human)
	TEST_ASSERT(!sword.activated, "The HALO AI sword test setup failed to return the sword to its inactive state.")

	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT_NOTNULL(target, "Failed to allocate a target for HALO AI Sangheili sword auto-activation testing.")
	human.a_intent_change(INTENT_HARM)
	sword.attack(target, human)

	TEST_ASSERT(sword.activated, "Sword-only HALO Sangheili AI should auto-activate its energy sword before attacking.")

/datum/unit_test/halo_sangheili_ai_mixed_sword_auto_activation
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_mixed_sword_auto_activation/Run()
	var/datum/human_ai_brain/ultra_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma, "Failed to create the HALO mixed Sangheili AI for sword auto-activation testing.")

	var/mob/living/carbon/human/human = ultra_plasma.tied_human
	var/obj/item/weapon/covenant/energy_sword/sword = put_sword_in_active_hand(human)
	TEST_ASSERT_NOTNULL(sword, "Failed to move the HALO mixed Sangheili sword into the active hand for sword auto-activation testing.")
	TEST_ASSERT(!sword.activated, "Mixed HALO Sangheili sword test setup should begin with an inactive sword.")

	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT_NOTNULL(target, "Failed to allocate a target for HALO mixed Sangheili sword auto-activation testing.")
	human.a_intent_change(INTENT_HARM)
	sword.attack(target, human)

	TEST_ASSERT(sword.activated, "Mixed HALO Sangheili AI should auto-activate its sword even outside the dedicated draw helper path.")

/datum/unit_test/halo_sangheili_ai_mixed_sword_close_switch
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_mixed_sword_close_switch/Run()
	var/datum/human_ai_brain/ultra_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma, "Failed to create the HALO mixed Sangheili AI for close-range sword switching testing.")
	TEST_ASSERT(ultra_plasma.halo_sangheili_runtime, "HALO mixed Sangheili AI should mark itself for HALO sword runtime behavior.")
	TEST_ASSERT_NOTNULL(ultra_plasma.halo_sangheili_find_sword(), "HALO mixed Sangheili should spawn with a recoverable sword before testing close-range switching.")

	var/obj/item/weapon/gun/original_primary = ultra_plasma.primary_weapon
	TEST_ASSERT_NOTNULL(original_primary, "The HALO mixed Sangheili close-range sword-switch test requires an initial primary firearm.")

	ultra_plasma.in_combat = TRUE
	ultra_plasma.target_turf = set_target_turf(ultra_plasma, ultra_plasma.halo_sangheili_unarmed_commit_range)
	TEST_ASSERT_NOTNULL(ultra_plasma.target_turf, "Failed to allocate a close-range target turf for HALO mixed Sangheili sword switching.")

	var/datum/ai_action/sangheili_sword_charge/charge_action = new(ultra_plasma)
	charge_action.trigger_action()

	var/mob/living/carbon/human/human = ultra_plasma.tied_human
	var/obj/item/weapon/covenant/energy_sword/sword = ultra_plasma.halo_sangheili_drawn_sword
	TEST_ASSERT_NOTNULL(sword, "Mixed HALO Sangheili should draw the sword automatically when the target is too close.")

	TEST_ASSERT(ultra_plasma.halo_sangheili_melee_committed, "Mixed HALO Sangheili should enter melee mode after drawing the sword for a close target.")
	TEST_ASSERT_NULL(ultra_plasma.primary_weapon, "Mixed HALO Sangheili should park the firearm while fighting with the sword.")
	TEST_ASSERT_EQUAL(ultra_plasma.halo_sangheili_committed_primary_weapon, original_primary, "The parked HALO Sangheili firearm was not preserved for later restoration.")
	TEST_ASSERT(ultra_plasma.ignore_looting, "Mixed HALO Sangheili should stop looking for replacement loot while the sword is out.")
	TEST_ASSERT(ultra_plasma.tried_reload, "Mixed HALO Sangheili should unlock the generic melee movement flow while sword-committed.")
	TEST_ASSERT(/datum/ai_action/fire_at_target in ultra_plasma.action_blacklist, "Mixed HALO Sangheili should suppress firearm firing actions while the sword is active.")
	TEST_ASSERT(/datum/ai_action/select_primary in ultra_plasma.action_blacklist, "Mixed HALO Sangheili should suppress firearm reselection while the sword is active.")
	TEST_ASSERT_EQUAL(sword.loc, human, "The active HALO Sangheili sword should remain in the wielder's possession.")

	qdel(charge_action)

/datum/unit_test/halo_sangheili_ai_mixed_sword_return_to_ranged
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_mixed_sword_return_to_ranged/Run()
	var/datum/human_ai_brain/ultra_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma, "Failed to create the HALO mixed Sangheili AI for ranged-restore testing.")

	var/obj/item/weapon/gun/original_primary = ultra_plasma.primary_weapon
	TEST_ASSERT_NOTNULL(original_primary, "The HALO mixed Sangheili ranged-restore test requires an initial primary firearm.")

	ultra_plasma.in_combat = TRUE
	ultra_plasma.target_turf = set_target_turf(ultra_plasma, ultra_plasma.halo_sangheili_unarmed_commit_range)
	TEST_ASSERT_NOTNULL(ultra_plasma.target_turf, "Failed to allocate a close-range target turf for HALO mixed Sangheili ranged-restore testing.")

	var/datum/ai_action/sangheili_sword_charge/charge_action = new(ultra_plasma)
	charge_action.trigger_action()

	var/mob/living/carbon/human/human = ultra_plasma.tied_human
	var/obj/item/weapon/covenant/energy_sword/sword = ultra_plasma.halo_sangheili_drawn_sword
	TEST_ASSERT_NOTNULL(sword, "The HALO mixed Sangheili ranged-restore test requires the sword to be drawn first.")

	ultra_plasma.target_turf = set_target_turf(ultra_plasma, ultra_plasma.halo_sangheili_sword_charge_range + 2)
	TEST_ASSERT_NOTNULL(ultra_plasma.target_turf, "Failed to allocate a far target turf for HALO mixed Sangheili ranged-restore testing.")

	var/result = charge_action.trigger_action()
	TEST_ASSERT_EQUAL(result, ONGOING_ACTION_COMPLETED, "The HALO sword charge action should complete once the target moves back out of sword range.")

	TEST_ASSERT(!ultra_plasma.halo_sangheili_melee_committed, "Mixed HALO Sangheili should leave melee mode once the enemy is far away again.")
	TEST_ASSERT_EQUAL(ultra_plasma.primary_weapon, original_primary, "Mixed HALO Sangheili should restore its parked firearm when returning to ranged combat.")
	TEST_ASSERT(!ultra_plasma.ignore_looting, "Mixed HALO Sangheili should restore its original looting behavior after leaving sword mode.")
	TEST_ASSERT(!ultra_plasma.action_blacklist || !(/datum/ai_action/fire_at_target in ultra_plasma.action_blacklist), "Mixed HALO Sangheili should remove firearm action suppression after leaving sword mode.")
	TEST_ASSERT(!sword.activated, "HALO Sangheili should deactivate the sword when switching back to ranged combat.")
	TEST_ASSERT_NOTEQUAL(sword.loc, human, "HALO Sangheili should no longer keep the sword in hand once ranged combat resumes.")

	ultra_plasma.target_turf = null
	ultra_plasma.lose_target()
	TEST_ASSERT(!ultra_plasma.halo_sangheili_should_sword_charge(), "Mixed HALO Sangheili should not remain in sword mode without a live melee target.")

	qdel(charge_action)

/datum/unit_test/halo_sangheili_ai_terminal_sword_persistence
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_terminal_sword_persistence/Run()
	var/datum/human_ai_brain/ultra_plasma = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(ultra_plasma, "Failed to create the HALO mixed Sangheili AI for terminal sword persistence testing.")

	var/obj/item/weapon/gun/original_primary = ultra_plasma.primary_weapon
	TEST_ASSERT_NOTNULL(original_primary, "The HALO terminal sword persistence test requires an initial firearm to remove.")

	ultra_plasma.in_combat = TRUE
	ultra_plasma.target_turf = set_target_turf(ultra_plasma, ultra_plasma.halo_sangheili_unarmed_commit_range)
	TEST_ASSERT_NOTNULL(ultra_plasma.target_turf, "Failed to allocate a close-range target turf for HALO terminal sword persistence testing.")

	var/datum/ai_action/sangheili_sword_charge/charge_action = new(ultra_plasma)
	charge_action.trigger_action()

	var/mob/living/carbon/human/human = ultra_plasma.tied_human
	var/obj/item/weapon/covenant/energy_sword/sword = ultra_plasma.halo_sangheili_drawn_sword
	TEST_ASSERT_NOTNULL(sword, "The HALO terminal sword persistence test requires the sword to be drawn first.")

	qdel(original_primary)
	ultra_plasma.halo_sangheili_committed_primary_weapon = null
	ultra_plasma.target_turf = set_target_turf(ultra_plasma, ultra_plasma.halo_sangheili_sword_charge_range + 2)
	TEST_ASSERT_NOTNULL(ultra_plasma.target_turf, "Failed to allocate a far target turf for HALO terminal sword persistence testing.")

	charge_action.trigger_action()
	ultra_plasma.exit_combat()

	TEST_ASSERT_NULL(ultra_plasma.primary_weapon, "HALO no-gun Sangheili should not restore a missing firearm when keeping the sword out.")
	TEST_ASSERT(!ultra_plasma.halo_sangheili_melee_committed, "HALO no-gun Sangheili should clear melee-commit bookkeeping when combat ends.")
	TEST_ASSERT_EQUAL(sword.loc, human, "HALO no-gun Sangheili should keep the sword in hand when there is no ranged fallback.")
	TEST_ASSERT(sword.activated, "HALO no-gun Sangheili should keep the sword active instead of deactivating it on teardown.")

	qdel(charge_action)

/datum/unit_test/halo_sangheili_player_sword_manual_activation_guard
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_player_sword_manual_activation_guard/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/ultra)
	TEST_ASSERT_NOTNULL(human, "Failed to create the HALO player Sangheili for manual sword activation guard testing.")

	var/obj/item/weapon/covenant/energy_sword/sword = put_sword_in_active_hand(human)
	TEST_ASSERT_NOTNULL(sword, "Failed to move the HALO player Sangheili sword into the active hand for guard testing.")
	TEST_ASSERT(!sword.activated, "Player Sangheili sword guard test should begin with an inactive sword.")

	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT_NOTNULL(target, "Failed to allocate a target for HALO player sword guard testing.")
	human.a_intent_change(INTENT_HARM)
	sword.attack(target, human)

	TEST_ASSERT(!sword.activated, "Player-controlled Sangheili should still require manual sword activation.")

/datum/unit_test/halo_sangheili_sword_overlay_refresh
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_sword_overlay_refresh/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/ultra)
	TEST_ASSERT_NOTNULL(human, "Failed to create the HALO Sangheili for sword overlay refresh testing.")

	var/obj/item/weapon/covenant/energy_sword/sword = put_sword_in_active_hand(human)
	TEST_ASSERT_NOTNULL(sword, "Failed to move the HALO Sangheili sword into the active hand for overlay refresh testing.")

	human.update_inv_l_hand()
	human.update_inv_r_hand()
	TEST_ASSERT_EQUAL(get_held_sword_overlay_icon_state(human, sword), "energy_sword", "Inactive HALO sword overlay should start with the inactive hand state.")

	sword.set_activation_state(TRUE, human)
	TEST_ASSERT_EQUAL(get_held_sword_overlay_icon_state(human, sword), "energy_sword_activated", "Activating the HALO sword should refresh the held overlay immediately.")

	sword.set_activation_state(FALSE, human)
	TEST_ASSERT_EQUAL(get_held_sword_overlay_icon_state(human, sword), "energy_sword", "Deactivating the HALO sword should refresh the held overlay back to the inactive state.")

/datum/unit_test/halo_sangheili_sword_hand_icon_dirs
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_sword_hand_icon_dirs/Run()
	var/list/hand_icons = list(
		"left" = 'icons/halo/mob/humans/onmob/items_lefthand_halo_64.dmi',
		"right" = 'icons/halo/mob/humans/onmob/items_righthand_halo_64.dmi',
	)
	var/list/required_states = list("energy_sword", "energy_sword_activated")
	var/list/required_dirs = list(SOUTH, NORTH, EAST, WEST)

	for(var/hand_label in hand_icons)
		var/icon/hand_icon = hand_icons[hand_label]
		for(var/state in required_states)
			TEST_ASSERT(state in icon_states(hand_icon, 1), "HALO [hand_label]-hand sword DMI is missing the [state] state.")
			for(var/direction in required_dirs)
				TEST_ASSERT(length(icon_states(icon(hand_icon, state, direction))), "HALO [hand_label]-hand sword DMI is missing [state] for dir [direction].")
				TEST_ASSERT(icon_state_has_visible_pixels(hand_icon, state, direction), "HALO [hand_label]-hand sword DMI has an empty [state] sprite for dir [direction].")

/datum/unit_test/halo_sangheili_sword_runtime_render_dirs
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_sword_runtime_render_dirs/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/ultra)
	TEST_ASSERT_NOTNULL(human, "Failed to create the HALO Sangheili for sword runtime render testing.")

	var/list/hand_matrix = list(
		WEAR_L_HAND = HALO_TEST_L_HAND_LAYER,
		WEAR_R_HAND = HALO_TEST_R_HAND_LAYER,
	)
	var/list/required_dirs = list(SOUTH, NORTH, EAST, WEST)

	for(var/slot as anything in hand_matrix)
		var/overlay_layer = hand_matrix[slot]
		var/obj/item/weapon/covenant/energy_sword/sword = put_sword_in_hand(human, slot)
		TEST_ASSERT_NOTNULL(sword, "Failed to move the HALO Sangheili sword into hand slot [slot] for runtime render testing.")

		sword.set_activation_state(TRUE, human)
		for(var/direction in required_dirs)
			human.face_dir(direction)
			human.update_inv_l_hand()
			human.update_inv_r_hand()
			TEST_ASSERT(image_has_visible_pixels(human.overlays_standing[overlay_layer]), "HALO Sangheili sword overlay is not visibly rendered for slot [slot] dir [direction].")

		human.drop_held_item(sword)
		if(istype(human.belt, /obj/item/storage))
			var/obj/item/storage/belt_storage = human.belt
			belt_storage.attempt_item_insertion(sword, FALSE, human)

/datum/unit_test/halo_sangheili_ai_speech_profiles
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_speech_profiles/Run()
	var/datum/human_ai_brain/major = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/major_carbine)
	var/datum/human_ai_brain/zealot_sword = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/zealot_sword)
	TEST_ASSERT_NOTNULL(major, "Failed to create the HALO Sangheili major AI for speech-profile testing.")
	TEST_ASSERT_NOTNULL(zealot_sword, "Failed to create the HALO Sangheili zealot sword AI for speech-profile testing.")

	assert_human_ai_localized_lines(major.enter_combat_lines, "Sangheili major enter_combat_lines")
	assert_human_ai_localized_lines(major.need_healing_lines, "Sangheili major need_healing_lines")
	assert_human_ai_localized_lines(zealot_sword.enter_combat_lines, "Sangheili zealot sword enter_combat_lines")

	TEST_ASSERT(major.enter_combat_lines.Find("Покажите честь в бою."), "Sangheili major AI lost its HALO-formal base speech profile.")
	TEST_ASSERT(major.enter_combat_lines.Find("По моему слову."), "Sangheili major AI lost its rank-specific speech lines.")
	TEST_ASSERT(zealot_sword.enter_combat_lines.Find("Во имя Священного Круга!"), "Sangheili zealot AI lost its zealot-specific speech lines.")
	TEST_ASSERT(zealot_sword.enter_combat_lines.Find("Клинки к бою!"), "Sword-only Sangheili lost its sword-charge speech lines.")

/datum/unit_test/halo_sangheili_shield_flicker
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_shield_flicker/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/minor)
	human.face_dir(EAST)
	var/obj/item/clothing/suit/marine/shielded/sangheili/harness = human.wear_suit
	TEST_ASSERT_NOTNULL(harness, "Failed to equip a Sangheili shield harness for the flicker test.")

	var/overlays_before = length(human.overlays)
	harness.take_damage(5, human)
	TEST_ASSERT(length(human.overlays) > overlays_before, "Sangheili shield damage no longer adds the onmob flicker overlay.")

/datum/unit_test/halo_sangheili_shield_processing_lifecycle
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_shield_processing_lifecycle/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/minor)
	var/obj/item/clothing/suit/marine/shielded/sangheili/harness = human.wear_suit
	TEST_ASSERT_NOTNULL(harness, "Failed to equip a Sangheili shield harness for the processing lifecycle test.")

	harness.update_shield_runtime_state()
	TEST_ASSERT(!(harness in SSfastobj.processing), "An idle Sangheili shield harness should not stay in SSfastobj while fully charged.")

	harness.take_damage(10, human)
	TEST_ASSERT(harness in SSfastobj.processing, "A damaged Sangheili shield harness should enter SSfastobj while it is recovering.")

	harness.shield_strength = harness.max_shield_strength
	harness.shield_broken = FALSE
	COOLDOWN_RESET(harness, time_to_regen)
	harness.update_shield_runtime_state()
	TEST_ASSERT(!(harness in SSfastobj.processing), "A fully recovered Sangheili shield harness should leave SSfastobj once it becomes idle again.")

/datum/unit_test/halo_sangheili_shield_full_absorb
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_shield_full_absorb/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/minor)
	human.face_dir(EAST)
	var/obj/item/clothing/suit/marine/shielded/sangheili/harness = human.wear_suit
	TEST_ASSERT_NOTNULL(harness, "Failed to equip a Sangheili shield harness for the bullet absorb test.")

	var/starting_shield = harness.shield_strength
	var/starting_brute = human.getBruteLoss()
	var/starting_fire = human.getFireLoss()
	var/overlays_before = length(human.overlays)
	var/obj/projectile/projectile = create_test_projectile(human, /datum/ammo/energy/halo_plasma/plasma_pistol/overcharge)

	human.bullet_act(projectile)

	TEST_ASSERT(harness.shield_strength < starting_shield, "Sangheili harness did not absorb any projectile damage.")
	TEST_ASSERT_EQUAL(human.getBruteLoss(), starting_brute, "A fully shielded projectile hit should not inflict brute damage through an intact Sangheili shield.")
	TEST_ASSERT_EQUAL(human.getFireLoss(), starting_fire, "A fully shielded projectile hit should not inflict burn damage through an intact Sangheili shield.")
	TEST_ASSERT(length(human.overlays) > overlays_before, "A fully shielded projectile hit should still show the Sangheili shield flicker.")

/datum/unit_test/halo_sangheili_shield_partial_absorb
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_shield_partial_absorb/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/minor)
	var/obj/item/clothing/suit/marine/shielded/sangheili/harness = human.wear_suit
	TEST_ASSERT_NOTNULL(harness, "Failed to equip a Sangheili shield harness for the partial absorb test.")

	harness.shield_strength = 5
	harness.shield_broken = FALSE
	var/residual_damage = harness.intercept_projectile_damage(human, 12)

	TEST_ASSERT_EQUAL(residual_damage, 7, "Sangheili shield partial absorb no longer returns the expected residual damage.")
	TEST_ASSERT_EQUAL(harness.shield_strength, 0, "Sangheili shield partial absorb should deplete the remaining shield strength.")
	TEST_ASSERT(harness.shield_broken, "Sangheili shield partial absorb should overload and break the harness when the shield reaches zero.")

/datum/unit_test/halo_sangheili_shield_signal_cleanup
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_shield_signal_cleanup/Run()
	var/mob/living/carbon/human/human = create_sangheili(/datum/equipment_preset/covenant/sangheili/minor)
	var/obj/item/clothing/suit/marine/shielded/sangheili/harness = human.wear_suit
	TEST_ASSERT_NOTNULL(harness, "Failed to equip a Sangheili shield harness for the signal cleanup test.")

	harness.take_damage(5, human)
	TEST_ASSERT(harness in SSfastobj.processing, "A worn Sangheili harness should begin processing after taking shield damage.")

	human.u_equip(harness, run_loc_floor_top_right)
	harness.update_shield_runtime_state()

	var/starting_shield = harness.shield_strength
	var/residual_damage = harness.intercept_projectile_damage(human, 15)

	TEST_ASSERT(!(harness in SSfastobj.processing), "An unequipped Sangheili harness should leave SSfastobj immediately.")
	TEST_ASSERT_EQUAL(residual_damage, 15, "An unequipped Sangheili harness should not still absorb projectile damage.")
	TEST_ASSERT_EQUAL(harness.shield_strength, starting_shield, "An unequipped Sangheili harness should not mutate its shield pool on human projectile signals.")

/datum/unit_test/halo_sangheili_ai_item_search_throttle
	parent_type = /datum/unit_test/halo_sangheili_equipment

/datum/unit_test/halo_sangheili_ai_item_search_throttle/Run()
	var/datum/human_ai_brain/brain = create_sangheili_ai_brain(/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma)
	TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO Sangheili AI for the item-search throttling test.")
	TEST_ASSERT(brain.nearby_item_search_interval > 0, "HALO Sangheili AI should enable nearby item-search throttling.")
	TEST_ASSERT(brain.should_run_nearby_item_search(), "A freshly created HALO Sangheili AI should allow its first nearby item scan.")
	TEST_ASSERT(!brain.should_run_nearby_item_search(), "HALO nearby item-search throttling should block an immediate second scan in the same state.")
	brain.invalidate_nearby_item_search()
	TEST_ASSERT(brain.should_run_nearby_item_search(), "Invalidating HALO nearby item-search throttling should force the next scan to run immediately.")

#undef HALO_TEST_R_HAND_LAYER
#undef HALO_TEST_L_HAND_LAYER
