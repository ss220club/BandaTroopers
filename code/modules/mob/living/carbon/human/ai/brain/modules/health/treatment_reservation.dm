// SS220 EDIT - START: one owner and one continuation predicate for the complete treatment operation
/datum/human_ai_module/health/proc/cancel_treatment()
	treatment_generation++
	healing_someone = FALSE
	release_treatment_reservation()

/datum/human_ai_module/health/proc/can_continue_treatment(mob/living/carbon/human/target, treatment_id = null)
	if(!isnull(treatment_id) && treatment_id != treatment_generation)
		return FALSE
	if(QDELETED(src) || !can_continue_health_work() || !can_treat_under_current_combat_pressure() || !target || QDELETED(target) || target.stat == DEAD)
		cancel_treatment()
		return FALSE
	return TRUE

/datum/human_ai_module/health/proc/get_treatment_check(mob/living/carbon/human/target)
	return CALLBACK(src, PROC_REF(can_continue_treatment), target, treatment_generation)

/datum/human_ai_module/health/proc/can_continue_self_treatment(datum/human_tied_controller/controller, treatment_id = null)
	if(!isnull(treatment_id) && treatment_id != treatment_generation)
		return FALSE
	if(QDELETED(src) || !can_continue_health_work() || (!can_treat_under_current_combat_pressure() && !can_continue_emergency_self_treatment(controller) && !can_tactical_self_treat(controller)) || !controller?.can_read_puppet() || controller.is_dead())
		cancel_treatment()
		return FALSE
	return TRUE

/datum/human_ai_module/health/proc/get_self_treatment_check(datum/human_tied_controller/controller)
	return CALLBACK(src, PROC_REF(can_continue_self_treatment), controller, treatment_generation)

/datum/human_ai_module/health/proc/try_reserve_treatment(mob/living/carbon/human/target)
	if(!target || !SShuman_ai?.try_reserve_treatment(target, brain))
		return FALSE
	current_treatment_target = target
	return TRUE

/datum/human_ai_module/health/proc/release_treatment_reservation()
	if(SShuman_ai && current_treatment_target)
		SShuman_ai.release_treatment_reservation(current_treatment_target, brain)
	current_treatment_target = null
// SS220 EDIT - END
