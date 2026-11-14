	layer = 6
	density = 0
/obj/structure/prop/invuln/prop_fog
	name = "Fog Prop"
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	layer = 6
	density = 0
	mouse_opacity = 0
	opacity = 0
/obj/structure/prop/invuln/prop_fog/smoke
	name = "Smoke Prop"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	pixel_x = -29
	pixel_y = -29
	layer = 6.1
/obj/structure/prop/invuln/prop_fog/mist
	name = "Mist Prop"
	icon = 'icons/obj/structures/props/watercloset.dmi'
	icon_state = "mist"
/obj/structure/prop/oilrig/support_beam
	name = "support beam"
	desc = "Marval of human engineering, keeping a metal platform afloat on the seas of a distant alien world."
	icon = 'icons/obj/structures/props/oilrig/support_beam.dmi'
	icon_state = "support_beam"
	bound_height = 64
	bound_width = 64
/obj/structure/prop/oilrig/support_beam/blue
	icon_state = "support_beam_blue"
/obj/structure/prop/oilrig/support_beam/green
	icon_state = "support_beam_green"
/obj/structure/prop/oilrig/support_beam/aqua
	icon_state = "support_beam_aqua"
/obj/structure/prop/oilrig/support_beam/red
	icon_state = "support_beam_red"
/obj/structure/prop/oilrig/support_beam/brown
	icon_state = "support_beam_brown"
/obj/effect/decal/navalis/plate_edge
	name = "solid metal grate"
	desc = "A metal grate."
	icon = 'icons/obj/structures/props/hybrisa/grates.dmi'
	icon_state = "zhalfgrate1"
	layer = HATCH_LAYER
/obj/effect/decal/navalis/plate_edge/darker
	color = "#ABA39D"
/obj/effect/decal/navalis/plate_edge/see_through
	icon_state = "zhalfgrate2"
/obj/structure/prop/invuln/static_corpse/afric_zimmer/trooper
	name = "Unknown Trooper"
	desc = "What remains of a unknown trooper. May they rest in peace."
	icon_state = "army_guy"
/obj/structure/prop/vehicles/aircraft/vtol
	name = "\improper AD-71E VTOL"
	desc = "A twin tilt-jet VTOL, the Blackfoot is the Bearcat's ugly big sister. For what she lacks in fire power and agility, she more than makes up for in utility and love handles. First tested by UA Northridge on American soil, the Blackfoot is currently undergoing active combat trials. This craft appears to be undergoing maintenance and is not ready to fly."
	icon = 'icons/obj/vehicles/vtol_prop.dmi'
	icon_state = "vtol"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/aircraft/vtol/damaged
	name = "\improper Crashed AD-71E VTOL"
	desc = "A twin tilt-jet VTOL, the Blackfoot is the Bearcat's ugly big sister. For what she lacks in fire power and agility, she more than makes up for in utility and love handles. First tested by UA Northridge on American soil, the Blackfoot is currently undergoing active combat trials. This craft appears to have crash landed, and is inoperable."
	icon_state = "vtol_damaged"
/obj/structure/prop/vehicles/aircraft/aircraft
	name = "\improper EVAC-3 Aerospace fighter"
	desc = "A state of the art EVAC-3F aerospace fighter used by the USCM. This fighter has seen better days with extensive internal wiring damage and unfinished repairs to the bomb-bays."
	icon = 'icons/obj/vehicles/aircraft_prop.dmi'
	icon_state = "evac_uscm"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/aircraft/aircraft/usaf
	icon_state = "evac_usaf"
	desc = "High tech, silver coated EVAC-3 aerospace fighter used by the USAF in deep recon mission. The thermal-absorbent paint alone probably costs more than your squads collective paycheck. Unfortunately, however, this jet was in the middle of a repair cycle when the nothern defences were breached, nessecitating an evacuation."
/obj/structure/prop/vehicles/tank/truck
	name = "M887 Truck"
	desc = "A small box-type van. It's a compact vehicle with a rectangular cargo area, typically designed for transporting goods or small equipment. It features a high roof and straight sides, providing ample vertical space for storage. Its size makes it maneuverable and ideal for urban driving and tight spaces. This van appears to be non-functional, likely due to excessive use during the recent oubreak."
	icon = 'icons/obj/vehicles/van_prop.dmi'
	icon_state = "van_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/truck/broken
	icon_state = "van_broken"
/obj/structure/prop/vehicles/tank/truck/base
/obj/structure/prop/vehicles/tank/truck/base/broken
	icon_state = "van_broken"
/obj/structure/prop/vehicles/tank/truck/alt
	name = "M991 Truck"
	icon_state = "truck_base"
/obj/structure/prop/vehicles/tank/truck/alt/broken
	icon_state = "truck_broken"
/obj/structure/prop/vehicles/tank/apc
	name = "M577 Armored Personnel Carrier"
	desc = "An M577 Armored Personnel Carrier. An armored transport with four big wheels. This one is no longer in working order, serving now as a roadblock."
	icon = 'icons/obj/vehicles/apc_prop.dmi'
	icon_state = "apc_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/apc/destroyed
	icon_state = "apc_destroyed"
/obj/structure/prop/vehicles/tank/apc/base
/obj/structure/prop/vehicles/tank/apc/base/destroyed
	icon_state = "apc_destroyed"
/obj/structure/prop/vehicles/tank/apc/med
	icon_state = "apc_med"
/obj/structure/prop/vehicles/tank/apc/med/destroyed
	icon_state = "apc_med_destroyed"
/obj/structure/prop/vehicles/tank/miltruck
	name = "M255 Armored Half-Track"
	desc = "UA Military half-track, used by all branches of the United American army, including the US Army and USCM. Comes in multiple different configurations, from being able to haul troops to mounting a mobile mortar. Verstile and cheap. This one appears to be non-functional due to overuse during the recent oubreak."
	icon = 'icons/obj/vehicles/miltruck_prop.dmi'
	icon_state = "track_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/miltruck/base
/obj/structure/prop/vehicles/tank/miltruck/base/destroyed
	icon_state = "track_destroyed"
/obj/structure/prop/vehicles/tank/miltruck/wheeled
	icon_state = "miltruck_1_base"
/obj/structure/prop/vehicles/tank/miltruck/wheeled/cover
	icon_state = "miltruck_2_base"
/obj/structure/prop/vehicles/tank/miltruck/wheeled/destroyed
	icon_state = "miltruck_1_destroyed"
/obj/structure/prop/vehicles/tank/humvee
	name = "\improper M540-B Armored Recon Carrier"
	desc = "An M540-B Armored Recon Carrier. A lightly armored reconnaissance and intelligence vehicle. This vehicle has been immobilised."
	icon = 'icons/obj/vehicles/humvee_prop.dmi'
	icon_state = "humvee_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/humvee/destroyed
	icon_state = "humvee_base_wreck"
/obj/structure/prop/vehicles/tank/humvee/transport
	icon_state = "humvee_carrier"
/obj/structure/prop/vehicles/tank/humvee/transport/destroyed
	icon_state = "humvee_carrier_wreck"
/obj/structure/prop/vehicles/tank/humvee/medical
	icon_state = "humvee_med"
/obj/structure/prop/vehicles/tank/humvee/medical/destroyed
	icon_state = "humvee_med_wreck"
/obj/structure/prop/vehicles/tank/humvee/turret
	icon_state = "humvee_gun"
/obj/structure/prop/vehicles/tank/humvee/turret/destroyed
	icon_state = "humvee_gun_wreck"
/obj/structure/prop/vehicles/tank/ifv
	name = "M34 Marshal IFV"
	desc = "The M34 Marshal IFV: Developed by W-Y, the RAT (Rover Armed Transport) was originally designed for the 3WE Military as an armed version of their RT series of expeditionary vehicles, adopted by the US Army, It's heavier and and more durable then the M570 series the marines use, as the army don't have a need for APCs capable of being transported by dropship."
	icon = 'icons/obj/vehicles/ifv_prop.dmi'
	icon_state = "ifv_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/ifv/destroyed
	icon_state = "ifv_destroyed"
/obj/structure/prop/vehicles/tank/bison
	name = "BISON Automated Transport Vehicle"
	desc = "The BISON ATV is an remote-controled logistical supply vehicle, intended to assist USCM and US Army rear-line logistic forces in moving supplies. It requires someone to be standing near it for the auto-pilot functions to work. This model is non-functional."
	icon = 'icons/obj/vehicles/bison_prop.dmi'
	icon_state = "base_closed"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/bison/destroyed
	icon_state = "base_closed_damaged"
/obj/structure/prop/vehicles/tank/bison/open
	icon_state = "base_open"
/obj/structure/prop/vehicles/tank/bison/open/destroyed
	icon_state = "base_open_damaged"
/obj/structure/prop/vehicles/tank/arc
	name = "M540-B Armored Recon Carrier"
	desc = "An M540-B Armored Recon Carrier. A lightly armored reconnaissance and intelligence vehicle. This vehicle appears to be non-functional."
	icon = 'icons/obj/vehicles/arc_prop.dmi'
	icon_state = "arc_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/arc/destroyed
	icon_state = "arc_destroyed"
/obj/structure/prop/vehicles/tank/longstreet
	name = "M34A2 Longstreet Light Tank"
	desc = "A giant piece of armor with a big gun, it knew what it had to do, and it served its duty."
	icon = 'icons/obj/vehicles/tank_prop.dmi'
	icon_state = "tank_base"
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/vehicles/tank/longstreet/base
/obj/structure/prop/vehicles/tank/longstreet/base/destroyed
	icon_state = "tank_base_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/caustic
	icon_state = "tank_caustic_base"
/obj/structure/prop/vehicles/tank/longstreet/caustic/damaged
	icon_state = "tank_caustic_damaged"
/obj/structure/prop/vehicles/tank/longstreet/caustic/destroyed
	icon_state = "tank_caustic_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/concussive
	icon_state = "tank_concussive_base"
/obj/structure/prop/vehicles/tank/longstreet/concussive/damaged
	icon_state = "tank_concussive_damaged"
/obj/structure/prop/vehicles/tank/longstreet/concussive/destroyed
	icon_state = "tank_concussive_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/ballistic
	icon_state = "tank_ballistic_base"
/obj/structure/prop/vehicles/tank/longstreet/ballistic/damaged
	icon_state = "tank_ballistic_damaged"
/obj/structure/prop/vehicles/tank/longstreet/ballistic/destroyed
	icon_state = "tank_ballistic_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/turret
	icon_state = "turret_base"
/obj/structure/prop/vehicles/tank/longstreet/turret/damaged
	icon_state = "turret_base_damaged"
/obj/structure/prop/vehicles/tank/longstreet/turret/destroyed
	icon_state = "turret_base_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/primary
	icon_state = "ltb_base"
/obj/structure/prop/vehicles/tank/longstreet/primary/ltb
/obj/structure/prop/vehicles/tank/longstreet/primary/ltb/destroyed
	icon_state = "ltb_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/primary/ltaaap
	icon_state = "ltaaap_base"
/obj/structure/prop/vehicles/tank/longstreet/primary/ltaaap/destroyed
	icon_state = "ltaaap_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/primary/auto
	icon_state = "ace_base"
/obj/structure/prop/vehicles/tank/longstreet/primary/auto/destroyed
	icon_state = "ace_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/primary/flamer
	icon_state = "flamer_base"
/obj/structure/prop/vehicles/tank/longstreet/primary/flamer/destroyed
	icon_state = "flamer_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/secondary
	icon_state = "flamer_sec_base"
/obj/structure/prop/vehicles/tank/longstreet/secondary/flamer
/obj/structure/prop/vehicles/tank/longstreet/secondary/flamer/destroyed
	icon_state = "flamer_sec_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/secondary/glauncher
	icon_state = "glauncher_base"
/obj/structure/prop/vehicles/tank/longstreet/secondary/glauncher/destroyed
	icon_state = "glauncher_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/secondary/towlauncher
	icon_state = "towlauncher_base"
/obj/structure/prop/vehicles/tank/longstreet/secondary/towlauncher/destroyed
	icon_state = "towlauncher_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/secondary/m56cupola
	icon_state = "m56cupola_base"
/obj/structure/prop/vehicles/tank/longstreet/secondary/towlauncher/destroyed
	icon_state = "m56cupola_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/module/
	icon_state = "warray_base"
/obj/structure/prop/vehicles/tank/longstreet/module/warray
/obj/structure/prop/vehicles/tank/longstreet/module/warray/destroyed
	icon_state = "warray_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/module/odrive
	icon_state = "odrive_enhancer_base"
/obj/structure/prop/vehicles/tank/longstreet/module/odrive/destroyed
	icon_state = "odrive_enhancer_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/module/slauncher
	icon_state = "slauncher_base"
/obj/structure/prop/vehicles/tank/longstreet/module/slauncher/destroyed
	icon_state = "slauncher_destroyed"
/obj/structure/prop/vehicles/tank/longstreet/module/slauncher/empty
	icon_state = "slauncher_empty"
/obj/structure/prop/vehicles/tank/longstreet/module/artillerymod
	icon_state = "artillerymod_base"
/obj/structure/prop/vehicles/tank/longstreet/module/artillerymod/destroyed
	icon_state = "artillerymod_destroyed"
/obj/structure/prop/turret
	name = "\improper UH-46 Heavy Sentry Gun"
	desc = "Large weapons system platform designed to deploy multiple types of automated defense systems. This one has been rendered permanently non-functional."
	icon = 'icons/obj/structures/props/static_defence_prop.dmi'
	icon_state = "gun_platform"
	layer = XENO_HIDING_LAYER
	bound_height = 32
	bound_width = 64
	density = TRUE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE
/obj/structure/prop/turret/missile
	icon_state = "missile_platform"
/obj/structure/prop/invuln/overhead
	layer = ABOVE_FLY_LAYER
	icon = 'icons/obj/structures/props/industrial/overhead_ducting.dmi'
	icon_state = "flammable_pipe_1"
/obj/structure/prop/invuln/overhead/flammable_pipe
	name = "dense fuel line"
	desc = "Likely to be incredibly flammable."
	density = TRUE
/obj/structure/prop/invuln/overhead/flammable_pipe/fly
	density = FALSE
/obj/structure/prop/static_tank
	name = "liquid tank"
	desc = "Warning, contents under pressure!"
	icon = 'icons/obj/structures/props/industrial/generic_props.dmi'
	icon_state = "tank"
	density = TRUE
/obj/structure/prop/static_tank/fuel
	desc = "It contains Decatuxole-Hypospaldirol. A non-volatile liquid fuel type that tastes like oranges. Can't really be used for anything outside of atmos-rocket boosters."
	icon_state = "weldtank_old"
/obj/structure/prop/static_tank/water
	desc = "It contains non-potable water. A label on the side instructs you to boil before consumption. It smells vaguely like the showers on the Almayer."
	icon_state = "watertank_old"
/obj/structure/prop/broken_arcade
	desc = "You can't see anything behind the screen, it looks half human and half machine."
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "arcadeb"
	name = "Spirit Phone, The Game, The Movie: II"
/obj/structure/prop/invuln
	layer = ABOVE_MOB_LAYER
	density = TRUE
	icon = 'icons/obj/structures/props/ice_colony/props.dmi'
	icon_state = "ice_tray"
/obj/structure/prop/invuln/catwalk_support
	name = "support lattice"
	icon_state = "support_lattice"
	desc = "The middle of a large set of steel support girders."
	density = FALSE
/obj/structure/prop/invuln/minecart_tracks
	name = "rails"
	icon_state = "rail"
	icon = 'icons/obj/structures/props/mining.dmi'
	density =  0
	desc = "Minecarts and rail vehicles go on these."
	layer = 3
/obj/structure/prop/invuln/minecart_tracks/bumper
	name = "rail bumpers"
	icon_state = "rail_bumpers"
	desc = "This (usually) stops minecarts and other rail vehicles at the end of a line of track."
/obj/structure/prop/invuln/dense
	density = TRUE
/obj/structure/prop/invuln/dense/catwalk_support
	name = "support lattice"
	icon_state = "support_lattice"
	desc = "The base of a large set of steel support girders."
/obj/structure/prop/invuln/dense/ice_tray
	name = "ice slab tray"
	icon_state = "ice_tray"
	desc = "It is a tray filled with slabs of dark ice."
/obj/structure/prop/invuln/ice_prefab
	name = "prefabricated structure"
	desc = "This structure is made of metal support rods and robust poly-kevlon plastics. A derivative of the stuff used in UA ballistics vests, USCM and UPP uniforms. The loose walls roll with each gust of wind."
	icon = 'icons/obj/structures/props/ice_colony/fabs_tileset.dmi'
	icon_state = "fab"
	density = TRUE
	layer = 3
	bound_width = 32
	bound_height = 32
/obj/structure/prop/invuln/ice_prefab/trim
	layer = ABOVE_MOB_LAYER
	density = FALSE
/obj/structure/prop/invuln/ice_prefab/roof_greeble
	icon = 'icons/obj/structures/props/ice_colony/fabs_greebles.dmi'
	icon_state = "antenna"
	layer = ABOVE_MOB_LAYER
	desc = "Windsocks, Air-Con units, solarpanels, oh my!"
	density = FALSE
/obj/structure/prop/invuln/ice_prefab/standalone
	density = TRUE
	icon = 'icons/obj/structures/props/ice_colony/fabs_64.dmi'
	icon_state = "orange"
	layer = 3
	bound_width = 64
	bound_height = 64
/obj/structure/prop/invuln/ice_prefab/standalone/trim
	icon_state = "orange_trim"
	layer = ABOVE_MOB_LAYER
	density = FALSE
/obj/structure/prop/invuln/remote_console_pod
	name = "Remote Console Pod"
	desc = "A drop pod used to launch remote piloting equipment to USCM areas of operation."
	icon = 'icons/obj/structures/droppod_32x64.dmi'
	icon_state = "techpod_open"
	layer = DOOR_CLOSED_LAYER
/obj/structure/prop/invuln/fire
	name = "fire"
	desc = "That isn't going out any time soon."
	color = "#FF7700"
	icon = 'icons/effects/fire.dmi'
	icon_state = "dynamic_2"
	layer = MOB_LAYER
	light_range = 3
	light_on = TRUE
