
SUBSYSTEM_DEF(human_ai)
	name = "Human AI"
	priority = SS_PRIORITY_HUMAN_AI
	wait = 0.2 SECONDS
	/// A list of mobs scheduled to process
	var/list/mob/living/carbon/human/current_run = list()

	var/ai_kill = FALSE

	/// List of current squads
	var/list/datum/human_ai_squad/squads = list()

	/// Dict of "id" : squad
	var/list/squad_id_dict = list()

	/// The current highest ID of any squad
	var/highest_squad_id = 0

	/// List of all existing orders
	var/list/datum/ai_order/existing_orders = list()

	var/list/human_ai_factions = list()

	/// If TRUE, then combat has been initiated at some point ever. Used for optimization reasons
	var/combat_ever_started = FALSE

	/// Patient -> human AI brain currently allowed to treat that patient.
	var/list/treatment_reservations = list()
	/// Patient -> world.time when the treatment reservation expires.
	var/list/treatment_reservation_expiries = list()

/datum/controller/subsystem/human_ai/Initialize()
	for(var/faction_path in subtypesof(/datum/human_ai_faction))
		var/datum/human_ai_faction/faction_obj = new faction_path
		human_ai_factions[faction_obj.faction] = faction_obj
	return SS_INIT_SUCCESS

/datum/controller/subsystem/human_ai/stat_entry(msg)
	msg = "P:[length(GLOB.human_ai_brains)]"
	// SS220 EDIT: let modular packs append subsystem-specific diagnostics without baking them into hardcode
	if(hascall(src, "modular_stat_entry_suffix"))
		var/suffix = call(src, "modular_stat_entry_suffix")()
		if(suffix)
			msg += " | [suffix]"
	return ..()

/datum/admins/proc/toggle_human_ai()
	set name = "Toggle Human AI"
	set category = "Game Master.Flags"

	if(!check_rights(R_DEBUG))
		return

	SShuman_ai.ai_kill = !SShuman_ai.ai_kill
	message_admins("[key_name_admin(usr)] [SShuman_ai.ai_kill? "killed" : "revived"] all human AI.")

/datum/controller/subsystem/human_ai/fire(resumed = FALSE)
	if(ai_kill)
		return

	if(!resumed)
		src.current_run = GLOB.human_ai_brains.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	while(length(current_run))
		var/datum/human_ai_brain/brain = current_run[length(current_run)]
		current_run.len--
		if(!QDELETED(brain)) // SS220 EDIT: brain.process() owns player-control/dead/incap lifecycle gating
			brain.process(wait * 0.1)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/human_ai/proc/create_new_squad()
	highest_squad_id++
	var/datum/human_ai_squad/new_squad = new
	squads += new_squad
	squad_id_dict["[highest_squad_id]"] = new_squad
	return new_squad

/datum/controller/subsystem/human_ai/proc/get_squad(squad_id)
	RETURN_TYPE(/datum/human_ai_squad)

	if(!squad_id || !(squad_id in squad_id_dict))
		return null
	return squad_id_dict[squad_id]

/datum/controller/subsystem/human_ai/proc/try_reserve_treatment(mob/living/carbon/human/patient, datum/human_ai_brain/healer, duration = 15 SECONDS)
	if(QDELETED(patient) || QDELETED(healer))
		return FALSE

	cleanup_treatment_reservation(patient)
	var/datum/human_ai_brain/current_healer = treatment_reservations[patient]
	if(current_healer && current_healer != healer)
		return FALSE

	var/expires_at = world.time + duration
	treatment_reservations[patient] = healer
	treatment_reservation_expiries[patient] = expires_at
	addtimer(CALLBACK(src, PROC_REF(expire_treatment_reservation), patient, healer, expires_at), duration, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)
	return TRUE

/datum/controller/subsystem/human_ai/proc/release_treatment_reservation(mob/living/carbon/human/patient, datum/human_ai_brain/healer)
	if(!patient || !(patient in treatment_reservations))
		return FALSE
	if(healer && treatment_reservations[patient] != healer)
		return FALSE

	treatment_reservations -= patient
	treatment_reservation_expiries -= patient
	return TRUE

/datum/controller/subsystem/human_ai/proc/release_treatment_reservations_for(datum/human_ai_brain/healer)
	if(!healer || !length(treatment_reservations))
		return

	for(var/mob/living/carbon/human/patient as anything in treatment_reservations.Copy())
		if(treatment_reservations[patient] == healer)
			release_treatment_reservation(patient, healer)

/datum/controller/subsystem/human_ai/proc/cleanup_treatment_reservation(mob/living/carbon/human/patient)
	if(!patient || !(patient in treatment_reservations))
		return

	var/datum/human_ai_brain/current_healer = treatment_reservations[patient]
	var/expires_at = treatment_reservation_expiries[patient]
	if(QDELETED(patient) || QDELETED(current_healer) || world.time >= expires_at)
		release_treatment_reservation(patient, current_healer)

/datum/controller/subsystem/human_ai/proc/expire_treatment_reservation(mob/living/carbon/human/patient, datum/human_ai_brain/healer, expected_expiry)
	if(!patient || !(patient in treatment_reservations))
		return
	if(treatment_reservations[patient] != healer)
		return
	if(treatment_reservation_expiries[patient] != expected_expiry)
		return

	release_treatment_reservation(patient, healer)
