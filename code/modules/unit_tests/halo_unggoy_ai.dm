/datum/unit_test/halo_unggoy_ai/proc/create_unggoy_ai_brain(preset_type)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	arm_equipment(human, preset_type, FALSE)
	var/datum/component/human_ai/ai_component = human.AddComponent(/datum/component/human_ai)
	if(!ai_component)
		TEST_FAIL("Failed to add a human AI component to the HALO Unggoy test mob.")
		return null
	if(!ai_component.ai_brain)
		TEST_FAIL("Failed to resolve a human AI brain for the HALO Unggoy test mob.")
		return null
	ai_component.ai_brain.appraise_inventory(armor = TRUE)
	if(isgun(human.s_store))
		ai_component.ai_brain.set_primary_weapon(human.s_store)
	return ai_component.ai_brain

/datum/unit_test/halo_unggoy_ai/proc/create_test_projectile(mob/living/carbon/human/firer, ammo_type)
	var/obj/projectile/projectile = allocate(/obj/projectile, run_loc_floor_top_right)
	var/datum/ammo/ammo = allocate(ammo_type)
	projectile.generate_bullet(ammo, 0, 0, firer)
	projectile.starting = get_turf(firer)
	projectile.def_zone = "chest"
	projectile.firer = firer
	return projectile

/datum/unit_test/halo_unggoy_ai/proc/pathfinding_noop_callback(list/path)
	return

/datum/unit_test/halo_unggoy_ai/Run()
	return

/datum/unit_test/halo_unggoy_ai/proc/get_first_assoc_key(list/assoc_list)
	for(var/entry as anything in assoc_list)
		return entry

/datum/unit_test/halo_unggoy_ai/proc/set_target_turf(datum/human_ai_brain/brain, distance)
	var/turf/origin = get_turf(brain?.tied_human)
	if(!origin)
		return null

	return locate(origin.x + distance, origin.y, origin.z)

/datum/unit_test/halo_unggoy_ai_equipment_matrix
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_equipment_matrix/Run()
	var/list/preset_matrix = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = list("suit" = /obj/item/clothing/suit/marine/unggoy/minor, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/minor),
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = list("suit" = /obj/item/clothing/suit/marine/unggoy/minor, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/minor),
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = list("suit" = /obj/item/clothing/suit/marine/unggoy/major, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/major),
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = list("suit" = /obj/item/clothing/suit/marine/unggoy/major, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/major),
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = list("suit" = /obj/item/clothing/suit/marine/unggoy/heavy, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/heavy),
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = list("suit" = /obj/item/clothing/suit/marine/unggoy/heavy, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/heavy),
		/datum/equipment_preset/covenant/unggoy/ai/ultra = list("suit" = /obj/item/clothing/suit/marine/unggoy/ultra, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/ultra),
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = list("suit" = /obj/item/clothing/suit/marine/unggoy/major, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/major),
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma = list("suit" = /obj/item/clothing/suit/marine/stealth/unggoy_specops, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/specops),
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler = list("suit" = /obj/item/clothing/suit/marine/stealth/unggoy_specops, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/specops),
		/datum/equipment_preset/covenant/unggoy/ai/specops_ultra = list("suit" = /obj/item/clothing/suit/marine/stealth/unggoy_specops/ultra, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/specops_ultra),
		/datum/equipment_preset/covenant/unggoy/ai/deacon_command = list("suit" = /obj/item/clothing/suit/marine/unggoy/deacon, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/ultra),
		/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber = list("suit" = /obj/item/clothing/suit/marine/unggoy/minor, "belt" = /obj/item/storage/belt/marine/covenant/unggoy/minor),
	)

	for(var/preset_type as anything in preset_matrix)
		var/datum/human_ai_brain/brain = create_unggoy_ai_brain(preset_type)
		TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO Unggoy AI for [preset_type].")
		var/mob/living/carbon/human/human = brain.tied_human
		var/list/expected = preset_matrix[preset_type]

		TEST_ASSERT_EQUAL(human.species?.name, SPECIES_UNGGOY, "[preset_type] did not set the expected Unggoy species.")
		TEST_ASSERT(istype(human.wear_mask, /obj/item/clothing/mask/gas/unggoy), "[preset_type] did not equip the expected Unggoy rebreather.")
		TEST_ASSERT(istype(human.wear_suit, expected["suit"]), "[preset_type] did not equip the expected HALO armor type.")
		TEST_ASSERT(istype(human.belt, expected["belt"]), "[preset_type] did not equip the expected HALO belt type.")

/datum/unit_test/halo_unggoy_ai_needler_ammo
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_needler_ammo/Run()
	var/list/needler_presets = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler,
		/datum/equipment_preset/covenant/unggoy/ai/major_needler,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler,
	)

	for(var/preset_type as anything in needler_presets)
		var/datum/human_ai_brain/brain = create_unggoy_ai_brain(preset_type)
		TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO Unggoy needler AI for [preset_type].")
		var/mob/living/carbon/human/human = brain.tied_human
		TEST_ASSERT(istype(human.s_store, /obj/item/weapon/gun/smg/covenant_needler), "[preset_type] did not equip a needler into suit storage.")

		brain.set_primary_weapon(human.s_store)
		var/obj/item/ammo_magazine/needler_crystal/crystals = brain.weapon_ammo_search(brain.primary_weapon)
		TEST_ASSERT_NOTNULL(crystals, "[preset_type] did not expose needler crystals through the AI ammunition map.")
		TEST_ASSERT(length(brain.equipment_map[HUMAN_AI_AMMUNITION]) >= 1, "[preset_type] did not retain readable ammunition in the AI equipment map.")

/datum/unit_test/halo_unggoy_ai_bomber_overrides
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_bomber_overrides/Run()
	var/datum/human_ai_brain/brain = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber)
	TEST_ASSERT_NOTNULL(brain, "Failed to create the HALO Unggoy suicide bomber test AI.")
	TEST_ASSERT(brain.halo_suicide_bomber, "Unggoy suicide bomber lost its HALO bomber override.")
	TEST_ASSERT_EQUAL(brain.halo_suicide_prime_range, 5, "Unggoy suicide bomber prime range drifted from the intended HALO value.")
	TEST_ASSERT(brain.ignore_looting, "Unggoy suicide bomber should ignore looting while charging.")
	TEST_ASSERT(!brain.grenading_allowed, "Unggoy suicide bomber should not use the generic grenade-throw action.")
	TEST_ASSERT(brain.halo_unggoy_ignore_panic, "Unggoy suicide bomber should bypass panic-retreat behavior.")
	TEST_ASSERT(!brain.halo_unggoy_overheat_retreat, "Unggoy suicide bomber should remain exempt from the HALO overheat-retreat behavior.")

/datum/unit_test/halo_unggoy_ai_panic_behavior
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_panic_behavior/Run()
	var/list/panicking_presets = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma,
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical,
		/datum/equipment_preset/covenant/unggoy/ai/deacon_command,
	)
	var/list/steady_presets = list(
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler,
		/datum/equipment_preset/covenant/unggoy/ai/ultra,
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler,
		/datum/equipment_preset/covenant/unggoy/ai/specops_ultra,
		/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber,
	)

	for(var/preset_type as anything in panicking_presets)
		var/datum/human_ai_brain/brain = create_unggoy_ai_brain(preset_type)
		TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO Unggoy panic-role AI for [preset_type].")
		brain.tied_human.health = brain.tied_human.maxHealth * 0.1
		TEST_ASSERT(brain.halo_unggoy_should_panic(), "[preset_type] should enable HALO panic-retreat when heavily wounded.")

	for(var/preset_type as anything in steady_presets)
		var/datum/human_ai_brain/brain = create_unggoy_ai_brain(preset_type)
		TEST_ASSERT_NOTNULL(brain, "Failed to create a HALO Unggoy steady-role AI for [preset_type].")
		brain.tied_human.health = brain.tied_human.maxHealth * 0.1
		TEST_ASSERT(!brain.halo_unggoy_should_panic(), "[preset_type] should not enable HALO panic-retreat when heavily wounded.")

/datum/unit_test/halo_unggoy_ai_overheat_retreat
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_overheat_retreat/Run()
	var/datum/human_ai_brain/leader = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/major_plasma)
	var/datum/human_ai_brain/member = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma)
	TEST_ASSERT_NOTNULL(leader, "Failed to create the HALO Unggoy leader AI for overheat testing.")
	TEST_ASSERT_NOTNULL(member, "Failed to create the HALO Unggoy member AI for overheat testing.")

	var/datum/human_ai_squad/squad = SShuman_ai.create_new_squad()
	squad.add_to_squad(leader)
	squad.add_to_squad(member)
	squad.set_squad_leader(leader)

	member.in_combat = TRUE
	member.target_turf = set_target_turf(member, 3)
	TEST_ASSERT_NOTNULL(member.target_turf, "Failed to allocate an Unggoy overheat target turf.")
	var/obj/item/weapon/gun/energy/plasma/member_plasma = member.primary_weapon
	COOLDOWN_START(member_plasma, cooldown, 5 SECONDS)

	TEST_ASSERT(member.halo_unggoy_should_retreat_on_overheat(), "A plasma-armed Unggoy should retreat while its Covenant weapon cools.")
	TEST_ASSERT(member.halo_unggoy_should_hold_anchor_on_overheat(), "A leader-supported Unggoy should keep local cohesion during overheat retreat.")
	TEST_ASSERT(!member.halo_unggoy_should_flee_on_overheat(), "A leader-supported Unggoy should not use the leaderless overheat flee branch.")

	squad.set_squad_leader(null)
	TEST_ASSERT(member.halo_unggoy_should_retreat_on_overheat(), "Leaderless Unggoy should still retreat while their weapon cools.")
	TEST_ASSERT(member.halo_unggoy_should_flee_on_overheat(), "Leaderless Unggoy should use the HALO flee branch during overheat retreat.")

	COOLDOWN_RESET(member_plasma, cooldown)
	COOLDOWN_RESET(member_plasma, manual_cooldown)
	TEST_ASSERT(!member.halo_unggoy_should_retreat_on_overheat(), "Unggoy overheat retreat should end immediately after the plasma cooldown finishes.")

	var/datum/human_ai_brain/bomber = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber)
	TEST_ASSERT_NOTNULL(bomber, "Failed to create the HALO Unggoy bomber AI for overheat testing.")
	bomber.in_combat = TRUE
	bomber.target_turf = set_target_turf(bomber, 3)
	TEST_ASSERT_NOTNULL(bomber.target_turf, "Failed to allocate an Unggoy bomber overheat target turf.")
	TEST_ASSERT(!bomber.halo_unggoy_should_retreat_on_overheat(), "Unggoy suicide bombers should remain exempt from overheat retreat.")

	qdel(squad)

/datum/unit_test/halo_unggoy_ai_adjacent_move_shortcut
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_adjacent_move_shortcut/Run()
	var/datum/human_ai_brain/brain = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma)
	TEST_ASSERT_NOTNULL(brain, "Failed to create the HALO Unggoy AI for adjacent-move shortcut testing.")

	var/turf/origin = run_loc_floor_bottom_left
	var/turf/adjacent_turf = get_step(origin, EAST)
	TEST_ASSERT(isfloorturf(origin), "The unit-test origin turf for adjacent-move shortcut testing was not a floor ([origin]).")
	TEST_ASSERT(isfloorturf(adjacent_turf), "The adjacent destination turf for adjacent-move shortcut testing was not a floor ([adjacent_turf]).")

	brain.tied_human.forceMove(origin)
	brain.ai_move_delay = 0
	brain.current_path = list(run_loc_floor_top_right)
	brain.current_path_target = run_loc_floor_top_right

	TEST_ASSERT(brain.move_to_next_turf(adjacent_turf), "Adjacent HALO AI movement should use the cheap direct-step path instead of failing.")
	TEST_ASSERT_EQUAL(get_turf(brain.tied_human), adjacent_turf, "Adjacent HALO AI movement did not move the human onto the requested turf.")
	TEST_ASSERT_NULL(brain.current_path, "Adjacent HALO AI movement should clear stale path data after a direct step.")
	TEST_ASSERT_NULL(brain.current_path_target, "Adjacent HALO AI movement should clear the stale path target after a direct step.")

/datum/unit_test/halo_unggoy_ai_short_step_pathing
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_short_step_pathing/Run()
	var/datum/human_ai_brain/brain = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma)
	TEST_ASSERT_NOTNULL(brain, "Failed to create the HALO Unggoy AI for short-step pathing tests.")
	TEST_ASSERT_EQUAL(brain.short_step_pathing_range, 4, "HALO Unggoy AI should opt into the nearby short-step pathing helper.")
	TEST_ASSERT_EQUAL(brain.path_target_retarget_slack, 1, "HALO Unggoy AI should tolerate one tile of moving-target drift before rebuilding a path.")

	var/turf/origin = run_loc_floor_bottom_left
	brain.tied_human.forceMove(origin)
	brain.ai_move_delay = 0

	var/turf/reference_target = set_target_turf(brain, 2)
	TEST_ASSERT(isfloorturf(reference_target), "The reference target turf for HALO Unggoy retarget-slack testing was not a floor ([reference_target]).")
	var/turf/slack_target = get_step(reference_target, EAST)
	var/turf/far_target = get_step(slack_target, EAST)
	TEST_ASSERT(isfloorturf(slack_target), "The one-tile drift target for HALO Unggoy retarget-slack testing was not a floor ([slack_target]).")
	TEST_ASSERT(isfloorturf(far_target), "The two-tile drift target for HALO Unggoy retarget-slack testing was not a floor ([far_target]).")

	brain.current_path = list(reference_target)
	brain.current_path_target = reference_target
	TEST_ASSERT(!brain.path_target_needs_refresh(slack_target), "HALO Unggoy AI should keep the current path target when the destination only drifts by one tile.")
	TEST_ASSERT(brain.path_target_needs_refresh(far_target), "HALO Unggoy AI should rebuild the path once the destination drifts beyond the configured slack.")

	var/turf/destination = set_target_turf(brain, 3)
	TEST_ASSERT(isfloorturf(destination), "The non-adjacent HALO Unggoy short-step destination was not a floor ([destination]).")

	brain.ai_move_delay = 0
	brain.current_path = list(run_loc_floor_top_right)
	brain.current_path_target = run_loc_floor_top_right

	TEST_ASSERT(brain.move_to_next_turf(destination), "HALO Unggoy AI should take a cheap local step toward nearby destinations before requesting full pathfinding.")
	TEST_ASSERT_EQUAL(get_turf(brain.tied_human), get_step(origin, EAST), "HALO Unggoy short-step pathing did not advance the AI one turf toward the destination.")
	TEST_ASSERT_NULL(brain.current_path, "HALO Unggoy short-step pathing should clear stale path data after the direct local move.")
	TEST_ASSERT_NULL(brain.current_path_target, "HALO Unggoy short-step pathing should clear the stale path target after the direct local move.")

/datum/unit_test/halo_unggoy_ai_local_detour_pathing
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_local_detour_pathing/Run()
	var/datum/human_ai_brain/brain = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma)
	TEST_ASSERT_NOTNULL(brain, "Failed to create the HALO Unggoy AI for local-detour pathing tests.")

	var/turf/origin = run_loc_floor_bottom_left
	var/turf/blocked_turf = get_step(origin, EAST)
	var/turf/detour_north = get_step(origin, NORTH)
	TEST_ASSERT(isfloorturf(origin), "The HALO detour origin turf was not a floor ([origin]).")
	TEST_ASSERT(isfloorturf(blocked_turf), "The blocked path turf for HALO detour testing was not a floor ([blocked_turf]).")
	TEST_ASSERT(isfloorturf(detour_north), "The detour turf for HALO detour testing was not a floor ([detour_north]).")
	// SS220 EDIT - START: choose a non-adjacent destination that stays inside the tiny unit-test floor strip
	brain.tied_human.forceMove(origin)
	var/turf/destination = set_target_turf(brain, 4)
	// SS220 EDIT - END
	TEST_ASSERT(isfloorturf(destination), "The HALO detour destination turf was not a floor ([destination]).")

	brain.ai_move_delay = 0
	brain.current_path = list(destination, blocked_turf)
	brain.current_path_target = destination

	// SS220 EDIT - START: exercise the local-detour helper directly because human mobs do not form a reliable hard blocker on a shared turf
	TEST_ASSERT(brain.try_local_detour_towards_turf(destination, blocked_turf), "HALO AI should keep movement alive by taking a local detour when the next path turf is blocked.")
	TEST_ASSERT_NOTEQUAL(get_turf(brain.tied_human), origin, "HALO AI remained stuck on the origin turf instead of taking a local detour around the blocked path step.")
	TEST_ASSERT_NOTEQUAL(get_turf(brain.tied_human), blocked_turf, "HALO AI incorrectly walked into the blocked path step instead of side-stepping.")
	// SS220 EDIT - END
	TEST_ASSERT_NULL(brain.current_path, "HALO local detour pathing should clear the stale path after taking a side-step.")
	TEST_ASSERT_NULL(brain.current_path_target, "HALO local detour pathing should clear the stale path target after taking a side-step.")

/datum/unit_test/halo_ai_pathfinding_repath_reset
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_ai_pathfinding_repath_reset/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/start = get_turf(human)
	// SS220 EDIT - START: stay on valid floor turfs inside the reserved unit-test map
	var/turf/first_destination = locate(start.x + 3, start.y, start.z)
	var/turf/second_destination = locate(start.x + 4, start.y, start.z)
	// SS220 EDIT - END
	TEST_ASSERT(isfloorturf(first_destination), "The first pathfinding reset destination was not a floor ([first_destination]).")
	TEST_ASSERT(isfloorturf(second_destination), "The second pathfinding reset destination was not a floor ([second_destination]).")

	SSpathfinding.calculate_path(human, first_destination, 20, human, CALLBACK(src, TYPE_PROC_REF(/datum/unit_test/halo_unggoy_ai, pathfinding_noop_callback)), list(human))
	var/datum/xeno_pathinfo/data = SSpathfinding.hash_path[human]
	TEST_ASSERT_NOTNULL(data, "Pathfinding reset test failed to register a queued path for the test human.")

	data.visited_nodes += run_loc_floor_top_right
	data.distances[run_loc_floor_top_right] = 99
	data.f_distances[run_loc_floor_top_right] = 199
	data.prev[run_loc_floor_top_right] = start

	SSpathfinding.calculate_path(human, second_destination, 20, human, CALLBACK(src, TYPE_PROC_REF(/datum/unit_test/halo_unggoy_ai, pathfinding_noop_callback)), list(human))

	TEST_ASSERT_EQUAL(length(data.visited_nodes), 1, "Re-pathing should reset stale visited nodes before starting the new A* search.")
	TEST_ASSERT_EQUAL(data.visited_nodes[1], start, "Re-pathing should restart the frontier from the agent's current turf.")
	TEST_ASSERT_EQUAL(length(data.distances), 1, "Re-pathing should discard stale distance state before recalculating.")
	TEST_ASSERT_EQUAL(data.distances[start], 0, "Re-pathing should reset the start turf distance to zero.")
	TEST_ASSERT_NULL(data.distances[run_loc_floor_top_right], "Re-pathing should discard stale distances from the previous unfinished search.")
	TEST_ASSERT_EQUAL(data.finish, second_destination, "Re-pathing should replace the old destination with the latest requested turf.")

/datum/unit_test/halo_unggoy_ai_vehicle_locker_interaction
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_vehicle_locker_interaction/Run()
	var/datum/human_ai_brain/brain = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma)
	TEST_ASSERT_NOTNULL(brain, "Failed to create the HALO Unggoy AI for clientless vehicle-locker interaction testing.")

	var/obj/structure/vehicle_locker/cabinet/cups/cabinet = allocate(/obj/structure/vehicle_locker/cabinet/cups, run_loc_floor_top_right)
	TEST_ASSERT_NOTNULL(cabinet?.container, "Vehicle locker test setup failed to initialize the cabinet's internal storage.")
	TEST_ASSERT(!brain.tied_human.client, "The HALO AI vehicle-locker interaction test expects a clientless AI human.")

	cabinet.human_ai_act(brain.tied_human, brain)

	TEST_ASSERT(!length(cabinet.container.content_watchers), "Clientless HALO AI should not register as a vehicle-locker storage watcher.")
	TEST_ASSERT_NULL(brain.tied_human.s_active, "Clientless HALO AI should not open a vehicle-locker storage UI.")

/datum/unit_test/halo_ai_projectile_backpressure
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_ai_projectile_backpressure/Run()
	var/mob/living/carbon/human/firer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	firer.mob_flags |= AI_CONTROLLED
	target.mob_flags |= AI_CONTROLLED

	var/obj/item/weapon/gun/energy/plasma/plasma_rifle/plasma_rifle = allocate(/obj/item/weapon/gun/energy/plasma/plasma_rifle, run_loc_floor_top_right)
	var/obj/item/weapon/gun/smg/covenant_needler/needler = allocate(/obj/item/weapon/gun/smg/covenant_needler, run_loc_floor_top_right)
	var/obj/item/weapon/gun/rifle/covenant_carbine/carbine = allocate(/obj/item/weapon/gun/rifle/covenant_carbine, run_loc_floor_top_right)

	TEST_ASSERT_NOTNULL(plasma_rifle.GetComponent(/datum/component/halo_projectile_backpressure), "Plasma rifle should register the HALO projectile backpressure component.")
	TEST_ASSERT_NOTNULL(needler.GetComponent(/datum/component/halo_projectile_backpressure), "Needler should register the HALO projectile backpressure component.")
	TEST_ASSERT_NOTNULL(carbine.GetComponent(/datum/component/halo_projectile_backpressure), "Carbine should register the HALO projectile backpressure component.")

	var/datum/ammo/energy/halo_plasma/plasma_ammo = allocate(/datum/ammo/energy/halo_plasma/plasma_rifle)
	TEST_ASSERT(!halo_should_backpressure_ai_only_projectile_fire(firer, target, plasma_ammo, 119), "HALO AI projectile backpressure should stay idle below the queue limit.")
	TEST_ASSERT(halo_should_backpressure_ai_only_projectile_fire(firer, target, plasma_ammo, 120), "HALO AI projectile backpressure should trigger at the queue limit.")
	TEST_ASSERT(halo_should_backpressure_ai_only_gun_fire(plasma_rifle, firer, target, 120), "HALO gun-level backpressure should reuse the same projectile-pressure gate.")

	target.mob_flags &= ~AI_CONTROLLED
	TEST_ASSERT(!halo_should_backpressure_ai_only_projectile_fire(firer, target, plasma_ammo, 120), "HALO projectile backpressure should not throttle player-facing fire.")

/datum/unit_test/halo_ai_projectile_pressure_ai_helpers
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_ai_projectile_pressure_ai_helpers/Run()
	var/datum/human_ai_brain/brain = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_needler)
	TEST_ASSERT_NOTNULL(brain, "Failed to create the HALO Unggoy AI for projectile-pressure helper testing.")

	brain.in_combat = TRUE
	brain.target_turf = set_target_turf(brain, 3)
	TEST_ASSERT_NOTNULL(brain.target_turf, "Failed to allocate a HALO projectile-pressure target turf.")

	TEST_ASSERT(!brain.halo_should_suspend_nearby_item_search(119), "HALO AI should keep nearby-item scans below the projectile soft limit.")
	TEST_ASSERT(brain.halo_should_suspend_nearby_item_search(120), "HALO AI should suspend nearby-item scans once projectile pressure reaches the soft limit.")
	TEST_ASSERT(!brain.halo_should_disable_cover_retreat(179), "HALO AI should keep cover retreat available below the hard projectile limit.")
	TEST_ASSERT(brain.halo_should_disable_cover_retreat(180), "HALO AI should prefer cheap retreat once projectile pressure reaches the hard limit.")
	TEST_ASSERT(!brain.halo_should_defer_ranged_fire(brain.target_turf, 119), "HALO AI should keep ranged fire enabled below the projectile soft limit.")
	TEST_ASSERT(brain.halo_should_defer_ranged_fire(brain.target_turf, 120), "HALO AI should defer ranged fire at the projectile soft limit.")

/datum/unit_test/halo_unggoy_ai_firearm_appraisals
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_firearm_appraisals/Run()
	var/obj/item/weapon/gun/energy/plasma/plasma_pistol/plasma_pistol = allocate(/obj/item/weapon/gun/energy/plasma/plasma_pistol, run_loc_floor_top_right)
	var/obj/item/weapon/gun/energy/plasma/plasma_rifle/plasma_rifle = allocate(/obj/item/weapon/gun/energy/plasma/plasma_rifle, run_loc_floor_top_right)
	var/obj/item/weapon/gun/smg/covenant_needler/needler = allocate(/obj/item/weapon/gun/smg/covenant_needler, run_loc_floor_top_right)
	var/obj/item/weapon/gun/rifle/covenant_carbine/carbine = allocate(/obj/item/weapon/gun/rifle/covenant_carbine, run_loc_floor_top_right)

	TEST_ASSERT_EQUAL(get_firearm_appraisal(plasma_pistol)?.type, /datum/firearm_appraisal/halo_plasma_pistol, "Plasma pistol lost its HALO-specific firearm appraisal.")
	TEST_ASSERT_EQUAL(get_firearm_appraisal(plasma_rifle)?.type, /datum/firearm_appraisal/halo_plasma_rifle, "Plasma rifle lost its HALO-specific firearm appraisal.")
	TEST_ASSERT_EQUAL(get_firearm_appraisal(needler)?.type, /datum/firearm_appraisal/halo_needler, "Needler lost its HALO-specific firearm appraisal.")
	TEST_ASSERT_EQUAL(get_firearm_appraisal(carbine)?.type, /datum/firearm_appraisal/halo_carbine, "Carbine lost its HALO-specific firearm appraisal.")
	TEST_ASSERT(get_firearm_appraisal(plasma_rifle)?.count_every_shot_toward_burst_limit, "HALO plasma rifle AI appraisal should count each shot toward the sustained-fire cap.")
	TEST_ASSERT(get_firearm_appraisal(needler)?.count_every_shot_toward_burst_limit, "HALO needler AI appraisal should count each shot toward the sustained-fire cap.")
	TEST_ASSERT(get_firearm_appraisal(carbine)?.count_every_shot_toward_burst_limit, "HALO carbine AI appraisal should count each shot toward the sustained-fire cap.")

/datum/unit_test/halo_unggoy_ai_speech_profiles
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_speech_profiles/Run()
	var/datum/human_ai_brain/minor = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/minor_plasma)
	var/datum/human_ai_brain/support = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/support_medical)
	var/datum/human_ai_brain/bomber = create_unggoy_ai_brain(/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber)
	TEST_ASSERT_NOTNULL(minor, "Failed to create the HALO Unggoy minor AI for speech-profile testing.")
	TEST_ASSERT_NOTNULL(support, "Failed to create the HALO Unggoy support AI for speech-profile testing.")
	TEST_ASSERT_NOTNULL(bomber, "Failed to create the HALO Unggoy bomber AI for speech-profile testing.")

	assert_human_ai_localized_lines(minor.enter_combat_lines, "Unggoy minor enter_combat_lines")
	assert_human_ai_localized_lines(support.need_healing_lines, "Unggoy support need_healing_lines")
	assert_human_ai_localized_lines(bomber.enter_combat_lines, "Unggoy bomber enter_combat_lines")

	TEST_ASSERT(minor.enter_combat_lines.Find("Начальник, помоги!"), "Unggoy AI lost its baseline panic-flavored speech lines.")
	TEST_ASSERT(support.need_healing_lines.Find("Не дайте мне умереть, я же медик!"), "Unggoy support AI lost its medical-role speech lines.")
	TEST_ASSERT(bomber.enter_combat_lines.Find("Я вас с собой заберу!"), "Unggoy bomber AI lost its suicide-role speech lines.")

/datum/unit_test/halo_unggoy_ai_squad_compositions
	parent_type = /datum/unit_test/halo_unggoy_ai

/datum/unit_test/halo_unggoy_ai_squad_compositions/Run()
	var/list/leader_matrix = list(
		/datum/human_ai_squad_preset/covenant/unggoy_fireteam = /datum/equipment_preset/covenant/unggoy/ai/major_plasma,
		/datum/human_ai_squad_preset/covenant/unggoy_assault_team = /datum/equipment_preset/covenant/unggoy/ai/major_needler,
		/datum/human_ai_squad_preset/covenant/unggoy_heavy_team = /datum/equipment_preset/covenant/unggoy/ai/ultra,
		/datum/human_ai_squad_preset/covenant/unggoy_support_team = /datum/equipment_preset/covenant/unggoy/ai/deacon_command,
		/datum/human_ai_squad_preset/covenant/unggoy_at_team = /datum/equipment_preset/covenant/unggoy/ai/ultra,
		/datum/human_ai_squad_preset/covenant/unggoy_specops_cell = /datum/equipment_preset/covenant/unggoy/ai/specops_ultra,
		/datum/human_ai_squad_preset/covenant/covenant_lance = /datum/equipment_preset/covenant/sangheili/ai/minor_plasma,
		/datum/human_ai_squad_preset/covenant/covenant_heavy_lance = /datum/equipment_preset/covenant/sangheili/ai/ultra_plasma,
		/datum/human_ai_squad_preset/covenant/covenant_at_lance = /datum/equipment_preset/covenant/sangheili/ai/zealot_command,
		/datum/human_ai_squad_preset/covenant/sangheili_pair = /datum/equipment_preset/covenant/sangheili/ai/minor_plasma,
		/datum/human_ai_squad_preset/covenant/sangheili_fireteam = /datum/equipment_preset/covenant/sangheili/ai/major_carbine,
		/datum/human_ai_squad_preset/covenant/sangheili_elite_team = /datum/equipment_preset/covenant/sangheili/ai/ultra_plasma,
		/datum/human_ai_squad_preset/covenant/sangheili_sword_pair = /datum/equipment_preset/covenant/sangheili/ai/ultra_sword,
		/datum/human_ai_squad_preset/covenant/sangheili_zealot_strike_cell = /datum/equipment_preset/covenant/sangheili/ai/zealot_sword,
	)

	for(var/preset_type as anything in leader_matrix)
		var/datum/human_ai_squad_preset/preset = allocate(preset_type)
		var/first_entry = get_first_assoc_key(preset.ai_to_spawn)
		TEST_ASSERT_EQUAL(first_entry, leader_matrix[preset_type], "[preset_type] no longer exposes its intended squad leader as the first spawned unit.")

	for(var/squad_type in subtypesof(/datum/human_ai_squad_preset/covenant))
		var/datum/human_ai_squad_preset/preset = allocate(squad_type)
		for(var/equipment_path as anything in preset.ai_to_spawn)
			TEST_ASSERT(!findtext("[equipment_path]", "anti_tank_temp"), "[squad_type] still references the retired temporary anti-tank Unggoy role.")
			if(findtext("[squad_type]", "/sangheili_"))
				TEST_ASSERT(findtext("[equipment_path]", "/sangheili/"), "[squad_type] should only contain Sangheili equipment presets.")
