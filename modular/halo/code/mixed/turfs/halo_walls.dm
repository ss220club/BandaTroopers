/turf/closed/wall/unsc
	name = "interior ship wall"
	desc = "A bog-standard wall. It's not titanium-A, but it's pretty strong."
	icon = 'icons/halo/turf/walls/unsc.dmi'
	icon_state = "unsc"
	walltype = WALL_UNSC

/turf/closed/wall/unsc/reinforced
	name = "reinforced interior ship wall"
	icon_state = "unsc_reinforced"
	damage_cap = HEALTH_WALL_REINFORCED

/turf/closed/wall/unsc/reinforced/hull
	hull = TRUE
	icon_state = "unsc_hull"

/turf/closed/wall/unsc/reinforced/hull/titanium_a
	name = "Titanium-A hull plating"
	desc = "The best battle plating the UNSC has to offer to its fleet of ships."
	icon_state = "unsc_hull_ext"

/turf/closed/wall/voi
	name = "paneled wall"
	desc = "Cheap and replaceable paneling for average industrial needs."
	icon_state = "voiwall"
	walltype = WALL_VOI
	icon = 'icons/halo/turf/walls/voi_wall.dmi'

/turf/closed/wall/voi/reinforced
	name = "reinforced paneled wall"
	desc = "This wall is reinforced beneath cosmetic paneling."
	icon_state = "voiwall_r"
	damage_cap = HEALTH_WALL_REINFORCED

/turf/closed/wall/voi/reinforced/hull
	name = "ultra-reinforced paneled wall"
	desc = "A heavily reinforced panel wall."
	icon_state = "voiwall_h"
	hull = TRUE

/turf/closed/wall/covenant
	name = "weak nanolaminate wall"
	desc = "A lighter variation of nanolaminate."
	icon_state = "covwall"
	walltype = WALL_COV
	damage_cap = HEALTH_WALL_REINFORCED
	icon = 'icons/halo/turf/walls/cov_standard.dmi'

/turf/closed/wall/covenant/hull
	name = "nanolaminate wall"
	desc = "Standard nanolaminate structure throughout the Covenant."
	icon_state = "covwall_h"
	hull = TRUE

/turf/closed/wall/covenant/hull/ship
	name = "starship-grade nanolaminate"
	desc = "The strongest Covenant wall material."
	icon_state = "covwall_h_ext"

/turf/closed/wall/covenant/lights
	name = "weak nanolaminate wall"
	desc = "Lighter nanolaminate with low-power lights."
	icon_state = "l_covwall"
	walltype = WALL_COV_LIGHTS
	damage_cap = HEALTH_WALL_REINFORCED
	light_on = TRUE
	light_range = 3
	light_power = 0.25
	light_color = LIGHT_COLOR_PINK

/turf/closed/wall/covenant/lights/brighter
	light_range = 4
	light_power = 0.5

/turf/closed/wall/covenant/lights/hull
	name = "nanolaminate wall"
	desc = "Standard nanolaminate wall with low-power lights."
	icon_state = "l_covwall_h"
	hull = TRUE

/turf/closed/wall/covenant/lights/hull/brighter
	light_range = 4
	light_power = 0.5
