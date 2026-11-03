///Estimates the light power based on the alpha of the light and the range.
///Assumes a linear fallout at (0, alpha/255) to (range, 0)
///Used for lightig mask lumcount calculations
#define LIGHT_POWER_ESTIMATION(alpha, range, distance) max((alpha * (range - distance)) / (255 * range), 0)

/// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	//Consider static lights
	lighting_corner_NE?.vis_update()
	lighting_corner_SE?.vis_update()
	lighting_corner_SW?.vis_update()
	lighting_corner_NW?.vis_update()

	//consider dynamic lights
	for(var/atom/movable/lighting_mask/mask as anything in hybrid_lights_affecting)
		mask.queue_mask_update()
	reconsider_directional_lights() // SS220 EDIT: notify geometry-only watchers behind partial blockers too.

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	var/totallums = 0
	if (static_lighting_object)
		var/datum/static_lighting_corner/L
		L = lighting_corner_NE
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g
		L = lighting_corner_SE
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g
		L = lighting_corner_SW
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g
		L = lighting_corner_NW
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g

		totallums /= 12 // 4 corners, each with 3 channels, get the average.

		totallums = (totallums - minlum) / (maxlum - minlum)

		totallums = CLAMP01(totallums)
	else
		totallums = 1

	for(var/atom/movable/lighting_mask/mask as anything in hybrid_lights_affecting)
		if(mask.radius <= 0) // SS220 EDIT: inactive masks cannot contribute or divide by their radius.
			continue
		if(mask.blend_mode == BLEND_ADD)
			// totallums += LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
			totallums += LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom))) * mask.turf_light_factor(src) // SS220 EDIT: cone/halo factor.
		else
			// totallums -= LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
			totallums -= LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom))) * mask.turf_light_factor(src) // SS220 EDIT: ordinary masks retain factor1.
	return clamp(totallums, 0.0, 1.0)

///Proc to add movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/add_opacity_source(atom/movable/new_source)
	LAZYADD(opacity_sources, new_source)
	if(opacity)
		return
	recalculate_directional_opacity()
	reconsider_directional_lights() // SS220 EDIT: a full cell and four borders can have identical opacity bits.


///Proc to remove movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/remove_opacity_source(atom/movable/old_source)
	LAZYREMOVE(opacity_sources, old_source)
	if(opacity) //Still opaque, no need to worry on updating.
		return
	recalculate_directional_opacity()
	reconsider_directional_lights() // SS220 EDIT: blocker kind can change without changing the directional bitmask.


///Calculate on which directions this turfs block view.
// /turf/proc/recalculate_directional_opacity()
/turf/proc/recalculate_directional_opacity(atom/movable/turning_source, new_dir) // SS220 EDIT: direction signals precede assignment.
	. = directional_opacity
	if(opacity)
		directional_opacity = ALL_CARDINALS
		if(. != directional_opacity)
			reconsider_lights()
		return
	directional_opacity = NONE
	for(var/atom/movable/opacity_source as anything in opacity_sources)
		if(opacity_source.flags_atom & ON_BORDER)
			// directional_opacity |= opacity_source.dir
			directional_opacity |= (opacity_source == turning_source ? new_dir : opacity_source.dir) // SS220 EDIT: use pending border direction.
		else //If fulltile and opaque, then the whole tile blocks view, no need to continue checking.
			directional_opacity = ALL_CARDINALS
			break
	if(. != directional_opacity && (. == ALL_CARDINALS || directional_opacity == ALL_CARDINALS))
		reconsider_lights() //The lighting system only cares whether the tile is fully concealed from all directions or not.
	else if(. != directional_opacity) // SS220 EDIT: directional masks also care about partial borders.
		reconsider_directional_lights()
