/datum/round_cinematics_intro_context
	var/mob/living/carbon/human/subject
	var/obj/structure/machinery/cryopod/source_pod
	var/preview = FALSE
	var/display_name = "НЕИЗВЕСТНО"
	var/display_rank = "UNKWN"
	var/display_role = "UNKWN"
	var/display_squad = "НЕИЗВЕСТНО"
	var/display_ship = "3rd Bat. 'Banda Troopers'"
	/// Resolved affiliation for this intro
	var/datum/round_cinematics_affiliation/affiliation = null
	var/list/boot_lines = list()
	var/list/personal_lines = list()
	var/list/manifest_entries = list()
	var/list/manifest_pages = list()

/datum/round_cinematics_intro_context/New(mob/living/carbon/human/subject, obj/structure/machinery/cryopod/source_pod, preview = FALSE)
	..()
	src.subject = subject
	src.source_pod = source_pod
	src.preview = preview
	build()

/datum/round_cinematics_intro_context/proc/build()
	display_name = round_cinematics_safe_text(subject?.real_name, "НЕИЗВЕСТНО")
	display_rank = round_cinematics_human_rank(subject)
	display_role = round_cinematics_human_role(subject)
	display_squad = round_cinematics_human_squad(subject)
	display_ship = round_cinematics_human_ship_profile_label(subject)

	// Resolve affiliation for faction-specific data
	affiliation = resolve_affiliation(subject)

	var/terminal_name = affiliation?.header_label || "CRYOGENIC REVIVAL SYSTEM"
	var/terminal_header = "[html_encode(terminal_name)]: ИНИЦИАЛИЗАЦИЯ..."

	boot_lines = list(
		terminal_header,
		"ПИТАНИЕ: НОРМА",
		"ЖИЗНЕОБЕСПЕЧЕНИЕ: НОРМА",
		"ТЕРМОРЕГУЛЯЦИЯ: 36.6°C",
		"НЕЙРООТКЛИК: УСТАНОВЛЕН",
		"БИОСИГНАТУРА: ПОДТВЕРЖДЕНА",
		"СТАЗИС-ЗАМОК: СНЯТ",
		"ОПЕРАТОР: [html_encode(display_name)]",
		"КАНАЛ: [html_encode(affiliation?.security_label || "ЗАЩИЩЁННЫЙ КАНАЛ")]"
	)

	personal_lines = list(
		"ИМЯ: [html_encode(display_name)]",
		"ЗВАНИЕ: [html_encode(display_rank)]",
		"РОЛЬ: [html_encode(display_role)]",
		"ОТРЯД: [html_encode(display_squad)]",
		"СЕГМЕНТ: [html_encode(display_ship)]"
	)

	// Universal data-driven affiliation lines
	if(affiliation)
		for(var/line in affiliation.build_intro_lines())
			personal_lines += html_encode(line)

	// Final access confirmation
	personal_lines += "ДОСТУП: ПОДТВЕРЖДЁН"

	build_manifest()

/datum/round_cinematics_intro_context/proc/get_accent_color()
	return affiliation?.accent_color || "#33FF33"

/datum/round_cinematics_intro_context/proc/build_manifest()
	manifest_entries = list()
	if(!subject)
		manifest_pages = list(list("<b>СОСТАВ ОТРЯДА</b><br>НЕТ ДАННЫХ"))
		return

	for(var/mob/living/carbon/human/human as anything in GLOB.alive_human_list)
		if(!human || human == subject)
			continue
		if(is_ground_level(human.z))
			continue
		if(human.faction != subject.faction)
			continue
		if(human.assigned_squad != subject.assigned_squad)
			continue

		var/list/entry_lines = list(
			"> [html_encode(round_cinematics_human_rank(human))] [html_encode(round_cinematics_safe_text(human.real_name, "НЕИЗВЕСТНО"))]",
			"  РОЛЬ: [html_encode(round_cinematics_human_role(human))]",
			"  ОТРЯД: [html_encode(round_cinematics_human_squad(human))]",
			"  СТАТУС: [html_encode(round_cinematics_human_status(human))]"
		)
		manifest_entries += list(entry_lines.Join("<br>"))

	manifest_pages = round_cinematics_paginate(manifest_entries, ROUND_CINEMATICS_INTRO_PAGE_ROWS)
	if(!length(manifest_pages))
		manifest_pages = list(list("<b>СОСТАВ ОТРЯДА</b><br>НЕТ ДАННЫХ"))
