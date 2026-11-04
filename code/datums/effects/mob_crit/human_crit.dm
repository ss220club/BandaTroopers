/datum/effects/crit/human/process_mob()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/affected_mob = affected_atom
	if(affected_mob.health > HEALTH_THRESHOLD_CRIT)
		qdel(src)
		return FALSE
	// Conscious but down: players can crawl and slowly use things, AI lies stunned
	if((affected_mob.status_flags & CANKNOCKOUT) && (affected_mob.mob_flags & AI_CONTROLLED))
		affected_mob.KnockDown(3)
		affected_mob.Stun(3)
		REMOVE_TRAIT(affected_mob, TRAIT_WOUNDED_DOWN, CRIT_TRAIT)
	else if((affected_mob.status_flags & CANKNOCKOUT))
		ADD_TRAIT(affected_mob, TRAIT_WOUNDED_DOWN, CRIT_TRAIT)
	else
		REMOVE_TRAIT(affected_mob, TRAIT_WOUNDED_DOWN, CRIT_TRAIT)
	if(!affected_mob.reagents || !affected_mob.reagents.has_reagent("inaprovaline"))
		affected_mob.apply_damage(1, OXY)

	return TRUE

/datum/effects/crit/human/Destroy()
	if(affected_atom)
		REMOVE_TRAIT(affected_atom, TRAIT_WOUNDED_DOWN, CRIT_TRAIT)
	return ..()
