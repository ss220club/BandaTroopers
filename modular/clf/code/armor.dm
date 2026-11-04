/obj/item/clothing/under/colonist/clf
	icon = 'modular/clf/icons/clf_uniform.dmi'
	item_icons = list(WEAR_BODY = 'modular/clf/icons/clf_uniform_worn.dmi')

/obj/item/clothing/suit/storage/militia
	storage_slots = 2

/obj/item/clothing/suit/storage/militia/full
	icon_state = "rebel_armor"
	item_state = "rebel_armor_full"
	item_state_slots = list(WEAR_JACKET = "rebel_armor_full")

/obj/item/clothing/suit/storage/militia/smartgun
	icon_state = "rebel_armor"
	item_state = "clf_harness"
	item_state_slots = list(WEAR_JACKET = "clf_harness")

/obj/item/clothing/suit/storage/jacket/marine/rmc/service/clf_wy/officer_armor
	name = "\improper Бронежилет лидера CLF-WP"
	desc = "Тактический бронежилет командного состава WY, переделанный под нужды Ячейки CLF-WP."
	icon = 'modular/clf/icons/clf_wy_suit.dmi'
	item_icons = list(WEAR_JACKET = 'modular/clf/icons/clf_wy_suit_worn.dmi')
	icon_state = "clf_wy_officer_armor"
	item_state = "clf_wy_officer_armor"
	item_state_slots = list(WEAR_JACKET = "clf_wy_officer_armor")
	uniform_restricted = null
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_MEDIUMLOW
	armor_rad = CLOTHING_ARMOR_LOW

/obj/item/clothing/suit/storage/jacket/marine/rmc/service/clf_wy/raincover
	name = "\improper Плащ-палатка CLF-WP"
	desc = "Дождевик из плотной ткани, используемый рядовым составом Ячейки CLF-WP."
	icon = 'modular/clf/icons/clf_wy_suit.dmi'
	item_icons = list(WEAR_JACKET = 'modular/clf/icons/clf_wy_suit_worn.dmi')
	icon_state = "clf_raincover"
	item_state = "clf_raincover"
	item_state_slots = list(WEAR_JACKET = "clf_raincover")
	uniform_restricted = null
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_LOW
	armor_laser = CLOTHING_ARMOR_LOW
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_LOW
	armor_bio = CLOTHING_ARMOR_LOW
	armor_rad = CLOTHING_ARMOR_LOW

/obj/item/clothing/suit/storage/marine/veteran/ua_riot/clf
	item_icons = list(WEAR_JACKET = 'modular/clf/icons/clf_suit_worn.dmi')

/obj/item/clothing/head/helmet/marine/veteran/ua_riot/clf
	name = "CLF reinforced helmet"
	item_state = "ua_riot"
	item_state_slots = list(WEAR_HEAD = "ua_riot")
