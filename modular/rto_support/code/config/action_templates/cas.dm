/datum/rto_support_action_template/cas_gun_run
	action_id = "cas_gun_run"
	name = "Gun run"
	description = "Быстрый пушечный проход по узкому коридору."
	scatter = 3
	shared_cooldown = 12 SECONDS
	personal_cooldown = 16 SECONDS
	category = "cas"
	icon_state = "gau"
	fire_support_path = /datum/fire_support/gau
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH

/datum/rto_support_action_template/cas_laser_run
	action_id = "cas_laser_run"
	name = "Laser run"
	description = "Точный лазерный проход с малым разбросом."
	scatter = 2
	shared_cooldown = 16 SECONDS
	personal_cooldown = 22 SECONDS
	category = "cas"
	icon_state = "laser"
	fire_support_path = /datum/fire_support/laser
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH

/datum/rto_support_action_template/cas_rocket_barrage
	action_id = "cas_rocket_barrage"
	name = "Rocket barrage"
	description = "Ракетный заход с умеренным разбросом."
	scatter = 4
	shared_cooldown = 22 SECONDS
	personal_cooldown = 36 SECONDS
	category = "cas"
	icon_state = "rockets"
	fire_support_path = /datum/fire_support/rockets
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
