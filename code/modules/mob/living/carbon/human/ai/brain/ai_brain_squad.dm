/datum/human_ai_squad
	/// Name of the squad, only visible to GMs
	var/name
	/// Numeric ID of the squad
	var/id
	/// The AI humans in the squad
	var/list/ai_in_squad = list()
	/// Primary order assigned to this squad
	var/datum/ai_order/current_order
	/// Ref to the squad leader brain
	var/datum/human_ai_brain/squad_leader

/datum/human_ai_squad/New()
	. = ..()
	id = get_human_ai_runtime_highest_squad_id()

/datum/human_ai_squad/Destroy(force, ...)
	for(var/datum/human_ai_brain/brain as anything in ai_in_squad)
		remove_from_squad(brain)
	var/list/runtime_squad_id_dict = get_human_ai_runtime_squad_id_dict()
	if(islist(runtime_squad_id_dict) && !isnull(id))
		runtime_squad_id_dict["[id]"] = null
	var/list/runtime_squads = get_human_ai_runtime_squads()
	if(islist(runtime_squads))
		runtime_squads -= src
	squad_leader = null
	return ..()

/datum/human_ai_squad/proc/poke_member_v2(datum/human_ai_brain/member)
	if(!member?.tied_human)
		return
	member.tied_human.request_human_ai_v2_reconcile(item_search = FALSE, fire_line = FALSE, cover_scan = FALSE, wake_now = TRUE)

/datum/human_ai_squad/proc/add_to_squad(datum/human_ai_brain/adding)
	var/list/runtime_squad_id_dict = get_human_ai_runtime_squad_id_dict()
	if(adding.squad_id && islist(runtime_squad_id_dict) && (adding.squad_id in runtime_squad_id_dict))
		var/datum/human_ai_squad/squad = runtime_squad_id_dict[adding.squad_id]
		squad.remove_from_squad(adding)
	adding.squad_id = id
	ai_in_squad += adding

	adding.set_current_order(current_order)
	poke_member_v2(adding)
	RegisterSignal(adding.tied_human, COMSIG_MOB_DEATH, PROC_REF(on_squad_member_death))
	RegisterSignal(adding, COMSIG_PARENT_QDELETING, PROC_REF(on_squad_member_delete))

/datum/human_ai_squad/proc/remove_from_squad(datum/human_ai_brain/removing)
	if(removing == squad_leader)
		set_squad_leader(null)
	removing.remove_current_order()
	removing.squad_id = null
	removing.is_squad_leader = FALSE
	ai_in_squad -= removing
	poke_member_v2(removing)
	if(removing.tied_human)
		UnregisterSignal(removing.tied_human, COMSIG_MOB_DEATH)
	UnregisterSignal(removing, COMSIG_PARENT_QDELETING)

/datum/human_ai_squad/proc/set_current_order(datum/ai_order/order)
	if(current_order)
		UnregisterSignal(current_order, COMSIG_PARENT_QDELETING)
	current_order = order
	if(order)
		RegisterSignal(order, COMSIG_PARENT_QDELETING, PROC_REF(on_order_delete))
	for(var/datum/human_ai_brain/brain as anything in ai_in_squad)
		brain.set_current_order(order)
		poke_member_v2(brain)

/datum/human_ai_squad/proc/remove_current_order()
	if(current_order)
		UnregisterSignal(current_order, COMSIG_PARENT_QDELETING)
	current_order = null
	for(var/datum/human_ai_brain/brain as anything in ai_in_squad)
		brain.remove_current_order()
		poke_member_v2(brain)

/datum/human_ai_squad/proc/set_squad_leader(datum/human_ai_brain/new_leader)
	if(squad_leader)
		squad_leader.is_squad_leader = FALSE
		poke_member_v2(squad_leader)
	squad_leader = new_leader
	if(squad_leader)
		new_leader.is_squad_leader = TRUE
		poke_member_v2(new_leader)

/datum/human_ai_squad/proc/on_squad_member_death(mob/living/carbon/human/dead_mob)
	SIGNAL_HANDLER

	var/datum/human_ai_brain/brain = dead_mob.get_ai_brain()
	if(brain && (squad_leader == brain))
		set_squad_leader(null)

	for(var/datum/human_ai_brain/squaddie as anything in ai_in_squad)
		if(squaddie?.tied_human.client)
			continue

		if(squaddie.tied_human.is_mob_incapacitated())
			continue

		squaddie.on_squad_member_death(dead_mob)

/datum/human_ai_squad/proc/on_squad_member_delete(datum/human_ai_brain/deleting)
	SIGNAL_HANDLER

	remove_from_squad(deleting)

/datum/human_ai_squad/proc/on_order_delete(datum/source, force)
	SIGNAL_HANDLER
	remove_current_order()

/datum/human_ai_brain
	/// Numeric ID of the squad this AI is in, if any
	var/squad_id
	var/is_squad_leader = FALSE

/datum/human_ai_brain/proc/add_to_squad(new_id)
	if(isnull(new_id) || (new_id == squad_id))
		return

	var/datum/human_ai_squad/squad = get_human_ai_runtime_squad("[new_id]")
	if(!squad)
		return
	squad.add_to_squad(src)
