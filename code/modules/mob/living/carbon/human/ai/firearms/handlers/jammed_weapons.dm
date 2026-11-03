// Isolated Human AI firearm jammed weapon handlers proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/jammed_smg
	gun_types = list()

/datum/human_ai_firearm_handler/jammed_smg/proc/try_clear_jam(datum/human_ai_firearm_context/context, jammed)
	if(!jammed)
		return FALSE
	if(!context.prepare_primary_weapon())
		return FALSE
	return context.use_unique_action()

/datum/human_ai_firearm_handler/jammed_smg/ppsh
	gun_types = list(/obj/item/weapon/gun/smg/ppsh)

/datum/human_ai_firearm_handler/jammed_smg/ppsh/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!.)
		return
	var/obj/item/weapon/gun/smg/ppsh/ppsh = context.firearm
	if(try_clear_jam(context, ppsh.jammed))
		return FALSE

/datum/human_ai_firearm_handler/jammed_smg/uzi
	gun_types = list(/obj/item/weapon/gun/smg/uzi)

/datum/human_ai_firearm_handler/jammed_smg/uzi/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!.)
		return
	var/obj/item/weapon/gun/smg/uzi/uzi = context.firearm
	if(try_clear_jam(context, uzi.jammed))
		return FALSE
