/obj/item/storage/box/guncase/heavy/sniper/iasf
	name = "Turing Watch F903A1 sniper kit"
	desc = "A case containing an F903A1 marksman rifle, specialist magazines, and a reconnaissance vest."
	storage_slots = 11
	can_hold = list(
		/obj/item/weapon/gun/rifle/rmc_f90/scope,
		/obj/item/ammo_magazine/rifle/rmc_f90/marksman,
		/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper,
	)

/obj/item/storage/box/guncase/heavy/sniper/iasf/fill_preset_inventory()
	new /obj/item/weapon/gun/rifle/rmc_f90/scope/ap(src)
	for(var/i in 1 to 3)
		new /obj/item/ammo_magazine/rifle/rmc_f90/marksman/incendiary(src)
		new /obj/item/ammo_magazine/rifle/rmc_f90/marksman/impact(src)
		new /obj/item/ammo_magazine/rifle/rmc_f90/marksman/flak(src)
	new /obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper(src)

/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper
	name = "Turing Watch reconnaissance vest"
	desc = "A lightweight Goshawk vest with a short-duration concealment field."
	var/mob/living/carbon/human/cloaked_wearer
	var/cloak_cooldown_until = 0
	var/cloak_previous_alpha = 255

/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper/verb/toggle_cloak()
	set name = "Activate concealment"
	set category = "Object"
	set src in usr
	var/mob/living/carbon/human/wearer = usr
	if(!istype(wearer) || wearer.wear_suit != src)
		return
	if(cloaked_wearer)
		end_cloak()
		return
	if(world.time < cloak_cooldown_until)
		to_chat(wearer, SPAN_WARNING("Concealment is recharging."))
		return
	cloaked_wearer = wearer
	cloak_previous_alpha = wearer.alpha
	wearer.alpha = 20
	ADD_TRAIT(wearer, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
	cloak_cooldown_until = world.time + 3 MINUTES
	addtimer(CALLBACK(src, PROC_REF(end_cloak)), 50 SECONDS)
	to_chat(wearer, SPAN_NOTICE("The concealment field activates for 50 seconds."))

/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper/proc/end_cloak()
	if(!cloaked_wearer)
		return
	var/mob/living/carbon/human/wearer = cloaked_wearer
	cloaked_wearer = null
	if(QDELETED(wearer))
		return
	REMOVE_TRAIT(wearer, TRAIT_CLOAKED, TRAIT_SOURCE_EQUIPMENT(WEAR_JACKET))
	wearer.alpha = cloak_previous_alpha
	to_chat(wearer, SPAN_NOTICE("The concealment field fades."))

/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper/dropped(mob/user)
	end_cloak()
	return ..()

/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper/equipped(mob/user, slot)
	if(slot != WEAR_JACKET)
		end_cloak()
	return ..()

/obj/item/clothing/suit/storage/marine/veteran/royal_marine/light/iasf/sniper/Destroy()
	end_cloak()
	return ..()
