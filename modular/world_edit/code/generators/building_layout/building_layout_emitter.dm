/datum/world_edit_generator/building_layout/proc/format_building_messages(list/messages)
	if(!islist(messages) || !length(messages))
		return ""
	var/output = ""
	for(var/message as anything in messages)
		if(!length("[message]"))
			continue
		if(length(output))
			output = "[output]; "
		output = "[output][message]"
	return output

/datum/world_edit_generator/building_layout/proc/apply_building_microvariation_if_available(datum/world_edit_building_layout_state/state)
	if(!istype(state) || !hascall(src, "apply_building_microvariation"))
		return
	call(src, "apply_building_microvariation")(state)

/datum/world_edit_generator/building_layout/proc/build_building_anchor_type_counts(datum/world_edit_building_layout_state/state, prefix_filter = null)
	var/list/counts = list()
	if(!istype(state) || !islist(state.fixtures.anchor_turfs))
		return counts
	var/filter = "[prefix_filter || ""]"
	for(var/anchor_id as anything in state.fixtures.anchor_turfs)
		var/anchor_text = "[anchor_id]"
		if(length(filter) && copytext(anchor_text, 1, length(filter) + 1) != filter)
			continue
		var/list/turfs = state.fixtures.anchor_turfs[anchor_id]
		counts[anchor_text] = islist(turfs) ? length(turfs) : 0
	return counts

/datum/world_edit_generator/building_layout/proc/count_building_anchor_turfs(datum/world_edit_building_layout_state/state, prefix_filter = null)
	var/total = 0
	var/list/counts = build_building_anchor_type_counts(state, prefix_filter)
	for(var/anchor_id as anything in counts)
		total += round(text2num("[counts[anchor_id]]") || 0)
	return total

/datum/world_edit_generator/building_layout/proc/build_building_room_contract_report(datum/world_edit_building_layout_state/state)
	var/list/report = list()
	if(!istype(state) || !istype(state.semantic_plan))
		return report
	for(var/datum/world_edit_building_room/room as anything in state.geometry.solved_rooms)
		if(!istype(room))
			continue
		var/datum/world_edit_building_zone_spec/zone_spec = state.semantic_plan.get_zone_spec(room.zone_id)
		var/list/region_specs = get_room_first_region_specs_for_zone(state, room.zone_id)
		var/best_region_id = ""
		var/best_overlap = 0
		var/best_priority = -999999999
		for(var/datum/world_edit_building_region_spec/region_spec as anything in region_specs)
			if(!istype(region_spec))
				continue
			var/overlap = 0
			for(var/turf/room_turf as anything in room.turfs)
				if(istype(room_turf) && region_spec_contains_turf(state, region_spec, room_turf))
					overlap++
			if(overlap > best_overlap || (overlap == best_overlap && region_spec.priority > best_priority))
				best_region_id = region_spec.id
				best_overlap = overlap
				best_priority = region_spec.priority
		report += list(list(
			"id" = room.id,
			"zone_id" = room.zone_id,
			"role" = room.role,
			"required" = istype(zone_spec) && zone_spec.required ? TRUE : FALSE,
			"divider_mode" = istype(zone_spec) ? zone_spec.divider_mode : "",
			"area" = room.area,
			"bounds" = list("x1" = room.x1, "y1" = room.y1, "x2" = room.x2, "y2" = room.y2),
			"route_access" = building_room_touches_circulation(state, room) ? TRUE : FALSE,
			"region_match_id" = best_region_id,
			"region_match_area" = best_overlap,
			"region_contract_ok" = !length(region_specs) || best_overlap > 0 || is_building_compact_or_micro_state(state),
		))
	return report

/datum/world_edit_generator/building_layout/proc/build_building_object_contract_report(datum/world_edit_building_layout_state/state)
	var/list/report = list()
	if(!istype(state))
		return report
	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(!islist(object_placement))
			continue
		report += list(list(
			"slot" = object_placement["requested_slot"] || object_placement["slot"],
			"category" = object_placement["category"],
			"zone_id" = object_placement["zone_id"],
			"anchor_id" = object_placement["anchor_id"],
			"cluster_id" = object_placement["cluster_id"],
			"semantic_requirement_id" = object_placement["semantic_requirement_id"] || object_placement["requirement_id"],
			"dir" = object_placement["dir"],
			"dir_label" = object_placement["dir_label"],
			"dir_source" = object_placement["dir_source"],
			"dir_mode" = object_placement["dir_mode"],
			"wall_dir" = object_placement["wall_dir"],
			"wall_dir_label" = object_placement["wall_dir_label"],
			"wall_mounted" = object_placement["wall_mounted"] ? TRUE : FALSE,
			"provider_id" = object_placement["fixture_provider_id"],
			"functional" = isnull(object_placement["functional"]) ? TRUE : (object_placement["functional"] ? TRUE : FALSE),
			"infrastructure" = object_placement["infrastructure"] ? TRUE : FALSE,
		))
	return report

/datum/world_edit_generator/building_layout/proc/build_building_dir_contract_report(datum/world_edit_building_layout_state/state)
	var/list/report = list()
	if(!istype(state))
		return report
	var/list/doors = list()
	for(var/list/door_report as anything in state.validation.door_reports)
		if(!islist(door_report))
			continue
		var/turf/door_turf = door_report["turf"]
		var/door_dir = door_report["dir"] || (istype(door_turf) ? state.geometry.door_dirs[door_turf] : null)
		doors += list(list(
			"kind" = door_report["kind"],
			"zone_id" = door_report["zone_id"],
			"x" = istype(door_turf) ? door_turf.x : null,
			"y" = istype(door_turf) ? door_turf.y : null,
			"dir" = door_dir,
			"dir_label" = GLOB.world_edit_helpers.dir_to_label(door_dir),
		))
	var/list/wall_fixtures = list()
	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(!islist(object_placement) || !GLOB.world_edit_helpers.parse_bool(object_placement["wall_mounted"]))
			continue
		wall_fixtures += list(list(
			"slot" = object_placement["requested_slot"] || object_placement["slot"],
			"zone_id" = object_placement["zone_id"],
			"dir" = object_placement["dir"],
			"dir_label" = object_placement["dir_label"],
			"wall_dir" = object_placement["wall_dir"],
			"wall_dir_label" = object_placement["wall_dir_label"],
			"front_dir" = object_placement["front_dir"],
			"front_dir_label" = object_placement["front_dir_label"],
			"dir_mode" = object_placement["dir_mode"],
			"dir_source" = object_placement["dir_source"],
		))
	report["requested_direction"] = state.geometry.requested_direction
	report["requested_direction_label"] = GLOB.world_edit_helpers.dir_to_label(state.geometry.requested_direction)
	report["actual_entry_direction"] = state.geometry.actual_entry_direction
	report["actual_entry_direction_label"] = GLOB.world_edit_helpers.dir_to_label(state.geometry.actual_entry_direction)
	report["direction_honored"] = state.geometry.actual_entry_direction == state.geometry.requested_direction
	report["direction_fallback_count"] = state.validation.direction_fallback_count
	report["direction_fallback_reason"] = state.geometry.direction_fallback_reason
	report["doors"] = doors
	report["wall_fixtures"] = wall_fixtures
	return report

/datum/world_edit_generator/building_layout/proc/add_building_emitted_requirement_count(list/emitted_requirement_counts, requirement_id, amount = 1)
	if(!islist(emitted_requirement_counts) || !length("[requirement_id]"))
		return
	var/count = max(round(text2num("[amount]") || 0), 0)
	if(count <= 0)
		return
	emitted_requirement_counts["[requirement_id]"] = round(text2num("[emitted_requirement_counts["[requirement_id]"]]") || 0) + count

/datum/world_edit_generator/building_layout/proc/find_building_cluster_spec_for_emitted_ids(datum/world_edit_building_layout_state/state, requirement_id, cluster_id = null, signature_id = null)
	if(!istype(state) || !istype(state.semantic_plan))
		return null
	for(var/datum/world_edit_building_cluster_spec/cluster_spec as anything in state.semantic_plan.cluster_specs)
		if(!istype(cluster_spec))
			continue
		if(length("[cluster_id]") && cluster_spec.id == "[cluster_id]")
			return cluster_spec
		if(length("[signature_id]") && cluster_spec.signature_id == "[signature_id]")
			return cluster_spec
		if(length("[requirement_id]") && get_building_cluster_requirement_id(cluster_spec) == "[requirement_id]")
			return cluster_spec
	return null

/datum/world_edit_generator/building_layout/proc/add_building_route_pattern_emitted_credits(datum/world_edit_building_layout_state/state, list/emitted_requirement_counts)
	if(!istype(state) || !islist(emitted_requirement_counts))
		return
	for(var/list/route_spec as anything in get_building_required_route_pattern_specs(state))
		if(!islist(route_spec))
			continue
		var/pattern_id = "[route_spec["id"]]"
		var/semantic_credit = "[route_spec["semantic_credit"] || pattern_id]"
		var/acceptance_counter = "[route_spec["acceptance_counter"] || "[semantic_credit]_ok"]"
		if(round(text2num("[state.fixtures.semantic_requirement_counts["[pattern_id]"]]") || 0) <= 0 && round(text2num("[state.fixtures.semantic_requirement_counts["[semantic_credit]"]]") || 0) <= 0)
			continue
		add_building_emitted_requirement_count(emitted_requirement_counts, pattern_id, 1)
		if(semantic_credit != pattern_id)
			add_building_emitted_requirement_count(emitted_requirement_counts, semantic_credit, 1)
		add_building_emitted_requirement_count(emitted_requirement_counts, acceptance_counter, 1)

/datum/world_edit_generator/building_layout/proc/increment_building_post_emit_report(list/report, key, amount = 1)
	if(!islist(report) || !length("[key]"))
		return
	var/report_key = "[key]"
	report[report_key] = round(text2num("[report[report_key]]") || 0) + max(round(text2num("[amount]") || 0), 0)

/datum/world_edit_generator/building_layout/proc/building_object_path_is_dense(obj_path)
	if(!ispath(obj_path, /obj))
		return FALSE
	var/atom/spawn_atom = obj_path
	return initial(spawn_atom.density) ? TRUE : FALSE

/datum/world_edit_generator/building_layout/proc/build_building_emit_object_key(kind, turf/target_turf, obj_path)
	if(!istype(target_turf))
		return null
	return "[kind]@[target_turf.x],[target_turf.y],[target_turf.z]:[obj_path]"

/datum/world_edit_generator/building_layout/proc/add_building_emit_count(list/count_lookup, key, amount = 1)
	if(!islist(count_lookup) || !length("[key]"))
		return
	var/count_key = "[key]"
	count_lookup[count_key] = round(text2num("[count_lookup[count_key]]") || 0) + max(round(text2num("[amount]") || 0), 0)

/datum/world_edit_generator/building_layout/proc/build_building_post_emit_reachable_lookup(list/walkable_lookup, turf/start_turf, list/limit_lookup)
	var/list/reachable_lookup = list()
	if(!islist(walkable_lookup) || !istype(start_turf) || !walkable_lookup[start_turf])
		return reachable_lookup
	var/list/open = list(start_turf)
	reachable_lookup[start_turf] = TRUE
	var/index = 1
	while(index <= length(open))
		var/turf/current_turf = open[index++]
		for(var/check_dir in GLOB.cardinals)
			var/turf/nearby_turf = get_step(current_turf, check_dir)
			if(!istype(nearby_turf) || reachable_lookup[nearby_turf] || !walkable_lookup[nearby_turf])
				continue
			if(islist(limit_lookup) && length(limit_lookup) && !limit_lookup[nearby_turf])
				continue
			reachable_lookup[nearby_turf] = TRUE
			open += nearby_turf
	return reachable_lookup

/datum/world_edit_generator/building_layout/proc/validate_building_plan_post_emit(datum/world_edit_plan/plan, datum/world_edit_building_layout_state/state)
	var/list/report = list(
		"status" = "ok",
		"missing_path_count" = 0,
		"failed_object_count" = 0,
		"state_mismatch_count" = 0,
		"wall_mismatch_count" = 0,
		"door_mismatch_count" = 0,
		"object_mismatch_count" = 0,
		"route_blocking_count" = 0,
		"route_unreachable_count" = 0,
		"door_cone_blocking_count" = 0,
		"microvariation_route_blocking_count" = 0,
		"semantic_credit_without_emitted_slots_count" = 0,
		"error_count" = 0,
	)
	if(!istype(plan) || !istype(state))
		report["status"] = "failed"
		report["error_count"] = 1
		return report

	var/wall_emit_count = 0
	var/door_emit_count = 0
	var/object_emit_count = 0
	var/list/emitted_floor_lookup = list()
	var/list/emitted_wall_lookup = list()
	var/list/emitted_door_lookup = list()
	var/list/emitted_dense_lookup = list()
	var/list/emitted_object_count_lookup = list()
	var/list/emitted_requirement_counts = list()
	var/list/route_blocking_samples = list()
	var/list/door_cone_blocking_samples = list()
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement))
			continue
		var/kind = "[placement["kind"]]"
		var/turf/target_turf = placement["turf"]
		switch(kind)
			if("floor", "wall")
				if(!istype(target_turf) || !ispath(placement["turf_path"], /turf))
					increment_building_post_emit_report(report, "missing_path_count")
					continue
				if(kind == "wall")
					wall_emit_count++
					emitted_wall_lookup[target_turf] = TRUE
				else
					emitted_floor_lookup[target_turf] = TRUE
			if("door", "window", "interior", "microvariation")
				if(!istype(target_turf) || !ispath(placement["obj_path"], /obj))
					increment_building_post_emit_report(report, "missing_path_count")
					continue
				add_building_emit_count(emitted_object_count_lookup, build_building_emit_object_key(kind, target_turf, placement["obj_path"]))
				if(kind == "door")
					door_emit_count++
					emitted_door_lookup[target_turf] = TRUE
					emitted_floor_lookup[target_turf] = TRUE
				if(kind in list("interior", "microvariation"))
					object_emit_count++
				if(kind == "interior")
					var/object_is_dense = building_object_path_is_dense(placement["obj_path"])
					if(object_is_dense)
						emitted_dense_lookup[target_turf] = TRUE
					if(object_is_dense && state.geometry.reserved_lookup[target_turf])
						increment_building_post_emit_report(report, "route_blocking_count")
						if(length(route_blocking_samples) < 12)
							route_blocking_samples += list(list(
								"kind" = kind,
								"x" = istype(target_turf) ? target_turf.x : null,
								"y" = istype(target_turf) ? target_turf.y : null,
								"z" = istype(target_turf) ? target_turf.z : null,
								"obj_path" = placement["obj_path"],
								"slot" = placement["slot"],
								"category" = placement["category"],
								"cluster_id" = placement["cluster_id"],
								"requirement_id" = placement["requirement_id"],
								"wall_mounted" = GLOB.world_edit_helpers.parse_bool(placement["wall_mounted"]),
								"dir" = placement["dir"],
							))
					var/requirement_credit = round(text2num("[placement["requirement_count_credit"]]") || 0)
					var/requirement_id = "[placement["requirement_id"] || ""]"
					if(requirement_credit > 0 && length(requirement_id))
						var/list/provided_slots = placement["provided_slots"]
						var/requested_slot = "[placement["requested_slot"] || placement["slot"] || ""]"
						var/required_capability = "[placement["required_capability"] || get_building_fixture_required_capability(requested_slot, placement["category"])]"
						if(!GLOB.world_edit_helpers.parse_bool(placement["functional"]) || !islist(provided_slots) || !(requested_slot in provided_slots) || !building_placement_provides_capability(placement, required_capability))
							increment_building_post_emit_report(report, "semantic_credit_without_emitted_slots_count", requirement_credit)
							continue
						add_building_emitted_requirement_count(emitted_requirement_counts, requirement_id, requirement_credit)
						var/cluster_id = "[placement["cluster_id"] || ""]"
						var/signature_id = "[placement["signature_id"] || ""]"
						add_building_emitted_requirement_count(emitted_requirement_counts, cluster_id, requirement_credit)
						add_building_emitted_requirement_count(emitted_requirement_counts, signature_id, requirement_credit)
						var/datum/world_edit_building_cluster_spec/source_cluster = find_building_cluster_spec_for_emitted_ids(state, requirement_id, cluster_id, signature_id)
						for(var/list/alias_spec as anything in get_building_cluster_credit_alias_specs(source_cluster))
							if(!islist(alias_spec))
								continue
							var/required_alias_capability = "[alias_spec["capability"] || ""]"
							if(length(required_alias_capability) && !building_placement_provides_capability(placement, required_alias_capability))
								continue
							var/alias_credit = "[alias_spec["semantic_credit"]]"
							var/alias_counter = "[alias_spec["acceptance_counter"] || "[alias_credit]_count"]"
							add_building_emitted_requirement_count(emitted_requirement_counts, alias_credit, requirement_credit)
							add_building_emitted_requirement_count(emitted_requirement_counts, alias_counter, requirement_credit)
				else if(kind == "microvariation")
					var/microvariation_is_dense = building_object_path_is_dense(placement["obj_path"])
					if(microvariation_is_dense)
						emitted_dense_lookup[target_turf] = TRUE
					if(microvariation_is_dense && state.geometry.reserved_lookup[target_turf])
						increment_building_post_emit_report(report, "route_blocking_count")
						increment_building_post_emit_report(report, "microvariation_route_blocking_count")
						if(length(route_blocking_samples) < 12)
							route_blocking_samples += list(list(
								"kind" = kind,
								"x" = istype(target_turf) ? target_turf.x : null,
								"y" = istype(target_turf) ? target_turf.y : null,
								"z" = istype(target_turf) ? target_turf.z : null,
								"obj_path" = placement["obj_path"],
								"slot" = placement["slot"],
								"category" = placement["category"],
								"cluster_id" = placement["cluster_id"],
								"requirement_id" = placement["requirement_id"],
								"wall_mounted" = GLOB.world_edit_helpers.parse_bool(placement["wall_mounted"]),
								"dir" = placement["dir"],
							))

	add_building_route_pattern_emitted_credits(state, emitted_requirement_counts)

	if(wall_emit_count != length(state.geometry.wall_lookup))
		increment_building_post_emit_report(report, "wall_mismatch_count", abs(wall_emit_count - length(state.geometry.wall_lookup)))
	for(var/turf/wall_turf as anything in state.geometry.wall_lookup)
		if(state.geometry.wall_lookup[wall_turf] && !emitted_wall_lookup[wall_turf])
			increment_building_post_emit_report(report, "wall_mismatch_count")
	for(var/turf/emitted_wall_turf as anything in emitted_wall_lookup)
		if(emitted_wall_lookup[emitted_wall_turf] && !state.geometry.wall_lookup[emitted_wall_turf])
			increment_building_post_emit_report(report, "wall_mismatch_count")
	if(door_emit_count != length(state.geometry.door_turfs))
		increment_building_post_emit_report(report, "door_mismatch_count", abs(door_emit_count - length(state.geometry.door_turfs)))
	for(var/turf/door_turf as anything in state.geometry.door_turfs)
		if(!emitted_door_lookup[door_turf])
			increment_building_post_emit_report(report, "door_mismatch_count")
	for(var/turf/emitted_door_turf as anything in emitted_door_lookup)
		if(emitted_door_lookup[emitted_door_turf] && !(emitted_door_turf in state.geometry.door_turfs))
			increment_building_post_emit_report(report, "door_mismatch_count")
	if(object_emit_count != length(state.fixtures.object_placements))
		increment_building_post_emit_report(report, "object_mismatch_count", abs(object_emit_count - length(state.fixtures.object_placements)))
	for(var/list/state_object_placement as anything in state.fixtures.object_placements)
		if(!islist(state_object_placement))
			continue
		var/state_object_key = build_building_emit_object_key(state_object_placement["kind"], state_object_placement["turf"], state_object_placement["obj_path"])
		var/emitted_count = round(text2num("[emitted_object_count_lookup["[state_object_key]"]]") || 0)
		if(emitted_count <= 0)
			increment_building_post_emit_report(report, "object_mismatch_count")
			continue
		emitted_object_count_lookup["[state_object_key]"] = emitted_count - 1

	var/list/emitted_walkable_lookup = list()
	for(var/turf/walkable_floor_turf as anything in emitted_floor_lookup)
		if(!emitted_wall_lookup[walkable_floor_turf] && !emitted_dense_lookup[walkable_floor_turf])
			emitted_walkable_lookup[walkable_floor_turf] = TRUE
	for(var/turf/walkable_door_turf as anything in emitted_door_lookup)
		if(!emitted_wall_lookup[walkable_door_turf] && !emitted_dense_lookup[walkable_door_turf])
			emitted_walkable_lookup[walkable_door_turf] = TRUE
	var/turf/route_start_turf = state.geometry.front_door_turf
	if(!emitted_walkable_lookup[route_start_turf] && length(state.geometry.primary_route_turfs))
		route_start_turf = state.geometry.primary_route_turfs[1]
	var/list/post_emit_reachable_lookup = build_building_post_emit_reachable_lookup(emitted_walkable_lookup, route_start_turf, state.geometry.footprint_lookup)
	for(var/turf/route_turf as anything in state.geometry.primary_route_turfs)
		if(!emitted_floor_lookup[route_turf] && !emitted_door_lookup[route_turf])
			increment_building_post_emit_report(report, "route_blocking_count")
			if(length(route_blocking_samples) < 12)
				route_blocking_samples += list(list(
					"kind" = "route",
					"reason" = "missing_floor_or_door",
					"x" = istype(route_turf) ? route_turf.x : null,
					"y" = istype(route_turf) ? route_turf.y : null,
					"z" = istype(route_turf) ? route_turf.z : null,
				))
		if(emitted_wall_lookup[route_turf] || emitted_dense_lookup[route_turf])
			increment_building_post_emit_report(report, "route_blocking_count")
			if(length(route_blocking_samples) < 12)
				route_blocking_samples += list(list(
					"kind" = "route",
					"reason" = "wall_or_dense",
					"x" = istype(route_turf) ? route_turf.x : null,
					"y" = istype(route_turf) ? route_turf.y : null,
					"z" = istype(route_turf) ? route_turf.z : null,
				))
		if(!post_emit_reachable_lookup[route_turf])
			increment_building_post_emit_report(report, "route_unreachable_count")
	for(var/turf/door_turf as anything in state.geometry.door_turfs)
		var/door_dir = state.geometry.door_dirs[door_turf] || state.placement_dir
		for(var/cone_dir as anything in list(door_dir, turn(door_dir, 180)))
			var/turf/cone_turf = get_step(door_turf, cone_dir)
			if(!state.geometry.floor_lookup[cone_turf])
				continue
			if(!emitted_floor_lookup[cone_turf] && !emitted_door_lookup[cone_turf])
				increment_building_post_emit_report(report, "route_blocking_count")
				increment_building_post_emit_report(report, "door_cone_blocking_count")
				if(length(door_cone_blocking_samples) < 12)
					door_cone_blocking_samples += list(list(
						"x" = istype(cone_turf) ? cone_turf.x : null,
						"y" = istype(cone_turf) ? cone_turf.y : null,
						"z" = istype(cone_turf) ? cone_turf.z : null,
						"door_turf" = istype(door_turf) ? "[door_turf.x],[door_turf.y],[door_turf.z]" : null,
						"door_dir" = door_dir,
						"cone_dir" = cone_dir,
					))
			if(emitted_wall_lookup[cone_turf] || emitted_dense_lookup[cone_turf])
				increment_building_post_emit_report(report, "route_blocking_count")
				increment_building_post_emit_report(report, "door_cone_blocking_count")
				if(length(door_cone_blocking_samples) < 12)
					door_cone_blocking_samples += list(list(
						"x" = istype(cone_turf) ? cone_turf.x : null,
						"y" = istype(cone_turf) ? cone_turf.y : null,
						"z" = istype(cone_turf) ? cone_turf.z : null,
						"door_turf" = istype(door_turf) ? "[door_turf.x],[door_turf.y],[door_turf.z]" : null,
						"door_dir" = door_dir,
						"cone_dir" = cone_dir,
					))

	for(var/requirement_id as anything in state.fixtures.semantic_requirement_counts)
		var/planned_count = round(text2num("[state.fixtures.semantic_requirement_counts[requirement_id]]") || 0)
		var/emitted_count = round(text2num("[emitted_requirement_counts[requirement_id]]") || 0)
		if(planned_count > emitted_count)
			increment_building_post_emit_report(report, "semantic_credit_without_emitted_slots_count", planned_count - emitted_count)
	report["emitted_requirement_counts"] = emitted_requirement_counts.Copy()

	report["state_mismatch_count"] = round(text2num("[report["wall_mismatch_count"]]") || 0) + round(text2num("[report["door_mismatch_count"]]") || 0) + round(text2num("[report["object_mismatch_count"]]") || 0)
	var/error_count = round(text2num("[report["missing_path_count"]]") || 0) + round(text2num("[report["failed_object_count"]]") || 0) + round(text2num("[report["state_mismatch_count"]]") || 0) + round(text2num("[report["route_blocking_count"]]") || 0) + round(text2num("[report["route_unreachable_count"]]") || 0) + round(text2num("[report["semantic_credit_without_emitted_slots_count"]]") || 0)
	report["error_count"] = error_count
	if(length(route_blocking_samples))
		report["route_blocking_samples"] = route_blocking_samples
	if(length(door_cone_blocking_samples))
		report["door_cone_blocking_samples"] = door_cone_blocking_samples
	if(error_count > 0)
		report["status"] = "failed"
		state.validation.emit_missing_path_count = round(text2num("[report["missing_path_count"]]") || 0)
		state.validation.emit_failed_object_count = round(text2num("[report["failed_object_count"]]") || 0)
		state.validation.emit_state_mismatch_count = round(text2num("[report["state_mismatch_count"]]") || 0)
		state.validation.post_emit_validation_error_count = error_count
		state.validation.semantic_credit_without_emitted_slots_count = round(text2num("[report["semantic_credit_without_emitted_slots_count"]]") || 0)
		state.add_warning("Post-emit validation failed for building layout: [error_count] emitted/reserved-state errors.")
	state.validation.post_emit_validation_report = report
	return report

/datum/world_edit_generator/building_layout/proc/resolve_building_zone_floor_type(datum/world_edit_building_layout_state/state, turf/floor_turf)
	if(!istype(state) || !istype(floor_turf))
		return state?.config?["floor_type"]
	var/zone_id = state.get_zone(floor_turf)
	var/floor_path = null
	switch(state.archetype?.id)
		if("medbay")
			if(building_zone_matches_any_signature_token(state, zone_id, list("treatment", "triage", "med", "surgery")))
				floor_path = "/turf/open/floor/prison/sterile_white"
		if("hydroponics")
			if(building_zone_matches_any_signature_token(state, zone_id, list("grow", "hydro", "greenhouse")))
				floor_path = "/turf/open/floor/prison/greenblue"
			else if(building_zone_matches_any_signature_token(state, zone_id, list("seed", "work", "service")))
				floor_path = "/turf/open/floor/prison/green"
		if("kitchen")
			if(building_zone_matches_any_signature_token(state, zone_id, list("kitchen", "prep", "cooking", "serving", "cold")))
				floor_path = "/turf/open/floor/prison/kitchen"
			else if(building_zone_matches_any_signature_token(state, zone_id, list("dining")))
				floor_path = "/turf/open/floor/interior/wood/alt"
		if("dormitory")
			if(building_zone_matches_any_signature_token(state, zone_id, list("sleep", "locker")))
				floor_path = "/turf/open/floor/interior/wood/alt"
		if("office")
			if(building_zone_matches_any_signature_token(state, zone_id, list("desk", "filing", "visitor")))
				floor_path = "/turf/open/floor/prison/blue_plate"
		if("security", "checkpoint")
			if(building_zone_matches_any_signature_token(state, zone_id, list("secure", "holding", "locker")))
				floor_path = "/turf/open/floor/prison/cell_stripe"
			else if(building_zone_matches_any_signature_token(state, zone_id, list("public", "counter", "desk")))
				floor_path = "/turf/open/floor/prison/blue"
		if("workshop")
			if(building_zone_matches_any_signature_token(state, zone_id, list("work", "service", "parts")))
				floor_path = "/turf/open/floor/almayer/orange"
		if("storage")
			if(building_zone_matches_any_signature_token(state, zone_id, list("rack", "loading", "staging")))
				floor_path = "/turf/open/floor/almayer/cargo"
		if("engineering")
			if(building_zone_matches_any_signature_token(state, zone_id, list("machine", "power", "engineering")))
				floor_path = "/turf/open/floor/almayer/orange"
			else if(building_zone_matches_any_signature_token(state, zone_id, list("parts", "storage")))
				floor_path = "/turf/open/floor/almayer/cargo"
		if("laboratory")
			if(building_zone_matches_any_signature_token(state, zone_id, list("lab", "analysis", "clean")))
				floor_path = "/turf/open/floor/prison/sterile_white"
			else if(building_zone_matches_any_signature_token(state, zone_id, list("specimen", "containment")))
				floor_path = "/turf/open/floor/prison/blue_plate"
	if(!isnull(floor_path))
		var/resolved_floor = resolve_building_type_path(floor_path, /turf)
		if(resolved_floor)
			return resolved_floor
	return state.config["floor_type"]

/datum/world_edit_generator/building_layout/proc/emit_building_layout_plan(datum/world_edit_building_layout_state/state, datum/world_edit_shape_contract/shape_contract, list/placement_context)
	var/datum/world_edit_plan/plan = new
	if(!istype(state))
		plan.metadata["error"] = "Building layout state is unavailable."
		finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
		return plan

	plan.metadata["archetype_id"] = state.archetype?.id
	plan.metadata["archetype_label"] = state.archetype?.label
	plan.metadata["faction_preset"] = state.config["faction_preset"]
	plan.metadata["footprint_family"] = state.config["footprint_family"]
	plan.metadata["placement_shape_id"] = state.config["placement_shape_id"]
	plan.metadata["footprint_source"] = state.config["footprint_source"]
	plan.metadata["placement_shape_used_as_seed_only"] = state.config["placement_shape_used_as_seed_only"] ? TRUE : FALSE
	plan.metadata["current_request_support_status"] = state.validation.current_request_support_status
	plan.metadata["user_facing_failure_reason"] = state.validation.user_facing_failure_reason
	plan.metadata["support_status_report"] = state.validation.support_status_report.Copy()
	var/detailed_reports = should_emit_detailed_building_reports(state.config)
	var/datum/world_edit_building_layout_context/active_layout_context = state.layout_context
	if(building_layout_solver_enabled(state))
		if(istype(active_layout_context?.selected_candidate))
			sync_building_layout_physical_door_state(state, active_layout_context.selected_candidate)
	plan.metadata["stage_reports"] = detailed_reports ? state.validation.stage_reports.Copy() : list()
	plan.metadata["stage_report_count"] = length(state.validation.stage_reports)
	plan.metadata["room_reports"] = detailed_reports ? state.validation.room_reports.Copy() : list()
	plan.metadata["room_report_count"] = length(state.validation.room_reports)
	plan.metadata["zone_reports"] = detailed_reports ? state.validation.zone_reports.Copy() : list()
	plan.metadata["zone_report_count"] = length(state.validation.zone_reports)
	plan.metadata["corridor_report"] = detailed_reports ? state.validation.corridor_report.Copy() : list()
	plan.metadata["wall_report"] = detailed_reports ? state.validation.wall_report.Copy() : list()
	plan.metadata["door_reports"] = detailed_reports ? state.validation.door_reports.Copy() : list()
	plan.metadata["door_report_count"] = length(state.validation.door_reports)
	plan.metadata["pattern_reports"] = detailed_reports ? state.validation.pattern_reports.Copy() : list()
	plan.metadata["pattern_report_count"] = length(state.validation.pattern_reports)
	plan.metadata["room_contract_report"] = build_building_room_contract_report(state)
	plan.metadata["object_contract_report"] = build_building_object_contract_report(state)
	plan.metadata["dir_contract_report"] = build_building_dir_contract_report(state)
	plan.metadata["infrastructure_report"] = detailed_reports ? state.validation.infrastructure_report.Copy() : list()
	plan.metadata["fallback_audit"] = detailed_reports ? state.validation.fallback_audit.Copy() : list()
	plan.metadata["old_path_audit"] = detailed_reports ? state.validation.old_path_audit.Copy() : list()
	plan.metadata["root_seed"] = state.root_seed
	plan.metadata["stage_seed_footprint"] = state.stage_seed_footprint
	plan.metadata["stage_seed_rooms"] = state.stage_seed_rooms
	plan.metadata["stage_seed_corridor"] = state.stage_seed_corridor
	plan.metadata["stage_seed_patterns"] = state.stage_seed_patterns
	plan.metadata["stage_seed_details"] = state.stage_seed_details
	plan.metadata["footprint_hash"] = state.geometry.footprint_hash
	plan.metadata["room_graph_hash"] = state.geometry.room_graph_hash
	plan.metadata["route_hash"] = state.geometry.route_hash
	plan.metadata["wall_hash"] = state.geometry.wall_hash
	plan.metadata["structural_topology_signature"] = state.geometry.structural_topology_signature
	plan.metadata["geometry_layout_hash"] = state.geometry.geometry_layout_hash
	plan.metadata["pattern_credit_hash"] = state.fixtures.pattern_credit_hash
	plan.metadata["layout_hash"] = state.geometry.layout_hash
	plan.metadata["determinism_check_hash"] = state.validation.determinism_check_hash
	var/target_room_count = round(text2num("[state.config["target_room_count"]]") || 0)
	var/effective_room_count_divider_count = state.validation.room_count_divider_count
	plan.metadata["building_placement_contract"] = list(
		"program_id" = state.archetype?.id,
		"shell_preset" = state.config["faction_preset"],
		"shape_id" = state.config["placement_shape_id"],
		"direction" = state.placement_dir,
		"footprint_source" = state.config["footprint_source"],
		"usable_area" = state.fixtures.usable_fixture_area,
		"room_count" = length(state.geometry.solved_rooms),
		"target_room_count" = state.config["target_room_count"] || 0,
		"room_count_divider_count" = effective_room_count_divider_count,
		"corridor_turf_count" = length(state.geometry.corridor_turfs),
		"semantic_requirement_minimums" = state.fixtures.semantic_requirement_minimums.Copy(),
		"semantic_requirement_counts" = state.fixtures.semantic_requirement_counts.Copy(),
		"reservation_count" = length(state.fixtures.semantic_slot_reservation_by_turf),
	)
	plan.metadata["layout_candidate_score"] = state.config["layout_candidate_score"] || state.validation.layout_candidate_score
	plan.metadata["layout_candidate_count"] = state.config["layout_candidate_count"] || 1
	plan.metadata["layout_candidate_reports"] = islist(state.config["layout_candidate_reports"]) ? state.config["layout_candidate_reports"].Copy() : list()
	plan.metadata["selected_candidate_report"] = islist(state.config["selected_candidate_report"]) ? state.config["selected_candidate_report"].Copy() : list()
	plan.metadata["layout_candidate_index"] = state.config["layout_candidate_index"] || 1
	plan.metadata["layout_enabled"] = state.config["layout_enabled"] ? TRUE : FALSE
	plan.metadata["layout_pattern_id"] = state.config["layout_pattern_id"] || ""
	plan.metadata["layout_candidate_id"] = state.config["layout_candidate_id"] || ""
	plan.metadata["layout_candidate_count"] = state.config["layout_candidate_count"] || 0
	plan.metadata["layout_hard_valid_candidate_count"] = state.config["layout_hard_valid_candidate_count"] || 0
	plan.metadata["layout_distinct_hard_valid_family_count"] = state.config["layout_distinct_hard_valid_family_count"] || state.validation.layout_distinct_hard_valid_family_count
	plan.metadata["structural_topology_signature_count"] = state.config["structural_topology_signature_count"] || state.validation.layout_distinct_hard_valid_family_count
	plan.metadata["layout_selected_topology_family"] = active_layout_context?.selected_candidate?.topology_family || state.config["layout_pattern_id"] || ""
	plan.metadata["layout_best_hard_valid_candidate_score"] = state.config["layout_best_hard_valid_candidate_score"] || state.config["layout_candidate_score"] || 0
	plan.metadata["layout_family_winner_count"] = state.config["layout_family_winner_count"] || 0
	plan.metadata["layout_family_winner_scores"] = islist(state.config["layout_family_winner_scores"]) ? state.config["layout_family_winner_scores"].Copy() : list()
	plan.metadata["layout_seed_quality_margin"] = state.config["layout_seed_quality_margin"] || 0
	plan.metadata["layout_seed_quality_floor"] = state.config["layout_seed_quality_floor"] || state.config["layout_candidate_score"] || 0
	plan.metadata["layout_seed_eligible_family_count"] = state.config["layout_seed_eligible_family_count"] || 0
	plan.metadata["layout_seed_selection_index"] = state.config["layout_seed_selection_index"] || 0
	plan.metadata["layout_seed_selection_key"] = state.config["layout_seed_selection_key"] || ""
	plan.metadata["layout_selected_candidate_score_gap"] = state.config["layout_selected_candidate_score_gap"] || 0
	plan.metadata["layout_functional_room_count"] = state.validation.layout_functional_room_count
	plan.metadata["layout_target_functional_room_count"] = state.validation.layout_target_functional_room_count
	plan.metadata["layout_functional_room_count_gap"] = state.validation.layout_functional_room_count_gap
	plan.metadata["layout_circulation_region_count"] = state.validation.layout_circulation_region_count
	plan.metadata["layout_candidate_metric_mismatch_count"] = state.validation.layout_candidate_metric_mismatch_count
	plan.metadata["layout_wall_cleanup_removed_count"] = state.validation.layout_wall_cleanup_removed_count
	plan.metadata["layout_wall_cleanup_ratio_percent"] = state.validation.layout_wall_cleanup_ratio_percent
	plan.metadata["layout_optional_template_attempt_count"] = state.validation.layout_optional_template_attempt_count
	plan.metadata["layout_optional_template_reject_count"] = state.validation.layout_optional_template_reject_count
	plan.metadata["layout_template_reject_ratio_percent"] = state.validation.layout_template_reject_ratio_percent
	plan.metadata["layout_scene_count"] = state.config["layout_scene_count"] || 0
	plan.metadata["semantic_region_claim_count"] = state.validation.region_claim_count
	plan.metadata["semantic_region_claim_reports"] = detailed_reports ? state.validation.region_claim_reports.Copy() : list()
	plan.metadata["rectangular_region_candidate_count"] = state.validation.rectangular_region_candidate_count
	plan.metadata["nested_room_count"] = state.validation.nested_room_count
	plan.metadata["target_room_count"] = state.config["target_room_count"] || state.validation.requested_room_count
	plan.metadata["room_count_divider_count"] = effective_room_count_divider_count
	plan.metadata["room_count_satisfied"] = !target_room_count || length(state.geometry.solved_rooms) >= target_room_count
	plan.metadata["room_count_gap"] = max(0, target_room_count - length(state.geometry.solved_rooms))
	plan.metadata["room_fill_attempt_count"] = state.validation.room_fill_attempt_count
	plan.metadata["room_fill_fixture_count"] = state.validation.room_fill_fixture_count
	plan.metadata["template_chunk_count"] = state.fixtures.template_chunk_count
	plan.metadata["template_chunk_cell_count"] = state.fixtures.template_chunk_cell_count
	plan.metadata["infrastructure_count"] = state.fixtures.infrastructure_count
	plan.metadata["semantic_slot_capacity_count"] = state.validation.semantic_slot_capacity_count
	plan.metadata["semantic_slot_shortage_count"] = state.validation.semantic_slot_shortage_count
	plan.metadata["semantic_slot_fallback_count"] = state.validation.semantic_slot_fallback_count
	plan.metadata["semantic_slot_reports"] = detailed_reports ? state.validation.semantic_slot_reports.Copy() : list()
	plan.metadata["semantic_slot_report_count"] = length(state.validation.semantic_slot_reports)
	plan.metadata["semantic_requirement_minimums"] = state.fixtures.semantic_requirement_minimums.Copy()
	plan.metadata["placed_requirement_counts"] = state.fixtures.placed_requirement_counts.Copy()
	plan.metadata["semantic_requirement_counts"] = state.fixtures.semantic_requirement_counts.Copy()
	plan.metadata["semantic_requirement_reports"] = state.validation.semantic_requirement_reports.Copy()
	plan.metadata["template_reject_reason_counts"] = state.validation.template_reject_reason_counts.Copy()
	plan.metadata["template_reject_reports"] = detailed_reports ? state.validation.template_reject_reports.Copy() : list()
	plan.metadata["template_reject_report_count"] = length(state.validation.template_reject_reports)
	plan.metadata["template_cluster_reports"] = detailed_reports ? state.validation.template_cluster_reports.Copy() : list()
	plan.metadata["template_cluster_report_count"] = length(state.validation.template_cluster_reports)
	plan.metadata["semantic_slot_reservation_count"] = length(state.fixtures.semantic_slot_reservation_by_turf)
	plan.metadata["semantic_slot_reservation_conflict_count"] = state.validation.semantic_slot_reservation_conflict_count
	plan.metadata["mandatory_room_count"] = state.validation.mandatory_room_count
	plan.metadata["mandatory_zone_count"] = state.validation.mandatory_zone_count
	plan.metadata["mandatory_room_missing_count"] = state.validation.mandatory_room_missing_count
	plan.metadata["mandatory_room_no_bounds_count"] = state.validation.mandatory_room_no_bounds_count
	plan.metadata["mandatory_room_no_access_count"] = state.validation.mandatory_room_no_access_count
	plan.metadata["mandatory_pattern_missing_count"] = state.validation.mandatory_pattern_missing_count
	plan.metadata["mandatory_pattern_uncredited_count"] = state.validation.mandatory_pattern_uncredited_count
	plan.metadata["mandatory_pattern_failure_count"] = state.validation.mandatory_pattern_failure_count
	plan.metadata["reserved_walk_blocked_count"] = state.validation.reserved_walk_blocked_count
	plan.metadata["door_cone_blocked_count"] = state.validation.door_cone_blocked_count
	plan.metadata["door_corner_count"] = state.validation.door_corner_count
	plan.metadata["mandatory_fixture_access_unreachable_count"] = state.validation.mandatory_fixture_access_unreachable_count
	plan.metadata["double_wall_error_count"] = state.validation.double_wall_error_count
	plan.metadata["diagonal_only_contact_count"] = state.validation.diagonal_only_contact_count
	plan.metadata["cutout_violation_count"] = state.validation.cutout_violation_count
	plan.metadata["unsupported_shape_silent_fallback_count"] = state.validation.unsupported_shape_silent_fallback_count
	plan.metadata["style_required_slot_missing_count"] = state.validation.style_required_slot_missing_count
	plan.metadata["raw_category_credit_count"] = state.validation.raw_category_credit_count
	plan.metadata["scatter_signature_credit_count"] = state.validation.scatter_signature_credit_count
	plan.metadata["semantic_credit_without_emitted_slots_count"] = state.validation.semantic_credit_without_emitted_slots_count
	plan.metadata["forbidden_fallback_count"] = state.validation.forbidden_fallback_count
	plan.metadata["unique_provider_path_count"] = state.validation.unique_provider_path_count
	plan.metadata["unique_functional_provider_path_count"] = state.validation.unique_functional_provider_path_count
	plan.metadata["unique_decorative_provider_path_count"] = state.validation.unique_decorative_provider_path_count
	plan.metadata["hard_counters"] = build_building_state_hard_counter_report(state)
	for(var/counter_name as anything in plan.metadata["hard_counters"])
		plan.metadata["[counter_name]"] = plan.metadata["hard_counters"][counter_name]
	plan.metadata["layout_unassigned_interior_turf_count"] = state.validation.layout_unassigned_interior_turf_count
	plan.metadata["layout_unassigned_interior_ratio_percent"] = state.validation.layout_unassigned_interior_ratio_percent
	plan.metadata["layout_route_component_count"] = state.validation.layout_route_component_count
	plan.metadata["layout_public_room_hard_closed_count"] = state.validation.layout_public_room_hard_closed_count
	plan.metadata["layout_public_opening_missing_count"] = state.validation.layout_public_opening_missing_count
	plan.metadata["layout_opposing_route_door_pair_count"] = state.validation.layout_opposing_route_door_pair_count
	plan.metadata["layout_corridor_wall_canyon_count"] = state.validation.layout_corridor_wall_canyon_count
	plan.metadata["layout_route_wall_canyon_length"] = state.validation.layout_route_wall_canyon_length
	plan.metadata["layout_excessive_wall_to_floor_ratio_count"] = state.validation.layout_excessive_wall_to_floor_ratio_count
	plan.metadata["layout_template_geometry_reject_count"] = state.validation.layout_template_geometry_reject_count
	plan.metadata["layout_missing_wall_context_reject_count"] = state.validation.layout_missing_wall_context_reject_count
	plan.metadata["layout_hard_valid_candidate_shortage_count"] = state.validation.layout_hard_valid_candidate_shortage_count
	plan.metadata["layout_distinct_hard_valid_family_count"] = state.config["layout_distinct_hard_valid_family_count"] || state.validation.layout_distinct_hard_valid_family_count
	plan.metadata["structural_topology_signature_count"] = state.config["structural_topology_signature_count"] || state.validation.layout_distinct_hard_valid_family_count
	plan.metadata["layout_functional_room_count"] = state.validation.layout_functional_room_count
	plan.metadata["layout_target_functional_room_count"] = state.validation.layout_target_functional_room_count
	plan.metadata["layout_functional_room_count_gap"] = state.validation.layout_functional_room_count_gap
	plan.metadata["layout_circulation_region_count"] = state.validation.layout_circulation_region_count
	plan.metadata["layout_candidate_metric_mismatch_count"] = state.validation.layout_candidate_metric_mismatch_count
	plan.metadata["semantic_distribution_noise_score"] = state.validation.semantic_distribution_noise_score
	plan.metadata["semantic_functional_coverage_percent"] = state.validation.semantic_functional_coverage_percent
	plan.metadata["semantic_route_clearance_percent"] = state.validation.semantic_route_clearance_percent
	plan.metadata["structured_scene_owner"] = state.fixtures.structured_scene_owner
	plan.metadata["structured_scene_count"] = state.fixtures.structured_scene_count
	plan.metadata["structured_primary_scene_count"] = state.fixtures.structured_primary_scene_count
	plan.metadata["semantic_interiors_scene_count"] = state.fixtures.semantic_interiors_scene_count
	plan.metadata["semantic_interiors_primary_scene_count"] = state.fixtures.semantic_interiors_primary_scene_count
	plan.metadata["mandatory_room_patch_fallback_count"] = state.validation.mandatory_room_patch_fallback_count
	plan.metadata["fallback_anchor_required_cluster_count"] = state.validation.fallback_anchor_required_cluster_count
	plan.metadata["blocked_turf_conflict_count"] = state.validation.blocked_turf_conflict_count
	plan.metadata["blocked_route_conflict_count"] = state.validation.blocked_route_conflict_count
	plan.metadata["blocked_room_conflict_count"] = state.validation.blocked_room_conflict_count
	plan.metadata["blocked_wall_conflict_count"] = state.validation.blocked_wall_conflict_count
	plan.metadata["blocked_fixture_conflict_count"] = state.validation.blocked_fixture_conflict_count
	plan.metadata["replace_blocked_turf_count"] = state.validation.replace_blocked_turf_count
	plan.metadata["will_replace_blocked_turfs"] = state.config["replace_blocked_turfs"] ? TRUE : FALSE
	plan.metadata["large_replacement_requires_confirmation"] = state.config["large_replacement_requires_confirmation"] ? TRUE : FALSE
	plan.metadata["large_replacement_reason"] = state.config["large_replacement_reason"] || ""
	plan.metadata["default_max_replaced_blockers"] = WORLD_EDIT_BUILDING_DEFAULT_MAX_REPLACED_BLOCKERS
	plan.metadata["hard_max_replaced_blockers"] = WORLD_EDIT_BUILDING_HARD_MAX_REPLACED_BLOCKERS
	plan.metadata["auto_size"] = state.config["auto_size"] ? TRUE : FALSE
	plan.metadata["size_policy"] = state.config["size_policy"]
	plan.metadata["requested_half_width"] = state.config["requested_half_width"]
	plan.metadata["requested_half_depth"] = state.config["requested_half_depth"]
	plan.metadata["final_half_width"] = state.config["final_half_width"] || state.config["half_width"]
	plan.metadata["final_half_depth"] = state.config["final_half_depth"] || state.config["half_depth"]
	plan.metadata["half_width"] = state.config["half_width"]
	plan.metadata["half_depth"] = state.config["half_depth"]
	plan.metadata["size_auto_adjusted"] = state.config["size_auto_adjusted"] ? TRUE : FALSE
	plan.metadata["size_degrade_level"] = state.config["size_degrade_level"] || WORLD_EDIT_BUILDING_DEGRADE_NONE
	plan.metadata["program_shedding"] = state.config["program_shedding"] ? TRUE : FALSE
	plan.metadata["estimated_usable_area"] = state.config["estimated_usable_area"]
	plan.metadata["required_usable_area"] = state.config["required_usable_area"]
	plan.metadata["required_compact_area"] = state.config["required_compact_area"]
	plan.metadata["compact_program"] = state.semantic_plan?.compact_program ? TRUE : FALSE
	plan.metadata["compact_shed_zones"] = islist(state.semantic_plan?.compact_shed_zones) ? state.semantic_plan.compact_shed_zones.Copy() : list()
	plan.metadata["compact_required_min_area"] = islist(state.semantic_plan?.compact_required_min_area) ? state.semantic_plan.compact_required_min_area.Copy() : list()
	plan.metadata["micro_layout"] = state.config["micro_layout"] ? TRUE : FALSE
	plan.metadata["route_access_repair_count"] = state.validation.route_access_repair_count
	plan.metadata["requested_direction"] = state.geometry.requested_direction
	plan.metadata["requested_direction_label"] = GLOB.world_edit_helpers.dir_to_label(state.geometry.requested_direction)
	plan.metadata["actual_entry_direction"] = state.geometry.actual_entry_direction
	plan.metadata["actual_entry_direction_label"] = GLOB.world_edit_helpers.dir_to_label(state.geometry.actual_entry_direction)
	plan.metadata["direction_honored"] = state.geometry.actual_entry_direction == state.geometry.requested_direction
	plan.metadata["direction_honored_count"] = state.validation.direction_honored_count
	plan.metadata["direction_fallback_count"] = state.validation.direction_fallback_count
	plan.metadata["direction_fallback_reason"] = state.geometry.direction_fallback_reason
	plan.metadata["counter_wrong_facing_count"] = state.validation.counter_wrong_facing_count
	plan.metadata["entry_face_mismatch_count"] = state.validation.entry_face_mismatch_count
	plan.metadata["entry_face_readable"] = state.geometry.entry_face_readable
	plan.metadata["degraded_region_fallback_count"] = state.validation.degraded_region_fallback_count
	plan.metadata["degraded_region_reports"] = detailed_reports ? state.validation.degraded_region_reports.Copy() : list()
	plan.metadata["microvariation_count"] = state.validation.microvariation_count
	plan.metadata["footprint_mask_score"] = state.config["footprint_mask_score"]
	plan.metadata["footprint_mask_candidate_count"] = state.config["footprint_mask_candidate_count"]
	plan.metadata["effective_seed"] = state.config["effective_seed"]
	plan.metadata["building_seed"] = state.config["building_seed"]
	plan.metadata["detail_budget"] = state.config["detail_budget"]
	plan.metadata["window_density"] = state.config["window_density"]
	plan.metadata["generator_effect_turfs"] = state.geometry.footprint.Copy()
	plan.metadata["warnings"] = state.validation.warnings.Copy()
	plan.metadata["signature_counts"] = state.fixtures.signature_counts.Copy()
	plan.metadata["signature_score"] = state.validation.signature_score
	plan.metadata["signature_max_score"] = state.validation.signature_max_score
	plan.metadata["style_score"] = state.validation.style_score
	plan.metadata["category_coverage_score"] = state.validation.category_coverage_score
	plan.metadata["repeat_index"] = state.validation.repeat_index
	plan.metadata["privacy_violation_count"] = state.validation.privacy_violation_count
	plan.metadata["reachability_failure_count"] = state.validation.reachability_failure_count
	plan.metadata["repetition_conflict_count"] = state.validation.repetition_conflict_count
	plan.metadata["fixture_density_score"] = state.validation.fixture_density_score
	plan.metadata["connectivity_score"] = state.validation.connectivity_score
	plan.metadata["visibility_privacy_score"] = state.validation.visibility_privacy_score
	plan.metadata["space_distribution_score"] = state.validation.space_distribution_score
	plan.metadata["door_buffer_conflict_count"] = state.validation.door_buffer_conflict_count
	plan.metadata["window_conflict_count"] = state.validation.window_conflict_count
	plan.metadata["facade_conflict_count"] = state.validation.facade_conflict_count
	plan.metadata["invalid_window_count"] = state.validation.invalid_window_count
	plan.metadata["service_wall_window_violation_count"] = state.validation.service_wall_window_violation_count
	plan.metadata["secure_wall_window_violation_count"] = state.validation.secure_wall_window_violation_count
	plan.metadata["fixture_conflict_count"] = state.validation.fixture_conflict_count
	plan.metadata["route_conflict_count"] = state.validation.route_conflict_count
	plan.metadata["signature_warnings"] = state.fixtures.signature_warnings.Copy()
	plan.metadata["empty_floor_ratio"] = state.validation.empty_floor_ratio
	plan.metadata["program_signature_ok"] = state.validation.signature_max_score <= 0 || state.validation.signature_score >= state.semantic_plan?.min_signature_score

	if(state.has_errors())
		plan.metadata["error"] = format_building_messages(state.validation.errors)
		plan.metadata["errors"] = state.validation.errors.Copy()
		finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
		return plan

	for(var/turf/footprint_turf as anything in state.geometry.footprint)
		if(!istype(footprint_turf))
			continue
		var/list/turf_placement
		if(state.geometry.wall_lookup[footprint_turf])
			turf_placement = build_turf_placement("wall", footprint_turf, state.config["wall_type"])
			var/wall_macro_id = get_building_layout_macro_id_for_turf(state, "facade", footprint_turf)
			if(length(wall_macro_id))
				turf_placement["layout_macro"] = wall_macro_id
				turf_placement["template_overlay"] = TRUE
				turf_placement["dmm_chunk"] = wall_macro_id
		else
			turf_placement = build_turf_placement("floor", footprint_turf, resolve_building_zone_floor_type(state, footprint_turf))
		plan.placements += list(turf_placement)
		plan.affected_turfs += footprint_turf

	for(var/turf/door_turf as anything in state.geometry.door_turfs)
		if(!istype(door_turf))
			continue
		var/door_dir = state.geometry.door_dirs[door_turf] || state.placement_dir
		var/list/door_placement = build_object_placement("door", door_turf, state.config["door_type"], door_dir)
		var/door_macro_id = get_building_layout_macro_id_for_turf(state, "door", door_turf)
		if(length(door_macro_id))
			door_placement["layout_macro"] = door_macro_id
			door_placement["template_overlay"] = TRUE
			door_placement["dmm_chunk"] = door_macro_id
		plan.placements += list(door_placement)

	for(var/turf/window_turf as anything in state.geometry.window_turfs)
		if(!istype(window_turf))
			continue
		var/window_dir = get_outward_dir(window_turf, state.geometry.footprint_lookup, (state.geometry.bounds["min_x"] + state.geometry.bounds["max_x"]) / 2, (state.geometry.bounds["min_y"] + state.geometry.bounds["max_y"]) / 2, state.placement_dir)
		var/list/window_placement = build_object_placement("window", window_turf, state.config["window_type"], window_dir)
		var/window_macro_id = get_building_layout_macro_id_for_turf(state, "window", window_turf)
		if(length(window_macro_id))
			window_placement["layout_macro"] = window_macro_id
			window_placement["template_overlay"] = TRUE
			window_placement["dmm_chunk"] = window_macro_id
		plan.placements += list(window_placement)

	for(var/list/object_placement as anything in state.fixtures.object_placements)
		if(islist(object_placement))
			plan.placements += list(object_placement)

	plan.metadata["center_turf"] = state.geometry.center_turf
	plan.metadata["entry_count"] = length(plan.placements)
	plan.metadata["footprint_count"] = length(state.geometry.footprint)
	plan.metadata["boundary_count"] = length(state.geometry.boundary)
	plan.metadata["wall_count"] = length(state.geometry.wall_lookup)
	plan.metadata["floor_count"] = length(state.geometry.floor_turfs)
	plan.metadata["door_count"] = length(state.geometry.door_turfs)
	plan.metadata["window_count"] = length(state.geometry.window_turfs)
	plan.metadata["interior_object_count"] = length(state.fixtures.object_placements)
	plan.metadata["major_fixture_count"] = state.fixtures.major_fixture_count
	plan.metadata["fixture_count"] = state.fixtures.fixture_count
	plan.metadata["fixture_category_counts"] = state.fixtures.category_counts.Copy()
	plan.metadata["cluster_counts"] = state.fixtures.cluster_counts.Copy()
	plan.metadata["signature_counts"] = state.fixtures.signature_counts.Copy()
	plan.metadata["style_score"] = state.validation.style_score
	plan.metadata["category_coverage_score"] = state.validation.category_coverage_score
	plan.metadata["repeat_index"] = state.validation.repeat_index
	plan.metadata["privacy_violation_count"] = state.validation.privacy_violation_count
	plan.metadata["reachability_failure_count"] = state.validation.reachability_failure_count
	plan.metadata["repetition_conflict_count"] = state.validation.repetition_conflict_count
	plan.metadata["fixture_density_score"] = state.validation.fixture_density_score
	plan.metadata["connectivity_score"] = state.validation.connectivity_score
	plan.metadata["visibility_privacy_score"] = state.validation.visibility_privacy_score
	plan.metadata["space_distribution_score"] = state.validation.space_distribution_score
	plan.metadata["door_buffer_conflict_count"] = state.validation.door_buffer_conflict_count
	plan.metadata["window_conflict_count"] = state.validation.window_conflict_count
	plan.metadata["facade_conflict_count"] = state.validation.facade_conflict_count
	plan.metadata["invalid_window_count"] = state.validation.invalid_window_count
	plan.metadata["service_wall_window_violation_count"] = state.validation.service_wall_window_violation_count
	plan.metadata["secure_wall_window_violation_count"] = state.validation.secure_wall_window_violation_count
	plan.metadata["fixture_conflict_count"] = state.validation.fixture_conflict_count
	plan.metadata["route_conflict_count"] = state.validation.route_conflict_count
	plan.metadata["fixture_category_budgets"] = state.fixtures.category_budgets.Copy()
	plan.metadata["zone_count"] = length(state.geometry.zone_turfs)
	plan.metadata["anchor_count"] = length(state.fixtures.anchor_turfs)
	plan.metadata["anchor_type_counts"] = build_building_anchor_type_counts(state)
	plan.metadata["microvariation_anchor_counts"] = build_building_anchor_type_counts(state, "microvariation_")
	plan.metadata["microvariation_anchor_count"] = count_building_anchor_turfs(state, "microvariation_")
	plan.metadata["microvariation_count"] = state.validation.microvariation_count
	plan.metadata["template_chunk_count"] = state.fixtures.template_chunk_count
	plan.metadata["template_chunk_cell_count"] = state.fixtures.template_chunk_cell_count
	plan.metadata["module_instance_count"] = state.fixtures.module_instance_count
	plan.metadata["module_counts"] = state.fixtures.module_counts.Copy()
	plan.metadata["unique_provider_path_count"] = state.validation.unique_provider_path_count
	plan.metadata["unique_functional_provider_path_count"] = state.validation.unique_functional_provider_path_count
	plan.metadata["unique_decorative_provider_path_count"] = state.validation.unique_decorative_provider_path_count
	plan.metadata["infrastructure_count"] = state.fixtures.infrastructure_count
	plan.metadata["degraded_region_fallback_count"] = state.validation.degraded_region_fallback_count
	plan.metadata["degraded_region_reports"] = detailed_reports ? state.validation.degraded_region_reports.Copy() : list()
	plan.metadata["layout_macros"] = state.fixtures.layout_macros.Copy()
	plan.metadata["layout_macro_counts"] = state.fixtures.layout_macro_counts.Copy()
	plan.metadata["layout_macro_count"] = length(state.fixtures.layout_macros)
	plan.metadata["semantic_region_count"] = length(state.geometry.solved_regions)
	plan.metadata["room_count"] = length(state.geometry.solved_rooms)
	plan.metadata["target_room_count"] = state.config["target_room_count"] || state.validation.requested_room_count
	plan.metadata["room_count_divider_count"] = effective_room_count_divider_count
	plan.metadata["room_count_satisfied"] = !target_room_count || length(state.geometry.solved_rooms) >= target_room_count
	plan.metadata["room_count_gap"] = max(0, target_room_count - length(state.geometry.solved_rooms))
	plan.metadata["corridor_turf_count"] = length(state.geometry.corridor_turfs)
	plan.metadata["primary_route_count"] = length(state.geometry.primary_route_turfs)
	plan.metadata["internal_wall_count"] = length(state.geometry.internal_wall_turfs)
	plan.metadata["partition_segment_count"] = length(active_layout_context?.selected_candidate?.partition_segments)
	plan.metadata["usable_fixture_area"] = state.fixtures.usable_fixture_area
	plan.metadata["patterned_layout"] = TRUE
	plan.metadata["layout_contract"] = "semantic_region_solver"
	var/list/post_emit_report = validate_building_plan_post_emit(plan, state)
	plan.metadata["post_emit_validation_report"] = post_emit_report
	plan.metadata["post_emit_validation_error_count"] = state.validation.post_emit_validation_error_count
	plan.metadata["emit_missing_path_count"] = state.validation.emit_missing_path_count
	plan.metadata["emit_failed_object_count"] = state.validation.emit_failed_object_count
	plan.metadata["emit_state_mismatch_count"] = state.validation.emit_state_mismatch_count
	plan.metadata["semantic_credit_without_emitted_slots_count"] = state.validation.semantic_credit_without_emitted_slots_count
	plan.metadata["hard_counters"] = build_building_state_hard_counter_report(state)
	for(var/counter_name as anything in plan.metadata["hard_counters"])
		plan.metadata["[counter_name]"] = plan.metadata["hard_counters"][counter_name]
	plan.metadata["layout_unassigned_interior_turf_count"] = state.validation.layout_unassigned_interior_turf_count
	plan.metadata["layout_unassigned_interior_ratio_percent"] = state.validation.layout_unassigned_interior_ratio_percent
	plan.metadata["layout_route_component_count"] = state.validation.layout_route_component_count
	plan.metadata["layout_public_room_hard_closed_count"] = state.validation.layout_public_room_hard_closed_count
	plan.metadata["layout_public_opening_missing_count"] = state.validation.layout_public_opening_missing_count
	plan.metadata["layout_opposing_route_door_pair_count"] = state.validation.layout_opposing_route_door_pair_count
	plan.metadata["layout_corridor_wall_canyon_count"] = state.validation.layout_corridor_wall_canyon_count
	plan.metadata["layout_route_wall_canyon_length"] = state.validation.layout_route_wall_canyon_length
	plan.metadata["layout_excessive_wall_to_floor_ratio_count"] = state.validation.layout_excessive_wall_to_floor_ratio_count
	plan.metadata["layout_template_geometry_reject_count"] = state.validation.layout_template_geometry_reject_count
	plan.metadata["layout_missing_wall_context_reject_count"] = state.validation.layout_missing_wall_context_reject_count
	plan.metadata["layout_hard_valid_candidate_shortage_count"] = state.validation.layout_hard_valid_candidate_shortage_count
	var/datum/world_edit_validation_verdict/generation_verdict = build_building_generation_validation_verdict(state)
	plan.metadata["generation_validation_verdict"] = generation_verdict.as_payload()
	plan.metadata["validation_verdict"] = plan.metadata["generation_validation_verdict"]
	plan.metadata["debug_stage_separation_report"] = detailed_reports ? list(
		"planned_rooms" = list(
			"mandatory_room_count" = state.validation.mandatory_room_count,
			"mandatory_zone_count" = state.validation.mandatory_zone_count,
			"semantic_zone_count" = length(state.semantic_plan?.zone_specs),
		),
		"solved_rooms" = list(
			"room_count" = length(state.geometry.solved_rooms),
			"zone_count" = length(state.geometry.zone_turfs),
			"room_reports" = state.validation.room_reports.Copy(),
		),
		"emitted_or_reserved_rooms" = list(
			"floor_count" = length(state.geometry.floor_turfs),
			"reservation_count" = length(state.fixtures.semantic_slot_reservation_by_turf),
			"primary_route_count" = length(state.geometry.primary_route_turfs),
		),
		"planned_patterns" = state.fixtures.semantic_requirement_minimums.Copy(),
		"placed_patterns" = state.fixtures.placed_requirement_counts.Copy(),
		"validator_credited_patterns" = state.fixtures.semantic_requirement_counts.Copy(),
		"planned_objects" = list(
			"semantic_slot_capacity_count" = state.validation.semantic_slot_capacity_count,
			"pattern_report_count" = length(state.validation.pattern_reports),
		),
		"reserved_objects" = list(
			"semantic_slot_reservation_count" = length(state.fixtures.semantic_slot_reservation_by_turf),
			"semantic_slot_reservation_conflict_count" = state.validation.semantic_slot_reservation_conflict_count,
		),
		"emitted_objects" = list(
			"placement_count" = length(plan.placements),
			"interior_object_count" = length(state.fixtures.object_placements),
			"emit_missing_path_count" = state.validation.emit_missing_path_count,
			"emit_failed_object_count" = state.validation.emit_failed_object_count,
			"emit_state_mismatch_count" = state.validation.emit_state_mismatch_count,
		),
		"planned_route" = list(
			"primary_route_count" = length(state.geometry.primary_route_turfs),
			"door_count" = length(state.geometry.door_turfs),
			"door_cone_blocked_count" = state.validation.door_cone_blocked_count,
		),
		"emitted_walkable_route" = list(
			"post_emit_status" = post_emit_report["status"],
			"route_blocking_count" = post_emit_report["route_blocking_count"],
			"route_unreachable_count" = post_emit_report["route_unreachable_count"],
			"door_cone_blocking_count" = post_emit_report["door_cone_blocking_count"],
		),
	) : list("omitted" = TRUE, "enable" = "debug_reports")
	if(state.has_errors())
		plan.metadata["error"] = format_building_messages(state.validation.errors)
		plan.metadata["errors"] = state.validation.errors.Copy()
	finalize_shared_placement_plan_metadata(plan, shape_contract, placement_context)
	return plan
