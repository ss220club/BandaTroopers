// Isolated Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/shotgun
	gun_types = list(/obj/item/weapon/gun/shotgun)

/datum/human_ai_firearm_handler/shotgun/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!. || context.firearm.in_chamber)
		return
	context.use_unique_action()

/datum/human_ai_firearm_handler/shotgun/after_fire(datum/human_ai_firearm_context/context)
	if(!can_use(context))
		return null
	var/datum/human_ai_firearm_result/result = new()
	if(istype(context.firearm, /obj/item/weapon/gun/shotgun/pump))
		var/obj/item/weapon/gun/shotgun/pump/pump_shotgun = context.firearm
		context.start_unique_action(pump_shotgun.pump_delay)
		return result.stop_fire_for(max(pump_shotgun.pump_delay, pump_shotgun.get_fire_delay()) + 1)
	context.start_fire(context.firearm.get_fire_delay()*3)
	return result.stop_fire_for(context.firearm.get_fire_delay() + 3)
