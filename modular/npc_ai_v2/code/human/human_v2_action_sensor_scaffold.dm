/// Human sensor/action scaffold for staged migration away from legacy ai_action datums.
/// Most mapped actions are migration-ready and run through action_datum path.

/datum/npc_ai_sensor_datum/human_v2_runtime_scaffold
	name = "human_v2_runtime_scaffold_sensor"
	legacy_sensor_id = "human_legacy_brain_sensor"
	defer_on_low_tiers = TRUE
	defer_min_tier = 2
	defer_interval_ds = 20

/// RU: Собирает сенсорные данные для planner/blackboard в human AI v2. Побочные эффекты: обновляет blackboard. EN: Collects sensor data for planner/blackboard in human AI v2. Side effects: updates blackboard.
/datum/npc_ai_sensor_datum/human_v2_runtime_scaffold/sense(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!..())
		return null
	blackboard.set_value("human_v2_scaffold_ready", TRUE)
	return list("human_v2_scaffold_sensor")

/datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_base_action"
	legacy_action_type = /datum/ai_action

/// RU: Вычисляет utility-вес шага для planner в action-datum; 0 отключает запуск. EN: Computes utility weight for planner step in an action datum; 0 disables execution.
/datum/npc_ai_action_datum/human_v2_base/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!migration_ready || !ispath(legacy_action_type, /datum/ai_action))
		return 0

	var/datum/human_ai_brain/current_brain = resolve_legacy_brain(agent, blackboard)
	if(!current_brain)
		return 0
	if(!current_brain.v2_action_can_start(legacy_action_type))
		return 0

	var/action_score = current_brain.v2_action_score(legacy_action_type)
	if(!isnum(action_score) || action_score <= 0)
		return 0
	return action_score

/// RU: Возвращает связанный legacy brain для human агента, чтобы action datum мог безопасно читать runtime-состояние перед score/start. EN: Resolves attached legacy brain for human agent so action datum can safely inspect runtime state before score/start.
/datum/npc_ai_action_datum/human_v2_base/proc/resolve_legacy_brain(mob/living/agent, datum/npc_ai_blackboard/blackboard)
	RETURN_TYPE(/datum/human_ai_brain)
	if(!istype(agent, /mob/living/carbon/human) || !blackboard)
		return null

	var/datum/human_ai_brain/current_brain = blackboard.get_value("legacy_brain")
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		return null
	return current_brain

/// RU: Запускает migration-ready действие через legacy brain action-start как управляемый v2 action datum шаг. EN: Starts migration-ready action through legacy brain action-start as a managed v2 action datum step.
/datum/npc_ai_action_datum/human_v2_base/start(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!..(controller, agent, blackboard))
		return FALSE
	if(!migration_ready || !ispath(legacy_action_type, /datum/ai_action))
		return FALSE

	var/datum/human_ai_brain/current_brain = resolve_legacy_brain(agent, blackboard)
	if(!current_brain)
		return FALSE
	if(!current_brain.v2_action_can_start(legacy_action_type))
		return FALSE

	return current_brain.v2_start_action(legacy_action_type)

/datum/npc_ai_action_datum/human_v2_inventory
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_inventory_action"
	legacy_action_type = /datum/ai_action/item_pickup
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_heal
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_heal_action"
	legacy_action_type = /datum/ai_action/treat_self
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_reload
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_reload_action"
	legacy_action_type = /datum/ai_action/reload
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_select_primary
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_select_primary_action"
	legacy_action_type = /datum/ai_action/select_primary
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_throw_grenade
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_throw_grenade_action"
	legacy_action_type = /datum/ai_action/throw_grenade
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_throw_back_nade
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_throw_back_nade_action"
	legacy_action_type = /datum/ai_action/throw_back_nade
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_resist_burning
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_resist_burning_action"
	legacy_action_type = /datum/ai_action/resist_burning
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_fire
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_fire_action"
	legacy_action_type = /datum/ai_action/fire_at_target
	migration_ready = TRUE

/// RU: Вычисляет utility для fire-at-target через v2 action datum и возвращает 0, если не пройдены weapon/range/LOS gate-условия. Побочные эффекты: обновляет blackboard. EN: Computes fire-at-target utility through v2 action datum and returns 0 when weapon/range/LOS gates fail. Side effects: updates blackboard.
/datum/npc_ai_action_datum/human_v2_fire/score(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	var/datum/human_ai_brain/current_brain = resolve_legacy_brain(agent, blackboard)
	if(!current_brain)
		return 0

	if(!current_brain.in_combat || current_brain.tried_reload || !current_brain.primary_weapon)
		return 0
	if(!current_brain.target_turf || !current_brain.gun_data)
		return 0
	if(!COOLDOWN_FINISHED(current_brain, stop_fire_cooldown))
		return 0

	var/should_fire_offscreen = (current_brain.target_turf && !COOLDOWN_FINISHED(current_brain, fire_offscreen) && (current_brain.gun_data.maximum_range > current_brain.view_distance))
	if(!current_brain.current_target && !should_fire_offscreen)
		return 0
	if((get_dist(current_brain.tied_human, current_brain.target_turf) > current_brain.view_distance) && !should_fire_offscreen)
		return 0
	if(current_brain.should_reload())
		return 0

	var/cached_target = blackboard.get_value("legacy_fire_line_target")
	if(cached_target != current_brain.target_turf)
		blackboard.set_value("legacy_fire_line_recalc_requested", TRUE)
		return 0
	if(!blackboard.get_value("legacy_fire_line_valid", FALSE))
		return 0

	return 10

/datum/npc_ai_action_datum/human_v2_keep_distance
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_keep_distance_action"
	legacy_action_type = /datum/ai_action/keep_distance
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_chase
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_chase_action"
	legacy_action_type = /datum/ai_action/chase_target
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_walk_melee
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_walk_melee_action"
	legacy_action_type = /datum/ai_action/walk_melee
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_take_cover
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_take_cover_action"
	legacy_action_type = /datum/ai_action/take_cover
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_follow_leader
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_follow_leader_action"
	legacy_action_type = /datum/ai_action/follow_leader
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_patrol
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_patrol_action"
	legacy_action_type = /datum/ai_action/patrol_waypoints
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_quick_approach
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_quick_approach_action"
	legacy_action_type = /datum/ai_action/quick_approach
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_mg_nest
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_mg_nest_action"
	legacy_action_type = /datum/ai_action/machinegunner_nest
	migration_ready = TRUE

/datum/npc_ai_action_datum/human_v2_sniper_nest
	parent_type = /datum/npc_ai_action_datum/human_v2_base
	name = "human_v2_sniper_nest_action"
	legacy_action_type = /datum/ai_action/sniper_nest
	migration_ready = TRUE

/datum/npc_ai_controller/human/proc/get_human_v2_scaffold_action_map()
	return list(
		/datum/ai_action/item_pickup = /datum/npc_ai_action_datum/human_v2_inventory,
		/datum/ai_action/treat_self = /datum/npc_ai_action_datum/human_v2_heal,
		/datum/ai_action/reload = /datum/npc_ai_action_datum/human_v2_reload,
		/datum/ai_action/select_primary = /datum/npc_ai_action_datum/human_v2_select_primary,
		/datum/ai_action/throw_grenade = /datum/npc_ai_action_datum/human_v2_throw_grenade,
		/datum/ai_action/throw_back_nade = /datum/npc_ai_action_datum/human_v2_throw_back_nade,
		/datum/ai_action/resist_burning = /datum/npc_ai_action_datum/human_v2_resist_burning,
		/datum/ai_action/fire_at_target = /datum/npc_ai_action_datum/human_v2_fire,
		/datum/ai_action/keep_distance = /datum/npc_ai_action_datum/human_v2_keep_distance,
		/datum/ai_action/chase_target = /datum/npc_ai_action_datum/human_v2_chase,
		/datum/ai_action/walk_melee = /datum/npc_ai_action_datum/human_v2_walk_melee,
		/datum/ai_action/take_cover = /datum/npc_ai_action_datum/human_v2_take_cover,
		/datum/ai_action/follow_leader = /datum/npc_ai_action_datum/human_v2_follow_leader,
		/datum/ai_action/patrol_waypoints = /datum/npc_ai_action_datum/human_v2_patrol,
		/datum/ai_action/quick_approach = /datum/npc_ai_action_datum/human_v2_quick_approach,
		/datum/ai_action/machinegunner_nest = /datum/npc_ai_action_datum/human_v2_mg_nest,
		/datum/ai_action/sniper_nest = /datum/npc_ai_action_datum/human_v2_sniper_nest,
	)

/// RU: Возвращает мигрированный action datum для legacy action_type, только если он помечен migration_ready и включен. EN: Resolves migrated action datum for a legacy action_type only when migration_ready and enabled.
/datum/npc_ai_controller/human/proc/get_migrated_action_datum_for_legacy_action(action_type)
	RETURN_TYPE(/datum/npc_ai_action_datum)
	if(!ispath(action_type, /datum/ai_action) || !islist(action_registry) || !length(action_registry))
		return null

	for(var/datum/npc_ai_action_datum/action_datum as anything in action_registry)
		if(QDELETED(action_datum))
			action_registry -= action_datum
			continue
		if(!action_datum.enabled || !action_datum.migration_ready)
			continue
		if(action_datum.legacy_action_type == action_type)
			return action_datum
	return null

/// RU: Регистрирует scaffold sensor и набор human_v2 action datums для поэтапной миграции из legacy. EN: Registers scaffold sensor and human_v2 action datums for staged migration from legacy.
/datum/npc_ai_controller/human/proc/register_human_v2_action_sensor_scaffold()
	register_sensor_datum(new /datum/npc_ai_sensor_datum/human_v2_runtime_scaffold)
	var/list/action_map = get_human_v2_scaffold_action_map()
	for(var/legacy_action_type as anything in action_map)
		var/action_datum_type = action_map[legacy_action_type]
		if(!ispath(action_datum_type, /datum/npc_ai_action_datum))
			continue
		register_action_datum(new action_datum_type)
