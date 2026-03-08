/datum/rto_support_template/logistics
	template_id = "logistics"
	name = "Logistics"
	description = "Логистический пакет для сброса грузов, мин и турелей без сектора наведения."
	role_summary = "Утилитарная поддержка для снабжения и быстрого развёртывания позиции."
	targeting_summary = "Зона не требуется: вооружите нужный сброс и наведите точку через RTO-бинокль."
	restriction_summary = "Все сбросы требуют открытую площадку и доступное небо над целью."
	requires_visibility_zone = FALSE
	visibility_zone_name = ""
	visibility_zone_type = ""
	visibility_zone_radius = 0
	visibility_zone_duration = 0
	visibility_zone_cooldown = 0
	category = "support"
	action_template_types = list(
		/datum/rto_support_action_template/logistics_supply,
		/datum/rto_support_action_template/logistics_mine_crate,
		/datum/rto_support_action_template/logistics_mini_sentry,
		/datum/rto_support_action_template/logistics_full_sentry,
	)
	visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	visibility_action_icon_state = "designator_swap_mortar"
