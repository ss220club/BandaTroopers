/obj/item/reagent_container/glass/barrel
	name = "канистра"
	desc = "Канистра. Вмещает до 240 единиц."
	icon = 'icons/halo/obj/objects.dmi'
	icon_state = "sbarrel"
	item_state = "sbarrel"
	matter = list("metal" = 4000)
	w_class = SIZE_LARGE
	volume = 240
	can_be_placed_into = null
	splashable = FALSE
	flags_atom = FPRINT | OPENCONTAINER

/obj/item/reagent_container/glass/barrel/water
	name = "канистра с водой"
	desc = "Полукрупная канистра, наполненная водой. Боковой носик позволяет наполнять бутылки и фляги. Не перепутайте с похожей канистрой с водородом."
	icon_state = "sbarrel_water"

/obj/item/reagent_container/glass/barrel/water/Initialize()
	. = ..()
	reagents.add_reagent("water", 240)

/obj/item/reagent_container/glass/barrel/liquidhydrogen
	name = "канистра с жидким водородом"
	desc = "Полукрупная и неудобная для переноски канистра с жидким водородом для заправки различной техники. На боку крупная предупреждающая надпись: 'НЕ ДЛЯ УПОТРЕБЛЕНИЯ'."
	icon_state = "sbarrel_hydrogen"

/obj/item/reagent_container/glass/barrel/liquidhydrogen/Initialize()
	. = ..()
	reagents.add_reagent("liquidhydrogen", 240)
