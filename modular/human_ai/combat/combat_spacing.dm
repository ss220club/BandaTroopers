/// Local combat spacing: never scan the map or move through scenery to form a line.
/datum/human_ai_brain
	COOLDOWN_DECLARE(combat_spacing_cooldown)

/datum/human_ai_brain/proc/combat_crowding(turf/position)
	var/penalty = 0
	for(var/mob/living/carbon/human/ally in range(1, position))
		if(ally == tied_human || ally.stat == DEAD || !faction_check(ally) || !ally.get_ai_brain())
			continue
		penalty += 2 - get_dist(position, ally)
	return penalty

/datum/ai_action/combat_spacing
	name = "Spread Out In Combat"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/combat_spacing/get_weight(datum/human_ai_brain/brain)
	if(!brain.setting("combat_spacing"))
		return 0
	if(!brain.current_target || !brain.in_combat || brain.has_live_grenade_emergency() || !COOLDOWN_FINISHED(brain, combat_spacing_cooldown))
		return 0
	return brain.combat_crowding(get_turf(brain.tied_human)) ? 20 : 0

/datum/ai_action/combat_spacing/trigger_action()
	. = ..()
	if(!get_weight(brain))
		return ONGOING_ACTION_COMPLETED
	var/turf/origin = get_turf(brain.tied_human)
	var/best_penalty = brain.combat_crowding(origin)
	var/turf/best_step
	for(var/turf/candidate as anything in origin.AdjacentTurfs())
		if(!brain.quick_order_step_within_boundary(candidate) || !brain.human_ai_turf_is_safe(candidate, TRUE, FALSE))
			continue
		var/penalty = brain.combat_crowding(candidate)
		if(penalty >= best_penalty)
			continue
		best_penalty = penalty
		best_step = candidate
	COOLDOWN_START(brain, combat_spacing_cooldown, 1 SECONDS)
	if(best_step)
		brain.end_cover()
		brain.move_to_next_turf(best_step)
	return ONGOING_ACTION_COMPLETED
