// Isolated Human AI firearm registry proposal. Not included in colonialmarines.dme yet.

GLOBAL_DATUM_INIT(human_ai_firearm_registry, /datum/human_ai_firearm_registry, new)

/datum/human_ai_firearm_registry
	var/list/datum/human_ai_firearm_handler/handlers = list()
	var/list/datum/human_ai_firearm_profile/profiles = list()

/datum/human_ai_firearm_registry/New()
	. = ..()
	build_handlers()
	build_profiles()

/datum/human_ai_firearm_registry/proc/build_handlers()
	handlers.Cut()
	for(var/type in subtypesof(/datum/human_ai_firearm_handler))
		insert_handler(new type)

/datum/human_ai_firearm_registry/proc/build_profiles()
	profiles.Cut()
	for(var/type in subtypesof(/datum/human_ai_firearm_profile))
		insert_profile(new type)

/datum/human_ai_firearm_registry/proc/get_handler(obj/item/weapon/gun/firearm)
	RETURN_TYPE(/datum/human_ai_firearm_handler)
	if(!firearm)
		return null
	for(var/datum/human_ai_firearm_handler/handler as anything in handlers)
		if(handler.matches(firearm))
			return handler

/datum/human_ai_firearm_registry/proc/get_profile(obj/item/weapon/gun/firearm)
	RETURN_TYPE(/datum/human_ai_firearm_profile)
	if(!firearm)
		return null
	for(var/datum/human_ai_firearm_profile/profile as anything in profiles)
		if(profile.matches(firearm))
			return profile

/datum/human_ai_firearm_registry/proc/insert_handler(datum/human_ai_firearm_handler/handler)
	if(!handler)
		return
	insert_by_specificity(handlers, handler, get_handler_specificity(handler))

/datum/human_ai_firearm_registry/proc/insert_profile(datum/human_ai_firearm_profile/profile)
	if(!profile)
		return
	insert_by_specificity(profiles, profile, get_profile_specificity(profile))

/datum/human_ai_firearm_registry/proc/insert_by_specificity(list/target_list, datum/entry, specificity)
	for(var/index in 1 to length(target_list))
		var/datum/existing_entry = target_list[index]
		if(specificity > get_entry_specificity(existing_entry))
			target_list.Insert(index, entry)
			return
	target_list += entry

/datum/human_ai_firearm_registry/proc/get_handler_specificity(datum/human_ai_firearm_handler/handler)
	return get_gun_type_list_specificity(handler?.gun_types)

/datum/human_ai_firearm_registry/proc/get_profile_specificity(datum/human_ai_firearm_profile/profile)
	return get_gun_type_list_specificity(profile?.gun_types)

/datum/human_ai_firearm_registry/proc/get_entry_specificity(datum/entry)
	if(istype(entry, /datum/human_ai_firearm_handler))
		var/datum/human_ai_firearm_handler/handler = entry
		return get_handler_specificity(handler)
	if(istype(entry, /datum/human_ai_firearm_profile))
		var/datum/human_ai_firearm_profile/profile = entry
		return get_profile_specificity(profile)
	return 0

/datum/human_ai_firearm_registry/proc/get_gun_type_list_specificity(list/gun_types)
	var/max_specificity = 0
	for(var/gun_type as anything in gun_types)
		max_specificity = max(max_specificity, get_type_specificity(gun_type))
	return max_specificity

/datum/human_ai_firearm_registry/proc/get_type_specificity(typepath)
	return length(splittext("[typepath]", "/"))
