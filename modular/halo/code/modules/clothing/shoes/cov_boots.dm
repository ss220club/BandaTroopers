/obj/item/clothing/shoes/sangheili
	name = "боевые сапоги сангхейли"
	desc = "Пара подогнанных поножей с сопутствующими сапогами. Хотя внешний наноламинатный слой может намекать на жёсткость и неудобство, внутренняя подкладка неожиданно мягкая, отводит влагу и пассивно регулирует температуру. Благодаря этому воин думает об искусстве убивать, а не о том, как сильно ему надоела маршировка."
	icon = 'icons/halo/obj/items/clothing/covenant/shoes.dmi'
	icon_state = "sangboots_minor"
	item_state = "sangboots_minor"

	drop_sound = "armorequip"

	item_icons = list(
		WEAR_FEET = 'icons/halo/mob/humans/onmob/clothing/sangheili/shoes.dmi'
	)

	allowed_species_list = list(SPECIES_SANGHEILI)

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/shoes/sangheili/minor
	name = "боевые сапоги сангхейли-минора"

/obj/item/clothing/shoes/sangheili/major
	name = "боевые сапоги сангхейли-майора"
	icon_state = "sangboots_major"
	item_state = "sangboots_major"

	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/shoes/sangheili/ultra
	name = "боевые сапоги сангхейли-ультры"
	icon_state = "sangboots_ultra"
	item_state = "sangboots_ultra"

	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGHPLUS
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/shoes/sangheili/zealot
	name = "боевые сапоги сангхейли-зилота"
	icon_state = "sangboots_zealot"
	item_state = "sangboots_zealot"

	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/shoes/ruuhtian
	name = "Ruuhtian foot guards"
	desc = "Foot guards fitted to Kig-Yar combat harnesses."
	icon = 'icons/halo/obj/items/clothing/covenant/shoes.dmi'
	icon_state = "ruuhtian_minor"
	item_state = "ruuhtian_minor"

	drop_sound = "armorequip"

	item_icons = list(
		WEAR_FEET = 'icons/halo/mob/humans/onmob/clothing/ruuhtian/shoes.dmi'
	)

	allowed_species_list = list(SPECIES_RUUHTIAN)

/obj/item/clothing/shoes/ruuhtian/minor
	name = "Ruuhtian Minor foot guards"
	desc = "Standard foot guards that preserve the mobility of a Kig-Yar skirmisher."
	icon_state = "ruuhtian_minor"
	item_state = "ruuhtian_minor"

/obj/item/clothing/shoes/ruuhtian/major
	name = "Ruuhtian Major foot guards"
	desc = "Veteran foot guards that preserve the mobility of a Kig-Yar skirmisher."
	icon_state = "ruuhtian_major"
	item_state = "ruuhtian_minor"

/obj/item/clothing/shoes/ruuhtian/ultra
	name = "Ruuhtian Ultra foot guards"
	desc = "Elite foot guards that preserve the mobility of a Kig-Yar skirmisher."
	icon_state = "ruuhtian_ultra"
	item_state = "ruuhtian_minor"

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM
