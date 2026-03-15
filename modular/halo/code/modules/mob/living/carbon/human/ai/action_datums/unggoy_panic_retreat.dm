/datum/ai_action/unggoy_panic_retreat
	name = "Unggoy Panic Retreat"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/unggoy_panic_retreat/get_weight(datum/human_ai_brain/brain)
	if(!brain.halo_unggoy_runtime)
		return 0

	if(!brain.in_combat || brain.hold_position)
		return 0

	if(!brain.halo_unggoy_should_retreat())
		return 0

	if(!brain.halo_covenant_get_threat_atom())
		return 0

	return 25

/datum/ai_action/unggoy_panic_retreat/trigger_action()
	. = ..()

	if(!brain || !brain.halo_unggoy_runtime || !brain.in_combat || !brain.halo_unggoy_should_retreat())
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/atom/threat = brain.halo_covenant_get_threat_atom()
	if(!tied_human || !threat)
		return ONGOING_ACTION_COMPLETED

	if(brain.halo_unggoy_should_use_cover_retreat() && try_cover_retreat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(!brain.halo_unggoy_should_use_cover_retreat() && brain.current_cover)
		brain.end_cover()

	if(step_away_from_threat(threat))
		return ONGOING_ACTION_UNFINISHED_BLOCK

	return ONGOING_ACTION_COMPLETED

/datum/ai_action/unggoy_panic_retreat/proc/try_cover_retreat(atom/threat)
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

/datum/ai_action/unggoy_panic_retreat/proc/step_away_from_threat(atom/threat)
	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/turf/threat_turf = brain.halo_covenant_get_cached_threat_turf()
	if(!tied_human || !threat_turf)
		return FALSE

	var/keep_anchor = !brain.halo_unggoy_should_flee_on_overheat()
	var/turf/anchor = keep_anchor ? brain.halo_unggoy_get_squad_anchor() : null
	var/turf/best_destination
	var/best_score = -INFINITY

	for(var/direction in GLOB.cardinals)
		var/turf/destination = get_step(tied_human, direction)
		if(!destination || destination.density)
			continue

		var/score = get_dist(destination, threat_turf) * 3
		if(anchor)
			score -= get_dist(destination, anchor)

		if(score > best_score)
			best_score = score
			best_destination = destination

	if(!best_destination && anchor && (get_dist(anchor, tied_human) > 0))
		best_destination = anchor

	if(!best_destination)
		return FALSE

	if(!brain.move_to_next_turf(best_destination))
		return FALSE

	tied_human.face_atom(threat)
	return TRUE
