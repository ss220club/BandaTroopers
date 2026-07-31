/datum/world_edit_generation_context
	var/headless = TRUE
	var/visual_workbench = TRUE
	var/seed = 0
	var/generator_id = ""
	var/list/config = list()
	var/list/shape = list()
	var/list/anchors = list()
	var/record_undo = TRUE
	var/record_history = FALSE
	var/write_admin_logs = FALSE
	var/collect_debug = TRUE
	var/collect_profile = FALSE
	var/datum/world_edit_visual_canvas/canvas
	var/datum/world_edit_visual_profiler/profiler
	var/list/debug = list()
	var/list/metrics = list()
	var/list/emitted_changes = list()
