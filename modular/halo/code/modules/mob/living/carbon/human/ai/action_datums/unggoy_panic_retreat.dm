/datum/ai_action/unggoy_panic_retreat
	name = "Паническое отступление унггоя"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/targeting, /datum/human_ai_module/navigation, /datum/human_ai_module/squad, /datum/human_ai_module/halo_covenant, /datum/human_ai_module/halo_unggoy)

/datum/ai_action/unggoy_panic_retreat/get_context_weight(datum/human_ai_context/context)
	return context?.brain?.halo_unggoy_get_panic_retreat_weight() || 0

/datum/ai_action/unggoy_panic_retreat/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	return context?.brain?.halo_unggoy_run_panic_retreat_step() || ONGOING_ACTION_COMPLETED
