// From source/pr203:code/game/area/areas.dm
/area/sky
	name = "Sky"
	icon_state = "lv-626"
	flags_area = AREA_UNWEEDABLE

// From source/pr203:code/game/machinery/colony_floodlights.dm
/obj/structure/machinery/colony_floodlight/alt
	icon_state = "alt_flood_s_off"

// From source/pr203:code/game/machinery/colony_floodlights.dm
/obj/structure/machinery/colony_floodlight/alt/update_icon()
	if(damaged)
		icon_state = "alt_flood_s_dmg"
	else if(is_on)
		icon_state = "alt_flood_s_on"
	else
		icon_state = "alt_flood_s_off"

// From source/pr203:code/game/machinery/computer/arcade.dm
/obj/structure/machinery/computer/arcade/green_stripe

	icon_state = "arcade_greenstripe"

// From source/pr203:code/game/machinery/computer/arcade.dm
/obj/structure/machinery/computer/arcade/blue_stripe

	icon_state = "arcade_bluestripe"

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/solid
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/single_door_solid.dmi'
	openspeed = 4 //shorter open animation.

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/solid/autoname
	autoname = TRUE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/glass
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/single_glass_door_teal.dmi'
	opacity = FALSE
	glass = TRUE
	openspeed = 4 //shorter open animation.

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/glass/autoname
	autoname = TRUE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/glass/orange
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/single_glass_door_orange.dmi'
	opacity = FALSE
	glass = TRUE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/glass/orange/autoname
	autoname = TRUE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/glass/red
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/single_glass_door_red.dmi'
	opacity = FALSE
	glass = TRUE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/almayer/lavaland/glass/red/autoname
	autoname = TRUE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/prison/alt
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/celldoor_alt.dmi'
	glass = FALSE

// From source/pr203:code/game/machinery/doors/airlock_types.dm
/obj/structure/machinery/door/airlock/prison/alt/autoname
	autoname = TRUE

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/double_glass_door_teal.dmi'
	opacity = FALSE
	glass = TRUE
	openspeed = 4 //shorter open animation.
	req_one_access = null

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE
	req_one_access = null

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/orange
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/double_glass_door_orange.dmi'
	opacity = FALSE
	glass = TRUE

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/orange/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/red
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/double_glass_door_red.dmi'
	opacity = FALSE
	glass = TRUE

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/red/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/solid
	name = "Secure Airlock"
	icon = 'icons/obj/structures/doors/lava/double_door_solid.dmi'
	opacity = TRUE
	glass = FALSE
	openspeed = 4 //shorter open animation.

// From source/pr203:code/game/machinery/doors/multi_tile.dm
/obj/structure/machinery/door/airlock/multi_tile/lavaland/black_double/solid/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE

// From source/pr203:code/game/machinery/doors/poddoor/almayer.dm
/obj/structure/machinery/door/poddoor/almayer/dark/closed
	name = "\improper Lockdown"
	icon_state = "darkdoor1"
	base_icon_state = "darkdoor"
	density = TRUE
	opacity = TRUE

// From source/pr203:code/game/machinery/doors/poddoor/almayer.dm
/obj/structure/machinery/door/poddoor/almayer/dark/open
	name = "\improper Lockdown"
	icon_state = "darkdoor1"
	base_icon_state = "darkdoor"
	density = FALSE
	opacity = FALSE

// From source/pr203:code/game/machinery/doors/poddoor/poddoor.dm
/obj/structure/machinery/door/poddoor/hybrisa/secure_red_door/open
	density = FALSE

// From source/pr203:code/game/machinery/fusion_engine.dm
/obj/structure/machinery/power/reactor/colony/alt
	icon = 'icons/obj/structures/machinery/fusion_eng.dmi'

#undef BUILDSTATE_FUNCTIONAL
#undef BUILDSTATE_DAMAGE_WELD
#undef BUILDSTATE_DAMAGE_WIRE
#undef BUILDSTATE_DAMAGE_WRENCH
#undef REACTOR_FAIL_CHECK_TICKS

// From source/pr203:code/game/machinery/newscaster.dm
/obj/structure/machinery/newscaster/seegson
	name = "newscaster"
	desc = "A standard newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/structures/machinery/terminals.dmi'
	icon_state = "altnewscaster_normal"
	anchored = TRUE

// From source/pr203:code/game/machinery/rechargestation.dm
/obj/structure/machinery/recharge_station/alt
	icon = 'icons/obj/structures/machinery/synth_repair_station.dmi'

// From source/pr203:code/game/machinery/vending/vending_types.dm
/obj/structure/machinery/vending/snack/generic
	name = "\improper Hot Foods Machine"
	desc = "A vending machine full of ready to cook meals, mhmmmm taste the nutritional goodness!"
	product_slogans = "Kepler Crisps! Try a snack that's out of this world!;Eat an EAT!;Eat a delicious packaged hamburger.;Eat a scrumptious packaged hot dog.;Eat a delightful packaged burrito.;"
	product_ads = "Kepler Crisps! Try a snack that's out of this world!;Eat an EAT!"
	icon_state = "snack_seeg"
	products = list(
		/obj/item/reagent_container/food/snacks/packaged_burger/unbranded = 4,
		/obj/item/reagent_container/food/snacks/packaged_burrito/unbranded = 2,
		/obj/item/reagent_container/food/snacks/packaged_hdogs/unbranded =1,
	)

	prices = list(
		/obj/item/reagent_container/food/snacks/packaged_burger/unbranded = 5,
		/obj/item/reagent_container/food/snacks/packaged_burrito/unbranded = 5,
		/obj/item/reagent_container/food/snacks/packaged_hdogs/unbranded = 5,
	)
	product_type = VENDOR_PRODUCT_TYPE_FOOD

// From source/pr203:code/game/machinery/vending/vending_types.dm
/obj/structure/machinery/vending/cola/generic
	name = "\improper Souto Softdrinks"
	desc = "A softdrink vendor provided by Souto Soda Company, Havana."
	icon_state = "soda_seeg"
	product_slogans = "Souto Soda: Have a Souto and be taken away to a tropical paradise!;Souto Classic. You can't beat that tangerine goodness!;Souto Cherry. The sweet flavor of a cool winter morning!;Souto Lime. For that sweet and sour flavor that you know and love!;Souto Grape. There's nothing better than a grape soda.;Weyland-Yutani Fruit Beer. Nothing came from that lawsuit!"
	product_ads = "Souto Classic. You can't beat that tangerine goodness!;Souto Cherry. The sweet flavor of a cool winter morning!;Souto Lime. For that sweet and sour flavor that you know and love!;Souto Grape. There's nothing better than a grape soda.;Weyland-Yutani Fruit Beer. Nothing came from that lawsuit!"
	products = list(
		/obj/item/reagent_container/food/drinks/cans/souto/classic = 3,
		/obj/item/reagent_container/food/drinks/cans/souto/cherry = 4,
		/obj/item/reagent_container/food/drinks/cans/souto/lime = 2,
		/obj/item/reagent_container/food/drinks/cans/souto/grape = 1,
		/obj/item/reagent_container/food/drinks/cans/souto/blue = 2,
		/obj/item/reagent_container/food/drinks/cans/souto/peach = 3,
		/obj/item/reagent_container/food/drinks/cans/souto/cranberry = 4,
		/obj/item/reagent_container/food/drinks/cans/souto/vanilla = 2,
		/obj/item/reagent_container/food/drinks/cans/souto/pineapple = 3,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/classic = 1,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/cherry = 2,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/lime = 3,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/grape = 2,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/blue = 1,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/peach = 2,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/cranberry = 4,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/vanilla = 1,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/pineapple = 4,
		/obj/item/reagent_container/food/drinks/cans/cola = 4,
	)

	prices = list(
		/obj/item/reagent_container/food/drinks/cans/souto/classic = 8,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/classic = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/cherry = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/cherry = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/lime = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/lime = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/grape = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/grape = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/blue = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/blue = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/peach = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/peach = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/cranberry = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/cranberry = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/vanilla = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/vanilla = 12,
		/obj/item/reagent_container/food/drinks/cans/souto/pineapple = 9,
		/obj/item/reagent_container/food/drinks/cans/souto/diet/pineapple = 12,
		/obj/item/reagent_container/food/drinks/cans/cola = 20,
	)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	product_type = VENDOR_PRODUCT_TYPE_SOUTO

// From source/pr203:code/game/objects/effects/decals/cleanable/blood/robots.dm
/obj/effect/decal/cleanable/blood/synth
	name = "artificial blood"
	desc = "A thick white fluid that serves as blood for synthetic beings. It smells faintly chemical."
	icon = 'icons/effects/blood.dmi'
	amount = 1
	color = "#EEEEEE"

// From source/pr203:code/game/objects/effects/decals/cleanable/misc.dm
/obj/effect/broken_tile
	icon = 'icons/effects/broken_tiles.dmi'
	icon_state = "triple"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/objects/effects/decals/cleanable/misc.dm
/obj/effect/broken_tile/double
	icon_state = "double"

// From source/pr203:code/game/objects/effects/decals/cleanable/misc.dm
/obj/effect/broken_tile/single
	icon_state = "single"

// From source/pr203:code/game/objects/effects/decals/cleanable/misc.dm
/obj/effect/broken_tile/angle
	icon_state = "angle"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/seegson
	name = "Seegson Corporation"
	icon = 'icons/effects/seegson_logo.dmi'
	icon_state = "seegson_logo"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/seegson/worn
	icon_state = "seegson_logo_worn"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/seegson/small
	icon = 'icons/effects/seegson_small.dmi'
	icon_state = "seegson_logo"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/seegson/small/worn
	icon_state = "seegson_logo_worn"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/seegson/small/lone
	icon_state = "seegson_lone"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/seegson/small/lone/worn
	icon_state = "seegson_lone_worn"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/lasalle_bio
	name = "Lasalle Bionational Corporation"
	icon = 'icons/effects/lasalle_logo.dmi'
	icon_state = "lasalle_logo"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/lasalle_bio/worn
	icon_state = "lasalle_logo_worn"

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/engineer_ruins
	icon = 'icons/effects/engineercircle.dmi'
	icon_state = "circle_combined"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/objects/effects/decals/floor_symbol.dm
/obj/effect/decal/engineer_ruins/individual
	icon_state = "circle1"

// From source/pr203:code/game/objects/effects/decals/hybrisa_decals.dm
/obj/effect/decal/hybrisa/checkpoint_decal/only_security
	icon = 'icons/effects/64x64hybrisa_decals.dmi'
	icon_state = "checkpoint_decal_only"

// From source/pr203:code/game/objects/effects/decals/hybrisa_decals.dm
/obj/effect/decal/hybrisa/dirt/above_turf_decal
	icon = 'icons/effects/hybrisa_decals.dmi'
	icon_state = "dirt"
	layer = WALL_LAYER

// From source/pr203:code/game/objects/effects/landmarks/ambient_sounds.dm
/obj/effect/landmark/ambient_sound
	name = "ambient sound"
	icon = 'icons/landmarks.dmi'
	icon_state = "sound"

	var/list/sound_list = list()
	var/min_delay = 30 SECONDS
	var/max_delay = 90 SECONDS
	var/volume = 35
	var/min_volume = 35
	var/vary = TRUE
	var/play_chance = 100
	var/sound_radius = 7
	var/play_once = FALSE

// From source/pr203:code/game/objects/effects/landmarks/ambient_sounds.dm
/obj/effect/landmark/ambient_sound/Initialize(mapload)
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(play_random_sound)), rand(min_delay, max_delay))

// From source/pr203:code/game/objects/effects/landmarks/ambient_sounds.dm
/obj/effect/landmark/ambient_sound/lava
	name = "lava ambience" // For the lava rivers and pools

	sound_list = list(
		'sound/ambience/lava/lava_river/lava_1.ogg',
		'sound/ambience/lava/lava_river/lava_2.ogg',
		'sound/ambience/lava/lava_river/lava_3.ogg',
		'sound/ambience/lava/lava_river/lava_4.ogg',
		'sound/ambience/lava/lava_river/lava_5.ogg',
		'sound/ambience/lava/lava_river/lava_6.ogg',
		'sound/ambience/lava/lava_river/lava_7.ogg',
		'sound/ambience/lava/lava_river/lava_8.ogg',
		'sound/ambience/lava/lava_river/lava_9.ogg',
		'sound/ambience/lava/lava_river/lava_10.ogg',
		'sound/ambience/lava/lava_river/lava_11.ogg',
		'sound/ambience/lava/lava_river/lava_12.ogg',
		'sound/ambience/lava/lava_river/lava_13.ogg',
		'sound/ambience/lava/lava_river/lava_14.ogg',
		'sound/ambience/lava/lava_river/lava_15.ogg',
		'sound/ambience/lava/lava_river/lava_16.ogg',
		'sound/ambience/lava/lava_river/lava_17.ogg',
		'sound/ambience/lava/lava_river/lava_18.ogg',
		'sound/ambience/lava/lava_river/lava_19.ogg',
		'sound/ambience/lava/lava_river/lava_20.ogg',
		'sound/ambience/lava/lava_river/lava_21.ogg',
		'sound/ambience/lava/lava_river/lava_22.ogg',
		'sound/ambience/lava/lava_river/lava_23.ogg',
		'sound/ambience/lava/lava_river/lava_24.ogg',
		'sound/ambience/lava/lava_river/lava_25.ogg',
	)

	min_delay = 6 SECONDS
	max_delay = 18 SECONDS
	min_volume = 15
	volume = 55
	sound_radius = 5
	play_chance = 80

// From source/pr203:code/game/objects/effects/landmarks/corpsespawner.dm
/obj/effect/landmark/corpsespawner/working_joe
	name = "Deactivated Working Joe"
	equip_path = /datum/equipment_preset/corpse/working_joe

// From source/pr203:code/game/objects/effects/landmarks/corpsespawner.dm
/obj/effect/landmark/corpsespawner/working_joe/fireproof
	name = "Deactivated Working Joe"
	equip_path = /datum/equipment_preset/corpse/working_joe/fireproof

// From source/pr203:code/game/objects/effects/landmarks/corpsespawner.dm
/obj/effect/landmark/corpsespawner/upp_spy
	name = "Corpse - Suspicious Colonist"
	equip_path = /datum/equipment_preset/corpse/upp_spy

// From source/pr203:code/game/objects/items/devices/flashlight.dm
/obj/item/device/flashlight/lamp/tripod/off
	on = 0

// From source/pr203:code/game/objects/items/devices/flashlight.dm
/obj/item/device/flashlight/lamp/tripod/grey/off
	on = 0

// From source/pr203:code/game/objects/items/frames/table_rack.dm
/obj/item/frame/rack/long
	icon_state = "longrack_parts"

// From source/pr203:code/game/objects/items/misc.dm
/obj/item/clock
	name = "digital clock"
	desc = "A battery powered clock, able to keep time within about 5 seconds... it was never that accurate."
	icon = 'icons/obj/items/devices.dmi'
	icon_state = "digital_clock"
	force = 3
	throwforce = 2
	throw_range = 4
	w_class = SIZE_SMALL

// From source/pr203:code/game/objects/items/misc.dm
/obj/item/clock/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("The [name] reads: [GLOB.current_date_string] - [worldtime2text()]")

// From source/pr203:code/game/objects/items/reagent_containers/food/drinks.dm
/obj/item/reagent_container/food/drinks/coffeecup/alt
	icon_state = "coffeecupblue"
	item_state = "coffeecupblue"

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burrito
	name = "Packaged Burrito"
	desc = "A hard microwavable burrito. There's no time given for how long to cook it. Packaged by the Weyland-Yutani Corporation."
	icon_state = "packaged-burrito"
	item_state = "pburrito"
	bitesize = 2
	package = 1
	flags_obj = OBJ_NO_HELMET_BAND|OBJ_IS_HELMET_GARB

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burrito/Initialize()
	. = ..()
	reagents.add_reagent("bread", 5)
	reagents.add_reagent("meatprotein", 5)

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burrito/attack_self(mob/user)
	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, SPAN_NOTICE("You pull off the wrapping from the squishy burrito!"))
		package = 0
		user.put_in_hands(new /obj/item/trash/buritto)
		icon_state = "open-burrito"
		item_state = "burrito"
		return
	..()

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burrito/unbranded
	desc = "A hard microwavable burrito. There's no time given for how long to cook it."
	icon_state = "unbranded_packaged-burrito"
	item_state = "unbranded_pburrito"

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burrito/unbranded/attack_self(mob/user)
	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, SPAN_NOTICE("You pull off the wrapping from the squishy burrito!"))
		package = 0
		user.put_in_hands(new /obj/item/trash/buritto/alt)
		icon_state = "open-burrito"
		item_state = "unbranded_burrito"
		return
	..()

// From source/pr203:code/game/objects/items/reagent_containers/food/snacks.dm
/obj/item/reagent_container/food/snacks/packaged_burrito/unbranded/Initialize()
	. = ..()
	reagents.add_reagent("bread", 5)
	reagents.add_reagent("meatprotein", 5)

// From source/pr203:code/game/objects/items/stacks/sheets/sheet_types.dm
/obj/item/stack/sheet/pyrotrinium
	name = "pyrotrinium"
	desc = "Refined from heat-resistant crystalline deposits, pyrotrinium is a dull red alloy prized for its exceptional thermal stability and conductivity. It is commonly used in reactor housings, power systems, and high-stress industrial equipment where conventional metals would fail."
	singular_name = "pyrotrinium sheet"
	icon_state = "sheet-pyrotrinium"
	sheettype = "pyrotrinium"
	stack_id = "pyrotrinium"
	item_state = "sheet-metal"
	throwforce = 14
	amount_sprites = TRUE

	black_market_value = 15

// From source/pr203:code/game/objects/items/stacks/sheets/sheet_types.dm
/obj/item/stack/sheet/pyrotrinium/small_stack
	amount = STACK_10

// From source/pr203:code/game/objects/items/storage/briefcase.dm
/obj/item/storage/briefcase/flap
	name = "flap-closure brown briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional. This one is less rigid, made with a flap and softer leather."
	icon_state = "briefcase_d"
	item_state = "briefcase_d"

// From source/pr203:code/game/objects/items/tools/cleaning_tools.dm
/obj/item/tool/warning_cone/blue // utility work.
	icon_state = "cone_blue"

// From source/pr203:code/game/objects/items/tools/cleaning_tools.dm
/obj/item/tool/warning_cone/red // extreme danger or restricted area.
	icon_state = "cone_red"

// From source/pr203:code/game/objects/items/tools/cleaning_tools.dm
/obj/item/tool/warning_cone/green // various or good to pass.
	icon_state = "cone_green"

// From source/pr203:code/game/objects/items/tools/misc_tools.dm
/obj/item/tool/pen/multicolor
	name = "multicolor pen"
	desc = "A color switching pen!"
	var/list/colour_list = list("red", "blue", "black")
	var/current_colour_index = 1

// From source/pr203:code/game/objects/items/tools/misc_tools.dm
/obj/item/tool/pen/multicolor/attack_self(mob/living/carbon/human/user)
	if(!on)
		return ..()

	current_colour_index = (current_colour_index % length(colour_list)) + 1
	pen_color = colour_list[current_colour_index]
	balloon_alert(user, "changed to [pen_color]")
	to_chat(user, SPAN_NOTICE("you twist the pen and change the ink color to [pen_color]."))
	if(clicky)
		playsound(user.loc, 'sound/items/pen_click_on.ogg', 100, 1, 5)
	update_pen_state()

// From source/pr203:code/game/objects/items/tools/misc_tools.dm
/obj/item/tool/pen/multicolor/fountain
	desc = "A lavish testament to the ingenuity of Armat's craftsmanship, this fountain pen is a paragon of design and functionality. Detailed with golden accents and intricate mechanics, the pen allows for a swift change between a myriad of ink colors with a simple twist. A product of precision engineering, each mechanism inside the pen is designed to provide a seamless, effortless transition from one color to the next, creating an instrument of luxurious versatility."
	desc_lore = "More than just a tool for writing, Armat's fountain pen is a symbol of distinction and authority within the ranks of the United States Colonial Marine Corps (USCM). It is a legacy item, exclusively handed out to the top-tier command personnel, each pen a tribute to the recipient's leadership and dedication.\n \nArmat, renowned for their weapons technology, took a different approach in crafting this piece. The fountain pen, though seemingly a departure from their usual field, is deeply ingrained with the company's engineering philosophy, embodying precision, functionality, and robustness.\n \nThe golden accents are not mere embellishments; they're an identifier, setting apart these pens and their owners from the rest. The gold is meticulously alloyed with a durable metallic substance, granting it resilience to daily wear and tear. Such resilience is symbolic of the tenacity and perseverance required of USCM command personnel.\n \nEach pen is equipped with an intricate color changing mechanism, allowing the user to switch between various ink colors. This feature, inspired by the advanced targeting systems of Armat's weaponry, uses miniaturized actuators and precision-ground components to smoothly transition the ink flow. A simple twist of the pen's body activates the change, rotating the internal ink cartridges into place with mechanical grace, ready for the user's command.\n \nThe ink colors are not chosen arbitrarily. Each represents a different echelon within the USCM, allowing the pen's owner to write in the hue that corresponds with their rank or the rank of the recipient of their written orders. This acts as a silent testament to the authority of their words, as if each stroke of the pen echoes through the halls of USCM authority.\n \nDespite its ornate appearance, the pen is as robust as any Armat weapon, reflecting the company's commitment to reliability and durability. The metal components are corrosion-resistant, ensuring the pen's longevity, even under the challenging conditions often faced by USCM high command.\n \nThe fusion of luxury and utility, the blend of gold and metal, is an embodiment of the hard-won elegance of command, of the fusion between power and grace. It's more than a writing instrument - it's an emblem of leadership, an accolade to the dedication and strength of those who bear it. Armat's fountain pen stands as a monument to the precision, integrity, and courage embodied by the USCM's highest-ranking officers."
	name = "fountain pen"
	icon_state = "fountain_pen"
	item_state = "fountain_pen"
	item_state_slots = list(WEAR_AS_GARB = "fountain_pen")
	matter = list("metal" = 20, "gold" = 10)
	colour_list = list("red", "blue", "green", "yellow", "purple", "pink", "brown", "black", "orange") // Can add more colors as required

// From source/pr203:code/game/objects/items/trash.dm
/obj/item/trash/burger/alt
	name = "Burger wrapper"
	icon_state = "unbranded_burger"
	desc = "A greasy plastic film that once held a Cheeseburger."

// From source/pr203:code/game/objects/items/trash.dm
/obj/item/trash/buritto/alt
	name = "Burrito wrapper"
	icon_state = "unbranded_burrito"
	desc = "A foul-smelling plastic film that once held a microwave burrito."

// From source/pr203:code/game/objects/items/weapons/swords_axes_etc.dm
/obj/item/weapon/classic_baton/alt
	icon_state = "baton_alt"
	item_state = "classic_baton_alt"

// From source/pr203:code/game/objects/prop.dm
/obj/item/prop/colony/canister/alt_1
	icon_state = "canister_alt1"

// From source/pr203:code/game/objects/prop.dm
/obj/item/prop/colony/canister/alt_2
	icon_state = "canister_alt2"

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/invuln/dense/excavator/gray_alt
	desc = "A Model 30 Light Excavator. Despite looking like a massive beast, the Model 30 is fairly light when compared to other terraforming excavators. It's designed to be able to be disassembled for transport and re-assembled on site. This one is a nice gray color."
	icon_state = "generic_digger_gray"

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/invuln/dense/excavator/yellow
	desc = "A Model 30 Light Excavator. Despite looking like a massive beast, the Model 30 is fairly light when compared to other terraforming excavators. It's designed to be able to be disassembled for transport and re-assembled on site. This one is a nice yellow color."
	icon_state = "generic_digger_yellow"

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/huge_mining_machine/smelter
	name = "industrial smelting furnace"
	desc = "A colossal custom Seegson-designed smelting furnace engineered for specific industrial processing, used primarily to reduce raw pyrotrinium ore into a molten form. It's frame and heat-scarred plating reflect Seegson's preference for cheap, but functional machinery."
	icon = 'icons/obj/structures/props/industrial/huge_mining_machines.dmi'
	icon_state = "smelter_machine"
	density = TRUE
	anchored = TRUE
	bound_width = 128
	bound_height = 96

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/huge_mining_machine/smelter/invun
	unacidable = TRUE
	unslashable = TRUE
	breakable = FALSE
	explo_proof = TRUE

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/huge_mining_machine/refinery
	name = "industrial smelting refinery"
	desc = "A massive custom Seegson-designed refinery press built to compress molten pyrotrinium into uniform slabs for transport and industrial use. It's frame and heat-scarred plating reflect Seegson's preference for cheap, but functional machinery."
	icon = 'icons/obj/structures/props/industrial/huge_mining_machines.dmi'
	icon_state = "press_machine"
	density = TRUE
	anchored = TRUE
	bound_width = 96
	bound_height = 128

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/huge_mining_machine/refinery/invun
	unacidable = TRUE
	unslashable = TRUE
	breakable = FALSE
	explo_proof = TRUE

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/huge_mining_machine/conveyor
	icon = 'icons/obj/structures/props/industrial/conveyor.dmi'
	icon_state = "conveyor"
	name = "conveyor belt"
	desc = "A large conveyor belt used in industrial facilities."
	projectile_coverage = FALSE
	density = FALSE
	layer = TURF_LAYER

// From source/pr203:code/game/objects/prop.dm
/obj/structure/prop/huge_mining_machine/conveyor/variation
	icon_state = "conveyor1"

// From source/pr203:code/game/objects/structures/bedsheet_bin.dm
/obj/item/bedsheet/bedroll
	icon_state = "bedroll_sheet"

// From source/pr203:code/game/objects/structures/bedsheet_bin.dm
/obj/item/bedsheet/bedroll/blue
	icon_state = "bedroll_sheet"
	color = "#8cb9e2"

// From source/pr203:code/game/objects/structures/bedsheet_bin.dm
/obj/item/bedsheet/bedroll/pink
	icon_state = "bedroll_sheet"
	color = "#eaa8b2"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/seegson/alt/left
	icon_state = "seegson_alt_l"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/seegson/alt/mid
	icon_state = "seegson_alt_m"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/seegson/alt/right
	icon_state = "seegson_alt_r"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/seegson/white/left
	icon_state = "seegson_alt2_l"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/seegson/white/mid
	icon_state = "seegson_alt2_m"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/seegson/white/right
	icon_state = "seegson_alt2_r"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle
	name = "Lasalle Bionational Corporation Cargo Container"
	desc = "A huge industrial shipping container.\nThis one is from Lasalle Bionational, they are known for their radiation-resistant crops and bioengineered livestock."

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/left
	icon_state = "lasa_l"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/mid
	icon_state = "lasa_m"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/right
	icon_state = "lasa_r"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/alt_1/left
	icon_state = "lasa1_l"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/alt_1/mid
	icon_state = "lasa1_m"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/alt_1/right
	icon_state = "lasa1_r"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/alt_2/left
	icon_state = "lasa2_l"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/alt_2/mid
	icon_state = "lasa2_m"

// From source/pr203:code/game/objects/structures/cargo_container.dm
/obj/structure/cargo_container/lasalle/alt_2/right
	icon_state = "lasa2_r"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/l3closet.dm
/obj/structure/closet/bionational_closet
	name = "Lasalle Bionational biohazard suit closet"
	desc = "It's a storage unit for Lasalle Bionational biohazard gear."
	icon_state = "bion"
	icon_closed = "bion"
	icon_opened = "bionopen"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/l3closet.dm
/obj/structure/closet/bionational_closet/Initialize()
	. = ..()
	new /obj/item/clothing/accessory/patch/lasalle( src )
	new /obj/item/clothing/suit/bio_suit/lasalle( src )
	new /obj/item/clothing/head/bio_hood/lasalle( src )
	new /obj/item/clothing/mask/gas/pmc/lasalle( src )

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt
	name = "\improper refrigerator"
	icon_state = "altfridge1"
	icon_closed = "altfridge"
	icon_locked = "altfridge1"
	icon_opened = "altfridgeopen"
	icon_broken = "altfridgebroken"
	icon_off = "altfridge1"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt/fridge/full
	name = "\improper refrigerator"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt/fridge/full/Initialize()
	. = ..()
	for(var/i = 0, i < 2, i++)
		new /obj/item/reagent_container/food/condiment/sugar(src)
	for(var/i = 0, i < 6, i++)
		new /obj/item/reagent_container/food/snacks/flour(src)
		new /obj/item/reagent_container/food/condiment/enzyme(src)
		new /obj/item/reagent_container/food/condiment/chocolate_syrup(src)

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt_1
	name = "\improper refrigerator"
	icon_state = "alt1fridge1"
	icon_closed = "alt1fridge"
	icon_locked = "alt1fridge1"
	icon_opened = "alt1fridgeopen"
	icon_broken = "alt1fridgebroken"
	icon_off = "alt1fridge1"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt_1/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt_1/fridge/full
	name = "\improper refrigerator"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/freezer.dm
/obj/structure/closet/secure_closet/freezer/alt_1/fridge/full/Initialize()
	. = ..()
	for(var/i = 0, i < 2, i++)
		new /obj/item/reagent_container/food/condiment/sugar(src)
	for(var/i = 0, i < 6, i++)
		new /obj/item/reagent_container/food/snacks/flour(src)
		new /obj/item/reagent_container/food/condiment/enzyme(src)
		new /obj/item/reagent_container/food/condiment/chocolate_syrup(src)

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/security.dm
/obj/structure/closet/secure_closet/seegson/security
	name = "Seegson Security locker"
	icon_state = "secure_yalt_locked_warrant"
	icon_closed = "secure_yalt_unlocked_warrant"
	icon_locked = "secure_yalt_locked_warrant"
	icon_opened = "secure_yalt_open_warrant"
	icon_broken = "secure_yalt_locked_warrant"
	icon_off = "secure_yalt_closed_warrant"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/secure/security.dm
/obj/structure/closet/secure_closet/seegson/security/Initialize()
	. = ..()
	new /obj/item/clothing/head/helmet/marine/veteran/pmc/corporate/seegson(src)
	new /obj/item/clothing/suit/armor/vest/seegson_security(src)
	new /obj/item/clothing/under/marine/seegson_security(src)
	new /obj/item/storage/backpack/lightpack/five_slot(src)
	new /obj/item/clothing/shoes/marine/corporate(src)
	new /obj/item/clothing/accessory/patch/seegson(src)
	new /obj/item/weapon/classic_baton/alt(src)

// From source/pr203:code/game/objects/structures/crates_lockers/closets/utility_closets.dm
/obj/structure/closet/firecloset/alt
	name = "advanced fire-safety closet"
	desc = "It's a storage unit for advanced fire-resistance gear."
	icon_state = "firecloset_alt"
	icon_closed = "firecloset_alt"
	icon_opened = "firecloset_altopen"

// From source/pr203:code/game/objects/structures/crates_lockers/closets/utility_closets.dm
/obj/structure/closet/firecloset/alt/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

// From source/pr203:code/game/objects/structures/crates_lockers/crates.dm
/obj/structure/closet/crate/trashcart/alt
	name = "trash cart"
	desc = "A heavy, metal trashcart with wheels."
	icon_state = "closed_trashcart_alt"
	icon_opened = "open_trashcart_alt"
	icon_closed = "closed_trashcart_alt"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins
	icon = 'icons/obj/structures/props/engineers/engineerpillar.dmi'
	icon_state = "pillar_tall"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars
	icon = 'icons/obj/structures/props/engineers/engineerpillar.dmi'
	icon_state = "pillar_tall"
	layer = BIG_XENO_LAYER
	density = TRUE

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars/tall
	name = "pillar"
	desc = "A huge stone pillar"
	icon = 'icons/obj/structures/props/engineers/engineerpillar.dmi'
	icon_state = "pillar_tall"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars/short
	name = "pillar"
	desc = "A stone pillar"
	icon = 'icons/obj/structures/props/engineers/engineerpillar.dmi'
	icon_state = "pillar_short"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars/fallen
	name = "broken pillar"
	desc = "A broken stone pillar"
	icon = 'icons/obj/structures/props/engineers/engineerpillar_fallen.dmi'
	icon_state = "pillar_fallen"
	projectile_coverage = 10
	throwpass = TRUE

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars/fallen/damaged
	icon_state = "pillar_damage"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars/fallen/fallen_long
	icon_state = "pillar_fallen_long"
	bound_width = 64
	bound_height = 32

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/pillars/fallen/fallen_middle
	icon_state = "pillar_fallen_middle"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/bench
	icon = 'icons/obj/structures/props/engineers/engineerbench.dmi'
	icon_state = "stonebench"
	layer = BELOW_MOB_LAYER
	density = FALSE

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/bench/bench_end
	icon_state = "stonebench1"

// From source/pr203:code/game/objects/structures/engineer_props.dm
/obj/structure/prop/engineer_ruins/large_pit
	name = "pit"
	desc = "A circular stone structure with a seemingly endless dark pit in the center. Gaze long enough into the abyss, the abyss will gaze back into you..."
	icon = 'icons/obj/structures/props/engineers/engineerpit.dmi'
	icon_state = "pit"
	explo_proof = TRUE
	unacidable = TRUE
	unslashable = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/fence/slim
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/structures/props/fences/fence_alt.dmi'

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/fence/slim/blue
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/structures/props/fences/fence_alt.dmi'
	color = "#8d93a1ff"

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/fence/slim/blue/door
	name = "fence door"
	desc = "A sturdy chainlink door set between two metal poles. A cheap way to section off areas while still allowing visibility through it."
	icon_state = "door_closed"
	color = "#8d93a1ff"
	door = TRUE
	forms_junctions = FALSE
	icon = 'icons/obj/structures/props/fences/fence_alt_door.dmi'

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/prop/fence
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon_state = "special_brokenfence1"
	icon = 'icons/obj/structures/props/fences/fence.dmi'
	density = FALSE
	layer = WINDOW_LAYER
	minimap_color = MINIMAP_FENCE

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/prop/fence/attackby(obj/item/W, mob/living/user)
	// Any sufficiently sharp knife/blade destroys instantly
	if(W.sharp >= IS_SHARP_ITEM_SIMPLE)
		user.animation_attack_on(src)
		to_chat(user, SPAN_WARNING("You cut \the [src] with \the [W]."))
		playsound(src, 'sound/items/Wirecutter.ogg', 25, 1)
		qdel(src)
		return ATTACKBY_HINT_UPDATE_NEXT_MOVE
	else
		. = ..()

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/prop/fence/slim
	icon = 'icons/obj/structures/props/fences/fence_alt.dmi'

// From source/pr203:code/game/objects/structures/fence.dm
/obj/structure/prop/fence/slim/blue
	icon = 'icons/obj/structures/props/fences/fence_alt.dmi'
	color = "#8d93a1ff"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/jungle/thickbush/large_jungle_bush
	name = "bush"
	desc = "A large jungle bush, it'll take something sharp and a lot of determination to clear away."
	icon = 'icons/obj/structures/props/natural/vegetation/colorable_junge_bush.dmi'
	icon_state = "bush1"
	density = FALSE
	layer = ABOVE_XENO_LAYER
	fire_flag = FLORA_BURN_NO_SPREAD
	health = 100

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/jungle/thickbush/large_jungle_bush/attack_alien(mob/living/carbon/xenomorph/current_xenomorph)
	if(unslashable)
		return XENO_NO_DELAY_ACTION
	current_xenomorph.animation_attack_on(src)
	playsound(src, 'sound/effects/vegetation_hit.ogg', 25, 1)
	current_xenomorph.visible_message(SPAN_DANGER("[current_xenomorph] slashes at [src]!"),
	SPAN_DANGER("You slash at [src]!"), null, 5, CHAT_TYPE_XENO_COMBAT)
	update_health(rand(current_xenomorph.melee_damage_lower, current_xenomorph.melee_damage_upper))
	return XENO_ATTACK_ACTION

//REDEMPTION VALLEY//

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/bush/ausbushes/ywflowers
	icon_state = "ywflowers_1"
	icon_tag = "ywflowers"
	layer = BELOW_MOB_LAYER

/*

	AUSBUSHES (3 VARIATIONS)

*/

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien
	name = "ashrose tree"
	desc = "Commonly known as the 'Ashrose Tree', this tall xenoflora is adapted to hostile environments and is nearly impervious to heat. Scientifically classified as 'pyroflora rosea thermalis'."
	icon = 'icons/obj/structures/props/natural/vegetation/alien_tree.dmi'
	icon_state = "tree1"
	density = FALSE
	layer = ABOVE_XENO_LAYER
	fire_flag = FLORA_NO_BURN

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_1
	icon_state = "tree1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_2
	icon_state = "tree2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_3
	icon_state = "tree3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_4
	icon_state = "tree4"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_5
	icon_state = "tree5"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_6
	name = "dead ashrose tree"
	icon_state = "tree6"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_7
	name = "ashrose tree stump"
	icon_state = "tree7"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/tree/alien/tree_8
	name = "ashrose tree stump"
	icon_state = "tree8"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien
	icon = 'icons/obj/structures/props/natural/vegetation/alien_flora.dmi'
	icon_state = "red_bulb_1"
	cut_level = PLANT_CUT_KNIFE
	projectile_coverage = 0
	layer = UNDERFLOOR_OBJ_LAYER
	plane = FLOOR_PLANE
	density = FALSE

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush
	icon_state = "chilli_bush_1"
	light_on = 1
	light_color = "#00f4ff"
	light_range = 2
	light_power = 1

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush/chilli_bush_1
	icon_state = "chilli_bush_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush/chilli_bush_2
	icon_state = "chilli_bush_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush/chilli_bush_3
	icon_state = "chilli_bush_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush/chilli_bush_4
	icon_state = "chilli_bush_4"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush_no_light
	icon_state = "chilli_bush_5"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/chilli_bush_no_light/chilli_bush_1
	icon_state = "chilli_bush_6"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/leafy_bush/leafy_bush_1
	icon_state = "leafybush_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/leafy_bush/leafy_bush_2
	icon_state = "leafybush_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/leafy_bush/leafy_bush_3
	icon_state = "leafybush_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/bluegrass/bluegrass_1
	icon_state = "bluegrass_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/bluegrass/bluegrass_2
	icon_state = "bluegrass_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/bluegrass/bluegrass_3
	icon_state = "bluegrass_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/bluegrass/bluegrass_4
	icon_state = "bluegrass_4"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/sparsegrass/sparsegrass_1
	icon_state = "sparsegrass_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/sparsegrass/sparsegrass_2
	icon_state = "sparsegrass_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/sparsegrass/sparsegrass_3
	icon_state = "sparsegrass_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/fullgrass/fullgrass_1
	icon_state = "fullgrass_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/fullgrass/fullgrass_1
	icon_state = "fullgrass_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/fullgrass/fullgrass_2
	icon_state = "fullgrass_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/fullgrass/fullgrass_3
	icon_state = "fullgrass_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb
	light_on = 1
	light_color = "#794aa4"
	light_range = 2
	light_power = 1

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb/red_bulb_1
	icon_state = "red_bulb_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb/red_bulb2
	icon_state = "red_bulb_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb/red_bulb_3
	icon_state = "red_bulb_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb/red_bulb_4
	icon_state = "red_bulb_4"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb/red_bulb_5
	icon_state = "red_bulb_5"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/red_bulb/red_bulb_6
	icon_state = "red_bulb_6"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_1
	icon_state = "p_mushroom_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_2
	icon_state = "p_mushroom_2"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_3
	icon_state = "p_mushroom_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_4
	icon_state = "p_mushroom_4"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_5
	icon_state = "p_mushroom_5"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_6
	icon_state = "p_mushroom_6"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_7
	icon_state = "p_mushroom_7"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/purple_mushroom/purple_mushroom_8
	icon_state = "p_mushroom_8"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/orange_mushroom/orange_mushroom_1
	icon_state = "o_mushroom_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/orange_mushroom/orange_mushroom_3
	icon_state = "o_mushroom_3"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/orange_mushroom/orange_mushroom_4
	icon_state = "o_mushroom_4"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/orange_mushroom/orange_mushroom_6
	icon_state = "o_mushroom_6"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/orange_mushroom/orange_mushroom_7
	icon_state = "o_mushroom_7"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/cup_plant/cup_plant_1
	icon_state = "cup_plant_1"

// From source/pr203:code/game/objects/structures/flora.dm
/obj/structure/flora/alien/cup_plant/cup_plant_2
	icon_state = "cup_plant_2"

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/blackgoocontainer/submerged
	icon_state = "blackgoocontainer4"
	desc = "A strange alien container. It exudes an aura of otherworldly mystery. It's submerged partially in the ground."
	icon = 'icons/obj/items/black_goo_stuff.dmi'
	density = FALSE

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/machinery/hybrisa/coffee_machine/alt
	icon_state = "coffeealt"
	vends = "coffeealt"
	base_state = "coffeealt"

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/cargo_container/hybrisa/containersextended/colorable_big_left
	name = "reinforced cargo container"
	desc = "A small reinforced industrial shipping container."
	icon_state = "colorable_crate_l"

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/cargo_container/hybrisa/containersextended/colorable_big_right
	name = "reinforced cargo container"
	desc = "A small reinforced industrial shipping container."
	icon_state = "colorable_crate_r"

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/cargo_container/hybrisa/containersextended/colorable_small
	name = "reinforced cargo container"
	desc = "A small reinforced industrial shipping container."
	icon_state = "colorable_crate_small"

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/prop/hybrisa/misc/prop_deco_edging
	name = "decorative edging"
	desc = "Decorative edging for bordering stuff, very fancy."
	icon = 'icons/obj/structures/props/hybrisa/platforms.dmi'
	icon_state = "stone_edging"
	density = FALSE
	anchored = TRUE
	unacidable = TRUE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/objects/structures/hybrisa_props.dm
/obj/structure/prop/hybrisa/misc/prop_deco_edging/corner
	icon = 'icons/obj/structures/props/hybrisa/platforms.dmi'
	icon_state = "stone_edging_deco"

// From source/pr203:code/game/objects/structures/inflatable.dm
/obj/structure/inflatable/black
	icon_state = "wall_black"
	icon_suffix = "_black"
	origin = /obj/item/inflatable/black
	poped_type = /obj/structure/inflatable/popped/black

// From source/pr203:code/game/objects/structures/inflatable.dm
/obj/item/inflatable/black
	icon_state = "folded_wall_black"
	inflatable_type = /obj/structure/inflatable/black

// From source/pr203:code/game/objects/structures/inflatable.dm
/obj/structure/inflatable/door/black
	icon_state = "door_closed_black"
	icon_suffix = "_black"
	origin = /obj/item/inflatable/door/black
	poped_type = /obj/structure/inflatable/popped/door/black

// From source/pr203:code/game/objects/structures/inflatable.dm
/obj/item/inflatable/door/black
	icon_state = "folded_door_black"
	inflatable_type = /obj/structure/inflatable/door/black

// From source/pr203:code/game/objects/structures/inflatable.dm
/obj/structure/inflatable/popped/door/black
	icon_state = "door_popped_black"
	icon_suffix = "_black"

// From source/pr203:code/game/objects/structures/landing_signs.dm
/obj/structure/lz_sign/charon_sign
	name = "Charon's Crucible Sign"
	desc = "A large sign reading 'Charon's Crucible'. It's heavily damaged and covered in ash. It has the Seegson logo."
	icon_state = "charon_sign"

// From source/pr203:code/game/objects/structures/landing_signs.dm
/obj/structure/lz_sign/charon_sign/lasalle_bionational
	name = "Charon's Crucible Sign"
	desc = "A large sign reading 'Charon's Crucible'. It has the Lasalle Bionational corporation logo."
	icon_state = "charon_sign_lasalle"

// From source/pr203:code/game/objects/structures/landing_signs.dm
/obj/structure/lz_sign/lasalle_bionational_sign
	name = "Lasalle Bionational Sign"
	desc = "A large sign with the Lasalle Bionational Corporation name and logo."
	icon_state = "lasalle_bio_sign"

// From source/pr203:code/game/objects/structures/landing_signs.dm
/obj/structure/lz_sign/seegson_sign
	name = "Seegson Sign"
	desc = "A large sign reading 'Seegson'."
	icon_state = "seegson"
	bound_width = 64
	bound_height = 32
	projectile_coverage = PROJECTILE_COVERAGE_MINIMAL

// From source/pr203:code/game/objects/structures/landing_signs.dm
/obj/structure/lz_sign/seegson_sign/damaged
	name = "Seegson Sign"
	desc = "A large sign reading 'Seegson'."
	icon_state = "seegson_d"

// From source/pr203:code/game/objects/structures/landing_signs.dm
/obj/structure/lz_sign/seegson_sign/damaged_ash
	name = "Seegson Sign"
	desc = "A large sign reading 'Seegson'."
	icon_state = "seegson_a"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/stairs/perspective/ramp
	icon = 'icons/obj/structures/stairs/perspective_stairs_ramp.dmi'
	icon_state = "ramp_multi"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/stairs/rock/engineer_temple //instance these for the required icons
	icon = 'icons/obj/structures/stairs/stairs_temple.dmi'
	icon_state = "rock_stairs"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt
	name = "metal ore box"
	desc = "A heavy metal box used for storing ore."
	icon_state = "orebox_alt_1"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt/alt_1
	icon_state = "orebox_alt_2"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt/alt_2
	icon_state = "orebox_alt_3"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt/alt_3
	icon_state = "orebox_alt_4"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt/metal_container_colorable
	name = "metal container"
	desc = "A heavy metal container used for storing various materials."
	icon_state = "metal_box"

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(xeno.a_intent == INTENT_HARM)
		if(unslashable)
			return
		xeno.animation_attack_on(src)
		xeno.visible_message(SPAN_DANGER("[xeno] slices [src] apart!"))
		playsound(src, 'sound/effects/metalhit.ogg')
		to_chat(xeno, SPAN_WARNING("We slice the [src] apart!"))
		deconstruct(FALSE)
		return XENO_ATTACK_ACTION
	else
		attack_hand(xeno)
		return XENO_NONCOMBAT_ACTION

// From source/pr203:code/game/objects/structures/misc.dm
/obj/structure/ore_box/alt/handle_tail_stab(mob/living/carbon/xenomorph/xeno, blunt_stab)
	if(unslashable)
		return TAILSTAB_COOLDOWN_NONE
	playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
	deconstruct(FALSE)
	xeno.visible_message(SPAN_DANGER("[xeno] destroys [src] with its tail!"),
	SPAN_DANGER("We destroy [src] with our tail!"), null, 5, CHAT_TYPE_XENO_COMBAT)
	xeno.emote("tail")
	return TAILSTAB_COOLDOWN_NORMAL

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/metal/stair_cut/lava_metal_left
	icon_state = "lava_metalplatform_stair"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/metal/stair_cut/lava_metal_right
	icon_state = "lava_metalplatform_stair_alt"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/metal/lava_metal
	name = "raised metal edge"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."
	icon_state = "lava_metalplatform"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/metal/lava_metal/north
	dir = NORTH

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/metal/lava_metal/east
	dir = EAST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/metal/lava_metal/west
	dir = WEST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/lava
	name = "lava rock edge"
	desc = "A rugged chunk of volcanic rock. Its jagged surface and blackened edges seem precarious but climbable."
	icon_state = "lava_platform"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/lava/north
	dir = NORTH

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/lava/east
	dir = EAST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/lava/west
	dir = WEST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/engineer
	name = "stone platform"
	desc = "A platform supporting elevated ground, made of stone."
	icon_state = "engineer_stone_wall"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/engineer/north
	dir = NORTH

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/engineer/east
	dir = EAST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform/stone/engineer/west
	dir = WEST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/metal/lava_metal
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. This is the corner."
	icon_state = "lava_metalplatform_deco"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/metal/lava_metal/north
	dir = NORTH

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/metal/lava_metal/east
	dir = EAST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/metal/lava_metal/west
	dir = WEST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/lava
	name = "lava rock corner"
	desc = "A rounded corner of volcanic rock, smoothed by molten flows yet still bearing a rugged texture."
	icon_state = "lava_platform_deco"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/lava/north
	dir = NORTH

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/lava/east
	dir = EAST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/lava/west
	dir = WEST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/engineer
	icon_state = "engineer_stone_deco"

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/engineer/north
	dir = NORTH

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/engineer/east
	dir = EAST

// From source/pr203:code/game/objects/structures/platforms.dm
/obj/structure/platform_decoration/stone/engineer/west
	dir = WEST

// From source/pr203:code/game/objects/structures/props.dm
/obj/effect/decal/large_stain
	name = "large stain"
	desc = FALSE
	icon = 'icons/obj/structures/props/64x64_bodybag_pile.dmi'
	icon_state = "large_stain"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/invuln/working_joe/large_storage
	name = "synthetic storage unit"
	desc = "A vertical storage bay designed to house inactive Working Joe synthetics, keeping them bagged, preserved, and ready for deployment."
	icon = 'icons/obj/structures/machinery/working_joe_storage.dmi'
	icon_state = "working_joe_storage_bluebag1_alt"
	unslashable = FALSE
	wrenchable = FALSE
	bound_height = 32
	bound_width = 32
	light_on = 1
	light_color = "#dcc687"
	light_range = 2
	light_power = 1
	explo_proof = FALSE
	unacidable = FALSE

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/invuln/joey/bag
	name = "synthetic storage unit"
	desc = "A vertical storage bay designed to house inactive Working Joe synthetics, keeping them bagged, preserved, and ready for deployment."
	icon = 'icons/obj/structures/machinery/working_joe_storage.dmi'
	icon_state = "working_joe_storage_bluebag1_alt"
	bound_height = 32
	bound_width = 32
	light_on = 1
	light_color = "#dcc687"
	light_range = 2
	light_power = 1
	explo_proof = FALSE

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/fire_colony
	icon = 'icons/obj/structures/props/ice_colony/props.dmi'
	icon_state = "pyro_tray_1"
	density = TRUE

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/fire_colony/dense
	projectile_coverage = 10
	health = 75

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/fire_colony/dense/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(xeno.a_intent == INTENT_HARM)
		if(unslashable)
			return
		xeno.animation_attack_on(src)
		playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
		xeno.visible_message(SPAN_DANGER("[xeno] slices [src] apart!"),
		SPAN_DANGER("We slice [src] apart!"), null, 5, CHAT_TYPE_XENO_COMBAT)
		deconstruct(FALSE)
		return XENO_ATTACK_ACTION
	else
		attack_hand(xeno)
		return XENO_NONCOMBAT_ACTION

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/fire_colony/dense/handle_tail_stab(mob/living/carbon/xenomorph/xeno, blunt_stab)
	if(unslashable)
		return TAILSTAB_COOLDOWN_NONE
	playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
	deconstruct(FALSE)
	xeno.visible_message(SPAN_DANGER("[xeno] destroys [src] with its tail!"),
	SPAN_DANGER("We destroy [src] with our tail!"), null, 5, CHAT_TYPE_XENO_COMBAT)
	xeno.emote("tail")
	return TAILSTAB_COOLDOWN_NORMAL

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony
	icon = 'icons/obj/structures/props/ice_colony/props.dmi'
	name = "pyrotrinium tray"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_tray
	icon = 'icons/obj/structures/props/ice_colony/props.dmi'
	name = "pyrotrinium tray_1"
	desc = "It is a tray filled with dark red, clustered pyrotrinium crystals."
	icon_state = "pyro_tray_empty"
	w_class = SIZE_MASSIVE

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_tray/tray_4
	icon_state = "pyro_tray_4"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_tray/tray_5
	icon_state = "pyro_tray_5"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_tray/tray_6
	icon_state = "pyro_tray_6"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_tray/tray_7
	icon_state = "pyro_tray_7"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal
	icon = 'icons/obj/structures/props/ice_colony/props.dmi'
	name = "pyrotrinium crystal"
	desc = "It is a giant pyrotrinium crystal cluster."
	icon_state = "pyro_crystal"
	w_class = SIZE_LARGE
	black_market_value = 1

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal/crystal_2
	icon_state = "pyro_crystal_2"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal/crystal_3
	icon_state = "pyro_crystal_3"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal/crystal_4
	icon_state = "pyro_crystal_4"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal/crystal_5
	icon_state = "pyro_crystal_5"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal/crystal_6
	icon_state = "pyro_crystal_6"

// From source/pr203:code/game/objects/structures/props.dm
/obj/item/fire_colony/pyrotrinium_crystal/crystal_7
	icon_state = "pyro_crystal_7"

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/fire_colony/dense/planter_box/plated/dark
	icon_state = "planter_box_lava"
	name = "plated grow box"
	desc = "The planter box is empty."
	projectile_coverage = FALSE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE

// From source/pr203:code/game/objects/structures/props.dm
/obj/structure/prop/fire_colony/dense/broken_ai_core
	name = "sabotaged AI core"
	desc = "The sabotaged central AI core that once coordinated the colony's 'Working Joe' network. It's screens and casing have been torn apart and it's internals deliberately destroyed, leaving it far beyond any practical repair."
	icon = 'icons/obj/structures/machinery/ai.dmi'
	icon_state = "hydra-damaged"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	bound_height = 64
	bound_width = 96
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
	projectile_coverage = TRUE

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/calendar/ua
	icon_state = "calendar_ua"
	desc = "Classic office decoration and a place to stare at maniacally, has a vertically placed UA flag and some army symbolics."
	calendar_faction = FACTION_MARINE

//===================//
//      Con-Am Faction Symbol     //
//=================//

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple
	icon = 'icons/obj/structures/props/wall_decorations/ruined_banner.dmi'
	icon_state = "ruinbanner_1"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple/attackby(obj/item/W, mob/living/user)
	// Any sufficiently sharp knife/blade destroys instantly
	if(W.sharp >= IS_SHARP_ITEM_SIMPLE)
		user.animation_attack_on(src)
		to_chat(user, SPAN_WARNING("You rip \the [src] with \the [W]."))
		playsound(src, 'sound/effects/cloth_rip.ogg', 25, 1)
		qdel(src)
		return ATTACKBY_HINT_UPDATE_NEXT_MOVE
	else
		. = ..()

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple/ancient_torn
	name = "\improper ancient torn banner"
	desc = "An ancient torn banner, who knows how long this has been hanging here..."
	icon_state = "small_ruinbanner_0"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple/ancient_torn/ancient_torn_1
	icon_state = "small_ruinbanner_1"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple/ancient_torn_desat
	name = "\improper ancient torn banner"
	desc = "An ancient torn banner, who knows how long this has been hanging here..."
	icon_state = "old_ruinbanner_0"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple/ancient_torn_desat/ancient_torn_desat_1
	icon_state = "old_ruinbanner_1"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/flag/simple/ancient_torn_desat/ancient_torn_desat_2
	icon_state = "old_ruinbanner_2"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/biolab/alt
	icon_state = "biolab_alt"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/restrictedarea/dark
	icon_state = "restrictedarea_dark"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/seventeen
	name = "seventeen semiotic"
	desc = "Semiotic Standard denoting the number seventeen."
	icon_state = "17"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/eighteen
	name = "eighteen semiotic"
	desc = "Semiotic Standard denoting the number eighteen."
	icon_state = "18"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/nineteen
	name = "nineteen semiotic"
	desc = "Semiotic Standard denoting the number nineteen."
	icon_state = "19"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/twenty
	name = "twenty semiotic"
	desc = "Semiotic Standard denoting the number twenty."
	icon_state = "20"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/twentyone
	name = "twenty-one semiotic"
	desc = "Semiotic Standard denoting the number twenty-one."
	icon_state = "21"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/twentytwo
	name = "twenty-two semiotic"
	desc = "Semiotic Standard denoting the number twenty-two."
	icon_state = "22"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/twentythree
	name = "twenty-three semiotic"
	desc = "Semiotic Standard denoting the number twenty-three."
	icon_state = "23"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/twentyfour
	name = "twenty-four semiotic"
	desc = "Semiotic Standard denoting the number twenty-four."
	icon_state = "24"

// From source/pr203:code/game/objects/structures/signs.dm
/obj/structure/sign/safety/twentyfive
	name = "twenty-five semiotic"
	desc = "Semiotic Standard denoting the number twenty-five."
	icon_state = "25"

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/bed.dm
/obj/item/roller/bedroll/comfy
	name = "folded comfy bedroll"
	desc = "Folded and innocent-looking — but don’t be fooled. It's technically illegal in three sectors for causing excessive napping."
	icon_state = "bedroll_comfy"
	rollertype = /obj/structure/bed/bedroll/comfy

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/bed.dm
/obj/item/roller/bedroll/comfy/blue
	color = "#8cb9e2"
	rollertype = /obj/structure/bed/bedroll/comfy/blue

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/bed.dm
/obj/item/roller/bedroll/comfy/pink
	color = "#eaa8b2"
	rollertype = /obj/structure/bed/bedroll/comfy/pink

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/chairs.dm
/obj/structure/bed/chair/comfy/blue_dark
	icon_state = "comfychair_bdark"

// From source/pr203:code/game/objects/structures/stool_bed_chair_nest/chairs.dm
/obj/structure/bed/chair/comfy/stool
	name = "comfy stool"
	desc = "Uh-hoh, the bar is heating up."
	icon_state = "stool_diner"
	anchored = TRUE
	can_buckle = FALSE

// From source/pr203:code/game/objects/structures/tables_racks.dm
/obj/structure/surface/rack/long
	icon_state = "longrack"
	parts = /obj/item/frame/rack
	debris = list(/obj/item/frame/rack)

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble
	icon_state = "c_rubble0"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_1
	icon_state = "c_rubble1"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_2
	icon_state = "c_rubble2"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_3
	icon_state = "c_rubble3"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_4
	icon_state = "c_rubble4"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_5
	icon_state = "c_rubble5"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_6
	icon_state = "c_rubble6"

// From source/pr203:code/game/objects/structures/temple_rubble.dm
/obj/effect/hunter/ancient_temple/colorable_rubble/rubble_7
	icon_state = "c_rubble7"

// From source/pr203:code/game/turfs/closed.dm
/turf/closed/shuttle/ert/transparent
	opacity = FALSE

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/almayer/research/containment/corner_var1/west
	dir = WEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_dir
	icon_state = "smooth_dir"

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_dir/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_dir/north
	dir = NORTH

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_dir/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_dir/west
	dir = WEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_dir/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_u
	icon_state = "smooth_u"

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_u/north
	dir = NORTH

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_u/east
	dir = EAST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/floor_plate/smooth_u/west
	dir = WEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/prison/ramptop/west
	dir = WEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid
	icon_state = "solid"

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid/directions
	icon_state = "solid_dir"

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid/directions/east
	dir = EAST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid/directions/west
	dir = WEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid/directions/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid/directions/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/floor_types.dm
/turf/open/floor/corsat/solid/directions/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/hybrisa.dm
/turf/open/floor/hybrisa/tile/tilegrey/broken
	icon_state = "tilegrey_broken"

// From source/pr203:code/game/turfs/hybrisa.dm
/turf/open/floor/hybrisa/tile/tilegrey/broken/north
	dir = NORTH

// From source/pr203:code/game/turfs/hybrisa.dm
/turf/open/floor/hybrisa/tile/tilegrey/broken/east
	dir = EAST

// From source/pr203:code/game/turfs/hybrisa.dm
/turf/open/floor/hybrisa/tile/tilegrey/broken/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery
	name = "sloped roof"
	icon = 'icons/turf/floors/floors.dmi'
	icon_state = "grass1"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/Entered(atom/movable/crosser)
	. = ..()
	if(isobserver(crosser) || crosser.anchored)
		return

	if(!(isitem(crosser) || isliving(crosser)))
		return

	INVOKE_ASYNC(crosser, TYPE_PROC_REF(/atom/movable, throw_atom), (get_step(src, dir)), 50, SPEED_FAST, null, TRUE)

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/dir_alt
	icon_state = "outerhull_dir_alt"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/dir_alt/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/tiles
	icon_state = "outerhull_tiles"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/tiles/east
	dir = EAST

//Colorable hull tiles

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable
	name = "sloped roof"
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull_colorable"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple
	color = "#716c71"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir
	icon_state = "outerhull_colorable_dir"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/dir/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/corner
	icon_state = "outerhull_colorable_corner"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/corner/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/corner/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/corner/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/corner_alt
	icon_state = "outerhull_colorable_corner_alt"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection
	icon_state = "outerhull_colorable_connection"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt
	icon_state = "outerhull_colorable_connection_alt"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_alt/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_middle
	icon_state = "outerhull_colorable_connection_middle"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_middle/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_corner
	icon_state = "outerhull_colorable_connection_corner"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_corner/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_corner/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_corner/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_end
	icon_state = "outerhull_colorable_connection_end"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_end/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_end/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/connection_end/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/full
	icon_state = "outerhull_colorable_full"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/purple/tiles
	icon_state = "outerhull_colorable_tiles"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal
	icon_state = "outerhull_colorable"
	color = "#697374"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir
	icon_state = "outerhull_colorable_dir"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner
	icon_state = "outerhull_colorable_corner"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/tiles2
	icon_state = "outerhull_colorable_tiles_alt"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal
	name = "sloped roof"
	icon = 'icons/turf/almayer.dmi'
	icon_state = "outerhull_colorable"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir
	icon_state = "outerhull_colorable_dir"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/dir/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner
	icon_state = "outerhull_colorable_corner"

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner/north
	dir = NORTH

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner/east
	dir = EAST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/corner/west
	dir = WEST

// From source/pr203:code/game/turfs/open.dm
/turf/open/slippery/hull/colorable/teal/tiles2
	icon_state = "outerhull_colorable_tiles_alt"

// From source/pr203:code/game/turfs/open.dm
/obj/structure/prop/roof/glass
	icon = 'icons/effects/glass_roof.dmi'
	icon_state = "glass_roof_1"
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/blue4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/fake_catwalk
	icon_state = "plating_catwalk_alt"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/blue4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3
	icon_state = "lightblue3"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue3/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue4
	icon_state = "lightblue4"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue4/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/lightblue4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3
	icon_state = "seeg3"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg3/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg4
	icon_state = "seeg4"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg4/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/seeg4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth
	icon_state = "smooth"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir
	icon_state = "smooth_dir"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_dir/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_u
	icon_state = "smooth_u"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_u/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_u/east

	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_u/south

	dir = SOUTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/smooth_u/west

	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand1
	icon_state = "sand1"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3
	icon_state = "sand3"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand3/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand4
	icon_state = "sand4"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand4/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/sand4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred1
	icon_state = "altred1"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3
	icon_state = "altred3"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred3/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred4
	icon_state = "altred4"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred4/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altred4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay1
	icon_state = "medbay1"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay3
	icon_state = "medbay3"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay3/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay3/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay3/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay3/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay3/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay4
	icon_state = "medbay4"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay4/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/medbay4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3
	icon_state = "altgreen3"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/southwest
	dir = SOUTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/southeast
	dir = SOUTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/northeast
	dir = NORTHEAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen3/northwest
	dir = NORTHWEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen4
	icon_state = "altgreen4"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen4/north
	dir = NORTH

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen4/east
	dir = EAST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/altgreen4/west
	dir = WEST

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/deco
	icon_state = "deco"

// From source/pr203:code/game/turfs/strata.dm
/turf/open/floor/strata/deco2
	icon_state = "deco2"

// From source/pr203:code/game/turfs/walls/wall_types.dm
/turf/closed/wall/shiva/prefabricated/dark
	icon_state = "shiva_fab_dark"
	walltype = WALL_SHIVA_FAB_DARK

// From source/pr203:code/modules/clothing/head/helmet.dm
/obj/item/clothing/head/helmet/marine/veteran/pmc/corporate/seegson
	name = "\improper Seegson security helmet"
	desc = "A basic skull-helm worn by Seegson corporate security assets."
	icon = 'icons/obj/items/clothing/hats/hats_by_faction/SEEGSON.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_faction/SEEGSON.dmi'
	)
	icon_state = "seegson_security_helmet"
	item_state = "seegson_security_helmet"

// From source/pr203:code/modules/clothing/under/ties.dm
/obj/item/clothing/accessory/patch/seegson
	name = "Seegson Corporation patch"
	desc = "An old corporate patch bearing the logo of Seegson Corporation, once known for its cheap, unreliable technology. Wearing it implies loyalty to profit over people."
	icon_state = "seegson"
	item_state_slots = list(WEAR_AS_GARB = "seegson")

// From source/pr203:code/modules/cm_marines/equipment/maps.dm
/obj/item/map/fire_colony
	name = "\improper LV-376 map"
	desc = "A map of the Lasalle Bionational owned colony on LV-376, commonly known as 'Charon's Crucible'."
	html_link = "images/1/18/Map_icecolony.png"
	color = "#d2440c"

// From source/pr203:code/modules/desert_dam/filtration/structures.dm
/obj/structure/filtration/machine_32x64/destructible
	name = "silo tank"
	icon = 'icons/obj/structures/props/industrial/32x64.dmi'
	icon_state = "solo_tank"
	density = TRUE
	anchored = TRUE
	bound_width = 32
	bound_height = 64

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/timed_event
	icon = 'icons/landmarks.dmi'
	icon_state = "o_red"

	var/static/list/notification_areas = list()

	/// How long to wait until the event should occur
	var/time

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/timed_event/Initialize(mapload, ...)
	. = ..()

	icon = null

	if(isnull(time))
		log_mapping("[type] (x: [x], y: [y], z: [z]) was created without a time.")
		return INITIALIZE_HINT_QDEL

	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(handle_round_start)))

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/timed_event/scrapeaway
	icon_state = "o_blue"

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/timed_event/scrapeaway/generate_callback()
	return CALLBACK(get_turf(src), TYPE_PROC_REF(/turf, ScrapeAway))

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/timed_event/scrapeaway/announce_event(time_to_grab)
	var/announcement_areas = english_list(notification_areas[type]["[time_to_grab]"])

	var/marine_announcement_text = SSmapping.configs[GROUND_MAP].environment_traits[ZTRAIT_IN_SPACE] \
		? "Structural collapse detected in [announcement_areas]. Be advised that new routes may be accessible." \
		: "Geological shifts detected in [announcement_areas]. Be advised that new routes may be accessible."

	marine_announcement(marine_announcement_text, "Priority Announcement")

	var/xeno_announcement_text = SSmapping.configs[GROUND_MAP].environment_traits[ZTRAIT_IN_SPACE] \
		? "The shattered metal of this place has collapsed, providing new routes in [announcement_areas]." \
		: "The ground of this world trembles, and new routes are accessible in [announcement_areas]."

	xeno_announcement(SPAN_XENOANNOUNCE(xeno_announcement_text), "everything", XENO_GENERAL_ANNOUNCE)

	qdel(src)

/// Mapping helper placed on turfs that toggles the destructiblity of the turf after a specified duration.

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark
	icon = 'icons/landmarks.dmi'
	icon_state = "map_sentry"

	var/abstract_type = /obj/effect/sentry_landmark

	/// Which landing zone this landmark should be connected to
	var/landing_zone

	/// Which position this sentry should spawn at
	var/position

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/Initialize(mapload, ...)
	. = ..()

	if(type == abstract_type)
		#if !defined(UNIT_TESTS)
		log_mapping("A [type] was created that should not have been! Use a subtype instead.")
		#endif
		return INITIALIZE_HINT_QDEL

	LAZYADDASSOCLIST(GLOB.sentry_spawns[landing_zone], position, get_turf(src))

	return INITIALIZE_HINT_QDEL

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_1
	abstract_type = /obj/effect/sentry_landmark/lz_1
	landing_zone = /obj/docking_port/stationary/marine_dropship/lz1

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_1/top_left
	position = SENTRY_TOP_LEFT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_1/top_right
	position = SENTRY_TOP_RIGHT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_1/bottom_left
	position = SENTRY_BOTTOM_LEFT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_1/bottom_right
	position = SENTRY_BOTTOM_RIGHT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_2
	abstract_type = /obj/effect/sentry_landmark/lz_2
	landing_zone = /obj/docking_port/stationary/marine_dropship/lz2

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_2/top_left
	position = SENTRY_TOP_LEFT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_2/top_right
	position = SENTRY_TOP_RIGHT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_2/bottom_left
	position = SENTRY_BOTTOM_LEFT

// From source/pr203:code/modules/mapping/mapping_helpers.dm
/obj/effect/sentry_landmark/lz_2/bottom_right
	position = SENTRY_BOTTOM_RIGHT

// From source/pr203:code/modules/paperwork/photocopier.dm
/obj/structure/machinery/photocopier/alt
	icon_state = "altbigscanner"
	animate_state = "altbigscanner1"

// From source/pr203:code/modules/power/apc.dm
/obj/structure/machinery/power/apc/fully_broken/no_cell/north
	pixel_y = 32
	dir = 1

#undef APC_UPDATE_ICON_COOLDOWN

// From source/pr203:code/modules/power/lighting.dm
/obj/structure/machinery/landinglight/spoke
	icon_state = "lz_spoke_light_off"

// From source/pr203:code/modules/power/lighting.dm
/obj/structure/machinery/landinglight/spoke/turn_on()
	icon_state = "lz_spoke_light_on"
	set_light(3)

// From source/pr203:code/modules/projectiles/guns/flamer/flamer.dm
/obj/item/weapon/gun/flamer/survivor
	name = "\improper improvised flamethrower"
	desc = "A custom made incinerator, made from repurposed welding and piping equipment."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony/flamers.dmi'
	icon_state = "flamer"
	item_state = "flamer"
	accepted_ammo = list(/obj/item/ammo_magazine/flamer_tank/survivor)
	current_mag = /obj/item/ammo_magazine/flamer_tank/survivor

	attachable_allowed = list(
		/obj/item/attachable/flashlight,
		/obj/item/attachable/attached_gun/flamer_nozzle,
	)

// From source/pr203:code/modules/projectiles/guns/flamer/flamer.dm
/obj/item/weapon/gun/flamer/survivor/get_fire_sound()
	var/list/fire_sounds = list(
		'sound/weapons/surv_flamer_fire1.ogg',
		'sound/weapons/surv_flamer_fire2.ogg',
		'sound/weapons/surv_flamer_fire3.ogg',
		'sound/weapons/surv_flamer_fire4.ogg')
	return pick(fire_sounds)

// From source/pr203:code/modules/projectiles/guns/pistols.dm
/obj/item/weapon/gun/pistol/holdout/custom
	name = "W62 'Whisper' custom pistol"
	desc = "A small plinker in .22LR made by Spearhead. Designed for target shooting or quietly dealing with interplanetary vermin. This one is custom fitted with ivory grip plates and a bluesteel finish."
	icon_state = "whisperc"
	item_state = "whisperc"
	lineart_gun_icon = "holdout"

// From source/pr203:code/modules/reagents/chemistry_machinery/chem_dispenser.dm
/obj/structure/machinery/chem_dispenser/corpsman/update_icon()
	if(stat & BROKEN)
		icon_state = (beaker ? "mixer1_b" : "mixer0_b")
	else if(stat & NOPOWER)
		icon_state = (beaker ? "[base_state]1_nopower" : "[base_state]0_nopower")
	else
		icon_state = (beaker ? "[base_state]1" : "[base_state]0")

// From source/pr203:code/modules/reagents/chemistry_machinery/chem_dispenser.dm
/obj/structure/machinery/chem_dispenser/corpsman
	name = "pressurized chemical dispenser"
	desc = "A more basic chemical dispenser, designed for use with pressurized reagent canisters. A Wey-Yu product."
	icon_state = "mixer0"
	ui_title = "Chem Dispenser 4000"
	req_skill_level = SKILL_MEDICAL_MEDIC
	accept_beaker_only = FALSE
	dispensable_reagents = list(
		"bicaridine",
		"kelotane",
		"anti_toxin",
		"dexalin",
		"dexalinp",
		"inaprovaline",
		"adrenaline",
		"peridaxon",
		"tramadol",
		"oxycodone",
		"tricordrazine",
	)

	var/base_state = "mixer"

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/dropship_clf
	name = "\improper UD-9M 'Dogbite'"
	desc = "The UD-9M 'Dogbite' is a repurposed utility dropship, originally designed for short-haul cargo operations across colonial systems. Stolen and heavily modified by the Colonial Liberation Front, it's now a rugged smuggler and strike craft, capable of dropping a full fireteam through tight patrol nets. Its hull is scarred with gunfire, rust, and graffiti — a patchwork of rebellion held together by grit and stolen parts."
	icon = 'icons/turf/dropship_clf.dmi'
	icon_state = "1"

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/dropship_clf/ex_act(severity, direction)
	return FALSE

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/dropship_clf/transparent
	opacity = FALSE

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/dropship_clf/transparent/left_engine
	icon_state = "leftengine_1"

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/dropship_clf/transparent/right_engine
	icon_state = "rightengine_1"

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/ert
	name = "wall"
	icon = 'icons/turf/ert_shuttle.dmi'
	icon_state = "stan4"
	opacity = TRUE

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/ert/ex_act(severity, direction)
	return FALSE

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/ert/front_left_stan
	icon_state = "stan20"

// From source/pr203:code/modules/shuttle/dropship.dm
/obj/structure/shuttle/part/ert/front_right_stan
	icon_state = "stan25"

// From source/pr203:code/modules/vehicles/hardpoints/wheels/van_wheels.dm
/obj/item/hardpoint/locomotion/van_wheels/rt01
	name = "RT-01 wheels"
	desc = "Integral to the movement of the RT-01 Transport vehicle."

	icon_state = "tires_rt01"
	disp_icon = "rt01"
	disp_icon_state = "wheels"

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/effect/vehicle_spawner/rt01
	name = "RT-01 Spawner"
	icon = 'icons/obj/vehicles/rt01.dmi'
	icon_state = "rt01_base"
	pixel_x = -16
	pixel_y = -16

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/effect/vehicle_spawner/rt01/Initialize()
	. = ..()
	spawn_vehicle()
	qdel(src)

//PRESET: no hardpoints

// From source/pr203:code/modules/vehicles/van/rt01.dm
/obj/effect/vehicle_spawner/rt01/spawn_vehicle()
	var/obj/vehicle/multitile/rt01/VAN = new (loc)

	load_misc(VAN)
	handle_direction(VAN)
	VAN.update_icon()

//PRESET: wheels installed, destroyed
