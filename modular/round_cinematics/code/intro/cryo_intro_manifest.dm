/datum/round_cinematics_intro_context/proc/get_manifest_page_count()
	return length(manifest_pages)

/datum/round_cinematics_intro_context/proc/get_manifest_page(page_index)
	if(!manifest_pages || !length(manifest_pages))
		return null
	page_index = clamp(page_index, 1, length(manifest_pages))
	return manifest_pages[page_index]

