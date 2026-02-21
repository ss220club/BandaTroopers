/obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter/arachnid
	splatter_type = "csplatter"
	color = BLOOD_COLOR_ARACHNID

/mob/living/carbon/xenomorph/arachnid/handle_blood_splatter(splatter_dir, duration)
	var/color_override
	if(special_blood)
		var/datum/reagent/D = GLOB.chemical_reagents_list[special_blood]
		if(D)
			color_override = D.color
	new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter/arachnid(loc, splatter_dir, duration, color_override)

// Нету симпл энималов, но мало ли:
// /mob/living/simple_animal/hostile/alien/arachnid/bullet_act(obj/projectile/P)
// 	. = ..()
// 	if(P.damage)
// 		var/splatter_dir = get_dir(P.starting, loc)//loc is the xeno getting hit, P.starting is the turf of where the projectile got spawned
// 		new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter/arachnid(loc, splatter_dir)
// 		if(prob(SOME_SPLATTER_ROAR_CHANCE))
// 			roar_emote()
