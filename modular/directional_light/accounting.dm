/turf
	/// Static overlay visibility, independent of moving lights and area base lighting.
	var/tmp/static_light_visible = TRUE
	/// Positive hybrid contributors only; hybrid_lights_affecting is an invalidation subscription list.
	var/tmp/list/atom/movable/lighting_mask/hybrid_light_contributors

/// Native luminosity is a visibility output, never a count of overlapping sources.
/turf/proc/refresh_lighting_visibility()
	var/area/lighting_area = loc
	luminosity = (static_light_visible || lighting_area?.area_has_base_lighting || LAZYLEN(hybrid_light_contributors)) ? 1 : 0

/turf/proc/set_static_light_visibility(visible)
	static_light_visible = !!visible
	refresh_lighting_visibility()

/atom/movable/lighting_mask
	/// Actual positive contributions owned by this mask, separate from its obstacle subscriptions.
	var/list/turf/luminous_turfs

/atom/movable/lighting_mask/proc/add_turf_luminosity(turf/target)
	if(alpha <= 0 || blend_mode != BLEND_ADD || turf_light_factor(target) <= 0)
		remove_turf_luminosity(target)
		return
	mark_luminous(target)

/// Use only after a positive light factor has already been established.
/atom/movable/lighting_mask/proc/mark_luminous(turf/target)
	if(target in luminous_turfs)
		return
	LAZYADD(luminous_turfs, target)
	LAZYOR(target.hybrid_light_contributors, src)
	target.refresh_lighting_visibility()

/atom/movable/lighting_mask/proc/remove_turf_luminosity(turf/target)
	if(!(target in luminous_turfs))
		return
	LAZYREMOVE(luminous_turfs, target)
	LAZYREMOVE(target.hybrid_light_contributors, src)
	target.refresh_lighting_visibility()

/// Reconcile an intensity/sign change without rebuilding obstacle geometry.
/atom/movable/lighting_mask/proc/refresh_turf_luminosity()
	for(var/turf/target as anything in affecting_turfs)
		add_turf_luminosity(target)

/// Shadow rebuilds retain unchanged contributions; release only lost dependencies.
/atom/movable/lighting_mask/proc/prune_turf_luminosity()
	for(var/turf/target as anything in luminous_turfs?.Copy())
		if(!(target in affecting_turfs))
			remove_turf_luminosity(target)

/// Also covers contributions released before the subscription list is cleared.
/atom/movable/lighting_mask/proc/clear_turf_luminosity()
	for(var/turf/target as anything in luminous_turfs?.Copy())
		remove_turf_luminosity(target)
