/obj/item/clothing/suit/marine/ruuhtian
	name = "Ruuhtian combat harness"
	desc = "A combat harness made to fit a Kig-Yar warrior."
	slowdown = SLOWDOWN_ARMOR_LIGHT

	icon = 'icons/halo/obj/items/clothing/covenant/armor.dmi'
	icon_state = "ruuhtian_minor"
	item_state = "ruuhtian_minor"

	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/ruuhtian/armor.dmi'
	)
	allowed_species_list = list(SPECIES_RUUHTIAN)
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH

	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE

/obj/item/clothing/suit/marine/ruuhtian/minor
	name = "Ruuhtian Minor combat harness"
	desc = "A standard Kig-Yar combat harness built around light nanolaminate plating."

/obj/item/clothing/suit/marine/ruuhtian/major
	name = "Ruuhtian Major combat harness"
	desc = "A reinforced Kig-Yar combat harness for veteran raiders and skirmishers."
	icon_state = "ruuhtian_major"
	item_state = "ruuhtian_major"

/obj/item/clothing/suit/marine/ruuhtian/ultra
	name = "Ruuhtian Ultra combat harness"
	desc = "A higher grade Kig-Yar combat harness for elite line veterans."
	icon_state = "ruuhtian_ultra"
	item_state = "ruuhtian_ultra"

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_MEDIUM
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
