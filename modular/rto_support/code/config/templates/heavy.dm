/datum/rto_support_template/heavy
	template_id = "heavy"
	name = "Heavy Strike"
	description = "Редкий тяжёлый пакет с малым разбросом, длинным окном удара и умеренно долгими интервалами между вызовами."
	role_summary = "Редкие и дорогие тяжёлые удары по приоритетным целям."
	targeting_summary = "Сначала разверните длинное окно сектора, затем подтверждайте тяжёлый удар по уже разведанной точке."
	restriction_summary = "Требует открытого неба и длинного, но дорогого окна работы с интервалами в среднем 10-20 секунд между ударами."
	visibility_zone_type = "Strike window"
	visibility_zone_radius = 4
	visibility_zone_duration = 80 SECONDS
	visibility_zone_cooldown = 800 SECONDS
	category = "support"
	action_template_types = list(
		/datum/rto_support_action_template/heavy_missile,
		/datum/rto_support_action_template/heavy_napalm,
	)
	visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
