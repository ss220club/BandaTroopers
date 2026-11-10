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

/obj/item/clothing/suit/storage/marine/m40/twe/activate_enrage(mob/living/carbon/human/H)
	var/was_active = enrage_active
	..()
	if(!was_active && enrage_active)
		H.adjustBruteLoss(-25)
		H.adjustFireLoss(-15)

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

/obj/item/weapon/shield/riot/ballistic/twe
	name = "TWE FBS-B ballistic shield"
	icon = 'icons/obj/items/weapons/weapons.dmi'
	icon_state = "ballisticshield"
	item_state = "ballisticshield"
	base_icon_state = "ballisticshield"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi',
		WEAR_BACK = 'modular/breacher/assets/icons/mob/humans/onmob/back.dmi',
	)
	item_state_slots = list(WEAR_BACK = "marine_shield")
	passive_block = 70
	readied_block = 100

/obj/item/weapon/shield/riot/ballistic/iasf
	icon = 'icons/obj/items/weapons/weapons.dmi'
	icon_state = "ballisticshield"
	item_state = "ballisticshield"
	base_icon_state = "ballisticshield"
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_1.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_1.dmi',
		WEAR_BACK = 'modular/breacher/assets/icons/mob/humans/onmob/back.dmi',
	)
	item_state_slots = list(WEAR_BACK = "marine_shield")
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
	set_skill(SKILL_SPEC_WEAPONS, SKILL_SPEC_BREACHER)
	set_skill(SKILL_MELEE_WEAPONS, SKILL_MELEE_SUPER)

/datum/skills/iasf/ship/breacher
	name = "IASF Turing Breacher"

/datum/skills/iasf/ship/breacher/New()
	. = ..()
	set_skill(SKILL_SPEC_WEAPONS, SKILL_SPEC_BREACHER)
	set_skill(SKILL_MELEE_WEAPONS, SKILL_MELEE_SUPER)

/datum/equipment_preset/uscm/rmc/mor
	skills = /datum/skills/rmc/breacher

/datum/equipment_preset/royal_marine/mortar
	skills = /datum/skills/rmc/breacher

/datum/equipment_preset/iasf/breacher
	skills = /datum/skills/iasf/ship/breacher

/obj/item/weapon/twohanded/breacher_hammer/iasf
	name = "Turing Watch N45 battle hammer"
	flags_item = TWOHANDED
	force = MELEE_FORCE_STRONG

/obj/item/weapon/twohanded/breacher_hammer/twe
	name = "TWE N45 battle hammer"
	flags_item = TWOHANDED
	force = MELEE_FORCE_STRONG

/obj/item/weapon/twohanded/breacher_hammer/iasf/attack(mob/target, mob/user)
	if(!skillcheck(user, SKILL_SPEC_WEAPONS, SKILL_SPEC_ALL) && user.skills.get_skill_level(SKILL_SPEC_WEAPONS) != SKILL_SPEC_BREACHER)
		return ..()
	. = ..()
	if(!ishuman(target) || (flags_item & TWOHANDED && !(flags_item & WIELDED)))
		return
	var/mob/living/carbon/human/victim = target
	victim.apply_effect(3, WEAKEN)
	victim.apply_damage(20, BRUTE)
