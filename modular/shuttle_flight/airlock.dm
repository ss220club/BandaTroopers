#define DROPSHIP_AIRLOCK_OUTER_AIRLOCK_ACCESS_GRACE_PERIOD 120 SECONDS
#define DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD 14 SECONDS
#define DROPSHIP_AIRLOCK_DECLAMP_PERIOD 3 SECONDS
#define DROPSHIP_AIRLOCK_HEIGHT_TRANSITION 9 SECONDS
#define DROPSHIP_AIRLOCK_FLOODLIGHT_TRANSITION 1.5 SECONDS
#define DROPSHIP_AIRLOCK_DOOR_PERIOD 5 SECONDS
#define DROPSHIP_AIRLOCK_AUTOMATIC_DELAY 5 SECONDS
#define DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_EFFECT x + airlock_x_offset - 7, y + airlock_y_offset - 12, z
#define DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_NE_BOUND x + airlock_x_offset + 7, y + airlock_y_offset + 12, z
#define DROPSHIP_AIRLOCK_BOUNDS locate(DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_EFFECT), locate(DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_NE_BOUND)
#define DROPSHIP_AIRLOCK_GO_DOWN "down"
#define DROPSHIP_AIRLOCK_GO_UP "up"
#define AIRLOCK_STATE_IDLE 0
#define AIRLOCK_STATE_IN_SEQUENCE 1
#define AIRLOCK_STATE_ADMIN_LOCKED 2
#define AIRLOCK_STATE_NEEDS_RESYNC 3
#define DROPSHIP_HANGAR_DOCK_IS_AIRLOCK (1<<0)
#define DROPSHIP_LZ_DOCK_IS_AIRLOCK (1<<1)
#define ALMAYER_HANGAR_AIRLOCK_ONE "almayer-hangar-airlock-one"
#define ALMAYER_HANGAR_AIRLOCK_TWO "almayer-hangar-airlock-two"


GLOBAL_LIST_EMPTY(dropship_airlock_docking_ports)

/obj/docking_port/stationary/marine_dropship/airlock
	var/airlock_x_offset = 0
	var/airlock_y_offset = 0



/obj/docking_port/stationary/marine_dropship/airlock/inner

	var/dropship_airlock_id = "generic"


	var/playing_airlock_alarm = FALSE
	var/open_inner_airlock = FALSE
	var/lowered_dropship = FALSE
	var/open_outer_airlock = FALSE
	var/disengaged_clamps = FALSE



	var/undergoing_admin_command = FALSE

	var/allow_processing_to_end = TRUE

	var/processing = FALSE

	var/airlock_state = AIRLOCK_STATE_IDLE




	var/internal_relocation_in_progress = FALSE


	var/obj/docking_port/stationary/marine_dropship/airlock/outer/linked_outer

	var/obj/effect/hangar_airlock/inner/inner_airlock_effect

	var/obj/effect/hangar_airlock/outer/outer_airlock_effect


	var/list/dropship_height_masks = null

	var/list/inner_airlock_turf_lists = null

	var/list/outer_airlock_turf_lists = null
	var/list/tracked_static_alpha_masks = null
	var/list/tracked_airlock_projectors = null


	var/list/floodlights = null
	var/list/door_controls = null
	var/list/poddoors = null
	var/list/railings = null


	var/obj/docking_port/mobile/marine_dropship/docked_mobile = null


	var/automatic_process_stage_change = 0
	var/automatic_process_stage = FALSE
	COOLDOWN_DECLARE(dropship_airlock_cooldown)



	COOLDOWN_DECLARE(sequence_violation_shake_cooldown)

	auto_open = TRUE

/obj/docking_port/stationary/marine_dropship/airlock/inner/almayer_one
	name = "Almayer Hangar Airlock 1 Inner"
	id = ALMAYER_A1_INNER
	dropship_airlock_id = ALMAYER_HANGAR_AIRLOCK_ONE
	roundstart_template = /datum/map_template/shuttle/alamo

/obj/docking_port/stationary/marine_dropship/airlock/inner/almayer_two
	name = "Almayer Hangar Airlock 2 Inner"
	id = ALMAYER_A2_INNER
	dropship_airlock_id = ALMAYER_HANGAR_AIRLOCK_TWO
	roundstart_template = /datum/map_template/shuttle/normandy

/obj/docking_port/stationary/marine_dropship/airlock/outer
	name = "Hangar Airlock Outer"
	id = GENERIC_A_O
	var/obj/docking_port/stationary/marine_dropship/airlock/inner/linked_inner

	var/dropship_airlock_id = "generic"

/obj/docking_port/stationary/marine_dropship/airlock/outer/almayer_one
	name = "Almayer Hangar Airlock 1 Outer"
	id = ALMAYER_A1_OUTER
	dropship_airlock_id = ALMAYER_HANGAR_AIRLOCK_ONE

/obj/docking_port/stationary/marine_dropship/airlock/outer/almayer_two
	name = "Almayer Hangar Airlock 2 Outer"
	id = ALMAYER_A2_OUTER
	dropship_airlock_id = ALMAYER_HANGAR_AIRLOCK_TWO






/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/sequence_violation_shake()
	if(!COOLDOWN_FINISHED(src, sequence_violation_shake_cooldown))
		return
	COOLDOWN_START(src, sequence_violation_shake_cooldown, 10 SECONDS)



	var/obj/docking_port/mobile/marine_dropship/ship = get_docked() || linked_outer.get_docked()
	if(!ship)
		return
	var/list/mobs_on_ship = list()
	for(var/area/shuttle_area as anything in ship.shuttle_areas)
		for(var/turf/shuttle_turf in shuttle_area)
			for(var/mob/living/carbon/mob_on_ship in shuttle_turf)
				mobs_on_ship += mob_on_ship
	if(!length(mobs_on_ship))
		return
	shakeship(3, 5, TRUE, restrict_to_mobs = mobs_on_ship)

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/update_airlock_alarm(play = playing_airlock_alarm, forced = FALSE)
	. = list("successful" = FALSE, "to_chat" = "ERROR. DROPSHIP AIRLOCK ALARM NOT FUNCTIONING. FILE A BUG REPORT.")
	if(play == playing_airlock_alarm)
		end_of_interaction()
		.["successful"] = TRUE
		return
	if(!forced)
		if(processing && !automatic_process_stage_change)
			.["to_chat"] = "The computer is already processing a command to the airlock."
			return

	processing = TRUE
	if(!inner_airlock_turf_lists)
		get_inner_airlock_turf_lists()
	if(!outer_airlock_turf_lists)
		linked_outer.get_outer_airlock_turf_lists()
	var/obj/structure/machinery/floodlight/landing/dropship_airlock/floodlight
	var/floodlight_increment = 1
	for(floodlight as anything in floodlights)
		addtimer(CALLBACK(floodlight, TYPE_PROC_REF(/obj/structure/machinery/floodlight/landing/dropship_airlock, toggle_rotating)), DROPSHIP_AIRLOCK_FLOODLIGHT_TRANSITION * floodlight_increment)
		floodlight_increment += 1
	addtimer(CALLBACK(src, PROC_REF(delayed_airlock_alarm)), DROPSHIP_AIRLOCK_FLOODLIGHT_TRANSITION * floodlight_increment)
	.["to_chat"] = play ? "Beginning rotation of airlock caution lights." : "Ending rotation of airlock caution lights."
	playing_airlock_alarm = play
	.["successful"] = TRUE

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/update_inner_airlock(open = open_inner_airlock, forced = FALSE)
	. = list("successful" = FALSE, "to_chat" = "ERROR. DROPSHIP AIRLOCK INNER NOT FUNCTIONING. FILE A BUG REPORT.")
	if(open == open_inner_airlock)
		end_of_interaction()
		.["successful"] = TRUE
		return
	if(!forced)
		if(processing && !automatic_process_stage_change)
			.["to_chat"] = "The computer is already processing a command to the airlock."
			return
		if(open_outer_airlock)
			sequence_violation_shake()
			.["to_chat"] = "The inner airlock cannot be engaged while the outer airlock is open."
			return

	processing = TRUE
	if(!inner_airlock_turf_lists)
		get_inner_airlock_turf_lists()
	if(open)
		SSfz_transitions.toggle_selective_update(open, dropship_airlock_id)
		linked_outer.handle_obscuring_shuttle_turfs()
		omnibus_airlock_transition("inner", TRUE, inner_airlock_turf_lists, inner_airlock_effect, DROPSHIP_AIRLOCK_DOOR_PERIOD)
		.["to_chat"] = "Opening inner airlock."
	else
		omnibus_airlock_transition("inner", FALSE, inner_airlock_turf_lists, inner_airlock_effect, DROPSHIP_AIRLOCK_DOOR_PERIOD)
		addtimer(CALLBACK(SSfz_transitions, TYPE_PROC_REF(/datum/controller/subsystem/fz_transitions, toggle_selective_update), open, dropship_airlock_id), DROPSHIP_AIRLOCK_DOOR_PERIOD)
		SSfz_transitions.toggle_selective_update(!open_inner_airlock, dropship_airlock_id)
		.["to_chat"] = "Closing inner airlock."
	open_inner_airlock = open
	.["successful"] = TRUE

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/update_dropship_height(lower = lowered_dropship, forced = FALSE)
	. = list("successful" = FALSE, "to_chat" = "ERROR. DROPSHIP AIRLOCK HEIGHT CHANGE NOT FUNCTIONING. FILE A BUG REPORT.")
	if(lower == lowered_dropship)
		end_of_interaction()
		.["successful"] = TRUE
		return
	if(!forced)
		if(processing && !automatic_process_stage_change)
			.["to_chat"] = "The computer is already processing a command to the airlock."
			return
		if(!open_inner_airlock)
			sequence_violation_shake()
			.["to_chat"] = "The inner airlock must be open for the mechanism to change the dropship altitude."
			return

	if(lower)
		docked_mobile = get_docked()
		if(linked_outer.get_docked())
			.["to_chat"] = "Cannot lower the dropship while there is another dropship in the airlock."
			return
	else
		docked_mobile = linked_outer.get_docked()
		if(get_docked())
			.["to_chat"] = "Cannot raise the dropship while there is another dropship ontop of the airlock."
			return
	if(!docked_mobile)
		.["to_chat"] = "ERROR. UNEXPECTED ATTEMPT TO CHANGE DROPSHIP AIRLOCK HEIGHT. FILE A BUG REPORT."
		return
	if(!inner_airlock_turf_lists)
		get_inner_airlock_turf_lists()
	if(!outer_airlock_turf_lists)
		linked_outer.get_outer_airlock_turf_lists()

	processing = TRUE
	omnibus_sound_play(lowered_dropship ? 'sound/machines/asrs_lowering.ogg' : 'sound/machines/asrs_raising.ogg')
	if(lower)
		COOLDOWN_START(src, dropship_airlock_cooldown, DROPSHIP_AIRLOCK_HEIGHT_TRANSITION)
		delayed_height_decrease()
		.["to_chat"] = "Lowering dropship into the airlock."
	else
		addtimer(CALLBACK(src, PROC_REF(delayed_height_increase)), DROPSHIP_AIRLOCK_HEIGHT_TRANSITION)
		.["to_chat"] = "Raising dropship from the airlock."
	lowered_dropship = lower
	.["successful"] = TRUE

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/update_outer_airlock(open = open_outer_airlock, forced = FALSE)
	. = list("successful" = FALSE, "to_chat" = "ERROR. DROPSHIP AIRLOCK OUTER NOT FUNCTIONING. FILE A BUG REPORT.")
	if(open == open_outer_airlock)
		end_of_interaction()
		.["successful"] = TRUE
		return
	if(!forced)
		if(processing && !automatic_process_stage_change)
			.["to_chat"] = "The computer is already processing a command to the airlock."
			return
		if(open_inner_airlock)
			sequence_violation_shake()
			.["to_chat"] = "Cannot engage the outer airlock while the inner airlock is open."
			return
		if(disengaged_clamps)
			sequence_violation_shake()
			.["to_chat"] = "Cannot engage the outer airlock without the dropship resting securely on its clamps."
			return

	processing = TRUE
	if(!outer_airlock_turf_lists)
		linked_outer.get_outer_airlock_turf_lists()
	if(open)
		for(var/obj/structure/machinery/door/poddoor/almayer/airlock/poddoor as anything in poddoors)
			poddoor.close()
		omnibus_airlock_transition("outer", TRUE, outer_airlock_turf_lists, outer_airlock_effect, DROPSHIP_AIRLOCK_DOOR_PERIOD)
		.["to_chat"] = "Opening outer airlock."
	else
		omnibus_airlock_transition("outer", FALSE, outer_airlock_turf_lists, outer_airlock_effect, DROPSHIP_AIRLOCK_DOOR_PERIOD)
		.["to_chat"] = "Closing outer airlock."
	open_outer_airlock = open
	.["successful"] = TRUE

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/update_clamps(disengage = disengaged_clamps, forced = FALSE)
	. = list("successful" = FALSE, "to_chat" = "ERROR. DROPSHIP AIRLOCK CLAMPS NOT FUNCTIONING. FILE A BUG REPORT.")
	docked_mobile = linked_outer.get_docked()
	if(disengage == disengaged_clamps)
		end_of_interaction()
		.["successful"] = TRUE
		return
	if(!docked_mobile)
		.["to_chat"] = "No dropship for the clamps to disengage with."
		return
	if(!forced)
		if(processing && !automatic_process_stage_change)
			.["to_chat"] = "The computer is already processing a command to the airlock."
			return
		if(!open_outer_airlock)
			sequence_violation_shake()
			.["to_chat"] = "The clamps can only be disengaged when the outer airlock is open."
			return
		if(!lowered_dropship)
			sequence_violation_shake()
			.["to_chat"] = "The clamps can only be disengaged when the dropship is lowered."
			return
		if(docked_mobile.mode == SHUTTLE_RECHARGING)
			.["to_chat"] = "The dropship is still recharging. It would be suicide to have it fly into a grav well without proper engine control."
			return

	processing = TRUE
	if(disengage)
		playsound(docked_mobile.return_center_turf(), 'modular/shuttle_flight/sound/effects/dropship_flight_airlocked_start.ogg', 100, sound_range = docked_mobile.dheight, vol_cat = VOLUME_SFX)
		addtimer(CALLBACK(src, PROC_REF(delayed_disengage_clamps), docked_mobile), DROPSHIP_AIRLOCK_DECLAMP_PERIOD)
		.["to_chat"] = "Disengaging clamps."
	else
		.["to_chat"] = "Engaging clamps."
	disengaged_clamps = disengage
	.["successful"] = TRUE



/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/delayed_airlock_alarm()
	docked_mobile = get_docked()
	docked_mobile?.door_control?.control_doors(playing_airlock_alarm ? "lock" : "unlock", "all")
	if(!docked_mobile)
		docked_mobile = linked_outer.get_docked()

	if(docked_mobile)
		if(playing_airlock_alarm)
			docked_mobile.alarm_sound_loop.start()
			docked_mobile.playing_launch_announcement_alarm = TRUE
		else
			docked_mobile.alarm_sound_loop.stop()
			docked_mobile.playing_launch_announcement_alarm = FALSE

	var/obj/structure/machinery/door/poddoor/railing/airlock_railing
	if(playing_airlock_alarm)
		for(airlock_railing as anything in railings)
			airlock_railing.close(TRUE)
	else
		for(airlock_railing as anything in railings)
			airlock_railing.open(TRUE)
	end_of_interaction()

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/delayed_airlock_transition(airlock_type, open, airlock_turf_lists, obj/effect/hangar_airlock/airlock, end_decisecond, transition)
	if(COOLDOWN_FINISHED(src, dropship_airlock_cooldown))
		airlock.icon_state = "[transition]"
		end_of_interaction()
		return
	var/decisecond = (end_decisecond - COOLDOWN_TIMELEFT(src, dropship_airlock_cooldown))
	if(!(decisecond % 10))
		if(decisecond != end_decisecond)
			airlock.icon_state = "[transition]_[decisecond * 0.1]s"
	var/list/transition_turfs = airlock_turf_lists["[decisecond]"]
	if(airlock_type == "outer")
		transition_turfs = list()
		for(var/turf/airlock_turf as anything in airlock_turf_lists)
			if(!istype(airlock_turf, /turf/open/floor/hangar_airlock/outer))
				continue
			var/turf/open/floor/hangar_airlock/outer/outer_turf = airlock_turf
			if(outer_turf.frame_threshold == decisecond)
				transition_turfs += outer_turf
	for(var/turf/open/floor/hangar_airlock/T as anything in transition_turfs)
		T.open = open
		if(istype(T, /turf/open/floor/hangar_airlock/outer))
			var/turf/open/floor/hangar_airlock/outer/outer_turf = T
			outer_turf.set_hatch_surface(open)
		for(var/atom/movable/contents_atom in T.contents)
			if(!contents_atom.anchored)
				T.Entered(contents_atom)
		T.clean_cleanables()
		T.can_bloody = !open
	INVOKE_NEXT_TICK(src, PROC_REF(delayed_airlock_transition), airlock_type, open, airlock_turf_lists, airlock, end_decisecond, transition)

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/delayed_height_decrease()
	if(COOLDOWN_FINISHED(src, dropship_airlock_cooldown))
		internal_relocation_in_progress = TRUE
		docked_mobile.initiate_docking(linked_outer)
		internal_relocation_in_progress = FALSE
		for(var/obj/effect/hangar_airlock/height_mask/dropship/qdeling_height_mask as anything in dropship_height_masks)
			dropship_height_masks -= qdeling_height_mask
			qdel(qdeling_height_mask)
		for(var/list in inner_airlock_turf_lists)
			list = null
		inner_airlock_turf_lists = null
		for(var/list in outer_airlock_turf_lists)
			list = null
		outer_airlock_turf_lists = null
		var/obj/structure/machinery/computer/shuttle/dropship/flight/root_console = docked_mobile.getControlConsole()
		if(root_console)
			root_console.visible_message(message = SPAN_WARNING("DROPSHIP AUTOMATIC EXIT PROCEDURE ACTIVATED. The shuttle will automatically exit in [DROPSHIP_AIRLOCK_OUTER_AIRLOCK_ACCESS_GRACE_PERIOD * 0.1] seconds if still in a lowered position."), max_distance = 3)
		addtimer(CALLBACK(src, PROC_REF(end_outer_airlock_access), TRUE), DROPSHIP_AIRLOCK_OUTER_AIRLOCK_ACCESS_GRACE_PERIOD)
		end_of_interaction()
		return
	var/alpha_reiteration = (DROPSHIP_AIRLOCK_HEIGHT_TRANSITION - COOLDOWN_TIMELEFT(src, dropship_airlock_cooldown)) * 2
	for(var/obj/effect/hangar_airlock/height_mask/dropship/transitioning_height_mask as anything in dropship_height_masks)
		transitioning_height_mask.alpha = alpha_reiteration
	INVOKE_NEXT_TICK(src, PROC_REF(delayed_height_decrease))

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/end_outer_airlock_access(go_down = TRUE)
	if(automatic_process_stage)
		return
	if(!test_conditions(null, null, TRUE, null, FALSE))
		return

	var/obj/structure/machinery/computer/shuttle/dropship/flight/root_console = docked_mobile?.getControlConsole()
	if(root_console)
		root_console.visible_message(message = go_down ? SPAN_WARNING("MANUAL PROCEDURE TIMEOUT. The dropship is beginning to automatically depart. Please prepare for freefall.") : SPAN_WARNING("MANUAL PROCEDURE TIMEOUT. The dropship is beginning to be automatically raised up."), max_distance = 3)
	allow_processing_to_end = FALSE
	force_process(go_down ? DROPSHIP_AIRLOCK_GO_DOWN : DROPSHIP_AIRLOCK_GO_UP)

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/delayed_height_increase()
	internal_relocation_in_progress = TRUE
	docked_mobile.initiate_docking(src)
	internal_relocation_in_progress = FALSE
	for(var/list in inner_airlock_turf_lists)
		list = null
	inner_airlock_turf_lists = null
	for(var/list in outer_airlock_turf_lists)
		list = null
	outer_airlock_turf_lists = null
	end_of_interaction()

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/delayed_disengage_clamps()
	if(!docked_mobile.assigned_transit)
		SSshuttle.generate_transit_dock(docked_mobile)
	docked_mobile.set_mode(SHUTTLE_IDLE)
	internal_relocation_in_progress = TRUE
	docked_mobile.initiate_docking(docked_mobile.assigned_transit)
	internal_relocation_in_progress = FALSE
	refresh_dropship_destination_lists()
	INVOKE_NEXT_TICK(docked_mobile, TYPE_PROC_REF(/obj/docking_port/mobile/marine_dropship, dropship_freefall))
	docked_mobile.update_ambience()
	if(docked_mobile.automated_target_id)
		addtimer(CALLBACK(docked_mobile, TYPE_PROC_REF(/obj/docking_port/mobile/marine_dropship, automated_fly)), 1)



	docked_mobile = null
	lowered_dropship = FALSE
	disengaged_clamps = FALSE
	if(open_outer_airlock)
		linked_outer.get_outer_airlock_turf_lists()
		update_outer_airlock(FALSE, forced = TRUE)
		return

	end_of_interaction()



/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/get_inner_airlock_turf_lists()
	for(var/obj/effect/hangar_airlock/height_mask/static_alpha/stale_mask as anything in tracked_static_alpha_masks)
		qdel(stale_mask)
	tracked_static_alpha_masks = list()

	inner_airlock_turf_lists = list()
	inner_airlock_turf_lists["shuttle"] = list()
	for(var/turf/turf as anything in block(DROPSHIP_AIRLOCK_BOUNDS))
		if(istype(turf.loc, /area/shuttle))
			inner_airlock_turf_lists["shuttle"] += turf
			tracked_static_alpha_masks += new /obj/effect/hangar_airlock/height_mask/static_alpha(turf)
		if(istype(turf, /turf/open/floor/hangar_airlock/inner))
			var/turf/open/floor/hangar_airlock/inner/openable_turf = turf
			if(!inner_airlock_turf_lists?["[openable_turf.frame_threshold]"])
				inner_airlock_turf_lists["[openable_turf.frame_threshold]"] = list()
			inner_airlock_turf_lists["[openable_turf.frame_threshold]"] += openable_turf
			tracked_static_alpha_masks += new /obj/effect/hangar_airlock/height_mask/static_alpha(turf)

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/omnibus_airlock_transition(airlock_type, open, airlock_turf_lists, obj/effect/hangar_airlock/airlock, end_decisecond)
	var/transition = open ? "open" : "close"
	airlock.icon_state = "[transition]_0s"

	omnibus_sound_play('sound/machines/centrifuge.ogg')

	COOLDOWN_START(src, dropship_airlock_cooldown, end_decisecond)
	INVOKE_NEXT_TICK(src, PROC_REF(delayed_airlock_transition), airlock_type, open, airlock_turf_lists, airlock, end_decisecond, transition)

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/omnibus_sound_play(sound_effect)
	playsound(src, sound_effect, 100, vol_cat = VOLUME_AMB)
	playsound(linked_outer, sound_effect, 100, vol_cat = VOLUME_AMB)

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/end_of_interaction()
	COOLDOWN_RESET(src, dropship_airlock_cooldown)
	if(automatic_process_stage_change)
		addtimer(CALLBACK(src, PROC_REF(automatic_process)), DROPSHIP_AIRLOCK_AUTOMATIC_DELAY)
		return
	if(allow_processing_to_end)
		processing = FALSE

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/test_conditions(test_playing_alarm = null, test_open_inner = null, test_lowered_dropship = null, test_open_outer = null, test_disengaged_clamps = null)
	if(test_playing_alarm != null && test_playing_alarm != playing_airlock_alarm)
		return FALSE
	if(test_open_inner != null && test_open_inner != open_inner_airlock)
		return FALSE
	if(test_lowered_dropship != null && test_lowered_dropship != lowered_dropship)
		return FALSE
	if(test_open_outer != null && test_open_outer != open_outer_airlock)
		return FALSE
	if(test_disengaged_clamps != null && test_disengaged_clamps != disengaged_clamps)
		return FALSE
	return TRUE


/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/ceremony_satisfied_for(obj/docking_port/mobile/marine_dropship/requesting_shuttle)
	var/obj/docking_port/stationary/current_dock = requesting_shuttle.get_docked()
	if(!current_dock || SSshuttle.preview_shuttle == requesting_shuttle)





		return TRUE
	return current_dock == linked_outer


/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/resync_airlock_apparatus(reason, resync_physical = FALSE)
	var/obj/docking_port/mobile/marine_dropship/ship_at_inner = get_docked()
	var/obj/docking_port/mobile/marine_dropship/ship_at_outer = linked_outer.get_docked()
	var/target_lowered = (ship_at_outer && !ship_at_inner)

	docked_mobile = target_lowered ? ship_at_outer : null
	playing_airlock_alarm = FALSE
	open_inner_airlock = FALSE
	lowered_dropship = target_lowered
	open_outer_airlock = FALSE
	disengaged_clamps = FALSE

	if(resync_physical)
		COOLDOWN_RESET(src, dropship_airlock_cooldown)

		if(!inner_airlock_turf_lists)
			get_inner_airlock_turf_lists()
		if(!outer_airlock_turf_lists)
			linked_outer.get_outer_airlock_turf_lists()









	if(inner_airlock_effect)
		inner_airlock_effect.icon_state = "close"
	if(outer_airlock_effect)
		outer_airlock_effect.icon_state = "close"







	if(inner_airlock_turf_lists)
		for(var/frame_key in inner_airlock_turf_lists)
			if(frame_key == "shuttle")
				continue
			for(var/turf/open/floor/hangar_airlock/inner/hangar_turf in inner_airlock_turf_lists[frame_key])
				hangar_turf.open = FALSE
				hangar_turf.can_bloody = TRUE
	if(outer_airlock_turf_lists)
		for(var/turf/open/floor/hangar_airlock/outer/hangar_turf in outer_airlock_turf_lists)
			hangar_turf.open = FALSE
			hangar_turf.set_hatch_surface(FALSE)
			hangar_turf.can_bloody = TRUE







	var/obj/structure/machinery/floodlight/landing/dropship_airlock/floodlight
	for(floodlight as anything in floodlights)
		if(istype(floodlight.light?.our_mask, /atom/movable/lighting_mask/rotating_toggleable))
			var/atom/movable/lighting_mask/rotating_toggleable/rotating_mask = floodlight.light.our_mask
			if(rotating_mask.toggled)
				floodlight.toggle_rotating()

	var/obj/structure/machinery/door/poddoor/railing/airlock_railing
	for(airlock_railing as anything in railings)
		airlock_railing.open(TRUE)

	if(docked_mobile)
		docked_mobile.alarm_sound_loop.stop()
		docked_mobile.playing_launch_announcement_alarm = FALSE
		docked_mobile.door_control?.control_doors("unlock", "all")

	if(resync_physical)
		SSfz_transitions.toggle_selective_update(FALSE, dropship_airlock_id)

		automatic_process_stage_change = 0
		automatic_process_stage = 0

		if(reason == "admin_unlock")
			allow_processing_to_end = TRUE
			undergoing_admin_command = FALSE
		if(allow_processing_to_end)
			processing = FALSE

		airlock_state = (reason == "admin_lock") ? AIRLOCK_STATE_ADMIN_LOCKED : AIRLOCK_STATE_IDLE

	refresh_dropship_destination_lists()

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/automatic_process(command = FALSE)
	if(automatic_process_stage_change && command)
		return list("successful" = FALSE, "to_chat" = "A second command has been sent before the first one was resolved.")
	switch(command)
		if(DROPSHIP_AIRLOCK_GO_UP)
			automatic_process_stage = 2
			automatic_process_stage_change = 1
		if(DROPSHIP_AIRLOCK_GO_DOWN)
			automatic_process_stage = 8
			automatic_process_stage_change = -1
	var/list/return_list
	switch(automatic_process_stage)
		if(9)
			automatic_process_stage_change = 0
			automatic_process_stage = 0
			processing = FALSE
		if(8)
			return_list = update_outer_airlock(FALSE)
		if(7)
			return_list = update_airlock_alarm(playing_airlock_alarm ? FALSE : TRUE)
		if(6)
			return_list = update_inner_airlock(open_inner_airlock ? FALSE : TRUE)
		if(5)
			return_list = update_dropship_height(lowered_dropship ? FALSE : TRUE)
		if(4)
			return_list = update_inner_airlock(open_inner_airlock ? FALSE : TRUE)
		if(3)
			return_list = update_airlock_alarm(playing_airlock_alarm ? FALSE : TRUE)
		if(2)
			return_list = update_outer_airlock(automatic_process_stage_change < 0)
		if(1)
			automatic_process_stage_change = 0
			automatic_process_stage = 0
			processing = FALSE
			return_list = update_clamps(TRUE)
		if(0)
			return
	if(return_list)
		. = return_list
		if(!return_list["successful"])
			log_ares_flight("Automatic","Automatic processing of \the [name] has been interrupted because [lowertext(return_list["to_chat"])]")
			ai_silent_announcement("Automatic processing on \the [name] has been interrupted because [lowertext(return_list["to_chat"])]")
			automatic_process_stage_change = 0
			automatic_process_stage = 0
			processing = FALSE
			return
	automatic_process_stage += automatic_process_stage_change

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/force_process(command = FALSE)




	resync_airlock_apparatus("force_process", resync_physical = TRUE)

	for(var/qdel_timer in active_timers)
		qdel(qdel_timer)

	var/number_to_call = 1
	switch(command)
		if(DROPSHIP_AIRLOCK_GO_UP)
			if(!lowered_dropship)
				return 0
			if(open_outer_airlock)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_outer_airlock), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(!playing_airlock_alarm)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_airlock_alarm), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(!open_inner_airlock)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_inner_airlock), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(lowered_dropship)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_dropship_height), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(open_inner_airlock)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_inner_airlock), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(playing_airlock_alarm)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_airlock_alarm), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)

		if(DROPSHIP_AIRLOCK_GO_DOWN)
			if(lowered_dropship)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_inner_airlock), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			else
				if(open_outer_airlock)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_outer_airlock), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
					number_to_call += 1
				if(!playing_airlock_alarm)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_airlock_alarm), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
					number_to_call += 1
				if(!open_inner_airlock)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_inner_airlock), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
					number_to_call += 1
				if(lowered_dropship)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_dropship_height), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
					number_to_call += 1
				if(open_inner_airlock)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_inner_airlock), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
					number_to_call += 1
			if(playing_airlock_alarm)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_airlock_alarm), FALSE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(!open_outer_airlock)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_outer_airlock), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)
				number_to_call += 1
			if(!disengaged_clamps)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_clamps), TRUE, TRUE), number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD)

	return number_to_call * DROPSHIP_AIRLOCK_MAX_THEORETICAL_UPDATE_PERIOD

/obj/docking_port/stationary/marine_dropship/airlock/inner/proc/end_of_admin_command()
	undergoing_admin_command = FALSE
	allow_processing_to_end = TRUE
	processing = FALSE

/obj/docking_port/stationary/marine_dropship/airlock/outer/proc/handle_obscuring_shuttle_turfs()
	for(var/turf/open/open_turf in block(DROPSHIP_AIRLOCK_BOUNDS))
		if(istype(open_turf, /turf/open/floor/hangar_airlock/outer))
			continue
		if(open_turf.clone)
			open_turf.clone.layer = 1.93
			open_turf.clone.color = "#000000"

/obj/docking_port/stationary/marine_dropship/airlock/outer/proc/get_outer_airlock_turf_lists()
	for(var/obj/effect/projector/airlock/stale_projector as anything in linked_inner.tracked_airlock_projectors)
		qdel(stale_projector)
	linked_inner.tracked_airlock_projectors = list()

	linked_inner.outer_airlock_turf_lists = list()
	var/list/offset_to_inner_coordinates = list("x" = (linked_inner.x - src.x), "y" = (linked_inner.y - src.y), "z" = (linked_inner.z - src.z))
	for(var/turf/turf as anything in block(DROPSHIP_AIRLOCK_BOUNDS))
		if(!istype(turf, /turf/open/floor/hangar_airlock/outer) && !istype(turf.loc, /area/shuttle))
			continue
		linked_inner.outer_airlock_turf_lists += turf
		var/obj/effect/projector/airlock/new_projector = new /obj/effect/projector/airlock(turf)
		new_projector.firing_id = dropship_airlock_id
		new_projector.vector_x = offset_to_inner_coordinates["x"]
		new_projector.vector_y = offset_to_inner_coordinates["y"]
		new_projector.register()
		linked_inner.tracked_airlock_projectors += new_projector



/obj/docking_port/stationary/marine_dropship/airlock/inner/Initialize(mapload)
	. = ..()
	GLOB.dropship_airlock_docking_ports.Add(src)
	dropship_height_masks = list()
	floodlights = list()
	door_controls = list()
	poddoors = list()
	railings = list()
	inner_airlock_effect = new /obj/effect/hangar_airlock/inner(locate(DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_EFFECT))
	new /obj/effect/hangar_airlock/outline(locate(DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_EFFECT))



/obj/docking_port/stationary/marine_dropship/airlock/inner/on_departure(obj/docking_port/mobile/departing_shuttle)
	. = ..()




	if(!internal_relocation_in_progress)
		resync_airlock_apparatus("departure", resync_physical = TRUE)

/obj/docking_port/stationary/marine_dropship/airlock/inner/on_arrival(obj/docking_port/mobile/arriving_shuttle)
	. = ..()
	auto_open = FALSE





	if(!internal_relocation_in_progress)
		resync_airlock_apparatus("arrival", resync_physical = TRUE)

	for(var/obj/effect/hangar_airlock/height_mask/dropship/stale_height_mask as anything in dropship_height_masks)
		qdel(stale_height_mask)
	dropship_height_masks = list()
	var/list/dropship_turfs = arriving_shuttle.return_turfs()
	for(var/turf/dropship_turf as anything in dropship_turfs)
		if(istype(dropship_turf, /turf/open/shuttle) || istype(dropship_turf, /turf/closed/shuttle))
			var/obj/effect/hangar_airlock/height_mask/dropship/dropship_height_mask = new /obj/effect/hangar_airlock/height_mask/dropship(dropship_turf)
			dropship_height_masks += dropship_height_mask
			continue
		if(istype(dropship_turf, /turf/open/floor/hangar_airlock/inner))
			var/obj/structure/shuttle/part/dropship_part = locate(/obj/structure/shuttle/part) in dropship_turf.contents
			if(!dropship_part)
				continue
			var/obj/effect/hangar_airlock/height_mask/dropship/dropship_part_height_mask = new /obj/effect/hangar_airlock/height_mask/dropship(dropship_turf)
			dropship_part_height_mask.icon = dropship_part.icon
			dropship_part_height_mask.icon_state = dropship_part.icon_state
			dropship_part_height_mask.color = "#000000"
			dropship_height_masks += dropship_part_height_mask

/obj/docking_port/stationary/marine_dropship/airlock/outer/Initialize(mapload)
	. = ..()
	GLOB.dropship_airlock_docking_ports.Add(src)
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/stationary/marine_dropship/airlock/outer/LateInitialize()
	. = ..()
	for(var/obj/docking_port/stationary/marine_dropship/airlock/inner/inner_port in GLOB.dropship_airlock_docking_ports)
		if(inner_port.dropship_airlock_id == dropship_airlock_id)
			linked_inner = inner_port
	if(!linked_inner)
		WARNING("[name] could not link to its inner counterpart. THE AIRLOCK WILL NOT WORK.")
		return
	linked_inner.linked_outer = src
	build_lower_chamber()
	install_warning_lights()
	var/turf/airlock_effect_turf = locate(DROPSHIP_AIRLOCK_FROM_DOCKPORT_TO_EFFECT)
	linked_inner.outer_airlock_effect = new /obj/effect/hangar_airlock/outer(airlock_effect_turf)
	var/obj/effect/projector/airlock/new_projector = new /obj/effect/projector/airlock(airlock_effect_turf)
	new_projector.firing_id = dropship_airlock_id
	new_projector.vector_x = linked_inner.x - src.x
	new_projector.vector_y = linked_inner.y - src.y
	new_projector.register()
	if(!linked_inner.roundstart_template)
		INVOKE_NEXT_TICK(linked_inner, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, update_outer_airlock), TRUE)

/obj/docking_port/stationary/marine_dropship/airlock/outer/on_departure(obj/docking_port/mobile/departing_shuttle)
	. = ..()



	if(!linked_inner.internal_relocation_in_progress)
		linked_inner.resync_airlock_apparatus("departure", resync_physical = TRUE)

/obj/docking_port/stationary/marine_dropship/airlock/outer/on_arrival(obj/docking_port/mobile/arriving_shuttle)
	. = ..()


	if(!linked_inner.internal_relocation_in_progress)
		linked_inner.resync_airlock_apparatus("arrival", resync_physical = TRUE)
	SSfz_transitions.fire()
	handle_obscuring_shuttle_turfs()
	if(linked_inner.internal_relocation_in_progress)
		return

	if(!istype(arriving_shuttle, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/arriving_dropship = arriving_shuttle
	if((arriving_dropship.automated_hangar_id == src.id) && arriving_dropship.automated_delay && !linked_inner.processing)
		linked_inner.automatic_process(DROPSHIP_AIRLOCK_GO_UP)
	else
		var/obj/structure/machinery/computer/shuttle/dropship/flight/root_console = arriving_dropship.getControlConsole()
		if(root_console)
			root_console.visible_message(message = SPAN_WARNING("DROPSHIP AUTOMATIC RETURN PROCEDURE ACTIVATED. The shuttle will automatically return to the top of the airlock in [DROPSHIP_AIRLOCK_OUTER_AIRLOCK_ACCESS_GRACE_PERIOD * 0.1] seconds if still in a lowered position."), max_distance = 3)
		addtimer(CALLBACK(linked_inner, TYPE_PROC_REF(/obj/docking_port/stationary/marine_dropship/airlock/inner, end_outer_airlock_access), FALSE), DROPSHIP_AIRLOCK_OUTER_AIRLOCK_ACCESS_GRACE_PERIOD)



/obj/effect/hangar_airlock
	layer = ABOVE_TURF_LAYER
	plane = FLOOR_PLANE
	unacidable = TRUE
	mouse_opacity = FALSE
	anchored = TRUE


/obj/effect/hangar_airlock/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(!anchored)
		. = ..()
	return TRUE

/obj/effect/hangar_airlock/inner
	name = "hangar inner airlock"
	icon = 'modular/shuttle_flight/icons/effects/airlock_inner.dmi'
	icon_state = "close"
	layer = 1.95

/obj/effect/hangar_airlock/outer
	name = "hangar outer airlock"
	icon = 'modular/shuttle_flight/icons/effects/airlock_outer.dmi'
	icon_state = "close"
	layer = 1.95

/obj/effect/hangar_airlock/outline
	icon = 'modular/shuttle_flight/icons/effects/airlock_outline.dmi'
	icon_state = "outline"

/obj/effect/hangar_airlock/half_tile
	icon = 'modular/shuttle_flight/icons/effects/airlock_32x32.dmi'
	icon_state = "half_tile"

/obj/effect/hangar_airlock/height_mask
	icon = 'modular/shuttle_flight/icons/effects/airlock_32x32.dmi'
	icon_state = "height_mask"
	layer = 1.94
	alpha = 135
	plane = -7

/obj/effect/hangar_airlock/height_mask/dropship
	name = "transitionary alpha height mask"
	layer = 5.01
	alpha = 0
	plane = -6

/obj/effect/hangar_airlock/height_mask/static_alpha
	name = "static alpha height mask"



/turf/open/floor/hangar_airlock
	turf_flags = NO_FLAGS
	tool_flags = null
	layer = 1.5
	var/frame_threshold = null
	var/open = FALSE

/turf/open/floor/hangar_airlock/outer
	name = "Hangar Outer Airlock"
	icon = 'modular/shuttle_flight/icons/turf/floors/dev/dev_airlock.dmi'
	icon_state = "0"

/turf/open/floor/hangar_airlock/outer/Initialize(mapload, ...)
	. = ..()
	set_hatch_surface(FALSE)

/turf/open/floor/hangar_airlock/outer/proc/set_hatch_surface(is_open)
	if(is_open)
		icon = 'icons/turf/floors/space.dmi'
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	else
		icon = 'icons/turf/almayer.dmi'
		icon_state = "plate"

/turf/open/floor/hangar_airlock/inner
	name = "Hangar Inner Airlock"
	icon = 'modular/shuttle_flight/icons/turf/floors/dev/dev_airlock.dmi'
	icon_state = "plate"

/turf/open/floor/hangar_airlock/inner/Initialize(mapload, ...)
	. = ..()
	icon = 'icons/turf/almayer.dmi'
	icon_state = "plate"



/turf/open/floor/hangar_airlock/Entered(atom/movable/entered_atom)
	if(open)
		if(!isobserver(entered_atom) && !istype(entered_atom, /obj/docking_port) && !istype(entered_atom, /atom/movable/clone) && !istype(entered_atom, /obj/effect/hangar_airlock))
			enter_depths(entered_atom)

/turf/open/floor/hangar_airlock/proc/enter_depths(/atom/movable/entered_atom)
	return

/turf/open/floor/hangar_airlock/inner/enter_depths(atom/movable/entered_atom)
	if(entered_atom.throwing == 0)
		entered_atom.visible_message(SPAN_WARNING("[entered_atom] falls into the depths!"), SPAN_WARNING("You fall into the depths!"))
		for(var/contents_atom in src.contents)
			if(istype(contents_atom, /atom/movable/clone))
				var/atom/movable/clone/clone = contents_atom

				if(istype(get_turf(clone.mstr), /turf/open/floor/hangar_airlock))
					entered_atom.forceMove(locate(clone.mstr.x, clone.mstr.y, clone.mstr.z))
					break

				var/obj/structure/shuttle/part/dropship_part_to_locate
				dropship_part_to_locate = locate(/obj/structure/shuttle/part) in range(4, clone.mstr)
				if(dropship_part_to_locate)
					entered_atom.forceMove(dropship_part_to_locate.loc)
					entered_atom.visible_message(SPAN_WARNING("[entered_atom] slides off the roof of the dropship!"), SPAN_WARNING("You slide off the roof of the dropship!"))
					break

				entered_atom.visible_message(SPAN_WARNING("[entered_atom] falls onto the engines of the dropship, burning into ash!"), SPAN_WARNING("You fall onto the engines of the dropship, burning into ash!"))
				qdel(entered_atom)
				break

		INVOKE_ASYNC(src, PROC_REF(depths_damage), entered_atom)

/turf/open/floor/hangar_airlock/inner/proc/depths_damage(atom/movable/entered_atom)
	if(!isliving(entered_atom))
		return
	var/mob/living/fallen_living = entered_atom
	fallen_living.visible_message(SPAN_WARNING("[fallen_living] splatters onto the ground with a thud!"), SPAN_BOLDWARNING("You splatter onto the ground with a thud!"))
	if(iscarbon(fallen_living))
		var/mob/living/carbon/fallen_carbon = fallen_living
		fallen_carbon.gib(create_cause_data("falling into an open dropship airlock", fallen_carbon))
		return
	qdel(entered_atom)

/turf/open/floor/hangar_airlock/outer/enter_depths(atom/movable/entered_atom)
	if(entered_atom.throwing == 0 && istype(get_turf(entered_atom), /turf/open/floor/hangar_airlock))
		entered_atom.visible_message(SPAN_WARNING("There is an onrush of air. [entered_atom] falls into space!"), SPAN_WARNING("There is an onrush of air. You fall into space!"))
		qdel(entered_atom)



/turf/open/floor/almayer/plate/hangar_1
	icon_state = "hangar_1"
	name = "Hangar Airlock One"

/turf/open/floor/almayer/plate/hangar_2
	icon_state = "hangar_2"
	name = "Hangar Airlock Two"

/turf/open/floor/hangar_airlock/inner/frame5
	frame_threshold = 5
	icon_state = "5"

/turf/open/floor/hangar_airlock/inner/frame9
	frame_threshold = 9
	icon_state = "9"

/turf/open/floor/hangar_airlock/inner/frame11
	frame_threshold = 11
	icon_state = "11"

/turf/open/floor/hangar_airlock/inner/frame13
	frame_threshold = 13
	icon_state = "13"

/turf/open/floor/hangar_airlock/inner/frame17
	frame_threshold = 17
	icon_state = "17"

/turf/open/floor/hangar_airlock/inner/frame21
	frame_threshold = 21
	icon_state = "21"

/turf/open/floor/hangar_airlock/inner/frame25
	frame_threshold = 25
	icon_state = "25"

/turf/open/floor/hangar_airlock/inner/frame30
	frame_threshold = 30
	icon_state = "30"

/turf/open/floor/hangar_airlock/inner/frame33
	frame_threshold = 33
	icon_state = "33"

/turf/open/floor/hangar_airlock/inner/frame35
	frame_threshold = 35
	icon_state = "35"

/turf/open/floor/hangar_airlock/inner/frame40
	frame_threshold = 40
	icon_state = "40"

/turf/open/floor/hangar_airlock/inner/frame49
	frame_threshold = 49
	icon_state = "49"

/turf/open/floor/hangar_airlock/outer/frame4
	frame_threshold = 4
	icon_state = "_4"

/turf/open/floor/hangar_airlock/outer/frame11
	frame_threshold = 11
	icon_state = "_11"

/turf/open/floor/hangar_airlock/outer/frame19
	frame_threshold = 19
	icon_state = "_19"

/turf/open/floor/hangar_airlock/outer/frame27
	frame_threshold = 27
	icon_state = "_27"

/turf/open/floor/hangar_airlock/outer/frame35
	frame_threshold = 35
	icon_state = "_35"

/turf/open/floor/hangar_airlock/outer/frame43
	frame_threshold = 43
	icon_state = "_43"

/turf/open/floor/hangar_airlock/outer/frame49
	frame_threshold = 49
	icon_state = "_49"
