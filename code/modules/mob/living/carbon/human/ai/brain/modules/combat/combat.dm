/datum/human_ai_module/combat
	module_id = "combat"
	required_module_types = list(/datum/human_ai_module/targeting)

	/// Ref to the last turf that the AI shot at
	var/turf/shot_at
	/// If TRUE, then we're actively fighting someone or saw a bullet go by or saw someone else go into combat
	var/in_combat = FALSE
	/// The minimum amount of time that can pass before this AI can leave combat
	var/combat_decay_time_min = 15 SECONDS
	/// The maximum amount of time that can pass before this AI can leave combat
	var/combat_decay_time_max = 30 SECONDS

/datum/human_ai_module/combat/proc/reset_combat()
	in_combat = FALSE
	shot_at = null

/datum/human_ai_module/combat/proc/is_in_combat()
	return in_combat

/datum/human_ai_module/combat/proc/set_shot_at_turf(turf/target_turf)
	shot_at = get_turf(target_turf)

/datum/human_ai_module/combat/reset_module()
	reset_combat()

/datum/human_ai_module/combat/suspend_module(clear_inventory = FALSE)
	reset_combat()

/datum/human_ai_module/combat/proc/can_continue_combat_work()
	return brain?.can_continue_runtime_work()

/datum/human_ai_module/combat/proc/has_owner_current_target()
	return brain.has_current_target()

/datum/human_ai_module/combat/proc/emit_owner_combat_entered(was_in_combat)
	return brain.emit_combat_entered(was_in_combat)

/datum/human_ai_module/combat/proc/has_valid_owner()
	return brain.has_valid_tied_human()

/datum/human_ai_module/combat/proc/emit_owner_combat_exit_force_cleared()
	return brain.emit_combat_exit_force_cleared()

/datum/human_ai_module/combat/proc/emit_owner_combat_exit_started()
	return brain.emit_combat_exit_started()

/datum/human_ai_module/combat/proc/emit_owner_combat_exit_finished()
	return brain.emit_combat_exit_finished()

/datum/human_ai_module/combat/proc/schedule_owner_combat_exit()
	addtimer(CALLBACK(brain, TYPE_PROC_REF(/datum/human_ai_brain, exit_combat)), rand(combat_decay_time_min, combat_decay_time_max), TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/datum/human_ai_module/combat/process_module(delta_time)
	if(!can_continue_combat_work())
		return
	if(has_owner_current_target())
		enter_combat()

/datum/human_ai_module/combat/on_ai_event(datum/human_ai_event/event)
	if(event.event_type == HUMAN_AI_EVENT_PROJECTILE_THREAT)
		var/obj/projectile/bullet = event.get_projectile()
		on_projectile_threat(bullet, event.is_from_direct_hit(), event.get_threat_turf())

/datum/human_ai_module/combat/on_projectile_threat(obj/projectile/bullet, from_direct_hit = FALSE, turf/threat_turf = null)
	if(!threat_turf)
		return

	enter_combat()

/datum/human_ai_module/combat/proc/enter_combat()
	SIGNAL_HANDLER
	if(!can_continue_combat_work())
		return

	var/was_in_combat = in_combat
	emit_owner_combat_entered(was_in_combat)
	in_combat = TRUE
	schedule_owner_combat_exit()
	SShuman_ai.combat_ever_started = TRUE

/datum/human_ai_module/combat/proc/exit_combat()
	if(!has_valid_owner())
		emit_owner_combat_exit_force_cleared()
		in_combat = FALSE
		return

	if(!can_continue_combat_work())
		return

	if(in_combat)
		emit_owner_combat_exit_started()

	emit_owner_combat_exit_finished()

	in_combat = FALSE
