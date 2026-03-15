/datum/human_ai_brain
	var/halo_suicide_bomber = FALSE
	var/halo_suicide_prime_range = 5

/datum/ai_action/unggoy_suicide_bomber
	name = "Unggoy Suicide Bomber"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS

/datum/ai_action/unggoy_suicide_bomber/get_weight(datum/human_ai_brain/brain)
	if(!brain.has_valid_tied_human())
		return 0

	if(!brain.halo_suicide_bomber)
		return 0

	if(!brain.in_combat || brain.hold_position)
		return 0

	if(!get_charge_target(brain))
		return 0

	if(find_active_held_grenade(brain.tied_human))
		return 80

	if(!length(brain.equipment_map[HUMAN_AI_GRENADES]))
		return 0

	return 70

/datum/ai_action/unggoy_suicide_bomber/trigger_action()
	. = ..()

	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(!tied_human)
		return ONGOING_ACTION_COMPLETED

	brain.end_cover()

	var/obj/item/explosive/grenade/active_grenade = find_active_held_grenade(tied_human)
	if(!active_grenade)
		var/atom/charge_target = get_charge_target(brain)
		if(!charge_target)
			return ONGOING_ACTION_COMPLETED

		var/target_dist = get_dist(tied_human, charge_target)
		if(target_dist > brain.halo_suicide_prime_range)
			if(!move_towards_target(charge_target))
				return ONGOING_ACTION_COMPLETED
			return ONGOING_ACTION_UNFINISHED_BLOCK

		if(!prime_grenades())
			return ONGOING_ACTION_COMPLETED

		active_grenade = find_active_held_grenade(tied_human)
		if(!active_grenade)
			return ONGOING_ACTION_COMPLETED

	var/atom/current_target = get_charge_target(brain)
	if(!current_target)
		return ONGOING_ACTION_UNFINISHED_BLOCK

	if(get_dist(tied_human, current_target) <= 1)
		tied_human.face_atom(current_target)
		return ONGOING_ACTION_UNFINISHED_BLOCK

	move_towards_target(current_target)
	return ONGOING_ACTION_UNFINISHED_BLOCK

/datum/ai_action/unggoy_suicide_bomber/proc/get_charge_target(datum/human_ai_brain/brain)
	return brain.current_target || brain.target_turf

/datum/ai_action/unggoy_suicide_bomber/proc/find_active_held_grenade(mob/living/carbon/human/tied_human)
	if(istype(tied_human.l_hand, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/left_grenade = tied_human.l_hand
		if(left_grenade.active)
			return left_grenade

	if(istype(tied_human.r_hand, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/right_grenade = tied_human.r_hand
		if(right_grenade.active)
			return right_grenade

/datum/ai_action/unggoy_suicide_bomber/proc/find_stored_grenade(obj/item/explosive/grenade/excluding = null)
	for(var/obj/item/explosive/grenade/grenade as anything in brain.equipment_map[HUMAN_AI_GRENADES])
		if(grenade == excluding)
			continue
		return grenade

/datum/ai_action/unggoy_suicide_bomber/proc/clear_both_hands()
	if(!brain || !brain.has_valid_tied_human())
		return

	brain.clear_main_hand()
	brain.tied_human.swap_hand()
	brain.clear_main_hand()
	brain.tied_human.swap_hand()

/datum/ai_action/unggoy_suicide_bomber/proc/prime_grenades()
	if(!brain || !brain.has_valid_tied_human())
		return FALSE

	var/mob/living/carbon/human/tied_human = brain.tied_human
	clear_both_hands()
	if(!brain.has_valid_tied_human())
		return FALSE

	var/obj/item/explosive/grenade/first_grenade = find_stored_grenade()
	if(!first_grenade)
		return FALSE

	brain.equip_item_from_equipment_map(HUMAN_AI_GRENADES, first_grenade)
	if(QDELETED(first_grenade) || (first_grenade.loc != tied_human))
		return FALSE

	var/obj/item/explosive/grenade/second_grenade = find_stored_grenade(first_grenade)
	if(second_grenade)
		tied_human.swap_hand()
		brain.equip_item_from_equipment_map(HUMAN_AI_GRENADES, second_grenade)
		if(QDELETED(second_grenade) || (second_grenade.loc != tied_human))
			second_grenade = null
		tied_human.swap_hand()

	if(!prime_grenade_no_sleep(first_grenade, tied_human))
		return FALSE
	if(second_grenade)
		prime_grenade_no_sleep(second_grenade, tied_human)
	if(tied_human.throw_mode)
		tied_human.toggle_throw_mode(THROW_MODE_OFF)

	return TRUE

/datum/ai_action/unggoy_suicide_bomber/proc/prime_grenade_no_sleep(obj/item/explosive/grenade/grenade, mob/living/carbon/human/user)
	if(!grenade || !user || grenade.active)
		return FALSE

	if(!grenade.can_use_grenade(user))
		return FALSE

	if(QDELETED(grenade) || isnull(grenade.loc))
		return FALSE

	if(grenade.antigrief_protection && user.faction == FACTION_MARINE && explosive_antigrief_check(grenade, user))
		to_chat(user, SPAN_WARNING("\The [grenade.name]'s safe-area accident inhibitor prevents you from priming the grenade!"))
		msg_admin_niche("[key_name(user)] attempted to prime \a [grenade.name] in [get_area(grenade)] [ADMIN_JMP(grenade.loc)]")
		return FALSE

	if(SEND_SIGNAL(user, COMSIG_GRENADE_PRE_PRIME) & COMPONENT_GRENADE_PRIME_CANCEL)
		return FALSE

	grenade.add_fingerprint(user)
	grenade.activate(user)
	grenade.cause_data = create_cause_data(initial(grenade.name), user)

	user.visible_message(SPAN_WARNING("[user] primes \a [grenade.name]!"), \
	SPAN_WARNING("You prime \a [grenade.name]!"))
	msg_admin_attack("[key_name(user)] primed \a grenade ([grenade.name]) in [get_area(grenade)] ([grenade.loc.x],[grenade.loc.y],[grenade.loc.z]).", grenade.loc.x, grenade.loc.y, grenade.loc.z)
	user.attack_log += text("\[[time_stamp()]\] <font color='red'> [key_name(user)] primed \a grenade ([grenade.name]) at ([grenade.loc.x],[grenade.loc.y],[grenade.loc.z])</font>")
	if(!user.throw_mode)
		user.toggle_throw_mode(THROW_MODE_NORMAL)

	return grenade.active

/datum/ai_action/unggoy_suicide_bomber/proc/move_towards_target(atom/charge_target)
	if(!brain || !brain.has_valid_tied_human())
		return FALSE

	var/turf/charge_turf = get_turf(charge_target)
	if(brain.halo_unggoy_runtime)
		charge_turf = brain.halo_covenant_get_cached_threat_turf()
	if(!charge_turf)
		return FALSE

	if(!brain.move_to_next_turf(charge_turf))
		return FALSE

	if(!brain.has_valid_tied_human())
		return FALSE

	brain.tied_human.face_atom(charge_target)
	return TRUE
