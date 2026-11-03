/proc/halo_is_ai_only_human(mob/living/carbon/human/human)
	return istype(human) && !human.client && (human.mob_flags & AI_CONTROLLED)

/proc/halo_is_ai_only_combat_pair(mob/living/carbon/human/source_human, mob/living/carbon/human/target_human)
	return halo_is_ai_only_human(source_human) && halo_is_ai_only_human(target_human)

/proc/halo_is_projectile_pressure_relevant_ammo(datum/ammo/ammo_datum)
	return istype(ammo_datum, /datum/ammo/energy/halo_plasma) || istype(ammo_datum, /datum/ammo/needler) || istype(ammo_datum, /datum/ammo/bullet/rifle/carbine)

/proc/halo_perf_collection_enabled()
	if(CONFIG_GET(flag/halo_perf_debug))
		return TRUE
#ifdef UNIT_TESTS
	return TRUE
#else
	return FALSE
#endif

/proc/halo_perf_debug_enabled()
	return CONFIG_GET(flag/halo_perf_debug)

/proc/halo_shield_debug_disable_fx()
	return CONFIG_GET(flag/halo_shield_debug_disable_fx)

/proc/halo_shield_debug_disable_harness()
	return CONFIG_GET(flag/halo_shield_debug_disable_harness)

GLOBAL_LIST_EMPTY_TYPED(halo_perf_active_shield_harnesses, /obj/item/clothing/suit/marine/shielded)
GLOBAL_LIST_INIT(halo_perf_window_counts, list(
	"temp_visuals" = 0,
	"cover_scans" = 0,
	"path_requests" = 0,
	"projectile_throttles" = 0,
	"shield_ssfastobj_enters" = 0,
	"shield_ssfastobj_leaves" = 0,
	"shield_hit_fx_spawns" = 0,
	"shield_pop_fx_spawns" = 0,
	"shield_timer_creates" = 0,
	"shield_effect_callbacks" = 0,
	"shield_temp_visual_qdels" = 0,
))
GLOBAL_LIST_INIT(halo_perf_total_counts, list(
	"temp_visuals" = 0,
	"cover_scans" = 0,
	"path_requests" = 0,
	"projectile_throttles" = 0,
	"shield_ssfastobj_enters" = 0,
	"shield_ssfastobj_leaves" = 0,
	"shield_hit_fx_spawns" = 0,
	"shield_pop_fx_spawns" = 0,
	"shield_timer_creates" = 0,
	"shield_effect_callbacks" = 0,
	"shield_temp_visual_qdels" = 0,
))
GLOBAL_LIST_INIT(halo_perf_gauges, list(
	"active_halo_temp_visuals" = 0,
	"active_shield_temp_visuals" = 0,
	"active_shield_filters" = 0,
))
GLOBAL_VAR_INIT(halo_perf_window_id, -1)

/proc/halo_perf_sync_window()
	if(!halo_perf_collection_enabled())
		return

	var/current_window_id = world.time - (world.time % 10)
	if(GLOB.halo_perf_window_id == current_window_id)
		return

	GLOB.halo_perf_window_id = current_window_id
	for(var/metric in GLOB.halo_perf_window_counts)
		GLOB.halo_perf_window_counts[metric] = 0

/proc/halo_perf_bump(metric, amount = 1)
	if(!metric || !halo_perf_collection_enabled())
		return

	halo_perf_sync_window()
	GLOB.halo_perf_window_counts[metric] = (GLOB.halo_perf_window_counts[metric] || 0) + amount
	GLOB.halo_perf_total_counts[metric] = (GLOB.halo_perf_total_counts[metric] || 0) + amount

/proc/halo_perf_get(metric)
	if(!metric || !halo_perf_collection_enabled())
		return 0

	halo_perf_sync_window()
	return GLOB.halo_perf_window_counts[metric] || 0

/proc/halo_perf_get_total(metric)
	if(!metric || !halo_perf_collection_enabled())
		return 0

	return GLOB.halo_perf_total_counts[metric] || 0

/proc/halo_perf_adjust_gauge(metric, amount)
	if(!metric || !halo_perf_collection_enabled())
		return

	GLOB.halo_perf_gauges[metric] = max((GLOB.halo_perf_gauges[metric] || 0) + amount, 0)

/proc/halo_perf_get_gauge(metric)
	if(!metric || !halo_perf_collection_enabled())
		return 0

	return GLOB.halo_perf_gauges[metric] || 0

/proc/halo_register_active_shield_harness(obj/item/clothing/suit/marine/shielded/harness)
	if(!istype(harness) || !halo_perf_collection_enabled())
		return

	GLOB.halo_perf_active_shield_harnesses |= harness

/proc/halo_unregister_active_shield_harness(obj/item/clothing/suit/marine/shielded/harness)
	if(!istype(harness) || !halo_perf_collection_enabled())
		return

	GLOB.halo_perf_active_shield_harnesses -= harness

/proc/halo_active_shield_harness_count()
	if(!halo_perf_collection_enabled())
		return 0

	for(var/obj/item/clothing/suit/marine/shielded/harness as anything in GLOB.halo_perf_active_shield_harnesses)
		if(QDELETED(harness))
			GLOB.halo_perf_active_shield_harnesses -= harness

	return length(GLOB.halo_perf_active_shield_harnesses)

/proc/halo_perf_bump_temp_visuals(amount = 1)
	halo_perf_bump("temp_visuals", amount)

/proc/halo_perf_bump_cover_scans(amount = 1)
	halo_perf_bump("cover_scans", amount)

/proc/halo_perf_bump_path_requests(amount = 1)
	halo_perf_bump("path_requests", amount)

/proc/halo_perf_bump_shield_ssfastobj_enters(amount = 1)
	halo_perf_bump("shield_ssfastobj_enters", amount)

/proc/halo_perf_bump_shield_ssfastobj_leaves(amount = 1)
	halo_perf_bump("shield_ssfastobj_leaves", amount)

/proc/halo_perf_bump_shield_hit_fx_spawns(amount = 1)
	halo_perf_bump("shield_hit_fx_spawns", amount)

/proc/halo_perf_bump_shield_pop_fx_spawns(amount = 1)
	halo_perf_bump("shield_pop_fx_spawns", amount)

/proc/halo_perf_bump_shield_timer_creates(amount = 1)
	halo_perf_bump("shield_timer_creates", amount)

/proc/halo_perf_bump_shield_effect_callbacks(amount = 1)
	halo_perf_bump("shield_effect_callbacks", amount)

/proc/halo_perf_bump_shield_temp_visual_qdels(amount = 1)
	halo_perf_bump("shield_temp_visual_qdels", amount)

/proc/halo_perf_adjust_active_halo_temp_visuals(amount)
	halo_perf_adjust_gauge("active_halo_temp_visuals", amount)

/proc/halo_perf_adjust_active_shield_temp_visuals(amount)
	halo_perf_adjust_gauge("active_shield_temp_visuals", amount)

/proc/halo_perf_adjust_active_shield_filters(amount)
	halo_perf_adjust_gauge("active_shield_filters", amount)

/proc/halo_perf_get_temp_visuals()
	return halo_perf_get("temp_visuals")

/proc/halo_perf_get_cover_scans()
	return halo_perf_get("cover_scans")

/proc/halo_perf_get_path_requests()
	return halo_perf_get("path_requests")

/proc/halo_perf_bump_projectile_throttles(amount = 1)
	halo_perf_bump("projectile_throttles", amount)

/proc/halo_perf_get_projectile_throttles()
	return halo_perf_get("projectile_throttles")

/proc/halo_perf_snapshot_subsystem(datum/controller/subsystem/subsystem)
	if(!istype(subsystem))
		return list()

	var/list/snapshot = list(
		"cost_ms" = round(subsystem.cost, 0.1),
		"tick_usage_pct" = round(subsystem.tick_usage, 0.1),
		"tick_overrun_pct" = round(subsystem.tick_overrun, 0.1),
		"ticks_avg" = round(subsystem.ticks, 0.1),
	)

	if(istype(subsystem, /datum/controller/subsystem/processing/fastobj))
		var/datum/controller/subsystem/processing/fastobj/fastobj = subsystem
		snapshot["processing_len"] = length(fastobj.processing)
	else if(istype(subsystem, /datum/controller/subsystem/timer))
		var/datum/controller/subsystem/timer/timer = subsystem
		snapshot["bucket_count"] = timer.bucket_count
		snapshot["second_queue_len"] = length(timer.second_queue)
		snapshot["clienttime_len"] = length(timer.clienttime_timers)
	else if(istype(subsystem, /datum/controller/subsystem/garbage))
		var/datum/controller/subsystem/garbage/garbage = subsystem
		var/queued_items = 0
		if(islist(garbage.queues))
			for(var/list/queue as anything in garbage.queues)
				queued_items += length(queue)
		snapshot["queued_items"] = queued_items
		snapshot["highest_del_ms"] = round(garbage.highest_del_ms, 0.1)
		snapshot["dels_last_tick"] = garbage.delslasttick
		snapshot["gced_last_tick"] = garbage.gcedlasttick

	return snapshot

/proc/halo_perf_checkpoint(label = null)
	if(!halo_perf_collection_enabled())
		return list()

	return list(
		"label" = label,
		"world_time" = world.time,
		"active_shield_harnesses" = halo_active_shield_harness_count(),
		"active_halo_temp_visuals" = halo_perf_get_gauge("active_halo_temp_visuals"),
		"active_shield_temp_visuals" = halo_perf_get_gauge("active_shield_temp_visuals"),
		"active_shield_filters" = halo_perf_get_gauge("active_shield_filters"),
		"temp_visuals_per_sec" = halo_perf_get_temp_visuals(),
		"temp_visuals_total" = halo_perf_get_total("temp_visuals"),
		"cover_scans_per_sec" = halo_perf_get_cover_scans(),
		"path_requests_per_sec" = halo_perf_get_path_requests(),
		"shield_ssfastobj_enters_per_sec" = halo_perf_get("shield_ssfastobj_enters"),
		"shield_ssfastobj_enters_total" = halo_perf_get_total("shield_ssfastobj_enters"),
		"shield_ssfastobj_leaves_per_sec" = halo_perf_get("shield_ssfastobj_leaves"),
		"shield_ssfastobj_leaves_total" = halo_perf_get_total("shield_ssfastobj_leaves"),
		"shield_hit_fx_spawns_per_sec" = halo_perf_get("shield_hit_fx_spawns"),
		"shield_hit_fx_spawns_total" = halo_perf_get_total("shield_hit_fx_spawns"),
		"shield_pop_fx_spawns_per_sec" = halo_perf_get("shield_pop_fx_spawns"),
		"shield_pop_fx_spawns_total" = halo_perf_get_total("shield_pop_fx_spawns"),
		"shield_timer_creates_per_sec" = halo_perf_get("shield_timer_creates"),
		"shield_timer_creates_total" = halo_perf_get_total("shield_timer_creates"),
		"shield_effect_callbacks_per_sec" = halo_perf_get("shield_effect_callbacks"),
		"shield_effect_callbacks_total" = halo_perf_get_total("shield_effect_callbacks"),
		"shield_temp_visual_qdels_per_sec" = halo_perf_get("shield_temp_visual_qdels"),
		"shield_temp_visual_qdels_total" = halo_perf_get_total("shield_temp_visual_qdels"),
		"projectile_throttles_per_sec" = halo_perf_get_projectile_throttles(),
		"subsystem_fastobj" = halo_perf_snapshot_subsystem(SSfastobj),
		"subsystem_timer" = halo_perf_snapshot_subsystem(SStimer),
		"subsystem_garbage" = halo_perf_snapshot_subsystem(SSgarbage),
	)

/proc/halo_build_human_ai_stat_suffix()
	if(!halo_perf_debug_enabled())
		return null

	var/active_shield_fx = halo_perf_get_gauge("active_shield_temp_visuals")
	var/shield_timers = halo_perf_get("shield_timer_creates")
	return "HALO Cover/s:[halo_perf_get_cover_scans()] Path/s:[halo_perf_get_path_requests()] Shields:[halo_active_shield_harness_count()] FXAlive:[active_shield_fx] Timers/s:[shield_timers]"

/proc/halo_build_pathfinding_stat_suffix()
	if(!halo_perf_debug_enabled())
		return null

	return "HALO Path/s:[halo_perf_get_path_requests()]"

/proc/halo_build_projectile_stat_suffix()
	if(!halo_perf_debug_enabled())
		return null

	var/shield_hit_fx = halo_perf_get("shield_hit_fx_spawns")
	var/shield_pop_fx = halo_perf_get("shield_pop_fx_spawns")
	return "HALO FX/s:[halo_perf_get_temp_visuals()] ShieldHit/s:[shield_hit_fx] ShieldPop/s:[shield_pop_fx] | HALO Throt/s:[halo_perf_get_projectile_throttles()]"

/proc/halo_perf_csv_headers()
	if(!halo_perf_debug_enabled())
		return list()

	return list(
		"halo_ai_brains",
		"halo_temp_visuals",
		"halo_temp_visuals_total",
		"halo_cover_scans",
		"halo_path_requests",
		"halo_active_shields",
		"halo_active_halo_temp_visuals",
		"halo_active_shield_temp_visuals",
		"halo_active_shield_filters",
		"halo_shield_ssfastobj_enters",
		"halo_shield_ssfastobj_leaves",
		"halo_shield_hit_fx_spawns",
		"halo_shield_pop_fx_spawns",
		"halo_shield_timer_creates",
		"halo_shield_effect_callbacks",
		"halo_shield_temp_visual_qdels",
		"halo_projectile_queue",
		"halo_projectile_throttles",
		"halo_fastobj_cost_ms",
		"halo_fastobj_tick_usage_pct",
		"halo_timer_cost_ms",
		"halo_timer_tick_usage_pct",
		"halo_garbage_cost_ms",
		"halo_garbage_tick_usage_pct",
	)

/proc/halo_perf_csv_values()
	if(!halo_perf_debug_enabled())
		return list()

	return list(
		length(GLOB.human_ai_brains),
		halo_perf_get_temp_visuals(),
		halo_perf_get_total("temp_visuals"),
		halo_perf_get_cover_scans(),
		halo_perf_get_path_requests(),
		halo_active_shield_harness_count(),
		halo_perf_get_gauge("active_halo_temp_visuals"),
		halo_perf_get_gauge("active_shield_temp_visuals"),
		halo_perf_get_gauge("active_shield_filters"),
		halo_perf_get("shield_ssfastobj_enters"),
		halo_perf_get("shield_ssfastobj_leaves"),
		halo_perf_get("shield_hit_fx_spawns"),
		halo_perf_get("shield_pop_fx_spawns"),
		halo_perf_get("shield_timer_creates"),
		halo_perf_get("shield_effect_callbacks"),
		halo_perf_get("shield_temp_visual_qdels"),
		halo_get_projectile_queue_length(),
		halo_perf_get_projectile_throttles(),
		round(SSfastobj.cost, 0.1),
		round(SSfastobj.tick_usage, 0.1),
		round(SStimer.cost, 0.1),
		round(SStimer.tick_usage, 0.1),
		round(SSgarbage.cost, 0.1),
		round(SSgarbage.tick_usage, 0.1),
	)

/datum/controller/subsystem/human_ai/proc/modular_stat_entry_suffix()
	return halo_build_human_ai_stat_suffix()

/datum/controller/subsystem/pathfinding/proc/modular_stat_entry_suffix()
	return halo_build_pathfinding_stat_suffix()

/datum/controller/subsystem/projectiles/proc/modular_stat_entry_suffix()
	return halo_build_projectile_stat_suffix()

/datum/controller/subsystem/time_track/proc/modular_perf_headers()
	return halo_perf_csv_headers()

/datum/controller/subsystem/time_track/proc/modular_perf_values()
	return halo_perf_csv_values()

/datum/human_ai_brain/proc/modular_on_navigation_path_queued(turf/destination, max_range)
	halo_perf_bump_path_requests()

/datum/human_ai_brain/proc/modular_on_cover_scan_started()
	halo_perf_bump_cover_scans()
