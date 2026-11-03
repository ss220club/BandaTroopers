/datum/ai_action/sangheili_sword_charge
	name = "Рывок сангхейли с мечом"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/melee, /datum/human_ai_module/halo_covenant, /datum/human_ai_module/halo_sangheili)

/datum/ai_action/sangheili_sword_charge/Added()
	context?.brain?.halo_sangheili_on_sword_charge_added()

/datum/ai_action/sangheili_sword_charge/get_context_weight(datum/human_ai_context/context)
	return context?.brain?.halo_sangheili_get_sword_charge_weight() || 0

/datum/ai_action/sangheili_sword_charge/Destroy(force, ...)
	context?.brain?.halo_sangheili_cleanup_sword_charge()
	return ..()

/datum/ai_action/sangheili_sword_charge/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	return context?.brain?.halo_sangheili_run_sword_charge_step() || ONGOING_ACTION_COMPLETED
