/// Prepared request object passed from controller logic into the dispatch adapter.
/datum/rto_support_request
	/// Human that initiated the support call.
	var/mob/living/carbon/human/owner
	/// Target turf chosen through the binocular flow.
	var/turf/target_turf
	/// Template active for the owner at request time.
	var/datum/rto_support_template/template
	/// Action template selected for this request.
	var/datum/rto_support_action_template/action_template
	/// Visibility sector active at request time.
	var/datum/rto_visibility_zone/visibility_zone
	/// Adapter-facing key copied from the action template.
	var/dispatch_key
	/// Path dispatched by the adapter.
	var/dispatch_path
	/// Runtime-adjusted spread applied to a fresh support instance.
	var/scatter_override = 0
	/// Human-readable name used in logs and ghost notifications.
	var/display_name = ""
	/// Request family: support or visibility payload.
	var/request_kind = RTO_SUPPORT_REQUEST_SUPPORT
	/// Marker style used for target previews.
	var/target_marker_style = RTO_SUPPORT_MARKER_STATIC
	/// Marker duration in deciseconds.
	var/target_marker_duration = 0
	/// Whether the request came from a zone-dependent action.
	var/requires_visibility_zone = FALSE
	/// Whether ghosts should be notified about the request.
	var/announce_to_ghosts = TRUE

/// Checks whether the request is structurally valid.
/datum/rto_support_request/proc/is_valid()
	if(!owner || QDELETED(owner))
		return FALSE
	if(!target_turf || QDELETED(target_turf))
		return FALSE
	if(!template || QDELETED(template))
		return FALSE
	if(request_kind == RTO_SUPPORT_REQUEST_SUPPORT && (!action_template || QDELETED(action_template)))
		return FALSE
	if(dispatch_path)
		return TRUE
	if(action_template?.fire_support_path)
		return TRUE
	return FALSE
