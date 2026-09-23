/*
 * Explicit case orchestration for the World Edit Visual Workbench.
 *
 * This datum deliberately does only two things:
 *   1. deserialize JSON text into a /datum/world_edit_visual_case,
 *   2. write a structured load-level error if the case cannot even be parsed.
 *
 * It does not create directories with shell calls. BYOND shell execution can be
 * unreliable during early headless DreamDaemon startup, and the tool-side
 * runner script owns creating parent directories before runtime.
 */
/datum/world_edit_visual_workbench
	var/inbox_dir = WORLD_EDIT_VISUAL_DEFAULT_INBOX
	var/out_dir = WORLD_EDIT_VISUAL_DEFAULT_OUT

GLOBAL_DATUM_INIT(world_edit_visual_workbench, /datum/world_edit_visual_workbench, new)

/datum/world_edit_visual_workbench/proc/process_inbox_once()
	ensure_runtime_directories()
	var/list/files = flist("[inbox_dir]/")
	if(!islist(files))
		return 0
	var/processed_count = 0
	for(var/file_name in files)
		var/file_text = "[file_name]"
		if(!is_json_case_file(file_text))
			continue
		var/path = "[inbox_dir]/[file_text]"
		var/text = file2text(path)
		process_case_file(file_text, text)
		processed_count++
	return processed_count

/datum/world_edit_visual_workbench/proc/ensure_runtime_directories()
	world_edit_visual_ensure_directory(inbox_dir)
	world_edit_visual_ensure_directory(out_dir)

/datum/world_edit_visual_workbench/proc/is_json_case_file(file_name)
	var/file_text = "[file_name]"
	var/suffix = ".json"
	return copytext(file_text, max(1, length(file_text) - length(suffix) + 1)) == suffix

/datum/world_edit_visual_workbench/proc/process_case_file(file_name, text)
	var/path = "[inbox_dir]/[file_name]"
	var/fallback_case_id = sanitize_filename(replacetext("[file_name]", ".json", ""))
	if(!length(text))
		write_error_for_file(fallback_case_id, "empty_case_file", "Case file is empty.")
		return
	var/datum/world_edit_visual_case/case = new
	var/list/load_result = case.load_from_json_text(text)
	if(load_result["error"])
		write_error_for_file(fallback_case_id, load_result["error"], load_result["message"])
		return
	case.source_file = path
	case.out_dir = "[out_dir]/[case.id]"
	case.execute()

/datum/world_edit_visual_workbench/proc/write_error_for_file(case_id, code, message = null)
	var/safe_id = sanitize_filename("[case_id]")
	if(!length(safe_id))
		safe_id = "invalid_case"
	var/error_dir = "[out_dir]/[safe_id]"
	var/list/directory_result = world_edit_visual_ensure_directory(error_dir)
	if(directory_result["error"])
		var/error_code = directory_result["error"]
		log_world("World Edit Visual Workbench failed to create output directory [error_dir]: [error_code]")
		return
	var/list/error = list(
		"schema" = "world_edit_visual_report/v1",
		"case_id" = safe_id,
		"generator" = "unknown",
		"status" = WORLD_EDIT_VISUAL_STATUS_ERROR,
		"stage" = WORLD_EDIT_VISUAL_STAGE_LOAD_CASE,
		"error" = "[code]",
		"errors" = list(list(
			"code" = "[code]",
			"message" = length("[message]") ? "[message]" : "[code]",
			"severity" = "error",
			"stage" = WORLD_EDIT_VISUAL_STAGE_LOAD_CASE,
		)),
		"warnings" = list(),
	)
	var/path = "[error_dir]/report.json"
	fdel(path)
	rustg_file_write(json_encode(error), path)

/proc/run_world_edit_visual_acceptance_from_params()
	if(!GLOB.world_edit_visual_workbench)
		GLOB.world_edit_visual_workbench = new
	var/datum/world_edit_visual_workbench/workbench = GLOB.world_edit_visual_workbench
	if(world.params["world_edit_acceptance_inbox"])
		workbench.inbox_dir = "[world.params["world_edit_acceptance_inbox"]]"
	if(world.params["world_edit_acceptance_out"])
		workbench.out_dir = "[world.params["world_edit_acceptance_out"]]"
	var/processed_count = workbench.process_inbox_once()
	log_world("World Edit Visual acceptance processed [processed_count] case(s).")

/proc/world_edit_visual_ensure_directory(path)
	var/clean_path = replacetext("[path]", "\\", "/")
	if(!length(clean_path))
		return list("error" = "empty_directory_path")
	// Keep runtime writes inside simple repository-relative paths. This is a
	// dev tool, but it still handles user-edited JSON filenames and output ids.
	if(findtext(clean_path, "..") || findtext(clean_path, " ") || findtext(clean_path, "\"") || findtext(clean_path, "'") || findtext(clean_path, "&") || findtext(clean_path, "|") || findtext(clean_path, ";"))
		return list("error" = "unsafe_directory_path")
	if(fexists("[clean_path]/"))
		return list("ok" = TRUE)
	// Directory creation is intentionally delegated to Python/batch tooling.
	// Returning a structured error is safer than blocking startup on shelleo().
	return list("error" = "directory_missing", "path" = clean_path)
