/turf/open/floor/forerunner
	name = "металлический пол"
	icon = 'icons/halo/turf/floors/forerunner.dmi'
	icon_state = "forerunner_1"
	hull_floor = TRUE

/turf/open/floor/forerunner/random/Initialize()
	icon_state = "forerunner_[rand(1, 6)]"

/obj/structure/prop/invuln/the_gate
	name = "Красные врата"
	desc = "За красной пеленой не видно ничего."
	icon = 'icons/halo/obj/structures/red_gate.dmi'
	icon_state = "gate_2"

/obj/structure/prop/invuln/the_gate/Initialize()
	. = ..()
	var/mutable_appearance/gate_glow = emissive_appearance(icon, "glow", INTERIOR_WALLMOUNT_LAYER)
	gate_glow.transform = transform
	overlays += gate_glow
