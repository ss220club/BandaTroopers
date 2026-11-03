// Isolated Human AI firearm handler proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_handler/shotgun_db
	gun_types = list(/obj/item/weapon/gun/shotgun/double)

/datum/human_ai_firearm_handler/shotgun_db/do_reload(datum/human_ai_firearm_context/context)
	if(can_use(context) && !context.reload_item)
		context.set_reload_item(find_reload_item(context))
	if(!can_use(context) || !context.mag)
		return FALSE
	if(!context.prepare_primary_weapon())
		return FALSE
	context.unwield_weapon()
	context.use_unique_action()
	context.swap_hand()
	if(!context.sleep_short() || !context.can_continue_reload() || !prepare_reload_item(context) || !context.can_continue_reload())
		return FALSE
	if(!context.sleep_short())
		return FALSE
	context.insert_ammo()
	if(!context.sleep_micro())
		return FALSE
	context.insert_ammo()
	if(!QDELETED(context.mag))
		var/storage_spot = context.storage_has_room(context.mag)
		if(storage_spot)
			if(!context.sleep_micro())
				return FALSE
			context.store_ammo_item(context.mag, storage_spot)
	if(!context.sleep_short())
		return FALSE
	context.swap_hand()
	context.use_unique_action()
	if(!context.wield_primary_sleep())
		return FALSE
	return TRUE
