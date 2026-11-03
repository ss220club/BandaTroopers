// Isolated Human AI firearm XM99 handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/xm99
	gun_types = list(/obj/item/weapon/gun/XM99)

/datum/human_ai_firearm_handler/xm99/do_reload(datum/human_ai_firearm_context/context)
	if(can_use(context) && !context.reload_item)
		context.set_reload_item(find_reload_item(context))
	if(!can_use(context) || !context.mag)
		return FALSE
	if(!context.prepare_primary_weapon())
		return FALSE
	context.unwield_weapon()
	if(!context.sleep_short() || !can_use(context))
		return FALSE
	if(context.firearm.current_mag)
		context.unload_for_reload()
	context.swap_hand()
	if(!context.sleep_micro() || !can_use(context) || QDELETED(context.mag))
		return FALSE
	context.equip_reload_item(HUMAN_AI_AMMUNITION)
	if(!context.sleep_short())
		return FALSE
	context.insert_ammo()
	if(!context.sleep_short())
		return FALSE
	context.swap_hand()
	if(!context.wield_primary_sleep())
		return FALSE
	return TRUE
