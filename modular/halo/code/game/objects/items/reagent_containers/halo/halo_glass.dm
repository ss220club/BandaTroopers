/obj/item/reagent_container/glass/beaker/unsc
	name = "\improper medical vial"
	desc = "A decently sized medical vial typically found in military first-aid applications."
	icon = 'icons/halo/obj/items/chemistry.dmi'
	icon_state = "bottle"
	ground_offset_x = 9
	ground_offset_y = 8

	var/label_color
	volume = 240
	amount_per_transfer_from_this = 15

	var/display_maptext = TRUE
	var/maptext_label
	maptext_height = 16
	maptext_width = 16
	maptext_x = 18
	maptext_y = 3

/obj/item/reagent_container/glass/beaker/unsc/update_icon()
	overlays.Cut()

	if(reagents && reagents.total_volume)
		var/image/filling = image('icons/halo/obj/items/chemistry.dmi', src, "[icon_state]10")

		var/percent = floor((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9) filling.icon_state = "[icon_state]-10"
			if(10 to 24) filling.icon_state = "[icon_state]10"
			if(25 to 49) filling.icon_state = "[icon_state]25"
			if(50 to 74) filling.icon_state = "[icon_state]50"
			if(75 to 79) filling.icon_state = "[icon_state]75"
			if(80 to 90) filling.icon_state = "[icon_state]80"
			if(91 to INFINITY) filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
	if(label_color)
		var/image/label = image('icons/halo/obj/items/chemistry.dmi', src, label_color)
		overlays += label

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid
	if((isstorage(loc) || ismob(loc)) && display_maptext)
		maptext = SPAN_LANGCHAT("[maptext_label]")
	else
		maptext = ""

/obj/item/reagent_container/glass/beaker/unsc/equipped()
	..()
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/on_exit_storage()
	..()
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dropped()
	..()
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/tricordrazine
	name = "\improper tricordrazine medical vial"
	desc = "A clear, glossy vial of tricordrazine. Used to treat general damage across the board. Overdoses at 30u."
	label_color = "brown"
	maptext_label = "Tc"

/obj/item/reagent_container/glass/beaker/unsc/tricordrazine/Initialize()
	. = ..()
	reagents.add_reagent("tricordrazine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/bicaridine
	name = "\improper bicaridine medical vial"
	desc = "A clear, glossy vial of bicaridine. Used to treat burn damage. Overdoses at 30u."
	label_color = "red"
	maptext_label = "Bi"

/obj/item/reagent_container/glass/beaker/unsc/bicaridine/Initialize()
	. = ..()
	reagents.add_reagent("bicaridine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/kelotane
	name = "\improper kelotane medical vial"
	desc = "A clear, glossy vial of kelotane. Used to treat burn damage. Overdoses at 30u."
	label_color = "orange"
	maptext_label = "Kl"

/obj/item/reagent_container/glass/beaker/unsc/kelotane/Initialize()
	. = ..()
	reagents.add_reagent("kelotane", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/tramadol
	name = "\improper tramadol medical vial"
	desc = "A clear, glossy vial of tramadol. A moderately effective painkiller. Overdoses at 30u."
	label_color = "pink"
	maptext_label = "Tr"

/obj/item/reagent_container/glass/beaker/unsc/tramadol/Initialize()
	. = ..()
	reagents.add_reagent("tramadol", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/morphine
	name = "\improper morphine medical vial"
	desc = "A clear, glossy vial of morphine. Less effective than oxycodone, but metabolizes slower. Overdoses at 20u."
	label_color = "pink-black"
	maptext_label = "Mr"

/obj/item/reagent_container/glass/beaker/unsc/morphine/Initialize()
	. = ..()
	reagents.add_reagent("morphine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/oxycodone
	name = "\improper oxycodone medical vial"
	desc = "A clear, glossy vial of oxycodone. One of the best painkillers available. Overdoses at 20u."
	label_color = "teal"
	maptext_label = "Ox"

/obj/item/reagent_container/glass/beaker/unsc/oxycodone/Initialize()
	. = ..()
	reagents.add_reagent("oxycodone", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dexalin
	name = "\improper dexalin medical vial"
	desc = "A clear, glossy vial of dexalin. Used to treat oxygen damage. Overdoses at 30u."
	label_color = "blue"
	maptext_label = "Dx"

/obj/item/reagent_container/glass/beaker/unsc/dexalin/Initialize()
	. = ..()
	reagents.add_reagent("dexalin", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dexplus
	name = "\improper dexalin+ medical vial"
	desc = "A clear, glossy vial of dexalin+. Used to treat oxygen damage quickly and is superior to regular dexalin. Overdoses at 15u."
	label_color = "l_blue"
	maptext_label = "D+"

/obj/item/reagent_container/glass/beaker/unsc/dexplus/Initialize()
	. = ..()
	reagents.add_reagent("dexalinp", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dylovene
	name = "\improper dylovene medical vial"
	desc = "A clear, glossy vial of dylovene. Used to treat toxin damage. Overdoses at 30u."
	label_color = "vomit"
	maptext_label = "Dy"

/obj/item/reagent_container/glass/beaker/unsc/dylovene/Initialize()
	. = ..()
	reagents.add_reagent("anti_toxin", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/inaprovaline
	name = "\improper inaprovaline medical vial"
	desc = "A clear, glossy vial of inaprovaline. Used to stave off respiratory failure when in critical condition. Overdoses at 60u."
	label_color = "magenta"
	maptext_label = "In"

/obj/item/reagent_container/glass/beaker/unsc/inaprovaline/Initialize()
	. = ..()
	reagents.add_reagent("inaprovaline", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/peridaxon
	name = "\improper peridaxon medical vial"
	desc = "A clear, glossy vial of peridaxon. Used to stave off the effects of organ damage, though doesn't heal it. Overdoses at 15u."
	label_color = "gray"
	maptext_label = "Pr"

/obj/item/reagent_container/glass/beaker/unsc/peridaxon/Initialize()
	. = ..()
	reagents.add_reagent("peridaxon", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dermaline
	name = "\improper dermaline medical vial"
	desc = "A clear, glossy vial of dermaline. Better than Optican BurnGuard at treating burns. overdoses at 15u."
	label_color = "orange-black"
	maptext_label = "De"

/obj/item/reagent_container/glass/beaker/unsc/dermaline/Initialize()
	. = ..()
	reagents.add_reagent("dermaline", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/meralyne
	name = "\improper meralyne medical vial"
	desc = "A clear, glossy vial of meralyne. Better than Bicaridine at treating brute. Overdoses at 15u."
	label_color = "red-black"
	maptext_label = "Me"

/obj/item/reagent_container/glass/beaker/unsc/meralyne/Initialize()
	. = ..()
	reagents.add_reagent("meralyne", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/iron
	name = "\improper iron medical vial"
	desc = "A clear, glossy vial of iron. Useful to treat blood loss. Overdoses at 30u."
	label_color = "label"
	maptext_label = "Fe"

/obj/item/reagent_container/glass/beaker/unsc/iron/Initialize()
	. = ..()
	reagents.add_reagent("iron", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/chorotazine
	name = "\improper chorotazine medical vial"
	label_color = "purple"
	desc = "A clear, glossy vial of chorotazine. Useful to treat brain and eye damage. Overdoses at 15u."
	maptext_label = "Cr"

/obj/item/reagent_container/glass/beaker/unsc/chorotazine/Initialize()
	. = ..()
	reagents.add_reagent("chorotazine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/nitrogenwater
	name = "\improper nitrogen-water medical vial"
	label_color = "purple"
	desc = "A clear, glossy vial of nitrogen-water. Useful to treat tramadol overdoses."
	maptext_label = "NW"

/obj/item/reagent_container/glass/beaker/unsc/nitrogenwater/Initialize()
	. = ..()
	reagents.add_reagent("nitrogen", 120)
	reagents.add_reagent("water", 120)
	update_icon()

