/datum/modpack/halo
	name = "HALO"
	desc = "Modular HALO content and integration hooks."
	author = "CMSS13-PVE-HALO, PhantomRU"

/datum/modpack/halo/initialize()
	. = ..()
	if(!SShuman_ai)
		return "Human AI subsystem is unavailable."

	if(SShuman_ai.initialized)
		apply_human_ai_faction_bridge(SShuman_ai)
		return

	RegisterSignal(SShuman_ai, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(handle_human_ai_post_initialize))

/datum/modpack/halo/proc/handle_human_ai_post_initialize(datum/controller/subsystem/human_ai/subsystem)
	SIGNAL_HANDLER

	UnregisterSignal(subsystem, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	apply_human_ai_faction_bridge(subsystem)

// Validate the HALO faction entries and then extend the existing USCM datum.
/datum/modpack/halo/proc/apply_human_ai_faction_bridge(datum/controller/subsystem/human_ai/subsystem)
	require_human_ai_faction(subsystem, FACTION_UNSC)
	require_human_ai_faction(subsystem, FACTION_UNSCN)
	require_human_ai_faction(subsystem, FACTION_ONI)
	require_human_ai_faction(subsystem, FACTION_UEG_POLICE)
	require_human_ai_faction(subsystem, FACTION_INSURGENT)
	require_human_ai_faction(subsystem, FACTION_COVENANT)

	var/datum/human_ai_faction/marine_faction = require_human_ai_faction(subsystem, FACTION_MARINE)
	marine_faction.add_friendly_faction(FACTION_UNSC)
	marine_faction.add_friendly_faction(FACTION_UNSCN)
	marine_faction.add_friendly_faction(FACTION_ONI)
	marine_faction.add_friendly_faction(FACTION_UEG_POLICE)

/datum/modpack/halo/proc/require_human_ai_faction(datum/controller/subsystem/human_ai/subsystem, faction_name)
	if(!subsystem)
		CRASH("HALO human AI faction bridge ran without the Human AI subsystem.")

	var/datum/human_ai_faction/faction = subsystem.human_ai_factions[faction_name]
	if(!faction)
		CRASH("HALO expected human_ai_faction [faction_name] to exist after Human AI initialization.")

	return faction
