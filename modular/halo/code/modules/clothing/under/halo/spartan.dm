/obj/item/clothing/under/marine/spartan
	name = "\improper Mjolnir Mk IV undersuit"
	desc = "A reinforced undersuit tailored for the Mjolnir armor platform."
	icon = 'icons/halo/obj/items/clothing/undersuit.dmi'
	icon_state = "spartan"
	item_state = "spartan"
	worn_state = "spartan"
	drop_sound = "armorequip"
	allowed_species_list = list(SPECIES_SPARTAN)
	item_state_slots = list()
	item_icons = list(
		WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/uniforms_48.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)
	flags_jumpsuit = null
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_internaldamage = CLOTHING_ARMOR_VERYLOW
	armor_bio = CLOTHING_ARMOR_LOW
	armor_rad = CLOTHING_ARMOR_LOW
	fire_intensity_resistance = BURN_LEVEL_TIER_1
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROT
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS
