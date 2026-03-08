/datum/rto_support_action_template/heavy_missile
	action_id = "heavy_missile"
	name = "Missile strike"
	description = "Редкий мощный ракетный удар по точке."
	scatter = 3
	shared_cooldown = 18 SECONDS
	personal_cooldown = 24 SECONDS
	category = "heavy"
	icon_state = "missile"
	fire_support_path = /datum/fire_support/missile
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH

/datum/rto_support_action_template/heavy_napalm
	action_id = "heavy_napalm"
	name = "Napalm strike"
	description = "Напалмовый удар по компактной зоне."
	scatter = 2
	shared_cooldown = 16 SECONDS
	personal_cooldown = 20 SECONDS
	category = "heavy"
	icon_state = "napalm_missile"
	fire_support_path = /datum/fire_support/missile/napalm
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
