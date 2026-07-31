/*
 * Coarse DM-side profiler.
 *
 * BYOND timing is decisecond-granularity, so this is not intended for precise
 * micro-benchmarking. Its job is to make workbench reports answer "which stage
 * did we reach?" and "which stage was relatively expensive?" even when a case
 * fails before apply. Python tools can add wall-clock render/index timings.
 */
/datum/world_edit_visual_profiler
	var/enabled = TRUE
	var/total_start_ds = 0
	var/total_end_ds = 0
	var/current_stage = null
	var/current_stage_start_ds = 0
	var/list/stages = list()
	var/list/global_counters = list()
	var/list/warnings = list()

/datum/world_edit_visual_profiler/proc/now_ds()
	return world.time

/datum/world_edit_visual_profiler/proc/begin_total()
	if(!enabled)
		return
	total_start_ds = now_ds()

/datum/world_edit_visual_profiler/proc/end_total()
	if(!enabled)
		return
	total_end_ds = now_ds()

/datum/world_edit_visual_profiler/proc/enter_stage(stage_name)
	if(!enabled)
		return
	if(current_stage)
		leave_stage(current_stage, list("auto_closed" = TRUE))
	current_stage = "[stage_name]"
	current_stage_start_ds = now_ds()

/datum/world_edit_visual_profiler/proc/leave_stage(stage_name, list/result)
	if(!enabled)
		return
	var/end_ds = now_ds()
	var/duration_ds = max(0, end_ds - current_stage_start_ds)
	var/list/stage = list(
		"name" = "[stage_name]",
		"duration_ds" = duration_ds,
		"duration_estimated_ms" = duration_ds * 100,
		"counters" = extract_counters(result),
	)
	if(islist(result) && result["error"])
		stage["error"] = result["error"]
	stages += list(stage)
	current_stage = null
	current_stage_start_ds = 0

/datum/world_edit_visual_profiler/proc/count(name, amount = 1)
	if(!enabled)
		return
	var/key = "[name]"
	global_counters[key] = (text2num("[global_counters[key]]") || 0) + amount

/datum/world_edit_visual_profiler/proc/set_counter(name, value)
	if(!enabled)
		return
	global_counters["[name]"] = value

/datum/world_edit_visual_profiler/proc/extract_counters(list/result)
	var/list/counters = list()
	if(!islist(result))
		return counters
	for(var/key as anything in result)
		if(findtext("[key]", "_count") || findtext("[key]", "count_") || findtext("[key]", "_total"))
			counters[key] = result[key]
	var/list/result_counters = result["counters"]
	if(islist(result_counters))
		for(var/key as anything in result_counters)
			counters[key] = result_counters[key]
	return counters

/datum/world_edit_visual_profiler/proc/to_json_list()
	if(!enabled)
		return null
	var/total_ds = max(0, total_end_ds - total_start_ds)
	if(total_ds <= 0)
		warnings += "Total DM time is 0 ds; case may be too fast for DM timing granularity. Use external wall time for precise timings."
	return list(
		"total_dm_ds" = total_ds,
		"total_estimated_ms" = total_ds * 100,
		"stages" = stages.Copy(),
		"counters" = global_counters.Copy(),
		"warnings" = warnings.Copy(),
	)
