PROCESSING_SUBSYSTEM_DEF(directional_light)
	name = "Directional lights"
	priority = SS_PRIORITY_FAST_OBJECTS
	flags = SS_NO_INIT
	wait = 0.1 SECONDS

/// Cached radial falloff with a feathered ~60-degree beam around SOUTH.
/atom/movable/lighting_mask/flashlight_60
	is_directional = TRUE
	// Dynamic source creation attaches the mask before its first queued calculation.
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/lighting_mask/flashlight_60/Initialize(mapload, ...)
	. = ..()
	var/static/icon/cone_icon
	if(!cone_icon)
		cone_icon = icon(LIGHTING_ICON_BIG, "light_normalized")
		var/icon/aperture = icon(cone_icon)
		aperture.Scale(64, 64)
		for(var/row in 1 to 64)
			for(var/column in 1 to 64)
				var/dx = (column - 32.5) / 32
				var/forward = (32.5 - row) / 32
				aperture.DrawBox(rgb(255, 255, 255, round(255 * beam_weight(forward, dx))), column, row, column, row)
		aperture.Scale(cone_icon.Width(), cone_icon.Height())
		cone_icon.Blend(aperture, ICON_MULTIPLY)
		// Double RGB contribution while preserving the feathered alpha channel.
		cone_icon.MapColors(2,0,0,0, 0,2,0,0, 0,0,2,0, 0,0,0,1, 0,0,0,0)
	icon = cone_icon
	icon_state = ""

/// Diagnostic item using the same controller as production lamps.
/obj/item/device/flashlight/directional_prototype
	name = "directional flashlight prototype"
	desc = "60-degree light test. Examine while holding to inspect cursor event state."
	light_system = MOVABLE_LIGHT
	// Hybrid intensity uses a different scale from ordinary movable lights.
	light_power = 8
	light_range = 10
	light_mask_type = /atom/movable/lighting_mask/flashlight_60

/obj/item/device/flashlight/directional_prototype/get_examine_text(mob/user)
	. = ..()
	var/datum/component/directional_beam/beam = GetComponent(/datum/component/directional_beam)
	if(beam)
		. += SPAN_NOTICE("Beam: [beam.last_event_state]; [round(beam.beam_angle)] degrees.")
