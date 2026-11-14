/obj/structure/machinery/door_control/navalis_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("The Industrial Rig lockdown cannot be lifted yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The Industrial Rig lockdown has already been lifted."))
		return
	. = ..()
	marine_announcement("The Industrial Rig primary entrance lockdown has been lifted.")
	xeno_announcement("The hosts have opened the entrance to the industrial area! Beware of the imminent southern attack!")
	used = TRUE


/obj/structure/machinery/door_control/navalis_charon_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_charon_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("The vehicle accessway cannot be opened yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The vehicle accessway has already been opened."))
		return
	. = ..()
	marine_announcement("The PSV Charon vehicle accessway has been opened.")
	xeno_announcement("The hosts have opened the supply vessels accessway! Be wary of a northern flank!")
	used = TRUE


/obj/structure/machinery/door_control/navalis_comms_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_comms_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("The internal access path cannot be opened yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The internal access path has already been opened."))
		return
	. = ..()
	marine_announcement("The Industrial Rig's secondary vehicle access blastdoors have been opened.")
	used = TRUE


/obj/structure/machinery/door_control/navalis_industrial_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_industrial_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("The internal access path cannot be opened yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The internal access path has already been opened."))
		return
	. = ..()
	marine_announcement("The Industrial Rig's internal blastdoors have been opened.")
	xeno_announcement("Be wary! The hosts have opened the internal blastdoors of the industrial rig. This area may now be far harder to hold!")
	used = TRUE


/obj/structure/machinery/door_control/navalis_walkway_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_walkway_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("This external access blastdoor cannot be sealed off yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The external access blastdoor has already been sealed off."))
		return
	. = ..()
	marine_announcement("The Industrial Rig's external eastern blastdoor has been permanently sealed off.")
	xeno_announcement("The hosts have shut off the external lattice access to the industrial area! We can now no longer access this area via our hidden external walkway!")
	used = TRUE


/obj/structure/machinery/door_control/navalis_digsite_nw_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_digsite_nw_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("This external access blastdoor cannot be sealed off yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The external access blastdoor has already been sealed off."))
		return
	. = ..()
	marine_announcement("The Mining Platforms external blastdoors have been sealed off. The xenomorphs will no longer be able to use this area to cross over to the primary rig structure.")
	xeno_announcement("The hosts sealed off the exteral walkway doors in the Mining Platform! We will no longer be able to use this to cross over easily to the main rig!")
	used = TRUE


/obj/structure/machinery/door_control/navalis_command_lockdown
	var/used = FALSE
	var/colony_lockdown_time = 25 MINUTES

/obj/structure/machinery/door_control/navalis_command_lockdown/use_button(mob/living/user,force)
	if(world.time < SSticker.mode.round_time_lobby + colony_lockdown_time)
		to_chat(user, SPAN_WARNING("This external access blastdoor cannot be opened yet. Please wait another [floor((SSticker.mode.round_time_lobby + colony_lockdown_time-world.time)/600)] minutes before trying again."))
		return
	if(used)
		to_chat(user, SPAN_WARNING("The external access blastdoor has already been opened off."))
		return
	. = ..()
	marine_announcement("The Command - Logistic rig level 2 bridge access  blastdoor has been opened.")
	xeno_announcement("The hosts have opened the upper bridge access to the Command rig!")
	used = TRUE
