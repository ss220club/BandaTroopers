/obj/item/stack/medical/splint/random_amount

/obj/item/stack/medical/splint/random_amount/Initialize(mapload, ...)
	. = ..()
	amount = rand(2,5)
	update_icon()

/obj/item/stack/medical/bruise_pack/random_amount

/obj/item/stack/medical/bruise_pack/random_amount/Initialize(mapload, ...)
	. = ..()
	amount = rand(4,10)
	update_icon()


/obj/item/stack/medical/ointment/random_amount

/obj/item/stack/medical/ointment/random_amount/Initialize(mapload, ...)
	. = ..()
	amount = rand(4,10)
	update_icon()


/obj/item/reagent_container/hypospray/autoinjector/tricord/random_amount

/obj/item/reagent_container/hypospray/autoinjector/tricord/random_amount/Initialize()
	. = ..()
	var/amount = rand(1, 6)
	switch(amount)
		if(1)
			reagents.add_reagent("tricordrazine", -45)
			uses_left = 0
			update_icon()
		if(2 , 3)
			reagents.add_reagent("tricordrazine", -30)
			uses_left = 1
			update_icon()
		if(4 , 5)
			reagents.add_reagent("tricordrazine", -15)
			uses_left = 2
			update_icon()


/obj/item/reagent_container/hypospray/autoinjector/bicaridine/random_amount

/obj/item/reagent_container/hypospray/autoinjector/bicaridine/random_amount/Initialize()
	. = ..()
	var/amount = rand(1, 6)
	switch(amount)
		if(1)
			reagents.add_reagent("bicaridine", -45)
			uses_left = 0
			update_icon()
		if(2 , 3)
			reagents.add_reagent("bicaridine", -30)
			uses_left = 1
			update_icon()
		if(4 , 5)
			reagents.add_reagent("bicaridine", -15)
			uses_left = 2
			update_icon()


/obj/item/reagent_container/hypospray/autoinjector/kelotane/random_amount

/obj/item/reagent_container/hypospray/autoinjector/kelotane/random_amount/Initialize()
	. = ..()
	var/amount = rand(1, 6)
	switch(amount)
		if(1)
			reagents.add_reagent("kelotane", -45)
			uses_left = 0
			update_icon()
		if(2 , 3)
			reagents.add_reagent("kelotane", -30)
			uses_left = 1
			update_icon()
		if(4 , 5)
			reagents.add_reagent("kelotane", -15)
			uses_left = 2
			update_icon()


/obj/item/reagent_container/hypospray/autoinjector/tramadol/random_amount

/obj/item/reagent_container/hypospray/autoinjector/tramadol/random_amount/Initialize()
	. = ..()
	var/amount = rand(1, 6)
	switch(amount)
		if(1)
			reagents.add_reagent("tramadol", -45)
			uses_left = 0
			update_icon()
		if(2 , 3)
			reagents.add_reagent("tramadol", -30)
			uses_left = 1
			update_icon()
		if(4 , 5)
			reagents.add_reagent("tramadol", -15)
			uses_left = 2
			update_icon()


/obj/item/ammo_magazine/rifle/heap/empty
    current_rounds = 0

/obj/item/ammo_magazine/smartgun/empty
    current_rounds = 0

/datum/ammo/bullet/pistol/squash/heap
	name = "high-explosive armor-piercing pistol bullet"
	headshot_state = HEADSHOT_OVERLAY_HEAVY
	damage = 65
	penetration = ARMOR_PENETRATION_TIER_5

/obj/item/ammo_magazine/pistol/vp78/heap
	name = "VP78 high explosive armor piercing magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash/heap
	ammo_band_color = AMMO_BAND_COLOR_HEAP
