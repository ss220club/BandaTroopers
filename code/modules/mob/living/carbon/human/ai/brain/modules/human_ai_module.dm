/datum/human_ai_module
	var/datum/human_ai_brain/brain
	var/datum/human_ai_context/context
	var/module_id
	var/list/required_module_types = list()

/datum/human_ai_module/New(datum/human_ai_brain/new_brain)
	. = ..()
	brain = new_brain
	if(brain)
		context = brain.create_context()

/datum/human_ai_module/Destroy(force, ...)
	brain?.unregister_ai_event_subscriber(src)
	QDEL_NULL(context)
	brain = null
	return ..()

/datum/human_ai_module/proc/reset_module()
	return

/datum/human_ai_module/proc/suspend_module(clear_inventory = FALSE)
	return

/datum/human_ai_module/proc/resume_module(previous_lifecycle_state)
	return

/datum/human_ai_module/proc/process_module(delta_time)
	return

/datum/human_ai_module/proc/dispatch_ai_event(datum/human_ai_event/event)
	switch(event.event_type)
		if(HUMAN_AI_EVENT_RESET_BEFORE_WAKE_CLEAR, HUMAN_AI_EVENT_RESET_AFTER_WAKE_CLEAR)
			on_reset()
		if(HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_BEFORE_WAKE_CLEAR, HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_AFTER_WAKE_CLEAR)
			on_lifecycle_suspended(event.get_new_lifecycle_state(), event.should_clear_inventory())
		if(HUMAN_AI_EVENT_LIFECYCLE_RESUMED)
			on_lifecycle_resumed(event.get_previous_lifecycle_state())
		else
			on_ai_event(event)

/datum/human_ai_module/proc/on_ai_event(datum/human_ai_event/event)
	return

/datum/human_ai_module/proc/on_target_changed(atom/movable/old_target, atom/movable/new_target)
	return

/datum/human_ai_module/proc/on_projectile_threat(obj/projectile/bullet, from_direct_hit = FALSE)
	return

/datum/human_ai_module/proc/on_combat_entered(was_in_combat)
	return

/datum/human_ai_module/proc/on_combat_exit_started(should_holster_primary = TRUE)
	return

/datum/human_ai_module/proc/on_combat_exit_finished(list/combat_exit_context)
	return

/datum/human_ai_module/proc/on_reset()
	reset_module()

/datum/human_ai_module/proc/on_lifecycle_suspended(new_lifecycle_state, clear_inventory = FALSE)
	suspend_module(clear_inventory)

/datum/human_ai_module/proc/on_lifecycle_resumed(previous_lifecycle_state)
	resume_module(previous_lifecycle_state)

/datum/human_ai_module/proc/on_handcuffed()
	return

/datum/human_ai_module/proc/on_species_changed(new_species)
	return

/datum/human_ai_module/proc/on_body_position_changed(new_position, old_position)
	return

/datum/human_ai_module/proc/on_moved(atom/oldloc, direction, forced)
	return

/datum/human_ai_module/proc/can_ignore_target_darkness()
	return FALSE
