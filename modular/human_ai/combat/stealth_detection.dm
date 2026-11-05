
// SS220 EDIT - START: rear stealth and explicit aggression response for Human AI
/datum/human_ai_brain/proc/modular_setup_stealth_detection()
	if(!has_valid_tied_human())
		return

	RegisterSignal(tied_human, COMSIG_ATOM_BEFORE_HUMAN_ATTACK_HAND, PROC_REF(on_human_ai_unarmed_aggression))
	RegisterSignal(tied_human, COMSIG_ATOM_MOB_ATTACKBY, PROC_REF(on_human_ai_item_aggression))
	RegisterSignal(tied_human, COMSIG_HUMAN_XENO_ATTACK, PROC_REF(on_human_ai_xeno_aggression))

/// Initial visual acquisition ignores the three directions behind the NPC.
/// An already acquired target remains known if it later circles behind the NPC.
/datum/human_ai_brain/proc/human_ai_can_visually_detect_target(atom/movable/potential_target)
	if(!has_valid_tied_human() || !potential_target)
		return FALSE

	if(potential_target == current_target)
		return TRUE
	if(!setting("stealth_enabled"))
		return TRUE

	return !(get_dir(tied_human, potential_target) in reverse_nearby_direction(tied_human.dir))

/// Empty-hand harm and disarm are aggression. Yellow Grab intent deliberately stays silent.
/datum/human_ai_brain/proc/on_human_ai_unarmed_aggression(datum/source, mob/living/carbon/human/attacker, click_parameters)
	SIGNAL_HANDLER
	if(!attacker || !((attacker.a_intent == INTENT_HARM) || (attacker.a_intent == INTENT_DISARM)))
		return

	human_ai_alert_to_aggressor(attacker)
	return

/// Damaging item use is aggression, while abstract grabs and non-damaging interactions remain silent.
/datum/human_ai_brain/proc/on_human_ai_item_aggression(datum/source, obj/item/used_item, mob/living/attacker)
	SIGNAL_HANDLER
	if(!used_item || !attacker || istype(used_item, /obj/item/grab))
		return
	// preserve the built-in rear throat-slit flow while the victim is held on yellow Grab intent.
	if((attacker.a_intent == INTENT_GRAB) && (tied_human.pulledby == attacker))
		return
	if((used_item.flags_item & NOBLUDGEON) || (used_item.force <= 0))
		return

	human_ai_alert_to_aggressor(attacker)
	return

/// Xenomorph melee attacks already identify the attacker on the victim-side signal.
/datum/human_ai_brain/proc/on_human_ai_xeno_aggression(datum/source, list/slash_data, mob/living/carbon/xenomorph/attacker)
	SIGNAL_HANDLER
	human_ai_alert_to_aggressor(attacker)
	return

/// Makes a direct hostile action bypass visual facing without weakening faction checks.
/datum/human_ai_brain/proc/human_ai_alert_to_aggressor(mob/living/attacker)
	if(!has_valid_tied_human() || tied_human.client || !attacker || (attacker == tied_human) || (attacker.stat == DEAD))
		return FALSE

	if(attacker.faction in neutral_factions)
		on_neutral_faction_betray(attacker.faction)

	if(faction_check(attacker))
		return FALSE

	if(current_target != attacker)
		lose_target()
		set_target(attacker)

	cancel_treatment_for_combat()
	enter_combat()
	return TRUE
// SS220 EDIT - END
