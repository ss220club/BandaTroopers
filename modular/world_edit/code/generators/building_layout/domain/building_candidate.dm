/datum/world_edit_building_diagnostics
	var/list/metrics = list()
	var/list/debug_trace = list()
	var/debug_trace_enabled = FALSE

/datum/world_edit_building_diagnostics/proc/set_metric(metric_id, value)
	if(!length("[metric_id]"))
		return FALSE
	metrics["[metric_id]"] = value
	return TRUE

/datum/world_edit_building_diagnostics/proc/add_trace(stage_id, message, list/context = null)
	if(!debug_trace_enabled || length(debug_trace) >= WORLD_EDIT_BUILDING_DIAGNOSTIC_TRACE_LIMIT)
		return null
	var/list/trace_entry = list(
		"stage" = "[stage_id]",
		"message" = "[message]",
	)
	if(islist(context))
		trace_entry["context"] = context.Copy()
	debug_trace += list(trace_entry)
	return trace_entry

/datum/world_edit_building_diagnostics/proc/as_payload()
	return list(
		"metrics" = islist(metrics) ? metrics.Copy() : list(),
		"debug_trace" = islist(debug_trace) ? debug_trace.Copy() : list(),
	)

/datum/world_edit_building_stage_result
	var/stage = ""
	var/status = ""
	var/value
	var/datum/world_edit_validation_verdict/verdict
	var/datum/world_edit_building_diagnostics/diagnostics

/datum/world_edit_building_stage_result/New(_stage = "", _status = "")
	. = ..()
	stage = "[_stage]"
	status = "[_status]"
	diagnostics = new

/datum/world_edit_building_stage_result/proc/is_success()
	return !verdict?.is_hard_failure()

/datum/world_edit_building_stage_result/proc/as_payload()
	return list(
		"stage" = stage,
		"status" = status,
		"verdict" = verdict?.as_payload(),
		"diagnostics" = diagnostics?.as_payload(),
	)

/datum/world_edit_building_candidate
	var/id = ""
	var/datum/world_edit_building_footprint/footprint
	var/list/rooms = list()
	var/list/routes = list()
	var/list/openings = list()
	var/list/placements = list()
	var/datum/world_edit_validation_verdict/verdict
	var/score = 0
	var/layout_hash = ""
	var/datum/world_edit_building_diagnostics/diagnostics

/datum/world_edit_building_candidate/New(_id = "")
	. = ..()
	id = "[_id]"
	verdict = new(WORLD_EDIT_BUILDING_GENERATION_VALID_PLAN, WORLD_EDIT_BUILDING_STAGE_CANDIDATE_VALIDATION)
	diagnostics = new

/datum/world_edit_building_candidate/proc/is_hard_valid()
	return istype(verdict) && !verdict.is_hard_failure()

/datum/world_edit_building_candidate/proc/as_payload()
	return list(
		"id" = id,
		"footprint" = footprint?.as_payload(),
		"room_count" = length(rooms),
		"route_count" = length(routes),
		"opening_count" = length(openings),
		"placement_count" = length(placements),
		"verdict" = verdict?.as_payload(),
		"score" = score,
		"layout_hash" = layout_hash,
		"diagnostics" = diagnostics?.as_payload(),
	)
