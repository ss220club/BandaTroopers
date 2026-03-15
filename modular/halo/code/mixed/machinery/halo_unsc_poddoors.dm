/obj/structure/machinery/door/poddoor/two_tile/four_tile/halo
	name = "тяжёлая взрывозащитная дверь"
	desc = "Тяжёлая взрывозащитная дверь, предназначенная для герметизации зон или обеспечения широкого прохода через один вход."
	icon = 'icons/halo/obj/structures/doors/podlocks/4x1_blast_hor.dmi'
	icon_state = "blast1"
	base_icon_state = "blast"

/obj/structure/machinery/door/poddoor/two_tile/four_tile/vertical/halo
	name = "тяжёлая взрывозащитная дверь"
	desc = "Тяжёлая взрывозащитная дверь, предназначенная для герметизации зон или обеспечения широкого прохода через один вход."
	icon = 'icons/halo/obj/structures/doors/podlocks/4x1_blast_vert.dmi'
	icon_state = "blast1"
	base_icon_state = "blast"

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile
	name = "тяжёлая взрывозащитная дверь"
	desc = "Тяжёлая взрывозащитная дверь, предназначенная для герметизации зон или обеспечения широкого прохода через один вход."
	icon = 'icons/halo/obj/structures/doors/podlocks/5x1_blast_hor.dmi'
	icon_state = "blast1"
	base_icon_state = "blast"
	shutter_length = 5
	var/obj/structure/machinery/door/poddoor/filler_object/f5

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile/Initialize()
	. = ..()
	f5 = new /obj/structure/machinery/door/poddoor/filler_object(get_step(f4, dir))
	f5.density = density
	f5.set_opacity(opacity)

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile/Destroy()
	QDEL_NULL(f5)
	return ..()

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile/start_opening()
	. = ..()
	f5.set_opacity(0)

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile/open_fully()
	. = ..()
	f5.density = FALSE

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile/start_closing()
	. = ..()
	f5.density = TRUE

/obj/structure/machinery/door/poddoor/two_tile/four_tile/five_tile/close_fully()
	. = ..()
	f5.set_opacity(initial(opacity))
