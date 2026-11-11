/datum/weather_ss_map_holder/navalis_platform_13
	name = "Navalis Map Holder"
	warn_time = 1 MINUTES
	min_time_between_events = 30 MINUTES
	min_time_between_checks = 0
	min_check_variance = 0
	no_weather_turf_icon_state = "strata_clearsky"
	potential_weather_events = list(
		/datum/weather_event/light_rain,
		/datum/weather_event/monsoon,
	)
/datum/weather_ss_map_holder/navalis_platform_13/should_affect_area(area/A)
	return !CEILING_IS_PROTECTED(A.ceiling, CEILING_GLASS)
/datum/weather_ss_map_holder/navalis_platform_13/should_start_event()
	return TRUE
/datum/weather_event/light_rain
	name = "Tropical Storm"
	display_name = "Tropical Storm"
	length = 4 MINUTES
	turf_overlay_icon_state = "strata_storm"
	turf_overlay_alpha = 40
	effect_message = null
	damage_per_tick = 0
	has_process = TRUE
	lightning_chance = 1
	ambience = 'sound/ambience/rainforest.ogg'
	fire_smothering_strength = 1
/datum/weather_event/monsoon
	name = "Monsoon Warning"
	display_name = "Monsoon Warning"
	length = 6 MINUTES
	turf_overlay_icon_state = "strata_storm"
	turf_overlay_alpha = 115
	effect_message = null
	damage_per_tick = 0
	ambience = 'sound/ambience/varadero_storm.ogg'
	has_process = TRUE
	lightning_chance = 6
	fire_smothering_strength = 4
