/datum/species
	var/dam_icon = 'icons/mob/humans/dam_human.dmi'
	var/eye_icon = 'icons/mob/humans/onmob/human_face.dmi'
	var/dodge_pool = 5
	var/dodge_pool_max = 5
	var/dodge_pool_regen = 0.2
	var/dodge_pool_regen_max = 0.2
	var/dodge_pool_regen_restoration = 0.1
	var/dp_regen_base_reactivation_time = 30

/obj/item/clothing
	var/list/allowed_species_list = list(SPECIES_HUMAN, SPECIES_YAUTJA)
