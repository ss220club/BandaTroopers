/obj/item/clothing/mob_can_equip(mob/M, slot, disable_warning = 0)
	if(!..())
		return FALSE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(H.species.name in allowed_species_list))
			if(!disable_warning)
				to_chat(M, SPAN_WARNING("You cannot equip \the [src] as a [H.species]."))
			return FALSE
	return TRUE

/mob/living/carbon/proc/halo_throw_carbon(mob/living/carbon/target, direction, distance, speed = SPEED_VERY_FAST, shake_camera = TRUE, immobilize = TRUE)
	if(!direction)
		direction = get_dir(src, target)
	var/turf/target_destination = get_ranged_target_turf(target, direction, distance)

	var/list/end_throw_callbacks
	if(immobilize)
		end_throw_callbacks = list(CALLBACK(src, PROC_REF(halo_throw_carbon_end), target))
		ADD_TRAIT(target, TRAIT_IMMOBILIZED, XENO_THROW_TRAIT)

	target.throw_atom(target_destination, distance, speed, src, spin = TRUE, end_throw_callbacks = end_throw_callbacks)
	if(shake_camera)
		shake_camera(target, 10, 1)

/mob/living/carbon/proc/halo_throw_carbon_end(mob/living/carbon/target)
	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, XENO_THROW_TRAIT)
