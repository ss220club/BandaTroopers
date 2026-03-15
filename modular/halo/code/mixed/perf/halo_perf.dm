/proc/halo_is_ai_only_human(mob/living/carbon/human/human)
	return istype(human) && !human.client && (human.mob_flags & AI_CONTROLLED)

/proc/halo_is_ai_only_combat_pair(mob/living/carbon/human/source_human, mob/living/carbon/human/target_human)
	return halo_is_ai_only_human(source_human) && halo_is_ai_only_human(target_human)

/proc/halo_is_projectile_pressure_relevant_ammo(datum/ammo/ammo_datum)
	return istype(ammo_datum, /datum/ammo/energy/halo_plasma) || istype(ammo_datum, /datum/ammo/needler) || istype(ammo_datum, /datum/ammo/bullet/rifle/carbine)

/proc/halo_perf_debug_enabled()
	return CONFIG_GET(flag/halo_perf_debug)

GLOBAL_LIST_EMPTY_TYPED(halo_perf_active_shield_harnesses, /obj/item/clothing/suit/marine/shielded)
GLOBAL_LIST_INIT(halo_perf_window_counts, list(
	"temp_visuals" = 0,
	"cover_scans" = 0,
	"path_requests" = 0,
	"projectile_throttles" = 0,
))
GLOBAL_VAR_INIT(halo_perf_window_id, -1)

/proc/halo_perf_sync_window()
	if(!halo_perf_debug_enabled())
		return

	var/current_window_id = world.time - (world.time % 10)
	if(GLOB.halo_perf_window_id == current_window_id)
		return

	GLOB.halo_perf_window_id = current_window_id
	for(var/metric in GLOB.halo_perf_window_counts)
		GLOB.halo_perf_window_counts[metric] = 0

/proc/halo_perf_bump(metric, amount = 1)
	if(!metric || !halo_perf_debug_enabled())
		return

	halo_perf_sync_window()
	GLOB.halo_perf_window_counts[metric] = (GLOB.halo_perf_window_counts[metric] || 0) + amount

/proc/halo_perf_get(metric)
	if(!metric || !halo_perf_debug_enabled())
		return 0

	halo_perf_sync_window()
	return GLOB.halo_perf_window_counts[metric] || 0

/proc/halo_register_active_shield_harness(obj/item/clothing/suit/marine/shielded/harness)
	if(!istype(harness) || !halo_perf_debug_enabled())
		return

	GLOB.halo_perf_active_shield_harnesses |= harness

/proc/halo_unregister_active_shield_harness(obj/item/clothing/suit/marine/shielded/harness)
	if(!istype(harness) || !halo_perf_debug_enabled())
		return

	GLOB.halo_perf_active_shield_harnesses -= harness

/proc/halo_active_shield_harness_count()
	if(!halo_perf_debug_enabled())
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

/proc/halo_build_human_ai_stat_suffix()
	if(!halo_perf_debug_enabled())
		return null

	return "HALO Cover/s:[halo_perf_get_cover_scans()] Path/s:[halo_perf_get_path_requests()] Shields:[halo_active_shield_harness_count()]"

/proc/halo_build_pathfinding_stat_suffix()
	if(!halo_perf_debug_enabled())
		return null

	return "HALO Path/s:[halo_perf_get_path_requests()]"

/proc/halo_build_projectile_stat_suffix()
	if(!halo_perf_debug_enabled())
		return null

	return "HALO FX/s:[halo_perf_get_temp_visuals()] | HALO Throt/s:[halo_perf_get_projectile_throttles()]"

/proc/halo_perf_csv_headers()
	if(!halo_perf_debug_enabled())
		return list()

	return list(
		"halo_ai_brains",
		"halo_temp_visuals",
		"halo_cover_scans",
		"halo_path_requests",
		"halo_active_shields",
		"halo_projectile_queue",
		"halo_projectile_throttles",
	)

/proc/halo_perf_csv_values()
	if(!halo_perf_debug_enabled())
		return list()

	return list(
		length(GLOB.human_ai_brains),
		halo_perf_get_temp_visuals(),
		halo_perf_get_cover_scans(),
		halo_perf_get_path_requests(),
		halo_active_shield_harness_count(),
		halo_get_projectile_queue_length(),
		halo_perf_get_projectile_throttles(),
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
