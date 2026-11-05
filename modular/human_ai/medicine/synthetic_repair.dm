/obj/item/stack/cable_coil/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BRUTE))
				continue

			return TRUE

	return FALSE

/obj/item/stack/cable_coil/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	user.a_intent_change(INTENT_HELP)

	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BRUTE))
				continue

			if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
				return

			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)

/obj/item/stack/nanopaste/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal)
				continue

			return TRUE

	return FALSE

/obj/item/stack/nanopaste/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal)
				continue

			if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
				return

			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)

/obj/item/tool/weldingtool/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target) || (get_fuel() <= 0))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BURN))
				continue

			return TRUE

	return FALSE

/obj/item/tool/weldingtool/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	user.a_intent_change(INTENT_HELP)
	if(!welding)
		toggle(FALSE)

	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BURN))
				continue

			if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
				return

			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult)

	if(welding)
		toggle(FALSE)
