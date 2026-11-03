/// Returns a human AI brain, if this human has one
/mob/living/carbon/human/proc/get_ai_brain()
	RETURN_TYPE(/datum/human_ai_brain)

	var/list/out_brain = list()
	SEND_SIGNAL(src, COMSIG_HUMAN_GET_AI_BRAIN, out_brain)
	if(length(out_brain))
		return out_brain[1]

/// Hacky getter proc used as part of the get_ai_brain() proc
/datum/human_ai_brain/proc/get_ai_brain(datum/source, list/out_brain)
	SIGNAL_HANDLER

	out_brain += src

/// Announces whenever an AI is handcuffed so that GMs can force someone in or take over themselves
/datum/human_ai_brain/proc/on_handcuffed(datum/source)
	SIGNAL_HANDLER
	emit_handcuffed()
