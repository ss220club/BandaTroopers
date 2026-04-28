/// Runtime coordinator for one RTO owner.
/datum/rto_support_controller
	var/mob/living/carbon/human/owner
	var/list/selected_templates = list()
	var/datum/rto_visibility_zone/active_zone
	var/armed_action_id
	var/armed_template_id
	var/list/shared_cooldowns_by_template = list()
	var/zone_shared_cooldown_until = 0
	var/list/zone_cooldowns_by_template = list()
	var/list/action_cooldowns = list()
	var/list/package_lockouts_by_template = list()
	var/list/support_pools_by_id = list()
	var/list/support_pool_overrides_by_id = list()
	var/list/action_handles = list()
	var/max_selected_templates = 2
	var/selection_reset_delay = 60 MINUTES
	var/datum/action/human_action/rto/select_preset/select_action
	var/list/visibility_actions = list()
	var/datum/action/human_action/rto/coordinates/coordinates_action
	var/datum/action/human_action/rto/manual_marker/manual_marker_action
	var/list/support_actions = list()
	var/datum/rto_support_validation_service/validation_service
	var/datum/rto_support_dispatch_service/dispatch_service
	var/hud_tick_timer_id = null
	var/zone_expiry_timer_id = null
	var/last_binocular_in_hand = FALSE
	var/runtime_initialized = FALSE
	var/selection_started_at = 0
	var/selection_reset_available_at = 0

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
	selected_templates = null
	shared_cooldowns_by_template = null
	zone_cooldowns_by_template = null
	action_cooldowns = null
	package_lockouts_by_template = null
	clear_support_pools()
	support_pools_by_id = null
	clear_support_pool_overrides()
	support_pool_overrides_by_id = null
	action_handles = null
	visibility_actions = null
	support_actions = null
	owner = null
	return ..()

/datum/rto_support_controller/proc/ensure_runtime()
	if(!owner || QDELETED(owner))
		return FALSE
	if(!validation_service)
		validation_service = new
	if(!dispatch_service)
		dispatch_service = new
	if(!selected_templates)
		selected_templates = list()
	if(!shared_cooldowns_by_template)
		shared_cooldowns_by_template = list()
	if(!zone_cooldowns_by_template)
		zone_cooldowns_by_template = list()
	if(!action_cooldowns)
		action_cooldowns = list()
	if(!package_lockouts_by_template)
		package_lockouts_by_template = list()
	if(!support_pools_by_id)
		support_pools_by_id = list()
	if(!support_pool_overrides_by_id)
		support_pool_overrides_by_id = list()
	if(!action_handles)
		action_handles = list()
	if(!visibility_actions)
		visibility_actions = list()
	if(!support_actions)
		support_actions = list()
	apply_support_pool_rules_update()
	runtime_initialized = TRUE
	sync_actions()
	last_binocular_in_hand = has_rto_binocular_in_hand()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/has_required_role()
	return owner && !QDELETED(owner) && GET_DEFAULT_ROLE(owner.job) == JOB_SQUAD_RTO

/datum/rto_support_controller/proc/get_support_profile()
	var/obj/item/device/binoculars/rto/binoculars = get_owned_binocular()
	if(binoculars)
		return binoculars.get_support_profile()
	if(owner?.job == JOB_SQUAD_RTO_UNSC)
		return "unsc"
	if(owner?.job == JOB_SQUAD_RTO_ODST)
		return "odst"
	return "uscm"

/datum/rto_support_controller/proc/get_available_templates()
	if(!owner || GET_DEFAULT_ROLE(owner.job) != JOB_SQUAD_RTO)
		return list()
	var/list/templates = GLOB.rto_support_registry?.get_template_catalog()
	if(!templates)
		return list()

	var/list/available_templates = list()
	for(var/datum/rto_support_template/template as anything in templates)
		if(!template?.is_available_to(src))
			continue
		available_templates += template

	return available_templates

/datum/rto_support_controller/proc/get_selected_templates()
	return selected_templates ? selected_templates.Copy() : list()

/datum/rto_support_controller/proc/get_selected_template_slot(template_type)
	if(!template_type || !length(selected_templates))
		return 0
	var/template_id = null
	if(istype(template_type, /datum/rto_support_template))
		var/datum/rto_support_template/template = template_type
		template_id = template.template_id
	else if(istext(template_type))
		template_id = template_type
	if(!template_id)
		return 0
	for(var/index in 1 to length(selected_templates))
		var/datum/rto_support_template/template = selected_templates[index]
		if(template?.template_id == template_id)
			return index
	return 0

/datum/rto_support_controller/proc/get_selected_template(template_type) as /datum/rto_support_template
	if(!template_type)
		return null
	if(istype(template_type, /datum/rto_support_template))
		var/datum/rto_support_template/template = template_type
		return get_selected_template_slot(template.template_id) ? template : null
	if(!istext(template_type))
		return null
	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(template?.template_id == template_type)
			return template
	return null

/datum/rto_support_controller/proc/has_selected_template(template_type)
	return !!get_selected_template(template_type)

/datum/rto_support_controller/proc/get_primary_selected_template() as /datum/rto_support_template
	return length(selected_templates) ? selected_templates[1] : null

/datum/rto_support_controller/proc/can_open_template_menu()
	if(!owner || QDELETED(owner))
		return FALSE
	if(GET_DEFAULT_ROLE(owner.job) != JOB_SQUAD_RTO)
		return FALSE
	if(!is_support_enabled_by_rules())
		return FALSE
	return TRUE

/datum/rto_support_controller/proc/can_add_template()
	if(!can_open_template_menu())
		return FALSE
	return length(selected_templates) < get_max_selected_templates()

/datum/rto_support_controller/proc/can_select_template()
	return can_add_template()

/datum/rto_support_controller/proc/can_add_specific_template(template_type)
	if(!can_add_template())
		return FALSE
	var/datum/rto_support_template/template = find_template(template_type)
	if(!template)
		return FALSE
	return !has_selected_template(template.template_id)

/datum/rto_support_controller/proc/can_reset_templates()
	if(!can_open_template_menu())
		return FALSE
	if(!length(selected_templates))
		return FALSE
	return world.time >= selection_reset_available_at

/datum/rto_support_controller/proc/get_selection_reset_ready_in()
	if(!length(selected_templates))
		return 0
	return max(0, selection_reset_available_at - world.time)

/datum/rto_support_controller/proc/get_max_selected_templates()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(!rules)
		return max_selected_templates
	return rules.get_rto_template_slot_count()

/datum/rto_support_controller/proc/get_selection_reset_delay()
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(!rules)
		return selection_reset_delay
	return rules.get_rto_template_reset_delay()

/datum/rto_support_controller/proc/get_selection_reset_delay_minutes()
	return round(get_selection_reset_delay() / (1 MINUTES))

/datum/rto_support_controller/proc/resolve_template_resource_target(template_type = null) as /datum/rto_support_template
	if(istype(template_type, /datum/rto_support_template))
		return template_type
	if(istext(template_type))
		return get_selected_template(template_type) || find_template(template_type)
	return get_primary_selected_template()

/datum/rto_support_controller/proc/get_template_support_resource_mode(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return RTO_SUPPORT_RESOURCE_MODE_LEGACY

	var/mode = template.support_resource_mode || RTO_SUPPORT_RESOURCE_MODE_LEGACY
	if(mode == RTO_SUPPORT_RESOURCE_MODE_LEGACY)
		return RTO_SUPPORT_RESOURCE_MODE_LEGACY
	if(template.support_pool_capacity <= 0)
		return RTO_SUPPORT_RESOURCE_MODE_LEGACY

	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(!rules)
		return mode

	if(rules.get_rto_support_resource_mode() == RTO_SUPPORT_RESOURCE_MODE_LEGACY)
		return RTO_SUPPORT_RESOURCE_MODE_LEGACY

	return mode

/datum/rto_support_controller/proc/template_has_support_pool_configuration(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return FALSE
	var/mode = template.support_resource_mode || RTO_SUPPORT_RESOURCE_MODE_LEGACY
	if(mode == RTO_SUPPORT_RESOURCE_MODE_LEGACY)
		return FALSE
	return template.support_pool_capacity > 0

/datum/rto_support_controller/proc/template_uses_support_pool(template_type = null)
	return get_template_support_resource_mode(template_type) != RTO_SUPPORT_RESOURCE_MODE_LEGACY

/datum/rto_support_controller/proc/get_support_pool_id(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return null
	return template.support_pool_id || template.template_id

/datum/rto_support_controller/proc/get_support_pool_override(template_type = null, create_if_missing = FALSE)
	if(!support_pool_overrides_by_id)
		support_pool_overrides_by_id = list()

	var/pool_id = get_support_pool_id(template_type)
	if(!pool_id)
		return null

	var/list/pool_override = support_pool_overrides_by_id[pool_id]
	if(!pool_override && create_if_missing)
		pool_override = list()
		support_pool_overrides_by_id[pool_id] = pool_override
	return pool_override

/datum/rto_support_controller/proc/clear_support_pool_override(template_type = null)
	var/pool_id = null
	if(istext(template_type) && support_pool_overrides_by_id && support_pool_overrides_by_id[template_type])
		pool_id = template_type
	else
		pool_id = get_support_pool_id(template_type)
	if(!pool_id || !support_pool_overrides_by_id)
		return FALSE
	support_pool_overrides_by_id -= pool_id
	return TRUE

/datum/rto_support_controller/proc/clear_support_pool_overrides()
	if(!length(support_pool_overrides_by_id))
		return FALSE
	support_pool_overrides_by_id.Cut()
	return TRUE

/datum/rto_support_controller/proc/get_effective_support_pool_capacity(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return 0
	var/list/pool_override = get_support_pool_override(template)
	if(pool_override && !isnull(pool_override["capacity"]))
		return max(0, round(pool_override["capacity"]))
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/multiplier = rules ? rules.get_rto_charge_capacity_multiplier() : 1
	return max(0, round(max(0, template.support_pool_capacity) * multiplier))

/datum/rto_support_controller/proc/get_effective_support_pool_starting_charges(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return 0
	return clamp(round(template.support_pool_starting_charges), 0, get_effective_support_pool_capacity(template))

/datum/rto_support_controller/proc/get_effective_support_pool_recharge_interval(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return 0
	if(template.support_pool_recharge_interval <= 0)
		return 0
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/multiplier = rules ? rules.get_rto_charge_recharge_multiplier() : 1
	return max(1, round(template.support_pool_recharge_interval / max(0.1, multiplier)))

/datum/rto_support_controller/proc/get_support_pool_recharge_amount(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return 0
	return max(0, round(template.support_pool_recharge_amount))

/datum/rto_support_controller/proc/get_support_pool_recharge_interval(template_type = null)
	var/datum/rto_support_resource_pool_state/pool = get_support_pool(template_type)
	if(pool)
		return pool.recharge_interval
	return get_effective_support_pool_recharge_interval(template_type)

/datum/rto_support_controller/proc/is_support_pool_auto_recharge_enabled(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return FALSE
	var/list/pool_override = get_support_pool_override(template)
	var/auto_recharge_enabled = !isnull(pool_override?["auto_recharge_enabled"]) ? !!pool_override["auto_recharge_enabled"] : !!template.support_pool_auto_recharge
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(rules?.rto_charge_manual_only)
		return FALSE
	if(rules && !rules.rto_charge_recharge_enabled)
		return FALSE
	return auto_recharge_enabled

/datum/rto_support_controller/proc/is_support_pool_manual_only(template_type = null)
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	if(rules?.rto_charge_manual_only)
		return TRUE
	var/list/pool_override = get_support_pool_override(template_type)
	if(pool_override && !isnull(pool_override["manual_only"]))
		return !!pool_override["manual_only"]
	return FALSE

/datum/rto_support_controller/proc/get_support_pool(template_type = null, create_if_missing = FALSE) as /datum/rto_support_resource_pool_state
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template || !template_uses_support_pool(template))
		return null

	var/pool_id = get_support_pool_id(template)
	if(!pool_id)
		return null

	var/datum/rto_support_resource_pool_state/pool = support_pools_by_id[pool_id]
	if(!pool && create_if_missing)
		pool = new
		support_pools_by_id[pool_id] = pool

	if(pool)
		pool.sync_configuration(
			pool_id,
			template.template_id,
			owner,
			get_effective_support_pool_capacity(template),
			get_effective_support_pool_starting_charges(template),
			get_effective_support_pool_recharge_interval(template),
			get_support_pool_recharge_amount(template),
			is_support_pool_auto_recharge_enabled(template),
			is_support_pool_manual_only(template),
			world.time
		)

	return pool

/datum/rto_support_controller/proc/get_support_pool_current_charges(template_type = null)
	var/datum/rto_support_resource_pool_state/pool = get_support_pool(template_type, TRUE)
	if(!pool)
		return 0
	return pool.get_current_charges(world.time)

/datum/rto_support_controller/proc/get_support_pool_capacity(template_type = null)
	var/datum/rto_support_resource_pool_state/pool = get_support_pool(template_type)
	if(pool)
		return pool.capacity
	return get_effective_support_pool_capacity(template_type)

/datum/rto_support_controller/proc/get_support_pool_next_recharge_in(template_type = null)
	var/datum/rto_support_resource_pool_state/pool = get_support_pool(template_type, TRUE)
	if(!pool)
		return 0
	return pool.get_next_recharge_in(world.time)

/datum/rto_support_controller/proc/get_effective_support_pool_cost(datum/rto_support_action_template/action_template)
	if(!action_template)
		return 0
	if(action_template.support_pool_cost > 0)
		return max(1, round(action_template.support_pool_cost))
	return 1

/datum/rto_support_controller/proc/get_effective_action_lockout(datum/rto_support_action_template/action_template)
	if(!action_template)
		return 0
	if(action_template.personal_lockout > 0)
		return max(1, round(action_template.personal_lockout))
	if(action_template.personal_cooldown <= 0)
		return 0
	var/datum/game_rule_state/rules = GLOB.game_rule_state
	var/multiplier = rules ? rules.rto_personal_cooldown_multiplier : 1
	return max(1, round(action_template.personal_cooldown * multiplier))

/datum/rto_support_controller/proc/get_effective_support_package_lockout(template_type = null, datum/rto_support_action_template/action_template = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(template?.support_package_lockout > 0)
		return max(1, round(template.support_package_lockout))
	return get_effective_action_lockout(action_template)

/datum/rto_support_controller/proc/can_pay_support_pool_cost(datum/rto_support_action_template/action_template, template_type = null)
	var/datum/rto_support_resource_pool_state/pool = get_support_pool(template_type)
	if(!pool)
		return FALSE
	return pool.can_pay(get_effective_support_pool_cost(action_template), world.time)

/datum/rto_support_controller/proc/apply_action_resource_consumption(datum/rto_support_template/template, datum/rto_support_action_template/action_template)
	if(!template || !action_template)
		return FALSE

	if(template_uses_support_pool(template))
		var/datum/rto_support_resource_pool_state/pool = get_support_pool(template, TRUE)
		if(!pool)
			return FALSE
		if(!pool.pay(get_effective_support_pool_cost(action_template), world.time))
			return FALSE
		var/lockout = get_effective_support_package_lockout(template, action_template)
		if(lockout > 0)
			package_lockouts_by_template[template.template_id] = world.time + lockout
		else
			package_lockouts_by_template -= template.template_id
		return TRUE

	shared_cooldowns_by_template[template.template_id] = world.time + get_effective_shared_cooldown(action_template)
	action_cooldowns[action_template.action_id] = world.time + get_effective_personal_cooldown(action_template)
	return TRUE

/datum/rto_support_controller/proc/remove_support_pool(template_type = null, clear_override = FALSE)
	var/pool_id = null
	if(istext(template_type) && support_pools_by_id && support_pools_by_id[template_type])
		pool_id = template_type
	else
		pool_id = get_support_pool_id(template_type)
	if(!pool_id)
		return FALSE
	var/datum/rto_support_resource_pool_state/pool = support_pools_by_id[pool_id]
	support_pools_by_id -= pool_id
	if(pool)
		qdel(pool)
	if(clear_override)
		clear_support_pool_override(pool_id)
	return TRUE

/datum/rto_support_controller/proc/clear_support_pools(clear_overrides = FALSE)
	if(!length(support_pools_by_id))
		return FALSE
	for(var/pool_id in support_pools_by_id.Copy())
		remove_support_pool(pool_id, clear_overrides)
	return TRUE

/datum/rto_support_controller/proc/apply_support_pool_rules_update()
	if(!support_pools_by_id)
		support_pools_by_id = list()

	var/list/valid_pool_ids = list()
	for(var/datum/rto_support_template/template as anything in selected_templates)
		var/pool_id = get_support_pool_id(template)
		if(!pool_id)
			continue
		if(!template_has_support_pool_configuration(template))
			remove_support_pool(pool_id, FALSE)
			continue
		valid_pool_ids += pool_id
		if(template_uses_support_pool(template))
			get_support_pool(template, TRUE)

	for(var/pool_id in support_pools_by_id.Copy())
		if(pool_id in valid_pool_ids)
			continue
		remove_support_pool(pool_id, FALSE)

	return TRUE

/datum/rto_support_controller/proc/get_owner_ckey()
	if(!owner)
		return null
	return owner.ckey || owner.client?.ckey

/datum/rto_support_controller/proc/get_owner_display_name()
	if(!owner)
		return "Unknown RTO"
	if(length(owner.real_name))
		return owner.real_name
	if(length(owner.name))
		return owner.name
	return "Unknown RTO"

/datum/rto_support_controller/proc/build_admin_charge_data()
	var/list/selected_template_names = list()
	var/list/selected_template_entries = list()
	var/list/pools = list()

	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(!template)
			continue
		selected_template_names += template.name
		selected_template_entries += list(list(
			"template_id" = template.template_id,
			"name" = template.name,
			"uses_charge_pool" = template_uses_support_pool(template),
		))
		if(!template_uses_support_pool(template))
			continue

		var/datum/rto_support_resource_pool_state/pool = get_support_pool(template, TRUE)
		if(!pool)
			continue

		pools += list(list(
			"template_id" = template.template_id,
			"template_name" = template.name,
			"resource_mode" = get_template_support_resource_mode(template),
			"current_charges" = round(pool.get_current_charges(world.time)),
			"capacity" = round(pool.capacity),
			"starting_charges" = round(pool.starting_charges),
			"recharge_interval" = round(pool.recharge_interval / 10),
			"recharge_amount" = round(pool.recharge_amount),
			"auto_recharge_enabled" = !!pool.auto_recharge_enabled,
			"manual_only" = !!pool.manual_only,
			"next_recharge_in" = round(pool.get_next_recharge_in(world.time) / 10),
			"last_modified_by_admin_ckey" = pool.last_modified_by_admin_ckey || "",
		))

	return list(
		"ckey" = get_owner_ckey() || "",
		"name" = get_owner_display_name(),
		"job" = owner?.job || "",
		"support_profile" = get_support_profile(),
		"selected_templates" = selected_template_names,
		"selected_template_entries" = selected_template_entries,
		"selected_count" = length(selected_templates),
		"charge_pool_count" = length(pools),
		"pools" = pools,
	)

/datum/rto_support_controller/proc/get_admin_charge_pool(template_id)
	var/datum/rto_support_template/template = get_selected_template(template_id)
	if(!template || !template_uses_support_pool(template))
		return null
	return get_support_pool(template, TRUE)

/datum/rto_support_controller/proc/mark_admin_charge_pool_update(datum/rto_support_resource_pool_state/pool, admin_ckey = null)
	if(!pool)
		return FALSE
	pool.last_modified_by_admin_ckey = admin_ckey
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/set_template_pool_current_charges(template_id, value, admin_ckey = null)
	if(!isnum(value))
		return FALSE
	var/datum/rto_support_resource_pool_state/pool = get_admin_charge_pool(template_id)
	if(!pool)
		return FALSE
	pool.set_current_charges(value, world.time)
	return mark_admin_charge_pool_update(pool, admin_ckey)

/datum/rto_support_controller/proc/adjust_template_pool_current_charges(template_id, delta, admin_ckey = null)
	if(!isnum(delta))
		return FALSE
	var/datum/rto_support_resource_pool_state/pool = get_admin_charge_pool(template_id)
	if(!pool)
		return FALSE
	pool.adjust_current_charges(delta, world.time)
	return mark_admin_charge_pool_update(pool, admin_ckey)

/datum/rto_support_controller/proc/set_template_pool_capacity(template_id, value, admin_ckey = null)
	if(!isnum(value))
		return FALSE
	var/list/pool_override = get_support_pool_override(template_id, TRUE)
	if(!pool_override)
		return FALSE
	pool_override["capacity"] = max(0, round(value))
	var/datum/rto_support_resource_pool_state/pool = get_admin_charge_pool(template_id)
	if(!pool)
		return FALSE
	return mark_admin_charge_pool_update(pool, admin_ckey)

/datum/rto_support_controller/proc/set_template_pool_auto_recharge(template_id, enabled, admin_ckey = null)
	var/list/pool_override = get_support_pool_override(template_id, TRUE)
	if(!pool_override)
		return FALSE
	pool_override["auto_recharge_enabled"] = !!enabled
	var/datum/rto_support_resource_pool_state/pool = get_admin_charge_pool(template_id)
	if(!pool)
		return FALSE
	return mark_admin_charge_pool_update(pool, admin_ckey)

/datum/rto_support_controller/proc/set_template_pool_manual_only(template_id, enabled, admin_ckey = null)
	var/list/pool_override = get_support_pool_override(template_id, TRUE)
	if(!pool_override)
		return FALSE
	pool_override["manual_only"] = !!enabled
	var/datum/rto_support_resource_pool_state/pool = get_admin_charge_pool(template_id)
	if(!pool)
		return FALSE
	return mark_admin_charge_pool_update(pool, admin_ckey)

/datum/rto_support_controller/proc/reset_template_pool_to_defaults(template_id, admin_ckey = null)
	var/datum/rto_support_template/template = get_selected_template(template_id)
	if(!template || !template_uses_support_pool(template))
		return FALSE
	clear_support_pool_override(template_id)
	var/datum/rto_support_resource_pool_state/pool = get_support_pool(template, TRUE)
	if(!pool)
		return FALSE
	pool.set_current_charges(pool.starting_charges, world.time)
	return mark_admin_charge_pool_update(pool, admin_ckey)

/datum/rto_support_controller/proc/refill_all_template_pools(admin_ckey = null)
	var/updated = FALSE
	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(!template_uses_support_pool(template))
			continue
		var/datum/rto_support_resource_pool_state/pool = get_support_pool(template, TRUE)
		if(!pool)
			continue
		pool.set_current_charges(pool.capacity, world.time)
		pool.last_modified_by_admin_ckey = admin_ckey
		updated = TRUE
	if(updated)
		refresh_action_handles()
	return updated

/datum/rto_support_controller/proc/empty_all_template_pools(admin_ckey = null)
	var/updated = FALSE
	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(!template_uses_support_pool(template))
			continue
		var/datum/rto_support_resource_pool_state/pool = get_support_pool(template, TRUE)
		if(!pool)
			continue
		pool.set_current_charges(0, world.time)
		pool.last_modified_by_admin_ckey = admin_ckey
		updated = TRUE
	if(updated)
		refresh_action_handles()
	return updated

/datum/rto_support_controller/proc/set_all_template_pools_auto_recharge(enabled, admin_ckey = null)
	var/updated = FALSE
	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(!template_uses_support_pool(template))
			continue
		if(set_template_pool_auto_recharge(template.template_id, enabled, admin_ckey))
			updated = TRUE
	if(updated)
		refresh_action_handles()
	return updated

/datum/rto_support_controller/proc/set_all_template_pools_manual_only(enabled, admin_ckey = null)
	var/updated = FALSE
	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(!template_uses_support_pool(template))
			continue
		if(set_template_pool_manual_only(template.template_id, enabled, admin_ckey))
			updated = TRUE
	if(updated)
		refresh_action_handles()
	return updated

/datum/rto_support_controller/proc/select_template(template_type)
	ensure_runtime()
	if(!can_add_specific_template(template_type))
		return FALSE

	var/datum/rto_support_template/template = find_template(template_type)
	if(!template)
		return FALSE

	selected_templates += template
	apply_support_pool_rules_update()
	if(!selection_started_at)
		selection_started_at = world.time
	selection_reset_available_at = selection_started_at + get_selection_reset_delay()

	sync_actions()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/remove_selected_template(template_type, admin_ckey = null)
	ensure_runtime()
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(!template)
		return FALSE

	var/template_id = template.template_id
	var/template_slot = get_selected_template_slot(template_id)
	if(!template_slot)
		return FALSE

	if(armed_template_id == template_id)
		reset_armed_action()
	if(active_zone?.source_template?.template_id == template_id)
		clear_active_zone(FALSE)

	selected_templates.Cut(template_slot, template_slot + 1)
	shared_cooldowns_by_template -= template_id
	zone_cooldowns_by_template -= template_id
	package_lockouts_by_template -= template_id
	remove_support_pool(template, TRUE)

	for(var/datum/rto_support_action_template/action_template as anything in template.get_action_templates())
		action_cooldowns -= action_template.action_id

	if(!length(selected_templates))
		selection_started_at = 0
		selection_reset_available_at = 0

	var/datum/rto_support_resource_pool_state/pool = get_admin_charge_pool(template_id)
	if(pool)
		pool.last_modified_by_admin_ckey = admin_ckey

	sync_actions()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/reset_templates()
	ensure_runtime()
	if(!can_reset_templates())
		return FALSE

	disarm_action()
	clear_active_zone(FALSE)
	clear_manual_designation()
	selected_templates = list()
	shared_cooldowns_by_template = list()
	zone_cooldowns_by_template = list()
	action_cooldowns = list()
	package_lockouts_by_template = list()
	clear_support_pools(TRUE)
	support_pools_by_id = list()
	clear_support_pool_overrides()
	support_pool_overrides_by_id = list()
	zone_shared_cooldown_until = 0
	selection_started_at = 0
	selection_reset_available_at = 0

	sync_actions()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/prune_selected_templates_to_limit()
	var/max_templates = get_max_selected_templates()
	if(length(selected_templates) <= max_templates)
		return FALSE

	var/list/removed_templates = list()
	while(length(selected_templates) > max_templates)
		var/datum/rto_support_template/removed_template = selected_templates[length(selected_templates)]
		removed_templates += removed_template
		selected_templates.Cut(length(selected_templates), length(selected_templates) + 1)

	if(!length(removed_templates))
		return FALSE

	for(var/datum/rto_support_template/removed_template as anything in removed_templates)
		var/template_id = removed_template?.template_id
		if(!template_id)
			continue

		if(armed_template_id == template_id)
			reset_armed_action()
		if(active_zone?.source_template?.template_id == template_id)
			clear_active_zone(FALSE)

		shared_cooldowns_by_template -= template_id
		zone_cooldowns_by_template -= template_id
		package_lockouts_by_template -= template_id
		remove_support_pool(removed_template, TRUE)

		for(var/datum/rto_support_action_template/action_template as anything in removed_template.get_action_templates())
			action_cooldowns -= action_template.action_id

	if(owner)
		to_chat(owner, SPAN_WARNING("Лишние пакеты поддержки сняты: лимит слотов был уменьшен правилами раунда."))

	return TRUE

/datum/rto_support_controller/proc/get_active_template() as /datum/rto_support_template
	return get_primary_selected_template()

/datum/rto_support_controller/proc/get_template_for_action(action_id, template_type = null) as /datum/rto_support_template
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(template?.get_action_template(action_id))
		return template
	for(var/datum/rto_support_template/selected_template as anything in selected_templates)
		if(selected_template?.get_action_template(action_id))
			return selected_template
	return null

/datum/rto_support_controller/proc/get_action_templates(template_type = null)
	var/list/action_templates = list()
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(template)
		return template.get_action_templates()
	for(var/datum/rto_support_template/selected_template as anything in selected_templates)
		action_templates += selected_template.get_action_templates()
	return action_templates

/datum/rto_support_controller/proc/template_requires_zone(template_type = null)
	var/datum/rto_support_template/template = template_type ? get_selected_template(template_type) : get_primary_selected_template()
	return !!template?.requires_visibility_zone

/datum/rto_support_controller/proc/get_active_zone() as /datum/rto_visibility_zone
	if(active_zone && !active_zone.is_active())
		clear_active_zone()
	return active_zone

/datum/rto_support_controller/proc/get_zone_owner_template() as /datum/rto_support_template
	return get_active_zone()?.source_template

/datum/rto_support_controller/proc/get_zone_state(template_type = null)
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(!template)
		template = get_primary_selected_template()
	if(!template || !template_requires_zone(template))
		return RTO_SUPPORT_ZONE_STATE_UNSUPPORTED
	if(get_active_zone())
		return RTO_SUPPORT_ZONE_STATE_ACTIVE
	if(get_zone_ready_in(template) > 0)
		return RTO_SUPPORT_ZONE_STATE_COOLDOWN
	return RTO_SUPPORT_ZONE_STATE_READY

/datum/rto_support_controller/proc/get_zone_ready_in(template_type = null)
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(!template)
		template = get_primary_selected_template()
	if(!template || !template_requires_zone(template) || get_active_zone())
		return 0
	return get_remaining_zone_cooldown(template)

/datum/rto_support_controller/proc/get_zone_expires_in(template_type = null)
	var/datum/rto_visibility_zone/zone = get_active_zone()
	if(!zone)
		return 0
	if(template_type)
		var/datum/rto_support_template/template = get_selected_template(template_type)
		if(template && zone.source_template?.template_id != template.template_id)
			return 0
	return max(0, zone.expires_at - world.time)

/datum/rto_support_controller/proc/get_remaining_zone_shared_cooldown()
	return 0

/datum/rto_support_controller/proc/get_remaining_zone_cooldown(template_type = null)
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(!template)
		template = get_primary_selected_template()
	if(!template)
		return 0
	var/cooldown_until = zone_cooldowns_by_template[template.template_id]
	return max(0, cooldown_until - world.time)

/datum/rto_support_controller/proc/get_solo_visibility_zone_cooldown(template_type = null)
	return get_effective_visibility_zone_cooldown(template_type)

/datum/rto_support_controller/proc/uses_single_template_zone_discount(template_type = null)
	return FALSE

/datum/rto_support_controller/proc/get_effective_visibility_zone_cooldown(template_type = null)
	var/datum/rto_support_template/template = null
	if(istype(template_type, /datum/rto_support_template))
		template = template_type
	else if(istext(template_type))
		template = get_selected_template(template_type) || find_template(template_type)
	else
		template = get_primary_selected_template()
	if(!template?.requires_visibility_zone || template.visibility_zone_cooldown <= 0)
		return max(0, template?.visibility_zone_cooldown)
	return template.visibility_zone_cooldown

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

/datum/rto_support_controller/proc/can_deploy_zone(template_type = null)
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(!template || !template_requires_zone(template))
		return FALSE
	if(get_active_zone())
		return FALSE
	return get_remaining_zone_cooldown(template) <= 0

/datum/rto_support_controller/proc/deploy_zone(turf/target_turf, template_type = null)
	ensure_runtime()
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(!template || !template_requires_zone(template) || !target_turf)
		return FALSE

	replace_active_zone(new /datum/rto_visibility_zone(owner, target_turf, template))

	if(template.visibility_support_path)
		var/datum/rto_support_request/request = new
		request.owner = owner
		request.target_turf = target_turf
		request.template = template
		request.visibility_zone = active_zone
		request.dispatch_key = RTO_SUPPORT_REQUEST_VISIBILITY
		request.dispatch_path = template.visibility_support_path
		request.display_name = template.visibility_zone_name
		request.request_kind = RTO_SUPPORT_REQUEST_VISIBILITY
		request.target_marker_style = template.visibility_target_marker_style
		request.announce_to_ghosts = FALSE
		dispatch_service.dispatch_request(request)

	if(owner)
		to_chat(owner, SPAN_NOTICE("[template.visibility_zone_name]: сектор развернут."))
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/can_arm_action(action_id, template_type = null)
	if(!action_id)
		return FALSE
	if(action_id == RTO_SUPPORT_ARM_COORDINATES || action_id == RTO_SUPPORT_ARM_MARKER)
		return TRUE
	if(!is_support_enabled_by_rules())
		return FALSE

	if(action_id == RTO_SUPPORT_ARM_VISIBILITY_ZONE)
		return can_deploy_zone(template_type)

	var/datum/rto_support_template/template = get_template_for_action(action_id, template_type)
	if(!template)
		return FALSE

	var/datum/rto_support_action_template/action_template = template.get_action_template(action_id)
	if(!action_template)
		return FALSE
	if(template_uses_support_pool(template))
		if(!can_pay_support_pool_cost(action_template, template))
			return FALSE
	else if(get_remaining_shared_cooldown(template) > 0)
		return FALSE
	if(template_uses_support_pool(template))
		if(get_remaining_support_package_lockout(template) > 0)
			return FALSE
	else if(get_remaining_action_cooldown(action_id) > 0)
		return FALSE
	if(action_template.requires_visibility_zone && template_requires_zone(template))
		var/datum/rto_visibility_zone/zone = get_active_zone()
		if(!zone || zone.source_template?.template_id != template.template_id)
			return FALSE
	return TRUE

/datum/rto_support_controller/proc/arm_action(action_id, template_type = null)
	ensure_runtime()
	if(!owner || QDELETED(owner))
		return FALSE
	if(!has_rto_binocular_in_hand())
		to_chat(owner, SPAN_WARNING("Нужен RTO-бинокль в руке."))
		return FALSE
	if(!can_arm_action(action_id, template_type))
		var/message = get_action_block_message(action_id, template_type)
		if(message)
			to_chat(owner, SPAN_WARNING(message))
		return FALSE
	if(armed_action_id == action_id && armed_template_id == template_type)
		return disarm_action()
	reset_armed_action()
	armed_action_id = action_id
	armed_template_id = template_type
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
	armed_template_id = null
	return TRUE

/datum/rto_support_controller/proc/handle_binocular_target(turf/target_turf, mob/living/carbon/human/user)
	ensure_runtime()
	if(!armed_action_id || !target_turf || user != owner)
		return FALSE

	var/obj/item/device/binoculars/rto/binoculars = get_active_binocular()
	if(!binoculars)
		to_chat(user, SPAN_WARNING("Нужно смотреть через RTO-бинокль."))
		return FALSE

	var/datum/rto_support_template/template = get_selected_template(armed_template_id)

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
		var/datum/rto_support_validation_result/zone_result = validation_service.validate_zone_deploy(src, template, target_turf, user, binoculars)
		if(!zone_result.success)
			if(zone_result.message)
				var/zone_name = template?.visibility_zone_name
				if(!zone_name || !length(zone_name))
					zone_name = "Сектор наведения"
				to_chat(user, SPAN_WARNING("[zone_name]: [zone_result.message]"))
			return FALSE
		var/zone_success = deploy_zone(target_turf, template?.template_id)
		if(zone_success)
			disarm_action()
		return zone_success

	if(!template)
		return FALSE

	var/datum/rto_support_action_template/action_template = template.get_action_template(armed_action_id)
	if(!action_template)
		return FALSE

	var/datum/rto_support_validation_result/support_result = validation_service.validate_support_call(src, template, action_template, target_turf, user, binoculars)
	if(!support_result.success)
		if(support_result.message)
			to_chat(user, SPAN_WARNING("[action_template.name]: [support_result.message]"))
		return FALSE

	var/datum/rto_support_request/request = new
	request.owner = owner
	request.target_turf = target_turf
	request.template = template
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

	if(!apply_action_resource_consumption(template, action_template))
		return FALSE
	to_chat(user, SPAN_NOTICE("[action_template.name]: вызов подтвержден."))
	disarm_action()
	refresh_action_handles()
	return TRUE

/datum/rto_support_controller/proc/build_preset_ui_data()
	var/list/data = list()
	for(var/datum/rto_support_template/template as anything in get_available_templates())
		var/datum/rto_support_ui_preset_entry/entry = template.build_ui_entry(src)
		var/list/entry_data = entry.to_list()
		entry_data["is_selected"] = has_selected_template(template.template_id)
		entry_data["selected_slot"] = get_selected_template_slot(template.template_id)
		data += list(entry_data)
	return data

/datum/rto_support_controller/proc/find_template(template_type)
	var/datum/rto_support_template/template = GLOB.rto_support_registry?.find_template(template_type)
	if(!template?.is_available_to(src))
		return null
	return template

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
	if(length(selected_templates))
		selection_reset_available_at = selection_started_at + get_selection_reset_delay()
	if(prune_selected_templates_to_limit())
		sync_actions()
	apply_support_pool_rules_update()
	if(is_action_restricted_by_rules(armed_action_id))
		reset_armed_action()
	else if(armed_action_id && armed_action_id != RTO_SUPPORT_ARM_COORDINATES && armed_action_id != RTO_SUPPORT_ARM_MARKER && !can_arm_action(armed_action_id, armed_template_id))
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
		if(!zone_cooldowns_by_template)
			zone_cooldowns_by_template = list()
		var/cooldown_until = world.time + get_effective_visibility_zone_cooldown(source_template)
		zone_cooldowns_by_template[source_template.template_id] = max(zone_cooldowns_by_template[source_template.template_id], cooldown_until)
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
			return get_selected_template(armed_template_id)?.visibility_zone_name || "Сектор наведения"
		if(RTO_SUPPORT_ARM_COORDINATES)
			return "Координаты"
		if(RTO_SUPPORT_ARM_MARKER)
			return "Лазерная отметка"
	var/datum/rto_support_template/template = get_template_for_action(armed_action_id, armed_template_id)
	var/datum/rto_support_action_template/action_template = template?.get_action_template(armed_action_id)
	return action_template?.name

/datum/rto_support_controller/proc/clear_actions()
	remove_select_action()
	remove_visibility_actions()
	remove_coordinates_action()
	remove_manual_marker_action()
	remove_support_actions()
	action_handles = list()

/datum/rto_support_controller/proc/sync_actions()
	if(!owner || QDELETED(owner) || GET_DEFAULT_ROLE(owner.job) != JOB_SQUAD_RTO)
		clear_actions()
		return

	ensure_select_action()
	ensure_coordinates_action()
	ensure_manual_marker_action()
	ensure_visibility_actions()
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

/datum/rto_support_controller/proc/ensure_visibility_actions()
	var/list/valid_template_ids = list()
	for(var/datum/rto_support_template/template as anything in selected_templates)
		if(!template?.requires_visibility_zone)
			continue
		valid_template_ids += template.template_id
		var/datum/action/human_action/rto/visibility_zone/action = visibility_actions[template.template_id]
		if(action && !QDELETED(action))
			continue
		action = new /datum/action/human_action/rto/visibility_zone(src, template.template_id)
		action.give_to(owner)
		visibility_actions[template.template_id] = action

	for(var/template_id in visibility_actions.Copy())
		if(template_id in valid_template_ids)
			continue
		remove_visibility_action(template_id)

/datum/rto_support_controller/proc/remove_visibility_actions()
	if(!visibility_actions)
		return
	for(var/template_id in visibility_actions.Copy())
		remove_visibility_action(template_id)

/datum/rto_support_controller/proc/remove_visibility_action(template_id)
	var/datum/action/human_action/rto/visibility_zone/action = visibility_actions[template_id]
	visibility_actions -= template_id
	if(!action)
		return
	if(action.owner)
		action.remove_from(action.owner)
	qdel(action)

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
	var/list/valid_template_ids = list()
	for(var/datum/rto_support_template/template as anything in selected_templates)
		valid_template_ids += template.template_id
		var/list/template_actions = support_actions[template.template_id]
		if(!islist(template_actions))
			template_actions = list()
			support_actions[template.template_id] = template_actions

		var/list/valid_action_ids = list()
		for(var/datum/rto_support_action_template/action_template as anything in template.get_action_templates())
			valid_action_ids += action_template.action_id
			var/datum/action/human_action/rto/support/action = template_actions[action_template.action_id]
			if(action && !QDELETED(action))
				continue
			action = new /datum/action/human_action/rto/support(src, template.template_id, action_template)
			action.give_to(owner)
			template_actions[action_template.action_id] = action

		for(var/action_id in template_actions.Copy())
			if(action_id in valid_action_ids)
				continue
			remove_support_action(template.template_id, action_id)

	for(var/template_id in support_actions.Copy())
		if(template_id in valid_template_ids)
			continue
		remove_support_actions(template_id)

/datum/rto_support_controller/proc/remove_support_actions(template_id = null)
	if(!support_actions)
		return
	if(template_id)
		var/list/template_actions = support_actions[template_id]
		if(!islist(template_actions))
			support_actions -= template_id
			return
		for(var/action_id in template_actions.Copy())
			remove_support_action(template_id, action_id)
		support_actions -= template_id
		return
	for(var/selected_template_id in support_actions.Copy())
		remove_support_actions(selected_template_id)

/datum/rto_support_controller/proc/remove_support_action(template_id, action_id)
	var/list/template_actions = support_actions[template_id]
	if(!islist(template_actions))
		return
	var/datum/action/human_action/rto/support/action = template_actions[action_id]
	template_actions -= action_id
	if(!length(template_actions))
		support_actions -= template_id
	if(!action)
		return
	if(action.owner)
		action.remove_from(action.owner)
	qdel(action)

/datum/rto_support_controller/proc/rebuild_action_handles()
	action_handles = list()
	if(select_action && !QDELETED(select_action))
		action_handles += select_action
	for(var/datum/rto_support_template/template as anything in selected_templates)
		var/datum/action/human_action/rto/visibility_zone/visibility_action = visibility_actions[template.template_id]
		if(visibility_action && !QDELETED(visibility_action))
			action_handles += visibility_action
	if(coordinates_action && !QDELETED(coordinates_action))
		action_handles += coordinates_action
	if(manual_marker_action && !QDELETED(manual_marker_action))
		action_handles += manual_marker_action
	for(var/datum/rto_support_template/template as anything in selected_templates)
		var/list/template_actions = support_actions[template.template_id]
		if(!islist(template_actions))
			continue
		for(var/datum/rto_support_action_template/action_template as anything in template.get_action_templates())
			var/datum/action/human_action/rto/support/support_action = template_actions[action_template.action_id]
			if(support_action && !QDELETED(support_action))
				action_handles += support_action

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

/datum/rto_support_controller/proc/get_remaining_shared_cooldown(template_type = null)
	var/datum/rto_support_template/template = get_selected_template(template_type)
	if(template)
		var/cooldown_until = shared_cooldowns_by_template[template.template_id]
		return max(0, cooldown_until - world.time)
	var/max_remaining = 0
	for(var/template_id in shared_cooldowns_by_template)
		max_remaining = max(max_remaining, max(0, shared_cooldowns_by_template[template_id] - world.time))
	return max_remaining

/datum/rto_support_controller/proc/get_remaining_visibility_cooldown(template_type = null)
	if(template_type)
		return get_remaining_zone_cooldown(template_type)
	return get_remaining_zone_shared_cooldown()

/datum/rto_support_controller/proc/get_remaining_action_cooldown(action_id)
	var/cooldown_until = action_cooldowns[action_id]
	return max(0, cooldown_until - world.time)

/datum/rto_support_controller/proc/get_remaining_support_package_lockout(template_type = null)
	var/datum/rto_support_template/template = resolve_template_resource_target(template_type)
	if(!template)
		return 0
	var/cooldown_until = package_lockouts_by_template[template.template_id]
	return max(0, cooldown_until - world.time)

/datum/rto_support_controller/proc/format_block_messages(list/reasons)
	return length(reasons) ? jointext(reasons, "\n") : null

/datum/rto_support_controller/proc/build_visibility_action_state(template_type)
	var/datum/rto_support_template/template = get_selected_template(template_type)
	var/datum/rto_support_template/zone_owner_template = get_zone_owner_template()
	var/zone_shared_cooldown_in = get_remaining_zone_shared_cooldown()
	var/zone_personal_cooldown_in = get_remaining_zone_cooldown(template)
	var/list/state = list(
		"has_binocular_in_hand" = has_rto_binocular_in_hand(),
		"is_armed" = is_action_armed(RTO_SUPPORT_ARM_VISIBILITY_ZONE, template?.template_id),
		"zone_state" = get_zone_state(template?.template_id),
		"zone_ready_in" = get_zone_ready_in(template?.template_id),
		"zone_expires_in" = get_zone_expires_in(zone_owner_template?.template_id),
		"zone_owner_template_id" = zone_owner_template?.template_id,
		"zone_owner_template_name" = zone_owner_template?.name,
		"zone_shared_cooldown_in" = zone_shared_cooldown_in,
		"zone_personal_cooldown_in" = zone_personal_cooldown_in,
		"is_disabled" = FALSE,
		"primary_label" = RTO_SUPPORT_STATUS_READY,
		"countdown_text" = null,
		"countdown_color" = "#f2f2f2"
	)

	if(!template || !template_requires_zone(template))
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

	if(zone_owner_template)
		var/remaining_active = round(get_zone_expires_in(zone_owner_template.template_id) / 10)
		state["is_disabled"] = TRUE
		if(zone_owner_template.template_id == template.template_id)
			state["primary_label"] = "[RTO_SUPPORT_STATUS_ACTIVE]: [remaining_active]s"
		else
			state["primary_label"] = "Чужой сектор: [remaining_active]s"
		state["countdown_text"] = "[remaining_active]s"
		state["countdown_color"] = "#7ee1ff"
		return state

	if(zone_shared_cooldown_in > 0)
		var/display_shared = round(zone_shared_cooldown_in / 10)
		state["is_disabled"] = TRUE
		state["primary_label"] = "Общий КД: [display_shared]s"
		state["countdown_text"] = "[display_shared]s"
		state["countdown_color"] = "#c6c6c6"
		return state

	if(zone_personal_cooldown_in > 0)
		var/display_personal = round(zone_personal_cooldown_in / 10)
		state["is_disabled"] = TRUE
		state["primary_label"] = "Личный КД: [display_personal]s"
		state["countdown_text"] = "[display_personal]s"
		state["countdown_color"] = "#c6c6c6"
		return state

	return state

/datum/rto_support_controller/proc/get_displayed_ability_cooldown(action_id, template_type = null)
	var/personal_cooldown_in = get_remaining_action_cooldown(action_id)
	var/shared_cooldown_in = get_remaining_shared_cooldown(template_type)
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

/datum/rto_support_controller/proc/build_support_action_state(action_id, template_type)
	var/datum/rto_support_template/template = get_template_for_action(action_id, template_type)
	var/datum/rto_support_action_template/action_template = template?.get_action_template(action_id)
	var/datum/rto_support_template/zone_owner_template = get_zone_owner_template()
	var/zone_state = get_zone_state(template?.template_id)
	var/zone_ready_in = get_zone_ready_in(template?.template_id)
	var/zone_expires_in = get_zone_expires_in(zone_owner_template?.template_id)
	var/uses_support_pool = template_uses_support_pool(template)
	var/pool_current_charges = uses_support_pool ? get_support_pool_current_charges(template) : 0
	var/pool_capacity = uses_support_pool ? get_support_pool_capacity(template) : 0
	var/pool_cost = uses_support_pool ? get_effective_support_pool_cost(action_template) : 0
	var/pool_next_recharge_in = uses_support_pool ? get_support_pool_next_recharge_in(template) : 0
	var/pool_has_enough_charges = !uses_support_pool || pool_current_charges >= pool_cost
	var/package_lockout_in = uses_support_pool ? get_remaining_support_package_lockout(template) : 0
	var/shared_cooldown_in = get_remaining_shared_cooldown(template?.template_id)
	var/personal_cooldown_in = uses_support_pool ? package_lockout_in : get_remaining_action_cooldown(action_id)
	var/list/display_cooldown = get_displayed_ability_cooldown(action_id, template?.template_id)
	var/requires_zone = !!(action_template?.requires_visibility_zone && template_requires_zone(template))
	var/list/state = list(
		"has_binocular_in_hand" = has_rto_binocular_in_hand(),
		"is_armed" = is_action_armed(action_id, template?.template_id),
		"uses_support_pool" = uses_support_pool,
		"pool_current_charges" = pool_current_charges,
		"pool_capacity" = pool_capacity,
		"pool_cost" = pool_cost,
		"pool_next_recharge_in" = pool_next_recharge_in,
		"pool_has_enough_charges" = pool_has_enough_charges,
		"pool_auto_recharge_enabled" = uses_support_pool ? is_support_pool_auto_recharge_enabled(template) : FALSE,
		"pool_manual_only" = uses_support_pool ? is_support_pool_manual_only(template) : FALSE,
		"requires_zone" = requires_zone,
		"zone_state" = zone_state,
		"zone_ready_in" = zone_ready_in,
		"zone_expires_in" = zone_expires_in,
		"zone_owner_template_id" = zone_owner_template?.template_id,
		"zone_owner_template_name" = zone_owner_template?.name,
		"shared_cooldown_in" = shared_cooldown_in,
		"personal_cooldown_in" = personal_cooldown_in,
		"support_package_lockout_in" = package_lockout_in,
		"display_cooldown_kind" = display_cooldown["kind"],
		"display_cooldown_in" = display_cooldown["value"],
		"is_disabled" = FALSE,
		"primary_label" = RTO_SUPPORT_STATUS_READY,
		"countdown_text" = null,
		"countdown_color" = "#f2f2f2"
	)

	if(!template || !action_template)
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
		if(zone_owner_template?.template_id != template.template_id)
			state["is_disabled"] = TRUE
			if(zone_owner_template)
				state["primary_label"] = "Нет своего сектора"
			else
				state["primary_label"] = RTO_SUPPORT_STATUS_NO_ZONE
			state["countdown_color"] = "#c6c6c6"
			return state

	if(uses_support_pool)
		if(package_lockout_in > 0)
			var/display_lockout = round(package_lockout_in / 10)
			state["is_disabled"] = TRUE
			state["primary_label"] = "Пауза пакета: [display_lockout]с"
			state["countdown_text"] = "[display_lockout]s"
			state["countdown_color"] = "#c6c6c6"
			return state
		if(!pool_has_enough_charges)
			state["is_disabled"] = TRUE
			state["primary_label"] = "Нужно: [pool_cost] (есть [pool_current_charges])"
			if(pool_next_recharge_in > 0)
				state["countdown_text"] = "[round(pool_next_recharge_in / 10)]s"
			state["countdown_color"] = "#c6c6c6"
			return state
		state["primary_label"] = "Заряды: [pool_current_charges]/[pool_capacity]"
		if(pool_next_recharge_in > 0 && pool_current_charges < pool_capacity)
			state["countdown_text"] = "[round(pool_next_recharge_in / 10)]s"
			state["countdown_color"] = "#7ee1ff"
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

/datum/rto_support_controller/proc/get_action_block_messages(action_id, template_type = null)
	var/list/messages = list()
	if(action_id == RTO_SUPPORT_ARM_COORDINATES || action_id == RTO_SUPPORT_ARM_MARKER)
		return messages
	if(is_action_restricted_by_rules(action_id))
		messages += "Disabled by Game Rule Panel"
		return messages

	if(action_id == RTO_SUPPORT_ARM_VISIBILITY_ZONE)
		var/datum/rto_support_template/zone_template = get_selected_template(template_type)
		if(!zone_template)
			messages += "Сначала выберите пакет поддержки."
			return messages
		if(!template_requires_zone(zone_template))
			messages += "Этот пакет не использует сектор наведения."
			return messages
		var/zone_name = zone_template.visibility_zone_name || "Сектор наведения"
		var/datum/rto_support_template/zone_owner_template = get_zone_owner_template()
		if(zone_owner_template)
			if(zone_owner_template.template_id == zone_template.template_id)
				messages += "[zone_name] уже активен."
			else
				messages += "Активен сектор пакета [zone_owner_template.name]: [round(get_zone_expires_in(zone_owner_template.template_id) / 10)] с."
			return messages
		var/shared_zone_cooldown = get_remaining_zone_shared_cooldown()
		if(shared_zone_cooldown > 0)
			messages += "Общий кулдаун секторов: [round(shared_zone_cooldown / 10)] с."
		var/personal_zone_cooldown = get_remaining_zone_cooldown(zone_template)
		if(personal_zone_cooldown > 0)
			messages += "Личный кулдаун [zone_name]: [round(personal_zone_cooldown / 10)] с."
		return messages

	var/datum/rto_support_template/template = get_template_for_action(action_id, template_type)
	if(!template)
		messages += "Сначала выберите пакет поддержки."
		return messages

	var/datum/rto_support_action_template/action_template = template.get_action_template(action_id)
	if(!action_template)
		messages += "Неизвестная способность поддержки."
		return messages

	if(action_template.requires_visibility_zone && template_requires_zone(template))
		var/datum/rto_support_template/zone_owner_template = get_zone_owner_template()
		if(!zone_owner_template)
			var/zone_shared_cooldown = get_remaining_zone_shared_cooldown()
			var/zone_personal_cooldown = get_remaining_zone_cooldown(template)
			if(zone_shared_cooldown > 0)
				messages += "Общий кулдаун секторов: [round(zone_shared_cooldown / 10)] с."
			if(zone_personal_cooldown > 0)
				messages += "Личный кулдаун сектора: [round(zone_personal_cooldown / 10)] с."
			if(zone_shared_cooldown <= 0 && zone_personal_cooldown <= 0)
				messages += "Сначала разверните сектор наведения."
		else if(zone_owner_template.template_id != template.template_id)
			messages += "Активен сектор другого пакета: [zone_owner_template.name]."

	var/personal_cooldown = template_uses_support_pool(template) ? get_remaining_support_package_lockout(template) : get_remaining_action_cooldown(action_id)
	if(template_uses_support_pool(template))
		if(personal_cooldown > 0)
			messages += "Пакет [template.name] еще не готов: [round(personal_cooldown / 10)] с."
		var/current_charges = get_support_pool_current_charges(template)
		var/required_charges = get_effective_support_pool_cost(action_template)
		if(current_charges < required_charges)
			if(is_support_pool_manual_only(template) || !is_support_pool_auto_recharge_enabled(template))
				messages += "Пополнение пакета отключено. Заряды выдаются вручную."
			messages += "Недостаточно зарядов пакета [template.name]: нужно [required_charges], доступно [current_charges]."
		return messages
	if(personal_cooldown > 0)
		messages += "Личный кулдаун [action_template.name]: [round(personal_cooldown / 10)] с."
	var/shared_cooldown = get_remaining_shared_cooldown(template)
	if(shared_cooldown > 0)
		messages += "Общий кулдаун пакета [template.name]: [round(shared_cooldown / 10)] с."
	return messages

/datum/rto_support_controller/proc/get_action_block_message(action_id, template_type = null)
	return format_block_messages(get_action_block_messages(action_id, template_type))

/datum/rto_support_controller/proc/is_action_armed(action_id, template_type = null)
	if(action_id != armed_action_id)
		return FALSE
	if(action_id == RTO_SUPPORT_ARM_COORDINATES || action_id == RTO_SUPPORT_ARM_MARKER)
		return TRUE
	if(!template_type)
		return !armed_template_id
	return armed_template_id == template_type

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
	if(get_active_zone())
		return TRUE
	if(get_remaining_zone_shared_cooldown() > 0)
		return TRUE
	for(var/template_id in shared_cooldowns_by_template)
		if(get_remaining_shared_cooldown(template_id) > 0)
			return TRUE
	for(var/template_id in zone_cooldowns_by_template)
		if(get_remaining_zone_cooldown(template_id) > 0)
			return TRUE
	for(var/action_id in action_cooldowns)
		if(get_remaining_action_cooldown(action_id) > 0)
			return TRUE
	for(var/template_id in package_lockouts_by_template)
		if(get_remaining_support_package_lockout(template_id) > 0)
			return TRUE
	for(var/pool_id in support_pools_by_id)
		var/datum/rto_support_resource_pool_state/pool = support_pools_by_id[pool_id]
		if(pool?.get_next_recharge_in(world.time) > 0)
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
