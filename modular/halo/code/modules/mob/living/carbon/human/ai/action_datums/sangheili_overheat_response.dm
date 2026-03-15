/datum/ai_action/sangheili_overheat_response
	name = "Sangheili Overheat Response"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS

/datum/ai_action/sangheili_overheat_response/Added()
	brain.halo_sangheili_holster_sword()

/datum/ai_action/sangheili_overheat_response/get_weight(datum/human_ai_brain/brain)
	if(!brain.halo_sangheili_runtime)
		return 0

	if(!brain.in_combat || brain.hold_position || brain.active_grenade_found)
		return 0

	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!threat)
		return 0

	if(!brain.halo_sangheili_should_overheat_response(threat))
		return 0

	if(brain.halo_sangheili_should_unarmed_commit(threat))
		return 38

	return 32

/datum/ai_action/sangheili_overheat_response/Destroy(force, ...)
	brain?.halo_sangheili_holster_sword()
	return ..()

/datum/ai_action/sangheili_overheat_response/trigger_action()
	. = ..()

	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!brain.halo_sangheili_runtime || !tied_human || !threat || !brain.in_combat || !brain.halo_sangheili_should_overheat_response(threat))
		return ONGOING_ACTION_COMPLETED

	tied_human.a_intent_change(INTENT_HARM)

	if(brain.halo_sangheili_should_unarmed_commit(threat))
		brain.end_cover()
		brain.halo_sangheili_holster_sword()
		brain.halo_covenant_clear_hands()
		tied_human.face_atom(threat)
		INVOKE_ASYNC(tied_human, TYPE_PROC_REF(/mob, do_click), threat, "", list())
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(try_cover_retreat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(step_away_from_threat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	return ONGOING_ACTION_COMPLETED

/datum/ai_action/sangheili_overheat_response/proc/try_cover_retreat(atom/threat)
	if(!brain.current_cover)
		brain.try_cover(Get_Angle(threat, brain.tied_human), threat)

	var/turf/cover_turf = get_turf(brain.current_cover)
	if(!cover_turf)
		return FALSE

	if(get_dist(cover_turf, brain.tied_human) > 0)
		if(!brain.move_to_next_turf(cover_turf))
			brain.end_cover()
			return FALSE

		return TRUE

	brain.in_cover = TRUE
	brain.tied_human.face_atom(threat)
	return TRUE

/datum/ai_action/sangheili_overheat_response/proc/step_away_from_threat(atom/threat)
	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/turf/threat_turf = brain.halo_covenant_get_cached_threat_turf()
	if(!tied_human || !threat_turf)
		return FALSE

	var/turf/best_destination
	var/best_score = -INFINITY

	for(var/direction in GLOB.cardinals)
		var/turf/destination = get_step(tied_human, direction)
		if(!destination || destination.density)
			continue

		var/score = get_dist(destination, threat_turf)
		if(score > best_score)
			best_score = score
			best_destination = destination

	if(!best_destination)
		return FALSE

	if(!brain.move_to_next_turf(best_destination))
		return FALSE

	tied_human.face_atom(threat)
	return TRUE
