/// Returns the RTO support controller bound to this human.
/mob/living/carbon/human/proc/get_rto_support_controller()
	return GLOB.rto_support_registry?.get_controller(src)

/// Returns an existing controller or creates one for this human.
/mob/living/carbon/human/proc/ensure_rto_support_controller()
	return GLOB.rto_support_registry?.ensure_controller(src)

/// Removes the controller bound to this human.
/mob/living/carbon/human/proc/remove_rto_support_controller()
	return GLOB.rto_support_registry?.remove_controller(src)
