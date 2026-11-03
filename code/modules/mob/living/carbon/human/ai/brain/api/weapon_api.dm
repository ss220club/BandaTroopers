// Human AI weapon and ranged-fire API.
// Firing actions still own line checks and firearm handler side effects.

/datum/human_ai_brain/proc/has_tried_reload()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.has_tried_reload()

/datum/human_ai_brain/proc/mark_tried_reload()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	guns_module?.mark_tried_reload()

/datum/human_ai_brain/proc/set_tried_reload(new_value)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return
	if(new_value)
		guns_module.mark_tried_reload()
	else
		guns_module.clear_tried_reload()

/datum/human_ai_brain/proc/should_reload()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.should_reload()

/datum/human_ai_brain/proc/can_start_fire()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_start_fire()

/datum/human_ai_brain/proc/start_stop_fire_cooldown(cooldown)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	guns_module?.start_stop_fire_cooldown(cooldown)

/datum/human_ai_brain/proc/can_continue_fire_burst()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_continue_fire_burst()

/datum/human_ai_brain/proc/start_fire_overload_cooldown()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	guns_module?.start_fire_overload_cooldown()

/datum/human_ai_brain/proc/is_currently_reloading()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.is_currently_reloading()

/datum/human_ai_brain/proc/stop_reload(clear_active_action = FALSE)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	guns_module?.stop_reload(clear_active_action)

/datum/human_ai_brain/proc/perform_reload(datum/human_tied_controller/controller, datum/ai_action/reload_action)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return ONGOING_ACTION_COMPLETED
	return guns_module.perform_reload(controller, reload_action)

/datum/human_ai_brain/proc/is_currently_firing()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.is_currently_firing()

/datum/human_ai_brain/proc/stop_ranged_fire(clear_active_action = FALSE)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	guns_module?.stop_ranged_fire(clear_active_action)

/datum/human_ai_brain/proc/register_ranged_fire_callback(datum/human_tied_controller/controller, datum/ai_action/fire_action)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.register_ranged_fire_callback(controller, fire_action)

/datum/human_ai_brain/proc/get_ranged_fire_weight(datum/human_tied_controller/controller)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.get_ranged_fire_weight(controller) || 0

/datum/human_ai_brain/proc/perform_ranged_fire(datum/human_tied_controller/controller, datum/ai_action/fire_action)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return ONGOING_ACTION_COMPLETED
	return guns_module.perform_ranged_fire(controller, fire_action)

/datum/human_ai_brain/proc/clear_tried_reload()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	guns_module?.clear_tried_reload()

/datum/human_ai_brain/proc/can_use_ranged_weapon()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_use_ranged_weapon()

/datum/human_ai_brain/proc/get_ranged_fire_target_turf(datum/human_ai_firearm_profile/gun_data = null)
	RETURN_TYPE(/turf)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.get_ranged_fire_target_turf(gun_data)

/datum/human_ai_brain/proc/can_reach_ranged_fire_target(datum/human_tied_controller/controller, turf/target_turf, maximum_range = null, datum/human_ai_firearm_profile/gun_data = null)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_reach_ranged_fire_target(controller, target_turf, maximum_range, gun_data)

/datum/human_ai_brain/proc/can_reach_ranged_fire_atom(datum/human_tied_controller/controller, atom/target, maximum_range = null, datum/human_ai_firearm_profile/gun_data = null)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_reach_ranged_fire_atom(controller, target, maximum_range, gun_data)

/datum/human_ai_brain/proc/can_use_ranged_fire_line(datum/human_tied_controller/controller, atom/target, datum/human_ai_firearm_profile/gun_data = null, listen = FALSE)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_use_ranged_fire_line(controller, target, gun_data, listen)

/datum/human_ai_brain/proc/get_ranged_fire_aim_target(datum/human_tied_controller/controller, atom/movable/current_target, turf/target_turf, datum/human_ai_firearm_profile/gun_data = null)
	RETURN_TYPE(/atom)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.get_ranged_fire_aim_target(controller, current_target, target_turf, gun_data)

/datum/human_ai_brain/proc/get_safe_adjacent_human_aim_turfs(datum/human_tied_controller/controller, turf/target_turf)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.get_safe_adjacent_human_aim_turfs(controller, target_turf) || list()

/datum/human_ai_brain/proc/get_miss_adjacent_human_aim_turfs(turf/target_turf, list/safe_turfs)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	return guns_module?.get_miss_adjacent_human_aim_turfs(target_turf, safe_turfs) || list()

/datum/human_ai_brain/proc/should_block_ranged_fire_for_throwable()
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.should_block_ranged_fire_for_throwable()

/datum/human_ai_brain/proc/should_defer_ranged_fire_target(atom/threat = null)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.should_defer_ranged_fire_target(threat)

/datum/human_ai_brain/proc/should_defer_current_ranged_fire(datum/human_ai_firearm_profile/gun_data = null)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.should_defer_current_ranged_fire(gun_data)

/datum/human_ai_brain/proc/perform_keep_distance(datum/human_tied_controller/controller)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return ONGOING_ACTION_COMPLETED
	return guns_module.perform_keep_distance(controller)

/datum/human_ai_brain/proc/can_attempt_ranged_fire(datum/human_tied_controller/controller, obj/item/weapon/gun/primary_weapon, datum/human_ai_firearm_profile/gun_data = null, require_combat = TRUE, block_active_grenade = FALSE, check_view_distance = TRUE, check_reload = TRUE, check_tried_reload = TRUE)
	var/datum/human_ai_module/guns/guns_module = get_guns_module()
	if(!guns_module)
		return FALSE
	return guns_module.can_attempt_ranged_fire(controller, primary_weapon, gun_data, require_combat, block_active_grenade, check_view_distance, check_reload, check_tried_reload)
