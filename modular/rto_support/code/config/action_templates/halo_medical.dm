/datum/rto_support_action_template/halo/medical
	parent_type = /datum/rto_support_action_template/halo
	shared_cooldown = 240 SECONDS
	personal_cooldown = 600 SECONDS
	support_pool_cost = 1
	personal_lockout = 6 SECONDS
	category = "medical"
	icon_state = "medic"

/datum/rto_support_action_template/halo_medical_packets_drop
	parent_type = /datum/rto_support_action_template/halo/medical
	action_id = "halo_medical_packets_drop"
	name = "Медицинские пакеты"
	description = "Сбрасывает запас травмпакетов для стабилизации раненых на передовой."
	fire_support_path = /datum/fire_support/supply_drop/halo/medical_packets

/datum/rto_support_action_template/halo_corpsman_kit_drop
	parent_type = /datum/rto_support_action_template/halo/medical
	action_id = "halo_corpsman_kit_drop"
	name = "Набор корпсмана"
	description = "Сбрасывает ящик корпсмана с полностью укомплектованным медснаряжением."
	fire_support_path = /datum/fire_support/supply_drop/halo/corpsman_kit

/datum/rto_support_action_template/halo_biofoam_reserve_drop
	parent_type = /datum/rto_support_action_template/halo/medical
	action_id = "halo_biofoam_reserve_drop"
	name = "Резерв биопены"
	description = "Сбрасывает инъекторы биопены и запас средств для лечения ожогов при долгой полевой работе."
	fire_support_path = /datum/fire_support/supply_drop/halo/biofoam_reserve
