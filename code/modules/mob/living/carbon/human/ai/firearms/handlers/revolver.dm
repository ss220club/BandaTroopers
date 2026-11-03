// Isolated Human AI firearm revolver handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/revolver
	gun_types = list(/obj/item/weapon/gun/revolver)

/datum/human_ai_firearm_handler/revolver/before_fire(datum/human_ai_firearm_context/context)
	. = ..()
	if(!.)
		return
	var/obj/item/weapon/gun/revolver/revolver = context.firearm
	if(revolver.current_mag?.chamber_closed == FALSE)
		context.controller.unload_weapon(revolver)

/datum/human_ai_firearm_handler/revolver/do_reload(datum/human_ai_firearm_context/context)
	if(can_use(context) && !context.reload_item)
		context.set_reload_item(find_reload_item(context))
	if(!can_use(context) || !context.mag)
		return FALSE
	var/obj/item/weapon/gun/revolver/revolver = context.firearm
	if(!context.prepare_primary_weapon())
		return FALSE
	context.unwield_weapon()
	if(!context.sleep_short() || !can_use(context))
		return FALSE
	if(revolver.current_mag?.chamber_closed)
		context.controller.unload_weapon(revolver)
	context.swap_hand()
	if(!context.sleep_micro() || !context.can_continue_reload() || !prepare_reload_item(context) || !context.can_continue_reload())
		return FALSE
	if(!context.sleep_short() || !context.can_continue_reload())
		return FALSE
	if(istype(context.mag, /obj/item/ammo_magazine/handful))
		var/obj/item/ammo_magazine/handful/handful = context.mag
		for(var/i in 1 to handful.current_rounds)
			if(!context.can_continue_reload(handful))
				return FALSE
			context.insert_ammo(handful)
			if(!context.sleep_micro())
				return FALSE
	else
		context.insert_ammo()
	if(!context.sleep_micro())
		return FALSE
	if(revolver.current_mag && !revolver.current_mag.chamber_closed)
		context.controller.unload_weapon(revolver)
	context.swap_hand()
	if(!context.wield_primary_sleep())
		return FALSE
	return TRUE
