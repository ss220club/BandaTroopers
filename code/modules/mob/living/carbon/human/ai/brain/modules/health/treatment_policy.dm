/datum/human_ai_module/health
	var/static/list/brute_critical_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/emergency,
		/obj/item/reagent_container/hypospray/autoinjector/meralyne,
		/obj/item/reagent_container/hypospray/autoinjector/bicaridine,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/storage/pill_bottle/merabica,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/stack/nanopaste,
		/obj/item/tool/weldingtool,
	)
	var/static/list/brute_combat_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/meralyne,
		/obj/item/reagent_container/hypospray/autoinjector/bicaridine,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/storage/pill_bottle/merabica,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/stack/nanopaste,
		/obj/item/tool/weldingtool,
	)
	var/static/list/brute_severe_noncombat_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/storage/pill_bottle/merabica,
		/obj/item/reagent_container/hypospray/autoinjector/meralyne,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/reagent_container/hypospray/autoinjector/bicaridine,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/stack/nanopaste,
		/obj/item/tool/weldingtool,
	)
	var/static/list/brute_stable_noncombat_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/storage/pill_bottle/merabica,
		/obj/item/reagent_container/hypospray/autoinjector/bicaridine,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/meralyne,
		/obj/item/stack/nanopaste,
		/obj/item/tool/weldingtool,
	)

	var/static/list/burn_critical_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/emergency,
		/obj/item/reagent_container/hypospray/autoinjector/dermaline,
		/obj/item/reagent_container/hypospray/autoinjector/kelotane,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/keloderm,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/stack/nanopaste,
		/obj/item/stack/cable_coil,
	)
	var/static/list/burn_combat_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/dermaline,
		/obj/item/reagent_container/hypospray/autoinjector/kelotane,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/keloderm,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/stack/nanopaste,
		/obj/item/stack/cable_coil,
	)
	var/static/list/burn_severe_noncombat_items = list(
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/keloderm,
		/obj/item/reagent_container/hypospray/autoinjector/dermaline,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/reagent_container/hypospray/autoinjector/kelotane,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/stack/nanopaste,
		/obj/item/stack/cable_coil,
	)
	var/static/list/burn_stable_noncombat_items = list(
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/storage/pill_bottle/keloderm,
		/obj/item/reagent_container/hypospray/autoinjector/kelotane,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/dermaline,
		/obj/item/stack/nanopaste,
		/obj/item/stack/cable_coil,
	)

	var/static/list/tox_critical_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/antitoxin,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/antitox,
		/obj/item/storage/pill_bottle/tricord,
	)
	var/static/list/tox_combat_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/antitoxin,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/antitox,
		/obj/item/storage/pill_bottle/tricord,
	)
	var/static/list/tox_noncombat_items = list(
		/obj/item/storage/pill_bottle/antitox,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/antitoxin,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
	)

	var/static/list/oxy_critical_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/dexalinp,
		/obj/item/storage/pill_bottle/dexalinplus,
		/obj/item/storage/pill_bottle/dexalin,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/tricord,
	)
	var/static/list/oxy_combat_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/dexalinp,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
		/obj/item/storage/pill_bottle/dexalinplus,
		/obj/item/storage/pill_bottle/dexalin,
		/obj/item/storage/pill_bottle/tricord,
	)
	var/static/list/oxy_noncombat_items = list(
		/obj/item/storage/pill_bottle/dexalinplus,
		/obj/item/storage/pill_bottle/dexalin,
		/obj/item/storage/pill_bottle/tricord,
		/obj/item/reagent_container/hypospray/autoinjector/dexalinp,
		/obj/item/reagent_container/hypospray/autoinjector/tricord,
	)

	var/static/list/bleed_urgent_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
	)
	var/static/list/bleed_stable_noncombat_items = list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/advanced/bruise_pack,
	)
	var/static/list/bonebreak_items = list(/obj/item/stack/medical/splint)
	var/static/list/pain_critical_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/oxycodone,
		/obj/item/reagent_container/hypospray/autoinjector/tramadol,
		/obj/item/storage/pill_bottle/tramadol,
	)
	var/static/list/pain_combat_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/oxycodone,
		/obj/item/reagent_container/hypospray/autoinjector/tramadol,
		/obj/item/storage/pill_bottle/tramadol,
	)
	var/static/list/pain_noncombat_items = list(
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/reagent_container/hypospray/autoinjector/tramadol,
		/obj/item/reagent_container/hypospray/autoinjector/oxycodone,
	)

/datum/human_ai_module/health/proc/get_treatment_urgency(mob/living/carbon/human/target)
	if(!target || !target.maxHealth)
		return HUMAN_AI_TREATMENT_URGENCY_STABLE
	if(target.health <= HEALTH_THRESHOLD_CRIT)
		return HUMAN_AI_TREATMENT_URGENCY_CRITICAL

	var/health_ratio = target.health / target.maxHealth
	if(health_ratio <= 0.25)
		return HUMAN_AI_TREATMENT_URGENCY_CRITICAL
	if(health_ratio <= 0.5)
		return HUMAN_AI_TREATMENT_URGENCY_SEVERE
	return HUMAN_AI_TREATMENT_URGENCY_STABLE

/datum/human_ai_module/health/proc/has_treatment_problem(mob/living/carbon/human/target, treatment_stage)
	if(!target)
		return FALSE

	switch(treatment_stage)
		if(HUMAN_AI_TREATMENT_STAGE_BRUTE)
			return target.getBruteLoss() > damage_problem_threshold
		if(HUMAN_AI_TREATMENT_STAGE_BLEED)
			return target.is_bleeding()
		if(HUMAN_AI_TREATMENT_STAGE_BONEBREAK)
			return target.has_broken_limbs()
		if(HUMAN_AI_TREATMENT_STAGE_BURN)
			return target.getFireLoss() > damage_problem_threshold
		if(HUMAN_AI_TREATMENT_STAGE_PAIN)
			return target.pain.get_pain_percentage() > pain_percentage_threshold
		if(HUMAN_AI_TREATMENT_STAGE_TOX)
			return target.getToxLoss() > damage_problem_threshold
		if(HUMAN_AI_TREATMENT_STAGE_OXY)
			return target.getOxyLoss() > damage_problem_threshold

	return FALSE

/datum/human_ai_module/health/proc/get_treatment_item_types(mob/living/carbon/human/target, treatment_stage)
	var/urgency = get_treatment_urgency(target)
	var/in_combat = is_owner_in_combat()

	switch(treatment_stage)
		if(HUMAN_AI_TREATMENT_STAGE_BRUTE)
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_CRITICAL)
				return brute_critical_items
			if(in_combat)
				return brute_combat_items
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_SEVERE)
				return brute_severe_noncombat_items
			return brute_stable_noncombat_items
		if(HUMAN_AI_TREATMENT_STAGE_BLEED)
			if(in_combat || urgency != HUMAN_AI_TREATMENT_URGENCY_STABLE)
				return bleed_urgent_items
			return bleed_stable_noncombat_items
		if(HUMAN_AI_TREATMENT_STAGE_BONEBREAK)
			return bonebreak_items
		if(HUMAN_AI_TREATMENT_STAGE_BURN)
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_CRITICAL)
				return burn_critical_items
			if(in_combat)
				return burn_combat_items
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_SEVERE)
				return burn_severe_noncombat_items
			return burn_stable_noncombat_items
		if(HUMAN_AI_TREATMENT_STAGE_PAIN)
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_CRITICAL)
				return pain_critical_items
			if(in_combat)
				return pain_combat_items
			return pain_noncombat_items
		if(HUMAN_AI_TREATMENT_STAGE_TOX)
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_CRITICAL)
				return tox_critical_items
			if(in_combat)
				return tox_combat_items
			return tox_noncombat_items
		if(HUMAN_AI_TREATMENT_STAGE_OXY)
			if(urgency == HUMAN_AI_TREATMENT_URGENCY_CRITICAL)
				return oxy_critical_items
			if(in_combat)
				return oxy_combat_items
			return oxy_noncombat_items

	return null

/datum/human_ai_module/health/proc/get_recent_treatment_key(mob/living/carbon/human/target, treatment_stage)
	if(!target || !treatment_stage)
		return null
	return "[REF(target)]-[treatment_stage]"

/datum/human_ai_module/health/proc/has_recent_treatment_for_stage(mob/living/carbon/human/target, treatment_stage)
	var/key = get_recent_treatment_key(target, treatment_stage)
	if(!key)
		return FALSE

	var/expire_time = recent_patient_treatments[key]
	if(!expire_time)
		return FALSE

	if(expire_time <= world.time)
		recent_patient_treatments -= key
		return FALSE

	return TRUE

/datum/human_ai_module/health/proc/get_treatment_effect_wait(obj/item/item)
	if(istype(item, /obj/item/storage/pill_bottle))
		return pill_treatment_effect_wait
	if(istype(item, /obj/item/reagent_container))
		return injected_treatment_effect_wait
	return 0

/datum/human_ai_module/health/proc/record_recent_treatment(mob/living/carbon/human/target, treatment_stage, obj/item/item)
	var/effect_wait = get_treatment_effect_wait(item)
	if(effect_wait <= 0)
		return

	var/key = get_recent_treatment_key(target, treatment_stage)
	if(!key)
		return

	recent_patient_treatments[key] = world.time + effect_wait

/datum/human_ai_module/health/proc/has_applicable_treatment_for(mob/living/carbon/human/target)
	if(!target)
		return FALSE

	for(var/stage in HUMAN_AI_TREATMENT_STAGE_BRUTE to HUMAN_AI_TREATMENT_STAGE_OXY)
		if(has_recent_treatment_for_stage(target, stage))
			continue
		if(!has_treatment_problem(target, stage))
			continue
		var/list/item_types = get_treatment_item_types(target, stage)
		if(item_types && find_owner_usable_treatment_item(item_types, target))
			return TRUE

	return FALSE

#undef HUMAN_AI_TREATMENT_STAGE_BRUTE
#undef HUMAN_AI_TREATMENT_STAGE_BLEED
#undef HUMAN_AI_TREATMENT_STAGE_BONEBREAK
#undef HUMAN_AI_TREATMENT_STAGE_BURN
#undef HUMAN_AI_TREATMENT_STAGE_PAIN
#undef HUMAN_AI_TREATMENT_STAGE_TOX
#undef HUMAN_AI_TREATMENT_STAGE_OXY

#undef HUMAN_AI_TREATMENT_URGENCY_STABLE
#undef HUMAN_AI_TREATMENT_URGENCY_SEVERE
#undef HUMAN_AI_TREATMENT_URGENCY_CRITICAL
