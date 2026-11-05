/obj/item/clothing/suit/storage/marine/m40/twe
	name = "TWE M40 breacher armor"
	desc = "An armored entry suit fitted with an adrenaline injector and protective dialysis system."
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/TWE.dmi'
	item_icons = list(WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/TWE.dmi')
	icon_state = "rmc_pointman"
	item_state = "rmc_pointman"

/obj/item/clothing/suit/storage/marine/m40/twe/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/TWE.dmi'
	item_icons[WEAR_JACKET] = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/TWE.dmi'
	icon_state = "rmc_pointman"
	item_state = "rmc_pointman"

/obj/item/clothing/head/helmet/marine/m40/twe
	name = "TWE M40 breacher helmet"
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons = list(WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi')
	icon_state = "rmc_helm_br"
	item_state = "rmc_helm_br"

/obj/item/clothing/head/helmet/marine/m40/twe/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	. = ..()
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/TWE.dmi'
	item_icons[WEAR_HEAD] = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/TWE.dmi'
	icon_state = "rmc_helm_br"
	item_state = "rmc_helm_br"

/obj/item/clothing/gloves/marine/m40/twe
	name = "TWE M40 breacher gloves"

/obj/item/weapon/shield/riot/montage/twe
	name = "TWE N30 breacher shield"

/obj/item/weapon/shield/riot/ballistic/iasf
	passive_block = 70
	readied_block = 100

/obj/item/weapon/shield/riot/ballistic/iasf/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'modular/breacher/assets/sound/effects/bang-bang.ogg', 25, FALSE)
			cooldown = world.time
		return
	. = ..()

/datum/skills/rmc/breacher
	name = "Royal Marine Breacher"

/datum/skills/rmc/breacher/New()
	. = ..()
	skills = skills.Copy()
	skills[SKILL_SPEC_WEAPONS] = SKILL_SPEC_BREACHER

/datum/skills/iasf/ship/breacher
	name = "IASF Turing Breacher"

/datum/skills/iasf/ship/breacher/New()
	. = ..()
	skills = skills.Copy()
	skills[SKILL_SPEC_WEAPONS] = SKILL_SPEC_BREACHER

/datum/equipment_preset/uscm/rmc/mor
	skills = /datum/skills/rmc/breacher

/datum/equipment_preset/royal_marine/mortar
	skills = /datum/skills/rmc/breacher

/datum/equipment_preset/iasf/breacher
	skills = /datum/skills/iasf/ship/breacher
