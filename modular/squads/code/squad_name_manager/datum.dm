/datum/squad_name_manager
	var/initialized = FALSE
	var/list/managed_static_names = list(SQUAD_MARINE_1, SQUAD_MARINE_2, SQUAD_MARINE_3, SQUAD_MARINE_4)
	var/list/squad_type_by_static = list(
		SQUAD_MARINE_1 = /datum/squad/marine/alpha,
		SQUAD_MARINE_2 = /datum/squad/marine/bravo,
		SQUAD_MARINE_3 = /datum/squad/marine/charlie,
		SQUAD_MARINE_4 = /datum/squad/marine/delta,
	)
	var/list/static_by_squad_type = list(
		/datum/squad/marine/alpha = SQUAD_MARINE_1,
		/datum/squad/marine/bravo = SQUAD_MARINE_2,
		/datum/squad/marine/charlie = SQUAD_MARINE_3,
		/datum/squad/marine/delta = SQUAD_MARINE_4,
	)
	var/list/runtime_name_by_static = list()
	var/list/default_name_by_static = list(
		SQUAD_MARINE_1 = SQUAD_MARINE_1_DEFAULT_NAME,
		SQUAD_MARINE_2 = SQUAD_MARINE_2_DEFAULT_NAME,
		SQUAD_MARINE_3 = SQUAD_MARINE_3_DEFAULT_NAME,
		SQUAD_MARINE_4 = SQUAD_MARINE_4_DEFAULT_NAME,
	)
	var/list/leader_lock_by_static = list()

/datum/squad_name_manager/New()
	. = ..()
	reset_runtime_names()
	reset_leader_locks()

/datum/squad_name_manager/proc/initialize_manager()
	if(initialized)
		return
	initialized = TRUE
	RegisterSignal(SSdcs, COMSIG_GLOB_MODE_POSTSETUP, PROC_REF(on_mode_postsetup))

/datum/squad_name_manager/proc/on_mode_postsetup(datum/source)
	SIGNAL_HANDLER
	apply_roundstart_defaults()

/datum/squad_name_manager/proc/reset_runtime_names()
	runtime_name_by_static = list(
		SQUAD_MARINE_1 = SQUAD_MARINE_1,
		SQUAD_MARINE_2 = SQUAD_MARINE_2,
		SQUAD_MARINE_3 = SQUAD_MARINE_3,
		SQUAD_MARINE_4 = SQUAD_MARINE_4,
	)

/datum/squad_name_manager/proc/reset_leader_locks()
	leader_lock_by_static = list(
		SQUAD_MARINE_1 = FALSE,
		SQUAD_MARINE_2 = FALSE,
		SQUAD_MARINE_3 = FALSE,
		SQUAD_MARINE_4 = FALSE,
	)
