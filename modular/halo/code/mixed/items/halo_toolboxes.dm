/obj/item/storage/toolbox/traxus
	name = "ящик с инструментами Traxus"
	desc = "Большой красный ящик с округлой крышкой, способный вместить самые разные инструменты и снаряжение на все случаи работы. Этот экземпляр произведён Traxus Heavy Industries и выглядит весьма... основательно."
	icon = 'icons/halo/obj/items/storage/toolbox.dmi'
	icon_state = "traxus"
	force = 6
	storage_slots = 8

/obj/item/storage/toolbox/traxus/fill_preset_inventory()
	var/color = pick("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white")
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/stack/cable_coil(src, 30, color)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/device/multitool(src)

/obj/item/storage/toolbox/traxus/alt
	desc = "Большой красный ящик с угловатой крышкой, способный вместить самые разные инструменты и снаряжение на все случаи работы. Этот экземпляр произведён Traxus Heavy Industries и выглядит весьма... основательно."
	icon_state = "traxus_2"

/obj/item/storage/toolbox/traxus/big
	name = "большой ящик с инструментами Traxus"
	desc = "Большой красный ящик с округлой крышкой, способный вместить самые разные инструменты и снаряжение на все случаи работы. Этот экземпляр произведён Traxus Heavy Industries и выглядит весьма... основательно."
	icon = 'icons/halo/obj/items/storage/toolbox.dmi'
	icon_state = "traxus_big"
	force = 8
	throw_range = 3
	storage_slots = 10

/obj/item/storage/toolbox/traxus/big/fill_preset_inventory()
	var/color = pick("red", "yellow", "green", "blue", "pink", "orange", "cyan", "white")
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/stack/cable_coil(src, 30, color)
	new /obj/item/tool/wirecutters(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/device/multitool(src)
	new /obj/item/circuitboard/apc(src)
	new /obj/item/device/flashlight(src)
