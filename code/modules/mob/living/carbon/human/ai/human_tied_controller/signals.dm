// Listener-aware puppet signal primitives

/datum/human_tied_controller/proc/register_signal_for(datum/listener, signal, proc_ref, override = FALSE)
	if(!listener || !can_read_puppet())
		return FALSE
	listener.RegisterSignal(tied_human, signal, proc_ref, override)
	return TRUE

/datum/human_tied_controller/proc/unregister_signal_for(datum/listener, signal)
	if(!listener || !has_tied_human())
		return FALSE
	listener.UnregisterSignal(tied_human, signal)
	return TRUE
