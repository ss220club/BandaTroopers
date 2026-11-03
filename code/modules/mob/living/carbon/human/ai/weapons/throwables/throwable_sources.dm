// Human AI throwable source selection and unpacking.

/datum/human_ai_throwable_handler/proc/prepare_grenade_for_throw(datum/human_ai_throwable_context/context, obj/item/grenade_source)
	RETURN_TYPE(/obj/item/explosive/grenade)
	if(!context?.is_valid() || !grenade_source)
		return null

	var/obj/item/explosive/grenade/direct_grenade = grenade_source
	if(istype(direct_grenade))
		return context.set_grenade(direct_grenade)

	var/obj/item/ammo_box/magazine/nade_box/grenade_box = grenade_source
	if(istype(grenade_box))
		return context.set_grenade(context.controller.take_grenade_from_grenade_box(grenade_box))

	return null
