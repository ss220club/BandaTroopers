/// Moves an idle Human AI to an injured friendly and delegates treatment to the shared health engine.
/datum/ai_action/treat_ally
	name = "Treat Ally"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	var/treatment_started = FALSE

/datum/ai_action/treat_ally/get_weight(datum/human_ai_brain/brain)
	// SS220 EDIT - START: use the same medical-priority gate that preempts routine movement and looting
	if(!brain.get_priority_ally_treatment_target())
		return 0
	// SS220 EDIT - END

	// SS220 EDIT: medical emergencies outrank routine pickup, reload, and navigation actions.
	return 20

/datum/ai_action/treat_ally/Destroy(force, ...)
	if(brain)
		brain.lose_injured_ally()
	return ..()

/datum/ai_action/treat_ally/trigger_action()
	. = ..()

	if(brain.healing_someone)
		return ONGOING_ACTION_UNFINISHED

	if(treatment_started)
		treatment_started = FALSE
		if(!brain.can_treat_ally(brain.found_injured_ally))
			brain.lose_injured_ally()
			return ONGOING_ACTION_COMPLETED

	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	if(brain.current_target || should_fire_offscreen || !length(brain.equipment_map[HUMAN_AI_HEALTHITEMS]))
		brain.lose_injured_ally()
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/injured_ally = brain.found_injured_ally
	if(!brain.can_treat_ally(injured_ally))
		brain.lose_injured_ally()
		injured_ally = brain.get_injured_ally()
		if(!injured_ally)
			return ONGOING_ACTION_COMPLETED
		brain.set_injured_ally(injured_ally)

	if(get_dist(brain.tied_human, injured_ally) > 1)
		// SS220 EDIT - START: move beside the patient; their occupied turf is not a valid pathfinding destination
		var/turf/approach_turf = brain.get_ally_treatment_approach_turf(injured_ally)
		if(!approach_turf || !brain.move_to_next_turf(approach_turf))
			brain.lose_injured_ally()
			return ONGOING_ACTION_COMPLETED
		// SS220 EDIT - END
		return ONGOING_ACTION_UNFINISHED

	treatment_started = TRUE
	brain.start_healing(injured_ally)
	return ONGOING_ACTION_UNFINISHED
