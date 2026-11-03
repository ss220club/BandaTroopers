/datum/human_ai_module/melee/proc/halo_sangheili_on_sword_charge_added()
	brain?.halo_covenant_end_cover()

/datum/human_ai_module/melee/proc/halo_sangheili_get_sword_charge_weight()
	if(!brain?.halo_sangheili_is_active())
		return 0

	if(!brain.halo_covenant_can_run_movement_action(TRUE))
		return 0

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!threat)
		return 0

	if(!brain.halo_sangheili_should_sword_charge(threat))
		return 0

	if(brain.halo_sangheili_is_sword_only())
		return 60

	return 45

/datum/human_ai_module/melee/proc/halo_sangheili_cleanup_sword_charge()
	if(!brain?.halo_sangheili_should_keep_sword_drawn())
		if(!brain?.halo_sangheili_restore_ranged_state())
			brain?.halo_sangheili_holster_sword()

/datum/human_ai_module/melee/proc/halo_sangheili_run_sword_charge_step()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!brain.halo_sangheili_is_active() || !brain.has_valid_tied_human() || !threat || !brain.halo_covenant_can_run_movement_action(TRUE) || !brain.halo_sangheili_should_sword_charge(threat))
		if(!brain.halo_sangheili_restore_ranged_state())
			brain.halo_sangheili_holster_sword()
		return ONGOING_ACTION_COMPLETED

	brain.halo_covenant_end_cover()
	controller.set_combat_intent()

	var/obj/item/weapon/covenant/energy_sword/sword = brain.halo_sangheili_draw_sword()
	if(!sword && !brain.halo_sangheili_is_sword_only())
		brain.halo_sangheili_restore_ranged_state()
		return ONGOING_ACTION_COMPLETED

	if(controller.get_distance_to(threat) <= 1)
		if(!sword)
			brain.halo_covenant_clear_hands()
		controller.face_atom(threat)
		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/human_tied_controller, do_click), threat, "", list())
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(!brain.halo_covenant_move_to_threat(threat))
		return ONGOING_ACTION_COMPLETED
	return ONGOING_ACTION_UNFINISHED_BLOCK

/datum/human_ai_module/melee/proc/halo_sangheili_on_unarmed_action_added()
	brain?.halo_sangheili_holster_sword()

/datum/human_ai_module/melee/proc/halo_sangheili_cleanup_unarmed_action()
	brain?.halo_sangheili_holster_sword()

/datum/human_ai_module/melee/proc/halo_sangheili_get_kick_weight()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain?.halo_sangheili_is_active() || !controller)
		return 0

	if(!brain.halo_covenant_can_run_movement_action(TRUE))
		return 0

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!threat || !brain.has_valid_tied_human())
		return 0

	if(brain.halo_sangheili_should_sword_charge(threat))
		return 0

	if(!brain.halo_sangheili_should_unarmed_commit(threat))
		return 0

	if(!brain.halo_sangheili_should_overheat_response(threat) && !brain.halo_sangheili_primary_weapon_unavailable())
		return 0

	if(controller.get_distance_to(threat) <= 1)
		return 44

	return 18

/datum/human_ai_module/melee/proc/halo_sangheili_run_kick_step()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!brain.halo_sangheili_is_active() || !brain.has_valid_tied_human() || !threat || !brain.halo_covenant_can_run_movement_action(TRUE))
		return ONGOING_ACTION_COMPLETED

	if(brain.halo_covenant_has_pending_cover())
		return ONGOING_ACTION_COMPLETED

	if(brain.halo_sangheili_should_sword_charge(threat))
		return ONGOING_ACTION_COMPLETED

	if(!brain.halo_sangheili_should_unarmed_commit(threat))
		return ONGOING_ACTION_COMPLETED

	if(!brain.halo_sangheili_should_overheat_response(threat) && !brain.halo_sangheili_primary_weapon_unavailable())
		return ONGOING_ACTION_COMPLETED

	controller.set_combat_intent()
	brain.halo_covenant_end_cover()
	brain.halo_sangheili_holster_sword()
	brain.halo_covenant_clear_hands()

	if(controller.get_distance_to(threat) <= 1)
		controller.face_atom(threat)
		if(prob(70) && controller.halo_use_sangheili_kick(threat))
			return ONGOING_ACTION_UNFINISHED_BLOCK
		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/human_tied_controller, do_click), threat, "", list())
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(!brain.halo_covenant_move_to_threat(threat))
		return ONGOING_ACTION_COMPLETED
	return ONGOING_ACTION_UNFINISHED_BLOCK

/datum/human_ai_module/melee/proc/halo_sangheili_get_overheat_response_weight()
	if(!brain?.halo_sangheili_is_active())
		return 0

	if(!brain.halo_covenant_can_run_movement_action(TRUE))
		return 0

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!threat)
		return 0

	if(!brain.halo_sangheili_should_overheat_response(threat))
		return 0

	if(brain.halo_sangheili_should_unarmed_commit(threat))
		return 38

	return 32

/datum/human_ai_module/melee/proc/halo_sangheili_run_overheat_response_step()
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!brain.halo_sangheili_is_active() || !brain.has_valid_tied_human() || !threat || !brain.halo_covenant_can_run_movement_action(TRUE) || !brain.halo_sangheili_should_overheat_response(threat))
		return ONGOING_ACTION_COMPLETED

	controller.set_combat_intent()

	if(brain.halo_sangheili_should_unarmed_commit(threat))
		brain.halo_covenant_end_cover()
		brain.halo_sangheili_holster_sword()
		brain.halo_covenant_clear_hands()
		controller.face_atom(threat)
		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/human_tied_controller, do_click), threat, "", list())
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(brain.halo_covenant_try_cover_retreat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(brain.halo_covenant_step_away_from_threat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	return ONGOING_ACTION_COMPLETED
