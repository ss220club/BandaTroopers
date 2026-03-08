/obj/item/clothing/suit/marine/unsc
	name = "\improper M52B body armor"
	desc = "Standard-issue to the UNSC Marine Corps, the M52B armor entered service by 2531 for use in the Human Covenant war, coming with improved protection against plasma-based projectiles compared to older models."
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
	name = "\improper ONI M52B body armor"
	desc = "A modified variant of the standard M52B armor, used by ONI security forces. Has no significant differences in protection compared to standard issue armor, but is painted black."
	icon_state = "oni_sec"
	item_state = "oni_sec"

/obj/item/clothing/suit/marine/unsc/police
	name = "\improper police RD90 ballistic armor"
	desc = "An older model of the M52B body armor, designated as the RD90 by local police and security forces. Whilst not as comfortable, it still does the job for most of its users, and has added protection against melee attacks."
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
	desc = "The sum total of the ODST armor complex, simply called 'Battle-Dress-Uniform'. Designed for several environments, be it in vacuum with its 30 minutes of air, in the racket of a SOEIV or the clamour of a battlefield; this BDU is ready for it all."
	icon_state = "odst"
	item_state = "odst"
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_HIGH

/obj/item/clothing/suit/marine/unsc/odst/insurrection
	name = "\improper scavenged M70DT ODST BDU"
	icon_state = "odst_insurgent"
	item_state = "odst_insurgent"
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PONCHO)
	restricted_accessory_slots = list(ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_DECORBRACER)
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_MEDIUMHIGH
