/turf/open/auto_turf/irvine_grass
	name = "matted grass"
	icon = 'icons/turf/floors/auto_forest_irvine.dmi'
	icon_state = "grass_1"
	icon_prefix = "grass"
	layer_name = list("ground", "lush thick grass")
	desc = "grass, dirt, mud, and other assorted high moisture cave flooring."

/turf/open/auto_turf/irvine_grass/insert_self_into_baseturfs()
	baseturfs += /turf/open/auto_turf/irvine_grass/layer0_mud

/turf/open/auto_turf/irvine_grass/layer0_mud
	icon_state = "grass_0_mud"
	bleed_layer = 0
	variant = "mud"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/irvine_grass/layer0_mud_alt
	icon_state = "grass_0_mud_alt"
	bleed_layer = 0
	variant = "mud_alt"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/irvine_grass/layer0_mud_heavy
	icon_state = "grass_0_mud_heavy"
	bleed_layer = 0
	variant = "mud_alt"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/irvine_grass/layer0_mud_heavy_alt
	icon_state = "grass_0_mud_heavy_alt"
	bleed_layer = 0
	variant = "mud_alt"
	variant_prefix_name = "muddy"

/turf/open/auto_turf/irvine_grass/layer1
	icon_state = "grass_1"
	bleed_layer = 1
