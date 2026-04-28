/obj/item/clothing/suit/marine/unsc/mjolnir
	name = "\improper Mjolnir Mk IV armour"
	desc = "A powered assault armor system built exclusively for Spartan operators."
	icon = 'icons/halo/obj/items/clothing/suits/suits_by_faction/suit_48.dmi'
	icon_state = "mk_iv"
	item_state = "mk_iv"
	valid_accessory_slots = list(ACCESSORY_SLOT_MEDAL, ACCESSORY_SLOT_DECORARMOR, ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORSHIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_PAINT, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PONCHO)
	restricted_accessory_slots = list(ACCESSORY_SLOT_DECORARMOR, ACCESSORY_SLOT_DECORGROIN, ACCESSORY_SLOT_DECORBRACER, ACCESSORY_SLOT_DECORNECK, ACCESSORY_SLOT_DECORSHIN, ACCESSORY_SLOT_M3UTILITY, ACCESSORY_SLOT_PAINT)
	item_icons = list(
		WEAR_JACKET = 'icons/halo/mob/humans/onmob/clothing/suits/suits_by_faction/suit_48.dmi'
	)
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_HANDS|BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_HANDS|BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_ARMS|BODY_FLAG_LEGS|BODY_FLAG_HANDS|BODY_FLAG_FEET
	allowed_species_list = list(SPECIES_SPARTAN)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	armor_melee = CLOTHING_ARMOR_ULTRAHIGHPLUS
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGHPLUS
	armor_laser = CLOTHING_ARMOR_ULTRAHIGHPLUS
	armor_bomb = CLOTHING_ARMOR_ULTRAHIGHPLUS
	armor_internaldamage = CLOTHING_ARMOR_ULTRAHIGHPLUS
	var/armor_status = 100

/obj/item/clothing/suit/marine/unsc/mjolnir/proc/armor_check()
	var/new_stat
	switch(armor_status)
		if(80 to 100)
			new_stat = CLOTHING_ARMOR_ULTRAHIGHPLUS
		if(50 to 80)
			new_stat = CLOTHING_ARMOR_VERYHIGH
		if(20 to 50)
			new_stat = CLOTHING_ARMOR_HIGHPLUS
		if(0 to 20)
			new_stat = CLOTHING_ARMOR_MEDIUM
	armor_melee = new_stat
	armor_bullet = new_stat
	armor_laser = new_stat
	armor_bomb = new_stat
	armor_internaldamage = new_stat
