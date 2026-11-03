/datum/human_ai_brain/proc/emit_initialized()
	emit_ai_event(HUMAN_AI_EVENT_INITIALIZED)

/datum/human_ai_brain/proc/emit_reset_before_wake_clear()
	emit_ai_event(HUMAN_AI_EVENT_RESET_BEFORE_WAKE_CLEAR)

/datum/human_ai_brain/proc/emit_reset_after_wake_clear()
	emit_ai_event(HUMAN_AI_EVENT_RESET_AFTER_WAKE_CLEAR)

/datum/human_ai_brain/proc/emit_lifecycle_suspended_before_wake_clear(list/lifecycle_context)
	emit_ai_event(HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_BEFORE_WAKE_CLEAR, lifecycle_context)

/datum/human_ai_brain/proc/emit_lifecycle_suspended_after_wake_clear(list/lifecycle_context)
	emit_ai_event(HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_AFTER_WAKE_CLEAR, lifecycle_context)

/datum/human_ai_brain/proc/emit_lifecycle_resumed(previous_lifecycle_state)
	emit_ai_event(HUMAN_AI_EVENT_LIFECYCLE_RESUMED, list(
		"previous_lifecycle_state" = previous_lifecycle_state,
	))

/datum/human_ai_brain/proc/emit_target_changed(atom/movable/old_target, atom/movable/new_target)
	emit_ai_event(HUMAN_AI_EVENT_TARGET_CHANGED, list(
		"old_target" = old_target,
		"new_target" = new_target,
	))

/datum/human_ai_brain/proc/emit_projectile_threat(obj/projectile/bullet, from_direct_hit = FALSE, atom/movable/threat_source = null, turf/threat_turf = null, threat_angle = null)
	emit_ai_event(HUMAN_AI_EVENT_PROJECTILE_THREAT, list(
		"bullet" = bullet,
		"from_direct_hit" = from_direct_hit,
		"threat_source" = threat_source,
		"threat_turf" = threat_turf,
		"threat_angle" = threat_angle,
	))

/datum/human_ai_brain/proc/emit_combat_entered(was_in_combat)
	emit_ai_event(HUMAN_AI_EVENT_COMBAT_ENTERED, list(
		"was_in_combat" = was_in_combat,
	))

/datum/human_ai_brain/proc/emit_combat_exit_started()
	var/datum/human_tied_controller/controller = get_tied_controller()
	controller?.set_safe_intent()
	var/should_holster_primary = !has_sniper_home()
	emit_ai_event(HUMAN_AI_EVENT_COMBAT_EXIT_STARTED, list(
		"should_holster_primary" = should_holster_primary,
	))

/datum/human_ai_brain/proc/emit_combat_exit_finished()
	var/list/combat_exit_context = list("clear_target_turf" = FALSE)
	emit_ai_event(HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED, list(
		"combat_exit_context" = combat_exit_context,
	))

/datum/human_ai_brain/proc/emit_combat_exit_force_cleared()
	var/list/combat_exit_context = list(
		"clear_target_turf" = TRUE,
		"force_clear" = TRUE,
	)
	emit_ai_event(HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED, list(
		"combat_exit_context" = combat_exit_context,
	))

/datum/human_ai_brain/proc/emit_species_changed(new_species)
	emit_ai_event(HUMAN_AI_EVENT_SPECIES_CHANGED, list(
		"new_species" = new_species,
	))

/datum/human_ai_brain/proc/emit_body_position_changed(new_position, old_position)
	emit_ai_event(HUMAN_AI_EVENT_BODY_POSITION_CHANGED, list(
		"new_position" = new_position,
		"old_position" = old_position,
	))

/datum/human_ai_brain/proc/emit_moved(atom/oldloc, direction, forced)
	emit_ai_event(HUMAN_AI_EVENT_MOVED, list(
		"oldloc" = oldloc,
		"direction" = direction,
		"forced" = forced,
	))

/datum/human_ai_brain/proc/emit_handcuffed()
	emit_ai_event(HUMAN_AI_EVENT_HANDCUFFED)
