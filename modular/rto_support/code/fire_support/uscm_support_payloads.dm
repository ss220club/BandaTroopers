/// Additional USCM support variants used by the modular RTO package.
/datum/fire_support/supply_drop/grenade_crate
	name = "Сброс ящика гранат"
	fire_support_type = "rto_grenade_crate_drop"
	icon_state = "ammo"
	delivered = /obj/structure/largecrate/supply/explosives/grenades/less

/datum/fire_support/supply_drop/sentry_ammo
	name = "Сброс патронов для турели"
	fire_support_type = "rto_sentry_ammo_drop"
	icon_state = "ammo"
	delivered = /obj/structure/largecrate/supply/ammo/sentry

/datum/fire_support/supply_drop/uscm/shotgun/compact
	name = "Сброс дробовых патронов USCM"
	fire_support_type = "rto_uscm_shotgun_ammo_compact_drop"
	delivered = /obj/structure/largecrate/supply/ammo/shotgun/sixteen

/datum/fire_support/supply_drop/uscm/smg/compact
	name = "Сброс боеприпасов для M39 USCM"
	fire_support_type = "rto_uscm_smg_ammo_compact_drop"
	delivered = /obj/structure/largecrate/supply/ammo/m39/half

/datum/fire_support/supply_drop/uscm/sidearm/compact
	name = "Сброс боеприпасов вторичного оружия USCM"
	fire_support_type = "rto_uscm_sidearm_ammo_compact_drop"
	delivered = /obj/structure/largecrate/supply/ammo/pistol/half

/datum/fire_support/supply_drop/medical_medkits
	name = "Сброс меднаборов"
	fire_support_type = "rto_medkits_drop"
	icon_state = "medic"
	delivered = /obj/structure/largecrate/supply/medicine/medkits

/datum/fire_support/supply_drop/medical_blood
	name = "Сброс резерва крови"
	fire_support_type = "rto_blood_drop"
	icon_state = "medic"
	delivered = /obj/structure/largecrate/supply/medicine/blood

/datum/fire_support/supply_drop/medical_iv
	name = "Сброс стоек с капельницами"
	fire_support_type = "rto_iv_drop"
	icon_state = "medic"
	delivered = /obj/structure/largecrate/supply/medicine/iv

/datum/fire_support/supply_drop/medical_optable
	name = "Сброс операционного стола"
	fire_support_type = "rto_optable_drop"
	icon_state = "medic"
	delivered = /obj/structure/largecrate/supply/medicine/optable

/datum/fire_support/supply_drop/technical_fortification
	name = "Сброс комплекта укреплений"
	fire_support_type = "rto_technical_fortification_drop"
	icon_state = "build"
	delivered = /obj/structure/largecrate/supply/supplies/rto/technical_fortification

/datum/fire_support/supply_drop/technical_power
	name = "Сброс энергетического комплекта"
	fire_support_type = "rto_technical_power_drop"
	icon_state = "build"
	delivered = /obj/structure/largecrate/supply/supplies/rto/technical_power

/datum/fire_support/supply_drop/technical_recon
	name = "Сброс разведывательного комплекта"
	fire_support_type = "rto_technical_recon_drop"
	icon_state = "build"
	delivered = /obj/structure/largecrate/supply/supplies/rto/technical_recon

/datum/fire_support/supply_drop/technical_powerloader
	name = "Сброс силового погрузчика"
	fire_support_type = "rto_technical_powerloader_drop"
	icon_state = "build"
	delivered = /obj/structure/largecrate/supply/powerloader

/obj/structure/largecrate/supply/supplies/rto
	name = "ящик техподдержки RTO"
	desc = "Ящик с модульными припасами технической поддержки."
	icon_state = "chest"

/obj/structure/largecrate/supply/supplies/rto/technical_fortification
	name = "ящик укреплений"
	desc = "Ящик с металлом, пласталью и мешками с песком для быстрой полевой обороны."
	supplies = list(
		/obj/item/stack/sheet/metal/large_stack = 2,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
		/obj/item/stack/sandbags/large_stack = 2,
	)

/obj/structure/largecrate/supply/supplies/rto/technical_power
	name = "энергетический ящик"
	desc = "Ящик с генератором, прожекторами и расходниками для развёртывания питания."
	supplies = list(
		/obj/structure/machinery/power/port_gen/pacman = 1,
		/obj/structure/machinery/floodlight = 2,
		/obj/item/stack/cable_coil/yellow = 3,
		/obj/item/stack/sheet/mineral/phoron/medium_stack = 1,
	)

/obj/structure/largecrate/supply/supplies/rto/technical_recon
	name = "разведывательный ящик"
	desc = "Ящик с детекторами, средствами связи и тактическими инструментами."
	supplies = list(
		/obj/item/device/motiondetector = 2,
		/obj/item/storage/box/flare/signal = 1,
		/obj/item/map/current_map = 1,
		/obj/item/device/flashlight/combat = 1,
	)
