/obj/structure/flora/grass/temperate
	icon = 'icons/obj/structures/props/natural/vegetation/temperate_flora.dmi'
	icon_state = "1"


/obj/structure/flora/tree/tyrargo
	icon = 'icons/obj/structures/props/natural/vegetation/tyrargo_pine_tree.dmi'
	icon_state = "pine_1_snow"


/obj/structure/flora/tree/tyrargo/tree_2
	icon_state = "pine_1"


/obj/structure/flora/tree/tyrargo/tree_3
	icon_state = "bald"


/obj/structure/flora/tree/tyrargo/tree_4
	icon_state = "dead_tree1"


/obj/structure/flora/tree/tyrargo/tree_5
	icon_state = "dead_tree2"


/obj/structure/flora/tree/tyrargo/tree_6
	icon_state = "dead_tree3"

/obj/structure/flora/tree/tyrargo_small
	icon = 'icons/obj/structures/props/natural/vegetation/tyrargo_dead_trees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/tyrargo_small/tree_2
	icon_state = "tree_2"

/obj/structure/flora/tree/tyrargo_small/tree_3
	icon_state = "tree_3"

/obj/structure/flora/tree/tyrargo_small/tree_4
	icon_state = "tree_4"

/obj/structure/flora/tree/tyrargo_small/tree_5
	icon_state = "tree_5"

/obj/structure/flora/tree/tyrargo_small/tree_stump
	icon_state = "tree_stump"
	density = FALSE

/turf/open/floor/almayer/plating_stripedcorner
	icon_state = "plating_striped_corner"

/turf/open/floor/almayer/plating_stripedcorner/north
	dir = NORTH

/turf/open/floor/almayer/plating_stripedcorner/south
	dir = SOUTH

/turf/open/floor/almayer/plating_stripedcorner/east
	dir = EAST

/turf/open/floor/almayer/plating_stripedcorner/west
	dir = WEST



/obj/structure/platform/stone/tyrargo
	name = "rock edge"
	desc = "A solid chunk of desolate rocks. Looks like you could climb it."
	icon_state = "tyrargo_rock_platform"


/obj/structure/platform/stone/tyrargo/north
	dir = NORTH

/obj/structure/platform/stone/tyrargo/east
	dir = EAST

/obj/structure/platform/stone/tyrargo/west
	dir = WEST


/obj/structure/platform_decoration/stone/tyrargo
	name = "rock corner"
	desc = "Solid chunks of desolate rocks."
	icon_state = "tyrargo_rock_platform_deco"


/obj/structure/platform_decoration/stone/tyrargo/north
	dir = NORTH

/obj/structure/platform_decoration/stone/tyrargo/east
	dir = EAST

/obj/structure/platform_decoration/stone/tyrargo/west
	dir = WEST


/turf/closed/wall/strata_ice/forest
	name = "forest vegetation"
	icon = 'icons/turf/walls/forest_veg.dmi'
	icon_state = "forest_veg"
	desc = "Exceptionally dense vegetation that you can't see through."
	walltype = WALL_FOREST //Thick forest, not metal.
	hull = 1


/turf/closed/wall/strata_ice/forest/rock
	name = "rock columns"
	icon_state = "rock_forest"
	desc = "Exceptionally dense rock formations."
	walltype = WALL_FOREST_ROCK //Rock but near a forest not jungle.
	hull = 1


/turf/closed/wall/strata_ice/forest/rock/dirty
	name = "rock columns"
	icon_state = "rock_forest_dirty"
	desc = "Exceptionally dense rock formations."
	walltype = WALL_FOREST_ROCK_DIRTY //Dirty rock but near a forest not jungle.
	hull = 1


/turf/open/auto_turf/tyrargo_grass
	name = "matted grass"
	icon = 'icons/turf/floors/auto_tyrargo_turf.dmi'
	icon_state = "grass_0"
	icon_prefix = "grass"
	layer_name = list("ground","lush thick grass")
	desc = "grass, dirt, mud, and other assorted high moisture cave flooring."


/turf/open/auto_turf/tyrargo_grass/insert_self_into_baseturfs()
	baseturfs += /turf/open/auto_turf/tyrargo_grass/layer0


/turf/open/auto_turf/tyrargo_grass/layer0
	icon_state = "grass_0"
	bleed_layer = 0
	variant_prefix_name = "matted grass"


/turf/open/auto_turf/tyrargo_grass/layer0_mud
	icon_state = "grass_0_mud"
	bleed_layer = 0
	variant = "mud"
	variant_prefix_name = "muddy"


/turf/open/auto_turf/tyrargo_grass/layer0_mud_alt
	icon_state = "grass_0_mud_alt"
	bleed_layer = 0
	variant = "mud_alt"
	variant_prefix_name = "muddy"


/turf/open/auto_turf/tyrargo_grass/layer1
	icon_state = "grass_1"
	bleed_layer = 1


/turf/open/floor/almayer/plating_striped
	icon_state = "plating_striped"


/turf/open/floor/almayer/plating_striped/north
	dir = NORTH


/turf/open/floor/almayer/plating_striped/east
	dir = EAST


/turf/open/floor/almayer/plating_striped
	icon_state = "plating_striped"


/turf/open/floor/almayer/plating_striped/north
	dir = NORTH


/turf/open/floor/almayer/plating_striped/south
	dir = SOUTH


/turf/open/floor/almayer/plating_striped/east
	dir = EAST


/turf/open/floor/almayer/plating_striped/west
	dir = WEST


/turf/open/floor/almayer/plating_striped/northeast
	dir = NORTHEAST


/turf/open/floor/almayer/plating_striped/northwest
	dir = NORTHWEST


/turf/open/floor/almayer/plating_striped/southeast
	dir = SOUTHEAST


/turf/open/floor/almayer/plating_striped/southwest
	dir = SOUTHWEST


/turf/open/floor/almayer/plating_striped/west
	dir = WEST


/turf/open/floor/strata/gray_multi_tiles/pred
	color = "#5e5d5d"
	icon_state = "multi_tiles"


/turf/open/floor/strata/gray_multi_tiles/south/pred
	dir = SOUTH



/turf/open/floor/almayer_hull/outerhull_dir_alt
	icon_state = "outerhull_dir_alt"


/turf/open/floor/almayer_hull/outerhull_dir_alt/southwest
	dir = SOUTHWEST


/turf/open/floor/almayer_hull/outerhull_dir_alt/north
	dir = NORTH


/turf/open/floor/almayer_hull/outerhull_dir_alt/east
	dir = EAST


/turf/open/floor/almayer_hull/outerhull_dir_alt/northeast
	dir = NORTHEAST


/turf/open/floor/almayer_hull/outerhull_dir_alt/southeast
	dir = SOUTHEAST


/turf/open/floor/almayer_hull/outerhull_dir_alt/west
	dir = WEST


/turf/open/floor/almayer_hull/outerhull_dir_alt/northwest
	dir = NORTHWEST

/turf/open/slippery/hull
	name = "sloped roof"
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull"


/turf/open/slippery/hull/dir
	icon_state = "outerhull_dir"


/turf/open/slippery/hull/dir/southwest
	dir = SOUTHWEST


/turf/open/slippery/hull/dir/north
	dir = NORTH


/turf/open/slippery/hull/dir/east
	dir = EAST


/turf/open/slippery/hull/dir/northeast
	dir = NORTHEAST


/turf/open/slippery/hull/dir/southeast
	dir = SOUTHEAST


/turf/open/slippery/hull/dir/west
	dir = WEST


/turf/open/slippery/hull/dir/northwest
	dir = NORTHWEST


/obj/effect/landmark/ammo_spawn/vp78_ammo
	name = "vp78 ammo (70)"
	icon_state = "ipool"


/obj/effect/landmark/ammo_spawn/vp78_ammo/Initialize(mapload, ...)
	. = ..()
	if(prob(70))
		new /obj/item/ammo_magazine/pistol/vp78(loc)


/obj/effect/landmark/ammo_spawn/smg_ammo
	name = "SMG ammo (60)"
	icon_state = "ipool"


/obj/effect/landmark/ammo_spawn/smg_ammo/Initialize(mapload, ...)
	. = ..()
	if(prob(60))
		new /obj/item/ammo_magazine/smg/m39(loc)

/obj/effect/landmark/corpsespawner/tyrargo/us_army_trooper
	name = "Corpse - US Army - Trooper"
	equip_path = /datum/equipment_preset/corpse/tyrargo/us_army_trooper


/obj/effect/landmark/corpsespawner/tyrargo/us_army_trooper/burst
	name = "Corpse - Burst - US Army - Trooper"
	equip_path = /datum/equipment_preset/corpse/tyrargo/us_army_trooper/burst


/obj/effect/landmark/corpsespawner/tyrargo/us_army_medic
	name = "Corpse - US Army - Trooper"
	equip_path = /datum/equipment_preset/corpse/tyrargo/us_army_medic


/obj/effect/landmark/corpsespawner/tyrargo/us_army_medic/burst
	name = "Corpse - Burst - US Army - Trooper"
	equip_path = /datum/equipment_preset/corpse/tyrargo/us_army_medic/burst


/obj/effect/landmark/structure_spawner/setup/distress/xeno_sticky
	name = "Distress Xeno sticky spawner"
	icon = 'icons/mob/xenos/effects.dmi'
	icon_state = "sticky"
	path_to_spawn = /obj/effect/alien/resin/sticky


/obj/effect/landmark/structure_spawner/setup/distress/xeno_wall_reinforced
	name = "Distress Xeno reinforced wall spawner"
	icon_state = "wall_r"
	path_to_spawn = /turf/closed/wall/resin/thick
	is_turf = TRUE


/obj/effect/landmark/structure_spawner/setup/distress/xeno_door_reinforced
	name = "Distress Xeno reinforced door spawner"
	icon_state = "door_r"
	path_to_spawn = /obj/structure/mineral_door/resin/thick


/obj/structure/lz_sign/tyrargo_sign
	name = "Tyrargo Rift - Firebase Charlie Landing Zone one sign"
	desc = "A medium sized sign, illuminated by red lights, designating this area as firebase charlie."
	icon_state = "tyrargo_sign_1"


/obj/structure/lz_sign/tyrargo_sign/lz2
	name = "Tyrargo Rift - USASF Airbase Anderson Landing Zone two sign"
	desc = "A large sign that designates this area as being a USASF airbase."
	icon_state = "tyrargo_sign_2"


/obj/structure/lz_sign/tyrargo_sign/lz2/alt
	icon_state = "tyrargo_sign_3"


/obj/structure/lz_sign/tyrargo_sign/city
	name = "Tyrargo Rift - city limit sign"
	desc = "A large sign designating the city limit of Tyrargo Rift."
	icon_state = "tyrargo_sign_4"


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket
	name = "basket"
	desc = "A basket."
	icon_state = "supermarketbasketempty"
	health = 5


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket/empty
	name = "basket"
	desc = "A basket."
	icon_state = "supermarketbasketempty"


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket/oranges
	name = "basket"
	desc = "A basket full of oranges."
	icon_state = "supermarketbasket1"


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket/pears
	name = "basket"
	desc = "A basket full of pears."
	icon_state = "supermarketbasket2"


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket/carrots
	name = "basket"
	desc = "A basket full of carrots."
	icon_state = "supermarketbasket3"


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket/melons
	name = "basket"
	desc = "A basket full of melons."
	icon_state = "supermarketbasket4"


/obj/structure/prop/hybrisa/supermart/supermartfruitbasket/apples
	name = "basket"
	desc = "A basket full of apples."
	icon_state = "supermarketbasket5"


/obj/structure/sign/minefield/alt
	icon_state = "mines_warning"


/obj/structure/barricade/sandbags/weak_wired/New()
	health = BARRICADE_SANDBAG_TRESHOLD_1
	maxhealth = BARRICADE_SANDBAG_TRESHOLD_1
	stack_amount = 0
	color = "#a98c7c"
	maxhealth += 50
	update_health(-50)
	can_wire = FALSE
	is_wired = TRUE
	build_stage = BARRICADE_SANDBAG_5
	update_icon()
	climbable = FALSE
	. = ..()


/obj/structure/barricade/sandbags/weak_wired/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	flags_can_pass_front_temp &= ~PASS_OVER_THROW_MOB
	flags_can_pass_behind_temp &= ~PASS_OVER_THROW_MOB

/obj/effect/decal/strata_decals/tyrargo_mud_corner
	icon_state = "tyrargo_mud_innercorner"
	name = "mud"
	desc = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/item/ammo_magazine/rifle/m49a/heap/empty
	current_rounds = 0


/obj/item/ammo_box/magazine/m41ae2/heap
	name = "magazine box (M41AE2 HEAP x 8)"
	overlay_ammo_type = "_heap_heavy"
	overlay_content = "_m41ae2_heap"
	magazine_type = /obj/item/ammo_magazine/hpr_box/heap


/obj/item/ammo_box/magazine/m41ae2/heap/empty
	empty = TRUE


/obj/item/weapon/gun/rifle/m49a/army/full
	current_mag = /obj/item/ammo_magazine/rifle/m49a/heap


/obj/item/clothing/head/beret/marine/commander/black/army
	name = "army major black beret"
