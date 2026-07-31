#define WORLD_EDIT_UNDO_FULL "undo_full"
#define WORLD_EDIT_UNDO_PARTIAL "undo_partial"
#define WORLD_EDIT_UNDO_NONE "non_undoable"

GLOBAL_DATUM_INIT(world_edit_changesets, /datum/world_edit_changeset_service, new)

/datum/world_edit_changeset_service

/datum/world_edit_changeset_service/proc/build_operation_id(prefix = "weop")
	var/safe_prefix = sanitize_filename("[prefix]")
	if(!length(safe_prefix))
		safe_prefix = "weop"
	return "[safe_prefix]_[copytext(md5("[safe_prefix]-[world.realtime]-[world.time]-[rand(1, 1000000)]"), 1, 13)]"

/datum/world_edit_changeset_service/proc/copy_changeset_metadata(list/raw_metadata)
	if(!islist(raw_metadata))
		return list()
	return raw_metadata.Copy()

/// Minimal changeset record for safe undo/cleanup of one World Edit operation.
/datum/world_edit_changeset
	var/operation_id = ""
	var/generator_id = ""
	var/undo_policy = WORLD_EDIT_UNDO_NONE
	var/list/created_entries = list()
	var/list/moved_entries = list()
	var/list/changed_turf_entries = list()
	var/list/owned_effect_entries = list()
	var/list/metadata = list()
	var/created_at = ""

/datum/world_edit_changeset/New(new_generator_id = "", new_undo_policy = WORLD_EDIT_UNDO_NONE, list/new_metadata = null, new_operation_id = null)
	. = ..()
	operation_id = length("[new_operation_id]") ? "[new_operation_id]" : GLOB.world_edit_changesets.build_operation_id("world_edit")
	generator_id = "[new_generator_id]"
	undo_policy = length("[new_undo_policy]") ? "[new_undo_policy]" : WORLD_EDIT_UNDO_NONE
	created_entries = list()
	moved_entries = list()
	changed_turf_entries = list()
	owned_effect_entries = list()
	metadata = GLOB.world_edit_changesets.copy_changeset_metadata(new_metadata)
	created_at = time_stamp()

/datum/world_edit_changeset/proc/add_created(atom/created_atom, turf/target_turf = null, list/entry_metadata = null)
	if(!created_atom || QDELETED(created_atom))
		return FALSE

	if(!target_turf)
		target_turf = get_turf(created_atom)

	created_entries += list(list(
		"target_ref" = WEAKREF(created_atom),
		"type" = created_atom.type,
		"target_turf" = target_turf,
		"metadata" = GLOB.world_edit_changesets.copy_changeset_metadata(entry_metadata),
	))
	return TRUE

/datum/world_edit_changeset/proc/add_moved(atom/movable/target, turf/source_turf, turf/destination_turf, list/mode_metadata = null)
	if(!target || QDELETED(target) || !source_turf || !destination_turf)
		return FALSE

	moved_entries += list(list(
		"target_ref" = WEAKREF(target),
		"source_turf" = source_turf,
		"destination_turf" = destination_turf,
		"mode_metadata" = GLOB.world_edit_changesets.copy_changeset_metadata(mode_metadata),
	))
	return TRUE

/datum/world_edit_changeset/proc/add_changed_turf(turf/changed_turf, old_type, new_type, old_baseturfs = null, list/entry_metadata = null)
	if(!istype(changed_turf) || !ispath(old_type, /turf) || !ispath(new_type, /turf))
		return FALSE

	var/stored_baseturfs = old_baseturfs
	if(islist(old_baseturfs))
		var/list/old_baseturfs_list = old_baseturfs
		stored_baseturfs = old_baseturfs_list.Copy()

	changed_turf_entries += list(list(
		"x" = changed_turf.x,
		"y" = changed_turf.y,
		"z" = changed_turf.z,
		"old_type" = old_type,
		"new_type" = new_type,
		"old_baseturfs" = stored_baseturfs,
		"metadata" = GLOB.world_edit_changesets.copy_changeset_metadata(entry_metadata),
	))
	return TRUE

/datum/world_edit_changeset/proc/add_owned_effect(atom/effect_atom, owner_operation_id = null, turf/effect_turf = null, list/effect_metadata = null)
	if(!effect_atom || QDELETED(effect_atom))
		return FALSE

	if(!effect_turf)
		effect_turf = get_turf(effect_atom)

	owned_effect_entries += list(list(
		"effect_ref" = WEAKREF(effect_atom),
		"effect_type" = effect_atom.type,
		"turf" = effect_turf,
		"owner_operation_id" = length("[owner_operation_id]") ? "[owner_operation_id]" : operation_id,
		"metadata" = GLOB.world_edit_changesets.copy_changeset_metadata(effect_metadata),
	))
	return TRUE

/datum/world_edit_changeset/proc/can_undo()
	if(!(undo_policy in list(WORLD_EDIT_UNDO_FULL, WORLD_EDIT_UNDO_PARTIAL)))
		return FALSE
	return (length(created_entries) || length(moved_entries) || length(changed_turf_entries)) ? TRUE : FALSE

/datum/world_edit_changeset/proc/can_cleanup_owned_effects()
	return length(owned_effect_entries) ? TRUE : FALSE

/datum/world_edit_changeset/proc/is_empty()
	return !can_undo() && !can_cleanup_owned_effects()

/datum/world_edit_changeset_service/proc/revert_changeset(datum/world_edit_changeset/changeset)
	var/reverted_count = 0
	var/skipped_count = 0

	if(!istype(changeset))
		return list(
			"reverted_count" = 0,
			"skipped_count" = 0,
			"outcome" = "none",
		)

	switch(changeset.undo_policy)
		if(WORLD_EDIT_UNDO_FULL)
			for(var/list/entry as anything in changeset.created_entries)
				var/datum/weakref/target_ref = entry["target_ref"]
				var/atom/target = target_ref?.resolve()
				var/expected_type = entry["type"]
				var/turf/expected_turf = entry["target_turf"]
				if(!target || QDELETED(target) || target.type != expected_type)
					skipped_count++
					continue
				if(expected_turf && get_turf(target) != expected_turf)
					skipped_count++
					continue

				GLOB.world_edit_helpers.safe_qdel(target)
				reverted_count++

			for(var/list/entry as anything in changeset.changed_turf_entries)
				var/x_value = text2num("[entry["x"]]")
				var/y_value = text2num("[entry["y"]]")
				var/z_value = text2num("[entry["z"]]")
				var/turf/target_turf = locate(x_value, y_value, z_value)
				var/expected_type = entry["new_type"]
				var/old_type = entry["old_type"]
				if(!istype(target_turf) || target_turf.type != expected_type || !ispath(old_type, /turf))
					skipped_count++
					continue

				target_turf.ChangeTurf(old_type, entry["old_baseturfs"])
				var/turf/restored_turf = locate(x_value, y_value, z_value)
				if(istype(restored_turf) && restored_turf.type == old_type)
					reverted_count++
				else
					skipped_count++

		if(WORLD_EDIT_UNDO_PARTIAL)
			for(var/list/entry as anything in changeset.moved_entries)
				var/datum/weakref/target_ref = entry["target_ref"]
				var/atom/movable/target = target_ref?.resolve()
				var/turf/source_turf = entry["source_turf"]
				var/turf/destination_turf = entry["destination_turf"]
				if(!istype(target, /atom/movable) || QDELETED(target))
					skipped_count++
					continue
				if(!source_turf || !destination_turf || target.anchored)
					skipped_count++
					continue
				if(ismob(target.loc) || !isturf(target.loc))
					skipped_count++
					continue
				if(get_turf(target) != destination_turf)
					skipped_count++
					continue

				target.forceMove(source_turf)
				if(get_turf(target) == source_turf)
					reverted_count++
				else
					skipped_count++

		else
			skipped_count = length(changeset.created_entries) + length(changeset.moved_entries) + length(changeset.changed_turf_entries)

	var/outcome = "none"
	var/attempted_count = reverted_count + skipped_count
	if(attempted_count > 0)
		if(skipped_count <= 0)
			outcome = "full"
		else if(reverted_count > 0)
			outcome = "partial"
		else
			outcome = "skipped"

	return list(
		"reverted_count" = reverted_count,
		"skipped_count" = skipped_count,
		"outcome" = outcome,
	)

/datum/world_edit_changeset_service/proc/cleanup_changeset_owned_effects(datum/world_edit_changeset/changeset)
	var/removed_count = 0
	var/skipped_count = 0

	if(!istype(changeset))
		return list(
			"reverted_count" = 0,
			"skipped_count" = 0,
			"outcome" = "none",
		)

	for(var/list/entry as anything in changeset.owned_effect_entries)
		var/datum/weakref/effect_ref = entry["effect_ref"]
		var/atom/effect_atom = effect_ref?.resolve()
		var/expected_type = entry["effect_type"]
		var/owner_operation_id = "[entry["owner_operation_id"] || changeset.operation_id]"
		if(!effect_atom || QDELETED(effect_atom) || effect_atom.type != expected_type)
			skipped_count++
			continue

		var/current_owner = "[effect_atom.vars["world_edit_owner_operation_id"]]"
		if(current_owner != owner_operation_id)
			skipped_count++
			continue

		GLOB.world_edit_helpers.safe_qdel(effect_atom)
		removed_count++

	var/outcome = "none"
	var/attempted_count = removed_count + skipped_count
	if(attempted_count > 0)
		if(skipped_count <= 0)
			outcome = "full"
		else if(removed_count > 0)
			outcome = "partial"
		else
			outcome = "skipped"

	return list(
		"reverted_count" = removed_count,
		"skipped_count" = skipped_count,
		"outcome" = outcome,
	)
