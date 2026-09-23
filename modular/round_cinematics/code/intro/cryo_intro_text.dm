/datum/round_cinematics_intro_context/proc/build_boot_text()
	return round_cinematics_html_block("ПРОТОКОЛ ПРОБУЖДЕНИЯ", round_cinematics_join_lines(boot_lines), get_accent_color())

/datum/round_cinematics_intro_context/proc/build_personal_text()
	return round_cinematics_html_block("ЛИЧНОЕ ДЕЛО", round_cinematics_join_lines(personal_lines), get_accent_color())

/datum/round_cinematics_intro_context/proc/build_manifest_text(page_index)
	if(!manifest_pages || !length(manifest_pages))
		return round_cinematics_html_block("СОСТАВ ОТРЯДА", "НЕТ ДАННЫХ", get_accent_color())

	page_index = clamp(page_index, 1, length(manifest_pages))
	var/list/page_entries = manifest_pages[page_index]
	var/list/chunks = list()
	for(var/entry in page_entries)
		chunks += "[entry]"
	return round_cinematics_html_block("СОСТАВ ОТРЯДА [page_index]/[length(manifest_pages)]", chunks.Join("<hr style='border:0;border-top:1px solid #556; margin:6px 0;'>"), get_accent_color())

