/// Movement priority uses the existing queue; no extra processing registration.
/atom/movable/lighting_mask/flashlight_60
	var/movement_shadow_pending = FALSE
	var/shadows_ready = FALSE

/atom/movable/lighting_mask/flashlight_60/calculate_lighting_shadows()
	if(SSlighting.started)
		var/turf/destination = get_turf(attached_atom)
		if(!destination || !mask_holder)
			invisibility = INVISIBILITY_ABSTRACT
			shadows_ready = FALSE
			awaiting_update = FALSE
			clear_turf_luminosity()
			clear_shadow_watchers()
			return FALSE
		// Native calculation does not yield: position and geometry publish together.
		// Moved only unions this already-pending mask into the same queue.
		mask_holder.glide_size = INFINITY
		if(mask_holder.loc != destination)
			mask_holder.forceMove(destination)
		movement_shadow_pending = FALSE
	. = ..()
	if(.)
		shadows_ready = TRUE
		invisibility = INVISIBILITY_LIGHTING

/// Publish initial geometry immediately after final range/aim, including short flashes.
/// During world initialization the native queued path owns the calculation.
/atom/movable/lighting_mask/flashlight_60/proc/ensure_shadows_ready()
	if(shadows_ready || !SSlighting.initialized)
		return
	calculate_lighting_shadows()
	if(!awaiting_update)
		SSlighting.mask_queue -= src

/datum/controller/subsystem/lighting
	var/directional_first_batch = TRUE

/// Stable interleaving prevents ordinary masks starving under a small tick budget.
/// Only called before consumption, never while the indexed native loop is running.
/datum/controller/subsystem/lighting/proc/prioritize_directional_shadows()
	if(length(mask_queue) < 2)
		return
	var/list/moving = list()
	var/list/ordinary = list()
	for(var/atom/movable/lighting_mask/mask as anything in mask_queue)
		if(istype(mask, /atom/movable/lighting_mask/flashlight_60))
			var/atom/movable/lighting_mask/flashlight_60/beam = mask
			if(beam.movement_shadow_pending)
				moving += mask
				continue
		ordinary += mask
	if(!length(moving) || !length(ordinary))
		return
	var/list/first = directional_first_batch ? moving : ordinary
	var/list/second = directional_first_batch ? ordinary : moving
	directional_first_batch = !directional_first_batch
	mask_queue.Cut()
	for(var/index in 1 to max(length(first), length(second)))
		if(index <= length(first))
			mask_queue += first[index]
		if(index <= length(second))
			mask_queue += second[index]
