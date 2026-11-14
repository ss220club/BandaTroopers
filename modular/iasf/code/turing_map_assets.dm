/turf/closed/wall/wood/plain
	name = "plain wood wall"
	icon = 'icons/turf/walls/wood_plain.dmi'
	icon_state = "wood"

/obj/effect/decal/grass_overlay/grass1/dark
	icon = 'modular/iasf/icons/turing_grass_overlay.dmi'
	icon_state = "grass_outercorner_dark"

/obj/structure/flora/tree/tyrargo
	icon = 'icons/obj/structures/props/natural/vegetation/tyrargo_pine_tree.dmi'
	icon_state = "pine_1_snow"

/obj/structure/flora/wood
	name = "stick"
	icon = 'icons/obj/structures/props/natural/vegetation/tyrargo_wood_flora.dmi'
	icon_state = "stick1"
	density = FALSE
	fire_flag = FLORA_BURN_NO_SPREAD

/obj/structure/flora/wood/stick1
	icon_state = "stick1"

/obj/structure/flora/wood/stick2
	icon_state = "stick2"

/obj/structure/flora/wood/stick3
	icon_state = "stick3"

/obj/structure/flora/wood/stick4
	icon_state = "stick4"

/obj/structure/platform/wood
	icon = 'modular/iasf/icons/turing_platforms.dmi'
	icon_state = "wood_platform"
	name = "wooden platform"
	desc = "A raised level of wood, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform/wood/east
	dir = EAST

/obj/structure/platform/wood/west
	dir = WEST

/obj/structure/platform_decoration/wood
	icon = 'modular/iasf/icons/turing_platforms.dmi'
	icon_state = "wood_platform_deco"

/obj/structure/platform_decoration/wood/north
	dir = NORTH

/obj/structure/platform_decoration/wood/east
	dir = EAST

/obj/structure/prop/colorable_rock/colorable
	name = "rocks"
	desc = "A solidified collection of local minerals."
	icon = 'modular/iasf/icons/turing_rocks.dmi'
	icon_state = "ground_colorable"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = TURF_LAYER

/obj/structure/prop/colorable_rock/colorable/alt
	icon_state = "ground_colorable_alt"

/obj/structure/prop/colorable_rock/colorable/alt1
	icon_state = "ground_colorable_1"

/obj/structure/prop/tyrargo/boards
	name = "boards"
	desc = "Salvaged wooden boards."
	icon = 'icons/obj/structures/props/tyrargo_props.dmi'
	icon_state = "boards"
	density = FALSE
	anchored = TRUE
	unslashable = FALSE
	health = 100
	layer = XENO_HIDING_LAYER

/obj/structure/prop/tyrargo/boards/boards_1
	icon_state = "boards_2"

/obj/structure/prop/tyrargo/boards/boards_2
	icon_state = "boards_3"

/obj/structure/prop/tyrargo/large_tents
	name = "Tent"
	icon = 'icons/obj/structures/props/large_tent_props.dmi'
	icon_state = "medical_tent"
	health = 300
	layer = ABOVE_FLY_LAYER
	bound_height = 96
	bound_width = 96
	density = TRUE

/obj/structure/prop/tyrargo/large_tents/small
	icon_state = "small_tent"

/obj/structure/prop/tyrargo/watchtower
	name = "Watchtower"
	desc = "UA military watchtower."
	icon = 'icons/obj/structures/props/industrial/watchtower.dmi'
	icon_state = "watchtower"
	health = 500
	density = TRUE
	layer = ABOVE_FLY_LAYER
	bound_height = 64
	bound_width = 64

/obj/structure/prop/tyrargo/traffic_signal
	name = "Portable Changeable Message Sign"
	desc = "A portable display for local instructions."
	icon = 'icons/obj/structures/props/industrial/traffic_signal.dmi'
	icon_state = "traffic_1"
	layer = BILLBOARD_LAYER
	density = TRUE
	health = 500
	light_on = TRUE
	light_color = "#FA9632"
	light_power = 2
	light_range = 2

/obj/structure/prop/tyrargo/traffic_signal/traffic_signal_1
	icon_state = "traffic_2"

/obj/structure/prop/tyrargo/gen
	name = "\improper expended UE-11 Generator Unit"
	icon = 'icons/obj/structures/props/tyrargo_props.dmi'
	icon_state = "gen"
	density = TRUE
	explo_proof = TRUE
	unslashable = TRUE
	unacidable = TRUE
	anchored = TRUE

/obj/structure/barricade/hesco
	name = "HESCO barricade"
	desc = "A sandbag wall."
	icon = 'modular/iasf/icons/turing_barricades.dmi'
	icon_state = "sand_wall"
	health = 500
	maxhealth = 500
	layer = OBJ_LAYER
	stack_type = /obj/item/stack/sandbags
	debris = list(/obj/item/stack/sandbags)
	stack_amount = 5
	color = "#a98c7c"
	destroyed_stack_amount = 1
	barricade_hitsound = 'sound/weapons/Genhit.ogg'
	can_change_dmg_state = FALSE
	barricade_type = "sand_wall"
	can_wire = FALSE
	repair_materials = list("sandbag" = 1)
	metallic = FALSE

/obj/structure/closet/coffin/woodencrate/old
	desc = "An old wooden crate."
	icon = 'modular/iasf/icons/turing_closet.dmi'
	icon_state = "closed_oldwoodcrate"
	icon_opened = "open_oldwoodcrate"
	icon_closed = "closed_oldwoodcrate"

/obj/item/storage/belt/gun/m39/rmc
	name = "\improper L110 pattern M39 holster rig"
	desc = "A leather holster and pouches for the L6A2 carriage and its ammunition."
	icon = 'modular/iasf/icons/turing_belts.dmi'
	icon_state = "rmc_smg"
	item_state = "s_marinebelt"

/obj/item/clothing/head/welding/painted
	name = "custom welding helmet"
	desc = "A welding helmet painted red with white stripes."
	icon = 'modular/iasf/icons/turing_hats.dmi'
	icon_state = "weldingpainted"
	item_state = "weldingpainted"
	item_icons = list(WEAR_HEAD = 'modular/iasf/icons/turing_head_onmob.dmi')

/obj/item/hardpoint/locomotion/humvee_wheels
	name = "\improper M24-JTMV Wheels"
	desc = "Integral to the movement of the M24-JTMV."
	icon = 'icons/obj/vehicles/hardpoints/humvee.dmi'
	icon_state = "tires"
	disp_icon = "humvee"
	disp_icon_state = "humvee_wheels"
	damage_multiplier = 0.15
	health = 300
	move_delay = VEHICLE_SPEED_SUPERFAST
	move_max_momentum = 2
	move_momentum_build_factor = 1.5
	move_turn_momentum_loss_factor = 0.5
