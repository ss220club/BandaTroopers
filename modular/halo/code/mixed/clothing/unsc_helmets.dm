/obj/item/clothing/head/helmet/marine/unsc
	name = "\improper CH252 helmet"
	desc = "Штатный шлем корпуса морской пехоты ККОН. Различные точки крепления позволяют устанавливать на него дополнительное оборудование."
	icon = 'icons/halo/obj/items/clothing/hats/hats_by_faction/hat_unsc.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	built_in_visors = null
	start_down_visor_type = null
	item_icons = list(
		WEAR_HEAD = 'icons/halo/mob/humans/onmob/clothing/hats/hats_by_faction/hat_unsc.dmi',
	)

/obj/item/clothing/head/helmet/marine/unsc/Initialize(mapload, list/new_protection)
	. = ..()
	AddComponent(/datum/component/halo_motion_sensor_manager)

/obj/item/clothing/head/helmet/marine/unsc/pilot
	name = "\improper FH252 helmet"
	desc = "Типичный шлем большинства пилотов ККОН благодаря полностью закрытой конструкции. Особенно ценится в боевых условиях, когда кабина может оказаться разгерметизированной."
	icon_state = "pilot"
	item_state = "pilot"
	flags_atom = ALLOWINTERNALS|NO_SNOW_TYPE|NO_NAME_OVERRIDE|BLOCKGASEFFECT|ALLOWREBREATH|ALLOWCPR

/obj/item/clothing/head/helmet/marine/unsc/police
	name = "\improper police CH252 helmet"
	desc = "Штатный шлем корпуса морской пехоты ККОН, этот вариант выдаётся местной полиции и силам безопасности по колониям."
	icon_state = "police"
	item_state = "police"

/obj/item/clothing/head/helmet/marine/unsc/insurrection
	icon_state = "insurgent"
	item_state = "insurgent"

/obj/item/clothing/head/helmet/marine/unsc/oni
	name = "\improper ONI CH252 helmet"
	desc = "Штатный шлем корпуса морской пехоты ККОН. Этот вариант используется силами безопасности ONI."
	icon_state = "oni"
	item_state = "oni"

/obj/item/clothing/head/helmet/marine/unsc/odst
	name = "\improper CH381 ODST helmet"
	desc = "Культовый шлем, разработанный для бойцов Orbital Drop Shock Troopers корпуса морской пехоты ККОН."
	icon_state = "odst"
	item_state = "odst"
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_HIGH
