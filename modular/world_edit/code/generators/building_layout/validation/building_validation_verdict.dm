/datum/world_edit_validation_verdict
	var/status = ""
	var/stage = ""
	var/list/hard_errors = list()
	var/list/warnings = list()
	var/list/metrics = list()

/datum/world_edit_validation_verdict/New(_status = null, _stage = null)
	. = ..()
	if(!isnull(_status))
		status = "[_status]"
	if(!isnull(_stage))
		stage = "[_stage]"

/datum/world_edit_validation_verdict/proc/add_hard_error(code, message = null, list/context = null)
	var/list/error_entry = list(
		"code" = "[code]",
	)
	if(!isnull(message))
		error_entry["message"] = "[message]"
	if(islist(context))
		error_entry["context"] = context.Copy()
	hard_errors += list(error_entry)
	return error_entry

/datum/world_edit_validation_verdict/proc/add_warning(code, message = null, list/context = null)
	var/list/warning_entry = list(
		"code" = "[code]",
	)
	if(!isnull(message))
		warning_entry["message"] = "[message]"
	if(islist(context))
		warning_entry["context"] = context.Copy()
	warnings += list(warning_entry)
	return warning_entry

/datum/world_edit_validation_verdict/proc/set_metric(metric_id, value)
	if(!length("[metric_id]"))
		return FALSE
	metrics["[metric_id]"] = value
	return TRUE

/datum/world_edit_validation_verdict/proc/has_hard_errors()
	return length(hard_errors) > 0

/datum/world_edit_validation_verdict/proc/is_hard_failure()
	if(has_hard_errors())
		return TRUE
	return status in list(
		WORLD_EDIT_BUILDING_PREFLIGHT_UNSUPPORTED,
		WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST,
		WORLD_EDIT_BUILDING_GENERATION_NO_SOLUTION,
		WORLD_EDIT_BUILDING_GENERATION_VALIDATION_FAILED,
		WORLD_EDIT_BUILDING_GENERATION_INTERNAL_ERROR,
		WORLD_EDIT_BUILDING_APPLY_WORLD_CONFLICT,
		WORLD_EDIT_BUILDING_APPLY_ROLLED_BACK,
		WORLD_EDIT_BUILDING_APPLY_FAILED,
		WORLD_EDIT_BUILDING_WORKBENCH_FAILED,
	)

/datum/world_edit_validation_verdict/proc/merge_from(datum/world_edit_validation_verdict/other)
	if(!istype(other))
		return src
	if(!length(status) && length(other.status))
		status = other.status
	if(!length(stage) && length(other.stage))
		stage = other.stage
	for(var/error_entry as anything in other.hard_errors)
		hard_errors += list(error_entry)
	for(var/warning_entry as anything in other.warnings)
		warnings += list(warning_entry)
	for(var/metric_id as anything in other.metrics)
		metrics[metric_id] = other.metrics[metric_id]
	return src

/datum/world_edit_validation_verdict/proc/copy()
	var/datum/world_edit_validation_verdict/new_verdict = new(status, stage)
	new_verdict.merge_from(src)
	return new_verdict

/datum/world_edit_validation_verdict/proc/as_payload()
	return list(
		"status" = status,
		"stage" = stage,
		"hard_errors" = islist(hard_errors) ? hard_errors.Copy() : list(),
		"warnings" = islist(warnings) ? warnings.Copy() : list(),
		"metrics" = islist(metrics) ? metrics.Copy() : list(),
	)
