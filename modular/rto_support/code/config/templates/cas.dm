/datum/rto_support_template/cas
	template_id = "cas"
	name = "CAS"
	description = "Точный авиационный пакет для среднего по редкости штурмового сопровождения."
	role_summary = "Точечная авиационная поддержка для быстрого продавливания."
	targeting_summary = "Сначала разверните сектор, затем наводите авиаудары в его пределах."
	restriction_summary = "Требует открытого неба и умеренного темпа: удары идут чаще heavy, но реже mortar."
	visibility_zone_type = "Air corridor"
	visibility_zone_radius = 5
	visibility_zone_duration = 60 SECONDS
	visibility_zone_cooldown = 500 SECONDS
	category = "support"
	action_template_types = list(
		/datum/rto_support_action_template/cas_gun_run,
		/datum/rto_support_action_template/cas_laser_run,
		/datum/rto_support_action_template/cas_rocket_barrage,
	)
	visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
