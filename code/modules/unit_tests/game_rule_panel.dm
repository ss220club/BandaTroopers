/datum/unit_test/game_rule_panel
	var/snapshot_rto_support_enabled
	var/snapshot_support_underground_enabled // SS220 EDIT: preserve the BT underground-support rule across test mutations
	var/snapshot_rto_shared_cooldown_multiplier
	var/snapshot_rto_personal_cooldown_multiplier
	var/snapshot_rto_support_resource_mode
	var/snapshot_rto_charge_recharge_enabled
	var/snapshot_rto_charge_recharge_multiplier
	var/snapshot_rto_charge_capacity_multiplier
	var/snapshot_rto_charge_manual_only
	var/snapshot_rto_template_slot_count
	var/snapshot_rto_template_reset_minutes
	var/snapshot_fire_support_enabled
	var/snapshot_player_survival_enabled
	var/snapshot_player_survival_crit_grace_seconds
	var/snapshot_player_survival_antigib_enabled
	var/snapshot_player_survival_antigib_limb_loss_chance
	var/snapshot_fire_support_defaults_captured
	var/list/snapshot_fire_support_default_points
	var/list/snapshot_fire_support_default_availability
	var/list/snapshot_fire_support_points
	var/list/snapshot_fire_support_flags

/datum/unit_test/game_rule_panel/Run()
	return

/datum/unit_test/game_rule_panel/New()
	. = ..()

	var/datum/game_rule_state/rules = GLOB.game_rule_state
	snapshot_rto_support_enabled = rules.rto_support_enabled
	snapshot_support_underground_enabled = rules.support_underground_enabled // SS220 EDIT: preserve the BT underground-support rule across test mutations
	snapshot_rto_shared_cooldown_multiplier = rules.rto_shared_cooldown_multiplier
	snapshot_rto_personal_cooldown_multiplier = rules.rto_personal_cooldown_multiplier
	snapshot_rto_support_resource_mode = rules.rto_support_resource_mode
	snapshot_rto_charge_recharge_enabled = rules.rto_charge_recharge_enabled
	snapshot_rto_charge_recharge_multiplier = rules.rto_charge_recharge_multiplier
	snapshot_rto_charge_capacity_multiplier = rules.rto_charge_capacity_multiplier
	snapshot_rto_charge_manual_only = rules.rto_charge_manual_only
	snapshot_rto_template_slot_count = rules.rto_template_slot_count
	snapshot_rto_template_reset_minutes = rules.rto_template_reset_minutes
	snapshot_fire_support_enabled = rules.fire_support_enabled
	snapshot_player_survival_enabled = rules.player_survival_enabled
	snapshot_player_survival_crit_grace_seconds = rules.player_survival_crit_grace_seconds
	snapshot_player_survival_antigib_enabled = rules.player_survival_antigib_enabled
	snapshot_player_survival_antigib_limb_loss_chance = rules.player_survival_antigib_limb_loss_chance
	snapshot_fire_support_defaults_captured = rules.fire_support_defaults_captured
	snapshot_fire_support_default_points = rules.fire_support_default_points ? rules.fire_support_default_points.Copy() : list()
	snapshot_fire_support_default_availability = rules.fire_support_default_availability ? rules.fire_support_default_availability.Copy() : list()
	snapshot_fire_support_points = GLOB.fire_support_points.Copy()
	snapshot_fire_support_flags = list()

	for(var/fire_support_type in GLOB.fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(!fire_support_option)
			continue
		snapshot_fire_support_flags[fire_support_type] = fire_support_option.fire_support_flags

/datum/unit_test/game_rule_panel/Destroy()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.rto_support_enabled = snapshot_rto_support_enabled
	rules.support_underground_enabled = snapshot_support_underground_enabled // SS220 EDIT: restore the BT underground-support rule after each test
	rules.rto_shared_cooldown_multiplier = snapshot_rto_shared_cooldown_multiplier
	rules.rto_personal_cooldown_multiplier = snapshot_rto_personal_cooldown_multiplier
	rules.rto_support_resource_mode = snapshot_rto_support_resource_mode
	rules.rto_charge_recharge_enabled = snapshot_rto_charge_recharge_enabled
	rules.rto_charge_recharge_multiplier = snapshot_rto_charge_recharge_multiplier
	rules.rto_charge_capacity_multiplier = snapshot_rto_charge_capacity_multiplier
	rules.rto_charge_manual_only = snapshot_rto_charge_manual_only
	rules.rto_template_slot_count = snapshot_rto_template_slot_count
	rules.rto_template_reset_minutes = snapshot_rto_template_reset_minutes
	rules.fire_support_enabled = snapshot_fire_support_enabled
	rules.player_survival_enabled = snapshot_player_survival_enabled
	rules.player_survival_crit_grace_seconds = snapshot_player_survival_crit_grace_seconds
	rules.player_survival_antigib_enabled = snapshot_player_survival_antigib_enabled
	rules.player_survival_antigib_limb_loss_chance = snapshot_player_survival_antigib_limb_loss_chance
	rules.fire_support_defaults_captured = snapshot_fire_support_defaults_captured
	rules.fire_support_default_points = snapshot_fire_support_default_points.Copy()
	rules.fire_support_default_availability = snapshot_fire_support_default_availability.Copy()

	if(!islist(GLOB.fire_support_points))
		GLOB.fire_support_points = list()
	else
		GLOB.fire_support_points.Cut()
	for(var/faction in snapshot_fire_support_points)
		GLOB.fire_support_points[faction] = snapshot_fire_support_points[faction]

	for(var/fire_support_type in snapshot_fire_support_flags)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[fire_support_type]
		if(!fire_support_option)
			continue
		fire_support_option.fire_support_flags = snapshot_fire_support_flags[fire_support_type]

	return ..()

/datum/unit_test/game_rule_panel/proc/count_player_survival_extremities(mob/living/carbon/human/human)
	. = 0
	if(!human)
		return

	var/static/list/extremity_zones = list(
		"l_hand",
		"r_hand",
		"l_foot",
		"r_foot"
	)

	for(var/zone in extremity_zones)
		var/obj/limb/limb = human.get_limb(zone)
		if(!limb)
			continue
		if(limb.status & LIMB_DESTROYED)
			continue
		.++

/mob/living/carbon/human/game_rule_panel_player_survival_test
/mob/living/carbon/human/game_rule_panel_player_survival_test/player_survival_is_protected_player()
	return TRUE

/mob/living/carbon/human/game_rule_panel_player_survival_test/player_survival_log_event(log_text, admin_text = null, notify_admins = FALSE)
	return

/datum/rto_support_action_template/game_rule_panel_charge_light
	action_id = "game_rule_panel_charge_light"
	name = "Charge light"
	description = "Synthetic Game Rule Panel light call."
	fire_support_path = /datum/fire_support/supply_drop
	requires_visibility_zone = FALSE
	allow_closed_turf = FALSE
	support_pool_cost = 1
	personal_lockout = 2 SECONDS

/datum/rto_support_action_template/game_rule_panel_charge_heavy
	action_id = "game_rule_panel_charge_heavy"
	name = "Charge heavy"
	description = "Synthetic Game Rule Panel heavy call."
	fire_support_path = /datum/fire_support/supply_drop
	requires_visibility_zone = FALSE
	allow_closed_turf = FALSE
	support_pool_cost = 3
	personal_lockout = 4 SECONDS

/datum/rto_support_template/game_rule_panel_unit_test_charges
	template_id = "game_rule_panel_unit_test_charges"
	name = "Game Rule Panel Unit Test Charges"
	description = "Synthetic charge-based template for Game Rule Panel runtime tests."
	role_summary = "Unit test package."
	targeting_summary = "No sector required."
	requires_visibility_zone = FALSE
	visibility_zone_name = ""
	visibility_zone_type = ""
	visibility_zone_radius = 0
	visibility_zone_duration = 0
	visibility_zone_cooldown = 0
	support_resource_mode = RTO_SUPPORT_RESOURCE_MODE_CHARGES
	support_pool_capacity = 3
	support_pool_starting_charges = 3
	support_pool_recharge_interval = 30 SECONDS
	support_pool_recharge_amount = 1
	support_pool_auto_recharge = TRUE
	action_template_types = list(
		/datum/rto_support_action_template/game_rule_panel_charge_light,
		/datum/rto_support_action_template/game_rule_panel_charge_heavy,
	)

/datum/unit_test/game_rule_panel_rto_cooldowns
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_cooldowns/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_rto_rules()
	TEST_ASSERT(rules.support_underground_enabled, "Reset RTO rules did not restore underground support to enabled.") // SS220 EDIT: BT RTO reset must also restore underground support
	TEST_ASSERT_EQUAL(rules.get_rto_template_slot_count(), 2, "Reset RTO rules did not restore the default package slot count.")
	TEST_ASSERT_EQUAL(rules.get_rto_template_reset_minutes(), 60, "Reset RTO rules did not restore the default package reset delay.")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/controller = allocate(/datum/rto_support_controller, human)
	var/datum/rto_support_action_template/mortar_he/action_template = allocate(/datum/rto_support_action_template/mortar_he)

	rules.rto_shared_cooldown_multiplier = 2
	rules.rto_personal_cooldown_multiplier = 3

	TEST_ASSERT_EQUAL(controller.get_effective_shared_cooldown(action_template), 80, "Shared cooldown multiplier did not affect future cooldown calculations.")
	TEST_ASSERT_EQUAL(controller.get_effective_personal_cooldown(action_template), 240, "Personal cooldown multiplier did not affect future cooldown calculations.")

	controller.shared_cooldowns_by_template["mortar"] = world.time + controller.get_effective_shared_cooldown(action_template)
	controller.action_cooldowns[action_template.action_id] = world.time + controller.get_effective_personal_cooldown(action_template)

	var/previous_shared_until = controller.shared_cooldowns_by_template["mortar"]
	var/previous_personal_until = controller.action_cooldowns[action_template.action_id]

	rules.rto_shared_cooldown_multiplier = 5
	rules.rto_personal_cooldown_multiplier = 6

	TEST_ASSERT_EQUAL(controller.shared_cooldowns_by_template["mortar"], previous_shared_until, "Existing shared cooldown was recalculated after multiplier change.")
	TEST_ASSERT_EQUAL(controller.action_cooldowns[action_template.action_id], previous_personal_until, "Existing personal cooldown was recalculated after multiplier change.")

/datum/unit_test/game_rule_panel_rto_charge_rules
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_charge_rules/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_rto_rules()
	TEST_ASSERT_EQUAL(rules.get_rto_support_resource_mode(), "charges", "Reset RTO rules did not restore the default support resource mode.")
	TEST_ASSERT(rules.rto_charge_recharge_enabled, "Reset RTO rules did not restore charge auto-recharge.")
	TEST_ASSERT_EQUAL(rules.get_rto_charge_recharge_multiplier(), 1, "Reset RTO rules did not restore the default recharge multiplier.")
	TEST_ASSERT_EQUAL(rules.get_rto_charge_capacity_multiplier(), 1, "Reset RTO rules did not restore the default capacity multiplier.")
	TEST_ASSERT(!rules.rto_charge_manual_only, "Reset RTO rules did not restore manual-only mode to disabled.")

	rules.rto_support_resource_mode = "legacy_cooldown"
	rules.rto_charge_recharge_enabled = FALSE
	rules.rto_charge_recharge_multiplier = 2
	rules.rto_charge_capacity_multiplier = 3
	rules.rto_charge_manual_only = TRUE

	rules.reset_rto_rules()

	TEST_ASSERT_EQUAL(rules.get_rto_support_resource_mode(), "charges", "RTO charge mode did not reset to charges.")
	TEST_ASSERT(rules.rto_charge_recharge_enabled, "Charge auto-recharge did not reset to enabled.")
	TEST_ASSERT_EQUAL(rules.get_rto_charge_recharge_multiplier(), 1, "Charge recharge multiplier did not reset to one.")
	TEST_ASSERT_EQUAL(rules.get_rto_charge_capacity_multiplier(), 1, "Charge capacity multiplier did not reset to one.")
	TEST_ASSERT(!rules.rto_charge_manual_only, "Manual-only charge mode did not reset to disabled.")

/datum/unit_test/game_rule_panel_rto_charge_lockout_rules
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_charge_lockout_rules/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_rto_rules()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/controller = allocate(/datum/rto_support_controller, human)
	var/datum/rto_support_action_template/game_rule_panel_charge_light/charge_action = allocate(/datum/rto_support_action_template/game_rule_panel_charge_light)
	var/datum/rto_support_action_template/mortar_he/legacy_action = allocate(/datum/rto_support_action_template/mortar_he)

	rules.rto_personal_cooldown_multiplier = 5

	TEST_ASSERT_EQUAL(controller.get_effective_action_lockout(charge_action), 2 SECONDS, "Charge-model anti-spam lockout should not be scaled by the legacy personal cooldown multiplier.")
	TEST_ASSERT_EQUAL(controller.get_effective_personal_cooldown(legacy_action), 400, "Legacy personal cooldown multiplier should still scale legacy cooldowns.")

/datum/unit_test/game_rule_panel_rto_charge_mode_flip_persists_pool
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_charge_mode_flip_persists_pool/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/datum/rto_support_registry/registry = GLOB.rto_support_registry
	rules.reset_rto_rules()
	registry.clear_controllers()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/controller = human.ensure_rto_support_controller()
	var/datum/rto_support_template/game_rule_panel_unit_test_charges/template = allocate(/datum/rto_support_template/game_rule_panel_unit_test_charges)
	controller.selected_templates = list(template)
	controller.apply_support_pool_rules_update()

	var/pool_id = controller.get_support_pool_id(template)
	var/datum/rto_support_resource_pool_state/pool = controller.get_support_pool(template, TRUE)
	TEST_ASSERT_NOTNULL(pool, "Charge test template should create a live support pool.")
	TEST_ASSERT(pool.pay(1, world.time), "Synthetic support pool should accept a valid charge spend.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 2, "Initial charge spend did not update the live pool state.")

	rules.rto_support_resource_mode = "legacy_cooldown"
	registry.propagate_rules_update()

	var/datum/rto_support_resource_pool_state/dormant_pool = controller.support_pools_by_id[pool_id]
	TEST_ASSERT_NULL(controller.get_support_pool(template), "Legacy mode should hide the active support pool runtime surface.")
	TEST_ASSERT_NOTNULL(dormant_pool, "Mode flip to legacy should preserve the dormant charge pool state.")
	TEST_ASSERT_EQUAL(dormant_pool.get_current_charges(world.time), 2, "Mode flip to legacy should not refill spent charges.")

	rules.rto_support_resource_mode = "charges"
	registry.propagate_rules_update()

	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 2, "Mode flip back to charges should keep the previously spent charge state.")

/datum/unit_test/game_rule_panel_rto_charge_recharge_resync
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_charge_recharge_resync/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/datum/rto_support_registry/registry = GLOB.rto_support_registry
	rules.reset_rto_rules()
	registry.clear_controllers()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/controller = human.ensure_rto_support_controller()
	var/datum/rto_support_template/game_rule_panel_unit_test_charges/template = allocate(/datum/rto_support_template/game_rule_panel_unit_test_charges)
	controller.selected_templates = list(template)
	controller.apply_support_pool_rules_update()

	var/datum/rto_support_resource_pool_state/pool = controller.get_support_pool(template, TRUE)
	TEST_ASSERT_NOTNULL(pool, "Charge test template should create a live support pool for recharge timing checks.")
	TEST_ASSERT(pool.pay(1, world.time), "Synthetic support pool should accept a valid charge spend before recharge timing checks.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_next_recharge_in(template), 30 SECONDS, "Synthetic support pool should start with the template recharge interval.")

	rules.rto_charge_recharge_multiplier = 2
	registry.propagate_rules_update()

	TEST_ASSERT_EQUAL(controller.get_support_pool_recharge_interval(template), 15 SECONDS, "Recharge interval should update immediately after a rules change.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_next_recharge_in(template), 15 SECONDS, "Active recharge timers should resync immediately after a rules change.")

/datum/unit_test/game_rule_panel_rto_selection_rules
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_selection_rules/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_rto_rules()
	rules.rto_template_slot_count = 3
	rules.rto_template_reset_minutes = 15

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/controller = human.ensure_rto_support_controller()

	TEST_ASSERT_EQUAL(controller.get_max_selected_templates(), 3, "Controller did not read the configured package slot count.")
	TEST_ASSERT_EQUAL(controller.get_selection_reset_delay_minutes(), 15, "Controller did not read the configured package reset delay.")
	TEST_ASSERT(controller.select_template("logistics"), "First package selection should succeed under the custom slot rules.")
	TEST_ASSERT(controller.select_template("medical"), "Second package selection should succeed under the custom slot rules.")
	TEST_ASSERT(controller.select_template("technical"), "Third package selection should succeed under the custom slot rules.")
	TEST_ASSERT(!controller.select_template("mortar"), "A fourth package should not fit into the configured three-slot model.")
	TEST_ASSERT_EQUAL(controller.selection_reset_available_at - controller.selection_started_at, 15 MINUTES, "Selection reset timing did not use the configured delay.")

	rules.rto_template_slot_count = 2
	rules.rto_template_reset_minutes = 5
	GLOB.rto_support_registry?.propagate_rules_update()

	TEST_ASSERT_EQUAL(controller.get_max_selected_templates(), 2, "Controller did not refresh the slot count after a rules update.")
	TEST_ASSERT_EQUAL(controller.get_selection_reset_delay_minutes(), 5, "Controller did not refresh the reset delay after a rules update.")
	TEST_ASSERT_EQUAL(length(controller.get_selected_templates()), 2, "Controller did not trim excess packages after the slot cap was lowered.")
	TEST_ASSERT_EQUAL(controller.selection_reset_available_at - controller.selection_started_at, 5 MINUTES, "Controller did not recalculate the active reset timer after the delay changed.")

/datum/unit_test/game_rule_panel_rto_live_charge_admin
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_live_charge_admin/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/datum/rto_support_registry/registry = GLOB.rto_support_registry
	rules.reset_rto_rules()
	registry.clear_controllers()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	human.ckey = "charge_admin_target"
	human.real_name = "Charge Admin Target"

	var/datum/rto_support_controller/controller = human.ensure_rto_support_controller()
	var/datum/rto_support_template/game_rule_panel_unit_test_charges/template = allocate(/datum/rto_support_template/game_rule_panel_unit_test_charges)
	controller.selected_templates = list(template)
	controller.apply_support_pool_rules_update()

	var/list/admin_rows = rules.build_active_rto_charge_admin_data()
	TEST_ASSERT_EQUAL(length(admin_rows), 1, "Game Rule Panel should expose one active RTO controller in the live charge admin table.")
	var/list/admin_row = admin_rows[1]
	TEST_ASSERT_EQUAL(admin_row["ckey"], ckey("charge_admin_target"), "Game Rule Panel live RTO data should expose the owner's normalized ckey.")
	TEST_ASSERT_EQUAL(admin_row["name"], "Charge Admin Target", "Game Rule Panel live RTO data should expose the owner's display name.")
	TEST_ASSERT_EQUAL(length(admin_row["selected_template_entries"]), 1, "Game Rule Panel live RTO data should expose selected template rows for per-player package management.")
	TEST_ASSERT_EQUAL(length(admin_row["pools"]), 1, "Game Rule Panel live RTO data should expose the synthetic charge pool.")
	TEST_ASSERT_NOTNULL(registry.find_controller_by_ckey("charge_admin_target"), "RTO registry should resolve an active controller by ckey for Game Rule Panel actions.")

	TEST_ASSERT(controller.set_template_pool_current_charges(template.template_id, 1, "gm_alpha"), "GM current-charge override should succeed for an active RTO pool.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 1, "GM current-charge override did not update the live charge pool.")
	TEST_ASSERT(controller.adjust_template_pool_current_charges(template.template_id, 2, "gm_alpha"), "GM charge grant should succeed for an active RTO pool.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 3, "GM charge grant did not update the live charge pool.")
	TEST_ASSERT(controller.set_template_pool_capacity(template.template_id, 5, "gm_alpha"), "GM capacity override should succeed for an active RTO pool.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_capacity(template), 5, "GM capacity override did not update the live charge pool capacity.")
	TEST_ASSERT(controller.set_template_pool_auto_recharge(template.template_id, FALSE, "gm_alpha"), "GM auto-recharge override should succeed for an active RTO pool.")
	TEST_ASSERT(!controller.is_support_pool_auto_recharge_enabled(template), "GM auto-recharge override did not disable auto-refill for the active pool.")
	TEST_ASSERT(controller.set_template_pool_manual_only(template.template_id, TRUE, "gm_alpha"), "GM manual-only override should succeed for an active RTO pool.")
	TEST_ASSERT(controller.is_support_pool_manual_only(template), "GM manual-only override did not mark the active pool as manual-only.")
	TEST_ASSERT(controller.refill_all_template_pools("gm_alpha"), "GM refill-all action should succeed for the active RTO controller.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 5, "GM refill-all action did not top the pool up to its overridden capacity.")
	TEST_ASSERT(controller.empty_all_template_pools("gm_alpha"), "GM empty-all action should succeed for the active RTO controller.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 0, "GM empty-all action did not drain the pool.")
	TEST_ASSERT(controller.reset_template_pool_to_defaults(template.template_id, "gm_alpha"), "GM pool reset should succeed for the active RTO pool.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_current_charges(template), 3, "GM pool reset did not restore the default starting charges.")
	TEST_ASSERT_EQUAL(controller.get_support_pool_capacity(template), 3, "GM pool reset did not clear the overridden capacity.")
	TEST_ASSERT(controller.is_support_pool_auto_recharge_enabled(template), "GM pool reset did not restore the default auto-recharge mode.")
	TEST_ASSERT(!controller.is_support_pool_manual_only(template), "GM pool reset did not clear manual-only mode.")

	var/list/refreshed_rows = rules.build_active_rto_charge_admin_data()
	var/list/refreshed_row = refreshed_rows[1]
	var/list/refreshed_pool = refreshed_row["pools"][1]
	TEST_ASSERT_EQUAL(refreshed_pool["current_charges"], 3, "Refreshed live RTO data did not report the restored charge count.")
	TEST_ASSERT_EQUAL(refreshed_pool["capacity"], 3, "Refreshed live RTO data did not report the restored pool capacity.")
	TEST_ASSERT_EQUAL(refreshed_pool["last_modified_by_admin_ckey"], "gm_alpha", "Refreshed live RTO data did not keep the last GM editor attribution.")

/datum/unit_test/game_rule_panel_rto_remove_selected_template
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_remove_selected_template/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/datum/rto_support_registry/registry = GLOB.rto_support_registry
	rules.reset_rto_rules()
	registry.clear_controllers()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	human.ckey = "template_remove_target"
	var/datum/rto_support_controller/controller = human.ensure_rto_support_controller()
	var/datum/rto_support_template/game_rule_panel_unit_test_charges/charge_template = allocate(/datum/rto_support_template/game_rule_panel_unit_test_charges)
	var/datum/rto_support_template/logistics/logistics_template = allocate(/datum/rto_support_template/logistics)
	controller.selected_templates = list(charge_template, logistics_template)
	controller.apply_support_pool_rules_update()

	TEST_ASSERT_EQUAL(length(controller.get_selected_templates()), 2, "Removal test setup should start with two selected packages.")
	TEST_ASSERT_NOTNULL(controller.get_support_pool(charge_template, TRUE), "Charge-based removal test template should create a live support pool before deletion.")
	TEST_ASSERT(controller.remove_selected_template(charge_template.template_id, "gm_remove"), "Game Rule Panel package removal should succeed for a selected template.")
	TEST_ASSERT_EQUAL(length(controller.get_selected_templates()), 1, "Removing one selected RTO package should leave the remaining package intact.")
	TEST_ASSERT_NULL(controller.get_selected_template(charge_template.template_id), "Removed RTO package should no longer appear in the selected template list.")
	TEST_ASSERT_NOTNULL(controller.get_selected_template(logistics_template.template_id), "Removing one selected RTO package should not remove unrelated packages.")
	TEST_ASSERT_NULL(controller.get_support_pool(charge_template), "Removing a selected charge package should also remove its live support pool.")

	var/list/admin_rows = rules.build_active_rto_charge_admin_data()
	TEST_ASSERT_EQUAL(length(admin_rows), 1, "Live RTO admin data should still expose the controller after removing one package.")
	var/list/admin_row = admin_rows[1]
	TEST_ASSERT_EQUAL(length(admin_row["selected_template_entries"]), 1, "Live RTO admin data should shrink the selected-template table after package removal.")
	var/list/remaining_template = admin_row["selected_template_entries"][1]
	TEST_ASSERT_EQUAL(remaining_template["template_id"], logistics_template.template_id, "Live RTO admin data should keep the surviving selected package after removal.")

// SS220 EDIT - START: cover BT underground-support defaults and reset behavior
/datum/unit_test/game_rule_panel_underground_support_defaults
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_underground_support_defaults/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	TEST_ASSERT(rules.support_underground_enabled, "Underground support should default to enabled.")

	rules.support_underground_enabled = FALSE
	rules.reset_rto_rules()

	TEST_ASSERT(rules.support_underground_enabled, "RTO rules reset did not restore underground support.")
// SS220 EDIT - END

/datum/unit_test/game_rule_panel_rto_disable
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_rto_disable/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_rto_rules()
	rules.rto_support_enabled = FALSE

	var/mob/living/carbon/human/select_human = allocate(/mob/living/carbon/human)
	select_human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/select_controller = allocate(/datum/rto_support_controller, select_human)
	TEST_ASSERT(!select_controller.can_open_template_menu(), "Preset selection remained available while RTO support was disabled.")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.job = JOB_SQUAD_RTO
	var/datum/rto_support_controller/controller = allocate(/datum/rto_support_controller, human)
	var/datum/rto_support_template/mortar/template = allocate(/datum/rto_support_template/mortar)
	controller.selected_templates += template

	var/datum/rto_support_action_template/action_template = template.get_action_template("mortar_he")
	TEST_ASSERT_NOTNULL(action_template, "Failed to retrieve RTO action template for disable rules test.")

	controller.active_zone = allocate(/datum/rto_visibility_zone, human, run_loc_floor_bottom_left, template)
	// controller.armed_action_id = "__visibility_zone__"
	controller.armed_action_id = RTO_SUPPORT_ARM_VISIBILITY_ZONE // switched unit test back to shared hardcode define
	controller.armed_template_id = "mortar"
	controller.apply_rules_update()

	TEST_ASSERT_NULL(controller.active_zone, "Active RTO visibility zone was not cleared after disabling support.")
	TEST_ASSERT_NULL(controller.armed_action_id, "Restricted armed action remained armed after disabling support.")
	TEST_ASSERT_EQUAL(controller.zone_shared_cooldown_until, 0, "Disabling RTO support applied a new visibility zone cooldown.")
	// TEST_ASSERT(controller.can_arm_action("__coordinates__"), "Coordinates action should remain available when RTO support is disabled.")
	TEST_ASSERT(controller.can_arm_action(RTO_SUPPORT_ARM_COORDINATES), "Coordinates action should remain available when RTO support is disabled.") // switched unit test back to shared hardcode define
	// TEST_ASSERT(controller.can_arm_action("__manual_marker__"), "Manual marker action should remain available when RTO support is disabled.")
	TEST_ASSERT(controller.can_arm_action(RTO_SUPPORT_ARM_MARKER), "Manual marker action should remain available when RTO support is disabled.") //  switched unit test back to shared hardcode define
	TEST_ASSERT(!controller.can_arm_action(action_template.action_id), "Strike action remained armable while RTO support was disabled.")

	var/list/visibility_state = controller.build_visibility_action_state("mortar")
	TEST_ASSERT(visibility_state["is_disabled"], "Visibility action state was not disabled by game rules.")
	TEST_ASSERT_EQUAL(visibility_state["primary_label"], "Disabled by Game Rule Panel", "Visibility action did not show the expected Game Rule Panel block reason.")

	var/list/support_state = controller.build_support_action_state(action_template.action_id, "mortar")
	TEST_ASSERT(support_state["is_disabled"], "Support action state was not disabled by game rules.")
	TEST_ASSERT_EQUAL(support_state["primary_label"], "Disabled by Game Rule Panel", "Support action did not show the expected Game Rule Panel block reason.")

/datum/unit_test/game_rule_panel_fire_support_master_toggle
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_fire_support_master_toggle/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_fire_support_rules()
	rules.fire_support_enabled = TRUE

	var/datum/fire_support/fire_support_option = GLOB.fire_support_types[FIRESUPPORT_TYPE_GUN]
	TEST_ASSERT_NOTNULL(fire_support_option, "Failed to find fire support datum for master toggle test.")

	var/original_flags = fire_support_option.fire_support_flags
	rules.fire_support_enabled = FALSE

	TEST_ASSERT_EQUAL(fire_support_option.fire_support_flags, original_flags, "Master toggle rewrote individual fire support availability flags.")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/device/binoculars/fire_support/binoculars = allocate(/obj/item/device/binoculars/fire_support)
	binoculars.mode = fire_support_option

	TEST_ASSERT(!binoculars.bino_checks(run_loc_floor_bottom_left, human), "Fire support binoculars were not blocked by the master toggle.")

	rules.fire_support_enabled = TRUE

/datum/unit_test/game_rule_panel_fire_support_points
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_fire_support_points/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_fire_support_rules()
	GLOB.fire_support_points[FACTION_MARINE] = 0

	TEST_ASSERT(rules.grant_fire_support_points(FACTION_MARINE, 7), "Granting fire support points returned FALSE.")
	TEST_ASSERT_EQUAL(GLOB.fire_support_points[FACTION_MARINE], 7, "Fire support points were not added additively.")

/datum/unit_test/game_rule_panel_fire_support_toggle_entry
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_fire_support_toggle_entry/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_fire_support_rules()

	var/datum/fire_support/fire_support_option = GLOB.fire_support_types[FIRESUPPORT_TYPE_GUN]
	TEST_ASSERT_NOTNULL(fire_support_option, "Failed to find fire support datum for availability toggle test.")

	var/original_available = !!(fire_support_option.fire_support_flags & FIRESUPPORT_AVAILABLE)
	TEST_ASSERT(rules.set_fire_support_type_enabled(FIRESUPPORT_TYPE_GUN, !original_available), "Toggling fire support availability returned FALSE.")
	TEST_ASSERT_EQUAL(!!(fire_support_option.fire_support_flags & FIRESUPPORT_AVAILABLE), !original_available, "Fire support availability flag did not flip after panel toggle.")

	TEST_ASSERT(rules.set_fire_support_type_enabled(FIRESUPPORT_TYPE_GUN, original_available), "Failed to restore original fire support availability after toggle test.")

/datum/unit_test/game_rule_panel_player_survival_defaults
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_defaults/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.player_survival_enabled = FALSE
	rules.player_survival_crit_grace_seconds = 99
	rules.player_survival_antigib_enabled = FALSE
	rules.player_survival_antigib_limb_loss_chance = 77
	rules.reset_player_survival_rules()

	TEST_ASSERT(rules.player_survival_enabled, "Player Survival reset did not restore Save Before Death.")
	TEST_ASSERT_EQUAL(rules.player_survival_crit_grace_seconds, 15, "Player Survival reset did not restore the default crit grace duration.")
	TEST_ASSERT(rules.player_survival_antigib_enabled, "Player Survival reset did not restore Anti-Gib Fallback.")
	TEST_ASSERT_EQUAL(rules.player_survival_antigib_limb_loss_chance, 30, "Player Survival reset did not restore the default limb loss chance.")

// SS220 EDIT - START: cover the BT-only new-round player survival reset path
/datum/unit_test/game_rule_panel_player_survival_new_round_defaults
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_new_round_defaults/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.player_survival_enabled = FALSE
	rules.player_survival_crit_grace_seconds = 0
	rules.player_survival_antigib_enabled = FALSE
	rules.player_survival_antigib_limb_loss_chance = 100
	rules.reset_player_survival_for_new_round()

	TEST_ASSERT(rules.player_survival_enabled, "New-round player survival reset did not restore Save Before Death.")
	TEST_ASSERT_EQUAL(rules.player_survival_crit_grace_seconds, 15, "New-round player survival reset did not restore the default crit grace duration.")
	TEST_ASSERT(rules.player_survival_antigib_enabled, "New-round player survival reset did not restore Anti-Gib Fallback.")
	TEST_ASSERT_EQUAL(rules.player_survival_antigib_limb_loss_chance, 30, "New-round player survival reset did not restore the default limb loss chance.")
// SS220 EDIT - END

/datum/unit_test/game_rule_panel_player_survival_runtime_duration
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_runtime_duration/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_player_survival_rules()
	rules.player_survival_crit_grace_seconds = 42

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	TEST_ASSERT_EQUAL(human.player_survival_get_crit_grace_seconds(), 42, "Player Survival crit grace duration did not read from Game Rule Panel runtime state.")

/datum/unit_test/game_rule_panel_player_survival_damage_block_toggle
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_damage_block_toggle/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_player_survival_rules()

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	human.player_survival_damage_block_until = world.time + 50

	TEST_ASSERT(human.player_survival_is_damage_blocked(), "Active crit grace should block damage while Save Before Death is enabled.")

	rules.player_survival_enabled = FALSE
	TEST_ASSERT(!human.player_survival_is_damage_blocked(), "Disabling Save Before Death should immediately disable active crit grace blocking.")

/datum/unit_test/game_rule_panel_player_survival_antigib_gib_toggle
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_antigib_gib_toggle/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_player_survival_rules()
	rules.player_survival_antigib_enabled = FALSE

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	human.gib(create_cause_data("unit test"))

	TEST_ASSERT(QDELETED(human), "Disabling Anti-Gib Fallback should restore normal gib behavior for human.gib().")

/datum/unit_test/game_rule_panel_player_survival_antigib_explosion_toggle
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_antigib_explosion_toggle/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_player_survival_rules()
	rules.player_survival_antigib_enabled = FALSE

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	human.ex_act(EXPLOSION_THRESHOLD_GIB + 1, null, create_cause_data("unit test"))

	TEST_ASSERT(QDELETED(human), "Disabling Anti-Gib Fallback should restore normal gib behavior for explosion entrypoints.")

/datum/unit_test/game_rule_panel_player_survival_antigib_without_grace
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_antigib_without_grace/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_player_survival_rules()
	rules.player_survival_enabled = FALSE
	rules.player_survival_antigib_enabled = TRUE
	rules.player_survival_antigib_limb_loss_chance = 0

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	TEST_ASSERT(human.player_survival_apply_non_gib_fallback(create_cause_data("unit test"), EXPLOSION_THRESHOLD_GIB, EXPLOSION_THRESHOLD_GIB, TRUE), "Anti-Gib Fallback did not trigger while enabled.")
	TEST_ASSERT(!QDELETED(human), "Anti-Gib Fallback should keep the mob alive when Save Before Death is disabled.")
	TEST_ASSERT_EQUAL(human.player_survival_damage_block_until, 0, "Anti-Gib Fallback should not start crit grace when Save Before Death is disabled.")

/datum/unit_test/game_rule_panel_player_survival_limb_loss_boundaries
	parent_type = /datum/unit_test/game_rule_panel

/datum/unit_test/game_rule_panel_player_survival_limb_loss_boundaries/Run()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	rules.reset_player_survival_rules()
	rules.player_survival_enabled = FALSE
	rules.player_survival_antigib_enabled = TRUE

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human_zero = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	var/before_zero = count_player_survival_extremities(human_zero)
	rules.player_survival_antigib_limb_loss_chance = 0
	TEST_ASSERT(human_zero.player_survival_apply_non_gib_fallback(create_cause_data("unit test zero"), EXPLOSION_THRESHOLD_GIB, EXPLOSION_THRESHOLD_GIB, TRUE), "Anti-Gib Fallback failed during 0% limb loss test.")
	TEST_ASSERT_EQUAL(count_player_survival_extremities(human_zero), before_zero, "0% limb loss chance should never detach an extremity.")

	var/mob/living/carbon/human/game_rule_panel_player_survival_test/human_full = allocate(/mob/living/carbon/human/game_rule_panel_player_survival_test)
	var/before_full = count_player_survival_extremities(human_full)
	rules.player_survival_antigib_limb_loss_chance = 100
	TEST_ASSERT(human_full.player_survival_apply_non_gib_fallback(create_cause_data("unit test full"), EXPLOSION_THRESHOLD_GIB, EXPLOSION_THRESHOLD_GIB, TRUE), "Anti-Gib Fallback failed during 100% limb loss test.")
	TEST_ASSERT_EQUAL(count_player_survival_extremities(human_full), before_full - 1, "100% limb loss chance should always detach exactly one extremity.")
