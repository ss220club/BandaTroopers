/datum/species/spartan
	group = SPECIES_SPARTAN
	name = SPECIES_SPARTAN
	name_plural = "Spartans"
	display_name = "Spartan"
	display_name_plural = "Spartans"
	mob_flags = KNOWS_TECHNOLOGY
	uses_skin_color = TRUE
	flags = HAS_HARDCRIT|HAS_SKIN_COLOR|SPECIAL_BONEBREAK|NO_SHRAPNEL
	mob_inherent_traits = list(
		TRAIT_COV_TECH,
		TRAIT_SUPER_STRONG,
		TRAIT_DEXTROUS,
		TRAIT_IRON_TEETH,
	)
	unarmed_type = /datum/unarmed_attack/punch/spartan
	pain_type = /datum/pain/spartan

	total_health = 250
	burn_mod = 0.8
	brute_mod = 0.8

	darksight = 2
	default_lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	dodge_pool = 10
	dodge_pool_max = 10
	dodge_pool_regen = 1
	dodge_pool_regen_max = 1
	dodge_pool_regen_restoration = 0.1
	dp_regen_base_reactivation_time = 20

	heat_level_1 = 500
	heat_level_2 = 700
	heat_level_3 = 1000

	knock_down_reduction = 2
	stun_reduction = 2
	knock_out_reduction = 2

	icobase = 'icons/halo/mob/humans/species/spartan/r_spartan.dmi'
	deform = 'icons/halo/mob/humans/species/spartan/r_spartan.dmi'
	eye_icon = 'icons/halo/mob/humans/species/spartan/eyes.dmi'
	dam_icon = 'icons/halo/mob/humans/species/spartan/dam_spartan.dmi'
	blood_mask = 'icons/halo/mob/humans/species/spartan/blood_mask.dmi'
	icon_template = 'icons/mob/humans/template_64.dmi'

/datum/species/spartan/New()
	..()
	equip_adjust = list(
		WEAR_R_HAND = list("[NORTH]" = list("x" = 1, "y" = 4), "[EAST]" = list("x" = 1, "y" = 4), "[SOUTH]" = list("x" = -1, "y" = 4), "[WEST]" = list("x" = 1, "y" = 4)),
		WEAR_L_HAND = list("[NORTH]" = list("x" = -1, "y" = 4), "[EAST]" = list("x" = 1, "y" = 4), "[SOUTH]" = list("x" = 1, "y" = 4), "[WEST]" = list("x" = 1, "y" = 4)),
		WEAR_WAIST = list("[NORTH]" = list("x" = 0, "y" = 6), "[EAST]" = list("x" = 0, "y" = 6), "[SOUTH]" = list("x" = 0, "y" = 6), "[WEST]" = list("x" = 1, "y" = 6)),
		WEAR_HEAD = list("[NORTH]" = list("x" = 0, "y" = 10), "[EAST]" = list("x" = 0, "y" = 10), "[SOUTH]" = list("x" = 0, "y" = 10), "[WEST]" = list("x" = 0, "y" = 10)),
		WEAR_FACE = list("[NORTH]" = list("x" = 0, "y" = 10), "[EAST]" = list("x" = 1, "y" = 10), "[SOUTH]" = list("x" = 0, "y" = 10), "[WEST]" = list("x" = 1, "y" = 10)),
		WEAR_EYES = list("[NORTH]" = list("x" = 0, "y" = 10), "[EAST]" = list("x" = 1, "y" = 10), "[SOUTH]" = list("x" = 0, "y" = 10), "[WEST]" = list("x" = 1, "y" = 10)),
		WEAR_ID = list("[NORTH]" = list("x" = 0, "y" = 6), "[EAST]" = list("x" = 1, "y" = 6), "[SOUTH]" = list("x" = 0, "y" = 6), "[WEST]" = list("x" = 1, "y" = 6)),
		WEAR_BACK = list("[NORTH]" = list("x" = 0, "y" = 7), "[EAST]" = list("x" = -2, "y" = 7), "[SOUTH]" = list("x" = 0, "y" = 7), "[WEST]" = list("x" = 3, "y" = 7)),
		WEAR_J_STORE = list("[NORTH]" = list("x" = 0, "y" = 7), "[EAST]" = list("x" = -2, "y" = 7), "[SOUTH]" = list("x" = 0, "y" = 7), "[WEST]" = list("x" = 3, "y" = 7)),
		WEAR_IN_JACKET = list("[NORTH]" = list("x" = 0, "y" = 7), "[EAST]" = list("x" = 1, "y" = 7), "[SOUTH]" = list("x" = 0, "y" = 7), "[WEST]" = list("x" = 1, "y" = 7)),
		WEAR_L_EAR = list("[NORTH]" = list("x" = 0, "y" = 10), "[EAST]" = list("x" = 1, "y" = 10), "[SOUTH]" = list("x" = 0, "y" = 10), "[WEST]" = list("x" = 1, "y" = 10)),
		WEAR_R_EAR = list("[NORTH]" = list("x" = 0, "y" = 10), "[EAST]" = list("x" = 1, "y" = 10), "[SOUTH]" = list("x" = 0, "y" = 10), "[WEST]" = list("x" = 1, "y" = 10)),
		WEAR_ACCESSORY = list("[NORTH]" = list("x" = 0, "y" = 7), "[EAST]" = list("x" = 0, "y" = 7), "[SOUTH]" = list("x" = 0, "y" = 7), "[WEST]" = list("x" = 0, "y" = 7)),
		WEAR_IN_ACCESSORY = list("[NORTH]" = list("x" = 0, "y" = 7), "[EAST]" = list("x" = 0, "y" = 7), "[SOUTH]" = list("x" = 0, "y" = 7), "[WEST]" = list("x" = 0, "y" = 7)),
		WEAR_IN_HELMET = list("[NORTH]" = list("x" = 0, "y" = 10), "[EAST]" = list("x" = 0, "y" = 10), "[SOUTH]" = list("x" = 0, "y" = 10), "[WEST]" = list("x" = 0, "y" = 10))
	)

/datum/species/spartan/post_species_loss(mob/living/carbon/human/H)
	..()
	GLOB.spartan_mob_list -= H
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

/datum/species/spartan/handle_post_spawn(mob/living/carbon/human/spartan)
	GLOB.alive_human_list -= spartan
	#ifndef UNIT_TESTS
	GLOB.spartan_mob_list += spartan
	#endif
	for(var/obj/limb/limb in spartan.limbs)
		switch(limb.name)
			if("groin", "chest")
				limb.min_broken_damage = 120
				limb.max_damage = 150
				limb.time_to_knit = 2 MINUTES
			if("head")
				limb.min_broken_damage = 120
				limb.max_damage = 150
				limb.time_to_knit = 1 MINUTES
			if("l_hand", "r_hand", "r_foot", "l_foot")
				limb.min_broken_damage = 120
				limb.max_damage = 150
				limb.time_to_knit = 1 MINUTES
			if("r_leg", "r_arm", "l_leg", "l_arm")
				limb.min_broken_damage = 120
				limb.max_damage = 150
				limb.time_to_knit = 1 MINUTES

	spartan.set_languages(list(LANGUAGE_ENGLISH))
	give_action(spartan, /datum/action/human_action/activable/lunge)
	give_action(spartan, /datum/action/human_action/activable/fling)
	give_action(spartan, /datum/action/human_action/activable/punch)
	give_action(spartan, /datum/action/human_action/activable/strength)
	spartan.AddComponent(/datum/component/leaping, _leap_range = 4, _leap_cooldown = 4 SECONDS, _leaper_allow_pass_flags = PASS_OVER|PASS_MOB_THRU)
	spartan.AddComponent(/datum/component/jump, _jump_duration = 0.75 SECONDS, _jump_cooldown = 1 SECONDS, _jump_height = 32, _jump_sound = 'sound/weapons/thudswoosh.ogg', _jump_flags = JUMP_SPIN, _jumper_allow_pass_flags = PASS_OVER|PASS_MOB_THRU)
	return ..()
