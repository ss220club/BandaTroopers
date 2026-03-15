/obj/item/clothing/head/helmet/marine/sangheili
	name = "\improper шлем сангхейли"
	desc = "Наноламинатный шлем, вдохновлённый древними доспехами сангхейли доковенантной эпохи и почти не менявший дизайн полсотни поколений. Оснащён полноценными системами связи и smart-link, позволяющими владельцу управлять своими подчинёнными и точно работать с оружием."
	icon = 'icons/halo/obj/items/clothing/covenant/helmets.dmi'
	icon_state = "sanghelmet_minor"
	item_state = "sanghelmet_minor"

	item_icons = list(
		WEAR_HEAD = 'icons/halo/mob/humans/onmob/clothing/sangheili/hat.dmi'
	)

	allowed_species_list = list(SPECIES_SANGHEILI)

	flags_marine_helmet = NO_FLAGS
	flags_inventory = NO_FLAGS
	flags_inv_hide = NO_FLAGS
	flags_atom = NO_NAME_OVERRIDE|NO_SNOW_TYPE
	built_in_visors = list()

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/head/helmet/marine/sangheili/minor
	name = "\improper шлем сангхейли-минор"

/obj/item/clothing/head/helmet/marine/sangheili/major
	name = "\improper шлем сангхейли-майор"
	icon_state = "sanghelmet_major"
	item_state = "sanghelmet_major"

	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/head/helmet/marine/sangheili/ultra
	name = "\improper шлем сангхейли-ультра"
	icon_state = "sanghelmet_ultra"
	item_state = "sanghelmet_ultra"

	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGHPLUS
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/head/helmet/marine/sangheili/zealot
	name = "\improper шлем сангхейли-зилота"
	icon_state = "sanghelmet_zealot"
	item_state = "sanghelmet_zealot"

	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH
