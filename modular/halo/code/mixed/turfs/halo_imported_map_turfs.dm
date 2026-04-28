/turf/open/auto_turf/varadero_brown_grass
	name = "matted grass"
	icon = 'icons/turf/floors/new_varadero/auto_grass_nv_brown.dmi'
	icon_state = "grass_0"
	icon_prefix = "grass"
	layer_name = list("ground", "lush thick grass", "soaked ground")
	desc = "grass, dirt, mud, and other assorted high moisture cave flooring."

/turf/open/auto_turf/varadero_brown_grass/insert_self_into_baseturfs()
	baseturfs += /turf/open/auto_turf/varadero_brown_grass/layer0

/turf/open/auto_turf/varadero_brown_grass/layer0
	icon_state = "grass_0"
	bleed_layer = 0
	variant_prefix_name = "matted grass"

/turf/open/auto_turf/varadero_brown_grass/layer0_mud
	icon_state = "grass_0_mud"
	bleed_layer = 0
	variant = "mud"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/varadero_brown_grass/layer0_mud_alt
	icon_state = "grass_0_mud_alt"
	bleed_layer = 0
	variant = "mud_alt"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/varadero_brown_grass/layer1
	icon_state = "grass_1"
	bleed_layer = 1

/turf/open/auto_turf/varadero_red_grass
	name = "matted grass"
	icon = 'icons/turf/floors/new_varadero/auto_grass_nv_red.dmi'
	icon_state = "grass_0"
	icon_prefix = "grass"
	layer_name = list("ground", "thick grass", "soaked ground")
	desc = "grass, dirt, mud, and other assorted high moisture cave flooring."

/turf/open/auto_turf/varadero_red_grass/insert_self_into_baseturfs()
	baseturfs += /turf/open/auto_turf/varadero_red_grass/layer0

/turf/open/auto_turf/varadero_red_grass/layer0
	icon_state = "grass_0"
	bleed_layer = 0
	variant_prefix_name = "matted grass"

/turf/open/auto_turf/varadero_red_grass/layer1
	icon_state = "grass_1"
	bleed_layer = 1

/turf/open/auto_turf/varadero_white_sand
	name = "compact sand"
	icon = 'icons/turf/floors/new_varadero/auto_sand_rock_nv.dmi'
	icon_state = "white_sand_0"
	icon_prefix = "white_sand_0"
	layer_name = list("ground", "compact sand")
	desc = "sand mixed with small rocks compacted tightly together by other means."

/turf/open/auto_turf/varadero_white_sand/layer0
	icon_state = "white_sand_0"
	bleed_layer = 0
	variant_prefix_name = "compact sand"

/turf/open/auto_turf/varadero_white_sand/layer1
	icon_state = "white_sand_1"
	bleed_layer = 1

/turf/open/auto_turf/ground_rock_column
	name = "rocky ground"
	icon = 'icons/turf/floors/new_varadero/auto_sand_rock_nv.dmi'
	icon_state = "rock_0"
	icon_prefix = "rock_0"
	layer_name = list("ground", "rocky ground")
	desc = "peculiar set of rocks formed into hexagonal pattern."

/turf/open/auto_turf/ground_rock_column/layer0
	icon_state = "rock_0"
	bleed_layer = 0
	variant_prefix_name = "rocky ground"

/turf/open/auto_turf/ground_rock_column/layer1
	icon_state = "rock_1"
	bleed_layer = 1

/turf/open/auto_turf/varadero_white_sand_alt
	name = "sand"
	icon = 'icons/turf/floors/new_varadero/white_auto_sand.dmi'
	icon_state = "sand_0"
	icon_prefix = "sand_0"
	layer_name = list("ground", "loose sand", "loose sand")
	desc = "sand mixed with small rocks compacted tightly together by other means."

/turf/open/auto_turf/varadero_white_sand_alt/layer0
	icon_state = "sand_0"
	bleed_layer = 0
	variant_prefix_name = "loose sand"

/turf/open/auto_turf/varadero_white_sand_alt/layer1
	icon_state = "sand_1"
	bleed_layer = 1
	variant_prefix_name = "loose sand"

/turf/open/auto_turf/varadero_white_sand_alt/layer2
	icon_state = "sand_1_1"
	bleed_layer = 2
	variant_prefix_name = "loose sand"

/turf/open/auto_turf/varadero_water_transit
	name = "deep water transition"
	icon = 'icons/turf/floors/new_varadero/seadeep_auto_turf_stuff.dmi'
	icon_state = "seadeep_0"
	icon_prefix = "seadeep_0"
	layer_name = list("sea water", "deep water transition")

/turf/open/auto_turf/varadero_water_transit/layer0
	icon_state = "seadeep_0"
	bleed_layer = 0
	variant_prefix_name = "sea water"

/turf/open/auto_turf/varadero_water_transit/layer1
	icon_state = "seadeep_1"
	bleed_layer = 1

/turf/open/nostromowater/cave_water
	name = "cave water"
	desc = "Icy cold water, it seems to have pooled into a natural divet in the cave floor."

/turf/open/shuttle/escapepod/floor0/north/west
	dir = WEST

/turf/open/shuttle/escapepod/floor2/north
	dir = NORTH

/turf/open/shuttle/escapepod/floor2/east
	dir = EAST

/turf/open/shuttle/escapepod/floor2/west
	dir = WEST
