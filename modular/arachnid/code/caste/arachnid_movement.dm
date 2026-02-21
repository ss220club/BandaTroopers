/datum/xeno_ai_movement/arachnid
	do_climb_structures = TRUE

/datum/xeno_ai_movement/arachnid/ai_move_hive(delta_time)
	. = ..()

	/// This will mean if the alien is pulling someone to the hive, they will keep tackling them with their free claw.
	if(. && parent.pulling && DT_PROB(XENO_SLASH, delta_time)) INVOKE_ASYNC(parent, TYPE_PROC_REF(/mob, do_click), parent.pulling, "", list())

/datum/xeno_ai_movement/arachnid/ai_strap_host(turf/closest_hive, hive_radius, delta_time)
	/// Want to make sure when nesting, they actually have the grab active in their main claw.
	/// This can lead to some funny behavior of the alien standing around with the victim next to them, but it should be fine for the moment.
	/// Something to address later perhaps.
	if(parent.pulling && parent.get_active_hand()) parent.swap_hand()
	return ..()

