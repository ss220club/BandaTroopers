/obj/item/clothing/suit/marine/unsc
	name = "\improper бронежилет M52B"
	desc = "Штатная броня корпуса морской пехоты ККОН. Комплект M52B поступил на вооружение к 2531 году для войны людей с Ковенантом и обеспечивал лучшую защиту от плазменного оружия по сравнению со старыми моделями."
	icon = 'icons/halo/obj/items/clothing/suits/suits_by_faction/suit_unsc.dmi'
	icon_state = "m52b"
	item_state = "m52b"
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/suits/suits_by_faction/suit_unsc.dmi',
	)
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL, ACCESSORY_SLOT_DECORARMOR, ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORSHIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PONCHO)
	restricted_accessory_slots = list(ACCESSORY_SLOT_DECORARMOR, ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_DECORSHIN, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PAINT)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/prop/prop_gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/storage/bible,
		/obj/item/attachable/bayonet,
		/obj/item/storage/backpack/general_belt,
		/obj/item/storage/large_holster/machete,
		/obj/item/storage/belt/gun/type47,
		/obj/item/storage/belt/gun/m4a3,
		/obj/item/storage/belt/gun/m44,
		/obj/item/storage/belt/gun/smartpistol,
		/obj/item/storage/belt/gun/flaregun,
		/obj/item/device/motiondetector,
		/obj/item/device/walkman,
		/obj/item/storage/belt/gun/m39,
		/obj/item/storage/belt/gun/xm51,
		/obj/item/storage/belt/gun/m6,
		/obj/item/storage/belt/gun/m7,
	)

/obj/item/clothing/suit/marine/unsc/oni
	name = "\improper бронежилет ONI M52B"
	desc = "Модифицированный вариант стандартной брони M52B, используемый силами безопасности ONI. Существенно не отличается по защите от штатного образца, но окрашен в чёрный цвет."
	icon_state = "oni_sec"
	item_state = "oni_sec"

/obj/item/clothing/suit/marine/unsc/police
	name = "\improper баллистическая броня полиции RD90"
	desc = "Более старая модель брони M52B, обозначаемая местной полицией и силами безопасности как RD90. Пусть она и не столь удобна, для большинства пользователей она всё ещё справляется со своей задачей, а вдобавок лучше защищает от ударов в ближнем бою."
	icon = 'icons/halo/obj/items/clothing/suits/suits_by_faction/suit_unsc.dmi'
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL, ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PONCHO)
	restricted_accessory_slots = list(ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PAINT)
	icon_state = "police"
	item_state = "police"
	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/suits/suits_by_faction/suit_unsc.dmi',
	)
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW

/obj/item/clothing/suit/marine/unsc/insurrection
	icon_state = "insurgent"
	item_state = "insurgent"
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW

/obj/item/clothing/suit/marine/unsc/odst
	name = "\improper M70DT ODST BDU"
	desc = "Полный комплект брони ODST, проще называемый Battle Dress Uniform. Рассчитан на самые разные условия: от вакуума с собственным запасом воздуха на 30 минут до грохота SOEIV и хаоса поля боя. Этот BDU готов ко всему."
	icon_state = "odst"
	item_state = "odst"
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/unsc/odst/insurrection
	name = "\improper трофейный комплект M70DT ODST BDU"
	icon_state = "odst_insurgent"
	item_state = "odst_insurgent"
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PONCHO)
	restricted_accessory_slots = list(ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_DECORBRACER)
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
