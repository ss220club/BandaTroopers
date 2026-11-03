// Human AI throwable weapon-use context.

/datum/human_ai_throwable_context
	parent_type = /datum/human_ai_weapon_context
	var/obj/item/explosive/grenade/grenade
	var/min_safe_throw_distance = 2
	var/throw_range_override = null

/datum/human_ai_throwable_context/New(datum/human_ai_brain/new_ai, obj/item/explosive/grenade/new_grenade = null, atom/movable/new_current_target = null, turf/new_target_turf = null, new_throw_range_override = null)
	. = ..(new_ai, new_grenade, new_current_target, new_target_turf)
	grenade = new_grenade
	throw_range_override = new_throw_range_override

/datum/human_ai_throwable_context/proc/set_grenade(obj/item/explosive/grenade/new_grenade)
	grenade = new_grenade
	weapon_item = new_grenade
	if(isnum(new_grenade?.throw_range))
		throw_range_override = new_grenade.throw_range
	return grenade

/datum/human_ai_throwable_context/proc/can_continue_throw()
	if(!can_continue(grenade))
		return FALSE
	if(!target_turf)
		return FALSE
	return TRUE
