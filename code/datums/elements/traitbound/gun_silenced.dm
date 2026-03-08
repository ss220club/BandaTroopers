/datum/element/traitbound/gun_silenced
	associated_trait = TRAIT_GUN_SILENCED
	compatible_types = list(/obj/item/weapon/gun)

/datum/element/traitbound/gun_silenced/Attach(datum/target)
	. = ..()
	if(. & ELEMENT_INCOMPATIBLE)
		return
	var/obj/item/weapon/gun/G = target
	G.flags_gun_features |= GUN_SILENCED
	G.muzzleflash_iconstate = null
	if(!HAS_TRAIT_FROM(G, TRAIT_GUN_SILENCED, TRAIT_SOURCE_INHERENT))
		var/obj/item/attachable/suppressor/silencer = G.attachments["muzzle"] // SS220 EDIT: allow suppressor-specific silenced fire key
		if(istype(silencer))
			G.fire_sound = silencer.new_fire_sound
		else
			G.fire_sound = "gun_silenced"

/datum/element/traitbound/gun_silenced/Detach(datum/target)
	var/obj/item/weapon/gun/G = target
	G.flags_gun_features &= ~GUN_SILENCED
	G.muzzleflash_iconstate = initial(G.muzzleflash_iconstate) // SS220 EDIT: restore correct muzzle flash icon state var
	G.fire_sound = initial(G.fire_sound)
	return ..()
