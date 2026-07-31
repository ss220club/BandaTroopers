/datum/world_edit_generator/building_layout/proc/get_building_infrastructure_specs(datum/world_edit_building_layout_state/state)
	var/list/specs = list()
	if(!istype(state))
		return specs
	specs += list(list(
		"id" = "infrastructure_lights",
		"slot" = "light",
		"category" = "light",
		"pattern" = "run",
		"minimum" = max(round(text2num("[state.semantic_plan?.category_minimums["light"]]") || 0), 2),
		"maximum" = max(3, round(length(state.geometry.floor_turfs) / 18)),
		"macro" = "infrastructure_light_chunk",
		"priority" = 100,
	))
	specs += list(list(
		"id" = "infrastructure_apc",
		"slot" = "apc",
		"category" = "apc",
		"pattern" = "wall_object",
		"minimum" = 1,
		"maximum" = 1,
		"macro" = "infrastructure_power_chunk",
		"priority" = 110,
	))
	specs += list(list(
		"id" = "infrastructure_air_alarm",
		"slot" = "air_alarm",
		"category" = "air_alarm",
		"pattern" = "wall_object",
		"minimum" = 1,
		"maximum" = 1,
		"macro" = "infrastructure_air_alarm_chunk",
		"priority" = 105,
	))
	specs += list(list(
		"id" = "infrastructure_light_switch",
		"slot" = "light_switch",
		"category" = "light_switch",
		"pattern" = "wall_object",
		"minimum" = 1,
		"maximum" = 1,
		"macro" = "infrastructure_switch_chunk",
		"priority" = 70,
	))
	specs += list(list(
		"id" = "infrastructure_fire_alarm",
		"slot" = "fire_alarm",
		"category" = "fire_alarm",
		"pattern" = "wall_object",
		"minimum" = 1,
		"maximum" = 1,
		"macro" = "infrastructure_fire_alarm_chunk",
		"priority" = 55,
	))
	return specs

/datum/world_edit_generator/building_layout/proc/build_infrastructure_anchor_list(datum/world_edit_building_layout_state/state)
	if(building_layout_solver_enabled(state))
		return list("wall_anchor", "service_wall", "storage_wall")
	var/list/anchors = list("wall_anchor", "service_wall", "storage_wall", "entry_buffer", "public_side")
	if(length("[state.semantic_plan?.primary_zone_id]"))
		anchors += state.semantic_plan.primary_zone_id
	if(length("[state.semantic_plan?.hub_zone_id]"))
		anchors += state.semantic_plan.hub_zone_id
	return anchors

/datum/world_edit_generator/building_layout/proc/place_building_infrastructure(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !istype(state.semantic_plan) || !length(state.geometry.floor_turfs))
		return FALSE
	var/repaired = FALSE
	var/list/anchors = build_infrastructure_anchor_list(state)
	var/is_micro = is_building_compact_or_micro_state(state) || GLOB.world_edit_helpers.parse_bool(state.config["micro_layout"])
	if(!is_micro && istype(state.archetype))
		is_micro = length(state.geometry.floor_turfs) < get_building_program_required_compact_area(state.archetype)
	for(var/list/spec_data as anything in get_building_infrastructure_specs(state))
		if(!islist(spec_data))
			continue
		var/category = "[spec_data["category"]]"
		var/requirement_id = "[spec_data["id"]]"
		var/minimum = max(round(text2num("[spec_data["minimum"]]") || 0), 0)
		var/placed_count = round(text2num("[state.fixtures.placed_requirement_counts[requirement_id]]") || 0)
		if(minimum <= 0 || placed_count >= minimum)
			continue
		var/needed = minimum - placed_count
		var/maximum = max(round(text2num("[spec_data["maximum"]]") || minimum), minimum)
		var/required = !is_micro
		var/datum/world_edit_building_cluster_spec/cluster_spec = new(
			requirement_id,
			"major",
			spec_data["pattern"],
			spec_data["slot"],
			category,
			anchors,
			needed,
			max(needed, maximum),
			TRUE,
			0,
			round(text2num("[spec_data["priority"]]") || 70),
			required,
			null,
			spec_data["macro"]
		)
		if(place_building_cluster_spec(state, cluster_spec, TRUE))
			repaired = TRUE
	return repaired
