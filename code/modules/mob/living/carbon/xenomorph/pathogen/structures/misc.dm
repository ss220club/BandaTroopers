/datum/construction_template/xenomorph/patho_plasma
	name = PATHOGEN_STRUCTURE_PLASMA
	description = "Gives out small bursts of plasma, replenishing the reserves of the sisters around it."
	build_type = /obj/effect/alien/resin/special/plasma_tree/pathogen
	build_icon_state = "recovery_plasma"

/datum/construction_template/xenomorph/patho_plasma/set_structure_image()
	build_icon = 'icons/mob/pathogen/pathogen_structures64x64.dmi'

/datum/construction_template/xenomorph/patho_recovery
	name = PATHOGEN_STRUCTURE_RECOVERY
	description = "Hastily recovers the strength of sisters resting around it."
	build_type = /obj/effect/alien/resin/special/recovery/pathogen
	build_icon_state = "recovery"

/datum/construction_template/xenomorph/patho_recovery/set_structure_image()
	build_icon = 'icons/mob/pathogen/pathogen_structures64x64.dmi'

/obj/effect/alien/resin/matriarch_cocoon
	name = PATHOGEN_STRUCTURE_COCOON_BIG
	var/hivenumber = XENO_HIVE_PATHOGEN
	desc = "A huge pulsating cocoon."
	icon = 'icons/mob/pathogen/MatriarchHatchery.dmi'
	icon_state = "growing" // "static", "hatching" and "hatched" are also available
	health = 4000
	pixel_x = -48
	pixel_y = -64
	density = TRUE
	plane = FLOOR_PLANE
