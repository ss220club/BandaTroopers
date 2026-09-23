#define WORLD_EDIT_BUILDING_SPACE_FUNCTIONAL_ROOM "functional_room"
#define WORLD_EDIT_BUILDING_SPACE_OPEN_BAY "open_bay"
#define WORLD_EDIT_BUILDING_SPACE_CIRCULATION "circulation"
#define WORLD_EDIT_BUILDING_SPACE_CHOKE "choke"
#define WORLD_EDIT_BUILDING_SPACE_NESTED_ROOM "nested_room"

#define WORLD_EDIT_BUILDING_CIRCULATION_ENCLOSED_ROUTE "enclosed_route"
#define WORLD_EDIT_BUILDING_CIRCULATION_ROOM_OWNED_AISLE "room_owned_aisle"

/datum/world_edit_building_zone_spec
	var/id = ""
	var/label = ""
	var/role = ""
	var/privacy_class = "public"
	var/min_area = 1
	var/required = TRUE
	var/optional = FALSE
	var/optional_weight = 60
	var/optional_min_footprint = 0
	var/must_touch_route = TRUE
	var/privacy_sensitive = FALSE
	var/window_allowed = TRUE
	var/divider_mode = "none"
	var/faction = ""
	var/danger = 0
	var/clutter_density = 0
	var/list/anchor_tags = list()
	var/spatial_kind = WORLD_EDIT_BUILDING_SPACE_FUNCTIONAL_ROOM
	var/counts_toward_target = TRUE
	var/min_capacity_units = 0
	var/capacity_kind = ""
	/// Circulation is either independent corridor floor or an explicit overlay
	/// owned by one functional room. Functional zones leave these fields inert.
	var/circulation_kind = WORLD_EDIT_BUILDING_CIRCULATION_ENCLOSED_ROUTE
	var/circulation_owner_room_id = ""
	var/circulation_min_width = 1

/datum/world_edit_building_zone_spec/New(_id, _label, _role, _min_area = 1, _required = TRUE, _must_touch_route = TRUE, _privacy_sensitive = FALSE, list/_anchor_tags = null, _window_allowed = TRUE, _divider_mode = "none", _privacy_class = null, _optional = FALSE, _optional_weight = 60, _optional_min_footprint = 0)
	. = ..()
	id = "[_id]"
	label = "[_label]"
	role = "[_role]"
	privacy_class = length("[_privacy_class]") ? "[_privacy_class]" : null
	min_area = max(round(text2num("[_min_area]") || 1), 0)
	required = _required ? TRUE : FALSE
	optional = _optional || !required ? TRUE : FALSE
	optional_weight = clamp(round(text2num("[_optional_weight]") || 60), 0, 100)
	optional_min_footprint = max(round(text2num("[_optional_min_footprint]") || 0), 0)
	must_touch_route = _must_touch_route ? TRUE : FALSE
	privacy_sensitive = _privacy_sensitive ? TRUE : FALSE
	window_allowed = _window_allowed ? TRUE : FALSE
	divider_mode = length("[_divider_mode]") ? "[_divider_mode]" : "none"
	anchor_tags = islist(_anchor_tags) ? _anchor_tags.Copy() : list()
	if(!length("[privacy_class]") || privacy_class == "null")
		if(privacy_sensitive)
			privacy_class = "private"
		else if(role in list("secure", "storage", "service", "support", "nested"))
			privacy_class = "secure"
		else if(role in list("entry", "public", "public_med", "choke", "route"))
			privacy_class = "public"
		else
			privacy_class = "semi_private"
	configure_spatial_contract()

/datum/world_edit_building_zone_spec/proc/configure_spatial_contract()
	switch(role)
		if("entry", "route")
			spatial_kind = WORLD_EDIT_BUILDING_SPACE_CIRCULATION
			counts_toward_target = FALSE
		if("choke")
			spatial_kind = WORLD_EDIT_BUILDING_SPACE_CHOKE
			counts_toward_target = FALSE
		if("hub", "public", "public_med", "work", "staging")
			spatial_kind = WORLD_EDIT_BUILDING_SPACE_OPEN_BAY
			counts_toward_target = TRUE
		if("nested")
			spatial_kind = WORLD_EDIT_BUILDING_SPACE_NESTED_ROOM
			counts_toward_target = TRUE
		else
			spatial_kind = WORLD_EDIT_BUILDING_SPACE_FUNCTIONAL_ROOM
			counts_toward_target = TRUE

/datum/world_edit_building_zone_spec/proc/clone()
	var/datum/world_edit_building_zone_spec/copy = new /datum/world_edit_building_zone_spec(
		id,
		label,
		role,
		min_area,
		required,
		must_touch_route,
		privacy_sensitive,
		anchor_tags,
		window_allowed,
		divider_mode,
		privacy_class,
		optional,
		optional_weight,
		optional_min_footprint
	)
	copy.spatial_kind = spatial_kind
	copy.counts_toward_target = counts_toward_target
	copy.min_capacity_units = min_capacity_units
	copy.capacity_kind = capacity_kind
	copy.circulation_kind = circulation_kind
	copy.circulation_owner_room_id = circulation_owner_room_id
	copy.circulation_min_width = circulation_min_width
	return copy

/datum/world_edit_building_region_spec
	var/id = ""
	var/zone_id = ""
	var/front_min = 0
	var/front_max = 100
	var/lateral_min = -100
	var/lateral_max = 100
	var/priority = 0

/datum/world_edit_building_region_spec/New(_id, _zone_id, _front_min, _front_max, _lateral_min, _lateral_max, _priority = 0)
	. = ..()
	id = "[_id]"
	zone_id = "[_zone_id]"
	front_min = round(text2num("[_front_min]") || 0)
	front_max = round(text2num("[_front_max]") || 0)
	lateral_min = round(text2num("[_lateral_min]") || 0)
	lateral_max = round(text2num("[_lateral_max]") || 0)
	priority = round(text2num("[_priority]") || 0)

/datum/world_edit_building_region_spec/proc/clone()
	return new /datum/world_edit_building_region_spec(id, zone_id, front_min, front_max, lateral_min, lateral_max, priority)

/datum/world_edit_building_solved_region
	var/id = ""
	var/zone_id = ""
	var/list/turfs = list()
	var/turf/focus_turf
	var/priority = 0
	var/x1 = null
	var/y1 = null
	var/x2 = null
	var/y2 = null

/datum/world_edit_building_solved_region/New(_id, _zone_id, _priority = 0)
	. = ..()
	id = "[_id]"
	zone_id = "[_zone_id]"
	priority = round(text2num("[_priority]") || 0)

/datum/world_edit_building_room
	var/id = ""
	var/zone_id = ""
	var/role = ""
	var/list/turfs = list()
	var/turf/focus_turf
	var/x1 = null
	var/y1 = null
	var/x2 = null
	var/y2 = null
	var/area = 0
	var/tiny = FALSE

/datum/world_edit_building_room/New(_id, _zone_id, _role = "")
	. = ..()
	id = "[_id]"
	zone_id = "[_zone_id]"
	role = "[_role]"

/datum/world_edit_building_room/proc/add_turf(turf/target_turf)
	if(!istype(target_turf) || target_turf in turfs)
		return
	turfs += target_turf
	area = length(turfs)
	if(isnull(x1) || target_turf.x < x1)
		x1 = target_turf.x
	if(isnull(x2) || target_turf.x > x2)
		x2 = target_turf.x
	if(isnull(y1) || target_turf.y < y1)
		y1 = target_turf.y
	if(isnull(y2) || target_turf.y > y2)
		y2 = target_turf.y
	tiny = area <= 1

/datum/world_edit_building_nested_room_spec
	var/outer_zone_id = ""
	var/inner_zone_id = ""
	var/min_width = 9
	var/min_height = 9
	var/margin = 1

/datum/world_edit_building_nested_room_spec/New(_outer_zone_id, _inner_zone_id, _min_width = 9, _min_height = 9, _margin = 1)
	. = ..()
	outer_zone_id = "[_outer_zone_id]"
	inner_zone_id = "[_inner_zone_id]"
	min_width = max(round(text2num("[_min_width]") || 1), 1)
	min_height = max(round(text2num("[_min_height]") || 1), 1)
	margin = max(round(text2num("[_margin]") || 1), 1)

/datum/world_edit_building_nested_room_spec/proc/clone()
	return new /datum/world_edit_building_nested_room_spec(outer_zone_id, inner_zone_id, min_width, min_height, margin)

/datum/world_edit_building_adjacency_rule
	var/zone_a = ""
	var/zone_b = ""
	var/required = TRUE

/datum/world_edit_building_adjacency_rule/New(_zone_a, _zone_b, _required = TRUE)
	. = ..()
	zone_a = "[_zone_a]"
	zone_b = "[_zone_b]"
	required = _required ? TRUE : FALSE

/datum/world_edit_building_adjacency_rule/proc/clone()
	return new /datum/world_edit_building_adjacency_rule(zone_a, zone_b, required)

/datum/world_edit_building_forbidden_rule
	var/id = ""
	var/kind = "zone_anchor"
	var/zone_id = ""
	var/target_id = ""
	var/severity = 100

/datum/world_edit_building_forbidden_rule/New(_id, _kind, _zone_id, _target_id, _severity = 100)
	. = ..()
	id = "[_id]"
	kind = length("[_kind]") ? "[_kind]" : "zone_anchor"
	zone_id = "[_zone_id]"
	target_id = "[_target_id]"
	severity = max(round(text2num("[_severity]") || 100), 0)

/datum/world_edit_building_forbidden_rule/proc/clone()
	return new /datum/world_edit_building_forbidden_rule(id, kind, zone_id, target_id, severity)

/datum/world_edit_building_facade_rule
	var/id = ""
	var/zone_id = ""
	var/role = ""
	var/privacy_class = ""
	var/facade_role = "neutral_face"
	var/window_weight = 50
	var/window_allowed = TRUE
	var/macro_id = "facade_panel"

/datum/world_edit_building_facade_rule/New(_id, _zone_id = null, _role = null, _privacy_class = null, _facade_role = "neutral_face", _window_weight = 50, _window_allowed = TRUE, _macro_id = "facade_panel")
	. = ..()
	id = "[_id]"
	zone_id = length("[_zone_id]") ? "[_zone_id]" : ""
	role = length("[_role]") ? "[_role]" : ""
	privacy_class = length("[_privacy_class]") ? "[_privacy_class]" : ""
	facade_role = length("[_facade_role]") ? "[_facade_role]" : "neutral_face"
	window_weight = clamp(round(text2num("[_window_weight]") || 50), 0, 220)
	window_allowed = _window_allowed ? TRUE : FALSE
	macro_id = length("[_macro_id]") ? "[_macro_id]" : "facade_panel"

/datum/world_edit_building_facade_rule/proc/clone()
	return new /datum/world_edit_building_facade_rule(id, zone_id, role, privacy_class, facade_role, window_weight, window_allowed, macro_id)

/datum/world_edit_building_cluster_spec
	var/id = ""
	var/phase = "major"
	var/pattern = "object"
	var/slot = "table"
	var/category = "table"
	var/list/anchors = list()
	var/min_count = 1
	var/max_count = 1
	var/wall_required = FALSE
	var/chair_count = 0
	var/priority = 50
	var/required = TRUE
	var/signature_id = ""
	var/signature_weight = 0
	var/signature_required = FALSE
	var/optional_zone_id = ""
	var/macro_id = ""
	var/count_cluster_id = ""
	var/count_signature_id = ""
	var/semantic_credit = ""
	var/failure_severity = "required"
	var/acceptance_counter = ""
	var/compact_substitute_id = ""
	var/compact_substitute_only = FALSE
	var/force_placement = FALSE
	var/instance_policy = "global_once"

/datum/world_edit_building_cluster_spec/New(_id, _phase, _pattern, _slot, _category, list/_anchors, _min_count = 1, _max_count = 1, _wall_required = FALSE, _chair_count = 0, _priority = 50, _required = TRUE, _optional_zone_id = null, _macro_id = null)
	. = ..()
	id = "[_id]"
	phase = "[_phase]"
	pattern = "[_pattern]"
	slot = "[_slot]"
	category = "[_category]"
	anchors = islist(_anchors) ? _anchors.Copy() : list()
	min_count = max(round(text2num("[_min_count]") || 1), 0)
	max_count = max(round(text2num("[_max_count]") || min_count), min_count)
	wall_required = _wall_required ? TRUE : FALSE
	chair_count = max(round(text2num("[_chair_count]") || 0), 0)
	priority = round(text2num("[_priority]") || 0)
	required = _required ? TRUE : FALSE
	failure_severity = required ? "required" : "optional"
	optional_zone_id = length("[_optional_zone_id]") ? "[_optional_zone_id]" : ""
	macro_id = length("[_macro_id]") ? "[_macro_id]" : ""
	semantic_credit = id
	acceptance_counter = "[id]_count"

/datum/world_edit_building_cluster_spec/proc/clone()
	var/datum/world_edit_building_cluster_spec/copy = new /datum/world_edit_building_cluster_spec(
		id,
		phase,
		pattern,
		slot,
		category,
		anchors,
		min_count,
		max_count,
		wall_required,
		chair_count,
		priority,
		required,
		optional_zone_id,
		macro_id
	)
	copy.signature_id = signature_id
	copy.signature_weight = signature_weight
	copy.signature_required = signature_required
	copy.count_cluster_id = count_cluster_id
	copy.count_signature_id = count_signature_id
	copy.semantic_credit = semantic_credit
	copy.failure_severity = failure_severity
	copy.acceptance_counter = acceptance_counter
	copy.compact_substitute_id = compact_substitute_id
	copy.compact_substitute_only = compact_substitute_only
	copy.force_placement = force_placement
	copy.instance_policy = instance_policy
	return copy

/datum/world_edit_building_semantic_plan
	var/datum/world_edit_building_archetype/archetype
	var/entry_zone_id = "entry_buffer"
	var/hub_zone_id = ""
	var/primary_zone_id = ""
	var/list/zone_specs = list()
	var/list/zone_specs_by_id = list()
	var/list/region_specs = list()
	var/list/adjacency_rules = list()
	var/list/forbidden_rules = list()
	var/list/cluster_specs = list()
	var/list/object_budgets = list()
	var/list/category_minimums = list()
	var/list/signature_minimums = list()
	var/list/signature_weights = list()
	var/list/mandatory_zones = list()
	var/list/optional_zones = list()
	var/list/selected_optional_zones = list()
	var/list/inactive_optional_zones = list()
	var/list/compact_shed_zones = list()
	var/list/compact_required_min_area = list()
	var/compact_program = FALSE
	var/list/privacy_classes = list()
	var/list/door_policy = list()
	var/list/window_policy = list()
	var/list/facade_rules = list()
	var/list/style_budget = list()
	var/list/repeat_penalties = list()
	var/list/nested_room_specs = list()
	var/nested_outer_zone = null
	var/nested_inner_zone = null
	var/nested_min_width = 9
	var/nested_min_height = 9
	var/min_signature_score = 70

/datum/world_edit_building_semantic_plan/New(datum/world_edit_building_archetype/_archetype, datum/world_edit_building_request/_request = null)
	. = ..()
	archetype = _archetype
	if(!istype(archetype))
		return
	entry_zone_id = archetype.entry_zone
	hub_zone_id = archetype.hub_zone
	primary_zone_id = archetype.primary_zone
	var/footprint_area = round(text2num("[_request?.config?["validated_footprint_count"]]") || 0)
	var/usable_area = round(text2num("[_request?.config?["validated_interior_count"]]") || footprint_area)
	var/list/adaptive_required_min_area = build_adaptive_required_min_area(_request, usable_area)
	if(islist(adaptive_required_min_area))
		compact_program = TRUE
		compact_required_min_area = adaptive_required_min_area.Copy()
	var/list/active_zone_lookup = list()
	var/list/inactive_zone_lookup = list()
	for(var/datum/world_edit_building_zone_spec/source_zone_spec as anything in archetype.zone_specs)
		if(!istype(source_zone_spec))
			continue
		var/datum/world_edit_building_zone_spec/zone_spec = source_zone_spec.clone()
		if(!istype(zone_spec))
			continue
		if(islist(adaptive_required_min_area) && source_zone_spec.required)
			if(isnull(adaptive_required_min_area[source_zone_spec.id]))
				compact_shed_zones += source_zone_spec.id
				inactive_optional_zones += source_zone_spec.id
				inactive_zone_lookup[source_zone_spec.id] = TRUE
				continue
			zone_spec.min_area = max(round(text2num("[adaptive_required_min_area[source_zone_spec.id]]") || 1), 1)
			zone_spec.required = TRUE
			zone_spec.optional = FALSE
		if(zone_spec.optional && !should_select_optional_zone(zone_spec, _request, footprint_area))
			inactive_optional_zones += zone_spec.id
			inactive_zone_lookup[zone_spec.id] = TRUE
			continue
		zone_specs += zone_spec
		active_zone_lookup[zone_spec.id] = TRUE
		if(zone_spec.required)
			mandatory_zones += zone_spec.id
		else
			optional_zones += zone_spec.id
		if(zone_spec.optional)
			selected_optional_zones += zone_spec.id
	for(var/datum/world_edit_building_region_spec/region_spec as anything in archetype.region_specs)
		if(istype(region_spec) && active_zone_lookup[region_spec.zone_id])
			region_specs += region_spec.clone()
	for(var/datum/world_edit_building_adjacency_rule/rule as anything in archetype.adjacency_rules)
		if(istype(rule) && active_zone_lookup[rule.zone_a] && active_zone_lookup[rule.zone_b])
			adjacency_rules += rule.clone()
	for(var/datum/world_edit_building_forbidden_rule/forbidden_rule as anything in archetype.forbidden_rules)
		if(istype(forbidden_rule) && (!length(forbidden_rule.zone_id) || active_zone_lookup[forbidden_rule.zone_id]))
			forbidden_rules += forbidden_rule.clone()
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in archetype.cluster_specs)
		if(cluster_spec_is_active(cluster_spec, inactive_zone_lookup, active_zone_lookup))
			cluster_specs += cluster_spec.clone()
	category_minimums = archetype.category_minimums.Copy()
	var/list/active_category_lookup = list()
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in cluster_specs)
		if(istype(cluster_spec) && length(cluster_spec.category))
			active_category_lookup[cluster_spec.category] = TRUE
	for(var/category as anything in archetype.object_budgets)
		if(active_category_lookup["[category]"] || category_minimums["[category]"])
			object_budgets["[category]"] = archetype.object_budgets[category]
	signature_minimums = archetype.signature_minimums.Copy()
	signature_weights = archetype.signature_weights.Copy()
	privacy_classes = archetype.privacy_classes.Copy()
	door_policy = archetype.door_policy.Copy()
	window_policy = archetype.window_policy.Copy()
	for(var/datum/world_edit_building_facade_rule/facade_rule as anything in archetype.facade_rules)
		if(istype(facade_rule) && (!length(facade_rule.zone_id) || active_zone_lookup[facade_rule.zone_id]))
			facade_rules += facade_rule.clone()
	style_budget = archetype.style_budget.Copy()
	repeat_penalties = archetype.repeat_penalties.Copy()
	for(var/datum/world_edit_building_nested_room_spec/nested_spec as anything in archetype.nested_room_specs)
		if(!istype(nested_spec))
			continue
		if(active_zone_lookup[nested_spec.outer_zone_id] && active_zone_lookup[nested_spec.inner_zone_id])
			nested_room_specs += nested_spec.clone()
	nested_outer_zone = active_zone_lookup["[archetype.nested_outer_zone]"] ? archetype.nested_outer_zone : null
	nested_inner_zone = active_zone_lookup["[archetype.nested_inner_zone]"] ? archetype.nested_inner_zone : null
	nested_min_width = archetype.nested_min_width
	nested_min_height = archetype.nested_min_height
	min_signature_score = archetype.min_signature_score
	if(compact_program)
		apply_compact_object_budget(_request, usable_area)
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in zone_specs)
		if(istype(zone_spec))
			zone_specs_by_id[zone_spec.id] = zone_spec

/datum/world_edit_building_semantic_plan/proc/build_adaptive_required_min_area(datum/world_edit_building_request/request, usable_area)
	if(!istype(request) || !GLOB.world_edit_helpers.parse_bool(request.config["program_shedding"]))
		return null
	usable_area = max(round(text2num("[usable_area]") || 0), 1)
	var/list/result = list()
	var/list/added = list()
	var/degrade_level = "[request.config["size_degrade_level"] || WORLD_EDIT_BUILDING_DEGRADE_NONE]"
	var/budget = max(round(usable_area * 0.75), 1)
	var/list/priority_ids = degrade_level == WORLD_EDIT_BUILDING_DEGRADE_MICRO ? list(primary_zone_id, hub_zone_id, entry_zone_id) : list(entry_zone_id, primary_zone_id, hub_zone_id)
	for(var/zone_id as anything in priority_ids)
		if(!length("[zone_id]") || added["[zone_id]"])
			continue
		var/list/archetype_zone_lookup = archetype?.zone_specs_by_id
		var/datum/world_edit_building_zone_spec/zone_spec = islist(archetype_zone_lookup) ? archetype_zone_lookup["[zone_id]"] : null
		if(!istype(zone_spec))
			continue
		var/min_area = min(max(zone_spec.min_area, 1), max(budget, 1))
		result[zone_spec.id] = min_area
		added[zone_spec.id] = TRUE
		budget -= min_area
		if(degrade_level == WORLD_EDIT_BUILDING_DEGRADE_MICRO)
			return result
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in archetype.zone_specs)
		if(!istype(zone_spec) || !zone_spec.required || added[zone_spec.id])
			continue
		var/min_required = zone_spec.divider_mode == "room" ? 2 : 1
		if(budget < min_required)
			continue
		var/min_area = min(max(zone_spec.min_area, min_required), budget)
		result[zone_spec.id] = min_area
		added[zone_spec.id] = TRUE
		budget -= min_area
	return result

/datum/world_edit_building_semantic_plan/proc/apply_compact_object_budget(datum/world_edit_building_request/request, usable_area)
	usable_area = max(round(text2num("[usable_area]") || 0), 1)
	var/detail_budget = clamp(round(text2num("[request?.config?["detail_budget"]]") || 0), 0, 100)
	var/max_optional_objects = detail_budget <= 0 ? 0 : max(round((usable_area * detail_budget) / 180), 1)
	var/remaining_optional = max_optional_objects
	for(var/category as anything in object_budgets)
		var/current_budget = max(round(text2num("[object_budgets[category]]") || 0), 0)
		if(is_building_infrastructure_category(category))
			object_budgets[category] = min(current_budget, max(round(usable_area / 16), 1))
			continue
		if(remaining_optional <= 0)
			object_budgets[category] = 0
			continue
		var/new_budget = min(current_budget, remaining_optional)
		object_budgets[category] = new_budget
		remaining_optional -= new_budget
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in cluster_specs)
		if(!istype(cluster_spec))
			continue
		var/category_budget = max(round(text2num("[object_budgets[cluster_spec.category]]") || 0), 0)
		cluster_spec.required = FALSE
		cluster_spec.signature_required = FALSE
		cluster_spec.failure_severity = "optional"
		if(category_budget <= 0)
			cluster_spec.min_count = 0
			cluster_spec.max_count = 0
		else
			cluster_spec.min_count = min(cluster_spec.min_count, category_budget)
			cluster_spec.max_count = min(max(cluster_spec.max_count, cluster_spec.min_count), category_budget)
	category_minimums.Cut()
	signature_minimums.Cut()
	signature_weights.Cut()
	min_signature_score = 0

/datum/world_edit_building_semantic_plan/proc/is_building_infrastructure_category(category)
	return "[category]" in list("light", "apc", "air_alarm", "fire_alarm", "light_switch")

/datum/world_edit_building_semantic_plan/proc/should_select_optional_zone(datum/world_edit_building_zone_spec/zone_spec, datum/world_edit_building_request/request = null, footprint_area = 0)
	if(!istype(zone_spec))
		return FALSE
	if(!zone_spec.optional)
		return TRUE
	if(zone_spec.optional_min_footprint > 0 && footprint_area > 0 && footprint_area < zone_spec.optional_min_footprint)
		return FALSE
	var/weight = clamp(round(text2num("[zone_spec.optional_weight]") || 0), 0, 100)
	if(weight >= 100)
		return TRUE
	if(weight <= 0)
		return FALSE
	var/datum/world_edit_building_prng/rng = request?.program_rng
	if(istype(rng))
		return rng.chance(weight)
	return weight >= 50

/datum/world_edit_building_semantic_plan/proc/cluster_spec_is_active(datum/world_edit_building_cluster_spec/cluster_spec, list/inactive_zone_lookup, list/active_zone_lookup = null)
	if(!istype(cluster_spec))
		return FALSE
	if(!islist(inactive_zone_lookup) || !length(inactive_zone_lookup))
		return TRUE
	if(length(cluster_spec.optional_zone_id) && inactive_zone_lookup[cluster_spec.optional_zone_id])
		return FALSE
	var/has_zone_anchor = FALSE
	var/has_active_zone_anchor = FALSE
	for(var/anchor_id as anything in cluster_spec.anchors)
		if(inactive_zone_lookup["[anchor_id]"])
			has_zone_anchor = TRUE
			continue
		if(islist(active_zone_lookup) && active_zone_lookup["[anchor_id]"])
			has_zone_anchor = TRUE
			has_active_zone_anchor = TRUE
	if(has_zone_anchor && !has_active_zone_anchor)
		return FALSE
	return TRUE

/datum/world_edit_building_semantic_plan/proc/get_zone_spec(zone_id)
	return zone_specs_by_id["[zone_id]"]

/datum/world_edit_building_semantic_plan/proc/get_cluster_specs(phase_id)
	var/list/result = list()
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in cluster_specs)
		if(istype(cluster_spec) && cluster_spec.phase == "[phase_id]" && !cluster_spec.compact_substitute_only)
			result += cluster_spec
	return result

/datum/world_edit_building_semantic_plan/proc/get_cluster_spec_by_id(cluster_id)
	if(!length("[cluster_id]"))
		return null
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in cluster_specs)
		if(istype(cluster_spec) && cluster_spec.id == "[cluster_id]")
			return cluster_spec
	return null

/datum/world_edit_building_archetype
	var/id = ""
	var/label = ""
	var/suggested_shell_preset = "colony"
	var/faction = "neutral"
	var/danger = 0
	var/list/footprint_families = list("RECT")
	var/list/layout_families = list("hub_spoke", "split_wing", "axial_fallback")
	var/primary_zone = "main"
	var/entry_zone = "entry_buffer"
	var/hub_zone = "main"
	var/list/zone_specs = list()
	var/list/zone_specs_by_id = list()
	var/list/region_specs = list()
	var/list/adjacency_rules = list()
	var/list/forbidden_rules = list()
	var/list/cluster_specs = list()
	var/list/category_minimums = list()
	var/list/signature_minimums = list()
	var/list/signature_weights = list()
	var/list/mandatory_zones = list()
	var/list/optional_zones = list()
	var/list/object_budgets = list()
	var/list/shell_overrides = list()
	var/list/privacy_classes = list()
	var/list/door_policy = list()
	var/list/window_policy = list()
	var/list/facade_rules = list()
	var/list/style_budget = list()
	var/list/repeat_penalties = list()
	var/list/nested_room_specs = list()
	var/window_bias = 40
	var/detail_bias = 60
	var/nested_outer_zone = null
	var/nested_inner_zone = null
	var/nested_min_width = 9
	var/nested_min_height = 9
	var/min_signature_score = 70

/datum/world_edit_building_archetype/New()
	. = ..()
	zone_specs = list()
	zone_specs_by_id = list()
	region_specs = list()
	adjacency_rules = list()
	forbidden_rules = list()
	cluster_specs = list()
	category_minimums = list()
	signature_minimums = list()
	signature_weights = list()
	mandatory_zones = list()
	optional_zones = list()
	object_budgets = list()
	shell_overrides = list()
	privacy_classes = list()
	door_policy = list()
	window_policy = list()
	facade_rules = list()
	style_budget = list()
	repeat_penalties = list()
	nested_room_specs = list()
	layout_families = layout_families.Copy()
	build_definition()
	finalize_declarative_definition()

/datum/world_edit_building_archetype/proc/build_definition()
	return

/datum/world_edit_building_archetype/proc/build_option()
	return list("label" = label, "value" = id)

/datum/world_edit_building_archetype/proc/add_zone(id, label, role, min_area = 1, required = TRUE, must_touch_route = TRUE, privacy_sensitive = FALSE, list/anchors = null, window_allowed = TRUE, divider_mode = "none", privacy_class = null, optional_weight = 60, optional_min_footprint = 0)
	var/datum/world_edit_building_zone_spec/zone_spec = new(id, label, role, min_area, required, must_touch_route, privacy_sensitive, anchors, window_allowed, divider_mode, privacy_class, !required, optional_weight, optional_min_footprint)
	zone_specs += zone_spec
	zone_specs_by_id[zone_spec.id] = zone_spec
	if(zone_spec.required)
		mandatory_zones += zone_spec.id
	else
		optional_zones += zone_spec.id
	return zone_spec

/datum/world_edit_building_archetype/proc/add_optional_zone(id, label, role, min_area = 1, optional_weight = 60, must_touch_route = TRUE, privacy_sensitive = FALSE, list/anchors = null, window_allowed = TRUE, divider_mode = "none", privacy_class = null, optional_min_footprint = 0)
	return add_zone(id, label, role, min_area, FALSE, must_touch_route, privacy_sensitive, anchors, window_allowed, divider_mode, privacy_class, optional_weight, optional_min_footprint)

/datum/world_edit_building_archetype/proc/add_region(id, zone_id, front_min, front_max, lateral_min, lateral_max, priority = 0)
	var/datum/world_edit_building_region_spec/region_spec = new(id, zone_id, front_min, front_max, lateral_min, lateral_max, priority)
	region_specs += region_spec
	return region_spec

/datum/world_edit_building_archetype/proc/add_adjacency(zone_a, zone_b, required = TRUE)
	var/datum/world_edit_building_adjacency_rule/rule = new(zone_a, zone_b, required)
	adjacency_rules += rule
	return rule

/datum/world_edit_building_archetype/proc/add_forbidden_rule(id, kind, zone_id, target_id, severity = 100)
	var/datum/world_edit_building_forbidden_rule/rule = new(id, kind, zone_id, target_id, severity)
	forbidden_rules += rule
	return rule

/datum/world_edit_building_archetype/proc/add_nested_room(outer_zone_id, inner_zone_id, min_width = 9, min_height = 9, margin = 1)
	var/datum/world_edit_building_nested_room_spec/nested_room_spec = new(outer_zone_id, inner_zone_id, min_width, min_height, margin)
	nested_room_specs += nested_room_spec
	return nested_room_spec

/datum/world_edit_building_archetype/proc/add_cluster(id, phase, pattern, slot, category, list/anchors, min_count = 1, max_count = 1, wall_required = FALSE, chair_count = 0, priority = 50, required = TRUE, optional_zone_id = null, macro_id = null)
	var/datum/world_edit_building_cluster_spec/cluster_spec = new(id, phase, pattern, slot, category, anchors, min_count, max_count, wall_required, chair_count, priority, required, optional_zone_id, macro_id)
	cluster_specs += cluster_spec
	return cluster_spec

/datum/world_edit_building_archetype/proc/add_signature_cluster(id, phase, pattern, slot, category, list/anchors, min_count = 1, max_count = 1, wall_required = FALSE, chair_count = 0, priority = 50, signature_id = null, signature_weight = 20, required = TRUE, optional_zone_id = null, macro_id = null)
	var/datum/world_edit_building_cluster_spec/cluster_spec = add_cluster(id, phase, pattern, slot, category, anchors, min_count, max_count, wall_required, chair_count, priority, required, optional_zone_id, macro_id)
	cluster_spec.signature_id = length("[signature_id]") ? "[signature_id]" : "[id]"
	cluster_spec.signature_weight = max(round(text2num("[signature_weight]") || 0), 0)
	cluster_spec.signature_required = required ? TRUE : FALSE
	cluster_spec.semantic_credit = cluster_spec.signature_id
	cluster_spec.acceptance_counter = "[cluster_spec.signature_id]_count"
	cluster_spec.failure_severity = required ? "required" : "optional"
	var/minimum = max(round(text2num("[min_count]") || 1), 1)
	if(cluster_spec.signature_required)
		signature_minimums[cluster_spec.signature_id] = max(round(text2num("[signature_minimums[cluster_spec.signature_id]]") || 0), minimum)
		signature_weights[cluster_spec.signature_id] = max(round(text2num("[signature_weights[cluster_spec.signature_id]]") || 0), cluster_spec.signature_weight)
	return cluster_spec

/datum/world_edit_building_archetype/proc/add_facade_rule(id, zone_id = null, role = null, privacy_class = null, facade_role = "neutral_face", window_weight = 50, window_allowed = TRUE, macro_id = "facade_panel")
	var/datum/world_edit_building_facade_rule/rule = new(id, zone_id, role, privacy_class, facade_role, window_weight, window_allowed, macro_id)
	facade_rules += rule
	return rule

/datum/world_edit_building_archetype/proc/has_cluster_id(cluster_id)
	if(!length("[cluster_id]"))
		return FALSE
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in cluster_specs)
		if(istype(cluster_spec) && cluster_spec.id == "[cluster_id]")
			return TRUE
	return FALSE

/datum/world_edit_building_archetype/proc/ensure_default_infrastructure_contract()
	var/list/common_wall_anchors = list("wall_anchor", "service_wall", "entry_buffer", primary_zone, hub_zone)
	if(!has_cluster_id("infrastructure_lights"))
		add_cluster("infrastructure_lights", "major", "run", "light", "light", common_wall_anchors, 2, 4, TRUE, 0, 95, TRUE, null, "infrastructure_light_chunk")
	if(!has_cluster_id("infrastructure_apc"))
		add_cluster("infrastructure_apc", "major", "wall_object", "apc", "apc", common_wall_anchors, 1, 1, TRUE, 0, 100, TRUE, null, "infrastructure_power_chunk")
	if(!has_cluster_id("infrastructure_air_alarm"))
		add_cluster("infrastructure_air_alarm", "major", "wall_object", "air_alarm", "air_alarm", common_wall_anchors, 1, 1, TRUE, 0, 100, TRUE, null, "infrastructure_air_alarm_chunk")
	if(!has_cluster_id("infrastructure_light_switch"))
		add_cluster("infrastructure_light_switch", "secondary", "wall_object", "light_switch", "light_switch", list("entry_buffer", "door_cone", "wall_anchor", primary_zone), 1, 1, TRUE, 0, 55, FALSE, null, "infrastructure_switch_chunk")
	if(!has_cluster_id("infrastructure_fire_alarm"))
		add_cluster("infrastructure_fire_alarm", "secondary", "wall_object", "fire_alarm", "fire_alarm", common_wall_anchors, 1, 1, TRUE, 0, 50, FALSE, null, "infrastructure_fire_alarm_chunk")
	object_budgets["light"] = max(round(text2num("[object_budgets["light"]]") || 0), 4)
	object_budgets["apc"] = max(round(text2num("[object_budgets["apc"]]") || 0), 1)
	object_budgets["air_alarm"] = max(round(text2num("[object_budgets["air_alarm"]]") || 0), 1)
	object_budgets["fire_alarm"] = max(round(text2num("[object_budgets["fire_alarm"]]") || 0), 1)
	object_budgets["light_switch"] = max(round(text2num("[object_budgets["light_switch"]]") || 0), 1)
	category_minimums["light"] = max(round(text2num("[category_minimums["light"]]") || 0), 2)
	category_minimums["apc"] = max(round(text2num("[category_minimums["apc"]]") || 0), 1)
	category_minimums["air_alarm"] = max(round(text2num("[category_minimums["air_alarm"]]") || 0), 1)

/datum/world_edit_building_archetype/proc/finalize_declarative_definition()
	for(var/datum/world_edit_building_zone_spec/zone_spec as anything in zone_specs)
		if(!istype(zone_spec))
			continue
		if(zone_spec.required && !(zone_spec.id in mandatory_zones))
			mandatory_zones += zone_spec.id
		if(zone_spec.optional && !(zone_spec.id in optional_zones))
			optional_zones += zone_spec.id
		if(!length("[privacy_classes[zone_spec.id]]"))
			privacy_classes[zone_spec.id] = zone_spec.privacy_class
		if(zone_spec.privacy_sensitive)
			add_forbidden_rule("privacy_[zone_spec.id]_door_cone", "zone_anchor", zone_spec.id, "door_cone", 100)
	if(!islist(door_policy) || !length(door_policy))
		door_policy = list(
			"id" = "front_controlled_optional_back",
			"front" = TRUE,
			"allow_back_exit" = TRUE,
			"max_exterior_doors" = 2,
			"controlled_internal_doors" = TRUE,
		)
	if(!islist(window_policy) || !length(window_policy))
		window_policy = list(
			"id" = "semantic_public_weighted",
			"public_weight" = max(window_bias + 45, 80),
			"semi_private_weight" = max(window_bias, 35),
			"service_weight" = max(round(window_bias / 2), 10),
			"secure_weight" = max(round(window_bias / 3), 0),
			"private_weight" = 0,
			"privacy_windows" = FALSE,
		)
	if(!islist(style_budget) || !length(style_budget))
		style_budget = list(
			"min_fixture_density" = 18,
			"ideal_fixture_density" = 38,
			"max_fixture_density" = 68,
			"min_category_coverage" = 60,
			"max_repeat_index" = 55,
		)
	if(isnull(style_budget["max_empty_floor_ratio"]))
		style_budget["max_empty_floor_ratio"] = WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO
	switch(id)
		if("storage", "compound_colony")
			style_budget["max_empty_floor_ratio"] = min(round(text2num("[style_budget["max_empty_floor_ratio"]]") || WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO), 68)
		if("hydroponics", "kitchen", "dormitory", "workshop", "engineering", "laboratory")
			style_budget["max_empty_floor_ratio"] = min(round(text2num("[style_budget["max_empty_floor_ratio"]]") || WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO), 60)
		if("medbay", "security", "checkpoint")
			style_budget["max_empty_floor_ratio"] = min(round(text2num("[style_budget["max_empty_floor_ratio"]]") || WORLD_EDIT_BUILDING_DEFAULT_MAX_EMPTY_FLOOR_RATIO), 58)
	ensure_default_infrastructure_contract()
	if(!islist(repeat_penalties))
		repeat_penalties = list()
	for(var/category as anything in object_budgets)
		if(!islist(repeat_penalties["[category]"]))
			var/soft_percent = 58
			if("[category]" in list("rack", "bed", "hydro_tray", "chair", "barrier"))
				soft_percent = 75
			repeat_penalties["[category]"] = list(
				"soft_percent" = soft_percent,
				"hard_percent" = 90,
				"penalty" = 8,
			)
	if(!length(facade_rules))
		add_facade_rule("public_default", null, "public", "public", "public_face", window_policy["public_weight"] || 120, TRUE, "facade_public_panel")
		add_facade_rule("entry_default", null, "entry", "public", "public_face", window_policy["public_weight"] || 120, TRUE, "door_node_chunk")
		add_facade_rule("service_default", null, "service", "secure", "service_face", window_policy["service_weight"] || 25, FALSE, "facade_service_panel")
		add_facade_rule("secure_default", null, "secure", "secure", "secure_face", window_policy["secure_weight"] || 15, FALSE, "facade_fortified_panel")
		add_facade_rule("private_default", null, "private", "private", "private_face", window_policy["private_weight"] || 0, FALSE, "facade_privacy_panel")
		add_facade_rule("neutral_default", null, null, null, "neutral_face", window_bias, TRUE, "facade_panel")

/datum/world_edit_building_archetype/proc/build_semantic_plan(datum/world_edit_building_request/request = null)
	return new /datum/world_edit_building_semantic_plan(src, request)

/datum/world_edit_building_archetype/living
	id = "living"
	layout_families = list("hub_spoke", "split_wing", "axial_fallback")
	label = "Living module"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "U")
	primary_zone = "common"
	hub_zone = "common"
	window_bias = 55
	detail_bias = 75

/datum/world_edit_building_archetype/living/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("common", "Common/social", "hub", 8, TRUE, TRUE, FALSE, list("common", "focus_center", "focus_ring", "social_focus", "work_cluster"), TRUE)
	add_zone("sleep_privacy", "Sleep privacy", "private", 3, TRUE, TRUE, TRUE, list("sleep_privacy", "privacy_zone", "wall_anchor"), FALSE, "room")
	add_zone("storage_service", "Personal storage", "service", 2, TRUE, TRUE, FALSE, list("storage_service", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("sanitation", "Sanitation room", "service", 2, TRUE, TRUE, TRUE, list("sanitation", "service_strip", "wall_anchor"), FALSE, "room", "private")
	add_region("entry_front", "entry_buffer", 0, 22, -45, 45, 100)
	add_region("common_core", "common", 16, 80, -50, 50, 75)
	add_region("common_social_ring", "common", 22, 84, -72, 72, 45)
	add_region("sleep_back_left", "sleep_privacy", 58, 100, -100, -30, 90)
	add_region("storage_back_right", "storage_service", 35, 100, 30, 100, 80)
	add_region("sanitation_back", "sanitation", 62, 100, 30, 100, 88)
	add_region("common_fill", "common", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "common")
	add_adjacency("common", "sleep_privacy")
	add_adjacency("common", "storage_service")
	add_adjacency("common", "sanitation")
	add_nested_room("common", "sleep_privacy", 7, 7, 1)
	add_signature_cluster("sleep_nook_signature", "major", "signature_living_nook", "bed", "sleeping_bed", list("sleep_privacy", "privacy_zone", "bed_wall"), 2, 2, FALSE, 0, 100, "sleep_nook", 35, TRUE, null, null)
	add_signature_cluster("dining_pair", "major", "table_cluster", "table", "table", list("common", "social_focus", "focus_center"), 1, 2, FALSE, 2, 95, "common_table", 22, TRUE, null, "living_dining_cluster_chunk")
	add_signature_cluster("center_social_cluster", "major", "table_cluster", "table", "table", list("common", "social_focus", "focus_center", "focus_ring"), 1, 2, FALSE, 4, 92, "living_social_core", 24, TRUE, null, "living_social_cluster_chunk")
	add_signature_cluster("ring_social_cluster", "major", "table_cluster", "table", "table", list("common", "social_focus", "focus_ring"), 1, 2, FALSE, 2, 88, "living_social_ring", 20, TRUE, null, "living_social_ring_chunk")
	add_signature_cluster("personal_storage", "major", "run", "cabinet", "personal_storage", list("storage_service", "service_strip", "storage_wall", "wall_anchor"), 1, 2, FALSE, 0, 80, "personal_storage", 20, TRUE, null, null)
	add_signature_cluster("sanitation_combined", "major", "wall_object", "toilet", "sanitation", list("sanitation", "service_strip", "wall_anchor"), 1, 1, TRUE, 0, 75, "sanitation_combined", 12, TRUE, null, "sanitation_combined_chunk")
	add_cluster("side_table", "secondary", "table_cluster", "table", "table", list("common", "window_band", "social_focus", "focus_ring"), 1, 2, FALSE, 1, 58, FALSE, null, "living_side_table_chunk")
	add_cluster("window_seat", "detail", "object", "chair", "chair", list("window_band", "common", "focus_ring"), 1, 2, FALSE, 0, 42, FALSE, null, "living_window_seat_chunk")
	add_cluster("center_chair_group", "secondary", "object", "chair", "chair", list("common", "social_focus", "focus_ring"), 2, 4, FALSE, 0, 60, FALSE, null, "living_chair_group_chunk")
	object_budgets = list("bed" = 2, "table" = 5, "chair" = 8, "cabinet" = 4, "rack" = 2, "sanitation" = 1, "kitchen_machine" = 1)
	category_minimums = list("bed" = 1, "table" = 2, "chair" = 4, "cabinet" = 1, "sanitation" = 1)

/datum/world_edit_building_archetype/workshop
	id = "workshop"
	layout_families = list("open_bay_perimeter", "split_wing", "compound_cells", "axial_fallback")
	label = "Workshop"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "T", "COMPOUND")
	primary_zone = "main_work"
	hub_zone = "main_work"
	window_bias = 25
	detail_bias = 85

/datum/world_edit_building_archetype/workshop/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("main_work", "Main work bay", "hub", 8, TRUE, TRUE, FALSE, list("main_work", "work_cluster", "focus_center"), TRUE)
	add_zone("service_wall", "Service wall", "service", 4, TRUE, TRUE, FALSE, list("service_wall", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("parts_storage", "Parts storage", "storage", 4, TRUE, TRUE, FALSE, list("parts_storage", "service_strip", "wall_anchor"), FALSE, "nook")
	add_region("entry_front", "entry_buffer", 0, 20, -35, 35, 100)
	add_region("service_left", "service_wall", 18, 88, -100, -50, 90)
	add_region("parts_back", "parts_storage", 68, 100, -20, 100, 80)
	add_region("main_work_core", "main_work", 16, 86, -48, 48, 60)
	add_region("main_work_fill", "main_work", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "main_work")
	add_adjacency("main_work", "service_wall")
	add_adjacency("main_work", "parts_storage")
	add_nested_room("main_work", "parts_storage", 9, 9, 1)
	var/datum/world_edit_building_cluster_spec/workbench_spec = add_signature_cluster("workbench_machine_wall", "major", "signature_workshop_wall", "table", "table", list("service_wall", "machine_wall", "main_work"), 4, 5, FALSE, 0, 100, "workbench_machine_wall", 35)
	workbench_spec.compact_substitute_id = "workbench_machine_wall_compact"
	var/datum/world_edit_building_cluster_spec/workbench_compact = add_signature_cluster("workbench_machine_wall_compact", "major", "run", "table", "table", list("service_wall", "machine_wall", "main_work"), 1, 4, FALSE, 0, 80, "workbench_machine_wall", 0, FALSE)
	workbench_compact.compact_substitute_only = TRUE
	var/datum/world_edit_building_cluster_spec/rack_spec = add_signature_cluster("parts_rack_aisles", "major", "signature_rack_aisles", "rack", "rack", list("parts_storage", "rack_aisle", "storage_wall"), 3, 5, FALSE, 0, 95, "parts_rack_aisles", 25)
	rack_spec.compact_substitute_id = "parts_rack_aisles_compact"
	var/datum/world_edit_building_cluster_spec/rack_compact = add_signature_cluster("parts_rack_aisles_compact", "major", "run", "rack", "rack", list("parts_storage", "rack_aisle", "storage_wall", "main_work"), 1, 2, FALSE, 0, 75, "parts_rack_aisles", 0, FALSE)
	rack_compact.compact_substitute_only = TRUE
	add_signature_cluster("central_assembly_table", "major", "table_cluster", "table", "table", list("main_work", "work_cluster", "focus_center"), 1, 1, FALSE, 2, 90, "assembly_table", 20)
	add_cluster("operator_console", "secondary", "wall_object", "console", "console", list("service_wall", "wall_anchor", "observation"), 1, 1, TRUE, 0, 70, FALSE)
	add_cluster("tool_storage", "secondary", "run", "cabinet", "cabinet", list("service_wall", "service_strip", "wall_anchor"), 1, 2, TRUE, 0, 60, FALSE)
	add_cluster("parts_crate_stack", "detail", "run", "crate", "crate", list("parts_storage", "main_work"), 2, 3, FALSE, 0, 45, FALSE)
	add_cluster("inspection_chair", "detail", "object", "chair", "chair", list("main_work", "work_cluster"), 1, 1, FALSE, 0, 35, FALSE)
	object_budgets = list("table" = 5, "chair" = 4, "rack" = 5, "cabinet" = 3, "console" = 1, "crate" = 3)
	category_minimums = list("table" = 3, "rack" = 3)

/datum/world_edit_building_archetype/storage
	id = "storage"
	layout_families = list("open_bay_perimeter", "split_wing", "axial_fallback")
	label = "Storage"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "T")
	primary_zone = "loading_axis"
	hub_zone = "loading_axis"
	window_bias = 15
	detail_bias = 85

/datum/world_edit_building_archetype/storage/build_definition()
	add_zone("entry_buffer", "Entry buffer", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), FALSE)
	add_zone("loading_axis", "Loading axis", "route", 6, TRUE, TRUE, FALSE, list("loading_axis", "primary_lane", "staging"), FALSE)
	add_zone("rack_zone", "Rack zone", "storage", 8, TRUE, TRUE, FALSE, list("rack_zone", "service_strip", "wall_anchor"), FALSE, "nook")
	add_zone("staging", "Staging/inspection", "staging", 3, TRUE, TRUE, FALSE, list("staging", "loading_axis"), FALSE)
	add_region("entry_front", "entry_buffer", 0, 18, -30, 30, 100)
	add_region("loading_spine", "loading_axis", 0, 100, -24, 24, 95)
	add_region("staging_back", "staging", 70, 100, -52, 52, 90)
	add_region("rack_left", "rack_zone", 18, 94, -100, -28, 75)
	add_region("rack_right", "rack_zone", 18, 94, 28, 100, 75)
	add_region("rack_fill", "rack_zone", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "loading_axis")
	add_adjacency("loading_axis", "rack_zone")
	add_adjacency("loading_axis", "staging")
	add_nested_room("loading_axis", "staging", 9, 9, 1)
	var/datum/world_edit_building_cluster_spec/storage_rack_spec = add_signature_cluster("rack_aisles", "major", "signature_rack_aisles", "rack", "rack", list("rack_zone", "rack_aisle", "storage_wall"), 6, 8, FALSE, 0, 100, "rack_aisles", 45)
	storage_rack_spec.compact_substitute_id = "rack_aisles_compact"
	var/datum/world_edit_building_cluster_spec/storage_rack_compact = add_signature_cluster("rack_aisles_compact", "major", "run", "rack", "rack", list("rack_zone", "rack_aisle", "storage_wall", "staging"), 1, 2, FALSE, 0, 75, "rack_aisles", 0, FALSE)
	storage_rack_compact.compact_substitute_only = TRUE
	add_signature_cluster("loading_crates", "major", "staging_group", "crate", "crate", list("staging", "loading_axis"), 2, 3, FALSE, 0, 80, "loading_staging", 20)
	add_cluster("inspection_table", "secondary", "table_cluster", "table", "table", list("staging", "loading_axis"), 1, 1, FALSE, 1, 55, FALSE)
	add_cluster("crate_stack", "detail", "run", "crate", "crate", list("staging", "rack_zone"), 2, 3, FALSE, 0, 45, FALSE)
	object_budgets = list("rack" = 9, "cabinet" = 4, "crate" = 7, "table" = 1, "chair" = 1)
	category_minimums = list("rack" = 6, "crate" = 2)

/datum/world_edit_building_archetype/checkpoint
	id = "checkpoint"
	layout_families = list("secure_core", "split_wing", "axial_fallback")
	label = "Checkpoint"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "WEDGE")
	primary_zone = "secure_side"
	hub_zone = "counter_line"
	window_bias = 20
	detail_bias = 75

/datum/world_edit_building_archetype/checkpoint/build_definition()
	add_zone("public_side", "Public approach", "public", 3, TRUE, TRUE, FALSE, list("public_side", "public_route", "entry_buffer"), TRUE)
	add_zone("counter_line", "Counter/barrier", "choke", 3, TRUE, TRUE, FALSE, list("counter_line", "counter_front", "barrier_line"), FALSE, "nook")
	add_zone("secure_side", "Secure side", "secure", 4, TRUE, TRUE, FALSE, list("secure_side", "counter_back", "work_cluster"), FALSE, "nook")
	add_zone("observation", "Observation/storage", "support", 2, TRUE, TRUE, FALSE, list("observation", "wall_anchor", "service_strip"), FALSE, "nook")
	add_region("public_front", "public_side", 0, 32, -100, 100, 95)
	add_region("counter_band", "counter_line", 30, 50, -100, 100, 100)
	add_region("observation_side", "observation", 50, 100, 42, 100, 80)
	add_region("secure_back", "secure_side", 48, 100, -100, 42, 70)
	add_region("secure_fill", "secure_side", 0, 100, -100, 100, 1)
	add_adjacency("public_side", "counter_line")
	add_adjacency("counter_line", "secure_side")
	add_adjacency("secure_side", "observation")
	add_nested_room("secure_side", "observation", 8, 8, 1)
	add_signature_cluster("checkpoint_control", "major", "run", "table", "table", list("counter_line", "counter_front", "counter_line_turf", "secure_side"), 2, 3, FALSE, 0, 100, "checkpoint_counter_control", 50)
	add_cluster("operator_console", "secondary", "wall_object", "console", "console", list("secure_side", "counter_back", "observation", "wall_anchor"), 1, 1, TRUE, 0, 95, FALSE)
	add_signature_cluster("security_storage", "major", "wall_object", "cabinet", "cabinet", list("observation", "secure_side", "wall_anchor"), 1, 1, TRUE, 0, 80, "secure_storage", 20)
	add_cluster("visitor_chair", "secondary", "object", "chair", "chair", list("public_side", "public_route"), 1, 1, FALSE, 0, 45, FALSE)
	add_cluster("barricade_line", "detail", "run", "barrier", "barrier", list("public_side", "barrier_line"), 2, 2, FALSE, 0, 35, FALSE)
	object_budgets = list("table" = 3, "chair" = 3, "rack" = 2, "cabinet" = 2, "console" = 1, "barrier" = 2)
	category_minimums = list("table" = 2, "console" = 1)

/datum/world_edit_building_archetype/medbay
	id = "medbay"
	layout_families = list("hub_spoke", "nested_service", "split_wing", "axial_fallback")
	label = "Medbay"
	suggested_shell_preset = "colony"
	footprint_families = list("RECT", "L", "U", "NESTED")
	primary_zone = "treatment"
	hub_zone = "treatment"
	window_bias = 35
	detail_bias = 80
	nested_outer_zone = "treatment"
	nested_inner_zone = "surgery_core"
	nested_min_width = 9
	nested_min_height = 9

/datum/world_edit_building_archetype/medbay/build_definition()
	add_zone("entry_buffer", "Entry/waiting", "entry", 2, TRUE, TRUE, FALSE, list("entry_buffer", "public_route"), TRUE)
	add_zone("triage", "Triage", "public_med", 4, TRUE, TRUE, FALSE, list("triage", "public_route", "window_band"), TRUE, "nook")
	add_zone("treatment", "Treatment", "hub", 8, TRUE, TRUE, FALSE, list("treatment", "work_cluster", "focus_center"), TRUE, "nook")
	add_zone("med_storage", "Medical storage", "service", 3, TRUE, TRUE, FALSE, list("med_storage", "service_strip", "wall_anchor"), FALSE, "room")
	add_optional_zone("surgery_core", "Surgery core", "nested", 1, 70, TRUE, TRUE, list("surgery_core", "privacy_zone", "work_cluster"), FALSE, "room", "private", 48)
	add_optional_zone("cryo_bay", "Cryo bay", "private", 3, 55, TRUE, TRUE, list("cryo_bay", "privacy_zone", "treatment_wall"), FALSE, "nook", "private", 40)
	add_optional_zone("chem_nook", "Chemistry nook", "service", 3, 45, TRUE, FALSE, list("chem_nook", "service_strip", "wall_anchor"), FALSE, "nook", "service", 44)
	add_optional_zone("morgue_nook", "Morgue nook", "private", 2, 35, TRUE, TRUE, list("morgue_nook", "privacy_zone", "storage_wall"), FALSE, "room", "private", 46)
	add_region("entry_front", "entry_buffer", 0, 18, -40, 40, 100)
	add_region("triage_front", "triage", 12, 42, -100, 100, 80)
	add_region("med_storage_side", "med_storage", 38, 100, 48, 100, 90)
	add_region("cryo_back_left", "cryo_bay", 58, 100, -100, -48, 85)
	add_region("chem_back_right", "chem_nook", 55, 100, 42, 100, 78)
	add_region("morgue_back", "morgue_nook", 72, 100, -38, 38, 76)
	add_region("treatment_core", "treatment", 35, 100, -48, 48, 70)
	add_region("treatment_fill", "treatment", 0, 100, -100, 100, 1)
	add_adjacency("entry_buffer", "triage")
	add_adjacency("triage", "treatment")
	add_adjacency("treatment", "med_storage")
	add_adjacency("treatment", "cryo_bay", FALSE)
	add_adjacency("treatment", "chem_nook", FALSE)
	add_adjacency("med_storage", "morgue_nook", FALSE)
	add_nested_room("treatment", "surgery_core", 9, 9, 1)
	add_signature_cluster("treatment_bay_signature", "major", "signature_treatment_bay", "medical_bed", "medical_bed", list("treatment_wall", "treatment_bay"), 3, 5, TRUE, 0, 100, "treatment_bay", 45)
	add_signature_cluster("med_storage_wall", "major", "run", "medical_storage", "medical_storage", list("med_storage", "service_strip", "storage_wall", "treatment_wall"), 2, 3, TRUE, 0, 95, "medical_storage_wall", 25)
	add_signature_cluster("triage_table", "major", "table_cluster", "table", "table", list("triage", "public_side", "focus_center"), 1, 1, FALSE, 2, 80, "triage_surface", 15)
	add_cluster("waiting_chairs", "secondary", "run", "chair", "chair", list("triage", "entry_buffer", "public_route"), 2, 2, FALSE, 0, 55, FALSE)
	add_cluster("med_side_storage", "secondary", "wall_object", "cabinet", "cabinet", list("med_storage", "wall_anchor", "service_strip"), 1, 1, TRUE, 0, 50, FALSE)
	add_cluster("surgery_bed", "detail", "object", "medical_bed", "medical_bed", list("surgery_core", "privacy_zone"), 1, 1, FALSE, 0, 45, FALSE, "surgery_core", "surgery_bed_chunk")
	add_cluster("cryo_sleeper", "secondary", "wall_object", "sleeper", "medical_bed", list("cryo_bay", "privacy_zone", "treatment_wall"), 1, 1, TRUE, 0, 60, FALSE, "cryo_bay", "cryo_sleeper_chunk")
	add_cluster("chem_storage", "secondary", "wall_object", "water_tank", "water_or_chem", list("chem_nook", "service_strip", "wall_anchor"), 1, 1, TRUE, 0, 55, FALSE, "chem_nook", "chem_storage_chunk")
	add_cluster("morgue_storage", "secondary", "run", "medical_storage", "medical_storage", list("morgue_nook", "storage_wall", "privacy_zone"), 1, 2, TRUE, 0, 50, FALSE, "morgue_nook", "morgue_storage_chunk")
	object_budgets = list("medical_bed" = 5, "medical_storage" = 4, "water_or_chem" = 1, "table" = 2, "chair" = 4, "cabinet" = 2)
	category_minimums = list("medical_bed" = 2, "medical_storage" = 1, "table" = 1)

/datum/world_edit_generator/building_layout/proc/get_building_archetype_catalog()
	if(length(GLOB.world_edit_building_archetype_catalog))
		return GLOB.world_edit_building_archetype_catalog
	for(var/archetype_type in subtypesof(/datum/world_edit_building_archetype))
		var/datum/world_edit_building_archetype/archetype = new archetype_type()
		if(!length(archetype.id))
			continue
		GLOB.world_edit_building_archetype_catalog[archetype.id] = archetype
	return GLOB.world_edit_building_archetype_catalog

/datum/world_edit_generator/building_layout/proc/get_building_archetype_options()
	var/list/options = list()
	var/list/catalog = get_building_archetype_catalog()
	for(var/archetype_id in catalog)
		var/datum/world_edit_building_archetype/archetype = catalog[archetype_id]
		options += list(archetype.build_option())
	return options

/datum/world_edit_generator/building_layout/proc/get_building_archetype_aliases()
	return list(
		"living_small" = "living",
		"workshop_small" = "workshop",
		"storage_small" = "storage",
		"checkpoint_small" = "checkpoint",
		"medbay_small" = "medbay",
		"colony_living_small" = "living",
		"uscm_workshop_small" = "workshop",
		"uscm_storage_small" = "storage",
		"uscm_checkpoint_wedge" = "checkpoint",
		"storage_t" = "storage",
		"checkpoint_wedge" = "checkpoint",
	)

/datum/world_edit_generator/building_layout/proc/canonicalize_building_archetype_id(archetype_id)
	var/archetype_text = "[archetype_id]"
	var/list/aliases = get_building_archetype_aliases()
	return "[aliases[archetype_text] || archetype_text]"

/datum/world_edit_generator/building_layout/proc/get_building_archetype(archetype_id)
	var/list/catalog = get_building_archetype_catalog()
	var/datum/world_edit_building_archetype/archetype = catalog[canonicalize_building_archetype_id(archetype_id)]
	if(!istype(archetype))
		return catalog["living"]
	return archetype

/datum/world_edit_generator/building_layout/proc/resolve_building_archetype_option(value, fallback = "living")
	var/list/options = get_building_archetype_ids()
	var/canonical_value = canonicalize_building_archetype_id(value)
	if(canonical_value in options)
		return canonical_value
	var/canonical_fallback = canonicalize_building_archetype_id(fallback)
	if(canonical_fallback in options)
		return canonical_fallback
	return "living"

/datum/world_edit_generator/building_layout/proc/resolve_layout_variant_archetype_alias(list/params)
	var/layout_variant = "[islist(params) ? params["layout_variant"] : null]"
	switch(layout_variant)
		if("workshop")
			return "workshop"
		if("storage")
			return "storage"
		if("checkpoint")
			return "checkpoint"
		if("office")
			return "office"
	return "living"
