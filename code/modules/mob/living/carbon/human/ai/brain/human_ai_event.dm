/datum/human_ai_event
	var/event_type
	var/datum/human_ai_brain/source_brain
	var/datum/human_ai_context/context
	var/list/data

/datum/human_ai_event/New(new_event_type, datum/human_ai_brain/new_source_brain, list/new_data)
	. = ..()
	event_type = new_event_type
	source_brain = new_source_brain
	context = source_brain?.create_context()
	data = new_data ? new_data.Copy() : list()

/datum/human_ai_event/Destroy(force, ...)
	QDEL_NULL(context)
	source_brain = null
	data = null
	return ..()

/datum/human_ai_event/proc/get_old_target()
	return data?["old_target"]

/datum/human_ai_event/proc/get_new_target()
	return data?["new_target"]

/datum/human_ai_event/proc/get_projectile()
	return data?["bullet"]

/datum/human_ai_event/proc/is_from_direct_hit()
	return data?["from_direct_hit"]

/datum/human_ai_event/proc/get_threat_source()
	return data?["threat_source"]

/datum/human_ai_event/proc/get_threat_turf()
	return data?["threat_turf"]

/datum/human_ai_event/proc/get_threat_angle()
	return data?["threat_angle"]

/datum/human_ai_event/proc/was_in_combat()
	return data?["was_in_combat"]

/datum/human_ai_event/proc/should_holster_primary()
	return data?["should_holster_primary"]

/datum/human_ai_event/proc/get_combat_exit_context()
	return data?["combat_exit_context"]

/datum/human_ai_event/proc/get_new_lifecycle_state()
	return data?["new_lifecycle_state"]

/datum/human_ai_event/proc/should_clear_inventory()
	return data?["clear_inventory"]

/datum/human_ai_event/proc/get_previous_lifecycle_state()
	return data?["previous_lifecycle_state"]

/datum/human_ai_event/proc/get_new_species()
	return data?["new_species"]

/datum/human_ai_event/proc/get_new_body_position()
	return data?["new_position"]

/datum/human_ai_event/proc/get_old_body_position()
	return data?["old_position"]

/datum/human_ai_event/proc/get_old_location()
	return data?["oldloc"]

/datum/human_ai_event/proc/get_direction()
	return data?["direction"]

/datum/human_ai_event/proc/was_forced_move()
	return data?["forced"]

/datum/human_ai_brain/proc/register_ai_event_subscriber(event_type, datum/human_ai_module/module)
	if(!event_type || !module)
		return FALSE

	LAZYORASSOCLIST(ai_event_subscribers, event_type, module)
	return TRUE

/datum/human_ai_brain/proc/unregister_ai_event_subscriber(datum/human_ai_module/module)
	if(!ai_event_subscribers || !module)
		return FALSE

	for(var/event_type as anything in ai_event_subscribers)
		LAZYREMOVEASSOC(ai_event_subscribers, event_type, module)
	return TRUE

/datum/human_ai_brain/proc/emit_ai_event(event_type, list/event_data = null)
	if(!event_type || !ai_event_subscribers)
		return FALSE

	var/list/subscribers = ai_event_subscribers[event_type]
	if(!length(subscribers))
		return FALSE

	var/list/subscribers_to_notify = subscribers.Copy()
	var/datum/human_ai_event/event = new(event_type, src, event_data)
	for(var/datum/human_ai_module/module as anything in subscribers_to_notify)
		if(QDELETED(module))
			continue
		module.dispatch_ai_event(event)

	qdel(event)
	return TRUE
