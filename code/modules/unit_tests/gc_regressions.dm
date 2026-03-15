/datum/unit_test/gc_regressions
	var/list/created_accounts
	var/list/created_squads
	var/list/created_squad_ids
	var/list/created_traits

/datum/unit_test/gc_regressions/New()
	. = ..()
	created_accounts = list()
	created_squads = list()
	created_squad_ids = list()
	created_traits = list()

/datum/unit_test/gc_regressions/Destroy()
	for(var/datum/money_account/account as anything in created_accounts)
		GLOB.all_money_accounts -= account
		if(!QDELETED(account))
			qdel(account)

	for(var/squad_id as anything in created_squad_ids)
		var/datum/human_ai_squad/lingering_squad
		if(SShuman_ai && islist(SShuman_ai.squad_id_dict))
			lingering_squad = SShuman_ai.squad_id_dict["[squad_id]"]
		if(lingering_squad)
			SShuman_ai.squads -= lingering_squad
			SShuman_ai.squad_id_dict -= "[squad_id]"
			if(!QDELETED(lingering_squad))
				qdel(lingering_squad, force = TRUE)

	for(var/datum/human_ai_squad/squad as anything in created_squads)
		if(!QDELETED(squad))
			qdel(squad, force = TRUE)

	for(var/datum/character_trait/trait as anything in created_traits)
		if(!QDELETED(trait))
			qdel(trait, force = TRUE)

	return ..()

/datum/unit_test/gc_regressions/proc/get_any_paygrade()
	for(var/paygrade_id in GLOB.paygrades)
		var/datum/paygrade/paygrade = GLOB.paygrades[paygrade_id]
		if(paygrade)
			return paygrade

	return null

/datum/unit_test/gc_regressions/Run()
	return

/datum/unit_test/gc_regressions_account_owner_snapshot
	parent_type = /datum/unit_test/gc_regressions

/datum/unit_test/gc_regressions_account_owner_snapshot/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	human.real_name = "GC Account Tester"
	human.name = human.real_name

	var/datum/paygrade/paygrade = get_any_paygrade()
	TEST_ASSERT_NOTNULL(paygrade, "Failed to resolve a paygrade for the money-account GC regression test.")

	var/datum/money_account/account = create_account(human, 10, paygrade)
	created_accounts += account

	TEST_ASSERT(istext(account.owner_name), "Money account owner_name should be stored as plain text.")
	TEST_ASSERT_EQUAL(account.owner_name, human.real_name, "Money account owner_name should snapshot the human name instead of retaining the mob ref.")
	TEST_ASSERT(length(account.transaction_log) >= 1, "Money account creation should seed an initial transaction.")

	var/datum/transaction/transaction = account.transaction_log[1]
	TEST_ASSERT(istext(transaction.target_name), "Initial money account transaction target_name should be stored as plain text.")
	TEST_ASSERT_EQUAL(transaction.target_name, human.real_name, "Initial money account transaction should snapshot the human name instead of retaining the mob ref.")

/datum/unit_test/gc_regressions_human_ai_squad_cleanup
	parent_type = /datum/unit_test/gc_regressions

/datum/unit_test/gc_regressions_human_ai_squad_cleanup/Run()
	var/datum/human_ai_squad/squad = SShuman_ai.create_new_squad()
	TEST_ASSERT_NOTNULL(squad, "Failed to create a Human AI squad for GC cleanup regression testing.")

	created_squads += squad
	created_squad_ids += squad.id

	var/squad_key = "[squad.id]"
	TEST_ASSERT_EQUAL(SShuman_ai.get_squad(squad_key), squad, "Freshly created Human AI squad was not indexed by its id.")

	qdel(squad, force = TRUE)

	TEST_ASSERT(QDELETED(squad), "Human AI squad should qdel immediately during the cleanup regression test.")
	TEST_ASSERT(!(squad_key in SShuman_ai.squad_id_dict), "Human AI squad id should be removed from squad_id_dict during Destroy().")
	TEST_ASSERT(!(squad in SShuman_ai.squads), "Human AI squad should be removed from the subsystem squad list during Destroy().")
	TEST_ASSERT_NULL(SShuman_ai.get_squad(squad_key), "Human AI squad lookup should return null after qdel cleanup.")

/datum/unit_test/gc_regressions_xeno_ai_action_cleanup
	parent_type = /datum/unit_test/gc_regressions

/datum/unit_test/gc_regressions_xeno_ai_action_cleanup/Run()
	var/list/required_action_types = list(
		/datum/action/xeno_action/activable/fling/charger,
		/datum/action/xeno_action/onclick/charger_charge,
		/datum/action/xeno_action/onclick/crusher_stomp,
	)

	var/mob/living/carbon/xenomorph/crusher/action_cleanup_crusher = allocate(/mob/living/carbon/xenomorph/crusher, run_loc_floor_top_right)
	var/datum/action/xeno_action/onclick/charger_charge/charge_action = get_action(action_cleanup_crusher, /datum/action/xeno_action/onclick/charger_charge)
	TEST_ASSERT_NOTNULL(charge_action, "Crusher should start with Toggle Charging for xeno AI action cleanup testing.")
	TEST_ASSERT(charge_action in action_cleanup_crusher.registered_ai_abilities, "Toggle Charging should be tracked in registered_ai_abilities before qdel.")

	qdel(charge_action, force = TRUE)

	TEST_ASSERT(QDELETED(charge_action), "Toggle Charging should qdel immediately during xeno AI action cleanup testing.")
	TEST_ASSERT(!(charge_action in action_cleanup_crusher.registered_ai_abilities), "Qdeleted xeno AI actions should remove themselves from registered_ai_abilities.")
	TEST_ASSERT_NULL(charge_action.owner, "Qdeleted xeno AI actions should drop their owner reference during cleanup.")

	var/mob/living/carbon/xenomorph/crusher/destroy_cleanup_crusher = allocate(/mob/living/carbon/xenomorph/crusher, run_loc_floor_bottom_left)
	var/list/tracked_actions = list()

	for(var/action_type as anything in required_action_types)
		var/datum/action/xeno_action/action = get_action(destroy_cleanup_crusher, action_type)
		TEST_ASSERT_NOTNULL(action, "Crusher was missing [action_type] during xeno AI action cleanup testing.")
		TEST_ASSERT(action in destroy_cleanup_crusher.registered_ai_abilities, "[action.type] should be tracked in registered_ai_abilities before crusher deletion.")
		tracked_actions += action

	qdel(destroy_cleanup_crusher, force = TRUE)

	TEST_ASSERT(QDELETED(destroy_cleanup_crusher), "Crusher should qdel immediately during xeno AI action cleanup testing.")
	TEST_ASSERT(!length(destroy_cleanup_crusher.registered_ai_abilities), "Crusher Destroy() should clear registered_ai_abilities before action GC runs.")

	for(var/datum/action/xeno_action/tracked_action as anything in tracked_actions)
		TEST_ASSERT_NULL(tracked_action.owner, "[tracked_action.type] should drop its owner reference during crusher cleanup.")

/datum/unit_test/gc_regressions_character_trait_cleanup
	parent_type = /datum/unit_test/gc_regressions

/datum/unit_test/gc_regressions_character_trait_cleanup/Run()
	var/datum/character_trait_group/biology/biology_group = GLOB.character_trait_groups[/datum/character_trait_group/biology]
	TEST_ASSERT_NOTNULL(biology_group, "Failed to resolve the biology trait group for character-trait GC regression testing.")

	var/datum/character_trait/biology/hardcore/runtime_trait = new
	created_traits += runtime_trait

	TEST_ASSERT(runtime_trait in biology_group.traits, "Runtime-created biology trait should register itself in the biology group list before cleanup.")

	qdel(runtime_trait, force = TRUE)

	TEST_ASSERT(QDELETED(runtime_trait), "Runtime-created biology trait should qdel immediately during the GC regression test.")
	TEST_ASSERT(!(runtime_trait in biology_group.traits), "Character trait Destroy() should remove runtime-created traits from their trait group list.")
