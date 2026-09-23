/datum/unit_test/world_edit_building_layout/proc/get_test_anchor_turf()
	var/min_x = min(13, world.maxx)
	var/min_y = min(13, world.maxy)
	var/max_x = max(min_x, world.maxx - 12)
	var/max_y = max(min_y, world.maxy - 12)
	var/turf/center_turf = locate(clamp(round(world.maxx / 2), min_x, max_x), clamp(round(world.maxy / 2), min_y, max_y), 1)
	if(istype(center_turf))
		return center_turf
	for(var/turf/test_turf in block(locate(min_x, min_y, 1), locate(max_x, max_y, 1)))
		if(istype(test_turf))
			return test_turf
	return null

/datum/unit_test/world_edit_building_layout/proc/prepare_building_test_canvas(turf/anchor_turf, radius = 12)
	TEST_ASSERT_NOTNULL(anchor_turf, "Missing test anchor turf.")
	var/min_x = max(anchor_turf.x - radius, 1)
	var/max_x = min(anchor_turf.x + radius, world.maxx)
	var/min_y = max(anchor_turf.y - radius, 1)
	var/max_y = min(anchor_turf.y + radius, world.maxy)
	for(var/y in min_y to max_y)
		for(var/x in min_x to max_x)
			var/turf/target_turf = locate(x, y, anchor_turf.z)
			if(!istype(target_turf))
				continue
			for(var/obj/target_object as anything in target_turf)
				if(istype(target_object, /obj/effect/landmark))
					continue
				qdel(target_object)
			if(!istype(target_turf, /turf/open))
				target_turf.ChangeTurf(/turf/open/floor/plating)

/datum/unit_test/world_edit_building_layout/Run()
	return

/datum/unit_test/world_edit_building_layout/proc/build_point_shape_contract(turf/anchor_turf)
	var/datum/world_edit_shape_contract/shape_contract = new
	shape_contract.shape_id = WORLD_EDIT_SHAPE_POINT
	shape_contract.shape_label = "Point"
	shape_contract.interaction_kind = "single"
	shape_contract.preview_kind = "shape"
	shape_contract.anchor_turfs = list(anchor_turf)
	shape_contract.metadata = list(
		"anchor_count" = 1,
		"final_turfs" = list(anchor_turf),
	)
	shape_contract.raw_result = list(
		"shape_id" = WORLD_EDIT_SHAPE_POINT,
		"turfs" = list(anchor_turf),
		"metadata" = shape_contract.metadata.Copy(),
	)
	return shape_contract

/datum/unit_test/world_edit_building_layout/proc/build_point_context(datum/world_edit_shape_contract/shape_contract, turf/anchor_turf, direction = NORTH)
	var/list/shape_metadata = istype(shape_contract) ? shape_contract.copy_metadata() : list()
	var/list/anchor_turfs = istype(shape_contract) ? shape_contract.copy_anchor_turfs() : list()
	if(!length(anchor_turfs))
		anchor_turfs += anchor_turf
	return list(
		"mode" = "single",
		"shape" = WORLD_EDIT_SHAPE_POINT,
		"shape_contract" = shape_contract,
		"shape_metadata" = shape_metadata,
		"anchor_turfs" = anchor_turfs,
		"start_turf" = anchor_turf,
		"end_turf" = anchor_turf,
		"shape_origin_turf" = anchor_turf,
		"seed_turf" = anchor_turf,
		"requested_end_turf" = anchor_turf,
		"resolved_end_turf" = anchor_turf,
		"direction" = direction,
	)

/datum/unit_test/world_edit_building_layout/proc/build_living_point_state(list/params)
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Building layout test could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf)
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_shape_contract/shape_contract = build_point_shape_contract(anchor_turf)
	var/list/placement_context = build_point_context(shape_contract, anchor_turf)
	var/datum/world_edit_building_request/base_request = generator.build_building_request(islist(params) ? params : list(), shape_contract, placement_context)
	var/datum/world_edit_building_request/candidate_request = generator.build_building_candidate_request(base_request, "RECT", 1)
	return generator.build_building_layout_candidate_state(candidate_request, shape_contract, islist(params) ? params : list(), placement_context)

/datum/unit_test/world_edit_building_layout/proc/build_living_point_plan(list/params, direction = NORTH)
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Building layout test could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf)
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_shape_contract/shape_contract = build_point_shape_contract(anchor_turf)
	return generator.build_plan_from_shape_contract(null, shape_contract, islist(params) ? params : list(), build_point_context(shape_contract, anchor_turf, direction))

/datum/unit_test/world_edit_building_layout/proc/get_plan_placement_turf(list/placement)
	if(!islist(placement))
		return null
	var/turf/placement_turf = placement["turf"]
	if(istype(placement_turf))
		return placement_turf
	var/x = round(text2num("[placement["x"]]") || 0)
	var/y = round(text2num("[placement["y"]]") || 0)
	var/z = round(text2num("[placement["z"]]") || 0)
	return locate(x, y, z)

/datum/unit_test/world_edit_building_layout/proc/has_error_containing(datum/world_edit_building_layout_state/state, needle)
	for(var/error_text as anything in state.validation.errors)
		if(findtext("[error_text]", "[needle]"))
			return TRUE
	return FALSE

/datum/unit_test/world_edit_building_layout/proc/build_family_policy_test_context(turf/anchor_turf)
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_state/state = new
	state.placement_dir = NORTH
	state.geometry.bounds = list(
		"min_x" = anchor_turf.x - 7,
		"max_x" = anchor_turf.x + 7,
		"min_y" = anchor_turf.y - 7,
		"max_y" = anchor_turf.y + 7,
		"width" = 15,
		"height" = 15,
		"z" = anchor_turf.z,
	)
	var/datum/world_edit_building_layout_program_contract/program = new
	program.topology_graph = new
	var/datum/world_edit_building_layout_context/context = new(generator, state, program)
	for(var/local_x in 1 to 15)
		for(var/local_y in 1 to 15)
			var/turf/check_turf = context.local_turf(local_x, local_y)
			if(!istype(check_turf))
				continue
			if(local_x == 1 || local_x == 15 || local_y == 1 || local_y == 15)
				state.geometry.boundary_lookup[check_turf] = TRUE
			else
				state.geometry.interior += check_turf
	return context

/datum/unit_test/world_edit_building_layout/proc/add_family_policy_test_room(datum/world_edit_building_layout_context/context, datum/world_edit_building_layout_candidate/candidate, room_id, role, privacy_class, spatial_kind, local_x1, local_y1, local_x2, local_y2, parent_id = "", graph_depth = 0)
	var/datum/world_edit_building_layout_room_contract/room_contract = new(room_id, role, room_id)
	room_contract.privacy_class = "[privacy_class]"
	room_contract.spatial_kind = "[spatial_kind]"
	context.program_contract.add_room_contract(room_contract)
	var/datum/world_edit_building_layout_topology_node/node = new(room_contract)
	node.parent_id = "[parent_id]"
	node.depth = graph_depth
	context.program_contract.topology_graph.add_node(node)
	var/datum/world_edit_building_layout_room_plan/room_plan = context.generator.add_building_layout_room_rect(context, candidate, room_id, room_id, role, room_id, local_x1, local_y1, local_x2, local_y2)
	room_plan.spatial_kind = "[spatial_kind]"
	room_plan.topology_parent = "[parent_id]"
	room_plan.graph_depth = graph_depth
	return room_plan

/datum/unit_test/world_edit_building_layout/proc/assert_living_template_plan_contract(datum/world_edit_plan/plan)
	TEST_ASSERT_NOTNULL(plan, "Living template contract did not return a plan.")
	TEST_ASSERT(!plan.metadata["error"], "Living template contract failed: [plan.metadata["error"]]")
	TEST_ASSERT(round(text2num("[plan.metadata["module_instance_count"]]") || 0) > 0, "Living layout did not place any semantic furnishing modules.")
	var/list/reject_counts = plan.metadata["template_reject_reason_counts"]
	var/template_not_found = islist(reject_counts) ? (reject_counts["template_chunk_not_found"] || 0) : 0
	TEST_ASSERT_EQUAL(template_not_found, 0, "Living layout reported missing template chunks.")
	TEST_ASSERT_EQUAL(plan.metadata["mandatory_pattern_failure_count"] || 0, 0, "Living layout left mandatory patterns unsatisfied.")
	TEST_ASSERT_EQUAL(plan.metadata["forbidden_fallback_count"] || 0, 0, "Living layout used forbidden required-cluster fallback.")
	TEST_ASSERT_EQUAL(plan.metadata["fallback_anchor_required_cluster_count"] || 0, 0, "Living layout used required-cluster fallback anchors.")

/datum/unit_test/world_edit_building_layout/proc/living_plan_has_slot(datum/world_edit_plan/plan, slot_id, category_id = null)
	if(!istype(plan))
		return FALSE
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement) || "[placement["kind"]]" != "interior")
			continue
		var/slot = "[placement["requested_slot"] || placement["slot"]]"
		var/category = "[placement["category"]]"
		if(slot != "[slot_id]")
			continue
		if(!isnull(category_id) && category != "[category_id]")
			continue
		return TRUE
	return FALSE

/datum/unit_test/world_edit_building_layout/living_template_resolution_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("bed_niche_chunk"), "bed_niche_chunk", "Direct sleep template chunk did not resolve.")
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("micro_bed_chunk"), "bed_niche_chunk", "Micro bed template did not resolve to the living sleep chunk.")
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("island_bed_chunk"), "bed_niche_chunk", "Island bed template did not resolve to the living sleep chunk.")
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("cabinet_run_chunk"), "cabinet_run_chunk", "Direct storage template chunk did not resolve.")

/datum/unit_test/world_edit_building_layout/capability_provider_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_object_provider_registry/registry = generator.get_building_object_provider_registry()
	TEST_ASSERT_EQUAL(length(registry.audit()), 0, "Building object provider registry reported audit errors.")
	TEST_ASSERT(length(registry.providers_by_id) >= 50, "Building object provider registry did not expose at least 50 verified providers.")
	TEST_ASSERT(registry.unique_provider_path_count >= 40, "Building object provider registry did not expose enough unique provider paths.")
	TEST_ASSERT(registry.unique_functional_provider_path_count >= 35, "Building object provider registry did not expose enough unique functional provider paths.")
	TEST_ASSERT(registry.unique_decorative_provider_path_count >= 1, "Building object provider registry did not track decorative-only providers.")
	TEST_ASSERT_EQUAL(registry.provider_path_not_in_build_count, 0, "Building object provider registry has unresolved provider paths.")
	TEST_ASSERT(length(registry.get_all_for_style_slot("colony", "bed")) >= 1, "Building object provider registry did not expose style-slot provider alternatives.")
	var/list/colony_config = generator.normalize_building_params(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
	))
	TEST_ASSERT(!colony_config["error"], "Colony living style should have functional providers: [colony_config["error"]].")
	var/list/colony_providers = colony_config["fixture_providers_by_slot"]
	var/datum/world_edit_building_fixture_provider/colony_bed_provider = islist(colony_providers) ? colony_providers["bed"] : null
	TEST_ASSERT(istype(colony_bed_provider), "Colony living style did not build a bed provider.")
	TEST_ASSERT(generator.building_fixture_provider_satisfies_slot(colony_bed_provider, "bed"), "Colony bed provider did not satisfy sleep_surface capability.")

	var/list/covenant_config = generator.normalize_building_params(list(
		"archetype_id" = "living",
		"faction_preset" = "covenant",
	))
	TEST_ASSERT(covenant_config["error"], "Covenant living style should be locked without functional living providers.")
	TEST_ASSERT_EQUAL(covenant_config["error_code"], "style.missing_capability", "Covenant living style should fail with style.missing_capability.")
	var/list/covenant_providers = covenant_config["fixture_providers_by_slot"]
	var/datum/world_edit_building_fixture_provider/covenant_bed_provider = islist(covenant_providers) ? covenant_providers["bed"] : null
	TEST_ASSERT(istype(covenant_bed_provider), "Covenant living style did not expose the rejected bed provider for diagnostics.")
	TEST_ASSERT(covenant_bed_provider.decorative_only, "Covenant barricade/recharger providers must remain decorative_only without proven functional capability.")
	TEST_ASSERT(!generator.building_fixture_provider_satisfies_slot(covenant_bed_provider, "bed"), "Covenant decorative bed provider should not satisfy sleep_surface capability.")

/datum/unit_test/world_edit_building_layout/placement_module_catalog_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_placement_module_catalog/catalog = generator.get_building_placement_module_catalog()
	TEST_ASSERT(length(catalog.modules_by_id) >= 100, "Building placement module catalog did not expose at least 100 modules.")
	TEST_ASSERT(catalog.curated_module_count >= 100, "Building placement module catalog did not expose at least 100 curated authored modules.")
	var/list/archetypes = generator.get_building_archetype_catalog()
	var/datum/world_edit_building_archetype/living_archetype = archetypes["living"]
	var/datum/world_edit_building_cluster_spec/dining_cluster = generator.find_building_cluster_spec_by_id(living_archetype, "dining_pair")
	var/list/dining_modules = catalog.get_for_cluster(dining_cluster)
	var/datum/world_edit_building_placement_module/first_dining_module = length(dining_modules) ? dining_modules[1] : null
	TEST_ASSERT(istype(first_dining_module) && first_dining_module.curated, "Curated placement modules must be preferred before generated cluster fallback modules.")
	for(var/module_id as anything in catalog.modules_by_id)
		var/datum/world_edit_building_placement_module/module = catalog.modules_by_id[module_id]
		TEST_ASSERT(istype(module), "Placement module [module_id] is not a module datum.")
		TEST_ASSERT(length(module.allowed_programs), "Placement module [module_id] has no allowed programs.")
		TEST_ASSERT(length(module.allowed_zone_ids) || length(module.allowed_room_roles), "Placement module [module_id] has no zone or role constraints.")
		TEST_ASSERT(length(module.occupied_offsets), "Placement module [module_id] has no occupied cells.")
		TEST_ASSERT(length(generator.get_building_module_clearance_offsets(module)), "Placement module [module_id] has no authored front, interaction, aisle, or forbidden clearance cells.")
		TEST_ASSERT(length(module.front_access_offsets) || length(module.interaction_offsets) || length(module.aisle_offsets) || length(module.forbidden_offsets), "Placement module [module_id] did not preserve a typed clearance mask.")
		TEST_ASSERT(length(module.repeat_group), "Placement module [module_id] has no repeat group.")
		TEST_ASSERT(module.max_per_room > 0, "Placement module [module_id] has invalid max_per_room.")
		TEST_ASSERT(module.max_per_building > 0, "Placement module [module_id] has invalid max_per_building.")
		TEST_ASSERT(module.max_repeat_group_per_room > 0, "Placement module [module_id] has invalid max_repeat_group_per_room.")

/datum/unit_test/world_edit_building_layout/capability_matrix_payload_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/list/payload = generator.get_ui_payload(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
	))
	var/list/building_payload = payload["building_layout"]
	TEST_ASSERT(islist(building_payload), "Building layout UI payload did not include building_layout data.")
	var/list/matrix = building_payload["capability_matrix"]
	TEST_ASSERT(islist(matrix), "Building layout UI payload did not include a capability matrix.")
	var/list/programs = matrix["programs"]
	var/list/styles = matrix["styles"]
	var/list/compatibility = matrix["compatibility"]
	TEST_ASSERT(islist(programs) && islist(programs["living"]), "Capability matrix did not include the living program.")
	TEST_ASSERT(islist(styles) && islist(styles["colony"]), "Capability matrix did not include the colony style.")
	var/list/colony_style = styles["colony"]
	var/list/colony_capabilities = colony_style["capabilities"]
	TEST_ASSERT(islist(colony_capabilities) && ("sleep_surface" in colony_capabilities), "Colony style payload did not advertise sleep_surface capability.")
	var/list/by_key = compatibility["by_key"]
	TEST_ASSERT(islist(by_key), "Capability matrix did not include keyed program/style rows.")
	var/list/colony_living = by_key["living|colony"]
	var/list/covenant_living = by_key["living|covenant"]
	TEST_ASSERT(islist(colony_living) && colony_living["supported"], "Capability matrix should mark living|colony as supported.")
	TEST_ASSERT(islist(covenant_living) && !covenant_living["supported"], "Capability matrix should mark living|covenant as unsupported.")
	TEST_ASSERT_EQUAL(covenant_living["lock_code"], "style.missing_capability", "Capability matrix should lock Covenant living with style.missing_capability.")
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("micro_cabinet_chunk"), "cabinet_run_chunk", "Micro cabinet template did not resolve to the storage chunk.")
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("wall_toilet_chunk"), "sanitation_combined_chunk", "Sanitation wall object did not resolve to the sanitation chunk.")
	TEST_ASSERT_EQUAL(generator.resolve_existing_building_template_chunk_id("missing_living_contract_chunk"), "", "Unknown chunks must not resolve through a generic fallback.")

	var/datum/world_edit_plan/plan = build_living_point_plan(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"building_seed" = 13,
		"detail_budget" = 80,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	))
	assert_living_template_plan_contract(plan)
	TEST_ASSERT(living_plan_has_slot(plan, "bed", "sleeping_bed"), "Living template contract did not emit a bed.")
	TEST_ASSERT(living_plan_has_slot(plan, "table", "table"), "Living template contract did not emit a table.")
	TEST_ASSERT(living_plan_has_slot(plan, "toilet", "sanitation"), "Living template contract did not emit a toilet.")

/datum/unit_test/world_edit_building_layout/public_ui_field_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/list/fields = generator.get_ui_fields(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
	))
	var/list/allowed_ids = list("archetype_id", "faction_preset", "building_seed", "size_profile")
	var/list/seen_ids = list()
	for(var/list/field as anything in fields)
		var/field_id = "[field["id"]]"
		TEST_ASSERT(field_id in allowed_ids, "Building layout public UI exposed unexpected field '[field_id]'.")
		TEST_ASSERT(!(field_id in seen_ids), "Building layout public UI exposed duplicate field '[field_id]'.")
		seen_ids += field_id
	for(var/required_id as anything in allowed_ids)
		TEST_ASSERT(required_id in seen_ids, "Building layout public UI did not expose required field '[required_id]'.")
	var/list/forbidden_ids = list("auto_size", "half_width", "half_depth", "target_room_count", "window_density", "detail_budget", "back_exit", "respect_blockers", "replace_blocked_turfs", "confirm_large_replacement")
	for(var/forbidden_id as anything in forbidden_ids)
		TEST_ASSERT(!(forbidden_id in seen_ids), "Building layout public UI still exposes internal solver field '[forbidden_id]'.")

/datum/unit_test/world_edit_building_layout/visual_canvas_origin_lifecycle/Run()
	var/obj/effect/landmark/world_edit_visual_canvas_origin/original_origin = GLOB.world_edit_visual_canvas_origin
	TEST_ASSERT(istype(original_origin), "The compiled visual canvas origin must be registered before World Edit tests run.")

	var/turf/anchor_turf = get_test_anchor_turf()
	var/obj/effect/landmark/world_edit_visual_canvas_origin/duplicate_origin = new(anchor_turf)
	TEST_ASSERT_EQUAL(GLOB.world_edit_visual_canvas_origin, original_origin, "A duplicate canvas landmark must not replace the compiled-map origin.")
	qdel(duplicate_origin, force = TRUE)
	TEST_ASSERT_EQUAL(GLOB.world_edit_visual_canvas_origin, original_origin, "Deleting a duplicate canvas landmark must preserve the compiled-map origin.")

	GLOB.world_edit_visual_canvas_origin = null
	var/obj/effect/landmark/world_edit_visual_canvas_origin/temporary_owner = new(anchor_turf)
	TEST_ASSERT_EQUAL(GLOB.world_edit_visual_canvas_origin, temporary_owner, "A canvas landmark must register when no live owner exists.")
	qdel(temporary_owner, force = TRUE)
	TEST_ASSERT(isnull(GLOB.world_edit_visual_canvas_origin), "Deleting the registered canvas landmark must clear its global reference.")
	GLOB.world_edit_visual_canvas_origin = original_origin

/datum/unit_test/world_edit_building_layout/default_living_preview/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/list/config = generator.normalize_building_params(list())
	TEST_ASSERT_EQUAL(config["archetype_id"], "living", "Default building layout program should be living.")
	TEST_ASSERT_EQUAL(config["faction_preset"], "colony", "Default building layout shell should be colony.")
	TEST_ASSERT(config["auto_size"], "Default building layout should use auto_size.")

	var/datum/world_edit_plan/plan = build_living_point_plan(list())
	TEST_ASSERT_NOTNULL(plan, "Default living preview did not return a plan.")
	TEST_ASSERT(!plan.metadata["error"], "[plan.metadata["error"]]")
	var/list/support_report = plan.metadata["support_status_report"]
	TEST_ASSERT(islist(support_report), "Default living preview did not include support diagnostics.")
	var/list/support_verdict = support_report["verdict"]
	TEST_ASSERT(islist(support_verdict), "Default living preview support diagnostics did not include a validation verdict.")
	TEST_ASSERT_EQUAL(support_verdict["status"], "supported", "Default living preview support verdict returned the wrong status.")
	TEST_ASSERT_EQUAL(support_report["feasibility_dry_solve_status"], "solved", "Default living preview support did not run a solved feasibility dry solve.")
	TEST_ASSERT(round(text2num("[support_report["feasibility_dry_solve_attempt_count"]]") || 0) > 0, "Default living preview dry solve did not attempt any candidates.")
	TEST_ASSERT(round(text2num("[support_report["feasibility_dry_solve_valid_candidate_count"]]") || 0) > 0, "Default living preview dry solve did not prove a valid candidate.")
	var/list/hard_errors = support_verdict["hard_errors"]
	TEST_ASSERT_EQUAL(length(hard_errors), 0, "Default living preview support verdict should not contain hard errors.")
	var/list/generation_verdict = plan.metadata["generation_validation_verdict"]
	TEST_ASSERT(islist(generation_verdict), "Default living preview did not include a generation validation verdict.")
	TEST_ASSERT_EQUAL(generation_verdict["status"], "valid_plan", "Default living preview generation verdict returned the wrong status.")
	TEST_ASSERT_EQUAL(generation_verdict["stage"], "candidate_validation", "Default living preview generation verdict returned the wrong stage.")
	var/list/generation_hard_errors = generation_verdict["hard_errors"]
	TEST_ASSERT_EQUAL(length(generation_hard_errors), 0, "Default living preview generation verdict should not contain hard errors.")
	var/list/final_verdict = plan.metadata["validation_verdict"]
	TEST_ASSERT(islist(final_verdict), "Default living preview did not include a final validation verdict.")
	TEST_ASSERT_EQUAL(final_verdict["status"], "valid_plan", "Default living preview final verdict should come from generation validation.")
	TEST_ASSERT_EQUAL(plan.metadata["post_emit_validation_error_count"] || 0, 0, "Default living preview should pass post-emit validation.")
	TEST_ASSERT_EQUAL(plan.metadata["reachability_failure_count"] || 0, 0, "Default living preview should have no route-touch failures.")
	TEST_ASSERT_EQUAL(plan.metadata["door_corner_count"] || 0, 0, "Default living preview should not place an avoidable corner door.")
	TEST_ASSERT_EQUAL(plan.metadata["mandatory_room_missing_count"] || 0, 0, "Default living preview should not miss mandatory rooms.")
	TEST_ASSERT_EQUAL(plan.metadata["mandatory_room_no_access_count"] || 0, 0, "Default living preview should keep mandatory rooms reachable.")
	TEST_ASSERT(GLOB.world_edit_helpers.parse_bool(plan.metadata["layout_enabled"]), "Default living preview should use building layout.")
	TEST_ASSERT(round(text2num("[plan.metadata["layout_candidate_count"]]") || 0) >= 2, "Default living preview should prove at least two v2 layout candidates.")
	var/datum/world_edit_plan/replay_plan = build_living_point_plan(list())
	TEST_ASSERT_NOTNULL(replay_plan, "Default living replay preview did not return a plan.")
	TEST_ASSERT(!replay_plan.metadata["error"], "[replay_plan.metadata["error"]]")
	TEST_ASSERT_EQUAL("[plan.metadata["layout_hash"]]", "[replay_plan.metadata["layout_hash"]]", "Default living same-seed replay changed layout_hash.")
	TEST_ASSERT(length("[plan.metadata["structural_topology_signature"]]"), "Default living preview did not report structural_topology_signature.")
	TEST_ASSERT(length("[plan.metadata["geometry_layout_hash"]]"), "Default living preview did not report geometry_layout_hash.")
	TEST_ASSERT_EQUAL("[plan.metadata["structural_topology_signature"]]", "[replay_plan.metadata["structural_topology_signature"]]", "Default living same-seed replay changed structural_topology_signature.")
	TEST_ASSERT_EQUAL("[plan.metadata["geometry_layout_hash"]]", "[replay_plan.metadata["geometry_layout_hash"]]", "Default living same-seed replay changed geometry_layout_hash.")
	assert_living_template_plan_contract(plan)

/datum/unit_test/world_edit_building_layout/direction_matrix/Run()
	for(var/requested_dir as anything in list(NORTH, SOUTH, EAST, WEST))
		var/datum/world_edit_plan/plan = build_living_point_plan(list(
			"archetype_id" = "living",
			"faction_preset" = "colony",
			"building_seed" = 11,
			"detail_budget" = 40,
			"replace_blocked_turfs" = TRUE,
			"respect_blockers" = FALSE,
		), requested_dir)
		TEST_ASSERT_NOTNULL(plan, "Direction [requested_dir] did not create a plan.")
		TEST_ASSERT(!plan.metadata["error"], "Direction [requested_dir] failed: [plan.metadata["error"]]")
		TEST_ASSERT_EQUAL(round(text2num("[plan.metadata["requested_direction"]]") || 0), requested_dir, "Requested direction was not recorded.")
		TEST_ASSERT(GLOB.world_edit_helpers.parse_bool(plan.metadata["direction_honored"]), "Front door did not honor requested direction [requested_dir].")
		TEST_ASSERT_EQUAL(plan.metadata["post_emit_validation_error_count"] || 0, 0, "Direction [requested_dir] failed post-emit validation.")

/datum/unit_test/world_edit_building_layout/wall_fixture_direction_contract/Run()
	var/datum/world_edit_plan/plan = build_living_point_plan(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"building_seed" = 12,
		"detail_budget" = 60,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	))
	TEST_ASSERT_NOTNULL(plan, "Wall fixture contract plan was not created.")
	TEST_ASSERT(!plan.metadata["error"], "Wall fixture contract plan failed: [plan.metadata["error"]]")
	var/list/wall_lookup = list()
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement) || "[placement["kind"]]" != "wall")
			continue
		var/turf/wall_turf = get_plan_placement_turf(placement)
		if(istype(wall_turf))
			wall_lookup[wall_turf] = TRUE
	var/wall_fixture_count = 0
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement) || "[placement["kind"]]" != "interior" || !GLOB.world_edit_helpers.parse_bool(placement["wall_mounted"]))
			continue
		wall_fixture_count++
		var/turf/target_turf = get_plan_placement_turf(placement)
		var/wall_dir = round(text2num("[placement["wall_dir"]]") || 0)
		var/dir_to_use = round(text2num("[placement["dir"]]") || 0)
		var/dir_mode = round(text2num("[placement["dir_mode"]]") || 0)
		TEST_ASSERT(wall_dir in GLOB.cardinals, "Wall fixture [placement["slot"]] has invalid wall_dir.")
		TEST_ASSERT(wall_lookup[get_step(target_turf, wall_dir)], "Wall fixture [placement["slot"]] has no adjacent wall at wall_dir.")
		if(dir_mode == 1)
			TEST_ASSERT_EQUAL(dir_to_use, wall_dir, "Attached-wall fixture [placement["slot"]] does not face the attached wall.")
		if(dir_mode == 2)
			TEST_ASSERT_EQUAL(dir_to_use, turn(wall_dir, 180), "Front-face fixture [placement["slot"]] does not face away from the wall.")
		TEST_ASSERT(length("[placement["dir_source"]]"), "Wall fixture [placement["slot"]] did not record dir_source.")
	TEST_ASSERT(wall_fixture_count > 0, "No wall fixtures were emitted for the direction contract test.")

/datum/unit_test/world_edit_building_layout/living_semantic_object_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_plan/plan = null
	for(var/seed_value in 13 to 24)
		var/datum/world_edit_plan/candidate_plan = build_living_point_plan(list(
			"archetype_id" = "living",
			"faction_preset" = "colony",
			"building_seed" = seed_value,
			"detail_budget" = 70,
			"replace_blocked_turfs" = TRUE,
			"respect_blockers" = FALSE,
		))
		if(!istype(candidate_plan) || candidate_plan.metadata["error"])
			continue
		var/candidate_bed_seen = FALSE
		var/candidate_table_seen = FALSE
		var/candidate_toilet_seen = FALSE
		for(var/list/candidate_placement as anything in candidate_plan.placements)
			if(!islist(candidate_placement) || "[candidate_placement["kind"]]" != "interior")
				continue
			var/candidate_slot = "[candidate_placement["requested_slot"] || candidate_placement["slot"]]"
			var/candidate_category = "[candidate_placement["category"]]"
			if(candidate_slot == "bed")
				candidate_bed_seen = TRUE
			if(candidate_slot == "table" && candidate_category == "table")
				candidate_table_seen = TRUE
			if(candidate_slot == "toilet" || candidate_category == "sanitation")
				candidate_toilet_seen = TRUE
		if(candidate_bed_seen && candidate_table_seen && candidate_toilet_seen)
			plan = candidate_plan
			break
	TEST_ASSERT_NOTNULL(plan, "Living semantic object contract plan was not created.")
	TEST_ASSERT(!plan.metadata["error"], "Living semantic object contract failed: [plan.metadata["error"]]")
	var/bed_seen = FALSE
	var/table_seen = FALSE
	var/toilet_seen = FALSE
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement) || "[placement["kind"]]" != "interior")
			continue
		var/slot = "[placement["requested_slot"] || placement["slot"]]"
		var/category = "[placement["category"]]"
		var/zone_id = "[placement["zone_id"]]"
		var/requirement_id = "[placement["semantic_requirement_id"] || placement["requirement_id"]]"
		if(slot == "bed")
			bed_seen = TRUE
			TEST_ASSERT_EQUAL(zone_id, "sleep_privacy", "Bed was emitted outside sleep_privacy.")
		if(slot == "cabinet" && findtext(requirement_id, "sleep"))
			TEST_ASSERT_EQUAL(zone_id, "sleep_privacy", "Sleep cabinet was emitted outside sleep_privacy.")
		if(slot == "toilet" || category == "sanitation")
			toilet_seen = TRUE
			TEST_ASSERT_EQUAL(zone_id, "sanitation", "Sanitation fixture was emitted outside sanitation.")
		if(slot == "sink" && findtext(requirement_id, "sanitation"))
			TEST_ASSERT_EQUAL(zone_id, "sanitation", "Sanitation sink was emitted outside sanitation.")
		if(slot == "table" && category == "table")
			table_seen = TRUE
			TEST_ASSERT_EQUAL(zone_id, "common", "Living table was emitted outside common.")
		if(slot == "chair" && category == "chair" && findtext(requirement_id, "common"))
			TEST_ASSERT_EQUAL(zone_id, "common", "Living chair was emitted outside common.")
	TEST_ASSERT(bed_seen, "Living layout did not emit a bed.")
	TEST_ASSERT(table_seen, "Living layout did not emit a common table.")
	TEST_ASSERT(toilet_seen, "Living layout did not emit a sanitation fixture.")
	TEST_ASSERT_EQUAL(plan.metadata["loose_table_count"] || 0, 0, "Living layout emitted loose tables outside semantic modules.")
	TEST_ASSERT_EQUAL(plan.metadata["loose_chair_count"] || 0, 0, "Living layout emitted loose chairs outside semantic modules.")
	TEST_ASSERT_EQUAL(plan.metadata["table_chair_mosaic_count"] || 0, 0, "Living layout emitted table/chair mosaic furniture.")
	TEST_ASSERT(round(text2num("[plan.metadata["module_instance_count"]]") || 0) > 0, "Living layout did not emit semantic module instances.")
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement) || "[placement["kind"]]" != "interior")
			continue
		var/placement_slot = "[placement["requested_slot"] || placement["slot"]]"
		var/placement_category = "[placement["category"]]"
		if(generator.is_building_semantic_furniture_slot(placement_slot, placement_category))
			TEST_ASSERT(length("[placement["module_instance_id"] || ""]"), "Semantic furniture [placement_slot] was emitted without a module instance.")

/datum/unit_test/world_edit_building_layout/full_layout_no_required_fallback_credit/Run()
	var/datum/world_edit_plan/plan = build_living_point_plan(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"building_seed" = 14,
		"detail_budget" = 70,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	))
	TEST_ASSERT_NOTNULL(plan, "Full layout fallback-credit contract plan was not created.")
	TEST_ASSERT(!plan.metadata["error"], "Full layout fallback-credit contract failed: [plan.metadata["error"]]")
	var/degrade_level = "[plan.metadata["size_degrade_level"]]"
	if(!length(degrade_level))
		degrade_level = "none"
	TEST_ASSERT_EQUAL(degrade_level, "none", "Full layout unexpectedly degraded.")
	TEST_ASSERT_EQUAL(plan.metadata["fallback_anchor_required_cluster_count"] || 0, 0, "Full layout used required-cluster fallback anchors.")
	TEST_ASSERT_EQUAL(plan.metadata["raw_category_credit_count"] || 0, 0, "Full layout used raw category semantic credit.")
	TEST_ASSERT_EQUAL(plan.metadata["semantic_credit_without_emitted_slots_count"] || 0, 0, "Full layout credited semantic slots without emitted objects.")

/datum/unit_test/world_edit_building_layout/large_layout_uses_scene_hierarchy/Run()
	var/datum/world_edit_plan/plan = build_living_point_plan(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"auto_size" = FALSE,
		"half_width" = 8,
		"half_depth" = 8,
		"building_seed" = 73,
		"detail_budget" = 85,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	))
	TEST_ASSERT_NOTNULL(plan, "Large living layout plan was not created.")
	TEST_ASSERT(!plan.metadata["error"], "Large living layout failed: [plan.metadata["error"]]")
	TEST_ASSERT(round(text2num("[plan.metadata["layout_scene_count"]]") || 0) > 0, "Large layout did not emit canonical room scenes.")
	TEST_ASSERT_EQUAL(round(text2num("[plan.metadata["layout_empty_large_room_count"]]") || 0), 0, "Large layout retained an empty large room.")
	TEST_ASSERT_EQUAL(round(text2num("[plan.metadata["layout_underfurnished_room_count"]]") || 0), 0, "Large layout retained an underfurnished room.")
	TEST_ASSERT_EQUAL(plan.metadata["semantic_credit_without_emitted_slots_count"] || 0, 0, "Large layout credited semantic slots without emitted objects.")

/datum/unit_test/world_edit_building_layout/target_room_count_is_exact_semantic_contract/Run()
	var/list/base_params = list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"auto_size" = FALSE,
		"half_width" = 8,
		"half_depth" = 8,
		"building_seed" = 91,
		"detail_budget" = 75,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	)
	var/datum/world_edit_plan/base_plan = build_living_point_plan(base_params.Copy())
	TEST_ASSERT_NOTNULL(base_plan, "Base room-count layout plan was not created.")
	TEST_ASSERT(!base_plan.metadata["error"], "Base room-count layout failed: [base_plan.metadata["error"]]")
	var/base_room_count = round(text2num("[base_plan.metadata["room_count"]]") || 0)
	var/list/target_params = base_params.Copy()
	target_params["target_room_count"] = max(base_room_count + 1, 6)
	var/datum/world_edit_plan/target_plan = build_living_point_plan(target_params)
	TEST_ASSERT_NOTNULL(target_plan, "Target room-count layout plan was not created.")
	TEST_ASSERT(!target_plan.metadata["error"], "Target room-count layout failed: [target_plan.metadata["error"]]")
	TEST_ASSERT_EQUAL(round(text2num("[target_plan.metadata["room_count"]]") || 0), round(text2num("[target_params["target_room_count"]]") || 0), "Target room-count layout did not create the exact semantic room count.")
	TEST_ASSERT_EQUAL(round(text2num("[target_plan.metadata["room_count_divider_count"]]") || 0), 0, "Canonical target room count must not use arbitrary divider rooms.")
	TEST_ASSERT_EQUAL(round(text2num("[target_plan.metadata["room_count_gap"]]") || 0), 0, "Canonical target room count reported a nonzero room gap.")

/datum/unit_test/world_edit_building_layout/canonical_program_contract_matrix/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/list/program_ids = generator.get_building_archetype_ids()
	TEST_ASSERT_EQUAL(length(program_ids), 15, "Canonical building layout catalog must expose exactly 15 programs.")
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Program contract matrix could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf, 8)
	for(var/program_id as anything in program_ids)
		var/list/config = generator.normalize_building_params(list("archetype_id" = program_id, "target_room_count" = 0))
		var/removed_layout_switch_key = "use_layout" + "_v2"
		TEST_ASSERT(!(removed_layout_switch_key in config), "Removed layout switch leaked into normalized config for [program_id].")
		var/datum/world_edit_building_request/request = new
		request.config = config
		request.archetype = generator.get_building_archetype(program_id)
		var/datum/world_edit_building_layout_state/state = new
		state.config = config
		state.request = request
		state.archetype = request.archetype
		state.semantic_plan = request.archetype.build_semantic_plan(request)
		state.geometry.bounds = list("min_x" = anchor_turf.x - 7, "max_x" = anchor_turf.x + 7, "min_y" = anchor_turf.y - 7, "max_y" = anchor_turf.y + 7, "width" = 15, "height" = 15)
		for(var/turf/footprint_turf in block(locate(anchor_turf.x - 7, anchor_turf.y - 7, anchor_turf.z), locate(anchor_turf.x + 7, anchor_turf.y + 7, anchor_turf.z)))
			state.geometry.footprint += footprint_turf
			state.geometry.footprint_lookup[footprint_turf] = TRUE
		var/datum/world_edit_building_layout_program_contract/program = generator.build_building_layout_program_contract(state)
		TEST_ASSERT_NOTNULL(program, "Program contract did not compile for [program_id]: [jointext(state.validation.errors, "; ")]")
		TEST_ASSERT_EQUAL(program.id, "[program_id]", "Program contract id mismatch for [program_id].")
		TEST_ASSERT_EQUAL(length(program.functional_room_contracts), program.target_functional_room_count, "Program contract functional room count is not exact for [program_id].")
		for(var/datum/world_edit_building_layout_room_contract/circulation_contract as anything in program.circulation_contracts)
			TEST_ASSERT(!circulation_contract.counts_toward_target, "Circulation contract [circulation_contract.id] counts toward target for [program_id].")
		TEST_ASSERT(program.max_layout_candidates <= 24, "Program contract exceeded the 24 layout-candidate bound for [program_id].")

/datum/unit_test/world_edit_building_layout/route_side_run_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_room_contract/room_contract = new
	room_contract.route_opening_kind = "door"
	TEST_ASSERT_EQUAL(generator.building_layout_room_access_run_length(room_contract), 3, "Controlled doors must reserve a three-turf side run.")
	room_contract.route_opening_kind = "arch"
	TEST_ASSERT_EQUAL(generator.building_layout_room_access_run_length(room_contract), 2, "Public openings must reserve a two-turf side run.")
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Side-run contract could not resolve an anchor turf.")
	var/turf/east_turf = get_step(anchor_turf, EAST)
	var/turf/east_two_turf = get_step(east_turf, EAST)
	var/list/wall_run = list(anchor_turf, east_turf, east_two_turf)
	var/list/route_run = list(get_step(anchor_turf, SOUTH), get_step(east_turf, SOUTH), get_step(east_two_turf, SOUTH))
	var/datum/world_edit_building_layout_candidate/candidate = new
	TEST_ASSERT(candidate.reserve_route_access("controlled_room", wall_run, route_run, list()), "Valid controlled side-run reservation was rejected.")
	var/list/reservation = candidate.get_route_access_reservation("controlled_room")
	TEST_ASSERT_EQUAL(length(reservation["wall_run"]), 3, "Controlled reservation lost wall-run width.")
	TEST_ASSERT_EQUAL(length(reservation["route_run"]), 3, "Controlled reservation lost route-run width.")
	TEST_ASSERT(!candidate.reserve_route_access("bad_room", wall_run, route_run.Copy(1, 3), list()), "Mismatched wall/route side runs must be rejected.")

/datum/unit_test/world_edit_building_layout/standard_candidate_diversity_is_hard_contract/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_state/state = new
	state.config["layout_hard_valid_candidate_count"] = 2
	state.config["layout_distinct_hard_valid_family_count"] = 1
	generator.validate_building_layout_candidate_diversity(state)
	TEST_ASSERT_EQUAL(state.validation.layout_hard_valid_candidate_shortage_count, 1, "Standard layouts must reject two hard-valid candidates from only one topology family.")

/datum/unit_test/world_edit_building_layout/structural_signature_ignores_translation_and_family_label/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Structural-signature test could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf, 8)
	var/list/candidates = list()
	for(var/variant in 1 to 2)
		var/shift = variant == 1 ? 0 : 3
		var/datum/world_edit_building_layout_candidate/candidate = new
		candidate.topology_family = variant == 1 ? "hub_spoke" : "split_wing"
		candidate.topology_graph = new
		candidate.topology_graph.root_node_id = "root"
		var/datum/world_edit_building_layout_room_contract/root_contract = new("root", "hub", "root")
		var/datum/world_edit_building_layout_room_contract/child_contract = new("child", "service", "child")
		var/datum/world_edit_building_layout_topology_node/root_node = new(root_contract)
		var/datum/world_edit_building_layout_topology_node/child_node = new(child_contract)
		child_node.parent_id = "root"
		child_node.depth = 1
		candidate.topology_graph.add_node(root_node)
		candidate.topology_graph.add_node(child_node)
		candidate.topology_graph.add_edge(new /datum/world_edit_building_layout_topology_edge("root", "child", "shared", TRUE, "door", "direct"))
		var/datum/world_edit_building_layout_room_plan/root_plan = new("root", "root", "hub", "root")
		var/datum/world_edit_building_layout_room_plan/child_plan = new("child", "child", "service", "child")
		child_plan.topology_parent = "root"
		child_plan.graph_depth = 1
		for(var/turf/root_turf in block(locate(anchor_turf.x - 3 + shift, anchor_turf.y + shift, anchor_turf.z), locate(anchor_turf.x - 2 + shift, anchor_turf.y + 1 + shift, anchor_turf.z)))
			root_plan.add_turf(root_turf)
		for(var/turf/child_turf in block(locate(anchor_turf.x + 2 + shift, anchor_turf.y + shift, anchor_turf.z), locate(anchor_turf.x + 3 + shift, anchor_turf.y + 1 + shift, anchor_turf.z)))
			child_plan.add_turf(child_turf)
		candidate.add_room_plan(root_plan)
		candidate.add_room_plan(child_plan)
		for(var/route_offset in 0 to 1)
			var/turf/route_turf = locate(anchor_turf.x + shift, anchor_turf.y + route_offset + shift, anchor_turf.z)
			candidate.add_route_turf(route_turf)
			candidate.route_owner_by_turf[route_turf] = "public_circulation"
		candidates += candidate
	var/datum/world_edit_building_layout_candidate/first_candidate = candidates[1]
	var/datum/world_edit_building_layout_candidate/translated_candidate = candidates[2]
	var/first_signature = generator.build_building_layout_topology_signature(first_candidate)
	var/translated_signature = generator.build_building_layout_topology_signature(translated_candidate)
	TEST_ASSERT_EQUAL(first_signature, translated_signature, "Structural signature changed after pure translation or family relabeling.")
	var/datum/world_edit_building_layout_topology_edge/changed_edge = translated_candidate.topology_graph.edges[1]
	changed_edge.edge_kind = "secure"
	changed_edge.opening_policy = "secure_door"
	TEST_ASSERT(generator.build_building_layout_topology_signature(translated_candidate) != first_signature, "Structural signature ignored a typed edge semantic change.")

/datum/unit_test/world_edit_building_layout/topology_family_hard_invariant_matrix/Run()
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Topology-family matrix could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf, 10)
	var/datum/world_edit_building_layout_context/context
	var/datum/world_edit_building_layout_candidate/candidate
	var/datum/world_edit_building_layout_family_policy/policy

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "hub_spoke"
	candidate.topology_graph = context.program_contract.topology_graph
	var/datum/world_edit_building_layout_room_plan/hub_root = add_family_policy_test_room(context, candidate, "hub", "hub", "public", "functional_room", 7, 7, 9, 9)
	add_family_policy_test_room(context, candidate, "hub_west", "service", "semi_private", "functional_room", 2, 7, 4, 9, "hub", 1)
	add_family_policy_test_room(context, candidate, "hub_east", "service", "semi_private", "functional_room", 12, 7, 14, 9, "hub", 1)
	context.program_contract.topology_graph.root_node_id = hub_root.contract_id
	context.program_contract.topology_graph.add_edge(new /datum/world_edit_building_layout_topology_edge("hub", "hub_west"))
	context.program_contract.topology_graph.add_edge(new /datum/world_edit_building_layout_topology_edge("hub", "hub_east"))
	policy = new /datum/world_edit_building_layout_family_policy/hub_spoke
	TEST_ASSERT(policy.hard_validate(context, candidate), "Valid hub_spoke candidate failed its hard invariants: [jointext(candidate.errors, ",")]")
	context.program_contract.topology_graph.edges.Cut(2, 3)
	TEST_ASSERT(!policy.hard_validate(context, candidate), "hub_spoke accepted a root with fewer than two functional children.")

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "split_wing"
	candidate.topology_graph = context.program_contract.topology_graph
	var/datum/world_edit_building_layout_room_plan/split_root = add_family_policy_test_room(context, candidate, "transition", "hub", "public", "functional_room", 7, 7, 9, 9)
	var/datum/world_edit_building_layout_room_plan/split_west = add_family_policy_test_room(context, candidate, "wing_west", "service", "semi_private", "functional_room", 2, 7, 4, 9, "transition", 1)
	var/datum/world_edit_building_layout_room_plan/split_east = add_family_policy_test_room(context, candidate, "wing_east", "service", "semi_private", "functional_room", 12, 7, 14, 9, "transition", 1)
	context.program_contract.topology_graph.root_node_id = split_root.contract_id
	policy = new /datum/world_edit_building_layout_family_policy/split_wing
	TEST_ASSERT(policy.hard_validate(context, candidate), "Valid split_wing candidate failed its hard invariants: [jointext(candidate.errors, ",")]")
	split_east.x1 = split_west.x1
	split_east.x2 = split_west.x2
	TEST_ASSERT(!policy.hard_validate(context, candidate), "split_wing accepted an empty second wing.")

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "open_bay_perimeter"
	candidate.topology_graph = context.program_contract.topology_graph
	var/datum/world_edit_building_layout_room_plan/open_bay = add_family_policy_test_room(context, candidate, "open_bay", "hub", "public", "open_bay", 4, 4, 11, 11)
	add_family_policy_test_room(context, candidate, "bay_service", "service", "semi_private", "functional_room", 13, 6, 14, 8, "open_bay", 1)
	context.program_contract.topology_graph.root_node_id = open_bay.contract_id
	context.program_contract.topology_graph.add_edge(new /datum/world_edit_building_layout_topology_edge("open_bay", "bay_service", "shared", TRUE, "door"))
	var/turf/bay_route_turf = context.local_turf(12, 7)
	candidate.add_route_turf(bay_route_turf)
	policy = new /datum/world_edit_building_layout_family_policy/open_bay_perimeter
	TEST_ASSERT(policy.can_solve(context), "open_bay_perimeter rejected an explicit single OPEN_BAY contract.")
	TEST_ASSERT(policy.hard_validate(context, candidate), "Valid open_bay_perimeter candidate failed its hard invariants: [jointext(candidate.errors, ",")]")
	candidate.route_turfs = list()
	candidate.route_lookup = list()
	TEST_ASSERT(!policy.hard_validate(context, candidate), "open_bay_perimeter accepted an OPEN_BAY without an owner aisle.")

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "secure_core"
	candidate.topology_graph = context.program_contract.topology_graph
	var/datum/world_edit_building_layout_room_plan/secure_room = add_family_policy_test_room(context, candidate, "secure_room", "secure", "secure", "functional_room", 7, 7, 9, 9)
	var/datum/world_edit_building_layout_room_contract/choke_contract = new("secure_choke", "choke", "secure_choke")
	choke_contract.spatial_kind = "choke"
	choke_contract.counts_toward_target = FALSE
	context.program_contract.add_room_contract(choke_contract)
	context.program_contract.topology_graph.add_node(new /datum/world_edit_building_layout_topology_node(choke_contract))
	context.program_contract.topology_graph.root_node_id = secure_room.contract_id
	var/datum/world_edit_building_layout_topology_edge/secure_edge = new("secure_choke", "secure_room", "secure", TRUE, "secure_door")
	context.program_contract.topology_graph.add_edge(secure_edge)
	policy = new /datum/world_edit_building_layout_family_policy/secure_core
	TEST_ASSERT(policy.hard_validate(context, candidate), "Valid secure_core candidate failed its hard invariants: [jointext(candidate.errors, ",")]")
	secure_edge.opening_policy = "door"
	TEST_ASSERT(!policy.hard_validate(context, candidate), "secure_core accepted a non-secure controlled transition.")

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "nested_service"
	candidate.topology_graph = context.program_contract.topology_graph
	var/datum/world_edit_building_layout_room_plan/nested_parent = add_family_policy_test_room(context, candidate, "nested_parent", "hub", "public", "functional_room", 3, 3, 12, 12)
	var/datum/world_edit_building_layout_room_plan/nested_child = add_family_policy_test_room(context, candidate, "nested_child", "service", "semi_private", "nested_room", 5, 5, 7, 7, "nested_parent", 1)
	context.program_contract.topology_graph.root_node_id = nested_parent.contract_id
	context.program_contract.topology_graph.add_edge(new /datum/world_edit_building_layout_topology_edge("nested_parent", "nested_child", "nested", TRUE, "door"))
	candidate.add_door_plan(new /datum/world_edit_building_layout_route_opening_plan("nested_opening", "door", context.local_turf(4, 6), EAST, "nested_parent", "nested_child"))
	policy = new /datum/world_edit_building_layout_family_policy/nested_service
	TEST_ASSERT(policy.hard_validate(context, candidate), "Valid nested_service candidate failed its hard invariants: [jointext(candidate.errors, ",")]")
	nested_child.x1 = nested_parent.x1
	TEST_ASSERT(!policy.hard_validate(context, candidate), "nested_service accepted a child touching the parent boundary.")

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "compound_cells"
	candidate.topology_graph = context.program_contract.topology_graph
	add_family_policy_test_room(context, candidate, "pod_sw", "service", "public", "functional_room", 2, 10, 4, 13)
	add_family_policy_test_room(context, candidate, "pod_se", "service", "public", "functional_room", 11, 10, 13, 13)
	add_family_policy_test_room(context, candidate, "pod_nw", "service", "public", "functional_room", 2, 2, 4, 5)
	candidate.region_candidate = new("compound_cells", "compound_test")
	candidate.region_candidate.add_route_hint("compound_courtyard", "cross", 8, 8, 8, 8)
	candidate.add_route_turf(context.local_turf(8, 8))
	policy = new /datum/world_edit_building_layout_family_policy/compound_cells
	TEST_ASSERT(policy.hard_validate(context, candidate), "Valid compound_cells candidate failed its hard invariants: [jointext(candidate.errors, ",")]")
	candidate.region_candidate.route_hints = list()
	TEST_ASSERT(!policy.hard_validate(context, candidate), "compound_cells accepted a layout without the authored courtyard route hint.")

	context = build_family_policy_test_context(anchor_turf)
	candidate = new
	candidate.family_policy_id = "axial_fallback"
	candidate.topology_graph = context.program_contract.topology_graph
	add_family_policy_test_room(context, candidate, "axial_room", "service", "public", "functional_room", 2, 6, 4, 9)
	candidate.region_candidate = new("axial_fallback", "axial_test")
	candidate.region_candidate.add_route_hint("axial_route", "line", 8, 3, 8, 13)
	for(var/local_y in 4 to 10)
		candidate.add_route_turf(context.local_turf(8, local_y))
	policy = new /datum/world_edit_building_layout_family_policy/axial_fallback
	var/axial_valid = policy.hard_validate(context, candidate)
	TEST_ASSERT(axial_valid, "Valid axial_fallback candidate failed its hard invariants: [jointext(candidate.errors, ",")]; policy=[policy.id] candidate_policy=[candidate.family_policy_id] room_count=[length(candidate.room_plans)] route_count=[length(candidate.route_turfs)] hint_count=[length(candidate.region_candidate.route_hints)]")
	candidate.route_turfs = list()
	candidate.route_lookup = list()
	for(var/local_offset in 5 to 8)
		candidate.add_route_turf(context.local_turf(local_offset, local_offset))
	TEST_ASSERT(!policy.hard_validate(context, candidate), "axial_fallback accepted a route without a dominant axial trunk.")

/datum/unit_test/world_edit_building_layout/seeded_family_selection_preserves_quality_tier/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_state/state = new
	var/datum/world_edit_building_layout_context/context = new(generator, state, null)
	var/datum/world_edit_building_layout_candidate/best_hub = new
	best_hub.id = "hub_best"
	best_hub.pattern_id = "hub_spoke"
	best_hub.topology_family = "hub_spoke"
	best_hub.score = 1000
	var/datum/world_edit_building_layout_candidate/weaker_same_family = new
	weaker_same_family.id = "hub_weaker"
	weaker_same_family.pattern_id = "hub_spoke"
	weaker_same_family.topology_family = "hub_spoke"
	weaker_same_family.score = 990
	var/datum/world_edit_building_layout_candidate/eligible_split = new
	eligible_split.id = "split_best"
	eligible_split.pattern_id = "split_wing"
	eligible_split.topology_family = "split_wing"
	eligible_split.score = 930
	var/datum/world_edit_building_layout_candidate/outside_band = new
	outside_band.id = "axial_low"
	outside_band.pattern_id = "axial_fallback"
	outside_band.topology_family = "axial_fallback"
	outside_band.score = 700
	var/list/candidates = list(best_hub, weaker_same_family, eligible_split, outside_band)
	var/list/selected_ids = list()
	for(var/seed_value in 1 to 32)
		state.root_seed = seed_value
		var/datum/world_edit_building_layout_candidate/selected = generator.select_seeded_building_layout_family_winner(context, candidates)
		TEST_ASSERT_NOTNULL(selected, "Seeded family selection returned no candidate for seed [seed_value].")
		TEST_ASSERT(selected == best_hub || selected == eligible_split, "Seeded family selection admitted a duplicate-family loser or a candidate below the quality floor.")
		TEST_ASSERT(round(text2num("[state.config["layout_selected_candidate_score_gap"]]") || 0) <= 100, "Seeded family selection exceeded the bounded quality gap.")
		selected_ids[selected.id] = TRUE
		var/datum/world_edit_building_layout_candidate/replay = generator.select_seeded_building_layout_family_winner(context, candidates)
		TEST_ASSERT_EQUAL(replay.id, selected.id, "Same-seed family selection replay changed candidate id.")
	TEST_ASSERT_EQUAL(length(selected_ids), 2, "Cross-seed family selection did not exercise both quality-admissible topology families.")

/datum/unit_test/world_edit_building_layout/synthetic_empty_large_room_rejected/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_state/state = new
	var/datum/world_edit_building_layout_program_contract/program = new
	var/datum/world_edit_building_layout_context/context = new(generator, state, program)
	var/datum/world_edit_building_layout_candidate/candidate = new
	var/datum/world_edit_building_layout_room_plan/room = new("empty_room", "empty_room", "hub", "empty_room")
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Empty-room synthetic test could not resolve an anchor turf.")
	room.x1 = anchor_turf.x
	room.y1 = anchor_turf.y
	room.x2 = anchor_turf.x + 3
	room.y2 = anchor_turf.y + 3
	for(var/turf/room_turf in block(anchor_turf, locate(room.x2, room.y2, anchor_turf.z)))
		room.turfs += room_turf
	candidate.room_plans += room
	generator.validate_building_layout_room_quality(context, candidate)
	TEST_ASSERT_EQUAL(state.validation.layout_empty_large_room_count, 1, "A large room without a composition must fail the canonical empty-room counter.")

/datum/unit_test/world_edit_building_layout/synthetic_invalid_shared_wall_rejected/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_state/state = new
	var/datum/world_edit_building_layout_program_contract/program = new
	var/datum/world_edit_building_layout_context/context = new(generator, state, program)
	var/datum/world_edit_building_layout_candidate/candidate = new
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Invalid-shared-wall synthetic test could not resolve an anchor turf.")
	candidate.add_door_plan(new /datum/world_edit_building_layout_route_opening_plan("invalid_door", "door", anchor_turf, NORTH, "missing_room", "route"))
	generator.validate_building_layout_opening_quality(context, candidate)
	TEST_ASSERT(state.validation.layout_door_no_shared_wall_count > 0, "A door without a shared-wall segment must fail layout_door_no_shared_wall_count.")
	TEST_ASSERT(state.validation.layout_door_not_on_shared_wall_count > 0, "A door outside the partition graph must fail layout_door_not_on_shared_wall_count.")

/datum/unit_test/world_edit_building_layout/synthetic_blocked_negative_space_rejected/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_building_layout_state/state = new
	var/datum/world_edit_building_layout_program_contract/program = new
	var/datum/world_edit_building_layout_context/context = new(generator, state, program)
	var/datum/world_edit_building_layout_candidate/candidate = new
	var/turf/focus_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(focus_turf, "Negative-space synthetic test could not resolve an anchor turf.")
	var/turf/blocked_turf = get_step(focus_turf, EAST)
	var/datum/world_edit_building_layout_room_plan/room = new("blocked_room", "blocked_room", "hub", "blocked_room")
	room.turfs = list(focus_turf, blocked_turf)
	room.x1 = min(focus_turf.x, blocked_turf.x)
	room.x2 = max(focus_turf.x, blocked_turf.x)
	room.y1 = focus_turf.y
	room.y2 = focus_turf.y
	var/datum/world_edit_building_layout_scene_plan/scene = new
	scene.scene_contract_id = "blocked_scene"
	scene.primary_anchors["focus"] = focus_turf
	scene.add_member("table", "table", focus_turf, SOUTH, "primary", FALSE, TRUE)
	scene.add_member("chair", "chair", blocked_turf, NORTH, "secondary", FALSE, FALSE)
	scene.negative_space_turfs += blocked_turf
	scene.no_furniture_lookup[blocked_turf] = TRUE
	room.scene_plan = scene
	candidate.room_plans += room
	var/datum/world_edit_building_layout_scene_contract/scene_contract = new("blocked_scene", "room_identity")
	program.add_scene_contract(scene_contract)
	generator.validate_building_layout_scene_quality(context, candidate)
	TEST_ASSERT_EQUAL(state.validation.layout_scene_blocks_negative_space_count, 1, "A scene member inside reserved negative space must fail the canonical counter.")


/datum/unit_test/world_edit_building_layout/living_sanitation_connected/Run()
	var/datum/world_edit_building_layout_state/state = build_living_point_state(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"building_seed" = 1,
	))
	TEST_ASSERT_NOTNULL(state, "Living layout state did not build.")
	TEST_ASSERT(!state.has_errors(), length(state.validation.errors) ? state.validation.errors[1] : "Living layout state has errors.")
	TEST_ASSERT(length(state.get_zone_turfs("sanitation")) >= 2, "Sanitation zone missing or too small.")
	var/datum/world_edit_generator/building_layout/generator = new
	TEST_ASSERT(generator.building_zone_touches_circulation(state, "sanitation"), "Sanitation is not connected to circulation.")

/datum/unit_test/world_edit_building_layout/sealed_sanitation_rejected/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/list/config = generator.normalize_building_params(list("archetype_id" = "living", "half_width" = 6, "half_depth" = 6))
	var/datum/world_edit_building_request/request = new
	request.config = config
	request.archetype = generator.get_building_archetype("living")
	var/datum/world_edit_building_layout_state/state = new
	state.config = config
	state.request = request
	state.archetype = request.archetype
	state.semantic_plan = request.archetype.build_semantic_plan(request)
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Sealed sanitation test could not resolve anchor turf.")
	prepare_building_test_canvas(anchor_turf, 4)
	var/turf/other_turf = get_step(anchor_turf, EAST)
	TEST_ASSERT_NOTNULL(other_turf, "Sealed sanitation test could not resolve second turf.")
	state.geometry.floor_turfs += anchor_turf
	state.geometry.floor_turfs += other_turf
	state.geometry.floor_lookup[anchor_turf] = TRUE
	state.geometry.floor_lookup[other_turf] = TRUE
	state.add_zone(anchor_turf, "sanitation")
	state.add_zone(other_turf, "sanitation")

	generator.validate_building_route_touch(state)
	TEST_ASSERT(has_error_containing(state, "Required zone 'sanitation' is not connected"), "Validator should reject sealed sanitation.")

/datum/unit_test/world_edit_building_layout/explicit_small_size_locked/Run()
	var/datum/world_edit_plan/plan = build_living_point_plan(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"auto_size" = FALSE,
		"half_width" = 2,
		"half_depth" = 2,
		"detail_budget" = 0,
		"window_density" = 0,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	))
	TEST_ASSERT_NOTNULL(plan, "Small explicit building plan was not created.")
	TEST_ASSERT(plan.metadata["error"], "Small explicit building should be rejected instead of hidden compact/micro generation.")
	TEST_ASSERT_EQUAL(round(text2num("[plan.metadata["half_width"]]") || 0), 2, "Explicit half_width changed.")
	TEST_ASSERT_EQUAL(round(text2num("[plan.metadata["half_depth"]]") || 0), 2, "Explicit half_depth changed.")
	TEST_ASSERT(!GLOB.world_edit_helpers.parse_bool(plan.metadata["size_auto_adjusted"]), "Explicit size was auto-adjusted.")
	TEST_ASSERT_EQUAL(plan.metadata["current_request_support_status"], "UNSUPPORTED_WITH_CLEAR_ERROR", "Small explicit building returned the wrong support status.")
	var/list/support_report = plan.metadata["support_status_report"]
	TEST_ASSERT(islist(support_report), "Small explicit building did not include support diagnostics.")
	TEST_ASSERT_EQUAL(support_report["lock_code"], "program.insufficient_footprint", "Small explicit building returned the wrong lock code.")
	var/list/support_verdict = support_report["verdict"]
	TEST_ASSERT(islist(support_verdict), "Small explicit building support diagnostics did not include a validation verdict.")
	TEST_ASSERT_EQUAL(support_verdict["status"], "unsupported", "Small explicit building support verdict returned the wrong status.")
	var/list/hard_errors = support_verdict["hard_errors"]
	TEST_ASSERT(length(hard_errors) > 0, "Small explicit building support verdict did not include a hard error.")
	var/list/first_error = hard_errors[1]
	TEST_ASSERT_EQUAL(first_error["code"], "program.insufficient_footprint", "Small explicit building support verdict returned the wrong hard error code.")
	TEST_ASSERT(!GLOB.world_edit_helpers.parse_bool(plan.metadata["program_shedding"]), "Small explicit building enabled hidden program shedding.")
	TEST_ASSERT_EQUAL(length(plan.placements), 0, "Small explicit building emitted placements despite rejection.")

/datum/unit_test/world_edit_building_layout/micro_size_locked/Run()
	var/datum/world_edit_plan/plan = build_living_point_plan(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"auto_size" = FALSE,
		"half_width" = 1,
		"half_depth" = 1,
		"detail_budget" = 0,
		"window_density" = 0,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	))
	TEST_ASSERT_NOTNULL(plan, "Micro building plan was not created.")
	TEST_ASSERT(plan.metadata["error"], "Micro building should be rejected instead of hidden micro generation.")
	TEST_ASSERT_EQUAL(plan.metadata["current_request_support_status"], "UNSUPPORTED_WITH_CLEAR_ERROR", "Micro building returned the wrong support status.")
	var/list/support_report = plan.metadata["support_status_report"]
	TEST_ASSERT(islist(support_report), "Micro building did not include support diagnostics.")
	TEST_ASSERT_EQUAL(support_report["lock_code"], "program.insufficient_footprint", "Micro building returned the wrong lock code.")
	var/list/support_verdict = support_report["verdict"]
	TEST_ASSERT(islist(support_verdict), "Micro building support diagnostics did not include a validation verdict.")
	TEST_ASSERT_EQUAL(support_verdict["status"], "unsupported", "Micro building support verdict returned the wrong status.")
	var/list/hard_errors = support_verdict["hard_errors"]
	TEST_ASSERT(length(hard_errors) > 0, "Micro building support verdict did not include a hard error.")
	var/list/first_error = hard_errors[1]
	TEST_ASSERT_EQUAL(first_error["code"], "program.insufficient_footprint", "Micro building support verdict returned the wrong hard error code.")
	TEST_ASSERT(!GLOB.world_edit_helpers.parse_bool(plan.metadata["program_shedding"]), "Micro building enabled hidden program shedding.")
	TEST_ASSERT(!GLOB.world_edit_helpers.parse_bool(plan.metadata["micro_layout"]), "Micro building used hidden micro layout.")
	TEST_ASSERT_EQUAL(length(plan.placements), 0, "Micro building emitted placements despite rejection.")

/datum/unit_test/world_edit_building_layout/request_key_shape_params/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/key_a = generator.build_building_runtime_request_key(list(
		"auto_size" = FALSE,
		"half_width" = 4,
		"half_depth" = 4,
		"shape_radius" = 4,
	))
	var/key_b = generator.build_building_runtime_request_key(list(
		"auto_size" = FALSE,
		"half_width" = 4,
		"half_depth" = 4,
		"shape_radius" = 5,
	))
	TEST_ASSERT(key_a != key_b, "Building runtime request key should change when shape params change.")

/datum/unit_test/world_edit_building_layout/atomic_apply_rejects_stale_target_state/Run()
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Atomic apply test could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf, 16)
	var/datum/world_edit_generator/building_layout/generator = new
	var/datum/world_edit_shape_contract/shape_contract = build_point_shape_contract(anchor_turf)
	var/list/params = list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
		"building_seed" = 31,
		"detail_budget" = 60,
		"replace_blocked_turfs" = TRUE,
		"respect_blockers" = FALSE,
	)
	var/datum/world_edit_plan/plan = generator.build_plan_from_shape_contract(null, shape_contract, params, build_point_context(shape_contract, anchor_turf))
	TEST_ASSERT_NOTNULL(plan, "Atomic apply test did not create a preview plan.")
	TEST_ASSERT(!plan.metadata["error"], "Atomic apply preview failed: [plan.metadata["error"]]")
	var/expected_target_hash = round(text2num("[plan.metadata["target_state_hash"]]") || 0)
	TEST_ASSERT(expected_target_hash > 0, "Preview plan did not stamp a target-state hash.")

	var/turf/drift_turf = null
	for(var/list/placement as anything in plan.placements)
		if(!islist(placement))
			continue
		var/kind = "[placement["kind"]]"
		if(!(kind in list("floor", "wall")))
			continue
		var/turf/candidate_turf = get_plan_placement_turf(placement)
		if(istype(candidate_turf) && !istype(candidate_turf, /turf/closed/wall))
			drift_turf = candidate_turf
			break
	TEST_ASSERT_NOTNULL(drift_turf, "Atomic apply test could not find a mutable target turf.")
	var/original_type = drift_turf.type
	var/original_baseturfs = islist(drift_turf.baseturfs) ? drift_turf.baseturfs.Copy() : drift_turf.baseturfs
	var/turf/changed_turf = drift_turf.ChangeTurf(/turf/closed/wall)
	TEST_ASSERT(istype(changed_turf, /turf/closed/wall), "Atomic apply test failed to mutate the target turf after preview.")
	var/current_target_hash = round(text2num("[generator.build_building_target_state_hash(plan)]") || 0)
	TEST_ASSERT(current_target_hash != expected_target_hash, "Target-state hash did not change after live target mutation: expected=[expected_target_hash], current=[current_target_hash], turf=[changed_turf.type] at [changed_turf.x],[changed_turf.y],[changed_turf.z].")

	var/datum/world_edit_apply_result/apply_result = generator.apply_plan(null, params, plan)
	TEST_ASSERT_NOTNULL(apply_result, "Stale target apply did not return an apply result.")
	TEST_ASSERT(!apply_result.success, "Stale target apply must not report success.")
	TEST_ASSERT(apply_result.suppress_history, "Stale target apply must suppress history.")
	TEST_ASSERT(isnull(apply_result.changeset), "Stale target apply must not create a committed changeset.")
	TEST_ASSERT_EQUAL(apply_result.meta["transaction_committed"], FALSE, "Stale target apply must not commit a transaction.")
	TEST_ASSERT_EQUAL(apply_result.meta["changed_turf_count"] || 0, 0, "Stale target apply must not change turfs.")
	TEST_ASSERT_EQUAL(apply_result.meta["created_object_count"] || 0, 0, "Stale target apply must not create objects.")
	TEST_ASSERT(apply_result.meta["target_state_mismatch"], "Stale target apply did not report target-state mismatch.")
	var/list/apply_verdict = apply_result.meta["apply_validation_verdict"]
	TEST_ASSERT(islist(apply_verdict), "Stale target apply did not include an apply validation verdict.")
	TEST_ASSERT_EQUAL(apply_verdict["status"], "world_conflict", "Stale target apply returned the wrong verdict status.")
	var/list/verdict_metrics = apply_verdict["metrics"]
	TEST_ASSERT(islist(verdict_metrics), "Stale target apply verdict did not include metrics.")
	TEST_ASSERT_EQUAL(verdict_metrics["transaction_committed"], FALSE, "Stale target apply verdict must report no commit.")
	TEST_ASSERT_EQUAL(verdict_metrics["suppress_history"], TRUE, "Stale target apply verdict must report history suppression.")
	TEST_ASSERT_EQUAL(verdict_metrics["changed_turf_count"] || 0, 0, "Stale target apply verdict must report zero turf changes.")
	TEST_ASSERT_EQUAL(verdict_metrics["created_object_count"] || 0, 0, "Stale target apply verdict must report zero created objects.")
	var/list/hard_errors = apply_verdict["hard_errors"]
	var/found_stale_error = FALSE
	for(var/list/error_entry as anything in hard_errors)
		if(islist(error_entry) && error_entry["code"] == "apply_target_state_mismatch")
			found_stale_error = TRUE
			break
	TEST_ASSERT(found_stale_error, "Stale target apply verdict did not include apply_target_state_mismatch.")
	TEST_ASSERT(istype(changed_turf, /turf/closed/wall), "Stale target apply mutated the drift target despite failure.")
	changed_turf.ChangeTurf(original_type, original_baseturfs)

/datum/unit_test/world_edit_building_layout/safe_blocker_defaults/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/list/config = generator.normalize_building_params(list(
		"archetype_id" = "living",
		"faction_preset" = "colony",
	))
	TEST_ASSERT(!config["error"], "Default building config failed to normalize: [config["error"]]")
	TEST_ASSERT(config["respect_blockers"], "Building layout must respect blockers by default.")
	TEST_ASSERT(!config["replace_blocked_turfs"], "Building layout must not replace blocked turfs by default.")

/datum/unit_test/world_edit_building_layout/locked_unsupported_shape/Run()
	var/datum/world_edit_generator/building_layout/generator = new
	var/turf/anchor_turf = get_test_anchor_turf()
	TEST_ASSERT_NOTNULL(anchor_turf, "Advertised shape test could not resolve an anchor turf.")
	prepare_building_test_canvas(anchor_turf, 16)
	var/list/supported_shapes = generator.get_supported_placement_shapes()
	TEST_ASSERT_EQUAL(length(supported_shapes), 3, "Building layout must advertise exactly three supported shapes.")
	TEST_ASSERT(WORLD_EDIT_SHAPE_POINT in supported_shapes, "Building layout must advertise point placement.")
	TEST_ASSERT(WORLD_EDIT_SHAPE_RECTANGLE in supported_shapes, "Building layout must advertise rectangle placement.")
	TEST_ASSERT(WORLD_EDIT_SHAPE_FILLED_RECTANGLE in supported_shapes, "Building layout must advertise filled rectangle placement.")
	for(var/shape_id as anything in generator.get_supported_placement_shapes())
		var/list/shape_params = generator.build_building_quality_shape_params(shape_id, 12345, 8, 8)
		var/list/shape_context = generator.build_building_quality_shape_context(anchor_turf, shape_id, shape_params)
		TEST_ASSERT(islist(shape_context), "Shape context was not created for [shape_id].")
		var/datum/world_edit_shape_contract/shape_contract = shape_context["shape_contract"]
		var/list/placement_context = shape_context["placement_context"]
		var/list/params = list(
			"archetype_id" = "living",
			"faction_preset" = "colony",
			"auto_size" = FALSE,
			"half_width" = 8,
			"half_depth" = 8,
			"detail_budget" = 20,
			"replace_blocked_turfs" = TRUE,
			"respect_blockers" = FALSE,
		)
		for(var/shape_param as anything in shape_params)
			params[shape_param] = shape_params[shape_param]
		var/datum/world_edit_plan/plan = generator.build_plan_from_shape_contract(null, shape_contract, params, placement_context)
		TEST_ASSERT_NOTNULL(plan, "Plan was null for shape [shape_id].")
		TEST_ASSERT(!plan.metadata["error"], "Advertised shape [shape_id] failed: [plan.metadata["error"]]")
	for(var/shape_id as anything in list(
		WORLD_EDIT_SHAPE_LINE,
		WORLD_EDIT_SHAPE_CIRCLE,
		WORLD_EDIT_SHAPE_RING,
		WORLD_EDIT_SHAPE_ELLIPSE,
		WORLD_EDIT_SHAPE_DIAMOND,
		WORLD_EDIT_SHAPE_TRIANGLE,
		WORLD_EDIT_SHAPE_SECTOR,
		WORLD_EDIT_SHAPE_POLYGON,
		WORLD_EDIT_SHAPE_POLYLINE,
		WORLD_EDIT_SHAPE_CUSTOM_MASK,
		WORLD_EDIT_SHAPE_BRUSH_PATH,
		WORLD_EDIT_SHAPE_SCATTER_CLUSTER
	))
		var/list/support = generator.get_placement_shape_support_report(shape_id, list(
			"archetype_id" = "living",
			"faction_preset" = "colony",
		), null)
		TEST_ASSERT(support["shape_locked"], "Unsupported shape [shape_id] should be shape-locked.")
		TEST_ASSERT_EQUAL(support["lock_code"], "shape.unsupported_for_building_layout", "Unsupported shape [shape_id] returned the wrong lock code.")
		var/list/support_verdict = support["verdict"]
		TEST_ASSERT(islist(support_verdict), "Unsupported shape [shape_id] support report did not include a validation verdict.")
		TEST_ASSERT_EQUAL(support_verdict["status"], "unsupported", "Unsupported shape [shape_id] support verdict returned the wrong status.")
		var/list/hard_errors = support_verdict["hard_errors"]
		TEST_ASSERT(length(hard_errors) > 0, "Unsupported shape [shape_id] support verdict did not include a hard error.")
		var/list/first_error = hard_errors[1]
		TEST_ASSERT_EQUAL(first_error["code"], "shape.unsupported_for_building_layout", "Unsupported shape [shape_id] support verdict returned the wrong hard error code.")
