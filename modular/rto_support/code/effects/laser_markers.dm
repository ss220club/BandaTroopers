/// Module-local laser marker variants for the RTO workflow.
/obj/effect/overlay/rto_laser_marker
	name = "laser marker"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_range = 2
	icon = 'icons/obj/items/weapons/projectiles.dmi'
	icon_state = "laser_target2"
	layer = ABOVE_FLY_LAYER
	var/effect_duration = 10

/obj/effect/overlay/rto_laser_marker/New(loc, duration_override)
	. = ..()
	if(isnum(duration_override) && duration_override > 0)
		effect_duration = duration_override
	QDEL_IN(src, effect_duration)

/obj/effect/overlay/rto_laser_marker/static
	icon_state = "laser_target2"

/obj/effect/overlay/rto_laser_marker/coordinate
	icon_state = "laser_target_coordinate"

/obj/effect/overlay/rto_laser_marker/slow_blink
	icon_state = "laser_target3"

/obj/effect/overlay/rto_laser_marker/slow_blink/New(loc, duration_override)
	. = ..()
	alpha = 255
	animate(src, alpha = 80, time = 0.6 SECONDS, loop = -1)
	animate(alpha = 255, time = 0.6 SECONDS)
