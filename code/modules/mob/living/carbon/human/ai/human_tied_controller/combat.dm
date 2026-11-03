// Raw intent primitives

/datum/human_tied_controller/proc/set_intent(intent)
	if(!can_directly_control())
		return FALSE
	tied_human.a_intent_change(intent)
	return TRUE

/datum/human_tied_controller/proc/set_raw_intent(intent)
	if(!can_directly_control())
		return FALSE
	tied_human.a_intent = intent
	return TRUE

/datum/human_tied_controller/proc/set_combat_intent()
	return set_intent(INTENT_HARM)

/datum/human_tied_controller/proc/set_grab_intent()
	return set_intent(INTENT_GRAB)

/datum/human_tied_controller/proc/set_safe_intent()
	return set_intent(INTENT_DISARM)

// Raw click/combat primitives

/datum/human_tied_controller/proc/wield(obj/item/weapon/gun/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	// SS220 EDIT - START: report readiness, including already wielded and one-handed weapons
	if(get_active_hand() != weapon)
		return FALSE
	if(!(weapon.flags_item & TWOHANDED))
		return TRUE
	weapon.wield(tied_human)
	// return TRUE
	return !QDELETED(weapon) && get_active_hand() == weapon && (weapon.flags_item & WIELDED)
	// SS220 EDIT - END

/datum/human_tied_controller/proc/unwield_weapon(obj/item/weapon/gun/weapon)
	if(!can_directly_control() || !weapon)
		return FALSE
	weapon.unwield(tied_human)
	return TRUE

/datum/human_tied_controller/proc/do_click(atom/target, params = "", list/modifiers)
	if(!can_directly_control() || !target)
		return FALSE
	if(!modifiers)
		modifiers = list()
	tied_human.do_click(target, params, modifiers)
	return TRUE

/datum/human_tied_controller/proc/get_action(action_type)
	RETURN_TYPE(/datum/action)
	if(!can_read_puppet() || !action_type)
		return null
	return locate(action_type) in tied_human.actions

/datum/human_tied_controller/proc/click_atom(atom/target)
	if(!do_click(target, "", list()))
		return FALSE
	face_atom(target)
	return TRUE

// Raw throw primitives

/datum/human_tied_controller/proc/can_throw()
	return can_directly_control() && tied_human.get_active_hand()

/datum/human_tied_controller/proc/toggle_throw_mode(mode = THROW_MODE_NORMAL)
	if(!can_directly_control())
		return FALSE
	if(!tied_human.throw_mode)
		tied_human.toggle_throw_mode(mode)
	return TRUE

/datum/human_tied_controller/proc/has_throw_mode()
	return !!tied_human?.throw_mode

/datum/human_tied_controller/proc/disable_throw_mode()
	if(!can_directly_control())
		return FALSE
	if(tied_human.throw_mode)
		tied_human.toggle_throw_mode(THROW_MODE_OFF)
	return TRUE

/datum/human_tied_controller/proc/throw_item(turf/target_turf)
	if(!can_throw() || !target_turf)
		return FALSE
	face_atom(target_turf)
	tied_human.throw_item(target_turf)
	return TRUE

/datum/human_tied_controller/proc/prime_grenade(obj/item/explosive/grenade/grenade)
	if(!can_directly_control() || !grenade)
		return FALSE
	grenade.attack_self(tied_human)
	return TRUE

// Behavior helper for legacy grenade priming paths that cannot sleep through attack_self().
/datum/human_tied_controller/proc/prime_grenade_no_sleep(obj/item/explosive/grenade/grenade)
	if(!can_directly_control() || !grenade || grenade.active)
		return FALSE

	if(!grenade.can_use_grenade(tied_human))
		return FALSE

	if(QDELETED(grenade) || isnull(grenade.loc))
		return FALSE

	if(grenade.antigrief_protection && tied_human.faction == FACTION_MARINE && explosive_antigrief_check(grenade, tied_human))
		to_chat(tied_human, SPAN_WARNING("\The [grenade.name]'s safe-area accident inhibitor prevents you from priming the grenade!"))
		msg_admin_niche("[key_name(tied_human)] attempted to prime \a [grenade.name] in [get_area(grenade)] [ADMIN_JMP(grenade.loc)]")
		return FALSE

	if(SEND_SIGNAL(tied_human, COMSIG_GRENADE_PRE_PRIME) & COMPONENT_GRENADE_PRIME_CANCEL)
		return FALSE

	grenade.add_fingerprint(tied_human)
	grenade.activate(tied_human)
	grenade.cause_data = create_cause_data(initial(grenade.name), tied_human)

	tied_human.visible_message(SPAN_WARNING("[tied_human] primes \a [grenade.name]!"), \
		SPAN_WARNING("You prime \a [grenade.name]!"))
	msg_admin_attack("[key_name(tied_human)] primed \a grenade ([grenade.name]) in [get_area(grenade)] ([grenade.loc.x],[grenade.loc.y],[grenade.loc.z]).", grenade.loc.x, grenade.loc.y, grenade.loc.z)
	tied_human.attack_log += text("\[[time_stamp()]\] <font color='red'> [key_name(tied_human)] primed \a grenade ([grenade.name]) at ([grenade.loc.x],[grenade.loc.y],[grenade.loc.z])</font>")
	if(!tied_human.throw_mode)
		tied_human.toggle_throw_mode(THROW_MODE_NORMAL)

	return grenade.active

// Grenade primitives

/datum/human_tied_controller/proc/can_hold_grenade(obj/item/explosive/grenade/grenade)
	return can_directly_control() && grenade

/datum/human_tied_controller/proc/is_holding_grenade(obj/item/explosive/grenade/grenade)
	return !!get_hand_holding(grenade)

/datum/human_tied_controller/proc/ensure_grenade_active(obj/item/explosive/grenade/grenade)
	if(!can_hold_grenade(grenade))
		return FALSE
	if(get_active_hand() == grenade)
		return TRUE
	if(get_inactive_hand() == grenade)
		swap_hand()
		return get_active_hand() == grenade
	return FALSE

/datum/human_tied_controller/proc/clear_active_hand_for_grenade()
	if(!get_active_hand())
		return TRUE
	return clear_active_hand_if_possible()

// Behavior/migration helpers

// Helper for reconstructing the old grenade pickup behavior during migration.
/datum/human_tied_controller/proc/hold_grenade(obj/item/explosive/grenade/grenade)
	if(!can_hold_grenade(grenade))
		return FALSE
	if(ensure_grenade_active(grenade))
		return TRUE
	if(!clear_active_hand_for_grenade())
		return FALSE
	return put_in_active_hand(grenade)

// Helper for reconstructing the old live-grenade drop behavior during migration.
/datum/human_tied_controller/proc/drop_live_grenade(obj/item/explosive/grenade/grenade)
	if(!can_hold_grenade(grenade) || !is_holding_grenade(grenade))
		return FALSE
	return drop_inv_item_on_ground(grenade)
