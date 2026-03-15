/obj/structure/closet/crate/unsc
	name = "ящик снабжения ККОН"
	desc = "Стандартный ящик снабжения сил ККОН, пригодный для хранения самых разных предметов."
	icon = 'icons/halo/obj/structures/crates.dmi'
	icon_state = "closed_unsc"
	icon_opened = "open_unsc"
	icon_closed = "closed_unsc"

/obj/structure/prop/unsc_crate
	name = "ящик ККОН"
	desc = "Военный грузовой ящик."
	icon = 'icons/halo/obj/structures/props/crates.dmi'
	icon_state = null
	density = TRUE

/obj/structure/prop/unsc_crate/stack
	name = "закреплённые ящики снабжения ККОН"
	desc = "Два ящика снабжения, стянутые между собой ремнём."
	icon = 'icons/halo/obj/structures/crates.dmi'
	icon_state = "cratestack"

/obj/structure/prop/unsc_crate/standard
	desc = "Военный грузовой ящик. Открыть его будет непросто."
	icon_state = "c1_greyscale"

/obj/structure/prop/unsc_crate/standard/blue
	icon_state = "c1_blue"

/obj/structure/prop/unsc_crate/standard/red
	icon_state = "c1_red"

/obj/structure/prop/unsc_crate/standard/green
	icon_state = "c1_green"

/obj/structure/prop/unsc_crate/standard/medical
	icon_state = "c1_medical"

/obj/structure/prop/unsc_crate/corrugated
	desc = "Военный грузовой ящик с рифлёными панелями."
	icon_state = "c2_greyscale"

/obj/structure/prop/unsc_crate/corrugated/blue
	icon_state = "c2_blue"

/obj/structure/prop/unsc_crate/corrugated/red
	icon_state = "c2_red"

/obj/structure/prop/unsc_crate/corrugated/green
	icon_state = "c2_green"

/obj/structure/prop/unsc_crate/big
	name = "крупный ящик ККОН"
	desc = "Крупный военный грузовой ящик."
	icon = 'icons/halo/obj/structures/props/64x64crates.dmi'
	icon_state = "crate"
	bound_height = 64
	pixel_x = -5

/obj/structure/prop/unsc_crate/big/stack
	name = "ящики ККОН"
	desc = "Стопка крупных военных грузовых ящиков."
	icon_state = "pile"
	pixel_x = -3

/obj/structure/prop/unsc_crate/big/stack/alt
	icon_state = "pile2"

/obj/structure/cargo_container/unsc
	name = "грузовой контейнер ККОН"
	desc = "Крупный грузовой контейнер оливкового цвета."
	icon = 'icons/halo/obj/structures/props/containers.dmi'
	icon_state = "main_1"
	density = TRUE
	health = 400
	opacity = FALSE
	layer = 5

/obj/structure/cargo_container/unsc/main_1
	icon_state = "main_1a"

/obj/structure/cargo_container/unsc/main_1/b
	icon_state = "main_1b"

/obj/structure/cargo_container/unsc/main_1/c
	icon_state = "main_1c"

/obj/structure/cargo_container/unsc/main_1/d
	icon_state = "main_1d"

/obj/structure/cargo_container/unsc/main_1/e
	icon_state = "main_1e"

/obj/structure/cargo_container/unsc/main_2
	icon_state = "main_2a"

/obj/structure/cargo_container/unsc/main_2/b
	icon_state = "main_2b"

/obj/structure/cargo_container/unsc/main_2/c
	icon_state = "main_2c"

/obj/structure/cargo_container/unsc/main_2/d
	icon_state = "main_2d"

/obj/structure/cargo_container/unsc/main_3
	icon_state = "main_3a"

/obj/structure/cargo_container/unsc/main_3/b
	icon_state = "main_3b"

/obj/structure/cargo_container/unsc/main_3/c
	icon_state = "main_3c"

/obj/structure/cargo_container/unsc/main_3/d
	icon_state = "main_3d"

/obj/structure/cargo_container/unsc/vertical
	bound_width = 64
	bound_height = 32

/obj/structure/cargo_container/unsc/vertical/south_1
	icon_state = "south_1"
	bound_height = 64

/obj/structure/cargo_container/unsc/vertical/south_1/alt
	icon_state = "south_1b"

/obj/structure/cargo_container/unsc/vertical/south_2
	icon_state = "south_2"

/obj/structure/cargo_container/unsc/vertical/south_3
	icon_state = "south_3"

/obj/structure/cargo_container/unsc/vertical/south_3/endcap_1
	icon_state = "south_3b"

/obj/structure/cargo_container/unsc/vertical/south_3/endcap_2
	icon_state = "south_3c"

/obj/structure/cargo_container/unsc/vertical/south_4
	icon_state = "south_4"
