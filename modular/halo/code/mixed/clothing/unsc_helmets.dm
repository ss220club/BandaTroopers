/obj/item/clothing/head/helmet/marine/unsc
	name = "\improper CH252 helmet"
	desc = "Standard-issue helmet to the UNSC Marine Corps. Various attachment points on the helmet allow for various equipment to be fitted to the helmet."
	icon = 'icons/halo/obj/items/clothing/hats/hats_by_faction/hat_unsc.dmi'
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	built_in_visors = null
	start_down_visor_type = null
	item_icons = list(
		WEAR_HEAD = 'icons/halo/mob/humans/onmob/clothing/hats/hats_by_faction/hat_unsc.dmi',
	)

/obj/item/clothing/head/helmet/marine/unsc/pilot
	name = "\improper FH252 helmet"
	desc = "The typical helmet found used by most UNSC pilots due to its fully enclosed nature, particularly preferred by pilots in combat situations where their cockpit may end up breached."
	icon_state = "pilot"
	item_state = "pilot"
	flags_atom = ALLOWINTERNALS|NO_SNOW_TYPE|NO_NAME_OVERRIDE|BLOCKGASEFFECT|ALLOWREBREATH|ALLOWCPR

/obj/item/clothing/head/helmet/marine/unsc/police
	name = "\improper police CH252 helmet"
	desc = "Standard-issue helmet to the UNSC Marine Corps, this one given to local police and security forces across the colonies."
	icon_state = "police"
	item_state = "police"

/obj/item/clothing/head/helmet/marine/unsc/insurrection
	icon_state = "insurgent"
	item_state = "insurgent"

/obj/item/clothing/head/helmet/marine/unsc/oni
	name = "\improper ONI CH252 helmet"
	desc = "Standard-issue helmet to the UNSC Marine Corps. This variant is used by ONI Security Forces."
	icon_state = "oni"
	item_state = "oni"

/obj/item/clothing/head/helmet/marine/unsc/odst
	name = "\improper CH381 ODST helmet"
	desc = "An iconic helmet, designed for use by Orbital-Drop-Shock-Troopers of the UNSC Marine Corps."
	icon_state = "odst"
	item_state = "odst"
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_HIGH
