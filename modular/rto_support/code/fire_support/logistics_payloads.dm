/// Logistics support variants used by the modular RTO package.
/datum/fire_support/supply_drop/mine_crate
	name = "Mine crate drop"
	fire_support_type = "rto_mine_crate_drop"
	icon_state = "ammo"
	delivered = /obj/structure/largecrate/supply/explosives/mines

/datum/fire_support/sentry_drop/full
	name = "Full sentry drop"
	fire_support_type = "rto_full_sentry_drop"
	icon_state = "sentry"
	sentry_type = /obj/structure/machinery/defenses/sentry/launchable

/datum/fire_support/sentry_drop/mini
	name = "Mini-sentry drop"
	fire_support_type = "rto_mini_sentry_drop"
	icon_state = "sentry"
	sentry_type = /obj/structure/machinery/defenses/sentry/launchable/mini

/obj/item/ammo_magazine/sentry/dropped/mini
	max_rounds = 60
	max_inherent_rounds = 180

/obj/structure/machinery/defenses/sentry/launchable/mini
	name = "\improper UA 512-M rapid deploy mini sentry"
	desc = "Быстроразворачиваемая мини-турель с уменьшенным магазином и меньшим внутренним запасом."
	ammo = new /obj/item/ammo_magazine/sentry/dropped/mini
	defense_type = "Mini"
	fire_delay = 0.15 SECONDS
	health = 150
	health_max = 150
	damage_mult = 0.4
	density = FALSE
	disassemble_time = 0.75 SECONDS
	handheld_type = /obj/item/defenses/handheld/sentry/mini
	composite_icon = FALSE
	firing_sound = null
