GLOBAL_LIST_EMPTY(human_ai_brains)

/datum/human_ai_brain
	/// API facade for reading and controlling the tied human puppet.
	var/datum/human_tied_controller/tied_controller
	var/datum/human_ai_module_config/module_config

	var/list/datum/human_ai_module/process_modules_before_posture
	var/list/datum/human_ai_module/process_modules_after_posture
	var/list/datum/human_ai_module/target_vision_modules
	var/list/ai_event_subscribers

	var/wake_rethink_queued_at = -1 // SS220 EDIT: wake-up signal should only queue one immediate rethink per tick
	var/last_process_tick = -1 // SS220 EDIT: prevent signal-driven wake rethinks from re-entering the scheduler in the same tick
	var/lifecycle_state = HUMAN_AI_LIFECYCLE_ACTIVE // SS220 EDIT: brain owns active/suspended runtime admission
	var/runtime_shutdown_started = FALSE // SS220 EDIT: component-owned lifetime teardown may race brain delete signals

/datum/human_ai_brain/New(mob/living/carbon/human/new_human)
	. = ..()
	tied_controller = new(src, new_human)
	var/datum/human_tied_controller/controller = get_tied_controller()
	module_config = create_module_config(new_human?.assigned_equipment_preset?.human_ai_module_config_type)
	module_config.setup_brain(src, new_human)
	setup_lifecycle_modules()
	controller.register_signal_for(src, COMSIG_PARENT_QDELETING, PROC_REF(on_human_delete))
	controller.register_signal_for(src, COMSIG_MOB_DEATH, PROC_REF(on_human_death)) // SS220 EDIT: death guard should tear down AI and force corpses prone immediately
	controller.register_signal_for(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	controller.register_signal_for(src, COMSIG_HUMAN_HANDCUFFED, PROC_REF(on_handcuffed))
	controller.register_signal_for(src, COMSIG_HUMAN_GET_AI_BRAIN, PROC_REF(get_ai_brain))
	controller.register_signal_for(src, COMSIG_HUMAN_SET_SPECIES, PROC_REF(on_species_change))
	controller.register_signal_for(src, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position_change)) // SS220 EDIT: standing back up should wake shared human AI immediately
	GLOB.human_ai_brains += src
	emit_initialized()

/datum/human_ai_brain/Destroy(force, ...)
	GLOB.human_ai_brains -= src
	shutdown_runtime()
	process_modules_before_posture = null
	process_modules_after_posture = null
	target_vision_modules = null
	ai_event_subscribers = null
	module_config?.teardown_brain_modules(src)
	QDEL_NULL(module_config)
	QDEL_NULL(tied_controller)

	return ..()

/datum/human_ai_brain/proc/has_valid_tied_human()
	return get_tied_controller()?.has_valid_tied_human()

/datum/human_ai_brain/proc/create_module_config(module_config_type = /datum/human_ai_module_config/default)
	if(!ispath(module_config_type, /datum/human_ai_module_config))
		module_config_type = /datum/human_ai_module_config/default
	return new module_config_type()

/datum/human_ai_brain/proc/setup_lifecycle_modules()
	module_config.configure_module_lists(src)

/datum/human_ai_brain/proc/reset_ai()
	emit_reset_before_wake_clear()
	wake_rethink_queued_at = -1 // SS220 EDIT: reset must always cancel deferred wake-up recovery before owner teardown finishes
	emit_reset_after_wake_clear()

/datum/human_ai_brain/proc/shutdown_runtime()
	if(runtime_shutdown_started)
		return FALSE

	runtime_shutdown_started = TRUE
	lifecycle_state = HUMAN_AI_LIFECYCLE_INVALID
	reset_ai()
	return TRUE

/datum/human_ai_brain/proc/can_continue_runtime_work()
	if(QDELETED(src) || runtime_shutdown_started)
		return FALSE
	if(lifecycle_state != HUMAN_AI_LIFECYCLE_ACTIVE)
		return FALSE
	return get_lifecycle_state() == HUMAN_AI_LIFECYCLE_ACTIVE

/datum/human_ai_brain/process(delta_time)
	last_process_tick = world.time // SS220 EDIT: track scheduler entry to guard same-tick wake rethinks
	wake_rethink_queued_at = -1 // SS220 EDIT: any queued wake rethink has been serviced once processing starts

	var/new_lifecycle_state = get_lifecycle_state()
	if(new_lifecycle_state != HUMAN_AI_LIFECYCLE_ACTIVE)
		handle_suspended_lifecycle_state(new_lifecycle_state)
		lifecycle_state = new_lifecycle_state
		return

	if(lifecycle_state != HUMAN_AI_LIFECYCLE_ACTIVE)
		resume_from_lifecycle_suspension(lifecycle_state)
	lifecycle_state = HUMAN_AI_LIFECYCLE_ACTIVE

	process_active_ai(delta_time)

/datum/human_ai_brain/proc/get_lifecycle_state()
	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller?.has_valid_tied_human())
		return HUMAN_AI_LIFECYCLE_INVALID
	if(controller.is_dead())
		return HUMAN_AI_LIFECYCLE_DEAD
	if(controller.can_player_takeover_block_ai())
		return HUMAN_AI_LIFECYCLE_PLAYER_CONTROLLED
	if(should_force_hardcrit_resting())
		return HUMAN_AI_LIFECYCLE_HARDCRIT
	if(controller.is_incapacitated())
		return HUMAN_AI_LIFECYCLE_INCAPACITATED
	return HUMAN_AI_LIFECYCLE_ACTIVE

/datum/human_ai_brain/proc/handle_suspended_lifecycle_state(new_lifecycle_state)
	switch(new_lifecycle_state)
		if(HUMAN_AI_LIFECYCLE_INVALID)
			reset_ai()
		if(HUMAN_AI_LIFECYCLE_DEAD)
			suspend_for_death()
		if(HUMAN_AI_LIFECYCLE_PLAYER_CONTROLLED)
			suspend_for_player_control()
		if(HUMAN_AI_LIFECYCLE_HARDCRIT)
			suspend_for_hardcrit()
		if(HUMAN_AI_LIFECYCLE_INCAPACITATED)
			suspend_for_incapacitated()

/datum/human_ai_brain/proc/suspend_runtime(new_lifecycle_state, clear_inventory = FALSE)
	var/list/lifecycle_context = list(
		"new_lifecycle_state" = new_lifecycle_state,
		"clear_inventory" = clear_inventory,
	)
	emit_lifecycle_suspended_before_wake_clear(lifecycle_context)
	wake_rethink_queued_at = -1
	emit_lifecycle_suspended_after_wake_clear(lifecycle_context)

/datum/human_ai_brain/proc/suspend_for_death()
	suspend_runtime(HUMAN_AI_LIFECYCLE_DEAD)
	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller?.has_valid_tied_human() || !controller.is_dead())
		return
	if(controller.is_buckled()) // SS220 EDIT: death suspension releases forced-standing buckle state without deleting revive-capable brain
		controller.unbuckle()
	controller.force_prone()

/datum/human_ai_brain/proc/suspend_for_player_control()
	if(lifecycle_state == HUMAN_AI_LIFECYCLE_PLAYER_CONTROLLED)
		return
	suspend_runtime(HUMAN_AI_LIFECYCLE_PLAYER_CONTROLLED)

/datum/human_ai_brain/proc/suspend_for_incapacitated()
	suspend_runtime(HUMAN_AI_LIFECYCLE_INCAPACITATED)

/datum/human_ai_brain/proc/suspend_for_hardcrit()
	suspend_runtime(HUMAN_AI_LIFECYCLE_HARDCRIT)
	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller?.has_valid_tied_human())
		return
	controller.force_prone()

/datum/human_ai_brain/proc/resume_from_lifecycle_suspension(previous_lifecycle_state)
	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller?.has_valid_tied_human() || controller.can_player_takeover_block_ai())
		return FALSE

	if(previous_lifecycle_state == HUMAN_AI_LIFECYCLE_INVALID)
		return FALSE

	emit_lifecycle_resumed(previous_lifecycle_state)
	brain_resume_modular_runtime()
	return TRUE

/datum/human_ai_brain/proc/brain_resume_modular_runtime()
	invalidate_runtime_extension_caches()

/datum/human_ai_brain/proc/should_force_hardcrit_resting()
	var/datum/human_tied_controller/controller = get_tied_controller()
	return (controller?.has_effect(/datum/effects/crit) && controller.has_status_flag(CANKNOCKOUT))

/datum/human_ai_brain/proc/process_active_ai(delta_time)

	if(process_active_module_list(process_modules_before_posture, delta_time))
		return

	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller)
		return

	// SS220 EDIT - START: hardcrit AIs should keep resting until the crit loop and knockdown pressure are truly gone
	if((controller.get_stat() == CONSCIOUS) && controller.is_resting() && !controller.has_trait(TRAIT_FLOORED))
		// SS220 EDIT - START: final stand-up gate must stay exactly aligned with the existing wake rethink eligibility rules
		controller.try_stand_up()
		// SS220 EDIT - END
	// SS220 EDIT - END

	if(controller.is_buckled())
		controller.clear_buckle_state() // AI never buckle themselves into chairs at the moment, change if this becomes the case

	if(process_active_module_list(process_modules_after_posture, delta_time))
		return

/datum/human_ai_brain/proc/process_active_module_list(list/datum/human_ai_module/module_list, delta_time)
	for(var/datum/human_ai_module/module as anything in module_list)
		if(module.process_module(delta_time))
			return TRUE
	return FALSE

/datum/human_ai_brain/proc/can_ignore_target_darkness()
	if(!target_vision_modules)
		return FALSE

	for(var/datum/human_ai_module/module as anything in target_vision_modules)
		if(module.can_ignore_target_darkness())
			return TRUE
	return FALSE


/datum/human_ai_brain/proc/on_human_delete(datum/source, force)
	SIGNAL_HANDLER
	clear_perception_detection_radius() // SS220 EDIT: aggressively tear down brain state before component qdel catches up
	shutdown_runtime()
	wake_rethink_queued_at = -1 // SS220 EDIT: owner delete must not leave a queued wake rethink pointing at a null tied human
	get_tied_controller()?.set_tied_human(null)

/datum/human_ai_brain/proc/on_human_death(datum/source)
	SIGNAL_HANDLER
	suspend_for_death()
	lifecycle_state = HUMAN_AI_LIFECYCLE_DEAD

/datum/human_ai_brain/proc/on_species_change(datum/source, new_species)
	SIGNAL_HANDLER
	emit_species_changed(new_species)

/datum/human_ai_brain/proc/on_body_position_change(datum/source, new_position, old_position)
	SIGNAL_HANDLER
	if((new_position != STANDING_UP) || (old_position != LYING_DOWN))
		return

	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller?.can_stand_up())
		return

	emit_body_position_changed(new_position, old_position)

	if((last_process_tick == world.time) || (wake_rethink_queued_at == world.time))
		return

	wake_rethink_queued_at = world.time
	INVOKE_ASYNC(src, PROC_REF(run_wake_rethink), world.time) // SS220 EDIT: queue exactly one no-sleep rethink outside the signal stack

/datum/human_ai_brain/proc/run_wake_rethink(queued_tick)
	if(QDELETED(src) || (wake_rethink_queued_at != queued_tick))
		return

	wake_rethink_queued_at = -1
	var/datum/human_tied_controller/controller = get_tied_controller()
	if(!controller?.can_stand_up())
		return

	if((last_process_tick == queued_tick) || (last_process_tick == world.time))
		return

	process(0) // SS220 EDIT: reuse the existing shared AI loop instead of inventing a separate wake-up behavior



/datum/human_ai_brain/proc/on_move(atom/oldloc, direction, forced)
	if(!has_valid_tied_human())
		return

	emit_moved(oldloc, direction, forced)
