// Puppet state queries

/datum/human_tied_controller/proc/has_tied_human()
	return tied_human && !QDELETED(tied_human)

/datum/human_tied_controller/proc/is_tied_human_loaded()
	return has_tied_human() && !isnull(tied_human.loc)

/datum/human_tied_controller/proc/has_valid_tied_human()
	return is_tied_human_loaded()

/datum/human_tied_controller/proc/has_client()
	return !!tied_human?.client

/datum/human_tied_controller/proc/has_active_player()
	return has_client()

/datum/human_tied_controller/proc/can_player_takeover_block_ai()
	return has_active_player()

// AI control flags

/datum/human_tied_controller/proc/is_ai_controlled()
	return !!(tied_human?.mob_flags & AI_CONTROLLED)

/datum/human_tied_controller/proc/mark_ai_controlled()
	if(!has_tied_human())
		return FALSE
	tied_human.mob_flags |= AI_CONTROLLED
	return TRUE

/datum/human_tied_controller/proc/clear_ai_controlled()
	if(!has_tied_human())
		return FALSE
	tied_human.mob_flags &= ~AI_CONTROLLED
	return TRUE

// Control gates

/datum/human_tied_controller/proc/can_read_puppet()
	return has_tied_human()

/datum/human_tied_controller/proc/can_mutate_puppet()
	return is_tied_human_loaded() && !can_player_takeover_block_ai()

/datum/human_tied_controller/proc/can_tick_ai()
	if(!can_mutate_puppet() || is_dead())
		return FALSE
	if(brain && !brain.can_continue_runtime_work()) // SS220 EDIT: raw puppet mutations must obey brain lifecycle between scheduler ticks
		return FALSE
	return TRUE

/datum/human_tied_controller/proc/can_directly_control()
	return can_tick_ai()

/datum/human_tied_controller/proc/can_force_control()
	return can_mutate_puppet()

/datum/human_tied_controller/proc/can_force_setup()
	return has_tied_human() && !can_player_takeover_block_ai()

/datum/human_tied_controller/proc/can_setup_puppet()
	return can_force_setup()

/datum/human_tied_controller/proc/can_release_puppet()
	return has_tied_human()

// Puppet read primitives

/datum/human_tied_controller/proc/is_dead()
	return !has_tied_human() || (tied_human.stat == DEAD)

/datum/human_tied_controller/proc/is_incapacitated(ignore_resting = FALSE)
	return !has_tied_human() || tied_human.is_mob_incapacitated(ignore_resting)

/datum/human_tied_controller/proc/is_conscious_available()
	return can_mutate_puppet() && !tied_human.buckled && (tied_human.stat == CONSCIOUS) && !tied_human.is_mob_incapacitated()

/datum/human_tied_controller/proc/get_current_turf()
	RETURN_TYPE(/turf)
	return get_turf(tied_human)

/datum/human_tied_controller/proc/get_self_target()
	RETURN_TYPE(/mob/living/carbon/human)
	if(!can_read_puppet())
		return null
	return tied_human

/datum/human_tied_controller/proc/get_loc()
	if(!can_read_puppet())
		return null
	return tied_human.loc

/datum/human_tied_controller/proc/get_x()
	return tied_human?.x

/datum/human_tied_controller/proc/get_y()
	return tied_human?.y

/datum/human_tied_controller/proc/get_z()
	return tied_human?.z

/datum/human_tied_controller/proc/get_current_dir()
	return tied_human?.dir

/datum/human_tied_controller/proc/get_real_name()
	return tied_human?.real_name

/datum/human_tied_controller/proc/get_name()
	return tied_human?.name

/datum/human_tied_controller/proc/get_key_name()
	if(!can_read_puppet())
		return null
	return key_name(tied_human)

/datum/human_tied_controller/proc/get_area_coords()
	if(!can_read_puppet())
		return null
	return AREACOORD(tied_human)

// Debug/admin helper only; external AI behavior should not locate this ref to bypass the controller API.
/datum/human_tied_controller/proc/get_ref()
	if(!can_read_puppet())
		return null
	return REF(tied_human)

/datum/human_tied_controller/proc/get_faction()
	return tied_human?.faction

/datum/human_tied_controller/proc/has_faction()
	return !!get_faction()

/datum/human_tied_controller/proc/faction_matches(faction)
	return tied_human?.faction == faction

/datum/human_tied_controller/proc/faction_in(list/factions)
	return tied_human?.faction in factions

/datum/human_tied_controller/proc/get_health()
	return tied_human?.health

/datum/human_tied_controller/proc/is_health_below(threshold)
	return !can_read_puppet() || (tied_human.health < threshold)

/datum/human_tied_controller/proc/get_stat()
	return tied_human?.stat

/datum/human_tied_controller/proc/is_stat_at_least(stat_threshold)
	return !can_read_puppet() || (tied_human.stat >= stat_threshold)

/datum/human_tied_controller/proc/has_effect(datum/effect_type)
	if(!can_read_puppet())
		return FALSE
	return !!(locate(effect_type) in tied_human.effects_list)

/datum/human_tied_controller/proc/has_status_flag(flag)
	return !!(tied_human?.status_flags & flag)

/datum/human_tied_controller/proc/is_zombie()
	return can_read_puppet() && iszombie(tied_human)

/datum/human_tied_controller/proc/is_resting()
	return !!tied_human?.resting

/datum/human_tied_controller/proc/is_buckled()
	return !!tied_human?.buckled

/datum/human_tied_controller/proc/is_body_position(body_position)
	return tied_human?.body_position == body_position

/datum/human_tied_controller/proc/has_trait(trait)
	return can_read_puppet() && HAS_TRAIT(tied_human, trait)

/datum/human_tied_controller/proc/has_trait_from(trait, source)
	return can_read_puppet() && HAS_TRAIT_FROM(tied_human, trait, source)

/datum/human_tied_controller/proc/is_on_fire()
	return !!tied_human?.on_fire

/datum/human_tied_controller/proc/is_bleeding()
	return can_read_puppet() && tied_human.is_bleeding()

/datum/human_tied_controller/proc/has_broken_limbs()
	return can_read_puppet() && tied_human.has_broken_limbs()

// Puppet mutation primitives

/datum/human_tied_controller/proc/set_faction(new_faction)
	if(!can_force_setup())
		return FALSE
	tied_human.faction = new_faction
	return TRUE

/datum/human_tied_controller/proc/get_health_ratio()
	if(!can_read_puppet() || !tied_human.maxHealth)
		return 0
	return tied_human.health / tied_human.maxHealth

/datum/human_tied_controller/proc/get_brute_loss()
	if(!can_read_puppet())
		return 0
	return tied_human.getBruteLoss()

/datum/human_tied_controller/proc/get_fire_loss()
	if(!can_read_puppet())
		return 0
	return tied_human.getFireLoss()

/datum/human_tied_controller/proc/get_tox_loss()
	if(!can_read_puppet())
		return 0
	return tied_human.getToxLoss()

/datum/human_tied_controller/proc/get_oxy_loss()
	if(!can_read_puppet())
		return 0
	return tied_human.getOxyLoss()

/datum/human_tied_controller/proc/get_pain_percentage()
	if(!can_read_puppet())
		return 0
	return tied_human.pain.get_pain_percentage()
