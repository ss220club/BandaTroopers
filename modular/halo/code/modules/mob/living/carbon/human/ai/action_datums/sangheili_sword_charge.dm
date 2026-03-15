/datum/ai_action/sangheili_sword_charge
	name = "Sangheili Sword Charge"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS

/datum/ai_action/sangheili_sword_charge/Added()
	brain.end_cover()

/datum/ai_action/sangheili_sword_charge/get_weight(datum/human_ai_brain/brain)
	if(!brain.halo_sangheili_runtime)
		return 0

	if(!brain.in_combat || brain.hold_position || brain.active_grenade_found)
		return 0

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!threat)
		return 0

	if(!brain.halo_sangheili_should_sword_charge(threat))
		return 0

	if(brain.halo_sangheili_sword_only)
		return 60

	return 45

/datum/ai_action/sangheili_sword_charge/Destroy(force, ...)
	if(!brain?.halo_sangheili_should_keep_sword_drawn())
		if(!brain?.halo_sangheili_restore_ranged_state())
			brain?.halo_sangheili_holster_sword()
	return ..()

/datum/ai_action/sangheili_sword_charge/trigger_action()
	. = ..()

	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!brain.halo_sangheili_runtime || !tied_human || !threat || !brain.in_combat || !brain.halo_sangheili_should_sword_charge(threat))
		if(!brain.halo_sangheili_restore_ranged_state())
			brain.halo_sangheili_holster_sword()
		return ONGOING_ACTION_COMPLETED

	brain.end_cover()
	tied_human.a_intent_change(INTENT_HARM)

	var/obj/item/weapon/covenant/energy_sword/sword = brain.halo_sangheili_draw_sword()
	if(!sword && !brain.halo_sangheili_sword_only)
		brain.halo_sangheili_restore_ranged_state()
		return ONGOING_ACTION_COMPLETED

	if(get_dist(tied_human, threat) <= 1)
		if(!sword)
			brain.halo_covenant_clear_hands()
		tied_human.face_atom(threat)
		INVOKE_ASYNC(tied_human, TYPE_PROC_REF(/mob, do_click), threat, "", list())
		return ONGOING_ACTION_UNFINISHED_BLOCK

	var/turf/threat_turf = brain.halo_covenant_get_cached_threat_turf()
	if(!threat_turf)
		return ONGOING_ACTION_COMPLETED

	if(!brain.move_to_next_turf(threat_turf))
		return ONGOING_ACTION_COMPLETED

	tied_human.face_atom(threat)
	return ONGOING_ACTION_UNFINISHED_BLOCK
