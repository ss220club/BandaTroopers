/// Scheduler gates affect new and uncommitted actions, never a primed grenade in flight.
/datum/human_ai_brain/proc/settings_allow_action(datum/ai_action/action)
	if(action_is_committed(action))
		return TRUE
	if(istype(action, /datum/ai_action/throw_grenade))
		return setting("grenades")
	if(istype(action, /datum/ai_action/fire_underbarrel_grenade))
		return setting("underbarrel")
	if(istype(action, /datum/ai_action/throw_back_nade))
		// This action also handles escape. Only its manipulation branch is configurable.
		return TRUE
	if(istype(action, /datum/ai_action/take_cover))
		return setting("cover")
	if(istype(action, /datum/ai_action/item_pickup))
		return setting("pickup")
	if(istype(action, /datum/ai_action/chase_target))
		return setting("pursuit_enabled") && setting("chase_time") > 0
	return TRUE

/datum/human_ai_brain/proc/settings_allow_treatment(mob/living/carbon/human/patient)
	if(QDELETED(patient) || patient.stat == DEAD || !setting("medicine"))
		return FALSE
	if(setting("heal_out_of_combat") && in_combat)
		return FALSE
	if(issynth(patient))
		return setting(patient == tied_human ? "repair_self" : "repair_allies")
	if(patient == tied_human)
		return setting("self_heal")
	return setting(patient.client ? "heal_players" : "heal_npcs")

/// Called once per projectile; never alters the weapon or shared appraisal data.
/mob/proc/human_ai_accuracy_multiplier()
	if(client)
		return 1
	var/datum/component/human_ai/component = GetComponent(/datum/component/human_ai)
	return component?.ai_brain ? component.ai_brain.setting("accuracy") : 1

/// Applied to the local firing angle, never to the weapon's shared stats.
/mob/proc/human_ai_scatter_multiplier()
	if(client)
		return 1
	var/datum/component/human_ai/component = GetComponent(/datum/component/human_ai)
	return component?.ai_brain ? component.ai_brain.setting("scatter") : 1

/// Keep the species datum untouched: it is not an NPC-specific health profile.
/mob/living/carbon/human
	var/human_ai_health_percent = 100

/mob/living/carbon/human/proc/human_ai_health_capacity()
	var/base_health = species ? species.total_health : 200
	return base_health * human_ai_health_percent / 100
