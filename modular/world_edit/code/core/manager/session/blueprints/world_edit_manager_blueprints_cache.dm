/datum/world_edit_manager/proc/ensure_blueprint_cache_loaded()
	if(blueprint_cache_loaded)
		return
	refresh_blueprint_cache()

/datum/world_edit_manager/proc/refresh_blueprint_cache()
	blueprint_entries_cache = GLOB.world_edit_blueprints.world_edit_load_blueprint_library_summaries()
	blueprint_cache_loaded = TRUE
	invalidate_active_blueprint_revision_cache()

/datum/world_edit_manager/proc/invalidate_active_blueprint_revision_cache()
	active_blueprint_revision_id = null
	active_blueprint_revision_hash = ""
	invalidate_active_blueprint_sprite_preview_cache()
	return TRUE

/datum/world_edit_manager/proc/invalidate_active_blueprint_sprite_preview_cache()
	active_blueprint_sprite_preview_revision_id = null
	active_blueprint_sprite_preview_revision_hash = ""
	active_blueprint_sprite_preview_cache = null
	return TRUE

/datum/world_edit_manager/proc/record_blueprint_usage(blueprint_id)
	var/blueprint_key = "[blueprint_id]"
	if(!length(blueprint_key))
		return FALSE

	if(!islist(blueprint_recent_usage))
		blueprint_recent_usage = list()

	blueprint_recent_usage_sequence++
	var/list/usage = blueprint_recent_usage[blueprint_key]
	var/use_count = islist(usage) ? text2num("[usage["use_count"]]") : 0
	blueprint_recent_usage[blueprint_key] = list(
		"last_used_rank" = blueprint_recent_usage_sequence,
		"last_used_at" = time_stamp(),
		"use_count" = max(use_count, 0) + 1,
	)
	return TRUE

/datum/world_edit_manager/proc/get_blueprint_usage_data(blueprint_id)
	if(!islist(blueprint_recent_usage))
		return null
	return blueprint_recent_usage["[blueprint_id]"]

/datum/world_edit_manager/proc/get_blueprint_entries_for_ui()
	ensure_blueprint_cache_loaded()

	var/active_blueprint_id = get_active_blueprint_id()
	var/list/ui_entries = list()
	for(var/list/entry as anything in blueprint_entries_cache)
		var/list/ui_entry = entry.Copy()
		ui_entry["active"] = "[entry["id"]]" == active_blueprint_id
		var/list/usage = get_blueprint_usage_data(entry["id"])
		ui_entry["last_used_rank"] = islist(usage) ? (usage["last_used_rank"] || 0) : 0
		ui_entry["last_used_at"] = islist(usage) ? (usage["last_used_at"] || "") : ""
		ui_entry["use_count"] = islist(usage) ? (usage["use_count"] || 0) : 0
		ui_entries += list(ui_entry)
	return ui_entries

/datum/world_edit_manager/proc/get_active_blueprint_id()
	if(current_definition?.id != "blueprint_stamp")
		return null
	var/blueprint_id = "[current_params["blueprint_id"]]"
	return length(blueprint_id) ? blueprint_id : null

/datum/world_edit_manager/proc/find_cached_blueprint_entry(blueprint_id)
	ensure_blueprint_cache_loaded()
	for(var/list/entry as anything in blueprint_entries_cache)
		if("[entry["id"]]" == "[blueprint_id]")
			return entry
	return null

/datum/world_edit_manager/proc/get_active_blueprint_revision()
	var/blueprint_id = get_active_blueprint_id()
	if(!length("[blueprint_id]"))
		return ""
	if(active_blueprint_revision_id == "[blueprint_id]")
		return active_blueprint_revision_hash || ""

	var/list/entry = find_cached_blueprint_entry(blueprint_id)
	var/file_path = islist(entry) ? entry["file_path"] : null
	active_blueprint_revision_id = "[blueprint_id]"
	active_blueprint_revision_hash = ""
	if(!length("[file_path]") || !fexists(file_path))
		return ""

	var/dmm_text = file2text(file_path)
	if(!length(dmm_text))
		return ""
	active_blueprint_revision_hash = md5(dmm_text)
	return active_blueprint_revision_hash

/datum/world_edit_manager/proc/get_active_blueprint_sprite_preview_for_ui(mob/user)
	if(!holder || !user?.client || holder != user.client)
		return null

	var/blueprint_id = get_active_blueprint_id()
	if(!length("[blueprint_id]"))
		return null

	var/list/entry = find_cached_blueprint_entry(blueprint_id)
	if(!islist(entry) || !entry["valid"])
		return GLOB.world_edit_blueprints.world_edit_build_sprite_preview_fallback("invalid")

	if(text2num("[entry["entry_count"]]") > WORLD_EDIT_BLUEPRINT_COMPACT_PREVIEW_ENTRY_THRESHOLD || "[entry["preview_mode"]]" == "compact")
		return GLOB.world_edit_blueprints.world_edit_build_sprite_preview_fallback("budget")

	var/revision_hash = get_active_blueprint_revision()
	if(!length(revision_hash))
		return GLOB.world_edit_blueprints.world_edit_build_sprite_preview_fallback("missing_revision")

	if(
		active_blueprint_sprite_preview_revision_id == "[blueprint_id]" \
		&& active_blueprint_sprite_preview_revision_hash == revision_hash \
		&& islist(active_blueprint_sprite_preview_cache)
	)
		var/asset_key = active_blueprint_sprite_preview_cache["asset_key"]
		if(length("[asset_key]"))
			SSassets.transport.send_assets(user.client, asset_key)
		return active_blueprint_sprite_preview_cache.Copy()

	var/file_path = entry["file_path"]
	if(!length("[file_path]") || !fexists(file_path))
		return GLOB.world_edit_blueprints.world_edit_build_sprite_preview_fallback("missing_file")

	var/list/load_result = GLOB.world_edit_blueprints.world_edit_load_blueprint_from_file(file_path)
	if(load_result["error"] || !islist(load_result["blueprint"]))
		return GLOB.world_edit_blueprints.world_edit_build_sprite_preview_fallback("load_failed")

	var/list/preview = GLOB.world_edit_blueprints.world_edit_build_blueprint_sprite_preview_payload(load_result["blueprint"], user.client)
	if(!islist(preview))
		preview = GLOB.world_edit_blueprints.world_edit_build_sprite_preview_fallback("render_failed")

	active_blueprint_sprite_preview_revision_id = "[blueprint_id]"
	active_blueprint_sprite_preview_revision_hash = revision_hash
	active_blueprint_sprite_preview_cache = preview.Copy()
	return preview
