// Isolated Human AI firearm linked-pack handlers proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/souto
	gun_types = list(/obj/item/weapon/gun/souto)

/datum/human_ai_firearm_handler/souto/can_select(datum/human_ai_firearm_context/context)
	return FALSE

/datum/human_ai_firearm_handler/souto/can_use(datum/human_ai_firearm_context/context)
	return FALSE

/datum/human_ai_firearm_handler/souto/do_reload(datum/human_ai_firearm_context/context)
	return FALSE

/datum/human_ai_firearm_handler/flamer/m240t
	gun_types = list(/obj/item/weapon/gun/flamer/M240T)

/datum/human_ai_firearm_handler/flamer/m240t/do_reload(datum/human_ai_firearm_context/context)
	if(!can_use(context))
		return FALSE
	var/obj/item/weapon/gun/flamer/M240T/m240t = context.firearm
	if(m240t.fuelpack)
		return FALSE
	return ..()
