// Isolated Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/xm51
	gun_types = list(/obj/item/weapon/gun/rifle/xm51)

/datum/human_ai_firearm_handler/xm51/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!. || context.firearm.in_chamber)
		return
	context.use_unique_action()

/datum/human_ai_firearm_handler/xm51/after_fire(datum/human_ai_firearm_context/context)
	if(!can_use(context))
		return null
	var/obj/item/weapon/gun/rifle/xm51/xm51 = context.firearm
	var/datum/human_ai_firearm_result/result = new()
	context.start_unique_action(xm51.pump_delay)
	return result.stop_fire_for(max(xm51.pump_delay, xm51.get_fire_delay()) + 1)
