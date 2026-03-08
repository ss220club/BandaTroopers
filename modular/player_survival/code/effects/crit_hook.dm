/datum/effects/crit/human/on_apply_effect()
	. = ..()
	var/mob/living/carbon/human/affected_human = affected_atom
	if(!istype(affected_human))
		return
	affected_human.player_survival_activate_crit_grace()

