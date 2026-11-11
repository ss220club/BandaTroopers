/obj/structure/barricade/handrail/strata/navalis
	stack_amount = 0
	destroyed_stack_amount = 0
	can_be_reinforced = FALSE
	projectile_coverage = PROJECTILE_COVERAGE_MINIMAL
	color = "#f50000"

/obj/structure/blocker/forcefield/all
	types = list(/mob/living/carbon/human, /mob/living/carbon/xenomorph, /obj/item/weapon)
	icon_state = "purple_line"

/obj/structure/bed/chair/comfy/yautja
	name = "alien chair"
	icon = 'icons/obj/structures/machinery/yautja_machines.dmi'
	debris = list(/obj/item/stack/sheet/mineral/sandstone/runed)

/obj/item/tool/weldingtool/empty

/obj/item/tool/weldingtool/empty/Initialize()
	. = ..()
	reagents.remove_reagent("fuel", max_fuel)

/obj/structure/filtration/machine_64x96/filtration_machine_a/alt
	icon_state = "filtration_machine_B_0"

/obj/structure/filtration/machine_64x96/sedementation
	name = "Sedementation Tanker"
	desc = "Machine intended to hold liquid."
	icon_state = "sedementation_0"

/obj/structure/filtration/machine_64x128/filtrationtank
	name = "Storage Tank"
	desc = "A massive tank intended to hold large amounts of liquid."
	icon_state = "filtration_0"

/obj/structure/prop/hybrisa/factory
	icon = 'icons/obj/structures/props/industrial/factory.dmi'
	icon_state = "factory_roboticarm"

/obj/structure/prop/hybrisa/factory/robotic_arm
	name = "robotic arm"
	desc = "A robotic arm used in the construction of 'Meridian' Automobiles."
	bound_width = 64
	bound_height = 32
	anchored = TRUE

/obj/structure/prop/hybrisa/factory/robotic_arm/flipped
	icon_state = "factory_roboticarm2"

/obj/structure/prop/hybrisa/misc/floorprops/grate2/indestructible
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE

/obj/structure/prop/hybrisa/misc/floorprops/grate4
	name = "solid metal grate"
	desc = "A metal grate."
	icon_state = "zhalfgrate2"

/obj/structure/prop/hybrisa/misc/picture_oil
	name = "framed picture"
	desc = "A silver framed picture of someone wearing a corporate issue deepsea powered hardsuit, the base of the frame has some words inscribed, 'site director'."
	icon = 'icons/obj/structures/props/wall_decorations/decals.dmi'
	icon_state = "pictureframe"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/window/framed/hybrisa/colony/hull/blastdoor
	name = "hull window"
	desc = "A glass window with a special rod matrix inside a wall frame. This one has an automatic shutter system to prevent any flooding breach."
	health = 200
	not_damageable = FALSE
	unslashable = FALSE
	unacidable = FALSE
	var/triggered = FALSE

/obj/structure/window/framed/hybrisa/colony/hull/blastdoor/Destroy(force)
	if(force)
		return ..()
	spawn_shutters()
	. = ..()

/obj/structure/window/framed/hybrisa/colony/hull/blastdoor/proc/spawn_shutters(from_dir = 0)
	if(triggered)
		return
	triggered = TRUE
	for(var/direction in GLOB.cardinals)
		if(direction == from_dir)
			continue
		for(var/obj/structure/window/framed/hybrisa/colony/hull/blastdoor/W in get_step(src, direction))
			W.spawn_shutters(turn(direction, 180))
	var/obj/structure/machinery/door/poddoor/shutters/almayer/pressure/pressure_door = new(get_turf(src))
	switch(junction)
		if(4, 5, 8, 9, 12)
			pressure_door.setDir(SOUTH)
		else
			pressure_door.setDir(EAST)
	pressure_door.close()

/obj/structure/machinery/colony_floodlight/navalis_wall_light
	name = "wall mounted colony floodlight"
	desc = "Powerful wall-mounted lights intended to operate even through a hurricane. Powered directly from the Industrial Rig."
	icon = 'icons/obj/items/lighting.dmi'
	icon_state = "slight0"
	density = FALSE
	light_color = "#FFEFD2"

/obj/structure/machinery/colony_floodlight/navalis_wall_light/update_icon()
	if(damaged)
		icon_state = "slight-burned"
	else if(is_on)
		icon_state = "slight1"
	else
		icon_state = "slight0"

/obj/effect/stairs
	var/direction

/obj/effect/stairs/Initialize(mapload, ...)
	. = ..()
	SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "stairs_[direction]")

/obj/effect/stairs/up
	direction = "up"

/obj/effect/stairs/down
	direction = "down"
