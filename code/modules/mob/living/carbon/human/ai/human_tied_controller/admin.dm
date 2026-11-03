// Admin/debug helper primitives

/datum/human_tied_controller/proc/message_admins_for_puppet(message)
	if(!can_read_puppet() || !message)
		return FALSE
	message_admins(message, tied_human.x, tied_human.y, tied_human.z)
	return TRUE
