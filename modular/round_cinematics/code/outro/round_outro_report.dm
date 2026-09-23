/proc/round_cinematics_status_color(status)
	switch(status)
		if("active")
			return "#44FF44"
		if("incapacitated")
			return "#FFAA44"
		if("dead")
			return "#FF4444"
		if("missing")
			return "#888888"
		else
			return "#DCE6F6"

/proc/round_cinematics_status_label(status)
	switch(status)
		if("active")
			return "В СТРОЮ"
		if("incapacitated")
			return "РАНЕН"
		if("dead")
			return "ПОГИБ"
		if("missing")
			return "НЕТ СИГНАЛА"
		else
			return "НЕИЗВЕСТНО"

/// Render a single participant record as an HTML entry block.
/// Формат: > [ЗВАНИЕ] [ИМЯ] + ОТРЯД/РОЛЬ/СТАТУС/ПРИЧИНА
/proc/round_cinematics_outro_render_record_entry(datum/round_cinematics_participant_record/record)
	if(!istype(record))
		return ""

	var/status_color = round_cinematics_status_color(record.status)
	var/status_label = round_cinematics_status_label(record.status)

	var/list/entry_lines = list(
		"> [html_encode(record.rank)] [html_encode(record.name)]",
		"  ОТРЯД: [html_encode(record.squad)]",
		"  РОЛЬ: [html_encode(record.role)]",
		"  СТАТУС: <span style='color:[status_color];'>[html_encode(status_label)]</span>",
		"  ПРИЧИНА: [html_encode(record.death_reason)]"
	)
	return entry_lines.Join("<br>")

/proc/round_cinematics_outro_render_summary_page(datum/round_cinematics_outro_context/context)
	if(!context)
		return round_cinematics_html_block("ОПЕРАЦИОННЫЙ ОТЧЕТ", "НЕТ ДАННЫХ", "#E4EAF8")
	var/color = context.outcome?.accent_color || "#E4EAF8"
	return round_cinematics_html_block("ОПЕРАЦИОННЫЙ ОТЧЕТ", round_cinematics_join_lines(context.summary_lines), color)

/proc/round_cinematics_outro_render_status_page(datum/round_cinematics_outro_context/context)
	if(!context)
		return round_cinematics_html_block("СВОДКА", "НЕТ ДАННЫХ", "#E4EAF8")

	var/datum/round_cinematics_statistics/stats = context.statistics
	if(!stats)
		return round_cinematics_html_block("СВОДКА", "НЕТ ДАННЫХ", "#E4EAF8")

	var/list/summary_counts = list(
		"ЛИЧНЫЙ СОСТАВ",
		"В СТРОЮ: [stats.personnel_active]",
		"РАНЕНЫ: [stats.personnel_incapacitated]",
		"ПОГИБЛИ: [stats.personnel_dead]",
		"НЕТ СИГНАЛА: [stats.personnel_missing]",
		"",
		"ПРОЧИЕ КОНТАКТЫ",
		"ВСЕГО УЧТЕНО: [stats.destruction_total]"
	)
	var/color = context.outcome?.accent_color || "#E4EAF8"
	return round_cinematics_html_block("СВОДКА", round_cinematics_join_lines(summary_counts), color)

/// Render a page from a list of /datum/round_cinematics_participant_record.
/proc/round_cinematics_outro_render_record_page(list/page_records, page_index, page_count, title)
	if(!islist(page_records) || !length(page_records))
		return round_cinematics_html_block(title, "НЕТ ДАННЫХ", "#E4EAF8")

	var/list/chunks = list()
	for(var/datum/round_cinematics_participant_record/record as anything in page_records)
		if(!istype(record))
			continue
		chunks += round_cinematics_outro_render_record_entry(record)

	var/full_title = page_count > 1 ? "[title] [page_index]/[page_count]" : title
	return round_cinematics_html_block(full_title, chunks.Join("<hr style='border:0;border-top:1px solid #556; margin:6px 0;'>"), "#E4EAF8")

/proc/round_cinematics_outro_render_personnel_page(list/page_entries, page_index, page_count)
	return round_cinematics_outro_render_record_page(page_entries, page_index, page_count, "ЛИЧНЫЙ СОСТАВ")

/proc/round_cinematics_outro_render_destruction_page(list/page_entries, page_index, page_count)
	// Фракционная агрегация NPC потерь
	if(!islist(page_entries) || !length(page_entries))
		return round_cinematics_html_block("ПРОЧИЕ ПОТЕРИ", "НЕТ ДАННЫХ", "#E4EAF8")

	// Группировка по faction
	var/list/by_faction = list()
	for(var/datum/round_cinematics_participant_record/record as anything in page_entries)
		if(!istype(record))
			continue
		var/faction_key = record.faction || "НЕИЗВЕСТНАЯ ФРАКЦИЯ"
		if(!by_faction[faction_key])
			by_faction[faction_key] = list(
				"total" = 0,
				"active" = 0,
				"incapacitated" = 0,
				"dead" = 0,
				"missing" = 0
			)
		var/list/faction_stats = by_faction[faction_key]
		faction_stats["total"]++
		switch(record.status)
			if("active")
				faction_stats["active"]++
			if("incapacitated")
				faction_stats["incapacitated"]++
			if("dead")
				faction_stats["dead"]++
			if("missing")
				faction_stats["missing"]++

	var/list/summary = list("ПРОЧИЕ ПОТЕРИ (НЕ-СТАРТОВЫЙ СОСТАВ)")
	for(var/faction_name in by_faction)
		var/list/fs = by_faction[faction_name]
		summary += ""
		summary += "[round_cinematics_faction_display_name(faction_name)]"
		summary += "  ВСЕГО: [fs["total"]]"
		summary += "  В СТРОЮ: [fs["active"]]"
		summary += "  РАНЕНЫ: [fs["incapacitated"]]"
		summary += "  ПОГИБЛИ: [fs["dead"]]"
		summary += "  НЕТ СИГНАЛА: [fs["missing"]]"

	return round_cinematics_html_block("ПРОЧИЕ ПОТЕРИ", round_cinematics_join_lines(summary), "#E4EAF8")

/proc/round_cinematics_outro_render_participant_page(list/page_entries, page_index, page_count)
	return round_cinematics_outro_render_record_page(page_entries, page_index, page_count, "ЛИЧНЫЙ СОСТАВ")

