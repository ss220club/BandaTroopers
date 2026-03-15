/obj/item/reagent_container/glass/beaker/unsc
	name = "\improper медицинский флакон"
	desc = "Медицинский флакон приличного объёма, обычно встречающийся в военных аптечках."
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
	name = "\improper медицинский флакон трикордразина"
	desc = "Прозрачный глянцевый флакон трикордразина. Используется для лечения повреждений широкого спектра. Передозировка при 30 ед."
	label_color = "brown"
	maptext_label = "Tc"

/obj/item/reagent_container/glass/beaker/unsc/tricordrazine/Initialize()
	. = ..()
	reagents.add_reagent("tricordrazine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/bicaridine
	name = "\improper медицинский флакон бикаридина"
	desc = "Прозрачный глянцевый флакон бикаридина. Используется для лечения ожогов. Передозировка при 30 ед."
	label_color = "red"
	maptext_label = "Bi"

/obj/item/reagent_container/glass/beaker/unsc/bicaridine/Initialize()
	. = ..()
	reagents.add_reagent("bicaridine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/kelotane
	name = "\improper медицинский флакон келотана"
	desc = "Прозрачный глянцевый флакон келотана. Используется для лечения ожогов. Передозировка при 30 ед."
	label_color = "orange"
	maptext_label = "Kl"

/obj/item/reagent_container/glass/beaker/unsc/kelotane/Initialize()
	. = ..()
	reagents.add_reagent("kelotane", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/tramadol
	name = "\improper медицинский флакон трамадола"
	desc = "Прозрачный глянцевый флакон трамадола. Умеренно эффективное обезболивающее. Передозировка при 30 ед."
	label_color = "pink"
	maptext_label = "Tr"

/obj/item/reagent_container/glass/beaker/unsc/tramadol/Initialize()
	. = ..()
	reagents.add_reagent("tramadol", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/morphine
	name = "\improper медицинский флакон морфина"
	desc = "Прозрачный глянцевый флакон морфина. Менее эффективен, чем оксикодон, но метаболизируется медленнее. Передозировка при 20 ед."
	label_color = "pink-black"
	maptext_label = "Mr"

/obj/item/reagent_container/glass/beaker/unsc/morphine/Initialize()
	. = ..()
	reagents.add_reagent("morphine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/oxycodone
	name = "\improper медицинский флакон оксикодона"
	desc = "Прозрачный глянцевый флакон оксикодона. Одно из лучших доступных обезболивающих. Передозировка при 20 ед."
	label_color = "teal"
	maptext_label = "Ox"

/obj/item/reagent_container/glass/beaker/unsc/oxycodone/Initialize()
	. = ..()
	reagents.add_reagent("oxycodone", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dexalin
	name = "\improper медицинский флакон дексалина"
	desc = "Прозрачный глянцевый флакон дексалина. Используется для лечения кислородного голодания. Передозировка при 30 ед."
	label_color = "blue"
	maptext_label = "Dx"

/obj/item/reagent_container/glass/beaker/unsc/dexalin/Initialize()
	. = ..()
	reagents.add_reagent("dexalin", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dexplus
	name = "\improper медицинский флакон дексалин+"
	desc = "Прозрачный глянцевый флакон дексалин+. Быстро лечит кислородное голодание и эффективнее обычного дексалина. Передозировка при 15 ед."
	label_color = "l_blue"
	maptext_label = "D+"

/obj/item/reagent_container/glass/beaker/unsc/dexplus/Initialize()
	. = ..()
	reagents.add_reagent("dexalinp", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dylovene
	name = "\improper медицинский флакон диловена"
	desc = "Прозрачный глянцевый флакон диловена. Используется для лечения токсического урона. Передозировка при 30 ед."
	label_color = "vomit"
	maptext_label = "Dy"

/obj/item/reagent_container/glass/beaker/unsc/dylovene/Initialize()
	. = ..()
	reagents.add_reagent("anti_toxin", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/inaprovaline
	name = "\improper медицинский флакон инапровалина"
	desc = "Прозрачный глянцевый флакон инапровалина. Помогает сдерживать дыхательную недостаточность в критическом состоянии. Передозировка при 60 ед."
	label_color = "magenta"
	maptext_label = "In"

/obj/item/reagent_container/glass/beaker/unsc/inaprovaline/Initialize()
	. = ..()
	reagents.add_reagent("inaprovaline", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/peridaxon
	name = "\improper медицинский флакон перидаксона"
	desc = "Прозрачный глянцевый флакон перидаксона. Сдерживает последствия повреждения органов, но не лечит их напрямую. Передозировка при 15 ед."
	label_color = "gray"
	maptext_label = "Pr"

/obj/item/reagent_container/glass/beaker/unsc/peridaxon/Initialize()
	. = ..()
	reagents.add_reagent("peridaxon", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/dermaline
	name = "\improper медицинский флакон дермалина"
	desc = "Прозрачный глянцевый флакон дермалина. Лечит ожоги лучше, чем Optican BurnGuard. Передозировка при 15 ед."
	label_color = "orange-black"
	maptext_label = "De"

/obj/item/reagent_container/glass/beaker/unsc/dermaline/Initialize()
	. = ..()
	reagents.add_reagent("dermaline", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/meralyne
	name = "\improper медицинский флакон мералина"
	desc = "Прозрачный глянцевый флакон мералина. Лечит физические травмы лучше, чем бикаридин. Передозировка при 15 ед."
	label_color = "red-black"
	maptext_label = "Me"

/obj/item/reagent_container/glass/beaker/unsc/meralyne/Initialize()
	. = ..()
	reagents.add_reagent("meralyne", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/iron
	name = "\improper медицинский флакон железа"
	desc = "Прозрачный глянцевый флакон железа. Полезен при кровопотере. Передозировка при 30 ед."
	label_color = "label"
	maptext_label = "Fe"

/obj/item/reagent_container/glass/beaker/unsc/iron/Initialize()
	. = ..()
	reagents.add_reagent("iron", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/chorotazine
	name = "\improper медицинский флакон хоротазина"
	label_color = "purple"
	desc = "Прозрачный глянцевый флакон хоротазина. Полезен при повреждениях мозга и глаз. Передозировка при 15 ед."
	maptext_label = "Cr"

/obj/item/reagent_container/glass/beaker/unsc/chorotazine/Initialize()
	. = ..()
	reagents.add_reagent("chorotazine", 240)
	update_icon()

/obj/item/reagent_container/glass/beaker/unsc/nitrogenwater
	name = "\improper медицинский флакон азотной воды"
	label_color = "purple"
	desc = "Прозрачный глянцевый флакон азотной воды. Полезен при передозировке трамадолом."
	maptext_label = "NW"

/obj/item/reagent_container/glass/beaker/unsc/nitrogenwater/Initialize()
	. = ..()
	reagents.add_reagent("nitrogen", 120)
	reagents.add_reagent("water", 120)
	update_icon()
