/// Adapter that translates prepared requests into actual fire support execution.
/datum/rto_support_dispatch_service

/// Dispatches a prepared request through the adapter layer.
/datum/rto_support_dispatch_service/proc/dispatch_request(datum/rto_support_request/request)
	if(!request?.is_valid())
		return FALSE

	var/path_to_dispatch = request.dispatch_path
	if(!path_to_dispatch)
		path_to_dispatch = request.action_template?.fire_support_path
	if(!path_to_dispatch)
		return FALSE

	var/datum/fire_support/fire_support = new path_to_dispatch
	fire_support.enable_firesupport()
	fire_support.faction = request.owner.faction
	fire_support.scatter_range = request.scatter_override
	if(request.display_name)
		fire_support.name = request.display_name

	spawn_request_marker(request, fire_support)

	// The base fire support datums are singleton-oriented, so request-local instances
	// need explicit cleanup after their timers and delayed impacts are complete.
	QDEL_IN(fire_support, max(1 MINUTES, fire_support.cooldown_duration + fire_support.delay_to_impact))

	if(request.request_kind == RTO_SUPPORT_REQUEST_SUPPORT && request.announce_to_ghosts)
		notify_ghosts(
			header = "RTO Support",
			message = "[request.owner] has called [request.display_name] at [request.target_turf.x],[request.target_turf.y],[request.target_turf.z].",
			source = request.target_turf,
			action = NOTIFY_JUMP
		)

	fire_support.initiate_fire_support(request.target_turf, request.owner)
	return TRUE

/datum/rto_support_dispatch_service/proc/spawn_request_marker(datum/rto_support_request/request, datum/fire_support/fire_support)
	if(!request?.target_turf)
		return null

	var/marker_style = request.target_marker_style
	if(!length(marker_style))
		marker_style = request.request_kind == RTO_SUPPORT_REQUEST_VISIBILITY ? RTO_SUPPORT_MARKER_SLOW_BLINK : RTO_SUPPORT_MARKER_STATIC

	var/duration = request.target_marker_duration
	if(duration <= 0)
		duration = max(1 SECONDS, fire_support?.delay_to_impact || 1 SECONDS)

	return create_request_marker(request.target_turf, marker_style, duration)

/datum/rto_support_dispatch_service/proc/create_request_marker(turf/target_turf, marker_style = RTO_SUPPORT_MARKER_STATIC, duration = 10)
	if(!target_turf || QDELETED(target_turf))
		return null

	switch(marker_style)
		if(RTO_SUPPORT_MARKER_SLOW_BLINK)
			return new /obj/effect/overlay/rto_laser_marker/slow_blink(target_turf, duration)
		if(RTO_SUPPORT_MARKER_COORDINATE)
			return new /obj/effect/overlay/rto_laser_marker/coordinate(target_turf, duration)
		else
			return new /obj/effect/overlay/rto_laser_marker/static(target_turf, duration)
