/datum/rto_support_template/mortar
	template_id = "mortar"
	name = "Mortar"
	description = "Частый утилитарный пакет с одиночными HE, дымовыми и зажигательными минами."
	role_summary = "Частое давление, дым и сдерживание проходов одиночными минами."
	targeting_summary = "Сначала разверните сектор, затем спамьте одиночные миномётные выстрелы короткими интервалами, пока зона активна."
	restriction_summary = "Лучше всего работает как частая утилита по заранее выбранной зоне, где важно быстро отстреляться до длинной перезарядки."
	visibility_zone_type = "Illumination"
	visibility_zone_radius = 7
	visibility_zone_duration = 30 SECONDS
	visibility_zone_cooldown = 300 SECONDS
	category = "support"
	action_template_types = list(
		/datum/rto_support_action_template/mortar_he,
		/datum/rto_support_action_template/mortar_smoke,
		/datum/rto_support_action_template/mortar_incendiary,
	)
	visibility_support_path = /datum/fire_support/rto_visibility/illumination
