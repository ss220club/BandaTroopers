/datum/rto_support_template/halo
	allowed_support_profiles = list("halo", "unsc", "odst")
	requires_visibility_zone = FALSE
	visibility_zone_name = ""
	visibility_zone_type = ""
	visibility_zone_radius = 0
	visibility_zone_duration = 0
	category = "support"
	visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	visibility_action_icon_state = "designator_mortar"

/datum/rto_support_template/halo_logistics
	parent_type = /datum/rto_support_template/halo
	template_id = "halo_logistics"
	name = "Боевые припасы"
	support_resource_mode = RTO_SUPPORT_RESOURCE_MODE_CHARGES
	support_pool_capacity = 3
	support_pool_starting_charges = 3
	support_pool_recharge_interval = 240 SECONDS
	support_pool_recharge_amount = 1
	support_pool_auto_recharge = TRUE
	support_package_lockout = 6 SECONDS
	description = "Десантный пакет снабжения с 3 общими зарядами, содержит различные наборы боеприпасов для стандартного вооружения ODST."
	role_summary = "Основной объём уходит в винтовочный боезапас. Специализированные ящики легче, чтобы пакета хватало на всю огневую группу, а не на одного бойца."
	targeting_summary = "Сектор не требуется: отметьте открытую точку посадки через RTO-бинокль и вызывайте груз напрямую."
	restriction_summary = "Доступен RTO ролям UNSC и ODST. Каждый сброс требует открытого неба и восстанавливается медленнее, чем снабжение USCM."
	action_template_types = list(
		/datum/rto_support_action_template/halo_rifle_ammo_drop,
		/datum/rto_support_action_template/halo_marksman_ammo_drop,
		/datum/rto_support_action_template/halo_pdw_ammo_drop,
		/datum/rto_support_action_template/halo_shotgun_ammo_drop,
		/datum/rto_support_action_template/halo_sniper_ammo_drop,
		/datum/rto_support_action_template/halo_spnkr_ammo_drop,
		/datum/rto_support_action_template/halo_grenadier_ammo_drop,
		/datum/rto_support_action_template/halo_emergency_weapon_drop,
	)
	support_action_icon_state = "ammo"
