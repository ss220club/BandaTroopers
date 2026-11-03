// Human AI melee weapon-use behavior.

/datum/human_ai_melee_handler
	parent_type = /datum/human_ai_weapon_handler

GLOBAL_DATUM_INIT(human_ai_melee_handler, /datum/human_ai_melee_handler, new)

/datum/human_ai_melee_handler/proc/can_attack(datum/human_ai_melee_context/context)
	return context?.is_adjacent_to_target()

/datum/human_ai_melee_handler/proc/attack(datum/human_ai_melee_context/context)
	if(!can_attack(context))
		return FALSE

	context.controller.set_combat_intent()
	context.unholster_any_weapon()
	INVOKE_ASYNC(context.controller, TYPE_PROC_REF(/datum/human_tied_controller, do_click), context.current_target, "", list())
	context.controller.face_atom(context.current_target)
	return TRUE
