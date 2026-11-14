/datum/squad/iasf
	name = SQUAD_IASF
	equipment_color = "#9a1228"
	chat_color = "#9a1228"
	radio_freq = IASF_FREQ
	minimap_color = "#9a1228"
	use_stripe_overlay = FALSE
	faction = FACTION_IASF
	active = TRUE
	roundstart = FALSE
	usable = TRUE
	locked = TRUE

/datum/squad_type/iasf_watch
	parent_type = /datum/squad_type/rmc_troop
	lead_name = "Platoon Sergeant"
	sub_squad = "Team"
	sub_leader = "Team Leader"

/datum/squad/marine/iasf
	name = SQUAD_IASF_TURING
	equipment_color = "#9a1228"
	chat_color = "#9a1228"
	minimap_color = "#9a1228"
	use_stripe_overlay = FALSE
	radio_freq = IASF_FREQ
	usable = TRUE
	squad_one_access = ACCESS_TWE_SQUAD_ONE
	squad_two_access = ACCESS_TWE_SQUAD_TWO
	faction = FACTION_IASF
	squad_type_datum = /datum/squad_type/iasf_watch

/datum/squad/marine/iasf/New()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_PLATOON_NAME_CHANGE, PROC_REF(rename_platoon))

/datum/squad/marine/iasf/put_marine_in_squad(mob/living/carbon/human/marine, obj/item/card/id/ID)
	. = ..()
	if(!.)
		return

	var/fireteam
	var/tracker_target
	switch(marine.job)
		if(JOB_IASF_SERGEANT)
			fireteam = "SQ1"
			tracker_target = TRACKER_PLTCO
		if(JOB_IASF_BREACHER, JOB_IASF_ENGINEER, JOB_IASF_TROOPER)
			fireteam = "SQ1"
			tracker_target = TRACKER_SL
		if(JOB_IASF_TEAM)
			fireteam = "SQ2"
			tracker_target = TRACKER_SL
		if(JOB_IASF_MEDIC, JOB_IASF_GUNNER, JOB_IASF_SNIPER)
			fireteam = "SQ2"
			tracker_target = TRACKER_FTL
	if(!fireteam)
		return
	if(marine.assigned_fireteam != fireteam)
		assign_fireteam(fireteam, marine)
	if(marine.job == JOB_IASF_TEAM && fireteam_leaders[fireteam] != marine)
		assign_ft_leader(fireteam, marine)
	for(var/obj/item/device/radio/headset/almayer/marine/solardevils/rmc/iasf/headset in list(marine.wear_l_ear, marine.wear_r_ear))
		headset.set_tracker_target(tracker_target)
