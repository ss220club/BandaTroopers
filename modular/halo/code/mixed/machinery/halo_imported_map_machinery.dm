/obj/structure/machinery/door/airlock/voi
	name = "\improper industrial door"
	desc = "An industrial door made of thick metal."
	icon = 'icons/halo/obj/structures/doors/voi_door.dmi'

/obj/structure/machinery/door/airlock/voi/autoname
	autoname = TRUE

/obj/structure/machinery/door/airlock/voi/colony
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_ENGINEERING, ACCESS_WY_COLONIAL)

/obj/structure/machinery/door/airlock/voi/colony/autoname
	autoname = TRUE

/obj/structure/machinery/door/airlock/voi/prop
	autoclose = FALSE
	locked = TRUE
	icon_state = "door_locked"

/obj/structure/machinery/door/airlock/voi/prop/autoname
	autoname = TRUE

/obj/structure/machinery/nuclearbomb/covenant_bomb
	name = "\improper Antimatter Charge"
	desc = "A frightening-looking explosive device of alien origin, you should get very far away from it, or get it very far away from you."
	icon = 'icons/halo/obj/structures/machinery/cov_bomb.dmi'
	icon_state = "lebomb"
	pixel_x = -16
	pixel_y = -6

/obj/structure/machinery/nuclearbomb/covenant_bomb/update_icon()
	overlays.Cut()
	if(anchored)
		var/image/I = image(icon, "+spikespikespikes")
		overlays += I
	if(timing)
		var/image/I = image(icon, "+light_base")
		overlays += I
	if(timing == -1)
		var/image/I = image(icon, "+light_flash")
		overlays += I
