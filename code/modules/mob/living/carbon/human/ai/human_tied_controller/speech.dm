// Raw speech/conversation primitives

/datum/human_tied_controller/proc/say(message)
	if(!can_mutate_puppet() || !message)
		return FALSE
	tied_human.say(message)
	return TRUE

/datum/human_tied_controller/proc/turn_to_conversation_partner(datum/human_tied_controller/partner)
	if(!can_directly_control() || !partner?.can_read_puppet())
		return FALSE
	var/turf/partner_turf = partner.get_current_turf()
	if(!partner_turf)
		return FALSE
	tied_human.setDir(get_cardinal_dir(tied_human, partner_turf))
	return TRUE
