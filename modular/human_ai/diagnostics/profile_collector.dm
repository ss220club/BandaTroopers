/// Optional aggregate instrumentation. This is server diagnostic state, never
/// part of NPC presets, personal slots or saved gameplay settings.
/datum/controller/subsystem/human_ai
	var/performance_profile_enabled = FALSE
	var/performance_profile_generation = 0
	var/performance_profile_path
	var/performance_profile_error
	var/performance_profile_window_time = 0
	var/performance_profile_window_realtime = 0
	/// Fixed stage keys plus two keys per registered AI action type, not per NPC.
	var/list/performance_profile_groups = list()
	/// Each row is: completed calls, valid inclusive milliseconds, max, skipped.
	var/list/performance_profile_stats = list()
	var/list/performance_profile_weight_keys = list()
	var/list/performance_profile_action_keys = list()

/datum/controller/subsystem/human_ai/proc/set_performance_profile(enabled)
	if(enabled == performance_profile_enabled)
		return TRUE
	if(!enabled)
		// Keep the last partial window instead of silently losing the final fight.
		performance_values()
		performance_profile_enabled = FALSE
		performance_profile_generation++
		return !performance_profile_error

	performance_profile_error = null
	if(!GLOB.log_directory)
		performance_profile_error = "Каталог журнала раунда ещё не готов."
		return FALSE
	performance_profile_path = "[GLOB.log_directory]/human-ai-profile-[GLOB.round_id].csv"
	if(!fexists(performance_profile_path))
		if(!text2file("time_ds,session,window_game_seconds,window_real_seconds,world_cpu,living_npcs,engaged_npcs,bucket,category,completed_calls,valid_calls,total_inclusive_ms,max_inclusive_ms,skipped_calls", performance_profile_path))
			performance_profile_error = "Не удалось создать CSV диагностики."
			return FALSE

	performance_profile_groups = list(
		"process" = "total",
		"targeting" = "targeting",
		"pursuit_update" = "pursuit",
		"item_scan" = "equipment",
		"grenade_scan" = "grenades",
		"medical_preemption" = "medicine",
		"navigation_safety" = "movement",
		"selection" = "selection",
		"dispatch" = "dispatch",
		"movement_event" = "movement",
		"projectile_event" = "targeting",
		"target_tracking" = "targeting",
		"fire_followup" = "firing",
		"fire_event" = "firing",
		"fire_safety" = "firing",
	)
	performance_profile_weight_keys = list()
	performance_profile_action_keys = list()
	for(var/action_type as anything in GLOB.AI_actions)
		var/category = performance_action_category(action_type)
		var/weight_key = "weight:[action_type]"
		var/action_key = "action:[action_type]"
		performance_profile_groups[weight_key] = category
		performance_profile_groups[action_key] = category
		performance_profile_weight_keys[action_type] = weight_key
		performance_profile_action_keys[action_type] = action_key
	performance_profile_stats = list()
	for(var/bucket in performance_profile_groups)
		performance_profile_stats[bucket] = list(0, 0, 0, 0)
	performance_profile_window_time = world.time
	performance_profile_window_realtime = REALTIMEOFDAY
	performance_profile_generation++
	performance_profile_enabled = TRUE
	return TRUE

/// Called only when enabling diagnostics, never in the per-NPC hot loop.
/datum/controller/subsystem/human_ai/proc/performance_action_category(action_type)
	if(ispath(action_type, /datum/ai_action/fire_at_target))
		return "firing"
	if(ispath(action_type, /datum/ai_action/treat_self) || ispath(action_type, /datum/ai_action/treat_ally) || ispath(action_type, /datum/ai_action/resist_burning))
		return "medicine"
	if(ispath(action_type, /datum/ai_action/throw_grenade) || ispath(action_type, /datum/ai_action/throw_back_nade) || ispath(action_type, /datum/ai_action/fire_underbarrel_grenade))
		return "grenades"
	if(ispath(action_type, /datum/ai_action/chase_target))
		return "pursuit"
	if(ispath(action_type, /datum/ai_action/item_pickup) || ispath(action_type, /datum/ai_action/reload) || ispath(action_type, /datum/ai_action/select_primary))
		return "equipment"
	return "other"

/// Inclusive synchronous cost, not wall time, per-NPC cost or CPU percentage.
/// Invalid/unfinished samples must never change control flow in the AI itself.
/datum/controller/subsystem/human_ai/proc/record_performance_profile(bucket, generation, started_tick, started_lag, usage_delta)
	if(!performance_profile_enabled || generation != performance_profile_generation)
		return
	var/list/counters = performance_profile_stats[bucket]
	if(!counters)
		return
	counters[1]++
	if(started_tick != world.time || started_lag != world.tick_lag || usage_delta < 0)
		counters[4]++
		return
	var/elapsed_ms = usage_delta * started_lag
	counters[2] += elapsed_ms
	counters[3] = max(counters[3], elapsed_ms)

/// Reuses the existing ten-second perf logger; no extra timer/subsystem/scans.
/datum/controller/subsystem/human_ai/proc/flush_performance_profile(living, engaged)
	if(!performance_profile_enabled)
		return
	var/current_time = world.time
	var/current_realtime = REALTIMEOFDAY
	var/real_elapsed = current_realtime - performance_profile_window_realtime
	if(real_elapsed < 0)
		real_elapsed += 24 HOURS
	var/game_seconds = (current_time - performance_profile_window_time) * 0.1
	var/real_seconds = real_elapsed * 0.1
	var/cpu = world.cpu
	var/list/lines = list()
	for(var/bucket in performance_profile_stats)
		var/list/counters = performance_profile_stats[bucket]
		// Always emit one heartbeat row so an enabled but idle window is visible.
		if(!counters[1] && bucket != "process")
			continue
		lines += jointext(list(current_time, performance_profile_generation, game_seconds, real_seconds, cpu, living, engaged, bucket, performance_profile_groups[bucket], counters[1], counters[1] - counters[4], counters[2], counters[3], counters[4]), ",")
		counters[1] = 0
		counters[2] = 0
		counters[3] = 0
		counters[4] = 0
	performance_profile_window_time = current_time
	performance_profile_window_realtime = current_realtime
	if(!text2file(jointext(lines, "\n"), performance_profile_path))
		performance_profile_error = "Не удалось записать CSV. Диагностика отключена."
		performance_profile_enabled = FALSE
		performance_profile_generation++
		log_admin("Human AI performance diagnostics disabled: failed to write [performance_profile_path].")

/// This optional wrapper is used only while profiling is enabled. Normal
/// scheduling calls the original get_weight directly; its return is untouched.
/datum/ai_action/proc/profiled_get_weight(datum/human_ai_brain/acting_brain)
	var/bucket = SShuman_ai.performance_profile_weight_keys[type]
	HAI_PROFILE_BEGIN(weight)
	. = get_weight(acting_brain)
	HAI_PROFILE_END(weight, bucket)
