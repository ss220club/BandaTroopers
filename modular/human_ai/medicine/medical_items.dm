/obj/item/storage/pill_bottle/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(issynth(target))
		return FALSE

	if(!length(contents) || !COOLDOWN_FINISHED(ai_brain, pill_use_cooldown))
		return FALSE

	var/obj/item/reagent_container/pill/pill = contents[1]
	if(!ai_brain.can_safely_administer_reagents(pill, target, pill.reagents.total_volume)) // SS220 EDIT: validate every reagent in mixed pills against patient levels
		return FALSE

	if(skilllock && !skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		return FALSE

	return TRUE

/obj/item/storage/pill_bottle/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	if(!ai_can_use(user, ai_brain, target)) // SS220 EDIT: another medic may have dosed the patient since selection
		return FALSE
	var/used_pill = FALSE
	var/obj/item/pill = contents[1]
	user.swap_hand()
	if(user.put_in_active_hand(pill))
		remove_from_storage(pill, user)
		if(!pill.attack(target, user)) // SS220 EDIT: late OD rejection must return the unused pill instead of losing it
			attempt_item_insertion(pill, FALSE, user)
		else
			used_pill = TRUE
			COOLDOWN_START(ai_brain, pill_use_cooldown, 5 SECONDS)
			sleep(ai_brain.medium_action_delay * ai_brain.action_delay_mult)

	if(QDELETED(ai_brain) || !ai_brain.has_valid_tied_human())
		return used_pill
	ai_brain.appraise_inventory() // For some reason it removes pill bottles from equipment_map after usage
	return used_pill

/obj/item/stack/medical/bruise_pack/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
			return

		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay)

/obj/item/stack/medical/bruise_pack/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target)
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			return TRUE
	return FALSE

/obj/item/stack/medical/advanced/bruise_pack/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			return TRUE

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BURN)
				continue

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				return TRUE
	return FALSE

/obj/item/stack/medical/advanced/bruise_pack/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
			return

		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay)
			continue

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BURN)
				continue

			if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
				return

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				user.zone_selected = limb.name
				attack(target, user)
				sleep(ai_brain.short_action_delay)

/obj/item/stack/medical/advanced/ointment/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BRUTE)
				continue

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				return TRUE
	return FALSE

/obj/item/stack/medical/advanced/ointment/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || wound.damage_type == BRUTE)
				continue

			if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
				return

			if(!(wound.bandaged & (WOUND_BANDAGED|WOUND_SUTURED)))
				user.zone_selected = limb.name
				attack(target, user)
				sleep(ai_brain.short_action_delay)

/obj/item/stack/medical/splint/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src) || QDELETED(ai_brain) || !ai_brain.treatment_can_continue(treatment_id, target))
			return

		if(limb.is_broken() && !(limb.status & LIMB_SPLINTED)) // SS220 EDIT: skip fractures already stabilized by a splint
			user.zone_selected = limb.name
			attack(target, user)
			sleep(ai_brain.short_action_delay)
			continue

/obj/item/stack/medical/splint/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target)
		return FALSE
	for(var/obj/limb/limb as anything in target.limbs)
		if((limb.status & LIMB_BROKEN) && !(limb.status & LIMB_SPLINTED))
			return TRUE
	return FALSE

/obj/item/reagent_container/hypospray/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	return target && reagents?.total_volume && target.can_inject(user, TRUE) && ai_brain?.can_safely_administer_reagents(src, target, amount_per_transfer_from_this) // SS220 EDIT: prevent AI-administered OD

/obj/item/reagent_container/hypospray/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/treatment_id = ai_brain.treatment_generation
	if(!ai_brain.treatment_can_continue(treatment_id, target))
		return FALSE
	if(!ai_can_use(user, ai_brain, target)) // SS220 EDIT: recheck after async treatment delay and other medics' doses
		return FALSE
	return attack(target, user)
