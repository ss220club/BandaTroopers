/datum/rto_support_action_template/logistics_supply
	action_id = "logistics_supply"
	name = "Supply drop"
	description = "Долгий сброс ящика снабжения для пополнения всего отделения."
	scatter = 1
	shared_cooldown = 120 SECONDS
	personal_cooldown = 600 SECONDS
	category = "logistics"
	icon_state = "ammo"
	fire_support_path = /datum/fire_support/supply_drop
	requires_visibility_zone = FALSE
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	allow_closed_turf = FALSE

/datum/rto_support_action_template/logistics_mine_crate
	action_id = "logistics_mine_crate"
	name = "Mine crate drop"
	description = "Долгий сброс ящика с минами для подготовки позиции."
	scatter = 1
	shared_cooldown = 90 SECONDS
	personal_cooldown = 420 SECONDS
	category = "logistics"
	icon_state = "ammo"
	fire_support_path = /datum/fire_support/supply_drop/mine_crate
	requires_visibility_zone = FALSE
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	allow_closed_turf = FALSE

/datum/rto_support_action_template/logistics_mini_sentry
	action_id = "logistics_mini_sentry"
	name = "Mini-sentry drop"
	description = "Долгий сброс облегчённой мини-турели с урезанным боезапасом."
	scatter = 1
	shared_cooldown = 120 SECONDS
	personal_cooldown = 540 SECONDS
	category = "logistics"
	icon_state = "sentry"
	fire_support_path = /datum/fire_support/sentry_drop/mini
	requires_visibility_zone = FALSE
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	allow_closed_turf = FALSE

/datum/rto_support_action_template/logistics_full_sentry
	action_id = "logistics_full_sentry"
	name = "Full sentry drop"
	description = "Самый редкий сброс полноценной турели с максимальным кулдауном в пакете."
	scatter = 1
	shared_cooldown = 180 SECONDS
	personal_cooldown = 780 SECONDS
	category = "logistics"
	icon_state = "sentry"
	fire_support_path = /datum/fire_support/sentry_drop/full
	requires_visibility_zone = FALSE
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	allow_closed_turf = FALSE
