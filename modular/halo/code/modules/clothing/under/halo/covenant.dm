/obj/item/clothing/under/marine/covenant
	name = "undersuit"
	desc = "Covenant undersuit. You shouldn't see this."
	icon = 'icons/halo/obj/items/clothing/covenant/under.dmi'
	icon_state = "sangheili_undersuit"
	item_state = "sangheili_undersuit"
	worn_state = "sangheili_undersuit"
	flags_jumpsuit = null
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	drop_sound = "armorequip"
	allowed_species_list = list()

/obj/item/clothing/under/marine/covenant/sangheili
	name = "\improper Sangheili undersuit"
	desc = "A high-tech jumpsuit that for the most part conforms to the users body. Interlaced with nanolaminate armoring, it provides ample protection for how flexible it is - enabling the wearer to be aggressive while still protecting themselves. Advanced magnetic projectors on the undersuit are capable of locking armor to it with considerable force."
	icon = 'icons/halo/obj/items/clothing/covenant/under.dmi'
	icon_state = "sangheili_undersuit"
	item_state = "sangheili_undersuit"
	worn_state = "sangheili_undersuit"
	flags_jumpsuit = UNIFORM_SLEEVE_ROLLABLE
	drop_sound = "armorequip"
	allowed_species_list = list(SPECIES_SANGHEILI)
	item_state_slots = list()

	item_icons = list(
		WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/sangheili/uniforms.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)

/obj/item/clothing/under/marine/covenant/unggoy
	name = "\improper Unggoy magnetic webbing"
	desc = "Issued to Unggoy as a part of their combat kit, the webbing is a series of straps fitted with magnetic locks intended to be worn with their issued armor. Although uncomfortable and doesn't prevent any armor chafing, Unggoy skin is pretty tough."

	icon_state = "unggoy_harness"
	item_state = "unggoy_harness"
	worn_state = "unggoy_harness"
	flags_jumpsuit = null
	drop_sound = "armorequip"
	allowed_species_list = list(SPECIES_UNGGOY)
	item_state_slots = list()

	item_icons = list(
		WEAR_BODY = 'icons/halo/mob/humans/onmob/clothing/unggoy/uniforms.dmi',
		WEAR_L_HAND = 'icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)
