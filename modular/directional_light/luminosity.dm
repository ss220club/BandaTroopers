/// Default light factor preserves ordinary hybrid lighting behavior.
/atom/movable/lighting_mask/proc/turf_light_factor(turf/target)
	return 1

/atom/movable/lighting_mask/flashlight_60
	var/cached_heading
	var/heading_sin
	var/heading_cos

/// Shared normalized aperture for the texture and gameplay lighting.
/atom/movable/lighting_mask/flashlight_60/proc/beam_weight(forward, side)
	var/static/inner_slope = tan(20)
	var/static/outer_slope = tan(40)
	var/beam = 0
	if(forward > 0)
		beam = clamp((outer_slope - abs(side) / forward) / (outer_slope - inner_slope), 0, 1)
		beam = beam * beam * (3 - 2 * beam)
	var/halo = clamp(1 - sqrt(side * side + forward * forward) / 0.1, 0, 1)
	halo = halo * halo * (3 - 2 * halo)
	return max(beam, halo)

/atom/movable/lighting_mask/flashlight_60/turf_light_factor(turf/target)
	prepare_heading()
	var/turf/origin = get_turf(attached_atom)
	return factor_from_origin(target, origin)

/atom/movable/lighting_mask/flashlight_60/proc/prepare_heading()
	if(cached_heading == current_angle && !isnull(heading_sin))
		return
	cached_heading = current_angle
	heading_sin = sin(current_angle + 180)
	heading_cos = cos(current_angle + 180)

/// Caller prepares heading once; origin is shared across a rotation's candidate pass.
/atom/movable/lighting_mask/flashlight_60/proc/factor_from_origin(turf/target, turf/origin)
	if(!origin || !target || origin.z != target.z || radius <= 0)
		return 0
	var/dx = (target.x - origin.x) / radius
	var/dy = (target.y - origin.y) / radius
	if(dx * dx + dy * dy >= 1)
		return 0
	var/forward = dx * heading_sin + dy * heading_cos
	var/side = dx * heading_cos - dy * heading_sin
	return 2 * beam_weight(forward, side)

/atom/movable/lighting_mask/flashlight_60/rotate(angle)
	set_beam_transform(angle)
	prepare_heading()
	var/turf/origin = get_turf(attached_atom)
	// At range10: at most441 cached candidates, no dview/shadow rebuilding.
	for(var/turf/target as anything in affecting_turfs)
		if(alpha > 0 && blend_mode == BLEND_ADD && factor_from_origin(target, origin) > 0)
			mark_luminous(target)
		else
			remove_turf_luminosity(target)
