/datum/human_ai_brain/proc/invalidate_runtime_extension_caches()
	if(hascall(src, "modular_invalidate_runtime_extension_caches"))
		call(src, "modular_invalidate_runtime_extension_caches")()

/datum/human_ai_brain/proc/notify_inventory_runtime_changed()
	invalidate_runtime_extension_caches()

/datum/human_ai_brain/proc/should_suspend_nearby_item_search(queued_projectiles_override = null)
	if(hascall(src, "modular_should_suspend_nearby_item_search"))
		return call(src, "modular_should_suspend_nearby_item_search")(queued_projectiles_override)
	return FALSE

/datum/human_ai_brain/proc/should_defer_ranged_fire(atom/threat = null, queued_projectiles_override = null)
	if(hascall(src, "modular_should_defer_ranged_fire"))
		return call(src, "modular_should_defer_ranged_fire")(threat, queued_projectiles_override)
	return FALSE

/datum/human_ai_brain/proc/notify_cover_scan_started()
	if(hascall(src, "modular_on_cover_scan_started"))
		call(src, "modular_on_cover_scan_started")()
