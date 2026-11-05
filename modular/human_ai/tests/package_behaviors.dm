#define HUMAN_AI_TEST_COVER_SCAN_LIMIT 198

// SS220 EDIT - START: rear visual stealth is broken only by explicit hostile actions, never yellow Grab
/datum/unit_test/human_ai_rear_stealth_detection

/datum/unit_test/human_ai_rear_stealth_detection/Run()
	var/turf/ai_turf = run_loc_floor_bottom_left
	var/turf/front_turf = get_step(ai_turf, NORTH)
	var/turf/rear_turf = get_step(ai_turf, SOUTH)
	TEST_ASSERT_NOTNULL(front_turf, "Human AI rear-stealth test area must contain a northern turf.")
	TEST_ASSERT_NOTNULL(rear_turf, "Human AI rear-stealth test area must contain a southern turf.")

	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, ai_turf)
	ai_human.faction = FACTION_UNSC
	ai_human.setDir(NORTH)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, ai_human)
	brain.has_nightvision = TRUE

	var/mob/living/carbon/human/front_hostile = allocate(/mob/living/carbon/human, front_turf)
	front_hostile.faction = FACTION_COVENANT
	var/mob/living/carbon/human/rear_hostile = allocate(/mob/living/carbon/human, rear_turf)
	rear_hostile.faction = FACTION_COVENANT

	TEST_ASSERT(brain.human_ai_can_visually_detect_target(front_hostile), "Human AI failed to see a hostile in front.")
	TEST_ASSERT(!brain.human_ai_can_visually_detect_target(rear_hostile), "Human AI visually detected a hostile in its rear blind spot.")
	TEST_ASSERT_EQUAL(brain.get_target(), front_hostile, "Human AI selected the rear hostile instead of the visible frontal hostile.")

	qdel(front_hostile)
	brain.lose_target()
	rear_hostile.a_intent_change(INTENT_GRAB)
	SEND_SIGNAL(ai_human, COMSIG_ATOM_BEFORE_HUMAN_ATTACK_HAND, rear_hostile, null)
	TEST_ASSERT_NULL(brain.current_target, "Yellow Grab intent alerted Human AI during a rear stealth takedown.")

	var/obj/item/test_weapon = allocate(/obj/item, rear_hostile)
	test_weapon.force = 10
	rear_hostile.start_pulling(ai_human)
	SEND_SIGNAL(ai_human, COMSIG_ATOM_MOB_ATTACKBY, test_weapon, rear_hostile)
	TEST_ASSERT_NULL(brain.current_target, "A held rear throat-slit setup on yellow Grab intent alerted Human AI.")
	rear_hostile.stop_pulling()

	rear_hostile.a_intent_change(INTENT_HARM)
	SEND_SIGNAL(ai_human, COMSIG_ATOM_BEFORE_HUMAN_ATTACK_HAND, rear_hostile, null)
	TEST_ASSERT_EQUAL(brain.current_target, rear_hostile, "A hostile rear harm action did not alert Human AI.")
	TEST_ASSERT(brain.in_combat, "A hostile rear harm action did not put Human AI into combat.")

	brain.lose_target()
	SEND_SIGNAL(ai_human, COMSIG_ATOM_MOB_ATTACKBY, test_weapon, rear_hostile)
	TEST_ASSERT_EQUAL(brain.current_target, rear_hostile, "A hostile rear item attack did not alert Human AI.")
// SS220 EDIT - END

// SS220 EDIT - START: fractional armor slowdown must survive subsystem timing quantization
/datum/unit_test/human_ai_movement_delay_remainder

/datum/unit_test/human_ai_movement_delay_remainder/Run()
	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, ai_human)

	brain.ai_move_delay = 2.5
	TEST_ASSERT_EQUAL(brain.schedule_next_move(4, 2.5, 2), 5, "Human AI discarded valid movement-delay remainder from a late subsystem tick.")

	brain.ai_move_delay = 1
	TEST_ASSERT_EQUAL(brain.schedule_next_move(100, 2.5, 2), 102.5, "Human AI banked stale idle time into its next movement deadline.")

	brain.ai_move_delay = 3
	TEST_ASSERT(brain.schedule_next_move(4, 0.5, 2) > 4, "Human AI scheduled more than one movement step in the same tick.")
// SS220 EDIT - END

// SS220 EDIT - START: stairs and handrails are safe traversal interactions, never standing scenery
/datum/unit_test/human_ai_structure_traversal

/datum/unit_test/human_ai_structure_traversal/Run()
	var/turf/start_turf = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, start_turf)
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, ai_human)
	brain.action_whitelist = list() // Manual traversal must not race autonomous scenery egress during sleep().

	var/turf/stairs_turf = get_step(start_turf, EAST)
	TEST_ASSERT_NOTNULL(stairs_turf, "Human AI traversal test area must contain a stairs turf.")
	allocate(/obj/structure/stairs, stairs_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(stairs_turf), "Human AI accepted stairs as an unrestricted standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(stairs_turf, FALSE, TRUE, TRUE), "Human AI rejected stairs in traversal-only safety mode.")
	brain.ai_move_delay = 0
	TEST_ASSERT(brain.try_adjacent_move_to_turf(stairs_turf), "Human AI did not traverse a stairs structure.")
	TEST_ASSERT_EQUAL(get_turf(ai_human), stairs_turf, "Human AI failed to finish its stairs traversal on the expected turf.")
	TEST_ASSERT(isturf(ai_human.loc), "Human AI entered the stairs object instead of remaining on a turf.")

	var/turf/ladder_turf = get_step(stairs_turf, EAST)
	TEST_ASSERT_NOTNULL(ladder_turf, "Human AI traversal test area must contain a ladder turf.")
	allocate(/obj/structure/ladder, ladder_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(ladder_turf), "Human AI accepted a ladder as an unrestricted standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(ladder_turf, FALSE, TRUE, TRUE), "Human AI rejected a ladder in traversal-only safety mode.")
	brain.ai_move_delay = 0
	TEST_ASSERT(brain.try_adjacent_move_to_turf(ladder_turf), "Human AI did not traverse a ladder structure.")
	TEST_ASSERT_EQUAL(get_turf(ai_human), ladder_turf, "Human AI failed to finish its ladder traversal on the expected turf.")
	TEST_ASSERT(isturf(ai_human.loc), "Human AI entered the ladder object instead of remaining on a turf.")

	// map staircases may be dense ON_BORDER platform cuts rather than /obj/structure/stairs.
	var/turf/platform_start_turf = get_step(start_turf, EAST)
	var/turf/platform_stair_turf = get_step(platform_start_turf, NORTH)
	var/turf/platform_landing_turf = get_step(platform_stair_turf, NORTH)
	TEST_ASSERT_NOTNULL(platform_start_turf, "Human AI traversal test area must contain a platform stair starting turf.")
	TEST_ASSERT_NOTNULL(platform_stair_turf, "Human AI traversal test area must contain a platform stair turf.")
	TEST_ASSERT_NOTNULL(platform_landing_turf, "Human AI traversal test area must contain a platform stair landing turf.")
	var/mob/living/carbon/human/platform_human = allocate(/mob/living/carbon/human, platform_start_turf)
	var/datum/human_ai_brain/platform_brain = allocate(/datum/human_ai_brain, platform_human)
	platform_brain.action_whitelist = list()
	var/obj/structure/platform/stair_cut/platform_stairs = allocate(/obj/structure/platform/stair_cut, platform_stair_turf)
	platform_stairs.setDir(NORTH)
	var/obj/structure/platform/platform_entry = allocate(/obj/structure/platform, platform_stair_turf)
	platform_entry.setDir(SOUTH)
	TEST_ASSERT(!platform_brain.human_ai_turf_is_safe(platform_stair_turf), "Human AI accepted platform stairs as an unrestricted standing destination.")
	TEST_ASSERT(platform_brain.human_ai_turf_is_safe(platform_stair_turf, FALSE, TRUE, TRUE), "Human AI rejected composite platform stairs in traversal-only safety mode.")
	var/list/platform_interactions = platform_brain.get_adjacent_move_interactions(platform_stair_turf)
	TEST_ASSERT(!isnull(platform_interactions) && (platform_entry in platform_interactions), "Human AI path validation did not identify the composite platform stair entry interaction.")
	platform_brain.ai_move_delay = 0
	TEST_ASSERT(platform_brain.complete_adjacent_move_to_turf(platform_stair_turf, TRUE, platform_interactions), "Human AI did not begin climbing onto the composite platform stairs.")
	sleep(platform_entry.climb_delay + 2)
	TEST_ASSERT_EQUAL(get_turf(platform_human), platform_stair_turf, "Human AI did not finish climbing onto the composite platform stairs.")
	platform_interactions = platform_brain.get_adjacent_move_interactions(platform_landing_turf)
	TEST_ASSERT(!isnull(platform_interactions) && (platform_stairs in platform_interactions), "Human AI path validation did not identify the platform stair exit interaction.")
	platform_brain.ai_move_delay = 0
	TEST_ASSERT(platform_brain.complete_adjacent_move_to_turf(platform_landing_turf, TRUE, platform_interactions), "Human AI did not begin leaving the composite platform stairs.")
	sleep(platform_stairs.climb_delay + 2)
	TEST_ASSERT_EQUAL(get_turf(platform_human), platform_landing_turf, "Human AI did not finish crossing the platform stairs.")
	TEST_ASSERT(isturf(platform_human.loc), "Human AI entered the platform stair object instead of remaining on a turf.")

	var/turf/ordinary_platform_turf = get_step(ladder_turf, EAST)
	TEST_ASSERT_NOTNULL(ordinary_platform_turf, "Human AI traversal test area must contain an ordinary platform turf.")
	var/obj/structure/platform/metal/stair_cut/metal_platform_stairs = allocate(/obj/structure/platform/metal/stair_cut, ordinary_platform_turf)
	TEST_ASSERT(brain.human_ai_turf_is_safe(ordinary_platform_turf, FALSE, TRUE, TRUE), "Human AI rejected metal platform stairs in traversal-only safety mode.")
	qdel(metal_platform_stairs)
	var/obj/structure/platform/stone/stair_cut/stone_platform_stairs = allocate(/obj/structure/platform/stone/stair_cut, ordinary_platform_turf)
	TEST_ASSERT(brain.human_ai_turf_is_safe(ordinary_platform_turf, FALSE, TRUE, TRUE), "Human AI rejected stone platform stairs in traversal-only safety mode.")
	qdel(stone_platform_stairs)
	allocate(/obj/structure/platform, ordinary_platform_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(ordinary_platform_turf), "Human AI accepted an ordinary platform as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(ordinary_platform_turf, FALSE, TRUE, TRUE), "Human AI rejected a player-climbable platform as a traversal step.")

	// non-dense scenery is traversable but never a final standing position.
	var/turf/flora_turf = get_step(platform_landing_turf, EAST)
	TEST_ASSERT_NOTNULL(flora_turf, "Human AI traversal test area must contain a flora turf.")
	TEST_ASSERT(istype(flora_turf, /turf/open/floor), "Human AI traversal regression must run on an open floor turf.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(flora_turf, FALSE, TRUE, TRUE), "Human AI rejected an unobstructed open floor turf.")
	var/obj/structure/flora/grass/passable_grass = allocate(/obj/structure/flora/grass, flora_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(flora_turf), "Human AI accepted passable grass as an unrestricted standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(flora_turf, FALSE, TRUE, TRUE), "Human AI rejected passable grass as a traversal step.")
	qdel(passable_grass)
	var/obj/structure/flora/forest/obscuring_forest = allocate(/obj/structure/flora/forest, flora_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(flora_turf), "Human AI accepted Halo forest foliage as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(flora_turf, FALSE, TRUE, TRUE), "Human AI treated non-dense Halo forest foliage as an invisible wall.")
	qdel(obscuring_forest)
	var/obj/structure/flora/bush/obscuring_bush = allocate(/obj/structure/flora/bush, flora_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(flora_turf), "Human AI accepted a bush as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(flora_turf, FALSE, TRUE, TRUE), "Human AI treated a non-dense bush as an invisible wall.")
	qdel(obscuring_bush)
	var/obj/structure/flora/grass/tallgrass/obscuring_tallgrass = allocate(/obj/structure/flora/grass/tallgrass, flora_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(flora_turf), "Human AI accepted tall grass as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(flora_turf, FALSE, TRUE, TRUE), "Human AI treated non-dense tall grass as an invisible wall.")
	qdel(obscuring_tallgrass)
	allocate(/obj/structure/flora/tree, flora_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(flora_turf, FALSE, TRUE, TRUE), "Human AI traversal mode accepted dense flora.")

	var/turf/underfloor_turf = get_step(flora_turf, SOUTH)
	TEST_ASSERT_NOTNULL(underfloor_turf, "Human AI traversal test area must contain an underfloor infrastructure turf.")
	var/obj/structure/pipes/underfloor_pipe = allocate(/obj/structure/pipes, underfloor_turf)
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf), "Human AI treated a non-dense underfloor pipe as a blocking structure.")
	qdel(underfloor_pipe)
	var/obj/structure/cable/underfloor_cable = allocate(/obj/structure/cable, underfloor_turf)
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf), "Human AI treated a non-dense underfloor cable as a blocking structure.")
	qdel(underfloor_cable)
	var/obj/structure/disposalpipe/underfloor_disposal = allocate(/obj/structure/disposalpipe, underfloor_turf)
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf), "Human AI treated a non-dense disposal pipe as a blocking structure.")
	qdel(underfloor_disposal)
	var/obj/structure/prop/floor_plane_prop = allocate(/obj/structure/prop, underfloor_turf)
	floor_plane_prop.density = FALSE
	floor_plane_prop.plane = FLOOR_PLANE
	TEST_ASSERT(!brain.human_ai_turf_is_safe(underfloor_turf), "Human AI accepted arbitrary floor scenery as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI treated non-dense floor scenery as an invisible wall.")
	qdel(floor_plane_prop)

	var/obj/structure/bed/chair/passable_chair = allocate(/obj/structure/bed/chair, underfloor_turf)
	passable_chair.density = FALSE
	TEST_ASSERT(!brain.human_ai_turf_is_safe(underfloor_turf), "Human AI accepted a chair as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI rejected a non-dense chair that a player can walk through.")
	qdel(passable_chair)

	var/obj/structure/window/intact_window = allocate(/obj/structure/window, underfloor_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI traversal mode accepted intact glass.")
	qdel(intact_window)
	var/obj/structure/machinery/cm_vending/solid_vendor = allocate(/obj/structure/machinery/cm_vending, underfloor_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI traversal mode accepted a vending machine.")
	qdel(solid_vendor)

	var/obj/structure/window_frame/broken_window_frame = allocate(/obj/structure/window_frame, underfloor_turf)
	TEST_ASSERT(!brain.human_ai_turf_is_safe(underfloor_turf), "Human AI accepted a broken window frame as a standing destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI rejected a player-climbable broken window frame.")
	qdel(broken_window_frame)
	var/obj/structure/barricade/passable_barricade = allocate(/obj/structure/barricade, underfloor_turf)
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI rejected a player-climbable barricade.")
	passable_barricade.is_wired = TRUE
	TEST_ASSERT(brain.human_ai_turf_is_safe(underfloor_turf, FALSE, TRUE, TRUE), "Human AI rejected a wired barricade that remains player-climbable.")
	qdel(passable_barricade)

	// retain a generic table path node until canonical delayed climbing reaches it.
	// The row south of the bottom-left landmark is the test room's wall, not floor.
	var/turf/table_start_turf = get_step(get_step(get_step(start_turf, NORTH), NORTH), NORTH)
	var/turf/table_turf = get_step(table_start_turf, EAST)
	var/turf/table_landing_turf = get_step(table_turf, EAST)
	TEST_ASSERT_NOTNULL(table_start_turf, "Human AI table traversal test requires a starting turf.")
	TEST_ASSERT_NOTNULL(table_turf, "Human AI table traversal test requires a table turf.")
	TEST_ASSERT_NOTNULL(table_landing_turf, "Human AI table traversal test requires a landing turf.")
	var/mob/living/carbon/human/table_human = allocate(/mob/living/carbon/human, table_start_turf)
	var/datum/human_ai_brain/table_brain = allocate(/datum/human_ai_brain, table_human)
	table_brain.action_whitelist = list()
	var/obj/structure/surface/table/climbed_table = allocate(/obj/structure/surface/table, table_turf)
	climbed_table.climb_delay = 1
	TEST_ASSERT(!table_brain.human_ai_turf_is_safe(table_turf), "Human AI accepted a table as a standing destination.")
	TEST_ASSERT(table_brain.human_ai_turf_is_safe(table_turf, FALSE, TRUE, TRUE), "Human AI rejected a player-climbable table.")
	table_brain.current_path = list(table_landing_turf, table_turf)
	table_brain.ai_move_delay = 0
	TEST_ASSERT(table_brain.follow_current_path_to_turf(table_landing_turf), "Human AI did not start its canonical table climb.")
	TEST_ASSERT_EQUAL(length(table_brain.current_path), 2, "Human AI consumed the table path node before delayed climbing reached it.")
	sleep(3)
	TEST_ASSERT_EQUAL(get_turf(table_human), table_turf, "Human AI did not finish climbing onto the table turf.")
	TEST_ASSERT(isturf(table_human.loc), "Human AI entered the table object instead of remaining on its turf.")
	TEST_ASSERT(table_brain.follow_current_path_to_turf(table_landing_turf), "Human AI did not consume the reached table path node.")
	TEST_ASSERT_EQUAL(length(table_brain.current_path), 1, "Human AI retained a table node after physically reaching it.")
	table_brain.ai_move_delay = 0
	TEST_ASSERT(table_brain.follow_current_path_to_turf(table_landing_turf), "Human AI did not continue beyond the climbed table.")
	TEST_ASSERT_EQUAL(get_turf(table_human), table_landing_turf, "Human AI stopped and remained hidden on the climbed table.")

	var/mob/living/carbon/human/vaulting_human = allocate(/mob/living/carbon/human, start_turf)
	var/datum/human_ai_brain/vaulting_brain = allocate(/datum/human_ai_brain, vaulting_human)
	vaulting_brain.action_whitelist = list()
	var/turf/vault_target = get_step(start_turf, NORTH)
	TEST_ASSERT_NOTNULL(vault_target, "Human AI traversal test area must contain a handrail destination.")
	var/obj/structure/barricade/handrail/handrail = allocate(/obj/structure/barricade/handrail, start_turf)
	handrail.setDir(NORTH)
	TEST_ASSERT(!vaulting_brain.human_ai_turf_is_safe(start_turf, TRUE), "Human AI accepted a handrail as an unrestricted standing destination.")
	TEST_ASSERT(vaulting_brain.human_ai_turf_is_safe(start_turf, TRUE, TRUE, TRUE), "Human AI rejected a handrail in traversal-only safety mode.")
	var/list/vault_interactions = vaulting_brain.get_adjacent_move_interactions(vault_target)
	TEST_ASSERT(!isnull(vault_interactions) && (handrail in vault_interactions), "Human AI path validation did not identify the handrail climb interaction.")
	vaulting_brain.ai_move_delay = 0
	TEST_ASSERT(vaulting_brain.complete_adjacent_move_to_turf(vault_target, TRUE, vault_interactions), "Human AI did not begin its handrail vault.")
	sleep(handrail.climb_delay + 2)
	TEST_ASSERT_EQUAL(get_turf(vaulting_human), vault_target, "Human AI did not finish vaulting to the opposite side of the handrail.")
	TEST_ASSERT(isturf(vaulting_human.loc), "Human AI entered the handrail object instead of remaining on a turf.")
// SS220 EDIT - END

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

	// SS220 EDIT - START: scenery and doors are traversal concerns, never final defensive posts
	var/turf/table_turf = get_step(ai_human, EAST)
	TEST_ASSERT_NOTNULL(table_turf, "Human AI cover test area must contain a table turf.")
	var/obj/structure/surface/table/invalid_table = allocate(/obj/structure/surface/table, table_turf)
	TEST_ASSERT(!brain.is_valid_cover_destination(table_turf), "Human AI accepted a table as a defensive destination.")
	cover_scores = list()
	TEST_ASSERT(brain.scan_turfs_for_cover(get_turf(ai_human), cover_scores, SOUTH), "Human AI table regression cover scan did not complete.")
	TEST_ASSERT(!(table_turf in cover_scores), "Human AI retained a table turf in its cover candidates.")

	var/turf/door_turf = get_step(ai_human, WEST)
	TEST_ASSERT_NOTNULL(door_turf, "Human AI cover test area must contain a blast-door turf.")
	var/obj/structure/machinery/door/poddoor/invalid_door = allocate(/obj/structure/machinery/door/poddoor, door_turf)
	invalid_door.density = FALSE
	TEST_ASSERT(!brain.is_valid_cover_destination(door_turf), "Human AI accepted an open blast door as a defensive destination.")
	TEST_ASSERT(brain.human_ai_turf_is_safe(door_turf, FALSE, TRUE), "Human AI rejected an open door as a traversal step.")

	var/turf/computer_turf = get_step(ai_human, NORTH)
	TEST_ASSERT_NOTNULL(computer_turf, "Human AI interaction test area must contain a computer turf.")
	var/obj/structure/machinery/computer/invalid_computer = allocate(/obj/structure/machinery/computer, computer_turf)
	TEST_ASSERT_EQUAL(invalid_computer.human_ai_obstacle(ai_human, brain, NORTH, computer_turf), INFINITY, "Human AI pathfinding did not reject a solid computer.")
	TEST_ASSERT_EQUAL(invalid_computer.human_ai_act(ai_human, brain), FALSE, "Human AI attempted to operate an unrelated computer during navigation.")
	qdel(invalid_table)
	qdel(invalid_door)
	qdel(invalid_computer)
	// SS220 EDIT - END

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
	// Exercise the production owner/component link required by asynchronous pathfinding.
	var/datum/component/human_ai/ai_component = medic.AddComponent(/datum/component/human_ai)
	var/datum/human_ai_brain/brain = ai_component.ai_brain
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
	var/mob/living/carbon/human/dose_patient = allocate(/mob/living/carbon/human/dummy, dose_patient_turf)
	dose_patient.faction = FACTION_UNSC
	brain.healing_someone = TRUE
	TEST_ASSERT(brain.treatment_can_continue(brain.treatment_generation, dose_patient), "Dose-safety fixture did not establish active treatment")

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
	brain.healing_someone = FALSE
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
	// ai_use treats several limbs asynchronously; the first healed limb is not completion.
	var/return_timeout = world.time + 15 SECONDS
	while((brain.healing_someone || medical_supply.loc != medical_belt) && world.time < return_timeout)
		sleep(1)
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
	// SS220 EDIT - START: idle relocation is disabled even in a cluster
	TEST_ASSERT(!first_brain.can_seek_idle_defensive_position(), "Human AI still permits automatic idle defensive relocation.")
	TEST_ASSERT_EQUAL(GLOB.AI_actions[/datum/ai_action/idle_defensive_position].get_weight(first_brain), 0, "Disabled idle relocation was offered to the scheduler.")
	TEST_ASSERT_NULL(first_brain.find_idle_defensive_position(), "Disabled idle relocation still searches for a position.")
	TEST_ASSERT(!first_brain.move_to_idle_defensive_position(get_step(cluster_turf, EAST)), "Disabled idle relocation still attempts movement.")
	TEST_ASSERT_EQUAL(get_turf(first_human), cluster_turf, "Disabled idle relocation moved the NPC.")
	// SS220 EDIT - END

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
	var/obj/structure/surface/table/idle_test_table = allocate(/obj/structure/surface/table, cover_neighbor)
	var/cover_score_after = first_brain.get_idle_position_cover_score(cover_candidate)
	TEST_ASSERT(cover_score_after > cover_score_before, "Human AI idle-position scoring did not prefer newly added physical cover.")
	TEST_ASSERT(first_brain.human_ai_is_idle_cover_anchor(idle_test_table), "Human AI did not recognize a table as an approved idle-cover anchor.")
	var/obj/structure/closet/crate/idle_test_crate = allocate(/obj/structure/closet/crate, cover_neighbor)
	var/obj/structure/largecrate/idle_test_large_crate = allocate(/obj/structure/largecrate, cover_neighbor)
	var/obj/structure/barricade/idle_test_barricade = allocate(/obj/structure/barricade, cover_neighbor)
	TEST_ASSERT(first_brain.human_ai_is_idle_cover_anchor(idle_test_crate), "Human AI did not recognize a crate as an approved idle-cover anchor.")
	TEST_ASSERT(first_brain.human_ai_is_idle_cover_anchor(idle_test_large_crate), "Human AI did not recognize a large crate as an approved idle-cover anchor.")
	TEST_ASSERT(first_brain.human_ai_is_idle_cover_anchor(idle_test_barricade), "Human AI did not recognize a barricade as an approved idle-cover anchor.")
	TEST_ASSERT_EQUAL(first_brain.score_idle_defensive_position(cover_neighbor), -INFINITY, "Human AI accepted a table turf as an idle defensive post.")
	TEST_ASSERT(first_brain.idle_defensive_step_is_blocked(cover_neighbor), "Human AI idle movement accepted a table as an intermediate step.")
	TEST_ASSERT(first_brain.human_ai_idle_position_is_clear(cover_candidate), "Human AI rejected an otherwise empty idle standing turf.")
	var/obj/item/device/flashlight/lamp/idle_position_obstacle = allocate(/obj/item/device/flashlight/lamp, cover_candidate)
	TEST_ASSERT(!first_brain.human_ai_idle_position_is_clear(cover_candidate), "Human AI considered an object-occupied idle standing turf clear.")
	TEST_ASSERT_EQUAL(first_brain.score_idle_defensive_position(cover_candidate), -INFINITY, "Human AI reserved an occupied turf in front of approved cover.")
	qdel(idle_position_obstacle)

	var/turf/door_candidate = get_step(cluster_turf, WEST)
	TEST_ASSERT_NOTNULL(door_candidate, "Human AI idle-position test area must contain a door turf.")
	var/obj/structure/machinery/door/poddoor/idle_test_door = allocate(/obj/structure/machinery/door/poddoor, door_candidate)
	idle_test_door.density = FALSE
	TEST_ASSERT(first_brain.human_ai_is_idle_cover_anchor(idle_test_door), "Human AI did not recognize a door as an approved idle-cover anchor.")
	TEST_ASSERT_EQUAL(first_brain.score_idle_defensive_position(door_candidate), -INFINITY, "Human AI accepted an open blast door as an idle defensive post.")
	TEST_ASSERT(first_brain.idle_defensive_step_is_blocked(door_candidate), "Human AI idle movement accepted an open blast door as an intermediate step.")

	var/turf/non_dense_prop_turf = get_step(cluster_turf, SOUTH)
	TEST_ASSERT_NOTNULL(non_dense_prop_turf, "Human AI navigation test area must contain a prop turf.")
	var/obj/structure/prop/non_dense_prop = allocate(/obj/structure/prop, non_dense_prop_turf)
	non_dense_prop.density = FALSE
	non_dense_prop.projectile_coverage = PROJECTILE_COVERAGE_HIGH
	TEST_ASSERT(!first_brain.human_ai_is_idle_cover_anchor(non_dense_prop), "Human AI accepted a generic high-coverage prop as an idle-cover anchor.")
	TEST_ASSERT(!first_brain.human_ai_turf_is_safe(non_dense_prop_turf), "Human AI accepted a non-dense structure as a standing tile.")
	TEST_ASSERT(isnull(first_brain.get_adjacent_move_interactions(non_dense_prop_turf)), "Human AI movement accepted a step onto a non-dense structure.")

	var/turf/uncovered_candidate
	for(var/turf/candidate in range(3, cluster_turf))
		if(candidate != cluster_turf && first_brain.human_ai_turf_is_safe(candidate) && first_brain.get_idle_position_cover_score(candidate) <= 0)
			uncovered_candidate = candidate
			break
	TEST_ASSERT_NOTNULL(uncovered_candidate, "Human AI idle-position test area must contain an uncovered clean turf.")
	TEST_ASSERT_EQUAL(first_brain.score_idle_defensive_position(uncovered_candidate), -INFINITY, "Human AI accepted an idle post with no approved cover anchor.")

	first_human.forceMove(cover_neighbor)
	TEST_ASSERT_EQUAL(GLOB.AI_actions[/datum/ai_action/leave_unsafe_turf].get_weight(first_brain), INFINITY, "Human AI did not prioritize leaving a table turf.")
	var/turf/egress_turf = first_brain.get_unsafe_turf_egress_destination()
	TEST_ASSERT_NOTNULL(egress_turf, "Human AI found no clean adjacent egress from a table turf.")
	TEST_ASSERT(first_brain.human_ai_turf_is_safe(egress_turf), "Human AI selected another scenery turf as its emergency egress destination.")
	first_human.forceMove(cluster_turf)

	first_brain.hold_position = TRUE
	TEST_ASSERT(!first_brain.can_seek_idle_defensive_position(), "Human AI idle redistribution ignored a hold-position order.")
	var/datum/ai_action/leave_unsafe_turf/egress_action = allocate(/datum/ai_action/leave_unsafe_turf, first_brain)
	TEST_ASSERT(!first_brain.quick_order_blocks_action(egress_action), "Quick Order: Hold Position blocked emergency egress from scenery.")
// SS220 EDIT - END

// SS220 EDIT - START: Quick Orders preempt movement immediately and Hold persists until Approach
/datum/unit_test/human_ai_quick_orders

/datum/unit_test/human_ai_quick_orders/Run()
	var/turf/start_turf = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, start_turf)
	ai_human.faction = FACTION_UNSC
	var/datum/human_ai_brain/brain = allocate(/datum/human_ai_brain, ai_human)

	var/turf/old_destination = get_step(start_turf, NORTH)
	var/turf/approach_flora_turf = get_step(start_turf, EAST)
	var/turf/new_destination = get_step(approach_flora_turf, EAST)
	TEST_ASSERT_NOTNULL(old_destination, "Human AI Quick Order test area must contain an old destination.")
	TEST_ASSERT_NOTNULL(approach_flora_turf, "Human AI Quick Order test area must contain a passable flora step.")
	TEST_ASSERT_NOTNULL(new_destination, "Human AI Quick Order test area must contain a destination two tiles east.")
	var/obj/structure/flora/grass/approach_grass = allocate(/obj/structure/flora/grass, approach_flora_turf)
	brain.quick_approach = old_destination
	var/datum/ai_action/quick_approach/stale_approach = allocate(/datum/ai_action/quick_approach, brain)
	brain.ongoing_actions += stale_approach
	brain.current_path = list(old_destination)
	brain.ai_move_delay = world.time + 10 SECONDS
	var/mob/living/carbon/human/combat_hostile = allocate(/mob/living/carbon/human, old_destination)
	combat_hostile.faction = FACTION_COVENANT
	brain.set_target(combat_hostile)

	var/initial_distance = get_dist(ai_human, new_destination)
	brain.apply_quick_approach_order(new_destination)
	TEST_ASSERT(!brain.hold_position, "Quick Order: Approach did not release Hold Position.")
	TEST_ASSERT_EQUAL(brain.quick_approach, new_destination, "Destroying the stale movement action erased the new Approach destination.")
	TEST_ASSERT(QDELETED(stale_approach) || !(stale_approach in brain.ongoing_actions), "Quick Order: Approach did not preempt the stale movement action.")
	TEST_ASSERT(!brain.current_path, "Quick Order: Approach retained the stale navigation path.")
	TEST_ASSERT_EQUAL(brain.target_turf, get_turf(combat_hostile), "Quick Order: Approach erased the current combat target turf needed for concurrent firing.")
	TEST_ASSERT(get_dist(ai_human, new_destination) < initial_distance, "Quick Order: Approach did not make its immediate local movement step.")
	TEST_ASSERT_EQUAL(get_turf(ai_human), approach_flora_turf, "Quick Order: Approach treated passable flora as an invisible wall.")
	qdel(approach_grass)
	brain.process(0)
	TEST_ASSERT(brain.quick_approach, "Quick Order: Approach was not retained for normal scheduler/pathfinder completion.")
	var/list/quick_approach_conflicts = GLOB.AI_actions[/datum/ai_action/quick_approach].get_conflicts(brain)
	TEST_ASSERT(!(/datum/ai_action/fire_at_target in quick_approach_conflicts), "Quick Order: Approach conflicts with hand-only combat firing.")
	var/datum/ai_action/quick_approach/interrupted_approach = allocate(/datum/ai_action/quick_approach, brain)
	qdel(interrupted_approach)
	TEST_ASSERT_EQUAL(brain.quick_approach, new_destination, "A temporary combat interruption erased the persistent Quick Order: Approach destination.")

	var/turf/unreachable_destination = get_step(get_turf(ai_human), NORTH)
	TEST_ASSERT_NOTNULL(unreachable_destination, "Human AI Quick Order test area must contain an unreachable adjacent destination.")
	var/obj/structure/window/unreachable_blocker = allocate(/obj/structure/window, unreachable_destination)
	brain.quick_approach = unreachable_destination
	var/datum/ai_action/quick_approach/unreachable_approach = allocate(/datum/ai_action/quick_approach, brain)
	for(var/i in 1 to 3)
		unreachable_approach.trigger_action()
	TEST_ASSERT_NULL(brain.quick_approach, "Human AI retained an unreachable Approach order after its bounded failure limit.")
	qdel(unreachable_approach)
	qdel(unreachable_blocker)

	var/obj/structure/surface/table/unsafe_order_table = allocate(/obj/structure/surface/table, unreachable_destination)
	brain.apply_quick_approach_order(unreachable_destination)
	TEST_ASSERT_NOTEQUAL(brain.quick_approach, unreachable_destination, "Quick Order: Approach retained a table turf as its final destination.")
	TEST_ASSERT(!brain.quick_approach || brain.human_ai_turf_is_safe(brain.quick_approach), "Quick Order: Approach did not normalize scenery to a safe nearby floor turf.")
	qdel(unsafe_order_table)
	brain.lose_target()

	brain.quick_approach = new_destination
	var/datum/ai_action/quick_approach/active_approach = allocate(/datum/ai_action/quick_approach, brain)
	brain.ongoing_actions += active_approach
	brain.current_path = list(new_destination)
	var/turf/held_turf = get_turf(ai_human)
	var/turf/hold_boundary = get_step(held_turf, EAST)
	var/turf/beyond_boundary = get_step(hold_boundary, EAST)
	var/turf/hostile_turf = get_step(held_turf, WEST)
	TEST_ASSERT_NOTNULL(hold_boundary, "Human AI Hold Position test area must contain a fallback boundary.")
	TEST_ASSERT_NOTNULL(beyond_boundary, "Human AI Hold Position test area must contain a turf beyond the boundary.")
	TEST_ASSERT_NOTNULL(hostile_turf, "Human AI Hold Position test area must contain a hostile turf.")
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, hostile_turf)
	hostile.faction = FACTION_COVENANT
	brain.set_target(hostile)
	brain.apply_quick_hold_position_order(hold_boundary)
	TEST_ASSERT(brain.hold_position, "Quick Order: Hold Position did not set its persistent movement lock.")
	TEST_ASSERT_EQUAL(brain.hold_position_turf, hold_boundary, "Quick Order: Hold Position did not store its fallback boundary.")
	TEST_ASSERT(!brain.quick_approach, "Quick Order: Hold Position retained an Approach destination.")
	TEST_ASSERT(QDELETED(active_approach) || !(active_approach in brain.ongoing_actions), "Quick Order: Hold Position did not immediately preempt movement.")
	TEST_ASSERT(!brain.current_path, "Quick Order: Hold Position retained a navigation path.")
	TEST_ASSERT(brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/chase_target]), "Hold Position did not centrally block chase movement.")
	TEST_ASSERT(!brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/hold_position_retreat]), "Hold Position blocked its legal bounded retreat action.")
	TEST_ASSERT(!brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/take_cover]), "Hold Position blocked movement toward cover inside its boundary.")
	TEST_ASSERT(!brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/treat_ally]), "Hold Position blocked movement toward an injured ally inside its boundary.")
	brain.current_cover = hold_boundary
	var/datum/ai_action/take_cover/cover_action = GLOB.AI_actions[/datum/ai_action/take_cover]
	var/datum/ai_action/hold_position_retreat/retreat_action = GLOB.AI_actions[/datum/ai_action/hold_position_retreat]
	TEST_ASSERT(cover_action.get_weight(brain) >= retreat_action.get_weight(brain), "Hold Position retreat priority displaced an available cover action.")
	brain.current_cover = null
	TEST_ASSERT(!brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/fire_at_target]), "Hold Position incorrectly blocked a non-movement combat action.")
	TEST_ASSERT(!brain.quick_order_blocks_action(GLOB.AI_actions[/datum/ai_action/resist_burning]), "Hold Position incorrectly blocked stationary fire resistance.")
	TEST_ASSERT(brain.hold_position_retreat_step_is_allowed(hold_boundary), "Hold Position rejected a retreat step toward its boundary.")
	TEST_ASSERT(!brain.hold_position_retreat_step_is_allowed(beyond_boundary), "Hold Position allowed retreat beyond its assigned boundary.")
	TEST_ASSERT(brain.quick_order_step_within_boundary(hold_boundary), "Hold Position rejected a step onto its boundary.")
	TEST_ASSERT(!brain.quick_order_step_within_boundary(beyond_boundary), "Hold Position accepted a step across its boundary.")
	brain.process(0)
	TEST_ASSERT_EQUAL(get_turf(ai_human), hold_boundary, "Human AI did not retreat from the enemy toward its Hold Position boundary.")
	TEST_ASSERT(isnull(brain.get_adjacent_move_interactions(beyond_boundary)), "Human AI path validation accepted a physical step across the Hold Position boundary.")
	TEST_ASSERT(!brain.is_valid_cover_destination(beyond_boundary), "Human AI cover search accepted a destination across the Hold Position boundary.")
	brain.process(0)
	TEST_ASSERT_EQUAL(get_turf(ai_human), hold_boundary, "Human AI crossed its assigned Hold Position boundary.")

	// A blocked direct retreat must choose a safe lateral route without approaching the enemy.
	ai_human.forceMove(held_turf)
	brain.hold_position_turf = beyond_boundary
	brain.hold_position_previous_turf = null
	var/obj/structure/surface/table/retreat_blocker = allocate(/obj/structure/surface/table, hold_boundary)
	var/turf/detour_step = brain.get_hold_position_retreat_step()
	TEST_ASSERT_NOTNULL(detour_step, "Human AI failed to find a bounded Hold Position detour around an obstacle.")
	TEST_ASSERT_NOTEQUAL(detour_step, hold_boundary, "Human AI selected the blocked direct Hold Position retreat turf.")
	TEST_ASSERT(get_dist(detour_step, hostile) >= get_dist(ai_human, hostile), "Human AI Hold Position detour moved closer to the enemy.")
	TEST_ASSERT(brain.hold_position_retreat_step_is_allowed(detour_step, TRUE), "Human AI selected an invalid Hold Position detour step.")
	qdel(retreat_blocker)

	brain.target_turf = new_destination
	brain.apply_quick_approach_order(new_destination)
	TEST_ASSERT(!brain.hold_position, "Only Approach should release Hold Position, but the release failed.")
	TEST_ASSERT(!brain.hold_position_origin_turf, "Quick Order: Approach did not clear the Hold Position origin.")
	TEST_ASSERT(!brain.hold_position_turf, "Quick Order: Approach did not clear the Hold Position boundary.")
	TEST_ASSERT(!brain.hold_position_previous_turf, "Quick Order: Approach did not clear the Hold Position detour history.")
// SS220 EDIT - END

// SS220 EDIT - START: live-grenade reaction and one-roll combat grenade behavior
/datum/unit_test/human_ai_grenade_reactions
	var/list/original_turf_types

/datum/unit_test/human_ai_grenade_reactions/New()
	. = ..()
	original_turf_types = list()
	// The default room is only 5x5; this test needs real floor for five-tile escape and ranged throws.
	for(var/x_offset in 0 to 10)
		for(var/y_offset in 0 to 10)
			var/turf/tile = locate(run_loc_floor_bottom_left.x + x_offset, run_loc_floor_bottom_left.y + y_offset, run_loc_floor_bottom_left.z)
			if(tile)
				original_turf_types[tile] = tile.type
				tile.ChangeTurf(/turf/open/floor)

/datum/unit_test/human_ai_grenade_reactions/Destroy()
	for(var/turf/tile as anything in original_turf_types)
		tile.ChangeTurf(original_turf_types[tile])
	original_turf_types = null
	return ..()

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
	brain.settings_snapshot["throwback"] = TRUE // Test fixture, not a production override API.
	TEST_ASSERT(!brain.can_attempt_live_grenade_throwback(live_grenade), "NPC approached a grenade outside the two-tile pickup radius")
	live_grenade.forceMove(get_step(get_step(ai_turf, EAST), EAST))
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
	brain.settings_snapshot["throwback_safety"] = FALSE
	TEST_ASSERT_EQUAL(reaction_action.get_hostile_throw_target(ai_human, live_grenade), hostile_turf, "Unsafe throwback still rejected an ally near the enemy")
	brain.settings_snapshot["throwback_safety"] = TRUE

	var/obj/item/explosive/grenade/high_explosive/carried_grenade = allocate(/obj/item/explosive/grenade/high_explosive, ai_human)
	brain.equipment_map[HUMAN_AI_GRENADES][carried_grenade] = ai_human
	brain.active_grenade_found = null
	brain.in_combat = TRUE
	brain.target_turf = hostile_turf
	TEST_ASSERT_EQUAL(brain.settings_snapshot["grenade_chance"], 100, "Human AI carried-grenade chance is not 100 percent by default.")
	brain.settings_snapshot["grenade_chance"] = 100
	brain.begin_combat_grenade_decision()
	TEST_ASSERT(brain.should_attempt_combat_grenade(), "Human AI failed a forced successful combat-grenade decision.")
	brain.settings_snapshot["grenade_chance"] = 0
	TEST_ASSERT(brain.should_attempt_combat_grenade(), "Human AI rerolled its stored combat-grenade decision during the same encounter.")
	var/datum/ai_action/throw_grenade/grenade_action_prototype = GLOB.AI_actions[/datum/ai_action/throw_grenade]
	TEST_ASSERT_NOTNULL(grenade_action_prototype, "Human AI carried-grenade action was not registered.")
	TEST_ASSERT_EQUAL(grenade_action_prototype.get_weight(brain), 0, "Safe carried throw ignored allied blast proximity")
	brain.settings_snapshot["grenade_safety"] = FALSE
	TEST_ASSERT_EQUAL(grenade_action_prototype.get_weight(brain), 100, "Human AI successful combat-grenade decision did not prioritize the throw action.")
	brain.settings_snapshot["grenade_chance"] = 100
	var/datum/ai_action/throw_grenade/carried_action = allocate(/datum/ai_action/throw_grenade, brain)
	TEST_ASSERT_NOTNULL(carried_action, "Human AI failed to create its selected carried-grenade action.")
	TEST_ASSERT(brain.combat_grenade_selected, "Human AI consumed its successful carried-grenade decision before an actual launch.")
	TEST_ASSERT(!carried_action.launch_grenade_to_target(ai_human, carried_grenade, hostile_turf), "Human AI launched an unprimed carried grenade.")
	carried_grenade.active = TRUE
	TEST_ASSERT(!carried_action.launch_grenade_to_target(ai_human, carried_grenade, hostile_turf), "Human AI launched a grenade that was not selected in its active hand.")
	carried_grenade.active = FALSE

	// carried grenades stay aligned with the hostile and pass over intervening allies.
	qdel(friendly)
	brain.settings_snapshot["grenade_safety"] = TRUE
	var/mob/living/carbon/human/intervening_friendly = allocate(/mob/living/carbon/human, get_step(ai_turf, NORTH))
	intervening_friendly.faction = FACTION_UNSC
	TEST_ASSERT_EQUAL(carried_action.resolve_throw_target(ai_human, carried_grenade, hostile_turf), hostile_turf, "Human AI rejected a safe hostile grenade target because an ally stood in the flight path.")

	var/turf/distant_hostile_turf = hostile_turf
	for(var/i in 1 to 3)
		distant_hostile_turf = get_step(distant_hostile_turf, NORTH)
	TEST_ASSERT_NOTNULL(distant_hostile_turf, "Human AI grenade test area must extend beyond normal grenade range.")
	var/turf/clamped_throw_turf = carried_action.resolve_throw_target(ai_human, carried_grenade, distant_hostile_turf)
	TEST_ASSERT(!clamped_throw_turf || get_dist(clamped_throw_turf, distant_hostile_turf) <= 1, "NPC wasted a grenade far from its hostile target")

	var/turf/blocker_turf = ai_turf
	for(var/i in 1 to 3)
		blocker_turf = get_step(blocker_turf, NORTH)
	var/obj/structure/surface/table/trajectory_blocker = allocate(/obj/structure/surface/table, blocker_turf)
	TEST_ASSERT_NULL(carried_action.resolve_throw_target(ai_human, carried_grenade, distant_hostile_turf), "Human AI selected a grenade trajectory through dense cover.")
	qdel(trajectory_blocker)

	// a loaded underbarrel launcher is the fallback explosive when no hand grenade exists.
	brain.equipment_map[HUMAN_AI_GRENADES] -= carried_grenade
	var/obj/item/weapon/gun/rifle/m41aMK1/army/launcher_rifle = allocate(/obj/item/weapon/gun/rifle/m41aMK1/army, ai_human)
	brain.set_primary_weapon(launcher_rifle)
	var/obj/item/attachable/attached_gun/grenade/underbarrel_launcher = brain.get_ready_underbarrel_grenade_launcher()
	TEST_ASSERT_NOTNULL(underbarrel_launcher, "Human AI did not recognize a loaded and ready underbarrel grenade launcher.")
	TEST_ASSERT_EQUAL(brain.get_underbarrel_grenade_target(underbarrel_launcher, hostile_turf), hostile_turf, "Human AI did not select the safe hostile turf for an underbarrel grenade.")
	var/datum/ai_action/fire_underbarrel_grenade/underbarrel_action = GLOB.AI_actions[/datum/ai_action/fire_underbarrel_grenade]
	TEST_ASSERT_EQUAL(underbarrel_action.get_weight(brain), 100, "A successful grenade decision did not prioritize the ready underbarrel launcher.")
	var/mob/living/carbon/human/launcher_friendly = allocate(/mob/living/carbon/human, get_step(hostile_turf, EAST))
	launcher_friendly.faction = FACTION_UNSC
	TEST_ASSERT_NULL(brain.get_underbarrel_grenade_target(underbarrel_launcher, hostile_turf), "Human AI accepted an underbarrel grenade target inside the friendly safety radius.")
	qdel(launcher_friendly)
	underbarrel_launcher.in_chamber = null
	underbarrel_launcher.current_rounds = 0
	TEST_ASSERT_NULL(brain.get_ready_underbarrel_grenade_launcher(), "Human AI considered an empty underbarrel grenade launcher ready.")

	brain.begin_combat_grenade_decision()
	brain.settings_snapshot["grenade_chance"] = 0
	TEST_ASSERT(!brain.should_attempt_combat_grenade(), "Human AI failed a forced unsuccessful combat-grenade decision.")
// SS220 EDIT - END
