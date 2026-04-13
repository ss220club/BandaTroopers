/datum/rto_support_template/halo_medical
	parent_type = /datum/rto_support_template/halo
	template_id = "halo_medical"
	name = "Медицинские припасы"
	support_resource_mode = RTO_SUPPORT_RESOURCE_MODE_CHARGES
	support_pool_capacity = 3
	support_pool_starting_charges = 3
	support_pool_recharge_interval = 180 SECONDS
	support_pool_recharge_amount = 1
	support_pool_auto_recharge = TRUE
	support_package_lockout = 6 SECONDS
	description = "Десантный медицинский пакет с 3 общими зарядами с припасами для корпсманов и комплектами первой помощи."
	role_summary = "Снабжение корпсманов в поле: медицинские пакеты стоят 2 заряда, набор корпсмана и запас биопены стоят по 1 заряду."
	targeting_summary = "Сектор не требуется: отметьте открытую точку посадки через RTO-бинокль и вызывайте груз напрямую."
	restriction_summary = "Доступен RTO ролям UNSC и ODST. Требует открытого неба и пополняется в умеренном темпе, чтобы не превращаться в бесконечную медподдержку."
	action_template_types = list(
		/datum/rto_support_action_template/halo_medical_packets_drop,
		/datum/rto_support_action_template/halo_corpsman_kit_drop,
		/datum/rto_support_action_template/halo_biofoam_reserve_drop,
	)
	support_action_icon_state = "medic"
