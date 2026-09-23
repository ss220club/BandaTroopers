/datum/world_edit_manager/proc/get_history_entries_desc()
	if(!length(history_entries))
		return list()

	var/list/desc_entries = list()
	for(var/i = length(history_entries), i >= 1, i--)
		desc_entries += list(history_entries[i])
	return desc_entries

/datum/world_edit_manager/proc/add_history_entry(generator_id, result_code, created_count, deleted_count, turf/center_turf, params_short, message = "", duration_ms = 0, list/extra_data = null)
	var/list/entry = list(
		"time" = time_stamp(),
		"generator_id" = generator_id,
		"result" = result_code,
		"created_count" = created_count,
		"deleted_count" = deleted_count,
		"center_turf" = center_turf ? "[center_turf.x],[center_turf.y],[center_turf.z]" : "n/a",
		"params_short" = params_short,
		"message" = message,
		"duration_ms" = duration_ms
	)
	if(islist(extra_data))
		for(var/key in extra_data)
			entry[key] = extra_data[key]
	history_entries += list(entry)
	while(length(history_entries) > WORLD_EDIT_HISTORY_LIMIT)
		history_entries.Cut(1, 2)
	return entry

/datum/world_edit_manager/proc/prune_changeset_stack()
	if(!islist(changeset_entries))
		changeset_entries = list()
		return

	while(length(changeset_entries))
		var/datum/world_edit_changeset/changeset = changeset_entries[length(changeset_entries)]
		if(istype(changeset) && !changeset.is_empty())
			break

		changeset_entries.Cut(length(changeset_entries), length(changeset_entries) + 1)
		if(istype(changeset))
			qdel(changeset)

/datum/world_edit_manager/proc/push_changeset(datum/world_edit_changeset/changeset)
	if(!istype(changeset))
		return null
	if(changeset.is_empty())
		qdel(changeset)
		return null

	if(!islist(changeset_entries))
		changeset_entries = list()

	changeset_entries += list(changeset)
	while(length(changeset_entries) > WORLD_EDIT_HISTORY_LIMIT)
		var/datum/world_edit_changeset/old_changeset = changeset_entries[1]
		changeset_entries.Cut(1, 2)
		if(istype(old_changeset))
			qdel(old_changeset)
	return changeset

/datum/world_edit_manager/proc/get_last_changeset()
	prune_changeset_stack()
	if(!length(changeset_entries))
		return null
	return changeset_entries[length(changeset_entries)]

/datum/world_edit_manager/proc/build_changeset_history_meta(datum/world_edit_changeset/changeset)
	var/list/meta = list(
		"undo_policy" = WORLD_EDIT_UNDO_NONE,
		"undo_status" = "not_available",
	)
	if(!istype(changeset))
		return meta

	meta["operation_id"] = changeset.operation_id
	meta["undo_policy"] = changeset.undo_policy
	meta["created_entries"] = length(changeset.created_entries)
	meta["moved_entries"] = length(changeset.moved_entries)
	meta["changed_turf_entries"] = length(changeset.changed_turf_entries)
	meta["owned_effect_entries"] = length(changeset.owned_effect_entries)
	meta["undo_status"] = changeset.can_undo() ? "available" : (changeset.can_cleanup_owned_effects() ? "cleanup_available" : "not_available")
	return meta

/datum/world_edit_manager/proc/build_last_changeset_summary()
	var/datum/world_edit_changeset/changeset = get_last_changeset()
	if(!istype(changeset))
		return null

	return list(
		"operation_id" = changeset.operation_id,
		"generator_id" = changeset.generator_id,
		"undo_policy" = changeset.undo_policy,
		"created_entries" = length(changeset.created_entries),
		"moved_entries" = length(changeset.moved_entries),
		"changed_turf_entries" = length(changeset.changed_turf_entries),
		"owned_effect_entries" = length(changeset.owned_effect_entries),
		"created_at" = changeset.created_at,
		"can_undo" = changeset.can_undo() ? TRUE : FALSE,
		"can_cleanup" = changeset.can_cleanup_owned_effects() ? TRUE : FALSE,
		"undo_status" = changeset.can_undo() ? "available" : (changeset.can_cleanup_owned_effects() ? "cleanup_available" : "not_available"),
	)

/datum/world_edit_manager/proc/can_undo_last_operation()
	var/datum/world_edit_changeset/changeset = get_last_changeset()
	return changeset?.can_undo() ? TRUE : FALSE

/datum/world_edit_manager/proc/can_cleanup_last_owned_effects()
	var/datum/world_edit_changeset/changeset = get_last_changeset()
	return changeset?.can_cleanup_owned_effects() ? TRUE : FALSE
