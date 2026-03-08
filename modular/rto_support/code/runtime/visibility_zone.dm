/// Runtime representation of one active visibility sector.
/datum/rto_visibility_zone
	/// Human that owns the visibility sector.
	var/mob/living/carbon/human/owner
	/// Center turf of the sector.
	var/turf/center_turf
	/// Radius used by validation.
	var/radius = 0
	/// Duration of the sector in deciseconds.
	var/duration = 0
	/// Absolute expiration timestamp.
	var/expires_at = 0
	/// Template that created the sector.
	var/datum/rto_support_template/source_template
	/// Marker shown at the center of the active sector.
	var/obj/effect/overlay/rto_visibility_zone_marker/marker

/datum/rto_visibility_zone/New(mob/living/carbon/human/new_owner, turf/new_center_turf, datum/rto_support_template/new_source_template)
	owner = new_owner
	center_turf = new_center_turf
	source_template = new_source_template
	. = ..()
	if(center_turf)
		marker = new(center_turf)
	if(source_template)
		radius = source_template.visibility_zone_radius
		duration = source_template.visibility_zone_duration
	expires_at = world.time + duration

/datum/rto_visibility_zone/Destroy()
	owner = null
	center_turf = null
	source_template = null
	QDEL_NULL(marker)
	return ..()

/// Checks whether a turf belongs to the sector.
/datum/rto_visibility_zone/proc/contains_turf(turf/target_turf)
	if(!is_active())
		return FALSE
	if(!target_turf || target_turf.z != center_turf?.z)
		return FALSE
	return get_dist(center_turf, target_turf) <= radius

/// Checks whether the sector is active.
/datum/rto_visibility_zone/proc/is_active()
	return owner && center_turf && world.time < expires_at

/// Expires the sector and performs cleanup.
/datum/rto_visibility_zone/proc/expire()
	expires_at = world.time
	QDEL_NULL(marker)
	return TRUE

/obj/effect/overlay/rto_visibility_zone_marker
	name = "visibility marker"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_range = 2
	icon = 'icons/obj/items/weapons/projectiles.dmi'
	icon_state = "laser_target3"
	layer = ABOVE_FLY_LAYER
