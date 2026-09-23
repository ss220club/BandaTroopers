/datum/round_cinematics_session
	var/datum/round_cinematics_controller/controller
	var/mob/owner
	var/client/client
	var/datum/round_cinematics_sequence/sequence = null
	var/obj/structure/machinery/cryopod/source_pod = null
	var/preview = FALSE
	var/cleaned_up = FALSE
	var/cleanup_reason = null
	var/completion_reason = "cleanup"
	var/list/active_texts = list()
	var/list/active_fullscreens = list()
	var/list/active_static_screens = list()
	var/hud_hidden = FALSE
	var/saved_hud_version = HUD_STYLE_STANDARD
	var/saved_hud_shown = TRUE
	var/saved_inventory_shown = TRUE
	var/saved_action_buttons_hidden = FALSE
	var/saved_hotkey_ui_hidden = FALSE
	var/start_time = 0
	var/skip_allowed_at = 0
	var/hard_timeout_at = 0
	/// Saved sleeping value before session lock (P1.7)
	var/saved_sleeping = 0
	/// Whether to lock sleeping during this session (intro only)
	var/should_lock_sleeping = FALSE

/datum/round_cinematics_session/New(datum/round_cinematics_controller/controller, mob/owner, preview = FALSE)
	..()
	src.controller = controller
	src.owner = owner
	src.client = owner?.client
	src.preview = preview

/datum/round_cinematics_session/proc/begin()
	start_time = world.time
	// P1.7: Save sleeping before locking (only for intro sessions)
	if(should_lock_sleeping && isliving(owner))
		var/mob/living/L = owner
		saved_sleeping = L.sleeping
		// P1.8: Lock player during intro session
		L.sleeping = 11
	RegisterSignal(owner, list(COMSIG_MOB_LOGOUT, COMSIG_PARENT_QDELETING), PROC_REF(handle_owner_signal))
	if(source_pod && !preview)
		RegisterSignal(source_pod, COMSIG_CRYOPOD_GO_OUT, PROC_REF(handle_pod_exit))
	hide_hud()
	apply_static_chrome()
	INVOKE_ASYNC(src, PROC_REF(play_sequence))
	if(hard_timeout_at > start_time)
		addtimer(CALLBACK(controller, TYPE_PROC_REF(/datum/round_cinematics_controller, force_finish_for), owner, "hard timeout"), hard_timeout_at - start_time)

/datum/round_cinematics_session/proc/play_sequence()
	if(sequence)
		sequence.execute(src)
	if(!cleaned_up)
		finish_session(completion_reason)

/datum/round_cinematics_session/proc/handle_owner_signal(datum/source)
	SIGNAL_HANDLER
	finish_session("owner signal")

/datum/round_cinematics_session/proc/handle_pod_exit(datum/source)
	SIGNAL_HANDLER
	finish_session("pod exit")

/datum/round_cinematics_session/proc/track_text(atom/movable/screen/text/round_cinematics/text_box)
	if(!text_box)
		return
	if(!(text_box in active_texts))
		active_texts += text_box

/datum/round_cinematics_session/proc/apply_fullscreen(category, type, severity = 0)
	if(!owner || cleaned_up || !category || !type)
		return null

	var/atom/movable/screen/fullscreen/screen = owner.overlay_fullscreen(category, type, severity)
	if(!screen)
		return null

	screen.clear_with_screen = FALSE
	screen.alpha = 0
	animate(screen, alpha = initial(screen.alpha), time = 0.3 SECONDS)
	if(!(category in active_fullscreens))
		active_fullscreens += category
	return screen

/datum/round_cinematics_session/proc/hide_hud()
	if(hud_hidden || !owner?.hud_used)
		return

	hud_hidden = TRUE
	saved_hud_version = owner.hud_used.hud_version
	saved_hud_shown = owner.hud_used.hud_shown
	saved_inventory_shown = owner.hud_used.inventory_shown
	saved_action_buttons_hidden = owner.hud_used.action_buttons_hidden
	saved_hotkey_ui_hidden = owner.hud_used.hotkey_ui_hidden
	owner.hud_used.show_hud(HUD_STYLE_NOHUD, owner)

/datum/round_cinematics_session/proc/restore_hud()
	if(!hud_hidden || !owner?.hud_used)
		return

	owner.hud_used.hud_shown = saved_hud_shown
	owner.hud_used.inventory_shown = saved_inventory_shown
	owner.hud_used.action_buttons_hidden = saved_action_buttons_hidden
	owner.hud_used.hotkey_ui_hidden = saved_hotkey_ui_hidden
	owner.hud_used.show_hud(saved_hud_version, owner)
	hud_hidden = FALSE

/datum/round_cinematics_session/proc/abort_texts()
	if(!length(active_texts))
		return

	for(var/atom/movable/screen/text/round_cinematics/text_box as anything in active_texts.Copy())
		if(!text_box)
			continue
		text_box.abort_play()
	active_texts.Cut()

/datum/round_cinematics_session/proc/clear_fullscreens()
	if(!owner || !length(active_fullscreens))
		return

	for(var/category in active_fullscreens.Copy())
		owner.clear_fullscreen(category, 0)
	active_fullscreens.Cut()

/datum/round_cinematics_session/proc/apply_static_chrome()
	if(!client || cleaned_up)
		return

	// Header
	var/atom/movable/screen/text/round_cinematics/header/header_screen = new
	header_screen.player = client
	header_screen.maptext = sequence?.get_header_html()
	client.add_to_screen(header_screen)
	active_static_screens += header_screen

	// Footer
	var/atom/movable/screen/text/round_cinematics/footer/footer_screen = new
	footer_screen.player = client
	footer_screen.maptext = sequence?.get_footer_html()
	client.add_to_screen(footer_screen)
	active_static_screens += footer_screen

	// Scanline
	var/atom/movable/screen/round_cinematics/scanline/scanline_screen = new
	client.add_to_screen(scanline_screen)
	active_static_screens += scanline_screen

	// Vignette
	var/atom/movable/screen/round_cinematics/vignette/vignette_screen = new
	client.add_to_screen(vignette_screen)
	active_static_screens += vignette_screen

/datum/round_cinematics_session/proc/clear_static_chrome()
	if(!length(active_static_screens))
		return

	for(var/atom/movable/screen/screen as anything in active_static_screens.Copy())
		if(client)
			client.remove_from_screen(screen)
		qdel(screen)
	active_static_screens.Cut()

/datum/round_cinematics_session/proc/is_skip_allowed()
	return skip_allowed_at && world.time >= skip_allowed_at

/datum/round_cinematics_session/proc/finish_session(reason = "cleanup")
	if(cleaned_up)
		return

	cleaned_up = TRUE
	cleanup_reason = reason
	UnregisterSignal(owner, list(COMSIG_MOB_LOGOUT, COMSIG_PARENT_QDELETING))
	if(source_pod)
		UnregisterSignal(source_pod, COMSIG_CRYOPOD_GO_OUT)
	abort_texts()
	clear_fullscreens()
	clear_static_chrome()
	restore_hud()
	// P1.7: Restore saved sleeping value (only if we locked it)
	if(should_lock_sleeping && isliving(owner))
		var/mob/living/L = owner
		L.sleeping = saved_sleeping
	controller?.on_session_finished(src)

/datum/round_cinematics_session/Destroy()
	if(!cleaned_up)
		finish_session("destroy")
	return ..()
