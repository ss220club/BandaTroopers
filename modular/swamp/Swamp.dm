//Prop =============================================================================
/obj/structure/prop/swamp_plants
	name = "swamp plant"
	desc = "you shouldn't be seeing this."
	icon = 'icons/obj/structures/props/natural/vegetation/swamp_plants.dmi'
	icon_state = "lillypads1"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/swamp_plants/lily_pads
	icon_state = "lillypads1"
	layer = ABOVE_TURF_LAYER

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_1
	icon_state = "lillypads1"

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_2
	icon_state = "lillypads2"

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_3
	icon_state = "lillypads3"

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_4
	icon_state = "lillypads4"

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_5
	icon_state = "lillypads5"

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_6
	icon_state = "lillypads6"

/obj/structure/prop/swamp_plants/lily_pads/lily_pads_7
	icon_state = "lillypads7"

/obj/structure/prop/swamp_plants/algae
	icon_state = "algae1"
	alpha = 215

/obj/structure/prop/swamp_plants/algae/small
	icon_state = "algae1"

/obj/structure/prop/swamp_plants/algae/small/algae_1
	icon_state = "algae2"

/obj/structure/prop/swamp_plants/algae/small/algae_2
	icon_state = "algae3"

/obj/structure/prop/swamp_plants/algae/small/algae_3
	icon_state = "algae4"

/obj/structure/prop/swamp_plants/algae/small/algae_4
	icon_state = "algae5"

/obj/structure/prop/swamp_plants/algae/small/algae_5
	icon_state = "algae6"

/obj/structure/prop/swamp_plants/algae/full
	icon_state = "algae_full"

/obj/structure/prop/swamp_plants/algae/full/algae_full_1
	icon_state = "algae_full_1"

/obj/structure/prop/swamp_plants/algae/full/algae_full_2
	icon_state = "algae_full_2"

/obj/structure/prop/swamp_plants/algae/full/algae_full_3
	icon_state = "algae_full_3"

/obj/structure/prop/swamp_plants/algae/full/algae_full_4
	icon_state = "algae_full_4"

// Algae edges & corners

/obj/structure/prop/swamp_plants/algae/straight
	icon_state = "algae_edge"

/obj/structure/prop/swamp_plants/algae/straight/south
	dir = 1

/obj/structure/prop/swamp_plants/algae/straight/west
	dir = 4

/obj/structure/prop/swamp_plants/algae/straight/east
	dir = 8

/obj/structure/prop/swamp_plants/algae/corner
	icon_state = "algae_edge_2"

/obj/structure/prop/swamp_plants/algae/corner/north_west

/obj/structure/prop/swamp_plants/algae/corner/north_east
	dir = 1

/obj/structure/prop/swamp_plants/algae/corner/south_east
	dir = 4

/obj/structure/prop/swamp_plants/algae/corner/south_west
	dir = 8

/obj/structure/prop/swamp_plants/algae/corner2
	icon_state = "algae_corner"

/obj/structure/prop/swamp_plants/algae/corner2/north_west

/obj/structure/prop/swamp_plants/algae/corner2/north_east
	dir = 1

/obj/structure/prop/swamp_plants/algae/corner2/south_west
	dir = 4

/obj/structure/prop/swamp_plants/algae/corner2/south_east
	dir = 8

//tyrargo_wood_flora ================================================
/obj/structure/prop/swamp_plants/wood_flora
	name = "stick"
	desc = "stick... "
	icon = 'icons/obj/structures/props/natural/vegetation/tyrargo_wood_flora.dmi'
	icon_state = "stick1"

/obj/structure/prop/swamp_plants/wood_flora/stick2
	icon_state = "stick2"

/obj/structure/prop/swamp_plants/wood_flora/stick3
	icon_state = "stick3"

/obj/structure/prop/swamp_plants/wood_flora/stick4
	icon_state = "stick4"

/obj/structure/prop/swamp_plants/wood_flora/trunk1
	name = "trunk"
	desc = "trunk..."
	icon_state = "trunk1"

/obj/structure/prop/swamp_plants/wood_flora/trunk2
	name = "trunk"
	desc = "trunk..."
	icon_state = "trunk2"

//wall =================================================================================
/turf/closed/wall/strata_ice/swamp
	name = "swamp vegetation"
	icon = 'icons/turf/walls/swamp_veg.dmi'
	icon_state = "swamp_veg"
	desc = "Exceptionally dense vegetation that you can't see through."
	walltype = WALL_JUNGLE_UPDATED

// Swamp Auto-turf
/turf/open/auto_turf/swamp_dirt
	layer_name = list("marsh sediment", "soft mud", "warn a coder", "warn a coder", "warn a coder")
	icon = 'icons/turf/floors/auto_dirt_swamp.dmi'
	icon_state = "swamp_1"
	icon_prefix = "swamp"

/turf/open/auto_turf/swamp_dirt/get_dirt_type()
	return DIRT_TYPE_SAND

/turf/open/auto_turf/swamp_dirt/layer0
	icon_state = "swamp_0"
	bleed_layer = 0

/turf/open/auto_turf/swamp_dirt/layer1
	icon_state = "swamp_1"
	bleed_layer = 1

/turf/open/auto_turf/swampalt_dirt
	layer_name = list("marsh sediment", "soft mud", "warn a coder", "warn a coder", "warn a coder")
	icon = 'icons/turf/floors/auto_dirt_swamp.dmi'
	icon_state = "alt_1"
	icon_prefix = "alt"

/turf/open/auto_turf/swampalt_dirt/get_dirt_type()
	return DIRT_TYPE_SAND

/turf/open/auto_turf/swampalt_dirt/layer0
	icon_state = "alt_0"
	bleed_layer = 0

/turf/open/auto_turf/swampalt_dirt/layer1
	icon_state = "alt_1"
	bleed_layer = 1

/turf/open/auto_turf/swamp_grass
	name = "matted grass"
	icon = 'icons/turf/floors/auto_swamp_grass.dmi'
	icon_state = "grass_0"
	icon_prefix = "grass"
	layer_name = list("ground","lush thick grass")
	desc = "Grass, dirt, mud, and other assorted high moisture cave flooring."

/turf/open/auto_turf/swamp_grass/insert_self_into_baseturfs()
	baseturfs += /turf/open/auto_turf/swamp_grass/layer0

/turf/open/auto_turf/swamp_grass/layer0
	icon_state = "grass_0"
	bleed_layer = 0
	variant_prefix_name = "matted grass"

/turf/open/auto_turf/swamp_grass/layer0_mud
	icon_state = "grass_0_mud"
	bleed_layer = 0
	variant = "mud"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/swamp_grass/layer0_mud_alt
	icon_state = "grass_0_mud_alt"
	bleed_layer = 0
	variant = "mud_alt"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/swamp_grass/layer1
	icon_state = "grass_1"
	bleed_layer = 1

//add new turf dor SWAMP =======================================================
/turf/open/gm/coast/dirt/swampdir
	icon = 'icons/turf/floors/swamp_water.dmi'
	icon_state = "swamp"
	baseturfs = /turf/open/gm/coast

/turf/open/gm/coast/dirt/swampdir/south
	dir = 1

/turf/open/gm/coast/dirt/swampdir/west
	dir = 4

/turf/open/gm/coast/dirt/swampdir/east
	dir = 8

/turf/open/gm/coast/dirt/swampbeachcorner
	icon = 'icons/turf/floors/swamp_water.dmi'
	icon_state = "swampcorner"

/turf/open/gm/coast/dirt/swampbeachcorner/north_west

/turf/open/gm/coast/dirt/swampbeachcorner/north_east
	dir = 1

/turf/open/gm/coast/dirt/swampbeachcorner/south_east
	dir = 4

/turf/open/gm/coast/dirt/swampbeachcorner/south_west
	dir = 8

/turf/open/gm/coast/dirt/swampbeachcorner2
	icon = 'icons/turf/floors/swamp_water.dmi'
	icon_state = "swampcorner2"

/turf/open/gm/coast/dirt/swampbeachcorner2/north_west

/turf/open/gm/coast/dirt/swampbeachcorner2/north_east
	dir = 1

/turf/open/gm/coast/dirt/swampbeachcorner2/south_west
	dir = 4

/turf/open/gm/coast/dirt/swampbeachcorner2/south_east
	dir = 8

/turf/open/gm/dirt/swamp_dirt
	name = "swamp dirt"
	icon = 'icons/turf/floors/swamp_water.dmi'
	icon_state = "desert"
	minimap_color = MINIMAP_DIRT

/turf/open/gm/dirt/swamp_dirt/variant_1
	icon_state = "desert0"

/turf/open/gm/dirt/swamp_dirt/variant_2
	icon_state = "desert1"

/turf/open/gm/dirt/swamp_dirt/variant_3
	icon_state = "desert2"

/turf/open/gm/dirt/swamp_dirt/variant_5
	icon_state = "desert3"

/turf/open/gm/dirt/swamp_dirt/variant_5/east
	dir = EAST

/turf/open/gm/dirt/swamp_dirt/variant_5/south
	dir = SOUTH

/turf/open/gm/dirt/swamp_dirt/variant_5/west
	dir = WEST

/turf/open/gm/dirt/swamp_dirt/variant_6
	icon_state = "desert_dug"

/turf/open/gm/dirtgrassborder2/grassdirt_corner
	icon_state = "grassdirt2_corner"

/turf/open/gm/dirtgrassborder2/grassdirt_corner/north_east
	dir = 1

/turf/open/gm/dirtgrassborder2/grassdirt_corner/south_east
	dir = 4

/turf/open/gm/dirtgrassborder2/grassdirt_corner/south_west
	dir = 8

/turf/open/gm/dirtgrassborder2/grassdirt_corner2
	icon_state = "grassdirt2_corner2"

/turf/open/gm/dirtgrassborder2/grassdirt_corner2/north_east
	dir = 1

/turf/open/gm/dirtgrassborder2/grassdirt_corner2/south_west
	dir = 4

/turf/open/gm/dirtgrassborder2/grassdirt_corner2/south_east
	dir = 8

// SS220 EDIT  START: GroundSide Smamp_1 for Swamp
/turf/open/gm/river/swamp
	name = "Puddle"
	icon = 'icons/turf/floors/swamp_water.dmi'
	icon_state = "swampshallow"
	icon_overlay = "swampriverwater"
	default_name = "Puddle"
	no_overlay = TRUE
	base_river_slowdown = 1.75
/turf/open/gm/river/swamp/mid
	base_river_slowdown = 10
	color = "#d4d1bc"
/turf/open/gm/river/swamp/mid/grass
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "grass1"
	icon_overlay = "grass1"
	color = null
/turf/open/gm/river/swamp/deep
	base_river_slowdown = 20
	color = "#c4c2b3"
/turf/open/gm/river/swamp/dirt
	name = "dirt"
	default_name = "Dirt"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "dirt"
	icon_overlay = "dirt"
	color = "#999999"
/turf/open/gm/river/swamp/dirt/slow2
	base_river_slowdown = 2
/turf/open/gm/river/swamp/dirt/slow3
	base_river_slowdown = 3

