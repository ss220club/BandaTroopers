/datum/rto_support_action_template/halo/engineering
	parent_type = /datum/rto_support_action_template/halo
	shared_cooldown = 360 SECONDS
	personal_cooldown = 780 SECONDS
	support_pool_cost = 1
	personal_lockout = 8 SECONDS
	category = "engineering"
	icon_state = "build"

/datum/rto_support_action_template/halo_fortification_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_fortification_drop"
	name = "Ящик с оборонительными припасами"
	description = "Сбрасывает мешки с песком, пласталь, металл, складные баррикады и оборонительные мины."
	support_pool_cost = 2
	fire_support_path = /datum/fire_support/supply_drop/halo/fortification

/datum/rto_support_action_template/halo_toolbox_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_toolbox_drop"
	name = "Ящик с инструментами"
	description = "Сбрасывает инженерные инструменты и снаряжение для полевого ремонта."
	fire_support_path = /datum/fire_support/supply_drop/halo/toolbox

/datum/rto_support_action_template/halo_breaching_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_breaching_drop"
	name = "Ящик с взрывчаткой"
	description = "Сбрасывает подрывные заряды, взрывпакеты и инструмент для форсированного входа."
	fire_support_path = /datum/fire_support/supply_drop/halo/breaching

/datum/rto_support_action_template/halo_vehicle_service_drop
	parent_type = /datum/rto_support_action_template/halo/engineering
	action_id = "halo_vehicle_service_drop"
	name = "Ящик обслуживания техники"
	description = "Сбрасывает полевой ремонтный набор и запасную батарею для ремонта техники."
	support_pool_cost = 2
	fire_support_path = /datum/fire_support/supply_drop/halo/vehicle_service
