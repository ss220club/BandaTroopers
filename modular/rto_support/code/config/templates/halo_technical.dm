/datum/rto_support_template/halo_technical
	parent_type = /datum/rto_support_template/halo
	template_id = "halo_technical"
	name = "Инженерные припасы"
	support_resource_mode = RTO_SUPPORT_RESOURCE_MODE_CHARGES
	support_pool_capacity = 3
	support_pool_starting_charges = 3
	support_pool_recharge_interval = 210 SECONDS
	support_pool_recharge_amount = 1
	support_pool_auto_recharge = TRUE
	support_package_lockout = 8 SECONDS
	description = "Десантный инженерный пакет с 3 общими зарядами для инженерии, разведки, связи и обеспечения RTO."
	role_summary = "Тяжёлые инженерные ящики стоят 2 заряда. Более лёгкие сигнальные и разведывательные вызовы стоят 1 заряд и сохраняют гибкость пакета."
	targeting_summary = "Сектор не требуется: отметьте открытую точку посадки через RTO-бинокль и вызывайте груз напрямую."
	restriction_summary = "Доступен RTO ролям UNSC и ODST. Требует открытого неба и имеет одну из самых длинных пауз среди утилитарных пакетов."
	action_template_types = list(
		/datum/rto_support_action_template/halo_toolbox_drop,
		/datum/rto_support_action_template/halo_fortification_drop,
		/datum/rto_support_action_template/halo_breaching_drop,
		/datum/rto_support_action_template/halo_vehicle_service_drop,
		/datum/rto_support_action_template/halo_signal_drop,
	)
	support_action_icon_state = "build"
