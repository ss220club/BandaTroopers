/obj/item/storage/box/tear_packet
	name = "packet"
	desc = "A plastic packet."
	icon = 'icons/halo/obj/items/storage/packets.dmi'
	icon_state = "ammo_packet"
	w_class = SIZE_SMALL
	can_hold = list()
	storage_slots = 3
	use_sound = "rip"
	var/isopened = FALSE

/obj/item/storage/box/tear_packet/m7
	name = "magazine packet (M7, x2)"
	storage_slots = 2

/obj/item/storage/box/tear_packet/m7/fill_preset_inventory()
	new /obj/item/ammo_magazine/smg/halo/m7(src)
	new /obj/item/ammo_magazine/smg/halo/m7(src)

/obj/item/storage/box/tear_packet/Initialize()
	. = ..()
	isopened = FALSE
	icon_state = "[initial(icon_state)]"
	use_sound = "rip"

/obj/item/storage/box/tear_packet/update_icon()
	if(!isopened)
		isopened = TRUE
		icon_state = "[initial(icon_state)]_o"
		use_sound = "rustle"

/obj/item/storage/box/tear_packet/medical_packet
	name = "UNSC medical packet"
	desc = "A combat-rated first aid medical packet filled with the bare bones basic essentials to ensuring you or your buddies don't die on the battlefield."
	icon_state = "medical_packet"
	storage_slots = 6
	max_w_class = 3
	can_hold = list(
		/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/small,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/splint,
		/obj/item/storage/syringe_case/unsc,
	)

/obj/item/storage/box/tear_packet/medical_packet/fill_preset_inventory()
	new /obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/small(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/storage/syringe_case/unsc/morphine/full(src)
