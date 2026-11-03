// Shared Human AI weapon-use handler contract.

/datum/human_ai_weapon_handler
	var/list/item_types = list(/obj/item)

/datum/human_ai_weapon_handler/proc/matches(obj/item/item)
	return item && is_type_in_list(item, item_types)

/datum/human_ai_weapon_handler/proc/can_use(datum/human_ai_weapon_context/context)
	return context?.can_continue()

/datum/human_ai_weapon_handler/proc/get_weight(datum/human_ai_weapon_context/context)
	return can_use(context) ? 1 : 0

/datum/human_ai_weapon_handler/proc/prepare(datum/human_ai_weapon_context/context)
	return can_use(context)

/datum/human_ai_weapon_handler/proc/use(datum/human_ai_weapon_context/context)
	return can_use(context)

/datum/human_ai_weapon_handler/proc/cleanup(datum/human_ai_weapon_context/context)
	return TRUE
