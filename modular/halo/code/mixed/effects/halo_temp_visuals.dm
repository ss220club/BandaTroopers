/particles/plasma
	icon = 'icons/halo/effects/plasma.dmi'
	icon_state = "circle"
	width = 340
	height = 340
	count = 100
	spawning = 5
	gradient = list("#FFFFFF", "#9990ffff", "#3e308aff")
	color_change = generator(GEN_NUM, 0.025, 0.05)
	lifespan = 15
	fade = generator(GEN_NUM, 25, 45)
	grow = -0.075
	velocity = list(0, 15)
	position = generator(GEN_CIRCLE, 3, 3, NORMAL_RAND)
	scale = generator(GEN_NUM, 0.65, 0.9)
	rotation = generator(GEN_NUM, 45, 135)
	spin = generator(GEN_NUM, -20, 20)
	drift = generator(GEN_VECTOR, list(-0.5, 0), list(0.5, 0), LINEAR_RAND)

/particles/plasma_explosion
	icon = 'icons/halo/effects/plasma.dmi'
	icon_state = list("shape_1" = 1, "shape_2" = 1, "shape_3" = 1, "shape_4" = 1)
	width = 340
	height = 340
	count = 45
	spawning = 45
	gradient = list("#FFFFFF", "#9990ffff", "#3e308aff")
	color_change = generator(GEN_NUM, 0.025, 0.01)
	lifespan = 6
	fade = generator(GEN_NUM, 25, 45)
	grow = -0.075
	velocity = generator(GEN_CIRCLE, 45, 35, NORMAL_RAND)
	scale = generator(GEN_NUM, 1.5, 1.7)
	friction = generator(GEN_NUM, 0.5, 0.25)

/particles/plasma_explosion/small
	count = 15
	spawning = 15
	velocity = generator(GEN_CIRCLE, 10, 15, NORMAL_RAND)
	scale = generator(GEN_NUM, 0.5, 1)

/particles/plasma_explosion/green
	count = 35
	spawning = 35
	gradient = list("#FFFFFF", "#5dbf67ff", "#328a30ff")
	velocity = generator(GEN_CIRCLE, 35, 25, NORMAL_RAND)

/particles/plasma_explosion/glassing
	width = 850
	height = 850
	count = 500
	spawning = 45
	fade = generator(GEN_NUM, 25, 55)
	position = list(0, -218)
	scale = generator(GEN_NUM, 2, 3)
	gradient = list("#FFFFFF", "#e67d71ff", "#470d0dff")
	velocity = generator(GEN_CIRCLE, 85, 75, NORMAL_RAND)

/particles/plasma_explosion/shield_pop
	count = 15
	spawning = 15
	velocity = generator(GEN_CIRCLE, 10, 15, NORMAL_RAND)
	scale = generator(GEN_NUM, 0.65, 1.1)

/particles/plasma_explosion/shield_hit
	count = 5
	spawning = 5
	velocity = generator(GEN_CIRCLE, 10, 15, NORMAL_RAND)
	fade = generator(GEN_NUM, 35, 55)
	scale = generator(GEN_NUM, 0.2, 0.25)

/particles/shield_spark
	icon = 'icons/halo/effects/plasma.dmi'
	icon_state = "circle"
	width = 150
	height = 150
	count = 12
	spawning = 12
	gradient = list("#FFFFFF", "#bce0ff", "#3e308aff")
	color_change = 0.25
	lifespan = 5
	fade = 5
	scale = list(0.17, 0.17)
	grow = -0.03
	velocity = generator(GEN_CIRCLE, 35, 35, NORMAL_RAND)
	position = generator(GEN_CIRCLE, 5, 5, NORMAL_RAND)
	friction = generator(GEN_NUM, 0.5, 0.4)

/obj/effect/temp_visual/plasma_incoming
	icon = null
	duration = 3 SECONDS
	pixel_z = 480
	light_on = TRUE
	light_power = 3
	light_range = 3
	light_color = "#71a2e6ff"
	layer = ABOVE_FLY_LAYER
	indestructible = TRUE

/obj/effect/temp_visual/plasma_incoming/Initialize(mapload)
	. = ..()
	particles = new /particles/plasma
	add_filter("pixel_outline", 1, outline_filter(1, "#4f308aff", OUTLINE_SHARP))
	add_filter("glow", 2, drop_shadow_filter(0, 0, 5, 1, "#4f308aff"))
	addtimer(VARSET_CALLBACK(particles, count, 0), 0.65 SECONDS)
	animate(src, pixel_z = -140, time = 1.25 SECONDS)

/obj/effect/temp_visual/plasma_explosion
	icon = null
	duration = 7
	light_on = TRUE
	light_power = 5
	light_range = 6
	light_color = "#71a2e6ff"
	layer = ABOVE_MOB_LAYER
	indestructible = TRUE
	var/outline_color = "#4f308aff"
	var/particles_used = /particles/plasma_explosion

/obj/effect/temp_visual/plasma_explosion/Initialize(mapload)
	. = ..()
	halo_perf_bump_temp_visuals()
	particles = new particles_used
	add_filter("pixel_outline", 1, outline_filter(1, outline_color, OUTLINE_SHARP))
	add_filter("glow", 2, drop_shadow_filter(0, 0, 5, 1, outline_color))
	addtimer(VARSET_CALLBACK(particles, count, 0), 0.25 SECONDS)

/obj/effect/temp_visual/plasma_explosion/small
	light_power = 2
	light_range = 3
	particles_used = /particles/plasma_explosion/small

/obj/effect/temp_visual/plasma_explosion/green
	light_color = "#75d66eff"
	particles_used = /particles/plasma_explosion/green
	outline_color = "#328a30ff"

/obj/effect/temp_visual/plasma_explosion/shield_pop
	light_color = "#77b6ff"
	particles_used = /particles/plasma_explosion/shield_pop
	outline_color = "#77b6ff"
	light_power = 2
	light_range = 3

/obj/effect/temp_visual/plasma_explosion/shield_hit
	light_color = "#77b6ff"
	particles_used = /particles/plasma_explosion/shield_hit
	outline_color = "#77b6ff"
	light_power = 1
	light_range = 2

/obj/effect/temp_visual/banshee_flyby
	icon = 'icons/halo/effects/banshee_flyby.dmi'
	icon_state = "banshee_shadow"
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 2 SECONDS
	pixel_x = -22
	pixel_z = -480
	indestructible = TRUE

/obj/effect/temp_visual/banshee_flyby/Initialize()
	. = ..()
	animate(src, pixel_z = 960, time = 2 SECONDS)

/obj/effect/temp_visual/glassing_beam
	icon = 'icons/halo/effects/glassing.dmi'
	icon_state = "beam"
	pixel_x = -50
	duration = 8.5 SECONDS
	light_on = TRUE
	light_power = 25
	light_range = 50
	light_color = "#e67d71ff"
	layer = ABOVE_FLY_LAYER
	indestructible = TRUE
	var/outline_color = "#c50909ff"
	var/particles_used = /particles/plasma_explosion/glassing

/obj/effect/temp_visual/glassing_beam/Initialize(mapload)
	. = ..()
	particles = new particles_used
	add_filter("pixel_outline", 1, outline_filter(1, outline_color, OUTLINE_SHARP))
	add_filter("glow", 2, drop_shadow_filter(0, 0, 3, 1, outline_color))
	addtimer(CALLBACK(src, PROC_REF(beam_off)), 7.5 SECONDS)

/obj/effect/temp_visual/glassing_beam/proc/beam_off()
	particles.count = 0
	icon_state = "off"
	light_on = FALSE

/obj/effect/temp_visual/shield_spark
	icon = null
	duration = 4
	layer = ABOVE_MOB_LAYER
	indestructible = TRUE

/obj/effect/temp_visual/shield_spark/Initialize(mapload)
	. = ..()
	halo_perf_bump_temp_visuals()
	particles = new /particles/shield_spark
	addtimer(VARSET_CALLBACK(particles, count, 0), 1)
	add_filter("glow", 2, drop_shadow_filter(0, 0, 3, 1, "#77b6ff"))
