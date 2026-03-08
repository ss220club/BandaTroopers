/obj/item/reagent_container/glass/barrel
	name = "canister"
	desc = "A canister. Can hold up to 240 units."
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
	name = "water canister"
	desc = "A semi-large canister full of water. The spout on the side allows you to fill bottles and canteens. Not to be mistaken for the similarly stored hydrogen."
	icon_state = "sbarrel_water"

/obj/item/reagent_container/glass/barrel/water/Initialize()
	. = ..()
	reagents.add_reagent("water", 240)

/obj/item/reagent_container/glass/barrel/liquidhydrogen
	name = "liquid hydrogen canister"
	desc = "A semi-large and inconvenient to hold canister full of liquid hydrogen for fueling up various vehicles. A large warning label on the side says 'NOT FOR CONSUMPTION'."
	icon_state = "sbarrel_hydrogen"

/obj/item/reagent_container/glass/barrel/liquidhydrogen/Initialize()
	. = ..()
	reagents.add_reagent("liquidhydrogen", 240)
