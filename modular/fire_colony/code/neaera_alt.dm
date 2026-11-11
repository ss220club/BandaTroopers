// Fire Colony's pink Neaera from CM-PVE PR #203.
/datum/species/monkey/neaera_alt
	parent_type = /datum/species/monkey/neaera
	name = "Pink Neaera"
	name_plural = "Pink Neaera"
	icobase = 'icons/mob/humans/species/monkeys/r_neaera_alt.dmi'
	deform = 'icons/mob/humans/species/monkeys/r_neaera_alt.dmi'

/mob/living/carbon/human/neaera_alt/Initialize(mapload)
	. = ..(mapload, new_species = "Pink Neaera")
