/datum/rto_support_action_template/mortar_he
	action_id = "mortar_he"
	name = "HE mortar"
	description = "Частый одиночный осколочно-фугасный выстрел для точечного давления."
	scatter = 4
	shared_cooldown = 4 SECONDS
	personal_cooldown = 8 SECONDS
	category = "mortar"
	icon_state = "he_mortar"
	fire_support_path = /datum/fire_support/mortar/rto_single

/datum/rto_support_action_template/mortar_smoke
	action_id = "mortar_smoke"
	name = "Smoke mortar"
	description = "Самый частый одиночный дымовой выстрел для перекрытия проходов и отхода."
	scatter = 3
	shared_cooldown = 3 SECONDS
	personal_cooldown = 5 SECONDS
	category = "mortar"
	icon_state = "smoke_mortar"
	fire_support_path = /datum/fire_support/mortar/smoke/rto_single

/datum/rto_support_action_template/mortar_incendiary
	action_id = "mortar_incendiary"
	name = "Incendiary mortar"
	description = "Одиночный зажигательный выстрел для выжигания узкой зоны и сдерживания."
	scatter = 4
	shared_cooldown = 6 SECONDS
	personal_cooldown = 10 SECONDS
	category = "mortar"
	icon_state = "incendiary_mortar"
	fire_support_path = /datum/fire_support/mortar/incendiary/rto_single
