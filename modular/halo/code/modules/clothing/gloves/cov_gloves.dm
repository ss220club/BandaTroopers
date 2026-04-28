/obj/item/clothing/gloves/marine/sangheili
	name = "\improper наручи сангхейли"
	desc = "Простые латные перчатки, которые сангхейли носят поверх запястий и предплечий. Выполнены из обычных наноламинатных композитов. Благодаря точной посадке они ничуть не мешают работе воина, а если приходится полагаться на чистую силу, вполне сойдут и за импровизированное оружие."
	icon = 'icons/halo/obj/items/clothing/covenant/gloves.dmi'
	icon_state = "sanggauntlets_minor"
	item_state = "sanggauntlets_minor"

	item_icons = list(
		WEAR_HANDS = 'icons/halo/mob/humans/onmob/clothing/sangheili/gloves.dmi'
	)

	allowed_species_list = list(SPECIES_SANGHEILI)

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/gloves/marine/sangheili/minor
	name = "\improper наручи сангхейли-минора"

/obj/item/clothing/gloves/marine/sangheili/major
	name = "\improper наручи сангхейли-майора"
	icon_state = "sanggauntlets_major"
	item_state = "sanggauntlets_major"

	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/gloves/marine/sangheili/ultra
	name = "\improper наручи сангхейли-ультры"
	icon_state = "sanggauntlets_ultra"
	item_state = "sanggauntlets_ultra"

	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGHPLUS
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/gloves/marine/sangheili/zealot
	name = "\improper наручи сангхейли-зилота"
	icon_state = "sanggauntlets_zealot"
	item_state = "sanggauntlets_zealot"

	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/gloves/marine/ruuhtian
	name = "\improper Ruuhtian vambrace"
	desc = "A protected weapon-hand vambrace designed for Kig-Yar warriors."
	icon = 'icons/halo/obj/items/clothing/covenant/gloves.dmi'
	icon_state = "ruuhtian_vambrace"
	item_state = "ruuhtian_vambrace"

	item_icons = list(
		WEAR_HANDS = 'icons/halo/mob/humans/onmob/clothing/ruuhtian/gloves.dmi'
	)

	allowed_species_list = list(SPECIES_RUUHTIAN)
