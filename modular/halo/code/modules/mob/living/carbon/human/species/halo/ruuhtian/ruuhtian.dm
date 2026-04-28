/datum/species/ruuhtian
	group = SPECIES_RUUHTIAN
	name = SPECIES_RUUHTIAN
	name_plural = SPECIES_RUUHTIAN
	display_name = "Kig-Yar"
	display_name_plural = "Kig-Yar"
	mob_flags = KNOWS_TECHNOLOGY
	uses_skin_color = TRUE
	flags = HAS_HARDCRIT|HAS_SKIN_COLOR|SPECIAL_BONEBREAK|NO_SHRAPNEL
	mob_inherent_traits = list(
		TRAIT_COV_TECH,
		TRAIT_SUPER_STRONG,
		TRAIT_FOREIGN_BIO,
		TRAIT_DEXTROUS,
		TRAIT_IRON_TEETH,
	)
	unarmed_type = /datum/unarmed_attack/punch/kigyar
	pain_type = /datum/pain/ruuhtian
	blood_color = BLOOD_COLOR_JACKAL
	flesh_color = BLOOD_COLOR_JACKAL

	total_health = 125
	burn_mod = 1
	brute_mod = 1
	slowdown = 0

	dodge_pool = 12
	dodge_pool_max = 12
	dodge_pool_regen = 1
	dodge_pool_regen_max = 1
	dodge_pool_regen_restoration = 0.2
	dp_regen_base_reactivation_time = 30

	icobase = 'icons/halo/mob/humans/species/ruuhtian/r_ruuhtian.dmi'
	deform = 'icons/halo/mob/humans/species/ruuhtian/r_ruuhtian.dmi'
	eye_icon = 'icons/halo/mob/humans/species/ruuhtian/eyes.dmi'
	dam_icon = 'icons/halo/mob/humans/species/ruuhtian/dam_ruuhtian.dmi'
	blood_mask = 'icons/halo/mob/humans/species/ruuhtian/blood_mask.dmi'

	has_organ = list(
		"heart" = /datum/internal_organ/heart/kigyar,
		"lungs" = /datum/internal_organ/lungs/kigyar,
		"liver" = /datum/internal_organ/liver/kigyar,
		"kidneys" = /datum/internal_organ/kidneys/kigyar,
		"brain" = /datum/internal_organ/brain/kigyar,
		"eyes" = /datum/internal_organ/eyes
	)

/datum/species/ruuhtian/post_species_loss(mob/living/carbon/human/H)
	..()
	var/datum/mob_hud/medical/advanced/advanced_hud = GLOB.huds[MOB_HUD_MEDICAL_ADVANCED]
	advanced_hud.add_to_hud(H)
	H.blood_type = pick("A+", "A-", "B+", "B-", "O-", "O+", "AB+", "AB-")
	H.h_style = "Bald"
	GLOB.kigyar_mob_list -= H
	for(var/obj/limb/limb in H.limbs)
		switch(limb.name)
			if("groin", "chest")
				limb.min_broken_damage = 40
				limb.max_damage = 200
			if("head")
				limb.min_broken_damage = 40
				limb.max_damage = 60
			if("l_hand", "r_hand", "r_foot", "l_foot")
				limb.min_broken_damage = 25
				limb.max_damage = 30
			if("r_leg", "r_arm", "l_leg", "l_arm")
				limb.min_broken_damage = 30
				limb.max_damage = 35
		limb.time_to_knit = -1

/datum/species/ruuhtian/handle_post_spawn(mob/living/carbon/human/ruuhtian)
	GLOB.alive_human_list -= ruuhtian

	ruuhtian.blood_type = "K*"
	#ifndef UNIT_TESTS
	GLOB.kigyar_mob_list += ruuhtian
	#endif
	for(var/obj/limb/limb in ruuhtian.limbs)
		switch(limb.name)
			if("groin", "chest")
				limb.min_broken_damage = 100
				limb.max_damage = 150
				limb.time_to_knit = 2 MINUTES
			if("head")
				limb.min_broken_damage = 100
				limb.max_damage = 150
				limb.time_to_knit = 1 MINUTES
			if("l_hand", "r_hand", "r_foot", "l_foot")
				limb.min_broken_damage = 150
				limb.max_damage = 150
				limb.time_to_knit = 1 MINUTES
			if("r_leg", "r_arm", "l_leg", "l_arm")
				limb.min_broken_damage = 150
				limb.max_damage = 150
				limb.time_to_knit = 1 MINUTES

	ruuhtian.set_languages(list(LANGUAGE_SANGHEILI, LANGUAGE_RUUHTIAN))
	return ..()

/datum/species/ruuhtian/get_hairstyle(style)
	var/datum/sprite_accessory/hairstyle = GLOB.ruuhtian_hair_styles_list[style]
	if(hairstyle)
		return hairstyle

	return ..()
