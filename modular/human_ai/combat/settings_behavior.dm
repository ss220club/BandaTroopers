/datum/human_ai_brain/proc/settings_needs_retreat()
	return has_valid_tied_human() && tied_human.health < tied_human.maxHealth * setting("retreat_health") / 100

/datum/human_ai_brain/proc/settings_engagement_range()
	if(!gun_data)
		return 1
	var/desired = gun_data.optimal_range
	if(settings_needs_retreat())
		return max(desired, view_distance)
	if(setting("tactical_distance") && ishuman(current_target))
		var/mob/living/carbon/human/enemy = current_target
		if(!istype(enemy.get_active_hand(), /obj/item/weapon/gun))
			desired = min(gun_data.maximum_range, desired + 2)
	return desired

/// Weapon quality with a bounded range bonus; a margin prevents repeated swapping.
/datum/human_ai_brain/proc/settings_weapon_score(obj/item/weapon/gun/weapon, datum/firearm_appraisal/appraisal)
	var/score = appraisal.get_primary_weight(tied_human)
	if(setting("switch_weapons") && current_target)
		var/distance = get_dist(tied_human, current_target)
		if(distance > appraisal.maximum_range)
			score -= 10
		else
			score += 3 - min(6, abs(distance - appraisal.optimal_range))
	return score

/// Unarmed and armed NPCs both retain a physical retreat when badly injured.
/datum/ai_action/critical_retreat
	name = "Retreat When Injured"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/critical_retreat/get_weight(datum/human_ai_brain/brain)
	if(!brain.current_target || !brain.settings_needs_retreat() || brain.in_cover || brain.has_live_grenade_emergency())
		return 0
	if(get_dist(brain.tied_human, brain.current_target) >= brain.view_distance)
		return 0
	return 30

/datum/ai_action/critical_retreat/trigger_action()
	. = ..()
	if(!get_weight(brain))
		return ONGOING_ACTION_COMPLETED
	var/away = get_dir(brain.current_target, brain.tied_human)
	var/distance = get_dist(brain.tied_human, brain.current_target)
	for(var/direction in list(away, turn(away, 45), turn(away, -45)))
		var/turf/candidate = get_step(brain.tied_human, direction)
		if(!candidate || get_dist(candidate, brain.current_target) <= distance || !brain.quick_order_step_within_boundary(candidate) || !brain.human_ai_turf_is_safe(candidate, TRUE, FALSE))
			continue
		if(brain.move_to_next_turf(candidate))
			return ONGOING_ACTION_UNFINISHED
	return ONGOING_ACTION_COMPLETED
