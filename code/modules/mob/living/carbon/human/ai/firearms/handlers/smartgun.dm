// Isolated Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/smartgun
	gun_types = list(
		/obj/item/weapon/gun/smartgun,
		/obj/item/weapon/gun/pkp,
	)

/datum/human_ai_firearm_handler/smartgun/do_reload(datum/human_ai_firearm_context/context)
	if(can_use(context) && !context.reload_item)
		context.set_reload_item(find_reload_item(context))
	if(!can_use(context) || !context.mag)
		return FALSE
	if(!context.prepare_primary_weapon())
		return FALSE
	context.unwield_weapon()
	context.swap_hand()
	context.alt_click_item()
	if(!context.sleep_short())
		return FALSE
	context.swap_hand()
	if(context.firearm.current_mag)
		context.unload_for_reload()
	context.swap_hand()
	if(!context.sleep_micro())
		return FALSE
	context.equip_reload_item(HUMAN_AI_AMMUNITION)
	if(!context.sleep_short())
		return FALSE
	context.insert_ammo()
	if(!context.sleep_short())
		return FALSE
	context.alt_click_item()
	if(!context.sleep_short())
		return FALSE
	context.swap_hand()
	if(!context.wield_primary_sleep())
		return FALSE
	return TRUE
