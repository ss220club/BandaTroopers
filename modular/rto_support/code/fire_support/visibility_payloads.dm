/// Base payload used when an RTO deploys a visibility sector.
/datum/fire_support/rto_visibility
	name = "RTO visibility payload"
	fire_support_type = "rto_visibility_payload"
	fire_support_firer = FIRESUPPORT_ARTY
	cost = 0
	scatter_range = 0
	impact_quantity = 1
	cooldown_duration = 1
	delay_to_impact = 0.5 SECONDS
	initiate_chat_message = null
	initiate_screen_message = null
	initiate_title = null
	portrait_type = null
	initiate_sound = null
	initiate_visual = null
	start_visual = null
	start_sound = null

/datum/fire_support/rto_visibility/illumination
	name = "Illumination"
	fire_support_type = "rto_visibility_illumination"
	icon_state = "flare_mortar"
	impact_start_visual = /obj/effect/temp_visual/falling_obj/flare
	impact_sound = 'sound/weapons/fire_support/mortar_long_whistle.ogg'

/datum/fire_support/rto_visibility/illumination/do_impact(turf/target_turf)
	new /obj/item/device/flashlight/flare/on/illumination(target_turf)
	playsound(target_turf, 'sound/weapons/gun_flare.ogg', 50, 1, 4)
