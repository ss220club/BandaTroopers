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
	squad_type_datum = /datum/squad_type/rmc_troop

/datum/squad/marine/iasf/New()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_PLATOON_NAME_CHANGE, PROC_REF(rename_platoon))
