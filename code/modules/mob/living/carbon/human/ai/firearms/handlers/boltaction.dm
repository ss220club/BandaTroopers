// Isolated Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/boltaction
	gun_types = list(/obj/item/weapon/gun/boltaction)

/datum/human_ai_firearm_handler/boltaction/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!. || context.firearm.in_chamber)
		return
	var/obj/item/weapon/gun/boltaction/boltaction = context.firearm
	context.use_unique_action()
	boltaction.recent_cycle = world.time - boltaction.bolt_delay
	context.use_unique_action()
	boltaction.recent_cycle = world.time - boltaction.bolt_delay

/datum/human_ai_firearm_handler/boltaction/after_fire(datum/human_ai_firearm_context/context)
	if(!can_use(context))
		return null
	var/obj/item/weapon/gun/boltaction/boltaction = context.firearm
	var/datum/human_ai_firearm_result/result = new()
	context.start_unique_action(1)
	context.start_unique_action(boltaction.bolt_delay + 1)
	return result.stop_fire_for(max(boltaction.bolt_delay * 2, boltaction.get_fire_delay()) + 1)
