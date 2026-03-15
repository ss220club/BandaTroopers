/datum/modpack/localization
	name = "Localization"
	desc = "Modular localization hooks and localized Human AI speech packs."
	author = "PhantomRU"

/datum/modpack/localization/initialize()
	. = ..()
	if(!SShuman_ai)
		return "Human AI subsystem is unavailable."

	if(SShuman_ai.initialized)
		halo_ai_localize_human_ai_factions(SShuman_ai)
		return

	RegisterSignal(SShuman_ai, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(handle_human_ai_post_initialize))

/datum/modpack/localization/proc/handle_human_ai_post_initialize(datum/controller/subsystem/human_ai/subsystem)
	SIGNAL_HANDLER

	UnregisterSignal(subsystem, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	halo_ai_localize_human_ai_factions(subsystem)
