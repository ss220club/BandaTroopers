/*************************************************
 * Human legacy bridge item-search scheduling
 *************************************************/
#define NPC_AI_V2_LEGACY_ITEM_SEARCH_REQUEST_KEY "legacy_item_search_requested"
#define NPC_AI_V2_LEGACY_ITEM_SEARCH_LAST_RUN_KEY "legacy_item_search_last_run_at"
#define NPC_AI_V2_LEGACY_ITEM_SEARCH_EVENT_INTERVAL (8)
#define NPC_AI_V2_LEGACY_ITEM_SEARCH_RECONCILE_INTERVAL (30)
#define NPC_AI_V2_LEGACY_FIRE_LINE_VALID_KEY "legacy_fire_line_valid"
#define NPC_AI_V2_LEGACY_FIRE_LINE_TARGET_KEY "legacy_fire_line_target"
#define NPC_AI_V2_LEGACY_FIRE_LINE_LAST_RUN_KEY "legacy_fire_line_last_run_at"
#define NPC_AI_V2_LEGACY_FIRE_LINE_RECALC_REQUEST_KEY "legacy_fire_line_recalc_requested"
#define NPC_AI_V2_LEGACY_FIRE_LINE_INTERVAL (3)
#define NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY "legacy_cover_scan_requested"
#define NPC_AI_V2_LEGACY_HAS_TARGET_KEY "legacy_has_target"
#define NPC_AI_V2_LEGACY_IN_COMBAT_KEY "legacy_in_combat"
#define NPC_AI_V2_LEGACY_CURRENT_TARGET_KEY "legacy_current_target"
#define NPC_AI_V2_LEGACY_TARGET_TURF_KEY "legacy_target_turf"
#define NPC_AI_V2_LEGACY_SQUAD_ID_KEY "legacy_squad_id"
#define NPC_AI_V2_LEGACY_SQUAD_LEADER_KEY "legacy_is_squad_leader"
#define NPC_AI_V2_LEGACY_ORDER_KEY "legacy_order"
#define NPC_AI_V2_LEGACY_ORDER_TYPE_KEY "legacy_order_type"
#define NPC_AI_V2_LEGACY_ORDER_WAITING_KEY "legacy_order_waiting"
#define NPC_AI_V2_LEGACY_SQUAD_ORDER_CHANGED_AT_KEY "legacy_squad_order_changed_at"

/datum/npc_ai_sensor/human_legacy_brain
	name = "human_legacy_brain_sensor"
	defer_on_low_tiers = TRUE
	defer_min_tier = 2
	defer_interval_ds = 16

/// RU: Синхронизирует legacy brain в blackboard, запускает reconcile-подпроцессы и выставляет readiness tag для planner. EN: Synchronizes legacy brain into blackboard, runs reconcile substeps, and sets readiness tag for planner.
/datum/npc_ai_sensor/human_legacy_brain/sense(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!enabled || !istype(controller, /datum/npc_ai_controller/human) || !istype(agent, /mob/living/carbon/human) || !blackboard)
		return list()

	var/datum/human_ai_brain/current_brain = blackboard.get_value("legacy_brain")
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		var/mob/living/carbon/human/human_agent = agent
		current_brain = human_agent.get_ai_brain()
		if(blackboard.get_value("legacy_brain") != current_brain)
			blackboard.set_value("legacy_brain", current_brain)

	var/brain_ready_for_actions = FALSE
	if(current_brain && !QDELETED(current_brain) && current_brain.tied_human == agent)
		brain_ready_for_actions = current_brain.v2_prepare_tick()
		if(brain_ready_for_actions)
			if(sync_squad_and_order_state(current_brain, blackboard))
				blackboard.set_value(NPC_AI_V2_LEGACY_ITEM_SEARCH_REQUEST_KEY, TRUE)
				blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_RECALC_REQUEST_KEY, TRUE)
				blackboard.set_value(NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY, TRUE)
			maybe_run_item_search(current_brain, blackboard)
			update_fire_line_cache(current_brain, blackboard)
			maybe_request_cover_scan(current_brain, blackboard)

	blackboard.set_value("legacy_brain_ready_for_actions", brain_ready_for_actions)
	if(brain_ready_for_actions)
		return list("human_legacy_brain_ready")

	return list()

/datum/npc_ai_sensor/human_legacy_targeting
	name = "human_legacy_targeting_sensor"

/// RU: Обновляет target/combat поля legacy brain в blackboard (has_target, in_combat, current_target, target_turf). EN: Updates legacy brain target/combat blackboard fields (has_target, in_combat, current_target, target_turf).
/datum/npc_ai_sensor/human_legacy_targeting/sense(datum/npc_ai_controller/controller, mob/living/agent, datum/npc_ai_blackboard/blackboard)
	if(!enabled || !istype(controller, /datum/npc_ai_controller/human) || !istype(agent, /mob/living/carbon/human) || !blackboard)
		return list()
	if(!blackboard.get_value("legacy_brain_ready_for_actions", FALSE))
		return list()

	var/datum/human_ai_brain/current_brain = blackboard.get_value("legacy_brain")
	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		var/mob/living/carbon/human/human_agent = agent
		current_brain = human_agent.get_ai_brain()
		if(blackboard.get_value("legacy_brain") != current_brain)
			blackboard.set_value("legacy_brain", current_brain)

	if(!current_brain || QDELETED(current_brain) || current_brain.tied_human != agent)
		blackboard.set_value(NPC_AI_V2_LEGACY_HAS_TARGET_KEY, FALSE)
		blackboard.set_value(NPC_AI_V2_LEGACY_IN_COMBAT_KEY, FALSE)
		blackboard.set_value(NPC_AI_V2_LEGACY_CURRENT_TARGET_KEY, null)
		blackboard.set_value(NPC_AI_V2_LEGACY_TARGET_TURF_KEY, null)
		return list()

	var/has_target = current_brain.v2_update_target_and_combat()
	blackboard.set_value(NPC_AI_V2_LEGACY_HAS_TARGET_KEY, has_target)
	blackboard.set_value(NPC_AI_V2_LEGACY_IN_COMBAT_KEY, !!current_brain.in_combat)
	blackboard.set_value(NPC_AI_V2_LEGACY_CURRENT_TARGET_KEY, current_brain.current_target)
	blackboard.set_value(NPC_AI_V2_LEGACY_TARGET_TURF_KEY, current_brain.target_turf)
	return list()

/// RU: Выполняет служебный этап в сенсорах AI v2 (этап: maybe run item search) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 sensors (step: maybe run item search) to coordinate state between AI v2 subsystems.
/datum/npc_ai_sensor/human_legacy_brain/proc/maybe_run_item_search(datum/human_ai_brain/current_brain, datum/npc_ai_blackboard/blackboard)
	if(!current_brain || !blackboard)
		return

	var/last_run_at = blackboard.get_value(NPC_AI_V2_LEGACY_ITEM_SEARCH_LAST_RUN_KEY, 0)
	var/search_requested = blackboard.get_value(NPC_AI_V2_LEGACY_ITEM_SEARCH_REQUEST_KEY, FALSE)
	var/time_since_last_run = world.time - last_run_at
	var/should_run = FALSE
	if(search_requested && time_since_last_run >= NPC_AI_V2_LEGACY_ITEM_SEARCH_EVENT_INTERVAL)
		should_run = TRUE
	else if(time_since_last_run >= NPC_AI_V2_LEGACY_ITEM_SEARCH_RECONCILE_INTERVAL)
		should_run = TRUE

	if(!should_run)
		return

	current_brain.v2_run_item_search(2)
	blackboard.set_value(NPC_AI_V2_LEGACY_ITEM_SEARCH_LAST_RUN_KEY, world.time)
	blackboard.set_value(NPC_AI_V2_LEGACY_ITEM_SEARCH_REQUEST_KEY, FALSE)

/// RU: Обновляет runtime состояние в сенсорах AI v2 (этап: update fire line cache) и синхронизирует данные для последующих тиков. EN: Updates runtime state in AI v2 sensors (step: update fire line cache) and synchronizes data for subsequent ticks.
/datum/npc_ai_sensor/human_legacy_brain/proc/update_fire_line_cache(datum/human_ai_brain/current_brain, datum/npc_ai_blackboard/blackboard)
	if(!current_brain || !blackboard)
		return

	var/turf/target_turf = current_brain.target_turf
	if(!target_turf || !current_brain.primary_weapon || current_brain.should_reload())
		blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_TARGET_KEY, target_turf)
		blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_VALID_KEY, FALSE)
		blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_LAST_RUN_KEY, world.time)
		blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_RECALC_REQUEST_KEY, FALSE)
		return

	var/previous_target = blackboard.get_value(NPC_AI_V2_LEGACY_FIRE_LINE_TARGET_KEY)
	var/target_changed = previous_target != target_turf
	var/recalc_requested = blackboard.get_value(NPC_AI_V2_LEGACY_FIRE_LINE_RECALC_REQUEST_KEY, FALSE)
	var/last_run_at = blackboard.get_value(NPC_AI_V2_LEGACY_FIRE_LINE_LAST_RUN_KEY, 0)
	if(!target_changed && !recalc_requested && (world.time - last_run_at) < NPC_AI_V2_LEGACY_FIRE_LINE_INTERVAL)
		return

	var/line_valid = current_brain.firing_line_check(current_brain, target_turf)
	blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_TARGET_KEY, target_turf)
	blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_VALID_KEY, line_valid)
	blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_LAST_RUN_KEY, world.time)
	blackboard.set_value(NPC_AI_V2_LEGACY_FIRE_LINE_RECALC_REQUEST_KEY, FALSE)

/// RU: Выполняет служебный этап в сенсорах AI v2 (этап: maybe request cover scan) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 sensors (step: maybe request cover scan) to coordinate state between AI v2 subsystems.
/datum/npc_ai_sensor/human_legacy_brain/proc/maybe_request_cover_scan(datum/human_ai_brain/current_brain, datum/npc_ai_blackboard/blackboard)
	if(!current_brain || !blackboard)
		return
	if(!current_brain.in_combat || current_brain.current_cover)
		return
	if(!current_brain.current_target || !isxeno(current_brain.current_target))
		return
	blackboard.set_value(NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY, TRUE)

/// RU: Выполняет служебный этап в сенсорах AI v2 (этап: sync squad and order state) для согласования состояния между подсистемами AI v2. EN: Executes an internal stage in AI v2 sensors (step: sync squad and order state) to coordinate state between AI v2 subsystems.
/datum/npc_ai_sensor/human_legacy_brain/proc/sync_squad_and_order_state(datum/human_ai_brain/current_brain, datum/npc_ai_blackboard/blackboard)
	if(!current_brain || !blackboard)
		return FALSE

	var/previous_squad_id = blackboard.get_value(NPC_AI_V2_LEGACY_SQUAD_ID_KEY)
	var/previous_squad_leader_state = blackboard.get_value(NPC_AI_V2_LEGACY_SQUAD_LEADER_KEY, FALSE)
	var/datum/ai_order/previous_order = blackboard.get_value(NPC_AI_V2_LEGACY_ORDER_KEY)
	var/previous_order_waiting = blackboard.get_value(NPC_AI_V2_LEGACY_ORDER_WAITING_KEY, FALSE)

	var/current_squad_id = current_brain.squad_id
	var/current_squad_leader_state = !!current_brain.is_squad_leader
	var/datum/ai_order/current_order = current_brain.current_order
	var/current_order_waiting = FALSE
	if(istype(current_order, /datum/ai_order/patrol))
		var/datum/ai_order/patrol/patrol_order = current_order
		current_order_waiting = patrol_order.waiting

	var/state_changed = FALSE
	if(previous_squad_id != current_squad_id)
		state_changed = TRUE
	else if(previous_squad_leader_state != current_squad_leader_state)
		state_changed = TRUE
	else if(previous_order != current_order)
		state_changed = TRUE
	else if(previous_order_waiting != current_order_waiting)
		state_changed = TRUE

	blackboard.set_value(NPC_AI_V2_LEGACY_SQUAD_ID_KEY, current_squad_id)
	blackboard.set_value(NPC_AI_V2_LEGACY_SQUAD_LEADER_KEY, current_squad_leader_state)
	blackboard.set_value(NPC_AI_V2_LEGACY_ORDER_KEY, current_order)
	blackboard.set_value(NPC_AI_V2_LEGACY_ORDER_TYPE_KEY, current_order?.type)
	blackboard.set_value(NPC_AI_V2_LEGACY_ORDER_WAITING_KEY, current_order_waiting)
	if(state_changed)
		blackboard.set_value(NPC_AI_V2_LEGACY_SQUAD_ORDER_CHANGED_AT_KEY, world.time)
	return state_changed

#undef NPC_AI_V2_LEGACY_ITEM_SEARCH_REQUEST_KEY
#undef NPC_AI_V2_LEGACY_ITEM_SEARCH_LAST_RUN_KEY
#undef NPC_AI_V2_LEGACY_ITEM_SEARCH_EVENT_INTERVAL
#undef NPC_AI_V2_LEGACY_ITEM_SEARCH_RECONCILE_INTERVAL
#undef NPC_AI_V2_LEGACY_FIRE_LINE_VALID_KEY
#undef NPC_AI_V2_LEGACY_FIRE_LINE_TARGET_KEY
#undef NPC_AI_V2_LEGACY_FIRE_LINE_LAST_RUN_KEY
#undef NPC_AI_V2_LEGACY_FIRE_LINE_RECALC_REQUEST_KEY
#undef NPC_AI_V2_LEGACY_FIRE_LINE_INTERVAL
#undef NPC_AI_V2_LEGACY_COVER_SCAN_REQUEST_KEY
#undef NPC_AI_V2_LEGACY_HAS_TARGET_KEY
#undef NPC_AI_V2_LEGACY_IN_COMBAT_KEY
#undef NPC_AI_V2_LEGACY_CURRENT_TARGET_KEY
#undef NPC_AI_V2_LEGACY_TARGET_TURF_KEY
#undef NPC_AI_V2_LEGACY_SQUAD_ID_KEY
#undef NPC_AI_V2_LEGACY_SQUAD_LEADER_KEY
#undef NPC_AI_V2_LEGACY_ORDER_KEY
#undef NPC_AI_V2_LEGACY_ORDER_TYPE_KEY
#undef NPC_AI_V2_LEGACY_ORDER_WAITING_KEY
#undef NPC_AI_V2_LEGACY_SQUAD_ORDER_CHANGED_AT_KEY
