// Isolated Human AI firearm mechanical cycling handlers proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/lever_action
	gun_types = list(/obj/item/weapon/gun/lever_action)

/datum/human_ai_firearm_handler/lever_action/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!. || context.firearm.in_chamber)
		return
	context.use_unique_action()

/datum/human_ai_firearm_handler/lever_action/after_fire(datum/human_ai_firearm_context/context)
	if(!can_use(context))
		return null
	var/obj/item/weapon/gun/lever_action/lever_action = context.firearm
	var/datum/human_ai_firearm_result/result = new()
	context.start_unique_action(lever_action.lever_delay)
	return result.stop_fire_for(max(lever_action.lever_delay, lever_action.get_fire_delay()) + 1)
