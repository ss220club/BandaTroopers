/// Returns a human AI brain, if this human has one
/mob/living/carbon/human/proc/get_ai_brain()
	RETURN_TYPE(/datum/human_ai_brain)

	var/list/out_brain = list()
	SEND_SIGNAL(src, COMSIG_HUMAN_GET_AI_BRAIN, out_brain)
	if(length(out_brain))
		return out_brain[1]

/// Refreshes runtime AI state after external equipment/order edits.
/// Returns TRUE when the mob has an AI brain, FALSE otherwise.
/mob/living/carbon/human/proc/refresh_human_ai_runtime_state(armor = TRUE)
	var/datum/human_ai_brain/brain = get_ai_brain()
	if(!brain)
		return FALSE

	brain.appraise_inventory(armor = armor)
	request_human_ai_v2_reconcile(item_search = TRUE, fire_line = TRUE, cover_scan = TRUE, wake_now = TRUE)
	return TRUE

/// Refreshes human AI runtime ownership for existing AI components after flag/client state changes.
/// Returns TRUE when ownership state changed (controller registration and/or AI_CONTROLLED flag).
/mob/living/carbon/human/proc/refresh_human_ai_runtime_ownership()
	var/static/v2_component_type = null
	if(isnull(v2_component_type))
		v2_component_type = text2path("/datum/component/human_ai_v2")
	if(!v2_component_type)
		return FALSE

	var/datum/component/human_ai_v2/v2_component = GetComponent(v2_component_type)
	if(!v2_component)
		return FALSE

	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai?.get_controller(/datum/npc_ai_controller/human)
	var/was_registered = FALSE
	if(human_controller)
		was_registered = !!human_controller.agents?.Find(src)
	var/was_ai_controlled = !!(mob_flags & AI_CONTROLLED)

	if(client || !GLOB.npc_ai_v2_human_enabled)
		v2_component.unregister_from_npc_ai()
		mob_flags &= ~AI_CONTROLLED
		return (was_registered || was_ai_controlled)

	v2_component.register_with_npc_ai()
	mob_flags |= AI_CONTROLLED

	if(human_controller && !was_registered && human_controller.agents?.Find(src))
		return TRUE
	if(!was_ai_controlled && (mob_flags & AI_CONTROLLED))
		return TRUE
	return FALSE

/// Applies refresh_human_ai_runtime_ownership() to all current AI humans.
/// Returns number of humans whose ownership state changed.
/proc/refresh_all_human_ai_runtime_ownership()
	var/updated_agents = 0
	for(var/mob/living/carbon/human/human as anything in GLOB.ai_humans)
		if(!istype(human))
			continue
		if(human.refresh_human_ai_runtime_ownership())
			updated_agents++
	return updated_agents

/// Requests v2 legacy-bridge cache/sensor reconciliation and optionally wakes next think immediately.
/// Returns TRUE when reconcile request was sent to a v2 blackboard, FALSE otherwise.
/mob/living/carbon/human/proc/request_human_ai_v2_reconcile(item_search = TRUE, fire_line = TRUE, cover_scan = TRUE, wake_now = TRUE)
	var/datum/human_ai_brain/brain = get_ai_brain()
	if(!brain)
		return FALSE

	var/datum/npc_ai_controller/human/human_controller = brain.get_npc_ai_v2_controller()
	if(!human_controller)
		return FALSE

	var/datum/npc_ai_blackboard/blackboard = human_controller.get_blackboard(src)
	if(!blackboard)
		return FALSE

	if(item_search)
		blackboard.set_value("legacy_item_search_requested", TRUE)
	if(fire_line)
		blackboard.set_value("legacy_fire_line_recalc_requested", TRUE)
	if(cover_scan)
		blackboard.set_value("legacy_cover_scan_requested", TRUE)
	if(wake_now)
		var/next_think_at = blackboard.get_value("v2_next_think_at", world.time)
		if(!isnum(next_think_at) || next_think_at > world.time)
			blackboard.set_value("v2_next_think_at", world.time)
	return TRUE

/// Hacky getter proc used as part of the get_ai_brain() proc
/datum/human_ai_brain/proc/get_ai_brain(datum/source, list/out_brain)
	SIGNAL_HANDLER

	out_brain += src

/// Returns v2 human AI controller when this brain is owned by a v2 component.
/datum/human_ai_brain/proc/get_npc_ai_v2_controller()
	RETURN_TYPE(/datum/npc_ai_controller/human)
	if(!SSnpc_ai || !tied_human)
		return null

	var/static/v2_component_type = null
	if(isnull(v2_component_type))
		v2_component_type = text2path("/datum/component/human_ai_v2")
	if(!v2_component_type || !tied_human.GetComponent(v2_component_type))
		return null

	var/datum/npc_ai_controller/human/human_controller = SSnpc_ai.get_controller(/datum/npc_ai_controller/human)
	if(!human_controller || !human_controller.is_enabled())
		return null

	return human_controller

/// Returns if this AI has a given action, based on path
/datum/human_ai_brain/proc/has_ongoing_action(path)
	if(!ispath(path))
		return FALSE

	for(var/datum/ai_action/action as anything in ongoing_actions)
		if(istype(action, path))
			return TRUE

	return FALSE

/// Given an order reference, sets it as this AI's current order
/datum/human_ai_brain/proc/set_current_order(datum/ai_order/ref)
	if(!ref)
		return

	current_order = ref
	current_order.brains += src

/// Nulls out this AI's current order
/datum/human_ai_brain/proc/remove_current_order()
	if(current_order)
		current_order.brains -= src
	current_order = null

/datum/human_ai_brain/proc/faction_list_has(list/faction_list, faction)
	if(!islist(faction_list) || !faction)
		return FALSE
	if(!isnull(faction_list[faction]))
		return TRUE
	return faction in faction_list

/// Returns TRUE if the target is friendly/neutral to us
/// This is THE hottest proc that Human AI invokes, so please be careful in adding more to it
// SS220 EDIT AI - START
/datum/human_ai_brain/proc/faction_check(atom/target)
	var/my_faction = tied_human.faction
	var/target_faction

	if(ismob(target))
		var/mob/mob_target = target
		target_faction = mob_target.faction
	else if(istype(target, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/vehicle_target = target
		target_faction = vehicle_target.vehicle_faction
	else if(isdefenses(target))
		var/obj/structure/machinery/defenses/defense_target = target
		return (my_faction in defense_target.faction_group)
	else
		return FALSE

	return ((target_faction == my_faction) || faction_list_has(friendly_factions, target_faction) || faction_list_has(neutral_factions, target_faction))
// SS220 EDIT AI - END

/// Removes neutral faction status from a given faction
/datum/human_ai_brain/proc/on_neutral_faction_betray(faction)
	if(!tied_human.faction)
		return

	var/datum/human_ai_faction/our_faction = get_human_ai_runtime_faction(tied_human.faction)
	if(!our_faction)
		return

	our_faction.remove_neutral_faction(faction)
	our_faction.reapply_faction_data()

/// Announces whenever an AI is handcuffed so that GMs can force someone in or take over themselves
/datum/human_ai_brain/proc/on_handcuffed(datum/source)
	SIGNAL_HANDLER

	if((tied_human.stat >= DEAD) || tied_human.client)
		return

	message_admins("AI human [tied_human.real_name] has been handcuffed while alive or unconscious.", tied_human.x, tied_human.y, tied_human.z)

/// Assuming an item is in the AI's hands, this ensures it is their actively selected hand
/datum/human_ai_brain/proc/ensure_primary_hand(obj/item/held_item)
	if(tied_human.get_inactive_hand() == held_item)
		tied_human.swap_hand()

/// Unholsters the AI's primary weapon, dropping anything that might obstruct it.
/datum/human_ai_brain/proc/unholster_primary()
	if(!primary_weapon || tied_human.l_hand == primary_weapon || tied_human.r_hand == primary_weapon)
		return

	var/cur_hand = tied_human.get_active_hand()
	if(cur_hand)
		tied_human.drop_held_item(cur_hand)

	tied_human.u_equip(primary_weapon)
	tied_human.put_in_active_hand(primary_weapon)

	primary_weapon.guaranteed_delay_time = world.time
	primary_weapon.wield_time = world.time
	primary_weapon.pull_time = world.time

/// Tells the AI to wield their primary weapon, can be called if they aren't holding it or if they are already wielding it
/datum/human_ai_brain/proc/wield_primary()
	primary_weapon?.wield(tied_human)

/// wield_primary() with a delay inbuilt
/datum/human_ai_brain/proc/wield_primary_sleep()
	wield_primary()
	sleep(max(primary_weapon?.wield_delay, short_action_delay * action_delay_mult))

/// Holsters the AI's primary weapon if possible
/datum/human_ai_brain/proc/holster_primary()
	if(tied_human.s_store || (tied_human.l_hand != primary_weapon && tied_human.r_hand != primary_weapon))
		return FALSE

	return tied_human.equip_to_slot_if_possible(primary_weapon, WEAR_J_STORE, TRUE)

/// Melee system currently only supports bootknives.
/datum/human_ai_brain/proc/unholster_melee()
	if(istype(tied_human.l_hand, /obj/item) || istype(tied_human.r_hand, /obj/item))
		return TRUE

	var/cur_hand = tied_human.get_active_hand()
	if(cur_hand)
		tied_human.drop_held_item(cur_hand)

	if(tied_human.shoes)
		var/obj/item/melee_weapon = tied_human.shoes.remove_item(tied_human)
		drawn_melee_weapon = melee_weapon
		RegisterSignal(drawn_melee_weapon, COMSIG_ITEM_DROPPED, PROC_REF(on_melee_dropped))
		return melee_weapon

/// Signal for if a melee weapon is dropped
/datum/human_ai_brain/proc/on_melee_dropped()
	SIGNAL_HANDLER

	UnregisterSignal(drawn_melee_weapon, COMSIG_ITEM_DROPPED)
	drawn_melee_weapon = null

/// Quick and dirty proc to holster a melee weapon if the AI is holding one.
/datum/human_ai_brain/proc/holster_melee()
	if(!drawn_melee_weapon)
		return TRUE

	if(drawn_melee_weapon.loc != tied_human)
		on_melee_dropped()
		return TRUE

	if(tied_human.shoes && tied_human.shoes.can_be_inserted(drawn_melee_weapon))
		return tied_human.shoes.attempt_insert_item(tied_human, drawn_melee_weapon)

	tied_human.drop_held_item(drawn_melee_weapon)
	return FALSE

/// Tells the AI to unwield *something*, prioritizing melee
/datum/human_ai_brain/proc/unholster_any_weapon()
	if(unholster_melee())
		tied_human.a_intent_change(INTENT_GRAB)
		return TRUE
	if(primary_weapon)
		unholster_primary()
		ensure_primary_hand(primary_weapon)
		wield_primary()
		tied_human.a_intent_change(INTENT_GRAB)
		return TRUE
	// insert any viable weapon slot macros in here
