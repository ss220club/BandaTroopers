/obj/item/clothing/head/helmet/marine/veteran/clf
	name = "repainted M10 pattern helmet"
	desc = "A M10 helmet repainted and modified for the Colonial Liberation Front."
	icon = 'modular/clf/icons/navalis_clf_helmets.dmi'
	icon_state = "clf_m10"
	item_state = "clf_m10"
	item_state_slots = list(WEAR_HEAD = "clf_m10")
	item_icons = list(WEAR_HEAD = 'modular/clf/icons/navalis_clf_helmets_worn.dmi')
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_HIGH
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROT
	clothing_traits = list(TRAIT_EAR_PROTECTION)
	flags_atom = NO_NAME_OVERRIDE

/obj/item/clothing/head/helmet/marine/veteran/clf/heavy
	name = "repainted reinforced M10 pattern helmet"
	desc = "An M10 helmet reinforced and repainted for the Colonial Liberation Front."
	icon_state = "clf_heavy_m10"
	item_state = "clf_heavy_m10"
	item_state_slots = list(WEAR_HEAD = "clf_heavy_m10")
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/head/helmet/marine/veteran/clf/riot
	name = "repainted RC6 helmet"
	desc = "An RC6 helmet repainted and modified for the Colonial Liberation Front."
	icon_state = "clf_riot"
	item_state = "clf_riot"
	item_state_slots = list(WEAR_HEAD = "clf_riot")

/obj/item/clothing/glasses/mgoggles/clf_riot_shield
	name = "custom made riot shield"
	desc = "An RC6 riot shield reinforced and repainted for the Colonial Liberation Front."
	icon = 'modular/clf/icons/navalis_riot_shield.dmi'
	icon_state = "riot_shield_clf"
	item_state = "riot_shield_clf"
	item_icons = list(WEAR_AS_GARB = 'modular/clf/icons/navalis_riot_shield_worn.dmi')
	active_icon_state = "riot_shield_clf"
	inactive_icon_state = "riot_shield_clf"
	activated = TRUE
	flags_equip_slot = null
