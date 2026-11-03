/datum/human_ai_module/health/proc/start_healing(mob/living/carbon/human/target)
	set waitfor = FALSE
	if(!can_continue_treatment(target) || healing_someone)
		return FALSE
	if(!try_reserve_treatment(target))
		return FALSE

	var/treatment_id = ++treatment_generation
	var/datum/callback/treatment_check = get_treatment_check(target)
	healing_someone = TRUE
	. = FALSE
	// Keep treatment priority explicit; re-evaluate damage after each preceding treatment.
	for(var/stage in HUMAN_AI_TREATMENT_STAGE_BRUTE to HUMAN_AI_TREATMENT_STAGE_OXY)
		if(!treatment_check.Invoke())
			break
		if(has_recent_treatment_for_stage(target, stage))
			continue
		if(!has_treatment_problem(target, stage))
			continue
		var/list/item_types = get_treatment_item_types(target, stage)
		if(item_types && use_treatment_item(target, item_types, treatment_check, stage))
			. = TRUE

	if(treatment_id == treatment_generation)
		healing_someone = FALSE
		release_treatment_reservation()
	qdel(treatment_check)

/datum/human_ai_module/health/proc/start_healing_controller(datum/human_tied_controller/controller)
	set waitfor = FALSE
	if(!can_continue_self_treatment(controller) || healing_someone)
		return FALSE
	var/mob/living/carbon/human/self_target = controller.get_self_target()
	if(!self_target || !try_reserve_treatment(self_target))
		return FALSE

	var/treatment_id = ++treatment_generation
	var/datum/callback/treatment_check = get_self_treatment_check(controller)
	healing_someone = TRUE
	. = FALSE
	// Keep self-treatment priority aligned with normal treatment.
	for(var/stage in HUMAN_AI_TREATMENT_STAGE_BRUTE to HUMAN_AI_TREATMENT_STAGE_OXY)
		if(!treatment_check.Invoke())
			break
		if(has_recent_treatment_for_stage(self_target, stage))
			continue
		if(!has_treatment_problem(self_target, stage))
			continue
		var/list/item_types = get_treatment_item_types(self_target, stage)
		if(item_types && use_self_treatment_item(controller, item_types, treatment_check, stage))
			. = TRUE

	if(treatment_id == treatment_generation)
		healing_someone = FALSE
		release_treatment_reservation()
	qdel(treatment_check)

/datum/human_ai_module/health/proc/use_treatment_item(mob/living/carbon/human/target, list/item_types, datum/callback/treatment_check, treatment_stage)
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller)
		return FALSE

	var/obj/item/item = find_owner_usable_treatment_item(item_types, target)
	if(!item)
		return FALSE
	clear_owner_main_hand()
	if(!equip_owner_treatment_item(item))
		return FALSE

	sleep(get_owner_action_delay())
	if(!can_continue_health_work())
		return FALSE
	if(!treatment_check.Invoke() || QDELETED(item))
		return FALSE
	controller.ai_use(item, target)
	record_recent_treatment(target, treatment_stage, item)
	if(!treatment_check.Invoke() || QDELETED(item))
		return TRUE

	var/storage_slot = get_owner_storage_slot_for_item(item)
	if(storage_slot)
		store_owner_treatment_item(item, storage_slot)
	else
		controller.drop_held_item(item)
	return TRUE

/datum/human_ai_module/health/proc/use_self_treatment_item(datum/human_tied_controller/controller, list/item_types, datum/callback/treatment_check, treatment_stage)
	if(!controller)
		return FALSE

	var/mob/living/carbon/human/self_target = controller.get_self_target()
	if(!self_target)
		return FALSE
	var/obj/item/item = find_owner_usable_treatment_item(item_types, self_target)
	if(!item)
		return FALSE
	clear_owner_main_hand()
	if(!equip_owner_treatment_item(item))
		return FALSE

	sleep(get_owner_action_delay())
	if(!can_continue_health_work())
		return FALSE
	if(!treatment_check.Invoke() || QDELETED(item))
		return FALSE
	controller.ai_use(item, self_target)
	record_recent_treatment(self_target, treatment_stage, item)
	if(!treatment_check.Invoke() || QDELETED(item))
		return TRUE

	var/storage_slot = get_owner_storage_slot_for_item(item)
	if(storage_slot)
		store_owner_treatment_item(item, storage_slot)
	else
		controller.drop_held_item(item)
	return TRUE
