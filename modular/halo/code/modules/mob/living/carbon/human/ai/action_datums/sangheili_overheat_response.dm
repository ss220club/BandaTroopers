/datum/ai_action/sangheili_overheat_response
	name = "Реакция сангхейли на перегрев"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/melee, /datum/human_ai_module/halo_covenant, /datum/human_ai_module/halo_sangheili)

/datum/ai_action/sangheili_overheat_response/Added()
	context?.brain?.halo_sangheili_on_unarmed_action_added()

/datum/ai_action/sangheili_overheat_response/get_context_weight(datum/human_ai_context/context)
	return context?.brain?.halo_sangheili_get_overheat_response_weight() || 0

/datum/ai_action/sangheili_overheat_response/Destroy(force, ...)
	context?.brain?.halo_sangheili_cleanup_unarmed_action()
	return ..()

/datum/ai_action/sangheili_overheat_response/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	return context?.brain?.halo_sangheili_run_overheat_response_step() || ONGOING_ACTION_COMPLETED
