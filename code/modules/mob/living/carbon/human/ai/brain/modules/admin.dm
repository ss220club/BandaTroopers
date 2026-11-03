/datum/human_ai_module/admin
	module_id = "admin"

/datum/human_ai_module/admin/on_ai_event(datum/human_ai_event/event)
	switch(event.event_type)
		if(HUMAN_AI_EVENT_INITIALIZED)
			on_initialized()
		if(HUMAN_AI_EVENT_HANDCUFFED)
			on_handcuffed()

/datum/human_ai_module/admin/proc/on_initialized()
	context?.controller?.set_safe_intent()

/datum/human_ai_module/admin/on_handcuffed()
	var/datum/human_tied_controller/controller = context?.controller
	if(!controller || controller.is_stat_at_least(DEAD) || controller.can_player_takeover_block_ai())
		return

	controller.message_admins_for_puppet("AI human [controller.get_real_name()] has been handcuffed while alive or unconscious.")
