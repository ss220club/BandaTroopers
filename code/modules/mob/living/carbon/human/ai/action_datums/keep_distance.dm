/datum/ai_action/keep_distance
	name = "Keep Distance"
	action_flags = ACTION_USING_LEGS
	required_ai_modules = list(/datum/human_ai_module/targeting, /datum/human_ai_module/navigation, /datum/human_ai_module/inventory, /datum/human_ai_module/guns)

/datum/ai_action/keep_distance/get_context_weight(datum/human_ai_context/context)
	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return 0

	var/atom/movable/current_target = brain.get_current_target()
	if(!current_target)
		return 0

	if(!brain.has_primary_weapon() || brain.has_tried_reload() || !brain.can_move_for_action())
		return 0

	if(brain.has_active_grenade())
		return 0

	if(brain.should_block_movement_for_pending_cover())
		return 0

	var/distance = controller.get_distance_to(current_target)
	var/datum/human_ai_firearm_profile/gun_data = brain.get_gun_data()

	if(ismob(current_target) && current_target?:is_mob_incapacitated())
		if(distance != gun_data.minimum_range)
			return 10

	else if(brain.is_in_cover())
		if(!brain.can_use_ranged_fire_line(controller, current_target, gun_data))
			return 10
		if(distance < gun_data.minimum_range)
			return 10

	else if(distance != gun_data.optimal_range)
		return 10

	return 0

/datum/ai_action/keep_distance/trigger_action()
	. = ..()
	if(. == ONGOING_ACTION_COMPLETED)
		return .

	var/datum/human_ai_brain/brain = context?.brain
	var/datum/human_tied_controller/controller = context?.controller
	if(!brain || !controller)
		return ONGOING_ACTION_COMPLETED

	return brain.perform_keep_distance(controller)
