/obj/item/clothing/gloves/marine/army
	name = "army combat gloves"
	desc = "Standard issue army tactical gloves. It reads: 'knit by Army Widows Association'."


/obj/item/clothing/head/beret/cm/black/army
	name = "US Army beret"
	desc = "The proud tradition of the US Army 1st Air Cav using black berets for their troopers is maintained since the 20th century."


/obj/item/clothing/head/cavalry
	name = "\improper US cavalry hat"
	desc = "Also known as Cavalry Stetson, this hat is a symbol of tradition and remembrence of heroism that is ongoing from as far as 19th century. Even though cavalry divison had cashed in its horses for choppers, choppers for dropships, and gone tear-assing around space, looking for the shit."
	icon_state = "cavalry"
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/UA.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/UA.dmi'
	)


/obj/item/clothing/head/helmet/marine/rto/army
	name = "\improper Personal body armor system helmet"
	desc = "The personal body armor system helmet is the standard issue combat helmet for the US Army. Selected over the M12 pattern helmet during combat trials, it offers allegedly superior protection compared to the M12 series, at over four times the cost. Though its far more uncomfortable to wear."
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/UA.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/UA.dmi',
	)
	icon_state = "army_helmet"
	item_state = "army_helmet"
	specialty = "Personal body armor system"

/obj/item/clothing/head/helmet/marine/rto/army/engi
	built_in_visors = list(new /obj/item/device/helmet_visor, new /obj/item/device/helmet_visor/welding_visor)

/obj/item/clothing/head/helmet/marine/rto/army/medic
	built_in_visors = list(new /obj/item/device/helmet_visor, new /obj/item/device/helmet_visor/medical/advanced)


/obj/item/clothing/mask/neckerchief/yellow
	icon_state = "neckerchief_bravo"
	item_state = "neckerchief_bravo"
	original_state = "neckerchief_bravo"


/obj/item/clothing/suit/storage/marine/light/synvest/army
	name = "\improper Synthetic Body Armor System"
	desc = "This is a variant of the Personnel Body Armor System, it has been modified extensively to be used by US Army Synthetics. It offers light protection, maximum mobility and more internal storage than its USCM counterpart. The cost of this item could outfit an entire squad of USCM Marines, but you are worth this cost."
	icon_state = "VL_syn_army"
	icon = 'icons/obj/items/clothing/suits/suits_by_faction/UA.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_faction/UA.dmi'
	)
	flags_atom = NO_NAME_OVERRIDE
	armor_melee = CLOTHING_ARMOR_VERYLOW
	armor_bullet = CLOTHING_ARMOR_MEDIUMLOW
	armor_laser = CLOTHING_ARMOR_VERYLOW
	armor_bomb = CLOTHING_ARMOR_VERYLOW
	armor_bio = CLOTHING_ARMOR_VERYLOW
	armor_rad = CLOTHING_ARMOR_MEDIUMLOW
	storage_slots = 4


/obj/item/device/radio/headset/almayer/sof/survivor_army
	parent_type = /obj/item/device/radio/headset/distress/army
	name = "US Army headset"
	desc = "Issued exclusively to Army troopers."
	icon_state = "arm_headset"

/obj/item/reagent_container/food/drinks/flask/marine/army
	name = "\improper US Army flask"
	icon_state = "flask_army"
	item_state = "flask_army"
	desc = "A metal flask embossed with the US Army logo and probably filled with a slurry of water, motor oil, and medicinal alcohol. Albiet, higher quality motor oil compared to Marine rations."


/obj/item/storage/backpack/molle/army
	name = "\improper M1 MOLLE Satchel"
	desc = "Tactical satchel manufactured by one of the Alphatech subsidiaries. Very lightweight beltbag variant that utilizes UA standard MOLLE fastening systems. Standard issue pack for US army troopers."
	icon_state = "MOLLEbeltbag"
	item_state = "MOLLEbeltbag"
	worn_accessible = TRUE
	max_storage_space = 15

/obj/item/storage/backpack/molle/backpack/army
	name = "M2 MOLLE Backpack"
	desc = "A lightweight backpack with UA standard MOLLE fastening systems."
	icon_state = "MOLLEbackpack"
	item_state = "MOLLEbackpack"
	max_storage_space = 21


/obj/item/storage/belt/gun/mateba/cmateba/black
	flags_atom = NO_NAME_OVERRIDE

/obj/item/storage/box/mre/us_army
	name = "\improper US Army MRE"
	desc = "A Meal, Ready-to-Eat. A single-meal combat ration designed to provide a soldier with enough nutrients for a day of strenuous work. Its expiration date is at least is a few years ahead of your expected service time."

/obj/item/weapon/gun/pistol/vp78/army
	starting_attachment_types = list(/obj/item/attachable/extended_barrel, /obj/item/attachable/reflex)

/obj/item/weapon/gun/pistol/vp78/army/heap
	current_mag = /obj/item/ammo_magazine/pistol/vp78/heap


/obj/item/weapon/gun/rifle/m41a/army
	current_mag = /obj/item/ammo_magazine/rifle/heap/empty
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/attached_gun/grenade, /obj/item/attachable/stock/rifle/collapsible)

/obj/item/weapon/gun/rifle/m41a/army/full
	current_mag = /obj/item/ammo_magazine/rifle/heap


/obj/item/weapon/gun/smg/m39/army
	starting_attachment_types = list(/obj/item/attachable/stock/smg, /obj/item/attachable/reflex, /obj/item/attachable/extended_barrel, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/smg/m39/army/heap
	current_mag = /obj/item/ammo_magazine/smg/m39/heap


/obj/item/clothing/suit/storage/jacket/marine/service/green
	icon = 'icons/obj/items/clothing/suits/suits_by_map/desert.dmi'
	item_icons = list(
		WEAR_JACKET = 'icons/mob/humans/onmob/clothing/suits/suits_by_map/desert.dmi'
	)
	initial_icon_state = "coat_officer"
