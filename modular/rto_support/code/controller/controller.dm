/// Runtime coordinator for one RTO owner.
/datum/rto_support_controller
	var/mob/living/carbon/human/owner
	var/datum/rto_support_template/active_template
	var/datum/rto_visibility_zone/active_zone
	var/armed_action_id
	var/shared_cooldown_until = 0
	var/visibility_zone_cooldown_until = 0
	var/list/action_cooldowns = list()
	var/list/action_handles = list()
	var/datum/action/human_action/rto/select_preset/select_action
	var/datum/action/human_action/rto/visibility_zone/visibility_action
	var/datum/action/human_action/rto/coordinates/coordinates_action
	var/datum/action/human_action/rto/manual_marker/manual_marker_action
	var/list/support_actions = list()
	var/datum/rto_support_validation_service/validation_service
	var/datum/rto_support_dispatch_service/dispatch_service
	var/hud_tick_timer_id = null
	var/zone_expiry_timer_id = null
	var/last_binocular_in_hand = FALSE
	var/runtime_initialized = FALSE

/datum/rto_support_controller/New(mob/living/carbon/human/new_owner)
	owner = new_owner
	. = ..()

/datum/rto_support_controller/Destroy()
	runtime_initialized = FALSE
	disarm_action()
	stop_hud_tick()
	clear_zone_expiry_timer()
	clear_active_zone(FALSE)
	clear_manual_designation()
	clear_actions()
	validation_service = null
	dispatch_service = null
	action_cooldowns = null
	action_handles = null
	support_actions = null
	owner = null
	active_template = null
	return ..()

/datum/rto_support_controller/proc/ensure_runtime()
	if(!owner || QDELETED(owner))
		return FALSE
	if(!validation_service)
		validation_service = new
	if(!dispatch_service)
		dispatch_service = new
	if(!action_cooldowns)
		action_cooldowns = list()
	if(!action_handles)
		action_handles = list()
	if(!support_actions)
		support_actions = list()
	runtime_initialized = TRUE
	sync_actions()
	last_binocular_in_hand = has_rto_binocular_in_hand()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/has_required_role()
	return owner && !QDELETED(owner) && GET_DEFAULT_ROLE(owner.job) == JOB_SQUAD_RTO

/datum/rto_support_controller/proc/get_available_templates()
	if(!owner || GET_DEFAULT_ROLE(owner.job) != JOB_SQUAD_RTO)
		return list()
	var/list/templates = GLOB.rto_support_registry?.get_template_catalog()
	return templates ? templates : list()

/datum/rto_support_controller/proc/can_select_template()
	if(!owner || QDELETED(owner))
		return FALSE
	if(GET_DEFAULT_ROLE(owner.job) != JOB_SQUAD_RTO)
		return FALSE
	if(!is_support_enabled_by_rules())
		return FALSE
	return !active_template

/datum/rto_support_controller/proc/select_template(template_type)
	ensure_runtime()
	if(!can_select_template())
		return FALSE
	var/datum/rto_support_template/template = find_template(template_type)
	if(!template)
		return FALSE
	active_template = template
	disarm_action()
	clear_active_zone(FALSE)
	visibility_zone_cooldown_until = 0
	sync_actions()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/get_active_template() as /datum/rto_support_template
	return active_template

/datum/rto_support_controller/proc/get_action_templates()
	return active_template ? active_template.get_action_templates() : list()

/datum/rto_support_controller/proc/template_requires_zone()
	return !!active_template?.requires_visibility_zone

/datum/rto_support_controller/proc/get_active_zone()
	if(active_zone && !active_zone.is_active())
		clear_active_zone()
	return active_zone

/datum/rto_support_controller/proc/get_zone_state()
	if(!active_template || !template_requires_zone())
		return RTO_SUPPORT_ZONE_STATE_UNSUPPORTED
	if(get_active_zone())
		return RTO_SUPPORT_ZONE_STATE_ACTIVE
	if(get_remaining_visibility_cooldown() > 0)
		return RTO_SUPPORT_ZONE_STATE_COOLDOWN
	return RTO_SUPPORT_ZONE_STATE_READY

/datum/rto_support_controller/proc/get_zone_ready_in()
	return get_zone_state() == RTO_SUPPORT_ZONE_STATE_COOLDOWN ? get_remaining_visibility_cooldown() : 0

/datum/rto_support_controller/proc/get_zone_expires_in()
	var/datum/rto_visibility_zone/zone = get_active_zone()
	return zone ? max(0, zone.expires_at - world.time) : 0

/datum/rto_support_controller/proc/is_manual_marker_active()
	var/obj/item/device/binoculars/rto/binoculars = get_owned_binocular()
	return binoculars?.is_live_marker_active()

/datum/rto_support_controller/proc/sync_runtime_state()
	if(!validate_owner_runtime())
		return FALSE
	prune_zone_state()
	if(armed_action_id && !has_rto_binocular_in_hand())
		reset_armed_action()
	last_binocular_in_hand = has_rto_binocular_in_hand()
	return TRUE

/datum/rto_support_controller/proc/can_deploy_zone()
	if(!active_template || !template_requires_zone())
		return FALSE
	if(get_active_zone())
		return FALSE
	return get_remaining_visibility_cooldown() <= 0

/datum/rto_support_controller/proc/deploy_zone(turf/target_turf)
	ensure_runtime()
	if(!active_template || !template_requires_zone() || !target_turf)
		return FALSE

	replace_active_zone(new /datum/rto_visibility_zone(owner, target_turf, active_template))

	if(active_template.visibility_support_path)
		var/datum/rto_support_request/request = new
		request.owner = owner
		request.target_turf = target_turf
		request.template = active_template
		request.visibility_zone = active_zone
		request.dispatch_key = RTO_SUPPORT_REQUEST_VISIBILITY
		request.dispatch_path = active_template.visibility_support_path
		request.display_name = active_template.visibility_zone_name
		request.request_kind = RTO_SUPPORT_REQUEST_VISIBILITY
		request.target_marker_style = active_template.visibility_target_marker_style
		request.announce_to_ghosts = FALSE
		dispatch_service.dispatch_request(request)

	if(owner)
		to_chat(owner, SPAN_NOTICE("[active_template.visibility_zone_name]: сектор развернут."))
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/can_arm_action(action_id)
	if(!action_id)
		return FALSE
	if(action_id == RTO_SUPPORT_ARM_COORDINATES || action_id == RTO_SUPPORT_ARM_MARKER)
		return TRUE
	if(!is_support_enabled_by_rules())
		return FALSE
	if(!active_template)
		return FALSE
	if(action_id == RTO_SUPPORT_ARM_VISIBILITY_ZONE)
		return can_deploy_zone()

	var/datum/rto_support_action_template/action_template = active_template.get_action_template(action_id)
	if(!action_template)
		return FALSE
	if(get_remaining_shared_cooldown() > 0)
		return FALSE
	if(get_remaining_action_cooldown(action_id) > 0)
		return FALSE
	if(action_template.requires_visibility_zone && template_requires_zone() && !get_active_zone())
		return FALSE
	return TRUE
/datum/rto_support_controller/proc/arm_action(action_id)
	ensure_runtime()
	if(!owner || QDELETED(owner))
		return FALSE
	if(!has_rto_binocular_in_hand())
		to_chat(owner, SPAN_WARNING("Нужен RTO-бинокль в руке."))
		return FALSE
	if(!can_arm_action(action_id))
		var/message = get_action_block_message(action_id)
		if(message)
			to_chat(owner, SPAN_WARNING(message))
		return FALSE
	if(armed_action_id == action_id)
		return disarm_action()
	reset_armed_action()
	armed_action_id = action_id
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/disarm_action()
	if(!reset_armed_action())
		return FALSE
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/reset_armed_action()
	if(!armed_action_id)
		return FALSE
	if(armed_action_id == RTO_SUPPORT_ARM_MARKER)
		clear_manual_designation()
	armed_action_id = null
	return TRUE
/datum/rto_support_controller/proc/handle_binocular_target(turf/target_turf, mob/living/carbon/human/user)
	ensure_runtime()
	if(!armed_action_id || !target_turf || user != owner)
		return FALSE

	var/obj/item/device/binoculars/rto/binoculars = get_active_binocular()
	if(!binoculars)
		to_chat(user, SPAN_WARNING("Нужно смотреть через RTO-бинокль."))
		return FALSE

	if(armed_action_id == RTO_SUPPORT_ARM_COORDINATES)
		var/datum/rto_support_validation_result/coordinate_result = validation_service.validate_coordinate_target(src, target_turf, user, binoculars)
		if(!coordinate_result.success)
			if(coordinate_result.message)
				to_chat(user, SPAN_WARNING("Координаты: [coordinate_result.message]"))
			return FALSE
		acquire_explicit_coordinates(target_turf, user)
		return TRUE

	if(armed_action_id == RTO_SUPPORT_ARM_MARKER)
		var/datum/rto_support_validation_result/marker_result = validation_service.validate_manual_marker_target(src, target_turf, user, binoculars)
		if(!marker_result.success)
			if(marker_result.message)
				to_chat(user, SPAN_WARNING("Лазерная отметка: [marker_result.message]"))
			return FALSE
		place_manual_designation(target_turf, user)
		return TRUE

	if(armed_action_id == RTO_SUPPORT_ARM_VISIBILITY_ZONE)
		var/datum/rto_support_validation_result/zone_result = validation_service.validate_zone_deploy(src, target_turf, user, binoculars)
		if(!zone_result.success)
			if(zone_result.message)
				var/zone_name = active_template?.visibility_zone_name
				if(!zone_name || !length(zone_name))
					zone_name = "Сектор наведения"
				to_chat(user, SPAN_WARNING("[zone_name]: [zone_result.message]"))
			return FALSE
		var/zone_success = deploy_zone(target_turf)
		if(zone_success)
			disarm_action()
		return zone_success

	var/datum/rto_support_action_template/action_template = active_template?.get_action_template(armed_action_id)
	if(!action_template)
		return FALSE

	var/datum/rto_support_validation_result/support_result = validation_service.validate_support_call(src, action_template, target_turf, user, binoculars)
	if(!support_result.success)
		if(support_result.message)
			to_chat(user, SPAN_WARNING("[action_template.name]: [support_result.message]"))
		return FALSE

	var/datum/rto_support_request/request = new
	request.owner = owner
	request.target_turf = target_turf
	request.template = active_template
	request.action_template = action_template
	request.visibility_zone = get_active_zone()
	request.dispatch_key = RTO_SUPPORT_REQUEST_SUPPORT
	request.dispatch_path = action_template.fire_support_path
	request.scatter_override = action_template.scatter
	request.display_name = action_template.name
	request.request_kind = RTO_SUPPORT_REQUEST_SUPPORT
	request.target_marker_style = action_template.target_marker_style
	request.requires_visibility_zone = action_template.requires_visibility_zone
	request.announce_to_ghosts = TRUE

	if(!dispatch_service.dispatch_request(request))
		return FALSE

	shared_cooldown_until = world.time + get_effective_shared_cooldown(action_template)
	action_cooldowns[action_template.action_id] = world.time + get_effective_personal_cooldown(action_template)
	to_chat(user, SPAN_NOTICE("[action_template.name]: вызов подтвержден."))
	disarm_action()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/build_preset_ui_data()
	var/list/data = list()
	for(var/datum/rto_support_template/template as anything in get_available_templates())
		var/datum/rto_support_ui_preset_entry/entry = template.build_ui_entry(src)
		data += list(entry.to_list())
	return data

/datum/rto_support_controller/proc/find_template(template_type)
	return GLOB.rto_support_registry?.find_template(template_type)

/datum/rto_support_controller/proc/is_support_enabled_by_rules()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(!rules)
		return TRUE
	return !!rules.rto_support_enabled

/datum/rto_support_controller/proc/get_effective_shared_cooldown(datum/rto_support_action_template/action_template)
	if(!action_template)
		return 0
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/multiplier = rules ? rules.rto_shared_cooldown_multiplier : 1
	return max(1, round(max(1, action_template.shared_cooldown) * multiplier))

/datum/rto_support_controller/proc/get_effective_personal_cooldown(datum/rto_support_action_template/action_template)
	if(!action_template)
		return 0
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/multiplier = rules ? rules.rto_personal_cooldown_multiplier : 1
	return max(1, round(max(1, action_template.personal_cooldown) * multiplier))

/datum/rto_support_controller/proc/is_action_restricted_by_rules(action_id)
	if(is_support_enabled_by_rules())
		return FALSE
	if(!action_id)
		return FALSE
	return action_id != RTO_SUPPORT_ARM_COORDINATES && action_id != RTO_SUPPORT_ARM_MARKER

/datum/rto_support_controller/proc/apply_rules_update()
	if(is_action_restricted_by_rules(armed_action_id))
		reset_armed_action()
	if(!is_support_enabled_by_rules() && active_zone)
		clear_active_zone(FALSE)
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/replace_active_zone(datum/rto_visibility_zone/new_zone)
	clear_active_zone(FALSE)
	active_zone = new_zone
	schedule_zone_expiry()

/datum/rto_support_controller/proc/clear_active_zone(apply_cooldown = TRUE)
	var/datum/rto_visibility_zone/zone = active_zone
	active_zone = null
	clear_zone_expiry_timer()
	if(!zone)
		return FALSE

	var/datum/rto_support_template/source_template = zone.source_template
	zone.expire()
	qdel(zone)

	if(apply_cooldown && source_template?.requires_visibility_zone && source_template.visibility_zone_cooldown > 0)
		visibility_zone_cooldown_until = max(visibility_zone_cooldown_until, world.time + source_template.visibility_zone_cooldown)
	return TRUE

/datum/rto_support_controller/proc/clear_manual_designation(obj/item/binoculars_override)
	var/obj/item/device/binoculars/rto/binoculars = null
	if(istype(binoculars_override, /obj/item/device/binoculars/rto) && !QDELETED(binoculars_override))
		binoculars = binoculars_override
	if(!binoculars)
		binoculars = get_owned_binocular()
	if(!binoculars)
		binoculars = get_rto_binocular_in_hand()
	binoculars?.stop_live_marker(owner, TRUE)
	return !!binoculars

/datum/rto_support_controller/proc/place_manual_designation(turf/target_turf, mob/living/carbon/human/user)
	var/obj/item/device/binoculars/rto/binoculars = get_active_binocular()
	if(!binoculars)
		return FALSE
	var/had_designation = binoculars.is_live_marker_active()
	clear_manual_designation()
	if(!binoculars.start_live_marker(target_turf, user))
		return FALSE
	if(user)
		if(had_designation)
			to_chat(user, SPAN_NOTICE("Лазерная отметка перенесена."))
		else
			to_chat(user, SPAN_NOTICE("Лазерная отметка активирована."))
		send_coordinate_report(target_turf, user, "Лазерная отметка")
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/acquire_explicit_coordinates(turf/target_turf, mob/living/carbon/human/user)
	send_coordinate_report(target_turf, user, "Координаты")
	return TRUE

/datum/rto_support_controller/proc/send_coordinate_report(turf/target_turf, mob/living/carbon/human/user, label = "Координаты")
	if(!target_turf || !user)
		return FALSE
	to_chat(user, SPAN_NOTICE("[label]: долгота [obfuscate_x(target_turf.x)], широта [obfuscate_y(target_turf.y)]."))
	return TRUE

/datum/rto_support_controller/proc/get_armed_mode_name()
	if(!armed_action_id)
		return null
	switch(armed_action_id)
		if(RTO_SUPPORT_ARM_VISIBILITY_ZONE)
			return active_template?.visibility_zone_name || "Сектор наведения"
		if(RTO_SUPPORT_ARM_COORDINATES)
			return "Координаты"
		if(RTO_SUPPORT_ARM_MARKER)
			return "Лазерная отметка"
	var/datum/rto_support_action_template/action_template = active_template?.get_action_template(armed_action_id)
	return action_template?.name

/datum/rto_support_controller/proc/clear_actions()
	remove_select_action()
	remove_visibility_action()
	remove_coordinates_action()
	remove_manual_marker_action()
	remove_support_actions()
	action_handles = list()
/datum/rto_support_controller/proc/sync_actions()
	if(!owner || QDELETED(owner) || GET_DEFAULT_ROLE(owner.job) != JOB_SQUAD_RTO)
		clear_actions()
		return

	ensure_coordinates_action()
	ensure_manual_marker_action()

	if(!active_template)
		ensure_select_action()
		remove_visibility_action()
		remove_support_actions()
		rebuild_action_handles()
		sync_action_visibility()
		return

	remove_select_action()
	if(template_requires_zone())
		ensure_visibility_action()
	else
		remove_visibility_action()
	ensure_support_actions()
	rebuild_action_handles()
	sync_action_visibility()

/datum/rto_support_controller/proc/ensure_select_action()
	if(select_action && !QDELETED(select_action))
		return
	select_action = new /datum/action/human_action/rto/select_preset(src)
	select_action.give_to(owner)

/datum/rto_support_controller/proc/remove_select_action()
	if(!select_action)
		return
	if(select_action.owner)
		select_action.remove_from(select_action.owner)
	qdel(select_action)
	select_action = null

/datum/rto_support_controller/proc/ensure_visibility_action()
	if(visibility_action && !QDELETED(visibility_action))
		return
	visibility_action = new /datum/action/human_action/rto/visibility_zone(src)
	visibility_action.give_to(owner)

/datum/rto_support_controller/proc/remove_visibility_action()
	if(!visibility_action)
		return
	if(visibility_action.owner)
		visibility_action.remove_from(visibility_action.owner)
	qdel(visibility_action)
	visibility_action = null

/datum/rto_support_controller/proc/ensure_coordinates_action()
	if(coordinates_action && !QDELETED(coordinates_action))
		return
	coordinates_action = new /datum/action/human_action/rto/coordinates(src)
	coordinates_action.give_to(owner)

/datum/rto_support_controller/proc/remove_coordinates_action()
	if(!coordinates_action)
		return
	if(coordinates_action.owner)
		coordinates_action.remove_from(coordinates_action.owner)
	qdel(coordinates_action)
	coordinates_action = null

/datum/rto_support_controller/proc/ensure_manual_marker_action()
	if(manual_marker_action && !QDELETED(manual_marker_action))
		return
	manual_marker_action = new /datum/action/human_action/rto/manual_marker(src)
	manual_marker_action.give_to(owner)

/datum/rto_support_controller/proc/remove_manual_marker_action()
	if(!manual_marker_action)
		return
	if(manual_marker_action.owner)
		manual_marker_action.remove_from(manual_marker_action.owner)
	qdel(manual_marker_action)
	manual_marker_action = null

/datum/rto_support_controller/proc/ensure_support_actions()
	var/list/valid_ids = list()
	for(var/datum/rto_support_action_template/action_template as anything in get_action_templates())
		valid_ids += action_template.action_id
		var/datum/action/human_action/rto/support/action = support_actions[action_template.action_id]
		if(action && !QDELETED(action))
			continue
		action = new /datum/action/human_action/rto/support(src, action_template)
		action.give_to(owner)
		support_actions[action_template.action_id] = action

	for(var/action_id in support_actions.Copy())
		if(action_id in valid_ids)
			continue
		remove_support_action(action_id)

/datum/rto_support_controller/proc/remove_support_actions()
	if(!support_actions)
		return
	for(var/action_id in support_actions.Copy())
		remove_support_action(action_id)

/datum/rto_support_controller/proc/remove_support_action(action_id)
	var/datum/action/human_action/rto/support/action = support_actions[action_id]
	support_actions -= action_id
	if(!action)
		return
	if(action.owner)
		action.remove_from(action.owner)
	qdel(action)

/datum/rto_support_controller/proc/rebuild_action_handles()
	action_handles = list()
	if(select_action && !QDELETED(select_action))
		action_handles += select_action
	if(visibility_action && !QDELETED(visibility_action))
		action_handles += visibility_action
	if(coordinates_action && !QDELETED(coordinates_action))
		action_handles += coordinates_action
	if(manual_marker_action && !QDELETED(manual_marker_action))
		action_handles += manual_marker_action
	for(var/action_id in support_actions)
		var/datum/action/human_action/rto/support/action = support_actions[action_id]
		if(action && !QDELETED(action))
			action_handles += action

/datum/rto_support_controller/proc/refresh_visible_actions()
	if(!runtime_initialized)
		return FALSE
	if(!validate_owner_runtime())
		return FALSE
	sync_actions()
	sync_action_visibility()
	last_binocular_in_hand = has_rto_binocular_in_hand()
	for(var/datum/action/human_action/rto/action as anything in action_handles.Copy())
		if(!action || QDELETED(action))
			action_handles -= action
			continue
		if(action.hidden)
			continue
		action.refresh_from_controller()
	return TRUE

/datum/rto_support_controller/proc/refresh_action_handles()
	if(!runtime_initialized)
		return
	prune_zone_state()
	if(!refresh_visible_actions())
		update_hud_tick_state()
		return
	update_hud_tick_state()

/datum/rto_support_controller/proc/handle_owner_death()
	reset_armed_action()
	clear_active_zone()
	clear_manual_designation()
	last_binocular_in_hand = FALSE
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/handle_owner_revived()
	if(!ensure_runtime())
		return FALSE
	last_binocular_in_hand = has_rto_binocular_in_hand()
	sync_actions()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/handle_inventory_changed(obj/item/changed_item, slot = null, signal_id = null)
	var/was_in_hand = last_binocular_in_hand
	var/is_in_hand = has_rto_binocular_in_hand()
	if(!is_inventory_change_relevant(changed_item, slot, signal_id) && was_in_hand == is_in_hand)
		return FALSE
	if(armed_action_id && was_in_hand && !is_in_hand)
		reset_armed_action()
		if(owner && owner.stat != DEAD)
			to_chat(owner, SPAN_WARNING("RTO-бинокль убран из рук. Наведение отменено."))
	if(!is_in_hand)
		var/obj/item/device/binoculars/rto/dropped_binocular = istype(changed_item, /obj/item/device/binoculars/rto) ? changed_item : null
		clear_manual_designation(dropped_binocular)
	last_binocular_in_hand = is_in_hand
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/is_inventory_change_relevant(obj/item/changed_item, slot = null, signal_id = null)
	if(istype(changed_item, /obj/item/device/binoculars/rto))
		return TRUE
	if(istype(changed_item, /obj/item/storage/pouch/sling/rto))
		return TRUE
	if(slot == WEAR_L_HAND || slot == WEAR_R_HAND)
		return last_binocular_in_hand || has_rto_binocular_in_hand()
	return FALSE
/datum/rto_support_controller/proc/get_remaining_shared_cooldown()
	return max(0, shared_cooldown_until - world.time)

/datum/rto_support_controller/proc/get_remaining_visibility_cooldown()
	return max(0, visibility_zone_cooldown_until - world.time)

/datum/rto_support_controller/proc/get_remaining_action_cooldown(action_id)
	var/cooldown_until = action_cooldowns[action_id]
	return max(0, cooldown_until - world.time)

/datum/rto_support_controller/proc/format_block_messages(list/reasons)
	return length(reasons) ? jointext(reasons, "\n") : null

/datum/rto_support_controller/proc/build_visibility_action_state()
	var/list/state = list(
		"has_binocular_in_hand" = has_rto_binocular_in_hand(),
		"is_armed" = is_action_armed(RTO_SUPPORT_ARM_VISIBILITY_ZONE),
		"zone_state" = get_zone_state(),
		"zone_ready_in" = get_zone_ready_in(),
		"zone_expires_in" = get_zone_expires_in(),
		"is_disabled" = FALSE,
		"primary_label" = RTO_SUPPORT_STATUS_READY,
		"countdown_text" = null,
		"countdown_color" = "#f2f2f2"
	)

	if(!active_template || !template_requires_zone())
		state["is_disabled"] = TRUE
		return state
	if(!is_support_enabled_by_rules())
		state["is_disabled"] = TRUE
		state["primary_label"] = "Disabled by Game Rule Panel"
		state["countdown_text"] = "GM"
		state["countdown_color"] = "#c6c6c6"
		return state
	if(!state["has_binocular_in_hand"])
		state["is_disabled"] = TRUE
		state["primary_label"] = RTO_SUPPORT_STATUS_NO_BINOCULAR
		state["countdown_text"] = "B"
		state["countdown_color"] = "#c6c6c6"
		return state
	if(state["is_armed"])
		state["primary_label"] = RTO_SUPPORT_STATUS_TARGETING
		state["countdown_text"] = "ARM"
		state["countdown_color"] = "#ffd25a"
		return state

	switch(state["zone_state"])
		if(RTO_SUPPORT_ZONE_STATE_ACTIVE)
			var/remaining_active = round(get_zone_expires_in() / 10)
			state["is_disabled"] = TRUE
			state["primary_label"] = "[RTO_SUPPORT_STATUS_ACTIVE]: [remaining_active]s"
			state["countdown_text"] = "[remaining_active]s"
			state["countdown_color"] = "#7ee1ff"
		if(RTO_SUPPORT_ZONE_STATE_COOLDOWN)
			var/remaining_cooldown = round(get_zone_ready_in() / 10)
			state["is_disabled"] = TRUE
			state["primary_label"] = "CD: [remaining_cooldown]s"
			state["countdown_text"] = "[remaining_cooldown]s"
			state["countdown_color"] = "#c6c6c6"
	return state

/datum/rto_support_controller/proc/get_displayed_ability_cooldown(action_id)
	var/personal_cooldown_in = get_remaining_action_cooldown(action_id)
	var/shared_cooldown_in = get_remaining_shared_cooldown()
	var/list/result = list(
		"kind" = "none",
		"value" = 0
	)

	if(personal_cooldown_in <= 0 && shared_cooldown_in <= 0)
		return result
	if(personal_cooldown_in >= shared_cooldown_in && personal_cooldown_in > 0)
		result["kind"] = "personal"
		result["value"] = personal_cooldown_in
		return result
	if(shared_cooldown_in > 0)
		result["kind"] = "shared"
		result["value"] = shared_cooldown_in
	return result

/datum/rto_support_controller/proc/build_support_action_state(action_id)
	var/datum/rto_support_action_template/action_template = active_template?.get_action_template(action_id)
	var/zone_state = get_zone_state()
	var/zone_ready_in = get_zone_ready_in()
	var/zone_expires_in = get_zone_expires_in()
	var/shared_cooldown_in = get_remaining_shared_cooldown()
	var/personal_cooldown_in = get_remaining_action_cooldown(action_id)
	var/list/display_cooldown = get_displayed_ability_cooldown(action_id)
	var/requires_zone = !!(action_template?.requires_visibility_zone && template_requires_zone())
	var/list/state = list(
		"has_binocular_in_hand" = has_rto_binocular_in_hand(),
		"is_armed" = is_action_armed(action_id),
		"requires_zone" = requires_zone,
		"zone_state" = zone_state,
		"zone_ready_in" = zone_ready_in,
		"zone_expires_in" = zone_expires_in,
		"shared_cooldown_in" = shared_cooldown_in,
		"personal_cooldown_in" = personal_cooldown_in,
		"display_cooldown_kind" = display_cooldown["kind"],
		"display_cooldown_in" = display_cooldown["value"],
		"is_disabled" = FALSE,
		"primary_label" = RTO_SUPPORT_STATUS_READY,
		"countdown_text" = null,
		"countdown_color" = "#f2f2f2",
		"secondary_labels" = list()
	)

	if(!action_template)
		state["is_disabled"] = TRUE
		return state
	if(!is_support_enabled_by_rules())
		state["is_disabled"] = TRUE
		state["primary_label"] = "Disabled by Game Rule Panel"
		state["countdown_text"] = "GM"
		state["countdown_color"] = "#c6c6c6"
		return state
	if(!state["has_binocular_in_hand"])
		state["is_disabled"] = TRUE
		state["primary_label"] = RTO_SUPPORT_STATUS_NO_BINOCULAR
		state["countdown_text"] = "B"
		state["countdown_color"] = "#c6c6c6"
		return state
	if(state["is_armed"])
		state["primary_label"] = RTO_SUPPORT_STATUS_TARGETING
		state["countdown_text"] = "ARM"
		state["countdown_color"] = "#ffd25a"
		return state

	if(requires_zone)
		if(zone_state != RTO_SUPPORT_ZONE_STATE_ACTIVE)
			state["is_disabled"] = TRUE
			state["primary_label"] = RTO_SUPPORT_STATUS_NO_ZONE
			state["countdown_text"] = null
			state["countdown_color"] = "#c6c6c6"
			return state

	switch(display_cooldown["kind"])
		if("personal")
			var/display_personal = round(display_cooldown["value"] / 10)
			state["is_disabled"] = TRUE
			state["primary_label"] = "Личный КД: [display_personal]s"
			state["countdown_text"] = "[display_personal]s"
			state["countdown_color"] = "#c6c6c6"
			return state
		if("shared")
			var/display_shared = round(display_cooldown["value"] / 10)
			state["is_disabled"] = TRUE
			state["primary_label"] = "Общий КД: [display_shared]s"
			state["countdown_text"] = "[display_shared]s"
			state["countdown_color"] = "#c6c6c6"
			return state

	return state

/datum/rto_support_controller/proc/get_action_block_messages(action_id)
	var/list/messages = list()
	if(action_id == RTO_SUPPORT_ARM_COORDINATES || action_id == RTO_SUPPORT_ARM_MARKER)
		return messages
	if(is_action_restricted_by_rules(action_id))
		messages += "Disabled by Game Rule Panel"
		return messages
	if(!active_template)
		messages += "Сначала выберите пакет поддержки."
		return messages
	if(action_id == RTO_SUPPORT_ARM_VISIBILITY_ZONE)
		if(!template_requires_zone())
			messages += "Этот пакет не использует сектор наведения."
			return messages
		var/zone_name = active_template?.visibility_zone_name || "Сектор наведения"
		if(get_active_zone())
			messages += "[zone_name] уже активен."
			return messages
		var/zone_cooldown = get_remaining_visibility_cooldown()
		if(zone_cooldown > 0)
			messages += "[zone_name] перезаряжается: [round(zone_cooldown / 10)] с."
		return messages

	var/datum/rto_support_action_template/action_template = active_template.get_action_template(action_id)
	if(!action_template)
		messages += "Неизвестная способность поддержки."
		return messages

	if(action_template.requires_visibility_zone && template_requires_zone())
		if(get_zone_state() == RTO_SUPPORT_ZONE_STATE_COOLDOWN)
			messages += "Сектор наведения перезаряжается: [round(get_zone_ready_in() / 10)] с."
		else if(get_zone_state() == RTO_SUPPORT_ZONE_STATE_ACTIVE)
			messages += "Сектор активен: [round(get_zone_expires_in() / 10)] с."
		else
			messages += "Сначала разверните сектор наведения."

	var/personal_cooldown = get_remaining_action_cooldown(action_id)
	if(personal_cooldown > 0)
		messages += "Личный кулдаун [action_template.name]: [round(personal_cooldown / 10)] с."
	var/shared_cooldown = get_remaining_shared_cooldown()
	if(shared_cooldown > 0)
		messages += "Общий кулдаун пакета: [round(shared_cooldown / 10)] с."
	return messages
/datum/rto_support_controller/proc/get_action_block_message(action_id)
	return format_block_messages(get_action_block_messages(action_id))

/datum/rto_support_controller/proc/is_action_armed(action_id)
	return armed_action_id == action_id

/datum/rto_support_controller/proc/has_rto_binocular()
	return !!get_owned_binocular()

/datum/rto_support_controller/proc/has_rto_binocular_in_hand()
	return !!get_rto_binocular_in_hand()

/datum/rto_support_controller/proc/get_rto_binocular_in_hand() as /obj/item/device/binoculars/rto
	if(!owner)
		return null
	if(istype(owner.l_hand, /obj/item/device/binoculars/rto))
		return owner.l_hand
	if(istype(owner.r_hand, /obj/item/device/binoculars/rto))
		return owner.r_hand
	return null

/datum/rto_support_controller/proc/get_owned_binocular() as /obj/item/device/binoculars/rto
	if(!owner)
		return null
	for(var/atom/movable/movable as anything in owner.contents_recursive())
		if(istype(movable, /obj/item/device/binoculars/rto))
			return movable
	return null

/datum/rto_support_controller/proc/get_active_binocular() as /obj/item/device/binoculars/rto
	if(istype(owner?.interactee, /obj/item/device/binoculars/rto))
		return owner.interactee
	return null

/datum/rto_support_controller/proc/sync_action_visibility()
	if(!owner)
		return FALSE
	var/visible = has_required_role() && owner.stat != DEAD && has_rto_binocular_in_hand()
	for(var/datum/action/human_action/rto/action as anything in action_handles)
		if(!action || QDELETED(action) || !action.owner)
			continue
		if(visible)
			if(action.hidden)
				action.unhide_from(owner)
		else
			if(!action.hidden)
				action.hide_from(owner)
	return TRUE

/datum/rto_support_controller/proc/validate_owner_runtime()
	if(!owner || QDELETED(owner))
		stop_hud_tick()
		return FALSE
	if(has_required_role())
		return TRUE
	reset_armed_action()
	clear_active_zone(FALSE)
	clear_manual_designation()
	clear_actions()
	stop_hud_tick()
	return FALSE

/datum/rto_support_controller/proc/prune_zone_state()
	if(active_zone && !active_zone.is_active())
		clear_active_zone()
		return TRUE
	return FALSE

/datum/rto_support_controller/proc/needs_hud_tick()
	if(!runtime_initialized || !owner || QDELETED(owner))
		return FALSE
	if(!has_required_role())
		return FALSE
	if(owner.stat == DEAD)
		return FALSE
	if(!has_rto_binocular_in_hand())
		return FALSE
	if(!length(action_handles))
		return FALSE
	var/zone_state = get_zone_state()
	if(zone_state == RTO_SUPPORT_ZONE_STATE_ACTIVE || zone_state == RTO_SUPPORT_ZONE_STATE_COOLDOWN)
		return TRUE
	if(get_remaining_shared_cooldown() > 0)
		return TRUE
	for(var/action_id in action_cooldowns)
		if(get_remaining_action_cooldown(action_id) > 0)
			return TRUE
	return FALSE

/datum/rto_support_controller/proc/start_hud_tick()
	if(hud_tick_timer_id)
		return FALSE
	hud_tick_timer_id = addtimer(CALLBACK(src, PROC_REF(refresh_action_handles)), 1 SECONDS, TIMER_LOOP|TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/datum/rto_support_controller/proc/stop_hud_tick()
	if(!hud_tick_timer_id)
		return FALSE
	deltimer(hud_tick_timer_id)
	hud_tick_timer_id = null
	return TRUE

/datum/rto_support_controller/proc/update_hud_tick_state()
	if(needs_hud_tick())
		start_hud_tick()
		return TRUE
	stop_hud_tick()
	return FALSE

/datum/rto_support_controller/proc/clear_zone_expiry_timer()
	if(!zone_expiry_timer_id)
		return FALSE
	deltimer(zone_expiry_timer_id)
	zone_expiry_timer_id = null
	return TRUE

/datum/rto_support_controller/proc/schedule_zone_expiry()
	clear_zone_expiry_timer()
	if(!active_zone || !active_zone.expires_at)
		return FALSE
	var/time_left = max(1, active_zone.expires_at - world.time)
	zone_expiry_timer_id = addtimer(CALLBACK(src, PROC_REF(handle_active_zone_expired)), time_left, TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/datum/rto_support_controller/proc/handle_active_zone_expired()
	zone_expiry_timer_id = null
	if(!active_zone)
		return FALSE
	clear_active_zone()
	refresh_action_handles()
	return TRUE
