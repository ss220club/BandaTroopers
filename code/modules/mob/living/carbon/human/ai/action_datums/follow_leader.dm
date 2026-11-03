/datum/ai_action/follow_leader
	name = "Follow Leader"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/squad, /datum/human_ai_module/navigation, /datum/human_ai_module/combat)

/datum/ai_action/follow_leader/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	if(brain.is_in_cover())
		return 0

	if(brain.is_squad_leader())
		return 0

	if(brain.is_in_combat())
		return 0

	if(!brain.can_move_for_action())
		return 0

	if(brain.has_pickup_queue())
		return 0

	var/list/squad_members = brain.get_squad_members()
	if(!length(squad_members))
		return 0

	var/datum/human_ai_context/squad_leader_context = brain.get_squad_leader()?.create_context()
	var/datum/human_tied_controller/squad_leader_controller = squad_leader_context?.controller
	if(!squad_leader_controller?.has_valid_tied_human())
		qdel(squad_leader_context)
		return 0

	if(controller.get_distance_to_controller(squad_leader_controller) <= (1 + length(squad_members) / 2))
		qdel(squad_leader_context)
		return 0

	qdel(squad_leader_context)
	return 5

/datum/ai_action/follow_leader/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_follow_leader(controller)
