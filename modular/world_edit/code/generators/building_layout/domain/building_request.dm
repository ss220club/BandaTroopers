/datum/world_edit_building_request
	var/program_id = ""
	var/style_id = ""
	var/datum/world_edit_building_size_profile/size_profile
	var/seed = 0
	var/direction = NORTH
	var/datum/world_edit_building_overwrite_policy/overwrite_policy
	var/datum/world_edit_shape_contract/shape
	var/datum/world_edit_validation_verdict/verdict

/datum/world_edit_building_size_profile
	var/id = WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD
	var/label = "Standard"
	var/min_width = 7
	var/min_depth = 7
	var/preferred_width = 11
	var/preferred_depth = 11
	var/max_width = WORLD_EDIT_BUILDING_MAX_FOOTPRINT_WIDTH
	var/max_depth = WORLD_EDIT_BUILDING_MAX_FOOTPRINT_DEPTH
	var/allow_point_family_masks = TRUE

/datum/world_edit_building_size_profile/New(_id = WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD, _label = "Standard", _min_width = 7, _min_depth = 7, _preferred_width = 11, _preferred_depth = 11, _max_width = WORLD_EDIT_BUILDING_MAX_FOOTPRINT_WIDTH, _max_depth = WORLD_EDIT_BUILDING_MAX_FOOTPRINT_DEPTH)
	. = ..()
	id = length("[_id]") ? "[_id]" : WORLD_EDIT_BUILDING_SIZE_PROFILE_STANDARD
	label = length("[_label]") ? "[_label]" : id
	min_width = max(round(text2num("[_min_width]") || 1), 1)
	min_depth = max(round(text2num("[_min_depth]") || 1), 1)
	preferred_width = max(round(text2num("[_preferred_width]") || min_width), min_width)
	preferred_depth = max(round(text2num("[_preferred_depth]") || min_depth), min_depth)
	max_width = clamp(round(text2num("[_max_width]") || WORLD_EDIT_BUILDING_MAX_FOOTPRINT_WIDTH), preferred_width, WORLD_EDIT_BUILDING_MAX_FOOTPRINT_WIDTH)
	max_depth = clamp(round(text2num("[_max_depth]") || WORLD_EDIT_BUILDING_MAX_FOOTPRINT_DEPTH), preferred_depth, WORLD_EDIT_BUILDING_MAX_FOOTPRINT_DEPTH)

/datum/world_edit_building_size_profile/proc/validate()
	var/datum/world_edit_validation_verdict/profile_verdict = new(WORLD_EDIT_BUILDING_PREFLIGHT_SUPPORTED, WORLD_EDIT_BUILDING_STAGE_REQUEST_NORMALIZATION)
	if(!length(id))
		profile_verdict.status = WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST
		profile_verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_INVALID_SIZE_PROFILE, "Size profile id is required.")
	if(max_width > WORLD_EDIT_BUILDING_MAX_FOOTPRINT_WIDTH || max_depth > WORLD_EDIT_BUILDING_MAX_FOOTPRINT_DEPTH)
		profile_verdict.status = WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST
		profile_verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_FOOTPRINT_TOO_LARGE, "Size profile exceeds the 32x32 cap.")
	return profile_verdict

/datum/world_edit_building_size_profile/proc/as_payload()
	return list(
		"id" = id,
		"label" = label,
		"min_width" = min_width,
		"min_depth" = min_depth,
		"preferred_width" = preferred_width,
		"preferred_depth" = preferred_depth,
		"max_width" = max_width,
		"max_depth" = max_depth,
		"allow_point_family_masks" = allow_point_family_masks ? TRUE : FALSE,
	)

/datum/world_edit_building_overwrite_policy
	var/id = WORLD_EDIT_BUILDING_OVERWRITE_POLICY_SAFE
	var/respect_blockers = TRUE
	var/replace_blocked_turfs = FALSE
	var/confirmed_preview_revision = null
	var/max_replaced_blockers = 0
	var/target_state_hash = null

/datum/world_edit_building_overwrite_policy/New(_id = WORLD_EDIT_BUILDING_OVERWRITE_POLICY_SAFE, _respect_blockers = TRUE, _replace_blocked_turfs = FALSE, _confirmed_preview_revision = null, _max_replaced_blockers = 0, _target_state_hash = null)
	. = ..()
	id = length("[_id]") ? "[_id]" : WORLD_EDIT_BUILDING_OVERWRITE_POLICY_SAFE
	respect_blockers = _respect_blockers ? TRUE : FALSE
	replace_blocked_turfs = _replace_blocked_turfs ? TRUE : FALSE
	confirmed_preview_revision = _confirmed_preview_revision
	max_replaced_blockers = max(round(text2num("[_max_replaced_blockers]") || 0), 0)
	target_state_hash = _target_state_hash

/datum/world_edit_building_overwrite_policy/proc/validate()
	var/datum/world_edit_validation_verdict/policy_verdict = new(WORLD_EDIT_BUILDING_PREFLIGHT_SUPPORTED, WORLD_EDIT_BUILDING_STAGE_REQUEST_NORMALIZATION)
	if(!length(id))
		policy_verdict.status = WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST
		policy_verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_INVALID_OVERWRITE_POLICY, "Overwrite policy id is required.")
	if(replace_blocked_turfs && isnull(confirmed_preview_revision))
		policy_verdict.status = WORLD_EDIT_BUILDING_PREFLIGHT_INVALID_REQUEST
		policy_verdict.add_hard_error(WORLD_EDIT_BUILDING_ERROR_INVALID_OVERWRITE_POLICY, "Destructive replacement requires a confirmed preview revision.")
	return policy_verdict

/datum/world_edit_building_overwrite_policy/proc/as_payload()
	return list(
		"id" = id,
		"respect_blockers" = respect_blockers ? TRUE : FALSE,
		"replace_blocked_turfs" = replace_blocked_turfs ? TRUE : FALSE,
		"confirmed_preview_revision" = confirmed_preview_revision,
		"max_replaced_blockers" = max_replaced_blockers,
		"target_state_hash" = target_state_hash,
	)
